@isTest
public class AsyncApexFrameworkTest {

    public static final String CRON_EXP = '0 15 * * * ?';
    
    @isTest
    public static void testStartBatch(){
        Test.startTest();
        String jobId = System.schedule('AsyncApexFramework',
                CRON_EXP, 
                new AsyncApexFramework ());

        Test.stopTest();
    }
}