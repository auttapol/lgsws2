@isTest
public class BatchUpdateCaseProgressSMSTest {
    public static final Id BB_ARM_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    public static final Id ZONE_ROLE_ID = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1].Id;
    public static User newUser;
    static {
        TestUtils.createAppConfig();
    }
    @testSetup static void setupTest(){
              
        EIM_Map__c EIM = new EIM_Map__c();
        EIM.SF_Field__c = 'CaseNumber';
        EIM.Field_Type__c  = 'Request';
        EIM.Node__c = 'DataNode';
        Insert EIM;        

        Case testCase = new Case();  
        testCase.Status = 'In progress';
        testCase.PTA_Segment__c = 'RBG';
        testCase.Category__c = 'Inquiry';
        testCase.Sub_Category__c = 'Test';
        testCase.Issue__c = 'TEST';
        testCase.Call_Log_ID__c = '0000123456';
		testCase.Call_Number__c = '0891234567';
		testCase.Contact_Person_Name__c = 'TEST';
        testCase.Contact_Person_Phone__c ='0800000000';
        testCase.Contact_Person_Phone_2__c ='0800000000';
        testCase.To_Ext_1__c ='401 ,403';
        testCase.To_Ext_2__c ='401 ,(403)- 1';

        testCase.Problem_Type__c = 'TEST';
        testCase.Journey__c = 'TEST';
        testCase.Service_Type_Matrix_Code__c = 'V00001';
        testCase.Origin = 'ลูกค้าสัมพันธ์';
        testCase.SLA_Day__c = 12;
        testCase.SMS_Code_for_Update_Progress__c = 'CRMRBG_012';
        testCase.Current_Service_Template__c = 'General';

        insert testCase;

        List<SMS_Notification_Handler__c> listSmsNotifyHandler = new List<SMS_Notification_Handler__c>();
        SMS_Notification_Handler__c smsNotifyHandler = new SMS_Notification_Handler__c();
        smsNotifyHandler.Name = 'test';
        smsNotifyHandler.Accout_ID_Field__c = 'test';
        smsNotifyHandler.Account_Name_Field__c = 'test';
        smsNotifyHandler.TOKEN_ENDPOINT_NAME__c = 'test';
        smsNotifyHandler.Sponsor_Class_Field__c = 'Name';
        smsNotifyHandler.IsActive__c = false;
        listSmsNotifyHandler.add(smsNotifyHandler);

        SMS_Notification_Handler__c smsNotifyHandler_2 = new SMS_Notification_Handler__c();
        smsNotifyHandler_2.Name = 'test_2';
        smsNotifyHandler_2.IsActive__c = true;
        listSmsNotifyHandler.add(smsNotifyHandler_2);
        insert listSmsNotifyHandler;

        String serviceName = 'test';
        String smsStatusLog = '';
        SMSServiceHandler smsService = new SMSServiceHandler(serviceName,smsStatusLog);


        String status = 'test';
        Boolean isQueryAgain = true;
        smsService.getEnableToSentSMS(listSmsNotifyHandler[0], status, isQueryAgain);
        smsService.getEnableToSentSMS(listSmsNotifyHandler[1], status, isQueryAgain);

        smsService.getTokenEndpoint();
        smsService.getAPIBatchQuery();
        
    }
    
    @isTest
    public static void positiveTest(){
        
        String nextYear = String.valueOf(System.Today().year() + 1);
        // System.runAs(newUser){
        Test.setMock(HttpCalloutMock.class, new MockupBatchUpdateCaseProgressSMS());
        Test.startTest();
            // update smsNotiLst;
            string CRON = '0 0 0 3 9 ? ' + nextYear;
            BatchUpdateCaseProgressSMS testBatch = new BatchUpdateCaseProgressSMS();
            system.schedule('Test Batch',CRON, new BatchUpdateCaseProgressSMS());
        
		// Database.Executebatch(testBatch);
        Test.stopTest();
    // }

    }
    @isTest
    public static void negativeTest(){
        String nextYear = String.valueOf(System.Today().year() + 1);
        // System.runAs(newUser){
        // Test.setMock(HttpCalloutMock.class, new MockupBatchUpdateCaseProgressSMS());
        Test.startTest();
            // update smsNotiLst;
            string CRON = '0 0 0 3 9 ? ' + nextYear;
            BatchUpdateCaseProgressSMS testBatch = new BatchUpdateCaseProgressSMS();
            system.schedule('Test Batch',CRON, new BatchUpdateCaseProgressSMS());
        
		// Database.Executebatch(testBatch);
        Test.stopTest();
    // }

    }
}