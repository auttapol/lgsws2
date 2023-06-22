@isTest
public class ForecastInputSynchronizationBatchTest {
    static{
        TestUtils.createAppConfig();

        List<NIM_Port__c> nimPortlst = new List<NIM_Port__c>();
        nimPortlst.add(new NIM_Port__c(NIMc__c = 0.12, NIMd__c = 0.43, Segment__c = 'SE'));
        insert nimPortlst;

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
        String combkey = existMFI.Year__c + existMFI.Month__c + prdlst.get(0).Financial_Product_Domain__c + prdlst.get(0).Remark__c + existingAccts.get(0).Segment_crm__c + existMFI.Account_Suffix_Ref__c;
        existMFI.Name = combkey.replaceAll( '\\s+', '');
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
        combkey = existMFI2.Year__c + existMFI2.Month__c + prdlst.get(1).Financial_Product_Domain__c + prdlst.get(1).Remark__c + existingAccts.get(0).Segment_crm__c + existMFI2.Account_Suffix_Ref__c;
        existMFI2.Name = combkey.replaceAll( '\\s+', '');
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
        combkey = existMFI3.Year__c + existMFI3.Month__c + prdlst.get(1).Financial_Product_Domain__c + prdlst.get(1).Remark__c + existingAccts.get(0).Segment_crm__c + existMFI3.Account_Suffix_Ref__c;
        existMFI3.Name = combkey.replaceAll( '\\s+', '');
        mfilst.add(existMFI3);
        
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
        combkey = existMFIDD1.Year__c + existMFIDD1.Month__c + prdlst.get(1).Financial_Product_Domain__c + prdlst.get(1).Remark__c + existingAccts.get(0).Segment_crm__c + existMFIDD1.Account_Suffix_Ref__c;
        existMFIDD1.Name = combkey.replaceAll( '\\s+', '');
        mfilst.add(existMFIDD1);

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
        combkey = existMFI4.Year__c + existMFI4.Month__c + prdlst.get(1).Financial_Product_Domain__c + prdlst.get(1).Remark__c + existingAccts.get(0).Segment_crm__c + existMFI3.Account_Suffix_Ref__c;
        existMFI4.Name = combkey.replaceAll( '\\s+', '');
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
        combkey = existMFI5.Year__c + existMFI5.Month__c + prdlst.get(1).Financial_Product_Domain__c + prdlst.get(1).Remark__c + existingAccts.get(0).Segment_crm__c + existMFI5.Account_Suffix_Ref__c;
        existMFI5.Name = combkey.replaceAll( '\\s+', '');
        insert existMFI5;

        Monthly_Forecast_Input__c existMFIDD2 = new  Monthly_Forecast_Input__c();
        existMFIDD2.recordtypeId = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Drawdown').getRecordTypeId();
        existMFIDD2.Account_Suffix_Ref__c = '001aDD-G1-Acc1';
        existMFIDD2.adjustMonthYear__c = Date.today();
        existMFIDD2.Year__c = String.valueOf(existMFIDD2.adjustMonthYear__c.year());
        existMFIDD2.Month__c = existMFIDD2.adjustMonthYear__c.month() < 10 ? '0' + String.valueOf(existMFIDD2.adjustMonthYear__c.month()) : String.valueOf(existMFIDD2.adjustMonthYear__c.month());
        existMFIDD2.Current_Ending_Balance__c = 1000;
        existMFIDD2.Actual_NIM__c = 1;
        existMFIDD2.Customer__c = existingAccts.get(0).Id;
        existMFIDD2.Product__c = prdlst.get(1).Id;
        existMFIDD2.YearMonthAcctSuffRef__c = existMFIDD2.Year__c + existMFIDD2.Month__c + existMFIDD2.Account_Suffix_Ref__c;
        existMFIDD2.Last_Month_Forecast__c = existMFIDD1.Id;
        combkey = existMFIDD2.Year__c + existMFIDD2.Month__c + prdlst.get(1).Financial_Product_Domain__c + prdlst.get(1).Remark__c + existingAccts.get(0).Segment_crm__c + existMFIDD2.Account_Suffix_Ref__c;
        existMFIDD2.Name = combkey.replaceAll( '\\s+', '');
        insert existMFIDD2;
	}

    @IsTest
    static void syncSetSegment(){
        Test.startTest();
        // ForecastInputSynchronizationBatch bat1 = new ForecastInputSynchronizationBatch(Date.today(), new Set<String>{'Deposit', 'Credit'}, new Set<String>{'1', '2', '3', '4', '5', '6', '7', '8'});
        ForecastInputSynchronizationBatch bat1 = new ForecastInputSynchronizationBatch(Date.today(), '', 'Credit', 'LT loan', '1', true);
        database.executebatch(bat1, 300);
        Test.stopTest();
    }

    @IsTest
    static void syncAll(){
        Test.startTest();
        ForecastInputSynchronizationBatch bat2 = new ForecastInputSynchronizationBatch(Date.today().addMonths(-1));
        database.executebatch(bat2, 300);
        Test.stopTest();
    }

    @IsTest
    static void syncSpecificAcct(){
        Test.startTest();
        ForecastInputSynchronizationBatch bat3 = new ForecastInputSynchronizationBatch(Date.today().addMonths(-1), new Set<String>{'001aDD-G1-Acc1'});
        database.executebatch(bat3, 300);
        Test.stopTest();
    }
    
    // @IsTest
    // static void syncAddOnQuery(){
    //     Test.startTest();
    //     string stMainQuery = 'SELECT Id, Year__c, Month__c, RecordtypeId, Recordtype.Name, adjustMonthYear__c, YearMonthAcctSuffRef__c, Account_Suffix_Ref__c, Current_Ending_Balance__c, F_Projected_Balance__c, Last_Month_Ending_Balance__c, Ending_Balance__c, Repay_Due_Amount_Week1__c, Repay_Due_Amount_Week2__c, Repay_Due_Amount_Week3__c, Repay_Due_Amount_Week4__c, Repay_Due_Amount_Week5__c, Repay_Due_Amount_Week6__c, Total_Repay_Due_Amount__c, Hold_Commitment__c, FTP__c, Interest_Income__c, Last_Month_Forecast__c, Actual_NIM__c, Forecast_NIM__c, Last_Month_Forecast__r.Actual_NIM__c, Last_Month_Forecast__r.Forecast_NIM__c, Last_Month_Forecast__r.Hold_Commitment__c, Last_Month_Forecast__r.FTP__c, Last_Month_Forecast__r.Interest_Income__c, Product__r.Financial_Product_Domain__c, Customer__r.Owner.Segment__c, NI_Monthly_Performance__c FROM Monthly_Forecast_Input__c WHERE Product__c != null';
    //     string staddOnquery = '';
    //     ForecastInputSynchronizationBatch bat3 = new ForecastInputSynchronizationBatch(Date.today().addMonths(-1), stMainQuery,staddOnquery);
    //     database.executebatch(bat3, 300);
    //     Test.stopTest();
    // }
}