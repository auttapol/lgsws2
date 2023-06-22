/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ValidateOpportunityController_Test {
    public static final Id USER_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id; 
    public static final RecordType Existing_Customer = [SELECT Id FROM RecordType WHERE developername='Existing_Customer' AND SobjectType = 'Account' and IsActive = true LIMIT 1];
    public static final RecordType SE_Credit_Product = [SELECT Id FROM RecordType WHERE developername='SE_Credit_Product' AND SobjectType = 'Opportunity' and IsActive = true LIMIT 1];
    public static final RecordType Commercial_Account = [SELECT Id FROM RecordType WHERE developername='Commercial_Account' AND SobjectType = 'Lead' and IsActive = true LIMIT 1];
    public static final RecordType Refer_to_Retail = [SELECT Id FROM RecordType WHERE developername = 'Refer_to_Retail' AND SobjectType = 'RTL_Referral__c' LIMIT 1];
    public static final RecordType Commercial_Lead = [SELECT Id FROM RecordType WHERE developername = 'Commercial_Lead' AND SobjectType = 'Lead' LIMIT 1];
    public static final RecordType Exclusive_Campaign_Active = [SELECT id FROM recordType WHERE DeveloperName = 'Exclusive_Campaign_Active' AND SobjectType = 'Campaign' LIMIT 1];
    static User adminUser;

    public static Lead CreateValidLead(Id OwnerID, Id accId){
        Lead leadRec = new lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'Passport ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Individual';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.RecordTypeId = Commercial_Lead.id;
        leadRec.Interest_result__c = 'Yes';
        leadRec.OwnerID = OwnerID;
        leadRec.Account__c = accId;
        return leadRec;
    }

    @testSetup 
    static void setup() {
		TestUtils.createAppConfig();
        TestUtility_Referral.createAppConfigReferralAssignment();
        TestUtility_Referral.createReferralAssignment();
        TestUtility_Referral.createAppConfigCallMeNowBH();

        adminUser = TestUtils.createUsers(1,'USERADMIN','TESTCLASS','test_TMB@tmbbank.com',true)[0];

		List<AppConfig__c> mc = new List<AppConfig__c> ();
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        insert mc;
		
        List<Trigger_Msg__c> mc2 = new List<Trigger_Msg__c> ();
        mc2.Add(new Trigger_Msg__c(Name = 'Permission_Create_Opportunity', Description__c = 'Permission Invalid [You must be the owner or account team member to do so', isError__c = true));
        insert mc2;
		
		RTL_Branch_Manager_Title__c branchTitle = new RTL_Branch_Manager_Title__c(Name='Branch Manager',RTL_Value__c='Branch Manager');
		insert branchTitle;

		Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '611';
        bz.IsActive__c = true;
        insert bz;

        

        System.runAs(adminUser){
            User User01 = RTL_TestUtility.createUsers(1, 'testName', 'testLastname', 'test@tmb.com.test', false).get(0);
            User01.ProfileId = USER_PROFILE_ID;
            User01.isActive = true;
            User01.RTL_Branch_Code__c = bz.Branch_Code__c;
            User01.Employee_ID__c = '123456';
            insert User01;
        }

		
	}

    @isTest
    static void ValidateOpportunity_Test() {
        User user = [SELECT Id, Name FROM User WHERE Email = 'test@tmb.com.test' AND ProfileId =: USER_PROFILE_ID LIMIT 1];
        
        Account acct = RTL_TestUtility.createAccounts(1 , false).get(0);
        acct.Customer_Type__c = 'Individual';
        // acct.RecordType = Existing_Customer;
        acct.RecordTypeId = Existing_Customer.Id;
        acct.OwnerId = user.id;
        insert acct;

        Date d = date.today();
        Date d2 = d.addDays(30);

        Campaign masterC = RTL_TestUtility.createMasterCampaign('MasterCam1',
            'D20171001',
            'Exclusive',
            'MB', user
            );
        masterC.IsActive = true;
        insert masterC;
        System.debug('TEST masterC ::: '+ masterC);
        // Campaign childC = RTL_TestUtility.createChildCampaign('ChildCam1', '1', masterC, Exclusive_Campaign_Active);
        // childC.IsActive = true;
        // insert childC;
        // System.debug('TEST childC ::: '+ childC);
        
        Test.startTest();
		System.runAs(user){
            
            Integer length = 5;
            List<Opportunity> optylst = new List<Opportunity>();
            List<Lead> leadlst = new List<Lead>();
            List<RTL_Referral__c> referrallst = new List<RTL_Referral__c>();
            List<Campaign> campaignlst = new List<Campaign>();
            Branch_and_zone__c bz = [SELECT Id FROM Branch_and_zone__c WHERE Branch_Code__c = '611' LIMIT 1];

            leadlst = RTL_TestUtility.createLeads(length, false);
            referrallst = TestUtility_Referral.createReferralsWithAccount(length, acct.id, bz.id, false);

            for (Integer i = 0; i < length; i++) {

                Lead lead = leadlst.get(i);
                lead.RecordTypeId = Commercial_Lead.Id;
                lead.Primary_Campaign__c = masterC.Id;
                // lead.Pri_Campaign_Active__c = true;
                lead.OwnerId = user.Id;
                lead.Account__c = acct.Id;

                RTL_Referral__c refObj = referrallst.get(i);
                refObj.RTL_Type__c = 'Sell (เพื่อนำเสนอขาย)';
                refObj.RTL_Stage__c = 'New';

                Opportunity opty = new Opportunity();
                opty.RecordTypeId = SE_Credit_Product.id;
                opty.CloseDate = d2;
                opty.Expected_submit_date__c = d;
                opty.OwnerId = user.id;
                opty.AccountId = acct.Id;
                opty.Name = 'VO01 : BOND' + i;
                opty.StageName = 'Analysis';
                optylst.add(opty);
            }
            
            insert leadlst;
            insert referrallst;
            insert optylst;
            List<Campaign> tmpCamplst = [SELECT Id, Name, IsActive FROM Campaign WHERE Id =: masterC.Id];
            // for (Campaign cc: tmpCamplst) {
            //     cc.IsActive = true;
            //     campaignlst.add(cc);
            // }
            // update campaignlst;
            
            System.debug('TEST leadlst ::: '+ leadlst.get(0));
            System.debug('TEST leadlst Campaign relate::: '+ tmpCamplst.get(0));
            System.debug('TEST leadlst Campaign Is active::: '+ leadlst.get(0).Pri_Campaign_Active__c);
            System.debug('TEST referrallst ::: '+ referrallst.get(0));
            System.debug('TEST optylst ::: '+ optylst.get(0));

            Test.setCurrentPageReference(new PageReference('Page.ValidateOpportunityPage'));
            System.currentPageReference().getParameters().put('AccountId', acct.Id);
           
            // PageReference VFPage = Page.ValidateOpportunityPage;
            // Test.setCurrentPage(VFPage);
            // ApexPages.currentPage().getParameters().put('AccountId', acct.Id);
            
            ValidateOpportunityController VOC = new ValidateOpportunityController();
            System.currentPageReference().getParameters().put('CallType', 'Lead');
            VOC.callShowMore();

            System.currentPageReference().getParameters().put('CallType', 'Referral');
            VOC.callShowMore();

            System.currentPageReference().getParameters().put('CallType', 'Oppty');
            VOC.callShowMore();
        }
    }
}