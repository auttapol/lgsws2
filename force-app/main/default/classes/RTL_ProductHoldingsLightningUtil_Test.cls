@isTest
public class RTL_ProductHoldingsLightningUtil_Test {

    @testSetup static void setup() {
		TestUtils.createAppConfig();

		List<AppConfig__c> mc = new List<AppConfig__c> ();
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        insert mc;
    }

    public static String getResponseOSC01 {
        get {
            return '{"GetCustomerAccountResponse":{"DepositAccounts":{"DepositAccount":[{"Status":"SUCCESS","AccountNumber":"2471779484","FIIdent":"0011000102470000","ProductType":"com.fnis.xes.IM","ProductCode":"101","OpenedDate":"2013-12-13","AccountStatus":"Active | ปกติ (Active)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00000542332499","FIIdent":"0011000100540200","ProductType":"com.fnis.xes.ST","ProductCode":"200","OpenedDate":"2013-12-31","AccountStatus":"Inactive | ปกติ (Active)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"02473011316001","FIIdent":"0011000102470300","ProductType":"com.fnis.xes.ST","ProductCode":"300","OpenedDate":"2014-03-18","AccountStatus":"Active | ปกติ (Active)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"02473011316002","FIIdent":"0011000102470300","ProductType":"com.fnis.xes.ST","ProductCode":"300","OpenedDate":"2014-02-05","AccountStatus":"Active | ปกติ (Active)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00000017681123","FIIdent":"0011000100010200","ProductType":"com.fnis.xes.ST","ProductCode":"200","OpenedDate":"2013-12-31","AccountStatus":"Dormant | ติดต่อสาขา (Contact Branch)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"SECJNT"},{"Status":"SUCCESS","AccountNumber":"00000292490034","FIIdent":"0011000100290200","ProductType":"com.fnis.xes.ST","ProductCode":"200","OpenedDate":"2013-07-31","AccountStatus":"Dormant | ติดต่อสาขา (Contact Branch)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"SECJNT"},{"Status":"SUCCESS","AccountNumber":"00002332136809","FIIdent":"0011000102330200","ProductType":"com.fnis.xes.ST","ProductCode":"221","OpenedDate":"2013-12-31","AccountStatus":"Inactive | ปกติ (Active)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"SECJNT"}]},"CreditCardAccounts":{"CreditCardAccount":[{"Status":"SUCCESS","CardNumber":"496694006242032105","CreditCardType":"011","OpenedDate":"2008-11-24","AccountStatus":"BLCK C"}]},"LoanAccounts":{"LoanAccount":[{"Status":"SUCCESS","AccountNumber":"00015405889701","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"S700","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00015414618701","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"S700","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00015414626701","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"S700","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00015414642701","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"S700","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00016151011001","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"ABHA","OpenedDate":"2020-01-24","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIJNT"}]},"BancassuranceAccounts":{"BancassuranceAccount":[{"Status":"SUCCESS","SumInsure":"0","AFVP":"0"}]},"InvestmentAccounts":{"InvestmentAccount":[{"Status":"SUCCESS","UnitHoldNo":"PT000000000000000003","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"PT000000000000000012","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"PT000000000000010501","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"PT000000000000103121","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"0010013993","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"0550003552","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"110063000379","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"110233000078","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"111001000034","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"111001010691","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"111324000011","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"}]}},"Status":{"StatusCode":200,"StatusDesc":"success"}}';
        }
    }
    public static String getResponseOSC02 {
        get {
            return '{ "GetDepositAccountResponse": { "AcctInqRs": { "Status": { "StatusCode": "0", "Severity": "Info", "StatusDesc": "Success", "AdditionalStatus": [ { "StatusCode": "0", "ServerStatusCode": "SD3000", "Severity": "Info", "StatusDesc": "Success" }, { "StatusCode": "-1000", "ServerStatusCode": "SD3000", "Severity": "Info", "StatusDesc": "OTHER ACTIVITY TODAY TSPCIMMI" } ] }, "RqUID": "61873ef9-c23c-4858-ad5b-4aa66a589078", "CustId": { "SPName": "IM", "CustPermId": "" }, "UpDt": "2013-12-13T00:00:00+07:00", "LastStmtDt": "2014-03-31", "AcctBal": [ { "BalType": "Avail", "CurAmt": { "Amt": "350250.00", "CurCode": "THB" } }, { "BalType": "AvgLedger", "CurAmt": { "Amt": "200250.00", "CurCode": "THB" } }, { "BalType": "Ledger", "CurAmt": { "Amt": "200250.00", "CurCode": "THB" } }, { "BalType": "Float", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } }, { "BalType": "FloatDay1", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } }, { "BalType": "FloatDay2", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } }, { "BalType": "FloatDay3", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } }, { "BalType": "ClosingLedger", "CurAmt": { "Amt": "350250.00", "CurCode": "THB" } } ], "ExtAcctBal": [ { "ExtBalType": "YTDInterest", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "SavingsYTDInterest", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "UnpaidAccruedInt", "CurAmt": { "Amt": "0.000000", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "LastYrInt", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "IODLastYrInt", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "IODYTDInterest", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "Hold", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "LastStmtBal", "CurAmt": { "Amt": "200250.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" } ], "BankAcctRec": { "DepAcctId": { "AcctId": "00110001024700002471779484", "AcctType": "DDA", "AcctCur": "THB", "BankInfo": { "BankId": "11", "RefInfo": { "RefType": "PrimaryOfficer", "RefId": "00247" }, "BranchId": "247", "BranchName": "" } }, "BankAcctInfo": { "CurCode": "THB", "ContactInfo": { "PhoneNum": { "PhoneType": "Business", "Phone": "022993718" } }, "CustAcctUse": "Retail", "IntRateInfo": { "Rate": "0.000000" }, "ProductId": "IM101" }, "BankAcctStatus": { "BankAcctStatusCode": "Active | ปกติ (Active)" }, "AcctBal": { "BalType": "OnlineCredits", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } } }, "DepAcctRec": { "HoldCount": "0", "LastDepDt": "2013-12-13", "LastDepCurAmt": { "Amt": "200.00", "CurCode": "THB" }, "DepAcctInfo": { "AccountTitle": "นาง ทด สอบ", "OpenDt": "2013-01-17", "EndDt": "2014-04-30T12:00:00.000000-00:00", "TINInfo": { "TINType": "Invalid-NoTIN", "TaxId": "" }, "PostedDt": "2014-04-29", "RelCd": "None", "Language": "", "DepAcctStmtInfo": { "CurrentCycleChecksCnt": "0", "StmtCycleCd": "E", "StmtInst": "0", "CombinedStmtCd": "E00", "Frequency": { "Freq": "EndOfMonth" } }, "PersonInfo": { "NameAddrType": "", "FullName": "นาง ทด สอบ", "ContactInfo": { "PostAddr": { "Addr1": "222/2 ม.2", "Addr2": "ถ.พหลโยธิน", "Addr3": "แขวงจอมพล เขตจตุจักร", "City": "กรุงเทพมหานคร -", "PostalCode": "10900", "Country": "TH", "AddrType": "Mailing" } } }, "HoldIndCode": "0", "WithholdCd": "0", "WithholdReason": "0", "LastMonetaryDt": "2013-12-13", "AcctMiscData": { "AcctMiscType": "NameAddrTrailer", "MiscText": "Primary Name/Address trailer only exists" }, "LastCustActvDt": "2013-12-13", "AccrIODInt": "0.00", "ShrtName": "TOD SOB", "ODLimitAmt": "150000.00", "CurAnnlRate2": "0.000000", "AmountWaived": "0", "WaiveRemaining": "0", "WaiveUsed": "0", "SMSAlertFlag": "N", "OpeningMethod": "0" }, "IndicatorsInfo": "", "AcctBal": { "BalType": "TotalFloat", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } } }, "SavingsTrailerInd": "0", "OverDraftItem": [ { "ODMonth": "1", "Count": "0" }, { "ODMonth": "2", "Count": "0" }, { "ODMonth": "3", "Count": "0" }, { "ODMonth": "4", "Count": "0" }, { "ODMonth": "5", "Count": "0" }, { "ODMonth": "6", "Count": "0" }, { "ODMonth": "7", "Count": "0" }, { "ODMonth": "8", "Count": "0" }, { "ODMonth": "9", "Count": "0" }, { "ODMonth": "10", "Count": "0" }, { "ODMonth": "11", "Count": "0" }, { "ODMonth": "12", "Count": "0" } ], "NSFItem": [ { "NSFMonth": "1", "Count": "0" }, { "NSFMonth": "2", "Count": "0" }, { "NSFMonth": "3", "Count": "0" }, { "NSFMonth": "4", "Count": "0" }, { "NSFMonth": "5", "Count": "0" }, { "NSFMonth": "6", "Count": "0" }, { "NSFMonth": "7", "Count": "0" }, { "NSFMonth": "8", "Count": "0" }, { "NSFMonth": "9", "Count": "0" }, { "NSFMonth": "10", "Count": "0" }, { "NSFMonth": "11", "Count": "0" }, { "NSFMonth": "12", "Count": "0" } ] }, "Datawarehouse": { "AvgOutBal": 0 }, "Status": { "StatusCode": "200", "StatusDesc": "success" } }, "GetDepositAccountDetailResponse": { "Result": { "Status": "SUCCESS", "Message": "", "DepositAccount": { "Status": "SUCCESS", "Message": "", "AccountNumber": "2471779484", "AccountName": "นาง ทด สอบ", "ProductCode": "IM101", "OpenedDate": "2013-01-17+07:00", "AccountStatus": "Active | ปกติ (Active)", "Outstanding": "350250.00", "ODLimit": "150000.00", "Ledger": "200250.00", "InterestRate": "0.000000", "HasJoint": "", "SMSAlertService": "No" }, "JointAccount": { "Status": "SUCCESS", "Message": "" }, "LastMonthTransactionSummary": { "Status": "SUCCESS", "Message": "" }, "Beneficiary": { "Status": "SUCCESS", "Message": "" } } }, "Status": { "StatusCode": "200", "StatusDesc": "success" } }';
        }
    }
    public static String getResponseOSC03 {
        get {
            return '{ "GetCreditCardAccountResponse": { "CCStmtInqRs": { "Status": { "StatusCode": "0", "Severity": "Info", "StatusDesc": "Success", "AdditionalStatus": { "StatusCode": "0", "ServerStatusCode": "0", "Severity": "Info", "StatusDesc": "TRANSACTION PROCESSING COMPLETE." } }, "RqUID": "5854149a-2c88-48f2-a9b9-a426b3fd0cbb", "CCStmtRec": { "CCStmtKeys": { "CCStmtId": "" }, "CCStmtInfo": { "CICSTranCode": "2", "TranCode": "", "MsgType": "2", "CardRef": { "CardKeys": { "CardId": "000010114966941140002105", "CardType": "" } }, "FromAcctName": "PLATINUM WEALTH CARD 55", "LedgerBal": { "Amt": "0.00" }, "AvailCrLimit": { "Amt": "530688.99" }, "AvailCashAdv": { "Amt": "1755000.00" }, "TotalCrLimit": { "Amt": "1755000.00" }, "LastPmtAmt": { "Amt": "90715.71" }, "BonusPoint": "0", "BonusPointUsed": "0", "BonusPointAvail": "30495", "PayAmtDue": { "Amt": "475917.00" }, "DueDt": "2018-11-09", "StmtDt": "2018-11-20", "RespCode": "", "BlockCode": "C", "DirectDrAcctId": { "AcctIdent": { "AcctIdentValue": "" } }, "TotalUnbilledAmt": { "Amt": "0.00" }, "FullPmtAmt": { "Amt": "0.00" }, "MinPmtAmt": { "Amt": "0.00" }, "RemainingPoint": "0", "DailyIntAmt": "0.00" }, "CCStmtStatus": { "StatusCode": "0" } } }, "Status": { "StatusCode": "200", "StatusDesc": "success" } }, "GetCreditCardAccountDetailResponse": { "Result": { "Status": "SUCCESS", "Message": "", "CreditCardInfo": { "Status": "SUCCESS", "Message": "", "CardNumber": "000010114966941140002105", "CreditLimit": "1755000.00", "TemporaryLine": "0", "CycleCut": "20", "UsageStatus": "2", "BlockCode": "C", "NextExpiredPointOn": "2018-11-20+07:00", "CashChillChill": "Y", "CashWithdrawalAccountNumber": "0000000000000000", "OpenedDate": "2008-11-24+07:00", "CurrentBalance": "530688.99", "PaymentDue": "2018-11-09+07:00", "PaymentBehavior": "", "RewardPoints": "30495", "NextExpiredPoints": "0", "CashChillChillStatus": "N", "DirectDebitAccountNumber": "", "UsageBehavior": "", "LastPaymentDate": "2017-11-21+07:00" }, "PayPlanRecord": { "Status": "SUCCESS", "Message": "" } } }, "Status": { "StatusCode": "200", "StatusDesc": "success" } }';
        }
    }
    public static String getResponseOSC04 {
        get {
            return '{ "GetLoanAccountResponse": { "AcctInqRs": { "Status": { "StatusCode": "0", "Severity": "Info", "StatusDesc": "Success" }, "RqUID": "f5d6d581-e4d4-4f36-82f5-930f91342707", "LoanAcctId": { "AcctId": "001100010001000000015405889701", "AcctType": "LOC", "BankInfo": { "BankId": "11" } }, "LnCustAcctId": { "SPName": "", "CustPermId": "001100010001000000000006878141" }, "UpDt": "2020-01-06T15:18:28.858+07:00", "LastTrnDt": "", "AcctBal": [ { "BalType": "Principal", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "Outstanding", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "Used", "CurAmt": { "Amt": "1126125.00" } }, { "BalType": "LnAvail", "CurAmt": { "Amt": "0.00" } }, { "BalType": "PayoffAmt", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "Current", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "CurIntRecBal", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } }, { "BalType": "OrigCommitmentBal", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "CurCommitmentBal", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } } ], "ExtAcctBal": [ { "ExtBalType": "YTDInterest", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "LastYrInt", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "Orig", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "Unpaid/AccruedInt", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "YTDInterestAccrEC", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "TotalPastDue", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" } ], "BankAcctRec": { "LoanAcctId": { "AcctId": "", "AcctType": "", "BankInfo": "" }, "BankAcctInfo": { "CurCode": "", "PersonName": { "LastName": "", "FirstName": "", "LegalName": "" }, "ContactInfo": "", "ProductId": "S700" } }, "LOCAcctRec": { "LoanInfoCommon": { "AccountTitle": "MR.NAME00000006878141 LAST00000006878141", "RemainingPmtCount": "0", "RemainingPmtTerm": "1", "RegPmtCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "LastPmtCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "PastDuePmtCount": "1", "PastDueDt": "2011-12-28", "NextPmtDt": "9999-12-31", "NextPmtCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "DaysPastDue": "2927", "CurrentIntRate": { "Rate": "0.0000001" }, "OriginalIntRate": { "Rate": "0.0000001" }, "RateType": "F", "EffDt": "2011-12-27T12:00:00.000000-00:00", "MatDt": "2011-12-28", "LOCLimit": { "Amt": "1126125.00", "CurCode": "THB" }, "LateChargesCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "CollateralInfo": { "CollateralCode": "000" }, "SeqNum": "0", "DebitAcct": "", "CurrentPmtCount": "0", "FeesDueCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "PerDiemCurAmt": { "Amt": "0.0000000", "CurCode": "THB" }, "PastDuePmtCounter": { "Type": "6-LifeTime", "DelinquencyCategory": "151", "PastDuePmtCount": "1" }, "DraftAcctInfo": { "AcctId": "", "USA.RTN": "0" }, "ProcessDt": "2020-01-02", "CustType": "Personal", "AutoDebitMethod": "", "OrigMatureDt": "2011-12-28", "AccruedIntAmt1": { "Amt": "0.00", "CurCode": "THB" }, "AccruedIntAmt2": { "Amt": "0.00", "CurCode": "THB" }, "AccruedIntAmt3": { "Amt": "0.00", "CurCode": "THB" }, "TotalInt": { "Amt": "0.00", "CurCode": "THB" }, "NextPmtPrincipal": { "Amt": "0.00" }, "NextPmtInterest": { "Amt": "0.00" }, "AcctBal": { "BalType": "ToAccountBal", "CurAmt": { "Amt": "0.00" } }, "LastTrnDt": "2011-12-28", "LastCalculatedInterestDt": "9999-12-31", "ContractDt": "2011-12-27", "TransactionCount": "N" } }, "BankAcctStatus": { "BankAcctStatusCode": "Active" }, "Language": "", "Region": "", "AuthOfficer": "18176", "PersonInfo": [ { "NameAddrType": "", "FullName": "MR.NAME00000006878141 LAST00000006878141", "ContactInfo": { "PostAddr": { "Addr1": "ที่อยู่บรรทัด100000006878141", "Addr2": "ที่อยู่บรรทัด200000006878141", "City": "จ.ทดสอบ", "StateProv": "  ", "PostalCode": "1234567890", "Country": "US", "AddrType": "Mailing" } }, "TINInfo": { "TINType": "SSN", "TaxId": "", "CertCode": "Certification Not on File" }, "OEDCode": "All Other Individuals", "OEDInstitution": "All Other Individuals" }, { "NameAddrType": "", "FullName": "", "ContactInfo": { "PhoneNum": { "PhoneType": "Business", "Phone": "000-00006878" } } } ], "InsuranceInfo": { "InsRebateDueCurAmt": { "Amt": "0.00" } }, "PartyAcctRel": "" }, "Status": { "StatusCode": "200", "StatusDesc": "success" } }, "GetLoanAccountDetailResponse": { "Result": { "Status": "SUCCESS", "Message": "" } }, "Status": { "StatusCode": "200", "StatusDesc": "success" } }';
        }
    }
    public static String getResponseOSC05 {
        get {
            return '{ "GetBancassuranceAccountResponse": { "Result":{} }, "Status": { "StatusCode": "200", "StatusDesc": "success" } }';
        }
    }
    public static String getResponseOSC05Detail {
        get {
            return '{ "GetBancassuranceAccountDetailResponse": { "Result": { "Status": "SUCCESS", "Message": "", "BancassuranceInformation": { "Status": "SUCCESS", "Message": "", "ProductType": "NON LIFE INSURANCE", "TMBProductCode": "PA02", "ProductName": "Accident Care 100% Extra Sure", "EffectiveDate": "2015-04-26+07:00", "PolicyStatus": "Active", "PolicyNo": "001D/PP00-15-044984", "SumInsured": "500000", "AFYP": "1403", "ExpiryDate": "2020-04-26+07:00", "Sales": "19521" }, "BancassuranceDetails": { "Status": "SUCCESS", "Message": "", "InsuranceCompany": "Thai Insurance" }, "PaymentInformation": { "Status": "SUCCESS", "Message": "", "PaymentMode": "Single", "PremiumAmount": "1403", "PaymentMethod": "Cash", "TotalPremiumPaid": "1403", "YearOfPayment": "1 of 1", "NumberOfTimePremiumPaid": "1", "LastPaymentDate": "2015-04-24+07:00" }, "NextCashBackInformation": { "Status": "SUCCESS", "Message": "", "Amount": "0" }, "InsuredPropertyAsset": { "Status": "SUCCESS", "Message": "", "Address": ", , , , " }, "InsuredAutomobileAsset": { "Status": "SUCCESS", "Message": "", "Brand": "", "YearOfManufactured": "", "Model": "", "PlateNumber": "" }, "BeneficiaryInformation": { "Status": "SUCCESS", "Message": "", "Beneficiary": { "Name": "จงกล", "Relationship": "บิดา" } }, "InsuranceClaimRecord": { "Status": "SUCCESS", "Message": "" } } }, "Status": { "StatusCode": "200", "StatusDesc": "success" } }';
        }
    }
    public static String getResponseOSC06Hi {
        get {
            return '{ "GetInvestmentAccountResponse": { "listFundClass": { "FundClass": { "FundClassCode": "800", "FundClassNameEN": "Long-term Equity Fund", "FundClassNameTH": "กองทุนรวมหุ้นระยะยาว", "listFundHouse": { "FundHouse": { "FundHouseCode": "UOBAMTH", "listFundCode": [ { "FundCode": { "UnitHolderNo": "PTXXXXXXXXXX", "FundCode": "CGLTF", "FundNameTH": "3", "FundNameEN": "Good Corporate Governance Long Term Equity Fund", "FundNickNameTH": "บรรษัทภิบาล LTF", "FundNickNameEN": "Good Corp Gov LTF", "FundShortName": "CG-LTF", "UnrealizedProfit": "3145.45", "MarketValue": "16045.45" } } ] } } } }, "percOfFundType": { "Balanced": "0", "ForeignEquity": "1", "ForeignFixedIncome": "0", "LocalEquity": "0", "LocalFixedIncome": "0", "Others": "1" }, "GetFundDetails": [ { "OrderToBeProcess": null, "detailFund": { "DateAsOf": "18/12/2019", "Unit": "275.2353", "Nav": "56.176", "Cost": "12900", "InvestmentValue": "15461.62", "UnrealizedProfit": "2561.62", "UnrealizedProfitPerc": "19.86", "TaxDoc": "N", "UnitLTF5Y": "275.2353", "FundHouseCode": "UOBAMTH", "UnitHolderNo": "PTXXXXXXXXXX", "FundNameTH": "CG-LTF", "FundNameEN": "Good Corporate Governance Long Term Equity Fund" } } ], "Status": { "StatusCode": "200", "StatusDesc": "success" } }, "Status": { "StatusCode": "200", "StatusDesc": "success" } }';
        }
    }
    public static String getResponseOSC06Low {
        get {
            return '{ "GetInvestmentAccountDetailResponse": { "Result": { "Status": "SUCCESS", "Message": "", "InvestmentInformation": { "Status": "SUCCESS", "Message": "", "NumberOfUnit": "275.2353", "CostOfInvestment": "12900", "MarketValue": "15461.62", "UnrealizedGL": "2561.62", "NAVUnit": "56.176", "AipInstruction": "No" }, "InvestmentTransaction": { "Status": "SUCCESS", "Message": "" }, "AutoInvestmentPlan": { "Status": "SUCCESS", "Message": "" } } }, "Status": { "StatusCode": "200", "StatusDesc": "success" } }';
        }
    }

