@isTest
public class RTL_HouseHoldDetailExtensionTest {
	
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
        RTL_Household_Pagination__c hhpagination = new RTL_Household_Pagination__c();
        hhpagination.Name = 'Record Per Page';
        hhpagination.Page_Max_Size__c = 10;
        insert hhpagination;
        
    }
        
    static testmethod void testHouseholdApproveAll(){
        
        Test.startTest();
        	Test.setCurrentPage(Page.RTL_HouseHold_Detail);
			
        	ApexPages.StandardController std = new ApexPages.StandardController(householdList[0]);
        	RTL_HouseHoldDetailExtension ext = new RTL_HouseHoldDetailExtension(std);
           	//Check Result : Verify that household record is not locked before submit for approval
        	System.assertEquals(false,ext.getIsHouseholdRecordLocked());
        	ext.submitForApproval(); 
        	//Check Result : Verify that household record is locked after submit for approval
        	System.assertEquals(true,ext.getIsHouseholdRecordLocked());
        	ext.approveAll();
        	//Check Result : Verify that household record is unlocked after approved
        	System.assertEquals(false,ext.getIsHouseholdRecordLocked());
        	
        	//Check Result : reload the page and verify that household and member status changed to Approved
        	RTL_HouseHoldDetailExtension ext2 = new RTL_HouseHoldDetailExtension(std);
        	System.assertEquals('Approved',ext2.household.RTL_Status__c);
        	System.assertEquals('Approved',ext2.memberList[0].RTL_Status__c);
        	System.assertEquals(true,ext2.getIsHouseholdEditable());
        Test.stopTest();
        
    }
    
    static testmethod void testHouseholdRejectAll(){
        
        Test.startTest();
        	Test.setCurrentPage(Page.RTL_HouseHold_Detail);
			
        	ApexPages.StandardController std = new ApexPages.StandardController(householdList[0]);
        	RTL_HouseHoldDetailExtension ext = new RTL_HouseHoldDetailExtension(std);
           	//Check Result : Verify that household record is not locked before submit for approval
        	System.assertEquals(false,ext.getIsHouseholdRecordLocked());
        	ext.submitForApproval(); 
        	//Check Result : Verify that household record is locked after submit for approval
        	System.assertEquals(true,ext.getIsHouseholdRecordLocked());
        	ext.rejectAll();
        	
        	List<RTL_Household__C> hhList = [SELECT ID,NAME FROM RTL_Household__C WHERE ID IN:householdList];
        	System.assertEquals(0,hhList.size());
        Test.stopTest();
        
    }
    
    static testmethod void testRequestDeleteHousehold(){
        
        Test.startTest();
        	Test.setCurrentPage(Page.RTL_HouseHold_Detail);
			
        	ApexPages.StandardController std = new ApexPages.StandardController(householdList[0]);
        	RTL_HouseHoldDetailExtension ext = new RTL_HouseHoldDetailExtension(std);
           	//Check Result : Verify that household record is not locked before submit for approval
        	System.assertEquals(false,ext.getIsHouseholdRecordLocked());
        	ext.submitForApproval(); 
        	//Check Result : Verify that household record is locked after submit for approval
        	System.assertEquals(true,ext.getIsHouseholdRecordLocked());
        	ext.approvalList[0].RTL_Outcome__c = 'Approved';
        	ext.updateHistory(new List<RTL_Household_History_and_Approval__c>());
        	ext.notifyRequestor();
        
        	//Check Result : reload the page and verify that household and member status changed to Approved
        	RTL_HouseHoldDetailExtension ext2 = new RTL_HouseHoldDetailExtension(std);
        	System.assertEquals('Approved',ext2.household.RTL_Status__c);
        	System.assertEquals('Approved',ext2.memberList[0].RTL_Status__c);
        	ext.requestDelete();
        	System.assertEquals(true,ext2.getIsHouseholdEditable());
        Test.stopTest();
        
    }
    
    static testmethod void testRequestDeleteMember(){
        
         Test.startTest();
        	Test.setCurrentPage(Page.RTL_HouseHold_Detail);
			RTL_TestUtility2.createHouseholdMember(true,householdList[0].id,acctList[1]);
        	ApexPages.StandardController std = new ApexPages.StandardController(householdList[0]);
        	RTL_HouseHoldDetailExtension ext = new RTL_HouseHoldDetailExtension(std);
           	//Check Result : Verify that household record is not locked before submit for approval
        	System.assertEquals(false,ext.getIsHouseholdRecordLocked());
        	
        	ext.submitForApproval(); 
        	//Check Result : Verify that household record is locked after submit for approval
        	System.assertEquals(true,ext.getIsHouseholdRecordLocked());
        	System.assertEquals(true,ext.getIsHouseholdEditable());
        	ext.approveAll();
        	ext.notifyRequestor();
        
        	//Check Result : reload the page and verify that household and member status changed to Approved
        	RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
        	RTL_HouseHoldDetailExtension ext2 = new RTL_HouseHoldDetailExtension(std);
        	System.debug('HISTORY :: '+ext2.historyList);
        	System.assertEquals('Approved',ext2.household.RTL_Status__c);
        	System.assertEquals('Approved',ext2.memberList[0].RTL_Status__c);
        	System.assertEquals('Approved',ext2.memberList[1].RTL_Status__c);
        	ext2.membId = ext2.memberList[1].id;
        	ext2.requestDeleteMember();
        	
        	RTL_HouseHoldDetailExtension ext3 = new RTL_HouseHoldDetailExtension(std);
        	ext3.submitForApproval();
        	System.debug('HISTORY :: '+ext3.historyList);
        
        	RTL_HouseHoldDetailExtension ext4 = new RTL_HouseHoldDetailExtension(std);
        	ext4.approveAll();
        	System.debug('HISTORY :: '+ext4.historyList);
        	RTL_HouseHoldDetailExtension ext5 = new RTL_HouseHoldDetailExtension(std);
        	//ext4.approveAll();
        	System.debug('HISTORY :: '+ext5.historyList);
        	System.assertEquals(1,ext5.memberList.size());
        Test.stopTest();
        
    }
    
    static testmethod void testRMDeleteFirstRequest(){
        
         Test.startTest();
        	Test.setCurrentPage(Page.RTL_HouseHold_Detail);
			
        	ApexPages.StandardController std = new ApexPages.StandardController(householdList[0]);
        	RTL_HouseHoldDetailExtension ext = new RTL_HouseHoldDetailExtension(std);
           	//Check Result : Verify that household record is not locked before submit for approval
        	System.assertEquals(false,ext.getIsHouseholdRecordLocked());
        	ext.histId = ext.historyList[0].id;
        	ext.deleteHistory();
        	List<RTL_Household__C> hhList = [SELECT ID,NAME FROM RTL_Household__C WHERE ID IN:householdList];
        	System.assertEquals(0,hhList.size());
        Test.stopTest();
        
    }
    
    static testmethod void testDeleteHistory(){
        
         Test.startTest();
        	Test.setCurrentPage(Page.RTL_HouseHold_Detail);

        	ApexPages.StandardController std = new ApexPages.StandardController(householdList[0]);
        	RTL_HouseHoldDetailExtension ext = new RTL_HouseHoldDetailExtension(std);
           	//Check Result : Verify that household record is not locked before submit for approval
        	System.assertEquals(false,ext.getIsHouseholdRecordLocked());
        	
        	ext.submitForApproval(); 
        	//Check Result : Verify that household record is locked after submit for approval
        	System.assertEquals(true,ext.getIsHouseholdRecordLocked());
        	ext.approveAll();
        	ext.notifyRequestor();
        
        	//Check Result : reload the page and verify that household and member status changed to Approved
        	RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
        	RTL_HouseholdTriggerHandler.householdBeforeUpdateTrigger = false;
        	RTL_HouseHoldDetailExtension ext2 = new RTL_HouseHoldDetailExtension(std);
        	System.debug('HISTORY :: '+ext2.historyList);
        	System.assertEquals('Approved',ext2.household.RTL_Status__c);
        	System.assertEquals('Approved',ext2.memberList[0].RTL_Status__c);
        	ext2.household.RTL_Remarks__c = 'xxx';
        	update ext2.household;
        	ext2.resetHistoryList();
        	System.assertEquals('xxx',ext2.historyList[1].RTL_New_Value__c);
        
        	RTL_HouseHoldDetailExtension ext3 = new RTL_HouseHoldDetailExtension(std);
        	ext3.histId = ext3.historyList[1].id;
        	ext3.deleteHistory();
        	ext3.resetHistoryList();
        	System.assertEquals(1, ext3.historyList.size());

        	

        Test.stopTest();
        
    }
    
     static testmethod void testApproveBeforeSubmit(){
        
        Test.startTest();
        	Test.setCurrentPage(Page.RTL_HouseHold_Detail);
			
        	ApexPages.StandardController std = new ApexPages.StandardController(householdList[0]);
        	RTL_HouseHoldDetailExtension ext = new RTL_HouseHoldDetailExtension(std);
           	//Check Result : Verify that household record is not locked before submit for approval
        	System.assertEquals(false,ext.getIsHouseholdRecordLocked());
        	ext.approveAll();
        	
        Test.stopTest();
        
    }
    
    static testmethod void testHistoryPagination(){
        RTL_TestUtility2.createHouseholdMember(true,householdList[0].id,acctList[1]);
        RTL_Household_Pagination__c hhpagination = RTL_Household_Pagination__c.getValues('Record Per Page');
        hhpagination.Page_Max_Size__c = 1;
        update hhpagination;
        Test.startTest();
        	Test.setCurrentPage(Page.RTL_HouseHold_Detail);
			
        	ApexPages.StandardController std = new ApexPages.StandardController(householdList[0]);
        	RTL_HouseHoldDetailExtension ext = new RTL_HouseHoldDetailExtension(std);
           	System.assertEquals(false,ext.getDisableNext());
        	System.assertEquals(true,ext.getDisablePrevious());
        	ext.Next();
        	System.assertEquals(false,ext.getDisablePrevious());
        	System.assertEquals(true,ext.getDisableNext());
        	ext.Previous();
        	ext.First();
        	ext.Last();
        	
        Test.stopTest();
        
    }
}