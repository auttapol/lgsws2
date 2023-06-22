public with sharing class AccountDetailPageNewEditV2 {

    
   @AuraEnabled
   public static Account getAccountCustomer(string recordId){
    Account acctRec;
    acctRec = [SELECT Name,Service_class__c,Visit_Class__c,Industry__c,Group__c,ParentId,
    High_Risk_Flag__c,Account_Plan_Flag__c,Account_Plan_Form__c,Group_Key_Decision_Maker__c,
    Key_Decision_Company__c,X4G_Base__c,Sub_4G__c FROM Account WHERE id = :recordId LIMIT 1];
       return acctRec;
   }

@AuraEnabled
   public static Boolean[] loadData(string section,string section2,string section3,string section4,string recordId)
   {
    Boolean isVisible;
    Boolean isVisible_B;
    Boolean isVisible_C;
    Boolean isVisible_D;
    Boolean isVisible_E;
    Account acctDetail = [SELECT id,recordType.name,RTL_RM_Name__c,OwnerId,Core_Banking_Suggested_Segment__c FROM Account WHERE id = :recordId ];
    Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
    Boolean[] canVisible = new Boolean[]{};
     if(section2 != null && section2 != ''){
           isVisible = RTL_AccountUtility.verifyFieldSecurity(section,userProfile.name, acctDetail.id);
           isVisible_B = RTL_AccountUtility.verifyFieldSecurity(section2,userProfile.name, acctDetail.id);
           isVisible_C = RTL_AccountUtility.verifyFieldSecurity(section3,userProfile.name, acctDetail.id);
           isVisible_D = RTL_AccountUtility.verifyFieldSecurity(section4,userProfile.name, acctDetail.id);
           canVisible.add(isVisible);
           canVisible.add(isVisible_B);
           canVisible.add(isVisible_C);
           canVisible.add(isVisible_D);
           canVisible.add(isVisible_E);
           
       }else{
           isVisible = RTL_AccountUtility.verifyFieldSecurity(section,userProfile.name, acctDetail.id);
           canVisible.add(isVisible);
       }   
       return canVisible;

   }
   
}