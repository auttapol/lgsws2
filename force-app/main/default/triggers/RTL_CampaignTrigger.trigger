trigger RTL_CampaignTrigger on Campaign (before insert,after insert,after update, before update) {

    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ;
// aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
    Set<ID> retailRecordTypeIDset = new Set<ID>();
    for(Recordtype perRecordType :  [SELECT ID from Recordtype 
                                     WHERE sObjectType ='Campaign'
                                     AND (NOT DeveloperName LIKE '%Commercial%')]){
        retailRecordTypeIDset.add(perRecordType.id); 
    }
    List<Campaign> newCampaignList = new List<Campaign>();
    List<Campaign> oldCampaignList = new List<Campaign>();
    Map<ID,Campaign> oldCampaignMap = new Map<Id,Campaign>();

    //Map<Campaign,Campaign> campaingOldNewMap = new Map<Campaign,Campaign>();

    for(Campaign campaignRecord: trigger.new){
        if(campaignRecord.RecordTypeId != null && retailRecordTypeIDset.contains(campaignRecord.RecordTypeId)) {
            newCampaignList.add(campaignRecord);
        }
    }

    if(trigger.old != null){
        for(Campaign campaignRecord: trigger.old){
            if(campaignRecord.RecordTypeId != null && retailRecordTypeIDset.contains(campaignRecord.RecordTypeId)) {
                oldCampaignList.add(campaignRecord);
                oldCampaignMap.put(campaignRecord.id,campaignRecord);
            }
        } 
    }
    
    
    if(Trigger.isBefore && Trigger.isInsert){
        if( RunTrigger || Test.isRunningTest() )
        {
            if(newCampaignList.size()>0){
                RTL_CampaignCodeGenerator.GenerateCampaignCode(newCampaignList);
                RTL_CampaignTriggerHandler.checkDuplicateName(newCampaignList,oldCampaignList);
                RTL_CampaignMemberUtil.setCampaignMemberRecordTypeId(newCampaignList);
                
            }
        }
    }

   if (Trigger.isBefore && Trigger.isUpdate){
        if( RunTrigger || Test.isRunningTest() )
        {
            if(newCampaignList.size()>0){
                RTL_CampaignTriggerHandler.checkDuplicateName(newCampaignList,oldCampaignList);
                RTL_CampaignMemberUtil.setCampaignMemberRecordTypeId(newCampaignList);

                // Remove and group to one method above
                // Need to update campaign member before campaign update 
                //  -> after update campaign already expired and not allowed to edit campaign member
                //  -> updateExpiredCampaignMemberProductOfferResult must run before RTL_UpdateContactStatus 
                //     Because RTL_UpdateContactStatus will update campaign member contact status to Unsed 
                //     updateExpiredCampaignMemberProductOfferResult will only check and change campaign member in pending status

                //RTL_CampaignMemberUtil.updateExpiredCampaignMemberProductOfferResult(newCampaignList,oldCampaignMap);
                // Move to updateExpiredCampaignMemberDataBatch to run in the same batch
                //RTL_CampaignMemberUtil.RTL_UpdateContactStatus(newCampaignList,oldCampaignMap);
               
            }
        }
    }


    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate )){
        if( RunTrigger || Test.isRunningTest() )
        {
            if(newCampaignList.size()>0)
            {
                if(Trigger.isInsert)
                {
                    RTL_CampaignStatusGenerator.RTL_GenerateCampaignMemberStatus(newCampaignList,oldCampaignMap);
                }
                else if(Trigger.isUpdate)
                {
                    List<Campaign> campaigncategoryChangeList = new List<Campaign>();
                    Map<ID,Campaign> oldcampaigncategoryChangeMap = new Map<Id,Campaign>();
                    for(Campaign newcampaign : newCampaignList){
                        Campaign oldcampaignRecord = oldCampaignMap.get(newcampaign.id);
                        if(newcampaign.RTL_Category__c != oldcampaignRecord.RTL_Category__c){
                            campaigncategoryChangeList.add(newcampaign);
                            oldcampaigncategoryChangeMap.put(oldcampaignRecord.id,oldcampaignRecord);

                        }
                    }

                    if(campaigncategoryChangeList.size()>0){
                        RTL_CampaignStatusGenerator.RTL_GenerateCampaignMemberStatus(campaigncategoryChangeList,oldcampaigncategoryChangeMap);
                    }

                    // Group update campaign member Offer result and Contact status when campaign expired to one method 
                    RTL_CampaignMemberUtil.updateExpiredCampaignMemberDataBatch(newCampaignList,oldCampaignMap);    

                }

                RTL_CampaignToHQApproval.calloutCampaingToHQ(newCampaignList,oldCampaignMap);
            }
        }

    }


    
}