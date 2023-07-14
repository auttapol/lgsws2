@isTest
public with sharing class LeadScoreCalculationTest {
    @testSetup static void setup() {
        TestUtils.createAppConfig();
        TestUtils.prepareIntegrationMapping();

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

        Lead_Scoring_Condition__c LSC1 = new Lead_Scoring_Condition__c();
        LSC1.Field_Mapping__c = 'LGS_Partner__c';
        LSC1.Object__c = 'CampaignMember';
        LSC1.Lead_Scoring_List__c = LSL.id;
        LSC1.Weight__c = 25;
        insert LSC1;

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
        
        

        Lead_Scoring_Condition__c LeadConListQuery = [SELECT id FROM Lead_Scoring_Condition__c WHERE Lead_Scoring_List__c = :LSL.id LIMIT 1];
        List<LeadScoringController.conditionDetailObject> leadConDetailList = new List<LeadScoringController.conditionDetailObject>();
        LeadScoringController.conditionDetailObject leadConDetail = new LeadScoringController.conditionDetailObject();
        leadConDetail.Operator = '=';
        leadConDetail.Value1 = '10';
        leadConDetail.Value2 = '';
        leadConDetail.Score = 10;
        leadConDetail.Id = '';
        leadConDetail.inputrowIndex = '1';
        leadConDetailList.add(leadConDetail);
        LeadScoringController.insertScoringConDetail(LeadConListQuery.id, leadConDetailList);

        Campaignmember cm = new Campaignmember();
        cm.RTL_Marketing_Code__c = 'DOUTBOUND1HN00001023';
        cm.RTL_AL_response__c = true;
        cm.Customer__c = null;
        cm.RTL_AL_Response_Flage__c = true;
        cm.RTL_Is_Send_To_HPAP__c = false;
        cm.RTL_Is_Interface_Success__c = true;
        cm.CampaignId = camp.Id;
        cm.LeadId = l.Id;
        cm.Scoring_Condition_Id__c = LSL.id;
        cm.RTL_Lead_Score_Flag__c = false;
        cm.LGS_Partner__c = '10';
        insert cm;
    }

    @isTest
    static void testcamploadUser() {
        User CamploadUser = TestUtils.createUsers(1,'Campload','User','ryu@dummy.com', false).get(0);
        CamploadUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'TMB CampLoad CC Report Specialist' LIMIT 1].Id;
        insert CamploadUser;
        Lead_Scoring_List__c LeadScoringId = [SELECT id FROM Lead_Scoring_List__c LIMIT 1];
        campaignmember cm = [SELECT id FROM campaignmember LIMIT 1];
        System.runAs(CamploadUser){
           
        }
    }
}