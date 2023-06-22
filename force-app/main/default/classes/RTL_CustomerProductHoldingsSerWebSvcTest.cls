@isTest
private class RTL_CustomerProductHoldingsSerWebSvcTest {

	@isTest static void coverGeneratedCodeTypes() {
		Test.setMock(WebServiceMock.class, new RTL_CustomerProductHoldingsServiMockImpl());
		RTL_CustomerProductHoldingsService parentObject = new RTL_CustomerProductHoldingsService();
		new RTL_CustomerProductHoldingsService.BancassuranceAccount();
		new RTL_CustomerProductHoldingsService.BancassuranceAccountsType();
		new RTL_CustomerProductHoldingsService.CreditCardAccount();
		new RTL_CustomerProductHoldingsService.CreditCardAccountsType();
		new RTL_CustomerProductHoldingsService.CustomerProductHoldings();
		new RTL_CustomerProductHoldingsService.DepositAccount();
		new RTL_CustomerProductHoldingsService.DepositAccountsType();
		new RTL_CustomerProductHoldingsService.getProductHoldings_element();
		new RTL_CustomerProductHoldingsService.getProductHoldingsResponse_element();
		new RTL_CustomerProductHoldingsService.InvestmentAccount();
		new RTL_CustomerProductHoldingsService.InvestmentAccountsType();
		new RTL_CustomerProductHoldingsService.LoanAccount();
		new RTL_CustomerProductHoldingsService.LoanAccountsType();
	}
	@isTest static void coverCodeForgetProductHoldings() {
		Test.setMock(WebServiceMock.class, new RTL_CustomerProductHoldingsServiMockImpl());
		RTL_CustomerProductHoldingsService.CustomerProductHoldingsSOAP testObject = new RTL_CustomerProductHoldingsService.CustomerProductHoldingsSOAP();
		System.assertNotEquals(null, testObject.getProductHoldings(null));
	}


	@isTest static void coverCodeForGetProductHoldingsAsync() {
		// Setup Mock Service 
		Test.setMock(WebServiceMock.class, new RTL_CustomerProductHoldingsServiMockImpl());
		// Invoke the continuation by calling the action method
		Integer TIMEOUT_INT_SECS = 60;   
		Continuation cont = new Continuation(TIMEOUT_INT_SECS);
		cont.continuationMethod = 'processResponse';

		AsyncRTL_CustomerProductHoldingsService.getProductHoldingsResponse_elementFuture d = new AsyncRTL_CustomerProductHoldingsService.getProductHoldingsResponse_elementFuture();


		AsyncRTL_CustomerProductHoldingsService.AsyncCustomerProductHoldingsSOAP asyncSoap = new AsyncRTL_CustomerProductHoldingsService.AsyncCustomerProductHoldingsSOAP();
		//Act    
		Test.startTest();
		AsyncRTL_CustomerProductHoldingsService.getProductHoldingsResponse_elementFuture respond;
		respond = asyncSoap.beginGetProductHoldings(cont, 'xxx');
		Test.stopTest();
		System.assertNotEquals(null, respond);


		system.debug('Contunue : ' + cont);
		if (respond != null)
		{
			Boolean isError = false;
			// Try to cover 100%
			try
			{
				respond.getValue();
			}
			catch(Exception e)
			{
				isError = true;
			}

			System.assertEquals(true, isError);
		}

	}
}