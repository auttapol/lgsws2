@isTest
public class taxCertificateControllerTest extends AbstractCoreClass {
    @testSetup 
    static void setupData() {
        TestUtils.createAppConfig();

        List<Account> acctlst = RTL_TestUtility.createAccounts(1, false);
        acctlst.get(0).Name = 'AccoutName test';
        acctlst.get(0).TMB_Customer_ID_PE__c = '001100000000000000000000051187';
        insert acctlst;

        List<Product2> prd2lst = RTL_TestUtility.createRetailProduct2(1, false);
        prd2lst.get(0).Name = 'MOCKUPPRDJA';
        prd2lst.get(0).ProductCode = 'CBHA';
        insert prd2lst;
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
                response.setBody('{"GetLoanAccountResponse":{"AcctInqRs":{"Status":{"StatusCode":"0","Severity":"Info","StatusDesc":"Success"},"RqUID":"fb754fa5-860a-4224-9764-2ffb6157fa21","LoanAcctId":{"AcctId":"001100010195000001955706724001","AcctType":"LOC","BankInfo":{"BankId":"11"}},"LnCustAcctId":{"SPName":"","CustPermId":"001100010195000000000001494435"},"UpDt":"2021-11-11T13:14:56.206+07:00","LastTrnDt":"2017-04-27","AcctBal":[{"BalType":"Principal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Outstanding","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Used","CurAmt":{"Amt":"1960000.00"}},{"BalType":"LnAvail","CurAmt":{"Amt":"0.00"}},{"BalType":"PayoffAmt","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Current","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"CurIntRecBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"OrigCommitmentBal","CurAmt":{"Amt":"1960000.00","CurCode":"THB"}},{"BalType":"CurCommitmentBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}}],"ExtAcctBal":[{"ExtBalType":"YTDInterest","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"LastYrInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Orig","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Unpaid/AccruedInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"YTDInterestAccrEC","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"TotalPastDue","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"}],"BankAcctRec":{"LoanAcctId":{"AcctId":"","AcctType":"","BankInfo":""},"BankAcctInfo":{"CurCode":"","PersonName":{"LastName":"","FirstName":"","LegalName":""},"ContactInfo":"","ProductId":"CBHA"}},"LOCAcctRec":{"LoanInfoCommon":{"AccountTitle":"MR.NAME00000001494435 LAST00000001494435","RemainingPmtCount":"181","RemainingPmtTerm":"0","RegPmtCurAmt":{"Amt":"13200.00","CurCode":"THB"},"LastPmtDt":"2017-04-27","LastPmtCurAmt":{"Amt":"231317.00","CurCode":"THB"},"PastDuePmtCount":"0","PastDueDt":"2017-05-31","NextPmtDt":"2017-05-31","NextPmtCurAmt":{"Amt":"0.00","CurCode":"THB"},"DaysPastDue":"0","CurrentIntRate":{"Rate":"4.0000000"},"OriginalIntRate":{"Rate":"0.0000001"},"RateType":"V","EffDt":"2010-05-25T12:00:00.000000-00:00","MatDt":"2032-05-31","LOCLimit":{"Amt":"0.00","CurCode":"THB"},"LateChargesCurAmt":{"Amt":"0.00","CurCode":"THB"},"CollateralInfo":{"CollateralCode":"000"},"SeqNum":"1","DebitAcct":"00001952109500","CurrentPmtCount":"264","FeesDueCurAmt":{"Amt":"0.00","CurCode":"THB"},"PerDiemCurAmt":{"Amt":"0.0000000","CurCode":"THB"},"PastDuePmtCounter":{"Type":"6-LifeTime","DelinquencyCategory":"151","PastDuePmtCount":"0"},"BillingMethod":"Statements","DraftAcctInfo":{"AcctId":"","USA.RTN":"0"},"ProcessDt":"2021-08-25","CustType":"Personal","AutoDebitMethod":"","OrigMatureDt":"2032-05-31","NxtDueDt":"2017-05-31","AccruedIntAmt1":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt2":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt3":{"Amt":"0.00","CurCode":"THB"},"TotalInt":{"Amt":"0.00","CurCode":"THB"},"NextPmtPrincipal":{"Amt":"0.00"},"NextPmtInterest":{"Amt":"0.00"},"AcctBal":{"BalType":"ToAccountBal","CurAmt":{"Amt":"0.00"}},"TransactionCount":"N"}},"BankAcctStatus":{"BankAcctStatusCode":"Closed"},"Language":"","Region":"","AuthOfficer":"00195","PersonInfo":[{"NameAddrType":"","FullName":"MR.NAME00000001494435 LAST00000001494435","ContactInfo":{"PostAddr":{"Addr1":"ที่อยู่บรรทัด100000001494435","Addr2":"ที่อยู่บรรทัด200000001494435","Addr3":"ที่อยู่บรรทัด300000001494435","City":"จ.ทดสอบ","StateProv":"  ","PostalCode":"1234567890","Country":"ไทย","AddrType":"Mailing"}},"TINInfo":{"TINType":"SSN","TaxId":"103552303","CertCode":"Certification Not on File"},"OEDCode":"All Other Individuals","OEDInstitution":"All Other Individuals"},{"NameAddrType":"","FullName":"","ContactInfo":{"PhoneNum":{"PhoneType":"Business","Phone":"000-00001494"}}}],"InsuranceInfo":{"InsRebateDueCurAmt":{"Amt":"0.00"}},"PartyAcctRel":{"PartyAcctRelType":"ENDORSER"}},"Status":{"StatusCode":"200","StatusDesc":"success"}},"GetLoanAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","LoanInformation":{"Status":"SUCCESS","Message":"","FIIdent":"0011000101950000","AccountNumber":"01955706724001","BusinessType":"KA010100","ProductCode":"CBHA","Tenor":"83","AccountStatus":"Closed","CreditLimit":"0.00","Outstanding":"0.00","OpenDate":"2010-05-25+07:00","ContractEndDate":"2032-05-31+07:00","PaymentDueDate":"2017-05-31+07:00","OtherConditions":"0.00","CampaignName":"83070","LastPaymentDate":"2017-04-27+07:00","CurrentTenor":"83","HasCoBorrower":"Yes"},"CoBorrowerInformation":{"Status":"SUCCESS","Message":"","CoBorrower":[{"RMID":"001100000000000000000001494435","Name":"NAME TEST","Relationship":"PRIJNT"},{"RMID":"001100000000000000000009864387","Name":"NAME TEST","Relationship":"SECJNT"}]},"LoanPaymentInformation":{"Status":"SUCCESS","Message":"","LoanPayment":{"PaymentMethod":"1","SavingAccount":"00001952109500","InstallmentBalance":"13200.00"}}}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
                response.setStatusCode(200);
                return response; 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    private class getOSC04MockupStatusDescError implements HttpCalloutMock {
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
                response.setBody('{"GetLoanAccountResponse":{"AcctInqRs":{"Status":{"StatusCode":"0","Severity":"Info","StatusDesc":"Success"},"RqUID":"fb754fa5-860a-4224-9764-2ffb6157fa21","LoanAcctId":{"AcctId":"001100010195000001955706724001","AcctType":"LOC","BankInfo":{"BankId":"11"}},"LnCustAcctId":{"SPName":"","CustPermId":"001100010195000000000001494435"},"UpDt":"2021-11-11T13:14:56.206+07:00","LastTrnDt":"2017-04-27","AcctBal":[{"BalType":"Principal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Outstanding","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Used","CurAmt":{"Amt":"1960000.00"}},{"BalType":"LnAvail","CurAmt":{"Amt":"0.00"}},{"BalType":"PayoffAmt","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Current","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"CurIntRecBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"OrigCommitmentBal","CurAmt":{"Amt":"1960000.00","CurCode":"THB"}},{"BalType":"CurCommitmentBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}}],"ExtAcctBal":[{"ExtBalType":"YTDInterest","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"LastYrInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Orig","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Unpaid/AccruedInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"YTDInterestAccrEC","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"TotalPastDue","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"}],"BankAcctRec":{"LoanAcctId":{"AcctId":"","AcctType":"","BankInfo":""},"BankAcctInfo":{"CurCode":"","PersonName":{"LastName":"","FirstName":"","LegalName":""},"ContactInfo":"","ProductId":"CBHA"}},"LOCAcctRec":{"LoanInfoCommon":{"AccountTitle":"MR.NAME00000001494435 LAST00000001494435","RemainingPmtCount":"181","RemainingPmtTerm":"0","RegPmtCurAmt":{"Amt":"13200.00","CurCode":"THB"},"LastPmtDt":"2017-04-27","LastPmtCurAmt":{"Amt":"231317.00","CurCode":"THB"},"PastDuePmtCount":"0","PastDueDt":"2017-05-31","NextPmtDt":"2017-05-31","NextPmtCurAmt":{"Amt":"0.00","CurCode":"THB"},"DaysPastDue":"0","CurrentIntRate":{"Rate":"4.0000000"},"OriginalIntRate":{"Rate":"0.0000001"},"RateType":"V","EffDt":"2010-05-25T12:00:00.000000-00:00","MatDt":"2032-05-31","LOCLimit":{"Amt":"0.00","CurCode":"THB"},"LateChargesCurAmt":{"Amt":"0.00","CurCode":"THB"},"CollateralInfo":{"CollateralCode":"000"},"SeqNum":"1","DebitAcct":"00001952109500","CurrentPmtCount":"264","FeesDueCurAmt":{"Amt":"0.00","CurCode":"THB"},"PerDiemCurAmt":{"Amt":"0.0000000","CurCode":"THB"},"PastDuePmtCounter":{"Type":"6-LifeTime","DelinquencyCategory":"151","PastDuePmtCount":"0"},"BillingMethod":"Statements","DraftAcctInfo":{"AcctId":"","USA.RTN":"0"},"ProcessDt":"2021-08-25","CustType":"Personal","AutoDebitMethod":"","OrigMatureDt":"2032-05-31","NxtDueDt":"2017-05-31","AccruedIntAmt1":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt2":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt3":{"Amt":"0.00","CurCode":"THB"},"TotalInt":{"Amt":"0.00","CurCode":"THB"},"NextPmtPrincipal":{"Amt":"0.00"},"NextPmtInterest":{"Amt":"0.00"},"AcctBal":{"BalType":"ToAccountBal","CurAmt":{"Amt":"0.00"}},"TransactionCount":"N"}},"BankAcctStatus":{"BankAcctStatusCode":"Closed"},"Language":"","Region":"","AuthOfficer":"00195","PersonInfo":[{"NameAddrType":"","FullName":"MR.NAME00000001494435 LAST00000001494435","ContactInfo":{"PostAddr":{"Addr1":"ที่อยู่บรรทัด100000001494435","Addr2":"ที่อยู่บรรทัด200000001494435","Addr3":"ที่อยู่บรรทัด300000001494435","City":"จ.ทดสอบ","StateProv":"  ","PostalCode":"1234567890","Country":"ไทย","AddrType":"Mailing"}},"TINInfo":{"TINType":"SSN","TaxId":"103552303","CertCode":"Certification Not on File"},"OEDCode":"All Other Individuals","OEDInstitution":"All Other Individuals"},{"NameAddrType":"","FullName":"","ContactInfo":{"PhoneNum":{"PhoneType":"Business","Phone":"000-00001494"}}}],"InsuranceInfo":{"InsRebateDueCurAmt":{"Amt":"0.00"}},"PartyAcctRel":{"PartyAcctRelType":"ENDORSER"}},"Status":{"StatusCode":"200","StatusDesc":"success"}},"GetLoanAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","LoanInformation":{"Status":"SUCCESS","Message":"","FIIdent":"0011000101950000","AccountNumber":"01955706724001","BusinessType":"","ProductCode":"CBHA","Tenor":"83","AccountStatus":"Closed","CreditLimit":"0.00","Outstanding":"0.00","OpenDate":"2010-05-25+07:00","ContractEndDate":"2032-05-31+07:00","PaymentDueDate":"2017-05-31+07:00","OtherConditions":"0.00","CampaignName":"83070","LastPaymentDate":"2017-04-27+07:00","CurrentTenor":"83","HasCoBorrower":"Yes"},"CoBorrowerInformation":{"Status":"ERROR","Message":"","CoBorrower":[{"RMID":"001100000000000000000001494435","Name":"NAME TEST","Relationship":"PRIJNT"},{"RMID":"001100000000000000000009864387","Name":"NAME TEST","Relationship":"SECJNT"}]},"LoanPaymentInformation":{"Status":"SUCCESS","Message":"","LoanPayment":{"PaymentMethod":"1","SavingAccount":"00001952109500","InstallmentBalance":"13200.00"}}}},"Status":{"StatusCode":"200","StatusDesc":"error"}}');
                response.setStatusCode(200);
                return response; 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    private class getOSC04MockupAcctNoBlank implements HttpCalloutMock {
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
                response.setBody('{"GetLoanAccountResponse":{"AcctInqRs":{"Status":{"StatusCode":"0","Severity":"Info","StatusDesc":"Success"},"RqUID":"fb754fa5-860a-4224-9764-2ffb6157fa21","LoanAcctId":{"AcctId":"001100010195000001955706724001","AcctType":"LOC","BankInfo":{"BankId":"11"}},"LnCustAcctId":{"SPName":"","CustPermId":"001100010195000000000001494435"},"UpDt":"2021-11-11T13:14:56.206+07:00","LastTrnDt":"2017-04-27","AcctBal":[{"BalType":"Principal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Outstanding","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Used","CurAmt":{"Amt":"1960000.00"}},{"BalType":"LnAvail","CurAmt":{"Amt":"0.00"}},{"BalType":"PayoffAmt","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Current","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"CurIntRecBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"OrigCommitmentBal","CurAmt":{"Amt":"1960000.00","CurCode":"THB"}},{"BalType":"CurCommitmentBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}}],"ExtAcctBal":[{"ExtBalType":"YTDInterest","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"LastYrInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Orig","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Unpaid/AccruedInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"YTDInterestAccrEC","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"TotalPastDue","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"}],"BankAcctRec":{"LoanAcctId":{"AcctId":"","AcctType":"","BankInfo":""},"BankAcctInfo":{"CurCode":"","PersonName":{"LastName":"","FirstName":"","LegalName":""},"ContactInfo":"","ProductId":"CBHA"}},"LOCAcctRec":{"LoanInfoCommon":{"AccountTitle":"MR.NAME00000001494435 LAST00000001494435","RemainingPmtCount":"181","RemainingPmtTerm":"0","RegPmtCurAmt":{"Amt":"13200.00","CurCode":"THB"},"LastPmtDt":"2017-04-27","LastPmtCurAmt":{"Amt":"231317.00","CurCode":"THB"},"PastDuePmtCount":"0","PastDueDt":"2017-05-31","NextPmtDt":"2017-05-31","NextPmtCurAmt":{"Amt":"0.00","CurCode":"THB"},"DaysPastDue":"0","CurrentIntRate":{"Rate":"4.0000000"},"OriginalIntRate":{"Rate":"0.0000001"},"RateType":"V","EffDt":"2010-05-25T12:00:00.000000-00:00","MatDt":"2032-05-31","LOCLimit":{"Amt":"0.00","CurCode":"THB"},"LateChargesCurAmt":{"Amt":"0.00","CurCode":"THB"},"CollateralInfo":{"CollateralCode":"000"},"SeqNum":"1","DebitAcct":"00001952109500","CurrentPmtCount":"264","FeesDueCurAmt":{"Amt":"0.00","CurCode":"THB"},"PerDiemCurAmt":{"Amt":"0.0000000","CurCode":"THB"},"PastDuePmtCounter":{"Type":"6-LifeTime","DelinquencyCategory":"151","PastDuePmtCount":"0"},"BillingMethod":"Statements","DraftAcctInfo":{"AcctId":"","USA.RTN":"0"},"ProcessDt":"2021-08-25","CustType":"Personal","AutoDebitMethod":"","OrigMatureDt":"2032-05-31","NxtDueDt":"2017-05-31","AccruedIntAmt1":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt2":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt3":{"Amt":"0.00","CurCode":"THB"},"TotalInt":{"Amt":"0.00","CurCode":"THB"},"NextPmtPrincipal":{"Amt":"0.00"},"NextPmtInterest":{"Amt":"0.00"},"AcctBal":{"BalType":"ToAccountBal","CurAmt":{"Amt":"0.00"}},"TransactionCount":"N"}},"BankAcctStatus":{"BankAcctStatusCode":"Closed"},"Language":"","Region":"","AuthOfficer":"00195","PersonInfo":[{"NameAddrType":"","FullName":"MR.NAME00000001494435 LAST00000001494435","ContactInfo":{"PostAddr":{"Addr1":"ที่อยู่บรรทัด100000001494435","Addr2":"ที่อยู่บรรทัด200000001494435","Addr3":"ที่อยู่บรรทัด300000001494435","City":"จ.ทดสอบ","StateProv":"  ","PostalCode":"1234567890","Country":"ไทย","AddrType":"Mailing"}},"TINInfo":{"TINType":"SSN","TaxId":"103552303","CertCode":"Certification Not on File"},"OEDCode":"All Other Individuals","OEDInstitution":"All Other Individuals"},{"NameAddrType":"","FullName":"","ContactInfo":{"PhoneNum":{"PhoneType":"Business","Phone":"000-00001494"}}}],"InsuranceInfo":{"InsRebateDueCurAmt":{"Amt":"0.00"}},"PartyAcctRel":{"PartyAcctRelType":"ENDORSER"}},"Status":{"StatusCode":"200","StatusDesc":"success"}},"GetLoanAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","LoanInformation":{"Status":"SUCCESS","Message":"","FIIdent":"0011000101950000","AccountNumber":"","BusinessType":"KA010100","ProductCode":"CBHA","Tenor":"83","AccountStatus":"Closed","CreditLimit":"0.00","Outstanding":"0.00","OpenDate":"2010-05-25+07:00","ContractEndDate":"2032-05-31+07:00","PaymentDueDate":"2017-05-31+07:00","OtherConditions":"0.00","CampaignName":"83070","LastPaymentDate":"2017-04-27+07:00","CurrentTenor":"83","HasCoBorrower":"Yes"},"CoBorrowerInformation":{"Status":"SUCCESS","Message":"","CoBorrower":[]},"LoanPaymentInformation":{"Status":"SUCCESS","Message":"","LoanPayment":{"PaymentMethod":"1","SavingAccount":"00001952109500","InstallmentBalance":"13200.00"}}}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
                response.setStatusCode(200);
                return response; 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    private class getOSC04MockupAcctInqError implements HttpCalloutMock {
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
                response.setBody('{"GetLoanAccountResponse":{"AcctInqRs":{"Status":{"StatusCode":"999","Severity":"Info","StatusDesc":"Error"},"RqUID":"fb754fa5-860a-4224-9764-2ffb6157fa21","LoanAcctId":{"AcctId":"001100010195000001955706724001","AcctType":"LOC","BankInfo":{"BankId":"11"}},"LnCustAcctId":{"SPName":"","CustPermId":"001100010195000000000001494435"},"UpDt":"2021-11-11T13:14:56.206+07:00","LastTrnDt":"2017-04-27","AcctBal":[{"BalType":"Principal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Outstanding","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Used","CurAmt":{"Amt":"1960000.00"}},{"BalType":"LnAvail","CurAmt":{"Amt":"0.00"}},{"BalType":"PayoffAmt","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Current","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"CurIntRecBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"OrigCommitmentBal","CurAmt":{"Amt":"1960000.00","CurCode":"THB"}},{"BalType":"CurCommitmentBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}}],"ExtAcctBal":[{"ExtBalType":"YTDInterest","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"LastYrInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Orig","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Unpaid/AccruedInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"YTDInterestAccrEC","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"TotalPastDue","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"}],"BankAcctRec":{"LoanAcctId":{"AcctId":"","AcctType":"","BankInfo":""},"BankAcctInfo":{"CurCode":"","PersonName":{"LastName":"","FirstName":"","LegalName":""},"ContactInfo":"","ProductId":"CBHA"}},"LOCAcctRec":{"LoanInfoCommon":{"AccountTitle":"MR.NAME00000001494435 LAST00000001494435","RemainingPmtCount":"181","RemainingPmtTerm":"0","RegPmtCurAmt":{"Amt":"13200.00","CurCode":"THB"},"LastPmtDt":"2017-04-27","LastPmtCurAmt":{"Amt":"231317.00","CurCode":"THB"},"PastDuePmtCount":"0","PastDueDt":"2017-05-31","NextPmtDt":"2017-05-31","NextPmtCurAmt":{"Amt":"0.00","CurCode":"THB"},"DaysPastDue":"0","CurrentIntRate":{"Rate":"4.0000000"},"OriginalIntRate":{"Rate":"0.0000001"},"RateType":"V","EffDt":"2010-05-25T12:00:00.000000-00:00","MatDt":"2032-05-31","LOCLimit":{"Amt":"0.00","CurCode":"THB"},"LateChargesCurAmt":{"Amt":"0.00","CurCode":"THB"},"CollateralInfo":{"CollateralCode":"000"},"SeqNum":"1","DebitAcct":"00001952109500","CurrentPmtCount":"264","FeesDueCurAmt":{"Amt":"0.00","CurCode":"THB"},"PerDiemCurAmt":{"Amt":"0.0000000","CurCode":"THB"},"PastDuePmtCounter":{"Type":"6-LifeTime","DelinquencyCategory":"151","PastDuePmtCount":"0"},"BillingMethod":"Statements","DraftAcctInfo":{"AcctId":"","USA.RTN":"0"},"ProcessDt":"2021-08-25","CustType":"Personal","AutoDebitMethod":"","OrigMatureDt":"2032-05-31","NxtDueDt":"2017-05-31","AccruedIntAmt1":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt2":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt3":{"Amt":"0.00","CurCode":"THB"},"TotalInt":{"Amt":"0.00","CurCode":"THB"},"NextPmtPrincipal":{"Amt":"0.00"},"NextPmtInterest":{"Amt":"0.00"},"AcctBal":{"BalType":"ToAccountBal","CurAmt":{"Amt":"0.00"}},"TransactionCount":"N"}},"BankAcctStatus":{"BankAcctStatusCode":"Closed"},"Language":"","Region":"","AuthOfficer":"00195","PersonInfo":[{"NameAddrType":"","FullName":"MR.NAME00000001494435 LAST00000001494435","ContactInfo":{"PostAddr":{"Addr1":"ที่อยู่บรรทัด100000001494435","Addr2":"ที่อยู่บรรทัด200000001494435","Addr3":"ที่อยู่บรรทัด300000001494435","City":"จ.ทดสอบ","StateProv":"  ","PostalCode":"1234567890","Country":"ไทย","AddrType":"Mailing"}},"TINInfo":{"TINType":"SSN","TaxId":"103552303","CertCode":"Certification Not on File"},"OEDCode":"All Other Individuals","OEDInstitution":"All Other Individuals"},{"NameAddrType":"","FullName":"","ContactInfo":{"PhoneNum":{"PhoneType":"Business","Phone":"000-00001494"}}}],"InsuranceInfo":{"InsRebateDueCurAmt":{"Amt":"0.00"}},"PartyAcctRel":{"PartyAcctRelType":"ENDORSER"}},"Status":{"StatusCode":"200","StatusDesc":"success"}},"GetLoanAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","LoanInformation":{"Status":"SUCCESS","Message":"","FIIdent":"0011000101950000","AccountNumber":"01955706724001","BusinessType":"KA010100","ProductCode":"CBHA","Tenor":"83","AccountStatus":"Closed","CreditLimit":"0.00","Outstanding":"0.00","OpenDate":"2010-05-25+07:00","ContractEndDate":"2032-05-31+07:00","PaymentDueDate":"2017-05-31+07:00","OtherConditions":"0.00","CampaignName":"83070","LastPaymentDate":"2017-04-27+07:00","CurrentTenor":"83","HasCoBorrower":"Yes"},"CoBorrowerInformation":{"Status":"SUCCESS","Message":"","CoBorrower":[]},"LoanPaymentInformation":{"Status":"SUCCESS","Message":"","LoanPayment":{"PaymentMethod":"1","SavingAccount":"00001952109500","InstallmentBalance":"13200.00"}}}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
                response.setStatusCode(200);
                return response; 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    private class getOSC04MockupCoBorrowerInformationError implements HttpCalloutMock {
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
                response.setBody('{"GetLoanAccountResponse":{"AcctInqRs":{"Status":{"StatusCode":"0","Severity":"Info","StatusDesc":"Success"},"RqUID":"fb754fa5-860a-4224-9764-2ffb6157fa21","LoanAcctId":{"AcctId":"001100010195000001955706724001","AcctType":"LOC","BankInfo":{"BankId":"11"}},"LnCustAcctId":{"SPName":"","CustPermId":"001100010195000000000001494435"},"UpDt":"2021-11-11T13:14:56.206+07:00","LastTrnDt":"2017-04-27","AcctBal":[{"BalType":"Principal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Outstanding","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Used","CurAmt":{"Amt":"1960000.00"}},{"BalType":"LnAvail","CurAmt":{"Amt":"0.00"}},{"BalType":"PayoffAmt","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Current","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"CurIntRecBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"OrigCommitmentBal","CurAmt":{"Amt":"1960000.00","CurCode":"THB"}},{"BalType":"CurCommitmentBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}}],"ExtAcctBal":[{"ExtBalType":"YTDInterest","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"LastYrInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Orig","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Unpaid/AccruedInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"YTDInterestAccrEC","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"TotalPastDue","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"}],"BankAcctRec":{"LoanAcctId":{"AcctId":"","AcctType":"","BankInfo":""},"BankAcctInfo":{"CurCode":"","PersonName":{"LastName":"","FirstName":"","LegalName":""},"ContactInfo":"","ProductId":"CBHA"}},"LOCAcctRec":{"LoanInfoCommon":{"AccountTitle":"MR.NAME00000001494435 LAST00000001494435","RemainingPmtCount":"181","RemainingPmtTerm":"0","RegPmtCurAmt":{"Amt":"13200.00","CurCode":"THB"},"LastPmtDt":"2017-04-27","LastPmtCurAmt":{"Amt":"231317.00","CurCode":"THB"},"PastDuePmtCount":"0","PastDueDt":"2017-05-31","NextPmtDt":"2017-05-31","NextPmtCurAmt":{"Amt":"0.00","CurCode":"THB"},"DaysPastDue":"0","CurrentIntRate":{"Rate":"4.0000000"},"OriginalIntRate":{"Rate":"0.0000001"},"RateType":"V","EffDt":"2010-05-25T12:00:00.000000-00:00","MatDt":"2032-05-31","LOCLimit":{"Amt":"0.00","CurCode":"THB"},"LateChargesCurAmt":{"Amt":"0.00","CurCode":"THB"},"CollateralInfo":{"CollateralCode":"000"},"SeqNum":"1","DebitAcct":"00001952109500","CurrentPmtCount":"264","FeesDueCurAmt":{"Amt":"0.00","CurCode":"THB"},"PerDiemCurAmt":{"Amt":"0.0000000","CurCode":"THB"},"PastDuePmtCounter":{"Type":"6-LifeTime","DelinquencyCategory":"151","PastDuePmtCount":"0"},"BillingMethod":"Statements","DraftAcctInfo":{"AcctId":"","USA.RTN":"0"},"ProcessDt":"2021-08-25","CustType":"Personal","AutoDebitMethod":"","OrigMatureDt":"2032-05-31","NxtDueDt":"2017-05-31","AccruedIntAmt1":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt2":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt3":{"Amt":"0.00","CurCode":"THB"},"TotalInt":{"Amt":"0.00","CurCode":"THB"},"NextPmtPrincipal":{"Amt":"0.00"},"NextPmtInterest":{"Amt":"0.00"},"AcctBal":{"BalType":"ToAccountBal","CurAmt":{"Amt":"0.00"}},"TransactionCount":"N"}},"BankAcctStatus":{"BankAcctStatusCode":"Closed"},"Language":"","Region":"","AuthOfficer":"00195","PersonInfo":[{"NameAddrType":"","FullName":"MR.NAME00000001494435 LAST00000001494435","ContactInfo":{"PostAddr":{"Addr1":"ที่อยู่บรรทัด100000001494435","Addr2":"ที่อยู่บรรทัด200000001494435","Addr3":"ที่อยู่บรรทัด300000001494435","City":"จ.ทดสอบ","StateProv":"  ","PostalCode":"1234567890","Country":"ไทย","AddrType":"Mailing"}},"TINInfo":{"TINType":"SSN","TaxId":"103552303","CertCode":"Certification Not on File"},"OEDCode":"All Other Individuals","OEDInstitution":"All Other Individuals"},{"NameAddrType":"","FullName":"","ContactInfo":{"PhoneNum":{"PhoneType":"Business","Phone":"000-00001494"}}}],"InsuranceInfo":{"InsRebateDueCurAmt":{"Amt":"0.00"}},"PartyAcctRel":{"PartyAcctRelType":"ENDORSER"}},"Status":{"StatusCode":"200","StatusDesc":"success"}},"GetLoanAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","LoanInformation":{"Status":"SUCCESS","Message":"","FIIdent":"0011000101950000","AccountNumber":"01955706724001","BusinessType":"KA010100","ProductCode":"CBHA","Tenor":"83","AccountStatus":"Closed","CreditLimit":"0.00","Outstanding":"0.00","OpenDate":"2010-05-25+07:00","ContractEndDate":"2032-05-31+07:00","PaymentDueDate":"2017-05-31+07:00","OtherConditions":"0.00","CampaignName":"83070","LastPaymentDate":"2017-04-27+07:00","CurrentTenor":"83","HasCoBorrower":"Yes"},"CoBorrowerInformation":{"Status":"ERROR","Message":"","CoBorrower":[]},"LoanPaymentInformation":{"Status":"SUCCESS","Message":"","LoanPayment":{"PaymentMethod":"1","SavingAccount":"00001952109500","InstallmentBalance":"13200.00"}}}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
                response.setStatusCode(200);
                return response; 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    private class getOSC04MockupIncorrectBusType implements HttpCalloutMock {
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

    private class getOSC04MockupTimeout implements HttpCalloutMock {
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
    
    private class taxConsentMuckup implements HttpCalloutMock {
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
            } else if (req.getEndpoint().startsWith('callout:TaxCert_GetConsents')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                string en = SCSMessageAPIUtil.encryptMessageWithKey('{"status":{"code":"0000","description":"Success"},"customer":{"profile":{"cc_id":"0001956938","rm_id":"001100000000000000000009551865"},"tax_certificate_consents":[{"acct_ctl1":"0011","acct_ctl2":"0000","acct_ctl3":"0000","acct_ctl4":"0000","acct_nbr":"00000111111111","channel":"CRM","flag":"N","create_date":"2021-11-10T17:44:34","create_by":"12345","update_date":"2021-11-10T17:45:57","update_by":"upd-me"}]}}', '1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2');
                response.setBody(en);
                response.setStatusCode(200);
                return response; 
            } 
            else if (req.getEndpoint().startsWith('callout:get_dwh_key')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2');
                res.setStatusCode(200);
                return res;
            }
            else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    private class taxConsentCatchMuckup implements HttpCalloutMock {
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
            } else if (req.getEndpoint().startsWith('callout:TaxCert_GetConsents')) {
                CalloutException e = (CalloutException)CalloutException.class.newInstance();
                e.setMessage('web service down');
                throw e;
            } 
            else if (req.getEndpoint().startsWith('callout:get_dwh_key')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2');
                res.setStatusCode(200);
                return res;
            }
            else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    private class CreateUpdateTaxConsent implements HttpCalloutMock {
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
            } else if (req.getEndpoint().startsWith('callout:TaxCert_CreateConsents')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                String en = SCSMessageAPIUtil.encryptMessageWithKey('{"status":{"code":"0000","description":"Success"}}','1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2');
                response.setBody(en);
                response.setStatusCode(200);
                return response; 
            } else if (req.getEndpoint().startsWith('callout:TaxCert_UpdateConsents')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                String en = SCSMessageAPIUtil.encryptMessageWithKey('{"status":{"code":"0000","description":"Success"}}','1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2');
                response.setBody(en);
                response.setStatusCode(200);
                return response; 
            } else if (req.getEndpoint().startsWith('callout:get_dwh_key')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:OSC04')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"GetLoanAccountResponse":{"AcctInqRs":{"Status":{"StatusCode":"999","Severity":"Info","StatusDesc":"Error"},"RqUID":"fb754fa5-860a-4224-9764-2ffb6157fa21","LoanAcctId":{"AcctId":"001100010195000001955706724001","AcctType":"LOC","BankInfo":{"BankId":"11"}},"LnCustAcctId":{"SPName":"","CustPermId":"001100010195000000000001494435"},"UpDt":"2021-11-11T13:14:56.206+07:00","LastTrnDt":"2017-04-27","AcctBal":[{"BalType":"Principal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Outstanding","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Used","CurAmt":{"Amt":"1960000.00"}},{"BalType":"LnAvail","CurAmt":{"Amt":"0.00"}},{"BalType":"PayoffAmt","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Current","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"CurIntRecBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"OrigCommitmentBal","CurAmt":{"Amt":"1960000.00","CurCode":"THB"}},{"BalType":"CurCommitmentBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}}],"ExtAcctBal":[{"ExtBalType":"YTDInterest","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"LastYrInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Orig","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Unpaid/AccruedInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"YTDInterestAccrEC","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"TotalPastDue","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"}],"BankAcctRec":{"LoanAcctId":{"AcctId":"","AcctType":"","BankInfo":""},"BankAcctInfo":{"CurCode":"","PersonName":{"LastName":"","FirstName":"","LegalName":""},"ContactInfo":"","ProductId":"CBHA"}},"LOCAcctRec":{"LoanInfoCommon":{"AccountTitle":"MR.NAME00000001494435 LAST00000001494435","RemainingPmtCount":"181","RemainingPmtTerm":"0","RegPmtCurAmt":{"Amt":"13200.00","CurCode":"THB"},"LastPmtDt":"2017-04-27","LastPmtCurAmt":{"Amt":"231317.00","CurCode":"THB"},"PastDuePmtCount":"0","PastDueDt":"2017-05-31","NextPmtDt":"2017-05-31","NextPmtCurAmt":{"Amt":"0.00","CurCode":"THB"},"DaysPastDue":"0","CurrentIntRate":{"Rate":"4.0000000"},"OriginalIntRate":{"Rate":"0.0000001"},"RateType":"V","EffDt":"2010-05-25T12:00:00.000000-00:00","MatDt":"2032-05-31","LOCLimit":{"Amt":"0.00","CurCode":"THB"},"LateChargesCurAmt":{"Amt":"0.00","CurCode":"THB"},"CollateralInfo":{"CollateralCode":"000"},"SeqNum":"1","DebitAcct":"00001952109500","CurrentPmtCount":"264","FeesDueCurAmt":{"Amt":"0.00","CurCode":"THB"},"PerDiemCurAmt":{"Amt":"0.0000000","CurCode":"THB"},"PastDuePmtCounter":{"Type":"6-LifeTime","DelinquencyCategory":"151","PastDuePmtCount":"0"},"BillingMethod":"Statements","DraftAcctInfo":{"AcctId":"","USA.RTN":"0"},"ProcessDt":"2021-08-25","CustType":"Personal","AutoDebitMethod":"","OrigMatureDt":"2032-05-31","NxtDueDt":"2017-05-31","AccruedIntAmt1":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt2":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt3":{"Amt":"0.00","CurCode":"THB"},"TotalInt":{"Amt":"0.00","CurCode":"THB"},"NextPmtPrincipal":{"Amt":"0.00"},"NextPmtInterest":{"Amt":"0.00"},"AcctBal":{"BalType":"ToAccountBal","CurAmt":{"Amt":"0.00"}},"TransactionCount":"N"}},"BankAcctStatus":{"BankAcctStatusCode":"Closed"},"Language":"","Region":"","AuthOfficer":"00195","PersonInfo":[{"NameAddrType":"","FullName":"MR.NAME00000001494435 LAST00000001494435","ContactInfo":{"PostAddr":{"Addr1":"ที่อยู่บรรทัด100000001494435","Addr2":"ที่อยู่บรรทัด200000001494435","Addr3":"ที่อยู่บรรทัด300000001494435","City":"จ.ทดสอบ","StateProv":"  ","PostalCode":"1234567890","Country":"ไทย","AddrType":"Mailing"}},"TINInfo":{"TINType":"SSN","TaxId":"103552303","CertCode":"Certification Not on File"},"OEDCode":"All Other Individuals","OEDInstitution":"All Other Individuals"},{"NameAddrType":"","FullName":"","ContactInfo":{"PhoneNum":{"PhoneType":"Business","Phone":"000-00001494"}}}],"InsuranceInfo":{"InsRebateDueCurAmt":{"Amt":"0.00"}},"PartyAcctRel":{"PartyAcctRelType":"ENDORSER"}},"Status":{"StatusCode":"200","StatusDesc":"success"}},"GetLoanAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","LoanInformation":{"Status":"SUCCESS","Message":"","FIIdent":"0011000101950000","AccountNumber":"01955706724001","BusinessType":"","ProductCode":"CBHA","Tenor":"83","AccountStatus":"Closed","CreditLimit":"0.00","Outstanding":"0.00","OpenDate":"2010-05-25+07:00","ContractEndDate":"2032-05-31+07:00","PaymentDueDate":"2017-05-31+07:00","OtherConditions":"0.00","CampaignName":"83070","LastPaymentDate":"2017-04-27+07:00","CurrentTenor":"83","HasCoBorrower":"Yes"},"CoBorrowerInformation":{"Status":"SUCCESS","Message":"","CoBorrower":[{"RMID":"001100000000000000000001494435","Name":"NAME TEST","Relationship":"PRIJNT"},{"RMID":"001100000000000000000009864387","Name":"NAME TEST","Relationship":"SECJNT"}]},"LoanPaymentInformation":{"Status":"SUCCESS","Message":"","LoanPayment":{"PaymentMethod":"1","SavingAccount":"00001952109500","InstallmentBalance":"13200.00"}}}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
                response.setStatusCode(200);
                return response; 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    private class CreateUpdateTaxConsentCache implements HttpCalloutMock {
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
            } else if (req.getEndpoint().startsWith('callout:TaxCert_CreateConsents')) {
                CalloutException e = (CalloutException)CalloutException.class.newInstance();
                e.setMessage('Mockup timed out webservice');
                throw e;
            } else if (req.getEndpoint().startsWith('callout:TaxCert_UpdateConsents')) {
                CalloutException e = (CalloutException)CalloutException.class.newInstance();
                e.setMessage('Mockup timed out webservice');
                throw e; 
            } else if (req.getEndpoint().startsWith('callout:get_dwh_key')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:OSC04')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"GetLoanAccountResponse":{"AcctInqRs":{"Status":{"StatusCode":"999","Severity":"Info","StatusDesc":"Error"},"RqUID":"fb754fa5-860a-4224-9764-2ffb6157fa21","LoanAcctId":{"AcctId":"001100010195000001955706724001","AcctType":"LOC","BankInfo":{"BankId":"11"}},"LnCustAcctId":{"SPName":"","CustPermId":"001100010195000000000001494435"},"UpDt":"2021-11-11T13:14:56.206+07:00","LastTrnDt":"2017-04-27","AcctBal":[{"BalType":"Principal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Outstanding","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Used","CurAmt":{"Amt":"1960000.00"}},{"BalType":"LnAvail","CurAmt":{"Amt":"0.00"}},{"BalType":"PayoffAmt","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Current","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"CurIntRecBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"OrigCommitmentBal","CurAmt":{"Amt":"1960000.00","CurCode":"THB"}},{"BalType":"CurCommitmentBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}}],"ExtAcctBal":[{"ExtBalType":"YTDInterest","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"LastYrInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Orig","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Unpaid/AccruedInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"YTDInterestAccrEC","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"TotalPastDue","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"}],"BankAcctRec":{"LoanAcctId":{"AcctId":"","AcctType":"","BankInfo":""},"BankAcctInfo":{"CurCode":"","PersonName":{"LastName":"","FirstName":"","LegalName":""},"ContactInfo":"","ProductId":"CBHA"}},"LOCAcctRec":{"LoanInfoCommon":{"AccountTitle":"MR.NAME00000001494435 LAST00000001494435","RemainingPmtCount":"181","RemainingPmtTerm":"0","RegPmtCurAmt":{"Amt":"13200.00","CurCode":"THB"},"LastPmtDt":"2017-04-27","LastPmtCurAmt":{"Amt":"231317.00","CurCode":"THB"},"PastDuePmtCount":"0","PastDueDt":"2017-05-31","NextPmtDt":"2017-05-31","NextPmtCurAmt":{"Amt":"0.00","CurCode":"THB"},"DaysPastDue":"0","CurrentIntRate":{"Rate":"4.0000000"},"OriginalIntRate":{"Rate":"0.0000001"},"RateType":"V","EffDt":"2010-05-25T12:00:00.000000-00:00","MatDt":"2032-05-31","LOCLimit":{"Amt":"0.00","CurCode":"THB"},"LateChargesCurAmt":{"Amt":"0.00","CurCode":"THB"},"CollateralInfo":{"CollateralCode":"000"},"SeqNum":"1","DebitAcct":"00001952109500","CurrentPmtCount":"264","FeesDueCurAmt":{"Amt":"0.00","CurCode":"THB"},"PerDiemCurAmt":{"Amt":"0.0000000","CurCode":"THB"},"PastDuePmtCounter":{"Type":"6-LifeTime","DelinquencyCategory":"151","PastDuePmtCount":"0"},"BillingMethod":"Statements","DraftAcctInfo":{"AcctId":"","USA.RTN":"0"},"ProcessDt":"2021-08-25","CustType":"Personal","AutoDebitMethod":"","OrigMatureDt":"2032-05-31","NxtDueDt":"2017-05-31","AccruedIntAmt1":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt2":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt3":{"Amt":"0.00","CurCode":"THB"},"TotalInt":{"Amt":"0.00","CurCode":"THB"},"NextPmtPrincipal":{"Amt":"0.00"},"NextPmtInterest":{"Amt":"0.00"},"AcctBal":{"BalType":"ToAccountBal","CurAmt":{"Amt":"0.00"}},"TransactionCount":"N"}},"BankAcctStatus":{"BankAcctStatusCode":"Closed"},"Language":"","Region":"","AuthOfficer":"00195","PersonInfo":[{"NameAddrType":"","FullName":"MR.NAME00000001494435 LAST00000001494435","ContactInfo":{"PostAddr":{"Addr1":"ที่อยู่บรรทัด100000001494435","Addr2":"ที่อยู่บรรทัด200000001494435","Addr3":"ที่อยู่บรรทัด300000001494435","City":"จ.ทดสอบ","StateProv":"  ","PostalCode":"1234567890","Country":"ไทย","AddrType":"Mailing"}},"TINInfo":{"TINType":"SSN","TaxId":"103552303","CertCode":"Certification Not on File"},"OEDCode":"All Other Individuals","OEDInstitution":"All Other Individuals"},{"NameAddrType":"","FullName":"","ContactInfo":{"PhoneNum":{"PhoneType":"Business","Phone":"000-00001494"}}}],"InsuranceInfo":{"InsRebateDueCurAmt":{"Amt":"0.00"}},"PartyAcctRel":{"PartyAcctRelType":"ENDORSER"}},"Status":{"StatusCode":"200","StatusDesc":"success"}},"GetLoanAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","LoanInformation":{"Status":"SUCCESS","Message":"","FIIdent":"0011000101950000","AccountNumber":"01955706724001","BusinessType":"","ProductCode":"CBHA","Tenor":"83","AccountStatus":"Closed","CreditLimit":"0.00","Outstanding":"0.00","OpenDate":"2010-05-25+07:00","ContractEndDate":"2032-05-31+07:00","PaymentDueDate":"2017-05-31+07:00","OtherConditions":"0.00","CampaignName":"83070","LastPaymentDate":"2017-04-27+07:00","CurrentTenor":"83","HasCoBorrower":"Yes"},"CoBorrowerInformation":{"Status":"SUCCESS","Message":"","CoBorrower":[{"RMID":"001100000000000000000001494435","Name":"NAME TEST","Relationship":"PRIJNT"},{"RMID":"001100000000000000000009864387","Name":"NAME TEST","Relationship":"SECJNT"}]},"LoanPaymentInformation":{"Status":"SUCCESS","Message":"","LoanPayment":{"PaymentMethod":"1","SavingAccount":"00001952109500","InstallmentBalance":"13200.00"}}}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
                response.setStatusCode(200);
                return response; 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    private class CreateUpdateTaxConsentFail implements HttpCalloutMock {
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
            } else if (req.getEndpoint().startsWith('callout:TaxCert_CreateConsents')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                String en = SCSMessageAPIUtil.encryptMessageWithKey('{"status":{"code":"9999","description":"ERROR"}}','1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2');
                response.setBody(en);
                response.setStatusCode(200);
                return response; 
            } else if (req.getEndpoint().startsWith('callout:TaxCert_UpdateConsents')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                String en = SCSMessageAPIUtil.encryptMessageWithKey('{"status":{"code":"9999","description":"ERROR"}}','1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2');
                response.setBody(en);
                response.setStatusCode(200);
                return response; 
            } else if (req.getEndpoint().startsWith('callout:get_dwh_key')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:OSC04')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"GetLoanAccountResponse":{"AcctInqRs":{"Status":{"StatusCode":"999","Severity":"Info","StatusDesc":"Error"},"RqUID":"fb754fa5-860a-4224-9764-2ffb6157fa21","LoanAcctId":{"AcctId":"001100010195000001955706724001","AcctType":"LOC","BankInfo":{"BankId":"11"}},"LnCustAcctId":{"SPName":"","CustPermId":"001100010195000000000001494435"},"UpDt":"2021-11-11T13:14:56.206+07:00","LastTrnDt":"2017-04-27","AcctBal":[{"BalType":"Principal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Outstanding","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Used","CurAmt":{"Amt":"1960000.00"}},{"BalType":"LnAvail","CurAmt":{"Amt":"0.00"}},{"BalType":"PayoffAmt","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"Current","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"CurIntRecBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}},{"BalType":"OrigCommitmentBal","CurAmt":{"Amt":"1960000.00","CurCode":"THB"}},{"BalType":"CurCommitmentBal","CurAmt":{"Amt":"0.00","CurCode":"THB"}}],"ExtAcctBal":[{"ExtBalType":"YTDInterest","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"LastYrInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Orig","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"Unpaid/AccruedInt","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"YTDInterestAccrEC","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"},{"ExtBalType":"TotalPastDue","CurAmt":{"Amt":"0.00","CurCode":"THB"},"EffDt":"2021-11-11T13:14:56.204000+07:00"}],"BankAcctRec":{"LoanAcctId":{"AcctId":"","AcctType":"","BankInfo":""},"BankAcctInfo":{"CurCode":"","PersonName":{"LastName":"","FirstName":"","LegalName":""},"ContactInfo":"","ProductId":"CBHA"}},"LOCAcctRec":{"LoanInfoCommon":{"AccountTitle":"MR.NAME00000001494435 LAST00000001494435","RemainingPmtCount":"181","RemainingPmtTerm":"0","RegPmtCurAmt":{"Amt":"13200.00","CurCode":"THB"},"LastPmtDt":"2017-04-27","LastPmtCurAmt":{"Amt":"231317.00","CurCode":"THB"},"PastDuePmtCount":"0","PastDueDt":"2017-05-31","NextPmtDt":"2017-05-31","NextPmtCurAmt":{"Amt":"0.00","CurCode":"THB"},"DaysPastDue":"0","CurrentIntRate":{"Rate":"4.0000000"},"OriginalIntRate":{"Rate":"0.0000001"},"RateType":"V","EffDt":"2010-05-25T12:00:00.000000-00:00","MatDt":"2032-05-31","LOCLimit":{"Amt":"0.00","CurCode":"THB"},"LateChargesCurAmt":{"Amt":"0.00","CurCode":"THB"},"CollateralInfo":{"CollateralCode":"000"},"SeqNum":"1","DebitAcct":"00001952109500","CurrentPmtCount":"264","FeesDueCurAmt":{"Amt":"0.00","CurCode":"THB"},"PerDiemCurAmt":{"Amt":"0.0000000","CurCode":"THB"},"PastDuePmtCounter":{"Type":"6-LifeTime","DelinquencyCategory":"151","PastDuePmtCount":"0"},"BillingMethod":"Statements","DraftAcctInfo":{"AcctId":"","USA.RTN":"0"},"ProcessDt":"2021-08-25","CustType":"Personal","AutoDebitMethod":"","OrigMatureDt":"2032-05-31","NxtDueDt":"2017-05-31","AccruedIntAmt1":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt2":{"Amt":"0.00","CurCode":"THB"},"AccruedIntAmt3":{"Amt":"0.00","CurCode":"THB"},"TotalInt":{"Amt":"0.00","CurCode":"THB"},"NextPmtPrincipal":{"Amt":"0.00"},"NextPmtInterest":{"Amt":"0.00"},"AcctBal":{"BalType":"ToAccountBal","CurAmt":{"Amt":"0.00"}},"TransactionCount":"N"}},"BankAcctStatus":{"BankAcctStatusCode":"Closed"},"Language":"","Region":"","AuthOfficer":"00195","PersonInfo":[{"NameAddrType":"","FullName":"MR.NAME00000001494435 LAST00000001494435","ContactInfo":{"PostAddr":{"Addr1":"ที่อยู่บรรทัด100000001494435","Addr2":"ที่อยู่บรรทัด200000001494435","Addr3":"ที่อยู่บรรทัด300000001494435","City":"จ.ทดสอบ","StateProv":"  ","PostalCode":"1234567890","Country":"ไทย","AddrType":"Mailing"}},"TINInfo":{"TINType":"SSN","TaxId":"103552303","CertCode":"Certification Not on File"},"OEDCode":"All Other Individuals","OEDInstitution":"All Other Individuals"},{"NameAddrType":"","FullName":"","ContactInfo":{"PhoneNum":{"PhoneType":"Business","Phone":"000-00001494"}}}],"InsuranceInfo":{"InsRebateDueCurAmt":{"Amt":"0.00"}},"PartyAcctRel":{"PartyAcctRelType":"ENDORSER"}},"Status":{"StatusCode":"200","StatusDesc":"success"}},"GetLoanAccountDetailResponse":{"Result":{"Status":"SUCCESS","Message":"","LoanInformation":{"Status":"SUCCESS","Message":"","FIIdent":"0011000101950000","AccountNumber":"01955706724001","BusinessType":"","ProductCode":"CBHA","Tenor":"83","AccountStatus":"Closed","CreditLimit":"0.00","Outstanding":"0.00","OpenDate":"2010-05-25+07:00","ContractEndDate":"2032-05-31+07:00","PaymentDueDate":"2017-05-31+07:00","OtherConditions":"0.00","CampaignName":"83070","LastPaymentDate":"2017-04-27+07:00","CurrentTenor":"83","HasCoBorrower":"Yes"},"CoBorrowerInformation":{"Status":"SUCCESS","Message":"","CoBorrower":[{"RMID":"001100000000000000000001494435","Name":"NAME TEST","Relationship":"PRIJNT"},{"RMID":"001100000000000000000009864387","Name":"NAME TEST","Relationship":"SECJNT"}]},"LoanPaymentInformation":{"Status":"SUCCESS","Message":"","LoanPayment":{"PaymentMethod":"1","SavingAccount":"00001952109500","InstallmentBalance":"13200.00"}}}},"Status":{"StatusCode":"200","StatusDesc":"success"}}');
                response.setStatusCode(200);
                return response; 
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    private class CreateUpdateTaxConsentOSC04catch implements HttpCalloutMock {
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
            } else if (req.getEndpoint().startsWith('callout:get_dwh_key')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().startsWith('callout:TaxCert_CreateConsents')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                String en = SCSMessageAPIUtil.encryptMessageWithKey('{"status":{"code":"0000","description":"Success"}}','1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2');
                response.setBody(en);
                response.setStatusCode(200);
                return response; 
            } else if (req.getEndpoint().startsWith('callout:TaxCert_UpdateConsents')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                String en = SCSMessageAPIUtil.encryptMessageWithKey('{"status":{"code":"0000","description":"Success"}}','1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2');
                response.setBody(en);
                response.setStatusCode(200);
                return response; 
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

    @isTest 
    static void testGetLoanInformationData() {
        Test.setMock(HttpCalloutMock.class, new getOSC04Mockup());

        String body = '{"GetLoanAccountRequest":{"RMID":"","FIIdent":"","AccountNumber":"01955706724001","AccountType":"com.fnis.xes.AL","ProductType":""}}';

        Test.startTest();
        taxCertificateController.loanDetailWrapperClass result = taxCertificateController.getLoanInformationData(body, '001100000000000000000000051187');
        System.assertEquals('0011000101950000', result.fiident);
        System.assertEquals('MOCKUPPRDJA', result.prodName);
        Test.stopTest();
    }
    
    @isTest 
    static void testGetLoanInformationDataErrorNullAcctNo() {
        Test.setMock(HttpCalloutMock.class, new getOSC04MockupAcctNoBlank());

        String body = '{"GetLoanAccountRequest":{"RMID":"","FIIdent":"","AccountNumber":"01955706724001","AccountType":"com.fnis.xes.AL","ProductType":""}}';

        Test.startTest();
        taxCertificateController.loanDetailWrapperClass result = taxCertificateController.getLoanInformationData(body, '001100000000000000000000051187');
        System.assertEquals(null, result.accountNumber);
        System.assertEquals(null, result.businessType);
        System.assertEquals(null, result.coborrow);
        System.assertEquals(null, result.creditLimit);
        System.assertEquals(null, result.fiident);
        System.assertEquals(null, result.openDate);
        System.assertEquals(null, result.prodName);
        System.assertEquals(null, result.statusDesc04);
        Test.stopTest();
    }

    @isTest 
    static void testGetLoanInformationDataOSC04SatausDescError() {
        Test.setMock(HttpCalloutMock.class, new getOSC04MockupStatusDescError());

        String body = '{"GetLoanAccountRequest":{"RMID":"","FIIdent":"","AccountNumber":"01955706724001","AccountType":"com.fnis.xes.AL","ProductType":""}}';

        Test.startTest();
        taxCertificateController.loanDetailWrapperClass result = taxCertificateController.getLoanInformationData(body, '001100000000000000000000051187');
        System.assertEquals('ERROR', result.statusDesc04);
        Test.stopTest();
    }
    
    @isTest
    static void testGetLoanInformationDataOSC04AcctInqSatausDescError() {
        Test.setMock(HttpCalloutMock.class, new getOSC04MockupAcctInqError());
        
        String body = '{"GetLoanAccountRequest":{"RMID":"","FIIdent":"","AccountNumber":"01955706724001","AccountType":"com.fnis.xes.AL","ProductType":""}}';
        
        Test.startTest();
        taxCertificateController.loanDetailWrapperClass result = taxCertificateController.getLoanInformationData(body, '001100000000000000000000051187');
        System.assertEquals('Account not found', result.statusDesc04);
        Test.stopTest();
    }

    @isTest
    static void testGetLoanInformationDataOSC04CoBorrowerInformationError() {
        Test.setMock(HttpCalloutMock.class, new getOSC04MockupCoBorrowerInformationError());
        
        String body = '{"GetLoanAccountRequest":{"RMID":"","FIIdent":"","AccountNumber":"01955706724001","AccountType":"com.fnis.xes.AL","ProductType":""}}';
        
        Test.startTest();
        taxCertificateController.loanDetailWrapperClass result = taxCertificateController.getLoanInformationData(body, '001100000000000000000000051187');
        System.assertEquals('Account not found', result.statusDesc04);
        Test.stopTest();
    }

    @isTest
    static void testGetLoanInformationDataOSC04IncorrectBusType() {
        Test.setMock(HttpCalloutMock.class, new getOSC04MockupIncorrectBusType());
        
        String body = '{"GetLoanAccountRequest":{"RMID":"","FIIdent":"","AccountNumber":"01955706724001","AccountType":"com.fnis.xes.AL","ProductType":""}}';
        
        Test.startTest();
        taxCertificateController.loanDetailWrapperClass result = taxCertificateController.getLoanInformationData(body, '001100000000000000000000051187');
        System.assertEquals('Account not found', result.statusDesc04);
        Test.stopTest();
    }

    @isTest
    static void testGetLoanInformationDataOSC04Timeout() {
        Test.setMock(HttpCalloutMock.class, new getOSC04MockupTimeout());
        
        String body = '{"GetLoanAccountRequest":{"RMID":"","FIIdent":"","AccountNumber":"01955706724001","AccountType":"com.fnis.xes.AL","ProductType":""}}';
        
        Test.startTest();
        taxCertificateController.loanDetailWrapperClass result = taxCertificateController.getLoanInformationData(body, '001100000000000000000000051187');
        System.assertEquals('TIMEOUT', result.statusDesc04);
        Test.stopTest();
    }

    @isTest 
    static void testGetConsent() {
        Test.setMock(HttpCalloutMock.class, new taxConsentMuckup());
        List<Account> acctlst = RTL_TestUtility.createAccounts(1, false);
        acctlst.get(0).Name = 'AccoutName test';
        acctlst.get(0).TMB_Customer_ID_PE__c = '001100000000000000000001494435';
        insert acctlst;

        Test.startTest();
        String decryptedBody = taxCertificateController.getTaxConsentDataByRMID('001100000000000000000001494435');
        String StatusDesc = decryptedBody != null && String.isNotEmpty(decryptedBody) ? String.valueOf(getResult('status.description', JSON.deserializeUntyped(decryptedBody))) : '';
        String StatusCode = decryptedBody != null && String.isNotEmpty(decryptedBody) ? String.valueOf(getResult('status.code', JSON.deserializeUntyped(decryptedBody))) : '';
        Test.stopTest();
        
        System.assertEquals('Success', StatusDesc);
        System.assertEquals('0000', StatusCode);
    }
    
    @isTest 
    static void testGetTaxConsentDataByRMIDcatch() {
        Test.setMock(HttpCalloutMock.class, new taxConsentCatchMuckup());
        
        Test.startTest();
        try {
            String result = taxCertificateController.getTaxConsentDataByRMID('');
        } catch (Exception e) {
            System.assertEquals('web service down', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest 
    static void testUpdateCreateConsent() {
        Test.setMock(HttpCalloutMock.class, new CreateUpdateTaxConsent());

        Test.startTest();
        String decryptedBody = taxCertificateController.CreateUpdateTaxConsent('001100000000000000000000051187', '123', 'Y', '1234567891234567', 'TaxCert_CreateConsents');
        Test.stopTest();
    }

    @isTest 
    static void testUpdateCreateConsentNofiident() {
        Test.setMock(HttpCalloutMock.class, new CreateUpdateTaxConsent());

        Test.startTest();
        String decryptedBody = taxCertificateController.CreateUpdateTaxConsent('001100000000000000000000051187', '123', 'Y', '', 'TaxCert_UpdateConsents');
        Test.stopTest();

        System.assertEquals(decryptedBody, 'true');
    }
    
    @isTest 
    static void testUpdateUpdateConsentFailAndNofiident() {
        Test.setMock(HttpCalloutMock.class, new CreateUpdateTaxConsentFail());

        Test.startTest();
        String decryptedBody = taxCertificateController.CreateUpdateTaxConsent('001100000000000000000000051187', '123', 'Y', '', 'TaxCert_UpdateConsents');
        Test.stopTest();

        System.assertEquals(decryptedBody, 'false');
    }
    
    @isTest 
    static void testUpdateUpdateConsentCatchAndNofiident() {
        Test.setMock(HttpCalloutMock.class, new CreateUpdateTaxConsentCache());

        Test.startTest();
        String decryptedBody = taxCertificateController.CreateUpdateTaxConsent('001100000000000000000000051187', '123', 'Y', '', 'TaxCert_UpdateConsents');
        Test.stopTest();

        System.assertEquals('TIMEOUT', decryptedBody);
    }
    
    @isTest 
    static void testUpdateCreateConsentFiIdent16Error() {
        Test.setMock(HttpCalloutMock.class, new CreateUpdateTaxConsent());
        Test.startTest();
        try{
            String decryptedBody = taxCertificateController.CreateUpdateTaxConsent('001100000000000000000000051187', '123', 'Y', '123', 'TaxCert_CreateConsents');
        }catch(Exception e){
            System.assertEquals('Error get fiident fail.', e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest 
    static void testUpdateCreateConsentGetOSC04Error() {
        Test.setMock(HttpCalloutMock.class, new CreateUpdateTaxConsentOSC04catch());
        
        Test.startTest();
        try {
            String decryptedBody = taxCertificateController.CreateUpdateTaxConsent('001100000000000000000000051187', '123', 'Y', '', 'TaxCert_UpdateConsents');
        } catch (Exception e) {
            System.assertEquals('Mockup timed out webservice', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest 
    static void testOtherCase() {
        User currentUser = [SELECT Id, Name, Employee_ID__c, ProfileId, Profile.Name FROM User WHERE Id = :userInfo.getUserId()];

        Test.startTest();
        String url = taxCertificateController.getServiceName('ABCDEFG');
        string getWatermarkHTML = taxCertificateController.getWatermarkHTML();
        Boolean getSearchBtnPermission = taxCertificateController.getSearchBtnPermission();
        
        System.assertEquals('', url);  
        System.assertEquals(currentUser.Employee_ID__c, getWatermarkHTML);
        // System.assertEquals(true, getSearchBtnPermission);
        Test.stopTest();
    }
}