@isTest
public class AssignOpportunityToCSScheduleTest {
    @isTest static void execute() {
        String CRON_EXP = '0 0 0 15 3 ? *';    
        
        Test.startTest();
        
        String jobId = System.schedule('AssignOpportunityToCSSchedule',  CRON_EXP, new AssignOpportunityToCSSchedule());
        
        Test.stopTest();
    }
}