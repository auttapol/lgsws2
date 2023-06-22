@isTest
private class CSEClientScheduleTest {
	
	@isTest static void execute() {
		String CRON_EXP = '0 0 0 15 3 ? *';    
        
        Test.startTest();

            String jobId = System.schedule('CSEClientSchedule',  CRON_EXP, new CSEClientSchedule());

        Test.stopTest();

    }
	
}