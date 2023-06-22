trigger OpportunityLineItemTrigger On OpportunityLineItem (before insert, after insert, before update, after update, before delete, after delete){

    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 

    /***---------------        Check OpportunityTeamMember is not retail        ---------------***/   
    
    map<id, OpportunityLineItem> mapOldObj = new map<id, OpportunityLineItem>();
    set<string> setRecordTypeId = new set<string>();
    list<opportunitylineitem> listOldOpportunityProduct = new list<opportunitylineitem>();
    for (recordtype r : [select id from recordtype where not name like 'Retail%']){
        setRecordTypeId.add(r.id);
    }
    
    set<string> listOptyID = new set<string>();
    map<string, string> mapOptyOppProd = new map<string,string>();
    map<string, string> mapOptyRecordType = new map<string, string>();
    
    if (Trigger.old != null) {
        for (OpportunityLineItem o : Trigger.old)
        {
            listOptyID.add(o.opportunityID);
            mapOptyOppProd.put(o.id, o.opportunityID);
        }
      
        for (opportunity o: [select id, recordtypeid from opportunity where id in: listOptyID])
        {
            mapOptyRecordType.put(o.id, o.recordtypeid);
        }
        
        for (OpportunityLineItem o : Trigger.old)
        {
            if (setRecordTypeId.contains(mapOptyRecordType.get(mapOptyOppProd.get(o.id)))){
                mapOldObj.put(o.id, o);
                listOldOpportunityProduct.add(o);
            }
        }
    }
  
    /***---------------        Check OpportunityTeamMember is not retail        ---------------***/

    if(Trigger.isBefore && Trigger.isInsert) 
    {  
//        system.debug('OpportunityLineItemTrigger before insert');

        //System.debug(':: before-insert: Stamp ProductGroupID, ProductProgramID, CreditTypeID to Opp Product ::');   
        OpportunityLineItemTriggerHandler.SetHostProductMappingToOppProduct(Trigger.new); 
    }
    else if(Trigger.isAfter && Trigger.isInsert) 
    {  
//        system.debug('OpportunityLineItemTrigger after insert');
        if(RunTrigger || Test.isRunningTest()){
            //OpportunityLineItemTriggerHandler.CalculateOpportunityTotalVol(Trigger.new); 
            //OpportunityLineItemTriggerHandler.StampOriginalStart(Trigger.new); 
            OpportunityLineItemTriggerHandler.GenerateDealForecast(Trigger.new);
        }
    }
    else if(Trigger.isBefore && Trigger.isUpdate) 
    {  
//        system.debug('OpportunityLineItemTrigger before update');

        //System.debug(':: before-update: Stamp ProductGroupID, ProductProgramID, CreditTypeID to Opp Product ::');   
        OpportunityLineItemTriggerHandler.SetHostProductMappingToOppProduct(Trigger.new);
    }
    else if(Trigger.isAfter && Trigger.isUpdate) 
    {  
//        system.debug('OpportunityLineItemTrigger after update');
        if(RunTrigger || Test.isRunningTest()){
            //OpportunityLineItemTriggerHandler.CalculateOpportunityTotalVol(Trigger.new); 
            //OpportunityLineItemTriggerHandler.StampOriginalStart(Trigger.new); 
            OpportunityLineItemTriggerHandler.syncDealForecast(Trigger.oldMap, Trigger.NewMap);
        }
    }
    else if(Trigger.isBefore && Trigger.isDelete) 
    {
//        system.debug('OpportunityLineItemTrigger before delete');
        if(RunTrigger || Test.isRunningTest()){
            OpportunityLineItemTriggerHandler.deleteDealForecast(Trigger.oldMap);
        }
    }
    else if(Trigger.isAfter && Trigger.isDelete) 
    {
//        system.debug('OpportunityLineItemTrigger after delete');
        if(RunTrigger || Test.isRunningTest()){
            OpportunityLineItemTriggerHandler.getDeletedRecord(mapOldObj);
            //OpportunityLineItemTriggerHandler.CalculateOpportunityTotalVol(Trigger.old); 
            
            // for SLOS set opportunity product group to blank if no at least one product
            OpportunityLineItemTriggerHandler.setOpportunityProductGroupIfNoProduct(listOldOpportunityProduct);
        }
    }

}