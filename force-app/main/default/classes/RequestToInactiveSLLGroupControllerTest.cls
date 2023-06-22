@isTest
public class RequestToInactiveSLLGroupControllerTest {

    static Account primCus;
    static User pam;
    static User approver1;
    // static User approver2;

    public static final Id AvailableRecordType = Schema.SObjectType.SLL_Group__c.getRecordTypeInfosByName().get('Available').getRecordTypeId();
    public static final Id SESM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;
    public static final Id SEZM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Zone Manager Profile' LIMIT 1].Id;
	public static final Id RM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB RM Profile' LIMIT 1].Id;
    public static final Id ExistingRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();

    static{
        TestUtils.createAppConfig();
        init();
    }

    static void init(){
        primCus = TestUtils.createAccounts(1, 'test', 'A', false).get(0);
        primCus.RecordTypeId = ExistingRecordType;
        insert primCus;
        List<User> usrs = TestUtils.createUsers(3,'testuser112', 'test','testuser112@tmbbank.com', false);
        // usrs.get(0).Employee_ID__c = 'testempid01';
        // usrs.get(0).ProfileId = SESM_PROFILE_ID;
        // // approver2 = usrs.get(0);
        // insert usrs.get(0);

        usrs.get(0).Employee_ID__c = 'testempid01';
        // usrs.get(1).ManagerId = usrs.get(0).Id;
        usrs.get(0).ProfileId = SEZM_PROFILE_ID;
        approver1 = usrs.get(0);
        insert usrs.get(0);

        usrs.get(1).ManagerId = usrs.get(0).Id;
        usrs.get(1).ProfileId = RM_PROFILE_ID;
        pam = usrs.get(1);
        insert usrs.get(1);
    }

    @isTest
    public static void testRequestToInactiveSLLGroupSuccess() {
        String comment = 'test comment';
        SLL_Group__c sg = new SLL_Group__c();
            sg.Name = 'testgroup';
            sg.Primary_Customer__c = primCus.Id;
            sg.PAM__c = pam.Id;
            sg.Approver1__c = approver1.Id;
            // sg.Approver2__c = approver2.Id;
            sg.Remark__c = 'testremark';
            sg.Is_Active__c = true;
            sg.Approval_Status__c = 'Approved - Active';
            sg.RecordTypeId = AvailableRecordType;
            insert sg;

            Test.startTest();
                SLL_Group__c testResult = RequestToInactiveSLLGroup.requestToInactiveSLLGroup(sg.Id, comment);
                // List<SLL_Group__c> expectedSG = [Select Id, Name, Primary_Customer__c FROM SLL_Group__c where Primary_Customer__c =: sg.Id and is_Active__c = true limit 1];

                System.assertEquals(sg.Name, testResult.Name);
                System.assertEquals('Pending Approval - Inactive', testResult.Approval_Status__c);
            Test.stopTest();
    }

    @isTest
    public static void testRequestToInactiveSLLGroupNoApprover() {
        String comment = 'test comment';
        SLL_Group__c sg = new SLL_Group__c();
            sg.Name = 'testgroup';
            sg.Primary_Customer__c = primCus.Id;
            sg.PAM__c = pam.Id;
            sg.Remark__c = 'testremark';
            insert sg;

            Test.startTest();
            try {
                SLL_Group__c testResult = RequestToInactiveSLLGroup.requestToInactiveSLLGroup(sg.Id, comment);
            } catch (Exception e) {
                System.assertEquals(e.getMessage(), 'Script-thrown exception');
            }
            Test.stopTest();
    }

    @isTest
    public static void testRequestToInactiveSLLGroupSubmitFailed() {
        String comment = 'test comment';
        SLL_Group__c sg = new SLL_Group__c();
            sg.Name = 'testgroup';
            sg.Primary_Customer__c = primCus.Id;
            sg.PAM__c = pam.Id;
            sg.Approver1__c = approver1.Id;
            // sg.Approver2__c = approver2.Id;
            sg.Remark__c = 'testremark';
            insert sg;

            Test.startTest();
                try {
                    SLL_Group__c testResult = RequestToInactiveSLLGroup.requestToInactiveSLLGroup(sg.Id, comment);
                } catch (Exception e) {
                    System.assertEquals(e.getMessage(), 'Script-thrown exception');
                }
            Test.stopTest();
    }

    @isTest
    public static void testRequestToInactiveSLLGroupApproverInactive() {
        String comment = 'test comment';
        List<User> inactiveUsers = TestUtils.createUsers(1,'testuser114', 'test','testuser112@tmbbank.com', false);
        User newApprover1 = inactiveUsers.get(0);
        newApprover1.isActive = false;
        // newApprover1.ManagerId = approver2.Id;
        newApprover1.ProfileId = SEZM_PROFILE_ID;
        newApprover1.Employee_ID__c = 'testempid55';
        insert newApprover1;

        pam.ManagerId = newApprover1.Id;
        update pam;

        SLL_Group__c sg = new SLL_Group__c();
            sg.Name = 'testgroup';
            sg.Primary_Customer__c = primCus.Id;
            sg.PAM__c = pam.Id;
            sg.Approver1__c = newApprover1.Id;
            // sg.Approver2__c = approver2.Id;
            sg.Remark__c = 'testremark';
            sg.Is_Active__c = true;
            sg.Approval_Status__c = 'Approved - Active';
            sg.RecordTypeId = AvailableRecordType;
            insert sg;

            Test.startTest();
                try {
                    SLL_Group__c testResult = RequestToInactiveSLLGroup.requestToInactiveSLLGroup(sg.Id, comment);
                } catch (Exception e) {
                    System.assertEquals(e.getMessage(), 'Script-thrown exception');
                }
            Test.stopTest();
    }
}