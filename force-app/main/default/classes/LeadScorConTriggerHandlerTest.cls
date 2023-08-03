@isTest
public with sharing class LeadScorConTriggerHandlerTest {
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

        Lead_Scoring_Condition_Detail__c leadConDetail = new Lead_Scoring_Condition_Detail__c();
        leadConDetail.Lead_Scoring_Condition__c = LSC.id;
        leadConDetail.Score__c = 20;
        leadConDetail.Priority__c = 1;
        leadConDetail.Operation__c = '=';
        leadConDetail.Value1__c = '10';
        leadConDetail.Value2__c = '';
        insert leadConDetail;
    }
    @isTest
    static void testcamploadUser() {
        User CamploadUser = TestUtils.createUsers(1,'Campload','User','ryu@dummy.com', false).get(0);
        CamploadUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'TMB CampLoad CC Report Specialist' LIMIT 1].Id;
        insert CamploadUser;
        Lead_Scoring_Condition__c LeadScoringCon = [SELECT id,Field_Mapping__c FROM Lead_Scoring_Condition__c LIMIT 1];
        System.runAs(CamploadUser){
            LeadScoringCon.Field_Mapping__c = 'LGS_001__c';
            update LeadScoringCon;
        }
    }
}