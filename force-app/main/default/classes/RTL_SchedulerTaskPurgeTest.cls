@isTest
public with sharing class RTL_SchedulerTaskPurgeTest {
    static {
        TestUtils.createAppConfig();
    }   	
    //use createddate to test since it's not able to change lastmodifieddate
    public static String query = 'select ID, RTL_NBO_History__c from Task where createddate < LAST_N_MONTHS:3 and (recordtype.developername = \'RTL_Retail_Task\' or recordtype.developername = \'RTL_Retail_Outbound_Phone_Call\')';
    
    public static testMethod void scheduleTaskPurgeTest(){
    	List<Task> taskList = new List<Task>();
    	
        //create retail master product
        RTL_TestUtility.createRetailMasterProducts2(true);   
        
        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        Id acctId = null;
        System.runAs(retailUser) {
        	//create test account
            List<Account> accountList = RTL_TestUtility.createAccounts(1,true); 
            acctId = accountList[0].Id;         
        } 
                   	
        //prepare 200 NBO Histories and Products
        List<RTL_NBO_History__c> nboHistoryList = RTL_TestUtility.createNBOHistoryAndProduct(200, acctId, true);
		
		//prepare 200 Retail Tasks, 100 is created within 3 months, 100 is created older than 3 months
		System.runAs(retailUser) {
			List<Lead> leadList = RTL_TestUtility.createLeads(1,true);
			String leadId = leadList[0].Id;
			Task taskObj = null;
			// Create 200 retail tasks
			for(Integer j = 0; j<200;j++){
				taskObj = new Task();
				taskObj.WhoId = leadId;
				taskObj.Subject = 'retail task' + j;
				taskObj.RTL_NBO_History__c = nboHistoryList[j].Id;
				taskObj.recordTypeId = RTL_TestUtility.retailTaskRecordType.Id;
				taskObj.RTL_Agent__c = '11111';
				taskList.add(taskObj);
			}
			insert taskList;
			//set the 1st 100 Task createddate to be 3 months earlier
			Integer counter = 1;
			for (Task task: taskList) {
				if (counter <= 100) Test.setCreatedDate(task.Id, RTL_TestUtility.threemonthsolder);
				counter++;
			}			
		}

        Test.startTest();
      	// Schedule the test job, but after Test.stopTest, the purge hasn't started.
      	String jobId = System.schedule('TaskPurgeTest',
                        RTL_TestUtility.CRON_EXP, 
                        new RTL_SchedulerTaskPurge());
                        
      	// Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

      	// Verify the expressions are the same
      	System.assertEquals(RTL_TestUtility.CRON_EXP, ct.CronExpression);

      	// Verify the scheduled job hasn't run yet.
      	System.assertEquals(200, taskList.size());
      	System.assertEquals(200, nboHistoryList.size());
      	Integer nboHistoryProductCount = [select count() from RTL_NBO_History_Product__c];
      	System.assertEquals(200, nboHistoryProductCount);      	
        
      	Test.stopTest();
    }     
    
    public static testMethod void batchTaskPurgeTest(){
    	List<Task> taskList = new List<Task>();
    	
        //create retail master product
        RTL_TestUtility.createRetailMasterProducts2(true);   
        
        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        Id acctId = null;
        System.runAs(retailUser) {
        	//create test account
            List<Account> accountList = RTL_TestUtility.createAccounts(1,true); 
            acctId = accountList[0].Id;         
        } 
                   	
        //prepare 200 NBO Histories and Products
        List<RTL_NBO_History__c> nboHistoryList = RTL_TestUtility.createNBOHistoryAndProduct(200, acctId, true);
		
		//prepare 200 Retail Tasks, 100 is created within 3 months, 100 is created older than 3 months
        System.runAs(retailUser) {
            //create new test lead     
            List<Lead> leads = RTL_TestUtility.createLeads(1, true);
			String leadId = leads[0].Id;
			Task taskObj = null;
			// Create 200 retail tasks
			for(Integer j = 0; j<200;j++){
				taskObj = new Task();
				taskObj.WhoId = leadId;
				taskObj.Subject = 'retail task' + j;
				taskObj.RTL_NBO_History__c = nboHistoryList[j].Id;
				taskObj.recordTypeId = RTL_TestUtility.retailTaskRecordType.Id;
				taskObj.RTL_Agent__c = '11111';
				taskList.add(taskObj);
			}
			insert taskList;
			//set the 1st 100 Task createddate to be 3 months earlier
			Integer counter = 1;
			for (Task task: taskList) {
				if (counter <= 100) Test.setCreatedDate(task.Id, RTL_TestUtility.threemonthsolder);
				counter++;
			}			
		}

        Test.startTest();
        // Call the batch class in order to check the batch result
        RTL_BatchTaskPurge taskPurge = new RTL_BatchTaskPurge(query);
        Id BatchProcessId = Database.ExecuteBatch(taskPurge);

      	// Verify the scheduled job hasn't run yet.
      	System.assertEquals(200, taskList.size());
      	System.assertEquals(200, nboHistoryList.size());
      	Integer nboHistoryProductCount = [select count() from RTL_NBO_History_Product__c];
      	System.assertEquals(200, nboHistoryProductCount);      	
        
      	Test.stopTest();
      	
        // Verify 100 Retail Task, NBO History and Products have been deleted
      	Integer taskCount = [select count() from Task where recordtype.developername = 'RTL_Retail_Task'];      	
      	System.assertEquals(100, taskCount);
      	Integer nboHistoryCount = [select count() from RTL_NBO_History__c];
      	System.assertEquals(100, nboHistoryCount);
      	nboHistoryProductCount = [select count() from RTL_NBO_History_Product__c];      	
      	System.assertEquals(100, nboHistoryProductCount);
    }    
}