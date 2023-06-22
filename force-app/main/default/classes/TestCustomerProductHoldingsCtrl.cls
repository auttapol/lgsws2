@isTest
private class TestCustomerProductHoldingsCtrl {

	private static List<sObject> ls;
	private static ProductHoldingDTO dto;

	static {
		//Load test data from resource
		ls = Test.loadData(Product2.sObjectType, 'RTLProductMaster');
		createMock();
		createMockCustomSetting();
	}

	//SCR 2017-1-1794 - Retail Product Holding Usage Log 23/12/2017
	private static void createMockCustomSetting() {
		List<AppConfig__c> apps = new  List<AppConfig__c>();
		AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'Is_Logger';
        Aconfig.Value__c = 'True'; 
        apps.add(Aconfig);
        insert apps;
	}
	//SCR 2017-1-1794 - Retail Product Holding Usage Log 23/12/2017

	private static void createMock() {
		dto = new ProductHoldingDTO();
		// 1) Deposit Accounts
		for (Integer i = 1; i <= 10; i++) {
			DepositeProductDTO d1 = new DepositeProductDTO();
			d1.DepositAccountNumber = '111111111' + i;
			if (i == 10)
			{
				d1.DepositAccountNumber = '1111111110';
			}
			d1.DepositProductCode = 'dp00' + i;
			if (i >= 10)
			{
				d1.DepositProductCode = 'dp000' + i;
			}

			d1.SubProductGroup = d1.DepositProductCode;
			d1.ProductName = d1.DepositProductCode;
			d1.OpenedDate = Date.today().addDays(- i).addYears(- i);
			d1.Status = 'Active';
			d1.OutStanding = 1000;
			d1.AvgOutStanding = (1060 + i);
			d1.IntEarning = (4505 + i);
			d1.Other = 'DC/DD';
			d1.HasJoint = 'Joint';     
			d1.ODLimit = 20000 + (i * 500);
			d1.LedgerBalance = 15000 + (i * 25);
			dto.DepositeProducts.add(d1);
            
            string v1 = d1.convertedOpenedDate;
		}
		// 2) Credit Card Accounts
		for (Integer i = 1; i <= 9; i++) {
			CreditCardRDCProductDTO d2 = new CreditCardRDCProductDTO();
			d2.CreditCardType = 'cd00' + i;
			if (i >= 6 && i <= 8)
			{
				d2.CreditCardType = 'cd004';
			}
			else if (i >= 9)
			{
				d2.CreditCardType = 'cd006';
			}
			d2.CardNumber = '3333-4444-5555-666' + i;
			d2.SubProductGroup = '';
			d2.ProductName = '';
			d2.OpenedDate = Date.today().addDays(- i).addYears(- i);
			d2.Status = 'Active';
			d2.Outstanding = (2345.21 * i);
			d2.VLimit = (2345.34 * i);
			dto.CreditCardRDCProducts.add(d2);
            string v2 = d2.convertedOpenedDate;
		}
		// 3) Loan Accounts
		for (Integer i = 1; i <= 9; i++) {
			LoanProductDTO d3 = new LoanProductDTO();
			d3.LoanAccountNumber = '187676899' + i;
			d3.LoanProductCode = 'ln001';
			if (i >= 6 && i <= 8)
			{
				d3.LoanProductCode = 'ln003';
			}
			else if (i >= 9)
			{
				d3.LoanProductCode = 'ln002';
			}

			d3.SubProductGroup = '';
			d3.ProductName = '';
			d3.OpenedDate = Date.today().addDays(- i).addYears(- i);
			d3.Status = 'Active';
			d3.Outstanding = (8789.21 * i);
			d3.VLimit = (2533.21 * i);
			d3.MuturityDate = Date.today().addDays(- i).addYears(- i);
			d3.HasCoBorrower = 'No';
			dto.LoanProducts.add(d3);
            string v3 = d3.convertedMaturityDate;
            string v4 = d3.convertedOpenedDate;
		}
		// 4) Bancassurance Accounts
		for (Integer i = 1; i <= 10; i++) {
			BancassuranceDTO d4 = new BancassuranceDTO();
			d4.PolicyNo = '0987654345' + i;
			d4.SubProductGroup = 'Life' + i;
			d4.ProductName = 'BA 15/ ' + i;
			d4.InsuranceCompany = 'TMB';
			if (i >= 8)
			{
				d4.InsuranceCompany = 'UOB';
			}
			d4.OpenedDate = Date.today().addDays(- i).addYears(- i);
			d4.Status = 'Active';
			d4.SumInsure = (5983.21 * i);
			d4.AFYP = (2533.21 * i);
			d4.ExpiryDate = Date.today().addDays(i);

			d4.SoapMessage = '';
			d4.SoapStatus = '';

			string param1 = d4.Params;
            string param2 = d4.convertedOpenedDate;

			dto.Bancassurances.add(d4);
		}
		// 5) Investment Accounts
		for (Integer i = 1; i <= 5; i++) {
			InvestmentProductDTO d5 = new InvestmentProductDTO();
			d5.FundCode = 'iv00' + i;
			d5.UnitHolderNo = '7683453456' + i;
			d5.ProductName = '';
			d5.SubProductGroup = '';
			d5.AssetClass = '';
			d5.IssuerFundHouse = 'TMB';
			if (i >= 4)
			{
				d5.IssuerFundHouse = 'TMBAM';
			}
			d5.OpenedDate = Date.today().addDays(- i);
			d5.Units = 1345.04 * i;
			d5.InitialValue = 2145.04 * i;
			d5.MarketValue = 3145.04 * i;
			d5.UnrealizedGL = 4145.04 * i;
			// SCR No. 2017-1-1804 for Average field Add on 18/10/2017
			d5.NavUnit = 2.5933 * i;
			// End SCR No. 2017-1-1804 for Average field Add on 18/10/2017
			dto.InvestmentProducts.add(d5);
            
            string v5 = d5.convertedOpenedDate;
		}
	}

