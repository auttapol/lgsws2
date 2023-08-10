@isTest
public with sharing class RTL_LGS_InquiryScoringConDetailTest {
    private static String encryptKey {
        get {
            return '645cd9c4fb491a9ea4fe5589d291fe3bbddf8ef04f22df0cea7277460fb9a0e1';
            // return (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), 'get_lgs_key');
        }
    }

    @TestSetup
    static void makeData() {
        Inquiry_List__c inquiryList = new Inquiry_List__c(
            Inquiry_Name__c = 'LGS_InquiryScoringConDetail',
            Salesforce_Object__c = 'Lead_Scoring_Condition_Detail__c',
            Message_Type__c ='Test'
        );
        insert inquiryList;

        Inquiry_Key__c inquiryKey = new Inquiry_Key__c(
            Parent_Id__c = inquiryList.Id,
            Key_Field__c = 'Lead_Scoring_Condition__r.Lead_Scoring_List__r.id',
            Key_Parameter__c = 'inquiryKeyId'
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

        List<LeadScoringController.conditionDetailObject> leadConDetailList = new List<LeadScoringController.conditionDetailObject>();
        LeadScoringController.conditionDetailObject leadConDetail = new LeadScoringController.conditionDetailObject();
        leadConDetail.Operator = '=';
        leadConDetail.Value1 = '10';
        leadConDetail.Value2 = '';
        leadConDetail.Score = 10;
        leadConDetail.Id = '';
        leadConDetail.inputrowIndex = '1';
        leadConDetailList.add(leadConDetail);
        // leadConDetailL.Id = '';
        LeadScoringController.insertScoringConDetail(LSC.id, leadConDetailList);
    }

    @IsTest
    static void testGetLeadScorConDetail(){
        Test.startTest();
        Lead_Scoring_List__c LSL = [SELECT id FROM Lead_Scoring_List__c LIMIT 1];
        // String LSC = [SELECT id FROM Lead_Scoring_Condition__c LIMIT 1].id;
        // Lead_Scoring_Condition_Detail__c leadConDetail = new Lead_Scoring_Condition_Detail__c();
        // leadConDetail.Operation__c = '=';
        // leadConDetail.Value1__c = '10';
        // leadConDetail.Value2__c = '';
        // leadConDetail.Score__c = 10;
        // leadConDetail.Priority__c = 1;
        // leadConDetail.Lead_Scoring_Condition__c = LSC;
        // insert leadConDetail;

        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            RTL_AL_WsCampaignMemberInfo webserviceClass = new RTL_AL_WsCampaignMemberInfo();
            System.debug(encryptKey);
            RestRequest request = new RestRequest();
            request.resourcePath = '0';
            request.addHeader('Integration-System', 'LGS');
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/LeadScore/getScoringConditionDetail/*';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'Scoring_Criteria_Id' => LSL.id
                }
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            System.debug('request -->'+request);
            RTL_AL_WebserviceAbstract.SCSReqRes responseEncrypt = RTL_LGS_InquiryScoringConDetail.getScoringConditionDetail();
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetLeadScorConDetailException(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            RTL_AL_WsCampaignMemberInfo webserviceClass = new RTL_AL_WsCampaignMemberInfo();
            System.debug(encryptKey);
            RestRequest request = new RestRequest();
            request.resourcePath = '0';
            // request.addHeader('Integration-System', 'LGS');
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/LeadScore/getScoringConditionDetail/*';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'Scoring_Criteria_Id' => 'DOUTBOUND1HN00001023'
                }
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            System.debug('request -->'+request);
            try {
                RTL_AL_WebserviceAbstract.SCSReqRes responseEncrypt = RTL_LGS_InquiryScoringConDetail.getScoringConditionDetail();
            } catch (Exception e) {
                
            }
            
        }
        Test.stopTest();
    }

    @IsTest
    static void testEmptyLeadScorConDetail(){
        Test.startTest();
        Lead_Scoring_List__c LSL = [SELECT id FROM Lead_Scoring_List__c LIMIT 1];
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            RTL_AL_WsCampaignMemberInfo webserviceClass = new RTL_AL_WsCampaignMemberInfo();
            System.debug(encryptKey);
            RestRequest request = new RestRequest();
            request.resourcePath = '0';
            request.addHeader('Integration-System', 'LGS');
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/LeadScore/getScoringConditionDetail/*';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'Scoring_Criteria_Id' => LSL.id
                }
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            System.debug('request -->'+request);
            RTL_AL_WebserviceAbstract.SCSReqRes responseEncrypt = RTL_LGS_InquiryScoringConDetail.getScoringConditionDetail();
        }
        Test.stopTest();
    }

}