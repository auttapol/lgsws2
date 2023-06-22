@isTest
private class RTL_NextBestOfferServiceTest {
    @isTest static void coverGeneratedCodeTypes() {
		Test.setMock(WebServiceMock.class, new RTL_NextBestOfferServiceMockImpl());
		RTL_NextBestOffer parentObject = new RTL_NextBestOffer();
		new RTL_NextBestOffer.NextBestOffer();
		new RTL_NextBestOffer.NextBestOfferDetail();
		new RTL_NextBestOffer.NextBestOfferDetailsType();
		new RTL_NextBestOffer.NextBestOfferProduct();
		new RTL_NextBestOffer.NextBestOfferProductsType();
		new RTL_NextBestOffer.getNextBestOffer_element();
		new RTL_NextBestOffer.getNextBestOfferResponse_element();
		
	}
	@isTest static void coverCodeForgetNBOSoap() {
		Test.setMock(WebServiceMock.class, new RTL_NextBestOfferServiceMockImpl());
		RTL_NextBestOffer.NextBestOfferSOAP testObject = new RTL_NextBestOffer.NextBestOfferSOAP();
		System.assertNotEquals(null, testObject.getNextBestOffer(null));
	}


	@isTest static void coverCodeForGetNBOAsync() {
		// Setup Mock Service 
		Test.setMock(WebServiceMock.class, new RTL_NextBestOfferServiceMockImpl());
		// Invoke the continuation by calling the action method
		Integer TIMEOUT_INT_SECS = 60;   
		Continuation cont = new Continuation(TIMEOUT_INT_SECS);
		cont.continuationMethod = 'processResponse';

		AsyncRTL_NextBestOffer.getNextBestOfferResponse_elementFuture d = new AsyncRTL_NextBestOffer.getNextBestOfferResponse_elementFuture();


		AsyncRTL_NextBestOffer.AsyncNextBestOfferSOAP asyncSoap = new AsyncRTL_NextBestOffer.AsyncNextBestOfferSOAP();
		//Act    
		Test.startTest();
		AsyncRTL_NextBestOffer.getNextBestOfferResponse_elementFuture respond;
		respond = asyncSoap.beginGetNextBestOffer(cont, 'xxx');
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