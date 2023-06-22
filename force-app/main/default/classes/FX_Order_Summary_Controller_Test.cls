@isTest
private class FX_Order_Summary_Controller_Test {
	
	 @testSetup static void setupData() 
	 {
	 	TestUtils.createAppConfig();
	 	//FX_Order__c fxo = setup_FXOrder();
	 	FX_Order__c fxor = new FX_Order__c();
		fxor.FXO_OrderStatus__c = FXOrderTriggerHandler.NEW_STATUS;
		fxor.FXO_BuySell__c = 'Sell';
		fxor.FXO_Currency__c = 'JPY';
		fxor.FXO_CurrencyPair__c = 'JPY/THB';
		fxor.FXO_CustomerRate__c = 0.225;
		fxor.FXO_RequestAmount__c = 50000000;
		fxor.Owner_s_Segment_stamp__c = 'SE';
		insert fxor;

		fxor.FXO_OrderStatus__c = FXOrderTriggerHandler.SUBMIT_STATUS;
		update fxor;

	 }


	public static FX_Order_Summary__c setup_FXS() {
		FX_Order_Summary__c fxs = [
			SELECT Id , FXS_Order_Key__c , FXS_Status__c, FXS_TotalAllocateAmount__c, FXS_TotalRequestAmount__c 
			FROM FX_Order_Summary__c
		];

		return fxs;
	}

	// @isTest static void test_Null_itemPerPage() {
	// 	Decimal page = FX_Order_Summary_Controller.getItemPerPage();
	// 	System.assertEquals(null, page);
	// }

	@isTest static void test_Default_itemPerPage() {
		Decimal page = FX_Order_Summary_Controller.getItemPerPage();
		System.assertEquals(200, page);
	}
	
	
	@isTest static void test_getFXSItemAmount(){
		Map<String, integer> Order = FX_Order_Summary_Controller.getFXSItemAmount('');
	}

	@isTest static void test_getFXSOrder(){
		// FX_Order_Summary_Controller x = new FX_Order_Summary_Controller();
		// FX_Order_Summary_Controller.OrderSummaryWrapper y = new FX_Order_Summary_Controller.OrderSummaryWrapper();
		FX_Order_Summary_Controller.OrderSummaryWrapper osw = new FX_Order_Summary_Controller.OrderSummaryWrapper();
		osw = FX_Order_Summary_Controller.getFXSOrder('usd', 1, 1);	
	}

	@isTest static void test_getbuyOrderAndgetSellOrder(){
		List<FX_Order_Summary__c> fxs_buy = FX_Order_Summary_Controller.getbuyOrder();
		List<FX_Order_Summary__c> fxs_sell = FX_Order_Summary_Controller.getSellOrder();
	}

	@isTest static void test_updateOrderSummary_to_partial(){
		Test.startTest();

		FX_Order_Summary__c fxs = setup_FXS();
		FX_Order_Summary__c tmp_fxs = FX_Order_Summary_Controller.getFXS(fxs.Id);
		tmp_fxs.FXS_TotalAllocateAmount__c = 10000000;
		if(FX_Order_Summary_Controller.validateAndUpdateFXS(tmp_fxs)){
			tmp_fxs = FX_Order_Summary_Controller.updateOrderSummary(tmp_fxs);
		}


		// // Expiration date
		// fxs = setup_FXS();
		// List<FX_Order__c> fxo_list = FX_Order_Summary_Controller.getSubmittedOrderByFXS(fxs.id);
		// fxo_list[0].FXO_GTC__c = false;
		// fxo_list[0].FXO_Expiration_Date__c = System.now().addSeconds(1);
		// // update fxo_list;
		// Integer start = System.Now().second();
		// while(System.Now().second() < start + 10){ }
		// FX_Order_Summary__c tmp_Expiration_fxs = FX_Order_Summary_Controller.getFXS(fxs.Id);
		// if(FX_Order_Summary_Controller.validateAndUpdateFXS(tmp_Expiration_fxs)){
		// 	tmp_Expiration_fxs.FXS_TotalAllocateAmount__c = tmp_Expiration_fxs.FXS_TotalRequestAmount__c;
		// 	tmp_Expiration_fxs = FX_Order_Summary_Controller.adjustOrderSummary(tmp_Expiration_fxs);
		// }	

		Test.stopTest();
	}
	@isTest static void test_updateOrderSummary_to_fully(){
		Test.startTest();

		FX_Order_Summary__c fxs = setup_FXS();
		FX_Order_Summary__c tmp_fxs = FX_Order_Summary_Controller.getFXS(fxs.Id);
		tmp_fxs.FXS_TotalAllocateAmount__c = 50000000;
		if(FX_Order_Summary_Controller.validateAndUpdateFXS(tmp_fxs)){
			tmp_fxs = FX_Order_Summary_Controller.updateOrderSummary(tmp_fxs);
		}
		Test.stopTest();
	}

