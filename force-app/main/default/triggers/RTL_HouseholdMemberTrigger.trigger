trigger RTL_HouseholdMemberTrigger on RTL_Household_Member__c (before insert, after insert,before update, after update, after delete, after undelete) {
    new RTL_HouseholdMemberTriggerHandler().run();
}