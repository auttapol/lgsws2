public with sharing class PEUpdateHelper {

    static FINAL String STR_INSERT = 'insert';
    static FINAL String STR_UPDATE = 'update';
    public String str_Action;
    public Account acct;
    
    @AuraEnabled
    public static Account getAccountCustomer(Id recordId){
        Account getAcct = new Account();
        getAcct = [SELECT Name,Customer_Name_PE_Eng__c,Account_Type__c,Customer_Type__c,
        Disqualified_Reason__c,Account_Plan_Flag__c,Mobile_Number_PE__c,Primary_Address_Line_1_PE__c
        ,Phone,Primary_Address_Line_2_PE__c,Primary_Phone_Ext_PE__c,Primary_Address_Line_3_PE__c,
        Email_Address_PE__c,Province_Primary_PE__c,Zip_Code_Primary_PE__c,Country_Primary_PE__c,
        Product_Group_1__c,Amount_1__c,Product_Group_2__c,Amount_2__c,Product_Group_3__c,Owner.name,
        Amount_3__c,Channel__c,Other_Channel__c,Branch_Referred__c,Campaign_ID__c,TMB_Employee_ID__c
        ,Remark__c,TMB_Employee_Name__c,Branch_and_Zone__c,Suggested_Segment__c,
        Suggested_Sub_Segment__c FROM Account WHERE Id=:recordId LIMIT 1];
        return getAcct;
    }

    @AuraEnabled
    public static Boolean loadData(String sectionName,String recordId)
    {
        system.debug('loadDataCome');
        Boolean isVisible=false;
        Account acctDetail = new Account();
        Profile userProfile = new Profile();
        acctDetail = [SELECT id,recordType.name,RTL_RM_Name__c,OwnerId FROM Account WHERE id = :recordId ];
        userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
		isVisible = RTL_AccountUtility.verifyFieldSecurity(sectionName,userProfile.name,acctDetail.id);
        system.debug('loadDataout');
        return isVisible;
    }

    
    
}