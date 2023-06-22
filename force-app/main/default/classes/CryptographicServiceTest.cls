@isTest
public class CryptographicServiceTest {
	@testSetup static void initData(){
        TestUtils.createAppConfig();
        
        List<AppConfig__c> apps = new  List<AppConfig__c>();
		AppConfig__c AppConfig = new AppConfig__c();
        AppConfig.Name = 'cryptographic_Timeout';
        AppConfig.Value__c = '120000';        
        apps.add(AppConfig);

        insert apps;
        
    }
    
    @isTest static void QueryService() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, 'c3018e70d8b7df129e502b2e12b8e4069e5c4cbae48ed9041a1454f069233265'));
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();       
        String body = '{"initial_vector" : "35499051e20b09efa4881d23c45fc2c3","encrypted_data" : "b32a52284f8ad02b0a3a7d9476c50a19055baf6a2618fef71d16dc0bb00233f221f26f93a3ffc61a5569a6c0994c1569b41f89ec584a69513e303b9ac737c47a89e9a9c24ec542bb705ef90a4ce9e5312a6d90141617333e60a4a42ea9d1cf1419695d18d00c0c9e2590a3866be628f2db0f00c55f7148af3c0f0d2bbd8642d5165eac4380b4fa04f6b07358ed4ffefc06311b111e8e5a59b9aad99d37c6f9fc5be76799d0679b2f605b1be570dff68e75bcdb3ced860135559d610be1c4b20d6d13355f740fd4f022b8210f560e25e1d77c482be2f2d125256c9bfd588b7f6949e217f65eb9e37f4ff48abb3b918d61e3a8361e6e4ffd4e76a50cb336dc177767aa0068ba938763b1fd36c6ce021b104996d46e354a72674f73c3aef0da664571d916451b3c460e04e17046deaaa48dd1ac1470d1206ecc8d401b2aa5d39a10e6b0bb239f4aaf5f51215fb1699e1d1f9eb53dc70302c3481b941881dd963575c984f51e8ff8f3f7c378af1243e78135179f47686cd7dfb155cc894d80e2f1264e0ea3a578a62da70897e96c09509dc499b805293adfa392a2088fc43d75cacb2f8adfedc35418ae8a3bce21db564c28b1f7a77222552a9ef2e26f7f31d8ffc91a86a12cdf144ebc5c9620f5b44e0da8762f381753851041a1e76d54d027ad0f14ce12dcbf3fda963d23ddd71a5e73ad47859c6b6b62c594edc4196bb214f038390845056f90739fa3b373b9684d6e91888e8a21f668d3d7519c0dc6b5f0254039331c2022e1e2f26318f805916bc7f3a6a0ec610152502aabe5473976af51d2cf4653ce9f2cfca253cf8bebc8d11183698e4676ea84cb338cf6755af95dc63e8851baa6502122fbc6d7c45cabb64e4aab26872db1ac2878935454ea6d7e1cc367353e7f9bb6013c4be2a112e1b9b73bd22afd6ae0b098a36c6ea71effa22797ba56c894fd06f45654a1a571fd0089eda524e0fe5cbf5c23e11530991419cca09048bc657b17a6e88fa01c0bf5fb5c17d502d1fe8d22450f5d6da22f7a452a275dcb0d85cf42c2a1248631e4655df0b4"}';
        req.requestURI = baseUrl+'/services/apexrest/data/V1.0/cryptographic/';  
        req.addHeader('Content-Type', 'application/json');
        req.addHeader('ReqId', 'Test1234');
        req.addHeader('Sforce-Auto-Assign', 'false');
        req.requestBody = Blob.valueof(body);
        req.httpMethod = 'POST';
         
        
        RestContext.request = req;
        RestContext.response = res;
        
        CryptographicService.mappingService();

        Test.stopTest();
    }
    
    @isTest static void InsertService() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, 'c3018e70d8b7df129e502b2e12b8e4069e5c4cbae48ed9041a1454f069233265'));
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();       
        String body = '{"initial_vector":"35499051e20b09efa4881d23c45fc2c3","encrypted_data":"f1978ed1efdb5761f9ceaeee98f09791d65561db4b11d06a16f8f00687148cbefa2ced3c8436dade25db0dea9faa6a75560cb220e4ffd9e7d3354e1bf893dd023c9f88dbc0ef29c3281e20cc82a6de00661fca49dcf84e50710b5a2d8a506a32"}';
        req.requestURI = baseUrl+'/services/apexrest/data/V1.0/cryptographic/';  
        req.addHeader('Content-Type', 'application/json');
        req.addHeader('ReqId', 'Test1234');
        req.addHeader('Sforce-Auto-Assign', 'false');
        req.requestBody = Blob.valueof(body);
        req.httpMethod = 'POST';
         
        
        RestContext.request = req;
        RestContext.response = res;
        
        CryptographicService.mappingService();

        Test.stopTest();
    }
    @isTest static void UpdateService() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, 'c3018e70d8b7df129e502b2e12b8e4069e5c4cbae48ed9041a1454f069233265'));
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();  
        String body = '{"initial_vector":"35499051e20b09efa4881d23c45fc2c3","encrypted_data":"f1978ed1efdb5761f9ceaeee98f0979112d84310315660e26283a40f15a8fcdb8c1190710c542e198f50bcf579b19bbc02d812f7535df1e6ba6c891e880375813ce200da8eb6f5a6b6608e509d7b57b125cf04fac1c812c1abf834514cefdaa496a8e4e15bba1b55a755c0334e02a1544185b3b4280405bdf394d95b4e6755c6690550e63972bdadd2504e99c040d3e11be07c19536cd4cbec5a567484ae080f7baaec86eabf326ae1259670c6c742e426ab6cf1c3734c9eecc48625de6f2fd4"}';
        req.requestURI = baseUrl+'/services/apexrest/data/V1.0/cryptographic/';  
        req.addHeader('ReqId', 'Test1234');
        req.requestBody = Blob.valueof(body);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response = res;
        
        CryptographicService.mappingService();
        
        Test.stopTest();
    }
    
    @isTest static void UpsertService() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, 'c3018e70d8b7df129e502b2e12b8e4069e5c4cbae48ed9041a1454f069233265'));
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();  
        String body = '{"initial_vector":"35499051e20b09efa4881d23c45fc2c3","encrypted_data":"f1978ed1efdb5761f9ceaeee98f0979112d84310315660e26283a40f15a8fcdb8c1190710c542e198f50bcf579b19bbc02d812f7535df1e6ba6c891e880375817c6c7454ad760bfc2e9d7b68db345d954503f22d721e5ed4ee1d0744f5b5b160b1bf622ba624a41e8bb68fc929c4daf496f30b09f4d8c5d0005f6fac9e485bbffb27c501a6adc29f5c747311e28f608b857129374b876bbf18c102fb788cd3a5"}';
        req.requestURI = baseUrl+'/services/apexrest/data/V1.0/cryptographic/'; 
        req.addHeader('ReqId', 'Test1234');
        req.requestBody = Blob.valueof(body);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        CryptographicService.mappingService();
        
        Test.stopTest();
    }
    
    @isTest static void ErrorService() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, 'c3018e70d8b7df129e502b2e12b8e4069e5c4cbae48ed9041a1454f069233265'));
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();  
        String body = '{Test" : 1111}';
        req.requestURI = baseUrl+'/services/apexrest/data/V1.0/manipulation/';  
        req.requestBody = Blob.valueof(body);
        req.addHeader('ReqId', 'Test1234');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        CryptographicService.mappingService();
        Test.stopTest();
    }
}