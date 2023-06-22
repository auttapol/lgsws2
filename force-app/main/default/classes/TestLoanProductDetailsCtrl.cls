@isTest
private class TestLoanProductDetailsCtrl {
	private static List<sObject> ls;
	private static LoanProductDetailDTO dto;

	static {
		//Load test data from resource
		ls = Test.loadData(Product2.sObjectType, 'RTLProductMaster');
		createMock();
	}

	private static void createMock() {
		dto = new LoanProductDetailDTO();
		dto.LoanAccountNumber = '1876768991';
		dto.LoanProductCode = 'DTHO';
		dto.ProductName = '';
		dto.SubProductGroup = '';
		dto.TenorMonth = 5;
		dto.AccountStatus = 'Normal (i.e mormal,30DPD,60DPD,90DPD,W/O)';
		dto.CreditLimit = 1500000.50;
		dto.Outstanding = 1500000.50;
		dto.OpenDate = Date.today().addDays(- 1).addYears(- 2);
		dto.ContractEndDate = Date.today().addDays(1);
		dto.PaymentDueDate = Date.today().addDays(1);
		dto.OtherConditions = 'Free Text';
		dto.CampaignName = 'N';
		dto.LastPaymentDate = Date.today().addDays(1);
		dto.RetentionDate = Date.today().addDays(1);
		dto.CurrentTenor = 0;
        
        string v1 = dto.convertedContractEndDate;
        string v2 = dto.convertedLastPaymentDate;
        string v3 = dto.convertedOpenedDate;
        string v4 = dto.convertedPaymentDueDate;
        string v5 = dto.convertedRetentionDate;
        string v6 = dto.MarkOutstanding;
        string v7 = dto.MarkCreditLimit;

		//CoBorrower 
		List<CoBorrowerDTO> CoBorrowers = new List<CoBorrowerDTO> ();
		dto.CoBorroweres = CoBorrowers;
		for (Integer i = 1; i <= 4; i++)
		{
			CoBorrowerDTO item = new CoBorrowerDTO();
			item.CoBorrowerName = 'Test' + i;
			item.CoBorrowerRelationship = 'Mother' + i;
			CoBorrowers.add(item);
		}

		//Related Insurance
		RelatedInsuranceDTO relatedInsurance = new RelatedInsuranceDTO();
		relatedInsurance.PolicyNumber = '3746363';
		relatedInsurance.Insurance = 'MRTA';
		relatedInsurance.StartDate = Date.today().addDays(- 150);
		relatedInsurance.Insurer = 'FWD';
		relatedInsurance.EndDate = Date.today().addDays(- 150);
		relatedInsurance.SumInsured = 2000000.00;
        string p1 = relatedInsurance.convertedStartDate;
        string p2 = relatedInsurance.convertedEndDate;
		dto.RelatedInsurance = relatedInsurance;

		LoanPaymentDTO loanPayment = new LoanPaymentDTO();
		loanPayment.PaymentMethod = 'Direct debit(i.e Payroll dedu)';
		loanPayment.PayrollDeductionUnit = 1;
		loanPayment.SavingAccount = '1111111111';
		loanPayment.InstallmentBalance = 45000.00;
		dto.LoanPayment = loanPayment;

		List<InterestPlanDTO> InterestPlans = new List<InterestPlanDTO> ();
		dto.InterestPlans = InterestPlans;
		for (Integer i = 1; i <= 5; i++)
		{
			InterestPlanDTO item = new InterestPlanDTO();
			item.Period = i * 5;
			item.InterestRate = i * 5;
			InterestPlans.add(item);
		}
	}
	@isTest private static void coverageViewModel() {
		LoanProductDetailsCtrl.ViewState viewstage = new LoanProductDetailsCtrl.ViewState();
		viewstage.OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
        string LoanAccountNumber = '1234567890';
        string ProjectCode = '';
        string DataSource = '';
		// assign value
		viewstage.LoanProductDetail = dto;
		viewstage.TransformDataDeposit(LoanAccountNumber,ProjectCode,DataSource);

		//Assert		
		System.assertEquals(1500000.50, viewstage.LoanProductDetail.CreditLimit);
	}
	@isTest private static void coverageSOAPController() {
		//Set View 
		PageReference pageRef = Page.LoanProductDetailView;
		Test.setCurrentPage(pageRef);

		string loanacctno = '00016080681007'; // Mock Accouont Id
		string prdtype = 'com.fnf.xes.AM';
        string fiident = '1';
        string status = 'ACTIVE';
        string projectcode = '75';
        string datasource = '14';
		string p = UrlHelper.encryptParams(loanacctno + '&' + prdtype+'&'+fiident+'&'+status+'&'+projectcode+'&'+datasource);
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('p', p);

		// Instantiate a new controller with all parameters in the page
		LoanProductDetailsCtrl ctrl = new LoanProductDetailsCtrl();
		Test.startTest();
		//Test Async Call Out
		Continuation conti = (Continuation) ctrl.startRequest();
		// Verify that the continuation has the proper requests
		Map<String, HttpRequest> requests = conti.getRequests();
		system.assert(requests.size() == 1);

		HttpResponse response = new HttpResponse();
		response.setBody(
		                 ' <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">                             '
		                 + '    <soap:Body>                                                                                     '
		                 + '       <ns2:getLoanProductDetailsResponse xmlns:ns2="http://www.tmbbank.com/LoanProductDetails/">   '
		                 + '          <Result>                                                                                  '
		                 + '             <Status>ERROR</Status>                                                               '
		                 + '             <Message>Message</Message>                                                                             '
		                 + '             <LoanInformation>                                                                      '
		                 + '                <Status>SUCCESS</Status>                                                            '
		                 + '                <Message/>                                                                          '
		                 + '                <AccountNumber>001100010001000000016080681007</AccountNumber>                       '
		                 + '                <ProductCode>DTHO</ProductCode>                           '
		                 + '                <AccountStatus>Active</AccountStatus>                                               '
		                 + '                <CreditLimit>260000.00</CreditLimit>                                                '
		                 + '                <Outstanding>4571.95</Outstanding>                                                  '
		                 + '                <OpenDate>2010-09-07+07:00</OpenDate>                                               '
		                 + '                <PaymentDueDate>9999-12-31+07:00</PaymentDueDate>                                   '
		                 + '             </LoanInformation>                                                                     '
		                 + '             <LoanPaymentInformation>                                                               '
		                 + '                <Status>SUCCESS</Status>                                                            '
		                 + '                <Message/>                                                                          '
		                 + '                <LoanPayment>                                                                       '
		                 + '                   <InstallmentBalance>0.00</InstallmentBalance>                                    '
		                 + '                </LoanPayment>                                                                      '
		                 + '             </LoanPaymentInformation>                                                              '
		                 + '			<CoBorrowerInformation>																	'
            			 + '				<CoBorrower>																		'
						 + '				</CoBorrower>																		'
            			 + '			</CoBorrowerInformation>																'
            			 + '			<InterestPlan>																			'
            			 + '				<InterestPlan>																			'
            			 + ' 				</InterestPlan>																			'
            			 + '			</InterestPlan>																			'
            			 + '			<RelatedInsuranceInformation>															'
            			 + '				<RelatedInsurance>																	'
            			 + '				</RelatedInsurance>																	'
            			 + '			</RelatedInsuranceInformation>															'
            			 + '          </Result>                                                                                 '
		                 + '       </ns2:getLoanProductDetailsResponse>                                                         '
		                 + '    </soap:Body>                                                                                    '
		                 + ' </soap:Envelope>                                                                                   '
		);
		// Set the fake response for the continuation
		String requestLabel = requests.keyset().iterator().next();
		Test.setContinuationResponse(requestLabel, response);

		// Invoke callback method
		Object result = Test.invokeContinuationMethod(ctrl, conti);
		test.stopTest();
		System.debug(ctrl);
		Object result1 = ctrl.processResponseSOAP();
		// result is the return value of the callback
		System.assertEquals(null, result);


		string v1 = ctrl.ViewState.LoanProductDetail.MakeLoanAccountNumber;
	}
    
