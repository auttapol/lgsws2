@isTest
public class RTL_SchedulerErrorLogPurgeTest {
	/*static {
        TestUtils.createAppConfig();
    } 	
	
	//use createddate to test since it's not able to change lastmodifieddate
    public static String query = 'select ID from RTL_Online_Service_Log__c where LastModifiedDate = TODAY';
    
    public static testMethod void scheduleErrorLogPurgeTest(){
        //create retail online service log
        RTL_TestUtility.createOnlineServiceLog(100,true);  
        Test.startTest();
      	// Schedule the test job, but after Test.stopTest, the purge hasn't started.
      	String jobId = System.schedule('ErrorLogPurgeTest',
                        RTL_TestUtility.CRON_EXP, 
                        new RTL_SchedulerErrorLogPurge());
                        
      	// Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

      	// Verify the expressions are the same
      	System.assertEquals(RTL_TestUtility.CRON_EXP, ct.CronExpression);
        
        // Verify the scheduled job hasn't run yet.
      	Integer logCount = [select count() from RTL_Online_Service_Log__c];
      	System.assertEquals(100, logCount);
        
      	Test.stopTest();
    }
    
    public static testMethod void batchErrorLogPurgeTest(){
        //create retail online service log
        RTL_TestUtility.createOnlineServiceLog(100,true);  
        Test.startTest();
        
        // Call the batch class in order to check the batch result
      	RTL_BatchErrorLogPurge logPurge = new RTL_BatchErrorLogPurge(query);
        Id BatchProcessId = Database.ExecuteBatch(logPurge);
        
        // Verify the scheduled job hasn't run yet.
      	Integer logCount = [select count() from RTL_Online_Service_Log__c];
      	System.assertEquals(100, logCount);
        
      	Test.stopTest();
        
        // Verify 100 Online Service Logs have been deleted
      	logCount = [select count() from RTL_Online_Service_Log__c];
      	System.assertEquals(0, logCount);
    }*/
}