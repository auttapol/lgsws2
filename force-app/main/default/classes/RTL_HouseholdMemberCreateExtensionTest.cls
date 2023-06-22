@isTest
public class RTL_HouseholdMemberCreateExtensionTest {
    
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
        System.debug('ACCOUNT :: '+acctList);
        rmUser.ManagerId = rmManager.id;
        update rmUser;     
    }
	testmethod static void testCreateHouseholdMember(){
        Test.startTest();
        	historyList = [SELECT ID,Name FROM RTL_Household_History_And_Approval__c];
        	RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
			Test.setCurrentPage(Page.RTL_HouseHold_Detail);
        	ApexPages.currentPage().getParameters().put('householdId',householdList[0].id);
        	ApexPages.currentPage().getParameters().put('tabId','scc-pt-01');
        	member = new RTL_Household_Member__c();
        	member.RTL_Household_Member_Name__c = acctList[1].id;
        	ApexPages.StandardController std = new ApexPages.StandardController(member);
        	RTL_HouseholdMemberCreateExtension ext = new RTL_HouseholdMemberCreateExtension(std);
        	
        	Integer historyCount = historyList.size();
        	ext.member.RTL_Benefit__c = true;
        	ext.member.RTL_Relationship__c = 'คู่สมรส';
        	ext.save();
        	
        	historyList = [SELECT ID,Name FROM RTL_Household_History_And_Approval__c];
        	System.assertEquals(historyCount+1, historyList.size());
		Test.stopTest();  
    }
    
    testmethod static void testFailCreateHouseholdMember(){
        Test.startTest();
			Test.setCurrentPage(Page.RTL_HouseHold_Detail);
        	ApexPages.currentPage().getParameters().put('householdId',householdList[0].id);
        	ApexPages.currentPage().getParameters().put('tabId','scc-pt-01');
        	member = new RTL_Household_Member__c();
        	ApexPages.StandardController std = new ApexPages.StandardController(member);
        	RTL_HouseholdMemberCreateExtension ext = new RTL_HouseholdMemberCreateExtension(std);
        	ext.member.RTL_Relationship__c = 'บิดา';
        	ext.save();
        		
        	List<Apexpages.Message> msgs = ApexPages.getMessages();
			boolean b = false;
			for(Apexpages.Message msg:msgs){
    			if (msg.getDetail().contains('List has no rows')) b = true;
			}
			system.assert(b);
        	ext.cancel();
		Test.stopTest();  
    }
    
    testmethod static void testFailCreateHouseholdNonPrimaryMemberWithoutRelationship(){
        Test.startTest();
			Test.setCurrentPage(Page.RTL_HouseHold_Detail);
        	ApexPages.currentPage().getParameters().put('householdId',householdList[0].id);
        	ApexPages.currentPage().getParameters().put('tabId','scc-pt-01');
        	member = new RTL_Household_Member__c();
        	member.RTL_Household_Member_Name__c = acctList[1].id;
        	ApexPages.StandardController std = new ApexPages.StandardController(member);
        	RTL_HouseholdMemberCreateExtension ext = new RTL_HouseholdMemberCreateExtension(std);
        	ext.save();
        		
        	List<Apexpages.Message> msgs = ApexPages.getMessages();
			boolean b = false;
			for(Apexpages.Message msg:msgs){
    			if (msg.getDetail().contains('must have a Relationship')) b = true;
			}
			system.assert(b);
        	ext.cancel();
		Test.stopTest();  
    }
}