@isTest
public class RTL_ProductHoldingSummaryController_Test {

    public static String getResponseOSC01 {
        get {
            return '{"GetCustomerAccountResponse":{"DepositAccounts":{"DepositAccount":[{"Status":"SUCCESS","AccountNumber":"2471779484","FIIdent":"0011000102470000","ProductType":"com.fnis.xes.IM","ProductCode":"101","OpenedDate":"2013-12-13","AccountStatus":"Active | ปกติ (Active)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00000542332499","FIIdent":"0011000100540200","ProductType":"com.fnis.xes.ST","ProductCode":"200","OpenedDate":"2013-12-31","AccountStatus":"Inactive | ปกติ (Active)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"02473011316001","FIIdent":"0011000102470300","ProductType":"com.fnis.xes.ST","ProductCode":"300","OpenedDate":"2014-03-18","AccountStatus":"Active | ปกติ (Active)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"02473011316002","FIIdent":"0011000102470300","ProductType":"com.fnis.xes.ST","ProductCode":"300","OpenedDate":"2014-02-05","AccountStatus":"Active | ปกติ (Active)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00000017681123","FIIdent":"0011000100010200","ProductType":"com.fnis.xes.ST","ProductCode":"200","OpenedDate":"2013-12-31","AccountStatus":"Dormant | ติดต่อสาขา (Contact Branch)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"SECJNT"},{"Status":"SUCCESS","AccountNumber":"00000292490034","FIIdent":"0011000100290200","ProductType":"com.fnis.xes.ST","ProductCode":"200","OpenedDate":"2013-07-31","AccountStatus":"Dormant | ติดต่อสาขา (Contact Branch)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"SECJNT"},{"Status":"SUCCESS","AccountNumber":"00002332136809","FIIdent":"0011000102330200","ProductType":"com.fnis.xes.ST","ProductCode":"221","OpenedDate":"2013-12-31","AccountStatus":"Inactive | ปกติ (Active)","Outstanding":"0","AvgOutstanding":"0","ODLimit":"0","Ledger":"0","InterestEarned":"0","HasJoint":"SECJNT"}]},"CreditCardAccounts":{"CreditCardAccount":[{"Status":"SUCCESS","CardNumber":"496694006242032105","CreditCardType":"011","OpenedDate":"2008-11-24","AccountStatus":"BLCK C"}]},"LoanAccounts":{"LoanAccount":[{"Status":"SUCCESS","AccountNumber":"00015405889701","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"S700","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00015414618701","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"S700","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00015414626701","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"S700","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00015414642701","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"S700","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00016151011001","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"ABHA","OpenedDate":"2020-01-24","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIJNT"}]},"BancassuranceAccounts":{"BancassuranceAccount":[{"Status":"SUCCESS","SumInsure":"0","AFVP":"0"}]},"InvestmentAccounts":{"InvestmentAccount":[{"Status":"SUCCESS","UnitHoldNo":"PT000000000000000003","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"PT000000000000000012","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"PT000000000000010501","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"PT000000000000103121","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"0010013993","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"0550003552","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"110063000379","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"110233000078","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"111001000034","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"111001010691","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"},{"Status":"SUCCESS","UnitHoldNo":"111324000011","Units":"0","MarketValue":"0","UnrealizedGL":"0","AvgCost":"0","NoOfUnit":"0"}]}},"Status":{"StatusCode":200,"StatusDesc":"success"}}';
        }
    }

