@isTest
public class GenerateForecastInputBatchTest {
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

        List<Product_Volume_Information__c> prdVollst = new List<Product_Volume_Information__c>();

        Product_Volume_Information__c prdVol = new Product_Volume_Information__c();
        prdVol.Account_Status_Desc__c = 'Account_Status_Desc__c';
        prdVol.Account_Suffix_Ref__c = '001aLT-G1-Acc1';
        prdVol.As_of_Date__c = Date.today().addMonths(-1);
        prdVol.Average_Balance_BE__c = 0;
        prdVol.Average_Balance_Deposit__c = 0;
        prdVol.Average_Balance_Loan__c = 1000000;
        prdVol.Business_Readiness_Level_BRL__c = 'High';
        prdVol.Current_4G__c = '01.Guard';
        prdVol.Customer__c = existingAccts.get(0).Id;
        prdVol.Ending_Balance_BE__c = 0;
        prdVol.Ending_Balance_Deposit__c = 0;
        prdVol.Ending_Balance_Loan__c = 1000000;
        prdVol.Gross_Rate__c = 0;
        prdVol.Interest_Revenue__c = 0;
        prdVol.Issue_Date__c = Date.today().addDays(-2);
        prdVol.Liability_O_S__c = 0;
        prdVol.Limit_Loan__c = 1000000;
        prdVol.Loan_Status__c = 'PL';
        prdVol.Maturity_Date__c = Date.today().addYears(1);
        prdVol.Origination_Date__c = Date.today().addDays(-2);
        prdVol.Product_Code__c = 'CAH1';
        prdVol.Product_Group__c = 'Loan';
        prdVol.Product_ID__c = '78998';
        prdVol.Product_Type__c = 'LT Loan';
        prdVol.Product__c = prdlst.get(0).Id;
        prdVol.RPN_Type__c = '';
        prdVol.SABS_Type__c = 'BU';
        prdVol.TMB_Account_ID__c = '001';
        prdVol.TMB_Ref__c = 'a';
        prdVol.TMB_Suffix__c = 'LT-G1-Acc1';
        prdVol.Unused_Balance__c  = 0;
        prdVollst.add(prdVol);

        Product_Volume_Information__c prdVol2 = new Product_Volume_Information__c();
        prdVol2.Account_Status_Desc__c = 'Account_Status_Desc__c';
        prdVol2.Account_Suffix_Ref__c = '001aLT-G1-Acc2';
        prdVol2.As_of_Date__c = Date.today().addMonths(-1);
        prdVol2.Average_Balance_BE__c = 0;
        prdVol2.Average_Balance_Deposit__c = 0;
        prdVol2.Average_Balance_Loan__c = 1000000;
        prdVol2.Business_Readiness_Level_BRL__c = 'High';
        prdVol2.Current_4G__c = '01.Guard';
        prdVol2.Customer__c = existingAccts.get(0).Id;
        prdVol2.Ending_Balance_BE__c = 0;
        prdVol2.Ending_Balance_Deposit__c = 0;
        prdVol2.Ending_Balance_Loan__c = 1000000;
        prdVol2.Gross_Rate__c = 0;
        prdVol2.Interest_Revenue__c = 0;
        prdVol2.Issue_Date__c = Date.today().addDays(-2);
        prdVol2.Liability_O_S__c = 0;
        prdVol2.Limit_Loan__c = 1000000;
        prdVol2.Loan_Status__c = 'PL';
        prdVol2.Maturity_Date__c = Date.today().addYears(1);
        prdVol2.Origination_Date__c = Date.today().addDays(-2);
        prdVol2.Product_Code__c = 'CAH1';
        prdVol2.Product_Group__c = 'Loan';
        prdVol2.Product_ID__c = '78998';
        prdVol2.Product_Type__c = 'LT Loan';
        prdVol2.Product__c = prdlst.get(0).Id;
        prdVol2.RPN_Type__c = '';
        prdVol2.SABS_Type__c = 'BU';
        prdVol2.TMB_Account_ID__c = '001';
        prdVol2.TMB_Ref__c = 'a';
        prdVol2.TMB_Suffix__c = 'LT-G1-Acc2';
        prdVol2.Unused_Balance__c  = 0;
        prdVollst.add(prdVol2);

