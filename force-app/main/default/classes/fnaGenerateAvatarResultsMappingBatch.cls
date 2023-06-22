global class fnaGenerateAvatarResultsMappingBatch implements 
	Database.Batchable<sObject>, Database.Stateful {
        public class Data{
            @AuraEnabled
            public String avatar {get;set;}
            @AuraEnabled
            public String question {get;set;}
            @AuraEnabled
            public List<String> answer {get;set;}
        }
        public class DataSendEmail{
            @AuraEnabled
            public String segment {get;set;}
            @AuraEnabled
            public String avatar {get;set;}
            @AuraEnabled
            public String question {get;set;}
            @AuraEnabled
            public List<String> answer {get;set;}
        }
        private Datetime startTime;
        private Datetime endTime;
        private Integer recordsSuccessful = 0;
        private Integer recordsFailed = 0;
        private String errorMessage = '';

        private String bodyTextSuccess = 'Please confirm your process, go to : ' + fnaAvatarResultMappingSendEmail.getDomain();
        private String bodyTextFailed = 'Please check your avatar combination and generate again, go to : ' + fnaAvatarResultMappingSendEmail.getDomain();
        private String bodyTextFailedByServer = '';

        public static final List<String> EMAIL_SENT_TO_ALERT = new List<String>{ 'CRM Admin 2' };

        private List<Avatar_Result_Mapping_Temp__c> avatarForCheck = new List<Avatar_Result_Mapping_Temp__c>();
        private List<Avatar_Result_Mapping_Temp__c> tempAvatarResultMapping_DB_Global_All = new List<Avatar_Result_Mapping_Temp__c>();
        private Set<Avatar_Result_Mapping_Temp__c> checkAvatarTempIdDuplicate_Global = new Set<Avatar_Result_Mapping_Temp__c>();

        global Database.QueryLocator start(Database.BatchableContext bc) {
            // collect the batches of records or objects to be passed to execute
            startTime = DateTime.now();
            return Database.getQueryLocator('SELECT Id, Segment__c, (SELECT Id, Question__c, Answer__c, Avatar_Master__c, SequenceNo__c, Avatar_Master__r.Id FROM Avatar_Combination__r ORDER BY Segment__c, Avatar_Master__r.Id, SequenceNo__c ASC) FROM Avatar_Master__c');
        }
        global void execute(Database.BatchableContext bc, List<Avatar_Master__c> avatarMasterDB){
            try{
                List<Avatar_Combination__c> avatarCombination = new List<Avatar_Combination__c>();            
                for(Avatar_Master__c tempAvatarMaster : avatarMasterDB){
                    avatarCombination.addAll(tempAvatarMaster.Avatar_Combination__r);
                }
                System.debug('avatarCombination on batch : ' + avatarCombination);
                List<String> questionFlow = new List<String>(); // base of questionFlow
                List<String> avatarFlow = new List<String>();
                
                List<Avatar_Result_Mapping_Temp__c> tempAvatarResultMapping_DB = new List<Avatar_Result_Mapping_Temp__c>();

                //model
                List<Data> temp_model_list = new List<Data>();
                Data temp_model_obj = new Data(); 

                fnaGenerateFlow x = new fnaGenerateFlow();

                questionFlow.addAll(x.findQuestionFlow(avatarFlow,avatarCombination));

                for(integer count_avatar = 0;count_avatar<avatarFlow.size();count_avatar++){
                    List<Avatar_Combination__c> avatarCombiTemp = new List<Avatar_Combination__c>();
                    System.debug('count_avatar : ' + count_avatar);
                    temp_model_obj.avatar = avatarFlow[count_avatar];
                    temp_model_obj.question = questionFlow[count_avatar];
                    // system.debug('avatar : ' + temp_model_obj.avatar);
                    // system.debug('question : ' + temp_model_obj.question);

                    List<String> answerFlow = new List<String>();
                    for(Avatar_Combination__c tempAvatarCombination : avatarCombination){
                        if(tempAvatarCombination.Avatar_Master__c == avatarFlow[count_avatar]){
                            System.debug('tempAvatarCombination : ' + tempAvatarCombination);
                            avatarCombiTemp.add(tempAvatarCombination);
                        }
                    }
                    answerFlow.addAll(x.findAnswer_AvatarFlow(avatarCombiTemp));
                    
                    temp_model_obj.answer = new List<String>();
                    temp_model_obj.answer.addAll(answerFlow);
                    System.debug('temp_model_obj on batch : ' + temp_model_obj);

                    for(String tempModelAnswer : temp_model_obj.answer){
                        Avatar_Result_Mapping_Temp__c tempAvatarResultMapping_DB_obj = new Avatar_Result_Mapping_Temp__c();
                        tempAvatarResultMapping_DB_obj.Answer_Flow__c = tempModelAnswer;
                        tempAvatarResultMapping_DB_obj.Questionnaire_Flow__c = temp_model_obj.question;
                        tempAvatarResultMapping_DB_obj.Avatar_Master__c = temp_model_obj.avatar;
                        tempAvatarResultMapping_DB_obj.unique__c = temp_model_obj.question + tempModelAnswer;

                        tempAvatarResultMapping_DB.add(tempAvatarResultMapping_DB_obj);
                    }
                }
                System.debug('tempAvatarResultMapping_DB on batch : ' + tempAvatarResultMapping_DB);
                System.debug('tempAvatarResultMapping_DB size on batch : ' + tempAvatarResultMapping_DB.size());

                //Add TempAll to global
                tempAvatarResultMapping_DB_Global_All.addAll(tempAvatarResultMapping_DB);

                Set<Id> errorId = new Set<Id>();

                Database.SaveResult[] srList = Database.insert(tempAvatarResultMapping_DB, false);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully updated Mix ' + sr.getId());
                        recordsSuccessful += 1;
                    }
                    else {
                        // Operation failed, so get all errors      
                        System.debug('sr.getErrors() : ' + sr.getErrors());
                        for(Database.Error err : sr.getErrors()){
                            System.debug('err : ' + err);
                            System.debug('err.getMessage() : '+err.getMessage());
                            System.debug(err.getMessage().substring(err.getMessage().indexOf('id: ')+4,err.getMessage().length()));
                            errorId.add(err.getMessage().substring(err.getMessage().indexOf('id: ')+4,err.getMessage().length()));
                        }
                        recordsFailed += 1;
                    }
                }

                System.debug('errorId : ' + errorId);

                List<Avatar_Result_Mapping_Temp__c> checkAvatarTempIdDuplicate = [SELECT Id, Avatar_Master__c, Avatar_Master__r.name, Questionnaire_Flow__c, Answer_Flow__c, unique__c FROM Avatar_Result_Mapping_Temp__c WHERE Id IN :errorId ORDER BY Avatar_Master__c ASC];
                System.debug('checkAvatarTempIdDuplicate : ' + checkAvatarTempIdDuplicate);


                for(Avatar_Result_Mapping_Temp__c tempDuplicateLoop : checkAvatarTempIdDuplicate){
                    tempDuplicateLoop.isDuplicate__c = true;
                }

                checkAvatarTempIdDuplicate_Global.addAll(checkAvatarTempIdDuplicate);

                System.debug('checkAvatarTempIdDuplicate size : ' + checkAvatarTempIdDuplicate.size());
                upsert checkAvatarTempIdDuplicate;

                System.debug('checkAvatarTempIdDuplicate : ' + checkAvatarTempIdDuplicate);
            }
            catch(DmlException e){
                System.debug('The following exception has occurred: ' + e.getMessage());
                bodyTextFailedByServer += 'The following exception has occurred: ' + e.getMessage();
            }
            // process each batch of records
        }

        global void finish(Database.BatchableContext bc){

            System.debug('checkAvatarTempIdDuplicate_Global : ' + checkAvatarTempIdDuplicate_Global);

            for(Avatar_Result_Mapping_Temp__c tempDuplicateLoop : checkAvatarTempIdDuplicate_Global){

                avatarForCheck.add(tempDuplicateLoop);
                System.debug('Avatar_Master__r.name : ' + tempDuplicateLoop.Avatar_Master__r.name);
                System.debug('tempDuplicateLoop.unique__c  :' + tempDuplicateLoop.unique__c);
                for(Avatar_Result_Mapping_Temp__c tempAvatarResultMappingObj : tempAvatarResultMapping_DB_Global_All){

                    if(tempDuplicateLoop.unique__c == tempAvatarResultMappingObj.unique__c && tempDuplicateLoop.Avatar_Master__c != tempAvatarResultMappingObj.Avatar_Master__c){

                        System.debug('Check .Avatar_Master__c : ' + tempDuplicateLoop.Avatar_Master__c);
                        System.debug('All .Avatar_Master__c : ' + tempAvatarResultMappingObj.Avatar_Master__c);
                        avatarForCheck.add(tempAvatarResultMappingObj);
                    }
                }
            }

            String query = '[SELECT Id, Avatar_Master__c, Questionnaire_Flow__c, Answer_Flow__c, unique__c FROM Avatar_Result_Mapping_Temp__c WHERE Id IN :errorId ORDER BY Avatar_Master__c ASC]';
            endTime = DateTime.now();
            System.debug('Send Email');

            // old code wait to implement
            System.debug('avatarForCheck : ' + avatarForCheck);

            List<Avatar_Master__c> avatarMaster = [SELECT Id, Name, Avatar_EN__c, Avatar_TH__c, Segment__c FROM Avatar_Master__c ORDER BY Id ASC]; 
            System.debug('avatarMaster : ' + avatarMaster);

            Map<String, String> mapSegment = new Map<String, String>(); 
            Map<String, String> mapName = new Map<String, String>(); 
            for(Avatar_Master__c avatarTemp : avatarMaster){
                mapSegment.put(avatarTemp.Id,avatarTemp.Segment__c);
                mapName.put(avatarTemp.Id,avatarTemp.Name);
            }
            // String errorMsg = '';
            for(Avatar_Result_Mapping_Temp__c data : avatarForCheck){
                errorMessage += data.Questionnaire_Flow__c + ','
                        + data.Answer_Flow__c + ','
                        + mapSegment.get(data.Avatar_Master__c) + ','
                        + mapName.get(data.Avatar_Master__c) + ','
                        + data.Avatar_Master__c + '\n';
            }

            EMAIL_SENT_TO_ALERT.add(UserInfo.getUserEmail());
            System.debug('EMAIL_SENT_TO_ALERT : ' + EMAIL_SENT_TO_ALERT);

            System.debug('recordsSuccessful : ' + recordsSuccessful);
            System.debug('recordsFailed : ' + recordsFailed);

            fnaAvatarResultMappingSendEmail.SendFinishDailyBatchSummaryEmail(
                Datetime.now(),
                startTime,
                Datetime.now(),
                recordsSuccessful,
                recordsFailed,
                'Avatar_Result_Mapping_Temp',
                'Avatar Result Mapping Temp',
                EMAIL_SENT_TO_ALERT,
                errorMessage, // mainError '001,test1c,404,Not Found\n002,test2c,503,Unavailiable\n'
                '', // secondaryError
                '', // successLog
                'Question,Answer,Avatar Master,Avatar Master Name,Avatar Master ID\n', // mainErrorHeader
                '', // secondaryErrorHeader
                '', // successLogHeader
                query,
                bodyTextSuccess,
                bodyTextFailed,
                bodyTextFailedByServer
            );
            System.debug('Success to Send Email');
        }    
    }