	@isTest private static void coverageViewModel() {
		CustomerProductHoldingsCtrl.ViewState viewstage = new CustomerProductHoldingsCtrl.ViewState();
		viewstage.OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
		// assign value
		viewstage.ProductHoldings = dto;
		viewstage.InvokeTranform();
		viewstage.InvokeSummary();
		//Assert
		decimal sumofDeposit = 0;
		for (DepositeProductDTO item : viewstage.ProductHoldings.DepositeProducts)
		{
			sumofDeposit += item.OutStanding;
		}
		System.assertEquals(10000, sumofDeposit);
	}

	@isTest private static void coverageProcessResponseException() {

		OscControllerBase tt = new OscControllerBase();
		tt.CallSOAP(new Continuation(60));

		//Set Mock service
		RetailAccountService.setMockservice(new RetailAccountServiceFailMock());

		//Set View 
		PageReference pageRef = Page.CustomerProductHoldingsView;
		Test.setCurrentPage(pageRef);

		string acctId = '001p0000008XXXS'; // Mock Accouont Id
		string rmid = '001100000000000000000000822735';


		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('acctId', acctId);
		ApexPages.currentPage().getParameters().put('rmid', rmid);

		// Instantiate a new controller with all parameters in the page
		CustomerProductHoldingsCtrl ctrl = new CustomerProductHoldingsCtrl();

		System.assertEquals(rmid, ctrl.getRMID());
		System.assertEquals(acctId, ctrl.getAccId());


		Test.startTest();
		ctrl.processResponseSOAP();
        ctrl.getIsEmployee();
		// result is the return value of the callback
		Test.stopTest();
		System.assertNotEquals(null, ctrl.PageMessage);
	}

	@isTest private static void UpdateAccoutFail() {
		//Set Mock service
		RetailAccountService.setMockservice(new RetailAccountServiceFailMock());
		//Set View 
		PageReference pageRef = Page.CustomerProductHoldingsView;
		Test.setCurrentPage(pageRef);
		string acctId = IDGenerator.generate(Account.sObjectType);
		string rmid = '001100000000000000000000822735';
		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('acctId', acctId);
		ApexPages.currentPage().getParameters().put('rmid', rmid);
		// Instantiate a new controller with all parameters in the page
		CustomerProductHoldingsCtrl ctrl = new CustomerProductHoldingsCtrl();


		ctrl.UpdateFieldOnAccount(null, 10, 1000,Datetime.now());

		System.debug('TMB :-> PageMessage is ' + ctrl.PageMessage);
		System.assertEquals(true, ctrl.PageMessage.contains('Update Account Information  error with inner exception'));

	}

