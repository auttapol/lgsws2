@isTest
public class LeadAssignmentUtilTest {
    static User adminUser{
        get
        {
            if(adminUser == null){
                adminUser = [SELECT Id, Name FROM User WHERE IsActive = true AND ProfileId =: TestUtils.SYSADMIN_PROFILE_ID LIMIT 1];
            }
            return adminUser;
        }
        set;
    }

    static {
        System.runAs(adminUser){
                
            TestUtils.createAppConfig();

            Branch_and_zone__c bz = new Branch_and_zone__c();
            bz.Branch_Code__c = '001';
            bz.Name = '001';
            bz.RMC_User__c = adminUser.Id;
            bz.SE_Queue_Name__c = 'test_queue';
            bz.isActive__c = true;
            insert bz;

            Group queue = new Group();
            queue.Name = 'Email - TMB';
            queue.DeveloperName = 'test_queue';
            queue.type = 'Queue';
            insert queue;
            
            QueuesObject qsObject = new QueueSObject();
            qsObject.QueueId = queue.Id;
            qsObject.SobjectType = 'Lead';
            insert qsObject;
            
            RTL_TestUtility.enableWebToLeadAutoAssign(true);
        }
    }

    @isTest
    public static void testCreateLeadCommercialAssignUserField(){
        RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 1;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_Assigned_User_field__c = 'OwnerId';
        leadAssignmentrule.RTL_IsAssign_Campaign__c = false;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Commercial Lead';
        insert leadAssignmentrule;

        Test.startTest();
        Lead led = new Lead();
        led.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
        led.Company = 'Company';
        led.LastName = 'LastName';
        insert led;
        Test.stopTest();
    }

    @isTest
    public static void testCreateLeadCommercialAssignUser(){
        RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 1;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_Assigned_User__c = userinfo.getUserId();
        leadAssignmentrule.RTL_IsAssign_Campaign__c = false;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Commercial Lead';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Web';
        insert leadAssignmentrule;

        RTL_Lead_Assignment_Rule__c leadAssignmentrule2 = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule2.RTL_Active_Flag__c = true;
        leadAssignmentrule2.RTL_Priority__c = 0;
        leadAssignmentrule2.RTL_IsInsertProduct__c = true;
        leadAssignmentrule2.RTL_Assigned_User_field__c = 'OwnerId';
        leadAssignmentrule2.RTL_IsAssign_Campaign__c = false;
        leadAssignmentrule2.RTL_Lead_Record_Type__c = 'Commercial Lead';
        leadAssignmentrule2.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule2.RTL_Lead_Field_Value_1__c = 'Web2';
        insert leadAssignmentrule2;

        Test.startTest();
        Lead led = new Lead();
        led.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
        led.Company = 'Company';
        led.LastName = 'LastName';
        led.LeadSource = 'Web';
        insert led;
        Test.stopTest();
    }

    @isTest
    public static void testCreateLeadCommercialAssignQueueName(){
        RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 1;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_Assigned_Queue_Name__c = 'test_queue';
        leadAssignmentrule.RTL_IsAssign_Campaign__c = false;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Commercial Lead';
        insert leadAssignmentrule;

        Test.startTest();
        Lead led = new Lead();
        led.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
        led.Company = 'Company';
        led.LastName = 'LastName';
        insert led;
        Test.stopTest();
    }

    @isTest
    public static void testCreateLeadCommercialAssignBranchZoneUserField(){
        RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 1;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_Branch_and_Zone_Queue_User_field__c = 'SE_Queue_Name__c';
        leadAssignmentrule.RTL_IsAssign_Campaign__c = false;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Commercial Lead';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Q';
        insert leadAssignmentrule;

        leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 2;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_Branch_and_Zone_Queue_User_field__c = 'RMC_User__c';
        leadAssignmentrule.RTL_IsAssign_Campaign__c = false;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Commercial Lead';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'User';
        insert leadAssignmentrule;

        Test.startTest();
        Lead led = new Lead();
        led.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
        led.Company = 'Company';
        led.LastName = 'LastName';
        led.LeadSource = 'Q';
        led.RTL_Branch_Name__c = '001';
        insert led;

        Lead led2 = new Lead();
        led2.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
        led2.Company = 'Company';
        led2.LastName = 'LastName';
        led2.LeadSource = 'User';
        led2.RTL_Branch_Name__c = '001';
        insert led2;
        
        led2 = new Lead();
        led2.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
        led2.Company = 'Company';
        led2.LastName = 'LastName';
        led2.LeadSource = 'User';
        led2.RTL_Branch_Name__c = '111';
        insert led2;
        Test.stopTest();
    }

    @isTest
    public static void testCreateLeadCommercialAssignDefult(){
        RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 1;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_Default_Queue_Name__c = 'test_queue';
        leadAssignmentrule.RTL_IsAssign_Campaign__c = false;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Commercial Lead';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Q';
        insert leadAssignmentrule;

        leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 2;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_Default_User__c = adminUser.Id;
        leadAssignmentrule.RTL_IsAssign_Campaign__c = false;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Commercial Lead';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'User';
        insert leadAssignmentrule;

        Test.startTest();
        Lead led = new Lead();
        led.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
        led.Company = 'Company';
        led.LastName = 'LastName';
        led.LeadSource = 'Q';
        insert led;

        Lead led2 = new Lead();
        led2.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();
        led2.Company = 'Company';
        led2.LastName = 'LastName';
        led2.LeadSource = 'User';
        insert led2;
        Test.stopTest();
    }
}