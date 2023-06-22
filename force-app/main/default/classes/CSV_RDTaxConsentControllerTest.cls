@isTest
public class CSV_RDTaxConsentControllerTest extends AbstractCoreClass {
    @testSetup 
    static void setupData() {
        TestUtils.createAppConfig();
	}

    private class getOSC0401MockupUnauthorized implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('callout:Smart_BDM_Cal_Tools_Create_Token')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{'+
                    '"access_token": "eyJ0eXBlIjoiSldUIiwiYWxnIjoiUlM1MTIifQ.eyJhcGlfa2V5IjoiYWRtaW4iLCJzY29wZSI6InJlYWQgd3JpdGUiLCJleHAiOjE1NDY4NTg3MzUsInZlcnNpb24iOiIwMDEtMjAxODExMTEiLCJqdGkiOiIyYTQ4ZmEwYi0yMjEyLTRlMzItYTAzMC1mOWFlMmRkYWFlOTQifQ.HcK3lexOKd-ufV0adiIsKWfHzG34D606gFwFbABC-5QFKpUoLus_xq_DPPttpqj7VQB_cYIqaoFEI0HkD2rbTjXuhDDcbcpvkkaLO6DpGYfXi5RYgk7MQq7BPhgq_CVts4p4zUsLnae-c5s3cd5zC08qkNjOVMGlgNli1DZekCFa5vHdrXHICu7ih_CVV6QLLYnyhrN5-STSasxOaNqlZ5v69q0aADP69wyj2NL1SVdCoG8aPlm0ILSjKIM8lj9RsZ23Xs1LUlMGpYNqjhHEI2BDQazuW-VFz_lXi6q_84uM4XvU1bMV6TJxuVXLYjtpaY4Y2wBQJMICvfbIGN-mOg",'+
                    '"token_type": "bearer",'+
                    '"expires_in": 3600,'+
                    '"scope": "read write",'+
                    '"jti": "2a48fa0b-2212-4e32-a030-f9ae2ddaae94",'+
                    '"client_id": "xxxxx",'+
                    '"version": "001-20181111"'+
                '}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:OSC04')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{'+
                    '"Status": {' +
                    '"StatusDesc": "Unauthorized",'+
                    '"StatusCode": "401"'+
                    '}'+
                '}');
                response.setStatusCode(200);
                return response; 
            } else if (req.getEndpoint().startsWith('callout:OSC01')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{'+
                    '"Status": {' +
                    '"StatusDesc": "Unauthorized",'+
                    '"StatusCode": "401"'+
                    '}'+
                '}');                
                response.setStatusCode(200);
                return response; 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    private class getOSC04Mockup implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('callout:Smart_BDM_Cal_Tools_Create_Token')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{'+
                    '"access_token": "eyJ0eXBlIjoiSldUIiwiYWxnIjoiUlM1MTIifQ.eyJhcGlfa2V5IjoiYWRtaW4iLCJzY29wZSI6InJlYWQgd3JpdGUiLCJleHAiOjE1NDY4NTg3MzUsInZlcnNpb24iOiIwMDEtMjAxODExMTEiLCJqdGkiOiIyYTQ4ZmEwYi0yMjEyLTRlMzItYTAzMC1mOWFlMmRkYWFlOTQifQ.HcK3lexOKd-ufV0adiIsKWfHzG34D606gFwFbABC-5QFKpUoLus_xq_DPPttpqj7VQB_cYIqaoFEI0HkD2rbTjXuhDDcbcpvkkaLO6DpGYfXi5RYgk7MQq7BPhgq_CVts4p4zUsLnae-c5s3cd5zC08qkNjOVMGlgNli1DZekCFa5vHdrXHICu7ih_CVV6QLLYnyhrN5-STSasxOaNqlZ5v69q0aADP69wyj2NL1SVdCoG8aPlm0ILSjKIM8lj9RsZ23Xs1LUlMGpYNqjhHEI2BDQazuW-VFz_lXi6q_84uM4XvU1bMV6TJxuVXLYjtpaY4Y2wBQJMICvfbIGN-mOg",'+
                    '"token_type": "bearer",'+
                    '"expires_in": 3600,'+
                    '"scope": "read write",'+
                    '"jti": "2a48fa0b-2212-4e32-a030-f9ae2ddaae94",'+
                    '"client_id": "xxxxx",'+
                    '"version": "001-20181111"'+
                '}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:OSC04')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"GetLoanAccountResponse":{"AcctInqRs":{"Status":{"StatusCode":"0","Severity":"Info","StatusDesc":"Success"},"RqUID":"fb754fa5-860a-4224-9764-2ffb6157fa21","LoanAcctId":{"AcctId":"001100010195000001955706724001","AcctType":"LOC","BankInfo":{"BankId":"11"}},"LnCustAcctId":{"SPName":"","CustPermId":"001100010195000000000001494435"},"UpDt":"2021-11-11T13:14:56.206+07:00","LastTrnDt":"2017-04-27","AcctBal":[{"BalType":"Principal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Outstanding","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Used","CurAmt":{"Amt":"1960000.00"}},{"BalType":"LnAvail","CurAmt":{"Amt":"0.00"}},{"BalType":"PayoffAmt","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Current","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"CurIntRecBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"OrigCommitmentBal","CurAmt":{"Amt":"1960000.00","CurCode":"THB"}},{"BalType":"CurCommitmentBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}}],"ExtAcctBal":[{"ExtBalType":"YTDInterest","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"LastYrInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Orig","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Unpaid/AccruedInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"YTDInterestAccrEC","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"TotalPastDue","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"}],"BankAcctRec":{"LoanAcctId":{"AcctId":"","AcctType":"","BankInfo":""},"BankAcctInfo":{"CurCode":"","PersonName":{"LastName":"","FirstName":"","LegalName":""},"ContactInfo":"","ProductId":"CBHA"}},"LOCAcctRec":{"LoanInfoCommon":{"AccountTitle":"MR.NAME00000001494435 LAST00000001494435","RemainingPmtCount":"181","RemainingPmtTerm":"0","RegPmtCurAmt":{"Amt":"13200.00","CurCode":"THB"},"LastPmtDt":"2017-04-27","LastPmtCurAmt":{"Amt":"231317.00","CurCode":"THB"},"PastDuePmtCount":"0","PastDueDt":"2017-05-31","NextPmtDt":"2017-05-31","NextPmtCurAmt":{"Amt":"0.00","CurCode":"THB"},"DaysPastDue":"0","CurrentIntRate":{"Rate":"4.0000000"},"OriginalIntRate":{"Rate":"0.0000001"},"RateType":"V","EffDt":"2010-05-25T12:00:00.000000-00:00","MatDt":"2032-05-31","LOCLimit":{"Amt":"0.00","CurCode":"THB"},"LateChargesCurAmt":{"Amt":"0.00","CurCode":"THB"},"CollateralInfo":{"CollateralCode":"000"},"SeqNum":"1","DebitAcct":"00001952109500","CurrentPmtCount":"264","FeesDueCurAmt":{"Amt":"0.00","CurCode":"THB"},"PerDiemCurAmt":{"Amt":"0.0000000","CurCode":"THB"},"PastDuePmtCounter":{"Type":"6-LifeTime","DelinquencyCategory":"151","PastDuePmtCount":"0"},"BillingMethod":"Statements","DraftAcctInfo":{"AcctId":"","USA.RTN":"0"},"ProcessDt":"2021-08-25","CustType":"Personal","AutoDebitMethod":"","OrigMatureDt":"2032-05-31","NxtDueDt":"2017-05-31","AccruedIntAmt1":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt2":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt3":{"Amt":"0.00","CurCode":"THB"},"TotalInt":{"Amt":"0.00","CurCode":"THB"},"NextPmtPrincipal":{"Amt":"0.00"},"NextPmtInterest":{"Amt":"0.00"},"AcctBal":{"BalType":"ToAccountBal","CurAmt":{"Amt":"0.00"}},"TransactionCount":"N"}},"BankAcctStatus":{"BankAcctStatusCode":"Closed"},"Language":"","Region":"","AuthOfficer":"00195","PersonInfo":[{"NameAddrType":"","FullName":"MR.NAME00000001494435 LAST00000001494435","ContactInfo":{"PostAddr":{"Addr1":"ที่อยู่บรรทัด100000001494435","Addr2":"ที่อยู่บรรทัด200000001494435","Addr3":"ที่อยู่บรรทัด300000001494435","City":"จ.ทดสอบ","StateProv":"  ","PostalCode":"1234567890","Country":"ไทย","AddrType":"Mailing"}},"TINInfo":{"TINType":"SSN","TaxId":"103552303","CertCode":"Certification Not on File"},"OEDCode":"All Other Individuals","OEDInstitution":"All Other Individuals"},{"NameAddrType":"","FullName":"","ContactInfo":{"PhoneNum":{"PhoneType":"Business","Phone":"000-00001494"}}}],"InsuranceInfo":{"InsRebateDueCurAmt":{"Amt":"0.00"}},"PartyAcctRel":{"PartyAcctRelType":"ENDORSER"}},"Status":{"StatusCode":"200","StatusDesc":"success"}},"GetLoanAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","LoanInformation":{"Status":"SUCCESS","Message":"","FIIdent":"0011000101950000","AccountNumber":"01955706724001","BusinessType":"","ProductCode":"CBHA","Tenor":"83","AccountStatus":"Closed","CreditLimit":"0.00","Outstanding":"0.00","OpenDate":"2010-05-25+07:00","ContractEndDate":"2032-05-31+07:00","PaymentDueDate":"2017-05-31+07:00","OtherConditions":"0.00","CampaignName":"83070","LastPaymentDate":"2017-04-27+07:00","CurrentTenor":"83","HasCoBorrower":"Yes"},"CoBorrowerInformation":{"Status":"SUCCESS","Message":"","CoBorrower":[{"RMID":"001100000000000000000001494435","Name":"NAME TEST","Relationship":"PRIJNT"},{"RMID":"001100000000000000000009864387","Name":"NAME TEST","Relationship":"SECJNT"}]},"LoanPaymentInformation":{"Status":"SUCCESS","Message":"","LoanPayment":{"PaymentMethod":"1","SavingAccount":"00001952109500","InstallmentBalance":"13200.00"}}}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
                response.setStatusCode(200);
                return response; 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    private class getOSC04MockupUnauthorized implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('callout:Smart_BDM_Cal_Tools_Create_Token')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{'+
                    '"access_token": "eyJ0eXBlIjoiSldUIiwiYWxnIjoiUlM1MTIifQ.eyJhcGlfa2V5IjoiYWRtaW4iLCJzY29wZSI6InJlYWQgd3JpdGUiLCJleHAiOjE1NDY4NTg3MzUsInZlcnNpb24iOiIwMDEtMjAxODExMTEiLCJqdGkiOiIyYTQ4ZmEwYi0yMjEyLTRlMzItYTAzMC1mOWFlMmRkYWFlOTQifQ.HcK3lexOKd-ufV0adiIsKWfHzG34D606gFwFbABC-5QFKpUoLus_xq_DPPttpqj7VQB_cYIqaoFEI0HkD2rbTjXuhDDcbcpvkkaLO6DpGYfXi5RYgk7MQq7BPhgq_CVts4p4zUsLnae-c5s3cd5zC08qkNjOVMGlgNli1DZekCFa5vHdrXHICu7ih_CVV6QLLYnyhrN5-STSasxOaNqlZ5v69q0aADP69wyj2NL1SVdCoG8aPlm0ILSjKIM8lj9RsZ23Xs1LUlMGpYNqjhHEI2BDQazuW-VFz_lXi6q_84uM4XvU1bMV6TJxuVXLYjtpaY4Y2wBQJMICvfbIGN-mOg",'+
                    '"token_type": "bearer",'+
                    '"expires_in": 3600,'+
                    '"scope": "read write",'+
                    '"jti": "2a48fa0b-2212-4e32-a030-f9ae2ddaae94",'+
                    '"client_id": "xxxxx",'+
                    '"version": "001-20181111"'+
                '}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:OSC01')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"GetCustomerAccountResponse":{"LoanAccounts":{"LoanAccount":[{"Status":"SUCCESS","AccountNumber":"00016338659001","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"12345678","OpenedDate":"2021-09-02","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00045796513001","FIIdent":"0011000100040000","ProductType":"com.fnis.xes.AL","ProductCode":"DEPA","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"}]}},"Status":{"StatusCode":200,"StatusDesc":"success"}}');
                response.setStatusCode(200);
                return response; 
            } else if (req.getEndpoint().startsWith('callout:OSC04')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{'+
                    '"Status": {' +
                    '"StatusDesc": "Unauthorized",'+
                    '"StatusCode": "401"'+
                    '}'+
                '}'); 
                response.setStatusCode(200);
                return response; 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    private class getOSC04MockupError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('callout:Smart_BDM_Cal_Tools_Create_Token')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{'+
                    '"access_token": "eyJ0eXBlIjoiSldUIiwiYWxnIjoiUlM1MTIifQ.eyJhcGlfa2V5IjoiYWRtaW4iLCJzY29wZSI6InJlYWQgd3JpdGUiLCJleHAiOjE1NDY4NTg3MzUsInZlcnNpb24iOiIwMDEtMjAxODExMTEiLCJqdGkiOiIyYTQ4ZmEwYi0yMjEyLTRlMzItYTAzMC1mOWFlMmRkYWFlOTQifQ.HcK3lexOKd-ufV0adiIsKWfHzG34D606gFwFbABC-5QFKpUoLus_xq_DPPttpqj7VQB_cYIqaoFEI0HkD2rbTjXuhDDcbcpvkkaLO6DpGYfXi5RYgk7MQq7BPhgq_CVts4p4zUsLnae-c5s3cd5zC08qkNjOVMGlgNli1DZekCFa5vHdrXHICu7ih_CVV6QLLYnyhrN5-STSasxOaNqlZ5v69q0aADP69wyj2NL1SVdCoG8aPlm0ILSjKIM8lj9RsZ23Xs1LUlMGpYNqjhHEI2BDQazuW-VFz_lXi6q_84uM4XvU1bMV6TJxuVXLYjtpaY4Y2wBQJMICvfbIGN-mOg",'+
                    '"token_type": "bearer",'+
                    '"expires_in": 3600,'+
                    '"scope": "read write",'+
                    '"jti": "2a48fa0b-2212-4e32-a030-f9ae2ddaae94",'+
                    '"client_id": "xxxxx",'+
                    '"version": "001-20181111"'+
                '}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:OSC01')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"GetCustomerAccountResponse":{"LoanAccounts":{"LoanAccount":[{"Status":"SUCCESS","AccountNumber":"00016338659001","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"12345678","OpenedDate":"2021-09-02","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00045796513001","FIIdent":"0011000100040000","ProductType":"com.fnis.xes.AL","ProductCode":"DEPA","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"}]}},"Status":{"StatusCode":200,"StatusDesc":"success"}}');
                response.setStatusCode(200);
                return response; 
            } else if (req.getEndpoint().startsWith('callout:OSC04')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"GetLoanAccountResponse":{"AcctInqRs":{"Status":{"StatusCode":"0","Severity":"Info","StatusDesc":"Success"},"RqUID":"fb754fa5-860a-4224-9764-2ffb6157fa21","LoanAcctId":{"AcctId":"001100010195000001955706724001","AcctType":"LOC","BankInfo":{"BankId":"11"}},"LnCustAcctId":{"SPName":"","CustPermId":"001100010195000000000001494435"},"UpDt":"2021-11-11T13:14:56.206+07:00","LastTrnDt":"2017-04-27","AcctBal":[{"BalType":"Principal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Outstanding","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Used","CurAmt":{"Amt":"1960000.00"}},{"BalType":"LnAvail","CurAmt":{"Amt":"0.00"}},{"BalType":"PayoffAmt","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Current","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"CurIntRecBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"OrigCommitmentBal","CurAmt":{"Amt":"1960000.00","CurCode":"THB"}},{"BalType":"CurCommitmentBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}}],"ExtAcctBal":[{"ExtBalType":"YTDInterest","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"LastYrInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Orig","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Unpaid/AccruedInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"YTDInterestAccrEC","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"TotalPastDue","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"}],"BankAcctRec":{"LoanAcctId":{"AcctId":"","AcctType":"","BankInfo":""},"BankAcctInfo":{"CurCode":"","PersonName":{"LastName":"","FirstName":"","LegalName":""},"ContactInfo":"","ProductId":"CBHA"}},"LOCAcctRec":{"LoanInfoCommon":{"AccountTitle":"MR.NAME00000001494435 LAST00000001494435","RemainingPmtCount":"181","RemainingPmtTerm":"0","RegPmtCurAmt":{"Amt":"13200.00","CurCode":"THB"},"LastPmtDt":"2017-04-27","LastPmtCurAmt":{"Amt":"231317.00","CurCode":"THB"},"PastDuePmtCount":"0","PastDueDt":"2017-05-31","NextPmtDt":"2017-05-31","NextPmtCurAmt":{"Amt":"0.00","CurCode":"THB"},"DaysPastDue":"0","CurrentIntRate":{"Rate":"4.0000000"},"OriginalIntRate":{"Rate":"0.0000001"},"RateType":"V","EffDt":"2010-05-25T12:00:00.000000-00:00","MatDt":"2032-05-31","LOCLimit":{"Amt":"0.00","CurCode":"THB"},"LateChargesCurAmt":{"Amt":"0.00","CurCode":"THB"},"CollateralInfo":{"CollateralCode":"000"},"SeqNum":"1","DebitAcct":"00001952109500","CurrentPmtCount":"264","FeesDueCurAmt":{"Amt":"0.00","CurCode":"THB"},"PerDiemCurAmt":{"Amt":"0.0000000","CurCode":"THB"},"PastDuePmtCounter":{"Type":"6-LifeTime","DelinquencyCategory":"151","PastDuePmtCount":"0"},"BillingMethod":"Statements","DraftAcctInfo":{"AcctId":"","USA.RTN":"0"},"ProcessDt":"2021-08-25","CustType":"Personal","AutoDebitMethod":"","OrigMatureDt":"2032-05-31","NxtDueDt":"2017-05-31","AccruedIntAmt1":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt2":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt3":{"Amt":"0.00","CurCode":"THB"},"TotalInt":{"Amt":"0.00","CurCode":"THB"},"NextPmtPrincipal":{"Amt":"0.00"},"NextPmtInterest":{"Amt":"0.00"},"AcctBal":{"BalType":"ToAccountBal","CurAmt":{"Amt":"0.00"}},"TransactionCount":"N"}},"BankAcctStatus":{"BankAcctStatusCode":"Closed"},"Language":"","Region":"","AuthOfficer":"00195","PersonInfo":[{"NameAddrType":"","FullName":"MR.NAME00000001494435 LAST00000001494435","ContactInfo":{"PostAddr":{"Addr1":"ที่อยู่บรรทัด100000001494435","Addr2":"ที่อยู่บรรทัด200000001494435","Addr3":"ที่อยู่บรรทัด300000001494435","City":"จ.ทดสอบ","StateProv":"  ","PostalCode":"1234567890","Country":"ไทย","AddrType":"Mailing"}},"TINInfo":{"TINType":"SSN","TaxId":"103552303","CertCode":"Certification Not on File"},"OEDCode":"All Other Individuals","OEDInstitution":"All Other Individuals"},{"NameAddrType":"","FullName":"","ContactInfo":{"PhoneNum":{"PhoneType":"Business","Phone":"000-00001494"}}}],"InsuranceInfo":{"InsRebateDueCurAmt":{"Amt":"0.00"}},"PartyAcctRel":{"PartyAcctRelType":"ENDORSER"}},"Status":{"StatusCode":"200","StatusDesc":"success"}},"GetLoanAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","LoanInformation":{"Status":"SUCCESS","Message":"","FIIdent":"0011000101950000","AccountNumber":"01955706724001","BusinessType":"","ProductCode":"CBHA","Tenor":"83","AccountStatus":"Closed","CreditLimit":"0.00","Outstanding":"0.00","OpenDate":"2010-05-25+07:00","ContractEndDate":"2032-05-3107:00","PaymentDueDate":"2017-05-31+07:00","OtherConditions":"0.00","CampaignName":"83070","LastPaymentDate":"2017-04-27+07:00","CurrentTenor":"83","HasCoBorrower":"Yes"},"CoBorrowerInformation":{"Status":"SUCCESS","Message":"","CoBorrower":[{"RMID":"001100000000000000000001494435","Name":"NAME TEST","Relationship":"PRIJNT"},{"RMID":"001100000000000000000009864387","Name":"NAME TEST","Relationship":"SECJNT"}]},"LoanPaymentInformation":{"Status":"SUCCESS","Message":"","LoanPayment":{"PaymentMethod":"1","SavingAccount":"00001952109500","InstallmentBalance":"13200.00"}}}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
                response.setStatusCode(200);
                return response; 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    private class OSC04Timeout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('callout:Smart_BDM_Cal_Tools_Create_Token')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{'+
                    '"access_token": "eyJ0eXBlIjoiSldUIiwiYWxnIjoiUlM1MTIifQ.eyJhcGlfa2V5IjoiYWRtaW4iLCJzY29wZSI6InJlYWQgd3JpdGUiLCJleHAiOjE1NDY4NTg3MzUsInZlcnNpb24iOiIwMDEtMjAxODExMTEiLCJqdGkiOiIyYTQ4ZmEwYi0yMjEyLTRlMzItYTAzMC1mOWFlMmRkYWFlOTQifQ.HcK3lexOKd-ufV0adiIsKWfHzG34D606gFwFbABC-5QFKpUoLus_xq_DPPttpqj7VQB_cYIqaoFEI0HkD2rbTjXuhDDcbcpvkkaLO6DpGYfXi5RYgk7MQq7BPhgq_CVts4p4zUsLnae-c5s3cd5zC08qkNjOVMGlgNli1DZekCFa5vHdrXHICu7ih_CVV6QLLYnyhrN5-STSasxOaNqlZ5v69q0aADP69wyj2NL1SVdCoG8aPlm0ILSjKIM8lj9RsZ23Xs1LUlMGpYNqjhHEI2BDQazuW-VFz_lXi6q_84uM4XvU1bMV6TJxuVXLYjtpaY4Y2wBQJMICvfbIGN-mOg",'+
                    '"token_type": "bearer",'+
                    '"expires_in": 3600,'+
                    '"scope": "read write",'+
                    '"jti": "2a48fa0b-2212-4e32-a030-f9ae2ddaae94",'+
                    '"client_id": "xxxxx",'+
                    '"version": "001-20181111"'+
                '}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:OSC04')) {
                CalloutException e = (CalloutException)CalloutException.class.newInstance();
                e.setMessage('Mockup timed out webservice');
                throw e;
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    private class getOSC01Mockup implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('callout:Smart_BDM_Cal_Tools_Create_Token')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{'+
                    '"access_token": "eyJ0eXBlIjoiSldUIiwiYWxnIjoiUlM1MTIifQ.eyJhcGlfa2V5IjoiYWRtaW4iLCJzY29wZSI6InJlYWQgd3JpdGUiLCJleHAiOjE1NDY4NTg3MzUsInZlcnNpb24iOiIwMDEtMjAxODExMTEiLCJqdGkiOiIyYTQ4ZmEwYi0yMjEyLTRlMzItYTAzMC1mOWFlMmRkYWFlOTQifQ.HcK3lexOKd-ufV0adiIsKWfHzG34D606gFwFbABC-5QFKpUoLus_xq_DPPttpqj7VQB_cYIqaoFEI0HkD2rbTjXuhDDcbcpvkkaLO6DpGYfXi5RYgk7MQq7BPhgq_CVts4p4zUsLnae-c5s3cd5zC08qkNjOVMGlgNli1DZekCFa5vHdrXHICu7ih_CVV6QLLYnyhrN5-STSasxOaNqlZ5v69q0aADP69wyj2NL1SVdCoG8aPlm0ILSjKIM8lj9RsZ23Xs1LUlMGpYNqjhHEI2BDQazuW-VFz_lXi6q_84uM4XvU1bMV6TJxuVXLYjtpaY4Y2wBQJMICvfbIGN-mOg",'+
                    '"token_type": "bearer",'+
                    '"expires_in": 3600,'+
                    '"scope": "read write",'+
                    '"jti": "2a48fa0b-2212-4e32-a030-f9ae2ddaae94",'+
                    '"client_id": "xxxxx",'+
                    '"version": "001-20181111"'+
                '}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:OSC01')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"GetCustomerAccountResponse":{"LoanAccounts":{"LoanAccount":[{"Status":"SUCCESS","AccountNumber":"00016338659001","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"12345678","OpenedDate":"2021-09-02","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00045796513001","FIIdent":"0011000100040000","ProductType":"com.fnis.xes.AL","ProductCode":"DEPA","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"}]}},"Status":{"StatusCode":200,"StatusDesc":"success"}}');
                response.setStatusCode(200);
                return response; 
            } else if (req.getEndpoint().startsWith('callout:OSC04')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"GetLoanAccountResponse":{"AcctInqRs":{"Status":{"StatusCode":"0","Severity":"Info","StatusDesc":"Success"},"RqUID":"fb754fa5-860a-4224-9764-2ffb6157fa21","LoanAcctId":{"AcctId":"001100010195000001955706724001","AcctType":"LOC","BankInfo":{"BankId":"11"}},"LnCustAcctId":{"SPName":"","CustPermId":"001100010195000000000001494435"},"UpDt":"2021-11-11T13:14:56.206+07:00","LastTrnDt":"2017-04-27","AcctBal":[{"BalType":"Principal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Outstanding","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Used","CurAmt":{"Amt":"1960000.00"}},{"BalType":"LnAvail","CurAmt":{"Amt":"0.00"}},{"BalType":"PayoffAmt","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Current","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"CurIntRecBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"OrigCommitmentBal","CurAmt":{"Amt":"1960000.00","CurCode":"THB"}},{"BalType":"CurCommitmentBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}}],"ExtAcctBal":[{"ExtBalType":"YTDInterest","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"LastYrInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Orig","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Unpaid/AccruedInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"YTDInterestAccrEC","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"TotalPastDue","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"}],"BankAcctRec":{"LoanAcctId":{"AcctId":"","AcctType":"","BankInfo":""},"BankAcctInfo":{"CurCode":"","PersonName":{"LastName":"","FirstName":"","LegalName":""},"ContactInfo":"","ProductId":"CBHA"}},"LOCAcctRec":{"LoanInfoCommon":{"AccountTitle":"MR.NAME00000001494435 LAST00000001494435","RemainingPmtCount":"181","RemainingPmtTerm":"0","RegPmtCurAmt":{"Amt":"13200.00","CurCode":"THB"},"LastPmtDt":"2017-04-27","LastPmtCurAmt":{"Amt":"231317.00","CurCode":"THB"},"PastDuePmtCount":"0","PastDueDt":"2017-05-31","NextPmtDt":"2017-05-31","NextPmtCurAmt":{"Amt":"0.00","CurCode":"THB"},"DaysPastDue":"0","CurrentIntRate":{"Rate":"4.0000000"},"OriginalIntRate":{"Rate":"0.0000001"},"RateType":"V","EffDt":"2010-05-25T12:00:00.000000-00:00","MatDt":"2032-05-31","LOCLimit":{"Amt":"0.00","CurCode":"THB"},"LateChargesCurAmt":{"Amt":"0.00","CurCode":"THB"},"CollateralInfo":{"CollateralCode":"000"},"SeqNum":"1","DebitAcct":"00001952109500","CurrentPmtCount":"264","FeesDueCurAmt":{"Amt":"0.00","CurCode":"THB"},"PerDiemCurAmt":{"Amt":"0.0000000","CurCode":"THB"},"PastDuePmtCounter":{"Type":"6-LifeTime","DelinquencyCategory":"151","PastDuePmtCount":"0"},"BillingMethod":"Statements","DraftAcctInfo":{"AcctId":"","USA.RTN":"0"},"ProcessDt":"2021-08-25","CustType":"Personal","AutoDebitMethod":"","OrigMatureDt":"2032-05-31","NxtDueDt":"2017-05-31","AccruedIntAmt1":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt2":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt3":{"Amt":"0.00","CurCode":"THB"},"TotalInt":{"Amt":"0.00","CurCode":"THB"},"NextPmtPrincipal":{"Amt":"0.00"},"NextPmtInterest":{"Amt":"0.00"},"AcctBal":{"BalType":"ToAccountBal","CurAmt":{"Amt":"0.00"}},"TransactionCount":"N"}},"BankAcctStatus":{"BankAcctStatusCode":"Closed"},"Language":"","Region":"","AuthOfficer":"00195","PersonInfo":[{"NameAddrType":"","FullName":"MR.NAME00000001494435 LAST00000001494435","ContactInfo":{"PostAddr":{"Addr1":"ที่อยู่บรรทัด100000001494435","Addr2":"ที่อยู่บรรทัด200000001494435","Addr3":"ที่อยู่บรรทัด300000001494435","City":"จ.ทดสอบ","StateProv":"  ","PostalCode":"1234567890","Country":"ไทย","AddrType":"Mailing"}},"TINInfo":{"TINType":"SSN","TaxId":"103552303","CertCode":"Certification Not on File"},"OEDCode":"All Other Individuals","OEDInstitution":"All Other Individuals"},{"NameAddrType":"","FullName":"","ContactInfo":{"PhoneNum":{"PhoneType":"Business","Phone":"000-00001494"}}}],"InsuranceInfo":{"InsRebateDueCurAmt":{"Amt":"0.00"}},"PartyAcctRel":{"PartyAcctRelType":"ENDORSER"}},"Status":{"StatusCode":"200","StatusDesc":"success"}},"GetLoanAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","LoanInformation":{"Status":"SUCCESS","Message":"","FIIdent":"0011000101950000","AccountNumber":"01955706724001","BusinessType":"","ProductCode":"CBHA","Tenor":"83","AccountStatus":"Closed","CreditLimit":"0.00","Outstanding":"0.00","OpenDate":"2010-05-25+07:00","ContractEndDate":"2032-05-31+07:00","PaymentDueDate":"2017-05-31+07:00","OtherConditions":"0.00","CampaignName":"83070","LastPaymentDate":"2017-04-27+07:00","CurrentTenor":"83","HasCoBorrower":"Yes"},"CoBorrowerInformation":{"Status":"SUCCESS","Message":"","CoBorrower":[{"RMID":"001100000000000000000001494435","Name":"NAME TEST","Relationship":"PRIJNT"},{"RMID":"001100000000000000000009864387","Name":"NAME TEST","Relationship":"SECJNT"}]},"LoanPaymentInformation":{"Status":"SUCCESS","Message":"","LoanPayment":{"PaymentMethod":"1","SavingAccount":"00001952109500","InstallmentBalance":"13200.00"}}}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
                response.setStatusCode(200);
                return response; 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    private class getOSC01MockupUnsuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('callout:Smart_BDM_Cal_Tools_Create_Token')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{'+
                    '"access_token": "eyJ0eXBlIjoiSldUIiwiYWxnIjoiUlM1MTIifQ.eyJhcGlfa2V5IjoiYWRtaW4iLCJzY29wZSI6InJlYWQgd3JpdGUiLCJleHAiOjE1NDY4NTg3MzUsInZlcnNpb24iOiIwMDEtMjAxODExMTEiLCJqdGkiOiIyYTQ4ZmEwYi0yMjEyLTRlMzItYTAzMC1mOWFlMmRkYWFlOTQifQ.HcK3lexOKd-ufV0adiIsKWfHzG34D606gFwFbABC-5QFKpUoLus_xq_DPPttpqj7VQB_cYIqaoFEI0HkD2rbTjXuhDDcbcpvkkaLO6DpGYfXi5RYgk7MQq7BPhgq_CVts4p4zUsLnae-c5s3cd5zC08qkNjOVMGlgNli1DZekCFa5vHdrXHICu7ih_CVV6QLLYnyhrN5-STSasxOaNqlZ5v69q0aADP69wyj2NL1SVdCoG8aPlm0ILSjKIM8lj9RsZ23Xs1LUlMGpYNqjhHEI2BDQazuW-VFz_lXi6q_84uM4XvU1bMV6TJxuVXLYjtpaY4Y2wBQJMICvfbIGN-mOg",'+
                    '"token_type": "bearer",'+
                    '"expires_in": 3600,'+
                    '"scope": "read write",'+
                    '"jti": "2a48fa0b-2212-4e32-a030-f9ae2ddaae94",'+
                    '"client_id": "xxxxx",'+
                    '"version": "001-20181111"'+
                '}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:OSC01')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"GetCustomerAccountResponse":{"LoanAccounts":{"LoanAccount":[{"Status":"SUCCESS","AccountNumber":"00016338659001","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"12345678","OpenedDate":"2021-09-02","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00045796513001","FIIdent":"0011000100040000","ProductType":"com.fnis.xes.AL","ProductCode":"DEPA","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"}]}},"Status":{"StatusCode":200,"StatusDesc":"error"}}');
                response.setStatusCode(200);
                return response; 
            } else if (req.getEndpoint().startsWith('callout:OSC04')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"GetLoanAccountResponse":{"AcctInqRs":{"Status":{"StatusCode":"0","Severity":"Info","StatusDesc":"Success"},"RqUID":"fb754fa5-860a-4224-9764-2ffb6157fa21","LoanAcctId":{"AcctId":"001100010195000001955706724001","AcctType":"LOC","BankInfo":{"BankId":"11"}},"LnCustAcctId":{"SPName":"","CustPermId":"001100010195000000000001494435"},"UpDt":"2021-11-11T13:14:56.206+07:00","LastTrnDt":"2017-04-27","AcctBal":[{"BalType":"Principal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Outstanding","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Used","CurAmt":{"Amt":"1960000.00"}},{"BalType":"LnAvail","CurAmt":{"Amt":"0.00"}},{"BalType":"PayoffAmt","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Current","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"CurIntRecBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"OrigCommitmentBal","CurAmt":{"Amt":"1960000.00","CurCode":"THB"}},{"BalType":"CurCommitmentBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}}],"ExtAcctBal":[{"ExtBalType":"YTDInterest","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"LastYrInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Orig","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Unpaid/AccruedInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"YTDInterestAccrEC","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"TotalPastDue","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"}],"BankAcctRec":{"LoanAcctId":{"AcctId":"","AcctType":"","BankInfo":""},"BankAcctInfo":{"CurCode":"","PersonName":{"LastName":"","FirstName":"","LegalName":""},"ContactInfo":"","ProductId":"CBHA"}},"LOCAcctRec":{"LoanInfoCommon":{"AccountTitle":"MR.NAME00000001494435 LAST00000001494435","RemainingPmtCount":"181","RemainingPmtTerm":"0","RegPmtCurAmt":{"Amt":"13200.00","CurCode":"THB"},"LastPmtDt":"2017-04-27","LastPmtCurAmt":{"Amt":"231317.00","CurCode":"THB"},"PastDuePmtCount":"0","PastDueDt":"2017-05-31","NextPmtDt":"2017-05-31","NextPmtCurAmt":{"Amt":"0.00","CurCode":"THB"},"DaysPastDue":"0","CurrentIntRate":{"Rate":"4.0000000"},"OriginalIntRate":{"Rate":"0.0000001"},"RateType":"V","EffDt":"2010-05-25T12:00:00.000000-00:00","MatDt":"2032-05-31","LOCLimit":{"Amt":"0.00","CurCode":"THB"},"LateChargesCurAmt":{"Amt":"0.00","CurCode":"THB"},"CollateralInfo":{"CollateralCode":"000"},"SeqNum":"1","DebitAcct":"00001952109500","CurrentPmtCount":"264","FeesDueCurAmt":{"Amt":"0.00","CurCode":"THB"},"PerDiemCurAmt":{"Amt":"0.0000000","CurCode":"THB"},"PastDuePmtCounter":{"Type":"6-LifeTime","DelinquencyCategory":"151","PastDuePmtCount":"0"},"BillingMethod":"Statements","DraftAcctInfo":{"AcctId":"","USA.RTN":"0"},"ProcessDt":"2021-08-25","CustType":"Personal","AutoDebitMethod":"","OrigMatureDt":"2032-05-31","NxtDueDt":"2017-05-31","AccruedIntAmt1":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt2":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt3":{"Amt":"0.00","CurCode":"THB"},"TotalInt":{"Amt":"0.00","CurCode":"THB"},"NextPmtPrincipal":{"Amt":"0.00"},"NextPmtInterest":{"Amt":"0.00"},"AcctBal":{"BalType":"ToAccountBal","CurAmt":{"Amt":"0.00"}},"TransactionCount":"N"}},"BankAcctStatus":{"BankAcctStatusCode":"Closed"},"Language":"","Region":"","AuthOfficer":"00195","PersonInfo":[{"NameAddrType":"","FullName":"MR.NAME00000001494435 LAST00000001494435","ContactInfo":{"PostAddr":{"Addr1":"ที่อยู่บรรทัด100000001494435","Addr2":"ที่อยู่บรรทัด200000001494435","Addr3":"ที่อยู่บรรทัด300000001494435","City":"จ.ทดสอบ","StateProv":"  ","PostalCode":"1234567890","Country":"ไทย","AddrType":"Mailing"}},"TINInfo":{"TINType":"SSN","TaxId":"103552303","CertCode":"Certification Not on File"},"OEDCode":"All Other Individuals","OEDInstitution":"All Other Individuals"},{"NameAddrType":"","FullName":"","ContactInfo":{"PhoneNum":{"PhoneType":"Business","Phone":"000-00001494"}}}],"InsuranceInfo":{"InsRebateDueCurAmt":{"Amt":"0.00"}},"PartyAcctRel":{"PartyAcctRelType":"ENDORSER"}},"Status":{"StatusCode":"200","StatusDesc":"success"}},"GetLoanAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","LoanInformation":{"Status":"SUCCESS","Message":"","FIIdent":"0011000101950000","AccountNumber":"01955706724001","BusinessType":"","ProductCode":"CBHA","Tenor":"83","AccountStatus":"Closed","CreditLimit":"0.00","Outstanding":"0.00","OpenDate":"2010-05-25+07:00","ContractEndDate":"2032-05-31+07:00","PaymentDueDate":"2017-05-31+07:00","OtherConditions":"0.00","CampaignName":"83070","LastPaymentDate":"2017-04-27+07:00","CurrentTenor":"83","HasCoBorrower":"Yes"},"CoBorrowerInformation":{"Status":"SUCCESS","Message":"","CoBorrower":[{"RMID":"001100000000000000000001494435","Name":"NAME TEST","Relationship":"PRIJNT"},{"RMID":"001100000000000000000009864387","Name":"NAME TEST","Relationship":"SECJNT"}]},"LoanPaymentInformation":{"Status":"SUCCESS","Message":"","LoanPayment":{"PaymentMethod":"1","SavingAccount":"00001952109500","InstallmentBalance":"13200.00"}}}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
                response.setStatusCode(200);
                return response; 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    private class getOSC01MockupError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('callout:Smart_BDM_Cal_Tools_Create_Token')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{'+
                    '"access_token": "eyJ0eXBlIjoiSldUIiwiYWxnIjoiUlM1MTIifQ.eyJhcGlfa2V5IjoiYWRtaW4iLCJzY29wZSI6InJlYWQgd3JpdGUiLCJleHAiOjE1NDY4NTg3MzUsInZlcnNpb24iOiIwMDEtMjAxODExMTEiLCJqdGkiOiIyYTQ4ZmEwYi0yMjEyLTRlMzItYTAzMC1mOWFlMmRkYWFlOTQifQ.HcK3lexOKd-ufV0adiIsKWfHzG34D606gFwFbABC-5QFKpUoLus_xq_DPPttpqj7VQB_cYIqaoFEI0HkD2rbTjXuhDDcbcpvkkaLO6DpGYfXi5RYgk7MQq7BPhgq_CVts4p4zUsLnae-c5s3cd5zC08qkNjOVMGlgNli1DZekCFa5vHdrXHICu7ih_CVV6QLLYnyhrN5-STSasxOaNqlZ5v69q0aADP69wyj2NL1SVdCoG8aPlm0ILSjKIM8lj9RsZ23Xs1LUlMGpYNqjhHEI2BDQazuW-VFz_lXi6q_84uM4XvU1bMV6TJxuVXLYjtpaY4Y2wBQJMICvfbIGN-mOg",'+
                    '"token_type": "bearer",'+
                    '"expires_in": 3600,'+
                    '"scope": "read write",'+
                    '"jti": "2a48fa0b-2212-4e32-a030-f9ae2ddaae94",'+
                    '"client_id": "xxxxx",'+
                    '"version": "001-20181111"'+
                '}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:OSC01')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"GetCustomerAccountResponse":{"LoanAccounts":{"LoanAccount":[{"Status":"SUCCESS","AccountNumber":"00016338659001","FIIdent":"0011000100010000","ProductType":"com.fnis.xes.AL","ProductCode":"12345678","OpenedDate":"2021-09-02","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"},{"Status":"SUCCESS","AccountNumber":"00045796513001","FIIdent":"0011000100040000","ProductType":"com.fnis.xes.AL","ProductCode":"DEPA","OpenedDate":"9999-12-31","AccountStatus":"Active","Outstanding":"0","Limit":"0","HasCoborrower":"PRIIND"}]}},"Status":{}}');
                response.setStatusCode(200);
                return response; 
            } else if (req.getEndpoint().startsWith('callout:OSC04')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"GetLoanAccountResponse":{"AcctInqRs":{"Status":{"StatusCode":"0","Severity":"Info","StatusDesc":"Success"},"RqUID":"fb754fa5-860a-4224-9764-2ffb6157fa21","LoanAcctId":{"AcctId":"001100010195000001955706724001","AcctType":"LOC","BankInfo":{"BankId":"11"}},"LnCustAcctId":{"SPName":"","CustPermId":"001100010195000000000001494435"},"UpDt":"2021-11-11T13:14:56.206+07:00","LastTrnDt":"2017-04-27","AcctBal":[{"BalType":"Principal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Outstanding","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Used","CurAmt":{"Amt":"1960000.00"}},{"BalType":"LnAvail","CurAmt":{"Amt":"0.00"}},{"BalType":"PayoffAmt","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Current","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"CurIntRecBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"OrigCommitmentBal","CurAmt":{"Amt":"1960000.00","CurCode":"THB"}},{"BalType":"CurCommitmentBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}}],"ExtAcctBal":[{"ExtBalType":"YTDInterest","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"LastYrInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Orig","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Unpaid/AccruedInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"YTDInterestAccrEC","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"TotalPastDue","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"}],"BankAcctRec":{"LoanAcctId":{"AcctId":"","AcctType":"","BankInfo":""},"BankAcctInfo":{"CurCode":"","PersonName":{"LastName":"","FirstName":"","LegalName":""},"ContactInfo":"","ProductId":"CBHA"}},"LOCAcctRec":{"LoanInfoCommon":{"AccountTitle":"MR.NAME00000001494435 LAST00000001494435","RemainingPmtCount":"181","RemainingPmtTerm":"0","RegPmtCurAmt":{"Amt":"13200.00","CurCode":"THB"},"LastPmtDt":"2017-04-27","LastPmtCurAmt":{"Amt":"231317.00","CurCode":"THB"},"PastDuePmtCount":"0","PastDueDt":"2017-05-31","NextPmtDt":"2017-05-31","NextPmtCurAmt":{"Amt":"0.00","CurCode":"THB"},"DaysPastDue":"0","CurrentIntRate":{"Rate":"4.0000000"},"OriginalIntRate":{"Rate":"0.0000001"},"RateType":"V","EffDt":"2010-05-25T12:00:00.000000-00:00","MatDt":"2032-05-31","LOCLimit":{"Amt":"0.00","CurCode":"THB"},"LateChargesCurAmt":{"Amt":"0.00","CurCode":"THB"},"CollateralInfo":{"CollateralCode":"000"},"SeqNum":"1","DebitAcct":"00001952109500","CurrentPmtCount":"264","FeesDueCurAmt":{"Amt":"0.00","CurCode":"THB"},"PerDiemCurAmt":{"Amt":"0.0000000","CurCode":"THB"},"PastDuePmtCounter":{"Type":"6-LifeTime","DelinquencyCategory":"151","PastDuePmtCount":"0"},"BillingMethod":"Statements","DraftAcctInfo":{"AcctId":"","USA.RTN":"0"},"ProcessDt":"2021-08-25","CustType":"Personal","AutoDebitMethod":"","OrigMatureDt":"2032-05-31","NxtDueDt":"2017-05-31","AccruedIntAmt1":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt2":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt3":{"Amt":"0.00","CurCode":"THB"},"TotalInt":{"Amt":"0.00","CurCode":"THB"},"NextPmtPrincipal":{"Amt":"0.00"},"NextPmtInterest":{"Amt":"0.00"},"AcctBal":{"BalType":"ToAccountBal","CurAmt":{"Amt":"0.00"}},"TransactionCount":"N"}},"BankAcctStatus":{"BankAcctStatusCode":"Closed"},"Language":"","Region":"","AuthOfficer":"00195","PersonInfo":[{"NameAddrType":"","FullName":"MR.NAME00000001494435 LAST00000001494435","ContactInfo":{"PostAddr":{"Addr1":"ที่อยู่บรรทัด100000001494435","Addr2":"ที่อยู่บรรทัด200000001494435","Addr3":"ที่อยู่บรรทัด300000001494435","City":"จ.ทดสอบ","StateProv":"  ","PostalCode":"1234567890","Country":"ไทย","AddrType":"Mailing"}},"TINInfo":{"TINType":"SSN","TaxId":"103552303","CertCode":"Certification Not on File"},"OEDCode":"All Other Individuals","OEDInstitution":"All Other Individuals"},{"NameAddrType":"","FullName":"","ContactInfo":{"PhoneNum":{"PhoneType":"Business","Phone":"000-00001494"}}}],"InsuranceInfo":{"InsRebateDueCurAmt":{"Amt":"0.00"}},"PartyAcctRel":{"PartyAcctRelType":"ENDORSER"}},"Status":{"StatusCode":"200","StatusDesc":"success"}},"GetLoanAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","LoanInformation":{"Status":"SUCCESS","Message":"","FIIdent":"0011000101950000","AccountNumber":"01955706724001","BusinessType":"","ProductCode":"CBHA","Tenor":"83","AccountStatus":"Closed","CreditLimit":"0.00","Outstanding":"0.00","OpenDate":"2010-05-25+07:00","ContractEndDate":"2032-05-31+07:00","PaymentDueDate":"2017-05-31+07:00","OtherConditions":"0.00","CampaignName":"83070","LastPaymentDate":"2017-04-27+07:00","CurrentTenor":"83","HasCoBorrower":"Yes"},"CoBorrowerInformation":{"Status":"SUCCESS","Message":"","CoBorrower":[{"RMID":"001100000000000000000001494435","Name":"NAME TEST","Relationship":"PRIJNT"},{"RMID":"001100000000000000000009864387","Name":"NAME TEST","Relationship":"SECJNT"}]},"LoanPaymentInformation":{"Status":"SUCCESS","Message":"","LoanPayment":{"PaymentMethod":"1","SavingAccount":"00001952109500","InstallmentBalance":"13200.00"}}}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
                response.setStatusCode(200);
                return response; 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    private class getOSC01Mockupcatch implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('callout:Smart_BDM_Cal_Tools_Create_Token')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{'+
                    '"access_token": "eyJ0eXBlIjoiSldUIiwiYWxnIjoiUlM1MTIifQ.eyJhcGlfa2V5IjoiYWRtaW4iLCJzY29wZSI6InJlYWQgd3JpdGUiLCJleHAiOjE1NDY4NTg3MzUsInZlcnNpb24iOiIwMDEtMjAxODExMTEiLCJqdGkiOiIyYTQ4ZmEwYi0yMjEyLTRlMzItYTAzMC1mOWFlMmRkYWFlOTQifQ.HcK3lexOKd-ufV0adiIsKWfHzG34D606gFwFbABC-5QFKpUoLus_xq_DPPttpqj7VQB_cYIqaoFEI0HkD2rbTjXuhDDcbcpvkkaLO6DpGYfXi5RYgk7MQq7BPhgq_CVts4p4zUsLnae-c5s3cd5zC08qkNjOVMGlgNli1DZekCFa5vHdrXHICu7ih_CVV6QLLYnyhrN5-STSasxOaNqlZ5v69q0aADP69wyj2NL1SVdCoG8aPlm0ILSjKIM8lj9RsZ23Xs1LUlMGpYNqjhHEI2BDQazuW-VFz_lXi6q_84uM4XvU1bMV6TJxuVXLYjtpaY4Y2wBQJMICvfbIGN-mOg",'+
                    '"token_type": "bearer",'+
                    '"expires_in": 3600,'+
                    '"scope": "read write",'+
                    '"jti": "2a48fa0b-2212-4e32-a030-f9ae2ddaae94",'+
                    '"client_id": "xxxxx",'+
                    '"version": "001-20181111"'+
                '}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:OSC01')) {
                CalloutException e = (CalloutException)CalloutException.class.newInstance();
                e.setMessage('Mockup timed out webservice');
                throw e;
            } else if (req.getEndpoint().startsWith('callout:OSC04')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"GetLoanAccountResponse":{"AcctInqRs":{"Status":{"StatusCode":"0","Severity":"Info","StatusDesc":"Success"},"RqUID":"fb754fa5-860a-4224-9764-2ffb6157fa21","LoanAcctId":{"AcctId":"001100010195000001955706724001","AcctType":"LOC","BankInfo":{"BankId":"11"}},"LnCustAcctId":{"SPName":"","CustPermId":"001100010195000000000001494435"},"UpDt":"2021-11-11T13:14:56.206+07:00","LastTrnDt":"2017-04-27","AcctBal":[{"BalType":"Principal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Outstanding","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Used","CurAmt":{"Amt":"1960000.00"}},{"BalType":"LnAvail","CurAmt":{"Amt":"0.00"}},{"BalType":"PayoffAmt","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Current","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"CurIntRecBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"OrigCommitmentBal","CurAmt":{"Amt":"1960000.00","CurCode":"THB"}},{"BalType":"CurCommitmentBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}}],"ExtAcctBal":[{"ExtBalType":"YTDInterest","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"LastYrInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Orig","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Unpaid/AccruedInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"YTDInterestAccrEC","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"TotalPastDue","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"}],"BankAcctRec":{"LoanAcctId":{"AcctId":"","AcctType":"","BankInfo":""},"BankAcctInfo":{"CurCode":"","PersonName":{"LastName":"","FirstName":"","LegalName":""},"ContactInfo":"","ProductId":"CBHA"}},"LOCAcctRec":{"LoanInfoCommon":{"AccountTitle":"MR.NAME00000001494435 LAST00000001494435","RemainingPmtCount":"181","RemainingPmtTerm":"0","RegPmtCurAmt":{"Amt":"13200.00","CurCode":"THB"},"LastPmtDt":"2017-04-27","LastPmtCurAmt":{"Amt":"231317.00","CurCode":"THB"},"PastDuePmtCount":"0","PastDueDt":"2017-05-31","NextPmtDt":"2017-05-31","NextPmtCurAmt":{"Amt":"0.00","CurCode":"THB"},"DaysPastDue":"0","CurrentIntRate":{"Rate":"4.0000000"},"OriginalIntRate":{"Rate":"0.0000001"},"RateType":"V","EffDt":"2010-05-25T12:00:00.000000-00:00","MatDt":"2032-05-31","LOCLimit":{"Amt":"0.00","CurCode":"THB"},"LateChargesCurAmt":{"Amt":"0.00","CurCode":"THB"},"CollateralInfo":{"CollateralCode":"000"},"SeqNum":"1","DebitAcct":"00001952109500","CurrentPmtCount":"264","FeesDueCurAmt":{"Amt":"0.00","CurCode":"THB"},"PerDiemCurAmt":{"Amt":"0.0000000","CurCode":"THB"},"PastDuePmtCounter":{"Type":"6-LifeTime","DelinquencyCategory":"151","PastDuePmtCount":"0"},"BillingMethod":"Statements","DraftAcctInfo":{"AcctId":"","USA.RTN":"0"},"ProcessDt":"2021-08-25","CustType":"Personal","AutoDebitMethod":"","OrigMatureDt":"2032-05-31","NxtDueDt":"2017-05-31","AccruedIntAmt1":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt2":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt3":{"Amt":"0.00","CurCode":"THB"},"TotalInt":{"Amt":"0.00","CurCode":"THB"},"NextPmtPrincipal":{"Amt":"0.00"},"NextPmtInterest":{"Amt":"0.00"},"AcctBal":{"BalType":"ToAccountBal","CurAmt":{"Amt":"0.00"}},"TransactionCount":"N"}},"BankAcctStatus":{"BankAcctStatusCode":"Closed"},"Language":"","Region":"","AuthOfficer":"00195","PersonInfo":[{"NameAddrType":"","FullName":"MR.NAME00000001494435 LAST00000001494435","ContactInfo":{"PostAddr":{"Addr1":"ที่อยู่บรรทัด100000001494435","Addr2":"ที่อยู่บรรทัด200000001494435","Addr3":"ที่อยู่บรรทัด300000001494435","City":"จ.ทดสอบ","StateProv":"  ","PostalCode":"1234567890","Country":"ไทย","AddrType":"Mailing"}},"TINInfo":{"TINType":"SSN","TaxId":"103552303","CertCode":"Certification Not on File"},"OEDCode":"All Other Individuals","OEDInstitution":"All Other Individuals"},{"NameAddrType":"","FullName":"","ContactInfo":{"PhoneNum":{"PhoneType":"Business","Phone":"000-00001494"}}}],"InsuranceInfo":{"InsRebateDueCurAmt":{"Amt":"0.00"}},"PartyAcctRel":{"PartyAcctRelType":"ENDORSER"}},"Status":{"StatusCode":"200","StatusDesc":"success"}},"GetLoanAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","LoanInformation":{"Status":"SUCCESS","Message":"","FIIdent":"0011000101950000","AccountNumber":"01955706724001","BusinessType":"{{","ProductCode":"CBHA","Tenor":"83","AccountStatus":"Closed","CreditLimit":"0.00","Outstanding":"0.00","OpenDate":"2010-05-25+07:00","ContractEndDate":"{{","PaymentDueDate":"2017-05-31+07:00","OtherConditions":"0.00","CampaignName":"83070","LastPaymentDate":"2017-04-27+07:00","CurrentTenor":"83","HasCoBorrower":"Yes"},"CoBorrowerInformation":{"Status":"SUCCESS","Message":"","CoBorrower":[{"RMID":"001100000000000000000001494435","Name":"NAME TEST","Relationship":"PRIJNT"},{"RMID":"001100000000000000000009864387","Name":"NAME TEST","Relationship":"SECJNT"}]},"LoanPaymentInformation":{"Status":"SUCCESS","Message":"","LoanPayment":{"PaymentMethod":"1","SavingAccount":"00001952109500","InstallmentBalance":"13200.00"}}}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
                response.setStatusCode(200);
                return response; 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    @isTest 
    static void testUnauthorized04() {
        Test.setMock(HttpCalloutMock.class, new getOSC04MockupUnauthorized());
        List<Account> acctlst = RTL_TestUtility.createAccounts(1, false);
        List<Product2> prd2 = TestUtils.createProduct(1, false);
        User currentUser = [SELECT Id, Name, Employee_ID__c, ProfileId, Profile.Name FROM User WHERE Id = :userInfo.getUserId()];
        Data_Security_Matrix__c dsm = new Data_Security_Matrix__c();
        dsm.Access_Type__c = 'All';
        dsm.Section_Name__c = 'RtlCust:Customer Product Holding (Low)';
        dsm.Profile_Name__c = currentUser.Profile.Name;
        Data_Security_Matrix__c dsm2 = new Data_Security_Matrix__c();
        dsm2.Access_Type__c = 'All';
        dsm2.Section_Name__c = 'RtlCust:Customer Product Holding (High)';
        dsm2.Profile_Name__c = currentUser.Profile.Name;
        insert dsm2;
        insert dsm;
        insert prd2;
        insert acctlst;
        Test.startTest();
        CSV_RDTaxConsentController.WrapperClassForRT result = CSV_RDTaxConsentController.getdataosc01(acctlst.get(0).id);
        Test.stopTest();
    }

    @isTest 
    static void testUnauthorized01() {
        Test.setMock(HttpCalloutMock.class, new getOSC0401MockupUnauthorized());
        List<Account> acctlst = RTL_TestUtility.createAccounts(1, false);
        List<Product2> prd2 = TestUtils.createProduct(1, false);
        User currentUser = [SELECT Id, Name, Employee_ID__c, ProfileId, Profile.Name FROM User WHERE Id = :userInfo.getUserId()];
        Data_Security_Matrix__c dsm = new Data_Security_Matrix__c();
        dsm.Access_Type__c = 'All';
        dsm.Section_Name__c = 'RtlCust:Customer Product Holding (Low)';
        dsm.Profile_Name__c = currentUser.Profile.Name;
        Data_Security_Matrix__c dsm2 = new Data_Security_Matrix__c();
        dsm2.Access_Type__c = 'All';
        dsm2.Section_Name__c = 'RtlCust:Customer Product Holding (High)';
        dsm2.Profile_Name__c = currentUser.Profile.Name;
        insert dsm2;
        insert dsm;
        insert prd2;
        insert acctlst;
        Test.startTest();
        CSV_RDTaxConsentController.WrapperClassForRT result = CSV_RDTaxConsentController.getdataosc01(acctlst.get(0).id);
        Test.stopTest();
    }

    @isTest 
    static void testgetOSC04Mockup() {
        Test.setMock(HttpCalloutMock.class, new getOSC04Mockup());
        Test.startTest();

        HTTPResponse res = CSV_RDTaxConsentController.getOSC04('', '');
        String response = res.getBody();
        String StatusDesc04 = response != null && String.isNotEmpty(response) ? String.valueOf(getResult('Status.StatusDesc', JSON.deserializeUntyped(response))) : '';
        String StatusCode04 = response != null && String.isNotEmpty(response) ? String.valueOf(getResult('Status.StatusCode', JSON.deserializeUntyped(response))) : '';
        System.assertEquals('success', StatusDesc04);
        System.assertEquals('200', StatusCode04);

        Test.stopTest();
    }

    @isTest 
    static void testgetOSC04MockupError() {
        Test.setMock(HttpCalloutMock.class, new getOSC04Mockup());
        Test.startTest();
        try{
        HTTPResponse decryptedBody = CSV_RDTaxConsentController.getOSC04(null, '');
        }catch(Exception e){
            System.assertEquals('Argument 1 cannot be null', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest 
    static void testgetOSC01Mockup() {
        Test.setMock(HttpCalloutMock.class, new getOSC01Mockup());
        Test.startTest();
        HTTPResponse res = CSV_RDTaxConsentController.getOSC01('');
        String response = res.getBody();
        String StatusDesc01 = response != null && String.isNotEmpty(response) ? String.valueOf(getResult('Status.StatusDesc', JSON.deserializeUntyped(response))) : '';
        String StatusCode01 = response != null && String.isNotEmpty(response) ? String.valueOf(getResult('Status.StatusCode', JSON.deserializeUntyped(response))) : '';
        System.assertEquals('success', StatusDesc01);
        System.assertEquals('200', StatusCode01);
        Test.stopTest();
    }

    @isTest 
    static void testgetDataFrom04Error() {
        Test.setMock(HttpCalloutMock.class, new OSC04Timeout());
        Test.startTest();
        OnlineServiceLog decryptedBody = CSV_RDTaxConsentController.getDataFrom04('');
        System.assertEquals('Mockup timed out webservice', decryptedBody.errorMesssage);
        Test.stopTest();
    }

    @isTest 
    static void testgetLoanAccountError() {
        Test.setMock(HttpCalloutMock.class, new getOSC04Mockup());
        String responseBody = '{"GetCustomerAccountResponse":{"LoanAccounts":{}}}';
        Test.startTest();
        String res = CSV_RDTaxConsentController.getLoanAccount(responseBody);
        System.assertEquals(res,'');
        Test.stopTest();
    }

    @isTest 
    static void testgetdataosc01() {
        Test.setMock(HttpCalloutMock.class, new getOSC01Mockup());
        List<Account> acctlst = RTL_TestUtility.createAccounts(1, false);
        List<Product2> prd2 = TestUtils.createProduct(1, false);
        User currentUser = [SELECT Id, Name, Employee_ID__c, ProfileId, Profile.Name FROM User WHERE Id = :userInfo.getUserId()];
        Data_Security_Matrix__c dsm = new Data_Security_Matrix__c();
        dsm.Access_Type__c = 'All';
        dsm.Section_Name__c = 'RtlCust:Customer Product Holding (Low)';
        dsm.Profile_Name__c = currentUser.Profile.Name;
        Data_Security_Matrix__c dsm2 = new Data_Security_Matrix__c();
        dsm2.Access_Type__c = 'All';
        dsm2.Section_Name__c = 'RtlCust:Customer Product Holding (High)';
        dsm2.Profile_Name__c = currentUser.Profile.Name;
        insert dsm2;
        insert dsm;
        insert prd2;
        insert acctlst;
        Test.startTest();
        CSV_RDTaxConsentController.WrapperClassForRT result = CSV_RDTaxConsentController.getdataosc01(acctlst.get(0).id);
        System.assertEquals(true,result.dataPartitionPermission);
        System.assertEquals('Active',result.loanWrapper.get(0).accountStatus);
        Test.stopTest();
    }

    @isTest 
    static void testgetdataosc01catch() {
        Test.setMock(HttpCalloutMock.class, new getOSC01Mockupcatch());
        List<Account> acctlst = RTL_TestUtility.createAccounts(1, false);
        List<Product2> prd2 = TestUtils.createProduct(1, false);
        Data_Security_Matrix__c dsm = new Data_Security_Matrix__c();
        User currentUser = [SELECT Id, Name, Employee_ID__c, ProfileId, Profile.Name FROM User WHERE Id = :userInfo.getUserId()];
        dsm.Access_Type__c = 'All';
        dsm.Section_Name__c = 'RtlCust:Customer Product Holding (Low)';
        dsm.Profile_Name__c = currentUser.Profile.Name;
        Data_Security_Matrix__c dsm2 = new Data_Security_Matrix__c();
        dsm2.Access_Type__c = 'All';
        dsm2.Section_Name__c = 'RtlCust:Customer Product Holding (High)';
        dsm2.Profile_Name__c = currentUser.Profile.Name;
        insert dsm2;
        insert dsm;
        insert prd2;
        insert acctlst;
        Test.startTest();
        CSV_RDTaxConsentController.WrapperClassForRT result = CSV_RDTaxConsentController.getdataosc01(acctlst.get(0).id);
        System.assertEquals('TIMEOUT', result.statusDesc01);
        Test.stopTest();
    }

    @isTest 
    static void testgetdataosc01Nodsm() {
        Test.setMock(HttpCalloutMock.class, new getOSC01Mockup());
        List<Account> acctlst = RTL_TestUtility.createAccounts(1, false);
        List<Product2> prd2 = TestUtils.createProduct(1, false);
        insert prd2;
        insert acctlst;
        Test.startTest();
        CSV_RDTaxConsentController.WrapperClassForRT result = CSV_RDTaxConsentController.getdataosc01(acctlst.get(0).id);
        System.assertEquals(false,result.dataPartitionPermission);
        Test.stopTest();
    }
    
    @isTest 
    static void testgetdataosc01Error() {
        Test.setMock(HttpCalloutMock.class, new getOSC01MockupError());
        List<Account> acctlst = RTL_TestUtility.createAccounts(1, false);
        List<Product2> prd2 = TestUtils.createProduct(1, false);
        Data_Security_Matrix__c dsm = new Data_Security_Matrix__c();
        User currentUser = [SELECT Id, Name, Employee_ID__c, ProfileId, Profile.Name FROM User WHERE Id = :userInfo.getUserId()];
        dsm.Access_Type__c = 'All';
        dsm.Section_Name__c = 'RtlCust:Customer Product Holding (Low)';
        dsm.Profile_Name__c = currentUser.Profile.Name;
        Data_Security_Matrix__c dsm2 = new Data_Security_Matrix__c();
        dsm2.Access_Type__c = 'All';
        dsm2.Section_Name__c = 'RtlCust:Customer Product Holding (High)';
        dsm2.Profile_Name__c = currentUser.Profile.Name;
        insert dsm2;
        insert dsm;
        insert prd2;
        insert acctlst;
        Test.startTest();
        CSV_RDTaxConsentController.WrapperClassForRT result = CSV_RDTaxConsentController.getdataosc01(acctlst.get(0).id);
        System.assertEquals('ERROR',result.statusDesc01);
        Test.stopTest();
    }
    
    @isTest 
    static void testgetdataosc01Unsuccess() {
        Test.setMock(HttpCalloutMock.class, new getOSC01MockupUnsuccess());
        List<Account> acctlst = RTL_TestUtility.createAccounts(1, false);
        List<Product2> prd2 = TestUtils.createProduct(1, false);
        Data_Security_Matrix__c dsm = new Data_Security_Matrix__c();
        User currentUser = [SELECT Id, Name, Employee_ID__c, ProfileId, Profile.Name FROM User WHERE Id = :userInfo.getUserId()];
        dsm.Access_Type__c = 'All';
        dsm.Section_Name__c = 'RtlCust:Customer Product Holding (Low)';
        dsm.Profile_Name__c = currentUser.Profile.Name;
        Data_Security_Matrix__c dsm2 = new Data_Security_Matrix__c();
        dsm2.Access_Type__c = 'All';
        dsm2.Section_Name__c = 'RtlCust:Customer Product Holding (High)';
        dsm2.Profile_Name__c = currentUser.Profile.Name;
        insert dsm2;
        system.debug(currentUser.Profile.Name);
        insert dsm;
        insert prd2;
        insert acctlst;
        Test.startTest();
        CSV_RDTaxConsentController.WrapperClassForRT result = CSV_RDTaxConsentController.getdataosc01(acctlst.get(0).id);
        System.assertEquals('ERROR',result.statusDesc01);
        Test.stopTest();
    }

    @isTest 
    static void testgetdataosc01Catchosc04() {
        Test.setMock(HttpCalloutMock.class, new getOSC04MockupError());

        List<Account> acctlst = RTL_TestUtility.createAccounts(1, false);
        List<Product2> prd2 = TestUtils.createProduct(1, false);
        Data_Security_Matrix__c dsm = new Data_Security_Matrix__c();
        User currentUser = [SELECT Id, Name, Employee_ID__c, ProfileId, Profile.Name FROM User WHERE Id = :userInfo.getUserId()];
        dsm.Access_Type__c = 'All';
        dsm.Section_Name__c = 'RtlCust:Customer Product Holding (Low)';
        dsm.Profile_Name__c = currentUser.Profile.Name;
        Data_Security_Matrix__c dsm2 = new Data_Security_Matrix__c();
        dsm2.Access_Type__c = 'All';
        dsm2.Section_Name__c = 'RtlCust:Customer Product Holding (High)';
        dsm2.Profile_Name__c = currentUser.Profile.Name;
        insert dsm2;
        system.debug(currentUser.Profile.Name);
        insert dsm;
        insert prd2;
        insert acctlst;

        Test.startTest();
        CSV_RDTaxConsentController.WrapperClassForRT result = CSV_RDTaxConsentController.getdataosc01(acctlst.get(0).id);
        System.debug(result);
        // System.assertEquals('ERROR',result.statusDesc01);
        Test.stopTest();
    }    
}