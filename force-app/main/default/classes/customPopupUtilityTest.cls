@isTest
public with sharing class customPopupUtilityTest {
    
    @isTest static void testPopup(){
        String dataJson = '{'+
            '"Call_ID__c": "9999999996",'+
            '"Employee_ID__c": "55555",'+
            '"Extension_Number__c": "7841",'+
            '"TMB_Cust_ID__c": "011100000000000000000000701121",'+
            '"Phone_Number__c": "104000159",'+
            '"Xfer__c": "TH Account",'+
            '"Verification_Status__c" : "02",'+
            '"Verification_Type__c" : "TMB ID",'+
            '"Verification_Result__c" : "None",'+
            '"Verification_Action__c" : "ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID,",'+
            '"Verification_Date_Time__c" : "2563-04-07T07:13:48.598Z",'+
            '"Fail_Reason__c" : "Not Verify"}';

        System.debug(JSON.serialize(dataJson));
        System.debug(JSON.serializePretty(dataJson));

        ContactCenter_Handler__c cch = new ContactCenter_Handler__c();
        cch.Name = 'test';
        cch.Action__c = 'ccpin';
        cch.Field__c = 'Phone_Number__c,Verification_Result__c,Employee_ID__c,Fail_Reason__c,Call_ID__c,Verification_Date_Time__c,Xfer__c,Verification_Type__c,Verification_Status__c,TMB_Cust_ID__c,Customer__r.TMB_Customer_ID_PE__c,Extension_Number__c,Call_ID__c,Customer__c';
        cch.IsActive__c = true;
        cch.ObjectOperation__c = 'Verification_History__c';
        cch.ObjectRedirect__c = 'Account';
        cch.FieldForTab__c = 'Customer__c';
        cch.RMIDSearchField__c = 'TMB_Cust_ID__c';
        cch.PhoneSearchField__c = 'Phone_Number__c';
        cch.url__c = '{Customer__c}?verf_hist_id={Id}';
        cch.ResultField__c = 'Id,Customer__c,Customer__r.Name,Customer__r.TMB_Customer_ID_PE__c,Customer__r.Core_Banking_Suggested_Segment__c';
        cch.Field_2__c = 'Verification_Action__c';

        insert cch;

        AppConfig__c runtrigger = new AppConfig__c();
        runtrigger.Name = 'runtrigger';
        runtrigger.Value__c = 'false';

        insert runtrigger;

        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.TMB_Customer_ID_PE__c = '011100000000000000000000701121';
        testAcc.Mobile_Number_PE__c = '023857143';

        insert testAcc;

        System.debug(customPopupUtilityController.service_contactcenterLightning('ccpin', dataJson, '00T1s000002RBgsEAG', 'test'));
    }

    @isTest static void testGetValues(){
        String dataJson = '{'+
        '"Call_ID__c": "9999999996",'+
        '"Employee_ID__c": "55555",'+
        '"Extension_Number__c": "7841",'+
        '"TMB_Cust_ID__c": "",'+
        '"Phone_Number__c": "104000159",'+
        '"Xfer__c": "TH Account",'+
        '"Verification_Status__c" : "02",'+
        '"Verification_Type__c" : "TMB ID",'+
        '"Verification_Result__c" : "None",'+
        '"Verification_Action__c" : "ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID,",'+
        '"Verification_Date_Time__c" : "2563-04-07T07:13:48.598Z",'+
        '"Fail_Reason__c" : "Not Verify"}';

        System.debug(JSON.serialize(dataJson));
        System.debug(JSON.serializePretty(dataJson));

        ContactCenter_Handler__c cch = new ContactCenter_Handler__c();
        cch.Name = 'test';
        cch.Action__c = 'ccpin';
        cch.Field__c = 'Phone_Number__c,Verification_Result__c,Employee_ID__c,Fail_Reason__c,Call_ID__c,Verification_Date_Time__c,Xfer__c,Verification_Type__c,Verification_Status__c,TMB_Cust_ID__c,Customer__r.TMB_Customer_ID_PE__c,Extension_Number__c,Call_ID__c,Customer__c';
        cch.IsActive__c = true;
        cch.ObjectOperation__c = 'Verification_History__c';
        cch.ObjectRedirect__c = 'Account';
        cch.FieldForTab__c = 'Customer__c';
        cch.RMIDSearchField__c = 'TMB_Cust_ID__c';
        cch.PhoneSearchField__c = 'Phone_Number__c';
        cch.url__c = '{Customer__c}?verf_hist_id={Id}';
        cch.ResultField__c = 'Id,Customer__c,Customer__r.Name,Customer__r.TMB_Customer_ID_PE__c,Customer__r.Core_Banking_Suggested_Segment__c';
        cch.Field_2__c = 'Verification_Action__c';

        insert cch;

        AppConfig__c runtrigger = new AppConfig__c();
        runtrigger.Name = 'runtrigger';
        runtrigger.Value__c = 'false';

        insert runtrigger;

        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.TMB_Customer_ID_PE__c = '011100000000000000000000701121';
        testAcc.Mobile_Number_PE__c = '104000159';

        insert testAcc;

        Contact testContact = new Contact();
        testContact.AccountId = testAcc.Id;
        testContact.Phone = '104000159';
        testContact.HomePhone = '104000159';
        testContact.MobilePhone = '104000159';
        testContact.LastName = 'Test';
        testContact.FirstName = 'Contact';

        insert testContact;

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = testContact.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        System.debug('Test Get Contact');
        System.debug([SELECT Id FROM Contact]);
        System.debug([FIND '104000159' IN PHONE FIELDS RETURNING Contact (Id,Name,AccountId,HomePhone,Phone,MobilePhone)]);

        System.debug(customPopupUtilityController.service_contactcenterLightning('ccpin', dataJson, '00T1s000002RBgsEAG', 'test'));

    }

    @isTest static void testGetValuesNoRmid(){
        String dataJson = '{'+
        '"Call_ID__c": "9999999996",'+
        '"Employee_ID__c": "55555",'+
        '"Extension_Number__c": "7841",'+
        '"TMB_Cust_ID__c": "",'+
        '"Phone_Number__c": "104000159",'+
        '"Xfer__c": "TH Account",'+
        '"Verification_Status__c" : "02",'+
        '"Verification_Type__c" : "TMB ID",'+
        '"Verification_Result__c" : "None",'+
        '"Verification_Action__c" : "ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID,",'+
        '"Verification_Date_Time__c" : "2563-04-07T07:13:48.598Z",'+
        '"Fail_Reason__c" : "Not Verify"}';

        System.debug(JSON.serialize(dataJson));
        System.debug(JSON.serializePretty(dataJson));

        ContactCenter_Handler__c cch = new ContactCenter_Handler__c();
        cch.Name = 'test';
        cch.Action__c = 'ccpin';
        cch.Field__c = 'Phone_Number__c,Verification_Result__c,Employee_ID__c,Fail_Reason__c,Call_ID__c,Verification_Date_Time__c,Xfer__c,Verification_Type__c,Verification_Status__c,TMB_Cust_ID__c,Customer__r.TMB_Customer_ID_PE__c,Extension_Number__c,Call_ID__c,Customer__c';
        cch.IsActive__c = true;
        cch.ObjectOperation__c = 'Verification_History__c';
        cch.ObjectRedirect__c = 'Account';
        cch.FieldForTab__c = 'Customer__c';
        cch.RMIDSearchField__c = 'TMB_Cust_ID__c';
        cch.PhoneSearchField__c = 'Phone_Number__c';
        cch.url__c = '{Customer__c}?verf_hist_id={Id}';
        cch.ResultField__c = 'Id,Customer__c,Customer__r.Name,Customer__r.TMB_Customer_ID_PE__c,Customer__r.Core_Banking_Suggested_Segment__c';
        cch.Field_2__c = 'Verification_Action__c';

        insert cch;

        AppConfig__c runtrigger = new AppConfig__c();
        runtrigger.Name = 'runtrigger';
        runtrigger.Value__c = 'false';

        insert runtrigger;

        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.TMB_Customer_ID_PE__c = '';
        testAcc.Mobile_Number_PE__c = '104000159';

        insert testAcc;

        Contact testContact = new Contact();
        testContact.AccountId = testAcc.Id;
        testContact.Phone = '104000159';
        testContact.HomePhone = '104000159';
        testContact.MobilePhone = '104000159';
        testContact.LastName = 'Test';
        testContact.FirstName = 'Contact';

        insert testContact;

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = testContact.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        System.debug('Test Get Contact');
        System.debug([SELECT Id FROM Contact]);
        System.debug([FIND '104000159' IN PHONE FIELDS RETURNING Contact (Id,Name,AccountId,HomePhone,Phone,MobilePhone)]);

        System.debug(customPopupUtilityController.service_contactcenterLightning('ccpin', dataJson, '00T1s000002RBgsEAG', 'test'));

    }

    @isTest static void testRmidNotFound(){
        String dataJson = '{'+
            '"Call_ID__c": "9999999996",'+
            '"Employee_ID__c": "55555",'+
            '"Extension_Number__c": "7841",'+
            '"TMB_Cust_ID__c": "011100000000000000000000701120",'+
            '"Phone_Number__c": "104000159",'+
            '"Xfer__c": "TH Account",'+
            '"Verification_Status__c" : "02",'+
            '"Verification_Type__c" : "TMB ID",'+
            '"Verification_Result__c" : "None",'+
            '"Verification_Action__c" : "ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID,",'+
            '"Verification_Date_Time__c" : "2563-04-07T07:13:48.598Z",'+
            '"Fail_Reason__c" : "Not Verify"}';

        System.debug(JSON.serialize(dataJson));
        System.debug(JSON.serializePretty(dataJson));

        ContactCenter_Handler__c cch = new ContactCenter_Handler__c();
        cch.Name = 'test';
        cch.Action__c = 'ccpin';
        cch.Field__c = 'Phone_Number__c,Verification_Result__c,Employee_ID__c,Fail_Reason__c,Call_ID__c,Verification_Date_Time__c,Xfer__c,Verification_Type__c,Verification_Status__c,TMB_Cust_ID__c,Customer__r.TMB_Customer_ID_PE__c,Extension_Number__c,Call_ID__c,Customer__c';
        cch.IsActive__c = true;
        cch.ObjectOperation__c = 'Verification_History__c';
        cch.ObjectRedirect__c = 'Account';
        cch.FieldForTab__c = 'Customer__c';
        cch.RMIDSearchField__c = 'TMB_Cust_ID__c';
        cch.PhoneSearchField__c = 'Phone_Number__c';
        cch.url__c = '{Customer__c}?verf_hist_id={Id}';
        cch.ResultField__c = 'Id,Customer__c,Customer__r.Name,Customer__r.TMB_Customer_ID_PE__c,Customer__r.Core_Banking_Suggested_Segment__c';
        cch.Field_2__c = 'Verification_Action__c';

        insert cch;

        AppConfig__c runtrigger = new AppConfig__c();
        runtrigger.Name = 'runtrigger';
        runtrigger.Value__c = 'false';

        insert runtrigger;

        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.TMB_Customer_ID_PE__c = '011100000000000000000000701121';
        testAcc.Mobile_Number_PE__c = '023857143';

        insert testAcc;

        System.debug(customPopupUtilityController.service_contactcenterLightning('ccpin', dataJson, '00T1s000002RBgsEAG', 'test'));
    }


    @isTest static void testContactnoAccount(){
        String dataJson = '{'+
            '"Call_ID__c": "9999999996",'+
            '"Employee_ID__c": "55555",'+
            '"Extension_Number__c": "7841",'+
            '"TMB_Cust_ID__c": "",'+
            '"Phone_Number__c": "104000159",'+
            '"Xfer__c": "TH Account",'+
            '"Verification_Status__c" : "02",'+
            '"Verification_Type__c" : "TMB ID",'+
            '"Verification_Result__c" : "None",'+
            '"Verification_Action__c" : "ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID,",'+
            '"Verification_Date_Time__c" : "2563-04-07T07:13:48.598Z",'+
            '"Fail_Reason__c" : "Not Verify"}';

        System.debug(JSON.serialize(dataJson));
        System.debug(JSON.serializePretty(dataJson));

        ContactCenter_Handler__c cch = new ContactCenter_Handler__c();
        cch.Name = 'test';
        cch.Action__c = 'ccpin';
        cch.Field__c = 'Phone_Number__c,Verification_Result__c,Employee_ID__c,Fail_Reason__c,Call_ID__c,Verification_Date_Time__c,Xfer__c,Verification_Type__c,Verification_Status__c,TMB_Cust_ID__c,Customer__r.TMB_Customer_ID_PE__c,Extension_Number__c,Call_ID__c,Customer__c';
        cch.IsActive__c = true;
        cch.ObjectOperation__c = 'Verification_History__c';
        cch.ObjectRedirect__c = 'Account';
        cch.FieldForTab__c = 'Customer__c';
        cch.RMIDSearchField__c = 'TMB_Cust_ID__c';
        cch.PhoneSearchField__c = 'Phone_Number__c';
        cch.url__c = '{Customer__c}?verf_hist_id={Id}';
        cch.ResultField__c = 'Id,Customer__c,Customer__r.Name,Customer__r.TMB_Customer_ID_PE__c,Customer__r.Core_Banking_Suggested_Segment__c';
        cch.Field_2__c = 'Verification_Action__c';

        insert cch;

        AppConfig__c runtrigger = new AppConfig__c();
        runtrigger.Name = 'runtrigger';
        runtrigger.Value__c = 'false';

        insert runtrigger;

        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.TMB_Customer_ID_PE__c = '';
        testAcc.Mobile_Number_PE__c = '023857143';

        insert testAcc;

        Contact testContact = new Contact();
        testContact.Phone = '104000159';
        testContact.HomePhone = '104000159';
        testContact.MobilePhone = '104000159';
        testContact.LastName = 'Test';
        testContact.FirstName = 'Contact';

        insert testContact;

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = testContact.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        System.debug(customPopupUtilityController.service_contactcenterLightning('ccpin', dataJson, '00T1s000002RBgsEAG', 'test'));
    }


    @isTest static void testMultipleContact(){
        String dataJson = '{'+
            '"Call_ID__c": "9999999996",'+
            '"Employee_ID__c": "55555",'+
            '"Extension_Number__c": "7841",'+
            '"TMB_Cust_ID__c": "",'+
            '"Phone_Number__c": "104000159",'+
            '"Xfer__c": "TH Account",'+
            '"Verification_Status__c" : "02",'+
            '"Verification_Type__c" : "TMB ID",'+
            '"Verification_Result__c" : "None",'+
            '"Verification_Action__c" : "ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID,",'+
            '"Verification_Date_Time__c" : "2563-04-07T07:13:48.598Z",'+
            '"Fail_Reason__c" : "Not Verify"}';

        System.debug(JSON.serialize(dataJson));
        System.debug(JSON.serializePretty(dataJson));

        ContactCenter_Handler__c cch = new ContactCenter_Handler__c();
        cch.Name = 'test';
        cch.Action__c = 'ccpin';
        cch.Field__c = 'Phone_Number__c,Verification_Result__c,Employee_ID__c,Fail_Reason__c,Call_ID__c,Verification_Date_Time__c,Xfer__c,Verification_Type__c,Verification_Status__c,TMB_Cust_ID__c,Customer__r.TMB_Customer_ID_PE__c,Extension_Number__c,Call_ID__c,Customer__c';
        cch.IsActive__c = true;
        cch.ObjectOperation__c = 'Verification_History__c';
        cch.ObjectRedirect__c = 'Account';
        cch.FieldForTab__c = 'Customer__c';
        cch.RMIDSearchField__c = 'TMB_Cust_ID__c';
        cch.PhoneSearchField__c = 'Phone_Number__c';
        cch.url__c = '{Customer__c}?verf_hist_id={Id}';
        cch.ResultField__c = 'Id,Customer__c,Customer__r.Name,Customer__r.TMB_Customer_ID_PE__c,Customer__r.Core_Banking_Suggested_Segment__c';
        cch.Field_2__c = 'Verification_Action__c';

        insert cch;

        AppConfig__c runtrigger = new AppConfig__c();
        runtrigger.Name = 'runtrigger';
        runtrigger.Value__c = 'false';

        insert runtrigger;

        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.TMB_Customer_ID_PE__c = '';
        testAcc.Mobile_Number_PE__c = '023857143';

        insert testAcc;

        Contact testContact = new Contact();
        testContact.AccountId = testAcc.Id;
        testContact.Phone = '104000159';
        testContact.HomePhone = '104000159';
        testContact.MobilePhone = '104000159';
        testContact.LastName = 'Test';
        testContact.FirstName = 'Contact';

        insert testContact;

        Contact testContact2 = new Contact();
        testContact2.AccountId = testAcc.Id;
        testContact2.Phone = '104000159';
        testContact2.HomePhone = '104000159';
        testContact2.MobilePhone = '104000159';
        testContact2.LastName = 'Test2';
        testContact2.FirstName = 'Contact';

        insert testContact2;

        Id [] fixedSearchResults= new Id[2];
        fixedSearchResults[0] = testContact.Id;
        fixedSearchResults[1] = testContact2.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        System.debug(customPopupUtilityController.service_contactcenterLightning('ccpin', dataJson, '00T1s000002RBgsEAG', 'test'));
    }


    @isTest static void testQueryAccount(){
        String dataJson = '{'+
            '"Call_ID__c": "9999999996",'+
            '"Employee_ID__c": "55555",'+
            '"Extension_Number__c": "7841",'+
            '"TMB_Cust_ID__c": "",'+
            '"Phone_Number__c": "104000159",'+
            '"Xfer__c": "TH Account",'+
            '"Verification_Status__c" : "02",'+
            '"Verification_Type__c" : "TMB ID",'+
            '"Verification_Result__c" : "None",'+
            '"Verification_Action__c" : "ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID,",'+
            '"Verification_Date_Time__c" : "2563-04-07T07:13:48.598Z",'+
            '"Fail_Reason__c" : "Not Verify"}';

        System.debug(JSON.serialize(dataJson));
        System.debug(JSON.serializePretty(dataJson));

        ContactCenter_Handler__c cch = new ContactCenter_Handler__c();
        cch.Name = 'test';
        cch.Action__c = 'ccpin';
        cch.Field__c = 'Phone_Number__c,Verification_Result__c,Employee_ID__c,Fail_Reason__c,Call_ID__c,Verification_Date_Time__c,Xfer__c,Verification_Type__c,Verification_Status__c,TMB_Cust_ID__c,Customer__r.TMB_Customer_ID_PE__c,Extension_Number__c,Call_ID__c,Customer__c';
        cch.IsActive__c = true;
        cch.ObjectOperation__c = 'Verification_History__c';
        cch.ObjectRedirect__c = 'Account';
        cch.FieldForTab__c = 'Customer__c';
        cch.RMIDSearchField__c = 'TMB_Cust_ID__c';
        cch.PhoneSearchField__c = 'Phone_Number__c';
        cch.url__c = '{Customer__c}?verf_hist_id={Id}';
        cch.ResultField__c = 'Id,Customer__c,Customer__r.Name,Customer__r.TMB_Customer_ID_PE__c,Customer__r.Core_Banking_Suggested_Segment__c';
        cch.Field_2__c = 'Verification_Action__c';

        insert cch;

        AppConfig__c runtrigger = new AppConfig__c();
        runtrigger.Name = 'runtrigger';
        runtrigger.Value__c = 'false';

        insert runtrigger;

        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.TMB_Customer_ID_PE__c = '';
        testAcc.Mobile_Number_PE__c = '104000159';

        insert testAcc;

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = testAcc.Id;
        // fixedSearchResults[1] = testContact2.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        System.debug(customPopupUtilityController.service_contactcenterLightning('ccpin', dataJson, '00T1s000002RBgsEAG', 'test'));
    }

    @isTest static void testQueryAccountWithRmid(){
        String dataJson = '{'+
            '"Call_ID__c": "9999999996",'+
            '"Employee_ID__c": "55555",'+
            '"Extension_Number__c": "7841",'+
            '"TMB_Cust_ID__c": "",'+
            '"Phone_Number__c": "104000159",'+
            '"Xfer__c": "TH Account",'+
            '"Verification_Status__c" : "02",'+
            '"Verification_Type__c" : "TMB ID",'+
            '"Verification_Result__c" : "None",'+
            '"Verification_Action__c" : "ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID,",'+
            '"Verification_Date_Time__c" : "2563-04-07T07:13:48.598Z",'+
            '"Fail_Reason__c" : "Not Verify"}';

        System.debug(JSON.serialize(dataJson));
        System.debug(JSON.serializePretty(dataJson));

        ContactCenter_Handler__c cch = new ContactCenter_Handler__c();
        cch.Name = 'test';
        cch.Action__c = 'ccpin';
        cch.Field__c = 'Phone_Number__c,Verification_Result__c,Employee_ID__c,Fail_Reason__c,Call_ID__c,Verification_Date_Time__c,Xfer__c,Verification_Type__c,Verification_Status__c,TMB_Cust_ID__c,Customer__r.TMB_Customer_ID_PE__c,Extension_Number__c,Call_ID__c,Customer__c';
        cch.IsActive__c = true;
        cch.ObjectOperation__c = 'Verification_History__c';
        cch.ObjectRedirect__c = 'Account';
        cch.FieldForTab__c = 'Customer__c';
        cch.RMIDSearchField__c = 'TMB_Cust_ID__c';
        cch.PhoneSearchField__c = 'Phone_Number__c';
        cch.url__c = '{Customer__c}?verf_hist_id={Id}';
        cch.ResultField__c = 'Id,Customer__c,Customer__r.Name,Customer__r.TMB_Customer_ID_PE__c,Customer__r.Core_Banking_Suggested_Segment__c';
        cch.Field_2__c = 'Verification_Action__c';

        insert cch;

        AppConfig__c runtrigger = new AppConfig__c();
        runtrigger.Name = 'runtrigger';
        runtrigger.Value__c = 'false';

        insert runtrigger;

        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.TMB_Customer_ID_PE__c = '011100000000000000000000701120';
        testAcc.Mobile_Number_PE__c = '104000159';

        insert testAcc;

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = testAcc.Id;
        // fixedSearchResults[1] = testContact2.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        System.debug(customPopupUtilityController.service_contactcenterLightning('ccpin', dataJson, '00T1s000002RBgsEAG', 'test'));
    }

    @isTest static void testQueryMultiAccount(){
        String dataJson = '{'+
            '"Call_ID__c": "9999999996",'+
            '"Employee_ID__c": "55555",'+
            '"Extension_Number__c": "7841",'+
            '"TMB_Cust_ID__c": "",'+
            '"Phone_Number__c": "104000159",'+
            '"Xfer__c": "TH Account",'+
            '"Verification_Status__c" : "02",'+
            '"Verification_Type__c" : "TMB ID",'+
            '"Verification_Result__c" : "None",'+
            '"Verification_Action__c" : "ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID,",'+
            '"Verification_Date_Time__c" : "2563-04-07T07:13:48.598Z",'+
            '"Fail_Reason__c" : "Not Verify"}';

        System.debug(JSON.serialize(dataJson));
        System.debug(JSON.serializePretty(dataJson));

        ContactCenter_Handler__c cch = new ContactCenter_Handler__c();
        cch.Name = 'test';
        cch.Action__c = 'ccpin';
        cch.Field__c = 'Phone_Number__c,Verification_Result__c,Employee_ID__c,Fail_Reason__c,Call_ID__c,Verification_Date_Time__c,Xfer__c,Verification_Type__c,Verification_Status__c,TMB_Cust_ID__c,Customer__r.TMB_Customer_ID_PE__c,Extension_Number__c,Call_ID__c,Customer__c';
        cch.IsActive__c = true;
        cch.ObjectOperation__c = 'Verification_History__c';
        cch.ObjectRedirect__c = 'Account';
        cch.FieldForTab__c = 'Customer__c';
        cch.RMIDSearchField__c = 'TMB_Cust_ID__c';
        cch.PhoneSearchField__c = 'Phone_Number__c';
        cch.url__c = '{Customer__c}?verf_hist_id={Id}';
        cch.ResultField__c = 'Id,Customer__c,Customer__r.Name,Customer__r.TMB_Customer_ID_PE__c,Customer__r.Core_Banking_Suggested_Segment__c';
        cch.Field_2__c = 'Verification_Action__c';

        insert cch;

        AppConfig__c runtrigger = new AppConfig__c();
        runtrigger.Name = 'runtrigger';
        runtrigger.Value__c = 'false';

        insert runtrigger;

        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.TMB_Customer_ID_PE__c = '';
        testAcc.Mobile_Number_PE__c = '104000159';

        insert testAcc;

        Account testAcc2 = new Account();
        testAcc2.Name = 'Test Account2';
        testAcc2.TMB_Customer_ID_PE__c = '';
        testAcc2.Mobile_Number_PE__c = '104000159';

        insert testAcc2;

        Id [] fixedSearchResults= new Id[2];
        fixedSearchResults[0] = testAcc.Id;
        fixedSearchResults[1] = testAcc2.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        System.debug(customPopupUtilityController.service_contactcenterLightning('ccpin', dataJson, '00T1s000002RBgsEAG', 'test'));
    }

    @isTest static void testQueryLead(){
        String dataJson = '{'+
            '"Call_ID__c": "9999999996",'+
            '"Employee_ID__c": "55555",'+
            '"Extension_Number__c": "7841",'+
            '"TMB_Cust_ID__c": "",'+
            '"Phone_Number__c": "104000159",'+
            '"Xfer__c": "TH Account",'+
            '"Verification_Status__c" : "02",'+
            '"Verification_Type__c" : "TMB ID",'+
            '"Verification_Result__c" : "None",'+
            '"Verification_Action__c" : "ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID,",'+
            '"Verification_Date_Time__c" : "2563-04-07T07:13:48.598Z",'+
            '"Fail_Reason__c" : "Not Verify"}';

        System.debug(JSON.serialize(dataJson));
        System.debug(JSON.serializePretty(dataJson));

        ContactCenter_Handler__c cch = new ContactCenter_Handler__c();
        cch.Name = 'test';
        cch.Action__c = 'ccpin';
        cch.Field__c = 'Phone_Number__c,Verification_Result__c,Employee_ID__c,Fail_Reason__c,Call_ID__c,Verification_Date_Time__c,Xfer__c,Verification_Type__c,Verification_Status__c,TMB_Cust_ID__c,Customer__r.TMB_Customer_ID_PE__c,Extension_Number__c,Call_ID__c,Customer__c';
        cch.IsActive__c = true;
        cch.ObjectOperation__c = 'Verification_History__c';
        cch.ObjectRedirect__c = 'Account';
        cch.FieldForTab__c = 'Customer__c';
        cch.RMIDSearchField__c = 'TMB_Cust_ID__c';
        cch.PhoneSearchField__c = 'Phone_Number__c';
        cch.url__c = '{Customer__c}?verf_hist_id={Id}';
        cch.ResultField__c = 'Id,Customer__c,Customer__r.Name,Customer__r.TMB_Customer_ID_PE__c,Customer__r.Core_Banking_Suggested_Segment__c';
        cch.Field_2__c = 'Verification_Action__c';

        insert cch;

        AppConfig__c runtrigger = new AppConfig__c();
        runtrigger.Name = 'runtrigger';
        runtrigger.Value__c = 'false';

        insert runtrigger;

        Lead testLead = new Lead();
        testLead.LastName = 'Test';
        testLead.Company = 'Test Company';

        insert testLead;

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = testLead.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        System.debug(customPopupUtilityController.service_contactcenterLightning('ccpin', dataJson, '00T1s000002RBgsEAG', 'test'));
    }

    @isTest static void testQueryMultiLead(){
        String dataJson = '{'+
            '"Call_ID__c": "9999999996",'+
            '"Employee_ID__c": "55555",'+
            '"Extension_Number__c": "7841",'+
            '"TMB_Cust_ID__c": "",'+
            '"Phone_Number__c": "104000159",'+
            '"Xfer__c": "TH Account",'+
            '"Verification_Status__c" : "02",'+
            '"Verification_Type__c" : "TMB ID",'+
            '"Verification_Result__c" : "None",'+
            '"Verification_Action__c" : "ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID,",'+
            '"Verification_Date_Time__c" : "2563-04-07T07:13:48.598Z",'+
            '"Fail_Reason__c" : "Not Verify"}';

        System.debug(JSON.serialize(dataJson));
        System.debug(JSON.serializePretty(dataJson));

        ContactCenter_Handler__c cch = new ContactCenter_Handler__c();
        cch.Name = 'test';
        cch.Action__c = 'ccpin';
        cch.Field__c = 'Phone_Number__c,Verification_Result__c,Employee_ID__c,Fail_Reason__c,Call_ID__c,Verification_Date_Time__c,Xfer__c,Verification_Type__c,Verification_Status__c,TMB_Cust_ID__c,Customer__r.TMB_Customer_ID_PE__c,Extension_Number__c,Call_ID__c,Customer__c';
        cch.IsActive__c = true;
        cch.ObjectOperation__c = 'Verification_History__c';
        cch.ObjectRedirect__c = 'Account';
        cch.FieldForTab__c = 'Customer__c';
        cch.RMIDSearchField__c = 'TMB_Cust_ID__c';
        cch.PhoneSearchField__c = 'Phone_Number__c';
        cch.url__c = '{Customer__c}?verf_hist_id={Id}';
        cch.ResultField__c = 'Id,Customer__c,Customer__r.Name,Customer__r.TMB_Customer_ID_PE__c,Customer__r.Core_Banking_Suggested_Segment__c';
        cch.Field_2__c = 'Verification_Action__c';

        insert cch;

        AppConfig__c runtrigger = new AppConfig__c();
        runtrigger.Name = 'runtrigger';
        runtrigger.Value__c = 'false';

        insert runtrigger;

        Lead testLead = new Lead();
        testLead.LastName = 'Test';
        testLead.Phone = '104000159';
        testLead.Company = 'Test Company';

        insert testLead;

        Lead testLead2 = new Lead();
        testLead2.LastName = 'Test2';
        testLead2.Phone = '104000159';
        testLead2.Company = 'Test Company';

        insert testLead2;

        Id [] fixedSearchResults= new Id[2];
        fixedSearchResults[0] = testLead.Id;
        fixedSearchResults[1] = testLead2.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        System.debug(customPopupUtilityController.service_contactcenterLightning('ccpin', dataJson, '00T1s000002RBgsEAG', 'test'));
    }

    @isTest static void testNoResult(){
        String dataJson = '{'+
            '"Call_ID__c": "9999999996",'+
            '"Employee_ID__c": "55555",'+
            '"Extension_Number__c": "7841",'+
            '"TMB_Cust_ID__c": "",'+
            '"Phone_Number__c": "104000159",'+
            '"Xfer__c": "TH Account",'+
            '"Verification_Status__c" : "02",'+
            '"Verification_Type__c" : "TMB ID",'+
            '"Verification_Result__c" : "None",'+
            '"Verification_Action__c" : "ต้องยืนยันตัวตนลูกค้าอีกครั้งด้วย TMB ID,",'+
            '"Verification_Date_Time__c" : "2563-04-07T07:13:48.598Z",'+
            '"Fail_Reason__c" : "Not Verify"}';

        System.debug(JSON.serialize(dataJson));
        System.debug(JSON.serializePretty(dataJson));

        ContactCenter_Handler__c cch = new ContactCenter_Handler__c();
        cch.Name = 'test';
        cch.Action__c = 'ccpin';
        cch.Field__c = 'Phone_Number__c,Verification_Result__c,Employee_ID__c,Fail_Reason__c,Call_ID__c,Verification_Date_Time__c,Xfer__c,Verification_Type__c,Verification_Status__c,TMB_Cust_ID__c,Customer__r.TMB_Customer_ID_PE__c,Extension_Number__c,Call_ID__c,Customer__c';
        cch.IsActive__c = true;
        cch.ObjectOperation__c = 'Verification_History__c';
        cch.ObjectRedirect__c = 'Account';
        cch.FieldForTab__c = 'Customer__c';
        cch.RMIDSearchField__c = 'TMB_Cust_ID__c';
        cch.PhoneSearchField__c = 'Phone_Number__c';
        cch.url__c = '{Customer__c}?verf_hist_id={Id}';
        cch.ResultField__c = 'Id,Customer__c,Customer__r.Name,Customer__r.TMB_Customer_ID_PE__c,Customer__r.Core_Banking_Suggested_Segment__c';
        cch.Field_2__c = 'Verification_Action__c';

        insert cch;

        AppConfig__c runtrigger = new AppConfig__c();
        runtrigger.Name = 'runtrigger';
        runtrigger.Value__c = 'false';

        insert runtrigger;

        // Id [] fixedSearchResults= new Id[2];
        // fixedSearchResults[0] = testLead.Id;
        // fixedSearchResults[1] = testLead2.Id;
        // Test.setFixedSearchResults(fixedSearchResults);

        System.debug(customPopupUtilityController.service_contactcenterLightning('ccpin', dataJson, '00T1s000002RBgsEAG', 'test'));
    }

    @isTest static void testGetAccountByTask(){

        AppConfig__c runtrigger = new AppConfig__c();
        runtrigger.Name = 'runtrigger';
        runtrigger.Value__c = 'false';

        insert runtrigger;

        Account testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.TMB_Customer_ID_PE__c = '011100000000000000000000701120';
        testAcc.Mobile_Number_PE__c = '104000159';

        insert testAcc;

        Task t = new Task();
        t.Subject = 'Test';
        t.WhatId = testAcc.Id;

        insert t;

        Task t2 = new Task();
        t.Subject = 'Test2';

        insert t2;

        System.debug(customPopupUtilityController.getAccountByTask(t.Id, t2.Id,'0987654321'));

    }
}