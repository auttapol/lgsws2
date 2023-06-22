global class fnaInsertToAvatarResultMappingBatch implements 
	Database.Batchable<sObject>, Database.Stateful {
        public class errLogs{
            @AuraEnabled
            public String Id {get;set;}
            @AuraEnabled
            public String fieldErr {get;set;}
            @AuraEnabled
            public String statusCode {get;set;}
            @AuraEnabled
            public String errMesg {get;set;}
        }
        public List<errLogs> errLogsAll = new List<errLogs>();
        public static final List<String> EMAIL_SENT_TO_ALERT = new List<String>{ 'CRM Admin 2' };        
        private Datetime startTime;
        private Datetime endTime;
        private Integer recordsSuccessful = 0;
        private Integer recordsFailed = 0;
        private String errorMessage = '';

        private String bodyTextSuccess = '<h2>SUCCESS</h2>';
        private String bodyTextFailed = 'Please check your avatar mapping temp, field and confirm again, go to : ' + fnaAvatarResultMappingSendEmail.getDomain();

        global Database.QueryLocator start(Database.BatchableContext bc) {
            // collect the batches of records or objects to be passed to execute
            startTime = DateTime.now();
            return Database.getQueryLocator('SELECT Id, Avatar_Master__c, Questionnaire_Flow__c, Answer_Flow__c, unique__c FROM Avatar_Result_Mapping_Temp__c');
        }
        global void execute(Database.BatchableContext bc, List<Avatar_Result_Mapping_Temp__c> avatarResultMappingTemp){
            // process each batch of records
            system.debug('avatarResultMappingTemp : ' + avatarResultMappingTemp);

            List<Avatar_Master__c> avatarMaster = [SELECT Id, Segment__c FROM Avatar_Master__c ORDER BY Id ASC]; 
            System.debug('avatarMaster : ' + avatarMaster);

            Map<String, String> mapName = new Map<String, String>(); 
            for(Avatar_Master__c avatarTemp : avatarMaster){
                mapName.put(avatarTemp.Id,avatarTemp.Segment__c);
            }

            List<AvatarResultMapping__c> avatarResultMapping = new List<AvatarResultMapping__c>();

            for(Avatar_Result_Mapping_Temp__c avatarTemp : avatarResultMappingTemp){
                AvatarResultMapping__c avatarResultMappingObj = new AvatarResultMapping__c();
                avatarResultMappingObj.AvatarMaster__c = avatarTemp.Avatar_Master__c;
                avatarResultMappingObj.QuestionnaireFlow__c = avatarTemp.Questionnaire_Flow__c;
                avatarResultMappingObj.Answer__c = avatarTemp.Answer_Flow__c; //Change Answer2
                //isActive = false
                system.debug('avatarResultMappingObj : ' + avatarResultMappingObj);
                avatarResultMapping.add(avatarResultMappingObj);
            }
            system.debug('avatarResultMapping : ' + avatarResultMapping);
            system.debug('avatarResultMapping.size : ' + avatarResultMapping.size());

            Database.SaveResult[] srList = Database.insert(avatarResultMapping, false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated Mix ' + sr.getId());
                    recordsSuccessful += 1;
                }
                else {
                    // Operation failed, so get all errors    
                    System.debug('sr.getId(): ' + sr.getId());
                    errLogs errLogObj = new errLogs();
                    errLogObj.Id = sr.getId();
                    for(Database.Error err : sr.getErrors()){
                        System.debug('eer: ' + err);
                        System.debug('err.getMessage() : ' + err.getMessage());
                        errLogObj.fieldErr = string.valueOf(err.getFields());
                        errLogObj.statusCode = string.valueOf(err.getStatusCode());
                        errLogObj.errMesg = err.getMessage();
                        errLogsAll.add(errLogObj);
                    }
                    recordsFailed += 1;
                    System.debug('errLogsAll : ' + errLogsAll);
                }
            }
            System.debug('recordsSuccessful : ' + recordsSuccessful);
            System.debug('recordsFailed : ' + recordsFailed);

        }    
        global void finish(Database.BatchableContext bc){
            // execute any post-processing operations
            endTime = DateTime.now();
            System.debug('finish batch insert to AvatarResultMapping');            
            if(recordsFailed == 0){
                //Remove old data in avatar result mapping when move temp to avatar result mapping (no failed)
                String queryTrue = 'SELECT Id, CreatedDate, CreatedBy.Name, QuestionnaireFlow__c, Answer__c, AvatarMaster__c, Segment__c, isActive__c FROM AvatarResultMapping__c WHERE isActive__c = true';
                fnaDeleteAvatarResultMappingBatch deleteAvatarResultMappingTrue = new fnaDeleteAvatarResultMappingBatch(queryTrue,true); 
                Id batchIdARMT = Database.executeBatch(deleteAvatarResultMappingTrue);

                System.debug('Success to isActive change false -> true');

                //Delete avatar result temp when success move to avatar result mapping
                fnaDeleteAvatarResultMappingTemp deleteAvatarResultMapping = new fnaDeleteAvatarResultMappingTemp(false); 
                Id batchIdDeleteARM = Database.executeBatch(deleteAvatarResultMapping);

                System.debug('Success to remove avatarResultMappingTemp');
            }
            else{
                //Rollback
                String queryFalse = 'SELECT Id, CreatedDate, CreatedBy.Name, QuestionnaireFlow__c, Answer__c, AvatarMaster__c, Segment__c, isActive__c FROM AvatarResultMapping__c WHERE isActive__c = false';
                fnaDeleteAvatarResultMappingBatch deleteAvatarResultMappingFalse = new fnaDeleteAvatarResultMappingBatch(queryFalse,false); 
                Id batchIdDeleteARMF = Database.executeBatch(deleteAvatarResultMappingFalse);
                System.debug('Success to remove isActive = false');
            }

            String query = '[SELECT Id, QuestionnaireFlow__c, Answer__c, AvatarMaster__c, Segment__c, isActive__c FROM AvatarResultMapping__c WHERE isActive__c = false]';
            System.debug('Send Email');

            String errorMsg = '';
            for(errLogs err : errLogsAll){
                errorMsg = err.Id + ','
                        + err.fieldErr + ','
                        + err.statusCode + ','
                        + err.errMesg + '\n';
                errorMessage += errorMsg;
            }

            EMAIL_SENT_TO_ALERT.add(UserInfo.getUserEmail());

            System.debug('Datetime.now() : ' + Datetime.now());
            System.debug('startTime : ' + startTime);
            System.debug('endTime : ' + endTime);
            System.debug('recordsSuccessful : ' + recordsSuccessful);
            System.debug('recordsFailed : ' + recordsFailed);
            System.debug('EMAIL_SENT_TO_ALERT : ' + EMAIL_SENT_TO_ALERT);
            System.debug('errorMessage : ' + errorMessage);
            System.debug('query : ' + query);


            fnaAvatarResultMappingSendEmail.SendFinishDailyBatchSummaryEmail(
                Datetime.now(),
                startTime,
                Datetime.now(),
                recordsSuccessful,
                recordsFailed,
                'Avatar_Result_Mapping',
                'Avatar Result Mapping',
                EMAIL_SENT_TO_ALERT,
                errorMessage, // mainError '001,test1c,404,Not Found\n002,test2c,503,Unavailiable\n'
                '', // secondaryError
                '', // successLog
                'Avatar Result Mapping ID,Field Error,StatusCode,Error Message\n', // mainErrorHeader
                '', // secondaryErrorHeader
                '', // successLogHeader
                query,
                bodyTextSuccess,
                bodyTextFailed,
                ''
            );
            System.debug('Success to Send Email');
            
        }    
    }