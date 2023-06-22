@isTest
public class DeleteOpptyProductHistoryScheduledTest {
    public static String CRON_EXP = '0 0 1 5 7 ?';
    public static testMethod void ScheduleDeleteOppProdtest(){
        String query = 'SELECT Id FROM Opportunity_Product_History__c WHERE LastModifiedDate = LAST_MONTH';
        List<Opportunity_Product_History__c> oppProdHis = new List<Opportunity_Product_History__c>();
        for(Integer i = 0; i<200;i++){
        Opportunity_Product_History__c oppProductTemp = new Opportunity_Product_History__c();
		
            oppProductTemp.Deal_Probability__c = '50';
            oppProductTemp.Description__c = 'test Description';
            oppProductTemp.Expected_Fee_Rate__c = 80.5;
            oppProductTemp.Expected_NIM__c = 2.5;
            oppProductTemp.Expected_Revenue__c = 12500;
            oppProductTemp.Expected_Revenue_Fee__c = 2500;
            oppProductTemp.Expected_Revenue_Total__c = 125000.5;
            oppProductTemp.Expected_Util_Year_Fee__c = 80.0;
            oppProductTemp.Expected_Util_Year_NI__c = 80.00;
            oppProductTemp.Expected_Utilization_Vol_Fee__c = 400000.00;
            oppProductTemp.Expected_Utilization_Vol_NI__c = 400000.00;
            oppProductTemp.Quantity__c = 5;
            oppProductTemp.Recurring_Type__c = 'Recurring';
            oppProductTemp.Recurring_Type_Fee__c = 'Recurring';
            oppProductTemp.RevisedStartMonth__c = 'Jan';
            oppProductTemp.RevisedStartMonthFee__c = 'Jan';
            oppProductTemp.RevisedStartYear__c = '2015';
            oppProductTemp.RevisedStartYearFee__c = '2015';
            oppProdHis.add(oppProductTemp);
        }
		insert oppProdHis;
       
        system.debug('##---oppProdHis : '+oppProdHis.size());
        Test.startTest();
      // Schedule the test job
      String jobId = System.schedule('DeleteOppProd',
                        CRON_EXP, 
                        new DeleteOpptyProductHistoryScheduled());
         System.debug('##---jobId :'+jobId);
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
        System.debug('##---cron trigger :'+ct);

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      //System.assertEquals('2560-07-05 01:00:00', String.valueOf(ct.NextFireTime));
        
      // Verify the scheduled job hasn't run yet.
      system.debug('##---oppProdHis test : '+oppProdHis);
      System.assertEquals(oppProdHis.size(),200);
        
      Test.stopTest();
    }
    
    public static testMethod void BatchDeleteOppProdtest(){
        String query =  'SELECT Id FROM Opportunity_Product_History__c';
        List<Opportunity_Product_History__c> oppProdHis = new List<Opportunity_Product_History__c>();
        for(Integer i = 0; i<200;i++){
        Opportunity_Product_History__c oppProductTemp = new Opportunity_Product_History__c();
		
            oppProductTemp.Deal_Probability__c = '50';
            oppProductTemp.Description__c = 'test Description';
            oppProductTemp.Expected_Fee_Rate__c = 80.5;
            oppProductTemp.Expected_NIM__c = 2.5;
            oppProductTemp.Expected_Revenue__c = 12500;
            oppProductTemp.Expected_Revenue_Fee__c = 2500;
            oppProductTemp.Expected_Revenue_Total__c = 125000.5;
            oppProductTemp.Expected_Util_Year_Fee__c = 80.0;
            oppProductTemp.Expected_Util_Year_NI__c = 80.00;
            oppProductTemp.Expected_Utilization_Vol_Fee__c = 400000.00;
            oppProductTemp.Expected_Utilization_Vol_NI__c = 400000.00;
            oppProductTemp.Quantity__c = 5;
            oppProductTemp.Recurring_Type__c = 'Recurring';
            oppProductTemp.Recurring_Type_Fee__c = 'Recurring';
            oppProductTemp.RevisedStartMonth__c = 'Jan';
            oppProductTemp.RevisedStartMonthFee__c = 'Jan';
            oppProductTemp.RevisedStartYear__c = '2015';
            oppProductTemp.RevisedStartYearFee__c = '2015';
            oppProdHis.add(oppProductTemp);
        }
		insert oppProdHis;
       
        system.debug('##---oppProdHis : '+oppProdHis.size());
        Test.startTest();
        DeleteOpptyProductHistory del = new DeleteOpptyProductHistory(query);
        Database.executeBatch(del);
        Test.stopTest();
        
        Integer count = [SELECT COUNT() FROM Opportunity_Product_History__c];
        System.assertEquals(count, 0);
    }
    
