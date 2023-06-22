@isTest
private class TestCreditCardDetailsCtrl {
	private static List<sObject> ls;
	private static CreditCardInformationDTO dto;

	static {
		//Load test data from resource
		ls = Test.loadData(Product2.sObjectType, 'RTLProductMaster');
		createMock();
	}
	private static void createMock() {
		dto = new CreditCardInformationDTO();
		dto.CardNumber = '1234567890';
		dto.CreditCardType = 'cd001'; // refer to | So Smart	|	Credit Card	| Credit Card
		dto.CreditLimit = 50000;
		dto.ProductName = '';
		dto.TemporaryLine = 60000;
		dto.CycleCut = 30;
		dto.UsageStatus = 'Active';
		dto.BlockCode = '-';
		dto.NextExpiredPointOn = Date.today().addDays(1).addYears(1);
		dto.CashChillChill = 'Ever';
		dto.CashWithdrawalAccountNumber = '1234567890';
		dto.OpenedDate = Date.today().addDays(1).addYears(- 1);
		dto.CurrentBalance = 45000;
		dto.TemporaryLinePeriod = 1;
		dto.PaymentDue = Date.today().addDays(1);
		dto.PaymentBehavior = 'Full/Partial';
		dto.RewardPoints = 12000;
		dto.NextExpiredPoints = 2500;
		dto.CashChillChillStatus = 'Active';
		dto.DirectDebitAccountNumber = '1234567890';
		dto.UsageBehavior = '70:30';
		dto.LastPaymentDate = Date.today().addDays(15);
		dto.SoapMessage ='';
		dto.SoapStatus = '';
		string v1 = dto.MarkedCardNumber ;
		string v2 = dto.MarkedCreditLimit;
        string v3 = dto.MarkedCurrentBalance;
        string v4 = dto.MarkedCashWithdrawalAccountNumber;
        string v5 = dto.MarkedDirectDebitAccountNumber;
        string v6 = dto.convertedLastPaymentDate;
        string v7 = dto.convertedNextExpiredPointOn;
        string v8 = dto.convertedOpenedDate;
        string v9 = dto.convertedPaymentDue;
        string v10 = dto.translatedBlockCode;
        string v11 = dto.translatedStatusCode;
		

		// Create List<SupplementaryInformationDTO>

		List<SupplementaryInformationDTO> relate = new List<SupplementaryInformationDTO> ();
		dto.SupplementaryInformations = relate;




		for (Integer i = 1; i <= 4; i++)
		{
			SupplementaryInformationDTO item = new SupplementaryInformationDTO();

			item.SupplementaryCardNumber = '1234567890';
			item.SupplementaryCardholderName = 'Name ' + i;
			relate.add(item);

		}

		SoGoodPayPlanDTO sogood = new SoGoodPayPlanDTO();
		dto.SoGoodPayPlan = sogood;


		sogood.LastCycleTransactionNonInterestCharge = 20000;
		sogood.LastCycleAmountInTHBNonInterestCharge = 20000;
		sogood.LastCycleTransactionInterestCharge = 20000;
		sogood.LastCycleAmountInTHBInterestCharge = 20000;
		sogood.TotalTransaction = 20000;
		sogood.TotalTHB = 20000;

	}
	@isTest private static void coverageViewModel() {

		CreditCardDetailsCtrl.ViewState viewStage = new CreditCardDetailsCtrl.ViewState();
		viewStage.OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
        string CardNumber = '1234567890';
        string CardType = '302';
		// assign value
		viewStage.CreditCardInformation = dto;
		viewStage.TransformDataCreditCard(CardNumber,CardType);
		//Assert Happy case
		System.assertEquals(45000, viewStage.CreditCardInformation.CurrentBalance);
		//Assert UnHappy case
		viewStage.CreditCardInformation = new CreditCardInformationDTO();
		viewStage.TransformDataCreditCard(CardNumber,CardType);
		System.assertEquals(0, viewStage.CreditCardInformation.CurrentBalance);

	}
    
