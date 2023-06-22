@IsTest
public with sharing class CommercialAutoLoanControllerTest {
    private static String encryptKey {
        get {
            return '208f6c8723b80c36fefc349575764dd14baf52d950a98c101034c403b1172b65';
        }
    }

    private static String tokenKey {
        get {
            return 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBfbmFtZSI6IkNSTSBTYWxlcyBNYW5hZ2VtZW50IFN5c3RlbXMvU2FsZXNGb3JjZSAtIFNJVCIsInNjb3BlIjpbInJlYWQiLCJ3cml0ZSJdLCJleHAiOjE2MDUxMDQzOTgsImFwcF9pZCI6IkEwMjkxIiwianRpIjoiMmMxMTY2YzMtNjczZi00OTcyLTk0MTYtM2FiYWExZDQ2NmJjIiwiY2xpZW50X2lkIjoiZjc5Njk4YTc5OWE0ODVlNDBhMGVkN2RjNDNmNDRmMTcifQ.DTyU2ZhgI94NZQo8OFLMYg86EBlSfKPnNKoB6IgJS0wJinumHjiMZx34TCooRE_QUtRu6VSfuQUPGPTmInuycyGrzqJren0ZrmwrbBoc-Dxg9IfNZcXfUVGUv7Dn2Bz4x9Vj3wFNt2Vz7J8CXkQo50664yDqRFDUD1y_ZF0uS_bYEenTFY06vj5LPzvygGyvCGJUyikeajSdcYv6KjdG8VxAjXUr-1V88Th9i3RAQXm3PzExfwk55duJ59zw3f4tuJuf084IJS1nMC--AD24V1B1vdFLyLqYekOurRea6VXTi4WAuAtSCjvXtXfywlvud9CUY1Jdnmn23t3yffXHYQ';
        }
    }

    @TestSetup
    static void makeData(){
        TestUtils.createAppConfig();
        AppConfig__c appConfig = AppConfig__c.getValues('runtrigger');
        appConfig.Value__c = 'true';
        update appConfig;

        Account tempAccount = new Account(
            Name = 'First_name_PE__c Last_name_PE__c',
            Email_Address_PE__c = 'test@test.com.al',
            First_name_PE__c = 'First_name_PE__c',
            Last_name_PE__c = 'Last_name_PE__c',
            ID_Type_PE__c = 'Alien ID',
            ID_Number_PE__c = '111111222222',
            Mobile_Number_PE__c = 'Mobile_Number_PE__c',
            TMB_Customer_ID_PE__c = '001100000000000000000014144927',
            Primary_Address_Line_2_PE__c = 'Primary_Address_Line_2_PE__c',
            Primary_Address_Line_3_PE__c = 'Primary_Address_Line_3_PE__c',
            Zip_Code_Primary_PE__c = '00000',
            Province_Primary_PE__c = 'Province_Primary_PE__c',
            RecordTypeId = Account.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Retail_Prospect').getRecordTypeId()
        );
        insert tempAccount;
    }

    private static String testCalloutservice(String body, Object state) {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
        Continuation conti = (Continuation)CommercialAutoLoanController.getProduct(
            (String)AbstractCoreClass.getResult('endpoint', state),
            'callback', 
            JSON.serialize(new Map<String, Object>{
                'test' => 'test'
            }), 
            'EC', 
            state
        );

        Map<String, HttpRequest> requests = conti.getRequests();
        HttpRequest request = requests.values().iterator().next();
        String requestLabel = requests.keyset().iterator().next();

        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody(body == '' ? body : (String)SCSMessageAPIUtil.encryptMessageWithKey(
            body,
            encryptKey
        ));
        Test.setContinuationResponse(requestLabel, response);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
        return requestLabel;
    }

    @IsTest
    static void testInitialize(){
        Test.startTest();
        String accountId = [SELECT Id FROM Account LIMIT 1].Id;
        CommercialAutoLoanController.getIsALGuarantorMdt();
        CommercialAutoLoanController.getALDXWFMdt();
        CommercialAutoLoanController.getAppConfigMdtByKey('CoreHP_Company');
        CommercialAutoLoanController.getAccessibleCusHold(accountId);
        Test.stopTest();
    }
    @IsTest
    static void testCalloutserviceException(){
        Test.startTest();
        try {
            Continuation conti = (Continuation)CommercialAutoLoanController.getProduct(
                'endpoint', 
                'callback', 
                JSON.serialize(new Map<String, Object>{
                    'test' => 'test'
                }), 
                'service', 
                null
            );
        } catch (Exception e) {}
        Test.stopTest();
    }

    @IsTest
    static void testCalloutserviceGuarantorException(){
        Test.startTest();
        
        Object state = new Map<String, Object>{
            'startDateTime' => Datetime.now(),
            'service' => 'EC',
            'tmbCustId' => 'tmbCustId',
            'endpoint' => 'callout:endpoint',
            'uuid' => new Uuid().getValue()
        };
        String requestLabel = testCalloutservice('', state);
        CommercialAutoLoanController.callbackGuarantor(new List<String>{requestLabel}, state);
        try { CommercialAutoLoanController.callbackGuarantor(new List<String>{requestLabel}, state); } catch (Exception e) {}

        Test.stopTest();
    }
    @IsTest
    static void testCalloutserviceGuarantor(){
        Test.startTest();

        Object state = new Map<String, Object>{
            'startDateTime' => Datetime.now(),
            'service' => 'EC',
            'tmbCustId' => 'tmbCustId',
            'endpoint' => 'callout:endpoint',
            'uuid' => new Uuid().getValue()
        };
        CommercialAutoLoanController.callbackGuarantor(
            new List<String>{ 
                testCalloutservice(
                    '{"status":{"code":"0000","description":"Success"},"guarantors":[{"c_name":"hhhh","id_no":"4552466","id_birth_date":"24/12/1997"},{"c_name":"iiiiii","id_no":"6432857","id_birth_date":"14/2/1999"},{"c_name":"pppp","id_no":"4552466","id_birth_date":"24/12/1997"},{"c_name":"nnnnn","id_no":"4552466","id_birth_date":"24/12/1997"}]}',
                    state
                )
            }, state);
            
        Test.stopTest();
    }

    @IsTest
    static void testCalloutserviceCYBException(){
        Test.startTest();
        Object state = new Map<String, Object>{
            'startDateTime' => Datetime.now(),
            'service' => 'EC',
            'tmbCustId' => 'tmbCustId',
            'endpoint' => 'callout:endpoint',
            'uuid' => new Uuid().getValue()
        };

        String requestLabel = testCalloutservice('', state);
        CommercialAutoLoanController.callbackCYBDetail(new List<String>{requestLabel}, state);
        try { CommercialAutoLoanController.callbackCYBDetail(new List<String>{requestLabel}, state); } catch (Exception e) {}
        Test.stopTest();
    }
    @IsTest
    static void testCalloutserviceCYB(){
        Test.startTest();
        Object state = new Map<String, Object>{
            'startDateTime' => Datetime.now(),
            'service' => 'EC',
            'tmbCustId' => 'tmbCustId',
            'endpoint' => 'callout:endpoint',
            'uuid' => new Uuid().getValue()
        };
        CommercialAutoLoanController.callbackCYBDetail(
            new List<String>{ 
                testCalloutservice(
                    '{"errors":[{"namespace":"DWH","message":"ORA-00942: table or view does not exist (java.sql.SQLSyntaxErrorException).","code":"5000"}],"status":{"code":"0000","description":"Success"},"loan_account":{"account_no":"0195490032901","account_type":"LOC","info":{"account_title":"MR.NAME00000000000001 LAST00000000000001","customer_type":"Personal"},"payment_info":{"last_payment_date":null,"past_due_date":"2020-03-31","next_due_date":"2020-05-31","next_payment_principal_amount":10100,"next_payment_interest_amount":0,"next_payment_date":"2020-05-31","past_due_payment_count":2,"total_past_due_amount":20100,"current_loan_amount":10000,"last_payment_amount":0,"next_payment_amount":10100,"late_charges_amount":7569.86,"fee_due_amount":200,"interest":{"current_rate":"6.2500000","original_rate":"0.0000001"}},"balance_info":{"balances":{"account_limit":{"amount":1000000,"currency":"THB"},"principal":{"amount":1000000,"currency":"THB"},"outstanding":{"amount":1000000,"currency":"THB"},"unpaid_accrued_interest":{"amount":11910.95,"currency":"THB"},"current_commitment":{"amount":1000000,"currency":"THB"}},"od":{"od_limit_amount":0}},"personal_info":{"full_name":"MR.NAME00000000000001 LAST00000000000001","contact_info":{"address1":"ที่อยู่บรรทัด100000000000001","address2":"ที่อยู่บรรทัด200000000000001","address3":"","city":"จ.ทดสอบ","postal_code":"1234567890","country":"US","address_type":"Mailing"}}}}',
                    state
                )
            }, state);
        Test.stopTest();
    }
    @IsTest
    static void testCalloutserviceCoreHPListException(){
        Test.startTest();
        Object state = new Map<String, Object>{
            'startDateTime' => Datetime.now(),
            'service' => 'CoreHP',
            'tmbCustId' => 'tmbCustId',
            'endpoint' => 'callout:endpoint',
            'uuid' => new Uuid().getValue()
        };

        String requestLabel = testCalloutservice('', state);
        CommercialAutoLoanController.callbackHpFleetHpList(new List<String>{requestLabel}, state);
        try { CommercialAutoLoanController.callbackHpFleetHpList(new List<String>{requestLabel}, state); } catch (Exception e) {}
        Test.stopTest();
    }
    @IsTest
    static void testCalloutserviceCoreHPList(){
        Test.startTest();
        Object state = new Map<String, Object>{
            'startDateTime' => Datetime.now(),
            'service' => 'CoreHP',
            'tmbCustId' => 'tmbCustId',
            'endpoint' => 'callout:endpoint',
            'uuid' => new Uuid().getValue()
        };
        CommercialAutoLoanController.callbackHpFleetHpList(
            new List<String>{ 
                testCalloutservice(
                    '{"OUTPUT": [{"ContractNo" : "242016300001","ContractStatusCode" : "10","ContractStatusName" : "ลูกหนี้เช่าซื้อปกติ","HPTotalAmount" : "900000.00","HPNetAmount" : "837000.00","OutstandingAmount" : "800000.00","Installment" : "15000.00","NumberOfInstallmentBalance" : "32","TotalInstallments" : "48","CurrentOfInstallments" : "16","OverdueNo" : "0","OverdueAmount" : "0","Channel" : "Hub"}],"RES": {"RESPONSECODE": "HP001","RESPONSEMESSAGE": "Success"}}',
                    state
                )
            }, state);
        Test.stopTest();
    }
    @IsTest
    static void testCalloutserviceCoreHPDetailException(){
        Test.startTest();
        Object state = new Map<String, Object>{
            'startDateTime' => Datetime.now(),
            'service' => 'CoreHP',
            'tmbCustId' => 'tmbCustId',
            'endpoint' => 'callout:endpoint',
            'uuid' => new Uuid().getValue()
        };

        String requestLabel = testCalloutservice('', state);
        CommercialAutoLoanController.callbackHpFleetHpDetail(new List<String>{requestLabel}, state);
        try { CommercialAutoLoanController.callbackHpFleetHpDetail(new List<String>{requestLabel}, state); } catch (Exception e) {}
        Test.stopTest();
    }
    @IsTest
    static void testCalloutserviceCoreHPDetail(){
        Test.startTest();
        Object state = new Map<String, Object>{
            'startDateTime' => Datetime.now(),
            'service' => 'CoreHP',
            'tmbCustId' => 'tmbCustId',
            'endpoint' => 'callout:endpoint',
            'uuid' => new Uuid().getValue()
        };
        CommercialAutoLoanController.callbackHpFleetHpDetail(
            new List<String>{ 
                testCalloutservice(
                    '{"OUTPUT":[ { "ContractNo":"242016300001", "CustomerCode":"1234567", "ContractDate10":"01/01/2563", "DealerName":"บมจ. มาสด้า", "CarpriceAmt":"1000000.00", "HPTotalAmount":"1050000.00", "InstallmentAmount":"1000.00", "InterestedRate":"5.50", "TotalInstallments":"72", "CurrentOfInstallments":"16", "NumberOfInstallmentBalance":"56", "CarBrandName":"Mazda", "CarModel":"CX-5", "CarColorName":"ขาว", "ProductCarType":"รถใหม่", "FinancialAmount":"900,000.00", "OverdueAmount":"0.00", "PenaltyAmount":"0.00", "OverdueNo":"0", "HubOwnerName":"23-รัชดา", "ProductCode":"New, Use, CYC", "LastDueDate":"09/11/2568", "MarketingOfficerName":"น.ส. สุขใจ ยินดี", "CarDownAmt":"200,000.00", "DueDay":"09", "PaymentMethodDesc":"Bill Paymant", "FirstInstallmentDate10":"09/12/2562", "OutstandingAmount":"800,000.00", "ContractStatusCode":"10", "ContractStatusName":"ลูกหนี้เช่าซื้อปกติ", "CarYear":"2019", "CarTypeDesc":"เก๋ง 2 ตอน", "CarRegno":"กก5290", "CarRegProv":"กรุงเทพฯ", "CarChasis":"XXXXXXXXXXXXXXXXXXXXXXXX", "CarEngno":"PE88888888888", "CarEngineSize":"1998", "GuarantorName1":"นายพล มูลมารถ1", "GuarantorBD1":"2/12/2538", "GuarantorIDNo1":"1421463", "GuarantorName2":"นายพล มูลมารถ2", "GuarantorBD2":"2/12/2538", "GuarantorIDNo2":"1421461", "GuarantorName3":"นายพล มูลมารถ3", "GuarantorBD3":"2/12/2538", "GuarantorIDNo3":"1421468", "GuarantorName4":"นายพล มูลมารถ4", "GuarantorBD4":"2/12/2538", "GuarantorIDNo4":"1421469" } ], "RES":{ "RESPONSECODE":"HP001", "RESPONSEMESSAGE":"Success" }}',
                    state
                )
            }, state);
        Test.stopTest();
    }
    @IsTest
    static void testCalloutserviceFloorPlanDetailException(){
        Test.startTest();
        Object state = new Map<String, Object>{
            'startDateTime' => Datetime.now(),
            'service' => 'FloorPlan',
            'tmbCustId' => 'tmbCustId',
            'endpoint' => 'callout:endpoint',
            'uuid' => new Uuid().getValue()
        };

        String requestLabel = testCalloutservice('', state);
        CommercialAutoLoanController.callbackFloorPlanDetail(new List<String>{requestLabel}, state);
        try { CommercialAutoLoanController.callbackFloorPlanDetail(new List<String>{requestLabel}, state); } catch (Exception e) {}
        Test.stopTest();
    }
    @IsTest
    static void testCalloutserviceFloorPlanDetail(){
        Test.startTest();
        Object state = new Map<String, Object>{
            'startDateTime' => Datetime.now(),
            'service' => 'FloorPlan',
            'tmbCustId' => 'tmbCustId',
            'endpoint' => 'callout:endpoint?test=test',
            'uuid' => new Uuid().getValue()
        };
        CommercialAutoLoanController.callbackFloorPlanDetail(
            new List<String>{ 
                testCalloutservice(
                    '{"fp_ca_no":"001363900563","os_balance":5447140,"details":[{"eff_date":"20/03/2020","eff_date_th":"20/03/2563","fp_ts_no":"4446300717","chassis_no":"MMM142EL0LH633982","engine_no":"LKH G200291138","license_no":"","make_desc":"CHEVROLET","prin_amt":516075,"loan_day":0,"os_balance":516075},{"eff_date":"20/03/2020","eff_date_th":"20/03/2563","fp_ts_no":"4446355555","chassis_no":"MMM142EL0LH633982","engine_no":"LKH G200291138","license_no":"","make_desc":"CHEVROLET","prin_amt":516075,"loan_day":0,"os_balance":516075},{"eff_date":"20/04/2020","eff_date_th":"20/04/2563","fp_ts_no":"4236355666","chassis_no":"MMM142EL0LH677982","engine_no":"LKH G200291138","license_no":"","make_desc":"CHEVROLET","prin_amt":300075,"loan_day":0,"os_balance":102475}],"total_record":20,"paging":{"count":2,"limit":100,"offset":0,"total":2},"fp_response":{"code":200,"description":"Success"}}',
                    state
                )
            }, state);
        Test.stopTest();
    }
    @IsTest
    static void testCalloutserviceFloorPlanListException(){
        Test.startTest();
        Object state = new Map<String, Object>{
            'startDateTime' => Datetime.now(),
            'service' => 'FloorPlan',
            'tmbCustId' => 'tmbCustId',
            'endpoint' => 'callout:endpoint',
            'uuid' => new Uuid().getValue()
        };

        String requestLabel = testCalloutservice('', state);
        CommercialAutoLoanController.callbackFloorPlanList(new List<String>{requestLabel}, state);
        try { CommercialAutoLoanController.callbackFloorPlanList(new List<String>{requestLabel}, state); } catch (Exception e) {}
        Test.stopTest();
    }
    @IsTest
    static void testCalloutserviceFloorPlanList(){
        Test.startTest();
        Object state = new Map<String, Object>{
            'startDateTime' => Datetime.now(),
            'service' => 'FloorPlan',
            'tmbCustId' => 'tmbCustId',
            'endpoint' => 'callout:endpoint?test=test',
            'uuid' => new Uuid().getValue()
        };
        CommercialAutoLoanController.callbackFloorPlanList(
            new List<String>{ 
                testCalloutservice(
                    '{"details":[{"fp_ca_no":"001358500133","car_type_desc":"New Car","approve_date":"20/03/2017","approve_date_th":"20/03/2560","exp_date":"31/10/2018","exp_date_th":"31/10/2561","status":"Active","credit_limit":70000000,"os_balance":17653820,"credit_available":52346180},{"fp_ca_no":"001358444444","car_type_desc":"New Car","approve_date":"20/03/2017","approve_date_th":"20/03/2560","exp_date":"31/10/2018","exp_date_th":"31/10/2561","status":"Active","credit_limit":123568761,"os_balance":6523260,"credit_available":1235321}],"total_record":7,"paging":{"count":5,"limit":5,"offset":0,"total":7},"fp_response":{"code":200,"description":"Success"}}',
                    state
                )
            }, state);
        Test.stopTest();
    }
    @IsTest
    static void testCalloutserviceLeasingListException(){
        Test.startTest();
        Object state = new Map<String, Object>{
            'startDateTime' => Datetime.now(),
            'service' => 'FloorPlan',
            'tmbCustId' => 'tmbCustId',
            'endpoint' => 'callout:endpoint',
            'uuid' => new Uuid().getValue()
        };

        String requestLabel = testCalloutservice('', state);
        CommercialAutoLoanController.callbackLeasingList(new List<String>{requestLabel}, state);
        try { CommercialAutoLoanController.callbackLeasingList(new List<String>{requestLabel}, state); } catch (Exception e) {}
        Test.stopTest();
    }
    @IsTest
    static void testCalloutserviceLeasingListFlagException(){
        Test.startTest();
        Object state = new Map<String, Object>{
            'startDateTime' => Datetime.now(),
            'service' => 'DWH',
            'tmbCustId' => 'tmbCustId',
            'endpoint' => 'callout:endpoint',
            'uuid' => new Uuid().getValue()
        };

        String requestLabel = testCalloutservice('', state);
        CommercialAutoLoanController.callbackLeasingFlag(new List<String>{requestLabel}, state);
        try { CommercialAutoLoanController.callbackLeasingFlag(new List<String>{requestLabel}, state); } catch (Exception e) {}
        Test.stopTest();
    }
    @IsTest
    static void testCalloutserviceLeasingFlag(){
        Test.startTest();
        Object state = new Map<String, Object>{
            'startDateTime' => Datetime.now(),
            'service' => 'DWH',
            'tmbCustId' => 'tmbCustId',
            'endpoint' => 'callout:AutoLoan_LeasingFlag',
            'uuid' => new Uuid().getValue()
        };
        CommercialAutoLoanController.callbackLeasingFlag(
            new List<String>{ 
                testCalloutservice(
                    '{"customer":{"product_holdings":{"other_accounts":[],"bancassurance_accounts":[],"mutual_fund_accounts":[],"foreign_exchange_accounts":[],"merchant_accounts":[],"leasing_accounts":[{"create_by":"BATCHCONV","relationship_code":"PRIIND","owner_type":"P","product_code":"HLV0","product_group_code":"-","acct_nbr":"001620501810","acct_ctrl4":"0000","acct_ctrl3":"0000","acct_ctrl2":"0000","acct_ctrl1":"0011","appl_code":"93"}],"hire_purchase_accounts":[],"safety_box_accounts":[],"debit_card_accounts":[],"credit_card_accounts":[],"treasury_accounts":[],"trade_finance_accounts":[],"loan_bill_accounts":[],"loan_accounts":[],"current_accounts":[],"saving_accounts":[{"balance_currency":"THB","current_balance":1008176.38,"account_status":"1","account_open_dt":"2020-06-30","relationship_code":"PRIIND","owner_type":"P","product_code":"200","product_group_code":"ST","account_name":"NAME TEST","acct_nbr":"00000112879721","acct_ctrl4":"0200","acct_ctrl3":"0011","acct_ctrl2":"0001","acct_ctrl1":"0011","appl_code":"60"}]},"profile":{"rm_id":"001100000000000000000014082721","cc_id":"2053592854"}},"status":{"description":"Success","code":"0000"}}',
                    state
                )
            }, state);
        Test.stopTest();
    }
    @IsTest
    static void testCalloutserviceLeasingList(){
        Test.startTest();
        Object state = new Map<String, Object>{
            'startDateTime' => Datetime.now(),
            'service' => 'FloorPlan',
            'tmbCustId' => 'tmbCustId',
            'endpoint' => 'callout:AutoLoan_LeasingList?test=test',
            'uuid' => new Uuid().getValue()
        };
        CommercialAutoLoanController.callbackLeasingList(
            new List<String>{ 
                testCalloutservice(
                    '{"details":[{"fp_ca_no":"001358500133","car_type_desc":"New Car","approve_date":"20/03/2017","approve_date_th":"20/03/2560","exp_date":"31/10/2018","exp_date_th":"31/10/2561","status":"Active","credit_limit":70000000,"os_balance":17653820,"credit_available":52346180},{"fp_ca_no":"001358444444","car_type_desc":"New Car","approve_date":"20/03/2017","approve_date_th":"20/03/2560","exp_date":"31/10/2018","exp_date_th":"31/10/2561","status":"Active","credit_limit":123568761,"os_balance":6523260,"credit_available":1235321}],"total_record":7,"paging":{"count":5,"limit":5,"offset":0,"total":7},"fp_response":{"code":200,"description":"Success"}}',
                    state
                )
            }, state);
        Test.stopTest();
    }
    @IsTest
    static void testCalloutserviceLeasingDetailException(){
        Test.startTest();
        Object state = new Map<String, Object>{
            'startDateTime' => Datetime.now(),
            'service' => 'FloorPlan',
            'tmbCustId' => 'tmbCustId',
            'endpoint' => 'callout:endpoint',
            'uuid' => new Uuid().getValue()
        };

        String requestLabel = testCalloutservice('', state);
        CommercialAutoLoanController.callbackLeasingDetail(new List<String>{requestLabel}, state);
        try { CommercialAutoLoanController.callbackLeasingDetail(new List<String>{requestLabel}, state); } catch (Exception e) {}
        Test.stopTest();
    }
    @IsTest
    static void testCalloutserviceLeasingDetail(){
        Test.startTest();
        Object state = new Map<String, Object>{
            'startDateTime' => Datetime.now(),
            'service' => 'FloorPlan',
            'tmbCustId' => 'tmbCustId',
            'endpoint' => 'callout:endpoint?test=test',
            'uuid' => new Uuid().getValue()
        };
        CommercialAutoLoanController.callbackLeasingDetail(
            new List<String>{ 
                testCalloutservice(
                    '{"details":[{"fp_ca_no":"001358500133","car_type_desc":"New Car","approve_date":"20/03/2017","approve_date_th":"20/03/2560","exp_date":"31/10/2018","exp_date_th":"31/10/2561","status":"Active","credit_limit":70000000,"os_balance":17653820,"credit_available":52346180},{"fp_ca_no":"001358444444","car_type_desc":"New Car","approve_date":"20/03/2017","approve_date_th":"20/03/2560","exp_date":"31/10/2018","exp_date_th":"31/10/2561","status":"Active","credit_limit":123568761,"os_balance":6523260,"credit_available":1235321}],"total_record":7,"paging":{"count":5,"limit":5,"offset":0,"total":7},"fp_response":{"code":200,"description":"Success"}}',
                    state
                )
            }, state);
        Test.stopTest();
    }
}