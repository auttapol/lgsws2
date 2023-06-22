@isTest
public class RTL_HouseholdHistoryEditExtensionTest {
    static User rmUser;
    static User rmManager;
    static List<Account> acctList;
    static List<RTL_Household__c> householdList;
    static List<RTL_Household_History_And_Approval__c> historyList;
   
    static{
        
        TestUtils.createAppConfig();
        rmUser = RTL_TestUtility.createRetailTestUserWithBranch(true);
        rmManager = RTL_TestUtility.createRetailTestUser(true);
        acctList = RTL_TestUtility.createAccounts(2,true);
        householdList = RTL_TestUtility2.createHouseholdwithPrimaryMember(1,true,rmUser,acctList[0]);
        rmUser.ManagerId = rmManager.id;
        update rmUser;     
    }
    testmethod static void testEditHistory(){
        RTL_TestUtility2.createHouseholdMember(true,householdList[0].id,acctList[1]);
        Test.startTest();    
        	historyList = [SELECT Id FROM RTL_Household_History_And_Approval__c];
			Test.setCurrentPage(Page.RTL_HouseHold_Detail);
        	ApexPages.StandardController std = new ApexPages.StandardController(historyList[0]);
        	RTL_HouseHoldHistoryEditExtension ext = new RTL_HouseHoldHistoryEditExtension(std);
        	ext.history.RTL_Outcome__c = 'Approved';
        	ext.save();
        	historyList = [SELECT Id,RTL_Outcome__c FROM RTL_Household_History_And_Approval__c];
        	System.assertEquals('Approved', historyList[0].RTL_Outcome__c);

		Test.stopTest();        
    }
    
    testmethod static void testApprovedMemberBeforeHousehold(){
        RTL_TestUtility2.createHouseholdMember(true,householdList[0].id,acctList[1]);
        Test.startTest();
        	historyList = [SELECT Id FROM RTL_Household_History_And_Approval__c];
			Test.setCurrentPage(Page.RTL_HouseHold_Detail);
        	ApexPages.StandardController std = new ApexPages.StandardController(historyList[1]);
        	RTL_HouseHoldHistoryEditExtension ext = new RTL_HouseHoldHistoryEditExtension(std);
        	ext.history.RTL_Outcome__c = 'Approved';
        	PageReference returnPage = ext.save();
        	System.assertEquals(true,ext.hasError);
		Test.stopTest();        
    }
    
    testmethod static void testApprovedDeleteMember(){
        RTL_Household_Member__c memb = RTL_TestUtility2.createHouseholdMember(true,householdList[0].id,acctList[1]);
        RTL_Household_History_And_Approval__c history1 = new RTL_Household_History_And_Approval__c();
        RTL_Household_History_And_Approval__c history2 = new RTL_Household_History_And_Approval__c();
        List<RTL_Household_History_And_Approval__c> historyToInsert = new List<RTL_Household_History_And_Approval__c>();
        List<RTL_Household_History_And_Approval__c> historyToUpdate = new List<RTL_Household_History_And_Approval__c>();
        history1.RTL_Household__c = householdList[0].id;
        history1.RTL_Household_Member__c = memb.id;
        history1.RTL_Field_Label__c = 'Delete Member';
        history1.RTL_New_Value__c = 'true';
        history1.RTL_Outcome__c = 'New';
        history2.RTL_Household__c = householdList[0].id;
        history2.RTL_Household_Member__c = memb.id;
        history2.RTL_Field_Label__c = 'Benefit';
        history2.RTL_New_Value__c = 'true';
        history2.RTL_Outcome__c = 'New';
        historyToInsert.add(history1);
        historyToInsert.add(history2);
        insert historyToInsert;
        Test.startTest();
        	history1.RTL_Outcome__c = 'Pending';
        	history2.RTL_Outcome__c = 'Pending';
        	historyToUpdate.add(history1);
        	historyToUpdate.add(history2);
        	update historyToUpdate;
			Test.setCurrentPage(Page.RTL_HouseHold_Detail);
        	ApexPages.StandardController std = new ApexPages.StandardController(history1);
        	RTL_HouseHoldHistoryEditExtension ext = new RTL_HouseHoldHistoryEditExtension(std);
        	ext.history.RTL_Outcome__c = 'Approved';
        	PageReference returnPage = ext.save();
        	List<RTL_Household_Member__c> memberList = [SELECT ID,Name FROM RTL_Household_Member__c WHERE ID =: memb.id];
        	System.assertEquals(0, memberList.size());
        	historyList = [SELECT ID,Name FROM RTL_Household_History_And_Approval__c WHERE RTL_Household_Member__C =:memb.id AND RTL_Field_Label__c ='Benefit'];
        	System.assertEquals(0, historyList.size());
        	
		Test.stopTest();        
    }
}