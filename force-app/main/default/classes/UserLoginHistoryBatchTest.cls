@isTest
class UserLoginHistoryBatchTest {
	public static String CRON_EXP = '0 0 0 3 9 ?';

	static testmethod void test_userhistoryinsert() {
      Test.startTest();   
      String logHistoryinsert = System.schedule('UserLoginHistInsertSchedulerForTest'
                          , CRON_EXP
                          , new UserLoginHistInsertScheduler());

      Test.stopTest();
   }

   static testmethod void test_userhistorydelete() {
      Test.startTest();   

      String logHistoryDelete = System.schedule('UserLoginHistDeleteSchedulerForTest'
                          , CRON_EXP
                          , new UserLoginHistDeleteScheduler());

      Test.stopTest();
   }
}