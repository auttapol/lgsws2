@isTest
private class FXOrderAcknowledgeController_Test {

	@testSetup static void setup() {
		TestUtils.createAppConfig();
		FX_Order__c fxor = new FX_Order__c();
		fxor.FXO_BuySell__c = 'Sell';
		fxor.FXO_Currency__c = 'JPY';
		fxor.FXO_CurrencyPair__c = 'JPY/THB';
		fxor.FXO_CustomerRate__c = 0.225;
		fxor.FXO_RequestAmount__c = 50000000;
		insert fxor;

		FX_Order__c fxor1 = new FX_Order__c();
		fxor1.FXO_BuySell__c = 'Buy';
		fxor1.FXO_Currency__c = 'JPY';
		fxor1.FXO_CurrencyPair__c = 'JPY/THB';
		fxor1.FXO_CustomerRate__c = 0.225;
		fxor1.FXO_RequestAmount__c = 10000000;
		insert fxor1;

		FX_Order__c fxor2 = new FX_Order__c();
		fxor2.FXO_BuySell__c = 'Buy';
		fxor2.FXO_Currency__c = 'JPY';
		fxor2.FXO_CurrencyPair__c = 'JPY/THB';
		fxor2.FXO_CustomerRate__c = 0.245;
		fxor2.FXO_RequestAmount__c = 20000000;
		insert fxor2;
	}

	@isTest static void test_getFXO() {
		// setup();
		FX_Order__c fxo_test = [
			SELECT id, FXO_OrderStatus__c
			FROM FX_Order__c
			LIMIT 1
		];
		FX_Order__c fxo = FXOrderAcknowledgeController.getFXO(fxo_test.id);
		
		fxo_test.FXO_OrderStatus__c = FXOrderTriggerHandler.DONE_STATUS;
		update fxo_test;
		fxo = FXOrderAcknowledgeController.getFXO(fxo_test.id);
	}

	@isTest static void test_acknowledgeFromQuickAction() {
		// setup();
		FX_Order__c fxo_test = [
			SELECT id, Name, FXO_Customer__c, OwnerId, Owner_s_Segment__c,
				FXO_BuySell__c, FXO_CurrencyPair__c, FXO_CustomerRate__c, FXO_RequestAmount__c,
				FXO_OrderStatus__c, FXO_Expiration_Date__c, FXO_GTC__c, 
				FXO_AcknowledgedDealby__c,FXO_Acknowledged_Date_Time__c
			FROM FX_Order__c
			LIMIT 1
		];

		fxo_test.FXO_OrderStatus__c = FXOrderTriggerHandler.DONE_STATUS;
		update fxo_test;
		System.assertEquals('Done', fxo_test.FXO_OrderStatus__c);
		FXOrderAcknowledgeController.acknowledgeFromQuickAction(fxo_test);
	}

	@isTest static void text_FXOrderAcknowledgeController() {
		// setup();
		List<FX_Order__c> fxo_list = [
			SELECT id, Name, FXO_Customer__c, OwnerId, Owner_s_Segment__c,
				FXO_BuySell__c, FXO_CurrencyPair__c, FXO_CustomerRate__c, FXO_RequestAmount__c,
				FXO_OrderStatus__c, FXO_Expiration_Date__c, FXO_GTC__c, 
				FXO_AcknowledgedDealby__c,FXO_Acknowledged_Date_Time__c
			FROM FX_Order__c
		];
		
		Test.startTest();

		fxo_list[0].FXO_OrderStatus__c = FXOrderTriggerHandler.DONE_STATUS;
		fxo_list[1].FXO_OrderStatus__c = FXOrderTriggerHandler.DONE_STATUS;
		update fxo_list;

		Test.setCurrentPage(Page.FXOrderAcknowledge);
		ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(fxo_list);
		stdSetController.setSelected(fxo_list);
		FXOrderAcknowledgeController ext = new FXOrderAcknowledgeController(stdSetController);
		ext.AcknowledgeFXOrder();
		fxo_list[2].FXO_OrderStatus__c = FXOrderTriggerHandler.ACKNOWLEDGE_STATUS;
		update fxo_list;
		ext.AcknowledgeFXOrder();
		ext.cancel();
		Test.stopTest();
	}

}