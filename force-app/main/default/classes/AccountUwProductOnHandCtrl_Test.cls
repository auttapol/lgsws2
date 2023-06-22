@isTest
private class AccountUwProductOnHandCtrl_Test {

	public static final Id UW_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB UW Profile' LIMIT 1].Id;  
	
	@isTest static void test_getTransactionalRecord() {

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

		// Insert Product for Transactional Banking.
		Product2 prod = new Product2();
        prod.Name = 'PROD1';
        prod.Product_Domain__c = 'Transactional Banking';
        prod.IsActive = true;
        prod.Family = 'Credit Product';
        prod.ProductCode = '12345678';
        insert prod;

		// Insert Product on hand summary.
		Product_Information_On_Hand__c proOnHandSum = new Product_Information_On_Hand__c();
		proOnHandSum.Product_Info_ExternalID__c = 'Test Pro On Hand';
		proOnHandSum.Product_Hierachy_Code__c = prod.Id;
		proOnHandSum.Account__c = accId;
		insert proOnHandSum;

		// Insert product detail
		Product_Information_Detail__c productDetail = new Product_Information_Detail__c();
		productDetail.Customer__c = accId;
		productDetail.Product_Information__c = proOnHandSum.Id;
		productDetail.TMB_Account_ID__c = '12345';
		productDetail.Account_Name__c = 'abc';
		productDetail.Limit_Balance__c = 100;
		insert productDetail;

		PageReference pageRef = Page.AccountUwProductOnHandView;
		Test.setCurrentPage(pageRef);
		ApexPages.StandardController sc = new ApexPages.StandardController(acc);
		AccountUwProductOnHandCtrl uw = new AccountUwProductOnHandCtrl(sc);

		System.assertEquals('12345', uw.listTransProduct.get(0).TMB_Account_ID__c);
		System.assertEquals(100, uw.listTransProduct.get(0).Limit_Balance__c);

		uw.nextTransPage();
		uw.previousTransPage();

		uw.nextDepositPage();
		uw.previousDepositPage();
		
		uw.nextFundPage();
		uw.previousFundPage();
		
		uw.nextRiskPage();
		uw.previousRiskPage();

		Test.stopTest();
	}
	
	//@isTest static void test_getDepositRecord() {
	//	// Implement test code
	//}

	//@isTest static void test_getFundRecord() {
	//	// Implement test code
	//}

	//@isTest static void test_getRiskRecord() {
	//	// Implement test code
	//}
	
}