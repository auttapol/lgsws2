@isTest
public class ChangeOwnerAutoRecallBatchTest {
    public static final Datetime batchDate = datetime.now();
    // public static final Id RPSPEC_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Commercial Report Specialist Profile' LIMIT 1].Id;
    // public static final Id TH_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Team Head Profile' LIMIT 1].Id;
    // public static final Id BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;

    public static final Id SESM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;
    public static final Id SEZM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Zone Manager Profile' LIMIT 1].Id;
    public static final Id BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;

    public static Map<String, Recordtype> mapRecordtypeName {
        get{
            if(mapRecordtypeName == null){
                mapRecordtypeName = new Map<String, Recordtype> ();

                for(Recordtype rt : [SELECT id, DeveloperName FROM recordType WHERE SobjectType = 'Change_Owner_Approval_History__c']) {
                    mapRecordtypeName.put(rt.DeveloperName, rt);
                }
            }
            return mapRecordtypeName;
        }
        set;
    }

    static{
        TestUtils.createAppConfig();

        Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '001';
        insert bz;

        List<AppConfig__c> apps = new  List<AppConfig__c>();
        
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'Auto Recall Change Owner Approval flow';
        Aconfig.Value__c = '7';        
        apps.add(Aconfig);

        Aconfig = new AppConfig__c();
        Aconfig.Name = 'Auto Reassign Current Approver';
        Aconfig.Value__c = '2';        
        apps.add(Aconfig);

        Aconfig = new AppConfig__c();
        Aconfig.Name = 'Auto Recall: Change Owner Prospect';
        Aconfig.Value__c = '2';        
        apps.add(Aconfig);

        Aconfig = new AppConfig__c();
        Aconfig.Name = 'Auto Recall: Request Account Team';
        Aconfig.Value__c = '2';        
        apps.add(Aconfig);

        Aconfig = new AppConfig__c();
        Aconfig.Name = 'Auto Recall: Change Segment';
        Aconfig.Value__c = '7';        
        apps.add(Aconfig);

        insert apps;

        // UserRole ur = new UserRole();
        // ur.name = 'CSBO';
        // insert ur;

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

        User User05 = RTL_TestUtility.createUsers(1, 'testuser5', 'testuser5', 'testuser5@tmb.com.test', false).get(0);
		User05.ProfileId = SEZM_PROFILE_ID;
		User05.isActive = true;
		User05.RTL_Branch_Code__c = bz.Branch_Code__c;
		User05.Employee_ID__c = '555555';
		User05.Zone__c = 'SE-ChiangMai';
		User05.Zone_Code__c = '8888';
		User05.Region__c = 'SE1-North1';
		User05.Region_Code__c = '2222';
        User05.Segment__c = 'SE';
        // User05.UserRoleId = ur.id;
        userlst.add(User05);

        User User06 = RTL_TestUtility.createUsers(1, 'testuser6', 'testuser6', 'testuser6@tmb.com.test', false).get(0);
		User06.ProfileId = SEZM_PROFILE_ID;
		User06.isActive = false;
		User06.RTL_Branch_Code__c = bz.Branch_Code__c;
		User06.Employee_ID__c = '66666';
		User06.Zone__c = 'SE-ChiangMai';
		User06.Zone_Code__c = '8888';
		User06.Region__c = 'SE1-North1';
		User06.Region_Code__c = '2222';
        User06.Segment__c = 'SE';
        userlst.add(User06);

        insert userlst;

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
        
        User04.ManagerId = User05.Id;
        
        insert User04;

        List<Account> existingAccts = TestUtils.createAccounts(1, 'name', 'Existing Customer', false);

        for (Account acct : existingAccts) {
            acct.OwnerId = User04.Id;
            acct.Account_Type__c = 'Existing Customer';
            acct.Stamp_Owner_Region_Group__c = 'SE1-North1';
            acct.Stamp_Owner_Region_Code_Group_Code__c = '1111';
            acct.Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
            acct.Stamp_Owner_Zone_Code_Team_C__c = '9999';
            acct.Stamp_Owner_Segment__c = 'SE';
            acct.Segment_crm__c = '4';
        }
        insert existingAccts;

        List<Change_Owner_Approval_History__c> appHistorylst = new List<Change_Owner_Approval_History__c>();
        
        Change_Owner_Approval_History__c changeOwnerHistory = new Change_Owner_Approval_History__c();
        changeOwnerHistory.Account__c = existingAccts[0].Id;
        changeOwnerHistory.Approver1__c = User04.Id;
        changeOwnerHistory.Approver1_Profile__c = User04.Profile.Name;
        changeOwnerHistory.Approver2__c = User01.Id;
        changeOwnerHistory.Approver2_Profile__c = User01.Profile.Name;
        changeOwnerHistory.Change_to_owner__c = User05.Id;
        changeOwnerHistory.Current_Owner__c = existingAccts[0].OwnerId; 
        changeOwnerHistory.Change_Owner_Remark__c = 'Change_Owner_Existing_CustomerActive' ;
        changeOwnerHistory.RecordtypeId = mapRecordtypeName.get('Change_Owner_Existing_Customer').Id;

        changeOwnerHistory.Change_Owner_Approval_Status__c = 'Pending for Approval';
        changeOwnerHistory.Approval_Step_Start_Wait_Time__c = batchDate;
        changeOwnerHistory.Approval_Start_Wait_Time__c = batchDate;
        appHistorylst.add(changeOwnerHistory);

        changeOwnerHistory = new Change_Owner_Approval_History__c();
        changeOwnerHistory.Account__c = existingAccts[0].Id;
        changeOwnerHistory.Approver1__c = User04.Id;
        changeOwnerHistory.Approver1_Profile__c = User04.Profile.Name;
        changeOwnerHistory.Approver2__c = User01.Id;
        changeOwnerHistory.Approver2_Profile__c = User01.Profile.Name;
        changeOwnerHistory.Approver3__c = User06.Id;
        changeOwnerHistory.Approver3_Profile__c = User06.Profile.Name;
        changeOwnerHistory.Approver4__c = User01.Id;
        changeOwnerHistory.Approver4_Profile__c = User01.Profile.Name;
        changeOwnerHistory.Change_to_owner__c = User05.Id;
        changeOwnerHistory.Current_Owner__c = existingAccts[0].OwnerId; 
        changeOwnerHistory.Change_Owner_Remark__c = 'Change_Owner_Existing_CustomerInactive' ;
        changeOwnerHistory.RecordtypeId = mapRecordtypeName.get('Change_Owner_Existing_Customer').Id;

        changeOwnerHistory.Change_Owner_Approval_Status__c = 'Pending for Approval';
        changeOwnerHistory.Approval_Step_Start_Wait_Time__c = batchDate;
        changeOwnerHistory.Approval_Start_Wait_Time__c = batchDate;
        appHistorylst.add(changeOwnerHistory);

        changeOwnerHistory = new Change_Owner_Approval_History__c();
        changeOwnerHistory.Account__c = existingAccts[0].Id;
        changeOwnerHistory.Approver1__c = User05.Id;
        changeOwnerHistory.Approver1_Profile__c = User05.Profile.Name;
        changeOwnerHistory.Change_to_owner__c = User05.Id;
        changeOwnerHistory.Current_Owner__c = existingAccts[0].OwnerId; 
        changeOwnerHistory.Change_Owner_Remark__c = 'Change_Owner_Qualified_Prospect' ;
        changeOwnerHistory.RecordtypeId = mapRecordtypeName.get('Change_Owner_Qualified_Prospect').Id;

        changeOwnerHistory.Change_Owner_Approval_Status__c = 'Pending for Approval';
        changeOwnerHistory.Approval_Step_Start_Wait_Time__c = batchDate;
        changeOwnerHistory.Approval_Start_Wait_Time__c = batchDate;
        appHistorylst.add(changeOwnerHistory);
        
        changeOwnerHistory = new Change_Owner_Approval_History__c();
        changeOwnerHistory.Account__c = existingAccts[0].Id;
        changeOwnerHistory.Approver1__c = User05.Id;
        changeOwnerHistory.Approver1_Profile__c = User05.Profile.Name;
        changeOwnerHistory.Change_to_owner__c = User05.Id;
        changeOwnerHistory.Current_Owner__c = existingAccts[0].OwnerId; 
        changeOwnerHistory.Change_Owner_Remark__c = 'Add_Account_Team' ;
        changeOwnerHistory.RecordtypeId = mapRecordtypeName.get('Add_Account_Team').Id;

        changeOwnerHistory.Change_Owner_Approval_Status__c = 'Pending for Approval';
        changeOwnerHistory.Approval_Step_Start_Wait_Time__c = batchDate;
        changeOwnerHistory.Approval_Start_Wait_Time__c = batchDate;
        appHistorylst.add(changeOwnerHistory);

        changeOwnerHistory = new Change_Owner_Approval_History__c();
        changeOwnerHistory.Account__c = existingAccts[0].Id;
        changeOwnerHistory.Approver1__c = User05.Id;
        changeOwnerHistory.Approver1_Profile__c = User05.Profile.Name;
        changeOwnerHistory.Change_to_owner__c = User05.Id;
        changeOwnerHistory.Current_Owner__c = existingAccts[0].OwnerId; 
        changeOwnerHistory.Change_Owner_Remark__c = 'Change_Segment' ;
        changeOwnerHistory.RecordtypeId = mapRecordtypeName.get('Change_Segment').Id;

        changeOwnerHistory.Change_Owner_Approval_Status__c = 'Pending for Approval';
        changeOwnerHistory.Approval_Step_Start_Wait_Time__c = batchDate;
        changeOwnerHistory.Approval_Start_Wait_Time__c = batchDate;
        appHistorylst.add(changeOwnerHistory);

        insert appHistorylst;

        System.debug([SELECT Id, Name, DeveloperName, Type, Description, TableEnumOrId, LockType, State, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp FROM ProcessDefinition WHERE TableEnumOrId = 'Change_Owner_Approval_History__c']);
    }

