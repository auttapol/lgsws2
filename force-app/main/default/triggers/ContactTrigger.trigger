trigger ContactTrigger on Contact (before insert, after insert,before update, after update, after delete, after undelete) {    
    //////////////////////////////////////
    // Create By : Thanakorn Haewphet
    // Email : tnh@ii.co.th
    // Create Date : 2015-02-26 
    // Summary : -
    //////////////////////////////////////
    System.debug('::: ContactTrigger Start ::::');
    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 
    if(RunTrigger){
         
        Id retailRTId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Retail Contact').getRecordTypeId();
        List<Contact> commercialContacts = new List<Contact>{};
        if(!Trigger.isDelete) {
            for(Contact contact: trigger.new) {
                if(contact.RecordTypeId != retailRTId) {
                    commercialContacts.add(contact);
                }
            }
        }
        
        // ********   BEFORE INSERT TRIGGER RUN HERE   ********* 
        if(Trigger.isBefore && Trigger.isInsert) 
        {        
            ContactTriggerHandler.handlerBeforeInsert(commercialContacts);
        }   
        // ********   BEFORE UPDATE TRIGGER RUN HERE   ********* 
        else if(Trigger.isBefore && Trigger.isUpdate) 
        {        
            ContactTriggerHandler.handlerBeforeUpdate(commercialContacts);
        } 
        // ********   BEFORE DELETE TRIGGER RUN HERE   ********* 
        else if(Trigger.isBefore && Trigger.isDelete) 
        {        
            
        } 
        // ********   AFTER INSERT TRIGGER RUN HERE   ********* 
        else if(Trigger.isAfter && Trigger.isInsert) 
        {
    
        } 
        // ********   BEFORE UPDATE TRIGGER RUN HERE   ********* 
/*      else if(Trigger.isAfter && Trigger.isUpdate) 
        {        
      
        } */
        // ********   AFTER DELETE TRIGGER RUN HERE   *********  
/*      else if(Trigger.isAfter && Trigger.isDelete) 
        {        
            
        }*/
    }
    System.debug('::: ContactTrigger End ::::');
}