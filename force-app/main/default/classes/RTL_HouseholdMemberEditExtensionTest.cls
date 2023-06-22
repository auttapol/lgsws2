@isTest
public class RTL_HouseholdMemberEditExtensionTest {
    
    static User rmUser;
    static User rmManager;
    static List<Account> acctList;
    static RTL_Household_Member__c member;
    static List<RTL_Household__c> householdList;
    static List<RTL_Household_History_And_Approval__c> historyList;
   
    static{
        
        TestUtils.createAppConfig();
        rmUser = RTL_TestUtility.createRetailTestUserWithBranch(true);
        rmManager = RTL_TestUtility.createRetailTestUser(true);
        acctList = RTL_TestUtility.createAccounts(2,true);
        householdList = RTL_TestUtility2.createHouseholdwithPrimaryMember(1,true,rmUser,acctList[0]);
        member = RTL_TestUtility2.createHouseholdMember(true, householdList[0].id, acctList[1]);
        rmUser.ManagerId = rmManager.id;
        update rmUser;     
    }
	testmethod static void testEditHouseholdMember(){
        Test.startTest();
        	historyList = [SELECT ID,Name FROM RTL_Household_History_And_Approval__c];
			historyList[0].RTL_Outcome__c = 'Approved';
        	historyList[1].RTL_Outcome__c = 'Approved';
        	update historyList;
        
        	RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
			Test.setCurrentPage(Page.RTL_HouseHold_Detail);
        	ApexPages.StandardController std = new ApexPages.StandardController(member);
        	RTL_HouseholdMemberEditExtension ext = new RTL_HouseholdMemberEditExtension(std);
        
        	Integer historyCount = historyList.size();
        	ext.member.RTL_Benefit__c = true;
        	ext.save();
        	historyList = [SELECT ID,Name FROM RTL_Household_History_And_Approval__c];
        	System.assertEquals(historyCount+1, historyList.size());
		Test.stopTest();  
    }
    
    testmethod static void testFailEditHouseholdMember(){
        Test.startTest();
			Test.setCurrentPage(Page.RTL_HouseHold_Detail);
        	ApexPages.StandardController std = new ApexPages.StandardController(member);
        	RTL_HouseholdMemberEditExtension ext = new RTL_HouseholdMemberEditExtension(std);
        	ext.member.RTL_Relationship__c = 'บิดา';
        	ext.save();
        	List<Apexpages.Message> msgs = ApexPages.getMessages();
			boolean b = false;
			for(Apexpages.Message msg:msgs){
    			if (msg.getDetail().contains('picklist')) b = true;
			}
			system.assert(b);
        	ext.cancel();
		Test.stopTest();  
    }
}