    public static String getResponseSCS_get_cards_balances {
        get {
            return '{\n' +
            '"status":{\n' +
                '"status_code":0\n' +
            '},\n' +
            '"rm_id":0,\n' +
            '"credit_card":[\n' +
                '{\n' +
                    '"card_id":"526789XXXXXX3728",\n' +
                    '"account_id":"0000000000053045212043728",\n' +
                    '"product_id":"600",\n' +
                    '"card_points":{\n' +
                        '"point_earned":0.00,\n' +
                        '"point_used":0.00,\n' +
                        '"point_available":0.00,\n' +
                        '"point_remain":0.00,\n' +
                        '"expiry_points":0.00,\n' +
                        '"expiry_date":""\n' +
                    '},\n' +
                    '"card_status":{\n' +
                        '"stop_code":2,\n' +
                        '"stop_code_desc":"-",\n' +
                        '"account_status":0,\n' +
                        '"account_agree_status":9,\n' +
                        '"activated_date":"0000-00-00",\n' +
                        '"block_code":"",\n' +
                        '"previous_expiry_date":0,\n' +
                        '"application_type":"B"\n' +
                    '},\n' +
                    '"card_balances":{\n'+
                        '"current_balance":38141.99,\n'+
                        '"ledger_balance":54463.00,\n'+
                        '"available_cash_advance":61650.00,\n'+
                        '"available_credit_allowance":32450.00,\n'+
                        '"last_payment_amount":2090.00,\n'+
                        '"last_payment_date":"2020-01-31",\n'+
                        '"eptb_installment_available":130000.00,\n'+
                        '"epai_installment_available":0.00,\n'+
                        '"balance_credit_limit":{\n'+
                            '"total":150000.00,\n'+
                            '"available_to_transfer":50000.00,\n'+
                            '"current":241800\n'+
                        '},\n'+
                        '"balance_credit_line":{\n'+
                            '"total":186000,\n'+
                            '"available":196759,\n'+
                            '"current":241800\n'+
                        '}\n'+
                    '}\n' +
                '},\n' +
                '{\n' +
                    '"card_id":"565813XXXXXX6010",\n' +
                    '"account_id":"000000000001452001274528",\n' +
                    '"product_id":"MDC601",\n' +
                    '"card_points":{\n' +
                        '"point_earned":0.00,\n' +
                        '"point_used":0.00,\n' +
                        '"point_available":0.00,\n' +
                        '"point_remain":0.00,\n' +
                        '"expiry_points":0.00,\n' +
                        '"expiry_date":""\n' +
                    '},\n' +
                    '"card_status":{\n' +
                        '"stop_code":2,\n' +
                        '"stop_code_desc":"-",\n' +
                        '"account_status":0,\n' +
                        '"account_agree_status":9,\n' +
                        '"activated_date":"0000-00-00",\n' +
                        '"block_code":"",\n' +
                        '"previous_expiry_date":0,\n' +
                        '"application_type":"B"\n' +
                    '},\n' +
                    '"card_balances":{\n'+
                        '"current_balance":38141.99,\n'+
                        '"ledger_balance":54463.00,\n'+
                        '"available_cash_advance":485.00,\n'+
                        '"available_credit_allowance":2535.00,\n'+
                        '"last_payment_amount":2090.00,\n'+
                        '"last_payment_date":"2020-01-31",\n'+
                        '"eptb_installment_available":120.00,\n'+
                        '"epai_installment_available":0.00,\n'+
                        '"balance_credit_limit":{\n'+
                            '"total":150000.00,\n'+
                            '"available_to_transfer":30000.00,\n'+
                            '"current":241800\n'+
                        '},\n'+
                        '"balance_credit_line":{\n'+
                            '"total":186000,\n'+
                            '"available":22255660,\n'+
                            '"current":125000\n'+
                        '}\n'+
                    '}\n' +
                '},\n' +
                '{\n' +
                    '"card_id":"596313XXXXXX3999",\n' +
                    '"account_id":"0000000000053029652569874",\n' +
                    '"product_id":"600",\n' +
                    '"card_points":{\n' +
                        '"point_earned":0.00,\n' +
                        '"point_used":0.00,\n' +
                        '"point_available":0.00,\n' +
                        '"point_remain":0.00,\n' +
                        '"expiry_points":0.00,\n' +
                        '"expiry_date":""\n' +
                    '},\n' +
                    '"card_status":{\n' +
                        '"stop_code":2,\n' +
                        '"stop_code_desc":"-",\n' +
                        '"account_status":0,\n' +
                        '"account_agree_status":9,\n' +
                        '"activated_date":"0000-00-00",\n' +
                        '"block_code":"",\n' +
                        '"previous_expiry_date":0,\n' +
                        '"application_type":"B"\n' +
                    '},\n' +
                    '"card_balances":{\n'+
                        '"current_balance":6423.99,\n'+
                        '"ledger_balance":687323.00,\n'+
                        '"available_cash_advance":87562.00,\n'+
                        '"available_credit_allowance":86623.00,\n'+
                        '"last_payment_amount":8452.00,\n'+
                        '"last_payment_date":"2020-03-12",\n'+
                        '"eptb_installment_available":532220.00,\n'+
                        '"epai_installment_available":0.00,\n'+
                        '"balance_credit_limit":{\n'+
                            '"total":350000.00,\n'+
                            '"available_to_transfer":120000.00,\n'+
                            '"current":23568\n'+
                        '},\n'+
                        '"balance_credit_line":{\n'+
                            '"total":1224458,\n'+
                            '"available":354568,\n'+
                            '"current":1122240\n'+
                        '}\n'+
                    '}\n' +
                '},\n' +
                '{\n' +
                    '"card_id":"698sd3XXXXXX3999",\n' +
                    '"account_id":"xxxxxxxx",\n' +
                    '"product_id":"MDC601",\n' +
                    '"card_points":{\n' +
                        '"point_earned":0.00,\n' +
                        '"point_used":0.00,\n' +
                        '"point_available":0.00,\n' +
                        '"point_remain":0.00,\n' +
                        '"expiry_points":0.00,\n' +
                        '"expiry_date":""\n' +
                    '},\n' +
                    '"card_status":{\n' +
                        '"stop_code":2,\n' +
                        '"stop_code_desc":"-",\n' +
                        '"account_status":0,\n' +
                        '"account_agree_status":9,\n' +
                        '"activated_date":"0000-00-00",\n' +
                        '"block_code":"",\n' +
                        '"previous_expiry_date":0,\n' +
                        '"application_type":"B"\n' +
                    '},\n' +
                    '"card_balances":{\n'+
                        '"current_balance":6423.99,\n'+
                        '"ledger_balance":687323.00,\n'+
                        '"available_cash_advance":432188.00,\n'+
                        '"available_credit_allowance":86623.00,\n'+
                        '"last_payment_amount":8452.00,\n'+
                        '"last_payment_date":"2020-03-12",\n'+
                        '"eptb_installment_available":532220.00,\n'+
                        '"epai_installment_available":0.00,\n'+
                        '"balance_credit_limit":{\n'+
                            '"total":350000.00,\n'+
                            '"available_to_transfer":12222000.00,\n'+
                            '"current":23568\n'+
                        '},\n'+
                        '"balance_credit_line":{\n'+
                            '"total":1224458,\n'+
                            '"available":354568,\n'+
                            '"current":1122240\n'+
                        '}\n'+
                    '}\n' +
                '},\n' +
                '{\n' +
                    '"card_id":"",\n' +
                    '"account_id":"xxxxxxxx",\n' +
                    '"product_id":"MDC601",\n' +
                    '"card_points":{\n' +
                        '"point_earned":0.00,\n' +
                        '"point_used":0.00,\n' +
                        '"point_available":0.00,\n' +
                        '"point_remain":0.00,\n' +
                        '"expiry_points":0.00,\n' +
                        '"expiry_date":""\n' +
                    '},\n' +
                    '"card_status":{\n' +
                        '"stop_code":2,\n' +
                        '"stop_code_desc":"-",\n' +
                        '"account_status":0,\n' +
                        '"account_agree_status":9,\n' +
                        '"activated_date":"0000-00-00",\n' +
                        '"block_code":"",\n' +
                        '"previous_expiry_date":0,\n' +
                        '"application_type":"B"\n' +
                    '},\n' +
                    '"card_balances":{\n'+
                        '"current_balance":6423.99,\n'+
                        '"ledger_balance":687323.00,\n'+
                        '"available_cash_advance":432188.00,\n'+
                        '"available_credit_allowance":86623.00,\n'+
                        '"last_payment_amount":8452.00,\n'+
                        '"last_payment_date":"2020-03-12",\n'+
                        '"eptb_installment_available":532220.00,\n'+
                        '"epai_installment_available":0.00,\n'+
                        '"balance_credit_limit":{\n'+
                            '"total":350000.00,\n'+
                            '"available_to_transfer":12222000.00,\n'+
                            '"current":23568\n'+
                        '},\n'+
                        '"balance_credit_line":{\n'+
                            '"total":1224458,\n'+
                            '"available":354568,\n'+
                            '"current":1122240\n'+
                        '}\n'+
                    '}\n' +
                '},\n' +
                '{\n' +
                    '"card_id":"xxxxxxxx",\n' +
                    '"account_id":"",\n' +
                    '"product_id":"MDC602",\n' +
                    '"card_points":{\n' +
                        '"point_earned":0.00,\n' +
                        '"point_used":0.00,\n' +
                        '"point_available":0.00,\n' +
                        '"point_remain":0.00,\n' +
                        '"expiry_points":0.00,\n' +
                        '"expiry_date":""\n' +
                    '},\n' +
                    '"card_status":{\n' +
                        '"stop_code":2,\n' +
                        '"stop_code_desc":"-",\n' +
                        '"account_status":0,\n' +
                        '"account_agree_status":9,\n' +
                        '"activated_date":"0000-00-00",\n' +
                        '"block_code":"",\n' +
                        '"previous_expiry_date":0,\n' +
                        '"application_type":"B"\n' +
                    '},\n' +
                    '"card_balances":{\n'+
                        '"current_balance":6423.99,\n'+
                        '"ledger_balance":687323.00,\n'+
                        '"available_cash_advance":432188.00,\n'+
                        '"available_credit_allowance":86623.00,\n'+
                        '"last_payment_amount":8452.00,\n'+
                        '"last_payment_date":"2020-03-12",\n'+
                        '"eptb_installment_available":532220.00,\n'+
                        '"epai_installment_available":0.00,\n'+
                        '"balance_credit_limit":{\n'+
                            '"total":350000.00,\n'+
                            '"available_to_transfer":12222000.00,\n'+
                            '"current":23568\n'+
                        '},\n'+
                        '"balance_credit_line":{\n'+
                            '"total":1224458,\n'+
                            '"available":354568,\n'+
                            '"current":1122240\n'+
                        '}\n'+
                    '}\n' +
                '}\n' +
            '],\n' +
            '"total_records":6,\n' +
            '"max_records":6,\n' +
            '"more_records":"N",\n' +
            '"search_keys":""\n' +
            '}\n';
        }
    }

