public class RTL_DataQualitySummaryExtension {
    public Account account {get;set;} 
    public string acctId {get;set;}
    
    public string dataAgeStatus{get;set;}
    public string qualityStatus {get;set;}
    public string marketingStatus {get;set;}
         
    public boolean ageDisable{get;set;}
    public boolean ageRerender{get;set;}
    public string ageColor{get;set;}
        
    public boolean qtymktDisable{get;set;}    
    public boolean qtymktRerender{get;set;}
    public string qtymktColor{get;set;}
       
    public Integer score {get;set;}
    public Map<String,RTL_Data_Section_IDs__c> section {get;set;}
    public RTL_Data_Summary__c dataSummary {get;set;}
    
    public RTL_DataQualitySummaryExtension(ApexPages.StandardController stdController){
        Account acct = (Account)stdController.getRecord();
        //acct = [SELECT ID,RTL_Overall_Quality_Formula__c,RTL_Overall_Quality__c,RTL_Age_Result_Formula__c,    RTL_Quality_Result__c,RTL_Marketing_Result__c FROM Account WHERE Id =: acct.id ];
        Account thisAcc = [SELECT Id,Name , Primary_Address_Line_1_PE__c,Zip_Code_Primary_PE__c,Registered_Address_Line_1_PE__c,
                           Zip_Code_Registered_PE__c,Office_Address_Line_1_PE__c,Zip_Code_Office_PE__c,ID_Type_PE__c,ID_Number_PE__c,
                           Mobile_Number_PE__c,Email_Address_PE__c,RTL_Date_Of_Birth__c,RTL_Occupation_Details__c,
                           Segment_crm__c,RTL_RM_Last_Update__c,Core_Banking_Suggested_Segment__c,Account_Type__c,TMB_Customer_ID_PE__c
                           FROM Account WHERE Id =: acct.Id];
        account = thisAcc;
        acctId = String.ValueOf(account.Id).Left(15);
        section = GetsectionId();
        dataSummary = new RTL_Data_Summary__c();
        
    }
    
    public void updateAccount(){

        if(account.Account_Type__c == 'Retail Prospect' || account.Account_Type__c == 'Prospect' || account.Core_Banking_Suggested_Segment__c == 'Others'){
            qualityStatus = 'N.A.';
            marketingStatus = 'N.A.';
            dataAgeStatus = 'N.A.';
            
        }else{
            RTL_DataQualityCheck dataQualityCheck = new RTL_DataQualityCheck();
            dataQualityCheck.start(new List<Account>{account});
            dataSummary = getDataSummary();
            qualityStatus = dataSummary.RTL_Data_Quality__c;
            marketingStatus = dataSummary.RTL_Marketing_Messages__c;
            dataAgeStatus = dataSummary.RTL_Data_Age__c;
        }
        
        if(dataAgeStatus == 'Pass'){
            ageDisable = true;
            ageRerender = true;
            ageColor = '#00ff00';
            //score = 1;
        }else if(dataAgeStatus =='Fail'){
            ageDisable = true;
            ageRerender = true;
            ageColor = '#ff0000';
            //score = 0;
        }else if(dataAgeStatus == 'N.A.'){
            ageDisable = true;
            ageRerender = true;
            ageColor = '#000000';
        }else{
            ageRerender = false;
        }
        
        if(qualityStatus == 'Pass' && marketingStatus == 'Pass'){
            qtymktDisable = true;
            qtymktRerender = true;
            qtymktColor = '#00ff00';
            //score += 1;
        }else if(qualityStatus =='Fail' || marketingStatus == 'Fail'){
            qualityStatus = 'Fail';
            qtymktDisable = false;
            qtymktRerender = true;
            qtymktColor = '#ff0000';
            //score += 0;                        
        }else if(qualityStatus == 'N.A.' || marketingStatus == 'N.A.'){
            qualityStatus = 'N.A';
            qtymktDisable = true;
            qtymktRerender = true;
            qtymktColor = '#000000';
        }
        else{
            qtymktRerender = false;
        }
       
    }

    public Map<String,RTL_Data_Section_IDs__c>  GetsectionId(){
        Map<String,RTL_Data_Section_IDs__c> section = RTL_Data_Section_IDs__c.getAll();
        return section;
    }
    
    public RTL_Data_Summary__c getDataSummary(){
        RTL_Data_Summary__c summary = new RTL_Data_Summary__c();
        summary = [SELECT ID,Name,RTL_Data_Age__c,RTL_Marketing_Messages__c  ,RTL_Data_Quality__c ,RTL_Overall_Quality__c,
                   RTL_Data_Age_Message__c
                   FROM RTL_Data_Summary__c WHERE RTL_Account__c=:account.id];
        return summary;
    }
    
    public Boolean isSF1 {
    get {                   
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
            String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
            ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
            (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
        ) {
            return true;
        }else{
            return false;
        }
    }
}
    

}