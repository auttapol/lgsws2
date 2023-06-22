trigger LeadTrigger on Lead (before insert, after insert, after update) {

    /***---------------        Check lead is not retail        ---------------***/   
    list<lead> listNewLead = new list<lead>();
    list<lead> listOldLead = new list<lead>();
    set<string> setRecordTypeId = new set<string>();
    // for (recordtype r : [select id from recordtype where name like '%commercial%']){
    //     setRecordTypeId.add(r.id);
    // }
    //TAY CODE 2020-06-02 CR Redesign Droplead retail 
    setRecordTypeId.add(Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Account').getRecordTypeId());
    setRecordTypeId.add(Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Completed').getRecordTypeId());
    setRecordTypeId.add(Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId());

    if (Trigger.new != null){
        for (lead l : Trigger.new){
            if (setRecordTypeId.contains(l.recordtypeId))
                listNewLead.add(l);
        }
    }
    if (Trigger.old != null){
        for (lead l : Trigger.old){
            if (setRecordTypeId.contains(l.recordtypeId))
                listOldLead.add(l);
        }
    }
    /***---------------        Check lead is not retail        ---------------***/

    //TAY CODE 2020-06-02 CR Redesign Droplead retail 
    Boolean RunTrigger = false;

    for(Lead lead: Trigger.new){
    	if(setRecordTypeId.contains(lead.recordtypeId)) RunTrigger = true;
    } 

    RunTrigger = RunTrigger && AppConfig__c.getValues('runtrigger').Value__c == 'true'; 
    System.debug('RunTrigger: ' + RunTrigger);

    if(Trigger.isBefore && Trigger.isInsert)
    {
        system.debug('LeadTrigger : before insert ');
        if( RunTrigger || Test.isRunningTest() )
        {   
             //// Prepare Lead data(FNA)
            LeadAssignmentUtil.assignLeadOwnerByLeadAssignmentrule(listNewLead);
            RTL_ReferralLeadService.prepareLeadInfo(listNewLead);
        }
    }

    if(Trigger.isAfter && Trigger.isInsert)
    {
        system.debug('LeadTrigger : after insert ');
        if( RunTrigger || Test.isRunningTest() )
        {
            LeadTriggerHandler.updatePrimaryCampaign(listNewLead, new list<lead>());
            //CR Referral Enhancement RQ-004 sync lead status and referral stage
            RTL_ReferralLeadService.updateReferralStageContacted(listNewLead);
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        system.debug('LeadTrigger : after update ');
        if( RunTrigger || Test.isRunningTest() )
        {
            LeadTriggerHandler.updatePrimaryCampaign(listNewLead, listOldLead);
            LeadTriggerHandler.afterChangeOwnerLead(listNewLead, listOldLead);
            //CR Referral Enhancement RQ-004 sync lead status and referral stage
            RTL_ReferralLeadService.updateReferralInfo(new Map<Id, Lead>(listOldLead),new Map<Id, Lead>(listNewLead));

        }
    }
    
}