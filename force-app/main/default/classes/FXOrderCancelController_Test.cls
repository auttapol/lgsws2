@isTest
private class FXOrderCancelController_Test {

	public static final Id RTL_BRANCH_SALES_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Retail Channel Sales' LIMIT 1].Id;  
	
	@testSetup static void setup() {
		FX_Order__c fxor = new FX_Order__c();
		fxor.FXO_OrderStatus__c = FXOrderTriggerHandler.NEW_STATUS;
		fxor.FXO_BuySell__c = 'Sell';
		fxor.FXO_Currency__c = 'JPY';
		fxor.FXO_CurrencyPair__c = 'JPY/THB';
		fxor.FXO_CustomerRate__c = 0.225;
		fxor.FXO_RequestAmount__c = 50000000;
		fxor.Owner_s_Segment_stamp__c = 'SE';
		fxor.FXO_From_Import_Flag__c = true;
		insert fxor;

		FX_Order__c fxor1 = new FX_Order__c();
		fxor1.FXO_OrderStatus__c = FXOrderTriggerHandler.SUBMIT_STATUS;
		fxor1.FXO_BuySell__c = 'Buy';
		fxor1.FXO_Currency__c = 'JPY';
		fxor1.FXO_CurrencyPair__c = 'JPY/THB';
		fxor1.FXO_CustomerRate__c = 0.225;
		fxor1.FXO_RequestAmount__c = 10000000;
		fxor1.Owner_s_Segment_stamp__c = 'BB';
		fxor1.FXO_From_Import_Flag__c = true;
		insert fxor1;

		FX_Order__c fxor2 = new FX_Order__c();
		fxor2.FXO_OrderStatus__c = FXOrderTriggerHandler.DONE_STATUS;
		fxor2.FXO_BuySell__c = 'Buy';
		fxor2.FXO_Currency__c = 'JPY';
		fxor2.FXO_CurrencyPair__c = 'JPY/THB';
		fxor2.FXO_CustomerRate__c = 0.245;
		fxor2.FXO_RequestAmount__c = 20000000;
		fxor2.Owner_s_Segment_stamp__c = 'MB';
		fxor2.FXO_From_Import_Flag__c = true;
		insert fxor2;



		User fxblotterUser = new User(FirstName='fxblotter', LastName='test fxblotter',
                                UserName='fxblotter_testuser@tmb.com',
                                Email='fxblotter_testuser@tmbbank.com', Alias='RTLUser', Segment__c ='SE',
                                LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                ProfileId = RTL_BRANCH_SALES_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                RTL_Branch_Code__c='001', Region_Code__c = '002', Zone_Code__c = '003',
                                Employee_ID__c='RTL01', RTL_Branch__c='RTLQ_001 (001)');
		insert fxblotterUser;
	}

	@isTest static void test_cancelFromQuickAction() {
		// setup();
		FX_Order__c o = [ SELECT id, Name, FXO_Customer__c, OwnerId, Owner_s_Segment__c,
                                FXO_BuySell__c, FXO_CurrencyPair__c, FXO_CustomerRate__c, FXO_RequestAmount__c,
                                FXO_OrderStatus__c, FXO_Expiration_Date__c, FXO_GTC__c, 
                                FXO_Cancelled_Order_By_Stamp__c,FXO_Cancelled_Order_Date_Time__c
                        FROM FX_Order__c
						LIMIT 1
		];
		FXOrderCancelController.cancelFromQuickAction(o);
	}
	
	@isTest static void test_getFXO() {
		// setup();
		FX_Order__c o = [ SELECT id, Name, FXO_Customer__c, OwnerId, Owner_s_Segment__c,
                                FXO_BuySell__c, FXO_CurrencyPair__c, FXO_CustomerRate__c, FXO_RequestAmount__c,
                                FXO_OrderStatus__c, FXO_Expiration_Date__c, FXO_GTC__c, 
                                FXO_Cancelled_Order_By_Stamp__c,FXO_Cancelled_Order_Date_Time__c
                FROM FX_Order__c 
				LIMIT 1
		];
		User u = FXOrderCancelController.getUserData();
		
		Test.startTest();
		FXOrderCancelController.getFXO(o.id);
		User user_fxblotter = [SELECT Id FROM User WHERE UserName = 'fxblotter_testuser@tmb.com' LIMIT 1];
		// o.OwnerId = user_fxblotter.Id;
		// update o;
		System.runAS(user_fxblotter){
			FXOrderCancelController.getFXO(o.id);
		}
		
		Test.stopTest();
	}

