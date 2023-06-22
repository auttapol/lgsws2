@isTest
public class DepositProductDetailViewController_Test {

    @testSetup 
    static void setup() {
		
    }

    public static String getResponseOSC02 {
        get {
            return '{ "GetDepositAccountResponse": { "AcctInqRs": { "Status": { "StatusCode": "0", "Severity": "Info", "StatusDesc": "Success", "AdditionalStatus": [ { "StatusCode": "0", "ServerStatusCode": "SD3000", "Severity": "Info", "StatusDesc": "Success" }, { "StatusCode": "-1000", "ServerStatusCode": "SD3000", "Severity": "Info", "StatusDesc": "OTHER ACTIVITY TODAY TSPCIMMI" } ] }, "RqUID": "61873ef9-c23c-4858-ad5b-4aa66a589078", "CustId": { "SPName": "IM", "CustPermId": "" }, "UpDt": "2013-12-13T00:00:00+07:00", "LastStmtDt": "2014-03-31", "AcctBal": [ { "BalType": "Avail", "CurAmt": { "Amt": "350250.00", "CurCode": "THB" } }, { "BalType": "AvgLedger", "CurAmt": { "Amt": "200250.00", "CurCode": "THB" } }, { "BalType": "Ledger", "CurAmt": { "Amt": "200250.00", "CurCode": "THB" } }, { "BalType": "Float", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } }, { "BalType": "FloatDay1", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } }, { "BalType": "FloatDay2", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } }, { "BalType": "FloatDay3", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } }, { "BalType": "ClosingLedger", "CurAmt": { "Amt": "350250.00", "CurCode": "THB" } } ], "ExtAcctBal": [ { "ExtBalType": "YTDInterest", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "SavingsYTDInterest", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "UnpaidAccruedInt", "CurAmt": { "Amt": "0.000000", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "LastYrInt", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "IODLastYrInt", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "IODYTDInterest", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "Hold", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "LastStmtBal", "CurAmt": { "Amt": "200250.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" } ], "BankAcctRec": { "DepAcctId": { "AcctId": "00110001024700002471779484", "AcctType": "DDA", "AcctCur": "THB", "BankInfo": { "BankId": "11", "RefInfo": { "RefType": "PrimaryOfficer", "RefId": "00247" }, "BranchId": "247", "BranchName": "" } }, "BankAcctInfo": { "CurCode": "THB", "ContactInfo": { "PhoneNum": { "PhoneType": "Business", "Phone": "022993718" } }, "CustAcctUse": "Retail", "IntRateInfo": { "Rate": "0.000000" }, "ProductId": "IM101" }, "BankAcctStatus": { "BankAcctStatusCode": "Active | ปกติ (Active)" }, "AcctBal": { "BalType": "OnlineCredits", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } } }, "DepAcctRec": { "HoldCount": "0", "LastDepDt": "2013-12-13", "LastDepCurAmt": { "Amt": "200.00", "CurCode": "THB" }, "DepAcctInfo": { "AccountTitle": "นาง ทด สอบ", "OpenDt": "2013-01-17", "EndDt": "2014-04-30T12:00:00.000000-00:00", "TINInfo": { "TINType": "Invalid-NoTIN", "TaxId": "" }, "PostedDt": "2014-04-29", "RelCd": "None", "Language": "", "DepAcctStmtInfo": { "CurrentCycleChecksCnt": "0", "StmtCycleCd": "E", "StmtInst": "0", "CombinedStmtCd": "E00", "Frequency": { "Freq": "EndOfMonth" } }, "PersonInfo": { "NameAddrType": "", "FullName": "นาง ทด สอบ", "ContactInfo": { "PostAddr": { "Addr1": "222/2 ม.2", "Addr2": "ถ.พหลโยธิน", "Addr3": "แขวงจอมพล เขตจตุจักร", "City": "กรุงเทพมหานคร -", "PostalCode": "10900", "Country": "TH", "AddrType": "Mailing" } } }, "HoldIndCode": "0", "WithholdCd": "0", "WithholdReason": "0", "LastMonetaryDt": "2013-12-13", "AcctMiscData": { "AcctMiscType": "NameAddrTrailer", "MiscText": "Primary Name/Address trailer only exists" }, "LastCustActvDt": "2013-12-13", "AccrIODInt": "0.00", "ShrtName": "TOD SOB", "ODLimitAmt": "150000.00", "CurAnnlRate2": "0.000000", "AmountWaived": "0", "WaiveRemaining": "0", "WaiveUsed": "0", "SMSAlertFlag": "N", "OpeningMethod": "0" }, "IndicatorsInfo": "", "AcctBal": { "BalType": "TotalFloat", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } } }, "SavingsTrailerInd": "0", "OverDraftItem": [ { "ODMonth": "1", "Count": "0" }, { "ODMonth": "2", "Count": "0" }, { "ODMonth": "3", "Count": "0" }, { "ODMonth": "4", "Count": "0" }, { "ODMonth": "5", "Count": "0" }, { "ODMonth": "6", "Count": "0" }, { "ODMonth": "7", "Count": "0" }, { "ODMonth": "8", "Count": "0" }, { "ODMonth": "9", "Count": "0" }, { "ODMonth": "10", "Count": "0" }, { "ODMonth": "11", "Count": "0" }, { "ODMonth": "12", "Count": "0" } ], "NSFItem": [ { "NSFMonth": "1", "Count": "0" }, { "NSFMonth": "2", "Count": "0" }, { "NSFMonth": "3", "Count": "0" }, { "NSFMonth": "4", "Count": "0" }, { "NSFMonth": "5", "Count": "0" }, { "NSFMonth": "6", "Count": "0" }, { "NSFMonth": "7", "Count": "0" }, { "NSFMonth": "8", "Count": "0" }, { "NSFMonth": "9", "Count": "0" }, { "NSFMonth": "10", "Count": "0" }, { "NSFMonth": "11", "Count": "0" }, { "NSFMonth": "12", "Count": "0" } ] }, "Datawarehouse": { "AvgOutBal": 0 }, "Status": { "StatusCode": "200", "StatusDesc": "success" } }, "GetDepositAccountDetailResponse": { "Result": { "Status": "SUCCESS", "Message": "", "DepositAccount": { "Status": "SUCCESS", "Message": "", "AccountNumber": "2471779484", "AccountName": "นาง ทด สอบ", "ProductCode": "IM101", "OpenedDate": "2013-01-17+07:00", "AccountStatus": "Active | ปกติ (Active)", "Outstanding": "350250.00", "ODLimit": "150000.00", "Ledger": "200250.00", "InterestRate": "0.000000", "HasJoint": "", "SMSAlertService": "No" }, "JointAccount": { "Status": "SUCCESS", "Message": "" }, "LastMonthTransactionSummary": { "Status": "SUCCESS", "Message": "" }, "Beneficiary": { "Status": "SUCCESS", "Message": "" } } }, "Status": { "StatusCode": "200", "StatusDesc": "success" } }';
        }
    }

