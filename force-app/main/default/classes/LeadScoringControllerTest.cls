@isTest
public with sharing class LeadScoringControllerTest {
    @testSetup static void setup() {
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
    @isTest
    static void testcamploadUser() {
        User CamploadUser = TestUtils.createUsers(1,'Campload','User','ryu@dummy.com', false).get(0);
        CamploadUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'TMB CampLoad CC Report Specialist' LIMIT 1].Id;
        insert CamploadUser;
        Lead_Scoring_List__c LeadScoringId = [SELECT id FROM Lead_Scoring_List__c LIMIT 1];
        System.runAs(CamploadUser){
            LeadScoringController.getRecord(LeadScoringId.id);
            LeadScoringController.getFieldName();
            LeadScoringController.getConDetail(LeadScoringId.id);

            String existName = 'Test_update_leadScoring';
            String newName = 'Test_insert_leadScoring';
            Integer TotalWeight = 100;
            String Description = 'Test Description';
            Boolean isActive = true;

            LeadScoringController.insertLeadScoring(LeadScoringId.id, existName, TotalWeight, Description, isActive);
            LeadScoringController.insertLeadScoring('a5P1s0000002is0EAC', newName, TotalWeight, Description, isActive);
            List<LeadScoringController.conditionObject> leadConList = new List<LeadScoringController.conditionObject>();
            LeadScoringController.conditionObject leadCon = new LeadScoringController.conditionObject();
            leadCon.LObject = 'Lead';
            leadCon.FieldName = 'LeadSource';
            leadCon.FieldType = '';
            leadCon.Length = '0';
            leadCon.APIName = 'LeadSource';
            leadCon.Weight = 20;
            leadConList.add(leadCon);
            // leadConL.Id = '';
            LeadScoringController.insertScoringCon(LeadScoringId.id, leadConList);

            Lead_Scoring_Condition__c LeadConListQuery1 = [SELECT id FROM Lead_Scoring_Condition__c WHERE Lead_Scoring_List__c = :LeadScoringId.id LIMIT 1];
            List<LeadScoringController.conditionObject> leadConList1 = new List<LeadScoringController.conditionObject>();
            LeadScoringController.conditionObject leadCon1 = new LeadScoringController.conditionObject();
            leadCon1.LObject = 'Lead';
            leadCon1.FieldName = 'LeadSource';
            leadCon1.FieldType = '';
            leadCon1.Length = '0';
            leadCon1.APIName = 'LeadSource';
            leadCon1.Weight = 30;
            leadConList1.add(leadCon1);
            leadCon1.Id = LeadConListQuery1.id;
            LeadScoringController.insertScoringCon(LeadScoringId.id, leadConList1);

            Lead_Scoring_Condition__c LeadConListQuery = [SELECT id FROM Lead_Scoring_Condition__c WHERE Lead_Scoring_List__c = :LeadScoringId.id LIMIT 1];
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
            LeadScoringController.insertScoringConDetail(LeadConListQuery.id, leadConDetailList);
        }
    }

    @isTest
    static void testAdminUser() {
        User adminUser = TestUtils.createUsers(1,'Admin','User','ryu@dummy.com', false).get(0);
        adminUser.ProfileId = [SELECT Id FROM Profile WHERE Name LIKE '%System Admin%' LIMIT 1].Id;
        insert adminUser;
        Lead_Scoring_List__c LeadScoringId = [SELECT id FROM Lead_Scoring_List__c LIMIT 1];
        System.runAs(adminUser){
            LeadScoringController.getRecord(LeadScoringId.id);
            LeadScoringController.getFieldName();
            LeadScoringController.getConDetail(LeadScoringId.id);

            String existName = 'Test_update_leadScoring';
            String newName = 'Test_insert_leadScoring';
            Integer TotalWeight = 100;
            String Description = 'Test Description';
            Boolean isActive = true;

            LeadScoringController.insertLeadScoring(LeadScoringId.id, existName, TotalWeight, Description, isActive);
            LeadScoringController.insertLeadScoring('a5P1s0000002is0EAC', newName, TotalWeight, Description, isActive);
            List<LeadScoringController.conditionObject> leadConList = new List<LeadScoringController.conditionObject>();
            LeadScoringController.conditionObject leadCon = new LeadScoringController.conditionObject();
            leadCon.LObject = 'Lead';
            leadCon.FieldName = 'LeadSource';
            leadCon.FieldType = '';
            leadCon.Length = '0';
            leadCon.APIName = 'LeadSource';
            leadCon.Weight = 20;
            leadConList.add(leadCon);
            // leadConL.Id = '';
            LeadScoringController.insertScoringCon(LeadScoringId.id, leadConList);

            Lead_Scoring_Condition__c LeadConListQuery = [SELECT id FROM Lead_Scoring_Condition__c WHERE Lead_Scoring_List__c = :LeadScoringId.id LIMIT 1];
            List<LeadScoringController.conditionDetailObject> leadConDetailList = new List<LeadScoringController.conditionDetailObject>();
            LeadScoringController.conditionDetailObject leadConDetail = new LeadScoringController.conditionDetailObject();
            leadConDetail.Operator = '=';
            leadConDetail.Value1 = '10';
            leadConDetail.Value2 = '';
            leadConDetail.Score = 10;
            leadConDetail.Id = 'a5R1s000000c9dHEAA';
            leadConDetail.inputrowIndex = '1';
            leadConDetailList.add(leadConDetail);
            // leadConDetailL.Id = '';
            try {    
                LeadScoringController.insertScoringConDetail(LeadScoringId.id, leadConDetailList);
            } catch (Exception ex) {
                
            }
            try {    
                LeadScoringController.insertScoringConDetail(LeadConListQuery.id, leadConDetailList);
            } catch (Exception ex) {
                
            }
            
        }
    }   
}