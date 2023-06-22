trigger CampaignTrigger on Campaign (before insert, before update, after update) {

    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 

     Set<ID> commercialRecordTypeSet = new Set<ID>();
    for(Recordtype perRecordType :  [SELECT ID from Recordtype 
                                     WHERE sObjectType ='Campaign'
                                     AND  DeveloperName LIKE '%Commercial%' ]){
                                        commercialRecordTypeSet.add(perRecordType.id); 
                                     }

  List<Campaign> triggerNewcampaignList = new List<Campaign>();   
  if (trigger.new != null){                               
    for(Campaign campaignRecord: trigger.new){
        if(campaignRecord.RecordTypeId != null && commercialRecordTypeSet.contains(campaignRecord.RecordTypeId)) {
            triggerNewcampaignList.add(campaignRecord);
        }
    } 
  }

  List<Campaign> triggeroldcampaignList = new List<Campaign>();     
  if (trigger.old != null){                              
    for(Campaign campaignRecord: trigger.old){
        if(campaignRecord.RecordTypeId != null && commercialRecordTypeSet.contains(campaignRecord.RecordTypeId)) {
            triggeroldcampaignList.add(campaignRecord);
        }
    }   
  }



    
    if (Trigger.isBefore && Trigger.isInsert)
    {
        system.debug('CampaignTrigger before insert');
        if( RunTrigger || Test.isRunningTest() )
        {
            if(triggerNewcampaignList.size()>0  ){
                CampaignTriggerHandler.checkDuplicateName(triggerNewcampaignList, new list<campaign>());
            }
            
        }
    } 
    
    if (Trigger.isBefore && Trigger.isUpdate)
    {
        system.debug('CampaignTrigger before update');
        if( RunTrigger || Test.isRunningTest() )
        {
            if(triggerNewcampaignList.size()>0  ){
            CampaignTriggerHandler.checkDuplicateName(triggerNewcampaignList, triggeroldcampaignList);
            }
        }
    } 

    if (Trigger.isAfter && Trigger.isUpdate)
    {
        system.debug('CampaignTrigger after update');
        if ( RunTrigger || Test.isRunningTest() )
        {
            if(triggerNewcampaignList.size()>0  ){
            CampaignTriggerHandler.calculateParentCampaign(triggerNewcampaignList, triggeroldcampaignList);
            CampaignTriggerHandler.checkParentCampaign(triggerNewcampaignList, triggeroldcampaignList);
            }
        }
    }

}