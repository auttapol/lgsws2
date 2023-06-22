trigger RTL_CampaignAssignmentRuleTrigger on RTL_Campaign_Assignment_Rule__c (before insert, before update,after insert, after update) {  
    
    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 
    
    List<RTL_Campaign_Assignment_Rule__c> listNew = new List<RTL_Campaign_Assignment_Rule__c>();
    Map<ID,RTL_Campaign_Assignment_Rule__c> oldMap = new Map<Id,RTL_Campaign_Assignment_Rule__c>();
    
    for(RTL_Campaign_Assignment_Rule__c c: trigger.new){
        listNew.add(c);
    }
    
    if(trigger.old !=null){
        for(RTL_Campaign_Assignment_Rule__c c: trigger.old){
            oldMap.put(c.id,c);
        } 
    }

    if(Trigger.isAfter && Trigger.isInsert)
    {
        system.debug('RTL_CampaignAssignmentRuleTrigger : after insert ');
        if( RunTrigger || Test.isRunningTest() )
        {
            RTL_CampaignAssignmentRuleTriggerHanlder.afterInsert(listNew, oldMap);
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        system.debug('RTL_CampaignAssignmentRuleTrigger : after update ');
        if( RunTrigger || Test.isRunningTest() )
        {
            RTL_CampaignAssignmentRuleTriggerHanlder.afterUpdate(listNew, oldMap);

        }
    }
                          

}