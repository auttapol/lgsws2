@isTest
public class RequestToAddSLLGroupControllerTest {
    public static final Id PAM_TMB_RM_PROFILE = [SELECT Id FROM Profile WHERE Name = 'TMB RM Profile' LIMIT 1].Id;
    public static final String ERROR_PROCESSINSTANCE_LABEL = System.Label.RequestChangeOwnerMessage2;
    public static final String ERROR_EXISTCUSTOMER_LABEL = System.Label.SLLGroupMessage11;
    public static final String ERROR_NO_PAM_MANAGER_LABEL = System.Label.SLLGroupMessage3;
    public static final String ERROR_EXIST_PENDING_LABEL = System.Label.SLLGroupMessage14;
    public static final Id AVAILABLE_ID = Schema.SObjectType.SLL_Group__c.getRecordTypeInfosByName().get('Available').getRecordTypeId();
    public static final Id EXISTING_ID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();
    @TestSetup
    static void makeData(){
        TestUtils.createAppConfig();
        List<User> user = TestUtils.createUsers(4,'UserTest','Test00','Test@gmail.com',false);
        user[0].profileId = PAM_TMB_RM_PROFILE;
        user[3].profileId = PAM_TMB_RM_PROFILE;
        insert user;

        user[0].ManagerId = user[1].Id;
        // user[1].ManagerId = user[2].Id;
        update user;

        Account customer = TestUtils.createAccounts(1,'CustomerTest','Individual',false).get(0);
        customer.RecordTypeId = EXISTING_ID;
        insert customer;
        Account customer2 = TestUtils.createAccounts(1,'CustomerTest','Individual',false).get(0);
        insert customer2;

        SLL_Group__c sllGroup = new SLL_Group__c();
        sllGroup.Name = 'SLLGROUP001';
        sllGroup.PAM__c = user[0].Id;
        sllGroup.Approval_Status__c	='Approved - Active';
        sllGroup.Is_Active__c = true;
        sllGroup.Remark__c = 'TestGroup';
        sllGroup.Primary_Customer__c = customer.Id;
        sllGroup.Approver1__c = user[1].Id;
        // sllGroup.Approver2__c = user[2].Id;
        insert sllGroup;

        SLL_Group__c sllGroup2 = new SLL_Group__c();
        sllGroup2.Name = 'SLLGROUP002';
        sllGroup2.PAM__c =user[3].Id;
        sllGroup2.Approval_Status__c = 'Approved - Active';
        sllGroup2.Is_Active__c = true;
        sllGroup2.Remark__c = 'TestGroup2';
        sllGroup2.Primary_Customer__c = customer.Id;
        sllGroup2.Approver1__c = user[1].Id;
        // sllGroup2.Approver2__c = user[2].Id;
        insert sllGroup2;

    }
    @isTest
    public static void TestgetAccRec(){
        Account acc = [SELECT id,name FROM Account LIMIT 1];
        Test.startTest();
        Account testacc = RequestToAddSLLGroupController.getAccRec(acc.Id);
        System.assertNotEquals(testacc,null);
        Test.stopTest();
    }
    @isTest
    public static void TestgetPickListValues(){
        Test.startTest();
        List<String> lst = RequestToAddSLLGroupController.getPickListValues();
        System.assertNotEquals(lst.size(),0);
        Test.stopTest();
    }
    @isTest
    public static void TestgetGroupPAM(){
        SLL_Group__c grp = [SELECT id,name FROM SLL_Group__c LIMIT 1];
        Test.startTest();
        SLL_Group__c testgrp = RequestToAddSLLGroupController.getGroupPAM(grp.Id);
        System.assertNotEquals(testgrp,null);
        Test.stopTest();
    }
    @isTest
    public static void TestgetPAMapprover(){
        User user = [SELECT id FROM User WHERE profileId =: PAM_TMB_RM_PROFILE AND ManagerId != null LIMIT 1];
        RequestToAddSLLGroupController.wrapApprover newWrapper = new RequestToAddSLLGroupController.wrapApprover();
        Test.startTest();
        newWrapper = RequestToAddSLLGroupController.getPAMapprover(user.Id);
        System.assertEquals(newWrapper.errMsg,null);
        Test.stopTest();
    }
    @isTest
    public static void TestgetPAMapproverFAIL(){
        SLL_Group__c grp = [SELECT id,Name,PAM__c FROM SLL_Group__c WHERE PAM__r.ManagerId = null LIMIT 1];
        RequestToAddSLLGroupController.wrapApprover newWrapper = new RequestToAddSLLGroupController.wrapApprover();
        Test.startTest();
        newWrapper = RequestToAddSLLGroupController.getPAMapprover(grp.PAM__c);
        System.assertNotEquals(newWrapper.errMsg,null);
        Test.stopTest();
    }
    @isTest
    public static void TestcreateRecord(){
        SLL_Group__c grp = [SELECT id,Name,PAM__c,PAM__r.ManagerId FROM SLL_Group__c LIMIT 1];
        Account acc = [SELECT id FROM Account LIMIT 1];
        Id approver1 = grp.PAM__r.ManagerId;
        // Id approver2 = grp.PAM__r.Manager.ManagerId;
        String Reason = '2001700001:เป็นผู้ที่เกี่ยวข้อง (ตามประกาศ Single Lending Limit)';
    
        Test.startTest();
        String result_success = RequestToAddSLLGroupController.createRecord(grp.Id,acc.Id,Reason,approver1);
        System.assertEquals(result_success,'SUCCESS');

        String result_fail = RequestToAddSLLGroupController.createRecord(grp.Id,acc.Id,Reason,approver1);
        System.assertEquals(result_fail,ERROR_EXIST_PENDING_LABEL);

        Test.stopTest();
    }
    @isTest
    public static void TestcreateRecordFAIL(){
        SLL_Group__c grp = [SELECT id,Name,PAM__c,PAM__r.ManagerId,PAM__r.Manager.ManagerId FROM SLL_Group__c LIMIT 1];
        Account acc = [SELECT id FROM Account LIMIT 1];
        String Reason = '2001700001:เป็นผู้ที่เกี่ยวข้อง (ตามประกาศ Single Lending Limit)';
    
        Test.startTest();
        try {
            RequestToAddSLLGroupController.createRecord(grp.Id,acc.Id,Reason,null);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.assertEquals(e.getMessage(), 'Script-thrown exception');
        }
        Test.stopTest();
    }
    @isTest
    public static void TestcreateRecordFAIL_Dup(){
        SLL_Group__c grp = [SELECT id,Name,PAM__c,PAM__r.ManagerId FROM SLL_Group__c LIMIT 1];

        Account acc = [SELECT id FROM Account LIMIT 1];
        String Reason = '2001700001:เป็นผู้ที่เกี่ยวข้อง (ตามประกาศ Single Lending Limit)';

        SLL_Group_Member__c sllGroupMember = new SLL_Group_Member__c();
        sllGroupMember.Customer_Name__c = acc.Id;
        sllGroupMember.SLL_Group__c = grp.Id;
        sllGroupMember.Reason__c = Reason;
        insert sllGroupMember;

        Id approver1 = grp.PAM__r.ManagerId;
        // Id approver2 = grp.PAM__r.Manager.ManagerId;
    
        Test.startTest();
        String result_fail = RequestToAddSLLGroupController.createRecord(grp.Id,acc.Id,Reason,approver1);
        System.assertEquals(result_fail,ERROR_EXISTCUSTOMER_LABEL);
        Test.stopTest();
    }
    @isTest
    public static void TestcreateRecordFAIL_INSTANCE(){
        SLL_Group__c grp = [SELECT id,Name,PAM__c,PAM__r.ManagerId,PAM__r.Manager.ManagerId,Approval_Status__c FROM SLL_Group__c LIMIT 1];
        grp.Approval_Status__c = 'Pending Approval - Inactive';
        grp.recordtypeId = AVAILABLE_ID;
        grp.Is_Active__c = true;
        update grp;
        System.debug('Approver1' + grp.PAM__r.ManagerId);
        // System.debug('Approver2' + grp.PAM__r.Manager.ManagerId);

        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        String comment = 'Test';
        req.setComments(comment);
        req.setObjectId(grp.Id);
        req.setSubmitterId(UserInfo.getUserId()); 
        Approval.ProcessResult result = Approval.process(req);

        Account acc = [SELECT id FROM Account LIMIT 1];
        Id approver1 = grp.PAM__r.ManagerId;
        // Id approver2 = grp.PAM__r.Manager.ManagerId;
        String Reason = '2001700001:เป็นผู้ที่เกี่ยวข้อง (ตามประกาศ Single Lending Limit)';
        
        Test.startTest();
        String result_error = RequestToAddSLLGroupController.createRecord(grp.Id,acc.Id,Reason,approver1);
        System.assertEquals(result_error,ERROR_PROCESSINSTANCE_LABEL);
        Test.stopTest();
    }
}