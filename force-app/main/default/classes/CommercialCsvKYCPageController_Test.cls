@isTest
public class CommercialCsvKYCPageController_Test {

    // AppConfig__c.getValues('runtrigger').Value__c
    static ApexPages.StandardController stdController;

    static void init(){
		Account acct2 = new Account();
        acct2.First_Name_PE__c = 'test acct';
        acct2.Last_Name_PE__c = '001';
        acct2.First_Name_ENG_PE__c = 'SathianP';
        acct2.Last_Name_PE_Eng__c = 'KD';
        acct2.Name = acct2.First_Name_PE__c + ' ' + acct2.Last_Name_PE__c;
        acct2.Email_Address_PE__c = 'satian@tmb.com';
        acct2.Mobile_Number_PE__c = '0998877665';
        acct2.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acct2.Account_Type__c = 'Retail Customer';
        acct2.ID_Type_PE__c = 'Citizen ID';
        acct2.ID_Number_PE__c = '4496799264466';
        acct2.RTL_NID__c = '44466';
        acct2.TMB_Customer_ID_PE__c = '001100000001100000000000000500';
        // acct = acct2;
        insert acct2;
        
        PageReference testPage = Page.CommercialCsvKYCSectionPage; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(acct2.Id));

        // ApexPages.StandardController stdController2 = new  ApexPages.StandardController(acct2);
        stdController = new  ApexPages.StandardController(acct2);
    }

    @testSetup static void setup() {
        TestUtils.createAppConfig();
    }
    
    @isTest static void testInitialDataCalloutSuccess () {
        init();
        CommercialCsvKYCSectionPageController controller = new CommercialCsvKYCSectionPageController(stdController);
        Integer retryDelay = CommercialCsvKYCSectionPageController.cvsRetryDelay; // for coverage
        String last_login = controller.last_login; // for coverage
        CommercialCsvKYCSectionPageController controller2 = new CommercialCsvKYCSectionPageController(); // for coverage

        String response = '{'+
            '\"GetCVSAnalyticsDataResponse\": {'+
              '\"Result\": {'+
                '\"Status\": \"SUCCESS\",'+
                '\"MIBStatus\": \"YES/YES\",'+
                '\"UsagePercentage\": \"0:1:0:0:1:0\",'+
                '\"LastLoginSuccessDate\": \"2022-02-09\",'+
                '\"suitability\": \"4\",'+
                '\"currentPrivilege2Desc\": \"NO FIXED\",'+
                '\"touchStatus\": \"YES\",'+
                '\"ibStatus\": \"NO\"'+
              '}'+
            '},'+
            '\"Status\": {'+
              '\"StatusCode\": \"200\",'+
              '\"StatusDesc\": \"Success\"'+
            '}'+
          '}';
        

        // Test.stopTest()
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200,response));
            // HttpResponse res = CalloutClass.getInfoFromExternalService(myCase.Id);
            controller.initialData();
        Test.stopTest();
    }

    @isTest static void testNoTouchStatus () {
        init();
        CommercialCsvKYCSectionPageController controller = new CommercialCsvKYCSectionPageController(stdController);
        
        String response = '{'+
            '\"GetCVSAnalyticsDataResponse\": {'+
              '\"Result\": {'+
                '\"Status\": \"SUCCESS\",'+
                '\"MIBStatus\": \"YES/YES\",'+
                '\"UsagePercentage\": \"0:1:0:0:1:0\",'+
                '\"LastLoginSuccessDate\": \"2022-02-09\",'+
                '\"suitability\": \"4\",'+
                '\"currentPrivilege2Desc\": \"NO FIXED\",'+
                '\"touchStatus\": \"NO\",'+
                '\"ibStatus\": \"NO\"'+
              '}'+
            '},'+
            '\"Status\": {'+
              '\"StatusCode\": \"200\",'+
              '\"StatusDesc\": \"Success\"'+
            '}'+
          '}';
        

        // Test.stopTest()
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200,response));
            // HttpResponse res = CalloutClass.getInfoFromExternalService(myCase.Id);
            controller.initialData();
        Test.stopTest();
    }

    @isTest static void testRetryTimeout () {
        init();
        CommercialCsvKYCSectionPageController controller = new CommercialCsvKYCSectionPageController(stdController);
        controller.cvsRetryRemain = 0;
        
        String response = '{'+
            '\"Status\": {'+
              '\"StatusCode\": \"401\",'+
              '\"StatusDesc\": \"invalid_token\"'+
            '}'+
          '}';
        

        // Test.stopTest()
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(401,response));
            // HttpResponse res = CalloutClass.getInfoFromExternalService(myCase.Id);
            controller.initialData();
        Test.stopTest();
    }

    @isTest static void testCalloutError () {
        init();
        CommercialCsvKYCSectionPageController controller = new CommercialCsvKYCSectionPageController(stdController);

        String response = 'invalid format';
        
        // Test.stopTest()
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200,response));
            // HttpResponse res = CalloutClass.getInfoFromExternalService(myCase.Id);
            controller.initialData();
        Test.stopTest();
    }

    @isTest static void testSetCVSRetryState () {
        init();
        CommercialCsvKYCSectionPageController controller = new CommercialCsvKYCSectionPageController(stdController);
        
        CVSAnalyticsDataDTO osc07 = new CVSAnalyticsDataDTO();
        osc07.Status = '';
        osc07.Message = '';
        osc07.MIBStatus = '';
        osc07.UsagePercentage = '';
        osc07.LastLoginSuccessDate = '';
        osc07.suitability = '';
        osc07.privilege = '';
        osc07.privilege2Url = '';
        osc07.currentPrivilege2Desc = '';
        osc07.entitledPrivilege2Desc = '';
        osc07.afPrivilegeFlag = '';
        osc07.touchStatus = '';
        osc07.ibStatus = '';
        osc07.csProfFreqBr = '';
        osc07.csProfAvgaum12m = 1;
        osc07.csProfAvgaum12mDt = Date.today();
        osc07.csProfSubsegment = '';
        osc07.csProfWealthExpDt = '';
        osc07.SoapStatus = '';
    	osc07.SoapMessage = '';

        Test.startTest();
            controller.setCVSRetryState();
            controller.recordId = '0019000001xxxxx';
            controller.getCustomerData();
        Test.stopTest();
    }

    @isTest static void testSetTouchStatusVariable () {
        init();
        CommercialCsvKYCSectionPageController controller = new CommercialCsvKYCSectionPageController(stdController);
        ApexPages.currentPage().getParameters().put('tmsg', 'testmessage'); 
        Test.startTest();
            controller.setTouchStatusVariable();
        Test.stopTest();
    }
}