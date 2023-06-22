@isTest
public class ManageAPIGWTokenQueueTest {
    @isTest 
    static void TestManageAPIGWTokenQueue() {
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());

        AppConfig__c app = new AppConfig__c(Name='TESTGETTOKENADDSECONDS', Value__c='25200');
        insert app;

        Test.startTest();        
        System.enqueueJob(new ManageAPIGWTokenQueue());
        Test.stopTest();
  
        System.assertEquals(Cache.Org.getPartition('local.CreateGateWayToken').contains('accesstoken'), true);    
    }

    @isTest 
    static void TestManageAPIGWTokenQueue3() { 
        String mockToken = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBfbmFtZSI6IkNSTSBTYWxlcyBNYW5hZ2VtZW50IFN5c3RlbXMvU2FsZXNGb3JjZSAtIFNJVCIsInNjb3BlIjpbInJlYWQiLCJ3cml0ZSJdLCJleHAiOjE2NTAyODY5MzcsImFwcF9pZCI6IkEwMjkxIiwianRpIjoiZDY5MDljNzctYmMwNS00MjE2LTgzODAtYjQ5MGQ0NDhiODA3IiwiY2xpZW50X2lkIjoiZjc5Njk4YTc5OWE0ODVlNDBhMGVkN2RjNDNmNDRmMTcifQ.TPXj1ULQCKuTbOaNc0oN8eJWWRGgzK93McJeGU92hMXeVBa_9HN6A4Tjsa47nqD9ykdwgW648jRJhhZti1ldVAm6k9AjrqkXE4CTqSyyyxlUx10RUXFocUphoT_sPHgbA7l-mMDovPjahP8zRdYAZjaa8P60RJH5FAInl1s9qJOaeoeGD0eATK';
        Datetime expTimeFrTokenDT = Datetime.now().addSeconds(-1);

        Cache.OrgPartition orgPartGetToken = Cache.Org.getPartition('local.CreateGateWayToken');

        orgPartGetToken.put('accesstoken', mockToken , Cache.Visibility.ALL);
        orgPartGetToken.put('expirytime', expTimeFrTokenDT, Cache.Visibility.ALL);

        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());

        Test.startTest();        
        System.enqueueJob(new ManageAPIGWTokenQueue());
        Map<String, String> mapTest = Smart_BDM_Constant.SmartBDM_CalculateTools_Settings;
        Test.stopTest();
    }

    @isTest 
    static void TestManageAPIGWTokenQueue4() { 
        String mockToken = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBfbmFtZSI6IkNSTSBTYWxlcyBNYW5hZ2VtZW50IFN5c3RlbXMvU2FsZXNGb3JjZSAtIFNJVCIsInNjb3BlIjpbInJlYWQiLCJ3cml0ZSJdLCJleHAiOjE2NTAyODY5MzcsImFwcF9pZCI6IkEwMjkxIiwianRpIjoiZDY5MDljNzctYmMwNS00MjE2LTgzODAtYjQ5MGQ0NDhiODA3IiwiY2xpZW50X2lkIjoiZjc5Njk4YTc5OWE0ODVlNDBhMGVkN2RjNDNmNDRmMTcifQ.TPXj1ULQCKuTbOaNc0oN8eJWWRGgzK93McJeGU92hMXeVBa_9HN6A4Tjsa47nqD9ykdwgW648jRJhhZti1ldVAm6k9AjrqkXE4CTqSyyyxlUx10RUXFocUphoT_sPHgbA7l-mMDovPjahP8zRdYAZjaa8P60RJH5FAInl1s9qJOaeoeGD0eATK';
        Datetime expTimeFrTokenDT = Datetime.now().addHours(7).addSeconds(2);

        Cache.OrgPartition orgPartGetToken = Cache.Org.getPartition('local.CreateGateWayToken');

        orgPartGetToken.put('accesstoken', mockToken , Cache.Visibility.ALL);
        orgPartGetToken.put('expirytime', expTimeFrTokenDT, Cache.Visibility.ALL);

        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());

        Test.startTest();        
        System.enqueueJob(new ManageAPIGWTokenQueue());
        Map<String, String> mapTest = Smart_BDM_Constant.SmartBDM_CalculateTools_Settings;
        Test.stopTest();
    }

    @isTest 
    static void TestManageAPIGWTokenQueue_ExpMoreThanInterval() {
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
        Integer manageTokenQueueIntervalSec = Smart_BDM_Constant.MANAGE_TOKEN_QUEUE_INTERVAL_SEC;
        Integer addSec = 25200 + manageTokenQueueIntervalSec + 100;

        AppConfig__c app = new AppConfig__c(Name='TESTGETTOKENADDSECONDS', Value__c=String.valueOf(addSec));
        insert app;

        Test.startTest();        
        System.enqueueJob(new ManageAPIGWTokenQueue());
        Test.stopTest();
  
        System.assertEquals(Cache.Org.getPartition('local.CreateGateWayToken').contains('accesstoken'), true);    
    }

    @isTest 
    static void TestManageAPIGWTokenQueue3_ExpMoreThanInterval() { 
        Integer manageTokenQueueIntervalSec = Smart_BDM_Constant.MANAGE_TOKEN_QUEUE_INTERVAL_SEC;
        Datetime dt = Datetime.now().addHours(7);
        dt.addSeconds(manageTokenQueueIntervalSec+100);
        Long mockTimeStamp = (dt.getTime()/1000);
        String strToken = '{"api_key":"admin","scope":"read write","exp":'+String.valueOf(mockTimeStamp)+',"version":"001-20181111","jti":"2a48fa0b-2212-4e32-a030-f9ae2ddaae94"}';
        // System.debug(strToken);

        String expTimeEncode = EncodingUtil.base64Encode(Blob.valueOf(strToken));

        String mockToken = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.'+expTimeEncode+'.TPXj1ULQCKuTbOaNc0oN8eJWWRGgzK93McJeGU92hMXeVBa_9HN6A4Tjsa47nqD9ykdwgW648jRJhhZti1ldVAm6k9AjrqkXE4CTqSyyyxlUx10RUXFocUphoT_sPHgbA7l-mMDovPjahP8zRdYAZjaa8P60RJH5FAInl1s9qJOaeoeGD0eATK';
        // Integer manageTokenQueueIntervalSec = Smart_BDM_Constant.MANAGE_TOKEN_QUEUE_INTERVAL_SEC;
        Datetime expTimeFrTokenDT = Datetime.now().addSeconds(manageTokenQueueIntervalSec+100);

        Cache.OrgPartition orgPartGetToken = Cache.Org.getPartition('local.CreateGateWayToken');

        orgPartGetToken.put('accesstoken', mockToken+'test' , Cache.Visibility.ALL);
        orgPartGetToken.put('expirytime', expTimeFrTokenDT, Cache.Visibility.ALL);

        // Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
        String response = '{'+
            '"access_token": "'+mockToken+'",'+
            '"token_type": "bearer",'+
            '"expires_in": 3600,'+
            '"scope": "read write",'+
            '"jti": "2a48fa0b-2212-4e32-a030-f9ae2ddaae94",'+
            '"client_id": "xxxxx",'+
            '"version": "001-20181111"'+
        '}';
        Test.setMock(HttpCalloutMock.class, new PDPAWebserviceCtlMockTest(200,response));

        Test.startTest();        
        System.enqueueJob(new ManageAPIGWTokenQueue());
        Map<String, String> mapTest = Smart_BDM_Constant.SmartBDM_CalculateTools_Settings;
        Test.stopTest();
    }

    @isTest 
    static void TestManageAPIGWTokenQueue4_ExpMoreThanInterval() { 
        String mockToken = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBfbmFtZSI6IkNSTSBTYWxlcyBNYW5hZ2VtZW50IFN5c3RlbXMvU2FsZXNGb3JjZSAtIFNJVCIsInNjb3BlIjpbInJlYWQiLCJ3cml0ZSJdLCJleHAiOjE2NTAyODY5MzcsImFwcF9pZCI6IkEwMjkxIiwianRpIjoiZDY5MDljNzctYmMwNS00MjE2LTgzODAtYjQ5MGQ0NDhiODA3IiwiY2xpZW50X2lkIjoiZjc5Njk4YTc5OWE0ODVlNDBhMGVkN2RjNDNmNDRmMTcifQ.TPXj1ULQCKuTbOaNc0oN8eJWWRGgzK93McJeGU92hMXeVBa_9HN6A4Tjsa47nqD9ykdwgW648jRJhhZti1ldVAm6k9AjrqkXE4CTqSyyyxlUx10RUXFocUphoT_sPHgbA7l-mMDovPjahP8zRdYAZjaa8P60RJH5FAInl1s9qJOaeoeGD0eATK';
        Integer manageTokenQueueIntervalSec = Smart_BDM_Constant.MANAGE_TOKEN_QUEUE_INTERVAL_SEC;
        System.debug(manageTokenQueueIntervalSec);
        Datetime expTimeFrTokenDT = Datetime.now().addHours(7).addSeconds(manageTokenQueueIntervalSec+100);

        Cache.OrgPartition orgPartGetToken = Cache.Org.getPartition('local.CreateGateWayToken');

        orgPartGetToken.put('accesstoken', mockToken , Cache.Visibility.ALL);
        orgPartGetToken.put('expirytime', expTimeFrTokenDT, Cache.Visibility.ALL);

        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());

        Test.startTest();        
        System.enqueueJob(new ManageAPIGWTokenQueue());
        Map<String, String> mapTest = Smart_BDM_Constant.SmartBDM_CalculateTools_Settings;
        Test.stopTest();
    }
}