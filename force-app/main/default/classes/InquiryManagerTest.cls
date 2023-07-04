@isTest
public with sharing class InquiryManagerTest {
    @testSetup static void setupTestData(){
        AppConfig__c app2 = new AppConfig__c(Name='runtrigger',Value__c='true');
        insert app2;
        Account acc = new Account (Name='TestAcc',Last_name_PE__c = 'Longdoo', First_name_PE__c = 'Somchai', Mobile_Number_PE__c ='0987654321', TMB_Customer_ID_PE__c = '001100000000000000000025173376');
        insert acc;
    }   

    @IsTest
    static void testInquiry() {

        Inquiry_List__c inquiryList = new Inquiry_List__c(
            Inquiry_Name__c = 'Test Inquiry',
            Salesforce_Object__c = 'Account',
            Message_Type__c ='Test'
        );
        insert inquiryList;

        Inquiry_Key__c inquiryKey = new Inquiry_Key__c(
            Parent_Id__c = inquiryList.Id,
            Key_Field__c = 'Name',
            Key_Parameter__c = 'Test'
        );
        insert inquiryKey;

        Inquiry_Data__c inquiryData = new Inquiry_Data__c(
            Parent_Id__c = inquiryList.Id,
            Salesforce_Field__c = 'Name',
            JSON_Mapping_Name__c = 'AccountName',
            Date_Format__c = 'yyyy-MM-dd',
            Field_Order__c = 1,
            IsActive__c = true
        );
        insert inquiryData;

        Map<String, Object> inquiryKeyMap = new Map<String, Object>();
        inquiryKeyMap.put('Test', 'Test');
        
        InquiryManager inqMgr = new InquiryManager('Test Inquiry', new Map<String, Object>());
        List<Map<String, Object>> jsonResult = inqMgr.getResult();
    }

    @IsTest
    static void testInquiryWithAndMultiKey() {

        Inquiry_List__c inquiryList = new Inquiry_List__c(
            Inquiry_Name__c = 'Test Inquiry',
            Salesforce_Object__c = 'Account',
            Message_Type__c ='Test'
        );
        
        insert inquiryList;

        Inquiry_Key__c inquiryKey = new Inquiry_Key__c(
            Parent_Id__c = inquiryList.Id,
            Key_Field__c = 'First_name_PE__c',
            Key_Parameter__c = 'firstName'
        );
        insert inquiryKey;
        inquiryKey = new Inquiry_Key__c(
            Parent_Id__c = inquiryList.Id,
            Key_Field__c = 'Last_name_PE__c',
            Key_Parameter__c = 'lastName'
        );
        insert inquiryKey;

        Inquiry_Data__c inquiryData = new Inquiry_Data__c(
            Parent_Id__c = inquiryList.Id,
            Salesforce_Field__c = 'First_name_PE__c',
            JSON_Mapping_Name__c = 'Firstname',
            Field_Order__c = 1,
            IsActive__c = true
        );
        insert inquiryData;
        inquiryData = new Inquiry_Data__c(
            Parent_Id__c = inquiryList.Id,
            Salesforce_Field__c = 'Last_name_PE__c',
            JSON_Mapping_Name__c = 'Lastname',
            Field_Order__c = 2,
            IsActive__c = true
        );
        insert inquiryData;
        inquiryData = new Inquiry_Data__c(
            Parent_Id__c = inquiryList.Id,
            Salesforce_Field__c = 'Mobile_Number_PE__c',
            JSON_Mapping_Name__c = 'Mobile',
            Field_Order__c = 3,
            IsActive__c = true
        );
        insert inquiryData;

        Map<String, Object> inquiryKeyMap = new Map<String, Object>();
        inquiryKeyMap.put('firstName', 'Somchai');
        inquiryKeyMap.put('lastName', 'Longdoo');
        
        InquiryManager inqMgr = new InquiryManager('Test Inquiry', new Map<String, Object>());
        List<Map<String, Object>> jsonResult = inqMgr.getResult();

        System.assertEquals('Somchai', jsonResult[0].get('Firstname') , 'Invalid firstname result');
        System.assertEquals('0987654321', jsonResult[0].get('Mobile') , 'Invalid mobile result');
    }

    @IsTest
    static void testInquiryWithOrMultiKey() {

        Inquiry_List__c inquiryList = new Inquiry_List__c(
            Inquiry_Name__c = 'Test Inquiry',
            Salesforce_Object__c = 'Account',
            Message_Type__c ='Test',
            Operation_Format__c = '{1} or {2}'
        );
        
        insert inquiryList;

        Inquiry_Key__c inquiryKey = new Inquiry_Key__c(
            Parent_Id__c = inquiryList.Id,
            Key_Field__c = 'First_name_PE__c',
            Key_Parameter__c = 'firstName'
        );
        insert inquiryKey;
        inquiryKey = new Inquiry_Key__c(
            Parent_Id__c = inquiryList.Id,
            Key_Field__c = 'Last_name_PE__c',
            Key_Parameter__c = 'lastName'
        );
        insert inquiryKey;

        Inquiry_Data__c inquiryData = new Inquiry_Data__c(
            Parent_Id__c = inquiryList.Id,
            Salesforce_Field__c = 'First_name_PE__c',
            JSON_Mapping_Name__c = 'Firstname',
            Field_Order__c = 1,
            IsActive__c = true
        );
        insert inquiryData;
        inquiryData = new Inquiry_Data__c(
            Parent_Id__c = inquiryList.Id,
            Salesforce_Field__c = 'Last_name_PE__c',
            JSON_Mapping_Name__c = 'Lastname',
            Field_Order__c = 2,
            IsActive__c = true
        );
        insert inquiryData;
        inquiryData = new Inquiry_Data__c(
            Parent_Id__c = inquiryList.Id,
            Salesforce_Field__c = 'Mobile_Number_PE__c',
            JSON_Mapping_Name__c = 'Mobile',
            Field_Order__c = 3,
            IsActive__c = true
        );
        insert inquiryData;

        Map<String, Object> inquiryKeyMap = new Map<String, Object>();
        inquiryKeyMap.put('firstName', 'Somchai');
        inquiryKeyMap.put('lastName', 'tester');
        
        InquiryManager inqMgr = new InquiryManager('Test Inquiry', new Map<String, Object>());
        List<Map<String, Object>> jsonResult = inqMgr.getResult();

        System.assertEquals('Somchai', jsonResult[0].get('Firstname') , 'Invalid firstname result');
        System.assertEquals('0987654321', jsonResult[0].get('Mobile') , 'Invalid mobile result');
    }

    @IsTest
    static void testInquiryNotFound() {

        Inquiry_List__c inquiryList = new Inquiry_List__c(
            Inquiry_Name__c = 'Test Inquiry',
            Salesforce_Object__c = 'Account',
            Message_Type__c ='Test'
        );
        
        insert inquiryList;

        Inquiry_Key__c inquiryKey = new Inquiry_Key__c(
            Parent_Id__c = inquiryList.Id,
            Key_Field__c = 'First_name_PE__c',
            Key_Parameter__c = 'firstName'
        );
        insert inquiryKey;

        Inquiry_Data__c inquiryData = new Inquiry_Data__c(
            Parent_Id__c = inquiryList.Id,
            Salesforce_Field__c = 'First_name_PE__c',
            JSON_Mapping_Name__c = 'Firstname',
            Field_Order__c = 1,
            IsActive__c = true
        );
        insert inquiryData;
        inquiryData = new Inquiry_Data__c(
            Parent_Id__c = inquiryList.Id,
            Salesforce_Field__c = 'Last_name_PE__c',
            JSON_Mapping_Name__c = 'Lastname',
            Field_Order__c = 2,
            IsActive__c = true
        );
        insert inquiryData;
        inquiryData = new Inquiry_Data__c(
            Parent_Id__c = inquiryList.Id,
            Salesforce_Field__c = 'Mobile_Number_PE__c',
            JSON_Mapping_Name__c = 'Mobile',
            Field_Order__c = 3,
            IsActive__c = true
        );
        insert inquiryData;

        Map<String, Object> inquiryKeyMap = new Map<String, Object>();
        inquiryKeyMap.put('firstName', 'invalid');
        
        InquiryManager inqMgr = new InquiryManager('Test Inquiry', new Map<String, Object>());
        List<Map<String, Object>> jsonResult = inqMgr.getResult();

        System.assertEquals(0, jsonResult.size() , 'Invalid firstname result');
        
    }
}