@istest
public class CustomerWealthGetProductSummary_Test {

    public static final Id WEALTH_PROFILE_ID {
        get{
            if(WEALTH_PROFILE_ID == null){
                WEALTH_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Retail Wealth Management' LIMIT 1].Id;
            }
            return WEALTH_PROFILE_ID;
        }
        set;
    }

    @testSetup static void setup() {
		
		TestUtils.createAppConfig();

		Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = 'WSS';
        insert bz;

		User User01 = RTL_TestUtility.createUsers(1, 'TestMock', 'Wealth', 'wealth@tmb.com.test', false).get(0);
		User01.ProfileId = WEALTH_PROFILE_ID;
		User01.isActive = true;
		User01.title = 'Private Wealth';
		User01.RTL_Branch_Code__c = bz.Branch_Code__c;
		User01.Employee_ID__c = '123456';
		insert User01;

    }

    public static testMethod void testGetCustomerInfo() {
        Account acct = new Account(Name='TestAcct1',Mobile_Number_PE__c='0123456789',Account_Type__c='Retail Customer',TMB_Customer_ID_PE__C='001100000000000000000000011498',LastGetOsc17__c=Datetime.now());
        insert acct;
                
        Test.startTest();
            String lastUpdate = CustomerWealthGetProductSummary.getCustomerInfo(acct.Id);
            System.assertNotEquals('', lastUpdate);
        Test.stopTest();
    }

    public static testMethod void testNeedUpdateTrue() {
        Account acct = new Account(Name='TestAcct1',Mobile_Number_PE__c='0123456789',Account_Type__c='Retail Customer',TMB_Customer_ID_PE__C='001100000000000000000000011498',LastGetOsc17__c=Datetime.now().addHours(-7));
        insert acct;
                
        Test.startTest();
            Boolean isNeedUpdate = CustomerWealthGetProductSummary.isNeedUpdateOsc17(acct.Id);
            System.assertEquals(true, isNeedUpdate);
        Test.stopTest();
    }

    public static testMethod void testNeedUpdateFalse() {
        Account acct = new Account(Name='TestAcct1',Mobile_Number_PE__c='0123456789',Account_Type__c='Retail Customer',TMB_Customer_ID_PE__C='001100000000000000000000011498',LastGetOsc17__c=Datetime.now());
        insert acct;
                
        Test.startTest();
            Boolean isNeedUpdate = CustomerWealthGetProductSummary.isNeedUpdateOsc17(acct.Id);
            System.assertEquals(false, isNeedUpdate);
        Test.stopTest();
    }

    public static testMethod void testGetOsc17FromStampValue() {
        Account acct = new Account(Name='TestAcct1'
                                  ,Mobile_Number_PE__c='0123456789'
                                  ,Account_Type__c='Retail Customer'
                                  ,TMB_Customer_ID_PE__C='001100000000000000000000011498'
                                  ,LastGetOsc17__c=Datetime.now()
                                  ,Osc17TempValueJson__c='{"MF":"100","LoanLimit":"200","Loan":"300.02","Deposit":"400.62","CreditLimit":"500","Credit":"600.00","BA":"700.0"}');
        insert acct;
                
        Test.startTest();
            List<List<String>> result = CustomerWealthGetProductSummary.getOsc17FromStampValue(acct.Id);
            System.assertNotEquals(0, result.size());
        Test.stopTest();
    }

    public static testMethod void testUpdateOsc17ToCustomer() {
        Account acct = new Account(Name='TestAcct1'
                                  ,Mobile_Number_PE__c='0123456789'
                                  ,Account_Type__c='Retail Customer'
                                  ,TMB_Customer_ID_PE__C='001100000000000000000000011498'
                                  ,LastGetOsc17__c=Datetime.now()
                                  ,Osc17TempValueJson__c='{"MF":"100","LoanLimit":"200","Loan":"300.02","Deposit":"400.62","CreditLimit":"500","Credit":"600.00","BA":"700.0"}');
        insert acct;
                
        Test.startTest();
            List<List<String>> data = new List<List<String>>();
            List<String> ban = new List<String>();
            List<String> mutualFund = new List<String>();
            List<String> depo = new List<String>();
            List<String> lo = new List<String>();
            List<String> loLimit = new List<String>();
            List<String> cd = new List<String>();
            List<String> cdLimit = new List<String>();

            // index 0 is BA
            ban.add('BA');
            ban.add('500');
            // index 1 is MF
            mutualFund.add('MF');
            mutualFund.add('500');
            // index 2 is Deposit
            depo.add('Deposit');
            depo.add('500');
            // index 3 is Credit
            cd.add('Credit');
            cd.add('500');
            // index 4 is Credit
            cdLimit.add('CreditLimit');
            cdLimit.add('1000');
            // index 5 is Loan
            lo.add('Loan');
            lo.add('500');
            // index 6 is Loan Limit
            loLimit.add('LoanLimit');
            loLimit.add('1000');
            
            data.add(ban);
            data.add(mutualFund);
            data.add(depo);
            data.add(cd);
            data.add(cdLimit);
            data.add(lo);
            data.add(loLimit);

            CustomerWealthGetProductSummary.updateOsc17ToCustomer(acct.Id, data);

            Account accTemp = [Select Osc17TempValueJson__c From Account Where id=: acct.Id LIMIT 1];
            System.assertNotEquals('', accTemp.Osc17TempValueJson__c);
        Test.stopTest();
    }

