@isTest
public class ManipulationObjectServiceTest {
    @testSetup static void initData(){
        TestUtils.createAppConfig();
        
        List<AppConfig__c> apps = new  List<AppConfig__c>();
		AppConfig__c AppConfig = new AppConfig__c();
        AppConfig.Name = 'Manipulation_Timeout';
        AppConfig.Value__c = '120000';        
        apps.add(AppConfig);

        insert apps;
        
    }
    
    @isTest static void InsertService() {
        
        Test.startTest();
               
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();       
        String body = '{"object_name" : "Account","body" : {"First_name_PE__c":"TestService"}}';
        req.requestURI = baseUrl+'/services/apexrest/data/V1.0/sobjects/manipulation/';  
        req.addHeader('Content-Type', 'application/json');
        req.addHeader('Sforce-Auto-Assign', 'false');
        req.requestBody = Blob.valueof(body);
        req.httpMethod = 'POST';
         
        
        RestContext.request = req;
        RestContext.response = res;
        
        ManipulationObjectService.InsertUpdate();

        Test.stopTest();
    }
    @isTest static void UpdateService() {
        
        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();  
        String body = '{"object_name" : "Task","record_id" : "00T1s000001nczxEAA","body" : {"CallDurationInSeconds":"120","Status" : "Completed"}}';
        req.requestURI = baseUrl+'/services/apexrest/data/V1.0/sobjects/manipulation/';  
        req.requestBody = Blob.valueof(body);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response = res;
        
        ManipulationObjectService.InsertUpdate();
        
        Test.stopTest();
    }
    
    @isTest static void UpsertService() {
        
        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();  
        String body = '{"object_name" : "Task","record_id" : "00T1s000001nczxEAA","extId_field" : "Test","body" : {"CallDurationInSeconds":"120","Status" : "Completed"}}';
        req.requestURI = baseUrl+'/services/apexrest/data/V1.0/sobjects/manipulation/';  
        req.requestBody = Blob.valueof(body);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        ManipulationObjectService.InsertUpdate();
        
        Test.stopTest();
    }
    
     @isTest static void ErrorService() {
        
        Test.startTest();
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();  
        String body = '{Test" : 1111}';
        req.requestURI = baseUrl+'/services/apexrest/data/V1.0/sobjects/manipulation/';  
        req.requestBody = Blob.valueof(body);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        ManipulationObjectService.InsertUpdate();
        
        Test.stopTest();
    }
}