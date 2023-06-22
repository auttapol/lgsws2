@isTest
public class SLLGroupTriggerTest {
    static Account primCus;
    static User pam;
    static User approver1;
    static Account customer;

    public static final Id ExistingRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();
    public static final Id AvailableRecordType = Schema.SObjectType.SLL_Group__c.getRecordTypeInfosByName().get('Available').getRecordTypeId();
    public static final Id DraftRecordType = Schema.SObjectType.SLL_Group__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
    public static final Id SESM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;
    public static final Id SEZM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Zone Manager Profile' LIMIT 1].Id;
	public static final Id RM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB RM Profile' LIMIT 1].Id;

    static{
        TestUtils.createAppConfig();
        init();
    }

    static void init(){
        primCus = TestUtils.createAccounts(1, 'test', 'A', false).get(0);
        primCus.RecordTypeId = ExistingRecordType;
        insert primCus;

        customer = TestUtils.createAccounts(1, 'test customer', 'A', false).get(0);
        customer.RecordTypeId = ExistingRecordType;
        insert customer;
        
        List<User> usrs = TestUtils.createUsers(3,'testuser112', 'test','testuser112@tmbbank.com', false);
        // usrs.get(0).Employee_ID__c = 'testempid01';
        // usrs.get(0).ProfileId = SESM_PROFILE_ID;
        // approver2 = usrs.get(0);
        // insert usrs.get(0);

        // usrs.get(1).ManagerId = usrs.get(0).Id;
        usrs.get(0).Employee_ID__c = 'testempid01';
        usrs.get(0).ProfileId = SEZM_PROFILE_ID;
        approver1 = usrs.get(0);
        insert usrs.get(0);

        usrs.get(1).ManagerId = usrs.get(0).Id;
        usrs.get(1).ProfileId = RM_PROFILE_ID;
        pam = usrs.get(1);
        insert usrs.get(1);

        
    }

    @isTest
    public static void testInsertCasePositive() {
        List<SLL_Group__c> newsllgroup = new List<SLL_Group__c>();

        SLL_Group__c canAddGroup = new SLL_Group__c(
            Name = 'canAddGroup', 
            PAM__c = pam.Id,
            Primary_Customer__c = primCus.Id,
            Remark__c = 'testRemark');

        newsllgroup.add(canAddGroup); // available cus
        Test.startTest();
            Appconfig__c Aconfig = [SELECT NAME,Value__c from Appconfig__c WHERE Name ='runtrigger' LIMIT 1];
            Aconfig.Value__c ='true';
            update Aconfig;

            Boolean chkResult = true;
            Database.SaveResult[] saveResultList = Database.insert(newsllgroup, false);

            for (Database.SaveResult sr : saveResultList) {
                if (!sr.isSuccess()) {
                    chkResult = false;
                }
            }
            System.assertEquals(true, chkResult);
        Test.stopTest();
    }

    @isTest
    public static void testInsertDupPrimCus() {
        Account existingPrimCus = TestUtils.createAccounts(2, 'test2', 'A', false).get(0);
        existingPrimCus.RecordTypeId = ExistingRecordType;
        insert existingPrimCus;

        SLL_Group__c existingGroup = new SLL_Group__c(
            Name = 'existing group', 
            Primary_Customer__c = existingPrimCus.Id, 
            Is_Active__c = true,
            PAM__c = pam.Id,
            RecordTypeId = AvailableRecordType,
            Remark__c = 'testremark');

        insert existingGroup;

        List<SLL_Group__c> newsllgroup = new List<SLL_Group__c>();

        SLL_Group__c addExistGroup = new SLL_Group__c(
            Name = 'existgroup', 
            PAM__c = pam.Id,
            Primary_Customer__c = existingPrimCus.Id
            );

        newsllgroup.add(addExistGroup); // existing cus

        Test.startTest();
            Appconfig__c Aconfig = [SELECT NAME,Value__c from Appconfig__c WHERE Name ='runtrigger' LIMIT 1];
            Aconfig.Value__c ='true';
            update Aconfig;

            try {
                insert newsllgroup;
            } catch (Exception e) {
                System.assert(e.getMessage().contains('The Primary Customer is already in another SLL Group.'), 'The Primary Customer is already in another SLL Group.');
            }
        Test.stopTest();
    }

