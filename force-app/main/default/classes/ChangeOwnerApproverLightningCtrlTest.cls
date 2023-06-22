@isTest
public class ChangeOwnerApproverLightningCtrlTest {
    public static final Id SYSAD_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    public static final Id SESM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;
    public static final Id SEZM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Zone Manager Profile' LIMIT 1].Id;
	public static final Id BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;
	public static PermissionSet ps;
    public static List<ObjectPermissions> op;
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
		
		Sub_Segment_Mapping__c subsegMap = new Sub_Segment_Mapping__c();
		subsegMap.Sub_Segment_Code__c = '20';
		subsegMap.Zone_Code_Team_Code__c = '8888';
		insert subsegMap;

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
	public static void testResource(){
		List<AppConfig__c> apps = new List<AppConfig__c>();

		AppConfig__c RMBDMProfiles = new AppConfig__c();
        RMBDMProfiles.Name = 'RM/BDM Profile';
        RMBDMProfiles.Value__c = 'TMB ABDM Profile';
		apps.add(RMBDMProfiles);
		
		AppConfig__c profilesToBeExistingCustApprover = new AppConfig__c();
        profilesToBeExistingCustApprover.Name = 'Custbase Approver Profile';
        profilesToBeExistingCustApprover.Value__c = 'TMB Team Head Profile';
        apps.add(profilesToBeExistingCustApprover);

		insert apps;
		
		AppConfig__c.getValues('RM/BDM Profile');
		Set<String> RMBDM = ChangeOwnerApproverLightningController.RMBDMProfiles;
		AppConfig__c.getValues('Custbase Approver Profile');
		Set<String> Approver = ChangeOwnerApproverLightningController.profilesToBeExistingCustApprover;

		try {
			User u = ChangeOwnerApproverLightningController.getSaleManageUserBySegment('zz');
		} catch (Exception e) {
			
		}
	}
    
