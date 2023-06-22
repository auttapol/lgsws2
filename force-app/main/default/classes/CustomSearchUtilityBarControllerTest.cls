@isTest
public class CustomSearchUtilityBarControllerTest {

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
        
        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'User1' , 'test@tmbbank.com' , false).get(0);
        u.RTL_Branch_Code__c  = '001';
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
        insert masterC;       
        
    }
    
    @isTest static void searchCampaignMember() 
    {
        // Implement test code
        Test.StartTest();     
        
        // Implement test code
        Account acc = [SELECT Id FROM Account LIMIT 1];     
        //Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Lead ld = [SELECT Id,FirstName,LastName,RTL_ID_Type__c,RTL_Citizen_Id__c,RTL_Mobile_Number__c,OwnerId,Status,IsConverted,RTL_Allow_Convert_Lead__c FROM Lead LIMIT 1];
        Campaign  masterC = [SELECT Id,isActive FROM Campaign WHERE isActive = true LIMIT 1];            
        
        CampaignMember cm = new CampaignMember();
        //cm.ContactId = ct.id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.RTL_Product_Group_1__c = 'LOAN';
        cm.RTL_OfferResult_Product_1__c = 'Interested';
        cm.LeadId = ld.Id;
        cm.RTL_Marketing_Code__c = 'ABCD12345';
        insert cm;
        
        Test.StopTest();
        CustomSearchUtilityBarController.searchCampaignMember(cm.Id);
    }
    
    @isTest static void checkProfileAssign() 
    {
        // Implement test code
        CustomSearchUtilityBarController.checkProfileAssign();
    }
    
    @isTest static void checkProfileAssignLoginAs() 
    {
        // Implement test code
        User u = [SELECT Id,ProfileId FROM User LIMIT 1];
        
        System.runAs(u) 
        {
            // The following code runs as user 'u'
            CustomSearchUtilityBarController.checkProfileAssign();
        }
        
    }
}