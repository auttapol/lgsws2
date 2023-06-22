@isTest
public class RequestToRemoveSLLGroupControllerTest {
    public static final Id PAM_TMB_RM_PROFILE = [SELECT Id FROM Profile WHERE Name = 'TMB RM Profile' LIMIT 1].Id;
    public static final String ERROR_EXISTCUSTOMER_LABEL = System.Label.SLLGroupMessage11;
    public static final String ERROR_NO_PAM_MANAGER_LABEL = System.Label.SLLGroupMessage3;
    public static final String ERROR_EXIST_PENDING_LABEL = System.Label.SLLGroupMessage14;
    public static final Id ExistingRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();

    @TestSetup
    static void makeData(){
        TestUtils.createAppConfig();
        List<User> user = TestUtils.createUsers(4,'UserTest','Test00','Test@gmail.com',false);
        user[0].profileId = PAM_TMB_RM_PROFILE;
        user[3].profileId = PAM_TMB_RM_PROFILE;
        insert user;

        user[0].ManagerId = user[1].Id;
        user[1].ManagerId = user[2].Id;
        update user;

        Account customer = TestUtils.createAccounts(1,'CustomerTest','Individual',false).get(0);
        customer.RecordTypeId = ExistingRecordType;
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
        insert sllGroup;

        SLL_Group__c sllGroup2 = new SLL_Group__c();
        sllGroup2.Name = 'SLLGROUP002';
        sllGroup2.PAM__c =user[3].Id;
        sllGroup2.Approval_Status__c = 'Approved - Active';
        sllGroup2.Is_Active__c = true;
        sllGroup2.Remark__c = 'TestGroup2';
        sllGroup2.Primary_Customer__c = customer.Id;
        insert sllGroup2;

        SLL_Group__c sllGroup3 = new SLL_Group__c();
        sllGroup3.Name = 'SLLGROUP003';
        sllGroup3.Approval_Status__c = 'Approved - Active';
        sllGroup3.Is_Active__c = true;
        sllGroup3.Remark__c = 'TestGroup3';
        sllGroup3.Primary_Customer__c = customer.Id;
        insert sllGroup3;

        SLL_Group_Member__c sllGroupMember = new SLL_Group_Member__c();
        sllGroupMember.Customer_Name__c = customer.Id;
        sllGroupMember.SLL_Group__c = sllGroup.Id;
        sllGroupMember.Reason__c = '2001700001:เป็นผู้ที่เกี่ยวข้อง (ตามประกาศ Single Lending Limit)';
        insert sllGroupMember;

        SLL_Group_Member__c sllGroupMember2 = new SLL_Group_Member__c();
        sllGroupMember2.Customer_Name__c = customer.Id;
        sllGroupMember2.SLL_Group__c = sllGroup2.Id;
        sllGroupMember2.Reason__c = '2001700001:เป็นผู้ที่เกี่ยวข้อง (ตามประกาศ Single Lending Limit)';
        insert sllGroupMember2;
        
        SLL_Group_Member__c sllGroupMember3 = new SLL_Group_Member__c();
        sllGroupMember3.Customer_Name__c = customer.Id;
        sllGroupMember3.SLL_Group__c = sllGroup3.Id;
        sllGroupMember3.Reason__c = '2001700001:เป็นผู้ที่เกี่ยวข้อง (ตามประกาศ Single Lending Limit)';
        insert sllGroupMember3;
    }
    @isTest
    public static void TestGetGroupRecord(){
        RequestToRemoveSLLGroupController.wrapGroupMember case_success = new RequestToRemoveSLLGroupController.wrapGroupMember();
        RequestToRemoveSLLGroupController.wrapGroupMember case_fail_no_manager = new RequestToRemoveSLLGroupController.wrapGroupMember();
        RequestToRemoveSLLGroupController.wrapGroupMember case_fail_no_pam = new RequestToRemoveSLLGroupController.wrapGroupMember();

        List<SLL_Group_Member__c> sllGroupMember = [SELECT Id,SLL_Group__c,SLL_Group__r.PAM__c FROM SLL_Group_Member__c WHERE SLL_Group__r.PAM__c != null LIMIT 2];
        
        case_success = RequestToRemoveSLLGroupController.getGroupMemRec(sllGroupMember[0].Id);//Sucess
        System.assertEquals(case_success.errMsg, null);

        case_fail_no_manager = RequestToRemoveSLLGroupController.getGroupMemRec(sllGroupMember[1].Id);//Failed NO manager
        System.assertEquals(case_fail_no_manager.errMsg, ERROR_NO_PAM_MANAGER_LABEL);

        SLL_Group_Member__c sllGroupMember2 = [SELECT Id,SLL_Group__c,SLL_Group__r.PAM__c FROM SLL_Group_Member__c WHERE SLL_Group__r.PAM__c = null LIMIT 1];
        case_fail_no_pam = RequestToRemoveSLLGroupController.getGroupMemRec(sllGroupMember2.Id);//Fail No PAM
        System.assertEquals(case_fail_no_pam.errMsg, 'This Group Member don\'t have PAM');
    }
    @isTest
    public static void TestcreateRecordGroupHistory(){
        String reason = '2001700001:เป็นผู้ที่เกี่ยวข้อง (ตามประกาศ Single Lending Limit)';

        SLL_Group_Member__c sllGroupMember = [SELECT Id,SLL_Group__c,SLL_Group__r.PAM__c,SLL_Group__r.PAM__r.ManagerId,Customer_Name__c FROM SLL_Group_Member__c WHERE SLL_Group__r.PAM__c != null AND SLL_Group__r.PAM__r.profileId =: PAM_TMB_RM_PROFILE LIMIT 1];
        Id approver1 = sllGroupMember.SLL_Group__r.PAM__r.ManagerId;
        // Id approver2 = sllGroupMember.SLL_Group__r.PAM__r.Manager.ManagerId;
        
        try {
            RequestToRemoveSLLGroupController.createRecord(sllGroupMember.Id,sllGroupMember.SLL_Group__c,sllGroupMember.Customer_Name__c,reason,null);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.assertEquals(e.getMessage(), 'Script-thrown exception');
        }

        String Status_success = RequestToRemoveSLLGroupController.createRecord(sllGroupMember.Id,sllGroupMember.SLL_Group__c,sllGroupMember.Customer_Name__c,reason,approver1);//Success
        System.assertEquals(Status_success, 'SUCCESS');

        String Status_Fail_Dup = RequestToRemoveSLLGroupController.createRecord(sllGroupMember.Id,sllGroupMember.SLL_Group__c,sllGroupMember.Customer_Name__c,reason,approver1);//Create Duplicate Record
        System.assertEquals(Status_Fail_Dup, ERROR_EXIST_PENDING_LABEL);

        Account Acct = new Account(); 
        Acct.Name = 'Test Account Test';
        Acct.Phone ='050111222';
        Acct.Mobile_Number_PE__c  = '0801112233';
        Acct.ID_Type_PE__c  = 'Citizen ID';
        Acct.ID_Number_PE__c  = '1510100181965';
        
        Acct.Customer_Type__c = 'Individual';
        Acct.First_name_PE__c = 'TestMock3';
        Acct.First_Name_ENG_PE__c = 'TestMock3';
        Acct.Last_name_PE__c = 'TestMock';
        Acct.Last_Name_PE_Eng__c  = 'TestMock';
        Acct.Rating = 'Hot';
        Acct.IsDisqualified__c = false;
        String Status_Fail_No_Group = RequestToRemoveSLLGroupController.createRecord(sllGroupMember.Id,sllGroupMember.SLL_Group__c,Acct.Id,reason,approver1);//No Group Member
        System.assertEquals(Status_Fail_No_Group, 'No customer in this Group Member to remove.');

    }
}