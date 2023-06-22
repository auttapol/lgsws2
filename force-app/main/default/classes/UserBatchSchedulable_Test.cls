@isTest
public class UserBatchSchedulable_Test {
    public static String CRON_EXP = '0 0 0 15 3 ? 2025';
    
    @isTest
    private static void RunSchedule_Error() {
        UserBatchDispatcher.emode = 1 ;
        
        
        test.StartTest();
        // Schedule the test job
        String jobId = System.schedule('UserBatchSchedulable',
                                       CRON_EXP,
                                       new UserBatchSchedulable());


        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        TimeZone tz = UserInfo.getTimeZone();
        System.debug('Display name: ' + tz.getDisplayName());
        System.debug('ID: ' + tz.getID());
        // During daylight saving time for the America/Los_Angeles time zone
        System.debug('Offset: ' + tz.getOffset(DateTime.newInstance(2012, 10, 23, 12, 0, 0)));
        // Not during daylight saving time for the America/Los_Angeles time zone
        System.debug('Offset: ' + tz.getOffset(DateTime.newInstance(2012, 11, 23, 12, 0, 0)));
        System.debug('String format: ' + tz.toString());
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP,
                            ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        if ('Asia/Bangkok' == tz.getID()) {
            //System.assertEquals('2568-03-15 00:00:00', String.valueOf(ct.NextFireTime));
            System.assertEquals('2025-03-15 00:00:00', String.valueOf(ct.NextFireTime));
        } else {
            // Verify the next time the job will run
            System.assertEquals('2025-03-15 00:00:00', String.valueOf(ct.NextFireTime));
        }


        //List<BatchHistory__c> histories = [Select id , Precessed_Rerords__c From BatchHistory__c];
        //system.assertEquals(0 , histories.size());
       // test.StopTest();
       // histories = [Select id , Precessed_Rerords__c From BatchHistory__c];
        //system.assertEquals(0 , histories.size());
    }
    
    @isTest(seeAllData = false)
    private static void RunSchedule() {

        test.StartTest();
        // Schedule the test job
        String jobId = System.schedule('UserBatchSchedulable',
                                       CRON_EXP,
                                       new UserBatchSchedulable());


        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        TimeZone tz = UserInfo.getTimeZone();
        System.debug('Display name: ' + tz.getDisplayName());
        System.debug('ID: ' + tz.getID());
        // During daylight saving time for the America/Los_Angeles time zone
        System.debug('Offset: ' + tz.getOffset(DateTime.newInstance(2012, 10, 23, 12, 0, 0)));
        // Not during daylight saving time for the America/Los_Angeles time zone
        System.debug('Offset: ' + tz.getOffset(DateTime.newInstance(2012, 11, 23, 12, 0, 0)));
        System.debug('String format: ' + tz.toString());
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP,
                            ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        if ('Asia/Bangkok' == tz.getID()) {
            //System.assertEquals('2568-03-15 00:00:00', String.valueOf(ct.NextFireTime));
            System.assertEquals('2025-03-15 00:00:00', String.valueOf(ct.NextFireTime));
        } else {
            // Verify the next time the job will run
            System.assertEquals('2025-03-15 00:00:00', String.valueOf(ct.NextFireTime));
        }


       // List<BatchHistory__c> histories = [Select id , Precessed_Rerords__c From BatchHistory__c];
      //  system.assertEquals(0 , histories.size());
      //  test.StopTest();
      //  histories = [Select id , Precessed_Rerords__c From BatchHistory__c];
      //  system.assertEquals(1 , histories.size());

    }
}