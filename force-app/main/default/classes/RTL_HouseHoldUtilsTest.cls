@isTest
public without sharing class RTL_HouseHoldUtilsTest {
  
    private static String sObjectName {
        get {
            return 'Account';
        }
    }

    private static List<String> fields {
        get {
            return new List<String>{
                'Id', 'Name', 'OwnerId'
            };
        }
    }

    static User rmUser;
    static User rmManager;
    static List<Account> acctList;
    static List<RTL_Household__c> householdList;
    static List<RTL_Household_History_And_Approval__c> historyList;

    static {
		TestUtils.createAppConfig();

		// List<AppConfig__c> mc = new List<AppConfig__c> ();
        // mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        // insert mc;

        insert new RTL_Branch_Manager_Title__c(
            Name = 'Branch Manager',
            RTL_Value__c = 'Branch Manager'
        );

        rmUser = RTL_TestUtility.createRetailTestUserWithBranch(true);
        rmManager = RTL_TestUtility.createRetailTestUser(true);
        acctList = RTL_TestUtility.createAccounts(3,true);
        householdList = RTL_TestUtility2.createHouseholdwithPrimaryMember(1,true,rmUser,acctList[0]);
        rmUser.ManagerId = rmManager.id;
        update rmUser;
        RTL_Household_Pagination__c hhpagination = new RTL_Household_Pagination__c();
        hhpagination.Name = 'Record Per Page';
        hhpagination.Page_Max_Size__c = 10;
        insert hhpagination;

        insert new RTL_Household_Number_Store__c(
            RTL_Number__c = 1,
            RTL_Account__c = acctList.get(0).Id
        );
    }
    
    private static void runAction(RTL_HouseHold__c household, String strType) {
        RTL_HouseHoldUtils.householdAction(
            new Map<String, Object>{
                'fields' => new List<String>{
                    'Name',
                    'RTL_RM__c',
                    'RTL_Benefit_Package__c',
                    'RTL_Approver_UserName__c',
                    'RTL_Status__c',
                    'RTL_Number_of_Members__c',
                    'RTL_Remarks__c'
                },
                'sObjectName' => 'RTL_HouseHold__c',
                'filter' => 'Id = \'' + household.Id + '\''
            },
            new Map<String, Object>{
                'fields' => new List<String>{
                    'Id', 'Name', 'RTL_Household_Member_Name__c', 'RTL_TMB_Customer_ID_PE__c',
                    'RTL_Primary__c', 'RTL_Benefit__c', 'RTL_Relationship__c', 'RTL_Status__c', 'RTL_Is_Approved__c',
                    'RTL_To_Delete__c', 'RTL_Household_Member_Name__r.Name'
                },
                'sObjectName' => 'RTL_Household_Member__c',
                'filter' => 'RTL_Household__c = \'' + household.Id + '\' ORDER BY RTL_Primary__c DESC'
            },
            new Map<String, Object>{
                'fields' => new List<String>{
                    'Id', 'Name', 'RTL_Field_Changed__c', 'RTL_Field_Label__c', 'RTL_User_Requesting__c', 'RTL_Prev_Value__c',
                    'RTL_New_Value__c', 'RTL_Outcome__c', 'RTL_Date_Requested__c', 'RTL_Date_Approved__c', 'RTL_Household_Member__c',
                    'RTL_Household__c', 'RTL_Household__r.Name', 'RTL_Household_Member__r.Name', 'RTL_Sent_To_Approval__c',
                    'RTL_Section__c', 'RTL_Sent_to_Requestor__c', 'RTL_User_Requesting__r.Name', 'RTL_Approver_Link__c',
                    'CreatedById', 'RTL_Member_Lookup_Account__c', 'RTL_Member_Lookup_Account__r.Name'
                },
                'sObjectName' => 'RTL_Household_History_and_Approval__c',
                'filter' => 'RTL_Outcome__c != \'Approved\' AND RTL_Outcome__c != \'Rejected\' AND RTL_Household__c = \'' + household.Id + '\''
            },
            strType
        );
    }
    @isTest static void testMethodUtils() {
        Test.startTest();

        Account AccountObj = (Account)acctList.get(0);
        Account AccountObj_temp = (Account)acctList.get(1);
    
        RTL_HouseHoldUtils.getDescribeFieldResult(sObjectName, fields);
        RTL_HouseHoldUtils.getDescribeFieldResultAndValue(AccountObj.Id, sObjectName, fields);
        RTL_HouseHoldUtils.getQueryDatabase(fields, sObjectName, null);
        RTL_HouseHoldUtils.getRecordPerPage();
        RTL_HouseHoldUtils.initialCreateHouseHold(AccountObj.Id);

        AccountObj.RTL_RM_Name__c = '001234';
        update AccountObj;
        Map<String, Object> objInitial = (Map<String, Object>)RTL_HouseHoldUtils.initialCreateHouseHold(AccountObj.Id);

        RTL_HouseHold__c household = (RTL_HouseHold__c)objInitial.get('RTL_HouseHold__c');
        household.RTL_Benefit_Package__c = 'Wealth Package 1';
        objInitial.put('RTL_HouseHold__c', household);
        household = (RTL_HouseHold__c)((Map<String, Object>)RTL_HouseHoldUtils.saveHousehold(objInitial)).get('RTL_HouseHold__c');
        RTL_HouseHoldUtils.getReference(household.Id);
        RTL_HouseHoldUtils.getIsHouseholdRecordLocked(household.Id);
        RTL_HouseHoldUtils.notifyRequestor(household.Id);
        RTL_HouseHoldUtils.requestDeleteMember(((List<RTL_Household_Member__c>)RTL_HouseHoldUtils.getQueryDatabase(new List<String>{'Id', 'Name'}, 'RTL_Household_Member__c', null)).get(0).Id);
        Id hhHistroryApprovalId = ((List<RTL_Household_History_and_Approval__c>)RTL_HouseHoldUtils.getQueryDatabase(new List<String>{'Id', 'Name'}, 'RTL_Household_History_and_Approval__c', null)).get(0).Id;
        RTL_HouseHoldUtils.deleteHouseholdHistoryApproval(hhHistroryApprovalId);
        // Test failed
        try {
            RTL_HouseHoldUtils.deleteHouseholdHistoryApproval(hhHistroryApprovalId);
        } catch (Exception e) {}

        Test.stopTest();
    }

    @isTest static void testSubmitForApproval() {
        Test.startTest();
        
        Account AccountObj = (Account)acctList.get(0);
        Account AccountObj2 = (Account)acctList.get(1);
        Account AccountObj3 = (Account)acctList.get(2);

        Map<String, Object> objInitial = (Map<String, Object>)RTL_HouseHoldUtils.initialCreateHouseHold(AccountObj.Id);
        RTL_HouseHold__c household = (RTL_HouseHold__c)objInitial.get('RTL_HouseHold__c');
        household.RTL_Benefit_Package__c = 'Wealth Package 1';
        household.RTL_RM__c = rmUser.Id;
        objInitial.put('RTL_HouseHold__c', household);

        System.runAs(rmUser){
        	insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=rmUser.Id);
        }
        System.runAs(rmUser){
            household = (RTL_HouseHold__c)((Map<String, Object>)RTL_HouseHoldUtils.saveHousehold(objInitial)).get('RTL_HouseHold__c');
            
            RTL_Household_Member__c member = new RTL_Household_Member__c(
                RTL_Household__c = household.Id,
                RTL_Household_Member_Name__c = AccountObj2.Id,
                RTL_Relationship__c = 'ญาติ'
            );
            insert member;
            RTL_Household_History_and_Approval__c hhHistoryApproval1 = new RTL_Household_History_and_Approval__c(
                RTL_Household__c = household.Id,
                RTL_Outcome__c = 'New',
                RTL_Household_Member__c = member.Id,
                RTL_Member_Lookup_Account__c = AccountObj2.Id,
                RTL_Date_Requested__c = Date.today(),
                RTL_Field_Label__c = 'Delete Member',
                RTL_Field_Changed__c = 'RTL_To_Delete__c',
                RTL_New_Value__c = 'true'
            );
            RTL_Household_History_and_Approval__c hhHistoryApproval2 = new RTL_Household_History_and_Approval__c(
                RTL_Household__c = household.Id,
                RTL_Outcome__c = 'New',
                RTL_Household_Member__c = member.Id,
                RTL_Member_Lookup_Account__c = AccountObj3.Id,
                RTL_Date_Requested__c = Date.today(),
                RTL_Field_Changed__c ='New Member'
            );

            insert new List<RTL_Household_History_and_Approval__c>{
                hhHistoryApproval1, hhHistoryApproval2, 
                new RTL_Household_History_and_Approval__c(
                    RTL_Household__c = household.Id,
                    RTL_Outcome__c = 'New',
                    RTL_Household_Member__c = member.Id,
                    RTL_Member_Lookup_Account__c = AccountObj2.Id,
                    RTL_Date_Requested__c = Date.today(),
                    RTL_Field_Changed__c ='New Member'
                ),
                new RTL_Household_History_and_Approval__c(
                    RTL_Household__c = household.Id,
                    RTL_Outcome__c = 'New',
                    RTL_Household_Member__c = member.Id,
                    RTL_Member_Lookup_Account__c = AccountObj3.Id,
                    RTL_Date_Requested__c = Date.today(),
                    RTL_Field_Changed__c ='New Member'
                )
            };

            try {
                RTL_HouseHoldUtils.saveHouseholdhistory('New', 'Pending', hhHistoryApproval2.Id);
            } catch (Exception e) {}
            try {
                RTL_HouseHoldUtils.saveHouseholdhistory('Pending', 'Approved', hhHistoryApproval1.Id);
            } catch (Exception e) {}

            try {
                runAction(household, 'SubmitForApproval');
            } catch (Exception e) {}
            try {
                runAction(household, 'approveAll');
            } catch (Exception e) {}

        }
        Test.stopTest();
    }
    @isTest static void testRejectHousehold() {
        Test.startTest();
        
        Account AccountObj = (Account)acctList.get(0);
        Account AccountObj2 = (Account)acctList.get(1);

        Map<String, Object> objInitial = (Map<String, Object>)RTL_HouseHoldUtils.initialCreateHouseHold(AccountObj.Id);
        RTL_HouseHold__c household = (RTL_HouseHold__c)objInitial.get('RTL_HouseHold__c');
        household.RTL_Benefit_Package__c = 'Wealth Package 1';
        household.RTL_RM__c = rmUser.Id;
        objInitial.put('RTL_HouseHold__c', household);
		
        System.runAs(rmUser){
        	insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=rmUser.Id);
        }
        System.runAs(rmUser){
            household = (RTL_HouseHold__c)((Map<String, Object>)RTL_HouseHoldUtils.saveHousehold(objInitial)).get('RTL_HouseHold__c');
            
            RTL_Household_Member__c member = new RTL_Household_Member__c(
                RTL_Household__c = household.Id,
                RTL_Household_Member_Name__c = AccountObj2.Id,
                RTL_Relationship__c = 'ญาติ'
            );
            insert member;

            // insert new RTL_Household_History_and_Approval__c(
            //     RTL_Household__c = household.Id,
            //     RTL_Outcome__c = 'New',
            //     RTL_Household_Member__c = member.Id,
            //     RTL_Member_Lookup_Account__c = AccountObj2.Id,
            //     RTL_Date_Requested__c = Date.today(),
            //     RTL_Field_Label__c = 'Delete Member',
            //     RTL_New_Value__c = 'true'
            // );
            RTL_Household_History_and_Approval__c hist = new RTL_Household_History_and_Approval__c(
                RTL_Household__c = household.Id,
                RTL_Outcome__c = 'New',
                RTL_Household_Member__c = member.Id,
                RTL_Member_Lookup_Account__c = AccountObj2.Id,
                RTL_Date_Requested__c = Date.today(),
                RTL_Field_Changed__c ='New Member'
            );
            insert hist;
            hist.RTL_Outcome__c = 'Pending';
            update hist;
            
            try {
                System.debug(JSON.serializePretty(hist));
                RTL_HouseHoldUtils.requestHouseholdDelete(household, new List<RTL_Household_Member__c>{member}, new Map<String, Object>{
                    'fields' => new List<String>{
                        'Id', 'Name', 'RTL_Field_Changed__c', 'RTL_Field_Label__c', 'RTL_User_Requesting__c', 'RTL_Prev_Value__c',
                        'RTL_New_Value__c', 'RTL_Outcome__c', 'RTL_Date_Requested__c', 'RTL_Date_Approved__c', 'RTL_Household_Member__c',
                        'RTL_Household__c', 'RTL_Household__r.Name', 'RTL_Household_Member__r.Name', 'RTL_Sent_To_Approval__c',
                        'RTL_Section__c', 'RTL_Sent_to_Requestor__c', 'RTL_User_Requesting__r.Name', 'RTL_Approver_Link__c',
                        'CreatedById', 'RTL_Member_Lookup_Account__c', 'RTL_Member_Lookup_Account__r.Name'
                    },
                    'sObjectName' => 'RTL_Household_History_and_Approval__c',
                    'filter' => ''
                });
            } catch (Exception e) {}
            try {
                runAction(household, 'RequestDelete');
            } catch (Exception e) {}
            try {
                runAction(household, 'rejectAll');
            } catch (Exception e) {}
            try {
                runAction(household, '');
            } catch (Exception e) {}

        }
        Test.stopTest();
    }
}