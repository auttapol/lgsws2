@IsTest
public class addNIProjectionCtrlTest {
static{
    	TestUtils.CreateProceBookAccess();
        TestUtils.CreateProceBook();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        TestUtils.createIdType();
        TestUtils.createTriggerMsg();
        TestUtils.createObjUserPermission();
    }
	public static testmethod void NIProjectionDetails() {

		//Create Account
		Account testAccount1 = new Account();
		testAccount1.Name = 'Test AccountPlan Step5';
        testAccount1.Phone ='050111222';
        testAccount1.Mobile_Number_PE__c  = '0801112233';
		insert testAccount1;

		//Create Contact
		Contact cont1 = new Contact();
		cont1.FirstName = 'AccountPlan';
		cont1.LastName = 'Step5';
		cont1.Position__c = 'Manager';
		cont1.Accountid = testAccount1.id;
		insert cont1;

		//Create Account Plan
		AcctPlanCompanyProfile__c Company1 = new AcctPlanCompanyProfile__c();
		Company1.Account__c = testAccount1.id;
		//Company1.Name = 'AccountPlan Step5';
		insert Company1;

		AcctPlanWallet__c Wallet1 = new AcctPlanWallet__c();
		Wallet1.AcctPlanCompanyProfile__c = Company1.id;
		insert Wallet1;

		AcctPlanWalletByDomain__c WalletDomain1 = new AcctPlanWalletByDomain__c();
		WalletDomain1.AcctPlanWallet__c = Wallet1.id;
		WalletDomain1.WalletDomain__c = 1;
		WalletDomain1.Priority__c = 'High';
		WalletDomain1.SubDomain__c = 'Liquidity Management';
		WalletDomain1.TypeOfNI__c = 'NIIC';
		insert WalletDomain1;


		AcctPlanActionPlan__c acctplan1 = new AcctPlanActionPlan__c();
		acctplan1.AcctPlanWalletByDomain__c = WalletDomain1.id;
		acctplan1.Objective__c = 'Acquire New customers';
		acctplan1.Status__c = 'Post Board';
		acctplan1.WinningPropostion__c = 'Test Class';
		insert acctplan1;

		Pricebook2 standardPricebook = new Pricebook2();
		Pricebook2[] Records = [SELECT Name FROM Pricebook2 WHERE IsActive = true ORDER BY Name ASC];
		Map<String, Pricebook2> pricebookmap = new Map<String, Pricebook2> ();
		for (Pricebook2 R : Records) {
			pricebookmap.put(r.Name, r);
		}
		Id pricebookselected;

		User us = [SELECT ID, Segment__c FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
		us.Segment__c = 'MB';
		update us;

		if (us.Segment__c != null) {
			//standardPricebook.id = pricebookmap.get('SE Price Book').id;
			pricebookselected = pricebookmap.get(Price_book_access__c.GetValues(us.Segment__c).PricebookItem__c).id;

		} else {
			pricebookselected = pricebookmap.get(Price_book_access__c.GetValues('Default').PricebookItem__c).id;
		}

		List<PricebookEntry> pricbook = [SELECT ID, Name, IsActive, Product2Id, Pricebook2Id, Product2.Product_Level__c From PricebookEntry WHERE IsActive = true AND Product2.Product_Level__c = '4' AND PriceBook2ID = :pricebookselected limit 1];
		Id prod;
		String prodName;
		for (PricebookEntry p : pricbook) {
			prod = p.Product2Id;
			prodName = p.Name;

		}

		PageReference pageRef1 = Page.NIProjectionDetails;
		pageRef1.getParameters().put('CompanyID', String.valueOf(Company1.id));
		pageRef1.getParameters().put('ActionPlanID', String.valueOf(acctplan1.id));
		pageRef1.getParameters().put('ProdCode1', String.valueOf(prod));
		pageRef1.getParameters().put('ProdName1', String.valueOf(prodName));
		pageRef1.getParameters().put('NoProd', '1');
		Test.setCurrentPage(pageRef1);

		AcctPlanNIProject__c ni = new AcctPlanNIProject__c(AcctPlanActionPlanID__c = acctplan1.id);
		ApexPages.StandardController sc1 = new ApexPages.StandardController(ni);
		addNIProjectionCtrl AddNICntrl1 = new addNIProjectionCtrl(sc1);
		List<SelectOption> fiscal = AddNICntrl1.getFiscalYear();
		AddNICntrl1.GroupCount();
		List<AcctPlanNIProject__c> ni2 = AddNICntrl1.getChildren();
		AddNICntrl1.dosave();

		ni.GroupCount__c = 'A';
		ni.GroupCount__c = 'B';
		ni.GroupCount__c = 'C';
		ni.GroupCount__c = 'D';
		ni.GroupCount__c = 'E';
		AddNICntrl1.dosave();

		//more test 
		// add by ktc
		AddNICntrl1.validationMsg = '';
		integer val = AddNICntrl1.Count;

		val = AddNICntrl1.NewRecordsSize;
		val = AddNICntrl1.DirtyRecordsSize;
		val = AddNICntrl1.DeleteRecordsSize;
		String val2 =AddNICntrl1.removeIndex;

		AddNICntrl1.removeFromList();
		PageReference pg = AddNICntrl1.getSuccessURL();


	}


	public static testmethod void NIProjectionValidate1() {

		//Create Account
		Account testAccount1 = new Account();
		testAccount1.Name = 'Test AccountPlan Step5';
        testAccount1.Phone ='050111222';
        testAccount1.Mobile_Number_PE__c  = '0801112233';
		insert testAccount1;

		//Create Contact
		Contact cont1 = new Contact();
		cont1.FirstName = 'AccountPlan';
		cont1.LastName = 'Step5';
		cont1.Position__c = 'Manager';
		cont1.Accountid = testAccount1.id;
		insert cont1;

		//Create Account Plan
		AcctPlanCompanyProfile__c Company1 = new AcctPlanCompanyProfile__c();
		Company1.Account__c = testAccount1.id;
		//Company1.Name = 'AccountPlan Step5';
		insert Company1;

		AcctPlanWallet__c Wallet1 = new AcctPlanWallet__c();
		Wallet1.AcctPlanCompanyProfile__c = Company1.id;
		insert Wallet1;

		AcctPlanWalletByDomain__c WalletDomain1 = new AcctPlanWalletByDomain__c();
		WalletDomain1.AcctPlanWallet__c = Wallet1.id;
		WalletDomain1.WalletDomain__c = 1;
		WalletDomain1.Priority__c = 'High';
		WalletDomain1.SubDomain__c = 'Liquidity Management';
		WalletDomain1.TypeOfNI__c = 'NIIC';
		insert WalletDomain1;


		AcctPlanActionPlan__c acctplan1 = new AcctPlanActionPlan__c();
		acctplan1.AcctPlanWalletByDomain__c = WalletDomain1.id;
		acctplan1.Objective__c = 'Acquire New customers';
		acctplan1.Status__c = 'Post Board';
		acctplan1.WinningPropostion__c = 'Test Class';
		insert acctplan1;

		Pricebook2 standardPricebook = new Pricebook2();
		Pricebook2[] Records = [SELECT Name FROM Pricebook2 WHERE IsActive = true ORDER BY Name ASC];
		Map<String, Pricebook2> pricebookmap = new Map<String, Pricebook2> ();
		for (Pricebook2 R : Records) {
			pricebookmap.put(r.Name, r);
		}
		Id pricebookselected;

		User us = [SELECT ID, Segment__c FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
		us.Segment__c = 'MB';
		update us;

		if (us.Segment__c != null) {
			//standardPricebook.id = pricebookmap.get('SE Price Book').id;
			pricebookselected = pricebookmap.get(Price_book_access__c.GetValues(us.Segment__c).PricebookItem__c).id;

		} else {
			pricebookselected = pricebookmap.get(Price_book_access__c.GetValues('Default').PricebookItem__c).id;
		}

		List<PricebookEntry> pricbook = [SELECT ID, Name, IsActive, Product2Id, Pricebook2Id, Product2.Product_Level__c From PricebookEntry WHERE IsActive = true AND Product2.Product_Level__c = '4' AND PriceBook2ID = :pricebookselected limit 1];
		Id prod;
		String prodName;
		for (PricebookEntry p : pricbook) {
			prod = p.Product2Id;
			prodName = p.Name;

		}

		PageReference pageRef1 = Page.NIProjectionDetails;
		pageRef1.getParameters().put('CompanyID', String.valueOf(Company1.id));
		pageRef1.getParameters().put('ActionPlanID', String.valueOf(acctplan1.id));
		pageRef1.getParameters().put('ProdCode1', String.valueOf(prod));
		pageRef1.getParameters().put('ProdName1', String.valueOf(prodName));
		pageRef1.getParameters().put('NoProd', '1');
		Test.setCurrentPage(pageRef1);

		AcctPlanNIProject__c ni2 = new AcctPlanNIProject__c(AcctPlanActionPlanID__c = acctplan1.id, GroupCount__c = 'A', TypeOfNI__c = 'NIIc');
		ApexPages.StandardController sc2 = new ApexPages.StandardController(ni2);
		addNIProjectionCtrl AddNICntrl2 = new addNIProjectionCtrl(sc2);
		List<AcctPlanNIProject__c> ni21 = AddNICntrl2.getChildren();
		for (AcctPlanNIProject__c ni211 : ni21) {
			ni211.GroupCount__c = 'A';
			ni211.TypeOfNI__c = 'NIIc';
		}

		AddNICntrl2.dosave();

		AcctPlanNIProject__c ni3 = new AcctPlanNIProject__c(AcctPlanActionPlanID__c = acctplan1.id, GroupCount__c = 'B', TypeOfNI__c = 'NIIc', NIRecuringType__c = 'Recurring');
		ApexPages.StandardController sc3 = new ApexPages.StandardController(ni3);
		addNIProjectionCtrl AddNICntrl3 = new addNIProjectionCtrl(sc3);
		List<AcctPlanNIProject__c> ni31 = AddNICntrl3.getChildren();
		for (AcctPlanNIProject__c ni311 : ni31) {
			ni311.TypeOfNI__c = 'NIIc';
			ni311.GroupCount__c = 'B';
			ni311.NIRecuringType__c = 'Recurring';
		}

		AddNICntrl3.dosave();


		AcctPlanNIProject__c ni4 = new AcctPlanNIProject__c(AcctPlanActionPlanID__c = acctplan1.id, TypeOfNI__c = 'NIIc', GroupCount__c = 'C', NIRecuringType__c = 'Recurring', ExpectedNimRate__c = 70);
		ApexPages.StandardController sc4 = new ApexPages.StandardController(ni4);
		addNIProjectionCtrl AddNICntrl4 = new addNIProjectionCtrl(sc4);
		List<AcctPlanNIProject__c> ni41 = AddNICntrl4.getChildren();
		for (AcctPlanNIProject__c ni411 : ni41) {
			ni411.TypeOfNI__c = 'NIIc';
			ni411.GroupCount__c = 'C';
			ni411.NIRecuringType__c = 'Recurring';
			ni411.ExpectedNimRate__c = 70;
		}

		AddNICntrl4.dosave();

		AcctPlanNIProject__c ni5 = new AcctPlanNIProject__c(AcctPlanActionPlanID__c = acctplan1.id, TypeOfNI__c = 'NIIc', GroupCount__c = 'D', NIRecuringType__c = 'Recurring', ExpectedNimRate__c = 70, ExpectedIncrementalNIPerYear1Year__c = 70);
		ApexPages.StandardController sc5 = new ApexPages.StandardController(ni5);
		addNIProjectionCtrl AddNICntrl5 = new addNIProjectionCtrl(sc5);
		List<AcctPlanNIProject__c> ni51 = AddNICntrl5.getChildren();
		for (AcctPlanNIProject__c ni511 : ni51) {

			ni511.TypeOfNI__c = 'NIIc';
			ni511.GroupCount__c = 'D';
			ni511.NIRecuringType__c = 'Recurring';
			ni511.ExpectedNimRate__c = 70;
			ni511.ExpectedIncrementalNIPerYear1Year__c = 70;
		}

		AddNICntrl5.dosave();

	}


	public static testmethod void NIProjectionValidate2() {

		//Create Account
		Account testAccount1 = new Account();
		testAccount1.Name = 'Test AccountPlan Step5';
        testAccount1.Phone ='050111222';
        testAccount1.Mobile_Number_PE__c  = '0801112233';
		insert testAccount1;

		//Create Contact
		Contact cont1 = new Contact();
		cont1.FirstName = 'AccountPlan';
		cont1.LastName = 'Step5';
		cont1.Position__c = 'Manager';
		cont1.Accountid = testAccount1.id;
		insert cont1;

		//Create Account Plan
		AcctPlanCompanyProfile__c Company1 = new AcctPlanCompanyProfile__c();
		Company1.Account__c = testAccount1.id;
		//Company1.Name = 'AccountPlan Step5';
		insert Company1;

		AcctPlanWallet__c Wallet1 = new AcctPlanWallet__c();
		Wallet1.AcctPlanCompanyProfile__c = Company1.id;
		insert Wallet1;

		AcctPlanWalletByDomain__c WalletDomain1 = new AcctPlanWalletByDomain__c();
		WalletDomain1.AcctPlanWallet__c = Wallet1.id;
		WalletDomain1.WalletDomain__c = 1;
		WalletDomain1.Priority__c = 'High';
		WalletDomain1.SubDomain__c = 'Liquidity Management';
		WalletDomain1.TypeOfNI__c = 'NIIC';
		insert WalletDomain1;


		AcctPlanActionPlan__c acctplan1 = new AcctPlanActionPlan__c();
		acctplan1.AcctPlanWalletByDomain__c = WalletDomain1.id;
		acctplan1.Objective__c = 'Acquire New customers';
		acctplan1.Status__c = 'Post Board';
		acctplan1.WinningPropostion__c = 'Test Class';
		insert acctplan1;

		Pricebook2 standardPricebook = new Pricebook2();
		Pricebook2[] Records = [SELECT Name FROM Pricebook2 WHERE IsActive = true ORDER BY Name ASC];
		Map<String, Pricebook2> pricebookmap = new Map<String, Pricebook2> ();
		for (Pricebook2 R : Records) {
			pricebookmap.put(r.Name, r);
		}
		Id pricebookselected;

		User us = [SELECT ID, Segment__c FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
		us.Segment__c = 'MB';
		update us;

		if (us.Segment__c != null) {
			//standardPricebook.id = pricebookmap.get('SE Price Book').id;
			pricebookselected = pricebookmap.get(Price_book_access__c.GetValues(us.Segment__c).PricebookItem__c).id;

		} else {
			pricebookselected = pricebookmap.get(Price_book_access__c.GetValues('Default').PricebookItem__c).id;
		}

		List<PricebookEntry> pricbook = [SELECT ID, Name, IsActive, Product2Id, Pricebook2Id, Product2.Product_Level__c From PricebookEntry WHERE IsActive = true AND Product2.Product_Level__c = '4' AND PriceBook2ID = :pricebookselected limit 1];
		Id prod;
		String prodName;
		for (PricebookEntry p : pricbook) {
			prod = p.Product2Id;
			prodName = p.Name;

		}

		PageReference pageRef1 = Page.NIProjectionDetails;
		pageRef1.getParameters().put('CompanyID', String.valueOf(Company1.id));
		pageRef1.getParameters().put('ActionPlanID', String.valueOf(acctplan1.id));
		pageRef1.getParameters().put('ProdCode1', String.valueOf(prod));
		pageRef1.getParameters().put('ProdName1', String.valueOf(prodName));
		pageRef1.getParameters().put('NoProd', '1');
		Test.setCurrentPage(pageRef1);

		AcctPlanNIProject__c ni6 = new AcctPlanNIProject__c(AcctPlanActionPlanID__c = acctplan1.id, TypeOfNI__c = 'NIIc', GroupCount__c = 'D', NIRecuringType__c = 'Recurring', ExpectedNimRate__c = 70, ExpectedIncrementalNIPerYear1Year__c = 70, NIStartMonth__c = '11');
		ApexPages.StandardController sc6 = new ApexPages.StandardController(ni6);
		addNIProjectionCtrl AddNICntrl6 = new addNIProjectionCtrl(sc6);
		List<AcctPlanNIProject__c> ni61 = AddNICntrl6.getChildren();
		for (AcctPlanNIProject__c ni611 : ni61) {

			ni611.TypeOfNI__c = 'NIIc';
			ni611.GroupCount__c = 'D';
			ni611.NIRecuringType__c = 'Recurring';
			ni611.ExpectedNimRate__c = 70;
			ni611.ExpectedIncrementalNIPerYear1Year__c = 70;
			ni611.NIStartMonth__c = '11';
		}

		AddNICntrl6.dosave();


		AcctPlanNIProject__c ni7 = new AcctPlanNIProject__c(AcctPlanActionPlanID__c = acctplan1.id, TypeOfNI__c = 'NIIc', GroupCount__c = 'D', NIRecuringType__c = 'Recurring', ExpectedNimRate__c = 70, ExpectedIncrementalNIPerYear1Year__c = 70, NIStartMonth__c = '11', NIStartYear__c = '2016', ExpectedIncrementalNIPerYear2Year__c = 20);
		ApexPages.StandardController sc7 = new ApexPages.StandardController(ni7);
		addNIProjectionCtrl AddNICntrl7 = new addNIProjectionCtrl(sc7);
		List<AcctPlanNIProject__c> ni71 = AddNICntrl7.getChildren();
		for (AcctPlanNIProject__c ni711 : ni71) {

			ni711.TypeOfNI__c = 'NIIc';
			ni711.GroupCount__c = 'D';
			ni711.NIRecuringType__c = 'Recurring';
			ni711.ExpectedNimRate__c = 70;
			ni711.ExpectedIncrementalNIPerYear1Year__c = 70;
			ni711.NIStartMonth__c = '11';
			ni711.NIStartYear__c = '2016';
			ni711.ExpectedIncrementalNIPerYear2Year__c = 20;
		}

		AddNICntrl7.dosave();


	}


	public static testmethod void FeeProjectionValidate1() {

		//Create Account
		Account testAccount1 = new Account();
		testAccount1.Name = 'Test AccountPlan Step5';
        testAccount1.Phone ='050111222';
        testAccount1.Mobile_Number_PE__c  = '0801112233';
		insert testAccount1;

		//Create Contact
		Contact cont1 = new Contact();
		cont1.FirstName = 'AccountPlan';
		cont1.LastName = 'Step5';
		cont1.Position__c = 'Manager';
		cont1.Accountid = testAccount1.id;
		insert cont1;

		//Create Account Plan
		AcctPlanCompanyProfile__c Company1 = new AcctPlanCompanyProfile__c();
		Company1.Account__c = testAccount1.id;
		//Company1.Name = 'AccountPlan Step5';
		insert Company1;

		AcctPlanWallet__c Wallet1 = new AcctPlanWallet__c();
		Wallet1.AcctPlanCompanyProfile__c = Company1.id;
		insert Wallet1;

		AcctPlanWalletByDomain__c WalletDomain1 = new AcctPlanWalletByDomain__c();
		WalletDomain1.AcctPlanWallet__c = Wallet1.id;
		WalletDomain1.WalletDomain__c = 1;
		WalletDomain1.Priority__c = 'High';
		WalletDomain1.SubDomain__c = 'Liquidity Management';
		WalletDomain1.TypeOfNI__c = 'NIIC';
		insert WalletDomain1;


		AcctPlanActionPlan__c acctplan1 = new AcctPlanActionPlan__c();
		acctplan1.AcctPlanWalletByDomain__c = WalletDomain1.id;
		acctplan1.Objective__c = 'Acquire New customers';
		acctplan1.Status__c = 'Post Board';
		acctplan1.WinningPropostion__c = 'Test Class';
		insert acctplan1;

		Pricebook2 standardPricebook = new Pricebook2();
		Pricebook2[] Records = [SELECT Name FROM Pricebook2 WHERE IsActive = true ORDER BY Name ASC];
		Map<String, Pricebook2> pricebookmap = new Map<String, Pricebook2> ();
		for (Pricebook2 R : Records) {
			pricebookmap.put(r.Name, r);
		}
		Id pricebookselected;

		User us = [SELECT ID, Segment__c FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
		us.Segment__c = 'MB';
		update us;

		if (us.Segment__c != null) {
			//standardPricebook.id = pricebookmap.get('SE Price Book').id;
			pricebookselected = pricebookmap.get(Price_book_access__c.GetValues(us.Segment__c).PricebookItem__c).id;

		} else {
			pricebookselected = pricebookmap.get(Price_book_access__c.GetValues('Default').PricebookItem__c).id;
		}

		List<PricebookEntry> pricbook = [SELECT ID, Name, IsActive, Product2Id, Pricebook2Id, Product2.Product_Level__c From PricebookEntry WHERE IsActive = true AND Product2.Product_Level__c = '4' AND PriceBook2ID = :pricebookselected limit 1];
		Id prod;
		String prodName;
		for (PricebookEntry p : pricbook) {
			prod = p.Product2Id;
			prodName = p.Name;

		}

		PageReference pageRef1 = Page.NIProjectionDetails;
		pageRef1.getParameters().put('CompanyID', String.valueOf(Company1.id));
		pageRef1.getParameters().put('ActionPlanID', String.valueOf(acctplan1.id));
		pageRef1.getParameters().put('ProdCode1', String.valueOf(prod));
		pageRef1.getParameters().put('ProdName1', String.valueOf(prodName));
		pageRef1.getParameters().put('NoProd', '1');
		Test.setCurrentPage(pageRef1);

		AcctPlanNIProject__c ni2 = new AcctPlanNIProject__c(AcctPlanActionPlanID__c = acctplan1.id, GroupCount__c = 'A', TypeOfFee__c = 'BA Fee');
		ApexPages.StandardController sc2 = new ApexPages.StandardController(ni2);
		addNIProjectionCtrl AddNICntrl2 = new addNIProjectionCtrl(sc2);
		List<AcctPlanNIProject__c> ni21 = AddNICntrl2.getChildren();
		for (AcctPlanNIProject__c ni211 : ni21) {
			ni211.GroupCount__c = 'A';
			ni211.TypeOfFee__c = 'BA Fee';
		}

		AddNICntrl2.dosave();

		AcctPlanNIProject__c ni3 = new AcctPlanNIProject__c(AcctPlanActionPlanID__c = acctplan1.id, GroupCount__c = 'B', TypeOfFee__c = 'BA Fee', FeeRecuringType__c = 'Recurring');
		ApexPages.StandardController sc3 = new ApexPages.StandardController(ni3);
		addNIProjectionCtrl AddNICntrl3 = new addNIProjectionCtrl(sc3);
		List<AcctPlanNIProject__c> ni31 = AddNICntrl3.getChildren();
		for (AcctPlanNIProject__c ni311 : ni31) {
			ni311.TypeOfFee__c = 'BA Fee';
			ni311.GroupCount__c = 'B';
			ni311.FeeRecuringType__c = 'Recurring';
		}

		AddNICntrl3.dosave();


		AcctPlanNIProject__c ni4 = new AcctPlanNIProject__c(AcctPlanActionPlanID__c = acctplan1.id, GroupCount__c = 'C', TypeOfFee__c = 'BA Fee', FeeRecuringType__c = 'Recurring', ExpectedFeeRate__c = 70);
		ApexPages.StandardController sc4 = new ApexPages.StandardController(ni4);
		addNIProjectionCtrl AddNICntrl4 = new addNIProjectionCtrl(sc4);
		List<AcctPlanNIProject__c> ni41 = AddNICntrl4.getChildren();
		for (AcctPlanNIProject__c ni411 : ni41) {
			ni411.TypeOfFee__c = 'BA Fee';
			ni411.GroupCount__c = 'C';
			ni411.FeeRecuringType__c = 'Recurring';
			ni411.ExpectedFeeRate__c = 70;
		}

		AddNICntrl4.dosave();

		AcctPlanNIProject__c ni5 = new AcctPlanNIProject__c(AcctPlanActionPlanID__c = acctplan1.id, GroupCount__c = 'D', TypeOfFee__c = 'BA Fee', FeeRecuringType__c = 'Recurring', ExpectedFeeRate__c = 70, ExpectedIncrementalFeePerYear1Year__c = 70);
		ApexPages.StandardController sc5 = new ApexPages.StandardController(ni5);
		addNIProjectionCtrl AddNICntrl5 = new addNIProjectionCtrl(sc5);
		List<AcctPlanNIProject__c> ni51 = AddNICntrl5.getChildren();
		for (AcctPlanNIProject__c ni511 : ni51) {

			ni511.TypeOfFee__c = 'BA Fee';
			ni511.GroupCount__c = 'D';
			ni511.FeeRecuringType__c = 'Recurring';
			ni511.ExpectedFeeRate__c = 70;
			ni511.ExpectedIncrementalFeePerYear1Year__c = 70;
		}

		AddNICntrl5.dosave();

	}

	public static testmethod void FeeProjectionValidate2() {

		//Create Account
		Account testAccount1 = new Account();
		testAccount1.Name = 'Test AccountPlan Step5';
        testAccount1.Phone ='050111222';
        testAccount1.Mobile_Number_PE__c  = '0801112233';
		insert testAccount1;

		//Create Contact
		Contact cont1 = new Contact();
		cont1.FirstName = 'AccountPlan';
		cont1.LastName = 'Step5';
		cont1.Position__c = 'Manager';
		cont1.Accountid = testAccount1.id;
		insert cont1;

		//Create Account Plan
		AcctPlanCompanyProfile__c Company1 = new AcctPlanCompanyProfile__c();
		Company1.Account__c = testAccount1.id;
		//Company1.Name = 'AccountPlan Step5';
		insert Company1;

		AcctPlanWallet__c Wallet1 = new AcctPlanWallet__c();
		Wallet1.AcctPlanCompanyProfile__c = Company1.id;
		insert Wallet1;

		AcctPlanWalletByDomain__c WalletDomain1 = new AcctPlanWalletByDomain__c();
		WalletDomain1.AcctPlanWallet__c = Wallet1.id;
		WalletDomain1.WalletDomain__c = 1;
		WalletDomain1.Priority__c = 'High';
		WalletDomain1.SubDomain__c = 'Liquidity Management';
		WalletDomain1.TypeOfNI__c = 'NIIC';
		insert WalletDomain1;


		AcctPlanActionPlan__c acctplan1 = new AcctPlanActionPlan__c();
		acctplan1.AcctPlanWalletByDomain__c = WalletDomain1.id;
		acctplan1.Objective__c = 'Acquire New customers';
		acctplan1.Status__c = 'Post Board';
		acctplan1.WinningPropostion__c = 'Test Class';
		insert acctplan1;

		Pricebook2 standardPricebook = new Pricebook2();
		Pricebook2[] Records = [SELECT Name FROM Pricebook2 WHERE IsActive = true ORDER BY Name ASC];
		Map<String, Pricebook2> pricebookmap = new Map<String, Pricebook2> ();
		for (Pricebook2 R : Records) {
			pricebookmap.put(r.Name, r);
		}
		Id pricebookselected;

		User us = [SELECT ID, Segment__c FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1];
		us.Segment__c = 'MB';
		update us;

		if (us.Segment__c != null) {
			//standardPricebook.id = pricebookmap.get('SE Price Book').id;
			pricebookselected = pricebookmap.get(Price_book_access__c.GetValues(us.Segment__c).PricebookItem__c).id;

		} else {
			pricebookselected = pricebookmap.get(Price_book_access__c.GetValues('Default').PricebookItem__c).id;
		}

		List<PricebookEntry> pricbook = [SELECT ID, Name, IsActive, Product2Id, Pricebook2Id, Product2.Product_Level__c From PricebookEntry WHERE IsActive = true AND Product2.Product_Level__c = '4' AND PriceBook2ID = :pricebookselected limit 1];
		Id prod;
		String prodName;
		for (PricebookEntry p : pricbook) {
			prod = p.Product2Id;
			prodName = p.Name;

		}

		PageReference pageRef1 = Page.NIProjectionDetails;
		pageRef1.getParameters().put('CompanyID', String.valueOf(Company1.id));
		pageRef1.getParameters().put('ActionPlanID', String.valueOf(acctplan1.id));
		pageRef1.getParameters().put('ProdCode1', String.valueOf(prod));
		pageRef1.getParameters().put('ProdName1', String.valueOf(prodName));
		pageRef1.getParameters().put('NoProd', '1');
		Test.setCurrentPage(pageRef1);

		AcctPlanNIProject__c ni5 = new AcctPlanNIProject__c(AcctPlanActionPlanID__c = acctplan1.id, GroupCount__c = 'C', TypeOfFee__c = 'BA Fee', FeeRecuringType__c = 'Recurring', ExpectedFeeRate__c = 70, ExpectedIncrementalFeePerYear1Year__c = 70, FeeStartMonth__c = '11');
		ApexPages.StandardController sc5 = new ApexPages.StandardController(ni5);
		addNIProjectionCtrl AddNICntrl5 = new addNIProjectionCtrl(sc5);
		List<AcctPlanNIProject__c> ni51 = AddNICntrl5.getChildren();
		for (AcctPlanNIProject__c ni511 : ni51) {

			ni511.TypeOfFee__c = 'BA Fee';
			ni511.GroupCount__c = 'C';
			ni511.FeeRecuringType__c = 'Recurring';
			ni511.ExpectedFeeRate__c = 70;
			ni511.ExpectedIncrementalFeePerYear1Year__c = 70;
			ni511.FeeStartMonth__c = '11';
		}

		AddNICntrl5.dosave();


		AcctPlanNIProject__c ni6 = new AcctPlanNIProject__c(AcctPlanActionPlanID__c = acctplan1.id, GroupCount__c = 'D', TypeOfFee__c = 'BA Fee', FeeRecuringType__c = 'Recurring', ExpectedFeeRate__c = 70, ExpectedIncrementalFeePerYear1Year__c = 70, FeeStartMonth__c = '11', FeeStartYear__c = '2016', ExpectedIncrementalFeePerYear2Year__c = 50);
		ApexPages.StandardController sc6 = new ApexPages.StandardController(ni6);
		addNIProjectionCtrl AddNICntrl6 = new addNIProjectionCtrl(sc6);
		List<AcctPlanNIProject__c> ni61 = AddNICntrl6.getChildren();
		for (AcctPlanNIProject__c ni611 : ni61) {

			ni611.TypeOfFee__c = 'BA Fee';
			ni611.GroupCount__c = 'D';
			ni611.FeeRecuringType__c = 'Recurring';
			ni611.ExpectedFeeRate__c = 70;
			ni611.ExpectedIncrementalFeePerYear1Year__c = 70;
			ni611.FeeStartMonth__c = '11';
			ni611.FeeStartYear__c = '2016';
			ni611.ExpectedIncrementalFeePerYear2Year__c = 50;
		}

		AddNICntrl6.dosave();


	}


}