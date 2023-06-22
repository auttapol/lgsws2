@isTest
public class PurgePDPAActivityLogBatchSchedulerTest {

    final static String cronEXP = '0 0 6 * * ?';

    static{
        // TestUtils.createAppConfig();
        // init();
    }

    @isTest
    public static void testScheduleHasAConfig() {
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'PDPA_Activity_Log_Purge_Days';
        Aconfig.Value__c = '365';  
        insert Aconfig;

        Test.startTest();
            String jobId = System.schedule('Purge PDPA Activity Log Test',  cronEXP, new PurgePDPAActivityLogBatchScheduler());

            List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(1, ct.size());
            if(ct.size() > 0) {
                System.assertEquals(cronEXP, ct.get(0).CronExpression);
                System.assertEquals(0, ct.get(0).TimesTriggered);
            }
        
        Test.stopTest();
    }

    @isTest
    public static void testScheduleWithoutAConfig() {
        Test.startTest();
            String jobId = System.schedule('Purge PDPA Activity Log Test',  cronEXP, new PurgePDPAActivityLogBatchScheduler());

            List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(1, ct.size());
            if(ct.size() > 0) {
                System.assertEquals(cronEXP, ct.get(0).CronExpression);
                System.assertEquals(0, ct.get(0).TimesTriggered);
            }
        Test.stopTest();
    }
    // public PurgePDPAActivityLogBatchSchedulerTest() {

    // }

    // Date backDate = System.Today().addDays(1);
    // String q = 'SELECT Id FROM PDPA_Activity_Log__c WHERE CreatedDate <=: BACKDATE';

    // database.executebatch(new PurgePDPAActivityLogBatch(q, backDate), 2000);
}