	@isTest static void test_getSubmittedOrderByFXS_new_to_full(){
		// ------------------------------------New FXS

		Test.startTest();
		// Full allocate - new to full
		FX_Order_Summary__c fxs = setup_FXS();
		List<FX_Order__c> fxo_list = FX_Order_Summary_Controller.getSubmittedOrderByFXS(fxs.id);
		
		fxs.FXS_TotalAllocateAmount__c = fxs.FXS_TotalRequestAmount__c;
		fxs = FX_Order_Summary_Controller.adjustOrderSummary(fxs);
		fxo_list = FX_Order_Summary_Controller.getSubmittedOrderByFXS(fxs.id);
		Test.stopTest();
	}

	@isTest static void test_getSubmittedOrderByFXS_new_to_partial_and_cancel(){
		// ------------------------------------New FXS
		
		Test.startTest();
		// Partail allocate - new to partial
		FX_Order_Summary__c fxs = setup_FXS();
		List<FX_Order__c> fxo_list = FX_Order_Summary_Controller.getSubmittedOrderByFXS(fxs.id);
		
		fxs.FXS_TotalAllocateAmount__c = 100000;
		fxs = FX_Order_Summary_Controller.adjustOrderSummary(fxs);
		fxo_list = FX_Order_Summary_Controller.getSubmittedOrderByFXS(fxs.id);

		fxs.FXS_TotalAllocateAmount__c = 100000;
		fxs = FX_Order_Summary_Controller.adjustOrderSummary(fxs);
		String s = FX_Order_Summary_Controller.cancelOrderSummaryFromPartialAndFull(fxs);
		fxo_list = FX_Order_Summary_Controller.getSubmittedOrderByFXS(fxs.id);
		Test.stopTest();
	}

	@isTest static void test_getSubmittedOrderByFXS_partial_to_full(){
		
		Test.startTest();
		FX_Order_Summary__c fxs = setup_FXS();
		fxs.FXS_TotalAllocateAmount__c = 100000;
		fxs.FXS_Status__c = FXOrderSummaryTriggerHandle.PARTAIL_COMPLETE_STATUS;
		update fxs;
		List<FX_Order__c> fxo_list = FX_Order_Summary_Controller.getSubmittedOrderByFXS(fxs.id);

		// Full allocate - partial to full
		fxs.FXS_TotalAllocateAmount__c = fxs.FXS_TotalRequestAmount__c;
		fxs = FX_Order_Summary_Controller.adjustOrderSummary(fxs);
		fxo_list = FX_Order_Summary_Controller.getSubmittedOrderByFXS(fxs.id);
	
		Test.stopTest();
	}

