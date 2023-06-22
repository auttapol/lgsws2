@isTest

public with sharing class RTL_AL_WsCampaignMemberTest {
    public RTL_AL_WsCampaignMemberTest() {

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

        Lead l = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
        l.RTL_Branch_Code_Rpt__c = '611';
        insert l;

        Campaignmember cm = new Campaignmember();
        cm.RTL_Marketing_Code__c = 'DOUTBOUND1HN00001023';
        cm.RTL_AL_response__c = true;
        cm.Customer__c = null;
        // cm.RTL_RelatedOpportunity_1__c = null;
        // cm.RTL_RelatedOpportunity_2__c = null;
        // cm.RTL_RelatedOpportunity_3__c = null;
        // cm.RTL_RelatedOpportunity_4__c = null;
        // cm.RTL_RelatedOpportunity_5__c = null;
        cm.RTL_AL_Response_Flage__c = true;
        cm.RTL_Is_Send_To_HPAP__c = true;
        cm.RTL_Is_Interface_Success__c = true;
        cm.CampaignId = camp.Id;
        cm.LeadId = l.Id;
        insert cm;

        // Campaignmember cm2 = new Campaignmember();
        // cm2.RTL_Marketing_Code__c = 'DOUTBOUND1HN00001027';
        // cm2.RTL_AL_response__c = false;
        // cm2.Customer__c = null;
        // // cm2.RTL_RelatedOpportunity_1__c = null;
        // // cm2.RTL_RelatedOpportunity_2__c = null;
        // // cm2.RTL_RelatedOpportunity_3__c = null;
        // // cm2.RTL_RelatedOpportunity_4__c = null;
        // cm2.RTL_RelatedOpportunity_5__c = null;
        // cm2.RTL_AL_Response_Flage__c = false;
        // cm2.RTL_Is_Send_To_HPAP__c = false;
        // cm2.RTL_Is_Interface_Success__c = true;
        // cm2.CampaignId = camp.Id;
        // cm2.LeadId = l.Id;
        // insert cm2;

        

    }

    @IsTest
    static void testCreateAccountAndCampaignMemberHPAP(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            RTL_AL_WsCampaignMember webserviceClass = new RTL_AL_WsCampaignMember();
            System.debug(encryptKey);
            RestRequest request = new RestRequest();
            request.resourcePath = '0';
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/getByMarketingCode/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'marketingCode' => 'DOUTBOUND1HN00001023'
                    
                    }
                
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes responseEncrypt = RTL_AL_WsCampaignMember.getOfferStatus();
        }
        Test.stopTest();
    }
    @IsTest
    static void testCreateAccountAndCampaignMemberHPAPFailled(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            RTL_AL_WsCampaignMember webserviceClass = new RTL_AL_WsCampaignMember();
            System.debug(encryptKey);
            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/getByMarketingCode/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'marketingCode' => 'DOUTBOUND1HN00001691'
                    
                    }
                
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes responseEncrypt = RTL_AL_WsCampaignMember.getOfferStatus();
        }
        Test.stopTest();
    }
    // 96%
     @IsTest
     static void testCreateAccountAndCampaignMemberHPAPIsFalse(){
         Test.startTest();
         User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
         System.runAs(sfextapi){
             RTL_AL_WsCampaignMember webserviceClass = new RTL_AL_WsCampaignMember();
             System.debug(encryptKey);
             RestRequest request = new RestRequest();
             request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/getByMarketingCode/';
             request.httpMethod = 'POST';
             request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                 new Map<String, Object>{
                     'marketingCode' => 'DOUTBOUND1HN00001027'
                    
                     }
                
             ), encryptKey)));
             RestContext.request = request;
             Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
             RTL_AL_WebserviceAbstract.SCSReqRes responseEncrypt = RTL_AL_WsCampaignMember.getOfferStatus();
         }
         Test.stopTest();
     }
}