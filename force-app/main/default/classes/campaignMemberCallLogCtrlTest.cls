@isTest
public class campaignMemberCallLogCtrlTest {
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
    
    
    @isTest static void getCallLog() 
    {
        Test.StartTest();
        // Implement test code   
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Campaign  masterC = [SELECT Id FROM Campaign LIMIT 1];
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.RTL_Product_Group_1__c = 'Deposit';
        insert cm; 
        
        Task newTask = new Task();
        newTask.TaskSubtype = 'Call';
        newTask.Type = 'Outbound';
        newTask.Subject = 'Call Back';
        newTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call Log Record Type').getRecordTypeId();
        newTask.Call_Log_ID__c = '000000';
        newTask.Marketing_Code__c = '12345';
        newTask.Related_Object__c = cm.Id;
        insert newTask;
        
        campaignMemberCallLogCtrl.getCallLog(cm.Id, 2);
        Test.StopTest();
    }
    
    @isTest static void getCallBackHist() 
    {
        Test.StartTest();
        // Implement test code   
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Campaign  masterC = [SELECT Id FROM Campaign LIMIT 1];
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.RTL_Product_Group_1__c = 'Deposit';
        insert cm; 
        
        Task newTask = new Task();
        newTask.TaskSubtype = 'Call';
        newTask.Type = 'Outbound';
        newTask.Subject = 'Call Back';
        newTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call Log Record Type').getRecordTypeId();
        newTask.Call_Log_ID__c = '000000';
        newTask.Marketing_Code__c = '12345';
        newTask.Related_Object__c = cm.Id;
        newTask.Status = 'Completed';
        insert newTask;
        
        campaignMemberCallLogCtrl.getCallBackHist(cm.Id, 2);
        Test.StopTest();
    }
    
    @isTest static void getCallBackIncoming() 
    {
        Test.StartTest();
        // Implement test code   
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Campaign  masterC = [SELECT Id FROM Campaign LIMIT 1];
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.RTL_Product_Group_1__c = 'Deposit';
        insert cm; 
        
        Task newTask = new Task();
        newTask.TaskSubtype = 'Call';
        newTask.Type = 'Outbound';
        newTask.Subject = 'Call Back';
        newTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call Log Record Type').getRecordTypeId();
        newTask.Call_Log_ID__c = '000000';
        newTask.Marketing_Code__c = '12345';
        newTask.Related_Object__c = cm.Id;
        newTask.Call_Start_Datetime__c = Date.today().addDays(2);
        insert newTask;
        
        campaignMemberCallLogCtrl.getCallBackIncoming(cm.Id, 2);
        Test.StopTest();
    }
}