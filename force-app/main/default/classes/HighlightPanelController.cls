public with sharing class HighlightPanelController {
    @AuraEnabled
    public static Map<String,String> getLatestNPS(String accId){
        Map<String,String> response = new Map<String,String>();
        //แก้ query
        List<CXM_Survey__c> surveyList = [SELECT Id, Survey_Score__c 
                                        FROM CXM_Survey__c 
                                        WHERE Account__c = :accId 
                                        AND Survey_Datetime__c = LAST_N_DAYS:30 ORDER BY Survey_Datetime__c DESC LIMIT 1];
        if(surveyList != null && surveyList.size() > 0){
            response.put('recordId', surveyList[0].Id);
            response.put('score', String.valueOf(surveyList[0].Survey_Score__c));            
        }else{
            response.put('score',  '-');    
        }
        return response;
    }

    @AuraEnabled
    public static Account getAccInfo(String accId){
        Account acc = [SELECT Id, RTL_Wealth_RM__r.Name, RTL_Wealth_RM__c, 
                        RTL_Assigned_BRC__r.Name, RTL_Assigned_BRC__c
                        FROM Account WHERE Id = :accId LIMIT 1];
       
        return acc;
    }

    @AuraEnabled
    public static String  getMainBank(String accId){
        List<Customer_Main_Bank_Info__c> mb = [SELECT Id, Name, Main_Bank_Status__c
                                FROM Customer_Main_Bank_Info__c 
                                WHERE Customer__c = :accId 
                                ORDER BY Calculation_Date__c DESC
                                LIMIT 1];
        String mainbank = '-';
        if(mb != null && mb.size() > 0 && mb[0].Main_Bank_Status__c != null){
            mainbank= mb[0].Main_Bank_Status__c;
        }
        System.debug(mainbank);
        return mainbank;
    }
}