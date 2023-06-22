@isTest
public class PendingApprovalPageControllerTest {
    public static final Id SESM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;
    public static final Id RPSPEC_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Commercial Report Specialist Profile' LIMIT 1].Id;
    public static final Id TH_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Team Head Profile' LIMIT 1].Id;
    public static final Id SEZM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Zone Manager Profile' LIMIT 1].Id;
    public static final Id BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;

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
		User06.Employee_ID__c = '666666';
		User06.Zone__c = 'SE-ChiangMai';
		User06.Zone_Code__c = '8888';
		User06.Region__c = 'SE1-North1';
		User06.Region_Code__c = '2222';
        User06.Segment__c = 'BB';
        userlst.add(User06);

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

        List<Change_Owner_Approval_History__c> changeOwnerHistorylst = new List<Change_Owner_Approval_History__c> ();

        Change_Owner_Approval_History__c changeOwnerHistory = new Change_Owner_Approval_History__c();
        changeOwnerHistory.Account__c = existingAccts[0].Id;
        changeOwnerHistory.Approver1__c = User04.Id;
        changeOwnerHistory.Approver1_Profile__c = User04.Profile.Name;
        changeOwnerHistory.Approver2__c = User01.Id;
        changeOwnerHistory.Approver2_Profile__c = User01.Profile.Name;
        changeOwnerHistory.Change_to_owner__c = User05.Id;
        changeOwnerHistory.Current_Owner__c = existingAccts[0].OwnerId; 
        changeOwnerHistory.Change_Owner_Remark__c = 'preFixremark' + ' : ' ;
        changeOwnerHistory.Change_Owner_Approval_Status__c = '3rd Approver Approved';
        changeOwnerHistorylst.add(changeOwnerHistory);

        Change_Owner_Approval_History__c changeOwnerHistory2 = new Change_Owner_Approval_History__c();
        changeOwnerHistory2.Account__c = existingAccts[0].Id;
        changeOwnerHistory2.Approver1__c = User04.Id;
        changeOwnerHistory2.Approver1_Profile__c = User04.Profile.Name;
        changeOwnerHistory2.Approver2__c = User01.Id;
        changeOwnerHistory2.Approver2_Profile__c = User01.Profile.Name;
        changeOwnerHistory2.Change_to_owner__c = User06.Id;
        changeOwnerHistory2.Current_Owner__c = existingAccts[0].OwnerId; 
        changeOwnerHistory2.Change_Owner_Remark__c = 'preFixremark' + ' : ' ;
        changeOwnerHistory2.Change_Owner_Approval_Status__c = '3rd Approver Approved';
        changeOwnerHistorylst.add(changeOwnerHistory2);

        insert changeOwnerHistorylst;
    }

    @isTest
    public static void testAfterUpdateTrigger() {
        User user = [SELECT Id, Name FROM User WHERE Email = 'testuser@tmb.com.test' AND ProfileId = :SESM_PROFILE_ID LIMIT 1];
		Test.startTest();
        System.runAs(user){
            PendingApprovalPageController ctrl = new PendingApprovalPageController();
        }
        Test.stopTest();
    }
}