@isTest
public class TaskEventHomeControllerTest{
    
    static integer IntResult;
    static string StrResult;
    static account acct;
    static boolean BolResult;
    	
    static testmethod void TaskEventTest()
    {
        insert new AppConfig__c(name = 'runtrigger', value__c = 'TRUE');
        TestUtils.createAppConfigRetailtoComm();
        acct = testutils.createAccounts(1, 'fname', 'Individual', true).get(0);
        	acct.ownerid = userinfo.getUserId();
        	update acct;
        product2 pd = new product2(name = 'prodname');
        	insert pd;
        Product_Information_On_Hand__c poh = new Product_Information_On_Hand__c(Account__c = acct.id,Product_Hierachy_Code__c = pd.id);
        	insert poh;
        Product_Information_Detail__c pid = new Product_Information_Detail__c(Customer__c = acct.id,Maturity_Date__c = Date.newInstance(System.today().Year(), System.today().month()-2, 15),Product_Information__c = poh.id);
        	insert pid;
        insert new ReportProfileMapping__c(name='test',ProductDueReportName__c='test',LeadReportName__c='test',OverdueReportName__c='test',
                   AnnualReportName__c='test',DPDReportName__c='test',ComplaintReportName__c='test',isActive__c=true,ProfileName__c='Default');
        
        Test.startTest();
        TaskEventHomeController taskevent = new TaskEventHomeController();
		IntResult = taskevent.countOverdue;
        IntResult = taskevent.countDPD;
        IntResult = taskevent.countProductDue;
        IntResult = taskevent.countAcctAnnualReview;
        IntResult = taskevent.countCaseNumber;
        IntResult = taskevent.countNewLead;
        IntResult = taskevent.countNewReferral;/* CR Referral */
    
        StrResult = taskevent.reportPageAnnual;
        StrResult = taskevent.reportPageCase;
        StrResult = taskevent.reportPageDPD;
        StrResult = taskevent.reportPageOverdue;
        StrResult = taskevent.reportPageProductDue;
        StrResult = taskevent.reportPageLead;
        StrResult = taskevent.reportPageReferral; /* CR Referral */
        BolResult = taskevent.isShowCase;
        BolResult = taskevent.isShowReferral;
        BolResult = taskevent.isShowLead;
        BolResult = taskevent.isShowOverdueActivity;
        BolResult = taskevent.isShowAnnual;
        BolResult = taskevent.isShowDPD;
        BolResult = taskevent.isShowPageProductDue;
        
        task taskObj1 = new task(OwnerId = userinfo.getUserId(),Subject = 'Call',Status = 'Not Started',Priority = 'Normal',ActivityDate = date.today());
        task taskObj2 = new task(OwnerId = userinfo.getUserId(),Subject = 'Call',Status = 'Not Started',Priority = 'Normal',ActivityDate = date.today());
        task taskObj3 = new task(OwnerId = userinfo.getUserId(),Subject = 'Call',Status = 'Not Started',Priority = 'Normal',ActivityDate = date.today());
        task taskObj4 = new task(OwnerId = userinfo.getUserId(),Subject = 'Call',Status = 'Not Started',Priority = 'Normal',ActivityDate = date.today());
        task taskObj5 = new task(OwnerId = userinfo.getUserId(),Subject = 'Call',Status = 'Not Started',Priority = 'Normal',ActivityDate = date.today());
        event eventObj1 = new event(OwnerId = userinfo.getUserId(),Subject = 'Call',StartDateTime = datetime.now(),EndDateTime = datetime.now(),ActivityDate = date.today());
        event eventObj2 = new event(OwnerId = userinfo.getUserId(),Subject = 'CalltestlongsubjectCalltestlongsubjectCall',StartDateTime = datetime.now(),EndDateTime = datetime.now(),ActivityDate = date.today());
        call_report__c cr = new call_report__c(Customer_name__c = acct.id,Date_of_Visit__c = date.today(),Categories__c = 'Pre boarding',Main_purpose__c = 'First visit',Sub_purpose__c='Credit');
            cr.RecordTypeId = [select id from recordtype where name ='Visit Plan / Report'].get(0).id;
            insert cr;
        
        taskevent.AddsTaskToWrapper(taskObj1);
        taskevent.AddsTaskToWrapper(taskObj2);
        taskevent.AddsTaskToWrapper(taskObj3);
        taskevent.AddsTaskToWrapper(taskObj4);
        taskevent.AddsTaskToWrapper(taskObj5);
        taskevent.AddsEventToWrapper(eventObj1);
        taskevent.AddsEventToWrapper(eventObj2);
        
        taskevent.pageLoad();
        
        boolean hn = taskevent.hasNext;
        boolean hp = taskevent.hasPrevious;
        
        taskevent.redirecttoNewTask();
        Test.stopTest();
    }

}