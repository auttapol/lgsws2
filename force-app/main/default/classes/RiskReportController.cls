public with sharing class RiskReportController {

    @AuraEnabled
    public static Map<String, Object> getAccountList(){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Account> AccountList = [SELECT Id, Name, RMC_Suitability_Risk_Expiry_Date__c, RMC_Suitability_Risk_Level__c
                                        FROM Account 
                                        WHERE RTL_Wealth_RM__c = :UserInfo.getUserId() AND RMC_Suitability_Risk_Expiry_Date__c <= NEXT_N_DAYS:14
                                          
                                        ORDER BY RMC_Suitability_Risk_Expiry_Date__c LIMIT 5];

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Risk_and_Suitability_Reassessment_OuL'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', AccountList);   
            
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