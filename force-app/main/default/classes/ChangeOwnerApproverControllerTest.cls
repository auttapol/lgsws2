@isTest
public class ChangeOwnerApproverControllerTest {
    public static final Id SYSAD_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    public static final Id SESM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;
    public static final Id SEZM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Zone Manager Profile' LIMIT 1].Id;
    public static final Id BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;
    static PermissionSet ps;
    static List<ObjectPermissions> op;
    //static{
    static{
        TestUtils.createAppConfig();

        Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '001';
        insert bz;

        //INSERT Sales Management System Admin
        //EMP ID is sort by Role (00000x to 99999x)
        List<User> userlst = new List<User>();

        User salesManagementSE = RTL_TestUtility.createUsers(1, 'SMSE', 'SMSE', 'SMSE@tmb.com.test', false).get(0);
		salesManagementSE.ProfileId = SESM_PROFILE_ID;
		salesManagementSE.isActive = true;
		salesManagementSE.RTL_Branch_Code__c = bz.Branch_Code__c;
		salesManagementSE.Employee_ID__c = '000001';
		salesManagementSE.Zone__c = 'SE-ChiangMai';
		salesManagementSE.Zone_Code__c = '9999';
		salesManagementSE.Region__c = 'SE1-North1';
		salesManagementSE.Region_Code__c = '1111';
        salesManagementSE.Segment__c = 'SE';
        userlst.add(salesManagementSE);

        User userSystemadmin = RTL_TestUtility.createUsers(1, 'Sysad', 'Sysad', 'Sysad@tmb.com.test', false).get(0);
		userSystemadmin.ProfileId = SYSAD_PROFILE_ID;
		userSystemadmin.isActive = true;
		userSystemadmin.RTL_Branch_Code__c = bz.Branch_Code__c;
		userSystemadmin.Employee_ID__c = '000002';
		userSystemadmin.Zone__c = 'ChiangMai';
		userSystemadmin.Zone_Code__c = '8888';
		userSystemadmin.Region__c = 'North1';
		userSystemadmin.Region_Code__c = '2222';
        userlst.add(userSystemadmin);

        insert userlst;

        //INSERT Team Head Role under Sales Management **need to insert after to get manager record ID.
        userlst = new List<User>();

        User teamhead = RTL_TestUtility.createUsers(1, 'teamhead', 'teamhead', 'teamhead@tmb.com.test', false).get(0);
		teamhead.ProfileId = SEZM_PROFILE_ID;
		teamhead.isActive = true;
		teamhead.RTL_Branch_Code__c = bz.Branch_Code__c;
		teamhead.Employee_ID__c = '111111';
		teamhead.Zone__c = 'SE-ChiangMai';
		teamhead.Zone_Code__c = '9999';
		teamhead.Region__c = 'SE1-North1';
		teamhead.Region_Code__c = '1111';
        teamhead.ManagerId = salesManagementSE.Id;
        userlst.add(teamhead);

        insert userlst;

        //INSERT Zone Manager Role under Team Head **need to insert after to get manager record ID.
        userlst = new List<User>();

        User zoneSEAct = RTL_TestUtility.createUsers(1, 'ZMSEAct', 'ZMSEAct', 'ZMSEAct@tmb.com.test', false).get(0);
		zoneSEAct.ProfileId = SEZM_PROFILE_ID;
		zoneSEAct.isActive = true;
		zoneSEAct.RTL_Branch_Code__c = bz.Branch_Code__c;
		zoneSEAct.Employee_ID__c = '222221';
		zoneSEAct.Zone__c = 'SE-ChiangMai';
		zoneSEAct.Zone_Code__c = '9999';
		zoneSEAct.Region__c = 'SE1-North1';
		zoneSEAct.Region_Code__c = '1111';
        zoneSEAct.ManagerId = teamhead.Id;
        userlst.add(zoneSEAct);

        User zoneSEInact = RTL_TestUtility.createUsers(1, 'ZMSEInact', 'ZMSEInact', 'ZMSEInact@tmb.com.test', false).get(0);
		zoneSEInact.ProfileId = SEZM_PROFILE_ID;
		zoneSEInact.isActive = false;
		zoneSEInact.RTL_Branch_Code__c = bz.Branch_Code__c;
		zoneSEInact.Employee_ID__c = '222222';
		zoneSEInact.Zone__c = 'SE-ChiangMai';
		zoneSEInact.Zone_Code__c = '9999';
		zoneSEInact.Region__c = 'SE1-North1';
		zoneSEInact.Region_Code__c = '1111';
        zoneSEInact.ManagerId = teamhead.Id;
        userlst.add(zoneSEInact);

        insert userlst;

        //INSERT RM/BDM **need to insert after to get manager record ID.
        userlst = new List<User>();
        //BDM HAVE NO MANAGER
        User bdmSEowner0 = RTL_TestUtility.createUsers(1, 'bdmSEowner0', 'bdmSEowner0', 'bdmSEowner0@tmb.com.test', false).get(0);
		bdmSEowner0.ProfileId = BDM_PROFILE_ID;
		bdmSEowner0.isActive = true;
		bdmSEowner0.RTL_Branch_Code__c = bz.Branch_Code__c;
		bdmSEowner0.Employee_ID__c = '333330';
		bdmSEowner0.Zone__c = 'SE-ChiangMai';
		bdmSEowner0.Zone_Code__c = '9999';
		bdmSEowner0.Region__c = 'SE1-North1';
		bdmSEowner0.Region_Code__c = '1111';
        bdmSEowner0.Segment__c = 'SE';
        userlst.add(bdmSEowner0);

        //Active Manager
        User bdmSEowner1 = RTL_TestUtility.createUsers(1, 'bdmSEowner1', 'bdmSEowner1', 'bdmSEowner1@tmb.com.test', false).get(0);
		bdmSEowner1.ProfileId = BDM_PROFILE_ID;
		bdmSEowner1.isActive = true;
		bdmSEowner1.RTL_Branch_Code__c = bz.Branch_Code__c;
		bdmSEowner1.Employee_ID__c = '333331';
		bdmSEowner1.Zone__c = 'SE-ChiangMai';
		bdmSEowner1.Zone_Code__c = '9999';
		bdmSEowner1.Region__c = 'SE1-North1';
		bdmSEowner1.Region_Code__c = '1111';
        bdmSEowner1.Segment__c = 'SE';
        bdmSEowner1.ManagerId = zoneSEAct.Id;
        userlst.add(bdmSEowner1);

        //Inactive Manager
        User bdmSEowner2 = RTL_TestUtility.createUsers(1, 'bdmSEowner2', 'bdmSEowner2', 'bdmSEowner2@tmb.com.test', false).get(0);
		bdmSEowner2.ProfileId = BDM_PROFILE_ID;
		bdmSEowner2.isActive = true;
		bdmSEowner2.RTL_Branch_Code__c = bz.Branch_Code__c;
		bdmSEowner2.Employee_ID__c = '333332';
		bdmSEowner2.Zone__c = 'SE-ChiangMai';
		bdmSEowner2.Zone_Code__c = '9999';
		bdmSEowner2.Region__c = 'SE1-North1';
		bdmSEowner2.Region_Code__c = '1111';
        bdmSEowner2.Segment__c = 'SE';
        bdmSEowner2.ManagerId = zoneSEInact.Id;
        userlst.add(bdmSEowner2);

        //Inactive SE BDM 
        User bdmSEowner3 = RTL_TestUtility.createUsers(1, 'bdmSEowner3', 'bdmSEowner3', 'bdmSEowner3@tmb.com.test', false).get(0);
		bdmSEowner3.ProfileId = BDM_PROFILE_ID;
		bdmSEowner3.isActive = false;
		bdmSEowner3.RTL_Branch_Code__c = bz.Branch_Code__c;
		bdmSEowner3.Employee_ID__c = '333333';
		bdmSEowner3.Zone__c = 'SE-ChiangMai';
		bdmSEowner3.Zone_Code__c = '9999';
		bdmSEowner3.Region__c = 'SE1-North1';
		bdmSEowner3.Region_Code__c = '1111';
        bdmSEowner3.Segment__c = 'SE';
        bdmSEowner3.ManagerId = zoneSEAct.Id;
        userlst.add(bdmSEowner3);

        //Segment NULL
        User bdmSEowner4 = RTL_TestUtility.createUsers(1, 'bdmSEowner4', 'bdmSEowner4', 'bdmSEowner4@tmb.com.test', false).get(0);
		bdmSEowner4.ProfileId = BDM_PROFILE_ID;
		bdmSEowner4.isActive = true;
		bdmSEowner4.RTL_Branch_Code__c = bz.Branch_Code__c;
		bdmSEowner4.Employee_ID__c = '333340';
		bdmSEowner4.Zone__c = 'SE-ChiangMai';
		bdmSEowner4.Zone_Code__c = '9999';
		bdmSEowner4.Region__c = 'SE1-North1';
		bdmSEowner4.Region_Code__c = '1111';
        bdmSEowner4.ManagerId = zoneSEInact.Id;
        userlst.add(bdmSEowner4);

        //Invalid Segment 
        User bdmSEowner5 = RTL_TestUtility.createUsers(1, 'bdmSEowner5', 'bdmSEowner5', 'bdmSEowner5@tmb.com.test', false).get(0);
		bdmSEowner5.ProfileId = BDM_PROFILE_ID;
		bdmSEowner5.isActive = true;
		bdmSEowner5.RTL_Branch_Code__c = bz.Branch_Code__c;
		bdmSEowner5.Employee_ID__c = '333341';
		bdmSEowner5.Zone__c = 'SE-ChiangMai';
		bdmSEowner5.Zone_Code__c = '9999';
		bdmSEowner5.Region__c = 'SE1-North1';
		bdmSEowner5.Region_Code__c = '1111';
        bdmSEowner5.ManagerId = zoneSEInact.Id;
        bdmSEowner5.Segment__c = 'ABC';
        userlst.add(bdmSEowner5);

        User bdmSEreq = RTL_TestUtility.createUsers(1, 'bdmSEreq', 'bdmSEreq', 'bdmSEreq@tmb.com.test', false).get(0);
		bdmSEreq.ProfileId = BDM_PROFILE_ID;
		bdmSEreq.isActive = true;
		bdmSEreq.RTL_Branch_Code__c = bz.Branch_Code__c;
		bdmSEreq.Employee_ID__c = '333334';
		bdmSEreq.Zone__c = 'SE-ChiangMai';
		bdmSEreq.Zone_Code__c = '8888';
		bdmSEreq.Region__c = 'SE1-North1';
		bdmSEreq.Region_Code__c = '2222';
        bdmSEreq.Segment__c = 'SE';
        bdmSEreq.ManagerId = zoneSEAct.Id;
        userlst.add(bdmSEreq);

        //Active Manager
        User bdmBBowner = RTL_TestUtility.createUsers(1, 'bdmBBowner', 'bdmBBowner', 'bdmBBowner@tmb.com.test', false).get(0);
		bdmBBowner.ProfileId = BDM_PROFILE_ID;
		bdmBBowner.isActive = true;
		bdmBBowner.RTL_Branch_Code__c = bz.Branch_Code__c;
		bdmBBowner.Employee_ID__c = '333335';
		bdmBBowner.Zone__c = 'BB-ChiangMai';
		bdmBBowner.Zone_Code__c = '8888';
		bdmBBowner.Region__c = 'BB-North1';
		bdmBBowner.Region_Code__c = '2222';
        bdmBBowner.Segment__c = 'BB';
        bdmBBowner.ManagerId = zoneSEAct.Id;
        userlst.add(bdmBBowner);

        //Inactive Manager
        User bdmBBowner2 = RTL_TestUtility.createUsers(1, 'bdmBBowner2', 'bdmBBowner2', 'bdmBBowner2@tmb.com.test', false).get(0);
		bdmBBowner2.ProfileId = BDM_PROFILE_ID;
		bdmBBowner2.isActive = true;
		bdmBBowner2.RTL_Branch_Code__c = bz.Branch_Code__c;
		bdmBBowner2.Employee_ID__c = '333336';
		bdmBBowner2.Zone__c = 'BB-ChiangMai';
		bdmBBowner2.Zone_Code__c = '8888';
		bdmBBowner2.Region__c = 'BB-North1';
		bdmBBowner2.Region_Code__c = '2222';
        bdmBBowner2.Segment__c = 'BB';
        bdmBBowner2.ManagerId = zoneSEInact.Id;
        userlst.add(bdmBBowner2);

        //Manage Active
        User bdmBBreq = RTL_TestUtility.createUsers(1, 'bdmBBreq', 'bdmBBreq', 'bdmBBreq@tmb.com.test', false).get(0);
		bdmBBreq.ProfileId = BDM_PROFILE_ID;
		bdmBBreq.isActive = true;
		bdmBBreq.RTL_Branch_Code__c = bz.Branch_Code__c;
		bdmBBreq.Employee_ID__c = '333337';
		bdmBBreq.Zone__c = 'BB-ChiangMai';
		bdmBBreq.Zone_Code__c = '8888';
		bdmBBreq.Region__c = 'BB-North1';
		bdmBBreq.Region_Code__c = '2222';
        bdmBBreq.Segment__c = 'BB';
        bdmBBreq.ManagerId = zoneSEAct.Id;
        userlst.add(bdmBBreq);
        
        //Manager Active
        User bdmMBreq = RTL_TestUtility.createUsers(1, 'bdmMBreq', 'bdmMBreq', 'bdmMBreq@tmb.com.test', false).get(0);
		bdmMBreq.ProfileId = BDM_PROFILE_ID;
		bdmMBreq.isActive = true;
		bdmMBreq.RTL_Branch_Code__c = bz.Branch_Code__c;
		bdmMBreq.Employee_ID__c = '333338';
		bdmMBreq.Zone__c = 'MB-ChiangMai';
		bdmMBreq.Zone_Code__c = '8888';
		bdmMBreq.Region__c = 'MB-North1';
		bdmMBreq.Region_Code__c = '2222';
        bdmMBreq.Segment__c = 'MB';
        bdmMBreq.ManagerId = zoneSEAct.Id;
        userlst.add(bdmMBreq);

        //Manager Inactive
        User bdmMBreq2 = RTL_TestUtility.createUsers(1, 'bdmMBreq2', 'bdmMBreq2', 'bdmMBreq2@tmb.com.test', false).get(0);
		bdmMBreq2.ProfileId = BDM_PROFILE_ID;
		bdmMBreq2.isActive = true;
		bdmMBreq2.RTL_Branch_Code__c = bz.Branch_Code__c;
		bdmMBreq2.Employee_ID__c = '333339';
		bdmMBreq2.Zone__c = 'MB-ChiangMai';
		bdmMBreq2.Zone_Code__c = '8888';
		bdmMBreq2.Region__c = 'MB-North1';
		bdmMBreq2.Region_Code__c = '2222';
        bdmMBreq2.Segment__c = 'MB';
        bdmMBreq2.ManagerId = zoneSEInact.Id;
        userlst.add(bdmMBreq2);

        insert userlst;

        User user = [SELECT Id FROM USER WHERE Profile.Name =: 'TMB System Administrator' AND IsActive = true LIMIT 1] ;
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
    public static void SEtoSE() {
        User bdmRequester = [SELECT Id, Name FROM User WHERE Email = 'bdmSEreq@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User bdmSEowner0 = [SELECT Id, Name FROM User WHERE Email = 'bdmSEowner0@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User bdmSEowner1 = [SELECT Id, Name FROM User WHERE Email = 'bdmSEowner1@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User bdmSEowner2 = [SELECT Id, Name FROM User WHERE Email = 'bdmSEowner2@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User bdmSEowner3 = [SELECT Id, Name FROM User WHERE Email = 'bdmSEowner4@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        List<Account> existingAccts = TestUtils.createAccounts(4, 'name', 'Existing Customer', false);
        existingAccts.get(0).OwnerId = bdmSEowner1.Id;
        existingAccts.get(0).Account_Type__c = 'Existing Customer';
        existingAccts.get(0).Stamp_Owner_Region_Group__c = 'SE1-North1';
        existingAccts.get(0).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(0).Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
        existingAccts.get(0).Stamp_Owner_Zone_Code_Team_C__c = '9999';
        existingAccts.get(0).Stamp_Owner_Segment__c = 'SE';

        existingAccts.get(1).OwnerId = bdmSEowner2.Id;
        existingAccts.get(1).Account_Type__c = 'Existing Customer';
        existingAccts.get(1).Stamp_Owner_Region_Group__c = 'SE1-North1';
        existingAccts.get(1).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(1).Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
        existingAccts.get(1).Stamp_Owner_Zone_Code_Team_C__c = '9999';
        existingAccts.get(1).Stamp_Owner_Segment__c = 'SE';
        
        existingAccts.get(2).OwnerId = bdmSEowner0.Id;
        existingAccts.get(2).Account_Type__c = 'Existing Customer';
        existingAccts.get(2).Stamp_Owner_Region_Group__c = 'SE1-North1';
        existingAccts.get(2).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(2).Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
        existingAccts.get(2).Stamp_Owner_Zone_Code_Team_C__c = '9999';
        existingAccts.get(2).Stamp_Owner_Segment__c = 'SE';
        
        existingAccts.get(3).OwnerId = bdmSEowner3.Id;
        existingAccts.get(3).Account_Type__c = 'Existing Customer';
        existingAccts.get(3).Stamp_Owner_Region_Group__c = 'SE1-North1';
        existingAccts.get(3).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(3).Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
        existingAccts.get(3).Stamp_Owner_Zone_Code_Team_C__c = '9999';
        existingAccts.get(3).Stamp_Owner_Segment__c = 'SE';
        insert existingAccts;
        
        List<Opportunity> oppList = new List<Opportunity>();
        System.runAs(bdmRequester) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmRequester.Id);
        }
        System.runAs(bdmSEowner1) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmSEowner1.Id);
        }
        System.runAs(bdmSEowner0) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmSEowner0.Id);
        }
        System.runAs(bdmSEowner2) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmSEowner2.Id);
        }
        System.runAs(bdmSEowner3) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmSEowner3.Id);
        }

        Test.startTest();
        System.runAs(bdmRequester){
            ChangeOwnerApproverController ctrl1 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(0)));
            ChangeOwnerApproverController ctrl2 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(1)));
            ChangeOwnerApproverController ctrl3 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(2)));
            ChangeOwnerApproverController ctrl4 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(3)));

            String invalidSMErrormsg = ctrl1.invalidSMErrormsg;
            PageReference confirmApprover = ctrl1.confirmApprover();
            PageReference cancelAction = ctrl1.cancelAction();
        }
        System.runAs(bdmSEowner1){
            ChangeOwnerApproverController ctrl1 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(0)));
        }
        Test.stopTest();
    }

    @isTest
    public static void errorProcessInProgress(){
        User bdmRequester = [SELECT Id, Name FROM User WHERE Email = 'bdmSEreq@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User bdmSEowner0 = [SELECT Id, Name FROM User WHERE Email = 'bdmSEowner0@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];

        List<Account> existingAccts = TestUtils.createAccounts(1, 'name', 'Existing Customer', false);
        
        existingAccts.get(0).OwnerId = bdmSEowner0.Id;
        existingAccts.get(0).Account_Type__c = 'Existing Customer';
        existingAccts.get(0).Stamp_Owner_Region_Group__c = 'SE1-North1';
        existingAccts.get(0).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(0).Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
        existingAccts.get(0).Stamp_Owner_Zone_Code_Team_C__c = '9999';
        existingAccts.get(0).Stamp_Owner_Segment__c = 'SE';
        insert existingAccts;

        Change_Owner_Approval_History__c changeOwnerHistory = new Change_Owner_Approval_History__c();
        changeOwnerHistory.Account__c = existingAccts[0].Id;
        changeOwnerHistory.Change_to_owner__c = bdmRequester.Id;
        changeOwnerHistory.Current_Owner__c = existingAccts[0].OwnerId; 
        changeOwnerHistory.Change_Owner_Remark__c = 'preFixremark' + ' : ' ;
        changeOwnerHistory.Change_Owner_Approval_Status__c = 'Pending for Approval';
        insert changeOwnerHistory;
        System.runAs(bdmRequester) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmRequester.Id);
        }
        System.runAs(bdmSEowner0) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmSEowner0.Id);
        }
        Test.startTest();
        System.runAs(bdmRequester){
            ChangeOwnerApproverController ctrl1 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(0)));
        }
        Test.stopTest();
    }
    @isTest
    public static void WBGtoWBG() {
        User bdmRequester = [SELECT Id, Name FROM User WHERE Email = 'bdmBBreq@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User bdmBBowner = [SELECT Id, Name FROM User WHERE Email = 'bdmBBowner@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User bdmBBowner2 = [SELECT Id, Name FROM User WHERE Email = 'bdmBBowner2@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        List<Account> existingAccts = TestUtils.createAccounts(2, 'name', 'Existing Customer', false);
        
        existingAccts.get(0).OwnerId = bdmBBowner.Id;
        existingAccts.get(0).Account_Type__c = 'Existing Customer';
        existingAccts.get(0).Stamp_Owner_Region_Group__c = 'BB-North1';
        existingAccts.get(0).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(0).Stamp_Owner_Zone_Team__c = 'BB-ChiangMai';
        existingAccts.get(0).Stamp_Owner_Zone_Code_Team_C__c = '9999';
        existingAccts.get(0).Stamp_Owner_Segment__c = 'BB';

        existingAccts.get(1).OwnerId = bdmBBowner2.Id;
        existingAccts.get(1).Account_Type__c = 'Existing Customer';
        existingAccts.get(1).Stamp_Owner_Region_Group__c = 'BB-North1';
        existingAccts.get(1).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(1).Stamp_Owner_Zone_Team__c = 'BB-ChiangMai';
        existingAccts.get(1).Stamp_Owner_Zone_Code_Team_C__c = '9999';
        existingAccts.get(1).Stamp_Owner_Segment__c = 'BB';
        insert existingAccts;
        System.debug(existingAccts.get(0).Id);
        System.runAs(bdmRequester) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmRequester.Id);
        }
        System.runAs(bdmBBowner) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmBBowner.Id);
        }
        System.runAs(bdmBBowner2) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmBBowner2.Id);
        }
        Test.startTest();
        System.runAs(bdmRequester){
            ChangeOwnerApproverController ctrl1 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(0)));
            ChangeOwnerApproverController ctrl2 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(1)));
        }
        Test.stopTest();
    }

    @isTest
    public static void SEtoWBG() {
        User bdmRequester = [SELECT Id, Name FROM User WHERE Email = 'bdmSEreq@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User bdmRequester2 = [SELECT Id, Name FROM User WHERE Email = 'bdmSEowner2@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User bdmBBowner = [SELECT Id, Name FROM User WHERE Email = 'bdmBBowner@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User bdmBBowner2 = [SELECT Id, Name FROM User WHERE Email = 'bdmBBowner2@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];

        List<Account> existingAccts = TestUtils.createAccounts(2, 'name', 'Existing Customer', false);
        
        existingAccts.get(0).OwnerId = bdmBBowner.Id;
        existingAccts.get(0).Account_Type__c = 'Existing Customer';
        existingAccts.get(0).Stamp_Owner_Region_Group__c = 'BB-North1';
        existingAccts.get(0).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(0).Stamp_Owner_Zone_Team__c = 'BB-ChiangMai';
        existingAccts.get(0).Stamp_Owner_Zone_Code_Team_C__c = '9999';
        existingAccts.get(0).Stamp_Owner_Segment__c = 'BB';

        existingAccts.get(1).OwnerId = bdmBBowner2.Id;
        existingAccts.get(1).Account_Type__c = 'Existing Customer';
        existingAccts.get(1).Stamp_Owner_Region_Group__c = 'BB-North1';
        existingAccts.get(1).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(1).Stamp_Owner_Zone_Team__c = 'BB-ChiangMai';
        existingAccts.get(1).Stamp_Owner_Zone_Code_Team_C__c = '9999';
        existingAccts.get(1).Stamp_Owner_Segment__c = 'BB';
        insert existingAccts;
		System.runAs(bdmRequester) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmRequester.Id);
        }
        System.runAs(bdmRequester2) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmRequester2.Id);
        }
        System.runAs(bdmBBowner) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmBBowner.Id);
        }
        System.runAs(bdmBBowner2) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmBBowner2.Id);
        }
        Test.startTest();
        System.runAs(bdmRequester){
            ChangeOwnerApproverController ctrl1 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(0)));
            ChangeOwnerApproverController ctrl2 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(1)));
        }
        System.runAs(bdmRequester2){
            ChangeOwnerApproverController ctrl3 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(0)));
            // ChangeOwnerApproverController ctrl2 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(1)));
        }
        Test.stopTest();
    }

    @isTest
    public static void WBGtoSE() {
        User bdmRequester = [SELECT Id, Name FROM User WHERE Email = 'bdmBBowner@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User bdmRequester2 = [SELECT Id, Name FROM User WHERE Email = 'bdmBBowner2@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User bdmSEowner = [SELECT Id, Name FROM User WHERE Email = 'bdmSEreq@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User bdmSEowner2 = [SELECT Id, Name FROM User WHERE Email = 'bdmSEowner2@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User bdmSEowner3 = [SELECT Id, Name FROM User WHERE Email = 'bdmSEowner4@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];

        List<Account> existingAccts = TestUtils.createAccounts(2, 'name', 'Existing Customer', false);
        
        existingAccts.get(0).OwnerId = bdmSEowner.Id;
        existingAccts.get(0).Account_Type__c = 'Existing Customer';
        existingAccts.get(0).Stamp_Owner_Region_Group__c = 'SE-North1';
        existingAccts.get(0).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(0).Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
        existingAccts.get(0).Stamp_Owner_Zone_Code_Team_C__c = '9999';
        existingAccts.get(0).Stamp_Owner_Segment__c = 'SE';

        existingAccts.get(1).OwnerId = bdmSEowner2.Id;
        existingAccts.get(1).Account_Type__c = 'Existing Customer';
        existingAccts.get(1).Stamp_Owner_Region_Group__c = 'SE-North1';
        existingAccts.get(1).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(1).Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
        existingAccts.get(1).Stamp_Owner_Zone_Code_Team_C__c = '9999';
        existingAccts.get(1).Stamp_Owner_Segment__c = 'SE';

        insert existingAccts;
		System.runAs(bdmRequester) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmRequester.Id);
        }
        System.runAs(bdmRequester2) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmRequester2.Id);
        }
        System.runAs(bdmSEowner) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmSEowner.Id);
        }
        System.runAs(bdmSEowner2) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmSEowner2.Id);
        }
        System.runAs(bdmSEowner3) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmSEowner3.Id);
        }
        Test.startTest();
        System.runAs(bdmRequester){
            ChangeOwnerApproverController ctrl1 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(0)));
            ChangeOwnerApproverController ctrl2 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(1)));
        }
        System.runAs(bdmRequester2){
            ChangeOwnerApproverController ctrl3 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(0)));
        }
        System.runAs(bdmSEowner3){
            ChangeOwnerApproverController ctrl3 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(0)));
        }
        Test.stopTest();
    }
    
    @isTest
    public static void CrossSegmentWBGtoWBGManageActive() {
        User bdmRequester = [SELECT Id, Name FROM User WHERE Email = 'bdmMBreq@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User Sysad = [SELECT Id, Name FROM User WHERE Email = 'Sysad@tmb.com.test' AND ProfileId = :SYSAD_PROFILE_ID LIMIT 1];
        User bdmBBowner = [SELECT Id, Name FROM User WHERE Email = 'bdmBBowner@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User bdmSEowner5 = [SELECT Id, Name FROM User WHERE Email = 'bdmSEowner5@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];

        List<Account> existingAccts = TestUtils.createAccounts(2, 'name', 'Existing Customer', false);
        
        existingAccts.get(0).OwnerId = bdmBBowner.Id;
        existingAccts.get(0).Account_Type__c = 'Existing Customer';
        existingAccts.get(0).Stamp_Owner_Region_Group__c = 'BB-North1';
        existingAccts.get(0).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(0).Stamp_Owner_Zone_Team__c = 'BB-ChiangMai';
        existingAccts.get(0).Stamp_Owner_Zone_Code_Team_C__c = '9999';
        existingAccts.get(0).Stamp_Owner_Segment__c = 'BB';

        existingAccts.get(1).OwnerId = bdmSEowner5.Id;
        existingAccts.get(1).Account_Type__c = 'Existing Customer';
        existingAccts.get(1).Stamp_Owner_Region_Group__c = '-North1';
        existingAccts.get(1).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(1).Stamp_Owner_Zone_Team__c = '-ChiangMai';
        existingAccts.get(1).Stamp_Owner_Zone_Code_Team_C__c = '9999';
        insert existingAccts;

        System.runAs(bdmRequester) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmRequester.Id);
        }
        System.runAs(Sysad) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=Sysad.Id);
        }
        System.runAs(bdmBBowner) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmBBowner.Id);
        }
        System.runAs(bdmSEowner5) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmSEowner5.Id);
        }
        Test.startTest();
        System.runAs(bdmRequester){
            ChangeOwnerApproverController ctrl1 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(0)));
        }
        System.runAs(Sysad){
            ChangeOwnerApproverController ctrl1 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(1)));
        }
        Test.stopTest();
    }

    @isTest
    public static void existingCustSpecialOwner() {
        User bdmRequester = [SELECT Id, Name FROM User WHERE Email = 'bdmMBreq@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User Sysad = [SELECT Id, Name FROM User WHERE Email = 'Sysad@tmb.com.test' AND ProfileId = :SYSAD_PROFILE_ID LIMIT 1];
        User SMSE = [SELECT Id, Name FROM User WHERE Email = 'SMSE@tmb.com.test' AND ProfileId = :SESM_PROFILE_ID LIMIT 1];

        List<Account> existingAccts = TestUtils.createAccounts(2, 'name', 'Existing Customer', false);
        
        existingAccts.get(0).OwnerId = Sysad.Id;
        existingAccts.get(0).Account_Type__c = 'Existing Customer';
        existingAccts.get(0).Stamp_Owner_Region_Group__c = 'BB-North1';
        existingAccts.get(0).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(0).Stamp_Owner_Zone_Team__c = 'BB-ChiangMai';
        existingAccts.get(0).Stamp_Owner_Zone_Code_Team_C__c = '9999';
        existingAccts.get(0).Stamp_Owner_Segment__c = 'BB';

        existingAccts.get(1).OwnerId = SMSE.Id;
        existingAccts.get(1).Account_Type__c = 'Existing Customer';
        existingAccts.get(1).Stamp_Owner_Region_Group__c = 'SE-North1';
        existingAccts.get(1).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(1).Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
        existingAccts.get(1).Stamp_Owner_Zone_Code_Team_C__c = '9999';
        existingAccts.get(1).Segment_crm__c = '4';

        insert existingAccts;
		System.runAs(bdmRequester) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmRequester.Id);
        }
        System.runAs(Sysad) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=Sysad.Id);
        }
        System.runAs(SMSE) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=SMSE.Id);
        }
        Test.startTest();
        System.runAs(bdmRequester){
            ChangeOwnerApproverController ctrl1 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(0)));
            ChangeOwnerApproverController ctrl2 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(1)));
        }
        Test.stopTest();
    }

    @isTest
    public static void CrossSegmentWBGtoWBGManageInactive() {
        List<AppConfig__c> Aconfiglst = new List<AppConfig__c>();
        
        AppConfig__c Aconfig1 = new AppConfig__c();
        Aconfig1.Name = 'RM/BDM Profile';
        Aconfig1.Value__c = 'TMB ABDM Profile;TMB BDM Profile;TMB RM Profile;TMB RMA Profile;TMB BB RM Profile;TMB BB ARM Profile';        
        Aconfiglst.add(Aconfig1);

        AppConfig__c Aconfig2 = new AppConfig__c();
        Aconfig2.Name = 'Custbase Approver Profile';
        Aconfig2.Value__c = 'TMB SE Zone Manager Profile;TMB SE Regional Manager Profile;TMB Team Head Profile;TMB BB Regional Manager Profile';        
        Aconfiglst.add(Aconfig2);

        insert Aconfiglst;

        User bdmRequester = [SELECT Id, Name FROM User WHERE Email = 'bdmMBreq2@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User bdmBBowner = [SELECT Id, Name FROM User WHERE Email = 'bdmBBowner2@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];

        List<Account> existingAccts = TestUtils.createAccounts(2, 'name', 'Existing Customer', false);
        
        existingAccts.get(0).OwnerId = bdmBBowner.Id;
        existingAccts.get(0).Account_Type__c = 'Existing Customer';
        existingAccts.get(0).Stamp_Owner_Region_Group__c = 'BB-North1';
        existingAccts.get(0).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(0).Stamp_Owner_Zone_Team__c = 'BB-ChiangMai';
        existingAccts.get(0).Stamp_Owner_Zone_Code_Team_C__c = '9999';
        existingAccts.get(0).Stamp_Owner_Segment__c = 'BB';
		// System.runAs(bdmRequester) {
        //     insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=bdmRequester.Id);
        // }
        insert existingAccts;

        System.runAs(bdmRequester) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmRequester.Id);
        }
        System.runAs(bdmBBowner) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmBBowner.Id);
        }
        Test.startTest();
        System.runAs(bdmRequester){
            ChangeOwnerApproverController ctrl1 = new ChangeOwnerApproverController(new ApexPages.StandardController(existingAccts.get(0)));
        }
        Test.stopTest();
    }

    @isTest
    public static void prospectFlow() {
        User bdmRequester = [SELECT Id, Name FROM User WHERE Email = 'bdmSEreq@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User Sysad = [SELECT Id, Name FROM User WHERE Email = 'Sysad@tmb.com.test' AND ProfileId = :SYSAD_PROFILE_ID LIMIT 1];
        User SMSE = [SELECT Id, Name FROM User WHERE Email = 'SMSE@tmb.com.test' AND ProfileId = :SESM_PROFILE_ID LIMIT 1];
        User bdmSEowner = [SELECT Id, Name FROM User WHERE Email = 'bdmSEowner1@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        
        List<Account> prospectAccts = RTL_TestUtility.createAccounts(2, false);
        prospectAccts.get(0).OwnerId = bdmSEowner.Id;
        prospectAccts.get(1).OwnerId = Sysad.Id;
        
        // prospectAccts.get(1).OwnerId = userSystemadmin.Id;
        insert prospectAccts;
        prospectAccts.get(0).RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        prospectAccts.get(1).RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        update prospectAccts;

        System.runAs(bdmRequester) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmRequester.Id);
        }
        System.runAs(Sysad) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=Sysad.Id);
        }
        System.runAs(SMSE) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=SMSE.Id);
        }
        System.runAs(bdmSEowner) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmSEowner.Id);
        }
        Test.startTest();
        System.runAs(bdmRequester){
            ChangeOwnerApproverController ctrl1 = new ChangeOwnerApproverController(new ApexPages.StandardController(prospectAccts.get(0)));
            ChangeOwnerApproverController ctrl2 = new ChangeOwnerApproverController(new ApexPages.StandardController(prospectAccts.get(1)));

            PageReference confirmApprover = ctrl1.confirmApprover();
        }
        System.runAs(SMSE){
            ChangeOwnerApproverController ctrl1 = new ChangeOwnerApproverController(new ApexPages.StandardController(prospectAccts.get(0)));
        }
        Test.stopTest();
    }
}