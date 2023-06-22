@isTest
private class RTL_LoanProductDetailsServiceWebSvcTest {
	
	@isTest static void coverGeneratedCodeTypes() {
		Test.setMock(WebServiceMock.class, new RTL_LoanProductDetailsServiceMockImpl());
		RTL_LoanProductDetailsService parentObject = new RTL_LoanProductDetailsService();
		new RTL_LoanProductDetailsService.CoBorrowerInformation();
		new RTL_LoanProductDetailsService.CoBorrowerInformationType();
		new RTL_LoanProductDetailsService.getLoanProductDetails_element();
		new RTL_LoanProductDetailsService.getLoanProductDetailsResponse_element();
		new RTL_LoanProductDetailsService.InterestPlan();
		new RTL_LoanProductDetailsService.InterestPlanType();
		new RTL_LoanProductDetailsService.LoanInformation();
		new RTL_LoanProductDetailsService.LoanPaymentInformation();
		new RTL_LoanProductDetailsService.LoanPaymentInformationType();
		new RTL_LoanProductDetailsService.LoanProductDetails();
		new RTL_LoanProductDetailsService.RelatedInsuranceInformation();
		new RTL_LoanProductDetailsService.RelatedInsuranceInformationType();
	}
	@isTest static void coverCodeForgetLoanProductDetails(){
		Test.setMock(WebServiceMock.class, new RTL_LoanProductDetailsServiceMockImpl());
		RTL_LoanProductDetailsService.LoanProductDetailsSOAP testObject = new RTL_LoanProductDetailsService.LoanProductDetailsSOAP();
		System.assertNotEquals(null, testObject.getLoanProductDetails(null,null,null));
	}
	@isTest static void coverCodeForgetLoanProductDetailsAsync(){
		Test.setMock(WebServiceMock.class, new RTL_LoanProductDetailsServiceMockImpl());
		

		// Invoke the continuation by calling the action method
		Integer TIMEOUT_INT_SECS = 60;
		Continuation cont = new Continuation(TIMEOUT_INT_SECS);
		cont.continuationMethod = 'processResponse';
		Test.startTest();
		AsyncRTL_LoanProductDetailsService.AsyncLoanProductDetailsSOAP asyncSoap = new AsyncRTL_LoanProductDetailsService.AsyncLoanProductDetailsSOAP();
		AsyncRTL_LoanProductDetailsService.getLoanProductDetailsResponse_elementFuture respond;
		respond = asyncSoap.beginGetLoanProductDetails(cont, 'xxx','xx','xxx');
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