    public static void RunSingleRecord(String query){
        system.debug('##---Run Single Record---');
        List<Opportunity_Product_History__c> oppProdHis = new List<Opportunity_Product_History__c>();
        Opportunity_Product_History__c oppProductTemp = new Opportunity_Product_History__c();

            oppProductTemp.Deal_Probability__c = '50';
            oppProductTemp.Description__c = 'test Description';
            oppProductTemp.Expected_Fee_Rate__c = 80.5;
            oppProductTemp.Expected_NIM__c = 2.5;
            oppProductTemp.Expected_Revenue__c = 12500;
            oppProductTemp.Expected_Revenue_Fee__c = 2500;
            oppProductTemp.Expected_Revenue_Total__c = 125000.5;
            oppProductTemp.Expected_Util_Year_Fee__c = 80.0;
            oppProductTemp.Expected_Util_Year_NI__c = 80.00;
            oppProductTemp.Expected_Utilization_Vol_Fee__c = 400000.00;
            oppProductTemp.Expected_Utilization_Vol_NI__c = 400000.00;
            oppProductTemp.Quantity__c = 5;
            oppProductTemp.Recurring_Type__c = 'Recurring';
            oppProductTemp.Recurring_Type_Fee__c = 'Recurring';
            oppProductTemp.RevisedStartMonth__c = 'Jan';
            oppProductTemp.RevisedStartMonthFee__c = 'Jan';
            oppProductTemp.RevisedStartYear__c = '2015';
            oppProductTemp.RevisedStartYearFee__c = '2015';
            
        oppProdHis.add(oppProductTemp);
		insert oppProdHis;
        system.debug('##---oppProdHis : '+oppProdHis.size());
        //String query = 'SELECT Id FROM Opportunity_Product_History__c WHERE LastModifiedDate = LAST_MONTH';
        DeleteOpptyProductHistory del = new DeleteOpptyProductHistory(query);
		//del.Query = 'SELECT Id FROM Opportunity_Product_History__c WHERE LastModifiedDate = LAST_MONTH';
		Id BatchProcessId = Database.executeBatch(del);
        //--- check record number ---
		List<Opportunity_Product_History__c> recCount = new List<Opportunity_Product_History__c>([SELECT Id FROM Opportunity_Product_History__c WHERE LastModifiedDate = LAST_MONTH]);
		System.assertEquals(recCount.size(),0);
        system.debug('##---recCount : '+recCount.size());
    }
    