    @isTest
    public static void testInsertPAMNoApprover() {
        List<SLL_Group__c> newsllgroup = new List<SLL_Group__c>();

        SLL_Group__c noApproverGroup = new SLL_Group__c(
            Name = 'noApproverGroup', 
            PAM__c = approver1.Id);

        newsllgroup.add(noApproverGroup); // available cus

        Test.startTest();
            Appconfig__c Aconfig = [SELECT NAME,Value__c from Appconfig__c WHERE Name ='runtrigger' LIMIT 1];
            Aconfig.Value__c ='true';
            update Aconfig;

            try {
                insert newsllgroup;
            } catch (Exception e) {
                System.assert(e.getMessage().contains('Not found team head or group head above the PAM'), 'Not found team head or group head above the PAM');
            }
        Test.stopTest();
    }

    @isTest
    public static void testInsertApproverInactive() {
        List<SLL_Group__c> newsllgroup = new List<SLL_Group__c>();
        List<User> usrs = TestUtils.createUsers(3,'testuser114', 'test','testuser112@tmbbank.com', false);
        usrs.get(0).Employee_ID__c = 'testempid11';
        usrs.get(0).ProfileId = SESM_PROFILE_ID;
        usrs.get(0).IsActive = false;
        insert usrs.get(0);

        usrs.get(1).ManagerId = usrs.get(0).Id;
        usrs.get(1).Employee_ID__c = 'testempid12';
        usrs.get(1).ProfileId = SEZM_PROFILE_ID;
        usrs.get(1).IsActive = false;
        insert usrs.get(1);

        usrs.get(2).ManagerId = usrs.get(1).Id;
        usrs.get(2).ProfileId = RM_PROFILE_ID;
        usrs.get(2).Employee_ID__c = 'testempid13';
        User pamApproverInactive = usrs.get(2);
        insert usrs.get(2);

        SLL_Group__c approverInactiveGroup = new SLL_Group__c(
            Name = 'approverInactiveGroup', 
            PAM__c = pamApproverInactive.Id);

        newsllgroup.add(approverInactiveGroup); // available cus
        Test.startTest();
            Appconfig__c Aconfig = [SELECT NAME,Value__c from Appconfig__c WHERE Name ='runtrigger' LIMIT 1];
            Aconfig.Value__c ='true';
            update Aconfig;

            try {
                insert newsllgroup;
            } catch (Exception e) {
                System.assert(e.getMessage().contains('TH or GH is inactive'),'TH or GH is inactive');
            }
        Test.stopTest();
    }

    @isTest
    public static void testApproveActive() {
        SLL_Group__c testGroup = new SLL_Group__c(
        Name = 'setup group', 
        Primary_Customer__c = primCus.Id, 
        Is_Active__c = false,
        PAM__c = pam.Id,
        RecordTypeId = DraftRecordType,
        Approval_Status__c = 'Pending Approval - Active',
        Remark__c = 'testremark');
        insert testGroup;

        SLL_Group_Approval_History__c testGroupHistory = new SLL_Group_Approval_History__c(
            SLL_Group_Name__c = testGroup.Id,
            Approval_Status_Pending__c = 'Pending',
            Request_Type__c = 'Request to add',
            Customer__c = customer.Id
        );
        insert testGroupHistory;

        testGroup.Approval_Status__c = 'Approved - Active';

        Test.startTest();
            Appconfig__c Aconfig = [SELECT NAME,Value__c from Appconfig__c WHERE Name ='runtrigger' LIMIT 1];
            Aconfig.Value__c ='true';
            update Aconfig;

            update testGroup;

            SLL_Group_Approval_History__c[] checkHist = [SELECT Id FROM SLL_Group_Approval_History__c WHERE Id =: testGroupHistory.Id AND Approval_Status_Pending__c = 'Approved'];
            System.assert(checkHist.size() > 0, 'History is not approved');
        Test.stopTest();
    }

