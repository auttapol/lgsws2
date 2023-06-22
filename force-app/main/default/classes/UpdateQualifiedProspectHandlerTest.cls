@IsTest
public class UpdateQualifiedProspectHandlerTest {
    
            static {
        TestUtils.createIdType();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();
        TestUtils.createDisqualifiedReason();    
      
    }
    
    public static testmethod void positiveTest(){
        System.debug(':::: positiveTest Start ::::');
        TestInit.createUser(false);
        User u = TestInit.us;
        System.runAs(u) {
            TestInit.createAccount(1);
            TestInit.createOpportunity(TestInit.accountList.values());
            TestInit.createTask(TestInit.accountList.values());
            TestInit.createReport(TestInit.accountList.values());
            List<Account> accountList = TestInit.accountList.values();
            List<Opportunity> opportunityList = TestInit.opportunityList.values();
            List<Task> taskList = TestInit.taskList.values();
            List<Call_Report__c> reportList = TestInit.reportList.values();
            
            ApexPages.StandardController sc = new ApexPages.StandardController(accountList.get(0));
            UpdateQualifiedProspectHandler objEx = new UpdateQualifiedProspectHandler(sc);
            Test.startTest();
            objEx.checkChangeAccountType();
            objEx.returnPage();
            Test.stopTest();
        }
        
        System.debug(':::: positiveTest End ::::');
    }

}