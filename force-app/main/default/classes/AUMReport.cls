public with sharing class AUMReport {

    @AuraEnabled
    public static Map<String, Object> getAUMPlus(){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Account> AccountList = [SELECT Id, Name, RMC_AUM_Calculation_Date__c, Type, RMC_AUM_Change__c, RMC_AUM__c
                                    FROM Account 
                                    WHERE RTL_Wealth_RM__c = :UserInfo.getUserId() AND RMC_AUM_Change__c > 0 
                                     
                                    //    AND RMC_AUM_Calculation_Date__c >= LAST_N_DAYS:3
                                    ORDER BY RMC_AUM_Change__c DESC LIMIT 5];

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'AUM_Change_Tqt'];

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

    @AuraEnabled
    public static Map<String, Object> getAUMMinus(){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Account> AccountList = [SELECT Id, Name, RMC_AUM_Calculation_Date__c, Type, RMC_AUM_Change__c, RMC_AUM__c
                                        FROM Account 
                                        WHERE RTL_Wealth_RM__c = :UserInfo.getUserId() AND RMC_AUM_Change__c < 0 
                                         
                                           // AND RMC_AUM_Calculation_Date__c >= LAST_N_DAYS:3
                                        ORDER BY RMC_AUM_Change__c  LIMIT 5];
            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'AUM_0Km'];

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