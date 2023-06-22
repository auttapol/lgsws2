@isTest 
public class ManageAPIGWTokenManualrunControllerTest {
    @TestSetup
    static void mockupData(){
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
    public static void runGetAPIGWTokenTest(){
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
        
        Test.startTest();
        ManageAPIGWTokenManualrunController.runGetAPIGWToken();
        ManageAPIGWTokenManualrunController.getAsyncQueueAPIGWTokenCrontrigger();
        Test.stopTest();
    }

    @isTest
    public static void runGetAPIGWTokenTestCache(){
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
        
        Test.startTest();
        ManageAPIGWTokenManualrunController.getTokenDataInPlatformCache();
        Test.stopTest();
    }
}