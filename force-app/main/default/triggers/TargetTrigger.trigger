trigger TargetTrigger on Target__c (before insert, after insert,before update, after update, after delete, after undelete) {
    //////////////////////////////////////
    // Create By : Thanakorn Haewphet
    // Email : tnh@ii.co.th
    // Create Date : 2014-11-12 
    // Summary : 
    //////////////////////////////////////
    System.debug('::: TargetTrigger Start ::::');
    // Use App Configuration to control =>  go to  App Setup > Develop > Custom Settings > AppConfig > Manage > runtrigger and then change the value
    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 
    if(RunTrigger){
        // ********   BEFORE INSERT TRIGGER RUN HERE   ********* 
        if(Trigger.isBefore && Trigger.isInsert) 
        {        
             if(RunTrigger || Test.isRunningTest() )
              if(RunTrigger){
              TargetTriggerHandler.handlerBeforeInsert(Trigger.new);
             }
        }     
        // ********   BEFORE UPDATE TRIGGER RUN HERE   ********* 
        else if(Trigger.isBefore && Trigger.isUpdate) 
        {        
            if(RunTrigger || Test.isRunningTest() )
            if(RunTrigger){
          TargetTriggerHandler.handlerBeforeUpdate(Trigger.new,Trigger.old);
            }        
        } 
        // ********   BEFORE DELETE TRIGGER RUN HERE   ********* 
        //else if(Trigger.isBefore && Trigger.isDelete) 
        //{        
        
        //} 
        // ********   AFTER INSERT TRIGGER RUN HERE   ********* 
         else if(Trigger.isAfter && Trigger.isInsert) 
        {
         TargetNITriggerHandler.handlerBeforeUpdate(Trigger.new,Trigger.old);
            
            //byDA :04Sep2015   
            TargetNITriggerHandler.handlerAfterInsert(Trigger.new);
        } 
        // ********   BEFORE UPDATE TRIGGER RUN HERE   ********* 
         else if(Trigger.isAfter && Trigger.isUpdate) 
        {     
            //byDA :04Sep2015   
            TargetNITriggerHandler.handlerAfterUpdate(Trigger.new);
        }
        // ********   AFTER DELETE TRIGGER RUN HERE   *********  
        // else if(Trigger.isAfter && Trigger.isDelete) 
        //{        
        
        // }
    }
    System.debug('::: TargetTrigger End ::::');
}