@IsTest
public class LeadMgmReportScheduler_Test{
	 private static void createCustomSettingForLeadMgmReport() {
	 	List<Lead_MGM_Report_Scheduler__c> leadMgmLst = new List<Lead_MGM_Report_Scheduler__c>();

	 	Lead_MGM_Report_Scheduler__c leadMgm = new Lead_MGM_Report_Scheduler__c();
	 	leadMgm.Name = 'Wealth MGM Lead Tracking Report';
	 	leadMgm.CRON_TIME__c = '0 0 6 ? * MON';
	 	leadMgm.Email_List__c = 'test@test.com';
	 	leadMgm.isActive__c = true;
	 	leadMgm.NoRecordMessage__c = '';
	 	leadMgm.Report_API_Name__c = '	Wealth_MGM_Lead_Tracking_Report';
	 	leadMgm.UserField__c = 'Pending Approver Emp Id';
	 	leadMgm.User_Role_List__c = '\'SME_CM_Sales_TH_TL\',\'SME_CM_Sales\'';

	 	Lead_MGM_Report_Scheduler__c leadMgm2 = new Lead_MGM_Report_Scheduler__c();
	 	leadMgm2.Name = 'Wealth MGM Lead Tracking Report 2';
	 	leadMgm2.CRON_TIME__c = '0 0 6 ? * FRI;0 0 16 ? * SAT';
	 	leadMgm2.Email_List__c = 'test@test.com';
	 	leadMgm2.isActive__c = true;
	 	leadMgm2.NoRecordMessage__c = '';
	 	leadMgm2.Report_API_Name__c = 'Wealth_MGM_Lead_Tracking_Report_2';
	 	leadMgm2.UserField__c = 'Pending Approver Emp Id';
	 	leadMgm2.User_Role_List__c = '\'SME_CM_Sales_TH_TL\',\'SME_CM_Sales\'';


	 	leadMgmLst.add(leadMgm);
	 	leadMgmLst.add(leadMgm2);

	 	insert leadMgmLst;

	 }


	 public static testmethod void testForLeadMgmReportSchedule(){
	 	Test.startTest();
        TestUtils.createAppConfig();
        createCustomSettingForLeadMgmReport();


        LeadMgmReportScheduler leadMgm = new LeadMgmReportScheduler('Wealth_MGM_Lead_Tracking_Report');
        leadMgm.executeJob();
        leadMgm.abortJob();



        System.schedule('Wealth_MGM_Lead_Tracking_Report_2'+' '+'0 0 12 * * ? *'
                          , '0 0 12 * * ? *'
                          , new LeadMgmReportScheduler('Wealth_MGM_Lead_Tracking_Report_2'));

        Test.stopTest();

	 }

}