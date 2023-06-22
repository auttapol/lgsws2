@isTest
public without sharing class RMC_Utility_Test {
    
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
    private static void Test_abortOldJobs() {
        Test.startTest();
            RMC_Utility.abortOldJobs('testJobName');
        Test.stopTest();
    }

    @isTest
    private static void Test_getScheduleDT() {
        Test.startTest();
            RMC_Utility.getScheduleDT('testJobName', DateTime.now());
        Test.stopTest();
    }

    @isTest
    private static void Test_getSObjectFieldList() {
        Test.startTest();
            RMC_Utility.getSObjectFieldList('Advisory_Planning__c');
        Test.stopTest();
    }

    @isTest
    private static void Test_getFieldsByFieldSet() {
        Test.startTest();
            RMC_Utility.getFieldsByFieldSet('Advisory_Planning_Item__c', 'List_Return');
        Test.stopTest();
    }

    @isTest
    private static void Test_isEmployee() {
        Test.startTest();
            RMC_Utility.isEmployee('testEmployee');
        Test.stopTest();
    }

    @isTest
    private static void Test_startCallGetTokenService() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
            RMC_Utility.startCallGetTokenService();
        Test.stopTest();
    }

    @isTest
    private static void Test_startCallGetTokenService_Error() {
        Test.startTest();
            RMC_Utility.startCallGetTokenService();
        Test.stopTest();
    }

    @isTest
    private static void Test_saveToOnlineLog() {

        Account accountInfo = [SELECT Id, TMB_Customer_ID_PE__c, Name ,Core_Banking_Suggested_Segment__c FROM Account LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());

            RMC_Utility.saveToOnlineLog( false , 'testcustomer name',  'errormessage', null , UserInfo.getName(), 
            'rmId' , 'serviceName' , 'requestBody' , 'requestBody' ,  accountInfo.Id, null,
            DateTime.now() , DateTime.now(), 'remark');
        Test.stopTest();
    }

    @isTest
    private static void Test_getAccount() {

        Account accountInfo = [SELECT Id, TMB_Customer_ID_PE__c, Name ,Core_Banking_Suggested_Segment__c FROM Account LIMIT 1];

        Test.startTest();
            RMC_Utility.getAccount(accountInfo.TMB_Customer_ID_PE__c);
        Test.stopTest();
    }

    @isTest
    private static void Test_getRMContants() {

        Test.startTest();
            RMC_Utility.getRMContants('RM_Cockpits_Get_All_Mutual_Fund');
        Test.stopTest();
    }

    @isTest
    private static void Test_isNotEmpty() {
        Map<String, SObject> objMap  = new Map<String, SObject>();
        for(Account eachAccount :  [SELECT Id FROM Account LIMIT 10]){
            objMap.put(eachAccount.Id, eachAccount);
        }
        Test.startTest();
            RMC_Utility.isNotEmpty(objMap);
        Test.stopTest();
    }

    @isTest
    private static void Test_getProductInformation() {
        Product2 prod = new Product2();
        prod.Name = '1AMDAILY';
        prod.Product_Domain__c = '1. Transactional Banking';
        prod.IsActive = true;
        prod.Family = 'INVESTMENT';
        prod.ProductCode = 'JBPLTF';
        prod.RTL_Product_Code__c = prod.ProductCode;
        insert prod;


        Test.startTest();
            RMC_Utility.getProductInformation(new Set<String>{prod.ProductCode});
        Test.stopTest();
    }

    
}