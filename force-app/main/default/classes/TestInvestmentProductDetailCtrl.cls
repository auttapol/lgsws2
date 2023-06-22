@isTest
private class TestInvestmentProductDetailCtrl {
	private static List<sObject> ls;
	private static InvestmentProductDetailsDTO dto;
	static {
		//Load test data from resource
		ls = Test.loadData(Product2.sObjectType, 'RTLProductMaster');
		createMock();
	}
	private static void createMock() {
		dto = new InvestmentProductDetailsDTO();

		dto.SoapMessage = '';
		dto.SoapStatus = 'SUCCESS';

		dto.InvestmentInformation.UnitHolderNo = '1234567890';
		dto.InvestmentInformation.FundCode = 'ABLTF';
		dto.InvestmentInformation.SoapMessage = '';
		dto.InvestmentInformation.SoapStatus = 'SUCCESS';
		dto.InvestmentInformation.NumberOfUnit = 5;
		dto.InvestmentInformation.CostOfInvestment = 125000;
		dto.InvestmentInformation.MarketValue = 4000;
		dto.InvestmentInformation.UnrealizedGL = 4000;
		dto.InvestmentInformation.NAVUnit = 4000;
        dto.InvestmentInformation.AssetType = '';
        dto.InvestmentInformation.FundType = '';
        dto.InvestmentInformation.IssuerFundHouse = '';
		Decimal v1 = dto.InvestmentInformation.AvgCostUnit;
		List<InvestmentTransactionDTO> InvestmentTransactions = new List<InvestmentTransactionDTO> ();
		dto.InvestmentTransactions = InvestmentTransactions;
		for (Integer i = 1; i <= 4; i++) {
			InvestmentTransactionDTO item = new InvestmentTransactionDTO();
			item.SoapMessage = '';
			item.SoapStatus = 'SUCCESS';
			item.TransactionDate = Date.today().addDays(- 1).addYears(+ 2);
			item.SettlementDate = Date.today().addDays(- 1).addYears(+ 4);
			item.TransactionType = 'Dividend';
			item.UnitMovement = 300;
			item.UnitOutstanding = 50000;
			item.TransactionValue = 60000;
			item.ValuePerUnit = 3000;
			item.Statue = 'Active';
			InvestmentTransactions.add(item);
            
            string p1 = item.convertedSettlementDate;
            string p2 = item.convertedTransactionDate;
		}

		List<AutoInvestmentPlanDTO> AutoInvestmentPlans = new List<AutoInvestmentPlanDTO> ();
		dto.AutoInvestmentPlans = AutoInvestmentPlans;
		for (Integer i = 1; i <= 4; i++) {
			AutoInvestmentPlanDTO item = new AutoInvestmentPlanDTO();
			item.SoapMessage = '';
			item.SoapStatus = 'SUCCESS';
			item.Instruction = 'Yes';
			item.Date_x = '25th of month';
			item.SinceDate = Date.today().addDays(- 1).addYears(+ 4);
			item.CreatedChannel = 'Branch 00' + i;
			item.Frequency = 'Monthly';
			item.Balance = 57500.00 + i;
			item.SavingAccountBundling = '123456789' + i;

			string v2 = item.MarkedSavingAccountBundling;
            string v3 = item.convertedSinceDate;
			AutoInvestmentPlans.add(item);
		}
	}

	@isTest private static void coverageViewModel() {

		InvestmentProductDetailCtrl.ViewState viewStage = new InvestmentProductDetailCtrl.ViewState();
		viewStage.OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();


		// assign value
		viewStage.InvestmentProductDetails = dto;
		viewStage.TransformDataInvestment();
		//Assert Happy case
		System.assertEquals(4000, viewStage.InvestmentProductDetails.InvestmentInformation.MarketValue);

		viewStage.InvestmentProductDetails = new InvestmentProductDetailsDTO();
		viewStage.TransformDataInvestment();

	}

