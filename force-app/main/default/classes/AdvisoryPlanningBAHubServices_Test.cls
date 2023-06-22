@isTest
public without sharing class AdvisoryPlanningBAHubServices_Test {

    public class MockResponseBAHub implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            String body = new Map<String,String> {
                'callout:RMC_Get_BA_Hub_Key' => 'c3018e70d8b7df129e502b2e12b8e4069e5c4cbae48ed9041a1454f069233265',
                'callout:RMC_Get_Recommended_Insurance' => '{"initial_vector":"c1378b6cecc7b7e0c9a0dc2bf7d3e2b6","encrypted_data":"bba3539c74b7a09890a731fafbe1cf01efe51fae414cf30491e7317beb9dc735a2671e1a192df49676a77a60fecc9b0db53ef71c67962a519a740d18875091fa675ce881a4988da7b26c3b7b052d9dc9db0392daea9cd84757679d10b555e8e653cadb9aff9124a975a8ba564795249a8811faeefbfed95e3cd067fc5e96f34216f1a9c7cf0ee1de59b897bc949e065a6b8e7db9fe2cd4ad3d73c064cdb6ed77"}'
            }.get(req.getEndpoint());

            System.debug('req mock service : ' + req.getBody());
            System.debug('reqEndpoint : ' + req.getEndpoint());
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockResponseBAHubError implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            String body = new Map<String,String> {
                'callout:RMC_Get_BA_Hub_Key' => 'c3018e70d8b7df129e502b2e12b8e4069e5c4cbae48ed9041a1454f069233265',
                'callout:RMC_Get_Recommended_Insurance' => '{"Status" : { "StatusCode" : "4102", "StatusDesc" : "Invalid request"}}'
            }.get(req.getEndpoint());

            System.debug('req mock service : ' + req.getBody());
            System.debug('reqEndpoint : ' + req.getEndpoint());
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }

    @testSetup 
    static void setup() {
        TestUtils.createAppConfig();

        List<AppConfig__c> mc = new List<AppConfig__c> ();
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        insert mc;

        List<Account> acct = TestUtils.createAccounts(1, 'Fname', 'Individual', false);
        acct[0].TMB_Customer_ID_PE__c = '001100000000000000000000000500';
        insert acct;

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
        Cache.OrgPartition orgPartSmartBDMCalToolsCreateToken = Cache.Org.getPartition('local.CreateGateWayToken');
        orgPartSmartBDMCalToolsCreateToken.put('accesstoken', authenTokenCalculateTools.access_token, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('SmartBDMEnliteToken', authenTokenCalculateTools.access_token, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
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
    }

    
    @isTest
    private static void Test_getBancassuranceDetail_BlankTTBCustomer() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());

            Account accountInfo = [SELECT Id, TMB_Customer_ID_PE__c, Name ,Core_Banking_Suggested_Segment__c FROM Account LIMIT 1];

            LightningServiceResult result = AdvisoryPlanningBAHubServices.getBancassuranceDetail(null, accountInfo.Id, accountInfo.Name,  accountInfo.Core_Banking_Suggested_Segment__c);
        Test.stopTest();
    }

    @isTest
    private static void Test_getBancassuranceDetail() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AdvisoryPlanningBAHubServices_Test.MockResponseBAHub());
            Account accountInfo = [SELECT Id, TMB_Customer_ID_PE__c, Name ,Core_Banking_Suggested_Segment__c FROM Account LIMIT 1];

            LightningServiceResult result = AdvisoryPlanningBAHubServices.getBancassuranceDetail(accountInfo.TMB_Customer_ID_PE__c, accountInfo.Id, accountInfo.Name,  accountInfo.Core_Banking_Suggested_Segment__c);
        Test.stopTest();
    }

    @isTest
    private static void Test_getBancassuranceDetail_withErrorCode() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AdvisoryPlanningBAHubServices_Test.MockResponseBAHubError());
            Account accountInfo = [SELECT Id, TMB_Customer_ID_PE__c, Name ,Core_Banking_Suggested_Segment__c FROM Account LIMIT 1];

            LightningServiceResult result = AdvisoryPlanningBAHubServices.getBancassuranceDetail(accountInfo.TMB_Customer_ID_PE__c, accountInfo.Id, accountInfo.Name,  accountInfo.Core_Banking_Suggested_Segment__c);
        Test.stopTest();
    }

    @isTest
    private static void Test_getBancassuranceDetail_withError() {
        
        Test.startTest();
            Account accountInfo = [SELECT Id, TMB_Customer_ID_PE__c, Name ,Core_Banking_Suggested_Segment__c FROM Account LIMIT 1];

            LightningServiceResult result = AdvisoryPlanningBAHubServices.getBancassuranceDetail(accountInfo.TMB_Customer_ID_PE__c, accountInfo.Id, accountInfo.Name,  accountInfo.Core_Banking_Suggested_Segment__c);
        Test.stopTest();
    }
}