        Product_Volume_Information__c prdVol3 = new Product_Volume_Information__c();
        prdVol3.Account_Status_Desc__c = 'Account_Status_Desc__c';
        prdVol3.Account_Suffix_Ref__c = '001aDeposit-G1-Acc1';
        prdVol3.As_of_Date__c = Date.today().addMonths(-1);
        prdVol3.Average_Balance_BE__c = 1000000;
        prdVol3.Average_Balance_Deposit__c = 0;
        prdVol3.Average_Balance_Loan__c = 0;
        prdVol3.Business_Readiness_Level_BRL__c = 'High';
        prdVol3.Current_4G__c = '01.Guard';
        prdVol3.Customer__c = existingAccts.get(0).Id;
        prdVol3.Ending_Balance_BE__c = 1000000;
        prdVol3.Ending_Balance_Deposit__c = 0;
        prdVol3.Ending_Balance_Loan__c = 0;
        prdVol3.Gross_Rate__c = 0;
        prdVol3.Interest_Revenue__c = 0;
        prdVol3.Issue_Date__c = Date.today().addDays(-2);
        prdVol3.Liability_O_S__c = 0;
        prdVol3.Limit_Loan__c = 1000000;
        prdVol3.Loan_Status__c = 'PL';
        prdVol3.Maturity_Date__c = Date.today().addYears(1);
        prdVol3.Origination_Date__c = Date.today().addDays(-2);
        prdVol3.Product_Code__c = 'Deposit';
        prdVol3.Product_Group__c = 'Deposit';
        prdVol3.Product_ID__c = '78998';
        prdVol3.Product_Type__c = 'Deposit';
        prdVol3.Product__c = prdlst.get(1).Id;
        prdVol3.RPN_Type__c = '';
        prdVol3.SABS_Type__c = 'BU';
        prdVol3.TMB_Account_ID__c = '001';
        prdVol3.TMB_Ref__c = 'a';
        prdVol3.TMB_Suffix__c = 'Dep-G1-Acc1';
        prdVol3.Unused_Balance__c  = 0;
        prdVollst.add(prdVol3);

        Product_Volume_Information__c prdVol4 = new Product_Volume_Information__c();
        prdVol4.Account_Status_Desc__c = 'Account_Status_Desc__c';
        prdVol4.Account_Suffix_Ref__c = '001aDeposit-G1-Acc2';
        prdVol4.As_of_Date__c = Date.today().addMonths(-1);
        prdVol4.Average_Balance_BE__c = 1000000;
        prdVol4.Average_Balance_Deposit__c = 0;
        prdVol4.Average_Balance_Loan__c = 0;
        prdVol4.Business_Readiness_Level_BRL__c = 'High';
        prdVol4.Current_4G__c = '01.Guard';
        prdVol4.Customer__c = existingAccts.get(0).Id;
        prdVol4.Ending_Balance_BE__c = 0;
        prdVol4.Ending_Balance_Deposit__c = 1000000;
        prdVol4.Ending_Balance_Loan__c = 0;
        prdVol4.Gross_Rate__c = 0;
        prdVol4.Interest_Revenue__c = 0;
        prdVol4.Issue_Date__c = Date.today().addDays(-2);
        prdVol4.Liability_O_S__c = 0;
        prdVol4.Limit_Loan__c = 1000000;
        prdVol4.Loan_Status__c = '';
        prdVol4.Maturity_Date__c = Date.today().addYears(1);
        prdVol4.Origination_Date__c = Date.today().addDays(-2);
        prdVol4.Product_Code__c = 'Deposit';
        prdVol4.Product_Group__c = 'Deposit';
        prdVol4.Product_ID__c = '78998';
        prdVol4.Product_Type__c = 'Deposit';
        prdVol4.Product__c = prdlst.get(1).Id;
        prdVol4.RPN_Type__c = '';
        prdVol4.SABS_Type__c = 'BU';
        prdVol4.TMB_Account_ID__c = '001';
        prdVol4.TMB_Ref__c = 'a';
        prdVol4.TMB_Suffix__c = 'Dep-G1-Acc2';
        prdVol4.Unused_Balance__c  = 0;
        prdVollst.add(prdVol4);

        insert prdVollst;

