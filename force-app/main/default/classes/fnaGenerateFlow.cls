public without sharing class fnaGenerateFlow {

    public class Data{
        @AuraEnabled
        public String avatar {get;set;}
        @AuraEnabled
        public String question {get;set;}
        @AuraEnabled
        public List<String> answer {get;set;}
    }

    public class Data_Duplicate{
        @AuraEnabled
        public List<String> avatar {get;set;}
        @AuraEnabled
        public List<String> question {get;set;}
        @AuraEnabled
        public List<String> answer {get;set;}
    }

    @AuraEnabled //check duplicate
    public static List<Data_Duplicate> checkAnswerFlow(List<Avatar_Result_Mapping_Temp__c> answerFlow) {

        List<Data_Duplicate> model_list_check = new List<Data_Duplicate>();
        String tempCheckUnique = null;

        for(integer count_answerFlow = 0;count_answerFlow<answerFlow.size();count_answerFlow++){
            
            if(count_answerFlow+1 < answerFlow.size()){
                if(answerFlow[count_answerFlow].unique__c == answerFlow[count_answerFlow+1].unique__c){
                    Data_Duplicate model_obj_check = new Data_Duplicate();
                    model_obj_check.avatar = new List<String>();
                    model_obj_check.question = new List<String>();
                    model_obj_check.answer = new List<String>();

                    model_obj_check.avatar.add(answerFlow[count_answerFlow].Avatar_Master__c);
                    model_obj_check.question.add(answerFlow[count_answerFlow].Questionnaire_Flow__c);
                    model_obj_check.answer.add(answerFlow[count_answerFlow].Answer_Flow__c);

                    system.debug('Avatar_Master__c : ' + answerFlow[count_answerFlow].Avatar_Master__c);
                    system.debug('Questionnaire_Flow__c : ' + answerFlow[count_answerFlow].Questionnaire_Flow__c);
                    system.debug('Answer_Flow__c : ' + answerFlow[count_answerFlow].Answer_Flow__c);

                    model_list_check.add(model_obj_check);
                }
            }
        }
        system.debug('model_list_check : ' + model_list_check);

        return model_list_check;
    }

    public List<String> findAnswer_AvatarFlow(List<Avatar_Combination__c> FlowA_DB) {
        List<String> listFlowQ = new List<String>();

        //Matrix Algorithm
        List<String> tempFirst = new List<String>();
        List<String> tempSecond = new List<String>(); 
        String avatarTemp = '';
        
        for(integer count_DB = 0;count_DB<FlowA_DB.size();count_DB++){
            //split ',' to store answer array
            String[] tempSplit = FlowA_DB[count_DB].Answer__c.split(',');

            if(tempFirst.isEmpty()){
                //store avatar to check same avatar
                avatarTemp = FlowA_DB[count_DB].Avatar_Master__c;
                tempFirst.addAll(tempSplit); // [A,B,C,D]
            }
            else {
                if(avatarTemp == FlowA_DB[count_DB].Avatar_Master__c){

                    integer tempFirstSize = tempFirst.size();
                    List<String> tempBeforeDuplicate = new List<String>(); 
                    List<String> tempAfterDuplicate = new List<String>(); 
                    tempBeforeDuplicate.addAll(tempFirst);
                    for(integer countForSplitSize = 0;countForSplitSize < tempSplit.size()-1;countForSplitSize++){
                        tempAfterDuplicate = tempBeforeDuplicate.clone();
                        tempFirst.addAll(tempAfterDuplicate);
                    }
                    integer countFirstSize = 0;
                    integer countSplitSize = 0;
                    for(String forTempFirst : tempFirst){
                        if(countSplitSize < tempSplit.size()){
                            if(countFirstSize >= tempFirstSize){
                                countFirstSize = 0;
                                countSplitSize++;
                            }
                            forTempFirst += tempSplit[countSplitSize];
                            tempSecond.add(forTempFirst);
                            countFirstSize++;
                        }
                    }
                    tempFirst.clear();
                    tempFirst.addAll(tempSecond); 
                    tempSecond.clear();
                }
                else{
                    continue;
                }
            }
        }
        listFlowQ.addAll(tempFirst);
        return listFlowQ;
    }

    public List<String> findQuestionFlow(List<String> avatarResult,List<Avatar_Combination__c> FlowQ_DB) {
        String avatarTemp = '';
        String qFlow = '';
        List<String> questionFlowTemp = new List<String>();

        for(integer count_DB = 0;count_DB<FlowQ_DB.size();count_DB++){
            if(avatarTemp == ''){
                avatarTemp = FlowQ_DB[count_DB].Avatar_Master__c;
                qFlow = FlowQ_DB[count_DB].Question__c;
                avatarResult.add(FlowQ_DB[count_DB].Avatar_Master__c);
            }
            else{
                if (avatarTemp == FlowQ_DB[count_DB].Avatar_Master__c){
                    qFlow += FlowQ_DB[count_DB].Question__c;

                    if(count_DB == FlowQ_DB.size()-1){
                        questionFlowTemp.add(qFlow);
                        system.debug('questionFlowTemp : ' + questionFlowTemp);
                    }
                }
                else{
                    questionFlowTemp.add(qFlow);
                    system.debug('questionFlowTemp : ' + questionFlowTemp);
                    avatarResult.add(FlowQ_DB[count_DB].Avatar_Master__c);

                    qFlow = FlowQ_DB[count_DB].Question__c;
                    avatarTemp = FlowQ_DB[count_DB].Avatar_Master__c;   
                }
            }
        }
        system.debug('questionFlowTemp : ' + questionFlowTemp.size());
        system.debug('avatarResult : ' + avatarResult.size());
        system.debug('FlowQ_DB : ' + FlowQ_DB.size());

        return questionFlowTemp;
    }

    @AuraEnabled
    public static void generateFlow() {
        fnaDeleteAvatarResultMappingTemp deleteAvatarResultMapping = new fnaDeleteAvatarResultMappingTemp(true); 
		Id batchId = Database.executeBatch(deleteAvatarResultMapping);
        system.debug('batchId : ' + batchId);
    }

    @AuraEnabled
    public static void confirmFlow(){
        fnaInsertToAvatarResultMappingBatch insertToAvatarResultMapping = new fnaInsertToAvatarResultMappingBatch(); 
		Id batchId = Database.executeBatch(insertToAvatarResultMapping);
        system.debug('batchId : ' + batchId);
    }

    @AuraEnabled
    public static Boolean checkTemp(){
        List<Avatar_Result_Mapping_Temp__c> avatarResultMappingTemp = [SELECT Id, Avatar_Master__c, Questionnaire_Flow__c, Answer_Flow__c, unique__c, isDuplicate__c FROM Avatar_Result_Mapping_Temp__c WHERE isDuplicate__c =: true];
        List<Avatar_Result_Mapping_Temp__c> avatarResultMappingTempAll = [SELECT Id, Avatar_Master__c, Questionnaire_Flow__c, Answer_Flow__c, unique__c, isDuplicate__c FROM Avatar_Result_Mapping_Temp__c];
        system.debug('avatarResultMappingTemp : ' + avatarResultMappingTemp);
        system.debug('avatarResultMappingTempAll : ' + avatarResultMappingTempAll);
        if(avatarResultMappingTemp.size() > 0){
            system.debug('Fail : Duplicate');
            return false;
        }
        else if(avatarResultMappingTempAll.size() == 0){
            system.debug('Fail : Nullable');
            return false;
        }
        else{
            system.debug('Success : Not duplicate');
            return true;
        }
    }
}