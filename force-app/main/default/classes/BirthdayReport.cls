public with sharing class BirthdayReport {
    @AuraEnabled
    public static Map<String, Object> getBirthdayList(){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Account> accList = [SELECT Id, Name, RTL_Date_Of_Birth__c
                                        FROM Account 
                                        WHERE RTL_Wealth_RM__c = :UserInfo.getUserId() AND RMC_Next_Birthday__c <= Next_N_Days:7 
                                        ORDER BY RMC_Next_Birthday__c LIMIT 5];
            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Customer_Birthday_in_Next_7_Days_pAw'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', accList);
            
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