    public static String getResponseSCS_get_cards_balances_with_error {
        get {
            return '{"status":{"status_code": "1","error_status":[ {"error_code": "ID00001","description": "Invalid ID Type"},{"error_code": "ID00002","description": "Invalid Issued Country Code"}]}}';                
        }
    }
    
    public static String getResponseSCS_get_card {
        get {
            return '{\n'+
            '"status":{\n'+
                '"status_code":0\n'+
            '},\n'+
            '"credit_card":{\n'+
                '"card_id":"526413XXXXXX3728",\n'+
                '"account_id":"0000000000053020012043728",\n'+
                '"product_id":"600",\n'+
                '"direct_deposit_account":5796179989200040030,\n'+
                '"direct_deposit_bank":"065",\n'+
                '"customer":{\n'+
                    '"rm_id":9192,\n'+
                    '"ec_id":8002,\n'+
                    '"birthdate":"1993-02-01",\n'+
                    '"identification_id":"999999999999"\n'+
                '},\n'+
                '"card_info":{\n'+
                    '"billing_cycle":31,\n'+
                    '"card_embossing_name1":"MATNIYA PHROMCHAT",\n'+
                    '"card_embossing_name2":"TCBSCOOP",\n'+
                    '"issued_by":2004,\n'+
                    '"expired_by":2504,\n'+
                    '"last_update_date":"2020-04 23",\n'+
                    '"effective_date":"0000-00-00",\n'+
                    '"created_date":"2020-04-22"\n'+
                '},\n'+
                '"card_phones":[\n'+
                    '{\n'+
                        '"phone_type":"",\n'+
                        '"phone_no":"",\n'+
                        '"phone_extension":""\n'+
                    '},\n'+
                    '{\n'+
                        '"phone_type":"",\n'+
                        '"phone_no":"",\n'+
                        '"phone_extension":""\n'+
                    '},\n'+
                    '{\n'+
                        '"phone_type":"",\n'+
                        '"phone_no":"",\n'+
                        '"phone_extension":""\n'+
                    '},\n'+
                    '{\n'+
                        '"phone_type":"",\n'+
                        '"phone_no":"",\n'+
                        '"phone_extension":""\n'+
                    '},\n'+
                    '{\n'+
                        '"phone_type":"",\n'+
                        '"phone_no":"",\n'+
                        '"phone_extension":""\n'+
                    '},\n'+
                    '{\n'+
                        '"phone_type":"",\n'+
                        '"phone_no":"",\n'+
                        '"phone_extension":""\n'+
                    '},\n'+
                    '{\n'+
                        '"phone_type":"",\n'+
                        '"phone_no":"",\n'+
                        '"phone_extension":""\n'+
                    '},\n'+
                    '{\n'+
                        '"phone_type":"",\n'+
                        '"phone_no":"",\n'+
                        '"phone_extension":""\n'+
                    '},\n'+
                    '{\n'+
                        '"phone_type":"",\n'+
                        '"phone_no":"",\n'+
                        '"phone_extension":""\n'+
                    '},\n'+
                    '{\n'+
                        '"phone_type":"",\n'+
                        '"phone_no":"",\n'+
                        '"phone_extension":""\n'+
                    '}\n'+
                '],\n'+
                '"card_addresses":{\n'+
                    '"city":"",\n'+
                    '"postal_code":"45120",\n'+
                    '"address_1":"161 หมู่ 2 ต. กลาง อ. เสลภูมิ จ. ร้อยเอ็",\n'+
                    '"address_2":"ด",\n'+
                    '"address_3":"",\n'+
                    '"country":"TH"\n'+
                '},\n'+
                '"card_email":{\n'+
                    '"email_address":"",\n'+
                    '"email_eStatementFlag":""\n'+
                '},\n'+
                '"balance_points":{\n'+
                    '"point_earned":0.00,\n'+
                    '"point_used":0.00,\n'+
                    '"point_available":0.00,\n'+
                    '"point_remain":0.00,\n'+
                    '"expiry_points":0.00,\n'+
                    '"expiry_date":""\n'+
                '},\n'+
                '"card_status":{\n'+
                    '"stop_code":0,\n'+
                    '"stop_code_desc":"",\n'+
                    '"account_status":"000",\n'+
                    '"account_agree_status":"009",\n'+
                    '"activated_date":"0000-00-00",\n'+
                    '"block_code":"",\n'+
                    '"previous_expiry_date":0,\n'+
                    '"application_type":"B",\n'+
                    '"stop_date":"2020-06-17"\n'+
                '},\n'+
                '"card_balances":{\n'+
                    '"current_balance":38141.99,\n'+
                    '"ledger_balance":54463.00,\n'+
                    '"available_cash_advance":61650.00,\n'+
                    '"available_credit_allowance":32450.00,\n'+
                    '"last_payment_amount":2090.00,\n'+
                    '"last_payment_date":"2020-01-31",\n'+
                    '"eptb_installment_available":130000.00,\n'+
                    '"epai_installment_available":0.00,\n'+
                    '"balance_credit_limit":{\n'+
                        '"total":150000.00,\n'+
                        '"available_to_transfer":50000.00,\n'+
                        '"current":241800\n'+
                    '},\n'+
                    '"balance_credit_line":{\n'+
                        '"total":186000,\n'+
                        '"available":196759,\n'+
                        '"current":241800\n'+
                    '}\n'+
                '},\n'+
                '"card_credit_limit":{\n'+
                    '"permanent_credit_limit":0,\n'+
                    '"temporary_credit_limit":{\n'+
                        '"amounts":0,\n'+
                        '"effective_date":"0000-00-00",\n'+
                        '"expiry_date":"0000-00-00",\n'+
                        '"request_reason":"",\n'+
                        '"previous_credit_limit":0,\n'+
                        '"max_temp_allowance":7188,\n'+
                        '"max_temp_increase":0\n'+
                    '}\n'+
                '}\n'+
            '}\n'+
        '}\n';
        }
    }

