@isTest
public class RTL_WriteHistoryTest {
    
    static User rmUser;
    static User rmManager;
    static RTL_Household_Member__c member;
    static List<Account> acctList;
    static List<RTL_Household__c> householdList;
    static Map<Id,RTL_HouseHold__c> householdOldMap;
    static Map<Id,RTL_HouseHold__c> householdNewMap;
    static Map<Id,RTL_HouseHold_Member__c> householdMemberOldMap;
    static Map<Id,RTL_HouseHold_Member__c> householdMemberNewMap;
    static List<RTL_Household_History_And_Approval__c> historyList;
    static Map<String,RTL_Household_History_and_Approval__c> existingHistoryMap;
    static List<String> fieldsToTrack;
    static Map<String,String> fieldNameMap;
    
    static{
        TestUtils.createAppConfig();
        rmUser = RTL_TestUtility.createRetailTestUserWithBranch(true);
        rmManager = RTL_TestUtility.createRetailTestUser(true);
        acctList = RTL_TestUtility.createAccounts(2,true);
        householdList = RTL_TestUtility2.createHouseholdwithPrimaryMember(2,true,rmUser,acctList[0]);
        member = RTL_TestUtility2.createHouseholdMember(true,householdList[0].id,acctList[1]); 
    }
    
    static testmethod void testPositiveWriteHouseholdHistory(){
        //initiate fields to track for Household
        fieldsToTrack = new List<String>{'RTL_Remarks__c','RTL_Benefit_Package__c','RTL_To_Delete__c'};
        fieldNameMap = new Map<String,String>();
        fieldNameMap.put('RTL_Remarks__c','Remarks');
        fieldNameMap.put('RTL_Benefit_Package__c','Benefit Package');
        fieldNameMap.put('RTL_To_Delete__c','To Delete');
        
        Integer size;
        //Query All History in the System
        historyList = [SELECT ID,Name FROM RTL_Household_History_And_Approval__c];
        //Keep number of history to a variable
        size = historyList.size();
        
        
        householdOldMap = new Map<Id,RTL_Household__c>();
        for(RTL_Household__c household : householdList){
            household.RTL_Status__c = 'Approved';
            household.RTL_Number_of_New_and_Pending_Reque__c = 1;
            householdOldMap.put(household.id,household);
        }
        
        householdNewMap = householdOldMap.deepClone();
        householdNewMap.get(householdList[0].id).RTL_Benefit_Package__c = 'Placeholder 2';
        existingHistoryMap = getExistingHouseholdHistory(householdNewMap);
        
        Test.startTest();
        	RTL_WriteHistory.writeUpdateHistory(householdOldMap,householdNewMap,fieldsToTrack,fieldNameMap,existingHistoryMap);
        	//Query All History After WriteUpdateHistory
        	historyList = [SELECT ID,Name FROM RTL_Household_History_And_Approval__c];
        	//Check Result : Verify that 1 history record is inserted
        	System.assertEquals(size+1,historyList.size());
        Test.stopTest();
        
    }
    
    static testmethod void testWriteHouseholdExistingHistory(){
        //initiate fields to track for Household
        fieldsToTrack = new List<String>{'RTL_Remarks__c','RTL_Benefit_Package__c','RTL_To_Delete__c'};
        fieldNameMap = new Map<String,String>();
        fieldNameMap.put('RTL_Remarks__c','Remarks');
        fieldNameMap.put('RTL_Benefit_Package__c','Benefit Package');
        fieldNameMap.put('RTL_To_Delete__c','To Delete');
        
        Integer size;
        //Query All History in the System
        historyList = [SELECT ID,Name FROM RTL_Household_History_And_Approval__c];
        //Keep number of history to a variable
        size = historyList.size();
        
        
        householdOldMap = new Map<Id,RTL_Household__c>();
        for(RTL_Household__c household : householdList){
            household.RTL_Status__c = 'Approved';
            household.RTL_Number_of_New_and_Pending_Reque__c = 1;
            householdOldMap.put(household.id,household);
        }
        
        householdNewMap = householdOldMap.deepClone();
        householdNewMap.get(householdList[0].id).RTL_Benefit_Package__c = 'Placeholder 2';
        existingHistoryMap = getExistingHouseholdHistory(householdNewMap);
        
        Test.startTest();
        	RTL_WriteHistory.writeUpdateHistory(householdOldMap,householdNewMap,fieldsToTrack,fieldNameMap,existingHistoryMap);
        	//Query All History After WriteUpdateHistory
        	historyList = [SELECT ID,Name FROM RTL_Household_History_And_Approval__c];
        	//Check Result : Verify that 1 history record is inserted
        	System.assertEquals(size+1,historyList.size());
        	householdOldMap = householdNewMap;
        	householdNewMap = householdOldMap.deepClone();
        	householdNewMap.get(householdList[0].id).RTL_Benefit_Package__c = 'Placeholder 3';
        	existingHistoryMap = getExistingHouseholdHistory(householdOldMap);
        	System.debug('EXISTING HISTORY :::::::: '+existingHistoryMap);
        	RTL_WriteHistory.writeUpdateHistory(householdOldMap,householdNewMap,fieldsToTrack,fieldNameMap,existingHistoryMap);
        Test.stopTest();
        
    }
    
