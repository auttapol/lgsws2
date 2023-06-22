@IsTest
public class UserInactiveListReportSchduler_Test{

    //  string CRONJOB = '0 0 12 * * ? *';
    //  private static void createCustomMetaDataForUserInactiveReport() {
    //      List<Tracking_Report__mdt> userInactiveLst = new List<Tracking_Report__mdt>();

    //      Tracking_Report__mdt userInactive = new Tracking_Report__mdt();
    //      userInactive.DeveloperName = 'User Inactive Tracking Report';
    //      userInactive.CRON_TIME__c = '0 0 6 ? * *';
    //      userInactive.Email_List__c = 'test@test.com';
    //      userInactive.isActive__c = true;
    //      userInactive.NoRecordMessage__c = '';
    //      userInactive.Report_API_Name__c = ' User_Inactive_Tracking_Report';
    //      userInactive.UserField__c = 'Pending Approver Emp Id';
    //      userInactive.User_Role_List__c = '\'SME_CM_Sales_TH_TL\',\'SME_CM_Sales\'';

    //      Tracking_Report__mdt userInactive2 = new Tracking_Report__mdt();
    //      userInactive2.DeveloperName = 'User Inactive Tracking Report 2';
    //      userInactive2.CRON_TIME__c = '0 0 6 ? * FRI;0 0 16 ? * SAT';
    //      userInactive2.Email_List__c = 'test1@test.com';
    //      userInactive2.isActive__c = true;
    //      userInactive2.NoRecordMessage__c = '';
    //      userInactive2.Report_API_Name__c = 'User_Inactive_Tracking_Report_2';
    //      userInactive2.UserField__c = 'Pending Approver Emp Id';
    //      userInactive2.User_Role_List__c = '\'SME_CM_Sales_TH_TL\',\'SME_CM_Sales\'';


    //      userInactiveLst.add(userInactive);
    //      userInactiveLst.add(userInactive2);

    //      insert userInactiveLst;

    //  }

    public static testmethod void testSetSchedule(){
        Test.startTest();
        // TestUtils.createAppConfig();
        // createCustomMetaDataForUserInactiveReport();

        UserInactiveListReportSchduler userInactive = new UserInactiveListReportSchduler('User_Inactive_Tracking_Report');
        userInactive.abortJob();
        userInactive.executeJob();
        userInactive.abortJob();

        System.schedule('User_Inactive_Tracking_Report'+' 0 0 12 * * ? *'
                          , '0 0 12 * * ? *'
                          , new UserInactiveListReportSchduler('User_Inactive_Tracking_Report'));

        Test.stopTest();

    }

}