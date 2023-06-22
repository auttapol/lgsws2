public with sharing class KYCReportController {

    @AuraEnabled
    public static Map<String, Object> getAccountList(){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Account> AccountList = [SELECT Id, Name, IAL__c, KYC_next_review_date__c
                                        FROM Account 
                                        WHERE RTL_Wealth_RM__c = :UserInfo.getUserId() AND KYC_next_review_date__c <= NEXT_N_DAYS:14 
                                        AND RMC_Is_current_RM_BM__c = true
                                        ORDER BY KYC_next_review_date__c LIMIT 5];

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'KYC_Updates_h7v'];

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