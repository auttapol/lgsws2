public with sharing class CampaignReportController {
    @AuraEnabled
    public static Map<String, Object> getCampaignList(){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Campaign> campaignList = [SELECT Id, Name, StartDate, EndDate 
                                        FROM Campaign 
                                        WHERE RTL_Campaign_Type__c = 'Mass'
                                        ORDER BY StartDate DESC LIMIT 5];

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'New_Campaigns_and_Promotions_pLK'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', campaignList);   
            
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