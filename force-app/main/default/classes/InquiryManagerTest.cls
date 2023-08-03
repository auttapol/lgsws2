@isTest
public with sharing class InquiryManagerTest {
    @testSetup static void setupTestData(){
        AppConfig__c app2 = new AppConfig__c(Name='runtrigger',Value__c='true');
        insert app2;
         
        Id retailProspectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Prospect').getRecordTypeId();
        Date mydate = Date.parse('04/07/1988');
        Account acc = new Account(
            Name = 'Somchai Longdoo',
            Email_Address_PE__c = 'ttb@tmbbank.com',
            First_name_PE__c = 'Somchai',
            Last_name_PE__c = 'Longdoo',
            ID_Type_PE__c = 'Citizen ID',
            ID_Number_PE__c = '4640865994576',
            Mobile_Number_PE__c = '0987654321',
            Primary_Address_Line_2_PE__c = '3000 Phahonyothin Rd. Khwang Chomphon',
            Primary_Address_Line_3_PE__c = 'Khet Chatuchak',
            Zip_Code_Primary_PE__c = '10900',
            Province_Primary_PE__c = 'Bangkok',
            RTL_Occupation__c = 'Student',
            RTL_Date_Of_Birth__c = mydate,
            RecordTypeId = retailProspectRecordTypeId
        );
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
        
        InquiryManager inqMgr = new InquiryManager('Test Inquiry', inquiryKeyMap);
        List<Map<String, Object>> jsonResult = inqMgr.getResult();
    }

    @IsTest
    static void testInquiryWithAndMultiKey() {
        String inquiryName = 'Test Inquiry AND Multi Key';
        Id inquiryListId = createInquiryData(inquiryName);

        List<Inquiry_Key__c> inquiryKeyList = new List<Inquiry_Key__c>();
        inquiryKeyList.add(new Inquiry_Key__c(
            Parent_Id__c = inquiryListId,
            Key_Field__c = 'Province_Primary_PE__c',
            Key_Parameter__c = 'province'
        ));
        inquiryKeyList.add(new Inquiry_Key__c(
            Parent_Id__c = inquiryListId,
            Key_Field__c = 'Zip_Code_Primary_PE__c',
            Key_Parameter__c = 'zipcode'
        ));
        insert inquiryKeyList;

        Map<String, Object> inquiryKeyMap = new Map<String, Object>();
        inquiryKeyMap.put('province', 'Bangkok');
        inquiryKeyMap.put('zipcode', '10900');
        
        InquiryManager inqMgr = new InquiryManager(inquiryName, inquiryKeyMap);
        List<Map<String, Object>> jsonResult = inqMgr.getResult();

        System.assertEquals(1, jsonResult.size() , 'Invalid result');
        System.assertEquals('Somchai', jsonResult[0].get('Firstname') , 'Invalid firstname result');
    }

    @IsTest
    static void testInquiryWithOrMultiKey() {

        String inquiryName = 'Test Inquiry OR Multi Key';
        Id inquiryListId = createInquiryData(inquiryName);
        Inquiry_List__c inquiryList = [select id,Operation_Format__c from Inquiry_List__c where id=:inquiryListId];
        inquiryList.Operation_Format__c = '{1} OR {2}';
        update inquiryList;

        List<Inquiry_Key__c> inquiryKeyList = new List<Inquiry_Key__c>();
        inquiryKeyList.add(new Inquiry_Key__c(
            Parent_Id__c = inquiryListId,
            Key_Field__c = 'Province_Primary_PE__c',
            Key_Parameter__c = 'province'
        ));
        inquiryKeyList.add(new Inquiry_Key__c(
            Parent_Id__c = inquiryListId,
            Key_Field__c = 'Zip_Code_Primary_PE__c',
            Key_Parameter__c = 'zipcode'
        ));
        insert inquiryKeyList;

        Map<String, Object> inquiryKeyMap = new Map<String, Object>();
        inquiryKeyMap.put('province', 'Bangkok');
        inquiryKeyMap.put('zipcode', '10230');
        
        InquiryManager inqMgr = new InquiryManager(inquiryName, inquiryKeyMap);
        List<Map<String, Object>> jsonResult = inqMgr.getResult();

        System.assertEquals(1, jsonResult.size() , 'Invalid result');
        System.assertEquals('Somchai', jsonResult[0].get('Firstname') , 'Invalid firstname result');
    }

    @IsTest
    static void testInquiryNotFound() {
        String inquiryName = 'Test Inquiry Not Found';
        Id inquiryListId = createInquiryData(inquiryName);
        Inquiry_Key__c inquiryKey = new Inquiry_Key__c(
            Parent_Id__c = inquiryListId,
            Key_Field__c = 'TMB_Customer_ID_PE__c',
            Key_Parameter__c = 'rmid'
        );
        insert inquiryKey;

        Map<String, Object> inquiryKeyMap = new Map<String, Object>();
        inquiryKeyMap.put('rmid', '12345');
        
        InquiryManager inqMgr = new InquiryManager(inquiryName, inquiryKeyMap);
        List<Map<String, Object>> jsonResult = inqMgr.getResult();

        System.assertEquals(0, jsonResult.size() , 'Invalid firstname result');
        
    }

    @IsTest
    static void testInquiryInvalidQueryName() {
        String inquiryName = '123';
        Map<String, Object> inquiryKeyMap = new Map<String, Object>();
        InquiryManager inqMgr = new InquiryManager(inquiryName, inquiryKeyMap);
        List<Map<String, Object>> jsonResult = inqMgr.getResult();

        System.assertEquals(null, jsonResult , 'Invalid result');
    }

    @IsTest
    static void testInquiryWithFullCondition() {
        String inquiryName = 'Test Inquiry Full Condition';
        Id inquiryListId = createInquiryData(inquiryName);
        Inquiry_List__c inquiryList = [select id,Operation_Format__c from Inquiry_List__c where id=:inquiryListId];
        inquiryList.Operation_Format__c = '({1} OR {2}) AND {3}';
        inquiryList.Order_By__c = 'RTL_Date_Of_Birth__c';
        inquiryList.Condition__c = 'Primary_Address_Line_3_PE__c = \'Khet Chatuchak\'';
        update inquiryList;

        List<Inquiry_Key__c> inquiryKeyList = new List<Inquiry_Key__c>();
        inquiryKeyList.add(new Inquiry_Key__c(
            Parent_Id__c = inquiryListId,
            Key_Field__c = 'Province_Primary_PE__c',
            Key_Parameter__c = 'province'
        ));
        inquiryKeyList.add(new Inquiry_Key__c(
            Parent_Id__c = inquiryListId,
            Key_Field__c = 'Zip_Code_Primary_PE__c',
            Key_Parameter__c = 'zipcode'
        ));
        inquiryKeyList.add(new Inquiry_Key__c(
            Parent_Id__c = inquiryListId,
            Key_Field__c = 'RTL_Occupation__c',
            Key_Parameter__c = 'occupation'
        ));
        insert inquiryKeyList;

        List<Inquiry_Data__c> inquiryDataList = new List<Inquiry_Data__c>();
        inquiryDataList.add(new Inquiry_Data__c(
                Parent_Id__c = inquiryListId,
                Salesforce_Field__c = 'createddate',
                JSON_Mapping_Name__c = 'CreateDate',
                Field_Order__c = 4,
                Date_Format__c = 'yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX',
                IsActive__c = true
        ));
        inquiryDataList.add(new Inquiry_Data__c(
                Parent_Id__c = inquiryListId,
                Salesforce_Field__c = 'TMB_Customer_ID_PE__c',
                JSON_Mapping_Name__c = 'RMID',
                Field_Order__c = 5,
                Empty_Value__c = 'Empty Value',
                IsActive__c = true
        ));
        inquiryDataList.add(new Inquiry_Data__c(
                Parent_Id__c = inquiryListId,
                Salesforce_Field__c = 'RTL_Gender__c',
                JSON_Mapping_Name__c = 'Gender',
                Field_Order__c = 6,
                Fixed_Value__c = 'Male',
                IsActive__c = true
        ));
        inquiryDataList.add(new Inquiry_Data__c(
                Parent_Id__c = inquiryListId,
                Salesforce_Field__c = 'CreatedBy.name',
                JSON_Mapping_Name__c = 'CreateBy',
                Field_Order__c = 7,
                IsActive__c = true
        ));
        inquiryDataList.add(new Inquiry_Data__c(
                Parent_Id__c = inquiryListId,
                Salesforce_Field__c = 'RTL_Date_Of_Birth__c',
                JSON_Mapping_Name__c = 'Birthdate',
                Field_Order__c = 8,
                Date_Format__c = 'yyyy-MM-dd',
                IsActive__c = true
        ));
        insert inquiryDataList;

        Map<String, Object> inquiryKeyMap = new Map<String, Object>();
        inquiryKeyMap.put('province', 'Bangkok');
        inquiryKeyMap.put('zipcode', '10230');
        inquiryKeyMap.put('occupation', 'Student');
        
        InquiryManager inqMgr = new InquiryManager(inquiryName, inquiryKeyMap);
        List<Map<String, Object>> jsonResult = inqMgr.getResult();

        System.assertEquals(1, jsonResult.size() , 'Invalid firstname result');
        System.assertEquals('Empty Value', jsonResult[0].get('RMID') , 'Invalid RMID result');
        System.assertEquals('Male', jsonResult[0].get('Gender') , 'Invalid gender result');
    }
    
    private static Id createInquiryData(String name) {
        Inquiry_List__c inquiryList = new Inquiry_List__c(
            Inquiry_Name__c = name,
            Salesforce_Object__c = 'Account',
            Message_Type__c ='Test'
        );
        
        insert inquiryList;

        List<Inquiry_Data__c> inquiryDataList = new List<Inquiry_Data__c>();
        inquiryDataList.add(new Inquiry_Data__c(
            Parent_Id__c = inquiryList.Id,
            Salesforce_Field__c = 'First_name_PE__c',
            JSON_Mapping_Name__c = 'Firstname',
            Field_Order__c = 1,
            IsActive__c = true
        ));
        inquiryDataList.add(new Inquiry_Data__c(
            Parent_Id__c = inquiryList.Id,
            Salesforce_Field__c = 'Last_name_PE__c',
            JSON_Mapping_Name__c = 'Lastname',
            Field_Order__c = 2,
            IsActive__c = true
        ));
        inquiryDataList.add(new Inquiry_Data__c(
            Parent_Id__c = inquiryList.Id,
            Salesforce_Field__c = 'Mobile_Number_PE__c',
            JSON_Mapping_Name__c = 'Mobile',
            Field_Order__c = 3,
            IsActive__c = true
        ));
        inquiryDataList.add(new Inquiry_Data__c(
            Parent_Id__c = inquiryList.Id,
            Salesforce_Field__c = 'Email_Address_PE__c',
            JSON_Mapping_Name__c = 'Email',
            Field_Order__c = 3,
            IsActive__c = true
        ));
        insert inquiryDataList;

        return inquiryList.Id;
    }
}