trigger RTL_NBOHistoryTrigger on RTL_NBO_History__c ( before insert, before update, before delete, 
                            after insert, after update, after delete, after undelete ) {                        
    new RTL_NBOHistoryTriggerHandler().run();
}