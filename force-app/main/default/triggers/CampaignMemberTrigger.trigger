trigger CampaignMemberTrigger on CampaignMember (before insert, after insert, after update, after delete) {

    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 

    set<string> setLeadID = new set<string>();
    set<string> setLeadIDRetail = new set<string>();
    //set<string> setContactID = new set<string>();
    map<string,campaignMember> mapCampaignMember = new map<string,campaignMember>();
    list<campaignMember> ListCommercial = new list<campaignMember>();
    list<campaignMember> ListRetail = new list<campaignMember>();
    
    Id CampaignRecordTypeId = Schema.SObjectType.CampaignMember.getRecordTypeInfosByName().get('Retail Campaign Member').getRecordTypeId();

    if (trigger.old != null){  
        for (campaignMember c : trigger.old)
        {
            if (c.LeadID != null){
                setLeadID.add(c.LeadID);
                if (c.RecordTypeId == CampaignRecordTypeId)
                {
                    setLeadIDRetail.add(c.LeadID);
                }
                mapCampaignMember.put(c.LeadID, c);
            }
            /*
            if (c.ContactID != null){
                setContactID.add(c.ContactID);
                mapCampaignMember.put(c.ContactID, c);
            }
            */
        }
    }
    
    if (trigger.new != null){
        for (campaignMember c : trigger.new)
        {
            if (c.LeadID != null){
                setLeadID.add(c.LeadID);
                if (c.RecordTypeId == CampaignRecordTypeId)
                {
                    setLeadIDRetail.add(c.LeadID);
                }
                mapCampaignMember.put(c.LeadID, c);
            }
            /*
            if (c.ContactID != null){
                setContactID.add(c.ContactID);
                mapCampaignMember.put(c.ContactID, c);
            }
            */
        }
    }
    
    for (Lead l : [select id,Recordtype.name from Lead where id in: setLeadID and Recordtype.Name Like: 'Commercial%'])
    {
        if (mapCampaignMember.get(l.id) != null) ListCommercial.add(mapCampaignMember.get(l.id));
    }

    for (Lead l : [select id, Recordtype.name from Lead where id in: setLeadIDRetail]) 
    {
        if (mapCampaignMember.get(l.id) != null) ListRetail.add(mapCampaignMember.get(l.id));
    }
    
    /*
    for (Contact c : [select id,Recordtype.name from Contact where id in: setContactID and (Recordtype.Name = 'Core bank' or Recordtype.Name = 'Salesforce')])
    {
        if (mapCampaignMember.get(c.id) != null) ListCommercial.add(mapCampaignMember.get(c.id));
    }
    */
    // system.debug(ListCommercial);


    if(Trigger.isBefore && Trigger.isInsert && ListCommercial.size() > 0)
    {
        //system.debug('CampaignMemberTrigger before insert ');
        if( RunTrigger || Test.isRunningTest() ){
//            CampaignMemberTriggerHandler.checkPrimaryCampaign(Trigger.new);
            CampaignMemberTriggerHandler.checkPrimaryCampaign(ListCommercial);
        }
    }
    
    if(Trigger.isAfter && Trigger.isInsert && ListCommercial.size() > 0)
    {
        //system.debug('CampaignMemberTrigger after insert ');
        if( RunTrigger || Test.isRunningTest() ){
            //CampaignMemberTriggerHandler.addCampaignProductToProductInterest(Trigger.new);
//            CampaignMemberTriggerHandler.addLeadToCampaingMember(Trigger.new);
            CampaignMemberTriggerHandler.addLeadToCampaingMember(ListCommercial);
        }
    }
    
        if(Trigger.isAfter && Trigger.isUpdate && ListRetail.size() > 0) 
    {
        system.debug('CampaignMemberTrigger after update ');
        if( RunTrigger || Test.isRunningTest() ){
//            CampaignMemberTriggerHandler.UpdateLeadWithCampaignMember(Trigger.new);
            CampaignMemberTriggerHandler.UpdateLeadWithCampaignMember(ListRetail);
        }
    }
    
    if(Trigger.isAfter && Trigger.isDelete && ListCommercial.size() > 0)
    {
        //system.debug('CampaignMemberTrigger after delete');
        if( RunTrigger || Test.isRunningTest() ){
            //CampaignMemberTriggerHandler.removeCampaignProductFromLead(Trigger.old, new list<string>());
//            CampaignMemberTriggerHandler.deleteCampaignMember(Trigger.old);
            CampaignMemberTriggerHandler.deleteCampaignMember(ListCommercial);
        }
    }

}