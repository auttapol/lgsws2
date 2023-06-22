@isTest
public class RTL_NBOControllerTest {
    static List<Account> acctList;
    static RTL_NBO_History_Product__c nboProduct;
	static List<RTL_NBO_History__c> nboHistoryList;
    
    static{       
        TestUtils.createAppConfig();
        acctList = RTL_TestUtility.createAccounts(2,true);
        RTL_TestUtility.createRetailMasterProducts2(true);
        nboHistoryList = RTL_TestUtility2.createNBOHistoryAndProductValidByProductGroup(20,acctList[0].id,'Deposit',true);
        nboProduct = [SELECT ID,Name FROM RTL_NBO_History_Product__c WHERE RTL_NBO_ID__c =:nboHistoryList[0].RTL_NBO_ID__c LIMIT 1];
        RTL_NBO_History_Pagination__c nboPagination = new RTL_NBO_History_Pagination__c();
        nboPagination.Name = 'Record Per Page';
        nboPagination.Page_Max_Size__c = 10;
        insert nboPagination;
        
    }
    
    static testmethod void testNBO(){
        Test.setMock(WebserviceMock.class,new RTL_NextBestOfferServiceMockImpl());
        Test.startTest();
        	Test.setCurrentPage(new PageReference('/apex/RTL_NBOSummaryView'));
        	ApexPages.currentPage().getParameters().put('acctId',acctList[0].id);
        	RTL_NBOController nboCtrl = new RTL_NBOController();
        	nboCtrl.SVR_MODE = 'soap';
        	// Invoke the continuation by calling the action method
        	Continuation cont = nboCtrl.startRequest();
        	// Verify that the continuation has the proper requests
        	Map<String, HttpRequest> requests = cont.getRequests();
        	System.assertEquals(requests.size(), 1);
        	
        	// Perform mock callout 
        	// (i.e. skip the callout and call the callback method)
        	HttpResponse response = new HttpResponse();
        	response.setBody('<SOAP:Envelope'
            	+ ' xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/">'
            	+ '<SOAP:Body>'
            	+ '<ns2:getNextBestOfferResponse '
            	+ 'xmlns:ns2="http://www.tmbbank.com/NextBestOffer/">'
            	+ '<Result>'
                + '<NextBestOfferDetails>'
                + '<Status>SUCCESS</Status>'
                + '		<NextBestOfferDetail>'
                + '			<NboId>001p000000CKy8AAD</NboId>'
                + '			<CampaignCode>R1205975</CampaignCode>'
                + '			<CampaignName>R1205975</CampaignName>'
                + '			<ValidFrom>2016/08/01</ValidFrom>'
                + '			<ContactDate>2016/08/01</ContactDate>'
                + '			<CustomerId>'+acctList[0].TMB_Customer_ID_PE__c+'</CustomerId>'
                + '		</NextBestOfferDetail>'             
                + '</NextBestOfferDetails>'
                + '<NextBestOfferProducts>'
                + '		<Status>SUCCESS</Status>'
                + '		<NextBestOfferProduct>'
                + '		<NboId>001p000000CKy8AAD</NboId>'
                + '		<NboProductId>R1205975032423</NboProductId>'
                + '		<Product>Deposit Product</Product>'
                + '		</NextBestOfferProduct>'
                + '</NextBestOfferProducts>'
                + '<Status>SUCCESS</Status>'
                + '</Result>' 
            	+ '</ns2:getNextBestOfferResponse>' 
            	+ '</SOAP:Body>'
            	+ '</SOAP:Envelope>');
        
        	System.debug('RESPONSE '+response);

        	// Set the fake response for the continuation
        	String requestLabel = requests.keyset().iterator().next();
        	Test.setContinuationResponse(requestLabel, response);
        
        	// Invoke callback method
        	Object result = Test.invokeContinuationMethod(nboCtrl, cont);
        	System.debug(nboCtrl);

        	// result is the return value of the callback
        	System.assertEquals(null, result);
        	//Check Result : Verity that one Valid NBO is fetched
        	System.assertEquals(1, nboCtrl.nbohistoryList.size());
        	System.assertEquals(10, nboCtrl.nbohistoryTempList.size());
        
        	//Test Pagination
        	System.assertEquals(false,nboCtrl.getDisableNext());
        	System.assertEquals(true,nboCtrl.getDisablePrevious());
        	nboCtrl.Next();
        	System.assertEquals(false,nboCtrl.getDisablePrevious());
        	System.assertEquals(true,nboCtrl.getDisableNext());
        	nboCtrl.Previous();
        	nboCtrl.First();
        	nboCtrl.Last();
        
        	nboCtrl.refreshNBOFromDB();
        	nboCtrl.doNothing();
        	nboCtrl.sortExpression = 'RTL_Valid_From__c';
        	nboCtrl.ViewData();
        	nboCtrl.sortExpression = 'RTL_Valid_From__c';
        	nboCtrl.ViewData();
        	nboCtrl.getSortDirection();
        	nboCtrl.setSortDirection('DESC');
        
        Test.stopTest();
    }
    
