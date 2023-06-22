@isTest
public with sharing class PDPAWebserviceCtlTest {

    static Account Acct;
    static boolean sutUpdataDone = false;
    public static testmethod void succesResponse(){
        if(!sutUpdataDone){
            setupData();  
        } 
        Test.startTest();
        String responseBody = '{"status": {"code": "0000","description": "Success"},"data": ';
        responseBody = responseBody + '{"customerId": "00000000000122","financialId": "0011000000000000","consents": [';
        responseBody = responseBody + '{"type": "MARKET","flag": "N","version": "3","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:05",';
        responseBody = responseBody + '"consentSignDate": "2020-01-02","needUpdateFlag": "N","needUpdateFlagReason": ""},';
        responseBody = responseBody + '{"type": "DATA-ANALYTIC","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
        responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": "" },';
        responseBody = responseBody + '{ "type": "PDPA-DEPOSIT","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
        responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": ""}]}}';

        Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, responseBody));
        ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
        PDPAWebserviceCtl accResult= new PDPAWebserviceCtl(pdpaAcc);
        accResult.viewPDPA();

        Test.stopTest();

        }

        
    public static testmethod void thailandList(){
        if(!sutUpdataDone){
            setupData();  
        } 
        Test.startTest(); 

        String responseBody = '{"status": {"code": "0000","description": "Success"},"data": ';
            responseBody = responseBody + '{"customerId": "00000000000122","financialId": "0011000000000000","consents": [';
            responseBody = responseBody + '{ "type": "PDPA-DEPOSIT","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
            responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": "TS2000"}]}}';

        Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, responseBody));
        ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
        PDPAWebserviceCtl accResult= new PDPAWebserviceCtl(pdpaAcc);
        accResult.viewPDPA();
        
        Test.stopTest();

    }

    public static testmethod void errorResponse(){
        if(!sutUpdataDone){
            setupData();  
        }
        Test.startTest(); 
        String responseBody = '{"status": {"code": "500","description": "Exception while executing: \nUnknown\nYou cannot compare a value of type ::null."}}';
        Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(500, responseBody));
        ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
        PDPAWebserviceCtl accResult= new PDPAWebserviceCtl(pdpaAcc);
        accResult.viewPDPA();
        
        Test.stopTest();

    }


    public static testmethod void saveSuccess(){
        if(!sutUpdataDone){
            setupData();  
        }
        User currentUser = [Select ID, Employee_ID__c, UserProfileName__c from User where id =: UserInfo.getUserId()]; 
        Test.startTest(); 

        system.runAs(currentUser){
            PageReference pageRef = Page.PDPAScreenUpdateComponent;
            pageRef.getParameters().put('pdpatype', 'PDPA');
            Test.setCurrentPage(pageRef); 
            ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
            PDPAWebserviceCtl accResult = new PDPAWebserviceCtl(pdpaAcc);
            String responseBody1 = '{"status": { "code": "0000", "description": "Success" }}';
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, responseBody1));
            accResult.saveForm();
        }
        Test.stopTest();

    }
    
    public static testmethod void saveFail1(){
        if(!sutUpdataDone){
            setupData();  
        }
        User currentUser = [Select ID, Employee_ID__c, UserProfileName__c from User where id =: UserInfo.getUserId()]; 
        Test.startTest(); 

        system.runAs(currentUser){

            ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
            PDPAWebserviceCtl accResult = new PDPAWebserviceCtl(pdpaAcc);  
            String responseBody = '{"status": {"code": "0000","description": "Success"},';
                responseBody = responseBody + '"data": {"customerId": "00000000000122","financialId": "0011000000000000","consents": [';
                responseBody = responseBody + '{"type": "PDPA-DEPOSIT","flag": "Y","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-28T10:03:57",';
                responseBody = responseBody + '"consentSignDate": "2020-02-28" }]}}';
        
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, responseBody)); 
            accResult.viewPDPA();

            String responseBody1 = '{"status": { "code": "0000", "description": "Success" }}';
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, responseBody1));
            accResult.saveForm();   
            List<SelectOption> option = accResult.getFlag();            

        }
        Test.stopTest();

    }

    @isTest
    public static void saveFailFlagNull(){
        if(!sutUpdataDone){
            setupData();  
        }
        User currentUser = [Select ID, Employee_ID__c, UserProfileName__c from User where id =: UserInfo.getUserId()]; 
        Test.startTest(); 

            ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
            PDPAWebserviceCtl accResult = new PDPAWebserviceCtl(pdpaAcc);  
            String responseBody = '{"status": {"code": "0000","description": "Success"},';
                responseBody = responseBody + '"data": {"customerId": "00000000000122","financialId": "0011000000000000","consents": [';
                responseBody = responseBody + '{"type": "PDPA-DEPOSIT","flag": "N","needUpdateFlag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-28T10:03:57",';
                responseBody = responseBody + '"consentSignDate": "2020-02-28" }]}}';
            
            
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, responseBody)); 
            accResult.viewPDPA();

            // String responseBody1 = '{"status": { "code": "0000", "description": "Success" }}';
            // Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, responseBody1));
            // accResult.saveForm();   
            // List<SelectOption> option = accResult.getFlag();            

        Test.stopTest();
    }

    public static testmethod void initInvalidAccId(){
        setupData();  
        Test.startTest();
        String responseBody = '{"status": {"code": "0000","description": "Success"},"data": ';
        responseBody = responseBody + '{"customerId": "00000000000122","financialId": "0011000000000000","consents": [';
        responseBody = responseBody + '{"type": "MARKET","flag": "N","version": "3","channel": "CRM-CC","consentBy": "41696","consentDateTime": "",';
        responseBody = responseBody + '"consentSignDate": "","needUpdateFlag": "N","needUpdateFlagReason": ""},';
        responseBody = responseBody + '{"type": "DATA-ANALYTIC","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
        responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": "" },';
        responseBody = responseBody + '{ "type": "PDPA-DEPOSIT","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
        responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": ""}]}}';

        Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, responseBody));
        Acct.Id = null;
        ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
        PDPAWebserviceCtl pdpa = new PDPAWebserviceCtl();
        PDPAWebserviceCtl accResult= new PDPAWebserviceCtl(pdpaAcc);
        Test.stopTest();

        }

        public static testmethod void responseNoDate(){
            setupData();  
            User currentUser = [Select ID, Employee_ID__c, UserProfileName__c from User where id =: UserInfo.getUserId()]; 
            Test.startTest();
            system.runAs(currentUser){
                String responseBody = '{"status": {"code": "0000","description": "Success"},"data": ';
                responseBody = responseBody + '{"customerId": "00000000000122","financialId": "0011000000000000","consents": [';
                responseBody = responseBody + '{"type": "MARKET","flag": "N","version": "3","channel": "CRM-CC","consentBy": "41696","consentDateTime": "",';
                responseBody = responseBody + '"consentSignDate": "","needUpdateFlag": "N","needUpdateFlagReason": ""},';
                responseBody = responseBody + '{"type": "DATA-ANALYTIC","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
                responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": "" },';
                responseBody = responseBody + '{ "type": "PDPA-DEPOSIT","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
                responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": ""}]}}';
        
                Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, responseBody));
                ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
                PDPAWebserviceCtl pdpa = new PDPAWebserviceCtl();
                PDPAWebserviceCtl accResult= new PDPAWebserviceCtl(pdpaAcc);
        
                Map<String,String> profileMapChanel = new Map<String,String>();
                profileMapChanel.put(currentUser.UserProfileName__c, 'test channel');
                accResult.profileMapChanel = profileMapChanel;
                accResult.viewPDPA();
            }
            Test.stopTest();
    
            }

    @isTest
    public static void callServiceFail() {
        setupData();  
        Test.startTest();
            ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
            PDPAWebserviceCtl accResult = new PDPAWebserviceCtl(pdpaAcc);  
            String requestBody = '{'+  '"customerId":"abcdefghigklmn}';
            accResult.callService(requestBody, 'PDPA_and_Market_Consent_Update'); 
        Test.stopTest();  
    }

    @isTest
    public static void testPrintENConsentPDFAccept() {
        setupData();  
        PDPAStructure.PDPAconsents consent = new PDPAStructure.PDPAconsents();
        consent.type = 'PDPA';
        consent.flag = 'Y';
        consent.version = '9';
        consent.consentDateTime = Datetime.now();
        consent.channel = 'CRM-CC';
        consent.consentBy = UserInfo.getUserId();
        consent.needUpdateFlag = 'No';
        consent.decriptionEN = 'test desc en';
        consent.decriptionTH = 'รายละเอียด';
        consent.consentSignDate = Date.today();
        consent.needUpdateFlagReason = 'No';
        consent.wsCurrentFlag = 'Y';

        List<PDPAStructure.PDPAconsents> pdpaForDisplay = new List<PDPAStructure.PDPAconsents>();
        pdpaForDisplay.add(consent);

        String responseBody = '{"status": {"code": "0000","description": "Success"},"data": ';
            responseBody = responseBody + '{"customerId": "00000000000122","financialId": "0011000000000000","consents": [';
            responseBody = responseBody + '{"type": "MARKET","flag": "N","version": "3","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:05",';
            responseBody = responseBody + '"consentSignDate": "2020-01-02","needUpdateFlag": "N","needUpdateFlagReason": ""},';
            responseBody = responseBody + '{"type": "DATA-ANALYTIC","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
            responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": "" },';
            responseBody = responseBody + '{ "type": "PDPA-DEPOSIT","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
            responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": ""}]}}';

        Acct.ID_Type_PE__c = 'Passport ID';
        Acct.First_Name_ENG_PE__c = 'test fname';
        Acct.Last_Name_PE_Eng__c = 'test lname';
        
        update Acct;
        Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, responseBody));
            ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
            PDPAWebserviceCtl ctl= new PDPAWebserviceCtl(pdpaAcc);
            ctl.selectedConsentIdx = 0;
            ctl.pdpaForDisplay = pdpaForDisplay;
            PageReference pdf = ctl.printConsentPDF();

            PDPA_Activity_Log__c activity = [SELECT Id, Activity_Type__c, Consent__c FROM PDPA_Activity_Log__c ORDER BY CreatedDate DESC LIMIT 1];
            System.assertEquals('Print', activity.Activity_Type__c);
            System.assertEquals('Y', activity.Consent__c);

        Test.stopTest();
    }

    @isTest
    public static void testPrintENConsentPDFReject() {
        setupData();  
        PDPAStructure.PDPAconsents consent = new PDPAStructure.PDPAconsents();
        consent.type = 'PDPA';
        consent.flag = 'N';
        consent.version = '9';
        consent.consentDateTime = Datetime.now();
        consent.channel = 'CRM-CC';
        consent.consentBy = UserInfo.getUserId();
        consent.needUpdateFlag = 'No';
        consent.decriptionEN = 'test desc en';
        consent.decriptionTH = 'รายละเอียด';
        consent.consentSignDate = Date.today();
        consent.wsCurrentFlag = 'N';

        List<PDPAStructure.PDPAconsents> pdpaForDisplay = new List<PDPAStructure.PDPAconsents>();
        pdpaForDisplay.add(consent);

        String responseBody = '{"status": {"code": "0000","description": "Success"},"data": ';
            responseBody = responseBody + '{"customerId": "00000000000122","financialId": "0011000000000000","consents": [';
            responseBody = responseBody + '{"type": "MARKET","flag": "N","version": "3","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:05",';
            responseBody = responseBody + '"consentSignDate": "2020-01-02","needUpdateFlag": "N","needUpdateFlagReason": ""},';
            responseBody = responseBody + '{"type": "DATA-ANALYTIC","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
            responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": "" },';
            responseBody = responseBody + '{ "type": "PDPA-DEPOSIT","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
            responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": ""}]}}';

        Acct.ID_Type_PE__c = 'Passport ID';
        update Acct;
        Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, responseBody));
            ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
            PDPAWebserviceCtl ctl= new PDPAWebserviceCtl(pdpaAcc);
            ctl.selectedConsentIdx = 0;
            ctl.pdpaForDisplay = pdpaForDisplay;
            PageReference pdf = ctl.printConsentPDF();

            PDPA_Activity_Log__c activity = [SELECT Id, Activity_Type__c, Consent__c FROM PDPA_Activity_Log__c ORDER BY CreatedDate DESC LIMIT 1];
            System.assertEquals('Print', activity.Activity_Type__c);
            System.assertEquals('N', activity.Consent__c);
        Test.stopTest();
    }

    @isTest
    public static void testPrintENConsentPDFPending() {
        setupData();  
        PDPAStructure.PDPAconsents consent = new PDPAStructure.PDPAconsents();
        consent.type = 'PDPA';
        consent.flag = null;
        consent.version = '9';
        consent.consentDateTime = Datetime.now();
        consent.channel = 'CRM-CC';
        consent.consentBy = UserInfo.getUserId();
        consent.needUpdateFlag = 'No';
        consent.decriptionEN = 'test desc en';
        consent.decriptionTH = 'รายละเอียด';
        consent.consentSignDate = Date.today();
        consent.wsCurrentFlag = null;

        List<PDPAStructure.PDPAconsents> pdpaForDisplay = new List<PDPAStructure.PDPAconsents>();
        pdpaForDisplay.add(consent);

        String responseBody = '{"status": {"code": "0000","description": "Success"},"data": ';
            responseBody = responseBody + '{"customerId": "00000000000122","financialId": "0011000000000000","consents": [';
            responseBody = responseBody + '{"type": "MARKET","flag": "N","version": "3","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:05",';
            responseBody = responseBody + '"consentSignDate": "2020-01-02","needUpdateFlag": "N","needUpdateFlagReason": ""},';
            responseBody = responseBody + '{"type": "DATA-ANALYTIC","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
            responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": "" },';
            responseBody = responseBody + '{ "type": "PDPA-DEPOSIT","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
            responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": ""}]}}';

        Acct.ID_Type_PE__c = 'Passport ID';
        update Acct;
        Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, responseBody));
            ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
            PDPAWebserviceCtl ctl= new PDPAWebserviceCtl(pdpaAcc);
            ctl.selectedConsentIdx = 0;
            ctl.pdpaForDisplay = pdpaForDisplay;
            PageReference pdf = ctl.printConsentPDF();

            PDPA_Activity_Log__c activity = [SELECT Id, Activity_Type__c, Consent__c FROM PDPA_Activity_Log__c ORDER BY CreatedDate DESC LIMIT 1];
            System.assertEquals('Print', activity.Activity_Type__c);
            System.assertEquals(null, activity.Consent__c);
        Test.stopTest();
    }

    @isTest
    public static void testPrintTHConsentPDFAccept() {
        setupData();  
        PDPAStructure.PDPAconsents consent = new PDPAStructure.PDPAconsents();
        consent.type = 'PDPA';
        consent.flag = 'Y';
        consent.version = '9';
        consent.consentDateTime = Datetime.now();
        consent.channel = 'CRM-CC';
        consent.consentBy = UserInfo.getUserId();
        consent.needUpdateFlag = 'No';
        consent.decriptionEN = 'test desc en';
        consent.decriptionTH = 'รายละเอียด';
        consent.consentSignDate = Date.today();
        consent.wsCurrentFlag = 'Y';

        List<PDPAStructure.PDPAconsents> pdpaForDisplay = new List<PDPAStructure.PDPAconsents>();
        pdpaForDisplay.add(consent);

        String responseBody = '{"status": {"code": "0000","description": "Success"},"data": ';
            responseBody = responseBody + '{"customerId": "00000000000122","financialId": "0011000000000000","consents": [';
            responseBody = responseBody + '{"type": "MARKET","flag": "N","version": "3","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:05",';
            responseBody = responseBody + '"consentSignDate": "2020-01-02","needUpdateFlag": "N","needUpdateFlagReason": ""},';
            responseBody = responseBody + '{"type": "DATA-ANALYTIC","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
            responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": "" },';
            responseBody = responseBody + '{ "type": "PDPA-DEPOSIT","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
            responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": ""}]}}';

        Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, responseBody));
            ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
            PDPAWebserviceCtl ctl= new PDPAWebserviceCtl(pdpaAcc);
            ctl.selectedConsentIdx = 0;
            ctl.pdpaForDisplay = pdpaForDisplay;
            PageReference pdf = ctl.printConsentPDF();
            
            PDPA_Activity_Log__c activity = [SELECT Id, Activity_Type__c, Consent__c FROM PDPA_Activity_Log__c ORDER BY CreatedDate DESC LIMIT 1];
            System.assertEquals('Print', activity.Activity_Type__c);
            System.assertEquals('Y', activity.Consent__c);
        Test.stopTest();
    }

    @isTest
    public static void testPrintTHConsentPDFReject() {
        setupData();  
        PDPAStructure.PDPAconsents consent = new PDPAStructure.PDPAconsents();
        consent.type = 'PDPA';
        consent.flag = 'N';
        consent.version = '9';
        consent.consentDateTime = Datetime.now();
        consent.channel = 'CRM-CC';
        consent.consentBy = UserInfo.getUserId();
        consent.needUpdateFlag = 'No';
        consent.decriptionEN = 'test desc en';
        consent.decriptionTH = 'รายละเอียด';
        consent.consentSignDate = Date.today();
        consent.wsCurrentFlag = 'N';

        List<PDPAStructure.PDPAconsents> pdpaForDisplay = new List<PDPAStructure.PDPAconsents>();
        pdpaForDisplay.add(consent);

        String responseBody = '{"status": {"code": "0000","description": "Success"},"data": ';
            responseBody = responseBody + '{"customerId": "00000000000122","financialId": "0011000000000000","consents": [';
            responseBody = responseBody + '{"type": "MARKET","flag": "N","version": "3","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:05",';
            responseBody = responseBody + '"consentSignDate": "2020-01-02","needUpdateFlag": "N","needUpdateFlagReason": ""},';
            responseBody = responseBody + '{"type": "DATA-ANALYTIC","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
            responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": "" },';
            responseBody = responseBody + '{ "type": "PDPA-DEPOSIT","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
            responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": ""}]}}';

        Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, responseBody));
            ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
            PDPAWebserviceCtl ctl= new PDPAWebserviceCtl(pdpaAcc);
            ctl.selectedConsentIdx = 0;
            ctl.pdpaForDisplay = pdpaForDisplay;
            PageReference pdf = ctl.printConsentPDF();

            PDPA_Activity_Log__c activity = [SELECT Id, Activity_Type__c, Consent__c FROM PDPA_Activity_Log__c ORDER BY CreatedDate DESC LIMIT 1];
            System.assertEquals('Print', activity.Activity_Type__c);
            System.assertEquals('N', activity.Consent__c);
        Test.stopTest();
    }

    @isTest
    public static void testPrintTHConsentPDFPending() {
        setupData();  
        PDPAStructure.PDPAconsents consent = new PDPAStructure.PDPAconsents();
        consent.type = 'PDPA';
        consent.flag = null;
        consent.version = '9';
        consent.consentDateTime = Datetime.now();
        consent.channel = 'CRM-CC';
        consent.consentBy = UserInfo.getUserId();
        consent.needUpdateFlag = 'No';
        consent.decriptionEN = 'test desc en';
        consent.decriptionTH = 'รายละเอียด';
        consent.consentSignDate = Date.today();
        consent.wsCurrentFlag = null;

        List<PDPAStructure.PDPAconsents> pdpaForDisplay = new List<PDPAStructure.PDPAconsents>();
        pdpaForDisplay.add(consent);

        String responseBody = '{"status": {"code": "0000","description": "Success"},"data": ';
            responseBody = responseBody + '{"customerId": "00000000000122","financialId": "0011000000000000","consents": [';
            responseBody = responseBody + '{"type": "MARKET","flag": "N","version": "3","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:05",';
            responseBody = responseBody + '"consentSignDate": "2020-01-02","needUpdateFlag": "N","needUpdateFlagReason": ""},';
            responseBody = responseBody + '{"type": "DATA-ANALYTIC","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
            responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": "" },';
            responseBody = responseBody + '{ "type": "PDPA-DEPOSIT","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
            responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": ""}]}}';

        Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, responseBody));
            ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
            PDPAWebserviceCtl ctl= new PDPAWebserviceCtl(pdpaAcc);
            ctl.selectedConsentIdx = 0;
            ctl.pdpaForDisplay = pdpaForDisplay;
            PageReference pdf = ctl.printConsentPDF();

            PDPA_Activity_Log__c activity = [SELECT Id, Activity_Type__c, Consent__c FROM PDPA_Activity_Log__c ORDER BY CreatedDate DESC LIMIT 1];
            System.assertEquals('Print', activity.Activity_Type__c);
            System.assertEquals(null, activity.Consent__c);
        Test.stopTest();
    }

    @isTest
    public static void testSendENMail() {
        setupData();  
        PDPAStructure.PDPAconsents consent = new PDPAStructure.PDPAconsents();
        consent.type = 'PDPA';
        consent.flag = null;
        consent.version = '9';
        consent.consentDateTime = Datetime.now();
        consent.channel = 'CRM-CC';
        consent.consentBy = UserInfo.getUserId();
        consent.needUpdateFlag = 'No';
        consent.decriptionEN = 'test desc en';
        consent.decriptionTH = 'รายละเอียด';
        consent.consentSignDate = Date.today();
        consent.wsCurrentFlag = null;

        List<PDPAStructure.PDPAconsents> pdpaForDisplay = new List<PDPAStructure.PDPAconsents>();
        pdpaForDisplay.add(consent);

        String responseBody = '{"status": {"code": "0000","description": "Success"},"data": ';
            responseBody = responseBody + '{"customerId": "00000000000122","financialId": "0011000000000000","consents": [';
            responseBody = responseBody + '{"type": "MARKET","flag": "N","version": "3","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:05",';
            responseBody = responseBody + '"consentSignDate": "2020-01-02","needUpdateFlag": "N","needUpdateFlagReason": ""},';
            responseBody = responseBody + '{"type": "DATA-ANALYTIC","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
            responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": "" },';
            responseBody = responseBody + '{ "type": "PDPA-DEPOSIT","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
            responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": ""}]}}';

        Acct.Email_Address_PE__c = 'test@mockmail.com';
        Acct.ID_Type_PE__c = 'Passport ID';
        Acct.TMB_Customer_ID_PE__c = null;
        update Acct;
        Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, responseBody));
            ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
            PDPAWebserviceCtl ctl= new PDPAWebserviceCtl(pdpaAcc);
            // Glean************
            String urlToUpdatePdpa = ctl.urlToUpdatePdpa;
            PDPAStructure.PDPAconsents pdpaViewBeforeEdit = new PDPAStructure.PDPAconsents();       
            pdpaViewBeforeEdit.flag = null;
            ctl.pdpaViewBeforeEdit = pdpaViewBeforeEdit;
            List<SelectOption> flag = ctl.getFlag();

            String pageMessage = ctl.pageMessage;
            String errorcallOut = ctl.errorcallOut;
            ctl.isProfileinCanvasList = true;
            // *************

            ctl.selectedConsentIdx = 0;
            ctl.pdpaForDisplay = pdpaForDisplay;
            ctl.sendMail();

            PDPA_Activity_Log__c activity = [SELECT Id, Activity_Type__c, Consent__c FROM PDPA_Activity_Log__c ORDER BY CreatedDate DESC LIMIT 1];
            System.assertEquals('Email', activity.Activity_Type__c);
        Test.stopTest();
    }

    @isTest
    public static void testSendMailInvalidReceiver() {
        setupData();  
        Test.startTest();
            
            ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
            PDPAWebserviceCtl ctl = new PDPAWebserviceCtl(pdpaAcc);
            ctl.accountObj.Email_Address_PE__c = 'test@mockmailinvalid';

            ctl.selectedConsentIdx = 0;
            List<AggregateResult> beforeActivity = [SELECT COUNT(Id)cnt FROM PDPA_Activity_Log__c WHERE Activity_Type__c = 'Email'];
            ctl.sendMail();

            List<AggregateResult> afterActivity = [SELECT COUNT(Id)cnt FROM PDPA_Activity_Log__c WHERE Activity_Type__c = 'Email'];
            System.assertEquals(beforeActivity[0].get('cnt'),afterActivity[0].get('cnt'));
        Test.stopTest();
    }


    @isTest
    public static void testSendTHMail() {
        setupData();  
        PDPAStructure.PDPAconsents consent = new PDPAStructure.PDPAconsents();
        consent.type = 'PDPA';
        consent.flag = null;
        consent.version = '9';
        consent.consentDateTime = Datetime.now();
        consent.channel = 'CRM-CC';
        consent.consentBy = UserInfo.getUserId();
        consent.needUpdateFlag = 'No';
        consent.decriptionEN = 'test desc en';
        consent.decriptionTH = 'รายละเอียด';
        consent.consentSignDate = Date.today();
        consent.wsCurrentFlag = null;

        List<PDPAStructure.PDPAconsents> pdpaForDisplay = new List<PDPAStructure.PDPAconsents>();
        pdpaForDisplay.add(consent);

        String responseBody = '{"status": {"code": "0000","description": "Success"},"data": ';
            responseBody = responseBody + '{"customerId": "00000000000122","financialId": "0011000000000000","consents": [';
            responseBody = responseBody + '{"type": "MARKET","flag": "N","version": "3","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:05",';
            responseBody = responseBody + '"consentSignDate": "2020-01-02","needUpdateFlag": "N","needUpdateFlagReason": ""},';
            responseBody = responseBody + '{"type": "DATA-ANALYTIC","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
            responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": "" },';
            responseBody = responseBody + '{ "type": "PDPA-DEPOSIT","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
            responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": ""}]}}';

        Acct.Email_Address_PE__c = 'test@mockmail.com';
        update Acct;
        Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, responseBody));
            ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
            PDPAWebserviceCtl ctl= new PDPAWebserviceCtl(pdpaAcc);
            ctl.selectedConsentIdx = 0;
            ctl.pdpaForDisplay = pdpaForDisplay;
            ctl.sendMail();

            PDPA_Activity_Log__c activity = [SELECT Id, Activity_Type__c, Consent__c FROM PDPA_Activity_Log__c ORDER BY CreatedDate DESC LIMIT 1];
            System.assertEquals('Email', activity.Activity_Type__c);
        Test.stopTest();
    }

    @isTest
    public static void testSetPDPARetryState() {
        if(!sutUpdataDone){
            setupData();  
        }
        User currentUser = [Select ID, Employee_ID__c, UserProfileName__c from User where id =: UserInfo.getUserId()]; 
        Test.startTest(); 

        system.runAs(currentUser){
            PageReference pageRef = Page.PDPAScreenUpdateComponent;
            Test.setCurrentPage(pageRef); 
            ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
            Integer pdpaRetryDelay = PDPAWebserviceCtl.pdpaRetryDelay;
            PDPAWebserviceCtl accResult = new PDPAWebserviceCtl(pdpaAcc);
            // Integer pdpaRetryDelay = accResult.pdpaRetryDelay;
            accResult.pdpaRetryRemain = 2;
            accResult.setPDPARetryState();
            // String responseBody1 = '{"status": { "code": "0000", "description": "Success" }}';
            // Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, responseBody1));
            // accResult.saveForm();
        }
        Test.stopTest();
    }

    @isTest
    public static void testTMBCustNull() {
        setupData();  
        PDPAStructure.PDPAconsents consent = new PDPAStructure.PDPAconsents();
        consent.type = 'PDPA';
        consent.flag = 'Y';
        consent.version = '9';
        consent.consentDateTime = Datetime.now();
        consent.channel = 'CRM-CC';
        consent.consentBy = UserInfo.getUserId();
        consent.needUpdateFlag = 'No';
        consent.decriptionEN = 'test desc en';
        consent.decriptionTH = 'รายละเอียด';
        consent.consentSignDate = Date.today();
        consent.needUpdateFlagReason = 'No';
        consent.wsCurrentFlag = 'Y';

        List<PDPAStructure.PDPAconsents> pdpaForDisplay = new List<PDPAStructure.PDPAconsents>();
        pdpaForDisplay.add(consent);

        String responseBody = '{"status": {"code": "0000","description": "Success"},"data": ';
            responseBody = responseBody + '{"customerId": "00000000000122","financialId": "0011000000000000","consents": [';
            responseBody = responseBody + '{"type": "MARKET","flag": "N","version": "3","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:05",';
            responseBody = responseBody + '"consentSignDate": "2020-01-02","needUpdateFlag": "N","needUpdateFlagReason": ""},';
            responseBody = responseBody + '{"type": "DATA-ANALYTIC","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
            responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": "" },';
            responseBody = responseBody + '{ "type": "PDPA-DEPOSIT","flag": "N","version": "2","channel": "CRM-CC","consentBy": "41696","consentDateTime": "2020-02-19T15:32:57",';
            responseBody = responseBody + '"consentSignDate": "2020-02-03","needUpdateFlag": "Y","needUpdateFlagReason": ""}]}}';

        Acct.TMB_Customer_ID_PE__c = null;
        Acct.ID_Type_PE__c = 'Passport ID';
        Acct.First_Name_ENG_PE__c = 'test fname';
        Acct.Last_Name_PE_Eng__c = 'test lname';
        
        update Acct;
        Test.startTest();
            
            Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200, responseBody));
            ApexPages.StandardController pdpaAcc = new ApexPages.StandardController(Acct);
            PDPAWebserviceCtl ctl= new PDPAWebserviceCtl(pdpaAcc);
            ctl.selectedConsentIdx = 0;
            ctl.pdpaForDisplay = pdpaForDisplay;
            PageReference pdf = ctl.printConsentPDF();

            PDPA_Activity_Log__c activity = [SELECT Id, Activity_Type__c, Consent__c FROM PDPA_Activity_Log__c ORDER BY CreatedDate DESC LIMIT 1];
            System.assertEquals('Print', activity.Activity_Type__c);
            System.assertEquals('Y', activity.Consent__c);

        Test.stopTest();
    }
    
    static void setupData(){
        TestUtils.createAppConfig();

        PDPA_Update_Flag_Permission__c pdapPermission = new PDPA_Update_Flag_Permission__c();
        pdapPermission.name = 'TMB Retail Contact1';
        pdapPermission.Channel__c = 'CRM-CC';
        pdapPermission.PermissionUpdateFlag__c = 'N';
        pdapPermission.Profile_Name__c = 'PT1';
        insert pdapPermission;

        List<PDPAMapping__c> insertMapPDPAList = New List<PDPAMapping__c>();
        PDPAMapping__c pdpamapping1 = new PDPAMapping__c();
        pdpamapping1.Name = 'PDPA-DEPOSIT';
        pdpamapping1.Template_Type__c = 'PDPA';
        pdpamapping1.Multiple_Update__c = 'PDPA';
        pdpamapping1.Display_Type__c = 'DATA-ANALYTIC';
        pdpamapping1.Description_TH__c = 'การให้ความยินยอมในการเปิดเผยข้อมูลส่วนบุคคลตามพ.ร.บ.คุ้มครองข้อมูลส่วนบุคคล';
        pdpamapping1.Description__c = 'Consent for Disclosure of Personal Information';
        insertMapPDPAList.add(pdpamapping1);

        PDPAMapping__c pdpamapping2 = new PDPAMapping__c();
        pdpamapping2.Name = 'MARKET';
        pdpamapping2.Template_Type__c = 'Market Consent';
        pdpamapping2.Multiple_Update__c = '';
        pdpamapping2.Display_Type__c = 'Market Conduct';
        pdpamapping2.Description_TH__c = 'การให้ความยินยอมในการเปิดเผยข้อมูลให้บุคคลอื่นเพื่อวัตถุประสงค์ทางการตลาด';
        pdpamapping2.Description__c = 'Consent for Disclosure of Information for Marketing Purpose';
        insertMapPDPAList.add(pdpamapping2);

        insert insertMapPDPAList;

        List<Consent_Template__c> consentTemList = new list<Consent_Template__c>();

        Consent_Template__c consentT1 = New Consent_Template__c();
        consentT1.Template_Name__c = 'Individual PDPA_P_TH';
        consentT1.Template_Type__c = 'PDPA';
        consentT1.Template_Mode__c = 'P';
        consentT1.Template_Language__c = 'TH';
        consentT1.Template_Version__c = '1';
        consentT1.Effective_Date__c = system.today();
        consentT1.Template_Header__c = 'หนังสือให้ความยินยอมเกี่ยวกับข้อมูลส่วนบุคคล';
        consentTemList.add(consentT1);

        Consent_Template__c consentT2 = New Consent_Template__c();
        consentT2.Template_Name__c = 'Individual Market Consent_P_TH';
        consentT2.Template_Type__c = 'Market Consent';
        consentT2.Template_Mode__c = 'P';
        consentT2.Template_Language__c = 'TH';
        consentT2.Template_Version__c = '1';
        consentT2.Effective_Date__c = system.today();
        consentT2.Template_Header__c = 'หนังสือให้ความยินยอมเกี่ยวกับข้อมูลส่วนบุคคล';
        consentTemList.add(consentT2);

        insert consentTemList;  
        
        Acct = new Account();
        Acct.Name = 'Test Account';
        Acct.Phone ='050111222';
        Acct.Mobile_Number_PE__c  = '0801112233';
        Acct.ID_Type_PE__c  = 'Citizen ID';
        Acct.ID_Number_PE__c  = '1510100181965';
        
        Acct.Customer_Type__c = 'Individual';
        Acct.First_name_PE__c = 'Test First';
        Acct.First_Name_ENG_PE__c = 'Test ENG';
        Acct.Last_name_PE__c = 'TestMock';
        Acct.Last_Name_PE_Eng__c  = 'TestMock';
        Acct.TMB_Customer_ID_PE__c = '001100000000000000000000000122';
        insert Acct;
        system.debug('Test lopp setup');
        sutUpdataDone = true;

        String authorized = '{'+
            '"access_token": "eyJ0eXBlIjoiSldUIiwiYWxnIjoiUlM1MTIifQ.eyJhcGlfa2V5IjoiYWRtaW4iLCJzY29wZSI6InJlYWQgd3JpdGUiLCJleHAiOjE1NDY4NTg3MzUsInZlcnNpb24iOiIwMDEtMjAxODExMTEiLCJqdGkiOiIyYTQ4ZmEwYi0yMjEyLTRlMzItYTAzMC1mOWFlMmRkYWFlOTQifQ.HcK3lexOKd-ufV0adiIsKWfHzG34D606gFwFbABC-5QFKpUoLus_xq_DPPttpqj7VQB_cYIqaoFEI0HkD2rbTjXuhDDcbcpvkkaLO6DpGYfXi5RYgk7MQq7BPhgq_CVts4p4zUsLnae-c5s3cd5zC08qkNjOVMGlgNli1DZekCFa5vHdrXHICu7ih_CVV6QLLYnyhrN5-STSasxOaNqlZ5v69q0aADP69wyj2NL1SVdCoG8aPlm0ILSjKIM8lj9RsZ23Xs1LUlMGpYNqjhHEI2BDQazuW-VFz_lXi6q_84uM4XvU1bMV6TJxuVXLYjtpaY4Y2wBQJMICvfbIGN-mOg",'+
            '"token_type": "bearer",'+
            '"expires_in": 3600,'+
            '"scope": "read write",'+
            '"jti": "2a48fa0b-2212-4e32-a030-f9ae2ddaae94",'+
            '"client_id": "xxxxx",'+
            '"version": "001-20181111",'+
            '"isSuccess": true,'+
            '"errorMessage": "",'+
            '"requestBody": "",'+
            '"responseBody": ""'+
        '}';
        
        AuthenticationToken authenTokenCalculateTools = AuthenticationToken.parse(authorized);
        Datetime startTime = Datetime.now();
        Datetime endTime = Datetime.now();
        Cache.OrgPartition orgPartSmartBDMCalToolsCreateToken = Cache.Org.getPartition('local.SmartBDMCalToolsCreateToken');
        orgPartSmartBDMCalToolsCreateToken.put('accesstoken', authenTokenCalculateTools.access_token, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('tokentype', authenTokenCalculateTools.token_type, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('expiresin', authenTokenCalculateTools.expires_in, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('scope', authenTokenCalculateTools.scope, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('jti', authenTokenCalculateTools.jti, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('clientid', authenTokenCalculateTools.client_id, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('version', authenTokenCalculateTools.version, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('isSuccess', authenTokenCalculateTools.isSuccess, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('errorMessage', authenTokenCalculateTools.errorMessage, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('requestBody', authenTokenCalculateTools.requestBody, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('responseBody', authenTokenCalculateTools.responseBody, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('startTime', Datetime.now(), Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('endtime', Datetime.now(), Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);

        OnlineServiceLog onlineServiceLogGateWay = new OnlineServiceLog(authenTokenCalculateTools.isSuccess, authenTokenCalculateTools.errorMessage, authenTokenCalculateTools.requestBody, authenTokenCalculateTools.responseBody, startTime, endTime);
        orgPartSmartBDMCalToolsCreateToken.put('onlineServiceLogGateWay', onlineServiceLogGateWay.parseToJson(), authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
    
        AppConfig__c configDpoEmail = new AppConfig__c();
        configDpoEmail.Name = 'DPO Email Address';
        configDpoEmail.Value__c = 'sf_admin@tmbbank.com';
        insert configDpoEmail;
    }
}