@isTest
private class FXOrderSubmitToTraderController_Test {
	
	@TestSetup static void setup() {
		FX_Order__c fxor = new FX_Order__c();
		fxor.FXO_OrderStatus__c = FXOrderTriggerHandler.NEW_STATUS;
		fxor.FXO_BuySell__c = 'Sell';
		fxor.FXO_Currency__c = 'JPY';
		fxor.FXO_CurrencyPair__c = 'JPY/THB';
		fxor.FXO_CustomerRate__c = 0.225;
		fxor.FXO_RequestAmount__c = 50000000;
		fxor.Owner_s_Segment_stamp__c = 'SE';
		fxor.FXO_GTC__c = false;
		Integer hours = now.hour();
		fxor.FXO_Expiration_Date__c = DateTime.newInstance(now.year(), now.month(), now.day(), hours + 1, 0, 0) ;
		// fxor.FXO_Expiration_Date__c = now.addHours(1);
		insert fxor;

		FX_Order__c fxor1 = new FX_Order__c();
		fxor1.FXO_OrderStatus__c = FXOrderTriggerHandler.SUBMIT_STATUS;
		fxor1.FXO_BuySell__c = 'Buy';
		fxor1.FXO_Currency__c = 'JPY';
		fxor1.FXO_CurrencyPair__c = 'JPY/THB';
		fxor1.FXO_CustomerRate__c = 0.225;
		fxor1.FXO_RequestAmount__c = 10000000;
		fxor1.Owner_s_Segment_stamp__c = 'BB';
		// fxor1.FXO_Expiration_Date__c = System.now().addDays(-2);
		insert fxor1;

		FX_Order__c fxor2 = new FX_Order__c();
		fxor2.FXO_OrderStatus__c = FXOrderTriggerHandler.DONE_STATUS;
		fxor2.FXO_BuySell__c = 'Buy';
		fxor2.FXO_Currency__c = 'JPY';
		fxor2.FXO_CurrencyPair__c = 'JPY/THB';
		fxor2.FXO_CustomerRate__c = 0.245;
		fxor2.FXO_RequestAmount__c = 20000000;
		fxor2.Owner_s_Segment_stamp__c = 'MB';
		insert fxor2;
	}

	@isTest static void test_getFXO() {
		// setup();
		FX_Order__c fxo = [ 
			SELECT id,Name,FXO_Submitted_Date_Time__c,FXO_Customer__c, OwnerId, Owner_s_Segment__c, 
				FXO_BuySell__c,FXO_CurrencyPair__c,FXO_CustomerRate__c,FXO_RequestAmount__c,
				FXO_OrderStatus__c,FXO_Expiration_Date__c,FXO_GTC__c,FXO_Submitted_By__c,
				FXO_InterbankRate__c,FXO_FillAmount__c 
			FROM FX_Order__c
			LIMIT 1
		];
		FXOrderSubmitToTraderController.getFXO(fxo.id);
		fxo.FXO_OrderStatus__c = FXOrderTriggerHandler.DONE_STATUS;
		update fxo;
		FXOrderSubmitToTraderController.getFXO(fxo.id);
	}

	//  -----------------------------------------------
	//  now     : getter/setter to have testemthod-driven different values for now; see also today
	//  -----------------------------------------------
	public static DateTime now {
		get {
			return now == null ? DateTime.now() : now;
		} 
		set;
	}

	//  -----------------------------------------------
	//  today : getter/setter to have testemthod-driven different values for today; see also now
	//  -----------------------------------------------
	public static Date today {
		get {
			return today == null ? Date.today() : today;
		} 
		set;
	}
	
	@isTest static void test_submitFromQuickAction() {
		// setup();
		FX_Order__c o = [ 
			SELECT id,Name,FXO_Submitted_Date_Time__c,FXO_Customer__c, OwnerId, Owner_s_Segment__c, 
				FXO_BuySell__c,FXO_CurrencyPair__c,FXO_CustomerRate__c,FXO_RequestAmount__c,
				FXO_OrderStatus__c,FXO_Expiration_Date__c,FXO_GTC__c,FXO_Submitted_By__c,
				FXO_InterbankRate__c,FXO_FillAmount__c 
			FROM FX_Order__c
			LIMIT 1
		];

		Test.startTest();
		FXOrderSubmitToTraderController.submitFromQuickAction(o);
		
		// DateTime.now().addYears(-1);
		// FXOrderSubmitToTraderController.submitFromQuickAction(o);
		Test.stopTest();
	}

	@isTest static void test_FXOrderSubmitToTraderController(){
		// setup();
		List<FX_Order__c> fxo_list = [ 
			SELECT id,Name,FXO_Submitted_Date_Time__c,FXO_Customer__c, OwnerId, Owner_s_Segment__c, 
				FXO_BuySell__c,FXO_CurrencyPair__c,FXO_CustomerRate__c,FXO_RequestAmount__c,
				FXO_OrderStatus__c,FXO_Expiration_Date__c,FXO_GTC__c,FXO_Submitted_By__c,
				FXO_InterbankRate__c,FXO_FillAmount__c 
			FROM FX_Order__c
		];
		
		// fxo_list[1].FXO_GTC__c = false;
		// fxo_list[1].FXO_Expiration_Date__c = System.now().addSeconds(5);
		fxo_list[2].FXO_OrderStatus__c = FXOrderTriggerHandler.DONE_STATUS;
		update fxo_list;
		// Integer start = System.Now().second();
        // while(System.Now().second() < start + 10){ 
        // }

		Test.startTest();
		Test.setCurrentPage(Page.FXOrderSubmitToTrader);
		ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(fxo_list);
		stdSetController.setSelected(fxo_list);
		FXOrderSubmitToTraderController ext = new FXOrderSubmitToTraderController(stdSetController);
		ext.submitToTrader();
		fxo_list[1].FXO_OrderStatus__c = FXOrderTriggerHandler.DONE_STATUS;
		update fxo_list;
		ext.submitToTrader();
		ext.cancel();
		Test.stopTest();
	}


	@isTest static void test_FXOrderItemSubmitToTraderController(){
		List<FX_Order__c> fxo_list = new List<FX_Order__c>{};
		
		FX_Order__c fxor = new FX_Order__c();
		fxor.FXO_OrderStatus__c = FXOrderTriggerHandler.NEW_STATUS;
		fxor.FXO_BuySell__c = 'Sell';
		fxor.FXO_Currency__c = 'JPY';
		fxor.FXO_CurrencyPair__c = 'JPY/THB';
		fxor.FXO_CustomerRate__c = 0.225;
		fxor.FXO_RequestAmount__c = 50000000;
		fxor.Owner_s_Segment_stamp__c = 'SE';

		fxo_list.add(fxor);
        insert fxo_list;

		Test.startTest();
		Test.setCurrentPage(Page.FXOrderItemSubmitToTrader);
		ApexPages.StandardController sc = new ApexPages.StandardController(fxo_list[0]);
		FXOrderItemSubmitToTraderController ext = new FXOrderItemSubmitToTraderController(sc);
		PageReference pageRef = Page.FXOrderItemSubmitToTrader;
        pageRef.getParameters().put('id', String.valueOf(fxor.Id));
		ext.doForward();
		Test.stopTest();
	}
	
}