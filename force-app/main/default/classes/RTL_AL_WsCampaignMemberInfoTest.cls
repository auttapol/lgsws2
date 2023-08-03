@isTest
public with sharing class RTL_AL_WsCampaignMemberInfoTest {
    public RTL_AL_WsCampaignMemberInfoTest() {

    }

    private static String encryptKey {
        get {
            return 'c3018e70d8b7df129e502b2e12b8e4069e5c4cbae48ed9041a1454f069233265';
            // (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), SCSMessageAPIUtil.INTEGRATE_SYSTEM.ONEAPP);
        }
    }

    @TestSetup
    static void makeData() {
        TestUtils.createAppConfig();
        AppConfig__c appConfig = AppConfig__c.getValues('runtrigger');
        appConfig.Value__c = 'true';
        update appConfig;
        
        Id recordTypeId  = [select Id from RecordType where SobjectType = 'Campaign' and DeveloperName=: 'Dummy_Campaign' and IsActive=true ].Id;
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = Recordtypeid;
        insert camp;

        Campaign camp1 = new Campaign();
        camp1.Name = 'Campaign_1';
        camp1.Segment__c = 'MB';
        camp1.OwnerId  = UserInfo.getUserId();
        camp1.RecordTypeId = Recordtypeid;
        insert camp1;

        Lead l = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
        l.RTL_Branch_Code_Rpt__c = '611';
        insert l;
        Lead l1 = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
        l1.RTL_Branch_Code_Rpt__c = '611';
        insert l1;
        Lead l2 = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
        l2.RTL_Branch_Code_Rpt__c = '611';
        l2.Status = 'Duplicated';
        insert l2;

        Campaignmember cm = new Campaignmember();
        cm.RTL_Marketing_Code__c = 'DOUTBOUND1HN00001023';
        cm.RTL_AL_response__c = true;
        cm.Customer__c = null;
        cm.RTL_AL_Response_Flage__c = true;
        cm.RTL_Is_Send_To_HPAP__c = true;
        cm.RTL_Is_Interface_Success__c = true;
        cm.CampaignId = camp.Id;
        cm.LeadId = l.Id;
        insert cm;

        Campaignmember cm1 = new Campaignmember();
        cm1.RTL_Web_Unique_ID__c = 'DOUTBOUND1HN00001023';
        cm1.RTL_AL_response__c = true;
        cm1.Customer__c = null;
        cm1.RTL_AL_Response_Flage__c = true;
        cm1.RTL_Is_Send_To_HPAP__c = true;
        cm1.RTL_Is_Interface_Success__c = true;
        cm1.CampaignId = camp1.Id;
        cm1.LeadId = l1.Id;
        insert cm1;

        Inquiry_List__c inquiryList = new Inquiry_List__c(
            Inquiry_Name__c = 'LGS_InquiryCampInfo',
            Salesforce_Object__c = 'Campaignmember',
            Message_Type__c ='Test'
        );
        insert inquiryList;

        Inquiry_Key__c inquiryKey = new Inquiry_Key__c(
            Parent_Id__c = inquiryList.Id,
            Key_Field__c = 'RTL_Web_Unique_ID__c',
            Key_Parameter__c = 'RTL_Web_Unique_ID__c'
        );
        insert inquiryKey;

        Inquiry_Data__c inquiryData = new Inquiry_Data__c(
            Parent_Id__c = inquiryList.Id,
            Salesforce_Field__c = 'RTL_Web_Unique_ID__c',
            JSON_Mapping_Name__c = 'RTL_Web_Unique_ID__c',
            Field_Order__c = 1,
            IsActive__c = true
        );
        insert inquiryData;

    }

    @IsTest
    static void testGetCarInfoByWebUniqueId(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            RTL_AL_WsCampaignMemberInfo webserviceClass = new RTL_AL_WsCampaignMemberInfo();
            System.debug(encryptKey);
            RestRequest request = new RestRequest();
            request.resourcePath = '0';
            request.addHeader('Integration-System', 'lgs');
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/CampaignMember/getInfoByMarketingCode/*';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'webUniqueId' => 'DOUTBOUND1HN00001023' 
                }
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            System.debug('request -->'+request);
            RTL_AL_WebserviceAbstract.SCSReqRes responseEncrypt = RTL_AL_WsCampaignMemberInfo.getCarInfo();
        }
        Test.stopTest();
    }
    @IsTest
    static void testGetCarInfoByMarketingCode(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            RTL_AL_WsCampaignMemberInfo webserviceClass = new RTL_AL_WsCampaignMemberInfo();
            System.debug(encryptKey);
            RestRequest request = new RestRequest();
            request.resourcePath = '0';
            request.addHeader('Integration-System', 'lgs');
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/CampaignMember/getInfoByMarketingCode/*';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'marketingCode' => 'DOUTBOUND1HN00001023' 
                }
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            System.debug('request -->'+request);
            RTL_AL_WebserviceAbstract.SCSReqRes responseEncrypt = RTL_AL_WsCampaignMemberInfo.getCarInfo();
        }
        Test.stopTest();
    }
    // @IsTest
    // static void testGetCarInfoByWebUniqueId(){
    //     Test.startTest();
    //     User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
    //     System.runAs(sfextapi){
    //         RTL_AL_WsCampaignMemberInfo webserviceClass = new RTL_AL_WsCampaignMemberInfo();
    //         System.debug(encryptKey);
    //         RestRequest request = new RestRequest();
    //         request.resourcePath = '0';
    //         request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/CampaignMember/getInfoByMarketingCode/*';
    //         request.httpMethod = 'POST';
    //         request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
    //             new Map<String, Object>{
    //                 'webUniqueId' => 'DOUTBOUND1HN00001023'
    //             }
    //         ), encryptKey)));
    //         RestContext.request = request;
    //         Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
    //         RTL_AL_WebserviceAbstract.SCSReqRes responseEncrypt = RTL_AL_WsCampaignMemberInfo.getCarInfo();
    //     }
    //     Test.stopTest();
    // }

    @IsTest
    static void testGetCarInfoByException(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            RTL_AL_WsCampaignMemberInfo webserviceClass = new RTL_AL_WsCampaignMemberInfo();
            System.debug(encryptKey);
            RestRequest request = new RestRequest();
            request.resourcePath = '0';
            request.addHeader('Integration-System', 'oneapp');
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/CampaignMember/getInfoByMarketingCode/*';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'webUniqueId' => 'DOUTBOUND1HN00001023'
                }
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes responseEncrypt = RTL_AL_WsCampaignMemberInfo.getCarInfo();
        }
        Test.stopTest();
    }
    @IsTest
    static void testGetCarInfoByException2(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            RTL_AL_WsCampaignMemberInfo webserviceClass = new RTL_AL_WsCampaignMemberInfo();
            System.debug(encryptKey);
            RestRequest request = new RestRequest();
            request.resourcePath = '0';
            request.addHeader('Integration-System', 'oneapp');
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/CampaignMember/getInfoByMarketingCode/*';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'webUniqueId' => ''
                }
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes responseEncrypt = RTL_AL_WsCampaignMemberInfo.getCarInfo();
        }
        Test.stopTest();
    }
}