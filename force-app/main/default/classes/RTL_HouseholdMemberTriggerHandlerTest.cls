@isTest
public class RTL_HouseholdMemberTriggerHandlerTest {
    
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
    static testmethod void testInsertNewMember(){ 
        Test.startTest();
            RTL_TestUtility2.createHouseholdMember(true,householdList[0].id,acctList[1]);
            historyList = getHistoryList();
            historyList[0].RTL_Outcome__c = 'Approved';
            historyList[1].RTL_Outcome__C = 'Approved';
            update historyList;
            
        	memberList = getMember();
        	System.assertEquals('Approved', memberList[1].RTL_Status__c);
        Test.stopTest();
        
    }
    
    static testmethod void testUpdateMember(){
        RTL_TestUtility2.createHouseholdMember(true,householdList[0].id,acctList[1]);
        historyList = getHistoryList();
        historyList[0].RTL_Outcome__c = 'Approved';
        historyList[1].RTL_Outcome__C = 'Approved';
        update historyList;
        Test.startTest();
            RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
            memberList = getMember();
            for(RTL_Household_Member__c member : memberList){
                if(member.RTL_Primary__c == false){
                    member.RTL_Relationship__c = 'ปู่/ย่า/ตา/ยาย';
                }
            }
            
            update memberList;
        	
        	historyList = getHistoryList();
        	System.assertEquals('RTL_Relationship__c', historyList[2].RTL_Field_Changed__c);
        	System.assertEquals('ปู่/ย่า/ตา/ยาย', historyList[2].RTL_New_Value__c);
        Test.stopTest();
        
    }
    
    static testmethod void testUpdate2FieldsApprovedOne(){
        RTL_TestUtility2.createHouseholdMember(true,householdList[0].id,acctList[1]);
        historyList = getHistoryList();
        historyList[0].RTL_Outcome__c = 'Approved';
        historyList[1].RTL_Outcome__C = 'Approved';
        update historyList;
        Test.startTest();
            RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
            memberList = getMember();
            for(RTL_Household_Member__c member : memberList){
                if(member.RTL_Primary__c == false){
                    member.RTL_Relationship__c = 'ปู่/ย่า/ตา/ยาย';
                    member.RTL_Benefit__c = true;
                }
            }
            
            update memberList;
        
            historyList = getHistoryList();
            System.assertEquals('RTL_Relationship__c', historyList[2].RTL_Field_Changed__c);
        	System.assertEquals('ปู่/ย่า/ตา/ยาย', historyList[2].RTL_New_Value__c);
        	System.assertEquals('RTL_Benefit__c', historyList[3].RTL_Field_Changed__c);
        	System.assertEquals('true', historyList[3].RTL_New_Value__c);
            historyList[2].RTL_Outcome__c = 'Approved';
            historyList[2].RTL_Sent_To_Approval__c = true;
            historyList[3].RTL_Sent_To_Approval__c = true;
            update historyList;
        	
        	memberList = getMember();
        	System.assertEquals('ปู่/ย่า/ตา/ยาย', memberList[1].RTL_Relationship__c);
        	System.assertEquals(false,memberList[1].RTL_Benefit__c);
        Test.stopTest();
    }
    
    static testmethod void testAddDuplicateMember(){
        Test.startTest();
        try{
            RTL_TestUtility2.createHouseholdMember(true,householdList[0].id,acctList[0]);
            System.assert(false,'Exception thrown expected');
            //If we get to this line it means an error was not added.
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('duplicate') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }

        Test.stopTest();
        
    }
    
    static testmethod void testUpdateSameFieldTwice(){
        RTL_TestUtility2.createHouseholdMember(true,householdList[0].id,acctList[1]);
        historyList = getHistoryList();
        historyList[0].RTL_Outcome__c = 'Approved';
        historyList[1].RTL_Outcome__C = 'Approved';
        update historyList;
        Test.startTest();
            RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
            memberList = getMember();
            for(RTL_Household_Member__c member : memberList){
                if(member.RTL_Primary__c == false){
                    member.RTL_Relationship__c = 'ปู่/ย่า/ตา/ยาย';
                }
            }
            
            update memberList;
        	
        	historyList = getHistoryList();
            System.assertEquals('RTL_Relationship__c', historyList[2].RTL_Field_Changed__c);
        	System.assertEquals('ปู่/ย่า/ตา/ยาย', historyList[2].RTL_New_Value__c);
        
            RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
            for(RTL_Household_Member__c member : memberList){
                if(member.RTL_Primary__c == false){
                    member.RTL_Relationship__c = 'พี่น้อง';
                }
            }
            update memberList;
        
        	historyList = getHistoryList();
            System.assertEquals('RTL_Relationship__c', historyList[2].RTL_Field_Changed__c);
        	System.assertEquals('พี่น้อง', historyList[2].RTL_New_Value__c);
        
        Test.stopTest();
    }
    
    public static List<RTL_Household_Member__c> getMember(){
        List<RTL_Household_Member__c> memberToReturn;
        memberToReturn = [SELECT ID,Name,RTL_Household_Member_Name__c,RTL_TMB_Customer_ID_PE__c,
                                 RTL_Primary__c,RTL_Benefit__c,RTL_Relationship__c,RTL_Status__c 
                                 FROM RTL_Household_Member__c];
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