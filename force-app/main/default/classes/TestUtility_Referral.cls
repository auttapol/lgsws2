@isTest
public class TestUtility_Referral {
    public static final Id SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    public static final Id SE_RMC_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE RMC / Telesales Profile' LIMIT 1].Id;
    public static final Id BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;
    public static final Id RMC_ROLE_ID = [SELECT Id FROM UserRole WHERE Name LIKE '%SME RMC%' LIMIT 1].id;
    public static Id referToRetailRecTypeId = Schema.Sobjecttype.RTL_Referral__c.getRecordTypeInfosByName().get('Refer to Retail').getRecordTypeId();
    public static Id referToCommercialRecTypeId = Schema.Sobjecttype.RTL_Referral__c.getRecordTypeInfosByName().get('Refer to Commercial').getRecordTypeId();
    public static Id referalCrossChannelRecTypeId = Schema.Sobjecttype.RTL_Referral__c.getRecordTypeInfosByName().get('Retail Cross Channel Referral').getRecordTypeId();
    public static List<Account> accountList {
        get
        {
            if(accountList == null){
                accountList = new List<Account>();
            }
            return accountList;
            
        }set;
    }
    
    public static List<Opportunity> opportunityList {
        get
        {
            if(opportunityList == null){
                opportunityList = new List<Opportunity>();
            }
            return opportunityList;
            
        }set;
    }
    
    public static User createRMCTestUser(Boolean doInsert) {
        User rmcUser = new User(FirstName='rmc', LastName='test user', 
                                UserName='rmc_testuser@tmb.com',
                                Email='rmc_testuser@tmbbank.com', Alias='RTLUser',
                                LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                ProfileId = SE_RMC_PROFILE_ID,UserRoleId=RMC_ROLE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                Reporting_Segment__c='SE',Region_Code__c = '002', Zone_Code__c = '003',
                                Employee_ID__c='0xx00');

        
        if(doInsert) insert rmcUser;
        return rmcUser;
    }
    
    public static User createBDMTestUser(Boolean doInsert) {
        User bdmUser = new User(FirstName='bdm', LastName='test user', 
                                UserName='bdm_testuser@tmbbank.com',
                                Email='bdm_testuser@tmbbank.com', Alias='bdm',
                                LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                ProfileId = BDM_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                Reporting_Segment__c='SE', Region_Code__c = '002', Zone_Code__c = '003',
                                Employee_ID__c='0000x');

        
        if(doInsert) insert bdmUser;
        return bdmUser;
    }
    
    public static List<RTL_Referral__c> createReferralsWithoutAccount(Integer size ,Id branchZoneId,String interestedProduct, String rtl_type ,Boolean doInsert) {
        List<RTL_Referral__c> referralList = new List<RTL_Referral__c>();
        
        for(Integer i = 0; i<size ; i++){
            RTL_Referral__c referral = new RTL_Referral__c(RTL_FirstName__c='Test Referral'+i,
                                                           RTL_LastName__c='Without Account'+i,
                                                           RTL_Preferred_Branch__c = branchZoneId,
                                                           RTL_Mobile1__c = '1111111111',
                                                           RTL_Interested_Product__c = interestedProduct,
                                                           RTL_Type__c = rtl_type,
                                                           RTL_Stage__c = 'New');
            referralList.add(referral);
        }

        if (doInsert)   insert referralList;
        return referralList;
    }
    
    public static List<RTL_Referral__c> createReferralsWithAccount(Integer size,Id acctId ,Id branchZoneId ,Boolean doInsert) {
        List<RTL_Referral__c> referralList = new List<RTL_Referral__c>();
        
        for(Integer i = 0; i<size ; i++){
            RTL_Referral__c referral = new RTL_Referral__c(RTL_FirstName__c='Test Referral'+i,
                                                           RTL_LastName__c='Without Account'+i,
                                                           RTL_Preferred_Branch__c = branchZoneId,
                                                           RTL_Mobile1__c = '1111111111',
                                                           RTL_Account_Name__c = acctId);
            referralList.add(referral);
        }

        if (doInsert)   insert referralList;
        return referralList;
    }
    
    public static List<RTL_Referral__c> createReferralsCrossChannelWithAccount(Integer size,Id acctId ,Id branchZoneId ,Id retailProductId,Boolean doInsert) {
        List<RTL_Referral__c> referralList = new List<RTL_Referral__c>();
        
        for(Integer i = 0; i<size ; i++){
            RTL_Referral__c referral = new RTL_Referral__c(RecordTypeId = referalCrossChannelRecTypeId,
                                                           RTL_Product_Name__c = retailProductId,
                                                           RTL_Preferred_Branch__c = branchZoneId,
                                                           RTL_Mobile1__c = '1111111111',
                                                           RTL_Account_Name__c = acctId);
            referralList.add(referral);
        }

        if (doInsert)   insert referralList;
        return referralList;
    }
    
    public static List<RTL_Referral__c> createReferralsCrossChannelWithoutAccount(Integer size,Id branchZoneId ,Id retailProductId,Boolean doInsert) {
        List<RTL_Referral__c> referralList = new List<RTL_Referral__c>();
        
        for(Integer i = 0; i<size ; i++){
            RTL_Referral__c referral = new RTL_Referral__c(RTL_FirstName__c = 'Test'+i,
                                                           RTL_LastName__c = 'Last Name'+i,
                                                           RecordTypeId = referalCrossChannelRecTypeId,
                                                           RTL_Product_Name__c = retailProductId,
                                                           RTL_Preferred_Branch__c = branchZoneId,
                                                           RTL_Mobile1__c = '1111111111');
            referralList.add(referral);
        }

        if (doInsert)   insert referralList;
        return referralList;
    }
    
    public static List<RTL_Referral__c> createReferralsWithoutBranch(Integer size ,Boolean doInsert) {
        List<RTL_Referral__c> referralList = new List<RTL_Referral__c>();
        
        for(Integer i = 0; i<size ; i++){
            RTL_Referral__c referral = new RTL_Referral__c(RTL_FirstName__c='Test Referral'+i,
                                                           RTL_LastName__c='Without Account'+i,
                                                           RTL_Mobile1__c = '1111111111');
            referralList.add(referral);
        }

        if (doInsert)   insert referralList;
        return referralList;
    }
    
    public static void createReferralAssignment(){
        RTL_Referral_Assignment__c refAssignment = new RTL_Referral_Assignment__c();
        refAssignment.RTL_Priority__c = 1;
        refAssignment.RTL_Referral_Type__c = 'Refer_to_Commercial';
        refAssignment.RTL_Referral_Field_Criteria_1__c = 'RTL_Preferred_Branch__c';
        refAssignment.RTL_Referral_Field_Value_1__c = '1';
        insert refAssignment;
    }
    
    
    
    public static void createAppConfigReferralAssignment(){     
        
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c appConfig1 = new AppConfig__c();
        appConfig1.Name = 'RTL_Referral_Assignment_ISNULL';
        appConfig1.Value__c = 'IS NULL';
        apps.add(appConfig1);
        
        AppConfig__c appConfig2 = new AppConfig__c();
        appConfig2.Name = 'RTL_Referral_Assignment_NOTNULL';
        appConfig2.Value__c = 'IS NOT NULL';
        apps.add(appConfig2);
        
        
        insert apps;
    }
    
    public static void createAppConfigCallMeNowBH(){     
        
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c appConfig1 = new AppConfig__c();
        appConfig1.Name = 'CallMeNowBH';
        appConfig1.Value__c = 'Call Me Now';
        apps.add(appConfig1);
        
        insert apps;
    }

}