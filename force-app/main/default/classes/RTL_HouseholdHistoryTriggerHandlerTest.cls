@isTest
public class RTL_HouseholdHistoryTriggerHandlerTest {
    
    static User rmUser;
    static User rmManager;
    static List<Account> acctList;
    static List<RTL_Household__c> householdList;
    static List<RTL_Household_Member__c> memberList;
    static List<RTL_Household_History_And_Approval__c> historyList;
    
    static{
        TestUtils.createAppConfig();
        rmUser = RTL_TestUtility.createRetailTestUserWithBranch(true);
        rmManager = RTL_TestUtility.createRetailTestUser(true);
        acctList = RTL_TestUtility.createAccounts(2,true);
        householdList = RTL_TestUtility2.createHouseholdwithPrimaryMember(1,true,rmUser,acctList[0]);
        
    }
    static testmethod void testApproveInsertHousehold(){
        Test.startTest();
            historyList = getHistoryList();
            
            for(RTL_Household_History_and_Approval__c history : historyList){
                history.RTL_Outcome__c = 'Approved';
            }
            
            update historyList;
        
            //Check Result : Verify that history outcome set to Approved;
            historyList = [SELECT Id,Name,RTL_Outcome__c FROM RTL_Household_History_and_Approval__c WHERE ID IN:historyList];
            System.assertEquals('Approved', historyList[0].RTL_Outcome__c);
            householdList = [SELECT ID,Name,RTL_Status__c FROM RTL_Household__c ];
            System.assertEquals('Approved', householdList[0].RTL_Status__c);    
            
            
        Test.stopTest();
        
    }
    
    static testmethod void testApproveInsertMember(){
        RTL_Household_Member__c member = RTL_TestUtility2.createHouseholdMember(true, householdList[0].id, acctList[1]);
        Test.startTest();
            historyList = getHistoryList();
            
            for(RTL_Household_History_and_Approval__c history : historyList){
                history.RTL_Outcome__c = 'Approved';
            }
            
            update historyList;
        
            //Check Result : Verify that history outcome set to Approved;
            historyList = [SELECT Id,Name,RTL_Outcome__c FROM RTL_Household_History_and_Approval__c WHERE ID IN:historyList];
            System.assertEquals('Approved', historyList[0].RTL_Outcome__c);
            System.assertEquals('Approved', historyList[1].RTL_Outcome__c);
            
            
        Test.stopTest();
        
    }
    
    static testmethod void testRejectInsertHousehold(){
        Test.startTest();
            historyList = getHistoryList();
            
            for(RTL_Household_History_and_Approval__c history : historyList){
                history.RTL_Outcome__c = 'Rejected';
            }
            
            update historyList;
        
            //Check Result : Verify that history outcome set to Approved;
            historyList = [SELECT Id,Name,RTL_Outcome__c FROM RTL_Household_History_and_Approval__c WHERE ID IN:historyList];
            System.assertEquals(0, historyList.size());
            
            
        Test.stopTest();
        
    }
    
    static testmethod void testRMCancelInsertHousehold(){
        Test.startTest();
            historyList = getHistoryList();         
            delete historyList;
        
            //Check Result : Verify that history outcome set to Approved;
            historyList = [SELECT Id,Name,RTL_Outcome__c FROM RTL_Household_History_and_Approval__c WHERE ID IN:historyList];
            System.assertEquals(0, historyList.size());
            
            
        Test.stopTest();
        
    }
    
    static testmethod void testRejectInsertMember(){
        RTL_Household_Member__c member = RTL_TestUtility2.createHouseholdMember(true, householdList[0].id, acctList[1]);
        Test.startTest();
            historyList = getHistoryList();
            
            historyList[0].RTL_Outcome__c = 'Approved';
            historyList[1].RTL_Outcome__c = 'Rejected';
            
            update historyList;
        
            //Check Result : Verify that history outcome set to Approved;
            historyList = [SELECT Id,Name,RTL_Outcome__c FROM RTL_Household_History_and_Approval__c WHERE ID IN:historyList];
            System.debug('MEMBER HISTORY :: '+historyList[1]);
            System.assertEquals('Approved', historyList[0].RTL_Outcome__c);
            System.assertEquals('Rejected', historyList[1].RTL_Outcome__c);
            
            
        Test.stopTest();
        
    }
    
