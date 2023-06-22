trigger TaskTrigger on Task (before insert, after insert,before update, after update,before delete, after delete, after undelete) {    
    //////////////////////////////////////
    // Create By : Thanakorn Haewphet
    // Email : tnh@ii.co.th
    // Create Date : 2014-10-20 
    // Summary : -
    //////////////////////////////////////
    System.debug('::: TaskTrigger Start ::::');
    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 
    //Boolean RunTrigger = false;
    // ********   BEFORE INSERT TRIGGER RUN HERE   ********* 
    Map<ID,Schema.RecordTypeInfo> rt_Map = Task.sObjectType.getDescribe().getRecordTypeInfosById();

    if(Trigger.isBefore && Trigger.isInsert) 
    {   
        //Edit by: Danudath leebandit
        //CR: Task assignment notification 
        for(Task ta : Trigger.new){
            /*try{
            	if(!rt_map.get(ta.recordTypeID).getName().containsIgnoreCase('Retail')){
                //Stamp customer name to custom field
                
                if(ta.WhoID != null){
                    List<Lead> leadName = [Select ID, Company from Lead where ID =: ta.WhoID limit 1]; 
                    ta.Customer_Name__c = leadName[0].company;
                }else{
                   List<Account> AccName = [Select ID, Name from Account where ID =: ta.WhatID limit 1]; 
                   if(AccName.size() > 0){
                        ta.Customer_Name__c = AccName[0].Name;
                   }
                }
                }
                }catch(exception e){
                    
                }*/
            
        }

    TaskTriggerHandler.handlerBeforeInsert(Trigger.New);
        
    }     
    // ********   BEFORE UPDATE TRIGGER RUN HERE   ********* 
    else if(Trigger.isBefore && Trigger.isUpdate) 
    {        
    } 
    // ********   BEFORE DELETE TRIGGER RUN HERE   ********* 
    else if(Trigger.isBefore && Trigger.isDelete) 
    {    
        //Edit by: Danudath leebandit
        //CR: Task assignment notification  
       if(RunTrigger || Test.isRunningTest()){ 
           TaskEmailNotifyHandler.sendEmail(Trigger.old);
      }

    } 
    
    // ********   AFTER INSERT TRIGGER RUN HERE   ********* 
    else if(Trigger.isAfter && Trigger.isInsert) 
    {
        if(RunTrigger || Test.isRunningTest()){
            TaskTriggerHandler.handlerAfterInsert(Trigger.new);

            TASKS2OProvider.integrate(Trigger.new, 'EWMService');
        }
    } 
    // ********   BEFORE UPDATE TRIGGER RUN HERE   ********* 
/*    else if(Trigger.isAfter && Trigger.isUpdate) 
    {        
     
    } */
    // ********   AFTER DELETE TRIGGER RUN HERE   *********  
/*    else if(Trigger.isAfter && Trigger.isDelete) 
    {        
        
    } */
    System.debug('::: TaskTrigger End ::::');
}