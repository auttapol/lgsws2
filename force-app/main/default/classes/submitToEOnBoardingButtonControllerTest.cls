@isTest
private class submitToEOnBoardingButtonControllerTest {
    public static final Id BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;

    @testSetup 
    static void setup() {
		TestUtils.createAppConfig();
        
		List<AppConfig__c> mc = new List<AppConfig__c> ();
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        insert mc;
		
		RTL_Branch_Manager_Title__c branchTitle = new RTL_Branch_Manager_Title__c(Name='Branch Manager',RTL_Value__c='Branch Manager');
		insert branchTitle;

		Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '611';
        insert bz;

		User User01 = RTL_TestUtility.createUsers(1, 'TestMock', 'SmartBDM', 'smartbdm@tmb.com.test', false).get(0);
		User01.ProfileId = BDM_PROFILE_ID;
		User01.isActive = true;
		User01.title = 'Branch Manager';
		User01.RTL_Branch_Code__c = bz.Branch_Code__c;
		User01.Employee_ID__c = '123456';
		insert User01;

		Account acct = RTL_TestUtility.createAccounts(1 , false).get(0);
		RecordType Prospect = [SELECT Id FROM RecordType WHERE developername = 'Prospect' AND SobjectType = 'Account' and IsActive = true LIMIT 1];
        acct.Name = 'test1';
		acct.Customer_Type__c = 'Individual';
		acct.RecordType = Prospect;
		acct.RecordTypeId = Prospect.Id;
        acct.ID_Type_PE__c = 'Citizen ID';
        acct.ID_Number_PE__c = '1885816433556';
        acct.TMB_Customer_ID_PE__c = null;
		insert acct;
	}


    @isTest
    static void TestErrorFlow() {
        Opportunity opty = new Opportunity();
        ApexPages.StandardController sc = new ApexPages.StandardController(opty);

        test.startTest();
        submitToEOnBoardingButtonController ext = new submitToEOnBoardingButtonController(sc);
        ext.ValidateEBoarding();
        ext.optyPage();
        Boolean bol = ext.submitPass;

        test.stopTest();
    }

    @isTest
    static void TestSuccessFlow(){
        System.debug([SELECT Id, OwnerId, RTL_NID__c FROM Account]);
        Account acct = [SELECT Id, OwnerId FROM Account WHERE RTL_NID__c = '13556' LIMIT 1];
        opportunity oppt = new opportunity();
        oppt.RecordTypeId = '01290000001AhOeAAK';
        oppt.accountId = acct.id;
        oppt.name = 'test';
        oppt.ownerid = acct.ownerid;
        oppt.stagename = 'Analysis';
        oppt.Expected_submit_date__c = date.today();
        oppt.closedate = date.today();
        insert oppt;

        ApexPages.StandardController sc = new ApexPages.StandardController(oppt);

        test.startTest();
        submitToEOnBoardingButtonController ext = new submitToEOnBoardingButtonController(sc);
        ext.recID = oppt.Id;
        ext.ValidateEBoarding();
        ext.optyPage();
        Boolean bol = ext.submitPass;

        test.stopTest();
    }

    @isTest
    static void TestUpdateFail(){
        System.debug([SELECT Id, OwnerId, RTL_NID__c FROM Account]);
        Account acct = [SELECT Id, OwnerId FROM Account WHERE RTL_NID__c = '13556' LIMIT 1];
        
        opportunity oppt = new opportunity();
        oppt.RecordTypeId = '01290000001AhOeAAK';
        oppt.accountId = acct.id;
        oppt.name = 'test';
        oppt.ownerid = acct.ownerid;
        oppt.stagename = 'Analysis';
        oppt.Expected_submit_date__c = date.today();
        oppt.closedate = date.today();
        insert oppt;

        ApexPages.StandardController sc = new ApexPages.StandardController(oppt);

        test.startTest();
        submitToEOnBoardingButtonController ext = new submitToEOnBoardingButtonController(sc);
        ext.recID = oppt.Id;
        ext.RecordtypeToUpdate = 'abc';
        ext.ValidateEBoarding();
        ext.optyPage();
        Boolean bol = ext.submitPass;

        test.stopTest();
    }
}