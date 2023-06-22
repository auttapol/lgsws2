@IsTest
public with sharing class RTL_SubmitReferralToALAPPCtrlTest {
    private static String encryptKey {
        get {
            return '208f6c8723b80c36fefc349575764dd14baf52d950a98c101034c403b1172b65';
        }
    }

    @TestSetup
    static void makeData(){
        TestUtils.createAppConfig();

        AppConfig__c appConfig = AppConfig__c.getValues('runtrigger');
        appConfig.Value__c = 'true';
        update appConfig;

        RTL_product_master__c prod = new RTL_product_master__c();
        prod.Name = 'CYC';
        prod.Active__c = true;
        insert prod;
        RTL_Contact_Address__c adds = new RTL_Contact_Address__c();
        adds.IsActive__c = true;
        adds.RTL_Province__c = 'กรุงเทพมหานคร';
        adds.RTL_District__c = 'เขตพระนคร';
        adds.RTL_Sub_District__c = 'พระบรมมหาราชวัง';
        adds.RTL_Zipcode__c = '50000';
        insert adds;
        Branch_and_Zone__c branch = new Branch_and_Zone__c();
        branch.Name = 'AL Marketing';
        branch.IsActive__c = true;
        insert branch;

        Account acc = new Account();
        acc.Name = 'Test';
        acc.ID_Type_PE__c = 'Citizen ID';
        acc.ID_Number_PE__c = '7931087047594';
        acc.First_name_PE__c = 'Commercial Customer 000001';
        acc.Last_name_PE__c = 'Commercial Customer 000001';
        acc.Mobile_Number_PE__c = '52418';
        insert acc;

        String responseBody = (String)SCSMessageAPIUtil.encryptMessageWithKey('{ "RefCode3" : "20220228141195350", "RefCode2" : "a2S0l000000DdujEAC", "RefCode" : "", "ResponseDetail" : "OK", "ResponseCode" : "000" }',encryptKey);

        RTL_Referral__c ref = new RTL_Referral__c();
        ref.RTL_FirstName__c = 'Fname001';
        ref.RTL_LastName__c = 'Lname001';
        ref.RTL_Mobile1__c = '0951234560';
        ref.RTL_Product_Name__c = [SELECT Id,Name FROM  RTL_product_master__c WHERE Name = 'CYC' LIMIT 1].Id;
        ref.RTL_Contact_Address__c = [SELECT Id,Name FROM  RTL_Contact_Address__c WHERE IsActive__c = TRUE LIMIT 1].Id;
        ref.RTL_Stage__c = 'New';
        ref.RTL_Preferred_Branch__c = [SELECT Id,Name FROM  Branch_and_Zone__c WHERE Name = 'AL Marketing' LIMIT 1].Id;
        ref.RTL_AL_contact_channel__c = 'DS';
        ref.RecordTypeId = RTL_Referral__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Retail_Cross_Channel_Referral').getRecordTypeId();
        ref.RTL_Account_Name__c = [SELECT Id FROM Account LIMIT 1].Id;

        insert ref;



    }
    @IsTest
    static void testgetReferralRecord(){
        Test.startTest();

        RTL_SubmitReferralToALAPPCtrl.getRecord([SELECT Id FROM RTL_Referral__c LIMIT 1].Id);

        Test.stopTest();
    }
    @IsTest
    static void testcallAPIcreateReferral(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHPAPHttpResponse());
        RTL_SubmitReferralToALAPPCtrl.submitALALPP([SELECT Id FROM RTL_Referral__c LIMIT 1].Id);

        Test.stopTest();
    }
    @IsTest
    static void testcallAPIcreateReferralFailNoProd(){
        Test.startTest();
        RTL_product_master__c prod = [SELECT Id,Name FROM  RTL_product_master__c WHERE Name = 'CYC' LIMIT 1];
        prod.Name = 'Test';
        update prod;

        Test.setMock(HttpCalloutMock.class, new MockHPAPHttpResponse());
        RTL_SubmitReferralToALAPPCtrl.submitALALPP([SELECT Id FROM RTL_Referral__c  LIMIT 1].Id);
        
        Test.stopTest();
    }

}