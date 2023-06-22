@isTest
public class LoanProductDetailViewController_Test {

    public static String getResponseOSC04 {
        get {
            return '{ "GetLoanAccountResponse": { "AcctInqRs": { "Status": { "StatusCode": "0", "Severity": "Info", "StatusDesc": "Success" }, "RqUID": "f5d6d581-e4d4-4f36-82f5-930f91342707", "LoanAcctId": { "AcctId": "001100010001000000015405889701", "AcctType": "LOC", "BankInfo": { "BankId": "11" } }, "LnCustAcctId": { "SPName": "", "CustPermId": "001100010001000000000006878141" }, "UpDt": "2020-01-06T15:18:28.858+07:00", "LastTrnDt": "", "AcctBal": [ { "BalType": "Principal", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "Outstanding", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "Used", "CurAmt": { "Amt": "1126125.00" } }, { "BalType": "LnAvail", "CurAmt": { "Amt": "0.00" } }, { "BalType": "PayoffAmt", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "Current", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "CurIntRecBal", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } }, { "BalType": "OrigCommitmentBal", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "CurCommitmentBal", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } } ], "ExtAcctBal": [ { "ExtBalType": "YTDInterest", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "LastYrInt", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "Orig", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "Unpaid/AccruedInt", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "YTDInterestAccrEC", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "TotalPastDue", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" } ], "BankAcctRec": { "LoanAcctId": { "AcctId": "", "AcctType": "", "BankInfo": "" }, "BankAcctInfo": { "CurCode": "", "PersonName": { "LastName": "", "FirstName": "", "LegalName": "" }, "ContactInfo": "", "ProductId": "S700" } }, "LOCAcctRec": { "LoanInfoCommon": { "AccountTitle": "MR.NAME00000006878141 LAST00000006878141", "RemainingPmtCount": "0", "RemainingPmtTerm": "1", "RegPmtCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "LastPmtCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "PastDuePmtCount": "1", "PastDueDt": "2011-12-28", "NextPmtDt": "9999-12-31", "NextPmtCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "DaysPastDue": "2927", "CurrentIntRate": { "Rate": "0.0000001" }, "OriginalIntRate": { "Rate": "0.0000001" }, "RateType": "F", "EffDt": "2011-12-27T12:00:00.000000-00:00", "MatDt": "2011-12-28", "LOCLimit": { "Amt": "1126125.00", "CurCode": "THB" }, "LateChargesCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "CollateralInfo": { "CollateralCode": "000" }, "SeqNum": "0", "DebitAcct": "", "CurrentPmtCount": "0", "FeesDueCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "PerDiemCurAmt": { "Amt": "0.0000000", "CurCode": "THB" }, "PastDuePmtCounter": { "Type": "6-LifeTime", "DelinquencyCategory": "151", "PastDuePmtCount": "1" }, "DraftAcctInfo": { "AcctId": "", "USA.RTN": "0" }, "ProcessDt": "2020-01-02", "CustType": "Personal", "AutoDebitMethod": "", "OrigMatureDt": "2011-12-28", "AccruedIntAmt1": { "Amt": "0.00", "CurCode": "THB" }, "AccruedIntAmt2": { "Amt": "0.00", "CurCode": "THB" }, "AccruedIntAmt3": { "Amt": "0.00", "CurCode": "THB" }, "TotalInt": { "Amt": "0.00", "CurCode": "THB" }, "NextPmtPrincipal": { "Amt": "0.00" }, "NextPmtInterest": { "Amt": "0.00" }, "AcctBal": { "BalType": "ToAccountBal", "CurAmt": { "Amt": "0.00" } }, "LastTrnDt": "2011-12-28", "LastCalculatedInterestDt": "9999-12-31", "ContractDt": "2011-12-27", "TransactionCount": "N" } }, "BankAcctStatus": { "BankAcctStatusCode": "Active" }, "Language": "", "Region": "", "AuthOfficer": "18176", "PersonInfo": [ { "NameAddrType": "", "FullName": "MR.NAME00000006878141 LAST00000006878141", "ContactInfo": { "PostAddr": { "Addr1": "ที่อยู่บรรทัด100000006878141", "Addr2": "ที่อยู่บรรทัด200000006878141", "City": "จ.ทดสอบ", "StateProv": "  ", "PostalCode": "1234567890", "Country": "US", "AddrType": "Mailing" } }, "TINInfo": { "TINType": "SSN", "TaxId": "", "CertCode": "Certification Not on File" }, "OEDCode": "All Other Individuals", "OEDInstitution": "All Other Individuals" }, { "NameAddrType": "", "FullName": "", "ContactInfo": { "PhoneNum": { "PhoneType": "Business", "Phone": "000-00006878" } } } ], "InsuranceInfo": { "InsRebateDueCurAmt": { "Amt": "0.00" } }, "PartyAcctRel": "" }, "Status": { "StatusCode": "200", "StatusDesc": "success" } }, "GetLoanAccountDetailResponse": { "Result":{"CoBorrowerInformation":{"Status":"success", "CoBorrower":[{"Name":"test man1", "Relationship":"SECJNT"}]},  "InterestPlan":[{"AccountNumber":"xxx-6-15101-x", "Period":"monthly", "InterestRate":"5"}],"Status": "SUCCESS", "Message": "" } }, "Status": { "StatusCode": "200", "StatusDesc": "success" } }';
        }
    }

