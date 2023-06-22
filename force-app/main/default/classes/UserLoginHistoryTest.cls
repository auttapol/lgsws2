@isTest
class UserLoginHistoryTest {
    public static String CRON_EXP = '0 0 0 3 9 ?';
    /*static testmethod void test() {
     Test.startTest();   
        User_Login_History__c log = new User_Login_History__c();
        log.Name = 'Testonly';
        log.Date__c = system.today() - 46;
        insert log;

        Login_History__c logH = New Login_History__c();
        logH.Name = 'Testlogin';
        LogH.CreateDate_Date__c = System.today() -46;
        insert LogH;
        
      // Schedule the test job
      String jobId = System.schedule('testScheduled',
      CRON_EXP, 
         new DailyLogUserLogin());
        
        // Schedule to log history
      String logHistory = System.schedule('testLogHistory',
      CRON_EXP, 
         new UserLoginHistory());

      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      Integer year = ct.NextFireTime.year();
      System.assertEquals(year+'-09-03 00:00:00', 
         String.valueOf(ct.NextFireTime));     

   Test.stopTest();

   }*/
   
   static testmethod void test2() {
     Test.startTest();   
        /*User_Login_History__c log = new User_Login_History__c();
        log.Name = 'Testonly';
        log.Date__c = system.today() - 46;
        insert log;

        Login_History__c logH = New Login_History__c();
        logH.Name = 'Testlogin';
        LogH.CreateDate_Date__c = System.today() -46;
        insert LogH;
        
      // Schedule the test job
      String jobId = System.schedule('testScheduled',
      CRON_EXP, 
         new DailyLogUserLogin());*/
        
        // Schedule to log history
      String logHistory = System.schedule('testLogHistory',
      CRON_EXP, 
         new UserLoginHistory_Delete());

      // Get the information from the CronTrigger API object
      /*CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      Integer year = ct.NextFireTime.year();
      System.assertEquals(year+'-09-03 00:00:00', 
         String.valueOf(ct.NextFireTime));*/     

   Test.stopTest();

   }

   static testmethod void test3() {
      Test.startTest();   
      
      List<AppConfig__c> apps = new  List<AppConfig__c>();
      AppConfig__c Aconfig = new AppConfig__c();
      Aconfig.Name = 'UserLoginHistoryEmail';
      Aconfig.Value__c = 'a@tmbbank.com';        
      apps.add(Aconfig);

      insert apps;

      String logHistory2 = System.schedule('testLogHistory2',
      CRON_EXP, 
         new UserLoginHistory_Insert());

      Test.stopTest();
   }

}