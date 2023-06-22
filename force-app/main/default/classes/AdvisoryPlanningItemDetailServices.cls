public with sharing class AdvisoryPlanningItemDetailServices {
    @AuraEnabled  (cacheable=true)
    public static string getWatermarkHTML() {
        string userId = UserInfo.getUserId();
        User loginUser = [Select Id, Name, Employee_ID__c From User Where Id =: userId Limit 1];
        string userEmpId = loginUser.Employee_ID__c;

        return userEmpId;
    }
}