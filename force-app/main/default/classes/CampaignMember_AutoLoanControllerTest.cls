@isTest
public with sharing class CampaignMember_AutoLoanControllerTest {
    public CampaignMember_AutoLoanControllerTest() {

    }
    private static String encryptKey {
        get {
            return '208f6c8723b80c36fefc349575764dd14baf52d950a98c101034c403b1172b65';
        }
    }
    @testSetup static void setup() {
        // Implement test code
        
        TestUtils.createAppConfig();
        
        //Add for Test campaignmember to CXM
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'CXM_SERVICE_CONNECTOR';
        Aconfig.Value__c = 'true';        
        apps.add(Aconfig);
        insert apps;
        TestUtils.prepareIntegrationMapping();
        TestUtils.prepareEIMmaps();
        
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
             
        Id recordTypeId = Schema.SObjectType.CampaignMember.getRecordTypeInfosByName().get('Retail Campaign Member').getRecordTypeId();
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
        masterC.CampaignMemberRecordTypeId = recordTypeId;
        insert masterC;       
    }
    
    @isTest static void checkPermissionToEdit() 
    {
        // Implement test code
        Test.StartTest();
        // Implement test code  
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));

        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Campaign  masterC = [SELECT Id, CampaignMemberRecordTypeId  FROM Campaign LIMIT 1];
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.CampaignId = masterC.id;
        cm.RTL_Contact_Status__c = 'New';
        cm.RTL_Product_Group_1__c = 'Auto Loan';
        cm.RTL_Contact_Method__c = 'AL Sales';
        cm.RTL_Is_Interface_Success__c = false; 
        cm.RTL_Is_Send_To_HPAP__c = false; 
        insert cm;
        
        CampaignMember_AutoLoanController.checkPermissionToEdit(cm.Id);
        Test.StopTest();
    }
    
    @isTest static void checkPermissionToEdit_Error() 
    {
        // Implement test code
        Test.StartTest();
        // Implement test code      
        try{
            CampaignMember_AutoLoanController.checkPermissionToEdit('xxxxxx');
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.StopTest();
    }
}