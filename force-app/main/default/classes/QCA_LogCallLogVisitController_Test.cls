@isTest
public class QCA_LogCallLogVisitController_Test {
    

    @testSetup 
    static void setup() {
        TestUtils.createAppConfig();
        
		/*List<AppConfig__c> mc = new List<AppConfig__c> {
            new AppConfig__c(Name = 'runtrigger', Value__c = 'true')
        };
        insert mc;*/

        String dateInString = DateTime.Now().format('MMddyyyyhhmmss');
		List<User> userList = RTL_TestUtility.createUsers(2, 'TestMock', 'SmartBDM', 'smartbdm@tmb.com.test', false);
        User User01 = userList.get(0);
		User01.ProfileId = QCA_LeadSimplifiedController_Test.BDM_PROFILE_ID;
		User01.isActive = true;
		User01.title = 'Branch Manager';
		// User01.RTL_Branch_Code__c = bz.Branch_Code__c;
		User01.Employee_ID__c = '123456';
		insert User01;
        
        User User02 = userList.get(1);
		User02.ProfileId = QCA_LeadSimplifiedController_Test.BDM_PROFILE_ID;
		User02.isActive = true;
		User02.title = 'Branch Manager';
		// User02.RTL_Branch_Code__c = bz.Branch_Code__c;
		User02.Employee_ID__c = '555123';
		insert User02;

        Account acct = TestUtils.createAccounts(1, 'test', 'CType', false).get(0);
		acct.Customer_Type__c = 'Individual';
		acct.OwnerID = User01.Id;
		acct.RecordTypeId = QCA_LeadSimplifiedController_Test.PROSPECT_ID;
        acct.Customer_Type__c = 'Juristic';
        acct.ID_Type_PE__c = 'BRN ID';
        acct.ID_Number_PE__c = dateInString + '99901';
		insert acct;
        List<Lead> leadList = RTL_TestUtility.createLeads(2, false);
        Lead Lead01 = leadList.get(0);
        Lead01.RecordTypeId = QCA_LeadSimplifiedController_Test.COMMERCIAL_ACCOUNT_ID;
        Lead01.OwnerID = User01.Id;
        Lead01.Account__c = acct.Id;
        Lead01.Customer_Type__c = 'Juristic';
        Lead01.ID_Type__c = 'BRN ID';
        Lead01.ID_Number__c = dateInString + '99901';
        insert Lead01;
        Lead01.Status = 'Passed Prescreening';
        Lead01.Pre_screening_Result__c = 'Passed';
        update Lead01;

        Task t = new Task(
            WhoId = Lead01.Id,
            OwnerId = User01.Id,
            ActivityDate = Date.today(),
            Status = 'Completed',
            Priority = 'Normal'
        );
        insert t;        

        Call_Report__c  cr = new Call_Report__c(
            OwnerId = User01.Id,
            // Customer_name__c = a.id,
            Lead__c = Lead01.Id,
            Status__c = 'Open',
            Date_of_Visit__c = Date.today(),
            Categories__c  = 'Sell product',
            Main_purpose__c = 'Sell product',
            Sub_Purpose__c  = 'Product'
        );
        insert cr;
        Opportunity oppty = TestUtils.createOpportunity(1, acct.Id, false).get(0);
        oppty.OwnerId = User01.Id;
        oppty.Converted_Lead_ID__c = Lead01.Id;
        insert oppty;

        // Visit_Report_Opportunity__c tmpVisitOppty = new Visit_Report_Opportunity__c();
        // tmpVisitOppty.Customer__c = cr.Id;
        // tmpVisitOppty.Opportunity__c = oppty.Id;
        // insert tmpVisitOppty;

        /*Lead Lead02 = leadList.get(1);
        Lead02.RecordTypeId = QCA_LeadSimplifiedController_Test.COMMERCIAL_LEAD_ID;
        Lead02.OwnerID = User02.Id;
        Lead02.Customer_Type__c = 'Juristic';
        Lead02.ID_Type__c = 'BRN ID';
        Lead02.ID_Number__c = dateInString + '99902';
        insert Lead02;
        Lead02.Status = 'Passed Prescreening';
        Lead02.Pre_screening_Result__c = 'Passed';
        update Lead02;*/

    }

    public static List<Lead> getLeadList(){
        return [SELECT Id FROM Lead];
    }

    public static List<Opportunity> getOpportunityList(){
        return [SELECT Id FROM Opportunity];
    }

    @isTest
    static void test_QCA_SLSProductController_positive() {
        QCA_LogCallLogVisitController.getTaskValues();
        QCA_LogCallLogVisitController.getTaskFieldValues('Main_Task__c');
        QCA_LogCallLogVisitController.getVisitPlanReportDependencyFieldValues('Main_purpose__c', 'Sub_Purpose__c');
    }

    @isTest
    static void test_QCA_SLSProductController_negative() {
        new QCA_LogCallLogVisitController();
        QCA_LogCallLogVisitController.getVisitPlanReportList(null, null, null);

        Task t = QCA_LogCallLogVisitController.getMyTaskLastedInforamtion(null);
        // QCA_LogCallLogVisitController.UpdateTaskRecord(null);

        Call_Report__c cr = QCA_LogCallLogVisitController.getMyVisitPlanReportLastedInforamtion(null, null, null);
        // QCA_LogCallLogVisitController.UpdateVisitPlanReport(null);
        
    }

    @isTest
    static void test_QCA_SLSProductController_Lead_positive() {
        List<Lead> leadlist = getLeadList();
        Task t = QCA_LogCallLogVisitController.getMyTaskLastedInforamtion(leadlist.get(0).Id);
        QCA_LogCallLogVisitController.UpdateTaskRecord(t);
        Call_Report__c cr = QCA_LogCallLogVisitController.getMyVisitPlanReportLastedInforamtion(leadlist.get(0).Id, 'QCALeadType', null);
        QCA_LogCallLogVisitController.UpdateVisitPlanReport(cr);
    }

    @isTest
    static void test_QCA_SLSProductController_Opportunity_positive() {
        List<Opportunity> opptylist = getOpportunityList();
        List<Lead> leadlist = getLeadList();
        Call_Report__c  tmpcr = new Call_Report__c(
            // OwnerId = User01.Id,
            // Customer_name__c = a.id,
            Lead__c = leadlist.get(0).Id,
            Status__c = 'Open',
            Date_of_Visit__c = Date.today(),
            Categories__c  = 'Sell product',
            Main_purpose__c = 'Sell product',
            Sub_Purpose__c  = 'Product'
        );
        insert tmpcr;
        Test.startTest();
        	QCA_LogCallLogVisitController.UpdateVisitPlanReportOppty(tmpcr, opptylist.get(0).Id);
        	Call_Report__c cr = QCA_LogCallLogVisitController.getMyVisitPlanReportLastedInforamtion(null, 'QCAOpptyType', opptylist.get(0).Id);
            QCA_LogCallLogVisitController.UpdateVisitPlanReportOppty(cr, opptylist.get(0).Id);
        Test.stopTest();
        
    }

}