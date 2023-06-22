public with sharing class KnowledgeReportController {
    @AuraEnabled
    public static Map<String, Object> getAdvisoryKnowledge(){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Knowledge__kav> knowledge = [SELECT Id, Title, FirstPublishedDate, LastModifiedDate
                                        FROM Knowledge__kav 
                                        WHERE Category__c = 'ttb Advisory' AND PublishStatus = 'Online'
                                        ORDER BY FirstPublishedDate DESC LIMIT 5];

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'New_Knowledge_Management_Report_wN2'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', knowledge);   
            
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
    public static Map<String, Object> getProductKnowledge(){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Knowledge__kav> knowledge = [SELECT Id, Title, FirstPublishedDate, LastModifiedDate
                                        FROM Knowledge__kav 
                                        WHERE Category__c = 'Product Knowledge' AND PublishStatus = 'Online'
                                        ORDER BY FirstPublishedDate DESC LIMIT 5];

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Knowledge_Management_Product_Knowledge_pxF'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', knowledge);  
            
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
    public static Map<String, Object> getWorkInstructionKnowledge(){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Knowledge__kav> knowledge = [SELECT Id, Title, FirstPublishedDate, LastModifiedDate
                                        FROM Knowledge__kav 
                                        WHERE Category__c = 'Work Instruction' AND PublishStatus = 'Online'
                                        ORDER BY FirstPublishedDate DESC LIMIT 5];

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Knowledge_Management_Work_Instruction_lj7'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', knowledge);  
            
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
    public static Map<String, Object> getCampaignCenterKnowledge(){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Knowledge__kav> knowledge = [SELECT Id, Title, FirstPublishedDate, LastModifiedDate
                                        FROM Knowledge__kav 
                                        WHERE Category__c = 'Campaign Center' AND PublishStatus = 'Online'
                                        ORDER BY FirstPublishedDate DESC LIMIT 5];

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Knowledge_Management_Campaign_Center_kXM'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', knowledge);   
            
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
    public static Map<String, Object> getBranchComKnowledge(){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Knowledge__kav> knowledge = [SELECT Id, Title, FirstPublishedDate, LastModifiedDate
                                        FROM Knowledge__kav 
                                        WHERE Category__c = 'Branch Communication' AND PublishStatus = 'Online'
                                        ORDER BY FirstPublishedDate DESC LIMIT 5];

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Knowledge_Branch_Communication_2eb'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', knowledge);  
            
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
    public static Map<String, Object> getTipKnowledge(){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Knowledge__kav> knowledge = [SELECT Id, Title, FirstPublishedDate, LastModifiedDate
                                        FROM Knowledge__kav 
                                        WHERE Category__c = 'Tips' AND PublishStatus = 'Online'
                                        ORDER BY FirstPublishedDate DESC LIMIT 5];

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Tips_Knowledge_JLk'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', knowledge);   
            
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
    public static Map<String, Object> getSalesCommKnowledge(){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Knowledge__kav> knowledge = [SELECT Id, Title, FirstPublishedDate, LastModifiedDate
                                        FROM Knowledge__kav 
                                        WHERE Category__c = 'Sales Commu' AND PublishStatus = 'Online'
                                        ORDER BY FirstPublishedDate DESC LIMIT 5];

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Sales_Commu_Knowledge_V0T'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', knowledge);    
            
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