    public static String getResponseSCS_get_unbilled_statement {
        get {
            return '{\n'+
                '"status":{\n'+
                   '"status_code":0\n'+
                '},\n'+
                '"card_statement":{\n'+
                   '"total_unbilled_amounts":0.00,\n'+
                   '"full_payment_amounts":0.00,\n'+
                   '"min_payment_amounts":0.00,\n'+
                   '"total_amount_due":0.00,\n'+
                   '"minimum_due":0.00,\n'+
                   '"interests":0.000,\n'+
                   '"cash_advance_fee":0.00,\n'+
                   '"total_cash_installment_records":0,\n'+
                   '"total_spending_installment_records":0,\n'+
                   '"due_date":"",\n'+
                   '"statement_date":"",\n'+
                   '"promotion_flag":"",\n'+
                   '"point_available":0.00,\n'+
                   '"statement_transactions":[\n'+
                      '{\n'+
                         '"transaction_code":0,\n'+
                         '"transaction_amounts":0.00,\n'+
                         '"posted_date":"0000-00-00",\n'+
                         '"transaction_type":"A",\n'+
                         '"transaction_date":"2020-04-22",\n'+
                         '"mcc_code":"7011",\n'+
                         '"transaction_description":"SEA BREEZE BUNGALOW      KOH SAMUI    TH",\n'+
                         '"transaction_currency":"THB"\n'+
                      '},\n'+
                      '{\n'+
                         '"transaction_code":0,\n'+
                         '"transaction_amounts":0.00,\n'+
                         '"posted_date":"0000-00-00",\n'+
                         '"transaction_type":"A",\n'+
                         '"transaction_date":"2020-04-22",\n'+
                         '"mcc_code":"7011",\n'+
                         '"transaction_description":"SEA BREEZE BUNGALOW      KOH SAMUI    TH",\n'+
                         '"transaction_currency":"THB"\n'+
                      '},\n'+
                      '{\n'+
                         '"transaction_code":5039,\n'+
                         '"transaction_amounts":-7.00,\n'+
                         '"posted_date":"2017-08-21",\n'+
                         '"transaction_type":"U",\n'+
                         '"transaction_date":"2017-08-21",\n'+
                         '"mcc_code":"",\n'+
                         '"transaction_description":"MERCHANT - ADDITIONAL CHR",\n'+
                         '"transaction_currency":"THB"\n'+
                      '},\n'+
                      '{\n'+
                         '"transaction_code":5039,\n'+
                         '"transaction_amounts":-7.00,\n'+
                         '"posted_date":"2017-08-21",\n'+
                         '"transaction_type":"U",\n'+
                         '"transaction_date":"2017-08-21",\n'+
                         '"mcc_code":"",\n'+
                         '"transaction_description":"MERCHANT - ADDITIONAL CHR",\n'+
                         '"transaction_currency":"THB"\n'+
                      '},\n'+
                      '{\n'+
                         '"transaction_code":5039,\n'+
                         '"transaction_amounts":-7.00,\n'+
                         '"posted_date":"2017-08-21",\n'+
                         '"transaction_type":"U",\n'+
                         '"transaction_date":"2017-08-21",\n'+
                         '"mcc_code":"",\n'+
                         '"transaction_description":"MERCHANT - ADDITIONAL CHR",\n'+
                         '"transaction_currency":"THB"\n'+
                      '},\n'+
                      '{\n'+
                         '"transaction_code":5039,\n'+
                         '"transaction_amounts":-7.00,\n'+
                         '"posted_date":"2017-08-21",\n'+
                         '"transaction_type":"U",\n'+
                         '"transaction_date":"2017-08-21",\n'+
                         '"mcc_code":"",\n'+
                         '"transaction_description":"MERCHANT - ADDITIONAL CHR",\n'+
                         '"transaction_currency":"THB"\n'+
                      '},\n'+
                      '{\n'+
                         '"transaction_code":5054,\n'+
                         '"transaction_amounts":-0.49,\n'+
                         '"posted_date":"2017-08-21",\n'+
                         '"transaction_type":"U",\n'+
                         '"transaction_date":"2017-08-21",\n'+
                         '"mcc_code":"",\n'+
                         '"transaction_description":"VAT MERCHANT",\n'+
                         '"transaction_currency":"THB"\n'+
                      '},\n'+
                      '{\n'+
                         '"transaction_code":5054,\n'+
                         '"transaction_amounts":-0.49,\n'+
                         '"posted_date":"2017-08-21",\n'+
                         '"transaction_type":"U",\n'+
                         '"transaction_date":"2017-08-21",\n'+
                         '"mcc_code":"",\n'+
                         '"transaction_description":"VAT MERCHANT",\n'+
                         '"transaction_currency":"THB"\n'+
                      '},\n'+
                      '{\n'+
                         '"transaction_code":5054,\n'+
                         '"transaction_amounts":-0.49,\n'+
                         '"posted_date":"2017-08-21",\n'+
                         '"transaction_type":"U",\n'+
                         '"transaction_date":"2017-08-21",\n'+
                         '"mcc_code":"",\n'+
                         '"transaction_description":"VAT MERCHANT",\n'+
                         '"transaction_currency":"THB"\n'+
                      '},\n'+
                      '{\n'+
                         '"transaction_code":5054,\n'+
                         '"transaction_amounts":-0.49,\n'+
                         '"posted_date":"2017-08-21",\n'+
                         '"transaction_type":"U",\n'+
                         '"transaction_date":"2017-08-21",\n'+
                         '"mcc_code":"",\n'+
                         '"transaction_description":"VAT MERCHANT",\n'+
                         '"transaction_currency":"THB"\n'+
                      '}\n'+
                   '],\n'+
                   '"point_remain":0.00,\n'+
                   '"expiry_date":"",\n'+
                   '"expiry_points":0.00\n'+
                '},\n'+
                '"total_records":230,\n'+
                '"max_records":10,\n'+
                '"more_records":"Y",\n'+
                '"search_keys":"0000000000000000000000000001000230"\n'+
             '}\n';
        }
    }

