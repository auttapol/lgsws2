trigger AccountTrigger on Account (before insert, after insert,before update, after update, after delete, after undelete) {    
    //////////////////////////////////////
    // Create By : Thanakorn Haewphet
    // Email : tnh@ii.co.th
    // Create Date : 2014-10-20 
    // Summary : 
    // NOte : https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_triggers_context_variables_considerations.htm
    //        ***  All Trigger.New   You can use an object to change its own field values using trigger.new, 
    //        but only in before triggers. In all after triggers, trigger.new is not saved, so a runtime exception is thrown.
    //        
    //  Change 01: By Ktc               
    //  Change Date: 23-10-2557
    //  Change Description : Move Update Account Process to Before trigger !!!
    //      
    //////////////////////////////////////
    System.debug('::: AccountTrigger Start ::::');
    
    
    /***---------------        Check account is not retail        ---------------***/   
    list<Account> listNewAcc = new list<Account>();
    list<Account> listOldAcc = new list<Account>();
    set<string> setRecordTypeId = new set<string>();
    // for (recordtype r : [select id from recordtype 
    //                      where SobjectType = 'Account' AND name in ('Existing Customer','Prospect') ]){
    /*
        Update by: Narathip Santhip
        Email: nrs@ii.co.th
        Note: Fix bug too many query 101
        Change Date: 2020-06-11
        Change Description: Getting from Schema recordtype infoes library instead of SQOL
    */
    for(Schema.RecordTypeInfo sr : Schema.Sobjecttype.Account.getRecordTypeInfosByName().values()){
        if (new List<String>{'Existing_Customer', 'Prospect'}.contains(sr.getDeveloperName())) {
            setRecordTypeId.add(sr.getRecordTypeId());
        }
    }
    if (Trigger.new != null){
        for (Account o : Trigger.new){
            if (setRecordTypeId.contains(o.recordtypeId))
                listNewAcc.add(o);
        }
    }
    if (Trigger.old != null){
       for (Account o : Trigger.old){
            //Tinnakrit : Fix BAU Issues - ExportExistingCustomerToSalesforceWindowsService Fail 
            //Sep 13 2016
            
            
            //if (setRecordTypeId.contains(o.recordtypeId))
                listOldAcc.add(o);
        }
    }
    /***---------------        Check account is not retail        ---------------***/
    
    
    // Use App Configuration to control =>  go to  App Setup > Develop > Custom Settings > AppConfig > Manage > runtrigger and then change the value
    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 
    System.debug('RUNTRIGGER : '+RunTrigger +' : '+Test.isRunningTest());
    //Boolean RunTrigger = false;
    // ********   BEFORE INSERT TRIGGER RUN HERE   ********* 
    if(Trigger.isBefore && Trigger.isInsert) 
    {      
        if( (RunTrigger || Test.isRunningTest()) && listNewAcc.size()>0  ){
            AccountTriggerHandler.handleBeforeInsert(listNewAcc);
        }
    }     
    // ********   BEFORE UPDATE TRIGGER RUN HERE   ********* 
    else if(Trigger.isBefore && Trigger.isUpdate) 
    {   
        if( (RunTrigger || Test.isRunningTest()) && listNewAcc.size()>0 ){
            AccountTriggerHandler.handleBeforeUpdate(listNewAcc,listOldAcc);
        } 
    } 
    // ********   BEFORE DELETE TRIGGER RUN HERE   ********* 
 /*   else if(Trigger.isBefore && Trigger.isDelete) 
    {        
        
    } 
    */
    // ********   AFTER INSERT TRIGGER RUN HERE   ********* 
    else if(Trigger.isAfter && Trigger.isInsert) 
    {
        if( (RunTrigger || Test.isRunningTest()) && listNewAcc.size()>0 ){

            AccountTriggerHandler.handleAfterInsert(listNewAcc);  
        }
    } 
    // ********   BEFORE UPDATE TRIGGER RUN HERE   ********* 
    else if(Trigger.isAfter && Trigger.isUpdate) 
    {  
        if( (RunTrigger || Test.isRunningTest()) && listNewAcc.size()>0 ){
            AccountTriggerHandler.handleAfterUpdate(listNewAcc,listOldAcc);
        } 
    }
    // ********   AFTER DELETE TRIGGER RUN HERE   *********  
 /*   else if(Trigger.isAfter && Trigger.isDelete) 
    {        
        
    } */
    System.debug('::: AccountTrigger End ::::');
}