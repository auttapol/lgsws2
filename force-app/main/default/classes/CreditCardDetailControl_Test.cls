@isTest
public class CreditCardDetailControl_Test extends AbstractCoreClass {

    private class getCardService401 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"Status":{"StatusCode":"401","StatusDesc":"Unauthorized"}}');
            res.setStatusCode(401);
            return res;
        }
    }

    private class getCardService200 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"result":{"credit_card":{"card_cash_advance":{"cash_adv_special_int_rate_expiry":"","cash_adv_special_int_rate":0,"cash_adv_special_min_amount":0,"cash_adv_int_rate":16,"cash_adv_fee_VAT_rate":7,"cash_adv_fee_model":"1","cash_adv_fee_fixed_amt":0,"cash_adv_fee_rate":3},"customer_supp":{"identification_id":"","birthdate":"","cc_id":"0","rm_id":"000000000000000000000000000000"},"card_credit_limit":{"temporary_credit_limit":{"max_temp_increase":42,"max_temp_allowance":113000,"previous_credit_limit":80000,"request_reason":"","expiry_date":"0000-00-00","effective_date":"0000-00-00","amounts":0},"permanent_credit_limit":80000},"card_balances":{"balance_credit_line":{"current":80000,"available":75282.92,"total":80000},"balance_credit_limit":{"current":80000,"available_to_transfer":75282.92,"total":80000},"epai_installment_available":0,"eptb_installment_available":0,"last_payment_date":"2021-03-08","last_payment_amount":-641.92,"available_credit_allowance":75282.92,"available_cash_advance":75282.92,"ledger_balance":4717.08,"current_balance":4717.08},"card_status":{"card_active_flag":"INACTIVE","card_ploan_flag":"1","stop_date":"2016-03-13","application_type":"B","previous_expiry_date":"1207","block_code":"","activated_date":"2012-08-10","account_agree_status":"016","account_status":"003","stop_code_desc":"24 - Account Closed","stop_code":2},"balance_points":{"expiry_date":"2023-08-20","expiry_points":0,"point_remain":2720.88,"point_available":2720.88,"point_used":0,"point_earned":0},"card_email":{"email_eStatementFlag":"Y","email_address":"PRETTYKAY5@YAHOO.COM"},"card_addresses":{"state_txt":"กรุงเทพมหานคร","state_code":"C10000","country":"TH","address_3":"แขวงจตุจักร","address_2":"ถ.วิภาวดี","address_1":"1/22 ซ.วิภาวดี 32","postal_code":"10900","city":"จตุจักร"},"card_phones":[{"phone_extension":"","phone_no":"","phone_type":""},{"phone_extension":"","phone_no":"","phone_type":""},{"phone_extension":"","phone_no":"","phone_type":""},{"phone_extension":"","phone_no":"","phone_type":""},{"phone_extension":"","phone_no":"","phone_type":""},{"phone_extension":"","phone_no":"","phone_type":""},{"phone_extension":"","phone_no":"","phone_type":""},{"phone_extension":"","phone_no":"","phone_type":""},{"phone_extension":"","phone_no":"","phone_type":""},{"phone_extension":"","phone_no":"","phone_type":""}],"card_info":{"created_date":"2012-08-10","effective_date":"2012-08-10","last_update_date":"2022-11 15","expired_by":"1707","issued_by":"0101","card_embossing_name2":"","card_embossing_name1":"KIPN :5273863","billing_cycle":20},"customer":{"identification_id":"OLIC :5273863","birthdate":"1977-11-26","cc_id":"3015440055","rm_id":"001100000000000000000000051187"},"direct_deposit_bank":"","direct_deposit_account":0,"product_id":"VSOFAS","account_id":"0000000052738630012079002","card_id":"456043XXXXXX9002"},"status":{"status_code":0}},"CreditCardAccount":{"AccountStatus":"Inactive","CardPLoan":"1","VLimit":80000,"SubProductGroup":"ttb so fast credit card(Visa Card)","Status":"FOUND","SeqGrp":"3","ProductName":"Visa Card So Fast Income >= 15,000 THB","Params":"syXAWZ/SoUJDA61jMckKIAkxunC9x1mNgpUgbdNsRHvXBUz2Uys9NKWmmTxSns4r","Outstanding":4717.08,"OpenedDate":"2012-08-10","MarkedVLimit":"80,0xx","MarkedOutstanding":"4,7xx","MarkedCardNumber":"4560-43xx-xxxx-9002","isEmployee":true,"CreditCardType":"VSOFAS","convertedOpenedDate":"10/08/2012","CardNumber":"456043XXXXXX9002","ProductType":"Credit Card & RDC","CardRole":"","CardActive":"INACTIVE"}}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class getCardUnbil implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"status":{"status_code":0},"card_statement":{"total_unbilled_amounts":0,"full_payment_amounts":4717.08,"min_payment_amounts":4717.08,"total_amount_due":4717.08,"minimum_due":4717.08,"interests":0,"cash_advance_fee":0,"total_cash_installment_records":0,"total_spending_installment_records":0,"due_date":"2023-08-09","statement_date":"2023-07-20","promotion_flag":"","point_available":2720.88,"statement_transactions":[{"transaction_code":0,"transaction_amounts":0,"posted_date":"","transaction_type":"","transaction_date":"","mcc_code":"","transaction_description":"","transaction_currency":"","transaction_source_amounts":0,"transaction_source_currency":""}],"point_remain":2720.88,"expiry_date":"0000-00-00","expiry_points":0,"total_spending_this_cycle":0},"total_records":0,"max_records":1,"more_records":"N","search_keys":""}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class getCardSummary implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"status":{"code":"200","description":"record not found."}}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest static void testgetSCSCreditCard1(){
        Test.setMock(HttpCalloutMock.class, new getCardService200());
        Object returnMap = CreditCardDetailControl.getSCSCreditCard('0000000052738630012079002', '001100000000000000000000051187', '001p0000010nXLS');
    }

    @isTest static void testgetSCSCreditCard2(){
        Test.setMock(HttpCalloutMock.class, new getCardService401());
        Object returnMap = CreditCardDetailControl.getSCSCreditCard('0000000052738630012079002', '001100000000000000000000051187', '001p0000010nXLS');
    }

    @isTest static void testgetSummaryCreditCardData(){
        Test.setMock(HttpCalloutMock.class, new getCardSummary());
        Object returnMap = CreditCardDetailControl.getSummaryCreditCardData('0000000052738630012079002', '001100000000000000000000051187', '001p0000010nXLS');
    }

    @isTest static void testgetUnbilCreditCard(){
        Test.setMock(HttpCalloutMock.class, new getCardUnbil());
        Object returnMap = CreditCardDetailControl.getUnbilCreditCard('0000000052738630012079002', '001100000000000000000000051187', '001p0000010nXLS');
    }

    @isTest static void testgetCreditFormat(){
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped('{"credit_card":{"account_id":"0000000052738630012079002","balance_points":{"expiry_date":"20/08/2023","expiry_points":0,"point_remain":2720.88},"card_balances":{"balance_credit_limit":{"available_to_transfer":75282.92,"current":80000,"total":80000},"current_balance":4717.08,"last_payment_date":"08/03/2021"},"card_credit_limit":{"temporary_credit_limit":{"amounts":0}},"card_id":"456043XXXXXX9002","card_info":{"billing_cycle":20,"created_date":"10/08/2012","expired_by":"1707"},"card_status":{"account_agree_status":"016","account_status":"003","activated_date":"10/08/2012","block_code":"","previous_expiry_date":"1207","stop_code":2,"stop_code_desc":"24 - Account Closed"},"direct_deposit_account":0,"product_id":"VSOFAS"},"status":{"status_code":0}}');
        Object returnMap = CreditCardDetailControl.getCreditFormat((Object) result, '001100000000000000000000051187', '001p0000010nXLS');
    }

    @isTest static void testGetWaterMark(){
        String returnMap = CreditCardDetailControl.getWatermark();
    }

    @isTest static void testGetMakeValue(){
        String returnMap = CreditCardDetailControl.getMakeValue('something', 'hello world');
    }

    @isTest static void testGetUnmask(){
        String returnMap = CreditCardDetailControl.getUnmaskBalance();
    }
}