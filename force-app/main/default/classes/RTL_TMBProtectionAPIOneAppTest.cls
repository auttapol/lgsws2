@isTest
public with sharing class RTL_TMBProtectionAPIOneAppTest {
    @testSetup static void setup() {
		TestUtils.createAppConfig();

		List<AppConfig__c> mc = new List<AppConfig__c> ();
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        insert mc;

        Account tempAccount = new Account(
            Name = 'First_name_PE__c Last_name_PE__c',
            Email_Address_PE__c = 'test@test.com.baview',
            First_name_PE__c = 'First_name_PE__c',
            Last_name_PE__c = 'Last_name_PE__c',
            ID_Type_PE__c = 'Alien ID',
            ID_Number_PE__c = '111111222222',
            Mobile_Number_PE__c = 'Mobile_Number_PE__c',
            TMB_Customer_ID_PE__c = '001100000000000000000000051187',
            // Core_Banking_Suggested_Segment__c = 'SE',
            Primary_Address_Line_2_PE__c = 'Primary_Address_Line_2_PE__c',
            Primary_Address_Line_3_PE__c = 'Primary_Address_Line_3_PE__c',
            Zip_Code_Primary_PE__c = '00000',
            Province_Primary_PE__c = 'Province_Primary_PE__c',
            RecordTypeId = Account.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Retail_Prospect').getRecordTypeId()
        );
        insert tempAccount;
    }

    private static String encryptKey {
        get {
            return '208f6c8723b80c36fefc349575764dd14baf52d950a98c101034c403b1172b65';
        }
    }

    @isTest static void test_baview_success() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
        String bodyrequest = JSON.serialize(new Map<String,Object>{
            'data' => new Map<String,String>{
                'validateUrl' => 'https://sitbahub.tau2904.com/protection/#/auth/access?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9zaWQiOiIxMDAzODUiLCJjaGFubmVsIjoic2YiLCJyZXF1ZXN0X2lkIjoiZDY0Mjc2YjQtMDRlZS00NWM1LTk5ZDktODYyZDgyZGEzN2VjIiwiY3VzdF9ybV9pZCI6IjAwMDAwMDAwMDUxMTg3IiwibGFuZ3VhZ2UiOiJFTiIsInN0YWZmX2lkIjoiMTk5NDciLCJuYmYiOjE2MjA4ODMyOTgsImV4cCI6MTYyMDg4NDQ5OCwiaWF0IjoxNjIwODgzMjk4fQ.g1T9imuKFDla21C9aN7Ojrs5UvAbzzsE8gVS1X8dD1Q&page=',
                'jwtRefreshToken' => 'AD073YfSbcPYbiEu3IG7y2yiHyi/dlTrbdn0amOndXpEpi+Fb7ZP146gUQBjEtutmg==',
                'jwtToken' => 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9zaWQiOiIxMDAzODUiLCJjaGFubmVsIjoic2YiLCJyZXF1ZXN0X2lkIjoiZDY0Mjc2YjQtMDRlZS00NWM1LTk5ZDktODYyZDgyZGEzN2VjIiwiY3VzdF9ybV9pZCI6IjAwMDAwMDAwMDUxMTg3IiwibGFuZ3VhZ2UiOiJFTiIsInN0YWZmX2lkIjoiMTk5NDciLCJuYmYiOjE2MjA4ODMyOTgsImV4cCI6MTYyMDg4NDQ5OCwiaWF0IjoxNjIwODgzMjk4fQ.g1T9imuKFDla21C9aN7Ojrs5UvAbzzsE8gVS1X8dD1Q'
            },
            'status' => new Map<String,String>{
                'message' => 'Success',
                'code' => 'SUCCESS'
            },
            'requestId' => 'd64276b4-04ee-45c5-99d9-862d82da37ec'
        });
        Continuation conti = (Continuation)RTL_TMBProtectionAPIOneApp.calloutPopupBAViewTMBProtection(
            '001100000000000000000000051187' // tmb_cust_id
        );
        Map<String, HttpRequest> requests = conti.getRequests();
        // Set the fake response for the continuation
        HttpRequest request = requests.values().iterator().next();
        String requestLabel = requests.keyset().iterator().next();

        // Callback OSC01
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody((String)SCSMessageAPIUtil.encryptMessageWithKey(bodyrequest, encryptKey));
        Test.setContinuationResponse(requestLabel, response);

        RTL_TMBProtectionAPIOneApp.callbackPopUPBAViewTMBProtection(new List<String>{requestLabel}, new Map<String, Object>{
            'Endpoint' => request.getEndpoint(),
            // 'Request-UID' => request.getHeader('Request-UID'),
            'Request-Datetime' => Datetime.now(),
            'Request-Body' => bodyrequest,
            'PrivateKey' => encryptKey,
            'RMId' => '001100000000000000000000051187'
        });
        Test.stopTest();
    }
    @isTest static void test_baview_error() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
        String bodyrequest = JSON.serialize(new Map<String,Object>{
            'data' => new Map<String,String>{
                'validateUrl' => 'https://sitbahub.tau2904.com/protection/#/auth/access?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9zaWQiOiIxMDAzODUiLCJjaGFubmVsIjoic2YiLCJyZXF1ZXN0X2lkIjoiZDY0Mjc2YjQtMDRlZS00NWM1LTk5ZDktODYyZDgyZGEzN2VjIiwiY3VzdF9ybV9pZCI6IjAwMDAwMDAwMDUxMTg3IiwibGFuZ3VhZ2UiOiJFTiIsInN0YWZmX2lkIjoiMTk5NDciLCJuYmYiOjE2MjA4ODMyOTgsImV4cCI6MTYyMDg4NDQ5OCwiaWF0IjoxNjIwODgzMjk4fQ.g1T9imuKFDla21C9aN7Ojrs5UvAbzzsE8gVS1X8dD1Q&page=',
                'jwtRefreshToken' => 'AD073YfSbcPYbiEu3IG7y2yiHyi/dlTrbdn0amOndXpEpi+Fb7ZP146gUQBjEtutmg==',
                'jwtToken' => 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9zaWQiOiIxMDAzODUiLCJjaGFubmVsIjoic2YiLCJyZXF1ZXN0X2lkIjoiZDY0Mjc2YjQtMDRlZS00NWM1LTk5ZDktODYyZDgyZGEzN2VjIiwiY3VzdF9ybV9pZCI6IjAwMDAwMDAwMDUxMTg3IiwibGFuZ3VhZ2UiOiJFTiIsInN0YWZmX2lkIjoiMTk5NDciLCJuYmYiOjE2MjA4ODMyOTgsImV4cCI6MTYyMDg4NDQ5OCwiaWF0IjoxNjIwODgzMjk4fQ.g1T9imuKFDla21C9aN7Ojrs5UvAbzzsE8gVS1X8dD1Q'
            },
            // 'status' => new Map<String,String>{
            //     'message' => 'Success',
            //     'code' => 'SUCCESS'
            // },
            'requestId' => 'd64276b4-04ee-45c5-99d9-862d82da37ec'
        });
        Continuation conti = (Continuation)RTL_TMBProtectionAPIOneApp.calloutPopupBAViewTMBProtection(
            '001100000000000000000000051187' // tmb_cust_id
        );
        Map<String, HttpRequest> requests = conti.getRequests();
        // Set the fake response for the continuation
        HttpRequest request = requests.values().iterator().next();
        String requestLabel = requests.keyset().iterator().next();

        // Callback OSC01
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody((String)SCSMessageAPIUtil.encryptMessageWithKey(bodyrequest, encryptKey));
        Test.setContinuationResponse(requestLabel, response);

        RTL_TMBProtectionAPIOneApp.callbackPopUPBAViewTMBProtection(new List<String>{requestLabel}, new Map<String, Object>{
            'Endpoint' => request.getEndpoint(),
            // 'Request-UID' => request.getHeader('Request-UID'),
            'Request-Datetime' => Datetime.now(),
            'Request-Body' => bodyrequest,
            'PrivateKey' => encryptKey,
            'RMId' => '001100000000000000000000051187'
        });
        Test.stopTest();
    }
    @isTest static void test_baview_catch() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
        String bodyrequest = JSON.serialize(new Map<String,Object>{
            'data' => new Map<String,String>{
                'validateUrl' => 'https://sitbahub.tau2904.com/protection/#/auth/access?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9zaWQiOiIxMDAzODUiLCJjaGFubmVsIjoic2YiLCJyZXF1ZXN0X2lkIjoiZDY0Mjc2YjQtMDRlZS00NWM1LTk5ZDktODYyZDgyZGEzN2VjIiwiY3VzdF9ybV9pZCI6IjAwMDAwMDAwMDUxMTg3IiwibGFuZ3VhZ2UiOiJFTiIsInN0YWZmX2lkIjoiMTk5NDciLCJuYmYiOjE2MjA4ODMyOTgsImV4cCI6MTYyMDg4NDQ5OCwiaWF0IjoxNjIwODgzMjk4fQ.g1T9imuKFDla21C9aN7Ojrs5UvAbzzsE8gVS1X8dD1Q&page=',
                'jwtRefreshToken' => 'AD073YfSbcPYbiEu3IG7y2yiHyi/dlTrbdn0amOndXpEpi+Fb7ZP146gUQBjEtutmg==',
                'jwtToken' => 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9zaWQiOiIxMDAzODUiLCJjaGFubmVsIjoic2YiLCJyZXF1ZXN0X2lkIjoiZDY0Mjc2YjQtMDRlZS00NWM1LTk5ZDktODYyZDgyZGEzN2VjIiwiY3VzdF9ybV9pZCI6IjAwMDAwMDAwMDUxMTg3IiwibGFuZ3VhZ2UiOiJFTiIsInN0YWZmX2lkIjoiMTk5NDciLCJuYmYiOjE2MjA4ODMyOTgsImV4cCI6MTYyMDg4NDQ5OCwiaWF0IjoxNjIwODgzMjk4fQ.g1T9imuKFDla21C9aN7Ojrs5UvAbzzsE8gVS1X8dD1Q'
            },
            // 'status' => new Map<String,String>{
            //     'message' => 'Success',
            //     'code' => 'SUCCESS'
            // },
            'requestId' => 'd64276b4-04ee-45c5-99d9-862d82da37ec'
        });
        Continuation conti = (Continuation)RTL_TMBProtectionAPIOneApp.calloutPopupBAViewTMBProtection(
            '001100000000000000000000051187' // tmb_cust_id
        );
        Map<String, HttpRequest> requests = conti.getRequests();
        // Set the fake response for the continuation
        HttpRequest request = requests.values().iterator().next();
        String requestLabel = requests.keyset().iterator().next();

        // Callback OSC01
        HttpResponse response = new HttpResponse();
        response.setStatusCode(500);
        response.setBody('error');
        Test.setContinuationResponse(requestLabel, response);

        try {
            RTL_TMBProtectionAPIOneApp.callbackPopUPBAViewTMBProtection(new List<String>{requestLabel}, new Map<String, Object>{
                'Endpoint' => request.getEndpoint(),
                // 'Request-UID' => request.getHeader('Request-UID'),
                'Request-Datetime' => '20201212',
                'Request-Body' => bodyrequest,
                'PrivateKey' => encryptKey,
                'RMId' => '001100000000000000000000051187'
            });
        } catch (Exception e) {}
      
        Test.stopTest();
    }
}