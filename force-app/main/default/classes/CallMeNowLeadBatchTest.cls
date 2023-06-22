@isTest
public class CallMeNowLeadBatchTest {
    static{
        TestUtils.createAppConfig();

        RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 0;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_Assigned_User_field__c = 'OwnerId';
        leadAssignmentrule.RTL_IsAssign_Campaign__c = true;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Retail Banking';
        leadAssignmentrule.RTL_Integration_Type__c = 'Cisco';

        insert leadAssignmentrule;

        RTL_TestUtility.enableWebToLeadAutoAssign(true);
        RTL_TestUtility.createCampaignAssignmentRule();
    }
    
    @isTest 
    static void CallMeNowLeadBatchTest() {
        RTL_TestUtility.createRetailMasterProducts(true);
        List<lead> leadList = RTL_TestUtility.createLeads(1,false);
        leadList.get(0).RTL_Web_Unique_ID_c__c = '989988712';
        leadList.get(0).RTL_Call_Back_Date_time__c = Datetime.now();
        leadList.get(0).RTL_TMB_Campaign_Source__c = 'Web';
        leadList.get(0).RTL_Contact_Method__c = 'Call Me Later';
        leadList.get(0).RTL_AL_Leasing_Condition__c = 'LeasingTest';
        leadList.get(0).RTL_AL_Car_Status__c = 'TestCarStatus';
        
        Test.startTest();
        insert leadList;
        Datetime nextBH = CallMeNowLeadBatch.getNextnBSDate();
        // RTL_TestUtility.createInterestedProducts(leadList, true);
        Test.stopTest();
    }
}