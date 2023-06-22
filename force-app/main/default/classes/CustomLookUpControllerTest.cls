@isTest
public class CustomLookUpControllerTest
{
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
    static void fetchLookUpValues()
    {
        Test.startTest();
        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'User1' , 'test@tmbbank.com' , false).get(0);
        insert u;
        Account acc = RTL_TestUtility.createAccounts(1,false).get(0);
        insert acc;
        
        List<Opportunity> Opportunitys = new List<Opportunity>{
            new Opportunity(Name = 'this is test class', StageName = 'Analysis ', CloseDate = Date.today().addDays(2), Expected_submit_date__c = Date.today(), AccountId = acc.Id),
                new Opportunity(Name = 'a developer is not a tester', StageName = 'Analysis ', CloseDate = Date.today().addDays(2), Expected_submit_date__c = Date.today(), AccountId = acc.Id),
                new Opportunity(Name = 'test is ...', StageName = 'Analysis ', CloseDate = Date.today().addDays(2), Expected_submit_date__c = Date.today(), AccountId = acc.Id),
                new Opportunity(Name = 'eiei', StageName = 'Analysis ', CloseDate = Date.today().addDays(2), Expected_submit_date__c = Date.today(),AccountId = acc.Id),
                new Opportunity(Name = 'this is test controller', StageName = 'Analysis ', CloseDate = Date.today().addDays(2), Expected_submit_date__c = Date.today(),AccountId = acc.Id)
                };
                    
                    insert Opportunitys;
        
        customLookUpController.fetchLookUpValues('%test%','Opportunity','Name','','StageName', '', 'StageName', false,true);
        //customLookUpController.fetchLookUpValues('UserTest','Account', 'Name', '', '', '', '', false, false);
        Test.stopTest();
        
    }
    
    @isTest
    static void fetchLookUpValuesSOSL()
    {
        Test.startTest();
        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'User1' , 'test@tmbbank.com' , false).get(0);
        insert u;
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Mobile_Number_PE__c = '0987654321';
        insert acc;
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = acc.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        customLookUpController.fetchLookUpValuesSOSL('Test','Account', 'Name, Mobile_Number_PE__c', '', 'Mobile_Number_PE__c');
        
        Test.stopTest();
        
    }
    
    @isTest
    static void getPicklistValue()
    {
        Test.startTest();       
        customLookUpController.getPicklistValue('CampaignMember','RTL_Contact_Status__c');       
        Test.stopTest();
        
    }
    
}