	@isTest private static void coverageSOAPController() {
		/*--------------------------------------------------
		  Arrang Value
		 *----------------------------------------------------*/
		//Set View 
		PageReference pageRef = Page.InvestmentProductDetailView;
		Test.setCurrentPage(pageRef);
		// Page param
		string unitHolderNo = '111643000068';
		string fundCode = 'iv002';
		string p = UrlHelper.encryptParams(unitHolderNo + '&' + fundCode);
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('p', p);
		// Instantiate a new controller with all parameters in the page
		InvestmentProductDetailCtrl ctrl = new InvestmentProductDetailCtrl();

		Test.startTest();
		//Test Async Call Out
		Continuation conti = (Continuation) ctrl.startRequest();
		// Verify that the continuation has the proper requests
		Map<String, HttpRequest> requests = conti.getRequests();
		system.assert(requests.size() == 1);

		HttpResponse response = new HttpResponse();
		response.setBody(
		                 '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">                                         '
		                 + '   <soap:Body>                                                                                                 '
		                 + '      <ns2:getInvestmentProductDetailsResponse xmlns:ns2="http://www.tmbbank.com/InvestmentProductDetails/">   '
		                 + '         <Result>                                                                                              '
		                 + '            <Status>SUCCESS</Status>                                                                           '
		                 + '            <Message/>                                                                                         '
            			 + '			<InvestmentInformation>																				'
            			 + '			</InvestmentInformation>																			'
		                 + '            <InvestmentTransaction>                                                                            '
		                 + '               <Status>SUCCESS</Status>                                                                        '
		                 + '               <Message/>                                                                                      '
		                 + '               <InvestmentTransaction>                                                                         '
		                 + '                  <TransactionDate>2015-03-11+07:00</TransactionDate>                                          '
		                 + '                  <SettlementDate>2015-03-11+07:00</SettlementDate>                                            '
		                 + '                  <TransactionType>BUY</TransactionType>                                                       '
		                 + '                  <InteractChannel>Branch</InteractChannel>                                                    '
		                 + '                  <UnitMovement>26003.0683</UnitMovement>                                                      '
		                 + '                  <UnitOutstanding>26003.0683</UnitOutstanding>                                                '
		                 + '                  <TransactionValue>400000</TransactionValue>                                                  '
		                 + '                  <ValuePerUnit>15.3828</ValuePerUnit>                                                         '
		                 + '               </InvestmentTransaction>                                                                        '
		                 + '               <InvestmentTransaction>                                                                         '
		                 + '                  <TransactionDate>2015-02-09+07:00</TransactionDate>                                          '
		                 + '                  <SettlementDate>2015-02-09+07:00</SettlementDate>                                            '
		                 + '                  <TransactionType>SELL</TransactionType>                                                      '
		                 + '                  <InteractChannel>Branch</InteractChannel>                                                    '
		                 + '                  <UnitMovement>27485.1737</UnitMovement>                                                      '
		                 + '                  <UnitOutstanding>0</UnitOutstanding>                                                         '
		                 + '                  <TransactionValue>402734.75</TransactionValue>                                               '
		                 + '                  <ValuePerUnit>14.6528</ValuePerUnit>                                                         '
		                 + '               </InvestmentTransaction>                                                                        '
		                 + '               <InvestmentTransaction>                                                                         '
		                 + '                  <TransactionDate>2015-01-19+07:00</TransactionDate>                                          '
		                 + '                  <SettlementDate>2015-01-19+07:00</SettlementDate>                                            '
		                 + '                  <TransactionType>BUY</TransactionType>                                                       '
		                 + '                  <InteractChannel>Branch</InteractChannel>                                                    '
		                 + '                  <UnitMovement>13310.5279</UnitMovement>                                                      '
		                 + '                  <UnitOutstanding>27485.1737</UnitOutstanding>                                                '
		                 + '                  <TransactionValue>200000</TransactionValue>                                                  '
		                 + '                  <ValuePerUnit>15.0257</ValuePerUnit>                                                         '
		                 + '               </InvestmentTransaction>                                                                        '
		                 + '            </InvestmentTransaction>                                                                           '
            			 + '			<AutoInvestmentPlan>																				'
            			 + '				<AutoInvestmentPlan>																			'
            			 + '				</AutoInvestmentPlan>																			'
            			 + '			</AutoInvestmentPlan>																				'
		                 + '         </Result>                                                                                             '
		                 + '      </ns2:getInvestmentProductDetailsResponse>                                                               '
		                 + '   </soap:Body>                                                                                                '
		                 + '</soap:Envelope>                                                                                               '
		);
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
		PageReference pageRef = Page.InvestmentProductDetailView;
		Test.setCurrentPage(pageRef);
		// Page param
		string unitHolderNo = '111643000068';
		string fundCode = 'iv002';
		string p = UrlHelper.encryptParams(unitHolderNo + '&' + fundCode);
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('p', p);
		// Instantiate a new controller with all parameters in the page
		InvestmentProductDetailCtrl ctrl = new InvestmentProductDetailCtrl();

		Test.startTest();
		//Test Async Call Out
		Continuation conti = (Continuation) ctrl.startRequest();
		// Verify that the continuation has the proper requests
		Map<String, HttpRequest> requests = conti.getRequests();
		system.assert(requests.size() == 1);

		HttpResponse response = new HttpResponse();
		response.setBody(
		                 '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">                                         '
		                 + '   <soap:Body>                                                                                                 '
		                 + '      <ns2:getInvestmentProductDetailsResponse xmlns:ns2="http://www.tmbbank.com/InvestmentProductDetails/">   '
		                 + '         <Result>                                                                                              '
		                 + '            <Status>SUCCESS</Status>                                                                           '
		                 + '            <Message/>                                                                                         '
		                 + '            <InvestmentTransaction>                                                                            '
		                 + '               <Status>SUCCESS</Status>                                                                        '
		                 + '               <Message/>                                                                                      '
		                 + '               <InvestmentTransaction>                                                                         '
		                 + '                  <TransactionDate>2015-03-11+07:00</TransactionDate>                                          '
		                 + '                  <SettlementDate>2015-03-11+07:00</SettlementDate>                                            '
		                 + '                  <TransactionType>BUY</TransactionType>                                                       '
		                 + '                  <InteractChannel>Branch</InteractChannel>                                                    '
		                 + '                  <UnitMovement>26003.0683</UnitMovement>                                                      '
		                 + '                  <UnitOutstanding>26003.0683</UnitOutstanding>                                                '
		                 + '                  <TransactionValue>400000</TransactionValue>                                                  '
		                 + '                  <ValuePerUnit>15.3828</ValuePerUnit>                                                         '
		                 + '               </InvestmentTransaction>                                                                        '
		                 + '               <InvestmentTransaction>                                                                         '
		                 + '                  <TransactionDate>2015-02-09+07:00</TransactionDate>                                          '
		                 + '                  <SettlementDate>2015-02-09+07:00</SettlementDate>                                            '
		                 + '                  <TransactionType>SELL</TransactionType>                                                      '
		                 + '                  <InteractChannel>Branch</InteractChannel>                                                    '
		                 + '                  <UnitMovement>27485.1737</UnitMovement>                                                      '
		                 + '                  <UnitOutstanding>0</UnitOutstanding>                                                         '
		                 + '                  <TransactionValue>402734.75</TransactionValue>                                               '
		                 + '                  <ValuePerUnit>14.6528</ValuePerUnit>                                                         '
		                 + '               </InvestmentTransaction>                                                                        '
		                 + '               <InvestmentTransaction>                                                                         '
		                 + '                  <TransactionDate>2015-01-19+07:00</TransactionDate>                                          '
		                 + '                  <SettlementDate>2015-01-19+07:00</SettlementDate>                                            '
		                 + '                  <TransactionType>BUY</TransactionType>                                                       '
		                 + '                  <InteractChannel>Branch</InteractChannel>                                                    '
		                 + '                  <UnitMovement>13310.5279</UnitMovement>                                                      '
		                 + '                  <UnitOutstanding>27485.1737</UnitOutstanding>                                                '
		                 + '                  <TransactionValue>200000</TransactionValue>                                                  '
		                 + '                  <ValuePerUnit>15.0257</ValuePerUnit>                                                         '
		                 + '               </InvestmentTransaction>                                                                        '
		                 + '            </InvestmentTransaction>                                                                           '
		                 + '         </Result>                                                                                             '
		                 + '      </ns2:getInvestmentProductDetailsResponse>                                                               '
		                 + '   </soap:Body>                                                                                                '
		                 + '</soap:Envelope>                                                                                               '
		);
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
		PageReference pageRef = Page.InvestmentProductDetailView;
		Test.setCurrentPage(pageRef);
		// Page param
		string unitHolderNo = '111643000068';
		string fundCode = 'iv002';
		string p = UrlHelper.encryptParams(unitHolderNo + '&' + fundCode);
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('p', p);
		// Instantiate a new controller with all parameters in the page
		InvestmentProductDetailCtrl ctrl = new InvestmentProductDetailCtrl();

		Test.startTest();
		//Test Async Call Out
		Continuation conti = (Continuation) ctrl.startRequest();
		// Verify that the continuation has the proper requests
		Map<String, HttpRequest> requests = conti.getRequests();
		system.assert(requests.size() == 1);

		HttpResponse response = new HttpResponse();
		response.setBody(
		                 '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">                                         '
		                 + '   <soap:Body>                                                                                                 '

		                 + '   </soap:Body>                                                                                                '
		                 + '</soap:Envelope>                                                                                               '
		);
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