    public static void Run200Records(String query){
        system.debug('##---Run 200 Record---');
        List<Opportunity_Product_History__c> oppProdHis = new List<Opportunity_Product_History__c>();
        for(Integer i = 0; i<200;i++){
        Opportunity_Product_History__c oppProductTemp = new Opportunity_Product_History__c();
		
            oppProductTemp.Deal_Probability__c = '50';
            oppProductTemp.Description__c = 'test Description';
            oppProductTemp.Expected_Fee_Rate__c = 80.5;
            oppProductTemp.Expected_NIM__c = 2.5;
            oppProductTemp.Expected_Revenue__c = 12500;
            oppProductTemp.Expected_Revenue_Fee__c = 2500;
            oppProductTemp.Expected_Revenue_Total__c = 125000.5;
            oppProductTemp.Expected_Util_Year_Fee__c = 80.0;
            oppProductTemp.Expected_Util_Year_NI__c = 80.00;
            oppProductTemp.Expected_Utilization_Vol_Fee__c = 400000.00;
            oppProductTemp.Expected_Utilization_Vol_NI__c = 400000.00;
            oppProductTemp.Quantity__c = 5;
            oppProductTemp.Recurring_Type__c = 'Recurring';
            oppProductTemp.Recurring_Type_Fee__c = 'Recurring';
            oppProductTemp.RevisedStartMonth__c = 'Jan';
            oppProductTemp.RevisedStartMonthFee__c = 'Jan';
            oppProductTemp.RevisedStartYear__c = '2015';
            oppProductTemp.RevisedStartYearFee__c = '2015';
            oppProdHis.add(oppProductTemp);
        }
		insert oppProdHis;
       
        system.debug('##---oppProdHis : '+oppProdHis.size());
        //String query = 'SELECT Id FROM Opportunity_Product_History__c WHERE LastModifiedDate = LAST_MONTH';
        DeleteOpptyProductHistory del = new DeleteOpptyProductHistory(query);
		//del.Query = 'SELECT Id FROM Opportunity_Product_History__c WHERE LastModifiedDate = LAST_MONTH';
		Id BatchProcessId = Database.executeBatch(del);
        //--- check record number ---
		List<Opportunity_Product_History__c> recCount = new List<Opportunity_Product_History__c>([SELECT Id FROM Opportunity_Product_History__c WHERE LastModifiedDate = LAST_MONTH]);
		System.assertEquals(recCount.size(),0);
        system.debug('##---recCount : '+recCount.size());
    }
    
    public static void Run500Records(String query){
        system.debug('##---Run 500 Record---');
        List<Opportunity_Product_History__c> oppProdHis = new List<Opportunity_Product_History__c>();
        for(Integer i = 0; i<500;i++){
        Opportunity_Product_History__c oppProductTemp = new Opportunity_Product_History__c();
		
            oppProductTemp.Deal_Probability__c = '50';
            oppProductTemp.Description__c = 'test Description';
            oppProductTemp.Expected_Fee_Rate__c = 80.5;
            oppProductTemp.Expected_NIM__c = 2.5;
            oppProductTemp.Expected_Revenue__c = 12500;
            oppProductTemp.Expected_Revenue_Fee__c = 2500;
            oppProductTemp.Expected_Revenue_Total__c = 125000.5;
            oppProductTemp.Expected_Util_Year_Fee__c = 80.0;
            oppProductTemp.Expected_Util_Year_NI__c = 80.00;
            oppProductTemp.Expected_Utilization_Vol_Fee__c = 400000.00;
            oppProductTemp.Expected_Utilization_Vol_NI__c = 400000.00;
            oppProductTemp.Quantity__c = 5;
            oppProductTemp.Recurring_Type__c = 'Recurring';
            oppProductTemp.Recurring_Type_Fee__c = 'Recurring';
            oppProductTemp.RevisedStartMonth__c = 'Jan';
            oppProductTemp.RevisedStartMonthFee__c = 'Jan';
            oppProductTemp.RevisedStartYear__c = '2015';
            oppProductTemp.RevisedStartYearFee__c = '2015';
            oppProdHis.add(oppProductTemp);
        }
       insert oppProdHis;
        system.debug('##---oppProdHis : '+oppProdHis.size());
        //String query = 'SELECT Id FROM Opportunity_Product_History__c WHERE LastModifiedDate = LAST_MONTH';
        DeleteOpptyProductHistory del = new DeleteOpptyProductHistory(query);
		//del.Query = 'SELECT Id FROM Opportunity_Product_History__c WHERE LastModifiedDate = LAST_MONTH';
		Id BatchProcessId = Database.executeBatch(del);
        //--- check record number ---
		List<Opportunity_Product_History__c> recCount = new List<Opportunity_Product_History__c>([SELECT Id FROM Opportunity_Product_History__c WHERE LastModifiedDate = LAST_MONTH]);
		System.assertEquals(recCount.size(),0);
        system.debug('##---recCount : '+recCount.size());
    }
}