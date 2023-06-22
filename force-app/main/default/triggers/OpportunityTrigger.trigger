trigger OpportunityTrigger on Opportunity (before insert, after insert,before update, after update, after delete, after undelete) {
    ///////////////////////////////////////////
    // Created   :  2014-09-05 
    // Create By :  Keattisak Chinburarat
    // Modified  :  2014-11-04
    // Last Modifed : Thanakorn Haewphet
    ///////////////////////////////////////////


    /***---------------        Check opportunity is not retail        ---------------***/   
    list<Opportunity> listNewOpp = new list<Opportunity>();
    list<Opportunity> listOldOpp = new list<Opportunity>();
    Map<Id,Opportunity> newOppMap = new Map<Id,Opportunity>();
    Map<Id,Opportunity> oldOppMap = new Map<Id,Opportunity>();
    /*
        Update by: Narathip Santhip
        Email: nrs@ii.co.th
        Note: Fix bug too many query 101
        Change Date: 2020-06-11
        Change Description: Getting from Schema recordtype infoes library instead of SQOL
    */
    set<string> setRecordTypeId = new set<string>();
    // for (recordtype r : [select id from recordtype where SobjectType = 'Opportunity' AND (name like '%Credit%' or name like '%Non-credit%') ]){
    for (Schema.RecordTypeInfo sr : Schema.SObjectType.Opportunity.getRecordTypeInfosById().values()){
        if (sr.getName().contains('Credit') || sr.getName().contains('Non-credit')) {
            setRecordTypeId.add(sr.getRecordTypeId());
        }
    }

    if (Trigger.new != null){
        for (Opportunity o : Trigger.new){
            System.debug('oppid ::: '+o.Id);
            System.debug('new owner ::: '+o.OwnerId);
            if (setRecordTypeId.contains(o.recordtypeId)){
                listNewOpp.add(o);
                newOppMap.put(o.id,o);
                
                
            }
        }
       
    }
    if (Trigger.old != null){
        for (Opportunity o : Trigger.old){
            System.debug('oppid ::: '+o.Id);
            System.debug('old owner ::: '+o.OwnerId);
            if (setRecordTypeId.contains(o.recordtypeId)){
                listOldOpp.add(o);
                oldOppMap.put(o.id,o);
                
            }
        }
    }
    System.debug('Comm OptTrigger: '+listNewOpp.size());
    
    /***---------------        Check opportunity is not retail        ---------------***/
    
    Date currentDate = Date.today();
    Integer currentyear = currentDate.year();
    Integer currentmonth = currentDate.month();
    string strCurrentyear = string.valueOf(currentyear).right(2);
    
    System.debug(':::: OpportunityTrigger Start'); 
    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 
    //Boolean RunTrigger = false;
    
    //-------------   BEFORE INSERT TRIGGER RUN HERE    -------------
    if(Trigger.isBefore && Trigger.isInsert) 
    {                 
        /*Opportunity[] Opps = Trigger.new;
         //  List<Id> userIds = new  List<Id>();   
        Decimal tgcount = Opps.size();        
        RunningUtility util  = new RunningUtility('Opportunity',currentyear,currentmonth,'');
        Running__c running= (Running__c)util.GetCurrentNumber();            
        Decimal start = running.No__c;            
        running.No__c = running.No__c+ 1 ;
        System.debug(':::: Running__c.No__c => ' + running.No__c); */
        if(RunTrigger || Test.isRunningTest()){
            if( listNewOpp.size()>0 ){
                OpportunityTriggerHandler.handleBeforeInsert(listNewOpp);
            }   
            RTL_ReferralOpportunityService.updateReferralClosedInterest(Trigger.New);
        }
        
    }
    
    // -------------   BEFORE UPDATE TRIGGER RUN HERE   ------------- 
    else if(Trigger.isBefore && Trigger.isUpdate) 
    {  
        if( (RunTrigger || Test.isRunningTest())){
            if(listNewOpp.size()>0 ){
                OpportunityTriggerHandler.handleBeforeUpdate(listNewOpp,listOldOpp);
            }
            
            ///////// CR Referral  ////////////
            RTL_ReferralOpportunityService.updateReferralInfo(Trigger.oldMap,Trigger.newMap);
        }        
    }
    // -------------   BEFORE DELETE TRIGGER RUN HERE   ------------- 
/*    else if(Trigger.isBefore && Trigger.isDelete) 
    {
    } 
*/
    // -------------   AFTER INSERT TRIGGER RUN HERE    ------------- 

    else if(Trigger.isAfter && Trigger.isInsert) 
    {
        if((RunTrigger || Test.isRunningTest()) && listNewOpp.size()>0){
            OpportunityTriggerHandler.updateCampaignRevenue(listNewOpp);
            OpportunityTriggerHandler.handleAfterInsert(listNewOpp);
        }
    }  

    // -------------   BEFORE AFTER TRIGGER RUN HERE    ------------- 
    else if(Trigger.isAfter && Trigger.isUpdate) 
    {
        if((RunTrigger || Test.isRunningTest()) && listNewOpp.size()>0){
            OpportunityTriggerHandler.handleAfterUpdate(listNewOpp,listOldOpp);
            OpportunityTriggerHandler.handleAfterUpdate(oldOppMap,newOppMap);
        }
        
    }    
    // -------------   AFTER DELETE TRIGGER RUN HERE    -------------  
    else if(Trigger.isAfter && Trigger.isDelete) 
    { 
        if((RunTrigger || Test.isRunningTest())){
            OpportunityTriggerHandler.updateOpportunityCampaign(listNewOpp,listOldOpp);
        }    
    } 
    
    System.debug(':::: OpportunityTrigger End'); 
}