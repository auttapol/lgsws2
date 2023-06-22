@isTest
public without sharing class CustomerProductLists_Test {

    // static fnaProductDetailCtrl testClass;
    static CustomerProductLists customerProdList;

    @isTest
    private static void Test_CustomerProductLists() {
        TestUtils.createAppConfig();

        List<Account> listAccount = new List<Account>();
        Account account = new Account();
        account.Name = 'Mockup Data';
        account.RTL_Office_Phone_Number__c = '012345678';
        account.Mobile_Number_PE__c = '0';
        account.TMB_Customer_ID_PE__c = '001100000000000000000014144590';
        listAccount.add(account);
        insert listAccount;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Customer__c = listAccount[0].Id;
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        List<FNA_Product_Offering__c> listProductOffering = new List<FNA_Product_Offering__c>();
        FNA_Product_Offering__c productOffering = new FNA_Product_Offering__c();
        productOffering.Flag_Offset_product_holding__c = true;
        // productOffering.FNA_Activity__c = listFnaAct[0].Id;
        listProductOffering.add(productOffering);
        insert listProductOffering;

        System.currentPageReference().getParameters().put('itemNumber', '1');
        System.currentPageReference().getParameters().put('accountId', listAccount[0].Id);
        System.currentPageReference().getParameters().put('productType', 'DepositLoan');
        System.currentPageReference().getParameters().put('tabindex', '0');

        String responseBodyOSC14 = '{"status": {"code": "0000","description": "Success"},"accounts": {"deposits": [{"accountTitle": "นาง ทด สอบ","accountNumber": "2471779484","accountType": "DDA","openDate": "2013-12-13","accountStatus": "Active | ปกติ (Active)","productCode": "101","smsAlertEligible": "0","smsAlertRegistered": "0"}],"creditCards": [{"accountTitle": "","accountNumber": "496694006242032105","accountType": "CCA","openDate": "2008-11-24","accountStatus": "BLCK B","productCode": "011"}],"loans": [{"accountTitle": "NAME TEST","accountNumber": "00015405889701","accountType": "LOC","openDate": "9999-12-31","accountStatus": "Active","productCode": "S700"}],"bancassurances": [{"accountTitle": "BLANK","accountNumber": "00000000051187","accountType": "BA","accountStatus": "Active","productCode": ""}],"investments": [{"accountTitle": "BLANK","accountNumber": "PT000000000000000003","accountType": "MFA","accountStatus": "Active | ปกติ (Active)","productCode": "SAS"}],"treasuries": [],"tradeFinances": []}}';
        String responseBodyOSC16 = '{"status": {"code": "0000","description": "Success"},"bancassurances": null,"total": "0"}';

        customerProdList = new CustomerProductLists();

        customerProdList.fnaActivityId = listFnaAct[0].Id;
        customerProdList.caseProductBancassurance = null;
        customerProdList.caseProductInvestment = null;
        customerProdList.productBAs = null;
        customerProdList.productInvestment = null;
        customerProdList.productAccounts = CaseAccountProduct.parseJsonToObj(responseBodyOSC14);
        customerProdList.searchProduct1 = 'test';
        customerProdList.searchProduct2 = 'test';
        customerProdList.searchProduct3 = 'test';

        customerProdList.setupCustomerList();
        customerProdList.getcaseProductDepositAndLoanList();

        customerProdList.searchProductNumber();
        customerProdList.clearSearch();
        customerProdList.setPaginationObj();
        customerProdList.nextBA();
        customerProdList.nextInvestment();
        // customerProdList.previousDepositAndLoan(); //List index out of bound -10
        // customerProdList.previousBA(); //List index out of bound -10
        // customerProdList.previousInvestment(); //List index out of bound -10
        String strData = 'TEST';
        String strFind = 'TEST';
        Boolean containResult = CustomerProductLists.containsIgnoreCase(strData,strFind);

        customerProdList.tmbCustomerID = '001100000000000000000001184383';
        Continuation conti = (Continuation) customerProdList.startCallCaseProductDeposit2();
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"GetCustomerAccountResponse":{"DepositAccounts":{"DepositAccount":[{"Status":"SUCCESS","AccountNumber":"2471779484","FIIdent":"0011000102470000","ProductType":"com.fnis.xes.IM","ProductCode":"101","OpenedDate":"2013-12-13","AccountStatus":"Active | \u0e1b\u0e01\u0e15\u0e34 (Active)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00000017681123","FIIdent":"0011000100010200","ProductType":"com.fnis.xes.ST","ProductCode":"200","OpenedDate":"2013-12-31","AccountStatus":"Dormant | \u0e15\u0e34\u0e14\u0e15\u0e48\u0e2d\u0e2a\u0e32\u0e02\u0e32 (Contact Branch)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"SECJNT"}]},"CreditCardAccounts":{"CreditCardAccount":[{"Status":"SUCCESS","CardNumber":"496694006242032105","CreditCardType":"011","OpenedDate":"2008-11-24","AccountStatus":"BLCK C"}]},"LoanAccounts":{"LoanAccount":[{"Status":"SUCCESS","AccountNumber":"00015414642701","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"S700","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00016151011001","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"ABHA","OpenedDate":"2020-02-24","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIJNT"}]},"BancassuranceAccounts":{"BancassuranceAccount":[{"Status":"SUCCESS","SumInsure":"0","AFVP":"0"}]},"InvestmentAccounts":{"InvestmentAccount":[{"Status":"SUCCESS","UnitHoldNo":"PT000000000000000003","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"}]}},"Status":{"StatusCode":200,"StatusDesc":"success"}}');
        Test.setContinuationResponse(customerProdList.requestLabel, response);
        Object result = Test.invokeContinuationMethod(customerProdList, conti);
        
        conti = (Continuation) customerProdList.startCallCaseProductBA2();
        response.setBody('{"GetBancassuranceAccountResponse":{"InsurancePolicyListCRMInqResponse":{"InsurancePolicyListCRMInqResult":{"Message":{"REQUEST_NO":"1","STATUS_CODE":"0000","STATUS_NAME":"Success"},"DataSets":[{"POLICY_NO":"17-59342724","POLICY_NAME":"Travel Insurance (Silver) - Trip","STATUS":"Active","COMPANY_NAME":"Thai Cardif Life Insurance","PRODUCT_GROUP":"","EFFECTIVE_DATE":"","EXPIRY_DATE":"","SUM_INSURE":"1500000","INSURE_TYPE":"TAST001","EMP_ID":"","NEXT_PAYMENT_DATE":"","NEXT_INTERIM_DATE":"","NEXT_INTERIM_AMOUNT":"0","TOTAL_PREMIUM_PAID":"1270","PAYMODE3":"01","PAYMENT_TYPE":"Single","PAYMENT_TERM":" of 1","PAYMENT_DATE":"","PAYMENT_METHOD":"Cash","PAYMENT_FREQUENCY_AMOUNT":"1270","PREMIUM":"1270","INTERIM_PAY_AMOUNT":"","BENEFICIARY":"","BENEFICIARY_RELATION":"","INSURED_ADDRESS":"18","INSURED_STREET":"","INSURED_DISTRICT":"","INSURED_AMPHUR":"","INSURED_PROVINCE":"","INSURED_POSTCODE":"12110","CAR_MODEL":"","CARBRAND":"","REGISTERPLATENUMBER":"","YEAR_OF_MANUFACTURE":""}]}},"Status":{"StatusCode":"200","StatusDesc":"success"}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');  
        Test.setContinuationResponse(customerProdList.requestLabel, response);
        result = Test.invokeContinuationMethod(customerProdList, conti);
 
        List<String> responseBodies = new List<String>();
        responseBodies.add('{"GetInvestmentAccountResponse":{"percOfFundType":{"Balanced":"0.0","ForeignEquity":"1.0","ForeignFixedIncome":"0.0","LocalEquity":"0.0","LocalFixedIncome":null,"Others":"1"},"listFundClass":{"FundClass":[{"FundClassCode":"100","FundClassNameEN":"Local Fixed Income","FundClassNameTH":"","listFundHouse":{"FundHouse":[{"FundHouseCode":"UOBAMTH","listFundCode":{"FundCode":{"UnitHolderNo":"AP000000000000561258","FundCode":"TCMF","FundNameTH":"Thai Cash Management Fund","FundNameEN":"","FundNickNameTH":"Thai Cash Management Fund","FundNickNameEN":"","FundShortName":"TCMF","UnrealizedProfit":"1.41","MarketValue":"0.0"}}}]}}]},"GetFundDetails":[{"FundCode":"TCMF","OrderToBeProcess":null,"detailFund":{"DateAsOf":"","Unit":"0","Nav":"15.0760","Cost":"0","InvestmentValue":"0","UnrealizedProfit":"0","UnrealizedProfitPerc":"0","TaxDoc":"N","UnitLTF5Y":"0","FundHouseCode":"UOBAMTH","UnitHolderNo":"AP000000000000561258","FundNameTH":"","FundNameEN":"Thai Cash Management Fund"}}],"Status":{"StatusCode":"200","StatusDesc":"success"}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
        List<String> unitHolderNoList = new List<String>();
        unitHolderNoList.add('AP000000000000561258');
        customerProdList.processResponseWsInvestment(responseBodies,unitHolderNoList);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
        String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;
        customerProdList.startCallCaseProductInvestment2();
 		Test.stopTest();
    }

    @isTest
    private static void Test_searchProductNumber_DepositLoan() {
        // customerProdList = new CustomerProductLists();
        // customerProdList.clearSearch();
    }

    @isTest
    private static void Test_searchProductNumber_Bancassurance() {
        System.currentPageReference().getParameters().put('productType', 'Bancassurance');
        customerProdList = new CustomerProductLists();
        String responseBodyOSC14 = '{"status": {"code": "0000","description": "Success"},"accounts": {"deposits": [{"accountTitle": "นาง ทด สอบ","accountNumber": "2471779484","accountType": "DDA","openDate": "2013-12-13","accountStatus": "Active | ปกติ (Active)","productCode": "101","smsAlertEligible": "0","smsAlertRegistered": "0"}],"creditCards": [{"accountTitle": "","accountNumber": "496694006242032105","accountType": "CCA","openDate": "2008-11-24","accountStatus": "BLCK B","productCode": "011"}],"loans": [{"accountTitle": "NAME TEST","accountNumber": "00015405889701","accountType": "LOC","openDate": "9999-12-31","accountStatus": "Active","productCode": "S700"}],"bancassurances": [{"accountTitle": "BLANK","accountNumber": "00000000051187","accountType": "BA","accountStatus": "Active","productCode": ""}],"investments": [{"accountTitle": "BLANK","accountNumber": "PT000000000000000003","accountType": "MFA","accountStatus": "Active | ปกติ (Active)","productCode": "SAS"}],"treasuries": [],"tradeFinances": []}}';
        customerProdList.productAccounts = CaseAccountProduct.parseJsonToObj(responseBodyOSC14);
        customerProdList.searchProductNumber();
        customerProdList.clearSearch();
    }

    @isTest
    private static void Test_searchProductNumber_Investment() {
        System.currentPageReference().getParameters().put('productType', 'Investment');
        customerProdList = new CustomerProductLists();
        String responseBodyOSC14 = '{"status": {"code": "0000","description": "Success"},"accounts": {"deposits": [{"accountTitle": "นาง ทด สอบ","accountNumber": "2471779484","accountType": "DDA","openDate": "2013-12-13","accountStatus": "Active | ปกติ (Active)","productCode": "101","smsAlertEligible": "0","smsAlertRegistered": "0"}],"creditCards": [{"accountTitle": "","accountNumber": "496694006242032105","accountType": "CCA","openDate": "2008-11-24","accountStatus": "BLCK B","productCode": "011"}],"loans": [{"accountTitle": "NAME TEST","accountNumber": "00015405889701","accountType": "LOC","openDate": "9999-12-31","accountStatus": "Active","productCode": "S700"}],"bancassurances": [{"accountTitle": "BLANK","accountNumber": "00000000051187","accountType": "BA","accountStatus": "Active","productCode": ""}],"investments": [{"accountTitle": "BLANK","accountNumber": "PT000000000000000003","accountType": "MFA","accountStatus": "Active | ปกติ (Active)","productCode": "SAS"}],"treasuries": [],"tradeFinances": []}}';
        customerProdList.productAccounts = CaseAccountProduct.parseJsonToObj(responseBodyOSC14);
        customerProdList.searchProductNumber();
        customerProdList.clearSearch();
    }

    @isTest
    private static void Test_setPaginationObj() {
        System.currentPageReference().getParameters().put('tabindex', '0');
        customerProdList = new CustomerProductLists();
        customerProdList.setPaginationObj();
    }

    @isTest
    private static void Test_setPaginationObj_1() {
        System.currentPageReference().getParameters().put('tabindex', '-1');
        customerProdList = new CustomerProductLists();
        customerProdList.setPaginationObj();
    }
}