	@isTest private static void coverageSOAPController() {
		//Set Mock service
		RetailAccountService.setMockservice(new RetailAccountServiceMock());

		//Set View 
		PageReference pageRef = Page.CustomerProductHoldingsView;
		Test.setCurrentPage(pageRef);

		string acctId = '001p0000008XXXS'; // Mock Accouont Id
		string rmid = '001100000000000000000000822735';


		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('acctId', acctId);
		ApexPages.currentPage().getParameters().put('rmid', rmid);

		// Instantiate a new controller with all parameters in the page
		CustomerProductHoldingsCtrl ctrl = new CustomerProductHoldingsCtrl();
		ctrl.SVR_MODE = 'soap';

		System.assertEquals(rmid, ctrl.getRMID());
		System.assertEquals(acctId, ctrl.getAccId());

		System.debug('START TEST');
		Test.startTest();
		//Test Async Call Out
		Continuation conti = (Continuation) ctrl.startRequest();
		// Verify that the continuation has the proper requests
		Map<String, HttpRequest> requests = conti.getRequests();
		system.assert(requests.size() == 1);

		HttpResponse response = new HttpResponse();

		response.setBody('	<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">                                '
		                 + '	   <soap:Body>                                                                                        '
		                 + '		  <ns2:getProductHoldingsResponse xmlns:ns2="http://www.tmbbank.com/CustomerProductHoldings/">    '
		                 + '			 <Result>                                                                                     '
		                 + '				<MuleInfo>                                                              				  '
                         + '					<LogId>18e36204-0aa1-42fa-ba0b-b872e57d3e99</LogId>									  '
                         + '					<Status>SUCCESS</Status>															  '
                         + '					<Message>success</Message>															  '
                         + '				</MuleInfo>																				  '
		                 + '				<DepositAccounts>                                                                         '
		                 + '				<MuleInfo>                                                              				  '
                         + '					<LogId>18e36204-0aa1-42fa-ba0b-b872e57d3e99</LogId>									  '
                         + '					<Status>SUCCESS</Status>															  '
                         + '					<Message>success</Message>															  '
                         + '				</MuleInfo>																				  '
                         + '				   <DepositAccount>                                                                       '
		                 + '					  <AccountNumber>2471779484</AccountNumber>                                           '
		                 + '					  <ProductType>com.fnis.xes.IM</ProductType>                                          '
		                 + '					  <ProductCode>101</ProductCode>                                                      '
		                 + '					  <OpenedDate>2013-05-01</OpenedDate>                                                 '
		                 + '					  <AccountStatus>Active | ปกติ (Active)</AccountStatus>                                 '
		                 + '					  <Outstanding>4</Outstanding>                                                        '
		                 + '					  <AvgOutstanding>0</AvgOutstanding>                                                  '
		                 + '					  <InterestEarned>0</InterestEarned>                                                  '
		                 + '					  <Other/>                                                                            '
		                 + '					  <HasJoint>PRIIND</HasJoint>                                                         '
		                 + '				   </DepositAccount>                                                                      '
		                 + '				   <DepositAccount>                                                                       '
		                 + '					  <AccountNumber>00000017541293</AccountNumber>                                       '
		                 + '					  <ProductType>com.fnis.xes.ST</ProductType>                                          '
		                 + '					  <ProductCode>220</ProductCode>                                                      '
		                 + '					  <OpenedDate>2013-05-22</OpenedDate>                                                 '
		                 + '					  <AccountStatus>Active | ปกติ (Active)</AccountStatus>                                 '
		                 + '					  <Outstanding>0</Outstanding>                                                        '
		                 + '					  <AvgOutstanding>0</AvgOutstanding>                                                  '
		                 + '					  <InterestEarned>0</InterestEarned>                                                  '
		                 + '					  <Other/>                                                                            '
		                 + '					  <HasJoint>PRIIND</HasJoint>                                                         '
		                 + '					  <Status>ERROR</Status>'
                         + '				   </DepositAccount>                                                                      '
		                 + '				   <DepositAccount>                                                                       '
		                 + '					  <AccountNumber>00000542332499</AccountNumber>                                       '
		                 + '					  <ProductType>com.fnis.xes.ST</ProductType>                                          '
		                 + '					  <ProductCode>200</ProductCode>                                                      '
		                 + '					  <OpenedDate>2013-05-11</OpenedDate>                                                 '
		                 + '					  <AccountStatus>Active | ปกติ (Active)</AccountStatus>                                 '
		                 + '					  <Outstanding>0</Outstanding>                                                        '
		                 + '					  <AvgOutstanding>600000</AvgOutstanding>                                                  '
		                 + '					  <InterestEarned>0</InterestEarned>                                                  '
		                 + '					  <Other/>                                                                            '
		                 + '					  <HasJoint>PRIIND</HasJoint>                                                         '
		                 + '				   </DepositAccount>                                                                      '
		                 + '				   <DepositAccount>                                                                       '
		                 + '					  <AccountNumber>02473011316001</AccountNumber>                                       '
		                 + '					  <ProductType>com.fnis.xes.ST</ProductType>                                          '
		                 + '					  <ProductCode>300</ProductCode>                                                      '
		                 + '					  <OpenedDate>2013-03-18</OpenedDate>                                                 '
		                 + '					  <AccountStatus>Active | ปกติ (Active)</AccountStatus>                                 '
		                 + '					  <Outstanding>0</Outstanding>                                                        '
		                 + '					  <AvgOutstanding>0</AvgOutstanding>                                                  '
		                 + '					  <InterestEarned>0</InterestEarned>                                                  '
		                 + '					  <Other/>                                                                            '
		                 + '					  <HasJoint>PRIIND</HasJoint>                                                         '
		                 + '				   </DepositAccount>                                                                      '
		                 + '				   <DepositAccount>                                                                       '
		                 + '					  <AccountNumber>02473011316002</AccountNumber>                                       '
		                 + '					  <ProductType>com.fnis.xes.ST</ProductType>                                          '
		                 + '					  <ProductCode>300</ProductCode>                                                      '
		                 + '					  <OpenedDate>2013-05-05</OpenedDate>                                                 '
		                 + '					  <AccountStatus>Active | ปกติ (Active)</AccountStatus>                                 '
		                 + '					  <Outstanding>0</Outstanding>                                                        '
		                 + '					  <AvgOutstanding>0</AvgOutstanding>                                                  '
		                 + '					  <InterestEarned>0</InterestEarned>                                                  '
		                 + '					  <Other/>                                                                            '
		                 + '					  <HasJoint>PRIIND</HasJoint>                                                         '
		                 + '				   </DepositAccount>                                                                      '
		                 + '				</DepositAccounts>                                                                        '
		                 + '				<CreditCardAccounts>                                                                      '
		                 + '				<MuleInfo>                                                              				  '
                         + '					<LogId>18e36204-0aa1-42fa-ba0b-b872e57d3e99</LogId>									  '
                         + '					<Status>SUCCESS</Status>															  '
                         + '					<Message>success</Message>															  '
                         + '				</MuleInfo>																				  '
                         + '				   <CreditCardAccount>                                                                    '
		                 + '					  <CardNumber>4560432101111150</CardNumber>                                           '
		                 + '					  <CreditCardType>021</CreditCardType>                                                '
		                 + '					  <AccountStatus>Active</AccountStatus>                                               '
		                 + '					  <Status>ERROR</Status>'
                         + '				   </CreditCardAccount>                                                                   '
		                 + '				   <CreditCardAccount>                                                                    '
		                 + '					  <CardNumber>4560432109659002</CardNumber>                                           '
		                 + '					  <CreditCardType>102</CreditCardType>                                                                   '
		                 + '					  <AccountStatus>NOTFND</AccountStatus>                                               '
                         + '					  <Outstanding>20000</Outstanding>														  '
                         + '					  <Limit>30000</Limit>															  '
		                 + '				   </CreditCardAccount>                                                                   '
		                 + '				</CreditCardAccounts>                                                                     '
		                 + '				<LoanAccounts>                                                                            '
		                 + '				<MuleInfo>                                                              				  '
                         + '					<LogId>18e36204-0aa1-42fa-ba0b-b872e57d3e99</LogId>									  '
                         + '					<Status>SUCCESS</Status>															  '
                         + '					<Message>success</Message>															  '
                         + '				</MuleInfo>																				  '
                         + '				   <LoanAccount>                                                                          '
		                 + '					  <AccountNumber>00016080681007</AccountNumber>                                       '
		                 + '					  <ProductType>com.fnis.xes.AL</ProductType>                                          '
		                 + '					  <ProductCode>AAPA</ProductCode>                                                     '
		                 + '					  <OpenedDate>9999-12-31</OpenedDate>                                                 '
		                 + '					  <AccountStatus>NonAccrual</AccountStatus>                                           '
		                 + '					  <Outstanding>6</Outstanding>                                                        '
		                 + '					  <Limit>260000.00</Limit>                                                            '
		                 + '					  <MaturityDate>2015-11-24+07:00</MaturityDate>                                       '
		                 + '				   </LoanAccount>                                                                         '
		                 + '				   <LoanAccount>                                                                          '
		                 + '					  <AccountNumber>00016151011002</AccountNumber>                                       '
		                 + '					  <ProductType>com.fnis.xes.AL</ProductType>                                          '
		                 + '					  <ProductCode>AAPA</ProductCode>                                                     '
		                 + '					  <OpenedDate>2016-03-24</OpenedDate>                                                 '
		                 + '					  <AccountStatus>NonAccrual</AccountStatus>                                           '
		                 + '					  <Outstanding>789024</Outstanding>                                                        '
		                 + '					  <Limit>700000.00</Limit>                                                            '
		                 + '					  <MaturityDate>2017-07-24+07:00</MaturityDate>                                       '
		                 + '				   </LoanAccount>                                                                         '
		                 + '				   <LoanAccount>                                                                          '
		                 + '					  <AccountNumber>00016151011001</AccountNumber>                                       '
		                 + '					  <ProductType>com.fnis.xes.AL</ProductType>                                          '
		                 + '					  <ProductCode>ABHA</ProductCode>                                                     '
		                 + '					  <OpenedDate>2016-03-24</OpenedDate>                                                 '
		                 + '					  <AccountStatus>NonAccrual</AccountStatus>                                           '
		                 + '					  <Outstanding>0</Outstanding>                                                        '
		                 + '					  <Limit>2686000.00</Limit>                                                           '
		                 + '					  <MaturityDate>2029-10-24+07:00</MaturityDate>                                       '
		                 + '					  <Status>ERROR</Status>'
                         + '				   </LoanAccount>                                                                         '
		                 + '				</LoanAccounts>                                                                           '
		                 + '				<BancassuranceAccounts>                                                                   '
						 + '				<MuleInfo>                                                              				  '
                         + '					<LogId>18e36204-0aa1-42fa-ba0b-b872e57d3e99</LogId>									  '
                         + '					<Status>SUCCESS</Status>															  '
                         + '					<Message>success</Message>															  '
                         + '				</MuleInfo>																				  '
		                 + '					<BancassuranceAccount>'
                         + ' 						<PolicyNumber>T01671399</PolicyNumber>'
                         + '						<SubProductGroup>LIFE INSURANCE</SubProductGroup>'
                         + '						<ProductName>#N/A</ProductName>'
                         + '						<InsuranceCompany>FWD Life Insurance</InsuranceCompany>'
                         + '						<OpenedDate>2013-12-17+07:00</OpenedDate>'
                         + '						<PolicyStatus>Active</PolicyStatus>'
                         + '						<SumInsure>113208.00</SumInsure>'
                         + '						<ExpiryDate>2028-12-17+07:00</ExpiryDate>'
                         + '					</BancassuranceAccount>'
                         + '					<BancassuranceAccount>'
                         + ' 						<PolicyNumber>T01671392</PolicyNumber>'
                         + '						<SubProductGroup>LIFE INSURANCE</SubProductGroup>'
                         + '						<ProductName>#N/A</ProductName>'
                         + '						<InsuranceCompany>FWD Life Insurance</InsuranceCompany>'
                         + '						<OpenedDate>2013-12-17+07:00</OpenedDate>'
                         + '						<PolicyStatus>Active</PolicyStatus>'
                         + '						<SumInsure>113208.00</SumInsure>'
                         + '						<ExpiryDate>2028-12-17+07:00</ExpiryDate>'
                         + '						<Status>ERROR</Status>'
                         + '					</BancassuranceAccount>'
                         + '				</BancassuranceAccounts>                                                                  '
                         + '				<InvestmentAccounts>'
                         + '				<MuleInfo>                                                              				  '
                         + '					<LogId>18e36204-0aa1-42fa-ba0b-b872e57d3e99</LogId>									  '
                         + '					<Status>SUCCESS</Status>															  '
                         + '					<Message>success</Message>															  '
                         + '				</MuleInfo>																				  '
                         + '				   <InvestmentAccount>                                                                    '
		                 + '					  <UnitHoldNo>0010013993</UnitHoldNo>                                                 '
		                 + '					  <ProductName>TMB MONEY FUND</ProductName>                                           '
		                 + '					  <FundCode>TB1</FundCode>                                                            '
		                 + '					  <Issuer>TMBAM</Issuer>                                                              '
		                 + '					  <MarketValue>1210.71</MarketValue>                                                  '
		                 + '					  <UnrealizedGL>10.71</UnrealizedGL>                                                  '
		                 + '					  <NavUnit>21.4367</NavUnit>		                                                  '
		                 + '				   </InvestmentAccount>                                                                   '
		                 + '				   <InvestmentAccount>                                                                    '
		                 + '					  <UnitHoldNo>0550003552</UnitHoldNo>                                                 '
		                 + '					  <ProductName>TMB MONEY FUND</ProductName>                                           '
		                 + '					  <FundCode>TB1</FundCode>                                                            '
		                 + '					  <Issuer>TMBAM</Issuer>                                                              '
		                 + '					  <MarketValue>399.30</MarketValue>                                                   '
		                 + '					  <UnrealizedGL>-5.70</UnrealizedGL>                                                  '
		                 + '					  <NavUnit>2.4367</NavUnit>			                                                  '
		                 + '					 <Status>ERROR</Status>																  '
                         + '				   </InvestmentAccount>                                                                   '
		                 + '				   <InvestmentAccount>                                                                    '
		                 + '					  <UnitHoldNo>0550003552</UnitHoldNo>                                                 '
		                 + '					  <ProductName>JUMBO 25 Dividend LTF</ProductName>                                    '
		                 + '					  <FundCode>LF6</FundCode>                                                            '
		                 + '					  <Issuer>TMBAM</Issuer>                                                              '
		                 + '					  <MarketValue>93180.45</MarketValue>                                                 '
		                 + '					  <UnrealizedGL>-18224.55</UnrealizedGL>                                              '
		                 + '					  <NavUnit>1.4367</NavUnit>		                                                  	  '
		                 + '				   </InvestmentAccount>                                                                   '
		                 + '				   <InvestmentAccount>                                                                    '
		                 + '					  <UnitHoldNo>110233000078</UnitHoldNo>                                               '
		                 + '					  <ProductName>Aberdeen Long Term Equity Fund</ProductName>                           '
		                 + '					  <FundCode>ABLTF</FundCode>                                                          '
		                 + '					  <Issuer>ABERDEEN</Issuer>                                                           '
		                 + '					  <MarketValue>43838.18</MarketValue>                                                 '
		                 + '					  <UnrealizedGL>-6161.82</UnrealizedGL>                                               '
		                 + '					  <NavUnit>3.4367</NavUnit>		                                                  	  '
		                 + '				   </InvestmentAccount>                                                                   '
		                 + '				   <InvestmentAccount>                                                                    '
		                 + '					  <UnitHoldNo>111001000034</UnitHoldNo>                                               '
		                 + '					  <ProductName>Thai Cash Management Fund</ProductName>                                '
		                 + '					  <FundCode>TCMF</FundCode>                                                           '
		                 + '					  <Issuer>UOBAMTH</Issuer>                                                            '
		                 + '					  <MarketValue>1062.07</MarketValue>                                                  '
		                 + '					  <UnrealizedGL>49.02</UnrealizedGL>                                                  '
		                 + '					  <NavUnit>21.4127</NavUnit>		                                                  '
		                 + '				   </InvestmentAccount>                                                                   '
		                 + '				   <InvestmentAccount>                                                                    '
		                 + '					  <UnitHoldNo>111001000034</UnitHoldNo>                                               '
		                 + '					  <ProductName>Aberdeen Small Cap Fund</ProductName>                                  '
		                 + '					  <FundCode>ABSM</FundCode>                                                           '
		                 + '					  <Issuer>ABERDEEN</Issuer>                                                           '
		                 + '					  <MarketValue>3739.93</MarketValue>                                                  '
		                 + '					  <UnrealizedGL>-235.90</UnrealizedGL>                                                '
		                 + '					  <NavUnit>21.5367</NavUnit>		                                                  '
		                 + '				   </InvestmentAccount>                                                                   '
		                 + '				   <InvestmentAccount>                                                                    '
		                 + '					  <UnitHoldNo>111324000011</UnitHoldNo>                                               '
		                 + '					  <ProductName>Thai Cash Management Fund</ProductName>                                '
		                 + '					  <FundCode>TCMF</FundCode>                                                           '
		                 + '					  <Issuer>UOBAMTH</Issuer>                                                            '
		                 + '					  <MarketValue>68.94</MarketValue>                                                    '
		                 + '					  <UnrealizedGL>8.26</UnrealizedGL>                                                   '
		                 + '					  <NavUnit>11.4367</NavUnit>		                                                  '
		                 + '				   </InvestmentAccount>                                                                   '
		                 + '				</InvestmentAccounts>                                                                     '
		                 + '			 </Result>                                                                                    '
		                 + '		  </ns2:getProductHoldingsResponse>                                                               '
		                 + '	   </soap:Body>                                                                                       '
		                 + '	</soap:Envelope>                                                                                      '
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

		// make get param
		for (BancassuranceDTO item : ctrl.ViewState.ProductHoldings.Bancassurances)
		{
			string v1 = item.Params;
			string v2 = item.SoapStatus;
			string v3 = item.SoapMessage;
			string v4 = item.Params;



		}
		for (CreditCardRDCProductDTO item : ctrl.ViewState.ProductHoldings.CreditCardRDCProducts)
		{
			string v1 = item.Params;
			string v2 = item.SoapStatus;
			string v3 = item.SoapMessage;
			string v4 = item.MarkedCardNumber;
			string v5 = item.MarkedOutstanding;
			string v6 = item.MarkedVLimit;



		}
		for (DepositeProductDTO item : ctrl.ViewState.ProductHoldings.DepositeProducts)
		{
			string v1 = item.Params;
			string v2 = item.SoapStatus;
			string v3 = item.SoapMessage;
			string v4 = item.MarkedDepositAccountNumber;
			string v5 = item.MarkedOutStanding;
			string v6 = item.MarkedAvgOutStanding;
			string v7 = item.MarkedLedgerBalance;


		}
		for (InvestmentProductDTO item : ctrl.ViewState.ProductHoldings.InvestmentProducts)
		{
			string v1 = item.Params;
			string v2 = item.SoapStatus;
			string v3 = item.SoapMessage;			
		}
		for (LoanProductDTO item : ctrl.ViewState.ProductHoldings.LoanProducts)
		{
			string v1 = item.Params;
			string v2 = item.SoapStatus;
			string v3 = item.SoapMessage;
			string v4 = item.MarkedLoanAccountNumber;
			string v5 = item.MarkedOutstanding;
			string v6 = item.MarkedVLimit;


		}

		if (ctrl.ViewState.ProductHoldingSummaries.containsKey('8'))
		{
			ProductHoldingSummaryDTO item = ctrl.ViewState.ProductHoldingSummaries.get('8');
			item.ProductSubGroup = '';
			decimal v1 = item.GetLimit;
			string v2 = item.GetMakedOutstanding;
			decimal v3 = item.NoOfProduct;
            boolean v4 = item.GetIsEmployee;
            integer v5 = item.NoOfAccount;
			
		}


	}
    
    @isTest private static void coverageSOAPControllerServiceERROR() {
		//Set Mock service
		RetailAccountService.setMockservice(new RetailAccountServiceMock());

		//Set View 
		PageReference pageRef = Page.CustomerProductHoldingsView;
		Test.setCurrentPage(pageRef);

		string acctId = '001p0000008XXXS'; // Mock Accouont Id
		string rmid = '001100000000000000000000822735';


		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('acctId', acctId);
		ApexPages.currentPage().getParameters().put('rmid', rmid);

		// Instantiate a new controller with all parameters in the page
		CustomerProductHoldingsCtrl ctrl = new CustomerProductHoldingsCtrl();
		ctrl.SVR_MODE = 'soap';

		System.assertEquals(rmid, ctrl.getRMID());
		System.assertEquals(acctId, ctrl.getAccId());

		System.debug('START TEST');
		Test.startTest();
		//Test Async Call Out
		Continuation conti = (Continuation) ctrl.startRequest();
		// Verify that the continuation has the proper requests
		Map<String, HttpRequest> requests = conti.getRequests();
		system.assert(requests.size() == 1);

		HttpResponse response = new HttpResponse();

		response.setBody('	<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">                                '
		                 + '	   <soap:Body>                                                                                        '
		                 + '		  <ns2:getProductHoldingsResponse xmlns:ns2="http://www.tmbbank.com/CustomerProductHoldings/">    '
		                 + '			 <Result>                                                                                     '
		                 + '				<MuleInfo>                                                              				  '
                         + '					<LogId>18e36204-0aa1-42fa-ba0b-b872e57d3e99</LogId>									  '
                         + '					<Status>ERROR</Status>															  '
                         + '					<Message>ERR002</Message>															  '
                         + '				</MuleInfo>																				  '
		                 + '			 </Result>                                                                                    '
		                 + '		  </ns2:getProductHoldingsResponse>                                                               '
		                 + '	   </soap:Body>                                                                                       '
		                 + '	</soap:Envelope>                                                                                      '
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
    
    @isTest private static void coverageSOAPControllerSectionERROR() {
		//Set Mock service
		RetailAccountService.setMockservice(new RetailAccountServiceMock());

		//Set View 
		PageReference pageRef = Page.CustomerProductHoldingsView;
		Test.setCurrentPage(pageRef);

		string acctId = '001p0000008XXXS'; // Mock Accouont Id
		string rmid = '001100000000000000000000822735';


		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('acctId', acctId);
		ApexPages.currentPage().getParameters().put('rmid', rmid);

		// Instantiate a new controller with all parameters in the page
		CustomerProductHoldingsCtrl ctrl = new CustomerProductHoldingsCtrl();
		ctrl.SVR_MODE = 'soap';

		System.assertEquals(rmid, ctrl.getRMID());
		System.assertEquals(acctId, ctrl.getAccId());

		System.debug('START TEST');
		Test.startTest();
		//Test Async Call Out
		Continuation conti = (Continuation) ctrl.startRequest();
		// Verify that the continuation has the proper requests
		Map<String, HttpRequest> requests = conti.getRequests();
		system.assert(requests.size() == 1);

		HttpResponse response = new HttpResponse();

		response.setBody('	<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">                                '
		                 + '	   <soap:Body>                                                                                        '
		                 + '		  <ns2:getProductHoldingsResponse xmlns:ns2="http://www.tmbbank.com/CustomerProductHoldings/">    '
		                 + '			 <Result>                                                                                     '
		                 + '				<MuleInfo>                                                              				  '
                         + '					<LogId>18e36204-0aa1-42fa-ba0b-b872e57d3e99</LogId>									  '
                         + '					<Status>SUCCESS</Status>															  '
                         + '					<Message>success</Message>															  '
                         + '				</MuleInfo>																				  '
		                 + '				<DepositAccounts>                                                                         '
		                 + '				<MuleInfo>                                                              				  '
                         + '					<LogId>18e36204-0aa1-42fa-ba0b-b872e57d3e99</LogId>									  '
                         + '					<Status>ERROR</Status>															  '
                         + '					<Message>success</Message>															  '
                         + '				</MuleInfo>																				  '
						 + '				</DepositAccounts>                                                                        '
		                 + '				<CreditCardAccounts>                                                                      '
		                 + '				<MuleInfo>                                                              				  '
                         + '					<LogId>18e36204-0aa1-42fa-ba0b-b872e57d3e99</LogId>									  '
                         + '					<Status>ERROR</Status>															  '
                         + '					<Message>success</Message>															  '
                         + '				</MuleInfo>																				  '
                         + '				</CreditCardAccounts>                                                                     '
		                 + '				<LoanAccounts>                                                                            '
		                 + '				<MuleInfo>                                                              				  '
                         + '					<LogId>18e36204-0aa1-42fa-ba0b-b872e57d3e99</LogId>									  '
                         + '					<Status>ERROR</Status>															  '
                         + '					<Message>success</Message>															  '
                         + '				</MuleInfo>																				  '
                         + '				</LoanAccounts>                                                                           '
		                 + '				<BancassuranceAccounts>                                                                   '
						 + '				<MuleInfo>                                                              				  '
                         + '					<LogId>18e36204-0aa1-42fa-ba0b-b872e57d3e99</LogId>									  '
                         + '					<Status>ERROR</Status>															  '
                         + '					<Message>success</Message>															  '
                         + '				</MuleInfo>																				  '  
		                 + '				</BancassuranceAccounts>                                                                  '
                         + '				<InvestmentAccounts>'
                         + '				<MuleInfo>                                                              				  '
                         + '					<LogId>18e36204-0aa1-42fa-ba0b-b872e57d3e99</LogId>									  '
                         + '					<Status>ERROR</Status>															  '
                         + '					<Message>success</Message>															  '
                         + '				</MuleInfo>																				  '
                         + '				</InvestmentAccounts>                                                                     '
		                 + '			 </Result>                                                                                    '
		                 + '		  </ns2:getProductHoldingsResponse>                                                               '
		                 + '	   </soap:Body>                                                                                       '
		                 + '	</soap:Envelope>                                                                                      '
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

		// make get param
		for (BancassuranceDTO item : ctrl.ViewState.ProductHoldings.Bancassurances)
		{
			string v1 = item.Params;
			string v2 = item.SoapStatus;
			string v3 = item.SoapMessage;
			string v4 = item.Params;



		}
		for (CreditCardRDCProductDTO item : ctrl.ViewState.ProductHoldings.CreditCardRDCProducts)
		{
			string v1 = item.Params;
			string v2 = item.SoapStatus;
			string v3 = item.SoapMessage;
			string v4 = item.MarkedCardNumber;
			string v5 = item.MarkedOutstanding;
			string v6 = item.MarkedVLimit;



		}
		for (DepositeProductDTO item : ctrl.ViewState.ProductHoldings.DepositeProducts)
		{
			string v1 = item.Params;
			string v2 = item.SoapStatus;
			string v3 = item.SoapMessage;
			string v4 = item.MarkedDepositAccountNumber;
			string v5 = item.MarkedOutStanding;
			string v6 = item.MarkedAvgOutStanding;
			string v7 = item.MarkedLedgerBalance;


		}
		for (InvestmentProductDTO item : ctrl.ViewState.ProductHoldings.InvestmentProducts)
		{
			string v1 = item.Params;
			string v2 = item.SoapStatus;
			string v3 = item.SoapMessage;			
		}
		for (LoanProductDTO item : ctrl.ViewState.ProductHoldings.LoanProducts)
		{
			string v1 = item.Params;
			string v2 = item.SoapStatus;
			string v3 = item.SoapMessage;
			string v4 = item.MarkedLoanAccountNumber;
			string v5 = item.MarkedOutstanding;
			string v6 = item.MarkedVLimit;


		}

		if (ctrl.ViewState.ProductHoldingSummaries.containsKey('8'))
		{
			ProductHoldingSummaryDTO item = ctrl.ViewState.ProductHoldingSummaries.get('8');
			item.ProductSubGroup = '';
			decimal v1 = item.GetLimit;
			string v2 = item.GetMakedOutstanding;
			decimal v3 = item.NoOfProduct;
            boolean v4 = item.GetIsEmployee;
            integer v5 = item.NoOfAccount;
			
		}


	}

	@isTest private static void coverageSOAPControllerException() {
		//Set Mock service
		RetailAccountService.setMockservice(new RetailAccountServiceMock());

		//Set View 
		PageReference pageRef = Page.CustomerProductHoldingsView;
		Test.setCurrentPage(pageRef);

		string acctId = '001p0000008XXXS'; // Mock Accouont Id
		string rmid = '001100000000000000000000822735';


		// Add parameters to page URL
		ApexPages.currentPage().getParameters().put('acctId', acctId);
		ApexPages.currentPage().getParameters().put('rmid', rmid);

		// Instantiate a new controller with all parameters in the page
		CustomerProductHoldingsCtrl ctrl = new CustomerProductHoldingsCtrl();
		ctrl.SVR_MODE = 'soap';

		System.assertEquals(rmid, ctrl.getRMID());
		System.assertEquals(acctId, ctrl.getAccId());
		ctrl.getCustomerName();

		Test.startTest();
		//Test Async Call Out
		Continuation conti = (Continuation) ctrl.startRequest();
		// Verify that the continuation has the proper requests
		Map<String, HttpRequest> requests = conti.getRequests();
		system.assert(requests.size() == 1);

		HttpResponse response = new HttpResponse();

		response.setBody('	<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">                                '
		                 + '	   <soap:Body>       ');
		// Set the fake response for the continuation
		String requestLabel = requests.keyset().iterator().next();
		Test.setContinuationResponse(requestLabel, response);

		// Invoke callback method
		Object result = Test.invokeContinuationMethod(ctrl, conti);
		test.stopTest();
		System.debug(ctrl);

		// result is the return value of the callback
		System.assertEquals(null, result);
	}

	//Mock Service 
	public class RetailAccountServiceMock implements IRetailAccountService {
		public Boolean UpdateTotalAccountsAndSumOfDepesite(string accountId, decimal noOfAccounts, decimal sumOfTotalDepositeOutstanding) {
			Boolean ret = true;
			return ret;
		}
		public Account GetAccountById(Id acctId) {
			return new Account(name = 'xxxx',TMB_Customer_ID_PE__c = '001100000000000000000000822735');
		}
	}
	public class RetailAccountServiceFailMock implements IRetailAccountService {
		public Boolean UpdateTotalAccountsAndSumOfDepesite(string accountId, decimal noOfAccounts, decimal sumOfTotalDepositeOutstanding) {
			throw new RetailAccountServiceImpl.RetailAccountServiceException('Exception Throw RetailAccountServiceFailMock');
		}
		public Account GetAccountById(Id acctId) {
			return new Account(name = 'xxxx',TMB_Customer_ID_PE__c = '001100000000000000000000822735');
		}

	}
}