	@isTest static void test_FXOrderCancelController() {
		// setup();
		List<FX_Order__c> fxo_list = [
			SELECT id, Name, FXO_Customer__c, OwnerId, Owner_s_Segment__c,
				FXO_BuySell__c, FXO_CurrencyPair__c, FXO_CustomerRate__c, FXO_RequestAmount__c,
				FXO_OrderStatus__c, FXO_Expiration_Date__c, FXO_GTC__c, 
				FXO_Cancelled_Order_By_Stamp__c,FXO_Cancelled_Order_Date_Time__c
			FROM FX_Order__c
		];
		

		// fxo_list[1].OwnerId = user_fxblotter.Id;
		fxo_list[2].FXO_OrderStatus__c = FXOrderTriggerHandler.DONE_STATUS;
		update fxo_list;
		
		User user_fxblotter = [SELECT Id FROM User WHERE UserName = 'fxblotter_testuser@tmb.com' LIMIT 1];
		Test.startTest();
		System.runAS(user_fxblotter){
			
		
			Test.setCurrentPage(Page.FXOrderCancel);
			// User u = FXOrderCancelController.getUserData();
			// u.Segment__c = 'BB';
			// update u;
			ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(fxo_list);
			stdSetController.setSelected(fxo_list);
			FXOrderCancelController ext = new FXOrderCancelController(stdSetController);
			ext.cancelOrderConfirm();
			// FXOrderAcknowledgeController.acknowledgeFromQuickAction(fxo_list[2]);
			// fxo_list[2].FXO_OrderStatus__c = FXOrderTriggerHandler.ACKNOWLEDGE_STATUS;
			// update fxo_list;
			//ext.cancelOrderConfirm();
			ext.cancel();

		}
		Test.stopTest();
	}

	//@isTest static void test_FXOrderCancelFailedController() {
	//	// setup();
	//	List<FX_Order__c> fxo_list = [
	//		SELECT id, Name, FXO_Customer__c, OwnerId, Owner_s_Segment__c,
	//			FXO_BuySell__c, FXO_CurrencyPair__c, FXO_CustomerRate__c, FXO_RequestAmount__c,
	//			FXO_OrderStatus__c, FXO_Expiration_Date__c, FXO_GTC__c, 
	//			FXO_Cancelled_Order_By_Stamp__c,FXO_Cancelled_Order_Date_Time__c
	//		FROM FX_Order__c
	//	];
		

	//	// fxo_list[1].OwnerId = user_fxblotter.Id;

		
	//	User user_fxblotter = [SELECT Id FROM User WHERE UserName = 'fxblotter_testuser@tmb.com' LIMIT 1];
	//	Test.startTest();
	//	System.runAS(user_fxblotter){
			
		
	//		Test.setCurrentPage(Page.FXOrderCancel);
	//		// User u = FXOrderCancelController.getUserData();
	//		// u.Segment__c = 'BB';
	//		// update u;
	//		ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(fxo_list);
	//		stdSetController.setSelected(fxo_list);
	//		FXOrderCancelController ext = new FXOrderCancelController(stdSetController);

	//		//ext.cancelOrderConfirm();

	//		//FXOrderAcknowledgeController.acknowledgeFromQuickAction(fxo_list[2]);


	
	//	//fxo_list[2].FXO_OrderStatus__c = FXOrderTriggerHandler.ACKNOWLEDGE_STATUS;
	//	//update fxo_list2[2];

	//	//	FXOrderAcknowledgeController.acknowledgeFromQuickAction(fxo_list[2]);

	//	List<FX_Order__c> fxo_list2 = [
	//		SELECT id, Name, FXO_Customer__c, OwnerId, Owner_s_Segment__c,
	//			FXO_BuySell__c, FXO_CurrencyPair__c, FXO_CustomerRate__c, FXO_RequestAmount__c,
	//			FXO_OrderStatus__c, FXO_Expiration_Date__c, FXO_GTC__c, 
	//			FXO_Cancelled_Order_By_Stamp__c,FXO_Cancelled_Order_Date_Time__c,
	//			FXO_FXOrderSummary__c
	//		FROM FX_Order__c
	//	];

	//	system.debug('Gade:' + fxo_list2);

	//		List<FX_Order_Summary__c> fxslist = [select id,FXS_Status__c from FX_Order_Summary__c where id = :fxo_list2[2].FXO_FXOrderSummary__c ];
	//	system.debug('Gade2:' + fxslist);			
	//		//ext.cancelOrderConfirm();
	//		//ext.cancel();

	//	}
	//	Test.stopTest();
	//}
}