@isTest
public class RTL_HouseholdRelatedListProxyCtrlTest {
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
        
        rmUser.ManagerId = rmManager.id;
        update rmUser;   
        
        RTL_HHM_RLID__c hhmrlid = new RTL_HHM_RLID__c(Name='ID',RTL_RLID__c='id');
        insert hhmrlid;
    }
	testmethod static void testCreateHouseholdMember(){
        Test.startTest();
        	RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
			Test.setCurrentPage(Page.RTL_HouseHold_Detail);
        	ApexPages.currentPage().getParameters().put('acctId',acctList[0].id);
        	member = new RTL_Household_Member__c();
        	ApexPages.StandardController std = new ApexPages.StandardController(member);
        	RTL_HouseholdRelatedListProxyCtrl ext = new RTL_HouseholdRelatedListProxyCtrl(std);
        	ext.redirectPage();
		Test.stopTest();  
    }
}