    public static String getResponseOSC04Error {
        get {
            return '{ "GetLoanAccountResponse": { "AcctInqRs": { "Status": { "StatusCode": "0", "Severity": "Info", "StatusDesc": "Success" }, "RqUID": "f5d6d581-e4d4-4f36-82f5-930f91342707", "LoanAcctId": { "AcctId": "001100010001000000015405889701", "AcctType": "LOC", "BankInfo": { "BankId": "11" } }, "LnCustAcctId": { "SPName": "", "CustPermId": "001100010001000000000006878141" }, "UpDt": "2020-01-06T15:18:28.858+07:00", "LastTrnDt": "", "AcctBal": [ { "BalType": "Principal", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "Outstanding", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "Used", "CurAmt": { "Amt": "1126125.00" } }, { "BalType": "LnAvail", "CurAmt": { "Amt": "0.00" } }, { "BalType": "PayoffAmt", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "Current", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "CurIntRecBal", "CurAmt": { "Amt": "0.00", "CurCode": "THB" } }, { "BalType": "OrigCommitmentBal", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } }, { "BalType": "CurCommitmentBal", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" } } ], "ExtAcctBal": [ { "ExtBalType": "YTDInterest", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "LastYrInt", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "Orig", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "Unpaid/AccruedInt", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "YTDInterestAccrEC", "CurAmt": { "Amt": "0.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" }, { "ExtBalType": "TotalPastDue", "CurAmt": { "Amt": "1126125.00", "CurCode": "THB" }, "EffDt": "2020-01-06T15:18:28.849000+07:00" } ], "BankAcctRec": { "LoanAcctId": { "AcctId": "", "AcctType": "", "BankInfo": "" }, "BankAcctInfo": { "CurCode": "", "PersonName": { "LastName": "", "FirstName": "", "LegalName": "" }, "ContactInfo": "", "ProductId": "S700" } }, "LOCAcctRec": { "LoanInfoCommon": { "AccountTitle": "MR.NAME00000006878141 LAST00000006878141", "RemainingPmtCount": "0", "RemainingPmtTerm": "1", "RegPmtCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "LastPmtCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "PastDuePmtCount": "1", "PastDueDt": "2011-12-28", "NextPmtDt": "9999-12-31", "NextPmtCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "DaysPastDue": "2927", "CurrentIntRate": { "Rate": "0.0000001" }, "OriginalIntRate": { "Rate": "0.0000001" }, "RateType": "F", "EffDt": "2011-12-27T12:00:00.000000-00:00", "MatDt": "2011-12-28", "LOCLimit": { "Amt": "1126125.00", "CurCode": "THB" }, "LateChargesCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "CollateralInfo": { "CollateralCode": "000" }, "SeqNum": "0", "DebitAcct": "", "CurrentPmtCount": "0", "FeesDueCurAmt": { "Amt": "0.00", "CurCode": "THB" }, "PerDiemCurAmt": { "Amt": "0.0000000", "CurCode": "THB" }, "PastDuePmtCounter": { "Type": "6-LifeTime", "DelinquencyCategory": "151", "PastDuePmtCount": "1" }, "DraftAcctInfo": { "AcctId": "", "USA.RTN": "0" }, "ProcessDt": "2020-01-02", "CustType": "Personal", "AutoDebitMethod": "", "OrigMatureDt": "2011-12-28", "AccruedIntAmt1": { "Amt": "0.00", "CurCode": "THB" }, "AccruedIntAmt2": { "Amt": "0.00", "CurCode": "THB" }, "AccruedIntAmt3": { "Amt": "0.00", "CurCode": "THB" }, "TotalInt": { "Amt": "0.00", "CurCode": "THB" }, "NextPmtPrincipal": { "Amt": "0.00" }, "NextPmtInterest": { "Amt": "0.00" }, "AcctBal": { "BalType": "ToAccountBal", "CurAmt": { "Amt": "0.00" } }, "LastTrnDt": "2011-12-28", "LastCalculatedInterestDt": "9999-12-31", "ContractDt": "2011-12-27", "TransactionCount": "N" } }, "BankAcctStatus": { "BankAcctStatusCode": "Active" }, "Language": "", "Region": "", "AuthOfficer": "18176", "PersonInfo": [ { "NameAddrType": "", "FullName": "MR.NAME00000006878141 LAST00000006878141", "ContactInfo": { "PostAddr": { "Addr1": "ที่อยู่บรรทัด100000006878141", "Addr2": "ที่อยู่บรรทัด200000006878141", "City": "จ.ทดสอบ", "StateProv": "  ", "PostalCode": "1234567890", "Country": "US", "AddrType": "Mailing" } }, "TINInfo": { "TINType": "SSN", "TaxId": "", "CertCode": "Certification Not on File" }, "OEDCode": "All Other Individuals", "OEDInstitution": "All Other Individuals" }, { "NameAddrType": "", "FullName": "", "ContactInfo": { "PhoneNum": { "PhoneType": "Business", "Phone": "000-00006878" } } } ], "InsuranceInfo": { "InsRebateDueCurAmt": { "Amt": "0.00" } }, "PartyAcctRel": "" }, "Status": { "StatusCode": "200", "StatusDesc": "success" } }, "GetLoanAccountDetailResponse": { "Result": {"CoBorrowerInformation":{"Status":"success", "CoBorrower":[{"Name":"test man1", "Relationship":"SECJNT"}]},  "Status": "SUCCESS", "Message": "" } }, "Status": { "StatusCode": "666", "StatusDesc": "not success" }, "StatusCode":"666" }';
        }
    }

