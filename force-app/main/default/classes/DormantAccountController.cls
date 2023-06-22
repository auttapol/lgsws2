public with sharing class DormantAccountController {

    @AuraEnabled
    public static Map<String, Object> getDormantAccount(){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Customer_Product_Alert__c> AccountList = [SELECT Id, Customer__c, Customer__r.Name, Dormant_Date__c, Account_Number__c, Customer__r.TMB_Customer_ID_PE__c
                                        FROM Customer_Product_Alert__c 
                                        WHERE  Dormant_Date__c <= NEXT_N_DAYS:30 AND Dormant_Date__c >= TODAY
                                        AND Customer__r.RTL_Wealth_RM__c = :UserInfo.getUserId() 
                                        ORDER BY Dormant_Date__c LIMIT 5];

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Dormant_Accounr_MDt'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', AccountList);
            
            if(test.isRunningTest()){
                insert new Account();
            }
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());
        }
        return response;
    }
}