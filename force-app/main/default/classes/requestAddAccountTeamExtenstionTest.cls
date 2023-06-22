@isTest
public class requestAddAccountTeamExtenstionTest {
    private static final Id SESM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;
    private static final Id BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;
    public static PermissionSet ps;
    public static List<ObjectPermissions> op;
    static{
        TestUtils.createAppConfig();
        Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '001';
        insert bz;

        List<User> userlst = new List<User>();

        User User00 = RTL_TestUtility.createUsers(1, 'testuser0', 'testuser0', 'testuser0@tmb.com.test', false).get(0);
		User00.ProfileId = SESM_PROFILE_ID;
		User00.isActive = true;
		User00.RTL_Branch_Code__c = bz.Branch_Code__c;
		User00.Employee_ID__c = '000000';
		User00.Zone__c = 'SE-ChiangMai';
		User00.Zone_Code__c = '9999';
		User00.Region__c = 'SE1-North1';
		User00.Region_Code__c = '1111';
        userlst.add(User00);
		
        User User01 = RTL_TestUtility.createUsers(1, 'testuser', 'testuser', 'testuser@tmb.com.test', false).get(0);
		User01.ProfileId = BDM_PROFILE_ID;
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
        User04.ManagerId = User00.Id;
        userlst.add(User04);

        insert userlst;

        List<Account> existingAccts = TestUtils.createAccounts(1, 'name', '	Qualified Prospect', false);
        
        existingAccts.get(0).OwnerId = User01.Id;
        existingAccts.get(0).Account_Type__c = 'Qualified Prospect';
        existingAccts.get(0).Stamp_Owner_Region_Group__c = 'SE1-North1';
        existingAccts.get(0).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(0).Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
        existingAccts.get(0).Stamp_Owner_Zone_Code_Team_C__c = '9999';
        existingAccts.get(0).Stamp_Owner_Segment__c = 'SE';

        insert existingAccts;
        User user = [SELECT Id FROM USER WHERE Profile.Name =: 'TMB System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(user) {
        	ps = new PermissionSet(Name='ViewAllRecords',Label='ViewAllRecords');
        	insert ps;
        	op = new List<ObjectPermissions>();
        	op.add(new ObjectPermissions(ParentId=ps.Id,
        	                             SobjectType='Account',
        	                             PermissionsRead=true,
        	                             PermissionsEdit=true,
        	                             PermissionsViewAllRecords=true));          
			
        	insert op;
        }
    }


    @isTest
    public static void testRequestAccountteam() {
        User user = [SELECT Id, Name FROM User WHERE Email = 'testuser4@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        Account acct = [SELECT Id FROM Account WHERE Owner.Email = :'testuser@tmb.com.test' AND Owner.ProfileId = :BDM_PROFILE_ID  LIMIT 1];

        System.runAs(user) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=user.Id);
        }

		Test.startTest();
        System.runAs(user){
            ApexPages.StandardController sc = new ApexPages.StandardController(acct);
            PageReference pageRef = Page.requestAddAccountTeam;
            Test.setCurrentPage(pageRef);
            requestAddAccountTeamExtenstion ctrl = new requestAddAccountTeamExtenstion(sc);

            String teamRoleProfile = ctrl.teamRoleProfile;

            PageReference confirmApprover = ctrl.confirmApprover();
            PageReference cancelAction = ctrl.cancelAction();
        }

        Test.stopTest();
    }

    @isTest
    public static void testRequestAccountError() {
        User u4 = [SELECT Id, Name FROM User WHERE Email = 'testuser4@tmb.com.test' LIMIT 1];
        User u0 = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'testuser0@tmb.com.test' LIMIT 1];

        Account acct = [SELECT Id, OwnerId FROM Account WHERE Owner.Email = :'testuser@tmb.com.test' AND Owner.ProfileId = :BDM_PROFILE_ID  LIMIT 1];

        Change_Owner_Approval_History__c changeOwnerHistory = new Change_Owner_Approval_History__c();
        changeOwnerHistory.Account__c = acct.Id;
        changeOwnerHistory.Approver1__c = u0.Id;
        changeOwnerHistory.Approver1_Profile__c = u0.Profile.Name;
        changeOwnerHistory.Change_to_owner__c = u4.Id;
        changeOwnerHistory.Current_Owner__c = acct.OwnerId; 
        changeOwnerHistory.Change_Owner_Remark__c = 'preFixremark' + ' : ' ;
        changeOwnerHistory.Change_Owner_Approval_Status__c = '3rd Approver Approved';

        insert changeOwnerHistory;
        System.runAs(u4) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=u4.Id);
        }
        System.runAs(u0) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=u0.Id);
        }

		Test.startTest();
        System.runAs(u4){
            ApexPages.StandardController sc = new ApexPages.StandardController(acct);
            PageReference pageRef = Page.requestAddAccountTeam;
            Test.setCurrentPage(pageRef);
            requestAddAccountTeamExtenstion ctrl = new requestAddAccountTeamExtenstion(sc);
        }

        Test.stopTest();
    }

    @isTest
    public static void testRequestAccountDuppAccteam() {
        User u4 = [SELECT Id, Name FROM User WHERE Email = 'testuser4@tmb.com.test' LIMIT 1];
        Account acct = [SELECT Id, OwnerId FROM Account WHERE Owner.Email = :'testuser@tmb.com.test' AND Owner.ProfileId = :BDM_PROFILE_ID  LIMIT 1];

        System.debug([SELECT Count() FROM User]);

        AccountTeamMember newAccountTeam = new AccountTeamMember(
                AccountId = acct.Id,
                UserId = u4.Id,
                TeamMemberRole = 'RM / BDM',

                AccountAccessLevel = 'Read',
                OpportunityAccessLevel = 'None',
                CaseAccessLevel = 'None'
        );

        insert newAccountTeam;

        System.runAs(u4) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=u4.Id);
        }

		Test.startTest();
        System.debug([SELECT Count() FROM User]);
        System.runAs(u4){
            System.debug([SELECT Count() FROM User]);
            ApexPages.StandardController sc = new ApexPages.StandardController(acct);
            PageReference pageRef = Page.requestAddAccountTeam;
            Test.setCurrentPage(pageRef);
            requestAddAccountTeamExtenstion ctrl = new requestAddAccountTeamExtenstion(sc);
        }
        Test.stopTest();
    }
}