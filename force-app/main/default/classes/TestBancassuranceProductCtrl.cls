@isTest
private class TestBancassuranceProductCtrl {
	private static List<sObject> ls;
	private static BancassuranceInformationDTO dto;

	static {
		//Load test data from resource
		ls = Test.loadData(Product2.sObjectType, 'RTLProductMaster');
		createMock();
	}
	private static void createMock() {
		dto = new BancassuranceInformationDTO();
		dto.SoapMessage = '';
		dto.SoapStatus = '';
		dto.PolicyNo = '1234567890';
		dto.ProductCode = 'USHY-A';
        dto.ProductGroup = 'BA';
		dto.EffectiveDate = Date.today().addDays(1);
		dto.SumInsured = 300000;
		dto.ExpiryDate = Date.today().addYears(1);
		dto.AFYP = 400000;
		dto.PolicyStatus = 'Active-Inforce';
		dto.Sales = 'Pommatt';
		dto.BancassuranceDetail.InsuranceCompany = 'FWD';
		dto.BancassuranceDetail.SoapMessage = '';
		dto.BancassuranceDetail.SoapStatus = 'TRUE';
		dto.PaymentInformation.PaymentMode = 'Monthly (Feild: "PAYMENT_FREQ")';
		dto.PaymentInformation.PremiumAmount = 400000;
		dto.PaymentInformation.PaymentMethod = 'Credit card';
		dto.PaymentInformation.TotalPremiumPaid = 1250000;
		dto.PaymentInformation.LastPaymentDate = Date.today().addYears(- 30);
		dto.PaymentInformation.YearOfPayment = '4/8/16';
		dto.PaymentInformation.NextDueDate = Date.today().addYears(- 50);
		dto.PaymentInformation.NumberOfTimePremiumPaid = 2;
		dto.PaymentInformation.SoapMessage = '';
		dto.PaymentInformation.SoapStatus = 'TRUE';
		dto.NextCashBackInformationzmation.PaymentDate = Date.today().addYears(- 2);
		dto.NextCashBackInformationzmation.Amount = 5000.00;
		dto.NextCashBackInformationzmation.TotalPaid = 5000.00;
		dto.NextCashBackInformationzmation.SoapMessage = '';
		dto.NextCashBackInformationzmation.SoapStatus = 'TRUE';
		dto.InsuredPropertyAsset.Address = 'Address , Stress , District ,Amphur ,Province , Postcode';
		dto.InsuredPropertyAsset.SoapMessage = '';
		dto.InsuredPropertyAsset.SoapStatus = 'TRUE';
		dto.InsuredAutomobileAsset.Brand = 'CAR BRAND';
		dto.InsuredAutomobileAsset.YearOfManufactured = 'YEAR';
		dto.InsuredAutomobileAsset.Model = 'Model';
		dto.InsuredAutomobileAsset.PlateNumber = 'CAR PLATE NO';
		dto.InsuredAutomobileAsset.SoapMessage = '';
		dto.InsuredAutomobileAsset.SoapStatus = 'TRUE';
        string v1 = dto.convertedEffectiveDate;
        string v2 = dto.convertedExpiryDate;
        string v3 = dto.NextCashBackInformationzmation.convertedPaymentDate;
        string v4 = dto.PaymentInformation.convertedNextDueDate;
        string v5 = dto.PaymentInformation.convertedLastPaymentDate;
		List<BeneficiaryInformationDTO> BeneficiaryInformations = new List<BeneficiaryInformationDTO> ();
		dto.BeneficiaryInformations = BeneficiaryInformations;
		for (Integer i = 1; i < 4; i++)
		{
			BeneficiaryInformationDTO item = new BeneficiaryInformationDTO();
			item.BeneficiaryName = 'Name' + i;
			item.Relationship = 'Relationship' + i;
			item.BenefitPercent = (i * 5);
			BeneficiaryInformations.add(item);
		}
		List<InsuranceClaimRecordDTO> InsuranceClaimRecords = new List<InsuranceClaimRecordDTO> ();
		dto.InsuranceClaimRecords = InsuranceClaimRecords;

		for (Integer i = 1; i < 4; i++) {
			InsuranceClaimRecordDTO item = new InsuranceClaimRecordDTO();
			item.Date_x = Date.today().addYears(i * 3);
			item.Type_x = 'Medical ' + i;
			item.Description = 'Car accident ' + i;
			item.RequestAmount = 15000 * i;
			item.ApprovedAmount = 15000 * i;
			item.SoapMessage ='';
			item.SoapStatus = '';


			InsuranceClaimRecords.add(item);
            string v6 = item.convertedDate_x;
		}
        BA_Insurance_Company__c ba = new BA_Insurance_Company__c();
        ba.Name = 'BA Company';
        insert ba;

	}
	@isTest private static void coverageViewModel() {

		BAInsuranceCompanyService.setMockservice(new BAInsuranceCompanyServiceImplMock());
		BancassuranceProductCtrl.ViewState viewstage = new BancassuranceProductCtrl.ViewState();
		viewstage.OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
		// assign value
		viewstage.BancassuranceInformation = dto;
		viewstage.TransformDataBancassurance();
		viewstage.InvokeFindInsuranceCompany();
		//Assert		
		System.assertEquals(300000, viewstage.BancassuranceInformation.SumInsured);

		// assign value
		viewstage.BancassuranceInformation = new BancassuranceInformationDTO();
		viewstage.TransformDataBancassurance();
		viewstage.InvokeFindInsuranceCompany();
	}
	@isTest private static void coverageSOAPController() {
		//Set View 
		PageReference pageRef = Page.BancassuranceProductView;
		Test.setCurrentPage(pageRef);

		string policyno = '111111111111'; // Mock Accouont Id	
		string p = UrlHelper.encryptParams(policyno);
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('p', p);

		// Instantiate a new controller with all parameters in the page
		BancassuranceProductCtrl ctrl = new BancassuranceProductCtrl();
		Test.startTest();
		//Test Async Call Out
		Continuation conti = (Continuation) ctrl.startRequest();
		// Verify that the continuation has the proper requests
		Map<String, HttpRequest> requests = conti.getRequests();
		system.assert(requests.size() == 1);

		HttpResponse response = new HttpResponse();
		response.setBody(
		                 '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">                                                              '
		                 + '   <soap:Body>                                                                                                                     '
		                 + '      <ns2:getBancassuranceProductDetailsResponse xmlns:ns2="http://www.tmbbank.com/BancassuranceProductDetails/">                 '
		                 + '         <Result>                                                                                                                  '
		                 + '            <Status>ERROR</Status>                                                                                               '
		                 + '            <Message/>                                                                                                             '
		                 + '            <BancassuranceInformation>                                                                                             '
		                 + '               <Status>SUCCESS</Status>                                                                                            '
		                 + '               <Message/>                                                                                                          '
		                 + '               <ProductType>LIFE INSURANCE</ProductType>                                                                           '
		                 + '               <ProductName>TMB Smart Life 10/7</ProductName>                                                                      '
		                 + '               <EffectiveDate>2015-08-25+07:00</EffectiveDate>                                                                     '
		                 + '               <PolicyStatus>Active</PolicyStatus>                                                                                 '
		                 + '               <SumInsured>100000.00</SumInsured>                                                                                  '
		                 + '               <ExpiryDate>2025-08-25+07:00</ExpiryDate>                                                                           '
		                 + '            </BancassuranceInformation>                                                                                            '
		                 + '            <BancassuranceDetails>                                                                                                 '
		                 + '               <Status>SUCCESS</Status>                                                                                            '
		                 + '               <Message/>                                                                                                          '
		                 + '               <InsuranceCompany>FWD Life Insurance</InsuranceCompany>                                                             '
		                 + '            </BancassuranceDetails>                                                                                                '
		                 + '            <PaymentInformation>                                                                                                   '
		                 + '               <Status>SUCCESS</Status>                                                                                            '
		                 + '               <Message/>                                                                                                          '
		                 + '               <PaymentMode>Annual</PaymentMode>                                                                                   '
		                 + '               <PremiumAmount>0</PremiumAmount>                                                                                    '
		                 + '               <YearOfPayment>0001 of 7</YearOfPayment>                                                                            '
		                 + '               <NextDueDate>2016-08-25+07:00</NextDueDate>                                                                         '
		                 + '            </PaymentInformation>                                                                                                  '
		                 + '            <NextCashBackInformation>                                                                                              '
		                 + '               <Status>SUCCESS</Status>                                                                                            '
		                 + '               <Message/>                                                                                                          '
		                 + '               <PaymentDate>2016-08-15+07:00</PaymentDate>                                                                         '
		                 + '               <Amount>382.00</Amount>                                                                                             '
		                 + '            </NextCashBackInformation>                                                                                             '
		    			 + '			<InsuredPropertyAsset>																								   '
            			 + '			</InsuredPropertyAsset>'
            			 + '            <InsuredAutomobileAsset>                                                                                               '
		                 + '               <Status>SUCCESS</Status>                                                                                            '
		                 + '               <Message/>                                                                                                          '
		                 + '               <Brand/>                                                                                                            '
		                 + '               <PlateNumber/>                                                                                                      '
		                 + '            </InsuredAutomobileAsset>                                                                                              '
		                 + '            <BeneficiaryInformation>                                                                                               '
		                 + '               <Status>SUCCESS</Status>                                                                                            '
		                 + '               <Message/>                                                                                                          '
		                 + '               <Beneficiary>                                                                                                       '
		                 + '                  <Name/>                                                                                                          '
		                 + '               </Beneficiary>                                                                                                      '
		                 + '            </BeneficiaryInformation>                                                                                              '
            			 + '			<InsuranceClaimRecord>																									'
            			 + '				<ClaimRecord>																										'
            			 + '				</ClaimRecord>																										'
            			 + '			</InsuranceClaimRecord>																									'
		                 + '         </Result>                                                                                                                 '
		                 + '      </ns2:getBancassuranceProductDetailsResponse>                                                                                '
		                 + '   </soap:Body>                                                                                                                    '
		                 + '</soap:Envelope>                                                                                                                   '
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
	}
	
    @isTest private static void coverageSOAPControllerNeg() {
		//Set View 
		PageReference pageRef = Page.BancassuranceProductView;
		Test.setCurrentPage(pageRef);

		string policyno = '111111111111'; // Mock Accouont Id	
		string p = UrlHelper.encryptParams(policyno);
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('p', p);

		// Instantiate a new controller with all parameters in the page
		BancassuranceProductCtrl ctrl = new BancassuranceProductCtrl();
		Test.startTest();
		//Test Async Call Out
		Continuation conti = (Continuation) ctrl.startRequest();
		// Verify that the continuation has the proper requests
		Map<String, HttpRequest> requests = conti.getRequests();
		system.assert(requests.size() == 1);

		HttpResponse response = new HttpResponse();
		response.setBody(
		                 '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">                                                              '
		                 + '   <soap:Body>                                                                                                                     '
		                 + '      <ns2:getBancassuranceProductDetailsResponse xmlns:ns2="http://www.tmbbank.com/BancassuranceProductDetails/">                 '
		                 + '         <Result>                                                                                                                  '
		                 + '            <Status>SUCCESS</Status>                                                                                               '
		                 + '            <Message/>                                                                                                             '
		                 + '            <BancassuranceInformation>                                                                                             '
		                 + '               <Status>SUCCESS</Status>                                                                                            '
		                 + '               <Message/>                                                                                                          '
		                 + '               <ProductType>LIFE INSURANCE</ProductType>                                                                           '
		                 + '               <ProductName>TMB Smart Life 10/7</ProductName>                                                                      '
		                 + '               <EffectiveDate>2015-08-25+07:00</EffectiveDate>                                                                     '
		                 + '               <PolicyStatus>Active</PolicyStatus>                                                                                 '
		                 + '               <SumInsured>100000.00</SumInsured>                                                                                  '
		                 + '               <ExpiryDate>2025-08-25+07:00</ExpiryDate>                                                                           '
		                 + '            </BancassuranceInformation>                                                                                            '
		                 + '            <BancassuranceDetails>                                                                                                 '
		                 + '               <Status>SUCCESS</Status>                                                                                            '
		                 + '               <Message/>                                                                                                          '
		                 + '               <InsuranceCompany>FWD Life Insurance</InsuranceCompany>                                                             '
		                 + '            </BancassuranceDetails>                                                                                                '
		                 + '            <PaymentInformation>                                                                                                   '
		                 + '               <Status>SUCCESS</Status>                                                                                            '
		                 + '               <Message/>                                                                                                          '
		                 + '               <PaymentMode>Annual</PaymentMode>                                                                                   '
		                 + '               <PremiumAmount>0</PremiumAmount>                                                                                    '
		                 + '               <YearOfPayment>0001 of 7</YearOfPayment>                                                                            '
		                 + '               <NextDueDate>2016-08-25+07:00</NextDueDate>                                                                         '
		                 + '            </PaymentInformation>                                                                                                  '
		                 + '            <NextCashBackInformation>                                                                                              '
		                 + '               <Status>SUCCESS</Status>                                                                                            '
		                 + '               <Message/>                                                                                                          '
		                 + '               <PaymentDate>2016-08-15+07:00</PaymentDate>                                                                         '
		                 + '               <Amount>382.00</Amount>                                                                                             '
		                 + '            </NextCashBackInformation>                                                                                             '
		                 + '            <InsuredAutomobileAsset>                                                                                               '
		                 + '               <Status>SUCCESS</Status>                                                                                            '
		                 + '               <Message/>                                                                                                          '
		                 + '               <Brand/>                                                                                                            '
		                 + '               <PlateNumber/>                                                                                                      '
		                 + '            </InsuredAutomobileAsset>                                                                                              '
		                 + '            <BeneficiaryInformation>                                                                                               '
		                 + '               <Status>SUCCESS</Status>                                                                                            '
		                 + '               <Message/>                                                                                                          '
		                 + '               <Beneficiary>                                                                                                       '
		                 + '                  <Name/>                                                                                                          '
		                 + '               </Beneficiary>                                                                                                      '
		                 + '            </BeneficiaryInformation>                                                                                              '
		                 + '         </Result>                                                                                                                 '
		                 + '      </ns2:getBancassuranceProductDetailsResponse>                                                                                '
		                 + '   </soap:Body>                                                                                                                    '
		                 + '</soap:Envelope>                                                                                                                   '
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
	}

    
	@isTest private static void coverageSOAPControllerException() {
		//Set View 
		PageReference pageRef = Page.BancassuranceProductView;
		Test.setCurrentPage(pageRef);

		string policyno = '111111111111'; // Mock Accouont Id	
		string p = UrlHelper.encryptParams(policyno);
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('p', p);

		// Instantiate a new controller with all parameters in the page
		BancassuranceProductCtrl ctrl = new BancassuranceProductCtrl();
		Test.startTest();
		//Test Async Call Out
		Continuation conti = (Continuation) ctrl.startRequest();
		// Verify that the continuation has the proper requests
		Map<String, HttpRequest> requests = conti.getRequests();
		system.assert(requests.size() == 1);

		HttpResponse response = new HttpResponse();
		response.setBody(
		                 '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">                                                              '
		                 + '   <soap:Body>                                                                                                                     '
		                 + '   </soap:Body>                                                                                                                    '
		                 + '</soap:Envelope>                                                                                                                   '
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
	}
	public class BAInsuranceCompanyServiceImplMock implements IBAInsuranceCompanyService {

		public Map<string /*company name*/, BA_Insurance_Company__c> getAllBAInsuranceCompanies() {
			Map<string /*company name*/, BA_Insurance_Company__c> BAInsuranceCompanies = new Map<string /*company name*/, BA_Insurance_Company__c> ();
			BA_Insurance_Company__c item = new BA_Insurance_Company__c();
			item.Name = 'FWD';
			BAInsuranceCompanies.put(item.Name, item);
			return BAInsuranceCompanies;
		}

	}

}