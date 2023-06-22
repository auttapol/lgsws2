public with sharing class campaignMemberCallLogCtrl {
    
    @AuraEnabled
    public static Map<String, Object> getCallLog(String recordId, Integer recLimit){

        Map<String, Object> resultMap = new Map<String, Object>();

        List<Task> selectedTask = [SELECT Id, Subject, Call_Log_ID__c, Call_Agent_Id__c, Call_Number__c,
                                            Call_Start_Datetime__c, Call_End_Time__c, CallType, Owner.Name, ActivityDate
                                    FROM Task
                                    WHERE Related_Object__c = :recordId
                                    AND RecordType.Name = 'Call Log Record Type'
                                    ORDER BY Call_Start_Datetime__c DESC
                                    LIMIT :recLimit];

        List<CampaignMember> selectedCM = [SELECT Id, RTL_Marketing_Code__c FROM CampaignMember WHERE Id = :recordId LIMIT 1];

        if(selectedTask.size() > 0 && selectedCM.size() > 0){
            resultMap.put('task', selectedTask);
            resultMap.put('marketing_code', selectedCM.get(0).RTL_Marketing_Code__c);
        }
        else if(selectedTask.size() > 0 && selectedCM.size() == 0){
            resultMap.put('task', selectedTask);
            resultMap.put('marketing_code', '');
        }

        return resultMap;
        
    }

    @AuraEnabled
    public static List<Task> getCallBackHist(String recordId, Integer recLimit){
        return [SELECT Id, Subject, Call_Log_ID__c, Call_Agent_Id__c, Call_Number__c,Call_Back_Mode__c,Description,
                        Call_Start_Datetime__c, Call_End_Time__c, CallType, Owner.Name, ActivityDate,Marketing_Code__c
                FROM Task
                WHERE RecordType.Name = 'Call Back'
                AND Related_Object__c = :recordId
                AND (Status = 'Completed' OR Status = 'Cancelled' OR Call_Start_Datetime__c <: Date.today())            
                LIMIT :recLimit];
    }

    @AuraEnabled
    public static List<Task> getCallBackIncoming(String recordId, Integer recLimit){

        return [SELECT Id, Subject, Call_Log_ID__c, Call_Agent_Id__c, Call_Number__c,Call_Back_Mode__c,Description,
                        Call_Start_Datetime__c, Call_End_Time__c, CallType, Owner.Name, ActivityDate,Marketing_Code__c
                FROM Task
                WHERE RecordType.Name = 'Call Back'
                AND Related_Object__c = :recordId
                AND Status != 'Completed' AND Status != 'Cancelled'
                AND Call_Start_Datetime__c >=: Date.today() LIMIT :recLimit];
    }

}