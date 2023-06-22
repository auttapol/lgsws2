@isTest
public class ChangeOwnerApprovalHisTriggerHandlerTest {
    private static final Id SESM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;
    private static final Id BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;

    private static final Map<String, Recordtype> mapRecordtypeName {
        get{
            if(mapRecordtypeName == null){
                mapRecordtypeName = new Map<String, Recordtype> ();
                for (Recordtype rt : [SELECT id, DeveloperName FROM recordType WHERE SobjectType = 'Change_Owner_Approval_History__c']) {
                    mapRecordtypeName.put(rt.DeveloperName, rt);
                }
            }
            return mapRecordtypeName;
        }
        set;
    }

    static{
        TestUtils.createAppConfig();
        // TestUtils.createAccounts(1, 'name', 'Qualified Prospect', true);

        Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '001';
        insert bz;

        List<User> userlst = new List<User>();

        User User01 = RTL_TestUtility.createUsers(1, 'testuser', 'testuser', 'testuser@tmb.com.test', false).get(0);
		User01.ProfileId = SESM_PROFILE_ID;
		User01.isActive = true;
		User01.RTL_Branch_Code__c = bz.Branch_Code__c;
		User01.Employee_ID__c = '111111';
		User01.Zone__c = 'SE-ChiangMai';
		User01.Zone_Code__c = '9999';
		User01.Region__c = 'SE1-North1';
		User01.Region_Code__c = '1111';
        User01.Segment__c = 'SE';
        userlst.add(User01);

        User User04 = RTL_TestUtility.createUsers(1, 'testuser4', 'testuser4', 'testuser4@tmb.com.test', false).get(0);
		User04.ProfileId = BDM_PROFILE_ID;
		User04.isActive = true;
		User04.RTL_Branch_Code__c = bz.Branch_Code__c;
		User04.Employee_ID__c = '444444';
		User04.Zone__c = 'SE-ChiangMai';
		User04.Zone_Code__c = '9999';
		User04.Region__c = 'SE1-North1';
		User04.Region_Code__c = '1111';
        User04.Segment__c = 'SE';
        userlst.add(User04);

        User User05 = RTL_TestUtility.createUsers(1, 'testuser5', 'testuser5', 'testuser5@tmb.com.test', false).get(0);
		User05.ProfileId = BDM_PROFILE_ID;
		User05.isActive = true;
		User05.RTL_Branch_Code__c = bz.Branch_Code__c;
		User05.Employee_ID__c = '555555';
		User05.Zone__c = 'SE-ChiangMai';
		User05.Zone_Code__c = '8888';
		User05.Region__c = 'SE1-North1';
		User05.Region_Code__c = '2222';
        User05.Segment__c = 'BB';
        userlst.add(User05);
        
        User User06 = RTL_TestUtility.createUsers(1, 'testuser6', 'testuser6', 'testuser6@tmb.com.test', false).get(0);
		User06.ProfileId = BDM_PROFILE_ID;
		User06.isActive = false;
		User06.RTL_Branch_Code__c = bz.Branch_Code__c;
		User06.Employee_ID__c = '66666';
		User06.Zone__c = 'SE-ChiangMai';
		User06.Zone_Code__c = '8888';
		User06.Region__c = 'SE1-North1';
		User06.Region_Code__c = '2222';
        User06.Segment__c = 'BB';
        userlst.add(User06);

        
        User User07 = RTL_TestUtility.createUsers(1, 'testuser7', 'testuser7', 'testuser7@tmb.com.test', false).get(0);
		User07.ProfileId = BDM_PROFILE_ID;
		User07.isActive = false;
		User07.RTL_Branch_Code__c = bz.Branch_Code__c;
		User07.Employee_ID__c = '77777';
		User07.Zone__c = 'SE-ChiangMai';
		User07.Zone_Code__c = '9999';
		User07.Region__c = 'SE1-North1';
		User07.Region_Code__c = '1111';
        User07.Segment__c = 'BB';
        userlst.add(User07);

        insert userlst;

        List<Account> existingAccts = TestUtils.createAccounts(1, 'name', 'Existing Customer', false);

        for (Account acct : existingAccts) {
            acct.OwnerId = User04.Id;
            acct.Account_Type__c = 'Existing Customer';
            acct.Stamp_Owner_Region_Group__c = 'SE1-North1';
            acct.Stamp_Owner_Region_Code_Group_Code__c = '1111';
            acct.Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
            acct.Stamp_Owner_Zone_Code_Team_C__c = '9999';
            acct.Stamp_Owner_Segment__c = 'SE';
        }
        insert existingAccts;

        list<Change_Owner_Approval_History__c> appHistory = new list<Change_Owner_Approval_History__c>();

        Change_Owner_Approval_History__c changeOwnerHistory = new Change_Owner_Approval_History__c();
        changeOwnerHistory.RecordTypeId = mapRecordtypeName.get('Change_Owner_Existing_Customer').Id;
        changeOwnerHistory.Account__c = existingAccts[0].Id;
        changeOwnerHistory.Approver1__c = User04.Id;
        changeOwnerHistory.Approver1_Profile__c = User04.Profile.Name;
        changeOwnerHistory.Approver2__c = User01.Id;
        changeOwnerHistory.Approver2_Profile__c = User01.Profile.Name;
        changeOwnerHistory.Change_to_owner__c = User05.Id;
        changeOwnerHistory.Current_Owner__c = existingAccts[0].OwnerId;
        changeOwnerHistory.Change_Owner_Remark__c = 'Change_Owner_Existing_CustomerActive' ;
        changeOwnerHistory.Change_Owner_Approval_Status__c = 'Pending for Approval';
        appHistory.add(changeOwnerHistory);
        
        changeOwnerHistory = new Change_Owner_Approval_History__c();
        changeOwnerHistory.RecordTypeId = mapRecordtypeName.get('Change_Owner_Qualified_Prospect').Id;
        changeOwnerHistory.Account__c = existingAccts[0].Id;
        changeOwnerHistory.Approver1__c = User04.Id;
        changeOwnerHistory.Approver1_Profile__c = User04.Profile.Name;
        changeOwnerHistory.Approver2__c = User01.Id;
        changeOwnerHistory.Approver2_Profile__c = User01.Profile.Name;
        changeOwnerHistory.Change_to_owner__c = User06.Id;
        changeOwnerHistory.Current_Owner__c = existingAccts[0].OwnerId;
        changeOwnerHistory.Change_Owner_Remark__c = 'Change_Owner_Existing_CustomerInactive' ;
        changeOwnerHistory.Change_Owner_Approval_Status__c = 'Pending for Approval';
        appHistory.add(changeOwnerHistory);

        changeOwnerHistory = new Change_Owner_Approval_History__c();
        changeOwnerHistory.RecordTypeId = mapRecordtypeName.get('Add_Account_Team').Id;
        changeOwnerHistory.Account__c = existingAccts[0].Id;
        changeOwnerHistory.Approver1__c = User04.Id;
        changeOwnerHistory.Approver1_Profile__c = User04.Profile.Name;
        changeOwnerHistory.Approver2__c = User01.Id;
        changeOwnerHistory.Approver2_Profile__c = User01.Profile.Name;
        changeOwnerHistory.Change_to_owner__c = User05.Id;
        changeOwnerHistory.Current_Owner__c = existingAccts[0].OwnerId;
        changeOwnerHistory.Change_Owner_Remark__c = 'Add_Account_TeamActive' ;
        changeOwnerHistory.Change_Owner_Approval_Status__c = 'Pending for Approval';
        changeOwnerHistory.Team_Role__c = 'RM / BDM';
        changeOwnerHistory.Account_Access__c = 'Read';
        changeOwnerHistory.Opportunity_Access__c = 'None';
        changeOwnerHistory.Case_Access__c = 'None';
        appHistory.add(changeOwnerHistory);

        changeOwnerHistory = new Change_Owner_Approval_History__c();
        changeOwnerHistory.RecordTypeId = mapRecordtypeName.get('Add_Account_Team').Id;
        changeOwnerHistory.Account__c = existingAccts[0].Id;
        changeOwnerHistory.Approver1__c = User04.Id;
        changeOwnerHistory.Approver1_Profile__c = User04.Profile.Name;
        changeOwnerHistory.Approver2__c = User01.Id;
        changeOwnerHistory.Approver2_Profile__c = User01.Profile.Name;
        changeOwnerHistory.Change_to_owner__c = User06.Id;
        changeOwnerHistory.Current_Owner__c = existingAccts[0].OwnerId;
        changeOwnerHistory.Change_Owner_Remark__c = 'Add_Account_TeamInactive' ;
        changeOwnerHistory.Change_Owner_Approval_Status__c = 'Pending for Approval';
        changeOwnerHistory.Team_Role__c = 'RM / BDM';
        changeOwnerHistory.Account_Access__c = 'Read';
        changeOwnerHistory.Opportunity_Access__c = 'None';
        changeOwnerHistory.Case_Access__c = 'None';
        appHistory.add(changeOwnerHistory);

        changeOwnerHistory = new Change_Owner_Approval_History__c();
        changeOwnerHistory.RecordTypeId = mapRecordtypeName.get('Change_Segment').Id;
        changeOwnerHistory.Account__c = existingAccts[0].Id;
        changeOwnerHistory.Current_Segement__c = existingAccts[0].Core_Banking_Suggested_Segment__c;
        changeOwnerHistory.To_Be_New_Segment__c = 'MB';
        changeOwnerHistory.Current_Owner__c = existingAccts[0].OwnerId;
        changeOwnerHistory.Change_to_owner__c = User07.Id;
        changeOwnerHistory.Change_Owner_Remark__c = 'Change_Segment_CustomerinActive' ;
        changeOwnerHistory.Change_Owner_Approval_Status__c = 'Pending for Approval';
        appHistory.add(changeOwnerHistory);

        changeOwnerHistory = new Change_Owner_Approval_History__c();
        changeOwnerHistory.RecordTypeId = mapRecordtypeName.get('Change_Segment').Id;
        changeOwnerHistory.Account__c = existingAccts[0].Id;
        changeOwnerHistory.Current_Segement__c = existingAccts[0].Core_Banking_Suggested_Segment__c;
        changeOwnerHistory.To_Be_New_Segment__c = 'CB';
        changeOwnerHistory.Change_to_owner__c = User05.Id;
        changeOwnerHistory.Current_Owner__c = existingAccts[0].OwnerId;
        changeOwnerHistory.Change_Owner_Remark__c = 'Change_Segment_CustomerActive' ;
        changeOwnerHistory.Change_Owner_Approval_Status__c = 'Pending for Approval';
        appHistory.add(changeOwnerHistory);

        insert appHistory;
    }

    @isTest
    public static void testAfterUpdateTriggerChange_Owner_Existing_Customer() {
        List<Change_Owner_Approval_History__c> appHistorylst = [SELECT Id, Change_Owner_Approval_Status__c FROM Change_Owner_Approval_History__c];

        for(Change_Owner_Approval_History__c appHis : appHistorylst){
            appHis.Change_Owner_Approval_Status__c = 'Final Approved';
        }

		Test.startTest();
        update appHistorylst;
        Test.stopTest();
    }
}