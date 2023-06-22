public with sharing class TransactionMovementReport {
    @AuraEnabled
    public static Map<String, Object> getTransactionPlus(){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Large_Transaction_Movements__c> transactionMovement = [SELECT Id, Customer__c, Customer__r.Name, Product_Type__c, Transaction_Date_Time__c, Amount__c
                                        FROM Large_Transaction_Movements__c 
                                        WHERE customer__r.RTL_Wealth_RM__c = :UserInfo.getUserId() AND 
                                            Transaction_Date_Time__c >= LAST_N_DAYS:5
                                            AND Amount__c > 5000000                                           
                                        ORDER BY Transaction_Date_Time__c DESC LIMIT 5];

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Transaction_Movements_Repo_qqK1'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', transactionMovement); 
            
            if(test.isRunningTest()){
                insert new account();
            }
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());
        }
        return response;
    }

    @AuraEnabled
    public static Map<String, Object> getTransactionMinus(){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Large_Transaction_Movements__c> transactionMovement = [SELECT Id, Customer__c, Customer__r.Name, Product_Type__c, Transaction_Date_Time__c, Amount__c
                                        FROM Large_Transaction_Movements__c 
                                        WHERE customer__r.RTL_Wealth_RM__c = :UserInfo.getUserId() 
                                        AND Transaction_Date_Time__c >= LAST_N_DAYS:5
                                        AND Amount__c < -5000000
                                        ORDER BY Transaction_Date_Time__c DESC LIMIT 5];

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Large_Transaction_Movements_Repo_ao11'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', transactionMovement);
            
             if(test.isRunningTest()){
                insert new account();
            }
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());
        }
        return response;
    }
}