    @isTest
    public static void testRejectActive() {
        SLL_Group__c testGroup = new SLL_Group__c(
        Name = 'setup group', 
        Primary_Customer__c = primCus.Id, 
        Is_Active__c = false,
        PAM__c = pam.Id,
        RecordTypeId = DraftRecordType,
        Approval_Status__c = 'Pending Approval - Active',
        Remark__c = 'testremark');
        insert testGroup;

        SLL_Group_Approval_History__c testGroupHistory = new SLL_Group_Approval_History__c(
            SLL_Group_Name__c = testGroup.Id,
            Approval_Status_Pending__c = 'Pending',
            Request_Type__c = 'Request to add',
            Customer__c = customer.Id
        );
        insert testGroupHistory;

        testGroup.Approval_Status__c = 'Rejected - Active';

        Test.startTest();
            Appconfig__c Aconfig = [SELECT NAME,Value__c from Appconfig__c WHERE Name ='runtrigger' LIMIT 1];
            Aconfig.Value__c ='true';
            update Aconfig;

            update testGroup;

            SLL_Group_Approval_History__c[] checkHist = [SELECT Id FROM SLL_Group_Approval_History__c WHERE Id =: testGroupHistory.Id AND Approval_Status_Pending__c = 'Rejected'];
            System.assert(checkHist.size() > 0, 'History is not rejected');
        Test.stopTest();
    }

    @isTest
    public static void testApproveUpdate() {
        List<User> usrs = TestUtils.createUsers(3,'testuser114', 'test','testuser112@tmbbank.com', false);
        usrs.get(0).Employee_ID__c = 'testempid11';
        usrs.get(0).ProfileId = SESM_PROFILE_ID;
        usrs.get(0).IsActive = true;
        insert usrs.get(0);

        usrs.get(1).ManagerId = usrs.get(0).Id;
        usrs.get(1).Employee_ID__c = 'testempid12';
        usrs.get(1).ProfileId = SEZM_PROFILE_ID;
        usrs.get(1).IsActive = true;
        insert usrs.get(1);

        usrs.get(2).ManagerId = usrs.get(1).Id;
        usrs.get(2).ProfileId = RM_PROFILE_ID;
        usrs.get(2).Employee_ID__c = 'testempid13';
        User newPAM = usrs.get(2);
        insert usrs.get(2);

        SLL_Group__c testGroup = new SLL_Group__c(
        Name = 'setup group', 
        Primary_Customer__c = primCus.Id, 
        Is_Active__c = true,
        PAM__c = pam.Id,
        RecordTypeId = AvailableRecordType,
        Approval_Status__c = 'Pending Approval - Update',
        Remark__c = 'testremark',
        PAM_To_Be__c = newPAM.Id
        );
        insert testGroup;

        testGroup.Approval_Status__c = 'Approved - Update';

        Test.startTest();
            Appconfig__c Aconfig = [SELECT NAME,Value__c from Appconfig__c WHERE Name ='runtrigger' LIMIT 1];
            Aconfig.Value__c ='true';
            update Aconfig;

            update testGroup;
            SLL_Group__c chkGroup = [SELECT Id,PAM__c FROM SLL_Group__c WHERE Id =: testGroup.Id];
            System.assertEquals(newPAM.Id, chkGroup.PAM__c);
        Test.stopTest();
    }

