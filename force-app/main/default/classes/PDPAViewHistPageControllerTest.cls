@isTest
public class PDPAViewHistPageControllerTest {
    
    public static Account account;
    
    @testSetup 
    static void setup() {
        System.debug('TestSetup::');
        AppConfig__c configTriger = new AppConfig__c();
        configTriger.Name = 'runtrigger';
        configTriger.Value__c = 'true';
        insert configTriger;
        
        AppConfig__c configTimeout = new AppConfig__c();
        configTimeout.Name = 'PDPA_Timeout';
        configTimeout.Value__c = '2';
        insert configTimeout;
        
        Account acct = new Account();
        acct.First_Name_PE__c = 'Normal';
        acct.Last_Name_PE__c = 'Account';
        acct.Name = acct.First_Name_PE__c + ' ' + acct.Last_Name_PE__c;
        acct.Email_Address_PE__c = 'satian@tmb.com';
        acct.Mobile_Number_PE__c = '0123456789';
        acct.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acct.Account_Type__c = 'Retail Customer';
        acct.ID_Type_PE__c = 'Citizen ID';
        acct.ID_Number_PE__c = '4496799264466';
        acct.RTL_NID__c = '44466';
        acct.TMB_Customer_ID_PE__c = '001100000001100000000009399743';                
        insert acct;
        
        Account acctNoTMBId = new Account();
        acctNoTMBId.First_Name_PE__c = 'เสถียรพร';
        acctNoTMBId.Last_Name_PE__c = 'คำดี';
        acctNoTMBId.Name = acctNoTMBId.First_Name_PE__c + ' ' + acctNoTMBId.Last_Name_PE__c;
        acctNoTMBId.Email_Address_PE__c = 'satian@tmb.com';
        acctNoTMBId.Mobile_Number_PE__c = '9876543210';
        acctNoTMBId.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acctNoTMBId.Account_Type__c = 'Retail Customer';
        acctNoTMBId.ID_Type_PE__c = 'Citizen ID';
        acctNoTMBId.ID_Number_PE__c = '4496799264466';
        acctNoTMBId.RTL_NID__c = '44444';
        acctNoTMBId.TMB_Customer_ID_PE__c = '';                
        insert acctNoTMBId;
        
        PDPAMapping__c type1 = new PDPAMapping__c(Name = 'MARKET', 
                                                 Description_TH__c = 'การให้ความยินยอมในการเปิดเผยข้อมูลให้บุคคลอื่นเพื่อวัตถุประสงค์ทางการตลาด',
                                                 Description__c = 'Consent for Disclosure of Information for Marketing Purpose',
                                                 Display_Type__c = 'Market Conduct'
                                                 );
        insert type1;
        
        PDPAMapping__c type2 = new PDPAMapping__c(Name = 'PDPA-DEPOSIT', 
                                                 Description_TH__c = 'การให้ความยินยอมในการเปิดเผยข้อมูลส่วนบุคคลตามพ.ร.บ.คุ้มครองข้อมูลส่วนบุคคล',
                                                 Description__c = 'Consent for Disclosure of Personal Information',
                                                 Display_Type__c = 'PDPA'
                                                 );
        insert type2;
        
        account = [SELECT id, name, Email_Address_PE__c, Mobile_Number_PE__c, RecordtypeId, Account_Type__c, ID_Type_PE__c, ID_Number_PE__c, RTL_NID__c, TMB_Customer_ID_PE__c 
                   FROM Account 
                   WHERE Account_Type__c = 'Retail Customer' 
                   LIMIT 1];
    }
    
