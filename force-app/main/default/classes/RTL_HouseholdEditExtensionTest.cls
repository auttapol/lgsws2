@isTest
public class RTL_HouseholdEditExtensionTest {
    
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
	testmethod static void testEditHousehold(){
        Test.startTest();
        	historyList = [SELECT ID,Name FROM RTL_Household_History_And_Approval__c];
			historyList[0].RTL_Outcome__c = 'Approved';
        	update historyList;
        
        	RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
			Test.setCurrentPage(Page.RTL_HouseHold_Detail);
        	ApexPages.StandardController std = new ApexPages.StandardController(householdList[0]);
        	RTL_HouseHoldEditExtension ext = new RTL_HouseHoldEditExtension(std);
        	Integer historyCount = historyList.size();
        	ext.household.RTL_Benefit_Package__c = 'Wealth Package 3';
        	ext.save();
        	
        	historyList = [SELECT ID,Name FROM RTL_Household_History_And_Approval__c];
        	System.assertEquals(historyCount+1, historyList.size());
		Test.stopTest();  
    }
    
    testmethod static void testFailEditHousehold(){
        Test.startTest();
			Test.setCurrentPage(Page.RTL_HouseHold_Detail);
        	ApexPages.StandardController std = new ApexPages.StandardController(householdList[0]);
        	RTL_HouseHoldEditExtension ext = new RTL_HouseHoldEditExtension(std);
        	ext.household.RTL_Benefit_Package__c = 'Wealth Package';
        	ext.save();
        	
        	List<Apexpages.Message> msgs = ApexPages.getMessages();
			boolean b = false;
			for(Apexpages.Message msg:msgs){
    			if (msg.getDetail().contains('picklist')) b = true;
			}
			system.assert(b);
		Test.stopTest();  
    }
}