@isTest
public class RTL_CustomerRelationshipExtensionTest {
    static {
        TestUtils.createAppConfig();      
    }
    
    public static testMethod void testExtController() {
        Account acct = new Account(Name='TestAcct1',Mobile_Number_PE__c='0123456789',Account_Type__c='Retail Customer',TMB_Customer_ID_PE__C='001100000000000000000000011498');
        insert acct;
        Test.setMock(WebServiceMock.class, new RTL_CvsAnalyticsDataServiceMockImpl());
        
        TEST.startTest();
            //1st time the two values should be blank
            acct = [select Id, RTL_OTC_ATM_ADM_IB_MIB__c, RTL_MIB_Status__c from Account where Id=:acct.Id];
            System.assertEquals(NULL, acct.RTL_OTC_ATM_ADM_IB_MIB__c);
            System.assertEquals(NULL, acct.RTL_MIB_Status__c);
            acct.RTL_OTC_ATM_ADM_IB_MIB__c = '20:10:10:20:20:20';
            acct.RTL_MIB_Status__c = 'Applied';
            update acct;
            //after calling controller, the value is retrieved from webservices
            ApexPages.StandardController controller = new ApexPages.StandardController(acct);
            RTL_CustomerRelationshipExtension extController = new RTL_CustomerRelationshipExtension(controller);
            // as controller calls online service, there is no value for the two fields. 
            // add test values
            extController.rtl_OtcAtmAdmIbMib='20:10:10:20:20:20';
            extController.rtl_MibStatus='Applied';
            //after calling action method, the value is persistent in DB
            //extController.updateAccount();
            acct = [select Id, RTL_OTC_ATM_ADM_IB_MIB__c, RTL_MIB_Status__c from Account where Id=:acct.Id];
            System.assert(acct.RTL_OTC_ATM_ADM_IB_MIB__c.length() > 0);
            System.assert(acct.RTL_MIB_Status__c.length() > 0);   
            System.assertEquals(false, extController.isSF1);

        Test.stopTest();
    }

    public static testMethod void testWebService() {
        Account acct = new Account(Name='TestAcct1',Mobile_Number_PE__c='0123456789',Account_Type__c='Retail Customer',TMB_Customer_ID_PE__C='001100000000000000000000011498');
        insert acct;

        RTL_TestUtility.createBranchZone(1,true);
        Test.setMock(WebServiceMock.class, new RTL_CvsAnalyticsDataServiceMockImpl());
        
        TEST.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(acct);
            RTL_CustomerRelationshipExtension extController = new RTL_CustomerRelationshipExtension(controller);
             // Invoke the continuation by calling the action method
            Continuation conti = (Continuation)extController.startRequest();

            String notAuthorized = extController.notAuthorizedMsg;
            extController.loadData();
            extController.loadParameter();
            String hiddenTxt = extController.hiddenText;
            String empCode = extController.empBrCode_userId;
     
            // Verify that the continuation has the proper requests
            Map<String, HttpRequest> requests = conti.getRequests();
            System.assertEquals(requests.size(), 1);

            // Perform mock callout 
            // (i.e. skip the callout and call the callback method)
            HttpResponse response = new HttpResponse();
            response.setBody(
                '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
                +'<soap:Body>'
                +'<ns2:getCVSAnalyticsDataResponse xmlns:ns2="http://www.tmbbank.com/CVSAnalyticsData/">'
                +'<Result>'
                +'<Status>SUCCESS</Status>'
                +'<MIBStatus>YES/YES</MIBStatus>'
                +'<UsagePercentage>0:37:5:18:21:18</UsagePercentage>'
                +'<suitability>4</suitability>'
                +'<touchStatus>YES</touchStatus>'
                +'<ibStatus>YES</ibStatus>'
                +'<csProfFreqBr>001</csProfFreqBr>'
                +'<afPrivilegeFlag>Y</afPrivilegeFlag>'
                +'</Result>'
                +'</ns2:getCVSAnalyticsDataResponse>'
                +'</soap:Body>'
                +'</soap:Envelope>');

            // Set the fake response for the continuation
            String requestLabel = requests.keyset().iterator().next();
            Test.setContinuationResponse(requestLabel, response);

            // Invoke callback method
            Object result = Test.invokeContinuationMethod(extController, conti); 

        Test.stopTest();
    }

    public static testMethod void testWebServiceFailed() {
        Account acct = new Account(Name='TestAcct1',Mobile_Number_PE__c='0123456789',Account_Type__c='Retail Customer',TMB_Customer_ID_PE__C='001100000000000000000000011498');
        insert acct;
        Test.setMock(WebServiceMock.class, new RTL_CvsAnalyticsDataServiceMockImpl());
        
        TEST.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(acct);
            RTL_CustomerRelationshipExtension extController = new RTL_CustomerRelationshipExtension(controller);
             // Invoke the continuation by calling the action method
            Continuation conti = (Continuation)extController.startRequest();

            extController.loadData();
            extController.loadParameter();
     
            // Verify that the continuation has the proper requests
            Map<String, HttpRequest> requests = conti.getRequests();
            System.assertEquals(requests.size(), 1);

            // Perform mock callout 
            // (i.e. skip the callout and call the callback method)
            HttpResponse response = new HttpResponse();
            response.setBody(
                '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
                +'<soap:Body>'
                +'<ns2:getCVSAnalyticsDataResponse xmlns:ns2="http://www.tmbbank.com/CVSAnalyticsData/">'
                +'<Result>'
                +'<Status>ERROR</Status>'
                +'</Result>'
                +'</ns2:getCVSAnalyticsDataResponse>'
                +'</soap:Body>'
                +'</soap:Envelope>');

            // Set the fake response for the continuation
            String requestLabel = requests.keyset().iterator().next();
            Test.setContinuationResponse(requestLabel, response);

            // Invoke callback method
            Object result = Test.invokeContinuationMethod(extController, conti); 

        Test.stopTest();
    }

    public static testMethod void testWebServiceNoResponse() {
        Account acct = new Account(Name='TestAcct1',Mobile_Number_PE__c='0123456789',Account_Type__c='Retail Customer',TMB_Customer_ID_PE__C='001100000000000000000000011498');
        insert acct;
        Test.setMock(WebServiceMock.class, new RTL_CvsAnalyticsDataServiceMockImpl());
        
        TEST.startTest();

            PageReference pageRef = Page.RTL_CustomerData_CR;
            pageRef.getParameters().put('sfdcIFrameHost','sf1');
            Test.setCurrentPage(pageRef);

            ApexPages.StandardController controller = new ApexPages.StandardController(acct);
            RTL_CustomerRelationshipExtension extController = new RTL_CustomerRelationshipExtension(controller);
             // Invoke the continuation by calling the action method
            Continuation conti = (Continuation)extController.startRequest();

            Boolean sf1 = extController.isSF1;
            extController.loadData();
            extController.loadParameter();
            extController.formatPrivilege2(null);
     
            // Verify that the continuation has the proper requests
            Map<String, HttpRequest> requests = conti.getRequests();
            System.assertEquals(requests.size(), 1);

            // Perform mock callout 
            // (i.e. skip the callout and call the callback method)
            HttpResponse response = new HttpResponse();
            response.setBody('');

            // Set the fake response for the continuation
            String requestLabel = requests.keyset().iterator().next();
            Test.setContinuationResponse(requestLabel, response);

            // Invoke callback method
            Object result = Test.invokeContinuationMethod(extController, conti); 

            

        Test.stopTest();
    }
}