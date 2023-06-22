@isTest
public without sharing class SMSServiceHandler_Test {

    public class mockSobj{
		public String endpoint;
		public Boolean force;
		public Boolean search;
	}

    @isTest
    private static void Test_SMSServiceHandler() {
        TestUtils.createAppConfig_Trigger();
        TestUtils.createAppConfig();
        
        List<SMS_Notification_Handler__c> listSmsNotifyHandler = new List<SMS_Notification_Handler__c>();
        SMS_Notification_Handler__c smsNotifyHandler = new SMS_Notification_Handler__c();
        smsNotifyHandler.Name = 'test';
        smsNotifyHandler.Accout_ID_Field__c = 'test';
        smsNotifyHandler.Account_Name_Field__c = 'test';
        smsNotifyHandler.TOKEN_ENDPOINT_NAME__c = 'test';
        smsNotifyHandler.Sponsor_Class_Field__c = 'Name';
        smsNotifyHandler.IsActive__c = false;
        // smsNotifyHandler.SMS_Notification_Handler__c = 'test';
        listSmsNotifyHandler.add(smsNotifyHandler);

        SMS_Notification_Handler__c smsNotifyHandler_2 = new SMS_Notification_Handler__c();
        smsNotifyHandler_2.Name = 'test_2';
        smsNotifyHandler_2.IsActive__c = true;
        listSmsNotifyHandler.add(smsNotifyHandler_2);
        insert listSmsNotifyHandler;

        EIM_Map__c eimMap = new EIM_Map__c();
        eimMap.Job_Type__c = 'test';
        eimMap.IsActive__c = true;
        eimMap.Field_Type__c = 'Request';
        eimMap.Node__c = 'test';
        insert eimMap;

        String serviceName = 'test';
        String smsStatusLog = '';
        SMSServiceHandler smsService = new SMSServiceHandler(serviceName,smsStatusLog);

        // SObject sobj = smsNotifyHandler;
        // sobj.test = 'test';

        String status = 'test';
        Boolean isQueryAgain = true;
        smsService.getEnableToSentSMS(listSmsNotifyHandler[0], status, isQueryAgain);
        smsService.getEnableToSentSMS(listSmsNotifyHandler[1], status, isQueryAgain);

        smsService.getTokenEndpoint();
        smsService.getAPIBatchQuery();

        // String status = '';
        Map<String,Object> resMap = new Map<String,Object>();
        // smsService.updateResponseWS(sobj, status, resMap);

        // SObject Err : Invalid field  for SMS_Notification_Handler__c
        // smsService.updateSMSLogInProcess(sobj,status);
    }
}