    private class OSC02API implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody(getResponseOSC02);
            res.setStatusCode(200);
            return res;
        }
    }


    public class MockResponseOSC01 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String body = 
                '{\n'+
                    '"GetCustomerAccountResponse":{\n'+
                        '"DepositAccounts":{\n'+
                            '"DepositAccount":[\n'+
                                '{\n'+
                                    '"Status":"SUCCESS","AccountNumber":"2471779484","FIIdent":"0011000102470000","ProductType":"com.fnis.xes.IM","ProductCode":"101","OpenedDate":"2013-12-13","AccountStatus":"Active | ปกติ (Active)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00000542332499","FIIdent":"0011000100540200","ProductType":"com.fnis.xes.ST","ProductCode":"200","OpenedDate":"2013-12-31","AccountStatus":"Inactive | ปกติ (Active)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"02473011316001","FIIdent":"0011000102470300","ProductType":"com.fnis.xes.ST","ProductCode":"300","OpenedDate":"2014-03-18","AccountStatus":"Active | ปกติ (Active)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"02473011316002","FIIdent":"0011000102470300","ProductType":"com.fnis.xes.ST","ProductCode":"300","OpenedDate":"2014-02-05","AccountStatus":"Active | ปกติ (Active)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00000017681123","FIIdent":"0011000100010200","ProductType":"com.fnis.xes.ST","ProductCode":"200","OpenedDate":"2013-12-31","AccountStatus":"Dormant | ติดต่อสาขา (Contact Branch)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"SECJNT"},{"Status":"SUCCESS","AccountNumber":"00000292490034","FIIdent":"0011000100290200","ProductType":"com.fnis.xes.ST","ProductCode":"200","OpenedDate":"2013-07-31","AccountStatus":"Dormant | ติดต่อสาขา (Contact Branch)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"SECJNT"},{"Status":"SUCCESS","AccountNumber":"00002332136809","FIIdent":"0011000102330200","ProductType":"com.fnis.xes.ST","ProductCode":"221","OpenedDate":"2013-12-31","AccountStatus":"Inactive | ปกติ (Active)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"SECJNT"}]},"CreditCardAccounts":{"CreditCardAccount":[{"Status":"SUCCESS","CardNumber":"496694006242032105","CreditCardType":"011","OpenedDate":"2008-11-24","AccountStatus":"BLCK C"}]},"LoanAccounts":{"LoanAccount":[{"Status":"SUCCESS","AccountNumber":"00015405889701","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"S700","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00015414618701","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"S700","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00015414626701","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"S700","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00015414642701","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"S700","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00016151011001","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"ABHA","OpenedDate":"2020-01-24","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIJNT"}]},"BancassuranceAccounts":{"BancassuranceAccount":[{"Status":"SUCCESS","SumInsure":"0","AFVP":"0"}]},"InvestmentAccounts":{"InvestmentAccount":[{"Status":"SUCCESS","UnitHoldNo":"PT000000000000000003","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"PT000000000000000012","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"PT000000000000010501","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"PT000000000000103121","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"0010013993","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"0550003552","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"110063000379","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"110233000078","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"111001000034","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"111001010691","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"111324000011","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"}]}},"Status":{"StatusCode":200,"StatusDesc":"success"}}';
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest 
    static void getDepositProductDetail(){
        Test.setMock(HttpCalloutMock.class, new OSC02API());
        // String unmaskB = '{"MarkedOutStanding":true,"MarkedAvgOutStanding":true,"MarkedLedgerBalance":true}';
        // Map<String, Object> unmaskBalance = (Map<String, Object>)JSON.deserializeUntyped(unmaskB);
        // Map<String, Boolean> fieldAccessMap = new Map<String, Boolean>();
        // fieldAccessMap.put('Authorize', true);
        // fieldAccessMap.put('Creditcard_CardActive', true);
        // fieldAccessMap.put('Investment_NavUnit', true);
        // fieldAccessMap.put('Bancassurance_SUM_INSURE', true);
        // fieldAccessMap.put('Bancassurance_POLICY_NO', true);
        // fieldAccessMap.put('ProductSum_Product_Group', true);
        // fieldAccessMap.put('AutoLoan_Status_AutoLoan', true);
        // fieldAccessMap.put('Loan_HasCoBorrower', true);
        // fieldAccessMap.put('Deposit_Other', true);
        // fieldAccessMap.put('AutoLoan_Paid_Period', true);
        // fieldAccessMap.put('Deposit_SubProductGroup', true);
        // fieldAccessMap.put('Bancassurance_EFFECTIVE_DATE', true);
        // fieldAccessMap.put('Investment_MarketValue', true);
        // fieldAccessMap.put('Deposit_Status', true);
        // fieldAccessMap.put('Bancassurance_PRODUCT_GROUP', true);
        // fieldAccessMap.put('Bancassurance_EXPIRY_DATE', true);
        // fieldAccessMap.put('Investment_NumberOfUnit', true);
        // fieldAccessMap.put('ProductSum_Number_of_Account', true);
        // fieldAccessMap.put('AutoLoan_Remain_Period', true);
        // fieldAccessMap.put('ProductSum_MarkedOutstanding', true);
        // fieldAccessMap.put('subDebtTranDetail', true);
        // fieldAccessMap.put('Loan_MarkedLoanAccountNumber', true);
        // fieldAccessMap.put('AutoLoan_HUB', true);
        // fieldAccessMap.put('Creditcard_MarkedCardNumber', true);
        // fieldAccessMap.put('AutoLoan_Installment_Amount', true);
        // fieldAccessMap.put('Loan_SubProductGroup', true);
        // fieldAccessMap.put('Deposit_MarkedLedgerBalance', true);
        // fieldAccessMap.put('Creditcard_MarkedOutstanding', true);
        // fieldAccessMap.put('Investment_IssuerFundHouse', true);
        // fieldAccessMap.put('AutoLoan_HP_Amount', true);
        // fieldAccessMap.put('Creditcard_SubProductGroup', true);
        // fieldAccessMap.put('Loan_ProductName', true);
        // fieldAccessMap.put('Loan_MarkedVLimit', true);
        // fieldAccessMap.put('AutoLoan_Overdue_Amount', true);
        // fieldAccessMap.put('Deposit_ProductName', true);
        // fieldAccessMap.put('ProductSum_Number_of_Product', true);
        // fieldAccessMap.put('ProductSum_MarkedODLimit', true);
        // fieldAccessMap.put('AutoLoan_MarkedOverdue_Amount', true);
        // fieldAccessMap.put('Investment_PercentWeight', true);
        // fieldAccessMap.put('Investment_UnitHolderNo', true);
        // fieldAccessMap.put('Bancassurance_PREMIUM', true);
        // fieldAccessMap.put('Creditcard_ProductName', true);
        // fieldAccessMap.put('Investment_UnrealizedGL', true);
        // fieldAccessMap.put('Deposit_MarkedDepositAccountNumber', true);
        // fieldAccessMap.put('Deposit_MarkedAvgOutStanding', true);
        // fieldAccessMap.put('Loan_Status', true);
        // fieldAccessMap.put('AutoLoan_Outstanding_Amount', true);
        // fieldAccessMap.put('Investment_AverageCostPerUnit', true);
        // fieldAccessMap.put('Bancassurance_STATUS', true);
        // fieldAccessMap.put('Loan_MarkedOutstanding', true);
        // fieldAccessMap.put('Investment_AssetClass', true);
        // fieldAccessMap.put('Loan_convertedMaturityDate', true);
        // fieldAccessMap.put('Creditcard_CardRole', true);
        // fieldAccessMap.put('Deposit_MarkedOutStanding', true);
        // fieldAccessMap.put('Investment_UnrealizedGLPerc', true);
        // fieldAccessMap.put('Investment_CostOfInvestment', true);
        // fieldAccessMap.put('Bancassurance_POLICY_NAME', true);
        // fieldAccessMap.put('Deposit_HasJoint', true);
        // fieldAccessMap.put('AutoLoan_Contract_Period', true);
        // fieldAccessMap.put('Investment_ProductName', true);
        // fieldAccessMap.put('AutoLoan_MarkedHP_Account_No', true);
        // fieldAccessMap.put('Creditcard_MaskedCreditLine', true);
        // fieldAccessMap.put('Creditcard_MarkedVLimit', true);
        // fieldAccessMap.put('Bancassurance_COMPANY_NAME', true);
        Map<String,Object> productFrom01 = new Map<String,Object>();
        productFrom01.put('SeqGrp','2');
        productFrom01.put('Fiident','0011000100010200');
        productFrom01.put('ProductType','com.fnis.xes.ST');
        productFrom01.put('DepositAccountNumber',null);
        productFrom01.put('MarkedDepositAccountNumber','xxx-9-99811-x');
        productFrom01.put('SubProductGroup','NON TRANSACTIONAL');
        productFrom01.put('ProductName','บัญชี ทีทีบี โนฟิกซ์');
        productFrom01.put('HasJoint','PRIIND');
        productFrom01.put('MarkedOutStanding','7xx');
        productFrom01.put('MarkedLedgerBalance','1xx');
        productFrom01.put('MarkedAvgBalanceMTD','7xx');

        // RTL_ProductHoldingSummaryController.DepositProductWrapper dp = new RTL_ProductHoldingSummaryController.DepositProductWrapper();
        // dp.DepositAccountNumber = 'i+hP755weaY0m/XtZBGtfQ==';
        // dp.DepositProductCode = 'bjIp21IekrtZ9XHjx0iJ1A==';
        // dp.FIIdent = '0011000100010200';
        // dp.HasJoint = 'PRIIND';
        // dp.MarkedDepositAccountNumber = 'xxx-9-99811-x';
        // dp.MarkedLedgerBalance = 'Loading...';
        // dp.MarkedAvgOutStanding = '';
        // dp.MarkedOutStanding = '';
        // dp.Other = '';
        // dp.ProductName = 'บัญชี ทีทีบี โนฟิกซ์';
        // dp.ProductType = 'com.fnis.xes.ST';
        // dp.SeqGrp = '2';
        // dp.Status = 'Dormant | ติดต่อสาขา (Contact Branch)';
        // dp.SubProductGroup = 'NON TRANSACTIONAL';
        String accountNumber = SFExtIntregration.encyptText('00000019998111');
        String accountType = SFExtIntregration.encyptText('221');
        Map<String,Object> returnMap = DepositProductDetailViewController.getDepositProductDetail(accountNumber,accountType,'com.fnis.xes.ST','000000000000051187','0011000100010200','001100000000000000000000051187','001p0000010nXLS',productFrom01);

    }

   

    // @isTest
    // static void getDepositProductDetail(){
    //     Map<String,Object> productFrom01 = (Map<String,Object>)RTL_ProductHoldingSummaryController.getProduct('0011s00001Z6aDIAAZ','0000000000166685','0011000000000000','001100000000000000000000166685');
    //     System.debug('productFrom01 : '+productFrom01);
    // }
}