@isTest
public class CreateSLLGroupControllerTest {
    static Account primCus;
    // static List<User> usrs;
    static User pam;
    static User approver1;
    static Id existingRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();
    // public static final Id SYSAD_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    public static final Id SESM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;
    public static final Id SEZM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Zone Manager Profile' LIMIT 1].Id;
	public static final Id RM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB RM Profile' LIMIT 1].Id;

    static{
        TestUtils.createAppConfig();
        init();
    }

    static void init(){
        primCus = TestUtils.createAccounts(1, 'test', 'A', false).get(0);
        primCus.RecordTypeId = existingRT;
        insert primCus;
        
        List<User> usrs = TestUtils.createUsers(2,'testfn001', 'testln001','testcre001@tmbbank.com', false);
        // usrs.get(0).Employee_ID__c = 'testempid01';
        // usrs.get(0).ProfileId = SESM_PROFILE_ID;
        // approver2 = usrs.get(0);
        // System.debug('Debug user '+usrs.get(0));
        // insert usrs.get(0);

        // usrs.get(0).ManagerId = usrs.get(0).Id;
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
    public static void testGetSLLGroupOfCustomer() {
            SLL_Group__c sg = new SLL_Group__c();
            sg.Name = 'testgroup';
            sg.Primary_Customer__c = primCus.Id;
            sg.PAM__c = pam.Id;
            sg.Remark__c = 'testremark';
            insert sg;

        Test.startTest();
            List<SLL_Group__c> testResult = CreateSLLGroupController.getSLLGroupOfCustomer(sg.Id, null);
            List<SLL_Group__c> expectedSG = [Select Id, Name, Primary_Customer__c FROM SLL_Group__c where Primary_Customer__c =: sg.Id and is_Active__c = true limit 1];

            System.assertEquals(expectedSG, testResult);
        Test.stopTest();
    }

    @isTest
    public static void testGetPAMApproverSuccess() {
        Test.startTest();
            CreateSLLGroupController.wrapApprover testResult = CreateSLLGroupController.getPAMApprover(pam.Id);
            
            System.assertEquals(approver1.Id, testResult.approver1.Id);
            System.assertEquals(null, testResult.errMsg);
        Test.stopTest();
    }

    @isTest
    public static void testGetPAMApproverFailed() {
        Test.startTest();
            CreateSLLGroupController.wrapApprover testResult = CreateSLLGroupController.getPAMApprover(approver1.Id);
            String errMsg = 'Not found Team head or Group head above the PAM';

            System.assertEquals(errMsg, testResult.errMsg);
        Test.stopTest();
    }

    @isTest
    public static void testCreateSLLGroupSuccess() {
        String gName = 'testgroup';
        String inpRemark = 'testremark';

        List<SLL_Group_Member__c> memberLst = new List<SLL_Group_Member__c>();
        memberLst.add(new SLL_Group_Member__c(Customer_Name__c = primCus.Id, Reason__c = '2001700002:มีการถือหุ้นหรือกรรมการไขว้กัน'));
        
        // error
        Test.startTest();
            SLL_Group__c testResult = CreateSLLGroupController.createSLLGroup(gName, primCus.Id, pam.Id, approver1.Id, inpRemark, memberLst);

            System.assertEquals(gName, testResult.Name);
            System.assertEquals(primCus.Id, testResult.Primary_Customer__c);
            System.assertEquals(pam.Id, testResult.PAM__c);
            System.assertEquals(approver1.Id, testResult.Approver1__c);
            // System.assertEquals(approver2.Id, testResult.Approver2__c);
            System.assertEquals(inpRemark, testResult.Remark__c);
        Test.stopTest();
    }

    @isTest
    public static void testCreateSLLGroupFailed1() {
        String gName = 'testgroup';
        String inpRemark = 'testremark';

        List<SLL_Group_Member__c> memberLst = new List<SLL_Group_Member__c>();
        memberLst.add(new SLL_Group_Member__c(Customer_Name__c = primCus.Id));
        
        Test.startTest();
            try {
                CreateSLLGroupController.createSLLGroup(gName, null, pam.Id, approver1.Id, inpRemark, memberLst);
            } catch (Exception e) {
                System.assertEquals(e.getMessage(), 'Script-thrown exception');
            }
        Test.stopTest();
    }

    @isTest
    public static void testCreateSLLGroupFailed2() {
        String gName = 'testgroup';
        String inpRemark = 'testremark';

        List<SLL_Group_Member__c> memberLst = new List<SLL_Group_Member__c>();
        memberLst.add(new SLL_Group_Member__c(Customer_Name__c = null, Reason__c = null));
        
        Test.startTest();
            try {
                CreateSLLGroupController.createSLLGroup(gName, primCus.Id, pam.Id, approver1.Id, inpRemark, memberLst);
            } catch(Exception e) {
                System.assertEquals(e.getMessage(), 'Script-thrown exception');
            }
        Test.stopTest();
    }

    @isTest
    public static void testGetReason() {
        Test.startTest();
            List<String> testResult = CreateSLLGroupController.getReasonList();
            System.assert(testResult.size() > 0, 'Reason list should be at least 1');
        Test.stopTest();
    }
}