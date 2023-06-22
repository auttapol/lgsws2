trigger TitleAndProductTrigger on Title_and_Product_Group_Mapping__c (before insert, after insert,before update, after update, after delete, after undelete) {
    
    System.debug('::: UserTrigger Start ::::');
    Boolean RunUserTrigger = false;
   // Use App Configuration to control =>  go to  App Setup > Develop > Custom Settings > AppConfig > Manage > runtrigger and then change the value
   if(!Test.isRunningTest()){
         RunUserTrigger = AppConfig__c.getValues('runUserTrigger').Value__c == 'true' ;
   }
   //Boolean RunTrigger = false;
   
   // ********   AFTER INSERT TRIGGER RUN HERE   *********  
   if(Trigger.isAfter && Trigger.isInsert)
   {
       if(RunUserTrigger || Test.isRunningTest())
       {
        TitleAndProductTriggerHandler.handleAfterInsert(Trigger.new,Trigger.oldMap );
       }
   } 
   // ********   AFTER UPDATE TRIGGER RUN HERE   *********  
   else if(Trigger.isAfter && Trigger.isUpdate)
   {
       if(RunUserTrigger || Test.isRunningTest())
       {
        TitleAndProductTriggerHandler.handleAfterUpdate(Trigger.new,Trigger.oldMap);
       }
   } 

   if(Trigger.isBefore && Trigger.isInsert)
   {
       if(RunUserTrigger || Test.isRunningTest())
       {
        TitleAndProductTriggerHandler.handleBeforeInsert(Trigger.new);
       }
   } 

   if(Trigger.isBefore && Trigger.isUpdate)
   {
       if(RunUserTrigger || Test.isRunningTest())
       {
        TitleAndProductTriggerHandler.handleBeforeUpdate(Trigger.new);
       }
   } 
   System.debug('::: UserTrigger End ::::');

}