@isTest
public without sharing class fnaAvatarResultMappingSendEmail_Test {

    private static void setupTestClass(){
        // Setup test data
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser222@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser222@testorg.com');

        System.runAs(u) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
        }
    }

    @isTest
    private static void Test_naAvatarResultMappingSendEmail() {
        List<AvatarResultMapping__c> listAvatarResultMaping = new List<AvatarResultMapping__c>();
        AvatarResultMapping__c avatarResultMaping = new AvatarResultMapping__c();
        avatarResultMaping.isActive__c = false;
        avatarResultMaping.Answer__c = 'คำตอบทั้งหมดX';
        listAvatarResultMaping.add(avatarResultMaping);
        insert listAvatarResultMaping;

        setupTestClass();
        
        fnaAvatarResultMappingSendEmail.LIMIT_TO_ADDR = 1;

        DateTime startTime = DateTime.now();
        Integer recordsSuccessful = 0;
        Integer recordsFailed = 0;
        List<String> EMAIL_SENT_TO_ALERT = new List<String>{ 'standarduser222@testorg.com' };
        String errorMessage = '';
        String query = '[SELECT Id, QuestionnaireFlow__c, Answer__c, AvatarMaster__c, Segment__c, isActive__c FROM AvatarResultMapping__c WHERE isActive__c = false]';
        String bodyTextSuccess = '<h2>SUCCESS</h2>';
        String bodyTextFailed = 'Please check your avatar mapping temp, field and confirm again, go to : ' + fnaAvatarResultMappingSendEmail.getDomain();
        fnaAvatarResultMappingSendEmail.SendFinishDailyBatchSummaryEmail(
            Datetime.now(),
            startTime,
            Datetime.now(),
            recordsSuccessful,
            recordsFailed,
            'Avatar_Result_Mapping',
            'Avatar Result Mapping',
            EMAIL_SENT_TO_ALERT,
            errorMessage, // mainError '001,test1c,404,Not Found\n002,test2c,503,Unavailiable\n'
            '', // secondaryError
            '', // successLog
            'Avatar Result Mapping ID,Field Error,StatusCode,Error Message\n', // mainErrorHeader
            '', // secondaryErrorHeader
            '', // successLogHeader
            query,
            bodyTextSuccess,
            bodyTextFailed,
            'TEST'
        );
    }

    @isTest
    private static void Test_naAvatarResultMappingSendEmail_2() {
        List<AvatarResultMapping__c> listAvatarResultMaping = new List<AvatarResultMapping__c>();
        AvatarResultMapping__c avatarResultMaping = new AvatarResultMapping__c();
        avatarResultMaping.isActive__c = false;
        avatarResultMaping.Answer__c = 'คำตอบทั้งหมดX';
        listAvatarResultMaping.add(avatarResultMaping);
        insert listAvatarResultMaping;

        DateTime startTime = DateTime.now();
        Integer recordsSuccessful = 0;
        Integer recordsFailed = 1;
        List<String> EMAIL_SENT_TO_ALERT = new List<String>();
        String errorMessage = 'test';
        String query = '[SELECT Id, QuestionnaireFlow__c, Answer__c, AvatarMaster__c, Segment__c, isActive__c FROM AvatarResultMapping__c WHERE isActive__c = false]';
        String bodyTextSuccess = '<h2>SUCCESS</h2>';
        String bodyTextFailed = 'Please check your avatar mapping temp, field and confirm again, go to : ' + fnaAvatarResultMappingSendEmail.getDomain();
        fnaAvatarResultMappingSendEmail.SendFinishDailyBatchSummaryEmail(
            Datetime.now(),
            startTime,
            Datetime.now(),
            recordsSuccessful,
            recordsFailed,
            'Avatar_Result_Mapping',
            'Avatar Result Mapping',
            EMAIL_SENT_TO_ALERT,
            errorMessage, // mainError '001,test1c,404,Not Found\n002,test2c,503,Unavailiable\n'
            'test', // secondaryError
            'test', // successLog
            'Avatar Result Mapping ID,Field Error,StatusCode,Error Message\n', // mainErrorHeader
            '', // secondaryErrorHeader
            '', // successLogHeader
            query,
            bodyTextSuccess,
            bodyTextFailed,
            ''
        );
    }
    
    @isTest
    private static void Test_doEmailLog(){
        setupTestClass();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'support@ii.co.th';
        Aconfig.Value__c = 'support@ii.co.th'; 
        insert Aconfig;
        List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();

			csvAttc.setFileName('LOG_SUCCESS_Test.csv');
        	Blob csvBlob = Blob.valueOf('test');
			csvAttc.setBody(csvBlob);
			csvAttc.setContentType('text/csv; charset=UTF-8');
			efaList.add(csvAttc);
        List<String> emailOpsList = new List<String>();
            emailOpsList.add('support@ii.co.th');
        fnaAvatarResultMappingSendEmail.SendEmailByUserIdsAndSingleEmail('test','test',emailOpsList,efaList,false);
    }

}