    public static String getResponseSCS_get_summary {
        get {
            return '{\n'+
                '"creditCardInfo":{\n'+
                '"amountOfInterestChargeTransactions": 4530,\n'+
                '"amountOfNonInterestChargeTransactions": 900000,\n'+
                '"numberOfInterestChargeTransactions": 4,\n'+
                '"numberOfNonInterestChargeTransactions": 8,\n'+
                '"paymentBehavior": "FULL ",\n'+
                '"totalAmountOfTransactions": "",\n'+
                '"totalNumberOfTransactions": 12,\n'+
                '"usageBehavior": "0:0",\n'+
                '},\n'+
                '"status": {\n'+
                    '"code": "200",\n'+
                    '"description": "success"\n'+
                '}\n'+
            '}\n';
        }
    }
    
    public static String getResponseSCS_get_summary_with_error {
        get {
            return '{"status": {"description": "record not found.","code": "201"}}';
        }
    }

    public class MockResponseGetCardsBalance implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = new Map<String,String> {
            'callout:get_cards_balances' => getResponseSCS_get_cards_balances,
            'callout:get_card' => getResponseSCS_get_card,
            'callout:get_unbilled_statement' => getResponseSCS_get_unbilled_statement,
            'callout:get_scs_key' => 'ahjdgfakSomedfheiwThingdfsdgsfhd4645'
        }.get(req.getEndpoint());
        System.debug('req mock service : ' + req.getBody());
        if (req.getBody().contains('errorOSCCredit')) {
            body = getResponseSCS_get_cards_balances_with_error;
        }
        System.debug('reqEndpoint : ' + req.getEndpoint());
        // String body = getResponseSCS_get_cards_balances;
        res.setBody(body);
        res.setStatusCode(200);
        return res;
        }
    }

    public class MockResponseGetSummary implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = new Map<String,String> {
            'callout:get_summary' => getResponseSCS_get_summary,
            'callout:get_scs_key' => 'ahjdgfakSomedfheiwThingdfsdgsfhd4645'
        }.get(req.getEndpoint());
        if (req.getBody().contains('errorOSCCredit')) {
            body = getResponseSCS_get_summary_with_error;
        }
        System.debug('reqEndpoint : '+ req.getEndpoint());
        res.setBody(body);
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

    @isTest static void test_MethodUtility() {
        RTL_ProductHoldingsLightningUtil.MakeValue('MarkedCashWithdrawalAccountNumber', '0000000000000000');
        RTL_ProductHoldingsLightningUtil.getAccessibleCusHold(null);
    }

    @isTest static void test_OSC01Service() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
        String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;

        Continuation conti = (Continuation)RTL_ProductHoldingsLightningUtil.getProduct(
            'callout:OSC01',
            'callbackOSC01',
            '{"GetCustomerAccountRequest":{"RMID":"0000000000051187","FIIdent":"0011000000000000"}}',
            '001100000000000000000000051187'
        );
        Continuation conti2 = (Continuation)RTL_ProductHoldingsLightningUtil.getProductContinue(
            'callout:OSC01',
            'callbackOSC01',
            '{"GetCustomerAccountRequest":{"RMID":"0000000000051187","FIIdent":"0011000000000000"}}',
            new Map<String, Object>()
        );
        Map<String, HttpRequest> requests = conti.getRequests();
        // Set the fake response for the continuation
        HttpRequest request = requests.values().iterator().next();
        String requestLabel = requests.keyset().iterator().next();

        // Callback OSC01
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody(getResponseOSC01);
        Test.setContinuationResponse(requestLabel, response);
        // Invoke callback method
        RTL_ProductHoldingsLightningUtil.callbackOSC01(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setStatusCode(2001);
        response.setBody('{"GetCustomerAccountResponse":{},"Status": { "StatusCode": 200, "StatusDesc": "success" }}');
        Test.setContinuationResponse(requestLabel, response);
        RTL_ProductHoldingsLightningUtil.callbackOSC01(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setBody('');
        Test.setContinuationResponse(requestLabel, response);
        RTL_ProductHoldingsLightningUtil.callbackOSC01(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setBody('{"GetCustomerAccountResponse":{}}');
        Test.setContinuationResponse(requestLabel, response);
        try {
            RTL_ProductHoldingsLightningUtil.callbackOSC01(new List<String>{requestLabel}, new Map<String, Object>{
                'isEmployee' => true,
                'body' => request.getBody(),
                'StartTime' => (Datetime)Datetime.now(),
                'RMID' => '001100000000000000000000051187',
                'Account' => null
            });
        } catch (Exception e) {
            
        }
        Test.stopTest();
    }
    @isTest static void test_OSC02Service() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
        String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;

        Continuation conti = (Continuation)RTL_ProductHoldingsLightningUtil.getProduct(
            'callout:OSC02',
            'callbackOSC02',
            '{"GetDepositAccountRequest":{"RMID":"000000000000051187","FIIdent":"0011000102470000","AccountNumber":"2471779484","AccountType":"101","ProductType":"com.fnis.xes.IM"}}',
            '001100000000000000000000051187'
        );
        Map<String, HttpRequest> requests = conti.getRequests();
        // Set the fake response for the continuation
        HttpRequest request = requests.values().iterator().next();
        String requestLabel = requests.keyset().iterator().next();

        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody(getResponseOSC02);
        Test.setContinuationResponse(requestLabel, response);
        // Invoke callback method
        RTL_ProductHoldingsLightningUtil.callbackOSC02(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setStatusCode(2001);
        response.setBody('{"GetDepositAccountDetailResponse":{"Result":{}},"Status": { "StatusCode": 200, "StatusDesc": "success" }}');
        Test.setContinuationResponse(requestLabel, response);
        RTL_ProductHoldingsLightningUtil.callbackOSC02(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setBody('');
        Test.setContinuationResponse(requestLabel, response);
        RTL_ProductHoldingsLightningUtil.callbackOSC02(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setBody('{"GetDepositAccountDetailResponse":{}}');
        Test.setContinuationResponse(requestLabel, response);
        try {
            RTL_ProductHoldingsLightningUtil.callbackOSC02(new List<String>{requestLabel}, new Map<String, Object>{
                'isEmployee' => true,
                'body' => request.getBody(),
                'StartTime' => (Datetime)Datetime.now(),
                'RMID' => '001100000000000000000000051187',
                'Account' => null
            });
        } catch (Exception e) {
            
        }
        Test.stopTest();
    }
    @isTest static void test_OSC03Service() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
        String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;

        Continuation conti = (Continuation)RTL_ProductHoldingsLightningUtil.getProduct(
            'callout:OSC03',
            'callbackOSC03',
            '{"GetCreditCardAccountRequest":{"CardID":"496694006242032105","CreditcardType":"011CRE"}}',
            '001100000000000000000000051187'
        );
        Map<String, HttpRequest> requests = conti.getRequests();
        // Set the fake response for the continuation
        HttpRequest request = requests.values().iterator().next();
        String requestLabel = requests.keyset().iterator().next();

        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody(getResponseOSC03);
        Test.setContinuationResponse(requestLabel, response);
        // Invoke callback method
        RTL_ProductHoldingsLightningUtil.callbackOSC03(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setStatusCode(2001);
        response.setBody('{"GetCreditCardAccountResponse":{},"Status": { "StatusCode": 200, "StatusDesc": "success" }}');
        Test.setContinuationResponse(requestLabel, response);
        RTL_ProductHoldingsLightningUtil.callbackOSC03(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setBody('');
        Test.setContinuationResponse(requestLabel, response);
        RTL_ProductHoldingsLightningUtil.callbackOSC03(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setBody('{"GetCreditCardAccountResponse":{}}');
        Test.setContinuationResponse(requestLabel, response);
        try {
            RTL_ProductHoldingsLightningUtil.callbackOSC03(new List<String>{requestLabel}, new Map<String, Object>{
                'isEmployee' => true,
                'body' => request.getBody(),
                'StartTime' => (Datetime)Datetime.now(),
                'RMID' => '001100000000000000000000051187',
                'Account' => null
            });
        } catch (Exception e) {
            
        }
        Test.stopTest();
    }
    @isTest static void test_OSC04Service() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
        String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;

        Continuation conti = (Continuation)RTL_ProductHoldingsLightningUtil.getProduct(
            'callout:OSC04',
            'callbackOSC04',
            '{"GetLoanAccountRequest":{"RMID":"000000000000051187","FIIdent":"0011000100010000","AccountNumber":"00015405889701","AccountType":"com.fnis.xes.AL","ProductType":""}}',
            '001100000000000000000000051187'
        );
        Map<String, HttpRequest> requests = conti.getRequests();
        // Set the fake response for the continuation
        HttpRequest request = requests.values().iterator().next();
        String requestLabel = requests.keyset().iterator().next();

        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody(getResponseOSC04);
        Test.setContinuationResponse(requestLabel, response);
        // Invoke callback method
        RTL_ProductHoldingsLightningUtil.callbackOSC04(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setStatusCode(2001);
        response.setBody('{"GetLoanAccountResponse":{},"Status": { "StatusCode": 200, "StatusDesc": "success" }}');
        Test.setContinuationResponse(requestLabel, response);
        RTL_ProductHoldingsLightningUtil.callbackOSC04(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setBody('');
        Test.setContinuationResponse(requestLabel, response);
        RTL_ProductHoldingsLightningUtil.callbackOSC04(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setBody('{"GetLoanAccountResponse":{}}');
        Test.setContinuationResponse(requestLabel, response);
        try {
            RTL_ProductHoldingsLightningUtil.callbackOSC04(new List<String>{requestLabel}, new Map<String, Object>{
                'isEmployee' => true,
                'body' => request.getBody(),
                'StartTime' => (Datetime)Datetime.now(),
                'RMID' => '001100000000000000000000051187',
                'Account' => null
            });
        } catch (Exception e) {
            
        }
        Test.stopTest();
    }
    @isTest static void test_OSC05Service() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
        String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;

        Continuation conti = (Continuation)RTL_ProductHoldingsLightningUtil.getProduct(
            'callout:OSC05_Detail',
            'callbackOSC05Detail',
            '{"GetBancassuranceAccountRequest":{"RMID":"000000000000506607"}}',
            '001100000000000000000000051187'
        );
        Map<String, HttpRequest> requests = conti.getRequests();
        // Set the fake response for the continuation
        HttpRequest request = requests.values().iterator().next();
        String requestLabel = requests.keyset().iterator().next();

        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody(getResponseOSC05);
        Test.setContinuationResponse(requestLabel, response);
        // Invoke callback method
        RTL_ProductHoldingsLightningUtil.callbackOSC05(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setBody(getResponseOSC05Detail);
        Test.setContinuationResponse(requestLabel, response);
        RTL_ProductHoldingsLightningUtil.callbackOSC05Detail(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setStatusCode(2001);
        response.setBody('{"GetBancassuranceAccountResponse":{},"Status": { "StatusCode": 200, "StatusDesc": "success" }}');
        Test.setContinuationResponse(requestLabel, response);
        RTL_ProductHoldingsLightningUtil.callbackOSC05(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setStatusCode(2001);
        response.setBody('{"GetBancassuranceAccountDetailResponse":{"Result": {"Status": "500","Message": "Network is unreachable: no further information"}},"Status": { "StatusCode": 200, "StatusDesc": "success" }}');
        Test.setContinuationResponse(requestLabel, response);
        RTL_ProductHoldingsLightningUtil.callbackOSC05Detail(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setBody('');
        Test.setContinuationResponse(requestLabel, response);
        RTL_ProductHoldingsLightningUtil.callbackOSC05(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        RTL_ProductHoldingsLightningUtil.callbackOSC05Detail(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setBody('{"GetBancassuranceAccount":{}}');
        Test.setContinuationResponse(requestLabel, response);
        try {
            RTL_ProductHoldingsLightningUtil.callbackOSC05(new List<String>{requestLabel}, new Map<String, Object>{
                'isEmployee' => true,
                'body' => request.getBody(),
                'StartTime' => (Datetime)Datetime.now(),
                'RMID' => '001100000000000000000000051187',
                'Account' => null
            });            
        } catch (Exception e) {
            
        }
        try {
            RTL_ProductHoldingsLightningUtil.callbackOSC05Detail(new List<String>{requestLabel}, new Map<String, Object>{
                'isEmployee' => true,
                'body' => request.getBody(),
                'StartTime' => (Datetime)Datetime.now(),
                'RMID' => '001100000000000000000000051187',
                'Account' => null
            });
        } catch (Exception e) {
            
        }
        Test.stopTest();
    }
    @isTest static void test_OSC06Service() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
        String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;

        Continuation conti = (Continuation)RTL_ProductHoldingsLightningUtil.getProduct(
            'callout:OSC06_Detail',
            'callbackOSC06Detail',
            '{"GetInvestmentAccountRequest":{"UnitHolderNo":"111324000011"}}',
            '001100000000000000000000051187'
        );
        Map<String, HttpRequest> requests = conti.getRequests();
        // Set the fake response for the continuation
        HttpRequest request = requests.values().iterator().next();
        String requestLabel = requests.keyset().iterator().next();

        HttpResponse response = new HttpResponse();
        // High level
        response.setStatusCode(200);
        response.setBody(getResponseOSC06Hi);
        Test.setContinuationResponse(requestLabel, response);
        // Invoke callback method
        RTL_ProductHoldingsLightningUtil.callbackOSC06List(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setStatusCode(2001);
        response.setBody('{"GetInvestmentAccountResponse":{},"Status": { "StatusCode": 200, "StatusDesc": "success" }}');
        Test.setContinuationResponse(requestLabel, response);
        RTL_ProductHoldingsLightningUtil.callbackOSC06List(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setBody('');
        Test.setContinuationResponse(requestLabel, response);
        RTL_ProductHoldingsLightningUtil.callbackOSC06List(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setBody('{"GetInvestmentAccountResponse":{}}');
        Test.setContinuationResponse(requestLabel, response);
        try {
            RTL_ProductHoldingsLightningUtil.callbackOSC06List(new List<String>{requestLabel}, new Map<String, Object>{
                'isEmployee' => true,
                'body' => request.getBody(),
                'StartTime' => (Datetime)Datetime.now(),
                'RMID' => '001100000000000000000000051187',
                'Account' => null
            });
        } catch (Exception e) {
            
        }

        // Low level
        response.setStatusCode(200);
        response.setBody(getResponseOSC06Low);
        Test.setContinuationResponse(requestLabel, response);
        // Invoke callback method
        RTL_ProductHoldingsLightningUtil.callbackOSC06Detail(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setStatusCode(2001);
        response.setBody('{"GetInvestmentAccountDetailResponse":{},"Status": { "StatusCode": 200, "StatusDesc": "success" }}');
        Test.setContinuationResponse(requestLabel, response);
        RTL_ProductHoldingsLightningUtil.callbackOSC06Detail(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setBody('');
        Test.setContinuationResponse(requestLabel, response);
        RTL_ProductHoldingsLightningUtil.callbackOSC06Detail(new List<String>{requestLabel}, new Map<String, Object>{
            'isEmployee' => true,
            'body' => request.getBody(),
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => '001100000000000000000000051187',
            'Account' => new Account()
        });
        response.setBody('{"GetInvestmentAccountDetailResponse":{}}');
        Test.setContinuationResponse(requestLabel, response);
        try {
            RTL_ProductHoldingsLightningUtil.callbackOSC06Detail(new List<String>{requestLabel}, new Map<String, Object>{
                'isEmployee' => true,
                'body' => request.getBody(),
                'StartTime' => (Datetime)Datetime.now(),
                'RMID' => '001100000000000000000000051187',
                'Account' => null
            });
        } catch (Exception e) {
            
        }
        Test.stopTest();
    }

    @isTest static void test_getProductHttp() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseOSC01());
        try {
            RTL_ProductHoldingsLightningUtil.getProductHttp('callout:OSC01', 
                                                        '{"GetCustomerAccountRequest":{"RMID":"0000000000051187","FIIdent":"0011000000000000"}}',
                                                          '001100000000000000000000051187');        
            RTL_ProductHoldingsLightningUtil.getProductHttp('callout:OSC01', 
                                                        '{"GetCustomerAccountRequest":{"RMID":"0000000000051187","FIIdent":"0011000000000000"}}',
                                                        '001100000000000000000000051187');    
        } catch (Exception e) {
            System.debug('getProductHttp with mock service: '+ e);
        }
        Test.stopTest();
    }
    
    @isTest static void test_getProductSCSCreditCard (){
        Test.startTest();
        String endpoint = 'callout:get_cards_balances';
        String body = '{"query": {"rm_id": "001100000000000000000000051187", "more_records": "N", "search_keys": "", "user_interface": ""}}';
        Test.setMock(HttpCalloutMock.class, new MockResponseGetCardsBalance());
        try {
            RTL_ProductHoldingsLightningUtil.getProductSCSCreditCard(endpoint, body, '001100000000000000000000051187');        
        } catch (Exception e) {
            System.debug('SCS mock service error' + e);
        }
        try {
            body = '{"query": {"rm_id": "001100000000000000000000051187", "more_records": "N", "search_keys": "", "user_interface": "", "errorOSCCredit" : ""}}';
            RTL_ProductHoldingsLightningUtil.getProductSCSCreditCard(endpoint, body, '001100000000000000000000051187');        
        } catch (Exception e) {
            System.debug('SCS mock service error' + e);
        }
        Test.stopTest();
    }

    @isTest static void test_getProductSCSCreditCardError (){
        Test.startTest();
        String endpoint = 'callout:get_cards_balances';
        String  body = '{"query": {"rm_id": "001100000000000000000000051187", "more_records": "N", "search_keys": "", "user_interface": "", "errorOSCCredit" : ""}}';
        Test.setMock(HttpCalloutMock.class, new MockResponseGetCardsBalance());
        try {
            RTL_ProductHoldingsLightningUtil.getProductSCSCreditCard(endpoint, body, '001100000000000000000000051187');        
        } catch (Exception e) {
            System.debug('SCS mock service error' + e);
        }
        Test.stopTest();
    }

    @isTest static void test_getCardSCSCreditCard (){
        Test.startTest();
        String endpoint = 'callout:get_card';
        String body = '{"query": {"account_id": "0000000000053020012043728"}}';
        //set mock service
        Test.setMock(HttpCalloutMock.class, new MockResponseGetCardsBalance());
        try {
            RTL_ProductHoldingsLightningUtil.getProductSCSCreditCard(endpoint, body, '001100000000000000000000051187');        
        } catch (Exception e) {
            System.debug('SCS error' + e);
        }
        try {
            body = '{"query": {"account_id": "0000000000053020012043727", "errorOSCCredit" : ""}}';
            RTL_ProductHoldingsLightningUtil.getProductSCSCreditCard(endpoint, body, '001100000000000000000000051187');        
        } catch (Exception e) {
            System.debug('SCS mock service error' + e);
        }
        Test.stopTest();
    }

    @isTest static void test_getCardSCSCreditCardError (){
        Test.startTest();
        String endpoint = 'callout:get_card';
        String  body = '{"query": {"account_id": "0000000000053020012043727", "errorOSCCredit" : ""}}';
        //set mock service
        Test.setMock(HttpCalloutMock.class, new MockResponseGetCardsBalance());
        try {
            RTL_ProductHoldingsLightningUtil.getProductSCSCreditCard(endpoint, body, '001100000000000000000000051187');        
        } catch (Exception e) {
            System.debug('SCS mock service error' + e);
        }
        Test.stopTest();
    }

    @isTest static void test_getUnbilledStatementSCSCreditCard (){
        Test.startTest();
        String endpoint = 'callout:get_unbilled_statement';
        String body = '{"query": {"account_id": "0000000000053020012043728", "more_records": "N", "search_keys": ""}}';
        //set mock service
        Test.setMock(HttpCalloutMock.class, new MockResponseGetCardsBalance());
        try {
            RTL_ProductHoldingsLightningUtil.getProductSCSCreditCard(endpoint, body, '001100000000000000000000051187');        
        } catch (Exception e) {
            System.debug('SCS error' + e);
        }
        try {
            body = '{"query": {"account_id": "0000000000053020012043727", "more_records": "N", "search_keys": "", "errorOSCCredit" : ""}}';
            RTL_ProductHoldingsLightningUtil.getProductSCSCreditCard(endpoint, body, '001100000000000000000000051187');        
        } catch (Exception e) {
            System.debug('SCS mock service error' + e);
        }
        Test.stopTest();
    }

    @isTest static void test_getUnbilledStatementSCSCreditCardError (){
        Test.startTest();
        String endpoint = 'callout:get_unbilled_statement';
        String  body = '{"query": {"account_id": "0000000000053020012043727", "more_records": "N", "search_keys": "", "errorOSCCredit" : ""}}';
        //set mock service
        Test.setMock(HttpCalloutMock.class, new MockResponseGetCardsBalance());
        try {
            RTL_ProductHoldingsLightningUtil.getProductSCSCreditCard(endpoint, body, '001100000000000000000000051187');        
        } catch (Exception e) {
            System.debug('SCS mock service error' + e);
        }
        Test.stopTest();
    }

    @isTest static void test_getSummarySCSCreditCard (){
        Test.startTest();
        String endpoint = 'callout:get_summary';
        String body = '{"query": {"account_id": "0000000000053020012043728"}}';
        //set mock service
        Test.setMock(HttpCalloutMock.class, new MockResponseGetSummary());
        try {
            RTL_ProductHoldingsLightningUtil.getSummaryProductSCSCreditCard(endpoint, body, '001100000000000000000000051187');        
        } catch (Exception e) {
            System.debug('SCS mock service error' + e);
        }
        try {
            body = '{"query": {"account_id": "0000000000053020012043727", "errorOSCCredit" : ""}}';
            RTL_ProductHoldingsLightningUtil.getSummaryProductSCSCreditCard(endpoint, body, '001100000000000000000000051187');        
        } catch (Exception e) {
            System.debug('SCS mock service error' + e);
        }
        Test.stopTest();
    }
    
    @isTest static void testetSummarySCSCreditCardError (){
        Test.startTest();
        String endpoint = 'callout:get_summary';
        String  body = '{"query": {"account_id": "0000000000053020012043727", "errorOSCCredit" : ""}}';
        //set mock service
        Test.setMock(HttpCalloutMock.class, new MockResponseGetSummary());
        try {
            RTL_ProductHoldingsLightningUtil.getSummaryProductSCSCreditCard(endpoint, body, '001100000000000000000000051187');        
        } catch (Exception e) {
            System.debug('SCS mock service error' + e);
        }
        Test.stopTest();
    }

    @isTest static void test_parseLogOSC() {
        RTL_ProductHoldingsLightningUtil.parseLogOSCService(getResponseOSC01, 'CustomerAccount - OSC01');
        RTL_ProductHoldingsLightningUtil.parseLogOSCService(getResponseOSC02, 'DepositAccount - OSC02');
        RTL_ProductHoldingsLightningUtil.parseLogOSCService(getResponseOSC03, 'CreditCardAccount - OSC03');
        RTL_ProductHoldingsLightningUtil.parseLogOSCService(getResponseOSC04, 'LoanAccount - OSC04');
        RTL_ProductHoldingsLightningUtil.parseLogOSCServiceRegEx(getResponseSCS_get_card, 'get_card');
        RTL_ProductHoldingsLightningUtil.parseLogOSCServiceRegEx(getResponseSCS_get_cards_balances, 'get_cards_balances');
    }

	@isTest static void test_fetchUserSessionId() {
        String sessionId = RTL_ProductHoldingsLightningUtil.fetchUserSessionId();
    }

    @isTest static void test_setFormatCreditData() {
        Test.startTest();
        Object product = (Map<String, Object>)JSON.deserializeUntyped(getResponseSCS_get_card);
        try {
            RTL_ProductHoldingsLightningUtil.setFormatCreditData(product, '001100000000000000000000051187');        
        } catch (Exception e) {
            System.debug('set format credit data error' + e);
        }
        Test.stopTest();
    }

    @isTest static void test_getWatermark() {
        Test.startTest();
        try {
            RTL_ProductHoldingsLightningUtil.getWatermarkHTML();        
        } catch (Exception e) {
        }
        Test.stopTest();
    }
    

    @isTest 
    static void testGetSubDebtTransaction(){
        Id TMBAutoLoanSalesProfile = [SELECT Id FROM Profile WHERE Name =: 'TMB Auto Loan Sales Profile' LIMIT 1].Id;
        Id TMBCRMAdminProfile = [SELECT Id FROM Profile WHERE Name =: 'TMB CRM Admin Profile' LIMIT 1].Id;

        User newUser1 = new User(FirstName = 'INACTIVE_FNAME' , LastName = 'INACTIVE_LNAME', 
                                    UserName='newUser1@tmbbank.com.test',
                                    Email='aaa@aa.com', Alias='inem',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='In_TMBTesttmb1',
                                    ProfileId = TMBAutoLoanSalesProfile
                                    , TimeZoneSidKey='America/New_York'
                                    ,isActive = true,
                                    Employee_ID__c ='MM00');
        insert newUser1;
        User newUser2 = new User(FirstName = 'INACTIVE_FNAME' , LastName = 'INACTIVE_LNAME', 
                                    UserName='newUser2@tmbbank.com.test',
                                    Email='aaa@aa.com', Alias='inem',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='In_TMBTesttmb2',
                                    ProfileId = TMBCRMAdminProfile
                                    , TimeZoneSidKey='America/New_York'
                                    ,isActive = true,
                                    Employee_ID__c ='MM01');
        insert newUser2;

        List<Account> accList = RTL_TestUtility.createAccounts(1, true);

        Data_Security_Matrix__c  custHigh = new Data_Security_Matrix__c (Access_Type__c='All', Profile_Name__c='TMB CRM Admin Profile', 
                                                                Section_Name__c='RtlCust:Customer Product Holding (High)');
        insert custHigh;

        Sub_Debt_Transaction__c sd = new Sub_Debt_Transaction__c(Name = 'Test SubDebt', 
        Sub_Debt_Transaction_Name__c = 'SubDebtTransactionNameTest1', Unit__c=100000, Interest_Rate__c='5%', Product_ID__c='testpid'
        , Term__c='testTerm', Issue_Date__c=Date.today(), Amount__c=100000, Maturity_Date__c=Date.today().addDays(300),Customer__c = accList.get(0).Id);
        insert sd;
            System.runAs(newUser2){
                    RTL_ProductHoldingsLightningUtil.getSubDebtTransaction(accList.get(0).Id);
            }
                      
            System.runAs(newUser1){
                try {
                    RTL_ProductHoldingsLightningUtil.getSubDebtTransaction(accList.get(0).Id);     
                } 
                catch (Exception e) {
                }       
            }
    }
}