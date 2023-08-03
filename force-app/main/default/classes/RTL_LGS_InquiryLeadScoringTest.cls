@isTest
public with sharing class RTL_LGS_InquiryLeadScoringTest {

    private static String encryptKey {
        get {
            return 'c3018e70d8b7df129e502b2e12b8e4069e5c4cbae48ed9041a1454f069233265';
            // return (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), 'get_lgs_key');
        }
    }

    @TestSetup
    static void makeData() {
        Inquiry_List__c inquiryList = new Inquiry_List__c(
            Inquiry_Name__c = 'LGS_InquiryLeadScoringList',
            Salesforce_Object__c = 'Lead_Scoring_List__c',
            Message_Type__c ='Test'
        );
        insert inquiryList;

        Inquiry_Key__c inquiryKey = new Inquiry_Key__c(
            Parent_Id__c = inquiryList.Id,
            Key_Field__c = 'Name',
            Key_Parameter__c = 'Name'
        );
        insert inquiryKey;

        Inquiry_Data__c inquiryData = new Inquiry_Data__c(
            Parent_Id__c = inquiryList.Id,
            Salesforce_Field__c = 'Name',
            JSON_Mapping_Name__c = 'Name',
            Field_Order__c = 1,
            IsActive__c = true
        );

        insert inquiryData;
        Lead_Scoring_List__c LSL = new Lead_Scoring_List__c();
        LSL.Description__c = 'Test1_Description';
        LSL.Total_Weight__c = 100;
        LSL.Name = 'Test1';
        LSL.isActive__c = true;
        insert LSL;

        Lead_Scoring_Condition__c LSC = new Lead_Scoring_Condition__c();
        LSC.Field_Mapping__c = 'LGS_Partner__c';
        LSC.Object__c = 'Lead';
        LSC.Lead_Scoring_List__c = LSL.id;
        LSC.Weight__c = 25;
        insert LSC;
    }

    @IsTest
    static void testGetLeadScoring(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            RTL_AL_WsCampaignMemberInfo webserviceClass = new RTL_AL_WsCampaignMemberInfo();
            System.debug(encryptKey);
            RestRequest request = new RestRequest();
            request.resourcePath = '0';
            request.addHeader('Integration-System', 'LGS');
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/CampaignMember/getInfoByMarketingCode/*';
            request.httpMethod = 'POST';
            // request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
            //     new Map<String, Object>{}
            // ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            System.debug('request -->'+request);
            RTL_AL_WebserviceAbstract.SCSReqRes responseEncrypt = RTL_LGS_InquiryLeadScoringList.getLeadScoringListInfo();
        }
        Test.stopTest();
    }
}