        Monthly_Forecast_Input__c existMFI = new  Monthly_Forecast_Input__c();
        existMFI.recordtypeId = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Existing Repay').getRecordTypeId();
        existMFI.Account_Suffix_Ref__c = '001aLT-G1-Acc2';
        existMFI.adjustMonthYear__c = Date.today();
        existMFI.Year__c = String.valueOf(existMFI.adjustMonthYear__c.year());
        existMFI.Month__c = existMFI.adjustMonthYear__c.month() < 10 ? '0' + String.valueOf(existMFI.adjustMonthYear__c.month()) : String.valueOf(existMFI.adjustMonthYear__c.month());
        existMFI.Customer__c =  + existingAccts.get(0).Id;
        existMFI.YearMonthAcctSuffRef__c = existMFI.Year__c + existMFI.Month__c + existMFI.Account_Suffix_Ref__c;
        insert existMFI;

        Monthly_Forecast_Input__c existMFI2 = new  Monthly_Forecast_Input__c();
        existMFI2.recordtypeId = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Existing Repay').getRecordTypeId();
        existMFI2.Account_Suffix_Ref__c = '001aDeposit-G1-Acc1';
        existMFI2.adjustMonthYear__c = Date.today();
        existMFI2.Year__c = String.valueOf(existMFI2.adjustMonthYear__c.year());
        existMFI2.Month__c = existMFI2.adjustMonthYear__c.month() < 10 ? '0' + String.valueOf(existMFI2.adjustMonthYear__c.month()) : String.valueOf(existMFI2.adjustMonthYear__c.month());
        existMFI2.Customer__c =  + existingAccts.get(0).Id;
        existMFI2.YearMonthAcctSuffRef__c = existMFI2.Year__c + existMFI2.Month__c + existMFI2.Account_Suffix_Ref__c;
        insert existMFI2;

        Monthly_Forecast_Input__c existMFI3 = new  Monthly_Forecast_Input__c();
        existMFI3.recordtypeId = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('Existing Repay').getRecordTypeId();
        existMFI3.Account_Suffix_Ref__c = '001aDeposit-G1-Acc2';
        existMFI3.adjustMonthYear__c = Date.today();
        existMFI3.Year__c = String.valueOf(existMFI3.adjustMonthYear__c.year());
        existMFI3.Month__c = existMFI3.adjustMonthYear__c.month() < 10 ? '0' + String.valueOf(existMFI3.adjustMonthYear__c.month()) : String.valueOf(existMFI3.adjustMonthYear__c.month());
        existMFI3.Customer__c =  + existingAccts.get(0).Id;
        existMFI3.YearMonthAcctSuffRef__c = existMFI3.Year__c + existMFI3.Month__c + existMFI3.Account_Suffix_Ref__c;
        insert existMFI3;
	}

    @IsTest
    static void genForecastInput(){
        String mainQuery = 'SELECT Id, Name, As_of_Date__c, Customer__c,Customer__r.Segment_crm__c, Account_Suffix_Ref__c, TMB_Account_ID__c, TMB_Suffix__c, TMB_Ref__c, Product_Type__c, Loan_Status__c, Limit_Loan__c, Ending_Balance_BE__c, Ending_Balance_Deposit__c, Ending_Balance_Loan__c, Average_Balance_BE__c, Average_Balance_Deposit__c, Average_Balance_Loan__c,Product_Group__c, Gross_Rate__c, Interest_Revenue__c, Product_Code__c, Issue_Date__c, Maturity_Date__c, Origination_Date__c, Account_Status_Desc__c, Liability_O_S__c, Unused_Balance__c,RPN_Type__c, SABS_Type__c, Current_4G__c, Business_Readiness_Level_BRL__c, Product__c, Product__r.Financial_Product_Domain__c, Product__r.Remark__c FROM Product_Volume_Information__c ';
        String addOnFilter = '';
        String orderByQuery = 'ORDER BY Customer__c, Product__c';
        
        String queryGenerate = mainQuery + ' '  + addOnFilter + ' ' + orderByQuery;
        
        String prodDomain = 'Credit';
        String prodRemark = 'LT loan';
        String customerSegment = '';
        Boolean runSync = true;

        Integer batchSize = 200;
        Integer priority = 1;

        
        Test.startTest();
        GenerateForecastInputBatch instance = new GenerateForecastInputBatch(queryGenerate, addOnFilter, prodDomain, prodRemark, customerSegment, runSync);

        database.executebatch(instance, 300);
        Test.stopTest();
    }
}