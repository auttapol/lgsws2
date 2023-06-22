@isTest
public class SLLApprovalHistoryTriggerHandlerTest {
    public static final Id PAM_TMB_RM_PROFILE = [SELECT Id FROM Profile WHERE Name = 'TMB RM Profile' LIMIT 1].Id;
    public static final Id EXISTING_ID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();
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
        customer.RecordTypeId = EXISTING_ID;
        insert customer;

        SLL_Group__c sllGroup = new SLL_Group__c();
        sllGroup.Name = 'SLLGROUP001';
        sllGroup.PAM__c = user[0].Id;
        sllGroup.Approval_Status__c	='Approved - Active';
        sllGroup.Is_Active__c = true;
        sllGroup.Remark__c = 'TestGroup';
        sllGroup.Primary_Customer__c = customer.Id;
        sllGroup.Approver1__c = user[1].Id;
        sllGroup.Approver2__c = user[2].Id;
        insert sllGroup;

        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';        
        insert Aconfig;
    }
    @isTest
    public static void handleCreateRecordTest_SUCCESS(){
        Test.startTest();

        User Pam = [SELECT id,ManagerId,Manager.ManagerId FROM USER WHERE ProfileId =: PAM_TMB_RM_PROFILE AND ManagerId != null LIMIT 1];
        SLL_Group_Approval_History__c record = new SLL_Group_Approval_History__c();
        Id currentuserId = Userinfo.getUserId();
        datetime curDateTime = datetime.now();
        record.Customer__c = [SELECT id FROM Account LIMIT 1 ].Id;
        record.SLL_Group_Name__c = [SELECT id FROM SLL_Group__c LIMIT 1 ].Id;
        record.Requester__c = currentuserId;
        record.Request_Date__c = curDateTime;
        record.Request_Type__c = 'Request to add';
        record.Reason__C = '2001700001:เป็นผู้ที่เกี่ยวข้อง (ตามประกาศ Single Lending Limit)';
        record.Approver1__c = Pam.ManagerId;
        record.Approver2__c = Pam.Manager.ManagerId;
        record.Approval_Status_Pending__c = 'Pending';
        insert record;
        record.Approval_Status_Pending__c = 'Approved';
        update record;
        Test.stopTest();

    }
    // @isTest
    // public static void handleCreateRecordTest_ERROR(){
    //     Test.startTest();

    //     User Pam = [SELECT id,ManagerId,Manager.ManagerId FROM USER WHERE ProfileId =: PAM_TMB_RM_PROFILE AND ManagerId != null LIMIT 1];
    //     SLL_Group_Approval_History__c record = new SLL_Group_Approval_History__c();
    //     Id currentuserId = Userinfo.getUserId();
    //     datetime curDateTime = datetime.now();
    //     record.Customer__c = [SELECT id FROM Account LIMIT 1 ].Id;
    //     record.SLL_Group_Name__c = [SELECT id FROM SLL_Group__c LIMIT 1 ].Id;
    //     record.Requester__c = currentuserId;
    //     record.Request_Date__c = curDateTime;
    //     record.Request_Type__c = 'Request to add';
    //     record.Reason__C = '2001700001:เป็นผู้ที่เกี่ยวข้อง (ตามประกาศ Single Lending Limit)';
    //     record.Approver1__c = Pam.ManagerId;
    //     record.Approver2__c = Pam.Manager.ManagerId;
    //     record.Approval_Status_Pending__c = 'Pending';
    //     insert record;
    //     record.Approval_Status_Pending__c = 'Approved';
    //     update record;
    //     record.Approval_Status_Pending__c = 'Pending';
    //     update record;
    //     try{
    //         record.Approval_Status_Pending__c = 'Approved';
    //         update record;
    //     }
    //     catch (Exception e) {
    //         System.debug(e.getMessage());
    //     }

    //     Test.stopTest();
    // }
    @isTest
    public static void handleRemoveRecordTest_SUCCESS(){
        Id groupId = [SELECT id FROM SLL_Group__c LIMIT 1 ].Id;
        Id CusId = [SELECT id FROM Account LIMIT 1 ].Id;

        SLL_Group_Member__c newGroupMember = new SLL_Group_Member__c();
        newGroupMember.Customer_Name__c = CusId;
        newGroupMember.SLL_Group__c = groupId;
        newGroupMember.Reason__c = '2001700001:เป็นผู้ที่เกี่ยวข้อง (ตามประกาศ Single Lending Limit)';
        newGroupMember.Last_Approve_Date__c = datetime.now();
        insert newGroupMember;

        Test.startTest();
        User Pam = [SELECT id,ManagerId,Manager.ManagerId FROM USER WHERE ProfileId =: PAM_TMB_RM_PROFILE AND ManagerId != null LIMIT 1];
        SLL_Group_Approval_History__c record = new SLL_Group_Approval_History__c();
        Id currentuserId = Userinfo.getUserId();
        datetime curDateTime = datetime.now();
        record.Customer__c = CusId;
        record.SLL_Group_Name__c = groupId;
        record.Requester__c = currentuserId;
        record.Request_Date__c = curDateTime;
        record.Request_Type__c = 'Request to remove';
        record.Reason__C = '2001700001:เป็นผู้ที่เกี่ยวข้อง (ตามประกาศ Single Lending Limit)';
        record.Approver1__c = Pam.ManagerId;
        record.Approver2__c = Pam.Manager.ManagerId;
        record.Approval_Status_Pending__c = 'Pending';
        record.SLL_Group_Member__c = newGroupMember.Id;
        insert record;
        try{
            record.Approval_Status_Pending__c = 'Approved';
            update record;
        }
        catch (Exception e) {
            System.debug('Errr : '+e.getMessage());
        }
        Test.stopTest();
    }
    @isTest
    public static void handleRemoveRecordTest_ERROR(){
        Id groupId = [SELECT id FROM SLL_Group__c LIMIT 1 ].Id;
        Id CusId = [SELECT id FROM Account LIMIT 1 ].Id;

        Test.startTest();
        User Pam = [SELECT id,ManagerId,Manager.ManagerId FROM USER WHERE ProfileId =: PAM_TMB_RM_PROFILE AND ManagerId != null LIMIT 1];
        SLL_Group_Approval_History__c record = new SLL_Group_Approval_History__c();
        Id currentuserId = Userinfo.getUserId();
        datetime curDateTime = datetime.now();
        record.Customer__c = CusId;
        record.SLL_Group_Name__c = groupId;
        record.Requester__c = currentuserId;
        record.Request_Date__c = curDateTime;
        record.Request_Type__c = 'Request to remove';
        record.Reason__C = '2001700001:เป็นผู้ที่เกี่ยวข้อง (ตามประกาศ Single Lending Limit)';
        record.Approver1__c = Pam.ManagerId;
        record.Approver2__c = Pam.Manager.ManagerId;
        record.Approval_Status_Pending__c = 'Pending';
        insert record;
        try{
            record.Approval_Status_Pending__c = 'Approved';
            update record;
        }
        catch (Exception e) {
            System.debug('Errr : '+e.getMessage());
            System.assertEquals(e.getMessage(), 'Invalid id at index 0: null');
        }
        Test.stopTest();
    }
}