	@isTest static void test_getSubmittedOrderByFXS_cancel(){
		// ------------------------------------New FXS

		Test.startTest();
		// Full allocate - new to full
		FX_Order_Summary__c fxs = setup_FXS();
		List<FX_Order__c> fxo_list = FX_Order_Summary_Controller.getSubmittedOrderByFXS(fxs.id);
		
		fxs.FXS_TotalAllocateAmount__c = fxs.FXS_TotalRequestAmount__c;
		fxs = FX_Order_Summary_Controller.adjustOrderSummary(fxs);
		fxo_list = FX_Order_Summary_Controller.getSubmittedOrderByFXS(fxs.id);
		String s = FX_Order_Summary_Controller.cancelOrderSummaryFromPartialAndFull(fxs);
		fxo_list = FX_Order_Summary_Controller.getSubmittedOrderByFXS(fxs.id);
		Test.stopTest();
	}

	@isTest static void test_getFXO(){
		FX_Order_Summary__c mock_fxs = setup_FXS();
		List<FX_Order__c> mock_fxo = FX_Order_Summary_Controller.getSubmittedOrderByFXS(mock_fxs.id);
		FX_Order__c fxo = FX_Order_Summary_Controller.getFXO(mock_fxo[0].id);
	}

	@isTest static void test_getFXS(){
		FX_Order_Summary__c mock_fxs = setup_FXS();
		FX_Order_Summary__c fxs = FX_Order_Summary_Controller.getFXS(mock_fxs.id);
	}

	@isTest static void test_getAllDetail(){
		User u = FX_Order_Summary_Controller.getUserData();
		FX_Blotter_Profile_Manager__mdt fxblop = FX_Order_Summary_Controller.getBlotterProfile();
		String session_id = FX_Order_Summary_Controller.getSessionId();
	}

	@isTest static void test_getAllField(){
		Set<String> test = FX_Order_Summary_Controller.getAllField('FX_Order__c');
	}

	@isTest static void test_createFXOrder(){
		FX_Order__c fxor = new FX_Order__c();
		// String test1 = FX_Order_Summary_Controller.createFXOrder(fxor);

		fxor.FXO_OrderStatus__c = FXOrderTriggerHandler.NEW_STATUS;
		fxor.FXO_BuySell__c = 'Sell';
		fxor.FXO_Currency__c = 'JPY';
		fxor.FXO_CurrencyPair__c = 'JPY/THB';
		fxor.FXO_CustomerRate__c = 0.245;
		fxor.FXO_RequestAmount__c = 10000000;
		fxor.Owner_s_Segment_stamp__c = 'SE';
		
		String test2 = FX_Order_Summary_Controller.createFXOrder(fxor);
	}

	@isTest static void test_stampCancelRemain(){
		FX_Order_Summary__c fxs = setup_FXS();
		List<FX_Order__c> fxo_list = FX_Order_Summary_Controller.getSubmittedOrderByFXS(fxs.id);
		FX_Order__c fxo = FX_Order_Summary_Controller.stampCancelRemain(fxo_list[0]);
	}

	// @isTest static void test_cancelOrderSummaryFromPartialAndFull(){
	// 	FX_Order_Summary__c fxs = setup_FXS();
	// 	String s = FX_Order_Summary_Controller.cancelOrderSummaryFromPartialAndFull(fxs);
	// }

	@isTest static void test_spreadOrder(){
		Test.startTest();

		FX_Order_Summary__c fxs = setup_FXS();
		fxs.FXS_TotalAllocateAmount__c = 100000;
		fxs = FX_Order_Summary_Controller.adjustOrderSummary(fxs);
		
		List<FX_Order__c> fxo_list = FX_Order_Summary_Controller.getSubmittedOrderByFXS(fxs.id);
		fxo_list[0].FXO_FillAmount__c = 100000;
		
		FX_Order_Summary_Controller.OrderWrapper ow = new FX_Order_Summary_Controller.OrderWrapper();
		ow = FX_Order_Summary_Controller.spreadOrder(fxo_list, fxs);
		
		Test.stopTest();
	}
}