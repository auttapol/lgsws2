@isTest
public class RTL_HouseholdTriggerHandlerTest {
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
        rmUser.ManagerId = rmManager.id;
        update rmUser;
    }
    static testmethod void testInsertNewHousehold(){
        Test.startTest();
            
                RTL_Household__c household = new RTL_Household__c();
                household.Name = 'New Household';
                household.RTL_Benefit_Package__c = 'Wealth Package 1';
                household.RTL_RM__c = rmUser.id;
                householdList = getHousehold();
                //Check Result : before insert household ,#of household in the system must be 0
                System.assertEquals(0,householdList.size());
            
                insert household;
                householdList = getHousehold();
                //Check Result : after insert household ,#of household in the system must be 1
                System.assertEquals(1,householdList.size());
                historyList = getHistoryList();
                //Check Result : History must be inserted with New Household Label
                System.assertEquals('New Household',historyList[0].RTL_Field_Label__c);
            
            
        Test.stopTest();
        
    }
    
     static testmethod void testUpdateHousehold(){
         
            //Initial Data : Insert Household with primary member
            householdList = RTL_TestUtility2.createHouseholdwithPrimaryMember(1,true,rmUser,acctList[0]);
            //Check Result : Verify that household has status = New
            System.assertEquals('New',householdList[0].RTL_Status__c);
            historyList = getHistoryList();
            //Approved the request to insert
            historyList[0].RTL_Outcome__c = 'Approved';
            update historyList;
            householdList = getHousehold();
            //Check Result : Verify that household has status = Approved
            System.assertEquals('Approved',householdList[0].RTL_Status__c);
         
         Test.startTest();
            
                householdList = getHousehold();
                //reset static variable
                RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
                //update household benefit package
                householdList[0].RTL_Benefit_Package__c = 'Wealth Package 2';
                update householdList;
                
                historyList = getHistoryList();
                //Check Result : Verify that new history record is inserted
                System.assertEquals(2,historyList.size());
                //Check Result : Verify that new history record has new value as the rm changed
                System.assertEquals('Wealth Package 2',historyList[1].RTL_New_Value__c);
                
        Test.stopTest();
        
    }
    
    static testmethod void testUpdateSameFieldTwice(){
        
        //Initial Data : Insert Household with primary member
        householdList = RTL_TestUtility2.createHouseholdwithPrimaryMember(1,true,rmUser,acctList[0]);
        //Check Result : Verify that household has status = New
        System.assertEquals('New',householdList[0].RTL_Status__c);
        historyList = getHistoryList();
        //Approved the request to insert
        historyList[0].RTL_Outcome__c = 'Approved';
        update historyList;
        
        householdList = getHousehold();
        //Check Result : Verify that household has status = Approved
        System.assertEquals('Approved',householdList[0].RTL_Status__c);
        
        Test.startTest();
            
                householdList = getHousehold();
                //reset static variable
                RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
        		RTL_HouseholdTriggerHandler.householdBeforeUpdateTrigger = false;
                //Update household Benefit Package
                householdList[0].RTL_Benefit_Package__c = 'Wealth Package 2';
                update householdList; 
                
                historyList = getHistoryList();
                //Check Result : History is inserted with New Value as RM Chagned
                System.assertEquals('Wealth Package 2',historyList[1].RTL_New_Value__c);
                
                //reset static variable
                RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
                RTL_HouseholdTriggerHandler.householdBeforeUpdateTrigger = false;
        
                //Update houshold Benefit Package again
                householdList[0].RTL_Benefit_Package__c = 'Wealth Package 3';
                update householdList;
                historyList = getHistoryList();
                //Check Result : the existing history must be updated with the new value
                System.assertEquals('Wealth Package 3',historyList[1].RTL_New_Value__c);
            

        Test.stopTest();
    
    }
    
    static testmethod void testUpdate2FieldsApprovedOne(){
        
        Test.startTest();
            //RM Create new Household and Sent to Approve
        
            householdList = RTL_TestUtility2.createHouseholdwithPrimaryMember(1,true,rmUser,acctList[0]);
            historyList = getHistoryList();
            historyList[0].RTL_Outcome__c = 'Pending';
            historyList[0].RTL_Sent_To_Approval__c = true;
            update historyList;     
        
            //Manager Approved
        
            historyList = getHistoryList();
            historyList[0].RTL_Outcome__c = 'Approved';
            update historyList;         
            
            
            householdList = getHousehold();
            //Check Result : Household status changed to Approved
            System.assertEquals('Approved',householdList[0].RTL_Status__c);
        
        
        
            householdList = getHousehold();
            
            //Reset static variable
            RTL_HouseholdHistoryTriggerHandler.historyTrigger = false;
            
            //Update Benefit Package and Remarks of Household
            householdList[0].RTL_Benefit_Package__c = 'Wealth Package 2';
            householdList[0].RTL_Remarks__c = 'Remarksxxx';
            update householdList;
            
            householdList = getHousehold();
            //Check Result : Benefit Package and Remarks must not be changed before Manager Approved the change
            System.assertEquals('Wealth Package 1', householdList[0].RTL_Benefit_Package__c);
            System.assertEquals('Remarks', householdList[0].RTL_Remarks__c);
            
            //Sent to Approve
            historyList = getHistoryList();
            historyList[1].RTL_Sent_To_Approval__c = true;
            historyList[2].RTL_Sent_To_Approval__c = true;
            historyList[1].RTL_Outcome__c = 'Pending';
            historyList[2].RTL_Outcome__c = 'Pending';
            update historyList;
            
            historyList = getHistoryList();         
            System.assertEquals(3,historyList.size());
        

            //Manager Approved 1 request
            historyList = getHistoryList();
            historyList[1].RTL_Outcome__c = 'Approved';
            update historyList[1];
            householdList = getHousehold();
            //Check Result : Household Record still locked because there is one pending job left
            System.assertEquals(true, Approval.IsLocked(householdList[0].id));

        
        Test.stopTest();
        
    }
    
    //Method used in testclass to query all household in the system
    public static List<RTL_Household__c> getHousehold(){
        List<RTL_Household__c> householdToReturn;
        
        householdToReturn = [SELECT ID,Name,RTL_Status__c,RTL_Remarks__c,RTL_Benefit_Package__c
                             FROM RTL_Household__c ];
        
        return householdToReturn;
    }
    
    //Method used in testclass to query all household history in the system
    public static List<RTL_Household_History_and_Approval__c> getHistoryList(){
        List<RTL_Household_History_and_Approval__c> historyToReturn;
        
        historyToReturn = [SELECT ID,Name,RTL_Field_Changed__c,RTL_Field_Label__c,RTL_User_Requesting__c ,RTL_Prev_Value__c ,
                            RTL_New_Value__c ,RTL_Outcome__c,RTL_Date_Requested__c ,RTL_Date_Approved__c,RTL_Household_Member__c,
                            RTL_Household__c,RTL_Household__r.Name,RTL_Household_Member__r.Name,RTL_Sent_To_Approval__c
                            FROM RTL_Household_History_and_Approval__c];
        
        return historyToReturn;
    }
}