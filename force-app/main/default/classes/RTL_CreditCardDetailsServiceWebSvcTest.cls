@isTest
private class RTL_CreditCardDetailsServiceWebSvcTest {

	@isTest static void coverGeneratedCodeTypes() {
		Test.setMock(WebServiceMock.class, new RTL_CreditCardDetailsServiceMockImpl());
		RTL_CreditCardDetailsService parentObject = new RTL_CreditCardDetailsService();
		new RTL_CreditCardDetailsService.CreditCardDetails();
		new RTL_CreditCardDetailsService.CreditCardInfo();
		new RTL_CreditCardDetailsService.getCreditCardDetails_element();
		new RTL_CreditCardDetailsService.getCreditCardDetailsResponse_element();
		new RTL_CreditCardDetailsService.PayPlanRecord();
		new RTL_CreditCardDetailsService.SupplementaryInfo();
		new RTL_CreditCardDetailsService.SupplementaryInfoType();
	}
	@isTest static void coverCodeForgetCreditCardDetails() {
		Test.setMock(WebServiceMock.class, new RTL_CreditCardDetailsServiceMockImpl());
		RTL_CreditCardDetailsService.CreditCardDetailsSOAP testObject = new RTL_CreditCardDetailsService.CreditCardDetailsSOAP();
		System.assertNotEquals(null, testObject.getCreditCardDetails(null, null));
	}
	@isTest static void coverGeneratedCodeTypesAsync() {
		Test.setMock(WebServiceMock.class, new RTL_CreditCardDetailsServiceMockImpl());

		// Invoke the continuation by calling the action method
		Integer TIMEOUT_INT_SECS = 60;
		Continuation cont = new Continuation(TIMEOUT_INT_SECS);
		cont.continuationMethod = 'processResponse';
		Test.startTest();
		AsyncRTL_CreditCardDetailsService.AsyncCreditCardDetailsSOAP asyncSoap = new AsyncRTL_CreditCardDetailsService.AsyncCreditCardDetailsSOAP();
		AsyncRTL_CreditCardDetailsService.getCreditCardDetailsResponse_elementFuture respond;
		respond = asyncSoap.beginGetCreditCardDetails(cont, 'xxx', 'xxx');
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