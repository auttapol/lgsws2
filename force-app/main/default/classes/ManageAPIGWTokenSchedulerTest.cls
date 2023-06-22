@isTest
public class ManageAPIGWTokenSchedulerTest{
    @isTest static void testManageAPIGWTokenScheduler() {
        AppConfig__c app = new AppConfig__c(Name='TESTGETTOKENADDSECONDS', Value__c='25200');
        insert app;

        Datetime expiryTimeSCH = System.now().addSeconds(25222);
        System.debug('expiryTimeSCH : '+ expiryTimeSCH);

        String secondExp =  String.valueOf(expiryTimeSCH.secondGmt());
        String minuteExp =  String.valueOf(expiryTimeSCH.minuteGmt());
        String hourExp   =  String.valueOf(expiryTimeSCH.hourGmt());
        String dayExp    =  String.valueOf(expiryTimeSCH.dayGmt());
        String monthExp  =  String.valueOf(expiryTimeSCH.monthGmt());
        String yearExp  =   String.valueOf(expiryTimeSCH.yearGmt());
        String cronExpression = secondExp + ' ' + minuteExp + ' ' + hourExp + ' ' + dayExp + ' ' + monthExp + ' ' + '? '+ yearExp;
        System.debug('cronExpression : '+ cronExpression);
        
        // Schedule the test job   
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());

        Test.startTest();
            String jobId = System.schedule('testSchedulerManageToken', cronExpression, new ManageAPIGWTokenScheduler());
            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
            System.debug('ct : '+ ct);

            // Verify the expressions are the same
            System.assertEquals(cronExpression, ct.CronExpression);
     
            // Verify the job has not run
            System.assertEquals(0, ct.TimesTriggered);
        
            // Verify the next time the job will run
            //System.assertEquals( String.valueOf(orgPartGetToken.get('expirytime')), String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }
    
}