    // public static String getResponseCallBackGuarantor {
        // get {
            // return '{"status":{"code":"0000","description":"Success"},"guarantors":[{"c_name":"hhhh","id_no":"4552466","id_birth_date":"24/12/1997"},{"c_name":"iiiiii","id_no":"6432857","id_birth_date":"14/2/1999"},{"c_name":"pppp","id_no":"4552466","id_birth_date":"24/12/1997"},{"c_name":"nnnnn","id_no":"4552466","id_birth_date":"24/12/1997"}]}';
        // }
    // }

    public static String getResponseCallBackGuarantor {
        get {
            return '{"status":{"code":"0000","description":"Success"},"account":{"guarantors":[{"c_name":"hhhh","id_no":"4552466","id_birth_date":"24/12/1997"},{"c_name":"iiiiii","id_no":"6432857","id_birth_date":"14/2/1999"},{"c_name":"pppp","id_no":"4552466","id_birth_date":"24/12/1997"},{"c_name":"nnnnn","id_no":"4552466","id_birth_date":"24/12/1997"}]}}';
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

    private class OSC04APIError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody(getResponseOSC04Error);
            res.setStatusCode(200);
            return res;
        }
    }

    private class CYBAPI implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"errors":[{"namespace":"DWH","message":"ORA-00942: table or view does not exist (java.sql.SQLSyntaxErrorException).","code":"5000"}],"status":{"code":"0000","description":"Success"},"loan_account":{"account_no":"0195490032901","account_type":"LOC","info":{"account_title":"MR.NAME00000000000001 LAST00000000000001","customer_type":"Personal"},"payment_info":{"last_payment_date":null,"past_due_date":"2020-03-31","next_due_date":"2020-05-31","next_payment_principal_amount":10100,"next_payment_interest_amount":0,"next_payment_date":"2020-05-31","past_due_payment_count":2,"total_past_due_amount":20100,"current_loan_amount":10000,"last_payment_amount":0,"next_payment_amount":10100,"late_charges_amount":7569.86,"fee_due_amount":200,"interest":{"current_rate":"6.2500000","original_rate":"0.0000001"}},"balance_info":{"balances":{"account_limit":{"amount":1000000,"currency":"THB"},"principal":{"amount":1000000,"currency":"THB"},"outstanding":{"amount":1000000,"currency":"THB"},"unpaid_accrued_interest":{"amount":11910.95,"currency":"THB"},"current_commitment":{"amount":1000000,"currency":"THB"}},"od":{"od_limit_amount":0}},"personal_info":{"full_name":"MR.NAME00000000000001 LAST00000000000001","contact_info":{"address1":"ที่อยู่บรรทัด100000000000001","address2":"ที่อยู่บรรทัด200000000000001","address3":"","city":"จ.ทดสอบ","postal_code":"1234567890","country":"US","address_type":"Mailing"}}}}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class GuarantorAPI implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody(getResponseCallBackGuarantor);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest static void testGetLoanProductDetail(){
        String res = '{"MarkedLoanAccountNumber":"xxx-6-15101-x","SubProductGroup":"HOME LOAN FOR STAFF","ProductName":"Housing (New Benefit)","MarkedOutstanding":"***********","MarkedVLimit":"***********","HasCoBorrower":"PRIIND"}';
        Map<String, Object> osc01 = (Map<String, Object>)JSON.deserializeUntyped(res);
        Test.setMock(HttpCalloutMock.class, new OSC04API());
        Map<String,Object> returnMap = LoanProductDetailViewController.getLoanProductDetail('000000000000051187', '0011000100010000', 'VLOZNqZuVZbHJjGR32X60Q', 'something', '001100000000000000000000051187', '001p0000010nXLS', osc01);
    }

    @isTest static void testGetLoanProductDetailError(){
        String res = '{"MarkedLoanAccountNumber":"xxx-6-15101-x","SubProductGroup":"HOME LOAN FOR STAFF","ProductName":"Housing (New Benefit)","MarkedOutstanding":"***********","MarkedVLimit":"***********","HasCoBorrower":"PRIIND"}';
        Map<String, Object> osc01 = (Map<String, Object>)JSON.deserializeUntyped(res);
        Test.setMock(HttpCalloutMock.class, new OSC04APIError());
        Map<String,Object> returnMap = LoanProductDetailViewController.getLoanProductDetail('000000000000051187', '0011000100010000', 'VLOZNqZuVZbHJjGR32X60Q', 'something', '001100000000000000000000051187', '001p0000010nXLS', osc01);
    }

    @isTest static void testGetCYBDetail(){
        Test.setMock(HttpCalloutMock.class, new CYBAPI());
        Object returnMap = LoanProductDetailViewController.getCYBDetail('VLOZNqZuVZbHJjGR32X60Q', '000000000000051187', '0011000100010000');
    }

    @isTest static void testGetGuarantorDetail(){
        Test.setMock(HttpCalloutMock.class, new GuarantorAPI());
        Object returnMap = LoanProductDetailViewController.getGuarantorDetail('VLOZNqZuVZbHJjGR32X60Q', '000000000000051187', '0011000100010000');
    }

}