    @isTest private static void coverageSOAPControllerNeg() {
		//Set View 
		PageReference pageRef = Page.LoanProductDetailView;
		Test.setCurrentPage(pageRef);

		string loanacctno = '00016080681007'; // Mock Accouont Id
		string prdtype = 'com.fnf.xes.AM';
        string projectcode = '75';
        string datasource = '14';
		string p = UrlHelper.encryptParams(loanacctno + '&' + prdtype+'&'+projectcode+'&'+datasource);
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('p', p);

		// Instantiate a new controller with all parameters in the page
		LoanProductDetailsCtrl ctrl = new LoanProductDetailsCtrl();
		Test.startTest();
		//Test Async Call Out
		Continuation conti = (Continuation) ctrl.startRequest();
		// Verify that the continuation has the proper requests
		Map<String, HttpRequest> requests = conti.getRequests();
		system.assert(requests.size() == 1);

		HttpResponse response = new HttpResponse();
		response.setBody(
		                 ' <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">                             '
		                 + '    <soap:Body>                                                                                     '
		                 + '       <ns2:getLoanProductDetailsResponse xmlns:ns2="http://www.tmbbank.com/LoanProductDetails/">   '
		                 + '          <Result>                                                                                  '
		                 + '             <Status>SUCCESS</Status>                                                               '
		                 + '             <Message>Message</Message>                                                                             '
		                 + '             <LoanInformation>                                                                      '
		                 + '                <Status>SUCCESS</Status>                                                            '
		                 + '                <Message/>                                                                          '
		                 + '                <AccountNumber>001100010001000000016080681007</AccountNumber>                       '
		                 + '                <ProductCode>001100010001000000016080681007</ProductCode>                           '
		                 + '                <AccountStatus>Active</AccountStatus>                                               '
		                 + '                <CreditLimit>260000.00</CreditLimit>                                                '
		                 + '                <Outstanding>4571.95</Outstanding>                                                  '
		                 + '                <OpenDate>2010-09-07+07:00</OpenDate>                                               '
		                 + '                <PaymentDueDate>9999-12-31+07:00</PaymentDueDate>                                   '
		                 + '             </LoanInformation>                                                                     '
		                 + '             <LoanPaymentInformation>                                                               '
		                 + '                <Status>SUCCESS</Status>                                                            '
		                 + '                <Message/>                                                                          '
		                 + '                <LoanPayment>                                                                       '
		                 + '                   <InstallmentBalance>0.00</InstallmentBalance>                                    '
		                 + '                </LoanPayment>                                                                      '
		                 + '             </LoanPaymentInformation>                                                              '
		                 + '          </Result>                                                                                 '
		                 + '       </ns2:getLoanProductDetailsResponse>                                                         '
		                 + '    </soap:Body>                                                                                    '
		                 + ' </soap:Envelope>                                                                                   '
		);
		// Set the fake response for the continuation
		String requestLabel = requests.keyset().iterator().next();
		Test.setContinuationResponse(requestLabel, response);

		// Invoke callback method
		Object result = Test.invokeContinuationMethod(ctrl, conti);
		test.stopTest();
		System.debug(ctrl);
		Object result1 = ctrl.processResponseSOAP();
		// result is the return value of the callback
		System.assertEquals(null, result);


		string v1 = ctrl.ViewState.LoanProductDetail.MakeLoanAccountNumber;
        string v2 = ctrl.ViewState.LoanProductDetail.LoanPayment.MarkedSavingAccount;
        string v3 = ctrl.ViewState.LoanProductDetail.LoanPayment.translatedPaymentMethod;
	}
    