    @isTest
    static void testController(){
        System.debug('TestController\n\n');
        test.startTest();

        account = [SELECT id, name, Email_Address_PE__c, Mobile_Number_PE__c, RecordtypeId, Account_Type__c, ID_Type_PE__c, ID_Number_PE__c, RTL_NID__c, TMB_Customer_ID_PE__c 
                   FROM Account 
                   WHERE Account_Type__c = 'Retail Customer' 
                   LIMIT 1];
       
        System.debug('\n\n'+account);
        PageReference pageRef = Page.PDPAViewHistPage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdAccount = new ApexPages.StandardController(account);
        PDPAViewHistPageController controller = new PDPAViewHistPageController(stdAccount);
        //No service
		controller.calloutConsentHist();
        
        //Normal Test
        Test.setMock(HttpCalloutMock.class, new PDPAViewHistHttpCalloutMock());
        stdAccount = new ApexPages.StandardController(account);
        controller = new PDPAViewHistPageController(stdAccount);
		controller.calloutConsentHist();
        controller.paginationNext();
        controller.paginationPrevious();
                
        //No TMBCustID
        account = [SELECT id, name, Email_Address_PE__c, Mobile_Number_PE__c, RecordtypeId, Account_Type__c, ID_Type_PE__c, ID_Number_PE__c, RTL_NID__c, TMB_Customer_ID_PE__c 
                   FROM Account 
                   WHERE RTL_NID__c = '44444' 
                   LIMIT 1];
        
		Test.setMock(HttpCalloutMock.class, new PDPAViewHistHttpCalloutMock());
        stdAccount = new ApexPages.StandardController(account);
        controller = new PDPAViewHistPageController(stdAccount);
		controller.calloutConsentHist();
        test.stopTest();
        
    }
    //callHistService Test already tested by PDPAViewHistControllerTest