    public static String getResponseOSC04 {
        get {
            return '{ "GetLoanAccountResponse": { "AcctInqRs": { "Status": { "StatusCode": "0", "Severity": "Info", "StatusDesc": "Success" }, "RqUID": "f5d6d581-e4d4-4f36-82f5-930f91342707", "LoanAcctId": { "AcctId": "001100010001000000015405889701", "AcctType": "LOC", "BankInfo": { "BankId": "11" } }, "LnCustAcctId": { "SPName": "", "CustPermId": "001100010001000000000006878141" }, "UpDt": "2020-01-06T15:18:28.858+07:00", "LastTrnDt": "", "AcctBal": [ { "BalType": "Principal", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "Outstanding", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "Used", "CurAmt": { "Amt": "1126125.00" } }, { "BalType": "LnAvail", "CurAmt": { "Amt": "0.00" } }, { "BalType": "PayoffAmt", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "Current", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "CurIntRecBal", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } }, { "BalType": "OrigCommitmentBal", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "CurCommitmentBal", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } } ], "ExtAcctBal": [ { "ExtBalType": "YTDInterest", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "LastYrInt", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "Orig", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "Unpaid/AccruedInt", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "YTDInterestAccrEC", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "TotalPastDue", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" } ], "BankAcctRec": { "LoanAcctId": { "AcctId": "", "AcctType": "", "BankInfo": "" }, "BankAcctInfo": { "CurCode": "", "PersonName": { "LastName": "", "FirstName": "", "LegalName": "" }, "ContactInfo": "", "ProductId": "S700" } }, "LOCAcctRec": { "LoanInfoCommon": { "AccountTitle": "MR.NAME00000006878141 LAST00000006878141", "RemainingPmtCount": "0", "RemainingPmtTerm": "1", "RegPmtCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "LastPmtCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "PastDuePmtCount": "1", "PastDueDt": "2011-12-28", "NextPmtDt": "9999-12-31", "NextPmtCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "DaysPastDue": "2927", "CurrentIntRate": { "Rate": "0.0000001" }, "OriginalIntRate": { "Rate": "0.0000001" }, "RateType": "F", "EffDt": "2011-12-27T12:00:00.000000-00:00", "MatDt": "2011-12-28", "LOCLimit": { "Amt": "1126125.00", "CurCode": "THB" }, "LateChargesCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "CollateralInfo": { "CollateralCode": "000" }, "SeqNum": "0", "DebitAcct": "", "CurrentPmtCount": "0", "FeesDueCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "PerDiemCurAmt": { "Amt": "0.0000000", "CurCode": "THB" }, "PastDuePmtCounter": { "Type": "6-LifeTime", "DelinquencyCategory": "151", "PastDuePmtCount": "1" }, "DraftAcctInfo": { "AcctId": "", "USA.RTN": "0" }, "ProcessDt": "2020-01-02", "CustType": "Personal", "AutoDebitMethod": "", "OrigMatureDt": "2011-12-28", "AccruedIntAmt1": { "Amt": "0.00", "CurCode": "THB" }, "AccruedIntAmt2": { "Amt": "0.00", "CurCode": "THB" }, "AccruedIntAmt3": { "Amt": "0.00", "CurCode": "THB" }, "TotalInt": { "Amt": "0.00", "CurCode": "THB" }, "NextPmtPrincipal": { "Amt": "0.00" }, "NextPmtInterest": { "Amt": "0.00" }, "AcctBal": { "BalType": "ToAccountBal", "CurAmt": { "Amt": "0.00" } }, "LastTrnDt": "2011-12-28", "LastCalculatedInterestDt": "9999-12-31", "ContractDt": "2011-12-27", "TransactionCount": "N" } }, "BankAcctStatus": { "BankAcctStatusCode": "Active" }, "Language": "", "Region": "", "AuthOfficer": "18176", "PersonInfo": [ { "NameAddrType": "", "FullName": "MR.NAME00000006878141 LAST00000006878141", "ContactInfo": { "PostAddr": { "Addr1": "ที่อยู่บรรทัด100000006878141", "Addr2": "ที่อยู่บรรทัด200000006878141", "City": "จ.ทดสอบ", "StateProv": "  ", "PostalCode": "1234567890", "Country": "US", "AddrType": "Mailing" } }, "TINInfo": { "TINType": "SSN", "TaxId": "", "CertCode": "Certification Not on File" }, "OEDCode": "All Other Individuals", "OEDInstitution": "All Other Individuals" }, { "NameAddrType": "", "FullName": "", "ContactInfo": { "PhoneNum": { "PhoneType": "Business", "Phone": "000-00006878" } } } ], "InsuranceInfo": { "InsRebateDueCurAmt": { "Amt": "0.00" } }, "PartyAcctRel": "" }, "Status": { "StatusCode": "200", "StatusDesc": "success" } }, "GetLoanAccountDetailResponse": { "Result": { "Status": "SUCCESS", "Message": "" } }, "Status": { "StatusCode": "200", "StatusDesc": "success" } }';
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

    public static String getResponseOSC02 {
        get {
            return '{ "GetDepositAccountResponse": { "AcctInqRs": { "Status": { "StatusCode": "0", "Severity": "Info", "StatusDesc": "Success", "AdditionalStatus": [ { "StatusCode": "0", "ServerStatusCode": "SD3000", "Severity": "Info", "StatusDesc": "Success" }, { "StatusCode": "-1000", "ServerStatusCode": "SD3000", "Severity": "Info", "StatusDesc": "OTHER ACTIVITY TODAY TSPCIMMI" } ] }, "RqUID": "61873ef9-c23c-4858-ad5b-4aa66a589078", "CustId": { "SPName": "IM", "CustPermId": "" }, "UpDt": "2013-12-13T00:00:00+07:00", "LastStmtDt": "2014-03-31", "AcctBal": [ { "BalType": "Avail", "CurAmt": { "Amt": "350250.00", "CurCode": "THB" } }, { "BalType": "AvgLedger", "CurAmt": { "Amt": "200250.00", "CurCode": "THB" } }, { "BalType": "Ledger", "CurAmt": { "Amt": "200250.00", "CurCode": "THB" } }, { "BalType": "Float", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } }, { "BalType": "FloatDay1", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } }, { "BalType": "FloatDay2", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } }, { "BalType": "FloatDay3", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } }, { "BalType": "ClosingLedger", "CurAmt": { "Amt": "350250.00", "CurCode": "THB" } } ], "ExtAcctBal": [ { "ExtBalType": "YTDInterest", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "SavingsYTDInterest", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "UnpaidAccruedInt", "CurAmt": { "Amt": "0.000000", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "LastYrInt", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "IODLastYrInt", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "IODYTDInterest", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "Hold", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" }, { "ExtBalType": "LastStmtBal", "CurAmt": { "Amt": "200250.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:04.400000+07:00" } ], "BankAcctRec": { "DepAcctId": { "AcctId": "00110001024700002471779484", "AcctType": "DDA", "AcctCur": "THB", "BankInfo": { "BankId": "11", "RefInfo": { "RefType": "PrimaryOfficer", "RefId": "00247" }, "BranchId": "247", "BranchName": "" } }, "BankAcctInfo": { "CurCode": "THB", "ContactInfo": { "PhoneNum": { "PhoneType": "Business", "Phone": "022993718" } }, "CustAcctUse": "Retail", "IntRateInfo": { "Rate": "0.000000" }, "ProductId": "IM101" }, "BankAcctStatus": { "BankAcctStatusCode": "Active | ปกติ (Active)" }, "AcctBal": { "BalType": "OnlineCredits", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } } }, "DepAcctRec": { "HoldCount": "0", "LastDepDt": "2013-12-13", "LastDepCurAmt": { "Amt": "200.00", "CurCode": "THB" }, "DepAcctInfo": { "AccountTitle": "นาง ทด สอบ", "OpenDt": "2013-01-17", "EndDt": "2014-04-30T12:00:00.000000-00:00", "TINInfo": { "TINType": "Invalid-NoTIN", "TaxId": "" }, "PostedDt": "2014-04-29", "RelCd": "None", "Language": "", "DepAcctStmtInfo": { "CurrentCycleChecksCnt": "0", "StmtCycleCd": "E", "StmtInst": "0", "CombinedStmtCd": "E00", "Frequency": { "Freq": "EndOfMonth" } }, "PersonInfo": { "NameAddrType": "", "FullName": "นาง ทด สอบ", "ContactInfo": { "PostAddr": { "Addr1": "222/2 ม.2", "Addr2": "ถ.พหลโยธิน", "Addr3": "แขวงจอมพล เขตจตุจักร", "City": "กรุงเทพมหานคร -", "PostalCode": "10900", "Country": "TH", "AddrType": "Mailing" } } }, "HoldIndCode": "0", "WithholdCd": "0", "WithholdReason": "0", "LastMonetaryDt": "2013-12-13", "AcctMiscData": { "AcctMiscType": "NameAddrTrailer", "MiscText": "Primary Name/Address trailer only exists" }, "LastCustActvDt": "2013-12-13", "AccrIODInt": "0.00", "ShrtName": "TOD SOB", "ODLimitAmt": "150000.00", "CurAnnlRate2": "0.000000", "AmountWaived": "0", "WaiveRemaining": "0", "WaiveUsed": "0", "SMSAlertFlag": "N", "OpeningMethod": "0" }, "IndicatorsInfo": "", "AcctBal": { "BalType": "TotalFloat", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } } }, "SavingsTrailerInd": "0", "OverDraftItem": [ { "ODMonth": "1", "Count": "0" }, { "ODMonth": "2", "Count": "0" }, { "ODMonth": "3", "Count": "0" }, { "ODMonth": "4", "Count": "0" }, { "ODMonth": "5", "Count": "0" }, { "ODMonth": "6", "Count": "0" }, { "ODMonth": "7", "Count": "0" }, { "ODMonth": "8", "Count": "0" }, { "ODMonth": "9", "Count": "0" }, { "ODMonth": "10", "Count": "0" }, { "ODMonth": "11", "Count": "0" }, { "ODMonth": "12", "Count": "0" } ], "NSFItem": [ { "NSFMonth": "1", "Count": "0" }, { "NSFMonth": "2", "Count": "0" }, { "NSFMonth": "3", "Count": "0" }, { "NSFMonth": "4", "Count": "0" }, { "NSFMonth": "5", "Count": "0" }, { "NSFMonth": "6", "Count": "0" }, { "NSFMonth": "7", "Count": "0" }, { "NSFMonth": "8", "Count": "0" }, { "NSFMonth": "9", "Count": "0" }, { "NSFMonth": "10", "Count": "0" }, { "NSFMonth": "11", "Count": "0" }, { "NSFMonth": "12", "Count": "0" } ] }, "Datawarehouse": { "AvgOutBal": 0 }, "Status": { "StatusCode": "200", "StatusDesc": "success" } }, "GetDepositAccountDetailResponse": { "Result": { "Status": "SUCCESS", "Message": "", "DepositAccount": { "Status": "SUCCESS", "Message": "", "AccountNumber": "2471779484", "AccountName": "นาง ทด สอบ", "ProductCode": "IM101", "OpenedDate": "2013-01-17+07:00", "AccountStatus": "Active | ปกติ (Active)", "Outstanding": "350250.00", "ODLimit": "150000.00", "Ledger": "200250.00", "InterestRate": "0.000000", "HasJoint": "", "SMSAlertService": "No" }, "JointAccount": { "Status": "SUCCESS", "Message": "" }, "LastMonthTransactionSummary": { "Status": "SUCCESS", "Message": "" }, "Beneficiary": { "Status": "SUCCESS", "Message": "" } } }, "Status": { "StatusCode": "200", "StatusDesc": "success" } }';
        }
    }
    
    private class BancassuranceAPI implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"GetBancassuranceAccountResponse":{"InsurancePolicyListCRMInqResponse":{"InsurancePolicyListCRMInqResult":{"Message":{"REQUEST_NO":"1","STATUS_CODE":"0000","STATUS_NAME":"Success"},"DataSets":[{"POLICY_NO":"T00004644","POLICY_NAME":"Smart Life 15/8","STATUS":"Active","COMPANY_NAME":"FWD Life Insurance","PRODUCT_GROUP":"LIFE INSURANCE","EFFECTIVE_DATE":"26+05+2008","EXPIRY_DATE":"26/05/2023","SUM_INSURE":"100000","INSURE_TYPE":"En05","EMP_ID":"14487","NEXT_PAYMENT_DATE":"","NEXT_INTERIM_DATE":"16/05/2018","NEXT_INTERIM_AMOUNT":"5000","TOTAL_PREMIUM_PAID":"25700","PAYMODE3":"01","PAYMENT_TYPE":"Annual","PAYMENT_TERM":" of 8","PAYMENT_DATE":"","PAYMENT_METHOD":"Cheque","PAYMENT_FREQUENCY_AMOUNT":"25700","PREMIUM":"25700","INTERIM_PAY_AMOUNT":"","BENEFICIARY":" ??????????????","BENEFICIARY_RELATION":"คู่สมรส,น้อง","INSURED_ADDRESS":"","INSURED_STREET":"","INSURED_DISTRICT":"","INSURED_AMPHUR":"","INSURED_PROVINCE":"","INSURED_POSTCODE":"","CAR_MODEL":"","CARBRAND":"","REGISTERPLATENUMBER":"","YEAR_OF_MANUFACTURE":""}]}},"Status":{"StatusCode":"200","StatusDesc":"success"}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class OSC04API implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody(getResponseOSC04);
            res.setStatusCode(200);
            return res;
        }
    }

    private class InvestmentAPI implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"Status":{"StatusDesc":"success","StatusCode":"200"},"GetInvestmentAccountResponse":{"Status":{"StatusDesc":"success","StatusCode":"200"},"GetFundDetails":[{"detailFund":{"SmartPortFlag":"N","FundNameEN":"JUMBO 25 Dividend LTF","FundNameTH":"กองทุนเปิด JUMBO 25 ปันผลหุ้นระยะยาว","UnitHolderNo":"PT000000000000011513","FundHouseCode":"EASTSPRING","UnitLTF5Y":"99081.7311","TaxDoc":"N","UnrealizedProfitPerc":"-8.13","UnrealizedProfit":"-219564.95","InvestmentValue":"2480435.05","Cost":"2700000","Nav":"21.0158","Unit":"118027.1531","DateAsOf":"25/11/2022"},"FundCode":"JB25LTF"},{"detailFund":{"SmartPortFlag":"N","FundNameEN":"JUMBO 25 RETIREMENT MUTUAL FUND","FundNameTH":"กองทุนเปิด JUMBO 25 เพื่อการเลี้ยงชีพ","UnitHolderNo":"PT000000000000011513","FundHouseCode":"EASTSPRING","UnitLTF5Y":"","TaxDoc":"Y","UnrealizedProfitPerc":"7.06","UnrealizedProfit":"155262.63","InvestmentValue":"2355261.19","Cost":"2199998.56","Nav":"35.3981","Unit":"66536.3731","DateAsOf":"25/11/2022"},"FundCode":"JB25RMF"},{"detailFund":{"SmartPortFlag":"N","FundNameEN":"TMB SET50 RETIREMENT MUTUAL FUND","FundNameTH":"กองทุนเปิดทหารไทย SET50 เพื่อการเลี้ยงชีพ","UnitHolderNo":"PT000000000000011513","FundHouseCode":"EASTSPRING","UnitLTF5Y":"","TaxDoc":"N","UnrealizedProfitPerc":"14.22","UnrealizedProfit":"127935.12","InvestmentValue":"1027935.20","Cost":"900000.08","Nav":"41.6549","Unit":"24677.4136","DateAsOf":"25/11/2022"},"FundCode":"TMB50RMF"}],"SumAccruedFee":"0.00","FeeAsOfDate":"02/01/2023","listFundClass":{"FundClass":[{"listFundHouse":{"FundHouse":{"listFundCode":{"FundCode":{"AccruedFee":"0.00","UnralizedProfitPercent":"-8.13","MarketValue":"2480435.05","UnrealizedProfit":"-219564.95","TFundUnitHolderNo":"","FundShortName":"JB25LTF","FundNickNameEN":"JUMBO 25 Dividend LTF","FundNickNameTH":"กองทุนเปิด JUMBO 25 ปันผลหุ้นระยะยาว","FundNameEN":"JUMBO 25 Dividend LTF","FundNameTH":"กองทุนเปิด JUMBO 25 ปันผลหุ้นระยะยาว","FundCode":"JB25LTF","UnitHolderNo":"PT000000000000011513"}},"FundHouseCode":"EASTSPRING"}},"FundClassNameTH":"Super Savings Fund(SSF)/LTF","FundClassNameEN":"Super Savings Fund(SSF)/LTF","FundClassCode":"800"},{"listFundHouse":{"FundHouse":{"listFundCode":{"FundCode":[{"AccruedFee":"0.00","UnralizedProfitPercent":"7.06","MarketValue":"2355261.19","UnrealizedProfit":"155262.63","TFundUnitHolderNo":"","FundShortName":"JB25RMF","FundNickNameEN":"JUMBO 25 RETIREMENT MUTUAL FUND","FundNickNameTH":"กองทุนเปิด JUMBO 25 เพื่อการเลี้ยงชีพ","FundNameEN":"JUMBO 25 RETIREMENT MUTUAL FUND","FundNameTH":"กองทุนเปิด JUMBO 25 เพื่อการเลี้ยงชีพ","FundCode":"JB25RMF","UnitHolderNo":"PT000000000000011513"},{"AccruedFee":"0.00","UnralizedProfitPercent":"14.22","MarketValue":"1027935.20","UnrealizedProfit":"127935.12","TFundUnitHolderNo":"","FundShortName":"TMB50RMF","FundNickNameEN":"TMB SET50 RETIREMENT MUTUAL FUND","FundNickNameTH":"กองทุนเปิดทหารไทย SET50 เพื่อการเลี้ยงชีพ","FundNameEN":"TMB SET50 RETIREMENT MUTUAL FUND","FundNameTH":"กองทุนเปิดทหารไทย SET50 เพื่อการเลี้ยงชีพ","FundCode":"TMB50RMF","UnitHolderNo":"PT000000000000011513"}]},"FundHouseCode":"EASTSPRING"}},"FundClassNameTH":"กองทุนรวมเพื่อการเลี้ยงชีพ","FundClassNameEN":"Retirement Mutual Fund","FundClassCode":"900"}]},"percOfFundType":{"Others":"1","LocalFixedIncome":"0.0","LocalEquity":"0.0","ForeignFixedIncome":"0.0","ForeignEquity":"1.0","Balanced":"0.0"}},"InvestmentAccount":[{"UnrealizedGLPerc":-8.13,"AssetClass":"LTF","AverageCostPerUnit":"22.8760918914344295914394973236036","convertedOpenedDate":"","CostOfInvestment":2700000,"FundCode":"JB25LTF","IssuerFundHouse":"TMB","MarketValue":2480435.05,"NavUnit":21.0158,"NumberOfUnit":118027.1531,"Params":"3lQE4v+CZEfgHNAAvuR37CstdOjhH0wt9h5cz84SQ5Ls8zavMZ6rF9v4WA5CcQF0","ProductName":"จัมโบ้ 25 ปันผล หุ้นระยะยาว","SeqGrp":"5","SubProductGroup":"NON MM","UnitHolderNo":"PT000000000000011513","UnitLtf5y":false,"UnrealizedGL":-219564.95},{"UnrealizedGLPerc":7.06,"AssetClass":"RMF","AverageCostPerUnit":"33.0645999699072866957937627652265","convertedOpenedDate":"","CostOfInvestment":2199998.56,"FundCode":"JB25RMF","IssuerFundHouse":"EASTSPRING","MarketValue":2355261.19,"NavUnit":35.3981,"NumberOfUnit":66536.3731,"Params":"hI3icHt4WHdeie0kVrkHAmMdS/Y3Kqgi/NeUbx66ny/I6bwF/OgqexH3zqd4Wv64","ProductName":"กองทุนเปิด JUMBO 25 เพื่อการเลี้ยงชีพ","SeqGrp":"5","SubProductGroup":"NON MM","UnitHolderNo":"PT000000000000011513","UnitLtf5y":false,"UnrealizedGL":155262.63},{"UnrealizedGLPerc":14.22,"AssetClass":"RMF","AverageCostPerUnit":"36.4705999821634468208613239760264","convertedOpenedDate":"","CostOfInvestment":900000.08,"FundCode":"TMB50RMF","IssuerFundHouse":"EASTSPRING","MarketValue":1027935.2,"NavUnit":41.6549,"NumberOfUnit":24677.4136,"Params":"vC8t2uLpwW9LxsWW0Cg6+iXFsVaEwUutpuzq5eDe93ACKSvYBkOX/E2SqJit7Kg2","ProductName":"กองทุนเปิดทหารไทย SET50 เพื่อการเลี้ยงชีพ","SeqGrp":"5","SubProductGroup":"NON MM","UnitHolderNo":"PT000000000000011513","UnitLtf5y":false,"UnrealizedGL":127935.12}]}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class InvestmentAPI2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"Status":{"StatusDesc":"success","StatusCode":"200"},"GetInvestmentAccountResponse":{"Status":{"StatusDesc":"success","StatusCode":"200"},"GetFundDetails":[],"SumAccruedFee":"0.00","FeeAsOfDate":"","listFundClass":"","percOfFundType":{"Others":"0","LocalFixedIncome":"0.0","LocalEquity":"0.0","ForeignFixedIncome":"0.0","ForeignEquity":"1.0","Balanced":"0.0"}},"InvestmentAccount":[]}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class OSC01API implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody(getResponseOSC01);
            res.setStatusCode(200);
            return res;
        }
    }

    private class CreditCardAPI implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody(getResponseSCS_get_cards_balances);
            res.setStatusCode(200);
            return res;
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

    private class AutoloanListAPI implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"isError":false,"Output":[{"ContractNo":"256203974","ContractStatusCode":"92","ContractStatusName":"ปิดสัญญาล่วงหน้า","HPTotalAmount":"350016.00","HPNetAmount":"327117.60","OutstandingAmount":"0.00","Installment":"7292.00","NumberOfInstallmentBalance":"0","TotalInstallments":"48","CurrentOfInstallments":"48","OverdueNo":"0","OverdueAmount":"0.00","Channel":"งามวงศ์วาน"},{"ContractNo":"236300013","ContractStatusCode":"21","ContractStatusName":"บอกเลิก","HPTotalAmount":"754640.00","HPNetAmount":"705271.12","OutstandingAmount":"440200.00","Installment":"15722.00","NumberOfInstallmentBalance":"28","TotalInstallments":"48","CurrentOfInstallments":"20","OverdueNo":"15","OverdueAmount":"235830.00","Channel":"รัชดา"}],"RES":{"RESPONSECODE":"HP001","RESPONSEMESSAGE":"Successful response"},"HTTPStatusCode":200}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest static void testGetProduct(){
        Test.setMock(HttpCalloutMock.class, new OSC01API());
        Object returnMap = RTL_ProductHoldingSummaryController.getProduct('001p0000010nXLSAA2', '000000000000051187', '000000000000051187', '001100000000000000000000051187');
    }
 
    @isTest static void testCallgetCreditCardData(){
        Test.setMock(HttpCalloutMock.class, new CreditCardAPI());
        Object returnMap = RTL_ProductHoldingSummaryController.callgetCreditCardData('000000000000051187', 'N', '', '', '001100000000000000000000051187', '001p0000010nXLSAA2');
    }

    @isTest static void testGetDepositProductDetail(){
        Test.setMock(HttpCalloutMock.class, new OSC02API());
        String unmaskB = '{"MarkedOutStanding":true,"MarkedAvgOutStanding":true,"MarkedLedgerBalance":true}';
        Map<String, Object> unmaskBalance = (Map<String, Object>)JSON.deserializeUntyped(unmaskB);
        Map<String, Boolean> fieldAccessMap = new Map<String, Boolean>();
        fieldAccessMap.put('Authorize', true);
        fieldAccessMap.put('Creditcard_CardActive', true);
        fieldAccessMap.put('Investment_NavUnit', true);
        fieldAccessMap.put('Bancassurance_SUM_INSURE', true);
        fieldAccessMap.put('Bancassurance_POLICY_NO', true);
        fieldAccessMap.put('ProductSum_Product_Group', true);
        fieldAccessMap.put('AutoLoan_Status_AutoLoan', true);
        fieldAccessMap.put('Loan_HasCoBorrower', true);
        fieldAccessMap.put('Deposit_Other', true);
        fieldAccessMap.put('AutoLoan_Paid_Period', true);
        fieldAccessMap.put('Deposit_SubProductGroup', true);
        fieldAccessMap.put('Bancassurance_EFFECTIVE_DATE', true);
        fieldAccessMap.put('Investment_MarketValue', true);
        fieldAccessMap.put('Deposit_Status', true);
        fieldAccessMap.put('Bancassurance_PRODUCT_GROUP', true);
        fieldAccessMap.put('Bancassurance_EXPIRY_DATE', true);
        fieldAccessMap.put('Investment_NumberOfUnit', true);
        fieldAccessMap.put('ProductSum_Number_of_Account', true);
        fieldAccessMap.put('AutoLoan_Remain_Period', true);
        fieldAccessMap.put('ProductSum_MarkedOutstanding', true);
        fieldAccessMap.put('subDebtTranDetail', true);
        fieldAccessMap.put('Loan_MarkedLoanAccountNumber', true);
        fieldAccessMap.put('AutoLoan_HUB', true);
        fieldAccessMap.put('Creditcard_MarkedCardNumber', true);
        fieldAccessMap.put('AutoLoan_Installment_Amount', true);
        fieldAccessMap.put('Loan_SubProductGroup', true);
        fieldAccessMap.put('Deposit_MarkedLedgerBalance', true);
        fieldAccessMap.put('Creditcard_MarkedOutstanding', true);
        fieldAccessMap.put('Investment_IssuerFundHouse', true);
        fieldAccessMap.put('AutoLoan_HP_Amount', true);
        fieldAccessMap.put('Creditcard_SubProductGroup', true);
        fieldAccessMap.put('Loan_ProductName', true);
        fieldAccessMap.put('Loan_MarkedVLimit', true);
        fieldAccessMap.put('AutoLoan_Overdue_Amount', true);
        fieldAccessMap.put('Deposit_ProductName', true);
        fieldAccessMap.put('ProductSum_Number_of_Product', true);
        fieldAccessMap.put('ProductSum_MarkedODLimit', true);
        fieldAccessMap.put('AutoLoan_MarkedOverdue_Amount', true);
        fieldAccessMap.put('Investment_PercentWeight', true);
        fieldAccessMap.put('Investment_UnitHolderNo', true);
        fieldAccessMap.put('Bancassurance_PREMIUM', true);
        fieldAccessMap.put('Creditcard_ProductName', true);
        fieldAccessMap.put('Investment_UnrealizedGL', true);
        fieldAccessMap.put('Deposit_MarkedDepositAccountNumber', true);
        fieldAccessMap.put('Deposit_MarkedAvgOutStanding', true);
        fieldAccessMap.put('Loan_Status', true);
        fieldAccessMap.put('AutoLoan_Outstanding_Amount', true);
        fieldAccessMap.put('Investment_AverageCostPerUnit', true);
        fieldAccessMap.put('Bancassurance_STATUS', true);
        fieldAccessMap.put('Loan_MarkedOutstanding', true);
        fieldAccessMap.put('Investment_AssetClass', true);
        fieldAccessMap.put('Loan_convertedMaturityDate', true);
        fieldAccessMap.put('Creditcard_CardRole', true);
        fieldAccessMap.put('Deposit_MarkedOutStanding', true);
        fieldAccessMap.put('Investment_UnrealizedGLPerc', true);
        fieldAccessMap.put('Investment_CostOfInvestment', true);
        fieldAccessMap.put('Bancassurance_POLICY_NAME', true);
        fieldAccessMap.put('Deposit_HasJoint', true);
        fieldAccessMap.put('AutoLoan_Contract_Period', true);
        fieldAccessMap.put('Investment_ProductName', true);
        fieldAccessMap.put('AutoLoan_MarkedHP_Account_No', true);
        fieldAccessMap.put('Creditcard_MaskedCreditLine', true);
        fieldAccessMap.put('Creditcard_MarkedVLimit', true);
        fieldAccessMap.put('Bancassurance_COMPANY_NAME', true);
        RTL_ProductHoldingSummaryController.DepositProductWrapper dp = new RTL_ProductHoldingSummaryController.DepositProductWrapper();
        dp.DepositAccountNumber = 'i+hP755weaY0m/XtZBGtfQ==';
        dp.DepositProductCode = 'bjIp21IekrtZ9XHjx0iJ1A==';
        dp.FIIdent = '0011000100010200';
        dp.HasJoint = 'PRIIND';
        dp.MarkedDepositAccountNumber = 'xxx-9-99811-x';
        dp.MarkedLedgerBalance = 'Loading...';
        dp.MarkedAvgOutStanding = '';
        dp.MarkedOutStanding = '';
        dp.Other = '';
        dp.ProductName = 'บัญชี ทีทีบี โนฟิกซ์';
        dp.ProductType = 'com.fnis.xes.ST';
        dp.SeqGrp = '2';
        dp.Status = 'Dormant | ติดต่อสาขา (Contact Branch)';
        dp.SubProductGroup = 'NON TRANSACTIONAL';
        Map<String,Object> returnMap = RTL_ProductHoldingSummaryController.getDepositProductDetail(dp, '000000000000051187', '001100000000000000000000051187', unmaskBalance, '001p0000010nXLSAA2', fieldAccessMap, true, new List<String>());
    }

    @isTest static void testGetBancDetailData200(){
        Test.setMock(HttpCalloutMock.class, new BancassuranceAPI());
        Object returnMap = RTL_ProductHoldingSummaryController.getBancAssuranceData('000000000000051187', '001p0000010nXLSAA2', '001100000000000000000000051187');
    }

    @isTest static void testGetInvestmentAccountList(){
        Test.setMock(HttpCalloutMock.class, new InvestmentAPI());
        Object returnMap = RTL_ProductHoldingSummaryController.getInvestmentAccountList('PT100000000000050089', '001p0000010nXLSAA2', '001100000000000000000000051187', '000000000000051187', false);
    }

    @isTest static void testGetInvestmentAccountList2(){
        Test.setMock(HttpCalloutMock.class, new InvestmentAPI2());
        Object returnMap = RTL_ProductHoldingSummaryController.getInvestmentAccountList('PT100000000000050089', '001p0000010nXLSAA2', '001100000000000000000000051187', '000000000000051187', false);
    }


    @isTest static void testGetAutoloanHpFleetHpList(){
        Test.setMock(HttpCalloutMock.class, new AutoloanListAPI());
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped('{"service":"CoreHP","recordId":"001p0000010nWtu","tmbCustId":"001100000000000000000001601819"}');
        Object returnMap = RTL_ProductHoldingSummaryController.getAutoloanHpFleetHpList('TBANK', '000000000001601819', 'HP', '20230103', '03300854', '001p0000010nXLSAA2', (Object) jsonMap, '{"isAccessibleCusHoldLow":true,"isAccessibleCusHoldMid":true,"isAccessibleCusHoldHig":true}');
    }

    @isTest static void testGetLoanProductDetail(){
        Test.setMock(HttpCalloutMock.class, new OSC04API());
        String unm = '{"MarkedVLimit":true,"MarkedOutstanding":true}';
        Map<String, Object> unmask = (Map<String, Object>)JSON.deserializeUntyped(unm);
        Map<String, Boolean> fieldAccessMap = new Map<String, Boolean>();
        fieldAccessMap.put('Authorize', true);
        fieldAccessMap.put('Creditcard_CardActive', true);
        fieldAccessMap.put('Investment_NavUnit', true);
        fieldAccessMap.put('Bancassurance_SUM_INSURE', true);
        fieldAccessMap.put('Bancassurance_POLICY_NO', true);
        fieldAccessMap.put('ProductSum_Product_Group', true);
        fieldAccessMap.put('AutoLoan_Status_AutoLoan', true);
        fieldAccessMap.put('Loan_HasCoBorrower', true);
        fieldAccessMap.put('Deposit_Other', true);
        fieldAccessMap.put('AutoLoan_Paid_Period', true);
        fieldAccessMap.put('Deposit_SubProductGroup', true);
        fieldAccessMap.put('Bancassurance_EFFECTIVE_DATE', true);
        fieldAccessMap.put('Investment_MarketValue', true);
        fieldAccessMap.put('Deposit_Status', true);
        fieldAccessMap.put('Bancassurance_PRODUCT_GROUP', true);
        fieldAccessMap.put('Bancassurance_EXPIRY_DATE', true);
        fieldAccessMap.put('Investment_NumberOfUnit', true);
        fieldAccessMap.put('ProductSum_Number_of_Account', true);
        fieldAccessMap.put('AutoLoan_Remain_Period', true);
        fieldAccessMap.put('ProductSum_MarkedOutstanding', true);
        fieldAccessMap.put('subDebtTranDetail', true);
        fieldAccessMap.put('Loan_MarkedLoanAccountNumber', true);
        fieldAccessMap.put('AutoLoan_HUB', true);
        fieldAccessMap.put('Creditcard_MarkedCardNumber', true);
        fieldAccessMap.put('AutoLoan_Installment_Amount', true);
        fieldAccessMap.put('Loan_SubProductGroup', true);
        fieldAccessMap.put('Deposit_MarkedLedgerBalance', true);
        fieldAccessMap.put('Creditcard_MarkedOutstanding', true);
        fieldAccessMap.put('Investment_IssuerFundHouse', true);
        fieldAccessMap.put('AutoLoan_HP_Amount', true);
        fieldAccessMap.put('Creditcard_SubProductGroup', true);
        fieldAccessMap.put('Loan_ProductName', true);
        fieldAccessMap.put('Loan_MarkedVLimit', true);
        fieldAccessMap.put('AutoLoan_Overdue_Amount', true);
        fieldAccessMap.put('Deposit_ProductName', true);
        fieldAccessMap.put('ProductSum_Number_of_Product', true);
        fieldAccessMap.put('ProductSum_MarkedODLimit', true);
        fieldAccessMap.put('AutoLoan_MarkedOverdue_Amount', true);
        fieldAccessMap.put('Investment_PercentWeight', true);
        fieldAccessMap.put('Investment_UnitHolderNo', true);
        fieldAccessMap.put('Bancassurance_PREMIUM', true);
        fieldAccessMap.put('Creditcard_ProductName', true);
        fieldAccessMap.put('Investment_UnrealizedGL', true);
        fieldAccessMap.put('Deposit_MarkedDepositAccountNumber', true);
        fieldAccessMap.put('Deposit_MarkedAvgOutStanding', true);
        fieldAccessMap.put('Loan_Status', true);
        fieldAccessMap.put('AutoLoan_Outstanding_Amount', true);
        fieldAccessMap.put('Investment_AverageCostPerUnit', true);
        fieldAccessMap.put('Bancassurance_STATUS', true);
        fieldAccessMap.put('Loan_MarkedOutstanding', true);
        fieldAccessMap.put('Investment_AssetClass', true);
        fieldAccessMap.put('Loan_convertedMaturityDate', true);
        fieldAccessMap.put('Creditcard_CardRole', true);
        fieldAccessMap.put('Deposit_MarkedOutStanding', true);
        fieldAccessMap.put('Investment_UnrealizedGLPerc', true);
        fieldAccessMap.put('Investment_CostOfInvestment', true);
        fieldAccessMap.put('Bancassurance_POLICY_NAME', true);
        fieldAccessMap.put('Deposit_HasJoint', true);
        fieldAccessMap.put('AutoLoan_Contract_Period', true);
        fieldAccessMap.put('Investment_ProductName', true);
        fieldAccessMap.put('AutoLoan_MarkedHP_Account_No', true);
        fieldAccessMap.put('Creditcard_MaskedCreditLine', true);
        fieldAccessMap.put('Creditcard_MarkedVLimit', true);
        fieldAccessMap.put('Bancassurance_COMPANY_NAME', true);
        RTL_ProductHoldingSummaryController.LoanProductWrapper lp = new RTL_ProductHoldingSummaryController.LoanProductWrapper();
        lp.HasCoBorrower = 'No';
        lp.Link = '';
        lp.Outstanding = '4555';
        lp.VLimit = '55555';
        lp.SeqGrp = '8';
        lp.Fiident = '0011000100010000';
        lp.AccountNumber = 'VLOZNqZuVZbHJjGR32X60Q==';
        lp.AccountType = '0HmwANzoQrAVrEYzir9aLQ==';
        lp.MarkedLoanAccountNumber = 'xxx-6-15101-x';
        lp.SubProductGroup = 'HOME LOAN FOR STAFF';
        lp.ProductName = 'Housing (New Benefit)';
        lp.Status = 'Active';
        lp.MarkedOutstanding = '***********';
        lp.MarkedVLimit = '***********';
        lp.HasCoBorrower = 'PRIIND';
        lp.isError = false;
        Object returnMap = RTL_ProductHoldingSummaryController.getLoanProductDetail(lp, '001p0000010nXLSAA2', '000000000001601819', '001100000000000000000001601819', unmask, fieldAccessMap, true);
    }

    @isTest static void testGetWaterMark(){
        String returnMap = RTL_ProductHoldingSummaryController.getWatermarkHTML();
    }

    @isTest static void testGetAccessibleCustHolding(){
        Map<String, Boolean> returnMap = RTL_ProductHoldingSummaryController.getAccessibleCustHolding('001p0000010nXLSAA2');
    }

    @isTest static void testGetAllUnmaskBalance(){
        String returnMap = RTL_ProductHoldingSummaryController.getAllUnmaskBalance();
    }

    @isTest static void testMaskWithXX1(){
        String returnMap1 = RTL_ProductHoldingSummaryController.maskWithXX('5000');
        String returnMap2 = RTL_ProductHoldingSummaryController.maskWithXX('88');
        String returnMap3 = RTL_ProductHoldingSummaryController.maskWithXX('0');
    }

    @isTest static void testGetCents(){
        String returnMap1 = RTL_ProductHoldingSummaryController.getCents(5000.83);
        String returnMap2 = RTL_ProductHoldingSummaryController.getCents(7000);
    }

    @isTest static void testGetAppConfigMdtByKey(){
        Object returnMap1 = RTL_ProductHoldingSummaryController.getAppConfigMdtByKey('CoreHP_Company');
    }

    @isTest static void testGetALDXWFMdt(){
        Object returnMap1 = RTL_ProductHoldingSummaryController.getALDXWFMdt();
    }

    @isTest static void testGetALDXWFMdtAll(){
        Object returnMap1 = RTL_ProductHoldingSummaryController.getALDXWFMdtAll();
    }

    @isTest static void testGetUnmaskBalance(){
        Map<String, Object> returnMap1 = RTL_ProductHoldingSummaryController.getUnmaskBalance('Deposit_Section');
    }

    @isTest static void testGetSummarizedObj(){
        String str = '{"accountList":[],"productList":[],"outStandingList":[0],"odLimitList":[0]}';
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(str);
        Object returnMap1 = RTL_ProductHoldingSummaryController.getSummarizedObj('001p0000010nXLSAA2', '001100000000000000000001601819', false, '1', (Object) jsonMap, true, true, false);
        Object returnMap2 = RTL_ProductHoldingSummaryController.getSummarizedObj('001p0000010nXLSAA2', '001100000000000000000001601819', false, '2', (Object) jsonMap, true, true, false);
        Object returnMap3 = RTL_ProductHoldingSummaryController.getSummarizedObj('001p0000010nXLSAA2', '001100000000000000000001601819', false, '3', (Object) jsonMap, true, true, false);
        Object returnMap4 = RTL_ProductHoldingSummaryController.getSummarizedObj('001p0000010nXLSAA2', '001100000000000000000001601819', false, '5', (Object) jsonMap, true, true, false);
        Object returnMap5 = RTL_ProductHoldingSummaryController.getSummarizedObj('001p0000010nXLSAA2', '001100000000000000000001601819', false, '6', (Object) jsonMap, true, true, false);
        Object returnMap6 = RTL_ProductHoldingSummaryController.getSummarizedObj('001p0000010nXLSAA2', '001100000000000000000001601819', false, '7', (Object) jsonMap, true, true, false);
        Object returnMap7 = RTL_ProductHoldingSummaryController.getSummarizedObj('001p0000010nXLSAA2', '001100000000000000000001601819', false, '8', (Object) jsonMap, true, true, false);
        Object returnMap8 = RTL_ProductHoldingSummaryController.getSummarizedObj('001p0000010nXLSAA2', '001100000000000000000001601819', false, '9', (Object) jsonMap, true, true, false);
        Object returnMap9 = RTL_ProductHoldingSummaryController.getSummarizedObj('001p0000010nXLSAA2', '001100000000000000000001601819', false, 'AutoLoan', (Object) jsonMap, true, true, false);
        
        String str2 = '{"accountList":[],"productList":[],"outStandingList":[500, "700"],"odLimitList":["500", 700]}';
        Map<String, Object> jsonMap2 = (Map<String, Object>)JSON.deserializeUntyped(str2);
        Object returnMap33 = RTL_ProductHoldingSummaryController.getSummarizedObj('001p0000010nXLSAA2', '001100000000000000000001601819', true, '3', (Object) jsonMap2, true, true, false);
        Object returnMap44 = RTL_ProductHoldingSummaryController.getSummarizedObj('001p0000010nXLSAA2', '001100000000000000000001601819', true, '6', (Object) jsonMap2, true, true, false);
        Object returnMap77 = RTL_ProductHoldingSummaryController.getSummarizedObj('001p0000010nXLSAA2', '001100000000000000000001601819', true, '7', (Object) jsonMap2, true, true, false);
    }
}