public class RTL_DataQualityCheck {
    
    public List<RTL_Customer_Data_Validation__c> dataValidationToUpsert;
    public List<RTL_Data_Summary__c> dataSummaryToUpsert;
    public Map<Id,RTL_Customer_Data_Validation__c> accountDataValidationMap;
    public Map<Id,RTL_Data_Summary__c> accountDataSummaryMap;
    
    public RTL_DataQualityCheck(){
        dataValidationToUpsert = new List<RTL_Customer_Data_Validation__c>();
        dataSummaryToUpsert = new List<RTL_Data_Summary__c>();
        accountDataValidationMap = new Map<Id,RTL_Customer_Data_Validation__c>();
        accountDataSummaryMap = new Map<Id,RTL_Data_Summary__c>();
    }
    
    public void start(List<Account> accountList){
        for(RTL_Customer_Data_Validation__c dataValidation : [SELECT Id,Name,RTL_Account__c,RTL_Primary_Address_Mkt__c,RTL_Primary_Address_Zip_Mkt__c,
                                                              RTL_Registered_Address_Mkt__c,RTL_Registered_Address_Zip_Mkt__c,RTL_Office_Address_Mkt__c,
                                                              RTL_Office_Address_Zip_Mkt__c,RTL_Citizen_ID_Mkt__c,RTL_Mobile_Mkt__c,
                                                              RTL_Email_Mkt__c,RTL_DOB_Mkt__c,RTL_Occupation_Mkt__c, TMB_Customer_ID_PE__c
                                                              FROM RTL_Customer_Data_Validation__c WHERE RTL_Account__c IN:accountList]){
            accountDataValidationMap.put(dataValidation.RTL_Account__c,dataValidation);
        }
        for(RTL_Data_Summary__c dataSummary : [SELECT Id,Name,RTL_Account__c FROM RTL_Data_Summary__c WHERE RTL_Account__c IN:accountList]){
            accountDataSummaryMap.put(dataSummary.RTL_Account__c,dataSummary);
        }
        
        for(Account acct : accountList){
            RTL_Customer_Data_Validation__c validation = new RTL_Customer_Data_Validation__c();
            
            
            RTL_Data_Summary__c summary = new RTL_Data_Summary__c();
            //If Account have existing Data Validation record
            if(accountDataValidationMap.containsKey(acct.id)){
                validation = accountDataValidationMap.get(acct.id);    
            }  
            if(accountDataSummaryMap.containsKey(acct.id)){
                summary = accountDataSummaryMap.get(acct.id);
            }
            validation.TMB_Customer_ID_PE__c = acct.TMB_Customer_ID_PE__c;
            RTL_DataSummary result = new RTL_ValidateData(acct,validation,summary).execute();
            dataValidationToUpsert.add(transformDataValidation(acct.Id,validation,result));
            dataSummaryToUpsert.add(transformDataSummary(acct.Id,summary,result));
        }
        
        if(dataValidationToUpsert.size() > 0){
            upsert dataValidationToUpsert;
        }
        if(dataSummaryToUpsert.size()>0){
            upsert dataSummaryToUpsert;
        }
            
    }
    
    public RTL_Customer_Data_Validation__c transformDataValidation(Id acctId,RTL_Customer_Data_Validation__c validation,RTL_DataSummary dataSummary){
        if(validation.id == null)
            validation.RTL_Account__c = acctId;
        validation.RTL_Primary_Address_Quality__c = dataSummary.Quality.primaryAddr;
        validation.RTL_Primary_Address_Zip_Quality__c = dataSummary.Quality.primaryZipCode;
        validation.RTL_Registered_Address_Quality__c = dataSummary.Quality.registeredAddr;
        validation.RTL_Registered_Address_Zip_Quality__c = dataSummary.Quality.registeredZipCode;
        validation.RTL_Office_Address_Quality__c = dataSummary.Quality.officeAddr;
        validation.RTL_Office_Address_Zip_Quality__c = dataSummary.Quality.officeZipCode;
        validation.RTL_Citizen_ID_Quality__c = dataSummary.Quality.citizenID;
        validation.RTL_Mobile_Quality__c = dataSummary.Quality.mobile;
        validation.RTL_Email_Quality__c = dataSummary.Quality.email;
        validation.RTL_DOB_Quality__c = dataSummary.Quality.DOB;
        validation.RTL_Occupation_Quality__c = dataSummary.Quality.occupation;
        return validation;
    }
    public RTL_Data_Summary__c transformDataSummary(Id acctId,RTL_Data_Summary__c summary,RTL_DataSummary dataSummary){
        if(summary.Id == null)
            summary.RTL_Account__c = acctId;
        summary.RTL_Data_Age__c = dataSummary.getDataAgeStatus();
        summary.RTL_Data_Quality__c = dataSummary.getQualityStatus();
        summary.RTL_Marketing_Messages__c = dataSummary.getMarketingStatus();
        summary.RTL_Data_Age_Message__c = dataSummary.Age.pageMsg;
        return summary;
    }
    
     

}