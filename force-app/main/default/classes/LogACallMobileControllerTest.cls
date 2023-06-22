@isTest
public class LogACallMobileControllerTest {

    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
    }
    
   static testmethod void UnitTest(){

    PageReference logacallpage = Page.LogACallMobileLayout;
       Account acct2 = TestUtils.createAccounts(1,'TestLogacall','TestLog',true).get(0);
       Contact con = TestUtils.createContacts(1,acct2.id, true).get(0);
       String currentDate=string.valueOf(System.today());
        logacallpage.getParameters().put('what_id',acct2.id);
        logacallpage.getParameters().put('sObjectType','Contact');
        logacallpage.getParameters().put('who_ID',con.id);
        logacallpage.getParameters().put('currentDate',currentDate);
       Test.setCurrentPage(logacallpage);
       Test.startTest();
       Task tsk = new task();
       
       ApexPages.StandardController sc = new ApexPages.StandardController(tsk);
       LogACallMobileController logacall = new LogACallMobileController(sc);
       
       logacall.todayActivityDateStr = string.valueOf(System.today()); 
       
       logacall.ActivityDateHidden = string.valueOf(System.today());   
       logacall.getSubjects();
       logacall.getSubjects2();
       logacall.getObjectType();
       logacall.setObjectType('Account');
       logacall.getWhatID();
       logacall.setWhatID('00100000203');
       
       logacall.Subject = 'Test';
       //logacall.ReminderTime =  Time.newInstance(0, 0, 0, 0);
       //logacall.TaskReminder.IsReminderSet = true;
       //logacall.task.ReminderDate__c = System.today();
       //logacall.reminderTimeStr = '06:00';
       logacall.save();
       Test.stoptest();
   }
    
      static testmethod void UnitTest2(){

    PageReference logacallpage = Page.LogACallMobileLayout;
       Account acct2 = TestUtils.createAccounts(1,'TestLogacall','TestLog',true).get(0);
       Contact con = TestUtils.createContacts(1,acct2.id, true).get(0);
       String currentDate = string.valueOf(System.today());
        logacallpage.getParameters().put('what_id',acct2.id);
        logacallpage.getParameters().put('sObjectType','Contact');
        logacallpage.getParameters().put('whoid',con.id);
        logacallpage.getParameters().put('currentDate',currentDate);
       Test.setCurrentPage(logacallpage);
       Test.startTest();
       Task tsk = new task();
       
       ApexPages.StandardController sc = new ApexPages.StandardController(tsk);
       LogACallMobileController logacall = new LogACallMobileController(sc);
       
       logacall.getSubjects();
       logacall.getSubjects2();
       logacall.getObjectType();
       logacall.setObjectType('Account');
       logacall.getWhatID();
       logacall.setWhatID('00100000203');      
       
       logacall.ActivityDateHidden = string.valueOf(System.today()); 
       logacall.todayActivityDateStr = string.valueOf(System.today()); 
       
       logacall.Subject = 'Test';
       //logacall.ReminderTime =  Time.newInstance(0, 0, 0, 0);
       //logacall.TaskReminder.IsReminderSet = true;
       //logacall.task.ReminderDate__c = System.today();
       //logacall.reminderTimeStr = '06:00';
       logacall.save();
       Test.stoptest();
   }
    
    
}