    static testmethod void testNBOError(){
        Test.setMock(WebserviceMock.class,new RTL_NextBestOfferServiceMockImpl());
        Test.startTest();
        	Test.setCurrentPage(new PageReference('/apex/RTL_NBOSummaryView'));
        	ApexPages.currentPage().getParameters().put('acctId',acctList[0].id);
        	RTL_NBOController nboCtrl = new RTL_NBOController();
        	nboCtrl.SVR_MODE = 'soap';
        	// Invoke the continuation by calling the action method
        	Continuation cont = nboCtrl.startRequest();
        	// Verify that the continuation has the proper requests
        	Map<String, HttpRequest> requests = cont.getRequests();
        	System.assertEquals(requests.size(), 1);
        	
        	// Perform mock callout 
        	// (i.e. skip the callout and call the callback method)
        	HttpResponse response = new HttpResponse();
        	response.setBody('<SOAP:Envelope'
            	+ ' xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/">'
            	+ '<SOAP:Body>'
            	+ '<ns2:getNextBestOfferResponse '
            	+ 'xmlns:ns2="http://www.tmbbank.com/NextBestOffer/">'
            	+ '<Result>'
                + '<Status>ERROR</Status>'
                + '<Message>ERR001</Message>'
                + '</Result>' 
            	+ '</ns2:getNextBestOfferResponse>' 
            	+ '</SOAP:Body>'
            	+ '</SOAP:Envelope>');
        
        	System.debug('RESPONSE '+response);

        	// Set the fake response for the continuation
        	String requestLabel = requests.keyset().iterator().next();
        	Test.setContinuationResponse(requestLabel, response);
        
        	// Invoke callback method
        	Object result = Test.invokeContinuationMethod(nboCtrl, cont);
        	System.debug(nboCtrl);

        	// result is the return value of the callback
        	System.assertEquals(null, result);

			System.assertEquals(System.Label.ERR001,nboCtrl.PageMessage);
        
        Test.stopTest();
    }
    
    static testmethod void testZeroNBO(){
        Test.setMock(WebserviceMock.class,new RTL_NextBestOfferServiceMockImpl());
        Test.startTest();
        	Test.setCurrentPage(new PageReference('/apex/RTL_NBOSummaryView'));
        	ApexPages.currentPage().getParameters().put('acctId',acctList[0].id);
        	RTL_NBOController nboCtrl = new RTL_NBOController();
        	nboCtrl.SVR_MODE = 'soap';
        	// Invoke the continuation by calling the action method
        	Continuation cont = nboCtrl.startRequest();
        	// Verify that the continuation has the proper requests
        	Map<String, HttpRequest> requests = cont.getRequests();
        	System.assertEquals(requests.size(), 1);
        	
        	// Perform mock callout 
        	// (i.e. skip the callout and call the callback method)
        	HttpResponse response = new HttpResponse();
        	response.setBody('<SOAP:Envelope'
            	+ ' xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/">'
            	+ '<SOAP:Body>'
            	+ '<ns2:getNextBestOfferResponse '
            	+ 'xmlns:ns2="http://www.tmbbank.com/NextBestOffer/">'
            	+ '<Result>'
                + '<NextBestOfferDetails>'
                + '<Status>SUCCESS</Status>'             
                + '</NextBestOfferDetails>'
                + '<NextBestOfferProducts>'
                + '</NextBestOfferProducts>'
                + '<Status>SUCCESS</Status>'
                + '</Result>' 
            	+ '</ns2:getNextBestOfferResponse>' 
            	+ '</SOAP:Body>'
            	+ '</SOAP:Envelope>');
        
        	System.debug('RESPONSE '+response);

        	// Set the fake response for the continuation
        	String requestLabel = requests.keyset().iterator().next();
        	Test.setContinuationResponse(requestLabel, response);
        
        	// Invoke callback method
        	Object result = Test.invokeContinuationMethod(nboCtrl, cont);
        	System.debug(nboCtrl);

        	// result is the return value of the callback
        	System.assertEquals(null, result);
        	//Check Result : Verify that no valid NBO Fetched
        	System.assertEquals(0, nboCtrl.nbohistoryList.size());
        
        Test.stopTest();
    }
    
    
}