@isTest
public class NIMonthlyPerformanceSyncBatchTest {
    static{
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
        
        List<Monthly_Forecast_Input__c> mfilst = new List<Monthly_Forecast_Input__c>();
        Monthly_Forecast_Input__c existMFI = new  Monthly_Forecast_Input__c();
        existMFI.recordtypeId = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Existing Repay').getRecordTypeId();
        existMFI.Account_Suffix_Ref__c = '001aLT-G1-Acc2';
        existMFI.adjustMonthYear__c = Date.today();
        existMFI.Year__c = String.valueOf(existMFI.adjustMonthYear__c.year());
        existMFI.Month__c = existMFI.adjustMonthYear__c.month() < 10 ? '0' + String.valueOf(existMFI.adjustMonthYear__c.month()) : String.valueOf(existMFI.adjustMonthYear__c.month());
        existMFI.Customer__c =  + existingAccts.get(0).Id;
        existMFI.Product__c =  + prdlst.get(0).Id;
        existMFI.YearMonthAcctSuffRef__c = existMFI.Year__c + existMFI.Month__c + existMFI.Account_Suffix_Ref__c;
        mfilst.add(existMFI);

        Monthly_Forecast_Input__c existMFI2 = new  Monthly_Forecast_Input__c();
        existMFI2.recordtypeId = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Existing Repay').getRecordTypeId();
        existMFI2.Account_Suffix_Ref__c = '001aDeposit-G1-Acc1';
        existMFI2.adjustMonthYear__c = Date.today();
        existMFI2.Year__c = String.valueOf(existMFI2.adjustMonthYear__c.year());
        existMFI2.Month__c = existMFI2.adjustMonthYear__c.month() < 10 ? '0' + String.valueOf(existMFI2.adjustMonthYear__c.month()) : String.valueOf(existMFI2.adjustMonthYear__c.month());
        existMFI2.Customer__c =  + existingAccts.get(0).Id;
        existMFI2.Product__c =  + prdlst.get(1).Id;
        existMFI2.YearMonthAcctSuffRef__c = existMFI2.Year__c + existMFI2.Month__c + existMFI2.Account_Suffix_Ref__c;
        mfilst.add(existMFI2);


        Monthly_Forecast_Input__c existMFI3 = new  Monthly_Forecast_Input__c();
        existMFI3.recordtypeId = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Existing Repay').getRecordTypeId();
        existMFI3.Account_Suffix_Ref__c = '001aDeposit-G1-Acc2';
        existMFI3.adjustMonthYear__c = Date.today().addMonths(-2);
        existMFI3.Year__c = String.valueOf(existMFI3.adjustMonthYear__c.year());
        existMFI3.Month__c = existMFI3.adjustMonthYear__c.month() < 10 ? '0' + String.valueOf(existMFI3.adjustMonthYear__c.month()) : String.valueOf(existMFI3.adjustMonthYear__c.month());
        existMFI3.Current_Ending_Balance__c = 1000;
        existMFI3.Repay_Due_Amount_Week1__c = 100;
        existMFI3.Actual_NIM__c = 1;
        existMFI3.Customer__c = existingAccts.get(0).Id;
        existMFI3.Product__c = prdlst.get(1).Id;
        existMFI3.YearMonthAcctSuffRef__c = existMFI3.Year__c + existMFI3.Month__c + existMFI3.Account_Suffix_Ref__c;
        mfilst.add(existMFI3);
        insert mfilst;

        Monthly_Forecast_Input__c existMFI4 = new  Monthly_Forecast_Input__c();
        existMFI4.recordtypeId = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Existing Repay').getRecordTypeId();
        existMFI4.Account_Suffix_Ref__c = '001aDeposit-G1-Acc2';
        existMFI4.adjustMonthYear__c = Date.today().addMonths(-1);
        existMFI4.Year__c = String.valueOf(existMFI4.adjustMonthYear__c.year());
        existMFI4.Month__c = existMFI4.adjustMonthYear__c.month() < 10 ? '0' + String.valueOf(existMFI4.adjustMonthYear__c.month()) : String.valueOf(existMFI4.adjustMonthYear__c.month());
        existMFI4.Current_Ending_Balance__c = 900;
        existMFI4.Customer__c = existingAccts.get(0).Id;
        existMFI4.Product__c = prdlst.get(1).Id;
        existMFI4.YearMonthAcctSuffRef__c = existMFI4.Year__c + existMFI4.Month__c + existMFI4.Account_Suffix_Ref__c;
        existMFI4.Last_Month_Forecast__c = existMFI3.Id;
        insert existMFI4;

        Monthly_Forecast_Input__c existMFI5 = new  Monthly_Forecast_Input__c();
        existMFI5.recordtypeId = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Existing Repay').getRecordTypeId();
        existMFI5.Account_Suffix_Ref__c = '001aDeposit-G1-Acc2';
        existMFI5.adjustMonthYear__c = Date.today();
        existMFI5.Year__c = String.valueOf(existMFI5.adjustMonthYear__c.year());
        existMFI5.Month__c = existMFI5.adjustMonthYear__c.month() < 10 ? '0' + String.valueOf(existMFI5.adjustMonthYear__c.month()) : String.valueOf(existMFI5.adjustMonthYear__c.month());
        existMFI5.Repay_Due_Amount_Week1__c = 10000;
        existMFI5.Customer__c = existingAccts.get(0).Id;
        existMFI5.Product__c = prdlst.get(1).Id;
        existMFI5.YearMonthAcctSuffRef__c = existMFI5.Year__c + existMFI5.Month__c + existMFI5.Account_Suffix_Ref__c;
        existMFI5.Last_Month_Forecast__c = existMFI4.Id;
        insert existMFI5;

        NI_Monthly_Performance__c niPerf = new NI_Monthly_Performance__c();
        niPerf.As_of_Date__c = Date.today().addMonths(-1);
        niPerf.Account_Suffix_Ref__c = '001aDeposit-G1-Acc2';
        niPerf.YearMonthAcctSuffRef__c = String.valueOf(niPerf.As_of_Date__c.year()) + (niPerf.As_of_Date__c.month() < 10 ? '0' + String.valueOf(niPerf.As_of_Date__c.month()) : String.valueOf(niPerf.As_of_Date__c.month())) + niPerf.Account_Suffix_Ref__c;
        niPerf.TMB_Account_ID__c = '001aDeposit';
        niPerf.TMB_Suffix__c = 'G1';
        niPerf.Average_Balance__c = 2000;
        niPerf.Average_Balance_YTD__c = 2000;
        niPerf.NIIc__c = 0;
        niPerf.NIId__c = 20;
        niPerf.NIId_DPA__c = 20;
        niPerf.DPA__c = 0;
        niPerf.Gross_Rate_Deposit__c = 1;
        niPerf.Gross_Rate_Loan__c = 0;
        niPerf.Unused_Balance__c = 0;
        niPerf.Fund_Transfer__c = 20;
        niPerf.Interest_Revenue__c = 20;
        niPerf.Product_Code__c = 'DEPOSIT';
        niPerf.Product_Key__c = 'DEPOSIT';
        niPerf.Product_Group__c = 'DEPOSIT';
        niPerf.Loan_Status__c = 'DEPOSIT';
        niPerf.SABS_Type__c = 'DEPOSIT';
        niPerf.Origination_Date__c = Date.Today();
        niPerf.TMB_Hold_Commitment__c = 0;
        niPerf.Product__c = prdlst.get(1).Id;
        insert niPerf;

        NI_Monthly_Performance__c niPerf2 = new NI_Monthly_Performance__c();
        niPerf2.As_of_Date__c = Date.today().addMonths(-1);
        niPerf2.Account_Suffix_Ref__c = '001aCREDIT-G1-Acc2';
        niPerf2.YearMonthAcctSuffRef__c = String.valueOf(niPerf.As_of_Date__c.year()) + (niPerf.As_of_Date__c.month() < 10 ? '0' + String.valueOf(niPerf.As_of_Date__c.month()) : String.valueOf(niPerf.As_of_Date__c.month())) + niPerf2.Account_Suffix_Ref__c;
        niPerf2.TMB_Account_ID__c = '001aCREDIT';
        niPerf2.TMB_Suffix__c = 'G1';
        niPerf2.Average_Balance__c = 2000;
        niPerf2.Average_Balance_YTD__c = 2000;
        niPerf2.NIIc__c = 20;
        niPerf2.NIId__c = 0;
        niPerf2.NIId_DPA__c = 0;
        niPerf2.DPA__c = 0;
        niPerf2.Gross_Rate_Deposit__c = 0;
        niPerf2.Gross_Rate_Loan__c = 1;
        niPerf2.Unused_Balance__c = 0;
        niPerf2.Fund_Transfer__c = 20;
        niPerf2.Interest_Revenue__c = 20;
        niPerf2.Product_Code__c = 'CREDIT';
        niPerf2.Product_Key__c = 'CREDIT';
        niPerf2.Product_Group__c = 'CREDIT';
        niPerf2.Loan_Status__c = 'CREDIT';
        niPerf2.SABS_Type__c = 'CREDIT';
        niPerf2.Origination_Date__c = Date.Today();
        niPerf2.TMB_Hold_Commitment__c = 0;
        niPerf2.Product__c = prdlst.get(0).Id;
        insert niPerf2;
    }

