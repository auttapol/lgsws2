trigger EmailSuppressionLogEvent on Email_Suppression_Log_Event__e (after insert) {
        
    List<Email_Suppression_Log__c> emailLogList = new List<Email_Suppression_Log__c>();
    for (Email_Suppression_Log_Event__e event : Trigger.New) 
    {      
        Email_Suppression_Log__c emailLog = new Email_Suppression_Log__c();
        emailLog.Agent__c  = event.Agent__c;
        emailLog.Case__c = event.Case__c;
        emailLog.Email_Suppression_Rule__c = event.Email_Suppression_Rule__c;
        emailLog.Severity__c = event.Severity__c;
        emailLog.Type__c = event.Type__c;
        
        emailLogList.add(emailLog);
       
    }
    
    if(emailLogList.size() > 0)
    {
        Database.insert(emailLogList,false);       
        System.debug('emailLog:'+emailLogList);
    }
}