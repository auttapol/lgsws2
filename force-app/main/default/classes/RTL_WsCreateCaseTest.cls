@isTest
public class RTL_WsCreateCaseTest {
    
    
    private static String encryptKey {
        get {
            return '208f6c8723b80c36fefc349575764dd14baf52d950a98c101034c403b1172c12';
        }
    }
    
    @testSetup static void setupData(){
        
        TestUtils.createAppConfig();
        
        Account acc = RTL_TestUtility.createAccounts(1,false).get(0);
        insert acc;
        
        List<Service_Type_Matrix__c> serviceTypeList = new List<Service_Type_Matrix__c>();
        
        Service_Type_Matrix__c serviceType = New Service_Type_Matrix__c();
        serviceType.Segment__c = 'SBG';
        serviceType.Service_Level1__c = 'Service Level1';
        serviceType.Service_Level2__c = 'Service level2';
        serviceType.Service_Level3__c = 'Service level3';
        serviceType.Service_Level4__c = 'Service level4';
        serviceType.SLA__c = 7;
        serviceType.Severity__c = '1';
        serviceType.Responsible_BU__c = 'Test_Queue_SE';
        serviceType.active__c = true;
        serviceType.Service_issue_EN__c = 'english version';
        serviceType.Validate_Code__c = '17454';
        serviceType.Responsible_BU_Hop_2__c = 'RMC';
        serviceType.Responsible_BU_Hop_3__c ='test queue';
        serviceType.Closed_By_BU__c = 'REGISTER';
        serviceType.SLA_Hop_1_Day__c = 1;
        serviceType.SLA_Hop_2_Day__c = 1;
        serviceType.SLA_Hop_3_Day__c = 1;
        serviceType.SLA_Closed_By_BU_Day__c = 1;
        // [2020-03-26] Case Select Template.
        serviceType.Service_Template__c = 'CreditService';
        serviceTypeList.add(serviceType);
        insert serviceTypeList;
        
    }
    
