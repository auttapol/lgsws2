@isTest
public with sharing class RTL_SchedulerNBOPurgeTest {
    static {
        TestUtils.createAppConfig();
    } 	
	
	//use createddate to test since it's not able to change lastmodifieddate
    public static String query = 'select ID from RTL_NBO_History__c where RTL_NBO_Product_Latest_Modified_Date__c < LAST_N_MONTHS:3';
    
    public static testMethod void scheduleNBOPurgeTest(){
        //create retail master product
        RTL_TestUtility.createRetailMasterProducts2(true);  

        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        Id acctId = null;
        System.runAs(retailUser) {
        	//create test account
            List<Account> accountList = RTL_TestUtility.createAccounts(1,true); 
            acctId = accountList[0].Id;         
        }         
          	
        //prepare 200 NBO Histories, 100 is created within 3 months, 100 is created older than 3 months
        List<RTL_NBO_History__c> nboHistoryList = RTL_TestUtility.createNBOHistoryAndProduct(200, acctId, true);

		//set the 1st 100 NBO History RTL_NBO_Product_Latest_Modified_Date__c to be 3 months earlier
		Integer counter = 1;
        for(RTL_NBO_History__c nboHis: nboHistoryList){
			if (counter <= 100) nboHis.RTL_NBO_Product_Latest_Modified_Date__c = Date.today().addDays(-200);
			counter++;
        }
        update nboHistoryList;

        Test.startTest();
      	// Schedule the test job, but after Test.stopTest, the purge hasn't started.
      	String jobId = System.schedule('NBOHistoryPurgeTest',
                        RTL_TestUtility.CRON_EXP, 
                        new RTL_SchedulerNBOPurge());
                        
      	// Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

      	// Verify the expressions are the same
      	System.assertEquals(RTL_TestUtility.CRON_EXP, ct.CronExpression);

      	// Verify the scheduled job hasn't run yet.
      	System.assertEquals(200, nboHistoryList.size());
      	Integer nboHistoryProductCount = [select count() from RTL_NBO_History_Product__c];
      	System.assertEquals(200, nboHistoryProductCount);      	
        
      	Test.stopTest();
    }  
    
    public static testMethod void batchNBOPurgeTest(){
        //create retail master product
        RTL_TestUtility.createRetailMasterProducts2(true);  
        
        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        Id acctId = null;
        System.runAs(retailUser) {
        	//create test account
            List<Account> accountList = RTL_TestUtility.createAccounts(1,true); 
            acctId = accountList[0].Id;         
        }           
            	
        //prepare 200 NBO Histories, 100 is created within 3 months, 100 is created older than 3 months
        List<RTL_NBO_History__c> nboHistoryList = RTL_TestUtility.createNBOHistoryAndProduct(200, acctId, true);

		//set the 1st 100 NBO History RTL_NBO_Product_Latest_Modified_Date__c to be 3 months earlier
		Integer counter = 1;
        for(RTL_NBO_History__c nboHis: nboHistoryList){
			if (counter <= 100) nboHis.RTL_NBO_Product_Latest_Modified_Date__c = Date.today().addDays(-200);
			counter++;
        }
        update nboHistoryList;

        Test.startTest();
		// Call the batch class in order to check the batch result
      	RTL_BatchNBOPurge nboPurge = new RTL_BatchNBOPurge(query);
        Id BatchProcessId = Database.ExecuteBatch(nboPurge);

      	// Verify the scheduled job hasn't run yet.
      	System.assertEquals(200, nboHistoryList.size());
      	Integer nboHistoryProductCount = [select count() from RTL_NBO_History_Product__c];
      	System.assertEquals(200, nboHistoryProductCount);      	
        
      	Test.stopTest();
      	
      	// Verify 100 NBO History and Products have been deleted
      	Integer nboHistoryCount = [select count() from RTL_NBO_History__c];
      	System.assertEquals(100, nboHistoryCount);
      	nboHistoryProductCount = [select count() from RTL_NBO_History_Product__c];      	
      	System.assertEquals(100, nboHistoryProductCount);
    }        
}