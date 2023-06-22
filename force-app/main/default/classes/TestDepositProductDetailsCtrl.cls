@isTest
private class TestDepositProductDetailsCtrl {
	private static List<sObject> ls;
	private static DepositeProductDetailDTO dto;
	static {
		//Load test data from resource
		ls = Test.loadData(Product2.sObjectType, 'RTLProductMaster');
		createMock();
	}
	private static void createMock() {
		dto = new DepositeProductDetailDTO();
		dto.DepositAccountNumber = '1111111111';
		dto.DepositProductCode = 'dp001';
		dto.SubProductGroup = dto.DepositProductCode;
		dto.ProductName = dto.DepositProductCode;
		dto.OpenedDate = Date.today().addDays(- 1).addYears(- 1);
		dto.Status = 'Active';
		dto.OutStanding = (1500 + 1);
		//dto.AvgOutStanding = (1060 + 1);
		dto.AvgBalanceMTD = 34503.09;
		dto.InterestEarned = (4505 + 1);
		dto.Other = 'DC/DD';
		dto.HasJoint = 'Join';
		dto.AccountName = 'Pommatt';
		dto.InterestRate = 49;
		dto.MaturityDate = Date.today().addDays(- 1).addYears(+ 2);
		dto.SMSAlertService = 'Sidebar-7 (Yes/No)';
		dto.MEAccountBundledBank = 'TMB-SCB-KBANK';
		dto.NoActiveDebitCardBundling = 130000.50;
		dto.ODLimit = 20000;
		dto.LedgerBalance = 15000;

		string v1 = dto.MarkedDepositAccountNumber;
		string v2 = dto.MarkedOutStanding;
        string v3 = dto.convertedMaturityDate;
        string v4 = dto.convertedOpenedDate;
        string v5 = dto.MarkedAvgBalanceMTD;
		decimal v6 = dto.MarkedODLimit;
		string v7 = dto.MarkedLedgerBalance;
		


		// Join Account Information 
		for (integer i = 1; i <= 4; i++) {
			JoinAccountInformationDTO item = new JoinAccountInformationDTO();
			item.JointAccountOwnerNumber = 'xxxxx' + i;
			item.Relationship = 'Sister';
			dto.JoinAccountInformations.add(item);
		}
		// Last Month Summary
		dto.LastMonthTransactionSummary.OfDeposit = 12301.99;
		dto.LastMonthTransactionSummary.OfWithdraw = 12302.99;
		dto.LastMonthTransactionSummary.OfTransferOutTMB = 12303.99;
		dto.LastMonthTransactionSummary.OfTransferOutOther = 12304.99;
		dto.LastMonthTransactionSummary.OfBillPayment = 12305.99;
		//Beneficiary Information 
		BeneficiaryInformationDTO ben1 = new BeneficiaryInformationDTO();
		ben1.BeneficiaryName = 'Tommy Huck1';
		ben1.BenefitPercent = 40;
		ben1.Relationship = 'Brother';

		BeneficiaryInformationDTO ben2 = new BeneficiaryInformationDTO();
		ben2.BeneficiaryName = 'Tommy Huck2';
		ben2.BenefitPercent = 40;
		ben2.Relationship = 'Brother';

		BeneficiaryInformationDTO ben3 = new BeneficiaryInformationDTO();
		ben3.BeneficiaryName = 'Tommy Huck3';
		ben3.BenefitPercent = 20;
		ben3.Relationship = 'Brother';

		dto.BeneficiaryInformations.add(ben1);
		dto.BeneficiaryInformations.add(ben2);
		dto.BeneficiaryInformations.add(ben3);
		//Standing Order 
		for (integer i = 1; i <= 10; i++) {
			StandingOrderDTO item = new StandingOrderDTO();
			item.RequestDate = Date.today().addDays(i).addYears(- i);
			item.Frequency = 4 + (i * 2);
			item.SettlementDate = Date.today().addDays(i).addYears(- i);
			item.Type = 'BA Payment';
			item.LastAmount = 300 + (8 * i);
			item.LastTrxDate = Date.today().addDays(i).addYears(- i);
            string p1 = item.convertedRequestDate;
            string p2 = item.convertedSettleDate;
            string p3 = item.convertedLastTrxDate;
			dto.StandingOrders.add(item);
		}
	}
	@isTest private static void coverageViewModel() {
		DepositProductDetailsCtrl.ViewState viewstage = new DepositProductDetailsCtrl.ViewState();
		viewstage.OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
		string DepositAccountNumber = '1234567890';
        string ProjectCode = '74';
        string DataSource = '11';
        
        // assign value
		viewstage.DepositeProductDetail = dto;
		viewstage.TransformDataDeposit(DepositAccountNumber,ProjectCode,DataSource);
		

		//Assert Happy case
		System.assertEquals(34503.09, viewstage.DepositeProductDetail.AvgBalanceMTD);
		//Assert UnHappy case
		viewstage.DepositeProductDetail = new DepositeProductDetailDTO();
		viewstage.TransformDataDeposit(DepositAccountNumber,ProjectCode,DataSource);
		System.assertEquals(null, viewstage.DepositeProductDetail.AvgBalanceMTD);
	}
	@isTest private static void coverageSOAPController() {
		/*--------------------------------------------------
		  Arrang Value
		 *----------------------------------------------------*/
		//Set View 
		PageReference pageRef = Page.DepositProductDetailsView;
		Test.setCurrentPage(pageRef);
		// Page param
		string DepositAccountNumber = '1234567890';
		string ProductType = 'AEC';
        string ProjectCode = '74';
        string DataSource = '11';
        string Fiident = '1';
		string p = UrlHelper.encryptParams(DepositAccountNumber + '&' + ProductType+'&'+Fiident+'&'+ProjectCode+'&'+DataSource);
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('p', p);
		// Instantiate a new controller with all parameters in the page
		DepositProductDetailsCtrl ctrl = new DepositProductDetailsCtrl();
		ctrl.SVR_MODE = 'soap';
		ctrl.getRMID();
		Test.startTest();
		//Test Async Call Out
		Continuation conti = (Continuation) ctrl.startRequest();
		// Verify that the continuation has the proper requests
		Map<String, HttpRequest> requests = conti.getRequests();
		system.assert(requests.size() == 1);

		HttpResponse response = new HttpResponse();
		response.setBody(' <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">                                  '
		                 + '    <soap:Body>                                                                                        '
		                 + '       <ns2:getProductDetailsResponse xmlns:ns2="http://www.tmbbank.com/DepositProductDetails/">       '
		                 + '          <Result>                                                                                     '
		                 + '             <Status>SUCCESS</Status>                                                                  '
		                 + '             <Message/>                                                                                '
		                 + '             <DepositAccount>                                                                          '
		                 + '                <Status>SUCCESS</Status>                                                               '
		                 + '                <Message/>                                                                             '
		                 + '                <AccountNumber>00110001024700002471779484</AccountNumber>                              '
		                 + '                <AccountName>??? ???????? ?????????? ? ?????????</AccountName>                              '
		                 + '                <ProductCode>IM101</ProductCode>                                                       '
		                 + '                <OpenedDate>2013-01-17+07:00</OpenedDate>                                              '
		                 + '                <AccountStatus>Active | ???? (Active)</AccountStatus>                                   '
		                 + '                <InterestRate>0.000000</InterestRate>                                                  '
		                 + '             </DepositAccount>                                                                         '
                         + '			 <JointAccount>																				'
                         + '			 <Status>SUCCESS</Status>																				'
                         + '			 <Message/>																				'
                         + '			 <JointAccount>																				'
                         + '			 <OwnerNumber></OwnerNumber><Relationship></Relationship>																				'   
                         + '			 </JointAccount>																				'
                         + '			 </JointAccount>																				'
                         + '			 <LastMonthTransactionSummary>																				'
                         + '			 <Status>SUCCESS</Status>																			'
                         + '			 <Message/>																				'
                         + '			 </LastMonthTransactionSummary>																				'
                         + '			 <Beneficiary>																				'
                         + '			 <Status>SUCCESS</Status>																				'
                         + '			 <Message/>																				'
		                 + '			 <Beneficiary></Beneficiary>'
                         + '           </Beneficiary>                                                                                   '
                         + '			<StandingOrder>' 
                         + '			<StandingOrder></StandingOrder>'
                         + '			</StandingOrder>'
                         + '          </Result>                                                                                    '
		                 + '       </ns2:getProductDetailsResponse>                                                                '
		                 + '    </soap:Body>                                                                                       '
		                 + ' </soap:Envelope>                                                                                      '

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
		PageReference pageRef = Page.DepositProductDetailsView;
		Test.setCurrentPage(pageRef);
		// Page param
		string DepositAccountNumber = '1234567890';
		string ProductType = 'AEC';
        string ProjectCode = '74';
        string DataSource = '11';
        string Fiident = '1';
		string p = UrlHelper.encryptParams(DepositAccountNumber + '&' + ProductType+'&'+Fiident+'&'+ProjectCode+'&'+DataSource);
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('p', p);
		// Instantiate a new controller with all parameters in the page
		DepositProductDetailsCtrl ctrl = new DepositProductDetailsCtrl();
		ctrl.SVR_MODE = 'soap';
		ctrl.getRMID();
		Test.startTest();
		//Test Async Call Out
		Continuation conti = (Continuation) ctrl.startRequest();
		// Verify that the continuation has the proper requests
		Map<String, HttpRequest> requests = conti.getRequests();
		system.assert(requests.size() == 1);

		HttpResponse response = new HttpResponse();
		response.setBody(' <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">                                  '
		                 + '    <soap:Body>                                                                                        '
		                 + '       <ns2:getProductDetailsResponse xmlns:ns2="http://www.tmbbank.com/DepositProductDetails/">       '
		                 + '          <Result>                                                                                     '
		                 + '             <Status>SUCCESS</Status>                                                                  '
		                 + '             <Message/>                                                                                '
		                 + '             <DepositAccount>                                                                          '
		                 + '                <Status>SUCCESS</Status>                                                               '
		                 + '                <Message/>                                                                             '
		                 + '                <AccountNumber>00110001024700002471779484</AccountNumber>                              '
		                 + '                <AccountName>??? ???????? ?????????? ? ?????????</AccountName>                              '
		                 + '                <ProductCode>IM101</ProductCode>                                                       '
		                 + '                <OpenedDate>2013-01-17+07:00</OpenedDate>                                              '
		                 + '                <AccountStatus>Active | ???? (Active)</AccountStatus>                                   '
		                 + '                <InterestRate>0.000000</InterestRate>                                                  '
		                 + '             </DepositAccount>                                                                         '
		                  + '			 <JointAccount>																				'
                         + '			 <Status>SUCCESS</Status>																				'
                         + '			 <Message/>																				'
                         + '			 </JointAccount>																				'
                         + '			 <LastMonthTransactionSummary>																				'
                         + '			 <Status>SUCCESS</Status>																			'
                         + '			 <Message/>																				'
                         + '			 </LastMonthTransactionSummary>																				'
                         + '			 <Beneficiary>																				'
                         + '			 <Status>SUCCESS</Status>																				'
                         + '			 <Message/>																					'		
                         + '           </Beneficiary>                                                                                   '
                         + '			<StandingOrder>' 
                         + '			</StandingOrder>'
                         + '          </Result>                                                                                    '
		                 + '       </ns2:getProductDetailsResponse>                                                                '
		                 + '    </soap:Body>                                                                                       '
		                 + ' </soap:Envelope>                                                                                      '
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
		PageReference pageRef = Page.DepositProductDetailsView;
		Test.setCurrentPage(pageRef);
		// Page param
		string DepositAccountNumber = '1234567890';
		string ProductType = 'AEC';
        string ProjectCode = '74';
        string DataSource = '11';
        string Fiident = '1';
		string p = UrlHelper.encryptParams(DepositAccountNumber + '&' + ProductType+'&'+Fiident+'&'+ProjectCode+'&'+DataSource);
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('p', p);
		// Instantiate a new controller with all parameters in the page
		DepositProductDetailsCtrl ctrl = new DepositProductDetailsCtrl();
		ctrl.SVR_MODE = 'soap';
		ctrl.getRMID();
		Test.startTest();
		ctrl.processResponseSOAP();
		// result is the return value of the callback
		Test.stopTest();
		System.assertNotEquals(null, ctrl.PageMessage);

	}
}