trigger RTL_HouseholdTrigger on RTL_Household__c (before insert, after insert,before update, after update, after delete, after undelete) {
    new RTL_HouseholdTriggerHandler().run();
}