@isTest
private class PHIRecommendedAtionExtensions_Test {
	public static final Id BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;   
	@testSetup static void setup() {
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

		RecordType Existing_Customer = [SELECT Id FROM RecordType WHERE developername='Existing_Customer' AND SobjectType = 'Account' and IsActive = true LIMIT 1];
		Account acc1 = TestUtils.createAccounts(1, 'test', 'CType', false).get(0);
		acc1.Customer_Type__c = 'Individual';
		acc1.OwnerID = User01.id;
		acc1.RecordType = Existing_Customer;
		acc1.RecordTypeId = Existing_Customer.Id;
		acc1.BIZ_FLAG__c = 'Y';
		acc1.WOW_FLAG__c = 'Y';
		insert acc1;

		Product2 prod2 = new Product2(Name = 'Deposit', Product_Domain__c ='Deposit & Investment', Family = 'Hardware', IsActive=true);
        insert prod2;
		Product_Information_On_Hand__c onhand2 = new Product_Information_On_Hand__c();
        onhand2.Account__c = acc1.Id;
        onhand2.Product_Hierachy_Code__c = String.valueOf(prod2.id);
        insert onhand2;
		Product_Information_Detail__c detail2 = new Product_Information_Detail__c();
        detail2.Product_Information__c = onhand2.id;
		detail2.Customer__c = acc1.Id;
		detail2.ACC_S1B__c = 'Y';
		// detail2.EDC_FLAG__c = 'Y';
		detail2.LATEST_MTH_TXN__c = 8;
		detail2.LATEST_SIXMTH_TXN__c = 8;
        insert detail2;
		Product_Information_Detail__c detail3 = new Product_Information_Detail__c();
        detail3.Product_Information__c = onhand2.id;
		detail3.Customer__c = acc1.Id;
		detail3.ACC_S1B__c = 'N';
		// detail3.EDC_FLAG__c = 'Y';
		detail3.LATEST_MTH_TXN__c = 9;
		detail3.LATEST_SIXMTH_TXN__c = 9;
        insert detail3;

		Product_Information_Detail__c detail4 = new Product_Information_Detail__c();
        detail4.Product_Information__c = onhand2.id;
		detail4.Customer__c = acc1.Id;
        insert detail4;
	}

	@isTest static void test_method_PHIRecommendedAtionExtensions() {
		User user = [SELECT Id, Name FROM User WHERE Email = 'smartbdm@tmb.com.test' AND ProfileId =: BDM_PROFILE_ID LIMIT 1];
		Id AcctId = [SELECT Id FROM Account WHERE Customer_Type__c = 'Individual' AND OwnerId =: user.id LIMIT 1].Id;
		List<Product_Information_Detail__c> dProtI = [SELECT Id FROM Product_Information_Detail__c WHERE Customer__c =: AcctId];
		
		// Positive Recommended Action
		Test.setCurrentPageReference(new PageReference('Page.ProductHoldingInfoRecommendedAtion'));
		ApexPages.StandardController sc = new ApexPages.StandardController(dProtI.get(0));
		PHIRecommendedAtionExtensions phir = new PHIRecommendedAtionExtensions(sc);
		phir.CallRecommendedAction();
		sc = new ApexPages.StandardController(dProtI.get(1));
		phir = new PHIRecommendedAtionExtensions(sc);
		phir.CallRecommendedAction();
		Boolean isSF1 = phir.isSF1;

		System.currentPageReference().getParameters().put('isdtp', 'p1');
		sc = new ApexPages.StandardController(dProtI.get(2));
		phir = new PHIRecommendedAtionExtensions(sc);
		phir.CallRecommendedAction();
		isSF1 = phir.isSF1;

		// Negative Call Recommended Action
		sc = new ApexPages.StandardController(new Product_Information_Detail__c());
		phir = new PHIRecommendedAtionExtensions(sc);
		phir.CallRecommendedAction();
		
	}
}