    public static testMethod void test_method_calloutOsc16_17() {
        Account acct = new Account(Name='TestAcct1'
                                  ,Mobile_Number_PE__c='0123456789'
                                  ,Account_Type__c='Retail Customer'
                                  ,TMB_Customer_ID_PE__C='001100000000000000000000011498'
                                  ,ID_Type_PE__c='Citizen ID'
                                  ,ID_Number_PE__c='3100500981853');
        insert acct;

        User u = [SELECT Id,Name FROM User WHERE Email = 'wealth@tmb.com.test' LIMIT 1];

        System.runAs(u){
            Test.startTest();
            // Set mock callout class
            // Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
            // AuthenticationToken authenTokenCalculateTools = SmartBDM_Service.startCallGetTokenService('Smart_BDM_Cal_Tools_Create_Token');

            Continuation conti = (Continuation)CustomerWealthGetProductSummary.startCallAllProducts(acct.Id, 'Smart_BDM_Cal_Tools_Create_Token', 'GetCustomerWealth');
            
            Map<String, HttpRequest> requests = conti.getRequests();
            List<String> labels = new List<String>();
            labels.add('Continuation-1');
            labels.add('Continuation-2');
			// Set the fake response for the continuation
			// String requestLabel = requests.keyset().iterator().next();
            HttpResponse response1 = new HttpResponse();
			response1.setBody('{"status":{"code": "0000","description": "Success"},"bancassurances":[{"sumInsure": "100000"}],"total": 1}');
			response1.setStatusCode(200);
            HttpResponse response2 = new HttpResponse();
            response2.setBody('{"Header":null,"GetCustomerWealth":{"CustomerInformation":{"Customername":"นายRM09863866NAMETEST","TranssactionCreateDate":"20100530","WealthStatus":"SB"},"CustomerCreditLine":"240000",'
                            + '"CustomerDeposit":[{"ProductType":"com.fnis.xes.MF","AccountType":"MFA","SumAvaiBalance":28038.9},{"ProductType":"com.fnis.xes.ST","AccountType":"CDA","SumAvaiBalance":5932.45}],'
                            + '"CustomerNonDeposit":[{"ProductType":"com.fnis.xes.CC","AccountType":"CCA","SumAvaiBalance":300}],'
                            + '"CustomerLoan":{"TotalTermLoanLimit":600000,"TotalTermLoanBalance":68096.98,"TotalSecureLoanLimit":4622000,"TotalSecureLoanBalance":3627099.93,"TotalUnsecureLoanLimit":350000,"TotalUnsecureLoanBalance":185880.13}}}');
			response2.setStatusCode(200);
			Test.setContinuationResponse(labels[0], response1);
            Test.setContinuationResponse(labels[1], response2);
			// Invoke callback method
            // respone is successesful
            CustomerWealthGetProductSummary.ContinuationState cs = new CustomerWealthGetProductSummary.ContinuationState('Test Success',u.name,'001100000000000000000000011498','requestBody', Datetime.now(), acct);
			List<List<String>> resultWC1 = CustomerWealthGetProductSummary.processResponseAllProduct(labels, cs);
            System.assertNotEquals(0, resultWC1.size());
            
            // respone is timeout
            // OSC16
            try{
                response1 = new HttpResponse();
                response1.setBody('');
                response1.setStatusCode(2000);
                response2 = new HttpResponse();
                response2.setBody('');
                response2.setStatusCode(2000);
                Test.setContinuationResponse(labels[0], response1);
                Test.setContinuationResponse(labels[1], response2);
                cs = new CustomerWealthGetProductSummary.ContinuationState('Test Error Timeout',u.name,'001100000000000000000000011498','requestBody', Datetime.now(), acct);
                resultWC1 = CustomerWealthGetProductSummary.processResponseAllProduct(labels, cs);
            }
            catch(Exception e){
                system.assertEquals(true, e.getMessage().contains(System.Label.Customer_Product_Timeout));
            }
            // OSC17
            try{
                response1 = new HttpResponse();
                response1.setBody('{"status":{"code": "0000","description": "Success"},"bancassurances":[{"sumInsure": "100000"}],"total": 1}');
                response1.setStatusCode(200);
                response2 = new HttpResponse();
                response2.setBody('');
                response2.setStatusCode(2000);
                Test.setContinuationResponse(labels[0], response1);
                Test.setContinuationResponse(labels[1], response2);
                cs = new CustomerWealthGetProductSummary.ContinuationState('Test Error Timeout',u.name,'001100000000000000000000011498','requestBody', Datetime.now(), acct);
                resultWC1 = CustomerWealthGetProductSummary.processResponseAllProduct(labels, cs);
            }
            catch(Exception e){
                system.assertEquals(true, e.getMessage().contains(System.Label.Customer_Product_Timeout));
            }
            
            // respone is other error
            // OSC16
            try{
                response1 = new HttpResponse();
                response1.setBody('');
                response1.setStatusCode(9999);
                response2 = new HttpResponse();
                response2.setBody('');
                response2.setStatusCode(9999);
                Test.setContinuationResponse(labels[0], response1);
                Test.setContinuationResponse(labels[1], response2);
                cs = new CustomerWealthGetProductSummary.ContinuationState('Test Other Error',u.name,'001100000000000000000000011498','requestBody', Datetime.now(), acct);
                resultWC1 = CustomerWealthGetProductSummary.processResponseAllProduct(labels, cs);
            }
            catch(Exception e){
                system.assertEquals(true, e.getMessage().contains(System.Label.Customer_Product_ERR001));
            }
            // OSC17
            try{
                response1 = new HttpResponse();
                response1.setBody('{"status":{"code": "0000","description": "Success"},"bancassurances":[{"sumInsure": "100000"}],"total": 1}');
                response1.setStatusCode(200);
                response2 = new HttpResponse();
                response2.setBody('');
                response2.setStatusCode(9999);
                Test.setContinuationResponse(labels[0], response1);
                Test.setContinuationResponse(labels[1], response2);
                cs = new CustomerWealthGetProductSummary.ContinuationState('Test Other Error',u.name,'001100000000000000000000011498','requestBody', Datetime.now(), acct);
                resultWC1 = CustomerWealthGetProductSummary.processResponseAllProduct(labels, cs);
            }
            catch(Exception e){
                system.assertEquals(true, e.getMessage().contains(System.Label.Customer_Product_ERR001));
            }
            
            // catch Exception response body is null
            // OSC16
            try{
                response1 = new HttpResponse();
                response1.setBody('');
                response1.setStatusCode(200);
                response2 = new HttpResponse();
                response2.setBody('');
                response2.setStatusCode(200);
                Test.setContinuationResponse(labels[0], response1);
                Test.setContinuationResponse(labels[1], response2);
                cs = new CustomerWealthGetProductSummary.ContinuationState('Test Response Body null',u.name,'001100000000000000000000011498','requestBody', Datetime.now(), acct);
                resultWC1 = CustomerWealthGetProductSummary.processResponseAllProduct(labels, cs);
            }
            catch(Exception e){
                system.assertEquals(true, e.getMessage().contains(System.Label.Customer_Product_ERR001));
            }
            // OSC17
            try{
                response1 = new HttpResponse();
                response1.setBody('{"status":{"code": "0000","description": "Success"},"bancassurances":[{"sumInsure": "100000"}],"total": 1}');
                response1.setStatusCode(200);
                response2 = new HttpResponse();
                response2.setBody('');
                response2.setStatusCode(200);
                Test.setContinuationResponse(labels[0], response1);
                Test.setContinuationResponse(labels[1], response2);
                cs = new CustomerWealthGetProductSummary.ContinuationState('Test Response Body null',u.name,'001100000000000000000000011498','requestBody', Datetime.now(), acct);
                resultWC1 = CustomerWealthGetProductSummary.processResponseAllProduct(labels, cs);
            }
            catch(Exception e){
                system.assertEquals(true, e.getMessage().contains(System.Label.Customer_Product_ERR001));
            }
            
            // respone is null
            // try{
            //     response1 = new HttpResponse();
            //     response2 = new HttpResponse();
            //     Test.setContinuationResponse(labels[0], response1);
            //     Test.setContinuationResponse(labels[1], response2);
            //     cs = new CustomerWealthGetProductSummary.ContinuationState('Test Response null',u.name,'001100000000000000000000011498','requestBody', Datetime.now(), acct);
            //     resultWC1 = CustomerWealthGetProductSummary.processResponseAllProduct(labels, cs);
            // }
            // catch(Exception e){
            //     system.assertEquals(true, e.getMessage().contains(System.Label.Customer_Product_ERR001));
            // }

            Test.stopTest();
        }
    }

}