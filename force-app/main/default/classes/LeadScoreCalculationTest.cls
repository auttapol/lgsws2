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

        List<Lead_Scoring_Condition__c> LSCList = new List<Lead_Scoring_Condition__c>();
        Lead_Scoring_Condition__c LSC = new Lead_Scoring_Condition__c();
        LSC.Field_Mapping__c = 'LGS_001__c';
        LSC.Object__c = 'Lead';
        LSC.Lead_Scoring_List__c = LSL.id;
        LSC.Weight__c = 25;
        LSCList.add(LSC);

        Lead_Scoring_Condition__c LSC1 = new Lead_Scoring_Condition__c();
        LSC1.Field_Mapping__c = 'LGS_002__c';
        LSC1.Object__c = 'CampaignMember';
        LSC1.Lead_Scoring_List__c = LSL.id;
        LSC1.Weight__c = 25;
        LSCList.add(LSC1);

        Lead_Scoring_Condition__c LSC2 = new Lead_Scoring_Condition__c();
        LSC2.Field_Mapping__c = 'LGS_003__c';
        LSC2.Object__c = 'CampaignMember';
        LSC2.Lead_Scoring_List__c = LSL.id;
        LSC2.Weight__c = 25;
        LSCList.add(LSC2);

        Lead_Scoring_Condition__c LSC3 = new Lead_Scoring_Condition__c();
        LSC3.Field_Mapping__c = 'LGS_004__c';
        LSC3.Object__c = 'CampaignMember';
        LSC3.Lead_Scoring_List__c = LSL.id;
        LSC3.Weight__c = 25;
        LSCList.add(LSC3);

        Lead_Scoring_Condition__c LSC4 = new Lead_Scoring_Condition__c();
        LSC4.Field_Mapping__c = 'LGS_005__c';
        LSC4.Object__c = 'CampaignMember';
        LSC4.Lead_Scoring_List__c = LSL.id;
        LSC4.Weight__c = 25;
        LSCList.add(LSC4);

        Lead_Scoring_Condition__c LSC5 = new Lead_Scoring_Condition__c();
        LSC5.Field_Mapping__c = 'Customer__c';
        LSC5.Object__c = 'CampaignMember';
        LSC5.Lead_Scoring_List__c = LSL.id;
        LSC5.Weight__c = 25;
        LSCList.add(LSC5);

        Lead_Scoring_Condition__c LSC6 = new Lead_Scoring_Condition__c();
        LSC6.Field_Mapping__c = 'LGS_006__c';
        LSC6.Object__c = 'CampaignMember';
        LSC6.Lead_Scoring_List__c = LSL.id;
        LSC6.Weight__c = 25;
        LSCList.add(LSC6);

        insert LSCList;

        Id recordTypeId  = [select Id from RecordType where SobjectType = 'Campaign' and DeveloperName=: 'Dummy_Campaign' and IsActive=true ].Id;
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = Recordtypeid;
        insert camp;
      
        Lead_Scoring_Condition__c LeadConListQuery = [SELECT id FROM Lead_Scoring_Condition__c WHERE id = :LSC.id LIMIT 1];
        Lead_Scoring_Condition__c LeadConListQuery1 = [SELECT id FROM Lead_Scoring_Condition__c WHERE id = :LSC1.id LIMIT 1];
        Lead_Scoring_Condition__c LeadConListQuery2 = [SELECT id FROM Lead_Scoring_Condition__c WHERE id = :LSC2.id LIMIT 1];
        Lead_Scoring_Condition__c LeadConListQuery3 = [SELECT id FROM Lead_Scoring_Condition__c WHERE id = :LSC3.id LIMIT 1];
        Lead_Scoring_Condition__c LeadConListQuery4 = [SELECT id FROM Lead_Scoring_Condition__c WHERE id = :LSC4.id LIMIT 1];
        List<LeadScoringController.conditionDetailObject> leadConDetailList = new List<LeadScoringController.conditionDetailObject>();
        List<LeadScoringController.conditionDetailObject> leadConDetail1List = new List<LeadScoringController.conditionDetailObject>();
        List<LeadScoringController.conditionDetailObject> leadConDetail2List = new List<LeadScoringController.conditionDetailObject>();
        List<LeadScoringController.conditionDetailObject> leadConDetail3List = new List<LeadScoringController.conditionDetailObject>();
        List<LeadScoringController.conditionDetailObject> leadConDetail4List = new List<LeadScoringController.conditionDetailObject>();
        LeadScoringController.conditionDetailObject leadConDetail = new LeadScoringController.conditionDetailObject();
        leadConDetail.Operator = '=';
        leadConDetail.Value1 = '10';
        leadConDetail.Value2 = '';
        leadConDetail.Score = 10;
        leadConDetail.Id = '';
        leadConDetail.inputrowIndex = '1';
        leadConDetailList.add(leadConDetail);
        LeadScoringController.conditionDetailObject leadConDetail1 = new LeadScoringController.conditionDetailObject();
        leadConDetail1.Operator = 'Contain';
        leadConDetail1.Value1 = '10';
        leadConDetail1.Value2 = '';
        leadConDetail1.Score = 10;
        leadConDetail1.Id = '';
        leadConDetail1.inputrowIndex = '1';
        leadConDetail1List.add(leadConDetail1);
        LeadScoringController.conditionDetailObject leadConDetail2 = new LeadScoringController.conditionDetailObject();
        leadConDetail2.Operator = '<';
        leadConDetail2.Value1 = '11';
        leadConDetail2.Value2 = '';
        leadConDetail2.Score = 10;
        leadConDetail2.Id = '';
        leadConDetail2.inputrowIndex = '1';
        leadConDetail2List.add(leadConDetail2);
        LeadScoringController.conditionDetailObject leadConDetail3 = new LeadScoringController.conditionDetailObject();
        leadConDetail3.Operator = '>';
        leadConDetail3.Value1 = '1';
        leadConDetail3.Value2 = '';
        leadConDetail3.Score = 10;
        leadConDetail3.Id = '';
        leadConDetail3.inputrowIndex = '1';
        leadConDetail3List.add(leadConDetail3);
        LeadScoringController.conditionDetailObject leadConDetail4 = new LeadScoringController.conditionDetailObject();
        leadConDetail4.Operator = 'Range';
        leadConDetail4.Value1 = '1';
        leadConDetail4.Value2 = '10';
        leadConDetail4.Score = 10;
        leadConDetail4.Id = '';
        leadConDetail4.inputrowIndex = '1';
        leadConDetail4List.add(leadConDetail4);
        
        LeadScoringController.insertScoringConDetail(LeadConListQuery.id, leadConDetailList);
        LeadScoringController.insertScoringConDetail(LeadConListQuery1.id, leadConDetail1List);
        LeadScoringController.insertScoringConDetail(LeadConListQuery2.id, leadConDetail2List);
        LeadScoringController.insertScoringConDetail(LeadConListQuery3.id, leadConDetail3List);
        LeadScoringController.insertScoringConDetail(LeadConListQuery4.id, leadConDetail4List);

        Lead l = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
        l.RTL_Branch_Code_Rpt__c = '611';
        l.LGS_001__c = '10';
        insert l;

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
        cm.LGS_001__c = '10';
        cm.LGS_002__c = '10';
        cm.LGS_003__c = '10';
        cm.LGS_004__c = '10';
        cm.LGS_005__c = '5';
        cm.LGS_006__c = '5';
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