    @isTest private static void coverageSOAPController() {
		/*--------------------------------------------------
		  Arrang Value
		 *----------------------------------------------------*/
		//Set View 
		PageReference pageRef = Page.CreditCardDetailsView;
		Test.setCurrentPage(pageRef);
		// Page param
		string cdno = '1234567890';
		string cdtype = '1';
        Boolean isEmployee = true;
		string p = UrlHelper.encryptParams(cdno + '&' + cdtype+'&'+isEmployee);
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('p', p);
		// Instantiate a new controller with all parameters in the page
		CreditCardDetailsCtrl ctrl = new CreditCardDetailsCtrl();	
	
		Test.startTest();
		//Test Async Call Out
		Continuation conti = (Continuation) ctrl.startRequest();
		// Verify that the continuation has the proper requests
		Map<String, HttpRequest> requests = conti.getRequests();
		system.assert(requests.size() == 1);

		HttpResponse response = new HttpResponse();
		response.setBody(' <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">                               '
		                 + '    <soap:Body>                                                                                       '
		                 + '       <ns2:getCreditCardDetailsResponse xmlns:ns2="http://www.tmbbank.com/CreditCardDetails/">       '
		                 + '          <Result>                                                                                    '
		                 + '             <Status>ERROR</Status>                                                                 '
		                 + '             <Message/>                                                                               '
		                 + '             <CreditCardInfo>                                                                         '
		                 + '                <Status>SUCCESS</Status>                                                              '
		                 + '                <Message/>                                                                            '
		                 + '                <CardNumber>000010214560432101111150</CardNumber>                                     '
		                 + '                <CreditLimit>0.00</CreditLimit>                                                       '
		                 + '                <CycleCut>20</CycleCut>                                                               '
		                 + '                <UsageStatus>0</UsageStatus>                                                          '
		                 + '                <BlockCode>Active</BlockCode>                                                         '
		                 + '                <CurrentBalance>0.00</CurrentBalance>                                                 '
		                 + '                <RewardPoints>3660</RewardPoints>                                                     '
		                 + '                <DirectDebitAccountNumber/>                                                           '
		                 + '             </CreditCardInfo>                                                                        '
		                 + '			 <SupplementaryInfo>																		'
                         + '				<SupplementaryInfo>																		'
                         + '					<CardNumber>1234</CardNumber>														'
                         + '				</SupplementaryInfo>																	'
                         + '			 </SupplementaryInfo>																		'
                         + '			<PayPlanRecord>																				'
                         + '				<NumberOfNonInterestChargeTransactions>640</NumberOfNonInterestChargeTransactions>		'
                         + '			</PayPlanRecord>																			'
                         + '          </Result>                                                                                   '
		                 + '       </ns2:getCreditCardDetailsResponse>                                                            '
		                 + '    </soap:Body>                                                                                      '
		                 + ' </soap:Envelope>                                                                                     ');
		// Set the fake response for the continuation
		String requestLabel = requests.keyset().iterator().next();
		Test.setContinuationResponse(requestLabel, response);

		// Invoke callback method
		Object result = Test.invokeContinuationMethod(ctrl, conti);
		test.stopTest();


		Object result1 = ctrl.processResponseSOAP();
		// result is the return value of the callback
		System.assertEquals(null, result);
	}
    
