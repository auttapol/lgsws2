trigger RTL_ReferralTrigger on RTL_Referral__c (before insert,before update,after update,after insert) {
	Boolean RunTrigger = AppConfig__c.getValues('runReferralTrigger').Value__c == 'true' ; 
    
    if (Trigger.isBefore && Trigger.isInsert)
    {
        if( RunTrigger || Test.isRunningTest() )
        {
           RTL_ReferralTriggerHandler.handleBeforeInsert(Trigger.New);
        }
    }
    
    if (Trigger.isAfter && Trigger.isInsert)
    {
        if( RunTrigger || Test.isRunningTest() )
        {
           RTL_ReferralTriggerHandler.handleAfterInsert(Trigger.New);
        }
    }
    
    if (Trigger.isBefore && Trigger.isUpdate)
    {
        if( RunTrigger || Test.isRunningTest() )
        {
           RTL_ReferralTriggerHandler.handleBeforeUpdate(Trigger.oldMap,Trigger.NewMap);
        }
    } 

    if (Trigger.isAfter && Trigger.isUpdate)
    {
        if ( RunTrigger || Test.isRunningTest() )
        {
            RTL_ReferralTriggerHandler.handleAfterUpdate(Trigger.oldMap,Trigger.NewMap);
        }
    }

    
}