    static testmethod void testPositiveWriteHouseholdMemberHistory(){
        //initiate fields to track for Household Member
        fieldsToTrack = new List<String>{'RTL_Relationship__c','RTL_Benefit__c','RTL_To_Delete__c'};
        fieldNameMap = new Map<String,String>();
        fieldNameMap.put('RTL_Relationship__c','Relationship');
        fieldNameMap.put('RTL_Benefit__c','Benefit');
        fieldNameMap.put('RTL_To_Delete__c','To Delete');
        
        householdMemberOldMap = new Map<Id,RTL_HouseHold_Member__c> ();
        
        Integer size;
        //Query All History in the System
        historyList = [SELECT ID,Name FROM RTL_Household_History_And_Approval__c];
        //Keep number of history to a variable
        size = historyList.size();

        member.RTL_Status__c = 'Approved';
        
        householdMemberOldMap.put(member.id,member);
        
        householdMemberNewMap = householdMemberOldMap.deepClone();
        householdMemberNewMap.get(member.id).RTL_Benefit__c = true;
        existingHistoryMap = getExistingMemberHistory(householdMemberNewMap);
        
        Test.startTest();
        	RTL_WriteHistory.writeUpdateHistory(householdMemberOldMap,householdMemberNewMap,fieldsToTrack,fieldNameMap,existingHistoryMap);
        	//Query All History After WriteUpdateHistory
        	historyList = [SELECT ID,Name FROM RTL_Household_History_And_Approval__c];
        	//Check Result : Verify that 1 history record is inserted
        	System.assertEquals(size+1,historyList.size());
        Test.stopTest();
        
    }
    
    static testmethod void testUpdateMemberToDelete(){
        //initiate fields to track for Household Member
        fieldsToTrack = new List<String>{'RTL_Relationship__c','RTL_Benefit__c','RTL_To_Delete__c'};
        fieldNameMap = new Map<String,String>();
        fieldNameMap.put('RTL_Relationship__c','Relationship');
        fieldNameMap.put('RTL_Benefit__c','Benefit');
        fieldNameMap.put('RTL_To_Delete__c','To Delete');
        
        householdMemberOldMap = new Map<Id,RTL_HouseHold_Member__c> ();
        
        Integer size;
        //Query All History in the System
        historyList = [SELECT ID,Name FROM RTL_Household_History_And_Approval__c];
        //Keep number of history to a variable
        size = historyList.size();

        member.RTL_Status__c = 'Approved';
        
        householdMemberOldMap.put(member.id,member);
        
        householdMemberNewMap = householdMemberOldMap.deepClone();
        householdMemberNewMap.get(member.id).RTL_To_Delete__c = true;
        existingHistoryMap = getExistingMemberHistory(householdMemberNewMap);
        
        Test.startTest();
        	RTL_WriteHistory.writeUpdateHistory(householdMemberOldMap,householdMemberNewMap,fieldsToTrack,fieldNameMap,existingHistoryMap);
        	//Query All History After WriteUpdateHistory
        	historyList = [SELECT ID,Name FROM RTL_Household_History_And_Approval__c];
        	//Check Result : Verify that 1 history record is inserted
        	System.assertEquals(size+1,historyList.size());
        Test.stopTest();
        
    }
    
    
    
    static Map<String,RTL_Household_History_and_Approval__c> getExistingMemberHistory(map<id,SObject> newMap){
        Map<String,RTL_Household_History_and_Approval__c> historyMap = new Map<String,RTL_Household_History_and_Approval__c>();
        List<RTL_Household_History_and_Approval__c> histList = [SELECT ID,Name,RTL_Prev_Value__c,RTL_New_Value__c,
                                                              RTL_Field_Changed__c,RTL_Household__c,
                                                              RTL_Household_Member__c 
                                                       FROM RTL_Household_History_and_Approval__c 
                                                       WHERE RTL_Outcome__c = 'New' 
                                                       		AND RTL_Household_Member__c IN:newMap.values()];
        for(RTL_Household_History_and_Approval__c history : histList){
            historyMap.put(history.RTL_Household_Member__c+history.RTL_Field_Changed__c,history);
        }
        return historyMap;
        
    }
    
    static Map<String,RTL_Household_History_and_Approval__c> getExistingHouseholdHistory(map<id,SObject> newMap){
        Map<String,RTL_Household_History_and_Approval__c> historyMap = new Map<String,RTL_Household_History_and_Approval__c>();
        List<RTL_Household_History_and_Approval__c> histList = [SELECT ID,Name,RTL_Prev_Value__c,RTL_New_Value__c,
                                                              RTL_Field_Changed__c,RTL_Household__c,
                                                              RTL_Household_Member__c 
                                                       FROM RTL_Household_History_and_Approval__c 
                                                       WHERE RTL_Outcome__c = 'New' 
                                                       		AND RTL_Household__c IN:newMap.values()];
        for(RTL_Household_History_and_Approval__c history : histList){
            historyMap.put(history.RTL_Household__c+history.RTL_Field_Changed__c,history);
        }
        return historyMap;
        
    }
    
    

}