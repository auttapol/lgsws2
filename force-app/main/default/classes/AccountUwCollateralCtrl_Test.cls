@isTest
private class AccountUwCollateralCtrl_Test {

    public static final Id UW_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB UW Profile' LIMIT 1].Id;      
	
	@isTest static void test_getCollateralRecord() {

        Test.startTest();

        // Insert Account.
        TestUtils.createAppConfig();

        List<AppConfig__c> mc = new List<AppConfig__c> ();
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        insert mc;
        
        RTL_Branch_Manager_Title__c branchTitle = new RTL_Branch_Manager_Title__c(Name='Branch Manager',RTL_Value__c='Branch Manager');
        insert branchTitle;

        Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '611';
        insert bz;

        User User01 = RTL_TestUtility.createUsers(1, 'TestMock', 'UW', 'smartbdm@tmb.com.test', false).get(0);
        User01.ProfileId = UW_PROFILE_ID;
        User01.isActive = true;
        User01.title = 'Branch Manager';
        User01.RTL_Branch_Code__c = bz.Branch_Code__c;
        User01.Employee_ID__c = '123456';
        insert User01;
        
        List<Account> acct = RTL_TestUtility.createAccounts(1 , false);
        RecordType Existing_Customer = [SELECT Id FROM RecordType WHERE developername='Existing_Customer' AND SobjectType = 'Account' and IsActive = true LIMIT 1];
        Account acc1 = acct.get(0);
        acc1.IsDisqualified__c = true;
        acc1.Customer_Type__c = 'Individual';
        acc1.RecordType = Existing_Customer;
        acc1.RecordTypeId = Existing_Customer.Id;
        acc1.OwnerID = User01.id;
        
        insert acc1;

		// Get Account
        Account acc = [SELECT Id, Name, RecordType.Name FROM Account WHERE Id =: acc1.Id LIMIT 1];		
		Id accId = acc.Id;
		System.debug('Account Id : ' + accId);

		// Insert Collateral header.
		Collateral__c colla = new Collateral__c();
        colla.Collateral_Group_Type__c = 'Test_Collateral';
        colla.Collateral_Group_Type_Key__c  = 'Test123456';
        colla.Account__c = accId;
        insert colla;

		// Insert Product on hand summary.
		Collateral_Detail__c colladetail = new Collateral_Detail__c();
        colladetail.Appraisal_Date__c = system.today();
        colladetail.Pledge_Value__c = 222210.11;
        colladetail.Collateral__c = colla.Id;
        insert colladetail;

		PageReference pageRef = Page.AccountUwProductOnHandView;
		Test.setCurrentPage(pageRef);
		ApexPages.StandardController sc = new ApexPages.StandardController(acc);
		AccountUwCollateralCtrl uw = new AccountUwCollateralCtrl(sc);

		System.assertEquals(system.today(), uw.listCollateralDetail.get(0).Appraisal_Date__c);
		System.assertEquals(222210.11, uw.listCollateralDetail.get(0).Pledge_Value__c);

		uw.nextCollatPage();
		uw.previousCollatPage();

        Test.stopTest();

	}
	
}