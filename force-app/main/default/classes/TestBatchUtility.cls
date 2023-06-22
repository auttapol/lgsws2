@IsTest
public class TestBatchUtility{
	 private static void createCustomSettingForEsuitReport() {
	 	List<ESuit_Report_Schedule__c> esuitLst = new List<ESuit_Report_Schedule__c>();

	 	ESuit_Report_Schedule__c esuit = new ESuit_Report_Schedule__c();
	 	esuit.Name = 'ESuit Pending Client Suitability - SME';
	 	esuit.CRON_TIME__c = '0 0 12 * * ? *;0 0 16 * * ? *;0 0 19 * * ? *';
	 	esuit.Email_List__c = 'test@test.com';
	 	esuit.isActive__c = true;
	 	esuit.NoRecordMessage__c = 'NoRecordMessage__c';
	 	esuit.Report_API_Name__c = 'Pending_Client_Suitability_SME_TEST';
	 	esuit.UserField__c = 'RM Emp No';
	 	esuit.User_Role_List__c = '\'SME_CM_Sales_TH_TL\',\'SME_CM_Sales\'';

	 	ESuit_Report_Schedule__c esuit2 = new ESuit_Report_Schedule__c();
	 	esuit2.Name = 'ESuit Pending Client Suitability - MB';
	 	esuit2.CRON_TIME__c = '0 0 12 * * ? *';
	 	esuit2.Email_List__c = 'test@test.com';
	 	esuit2.isActive__c = true;
	 	esuit2.NoRecordMessage__c = 'NoRecordMessage__c';
	 	esuit2.Report_API_Name__c = 'Pending_Client_Suitability_MB_TEST';
	 	esuit2.UserField__c = 'RM Emp No';
	 	esuit2.User_Role_List__c = '\'SME_CM_Sales_TH_TL\',\'SME_CM_Sales\'';


	 	esuitLst.add(esuit);
	 	esuitLst.add(esuit2);

	 	insert esuitLst;

	 }


	 public static testmethod void testForEsuitReportSchedule(){
	 	Test.startTest();
        TestUtils.createAppConfig();
        createCustomSettingForEsuitReport();


        EsuitReportScheduler esuit = new EsuitReportScheduler('Pending_Client_Suitability_SME_TEST');
        esuit.executeJob();
        esuit.abortJob();



        System.schedule('Pending_Client_Suitability_MB_TEST'+' '+'0 0 12 * * ? *'
                          , '0 0 12 * * ? *'
                          , new EsuitReportScheduler('Pending_Client_Suitability_MB_TEST'));

        Test.stopTest();

	 }

}