    @isTest
    public static void testConstructor() {
        Change_Owner_Approval_History__c changeOwnerHistory = [SELECT Id, Change_to_owner__c, Change_to_owner__r.Segment__c, Account__c, Account__r.Owner.Segment__c , Account__r.Core_Banking_Suggested_Segment__c, Approver1__c, Approver2__c, Approver3__c, Approver4__c, Change_Owner_Remark__c, Recordtype.Name, Change_Owner_Approval_Status__c FROM Change_Owner_Approval_History__c WHERE Approver3__c = null AND Approver4__c = null LIMIT 1];
        
        User u5 = [SELECT Id, Name, Profile.Name, ManagerId FROM User WHERE Email = 'testuser5@tmb.com.test' LIMIT 1];

        Test.startTest();
        System.runAs(u5){
            try{
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(changeOwnerHistory.Id);
                Approval.ProcessResult result = Approval.process(req);
            }
            catch (Exception ex){
                System.debug(ex.getMessage());
            }
        }

        System.debug([SELECT TargetObjectId, CreatedDate FROM ProcessInstance]);

        Database.executeBatch(new ChangeOwnerAutoRecallBatch());
        Test.stopTest();
    }

    @isTest
    public static void testRecall() {
        Test.startTest();
        Database.executeBatch(new ChangeOwnerAutoRecallBatch(batchDate.month(), batchDate.day() + 20));
        Test.stopTest();
    }
    
    @isTest
    public static void testEscalate() {
        Test.startTest();
        Database.executeBatch(new ChangeOwnerAutoRecallBatch(batchDate.month(), batchDate.day() + 6));
        Test.stopTest();
    }

    @isTest
    public static void testInactiveApprover() {
        Test.startTest();
        Database.executeBatch(new ChangeOwnerAutoRecallBatch(batchDate.month(), batchDate.day() + 6));
        Test.stopTest();
    }

    @isTest static void testschedule() {
        User u4 = [SELECT Id, Name, Profile.Name, ManagerId FROM User WHERE Email = 'testuser4@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];

        Test.startTest();
        
        String jobId = System.schedule('test',  '0 0 0 15 3 ? *', new ChangeOwnerAutoRecallBatchScheduled());

        Map<Id, User> mapUser = ChangeOwnerAutoRecallBatchUtil.mapUser;
        List<String> specialProfileToIgnore = ChangeOwnerAutoRecallBatchUtil.specialProfileToIgnore;

        User u = ChangeOwnerAutoRecallBatchUtil.getNextApprover(u4);
        
        Test.stopTest();
    }

}