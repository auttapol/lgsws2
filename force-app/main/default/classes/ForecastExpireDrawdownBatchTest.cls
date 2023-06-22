@isTest
public  class ForecastExpireDrawdownBatchTest {
    static {
        TestUtils.createAppConfig();

        List<Account> existingAccts = TestUtils.createAccounts(1, 'nametestforecast', 'Existing Customer', false);

		existingAccts.get(0).RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();
        existingAccts.get(0).Segment_crm__c = '1';
		
		insert existingAccts;

        List<Product2> prdlst = new List<Product2>();
        Product2 prd = new Product2();
        prd.Name = 'LT Loan';
        prd.isActive = true;
        prd.FLAG_RTL_Product__c = false;
        prd.Financial_Product_Code__c = 'CAH1';
        prd.Financial_Product_Domain__c = 'Credit';
        prd.Financial_Product_Group_Name__c = 'LT Loan';
        prd.Financial_Product_Group__c = 'Loan';
        prd.Financial_Product_ID__c = '110101';
        prd.Forecast_NIIc_NIId_Flag__c = true;
        prd.Remark__c = 'LT loan';
        prd.Sub_Remark__c = 'non-Trade';
        prdlst.add(prd);

        Product2 prd3 = new Product2();
        prd3.Name = 'Deposit';
        prd3.isActive = true;
        prd3.FLAG_RTL_Product__c = false;
        prd3.Financial_Product_Code__c = 'CODE3';
        prd3.Financial_Product_Domain__c = 'Deposit';
        prd3.Financial_Product_Group_Name__c = 'Deposit';
        prd3.Financial_Product_Group__c = 'Deposit';
        prd3.Financial_Product_ID__c = '130101';
        prd3.Forecast_NIIc_NIId_Flag__c = true;
        prd3.Remark__c = '';
        prd3.Sub_Remark__c = '';
        prdlst.add(prd3);
        insert prdlst;

        Monthly_Forecast_Input__c existMFIDD1 = new  Monthly_Forecast_Input__c();
        existMFIDD1.recordtypeId = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Drawdown').getRecordTypeId();
        existMFIDD1.Account_Suffix_Ref__c = '001aDD-G1-Acc1';
        existMFIDD1.adjustMonthYear__c = Date.today().addMonths(-1);
        existMFIDD1.Year__c = String.valueOf(existMFIDD1.adjustMonthYear__c.year());
        existMFIDD1.Month__c = existMFIDD1.adjustMonthYear__c.month() < 10 ? '0' + String.valueOf(existMFIDD1.adjustMonthYear__c.month()) : String.valueOf(existMFIDD1.adjustMonthYear__c.month());
        existMFIDD1.Current_Ending_Balance__c = 1000;
        existMFIDD1.Actual_NIM__c = 1;
        existMFIDD1.Customer__c = existingAccts.get(0).Id;
        existMFIDD1.Product__c = prdlst.get(1).Id;
        existMFIDD1.YearMonthAcctSuffRef__c = existMFIDD1.Year__c + existMFIDD1.Month__c + existMFIDD1.Account_Suffix_Ref__c;
        insert existMFIDD1;
    }

    @IsTest
    static void genForecastInput(){
        Test.startTest();
        database.executebatch(new ForecastExpireDrawdownBatch(Date.newInstance(Date.today().addMonths(-1).year(), Date.today().addMonths(-1).month(), 1)), 500);
        System.schedule('test_ForecastExpireDrawdownBatchScheduler',  '0 0 2 * * ?', new ForecastExpireDrawdownBatchScheduler());
        System.schedule('test_ForecastPipelineDailyScheduler',  '0 0 2 * * ?', new ForecastPipelineDailyScheduler());
        Test.stopTest();
    }
}