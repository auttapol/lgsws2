trigger RTL_CampaignMemberTrigger on CampaignMember (before insert,before update,after update,after insert ) {
    Boolean RunTrigger = AppConfig__c.getValues('runRetailCampaignMemberTrigger').Value__c == 'true' ;
    List<CampaignMember> newList = new List<CampaignMember>();
    List<CampaignMember> campaignMembToAssign = new List<CampaignMember>();
    Map<ID,CampaignMember> oldMap = new Map<Id,CampaignMember>();
    
    if(Trigger.New != null){
        for(CampaignMember campaignMemb : Trigger.New){
            if(RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(CampaignMember.SObjectType, 'Retail').contains(campaignMemb.RecordTypeId)){
                newList.add(campaignMemb);
            }
        }  
    }

    if(Trigger.Old !=null){
        for(CampaignMember campaignRecord: Trigger.Old){
            if(RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(CampaignMember.SObjectType, 'Retail').contains(campaignRecord.RecordTypeId)){
                oldMap.put(campaignRecord.id,campaignRecord);
            }
        } 
    }
    
    if( newList.size() > 0 )
    {
        if(Trigger.isBefore && Trigger.isInsert){
            if( RunTrigger || Test.isRunningTest() ){
                RTL_CampaignMemberTriggerHandler.beforeInsert(newList);
                RTL_CampaignStatusGenerator.RTL_UpdateCampaignMemberStatus(newList);
                RTL_CampaignMemberUtil.RTL_SaveProductsOffer(newList);
                RTL_CampaignMemberUtil.RTL_UpdateCampaignMemberAssigned(newList,oldMap);
                RTL_CampaignMemberUtil.RTL_UpdateMarkettingCode(newList);
                RTL_CampaignMemberUtil.RTL_UpdateCustomer(newList);
                RTL_CampaignMemberUtil.RTL_StampLeadName(newList,oldMap);
                RTL_CampaignMemberTriggerHandler.updateCampaignSubsidaryChannel(newList);
               
            }
        }

        if(Trigger.isBefore && Trigger.isUpdate){
            if( RunTrigger || Test.isRunningTest() ){
                
                RTL_CampaignStatusGenerator.RTL_UpdateCampaignMemberStatus(newList);
                RTL_CampaignMemberUtil.RTL_UpdateCampaignMemberAssigned(newList,oldMap);
                RTL_CampaignMemberUtil.RTL_UpdateCustomer(newList); 
                RTL_CampaignMemberTriggerHandler.beforeUpdate(newList,oldMap);
                RTL_CampaignMemberUtil.RTL_StampLeadName(newList,oldMap);
                RTL_CampaignMemberTriggerHandler.updateCampaignSubsidaryChannel(newList);

            }
            
        }

        if(Trigger.isAfter && Trigger.isUpdate){
            if( RunTrigger || Test.isRunningTest() ){
                system.debug('After : '+Trigger.New);
                RTL_CampaignMemberTriggerHandler.OnAfterUpdate(Trigger.New,trigger.oldmap);

                //SEND CampaignMember to CXM
                CXMServiceProvider cxmService = new CXMServiceProvider(CXMServiceProvider.CMP_MEMBER_CXM);
                cxmService.integrateToCXMForSales(Trigger.oldMap,Trigger.NewMap);
                //SEND CampaignMember to CXM
            }
        }

        if(Trigger.isAfter && Trigger.isInsert){
            if( RunTrigger || Test.isRunningTest() ){
                RTL_CampaignMemberTriggerHandler.OnAfterInsert(newList);
            }
        }

    }

}