    @isTest
    public static void ProspectCustomer() {
        User bdmRequester = [SELECT Id, Name FROM User WHERE Email = 'bdmSEreq@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User bdmSEowner1 = [SELECT Id, Name FROM User WHERE Email = 'bdmSEowner1@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
		User Sysad = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'Sysad@tmb.com.test' AND ProfileId = :SYSAD_PROFILE_ID LIMIT 1];
		
		User BITeam = RTL_TestUtility.createUsers(1, 'BI', 'Team', 'BITeam@tmb.com.test', false).get(0);
		BITeam.FirstName = 'BI';
		BITeam.LastName = 'Team';
		BITeam.ProfileId = SYSAD_PROFILE_ID;
		BITeam.isActive = true;
		BITeam.Employee_ID__c = '16345';
		BITeam.Zone__c = 'ChiangMai';
		BITeam.Zone_Code__c = '8888';
		BITeam.Region__c = 'North1';
		BITeam.Region_Code__c = '2222';
		insert BITeam;
        BITeam = [SELECT Id, Name FROM User WHERE Email = 'BITeam@tmb.com.test' AND ProfileId = :SYSAD_PROFILE_ID LIMIT 1];
		

        List<Account> existingAccts = TestUtils.createAccounts(4, 'name', 'Existing Customer', false);

        existingAccts.get(0).OwnerId = bdmSEowner1.Id;
        existingAccts.get(0).RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        existingAccts.get(0).Account_Type__c = 'Prospect';
        existingAccts.get(0).Segment_crm__c = '1';
        existingAccts.get(0).Stamp_Owner_Region_Group__c = 'SE1-North1';
        existingAccts.get(0).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(0).Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
        existingAccts.get(0).Stamp_Owner_Zone_Code_Team_C__c = '9999';
		existingAccts.get(0).Stamp_Owner_Segment__c = 'SE';
		
        existingAccts.get(1).OwnerId = Sysad.Id;
		existingAccts.get(1).RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
		
        existingAccts.get(2).OwnerId = bdmSEowner1.Id;
		existingAccts.get(2).RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();
		
        existingAccts.get(3).OwnerId = Sysad.Id;
        existingAccts.get(3).RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();
		
		insert existingAccts;

		System.runAs(bdmRequester) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmRequester.Id);
        }
		System.runAs(bdmSEowner1) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmSEowner1.Id);
        }
		System.runAs(Sysad) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=Sysad.Id);
        }

        Test.startTest();
        System.runAs(bdmRequester){
			String invalidSMErrormsg = ChangeOwnerApproverLightningController.invalidSMErrormsg;
			List<ChangeOwnerApproverLightningController.approverWraperClass> approvelst = new List<ChangeOwnerApproverLightningController.approverWraperClass>();
			ChangeOwnerApproverLightningController.approverWraperClass approver1 = new ChangeOwnerApproverLightningController.approverWraperClass();
			ChangeOwnerApproverLightningController.approverWraperClass approver2 = new ChangeOwnerApproverLightningController.approverWraperClass();
			approver1.RowNumber = '1';
			approver1.Approver = BITeam;
			approvelst.add(approver1);
			approver2.RowNumber = '2';
			approver2.Approver = Sysad;
			approvelst.add(approver2);

			String biTeamInactive = ChangeOwnerApproverLightningController.biTeamInactive;

            Account acct = ChangeOwnerApproverLightningController.getRequestPermission(existingAccts.get(0).id);
            ChangeOwnerApproverLightningController.getApprover(existingAccts.get(0).id);
			ChangeOwnerApproverLightningController.getApprover(existingAccts.get(1).id);
			ChangeOwnerApproverLightningController.getApprover(existingAccts.get(2).id);
			ChangeOwnerApproverLightningController.getApprover(existingAccts.get(3).id);

			try {
				ChangeOwnerApproverLightningController.submitRequest(existingAccts.get(0).id, 'remark', approvelst);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
			try {
				ChangeOwnerApproverLightningController.submitRequest(existingAccts.get(2).id, 'remark', approvelst);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
		}
        Test.stopTest();
	}
	
    @isTest
    public static void requestProspectErrorRequesterProfile() {
        User bdmSEowner1 = [SELECT Id, Name FROM User WHERE Email = 'bdmSEowner1@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        User salesManagementSE = [SELECT Id, Name FROM User WHERE Email = 'SMSE@tmb.com.test' AND ProfileId = :SESM_PROFILE_ID LIMIT 1];

        List<Account> existingAccts = TestUtils.createAccounts(4, 'name', 'Existing Customer', false);

        existingAccts.get(0).OwnerId = bdmSEowner1.Id;
        existingAccts.get(0).RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        existingAccts.get(0).Account_Type__c = 'Prospect';
        existingAccts.get(0).Stamp_Owner_Region_Group__c = 'SE1-North1';
        existingAccts.get(0).Stamp_Owner_Region_Code_Group_Code__c = '1111';
        existingAccts.get(0).Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
        existingAccts.get(0).Stamp_Owner_Zone_Code_Team_C__c = '9999';
		existingAccts.get(0).Stamp_Owner_Segment__c = 'SE';

		existingAccts.get(1).OwnerId = salesManagementSE.Id;
		existingAccts.get(1).RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
		
		existingAccts.get(2).OwnerId = bdmSEowner1.Id;
        existingAccts.get(2).RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();

		insert existingAccts;

		System.runAs(bdmSEowner1) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=bdmSEowner1.Id);
        }
		System.runAs(salesManagementSE) {
            insert new PermissionSetAssignment(PermissionSetId=ps.Id,AssigneeId=salesManagementSE.Id);
        }
		
        Test.startTest();
        System.runAs(salesManagementSE){
			try {
				Account acct = ChangeOwnerApproverLightningController.getRequestPermission(existingAccts.get(0).id);
			} catch (Exception e) {
				System.debug(e.getMessage());
				System.assertEquals(e.getMessage(), 'Your Profile can not request owner from Qualified Prospect Customer.');
			}

			try {
				Account acct = ChangeOwnerApproverLightningController.getRequestPermission(existingAccts.get(1).id);
			} catch (Exception e) {
				System.debug(e.getMessage());
				System.assertEquals(e.getMessage(), 'You are already an account owner.');
			}

			try {
				Account acct = ChangeOwnerApproverLightningController.getRequestPermission(existingAccts.get(2).id);
			} catch (Exception e) {
				System.debug(e.getMessage());
				System.assertEquals(e.getMessage(), 'Not support Customer record type.');
			}

			try{
				ChangeOwnerApproverLightningController.getApprover(existingAccts.get(2).id);
			}catch (Exception e) {
				System.debug(e.getMessage());
				System.assertEquals(e.getMessage(), 'Not support Customer record type.');
			}
		}
        Test.stopTest();
	}
}