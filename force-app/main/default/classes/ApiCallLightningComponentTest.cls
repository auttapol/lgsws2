@isTest
public class ApiCallLightningComponentTest {
    @testSetup static void setupData(){
        TestUtils.createAppConfig();
        TestUtility_Referral.createAppConfigReferralAssignment();
        TestUtility_Referral.createReferralAssignment();
        TestUtility_Referral.createAppConfigCallMeNowBH();       
        
        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'User1' , 'test@tmbbank.com' , false).get(0);
        u.RTL_Branch_Code__c  = '001';
        insert u;
        
        Account acc = RTL_TestUtility.createAccounts(1,false).get(0);
        insert acc;
        
        Contact ct = RTL_TestUtility.createContacts(acc);
        ct.TMB_Customer_ID__c = acc.TMB_Customer_ID_PE__c;
        ct.OwnerId = u.id;
        insert ct;
        
        Lead lead = RTL_TestUtility.createLeads(1,false).get(0);
        insert lead;
        
  
        Branch_And_Zone__c branch = RTL_TestUtility.createBranchZone(1,true).get(0);
        RTL_Referral__c rf = new RTL_Referral__c(RTL_FirstName__c='Test Referral',
                                                           RTL_LastName__c='Without Account',
                                                           RTL_Mobile1__c = '1111111111',
                                                 RTL_Preferred_Branch__c = branch.Id);
        
        insert rf;        
          
        Campaign masterC = new Campaign();
        masterC.Name = 'Test Campaign';
        masterC.OwnerId  = u.id;
        masterC.isActive = true;
        masterC.Status = 'In Progress';
        masterC.RTL_Call_Start_Date__c = Date.today();
        masterC.RTL_Call_End_Date__c = Date.today().addDays(7);
        masterC.startDate = Date.today();
        masterC.endDate = Date.today().addDays(7);
        insert masterC;       
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.CampaignId = masterC.id;
        insert cm;
        
    }
    
	@isTest
    public static void getLayoutNameForCurrentUserProfile_Account(){
        test.startTest();
        List<Account> accList = [SELECT Id,Name From Account LIMIT 1];
        ApiCallLightningComponent.getLayoutNameForCurrentUserProfile(accList[0].Id,'Account');
        test.stopTest();
    }

    @isTest 
    public static void getLayoutNameForCurrentUserProfile_Contact()
    {        
        test.startTest();
        List<Contact> ct = [SELECT Id,Name FROM Contact LIMIT 1];
        ApiCallLightningComponent.getLayoutNameForCurrentUserProfile(ct[0].Id,'Contact');
        test.stopTest();
    }
    
      
    @isTest 
    public static void getLayoutNameForCurrentUserProfile_Lead()
    {      
        test.startTest();
        List<Lead> lead = [SELECT Id,Name FROM Lead LIMIT 1];
        ApiCallLightningComponent.getLayoutNameForCurrentUserProfile(lead[0].Id,'Lead');
        test.stopTest();
    }
    
      
    @isTest 
    public static void getLayoutNameForCurrentUserProfile_Referral()
    {       
        test.startTest();
        List<RTL_Referral__c> rf = [SELECT Id,Name FROM RTL_Referral__c LIMIT 1];
        ApiCallLightningComponent.getLayoutNameForCurrentUserProfile(rf[0].Id,'RTL_Referral__c');
        test.stopTest();
    }
    
      
    @isTest 
    public static void getLayoutNameForCurrentUserProfile_CampaignMember()
    {       
        test.startTest();
        List<CampaignMember> cm = [SELECT Id,Name FROM CampaignMember LIMIT 1];
        ApiCallLightningComponent.getLayoutNameForCurrentUserProfile(cm[0].Id,'CampaignMember');
        test.stopTest();
    }
}