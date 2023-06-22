@IsTest
public class CustBaseReport_Test{
	 private static void createCustomSettingForCustBaseReport() {
	 	List<Cust_Base_Report_Scheduler__c> custBaseLst = new List<Cust_Base_Report_Scheduler__c>();

	 	Cust_Base_Report_Scheduler__c custBase = new Cust_Base_Report_Scheduler__c();
	 	custBase.Name = 'CRM_Pending_Aprv_Change_Owner_Cross';
	 	custBase.CRON_TIME__c = '0 0 6 ? * *';
	 	custBase.Email_List__c = 'test@test.com';
	 	custBase.isActive__c = true;
	 	custBase.NoRecordMessage__c = '';
	 	custBase.Report_API_Name__c = '	CRM_Pending_Approval_Change_Owner_Cross_Test';
	 	custBase.UserField__c = 'Pending Approver Emp Id';
	 	custBase.User_Role_List__c = '\'SME_CM_Sales_TH_TL\',\'SME_CM_Sales\'';

	 	Cust_Base_Report_Scheduler__c custBase2 = new Cust_Base_Report_Scheduler__c();
	 	custBase2.Name = 'CRM_Pending_Aprv_Change_Owner_Within';
	 	custBase2.CRON_TIME__c = '0 0 6 ? * *;0 0 16 * * ? *';
	 	custBase2.Email_List__c = 'test@test.com';
	 	custBase2.isActive__c = true;
	 	custBase2.NoRecordMessage__c = '';
	 	custBase2.Report_API_Name__c = 'CRM_Pending_Approval_Change_Owner_Within_Test';
	 	custBase2.UserField__c = 'Pending Approver Emp Id';
	 	custBase2.User_Role_List__c = '\'SME_CM_Sales_TH_TL\',\'SME_CM_Sales\'';


	 	custBaseLst.add(custBase);
	 	custBaseLst.add(custBase2);

	 	insert custBaseLst;

	 }


	 public static testmethod void testForCustBaseReportSchedule(){
	 	Test.startTest();
        TestUtils.createAppConfig();
        createCustomSettingForCustBaseReport();


        CustBaseReportScheduler custBase = new CustBaseReportScheduler('CRM_Pending_Approval_Change_Owner_Cross_Test');
        custBase.executeJob();
        custBase.abortJob();



        System.schedule('CRM_Pending_Approval_Change_Owner_Within_Test'+' '+'0 0 12 * * ? *'
                          , '0 0 12 * * ? *'
                          , new CustBaseReportScheduler('CRM_Pending_Approval_Change_Owner_Within_Test'));

        Test.stopTest();

	 }

}