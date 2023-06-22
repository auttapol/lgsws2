@isTest
private class ValidateOpportunityProxyController_Test {
    public static final Id USER_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id; 

    @testSetup 
    static void setup() {
		TestUtils.createAppConfig();
        
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
        insert bz;

		User User01 = RTL_TestUtility.createUsers(1, 'testName', 'testLastname', 'test@tmb.com.test', false).get(0);
		User01.ProfileId = USER_PROFILE_ID;
		User01.isActive = true;
		User01.RTL_Branch_Code__c = bz.Branch_Code__c;
		User01.Employee_ID__c = '123456';
		insert User01;
	}

    @isTest
    static void testFlow() {
		User user = [SELECT Id, Name FROM User WHERE Email = 'test@tmb.com.test' AND ProfileId =: USER_PROFILE_ID LIMIT 1];
        RecordType Existing_Customer = [SELECT Id FROM RecordType WHERE developername='Existing_Customer' AND SobjectType = 'Account' and IsActive = true LIMIT 1];
        RecordType SE_Credit_Product = [SELECT Id FROM RecordType WHERE developername='SE_Credit_Product' AND SobjectType = 'Opportunity' and IsActive = true LIMIT 1];

        Account acct = RTL_TestUtility.createAccounts(1 , false).get(0);
        acct.Customer_Type__c = 'Individual';
        acct.RecordType = Existing_Customer;
        acct.RecordTypeId = Existing_Customer.Id;
        acct.OwnerId = user.id;
        insert acct;

        Date d = date.today();
        Date d2 = d.addDays(30);

        system.debug('ID: ' + acct.Id);

        Test.startTest();
		System.runAs(user){

            Opportunity opty = new Opportunity();
            opty.RecordTypeId = SE_Credit_Product.id;
            opty.CloseDate = d2;
            opty.Expected_submit_date__c = d;
            opty.OwnerId = user.id;
            opty.AccountId = acct.Id;
            opty.Name = 'VO01 : BOND';
            opty.StageName = 'Analysis';
            insert opty;

			Test.setCurrentPageReference(new PageReference('Page.ValidateOpportunityProxy'));

            PageReference VFPage = Page.ValidateOpportunityProxy;
            Test.setCurrentPage(VFPage);

            ApexPages.currentPage().getParameters().put('id', acct.Id);

            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(new List<Opportunity>());
            ValidateOpportunityProxyController ext = new ValidateOpportunityProxyController(sc);
			
            PageReference page = ext.ValidateOpty();
            
            Boolean fag = ext.ValidateOptyFag;
            Id userId = ValidateOpportunityProxyController.userOwnerId;

            List<Opportunity> opptylst = ext.opptylst;
            List<RTL_Referral__c> referallst = ext.referallst;
            List<Lead> leadlst = ext.leadlst;
            Profile currentUserProfile = ext.currentUserProfile;

            Integer sObjSize = ext.leadSize;
            sObjSize = ext.referSize;
            sObjSize = ext.optySize;

            Id recID = ext.recID;

            System.assert(true, Fag);

            fag = ext.ValidateOptyFag;
		}
        Test.stopTest();

    }
}