    @isTest
    static void testRetryState() {
        System.debug('TestController\n\n');
        // test.startTest();

        account = [SELECT id, name, Email_Address_PE__c, Mobile_Number_PE__c, RecordtypeId, Account_Type__c, ID_Type_PE__c, ID_Number_PE__c, RTL_NID__c, TMB_Customer_ID_PE__c 
                   FROM Account 
                   WHERE Account_Type__c = 'Retail Customer' 
                   LIMIT 1];
       
        System.debug('\n\n'+account);
        PageReference pageRef = Page.PDPAViewHistPage;
        Test.setCurrentPage(pageRef);
        
        //Normal Test
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PDPAViewHistHttpCalloutMock());
            ApexPages.StandardController stdAccount = new ApexPages.StandardController(account);
            PDPAViewHistPageController controller = new PDPAViewHistPageController(stdAccount);
            Integer retryDelay = PDPAViewHistPageController.pdpaHisRetryDelay; // for coverage
            controller.setPDPAHisRetryState();
        Test.stopTest();
    }

    @isTest
    static void testResponseSuccess() {
        account = [SELECT id, name, Email_Address_PE__c, Mobile_Number_PE__c, RecordtypeId, Account_Type__c, ID_Type_PE__c, ID_Number_PE__c, RTL_NID__c, TMB_Customer_ID_PE__c 
                   FROM Account 
                   WHERE Account_Type__c = 'Retail Customer' 
                   LIMIT 1];
       
        System.debug('\n\n'+account);
        PageReference pageRef = Page.PDPAViewHistPage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdAccount = new ApexPages.StandardController(account);

        String response = '{'+
            '\"data\": {'+
              '\"customerId\": \"0000001\",'+
              '\"financialId\": \"0000001\",'+
              '\"consents\": ['+
                    '{'+
                        '\"type\": \"PDPA-DEPOSIT\",'+
                        '\"flag\": \"Y\",'+
                        '\"consentDateTime\":\"2022-01-01\",'+
                        '\"consentSignDate\":\"2022-01-01\"'+
                    '},'+
                    '{'+
                        '\"type\": \"MARKET\",'+
                        '\"flag\": \"N\",'+
                        '\"consentDateTime\":\"2022-01-01\",'+
                        '\"consentSignDate\":\"2022-01-01\"'+
                    '}'+
                ']'+
              '},'+
            '\"status\": {'+
                '\"code\": \"0000\",'+
                '\"description\": \"Success\"'+
            '}'+
          '}';
        

        // Test.stopTest()
        Test.startTest();
            
            PDPAViewHistPageController controller = new PDPAViewHistPageController(stdAccount);
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200,response));
            //No service
            controller.calloutConsentHist();
        Test.stopTest();
    }

    @isTest
    static void testException() {
        account = [SELECT id, name, Email_Address_PE__c, Mobile_Number_PE__c, RecordtypeId, Account_Type__c, ID_Type_PE__c, ID_Number_PE__c, RTL_NID__c, TMB_Customer_ID_PE__c 
                   FROM Account 
                   WHERE Account_Type__c = 'Retail Customer' 
                   LIMIT 1];
       
        System.debug('\n\n'+account);
        account.Id = '001O000002FoUYtIAN'; // invalid id
        PageReference pageRef = Page.PDPAViewHistPage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdAccount = new ApexPages.StandardController(account);

        String response = ' '; // invalid response
        

        // Test.stopTest()
        Test.startTest();
            
            PDPAViewHistPageController controller = new PDPAViewHistPageController(stdAccount);
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200,response));
            //No service
            controller.calloutConsentHist();
        Test.stopTest();
    }

    @isTest
    static void testParseJsonException() {
        account = [SELECT id, name, Email_Address_PE__c, Mobile_Number_PE__c, RecordtypeId, Account_Type__c, ID_Type_PE__c, ID_Number_PE__c, RTL_NID__c, TMB_Customer_ID_PE__c 
                   FROM Account 
                   WHERE Account_Type__c = 'Retail Customer' 
                   LIMIT 1];
       
        System.debug('\n\n'+account);
        PageReference pageRef = Page.PDPAViewHistPage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdAccount = new ApexPages.StandardController(account);

        String response = '{'+
            '\"data2\": {'+
              '\"customerId\": \"0000001\",'+
              '\"financialId\": \"0000001\",'+
              '\"consents\": ['+
                    '{'+
                        '\"type\": \"PDPA-DEPOSIT\",'+
                        '\"flag\": \"Y\",'+
                        '\"consentDateTime\":\"2022-01-01\",'+
                        '\"consentSignDate\":\"2022-01-01\"'+
                    '},'+
                    '{'+
                        '\"type\": \"MARKET\",'+
                        '\"flag\": \"N\",'+
                        '\"consentDateTime\":\"2022-01-01\",'+
                        '\"consentSignDate\":\"2022-01-01\"'+
                    '}'+
                ']'+
              '},'+
            '\"status\": {'+
                '\"code\": \"0000\",'+
                '\"description\": \"invalid_token\"'+
            '}'+
          '}';
        

        // Test.stopTest()
        Test.startTest();
            PDPAViewHistPageController controller = new PDPAViewHistPageController(stdAccount);
            controller.pdpaHisRetryRemain = 0;
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200,response));
            //No service
            controller.calloutConsentHist();
        Test.stopTest();
    }

    @isTest
    static void testError() {
        account = [SELECT id, name, Email_Address_PE__c, Mobile_Number_PE__c, RecordtypeId, Account_Type__c, ID_Type_PE__c, ID_Number_PE__c, RTL_NID__c, TMB_Customer_ID_PE__c 
                   FROM Account 
                   WHERE Account_Type__c = 'Retail Customer' 
                   LIMIT 1];
       
        System.debug('\n\n'+account);
        PageReference pageRef = Page.PDPAViewHistPage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdAccount = new ApexPages.StandardController(account);

        String response = '{'+
            '\"data\": {'+
              '\"customerId\": \"0000001\",'+
              '\"financialId\": \"0000001\",'+
              '\"consents\": ['+
                    '{'+
                        '\"type\": \"PDPA-DEPOSIT\",'+
                        '\"flag\": \"Y\",'+
                        '\"consentDateTime\":\"2021-01-01\",'+
                        '\"consentSignDate\":\"2021-01-01\"'+
                    '},'+
                    '{'+
                        '\"type\": \"MARKET\",'+
                        '\"flag\": \"N\",'+
                        '\"consentDateTime\":\"2022-01-01\",'+
                        '\"consentSignDate\":\"2022-01-01\"'+
                    '},'+
                    '{'+
                        '\"type\": \"MARKET\",'+
                        '\"flag\": \"N\",'+
                        '\"consentDateTime\":\"2022-01-01\",'+
                        '\"consentSignDate\":\"2022-01-01\"'+
                    '}'+
                ']'+
              '},'+
            '\"status\": {'+
                '\"code\": \"0000\",'+
                '\"description\": \"Success\"'+
            '}'+
          '}';
        

        // Test.stopTest()
        Test.startTest();
            
            PDPAViewHistPageController controller = new PDPAViewHistPageController(stdAccount);
            controller.isError = true;
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200,response));
            //No service
            controller.calloutConsentHist();
        Test.stopTest();
    }
}