    static testmethod void testApprovedUpdateMember(){
        Test.startTest();
            RTL_Household_Member__c member = RTL_TestUtility2.createHouseholdMember(true, householdList[0].id, acctList[1]);
            historyList = getHistoryList();
            
            for(RTL_Household_History_and_Approval__c history : historyList){
                history.RTL_Outcome__c = 'Approved';
            }
            
            update historyList;
            
            RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
            member.RTL_Benefit__c = true;
            member.RTL_Relationship__c = 'ปู่/ย่า/ตา/ยาย';
            member.RTL_status__c = 'Approved';
            update member;
        
            //Check Result : Verify that history outcome set to Approved;
            historyList = [SELECT Id,Name,RTL_Outcome__c FROM RTL_Household_History_and_Approval__c WHERE ID IN:historyList];
            System.assertEquals('Approved', historyList[0].RTL_Outcome__c);
            System.assertEquals('Approved', historyList[1].RTL_Outcome__c);
        
            historyList = getHistoryList();
            System.assertEquals(4, historyList.size());
            
            for(RTL_Household_History_and_Approval__c history : historyList){
                history.RTL_Outcome__c = 'Approved';
            }
            update historyList;
            
        Test.stopTest();
        
    }
    
    
    
    static testmethod void testApproveHouseholdDeletion(){
        Test.startTest();
            historyList = getHistoryList();
            historyList[0].RTL_Outcome__c = 'Approved';
            
            update historyList;
        

            RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
            householdList = [SELECT ID,Name,RTL_Status__c FROM RTL_Household__c ];
            //Update household status to To Delete in order to delete the household
            householdList[0].RTL_To_Delete__c = true;
            update householdList;
        
            //Approved to Delete
            historyList = getHistoryList();
            historyList[1].RTL_Outcome__c = 'Approved';
            update historyList;
            
            //Check Result : Verify that house hold status is changed to Delete
            RTL_Household__c household = [SELECT ID,Name,RTL_Status__c FROM RTL_Household__c WHERE Id =:householdList[0].id ];
            System.assertEquals('Deleted', household.RTL_Status__c);
        
            
        Test.stopTest();
        
    }
    
    static testmethod void testApproveHouseholdMemberDeletion(){
        RTL_Household_Member__c member = RTL_TestUtility2.createHouseholdMember(true, householdList[0].id, acctList[1]);
        Test.startTest();
            historyList = getHistoryList();
            historyList[0].RTL_Outcome__c = 'Approved';
            historyList[1].RTL_Outcome__c = 'Approved';
            update historyList;
        
            RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
            memberList = getMember();
            //Check Result : there must be 2 member in the system.
            System.assertEquals(2, memberList.size());
            memberList[1].RTL_To_Delete__c = true;
            update memberList;
            
            historyList = getHistoryList();
            historyList[2].RTL_Outcome__c = 'Approved';
            update historyList;
            memberList = getMember();
            //Check Result : Verify that member was deleted;
            System.assertEquals(1, memberList.size());
            
            
        Test.stopTest();
        
    }
    
    static testmethod void testRejectHouseholdDeletion(){
        Test.startTest();
            historyList = getHistoryList();
            historyList[0].RTL_Outcome__c = 'Approved';
            
            update historyList;
            
            RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
            householdList = [SELECT ID,Name,RTL_Status__c FROM RTL_Household__c ];
            System.debug('HH'+householdList);
            //Update household status to To Delete in order to delete the household
            householdList[0].RTL_To_Delete__c = true;
            update householdList;
        
            //Approved to Delete
            historyList = getHistoryList();
            System.debug('HISTORY LIST '+historyList);
            historyList[1].RTL_Outcome__c = 'Rejected';
            update historyList;
            
            //Check Result : Verify that house hold status is changed to Delete
            RTL_Household__c household = [SELECT ID,Name,RTL_Status__c FROM RTL_Household__c WHERE Id =:householdList[0].id ];
            System.assertEquals('Approved', household.RTL_Status__c);
        
            
        Test.stopTest();
        
    }
    