    @isTest
    public static void createCase_FoundAccount()
    {                 
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        test.startTest();
        Account acc = [SELECT Id, TMB_Customer_ID_PE__c FROM Account];
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            String body = '{'+
                '"Customer_ID_OneApp__c":"'+acc.TMB_Customer_ID_PE__c+'",'+
                '"FCR__c":true,'+
                '"Origin":"One APP",'+
                '"Service_Type_Matrix_Code__c":"17454",'+
                '"Contact_Person_Name__c":"firstname lastname",'+
                '"Description":"this is an example of description",'+
                '"External_Ref_ID":"",'+
                '"Root_Cause_List__c":"Customer_ลูกค้าร้องขอบริการ",'+
                '"Resolution_LIst__c":"ดำเนินการตามที่ลูกค้าร้องขอ"'+
                '}';
            RestRequest request = new RestRequest();
            request.requestUri = baseUrl+'/services/apexrest/data/V1.0/sobjects/Case';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf((String)SCSMessageAPIUtil.encryptMessageWithKey(body, encryptKey));
            
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_WsCreateCase.createCase();
        }
        test.stopTest();
        
    }
    
    @isTest
    public static void createCase_NotFoundAccount()
    {                 
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        test.startTest();
        Account acc = [SELECT Id, TMB_Customer_ID_PE__c FROM Account];
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            String body = '{'+
                '"Customer_ID_OneApp__c":"001100000000000000000099999998",'+
                '"FCR__c":true,'+
                '"Origin":"One APP",'+
                '"Service_Type_Matrix_Code__c":"17454",'+
                '"Contact_Person_Name__c":"firstname lastname",'+
                '"Description":"this is an example of description",'+
                '"External_Ref_ID":"",'+
                '"Root_Cause_List__c":"Customer_ลูกค้าร้องขอบริการ",'+
                '"Resolution_LIst__c":"ดำเนินการตามที่ลูกค้าร้องขอ"'+
                '}';
            RestRequest request = new RestRequest();
            request.requestUri = baseUrl+'/services/apexrest/data/V1.0/sobjects/Case';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf((String)SCSMessageAPIUtil.encryptMessageWithKey(body, encryptKey));
            
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_WsCreateCase.createCase();
        }
        test.stopTest();
        
    }
    
    @isTest
    public static void createCase_ServiceCodeError()
    {                 
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            String body = '{'+
                '"Customer_ID_OneApp__c":"001100000000000000000099999998",'+
                '"FCR__c":true,'+
                '"Origin":"One APP",'+
                '"Service_Type_Matrix_Code__c":"1111",'+
                '"Contact_Person_Name__c":"firstname lastname",'+
                '"Description":"this is an example of description",'+
                '"External_Ref_ID":"",'+
                '"Root_Cause_List__c":"Customer_ลูกค้าร้องขอบริการ",'+
                '"Resolution_LIst__c":"ดำเนินการตามที่ลูกค้าร้องขอ"'+
                '}';
            RestRequest request = new RestRequest();
            request.requestUri = baseUrl+'/services/apexrest/data/V1.0/sobjects/Case';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf((String)SCSMessageAPIUtil.encryptMessageWithKey(body, encryptKey));
            
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_WsCreateCase.createCase();
        }
        test.stopTest();
        
    }
    
    @isTest
    public static void createCase_requireFieldError()
    {                 
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            String body = '{'+
                '"Customer_ID_OneApp__c":"001100000000000000000099999998",'+
                '"FCR__c":true,'+
                '"Contact_Person_Name__c":"firstname lastname",'+
                '"Description":"this is an example of description",'+
                '"External_Ref_ID":"",'+
                '"Root_Cause_List__c":"Customer_ลูกค้าร้องขอบริการ",'+
                '"Resolution_LIst__c":"ดำเนินการตามที่ลูกค้าร้องขอ"'+
                '}';
            RestRequest request = new RestRequest();
            request.requestUri = baseUrl+'/services/apexrest/data/V1.0/sobjects/Case';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf((String)SCSMessageAPIUtil.encryptMessageWithKey(body, encryptKey));
            
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_WsCreateCase.createCase();
        }
        test.stopTest();
        
    }
    
    @isTest
    public static void createCase_requireFieldisNull()
    {                 
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            String body = '{'+
                '"Customer_ID_OneApp__c":"001100000000000000000099999998",'+
                '"FCR__c":true,'+
                '"Contact_Person_Name__c":null,'+
                '"Description":"this is an example of description",'+
                '"External_Ref_ID":"",'+
                '"Root_Cause_List__c":"Customer_ลูกค้าร้องขอบริการ",'+
                '"Resolution_LIst__c":"ดำเนินการตามที่ลูกค้าร้องขอ"'+
                '}';
            RestRequest request = new RestRequest();
            request.requestUri = baseUrl+'/services/apexrest/data/V1.0/sobjects/Case';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf((String)SCSMessageAPIUtil.encryptMessageWithKey(body, encryptKey));
            
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_WsCreateCase.createCase();
        }
        test.stopTest();
        
    }
    
    @isTest
    public static void createCase_Fail()
    {                 
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            String body = '{'+
                '"Customer_ID_OneApp__c":"001100000000000000000099999998",'+
                '"FCR__c":true,'+
                '"Contact_Person_Name__c":"firstname lastname",'+
                '"Description":"this is an example of description",'+
                '"External_Ref_ID":"",'+
                '"Root_Cause_List__c"'+
                '}';
            RestRequest request = new RestRequest();
            request.requestUri = baseUrl+'/services/apexrest/data/V1.0/sobjects/Case';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf((String)SCSMessageAPIUtil.encryptMessageWithKey(body, encryptKey));
            
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_WsCreateCase.createCase();
        }
        test.stopTest();
        
    }
    
    @isTest
    public static void createCase_OneApp()
    {                 
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        test.startTest();
        Account acc = [SELECT Id, TMB_Customer_ID_PE__c FROM Account];
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            String body = '{'+
                '"Customer_ID_OneApp__c":"001100000000000000000099999998",'+
                '"FCR__c":true,'+
                '"Origin":"One APP",'+
                '"Service_Type_Matrix_Code__c":"O0011",'+
                '"Contact_Person_Name__c":"firstname lastname",'+
                '"Description":"this is an example of description",'+
                '"External_Ref_ID":"",'+
                '"Root_Cause_List__c":"Customer_ลูกค้าร้องขอบริการ",'+
                '"Resolution_LIst__c":"ดำเนินการตามที่ลูกค้าร้องขอ"'+
                '}';
            RestRequest request = new RestRequest();
            request.requestUri = baseUrl+'/services/apexrest/data/V1.0/sobjects/Case';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf((String)SCSMessageAPIUtil.encryptMessageWithKey(body, encryptKey));
            
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_WsCreateCase.createCase();
        }
        test.stopTest();
        
    }
}