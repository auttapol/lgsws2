public class RTL_DataQualityDetailsExtension {
    public Account account {get;set;}
    public String  accountId {get;set;}
    public Label label {get;set;}
    public Map<String,RTL_Data_Section_IDs__c> section {get;set;}
    public RTL_Customer_Data_Validation__c dataValidation{get;set;}
    public boolean rendered{get;set;}
    
    public RTL_DataQualityDetailsExtension(ApexPages.StandardController stdController){
        account = (Account)stdController.getRecord();
        account = [SELECT Id,Name , Primary_Address_Line_1_PE__c,Zip_Code_Primary_PE__c,Registered_Address_Line_1_PE__c,
                           Zip_Code_Registered_PE__c,Office_Address_Line_1_PE__c,Zip_Code_Office_PE__c,ID_Type_PE__c,ID_Number_PE__c,
                           Mobile_Number_PE__c,Email_Address_PE__c,RTL_Date_Of_Birth__c,RTL_Occupation_Details__c,
                           Account_Type__c,RTL_RM_Last_Update__c,Segment_crm__c,TMB_Customer_ID_PE__c
                           FROM Account WHERE Id =: account.Id];
        
        accountId = String.ValueOf(account.id).Left(15);
        label = getMetadata();
        section = GetsectionId();
        if(account.Account_Type__c == 'Retail Prospect' || account.Account_Type__c == 'Prospect'){
          rendered=false;
        }else{
          rendered=true;
        }
    }
    
    public RTL_Customer_Data_Validation__c getDataValidation(){
        RTL_Customer_Data_Validation__c validation;
        validation = [SELECT ID,Name, RTL_Citizen_ID_Mkt__c ,RTL_Citizen_ID_Quality__c ,RTL_DOB_Mkt__c ,
                      RTL_DOB_Quality__c ,RTL_Email_Mkt__c ,RTL_Email_Quality__c,RTL_Mobile_Mkt__c , RTL_Mobile_Quality__c,
                      RTL_Occupation_Mkt__c ,RTL_Occupation_Quality__c  ,RTL_Office_Address_Marketing_Combined__c ,
                      RTL_Office_Address_Quality_Combined__c ,
                      RTL_Primary_Address_Marketing_Combined__c ,
                      RTL_Primary_Address_Quality_Combined__c  ,
                      RTL_Registered_Address_Marketing_Combine__c ,
                      RTL_Registered_Address_Quality_Combined__c  
                      FROM RTL_Customer_Data_Validation__c WHERE RTL_Account__c =:account.id];
        return validation;
    }
    
    public  Label getMetadata(){
        Label label = new Label();
        Map<String, Schema.SObjectType> GlobalMap = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult obj = GlobalMap.get('Account').getDescribe();
        
        Schema.DescribeFieldResult emailField = obj.Fields.getMap().get('Email_Address_PE__c').getDescribe();
            label.email = emailField.getLabel();
        Schema.DescribeFieldResult idnoField = obj.Fields.getMap().get('ID_Number_PE__c').getDescribe();
            label.idno = idnoField.getLabel();
        Schema.DescribeFieldResult mobiField = obj.Fields.getMap().get('Mobile_Number_PE__c').getDescribe();
            label.mobi = mobiField.getLabel();
        Schema.DescribeFieldResult officeAddrField = obj.Fields.getMap().get('Office_Address_Line_1_PE__c').getDescribe();
            label.officeAddr = officeAddrField.getLabel();
        Schema.DescribeFieldResult primaryAddrField = obj.Fields.getMap().get('Primary_Address_Line_1_PE__c').getDescribe();
            label.primaryAddr = primaryAddrField.getLabel();
        Schema.DescribeFieldResult DOBField = obj.Fields.getMap().get('RTL_Date_Of_Birth__c').getDescribe();
            label.DOBField = DOBField.getLabel();
        Schema.DescribeFieldResult occupationField = obj.Fields.getMap().get('RTL_Occupation_Details__c').getDescribe();
            label.occupation = occupationField.getLabel();
        Schema.DescribeFieldResult regisAddrField = obj.Fields.getMap().get('Registered_Address_Line_1_PE__c').getDescribe();
            label.regisAddr = regisAddrField.getLabel();
        Schema.DescribeFieldResult zipPrimaryField = obj.Fields.getMap().get('Zip_Code_Primary_PE__c').getDescribe();
            label.zipPrimary = zipPrimaryField.getLabel();
        Schema.DescribeFieldResult zipRegisField = obj.Fields.getMap().get('Zip_Code_Registered_PE__c').getDescribe();
            label.zipRegis = zipRegisField.getLabel();
        Schema.DescribeFieldResult zipOfficeField = obj.Fields.getMap().get('Zip_Code_Office_PE__c').getDescribe();
            label.zipOffice = zipOfficeField.getLabel();
        return  label;
    }
   
    public Map<String,RTL_Data_Section_IDs__c>  GetsectionId(){
        Map<String,RTL_Data_Section_IDs__c> section = RTL_Data_Section_IDs__c.getAll();
        return section;
    }
    public void updateAccountValidation(){
        RTL_DataQualityCheck dataQualityCheck = new RTL_DataQualityCheck();
        dataQualityCheck.start(new List<Account>{account});
        dataValidation = getDataValidation();
    }
    
    public class Label
    {
        public string email {get;set;}
        public string idno {get;set;}
        public string mobi {get;set;}
        public string officeAddr {get;set;}
        public string primaryAddr {get;set;}
        public string DOBField {get;set;}
        public string occupation {get;set;}
        public string regisAddr {get;set;}
        public string zipPrimary {get;set;}
        public string zipRegis {get;set;}
        public string zipOffice {get;set;}
    }
 
    
}