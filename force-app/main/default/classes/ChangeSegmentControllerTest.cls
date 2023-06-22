@isTest
public class ChangeSegmentControllerTest {
    public static final Id BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;
    public static final Id SYSAD_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    public static final Id SESM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;

    static{
        TestUtils.createAppConfig();
        Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '001';
        insert bz;
        List<User> userlst = new List<User>();

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

        User User01 = RTL_TestUtility.createUsers(1, 'testuser1', 'testuser1', 'testuser1@tmb.com.test', false).get(0);
		User01.ProfileId = BDM_PROFILE_ID;
		User01.isActive = true;
		User01.RTL_Branch_Code__c = bz.Branch_Code__c;
		User01.Employee_ID__c = '11111';
		User01.Zone__c = 'SE-ChiangMai';
		User01.Zone_Code__c = '8888';
		User01.Region__c = 'SE1-North1';
		User01.Region_Code__c = '1111';
        User01.Segment__c = 'RM';
        userlst.add(User01);

        User User07 = RTL_TestUtility.createUsers(1, 'testuser7', 'testuser7', 'testuser7@tmb.com.test', false).get(0);
		User07.ProfileId = SESM_PROFILE_ID;
		User07.isActive = true;
		User07.RTL_Branch_Code__c = bz.Branch_Code__c;
		User07.Employee_ID__c = '77777';
		User07.Zone__c = 'SE-ChiangMai';
		User07.Zone_Code__c = '8888';
		User07.Region__c = 'SE1-North1';
		User07.Region_Code__c = '1111';
        User07.Segment__c = 'RM';
        userlst.add(User07);

        insert userlst;

        List<Account> existingAccts = new List<Account>();

        Account acctRec = TestUtils.createAccounts(1, 'TestAcct', 'Existing Customer', false).get(0);
        acctRec.OwnerId = User01.Id;
        acctRec.Account_Type__c = 'Existing Customer';
        acctRec.Stamp_Owner_Region_Group__c = 'SE-North1';
        acctRec.Stamp_Owner_Region_Code_Group_Code__c = '1111';
        acctRec.Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
        acctRec.Stamp_Owner_Zone_Code_Team_C__c = '9999';
        acctRec.Stamp_Owner_Segment__c = 'SE';
        existingAccts.add(acctRec);

        Account acctRec2 = TestUtils.createAccounts(1, 'TestAcct2', 'Existing Customer', false).get(0);
        acctRec2.OwnerId = User01.Id;
        acctRec2.Account_Type__c = 'Existing Customer';
        acctRec2.Stamp_Owner_Region_Group__c = 'SE-North1';
        acctRec2.Stamp_Owner_Region_Code_Group_Code__c = '1111';
        acctRec2.Stamp_Owner_Zone_Team__c = 'SE-ChiangMai';
        acctRec2.Stamp_Owner_Zone_Code_Team_C__c = '9999';
        acctRec2.Stamp_Owner_Segment__c = 'SE';
        existingAccts.add(acctRec2);

        insert existingAccts;

        Change_Owner_Approval_History__c approvalHisRec = new Change_Owner_Approval_History__c();
        approvalHisRec.RecordTypeId = Schema.Sobjecttype.Change_Owner_Approval_History__c.getRecordTypeInfosByName().get('Change Segment').getRecordTypeId();
        approvalHisRec.Current_Segement__c = acctRec2.Core_Banking_Suggested_Segment__c;
        approvalHisRec.To_Be_New_Segment__c = 'MB';
        approvalHisRec.Change_Owner_Remark__c = 'TestCheckApprove';
        approvalHisRec.Account__c = acctRec2.Id;
        approvalHisRec.Current_Owner__c = acctRec2.OwnerId;
        approvalHisRec.Change_to_owner__c = User01.Id;

        insert approvalHisRec;

        Sub_Segment_Mapping__c subsegMap = new Sub_Segment_Mapping__c();
		subsegMap.Sub_Segment_Code__c = '20';
		subsegMap.Zone_Code_Team_Code__c = '8888';
		insert subsegMap;
    }

    
    @isTest 
    public static void TestgetAcctRec(){        
        User rm1 = [SELECT Id, Name FROM User WHERE Email = 'testuser1@tmb.com.test' LIMIT 1];
        List<Account> acctRec = [SELECT Id,Name FROM Account WHERE Account_Type__c='Existing Customer'];
        Test.startTest();
        System.runAs(rm1){
            ChangeSegmentController.getAcctRec(acctRec[0].Id);
            try {
                ChangeSegmentController.saveRecord(acctRec[0].Id, 'SE', 'Test');
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
        Test.stopTest();
    }

    @isTest 
    public static void TestgetAcctRecerror(){        
        User SESM_PROFILE_ID = [SELECT Id, Name FROM User WHERE Email = 'testuser7@tmb.com.test' AND ProfileId = :SESM_PROFILE_ID LIMIT 1];
        List<Account> acctRec = [SELECT Id,Name FROM Account WHERE Account_Type__c='Existing Customer'];
        Test.startTest();
        System.runAs(SESM_PROFILE_ID){
            ChangeSegmentController.getAcctRec(acctRec[1].Id);
        }
        Test.stopTest();
    }
}