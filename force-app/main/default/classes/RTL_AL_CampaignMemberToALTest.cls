@isTest
public with sharing class RTL_AL_CampaignMemberToALTest {
    @TestSetup
    static void makeData() {
        TestUtils.createAppConfig();
        TestUtils.prepareIntegrationMapping();

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
        l.RTL_Branch_Code_Rpt__c = '611';
        insert l1;
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
        cm1.RTL_Web_Unique_ID__c = 'DOUTBOUND1HN00001024';
        cm1.RTL_AL_response__c = true;
        cm1.Customer__c = null;
        cm1.RTL_AL_Response_Flage__c = true;
        cm1.RTL_Is_Send_To_HPAP__c = true;
        cm1.RTL_Is_Interface_Success__c = true;
        cm1.CampaignId = camp1.Id;
        cm1.LeadId = l1.Id;
        insert cm1;


    }

    @IsTest
    static void testSendCampaignMemberToAL(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            List<CampaignMember> cm = [SELECT Id,Name FROM CampaignMember ];
            Test.setMock(HttpCalloutMock.class, new MockHPAPHttpResponse());
            RTL_AL_CampaignMemberToAL.sendCampaignMemberToAL(cm);
        }
        Test.stopTest();
    }
}