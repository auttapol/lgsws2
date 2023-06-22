trigger CampaignProductTrigger on Campaign_Product__c (before insert, after insert, before update, after update, after delete) {
    
    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 
    
    if (Trigger.isBefore && Trigger.isInsert)
    {
        system.debug('CampaignProductTrigger before insert ');
        if( RunTrigger || Test.isRunningTest() )
        {
            CampaignProductTriggerHandler.checkProductPricebook(Trigger.new, new list<Campaign_Product__c >());
            CampaignProductTriggerHandler.checkDuplicateCampaignProduct(Trigger.new, new list<Campaign_Product__c >());
        }
    } 
    
    if (Trigger.isAfter && Trigger.isInsert)
    {
        system.debug('CampaignProductTrigger after insert ');
        if( RunTrigger || Test.isRunningTest() )
        {
            CampaignProductTriggerHandler.calExpectedRevenue(Trigger.new);
        }
    }  
    
    if (Trigger.isBefore && Trigger.isUpdate)
    {
        system.debug('CampaignProductTrigger before update');
        if( RunTrigger || Test.isRunningTest() )
        {
            CampaignProductTriggerHandler.checkProductPricebook(Trigger.new, Trigger.old);
            CampaignProductTriggerHandler.checkDuplicateCampaignProduct(Trigger.new, Trigger.old);
        }
    } 
    
    if (Trigger.isAfter && Trigger.isUpdate)
    {
        system.debug('CampaignProductTrigger after update');
        if( RunTrigger || Test.isRunningTest() )
        {
            CampaignProductTriggerHandler.calExpectedRevenue(Trigger.new);
        }
    }  
    
    if (Trigger.isAfter && Trigger.isDelete)
    {
        system.debug('CampaignProductTrigger after delete');
        if( RunTrigger || Test.isRunningTest() )
        {
            CampaignProductTriggerHandler.calExpectedRevenue(Trigger.old);
        }
    }    
}