    @isTest
    public static void testRejectUpdate() {
        List<User> usrs = TestUtils.createUsers(3,'testuser114', 'test','testuser112@tmbbank.com', false);
        usrs.get(0).Employee_ID__c = 'testempid11';
        usrs.get(0).ProfileId = SESM_PROFILE_ID;
        usrs.get(0).IsActive = true;
        insert usrs.get(0);

        usrs.get(1).ManagerId = usrs.get(0).Id;
        usrs.get(1).Employee_ID__c = 'testempid12';
        usrs.get(1).ProfileId = SEZM_PROFILE_ID;
        usrs.get(1).IsActive = true;
        insert usrs.get(1);

        usrs.get(2).ManagerId = usrs.get(1).Id;
        usrs.get(2).ProfileId = RM_PROFILE_ID;
        usrs.get(2).Employee_ID__c = 'testempid13';
        User newPAM = usrs.get(2);
        insert usrs.get(2);

        SLL_Group__c testGroup = new SLL_Group__c(
        Name = 'setup group', 
        Primary_Customer__c = primCus.Id, 
        Is_Active__c = true,
        PAM__c = pam.Id,
        RecordTypeId = AvailableRecordType,
        Approval_Status__c = 'Pending Approval - Update',
        Remark__c = 'testremark',
        PAM_To_Be__c = newPAM.Id
        );
        insert testGroup;

        testGroup.Approval_Status__c = 'Rejected - Update';

        Test.startTest();
            Appconfig__c Aconfig = [SELECT NAME,Value__c from Appconfig__c WHERE Name ='runtrigger' LIMIT 1];
            Aconfig.Value__c ='true';
            update Aconfig;

            update testGroup;
            SLL_Group__c chkGroup = [SELECT Id,PAM__c FROM SLL_Group__c WHERE Id =: testGroup.Id];
            System.assertEquals(pam.Id, chkGroup.PAM__c);
        Test.stopTest();
    }

    @isTest
    public static void testApproveInactive() {
        SLL_Group__c testGroup = new SLL_Group__c(
        Name = 'setup group', 
        Primary_Customer__c = primCus.Id, 
        Is_Active__c = true,
        PAM__c = pam.Id,
        RecordTypeId = AvailableRecordType,
        Approval_Status__c = 'Pending Approval - Inactive',
        Remark__c = 'testremark');
        insert testGroup;

        SLL_Group_Member__c testGroupMember = new SLL_Group_Member__c(
            SLL_Group__c = testGroup.Id,
            Customer_Name__c = customer.Id
        );
        insert testGroupMember;

        SLL_Group_Approval_History__c testGroupHistory = new SLL_Group_Approval_History__c(
            SLL_Group_Name__c = testGroup.Id,
            Approval_Status_Pending__c = 'Pending',
            Request_Type__c = 'Request to add',
            Customer__c = customer.Id
        );
        insert testGroupHistory;

        testGroup.Approval_Status__c = 'Approved - Inactive';

        Test.startTest();
            Appconfig__c Aconfig = [SELECT NAME,Value__c from Appconfig__c WHERE Name ='runtrigger' LIMIT 1];
            Aconfig.Value__c ='true';
            update Aconfig;
            System.debug('to update sll group '+testGroup);
            update testGroup;

            SLL_Group_Member__c[] checkMember = [SELECT Id FROM SLL_Group_Member__c WHERE SLL_Group__c =: testGroup.Id];
            System.assertEquals(0,checkMember.size());
        Test.stopTest();
    }

    @isTest
    public static void testRejectInactive() {
        SLL_Group__c testGroup = new SLL_Group__c(
        Name = 'setup group', 
        Primary_Customer__c = primCus.Id, 
        Is_Active__c = true,
        PAM__c = pam.Id,
        RecordTypeId = AvailableRecordType,
        Approval_Status__c = 'Pending Approval - Inactive',
        Remark__c = 'testremark');
        insert testGroup;

        SLL_Group_Member__c testGroupMember = new SLL_Group_Member__c(
            SLL_Group__c = testGroup.Id
        );
        insert testGroupMember;

        testGroup.Approval_Status__c = 'Rejected - Inactive';

        Test.startTest();
            Appconfig__c Aconfig = [SELECT NAME,Value__c from Appconfig__c WHERE Name ='runtrigger' LIMIT 1];
            Aconfig.Value__c ='true';
            update Aconfig;

            update testGroup;

            SLL_Group_Member__c[] checkMember = [SELECT Id FROM SLL_Group_Member__c WHERE SLL_Group__c =: testGroup.Id];
            System.assertEquals(1,checkMember.size());
        Test.stopTest();
    }
}