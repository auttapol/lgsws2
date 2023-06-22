@isTest
public class customCampaignMemberHistoryCtrlTest {
 @testSetup static void setup() {
        // Implement test code
        
        TestUtils.createAppConfig();
        TestUtility_Referral.createAppConfigReferralAssignment();
        TestUtility_Referral.createReferralAssignment();
        TestUtility_Referral.createAppConfigCallMeNowBH();
        
        //Add for Test campaignmember to CXM
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'CXM_SERVICE_CONNECTOR';
        Aconfig.Value__c = 'true';        
        apps.add(Aconfig);
        insert apps;
        TestUtils.prepareIntegrationMapping();
        TestUtils.prepareEIMmaps();  
     
     
              
    }
    
    @isTest
	static void HistoryWrapper()
	{
        Test.startTest();
        
        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'User1' , 'test@tmbbank.com' , false).get(0);
        insert u;
        
        Campaign masterC = new Campaign();
        masterC.Name = 'Test Campaign';
        masterC.OwnerId  = u.id;
        masterC.isActive = true;
        masterC.Approvedflag__c = true;
        masterC.Status = 'In Progress';
        masterC.RTL_Call_Start_Date__c = Date.today();
        masterC.RTL_Call_End_Date__c = Date.today().addDays(7);
        masterC.startDate = Date.today();
        masterC.endDate = Date.today().addDays(7);
        masterC.RTL_Campaign_Code_10_digits__c = 'DFFFLOC11A';
        insert masterC;  
        
        RTL_Campaign_Member_History__c cmh = new RTL_Campaign_Member_History__c();
        cmh.RTL_Date__c = Date.today();
        cmh.RTL_Modified_By__c = UserInfo.getUserId();
        cmh.RTL_Campaign__c = masterC.Id;
        insert cmh;
        
       	RTL_Campaign_Member_History_detail__c cmhd = new RTL_Campaign_Member_History_detail__c();
        cmhd.RTL_Campaign_Member_History__c = cmh.Id;
        cmhd.RTL_Field_Old_Value__c = 'New';
        cmhd.RTL_Field_New_Value__c = 'Contact';
        cmhd.RTL_Field_Name__c = 'RTL_Contact_Status__c';
        insert cmhd;
            
        customCampaignMemberHistoryCtrl.HistoryWrapper hisWarp = new customCampaignMemberHistoryCtrl.HistoryWrapper(cmhd);            
        
		Test.stopTest();

	}
    
    @isTest
	static void getHistoryDetails()
	{
        Test.startTest();
        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'User1' , 'test@tmbbank.com' , false).get(0);
        insert u;
        
        Account acc = RTL_TestUtility.createAccounts(1,false).get(0);
        insert acc;
        
        AccountTeamMember atm = new AccountTeamMember(accountid = acc.id, UserId = u.id);
        insert atm;
        
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
        masterC.Approvedflag__c = true;
        masterC.Status = 'In Progress';
        masterC.RTL_Call_Start_Date__c = Date.today();
        masterC.RTL_Call_End_Date__c = Date.today().addDays(7);
        masterC.startDate = Date.today();
        masterC.endDate = Date.today().addDays(7);
        masterC.RTL_Campaign_Code_10_digits__c = 'DFFFLOC11A';
        insert masterC;  
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.RTL_Product_Group_1__c = 'Deposit';
        insert cm;
		customCampaignMemberHistoryCtrl.getHistoryDetails(cm.Id);
        
		Test.stopTest();

	}
    
	@isTest
	static void getHistoryDetailsWithLimit()
	{
        Test.startTest();
        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'User1' , 'test@tmbbank.com' , false).get(0);
        insert u;
        
        Account acc = RTL_TestUtility.createAccounts(1,false).get(0);
        insert acc;
        
        AccountTeamMember atm = new AccountTeamMember(accountid = acc.id, UserId = u.id);
        insert atm;
        
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
        masterC.Approvedflag__c = true;
        masterC.Status = 'In Progress';
        masterC.RTL_Call_Start_Date__c = Date.today();
        masterC.RTL_Call_End_Date__c = Date.today().addDays(7);
        masterC.startDate = Date.today();
        masterC.endDate = Date.today().addDays(7);
        masterC.RTL_Campaign_Code_10_digits__c = 'DFFFLOC11A';
        insert masterC;  
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.RTL_Product_Group_1__c = 'Deposit';
        insert cm;
		customCampaignMemberHistoryCtrl.getHistoryDetailsWithLimit(cm.Id,2);
        
		Test.stopTest();

	}

}