	@isTest private static void coverageSOAPControllerNeg() {
		/*--------------------------------------------------
		  Arrang Value
		 *----------------------------------------------------*/
		//Set View 
		PageReference pageRef = Page.CreditCardDetailsView;
		Test.setCurrentPage(pageRef);
		// Page param
		string cdno = '1234567890';
		string cdtype = '1';
        boolean isEmployee = true;
		string p = UrlHelper.encryptParams(cdno + '&' + cdtype+'&'+isEmployee);
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('p', p);
		// Instantiate a new controller with all parameters in the page
		CreditCardDetailsCtrl ctrl = new CreditCardDetailsCtrl();	
	
		Test.startTest();
		//Test Async Call Out
		Continuation conti = (Continuation) ctrl.startRequest();
		// Verify that the continuation has the proper requests
		Map<String, HttpRequest> requests = conti.getRequests();
		system.assert(requests.size() == 1);

		HttpResponse response = new HttpResponse();
		response.setBody(' <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">                               '
		                 + '    <soap:Body>                                                                                       '
		                 + '       <ns2:getCreditCardDetailsResponse xmlns:ns2="http://www.tmbbank.com/CreditCardDetails/">       '
		                 + '          <Result>                                                                                    '
		                 + '             <Status>SUCCESS</Status>                                                                 '
		                 + '             <Message/>                                                                               '
		                 + '             <CreditCardInfo>                                                                         '
		                 + '                <Status>SUCCESS</Status>                                                              '
		                 + '                <Message/>                                                                            '
		                 + '                <CardNumber>000010214560432101111150</CardNumber>                                     '
		                 + '                <CreditLimit>0.00</CreditLimit>                                                       '
		                 + '                <CycleCut>20</CycleCut>                                                               '
		                 + '                <UsageStatus>0</UsageStatus>                                                          '
		                 + '                <BlockCode>Active</BlockCode>                                                         '
		                 + '                <CurrentBalance>0.00</CurrentBalance>                                                 '
		                 + '                <RewardPoints>3660</RewardPoints>                                                     '
		                 + '                <DirectDebitAccountNumber/>                                                           '
		                 + '             </CreditCardInfo>                                                                        '
		                 + '          </Result>                                                                                   '
		                 + '       </ns2:getCreditCardDetailsResponse>                                                            '
		                 + '    </soap:Body>                                                                                      '
		                 + ' </soap:Envelope>                                                                                     ');
		// Set the fake response for the continuation
		String requestLabel = requests.keyset().iterator().next();
		Test.setContinuationResponse(requestLabel, response);

		// Invoke callback method
		Object result = Test.invokeContinuationMethod(ctrl, conti);
		test.stopTest();


		Object result1 = ctrl.processResponseSOAP();
		// result is the return value of the callback
		System.assertEquals(null, result);
	}
	@isTest private static void coverageSOAPControllerException() {
		/*--------------------------------------------------
		  Arrang Value
		 *----------------------------------------------------*/
		//Set View 
		PageReference pageRef = Page.CreditCardDetailsView;
		Test.setCurrentPage(pageRef);
		// Page param
		string cdno = '1234567890';
		string cdtype = '1';
        boolean isEmployee = true;
		string p = UrlHelper.encryptParams(cdno + '&' + cdtype+'&'+isEmployee);
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('p', p);
		// Instantiate a new controller with all parameters in the page
		CreditCardDetailsCtrl ctrl = new CreditCardDetailsCtrl();
		Test.startTest();
		//Test Async Call Out
		Continuation conti = (Continuation) ctrl.startRequest();
		// Verify that the continuation has the proper requests
		Map<String, HttpRequest> requests = conti.getRequests();
		system.assert(requests.size() == 1);

		HttpResponse response = new HttpResponse();
		response.setBody(' <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">                               '
		                 + '    <soap:Body>                                                                                       '
		                 + '    </soap:Body>                                                                                      '
		                 + ' </soap:Envelope>                                                                                     ');
		// Set the fake response for the continuation
		String requestLabel = requests.keyset().iterator().next();
		Test.setContinuationResponse(requestLabel, response);

		// Invoke callback method
		Object result = Test.invokeContinuationMethod(ctrl, conti);
		test.stopTest();


		Object result1 = ctrl.processResponseSOAP();
		// result is the return value of the callback
		System.assertEquals(null, result);
	}
}