    @IsTest
    static void NIMonthlyBatchTest(){
        Test.startTest();
        database.executebatch(new NIMonthlyPerformanceSyncBatch(), 300);
        // database.executebatch(new NIMonthlyPerformanceSyncBatch('SELECT Id, As_of_Date__c, YearMonthAcctSuffRef__c, Average_Balance__c, Average_Balance_YTD__c, NIIc__c, NIId__c, Fund_Transfer__c, Interest_Revenue__c, Product_Code__c, Product_Key__c, Product_Group__c, Loan_Status__c, NIId_DPA__c, DPA__c,  Unused_Balance__c, Gross_Rate_Deposit__c, Gross_Rate_Loan__c, SABS_Type__c, Origination_Date__c, TMB_Hold_Commitment__c, Product__c, Product__r.Financial_Product_Domain__c, Ending_Balance__c, Customer__c, Account_Suffix_Ref__c, TMB_Account_ID__c, TMB_Suffix__c, TMB_Ref__c, Issue_Date__c, Product_Type__c, Limit_Loan__c, Maturity_Date__c FROM NI_Monthly_Performance__c WHERE CreatedDate = TODAY AND isUpdateToMFISuccess__c = false ORDER BY Customer__c, Product__c'), 300);
        Test.stopTest();
    }
}