	@isTest private static void coverageSOAPControllerException() {
		//Set View 
		PageReference pageRef = Page.LoanProductDetailView;
		Test.setCurrentPage(pageRef);

		string loanacctno = '00016080681007'; // Mock Accouont Id
		string prdtype = 'com.fnf.xes.AM';
        string Fiident = '1';
        string Status = 'ACTIVE';
		string p = UrlHelper.encryptParams(loanacctno + '&' + prdtype+'&'+Fiident+'&'+Status);
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('p', p);

		// Instantiate a new controller with all parameters in the page
		LoanProductDetailsCtrl ctrl = new LoanProductDetailsCtrl();
		Test.startTest();
		//Test Async Call Out
		Continuation conti = (Continuation) ctrl.startRequest();
		// Verify that the continuation has the proper requests
		Map<String, HttpRequest> requests = conti.getRequests();
		system.assert(requests.size() == 1);

		HttpResponse response = new HttpResponse();
		response.setBody(
		                   ' <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">                             '
		                 + '    <soap:Body>                                                                                     '		                
		                 + '    </soap:Body> '
		                 + ' </soap:Envelope>   ');
		// Set the fake response for the continuation
		String requestLabel = requests.keyset().iterator().next();
		Test.setContinuationResponse(requestLabel, response);

		// Invoke callback method
		Object result = Test.invokeContinuationMethod(ctrl, conti);
		test.stopTest();
		System.debug(ctrl);
		Object result1 = ctrl.processResponseSOAP();
		// result is the return value of the callback
		System.assertEquals(null, result);
	}
}