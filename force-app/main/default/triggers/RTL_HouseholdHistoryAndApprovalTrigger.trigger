trigger RTL_HouseholdHistoryAndApprovalTrigger on RTL_Household_History_and_Approval__c (before insert, after insert,before update, after update,before delete, after delete, after undelete) {
    new RTL_HouseholdHistoryTriggerHandler().run();
}