    static testmethod void testRejectHouseholdMemberDeletion(){
        RTL_Household_Member__c member = RTL_TestUtility2.createHouseholdMember(true, householdList[0].id, acctList[1]);
        Test.startTest();
            historyList = getHistoryList();
            historyList[0].RTL_Outcome__c = 'Approved';
            historyList[1].RTL_Outcome__c = 'Approved';
            update historyList;
        
            RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
            memberList = getMember();
            //Check Result : there must be 2 member in the system.
            System.assertEquals(2, memberList.size());
            memberList[1].RTL_To_Delete__c = true;
            update memberList;
            
            historyList = getHistoryList();
            historyList[2].RTL_Outcome__c = 'Rejected';
            update historyList;
            memberList = getMember();
            //Check Result : Verify that member was deleted;
            System.assertEquals(2, memberList.size());
            
            
        Test.stopTest();
        
    }

    
    static testmethod void testCancelHouseholdMemberDeletion(){
       RTL_Household_Member__c member = RTL_TestUtility2.createHouseholdMember(true, householdList[0].id, acctList[1]);
        Test.startTest();
            historyList = getHistoryList();
            historyList[0].RTL_Outcome__c = 'Approved';
            historyList[1].RTL_Outcome__c = 'Approved';
            update historyList;
            
            RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
            member.RTL_To_Delete__c = true;
            member.RTL_Status__c = 'Approved';
            update member;
            
            historyList = getHistoryList();
            delete historyList[2];
        
            //Check Result : Verify that history outcome set to Approved;
            member = [SELECT ID,RTL_To_Delete__c FROM RTL_Household_Member__c WHERE Id=:member.id];
        	System.assertEquals(false, member.RTL_To_Delete__c);
            
        Test.stopTest();
        
    }
    
    static testmethod void testCancelInsertMember(){
       RTL_Household_Member__c member = RTL_TestUtility2.createHouseholdMember(true, householdList[0].id, acctList[1]);
        Test.startTest();
            historyList = getHistoryList();
            delete HistoryList[1];
        
            //Check Result : Verify that history outcome set to Approved;
            historyList = [SELECT Id,Name,RTL_Outcome__c FROM RTL_Household_History_and_Approval__c WHERE ID IN:historyList];
            memberList = getMember();
            System.assertEquals(1, historyList.size());
            System.assertEquals(1, memberList.size());
            
        Test.stopTest();
        
    }

    
    public static List<RTL_Household_Member__c> getMember(){
        List<RTL_Household_Member__c> memberToReturn;
        memberToReturn = [SELECT ID,Name,RTL_Household_Member_Name__c,RTL_TMB_Customer_ID_PE__c,
                                 RTL_Primary__c,RTL_Benefit__c,RTL_Relationship__c,RTL_Status__c 
                                 FROM RTL_Household_Member__c ];
        return memberToReturn;
    }
    
    public static List<RTL_Household_History_and_Approval__c> getHistoryList(){
        List<RTL_Household_History_and_Approval__c> historyToReturn;
        
        historyToReturn = [SELECT ID,Name,RTL_Field_Changed__c,RTL_Field_Label__c,RTL_User_Requesting__c ,RTL_Prev_Value__c ,
                            RTL_New_Value__c ,RTL_Outcome__c,RTL_Date_Requested__c ,RTL_Date_Approved__c,RTL_Household_Member__c,
                            RTL_Household__c,RTL_Household__r.Name,RTL_Household_Member__r.Name,RTL_Sent_To_Approval__c
                            FROM RTL_Household_History_and_Approval__c];
        
        return historyToReturn;
    }
    
    
}