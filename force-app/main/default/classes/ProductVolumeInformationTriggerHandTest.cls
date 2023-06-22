@isTest
global class ProductVolumeInformationTriggerHandTest {
    static{
        TestUtils.createAppConfig();
        
        
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';        
        insert Aconfig;
    }

    @IsTest
    static void testCreateProdVol(){
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
        insert prdlst;

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

        Test.startTest();
        insert prdVol;
        Test.stopTest();
    }
}