trigger VisitReportOpportunity on Visit_Report_Opportunity__c (before insert, before update) {

    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 
    
    if(Trigger.isBefore && Trigger.isInsert)
    {
        system.debug('VisitReportOpportunity : before insert ');
        if( RunTrigger || Test.isRunningTest() )
        {
            VisitReportOpportunityTriggerHandler.checkDuplicate(Trigger.new, new list<Visit_Report_Opportunity__c>());
        }
    }
    
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        system.debug('VisitReportOpportunity : before update ');
        if( RunTrigger || Test.isRunningTest() )
        {
            VisitReportOpportunityTriggerHandler.checkDuplicate(Trigger.new, Trigger.old);
        }
    }

}