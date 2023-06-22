public class CreditCardDetailControl {

    public class creditCardAccountWrapper{
        @AuraEnabled public String CardActive{ get; set; }
        @AuraEnabled public String CardRole{ get; set; }
        @AuraEnabled public String ProductType{ get; set; }
        @AuraEnabled public String CardNumber{ get; set; }
        @AuraEnabled public String convertedOpenedDate{ get; set; }
        @AuraEnabled public String CreditCardType{ get; set; }
        @AuraEnabled public Boolean isEmployee{ get; set; }
        @AuraEnabled public String MarkedCardNumber{ get; set; }
        @AuraEnabled public String MarkedOutstanding{ get; set; }
        @AuraEnabled public String MarkedVLimit{ get; set; }
        @AuraEnabled public String OpenedDate{ get; set; }
        @AuraEnabled public String Params{ get; set; }
        @AuraEnabled public String ProductName{ get; set; }
        @AuraEnabled public String SeqGrp{ get; set; }
        @AuraEnabled public String Status{ get; set; }
        @AuraEnabled public String SubProductGroup{ get; set; }
        @AuraEnabled public String CardPLoan{ get; set; }
        @AuraEnabled public String AccountStatus{ get; set; }
        // @AuraEnabled public String Outstanding{ get; set; }
        // @AuraEnabled public String VLimit{ get; set; }
    }

    public class Credit_cardWrapper{
        @AuraEnabled public String card_id{ get; set; }
        @AuraEnabled public String account_id{ get; set; }
        @AuraEnabled public String product_id{ get; set; }    
        @AuraEnabled public String direct_deposit_account{ get; set; }    
        @AuraEnabled public Card_infoWrapper card_info{ get; set; }
        @AuraEnabled public Card_balancesWrapper card_balances{ get; set; }
        @AuraEnabled public Card_credit_limitWrapper card_credit_limit{ get; set; }
        @AuraEnabled public Balance_pointsWrapper balance_points{ get; set; }
        @AuraEnabled public Card_statusWrapper card_status{ get; set; }
    }    

    public class Card_infoWrapper{
        @AuraEnabled public String created_date{ get; set; }        
        @AuraEnabled public String expired_by{ get; set; }        
        @AuraEnabled public String billing_cycle{ get; set; }
    }

    public class Card_balancesWrapper{
        @AuraEnabled public String last_payment_date{ get; set; }
        @AuraEnabled public String current_balance{ get; set; }        
        @AuraEnabled public Balance_credit_limitWrapper balance_credit_limit{ get; set; }        
    }

    public class Balance_credit_limitWrapper{
        @AuraEnabled public String total{ get; set; }
        @AuraEnabled public String available_to_transfer{ get; set; }
        @AuraEnabled public String current{ get; set; }
    }   

    public class Card_credit_limitWrapper{
        @AuraEnabled public Temporary_credit_limitWrapper temporary_credit_limit{ get; set; }
    }

    public class Temporary_credit_limitWrapper{
        @AuraEnabled public String amounts{ get; set; }
    }

    public class Balance_pointsWrapper{
        @AuraEnabled public String point_remain{ get; set; }
        @AuraEnabled public String expiry_points{ get; set; }
        @AuraEnabled public String expiry_date{ get; set; }
    }

    public class Card_statusWrapper{
        @AuraEnabled public String activated_date{ get; set; }
        @AuraEnabled public String previous_expiry_date{ get; set; }
        @AuraEnabled public String account_status{ get; set; }
        @AuraEnabled public String stop_code_desc{ get; set; }
        @AuraEnabled public String account_agree_status{ get; set; }
        @AuraEnabled public String block_code{ get; set; }
        @AuraEnabled public String stop_code{ get; set; }
    }

    @AuraEnabled
    public static Object getSCSCreditCard(String account_id, String tmbCustId, String recordId){
        String reqBody = '{"query":{"account_id":"' + account_id + '"}}';
        String endpoint = 'callout:get_card';
        Map<String, Object> result;
        Object objresult;
        if(!Test.isRunningTest()){
            objresult = RTL_ProductHoldingsLightningUtil.getProductSCSCreditCard(endpoint, reqBody, tmbCustId);
            result = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(objresult));    
        }
        else{
            result = (Map<String, Object>)JSON.deserializeUntyped('{"result":{"credit_card":{"card_cash_advance":{"cash_adv_special_int_rate_expiry":"","cash_adv_special_int_rate":0,"cash_adv_special_min_amount":0,"cash_adv_int_rate":16,"cash_adv_fee_VAT_rate":7,"cash_adv_fee_model":"1","cash_adv_fee_fixed_amt":0,"cash_adv_fee_rate":3},"customer_supp":{"identification_id":"","birthdate":"","cc_id":"0","rm_id":"000000000000000000000000000000"},"card_credit_limit":{"temporary_credit_limit":{"max_temp_increase":42,"max_temp_allowance":113000,"previous_credit_limit":80000,"request_reason":"","expiry_date":"0000-00-00","effective_date":"0000-00-00","amounts":0},"permanent_credit_limit":80000},"card_balances":{"balance_credit_line":{"current":80000,"available":75282.92,"total":80000},"balance_credit_limit":{"current":80000,"available_to_transfer":75282.92,"total":80000},"epai_installment_available":0,"eptb_installment_available":0,"last_payment_date":"2021-03-08","last_payment_amount":-641.92,"available_credit_allowance":75282.92,"available_cash_advance":75282.92,"ledger_balance":4717.08,"current_balance":4717.08},"card_status":{"card_active_flag":"INACTIVE","card_ploan_flag":"1","stop_date":"2016-03-13","application_type":"B","previous_expiry_date":"1207","block_code":"","activated_date":"2012-08-10","account_agree_status":"016","account_status":"003","stop_code_desc":"24 - Account Closed","stop_code":2},"balance_points":{"expiry_date":"2023-08-20","expiry_points":0,"point_remain":2720.88,"point_available":2720.88,"point_used":0,"point_earned":0},"card_email":{"email_eStatementFlag":"Y","email_address":"PRETTYKAY5@YAHOO.COM"},"card_addresses":{"state_txt":"กรุงเทพมหานคร","state_code":"C10000","country":"TH","address_3":"แขวงจตุจักร","address_2":"ถ.วิภาวดี","address_1":"1/22 ซ.วิภาวดี 32","postal_code":"10900","city":"จตุจักร"},"card_phones":[{"phone_extension":"","phone_no":"","phone_type":""},{"phone_extension":"","phone_no":"","phone_type":""},{"phone_extension":"","phone_no":"","phone_type":""},{"phone_extension":"","phone_no":"","phone_type":""},{"phone_extension":"","phone_no":"","phone_type":""},{"phone_extension":"","phone_no":"","phone_type":""},{"phone_extension":"","phone_no":"","phone_type":""},{"phone_extension":"","phone_no":"","phone_type":""},{"phone_extension":"","phone_no":"","phone_type":""},{"phone_extension":"","phone_no":"","phone_type":""}],"card_info":{"created_date":"2012-08-10","effective_date":"2012-08-10","last_update_date":"2022-11 15","expired_by":"1707","issued_by":"0101","card_embossing_name2":"","card_embossing_name1":"KIPN :5273863","billing_cycle":20},"customer":{"identification_id":"OLIC :5273863","birthdate":"1977-11-26","cc_id":"3015440055","rm_id":"001100000000000000000000051187"},"direct_deposit_bank":"","direct_deposit_account":0,"product_id":"VSOFAS","account_id":"0000000052738630012079002","card_id":"456043XXXXXX9002"},"status":{"status_code":0}},"CreditCardAccount":{"AccountStatus":"Inactive","CardPLoan":"1","VLimit":80000,"SubProductGroup":"ttb so fast credit card(Visa Card)","Status":"FOUND","SeqGrp":"3","ProductName":"Visa Card So Fast Income >= 15,000 THB","Params":"syXAWZ/SoUJDA61jMckKIAkxunC9x1mNgpUgbdNsRHvXBUz2Uys9NKWmmTxSns4r","Outstanding":4717.08,"OpenedDate":"2012-08-10","MarkedVLimit":"80,0xx","MarkedOutstanding":"4,7xx","MarkedCardNumber":"4560-43xx-xxxx-9002","isEmployee":true,"CreditCardType":"VSOFAS","convertedOpenedDate":"10/08/2012","CardNumber":"456043XXXXXX9002","ProductType":"Credit Card & RDC","CardRole":"","CardActive":"INACTIVE"}}');
        }
        try{
            Map<String, Object> returnMap = new Map<String, Object>(result);
            Map<String, Object> layer1 = (Map<String, Object>)returnMap.get('result');
            Map<String, Boolean> fieldVisible = RTL_ProductHoldingSummaryController.getFieldVisibilityByPage(recordId, 'Credit Card / RDC Product Details');        
            layer1.put('credit_card', parseCredit_cardWrapper(result ,recordId, fieldVisible));
            returnMap.put('result', (Object) layer1);
            returnMap.put('CreditCardAccount', (Object) parseCreditCardAccount(result, recordId, fieldVisible));
            returnMap.put('Authorize', fieldVisible.get('Authorize'));
            return (Object) returnMap;
        }catch(Exception e){
            return (object) result;
        }
    }

    private static Credit_cardWrapper parseCredit_cardWrapper(Map<String, Object> result, String recordId, Map<String, Boolean> fieldVisible){
        Credit_cardWrapper wrapper = new Credit_cardWrapper();
        try{
            Map<String, Object> layer1 = (Map<String, Object>)result.get('result');
            Map<String, Object> layer2 = (Map<String, Object>)layer1.get('credit_card');
            wrapper.card_id = fieldVisible.get('CCDetail_card_id') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer2.get('card_id'));
            wrapper.account_id = fieldVisible.get('CCDetail_account_id') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer2.get('account_id'));
            wrapper.product_id = fieldVisible.get('CCDetail_product_id') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer2.get('product_id'));
            wrapper.direct_deposit_account = fieldVisible.get('CCDetail_direct_deposit_account') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer2.get('direct_deposit_account'));
            wrapper.card_info = parsecard_infoWrapper(layer2,fieldVisible);
            wrapper.card_balances = parseCard_balanceWrapper(layer2,fieldVisible);
            wrapper.card_credit_limit = parseCard_credit_limitWrapper(layer2,fieldVisible);
            wrapper.balance_points = parseBalance_pointsWrapper(layer2,fieldVisible);
            wrapper.card_status = parseCard_statusWrapper(layer2,fieldVisible);
            return wrapper;
        }catch(Exception e){
            return wrapper;
        }
    }

    private static Card_statusWrapper parseCard_statusWrapper(Map<String, Object> layer2, Map<String, Boolean> fieldVisible){
        Map<String, Object> layer3 = (Map<String, Object>)layer2.get('card_status');
        Card_statusWrapper wrapper = new Card_statusWrapper();
        String pexd = genDDMMYYYY(String.valueOf(layer3.get('previous_expiry_date')));
        String actd = genDDMMYYYY(String.valueOf(layer3.get('activated_date')));
        wrapper.previous_expiry_date = fieldVisible.get('CCDetail_previous_expiry_date') == false ? Label.Data_Condition_Hidden_Text : pexd == 'Invalid' ? String.valueOf(layer3.get('previous_expiry_date')) : pexd ;
        wrapper.activated_date = fieldVisible.get('CCDetail_activated_date') == false ? Label.Data_Condition_Hidden_Text : actd == 'Invalid' ? String.valueOf(layer3.get('activated_date')) : actd ;
        wrapper.account_status = fieldVisible.get('CCDetail_account_status') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer3.get('account_status'));
        wrapper.stop_code_desc = fieldVisible.get('	CCDetail_stop_code_desc') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer3.get('stop_code_desc'));
        wrapper.account_agree_status = fieldVisible.get('CCDetail_account_agree_status') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer3.get('account_agree_status'));
        wrapper.block_code = fieldVisible.get('CCDetail_block_code') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer3.get('block_code'));
        wrapper.stop_code = fieldVisible.get('CCDetail_stop_code') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer3.get('stop_code'));
        return wrapper;
    }

    private static Balance_pointsWrapper parseBalance_pointsWrapper(Map<String, Object> layer2, Map<String, Boolean> fieldVisible){
        Map<String, Object> layer3 = (Map<String, Object>)layer2.get('balance_points');
        Balance_pointsWrapper wrapper = new Balance_pointsWrapper();
        String exd = genDDMMYYYY(String.valueOf(layer3.get('expiry_date')));
        wrapper.point_remain = fieldVisible.get('CCDetail_point_remain') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer3.get('point_remain'));
        wrapper.expiry_points = fieldVisible.get('CCDetail_expiry_points') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer3.get('expiry_points'));
        wrapper.expiry_date = fieldVisible.get('CCDetail_expiry_date') == false ? Label.Data_Condition_Hidden_Text : exd == 'Invalid' ? String.valueOf(layer3.get('expiry_date')) : exd;
        return wrapper;
    }

    private static Card_credit_limitWrapper parseCard_credit_limitWrapper(Map<String, Object> layer2, Map<String, Boolean> fieldVisible){
        Map<String, Object> layer3 = (Map<String, Object>)layer2.get('card_credit_limit');
        Card_credit_limitWrapper wrapper = new Card_credit_limitWrapper();
        Map<String, Object> layer4 = (Map<String, Object>)layer3.get('temporary_credit_limit');
        Temporary_credit_limitWrapper tem = new Temporary_credit_limitWrapper();
        tem.amounts = fieldVisible.get('CCDetail_limit_amounts') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer4.get('amounts'));
        wrapper.temporary_credit_limit = tem;
        return wrapper;
    }

    private static Card_balancesWrapper parseCard_balanceWrapper(Map<String, Object> layer2, Map<String, Boolean> fieldVisible){
        Map<String, Object> layer3 = (Map<String, Object>)layer2.get('card_balances');
        Card_balancesWrapper wrapper = new Card_balancesWrapper();
        String lpd = genDDMMYYYY(String.valueOf(layer3.get('last_payment_date')));
        wrapper.current_balance = fieldVisible.get('CCDetail_current_balance') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer3.get('current_balance'));        
        wrapper.last_payment_date = fieldVisible.get('CCDetail_last_payment_date') == false ? Label.Data_Condition_Hidden_Text : lpd == 'Invalid' ? String.valueOf(layer3.get('last_payment_date')) : lpd;

        Map<String, Object> credit_limit = (Map<String, Object>)layer3.get('balance_credit_limit');
        Balance_credit_limitWrapper lim = new Balance_credit_limitWrapper();
        lim.total = fieldVisible.get('CCDetail_limit_total') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(credit_limit.get('total'));
        lim.available_to_transfer = fieldVisible.get('CCDetail_limit_available_to_transfer') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(credit_limit.get('available_to_transfer'));
        lim.current = fieldVisible.get('CCDetail_limit_current') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(credit_limit.get('current'));        
        wrapper.balance_credit_limit = lim;        
        return wrapper;

    }

    private static Card_infoWrapper parsecard_infoWrapper(Map<String, Object> layer2, Map<String, Boolean> fieldVisible){
        Map<String, Object> layer3 = (Map<String, Object>)layer2.get('card_info');
        Card_infoWrapper wrapper = new Card_infoWrapper();
        String crd = genDDMMYYYY(String.valueOf(layer3.get('created_date')));
        wrapper.billing_cycle = fieldVisible.get('CCDetail_billing_cycle') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer3.get('billing_cycle'));        
        wrapper.expired_by = fieldVisible.get('CCDetail_expired_by') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer3.get('expired_by'));        
        wrapper.created_date = fieldVisible.get('CCDetail_created_date') == false ? Label.Data_Condition_Hidden_Text : crd == 'Invalid' ? String.valueOf(layer3.get('created_date')) : crd;
        return wrapper;
    }

    private static creditCardAccountWrapper parseCreditCardAccount(Map<String, Object> result, String recordId, Map<String, Boolean> fieldVisible){
        Map<String, Object> layer1 = (Map<String, Object>)result.get('CreditCardAccount');
        Boolean isEmployee =  (Boolean) layer1.get('isEmployee');
        String cod = genDDMMYYYY(String.valueOf(layer1.get('convertedOpenedDate')));
        String opd = genDDMMYYYY(String.valueOf(layer1.get('OpenedDate')));
        creditCardAccountWrapper wrapper = new creditCardAccountWrapper();
        wrapper.convertedOpenedDate = fieldVisible.get('CCDetail_convertedOpenedDate') == false ? Label.Data_Condition_Hidden_Text : cod == 'Invalid' ? String.valueOf(layer1.get('convertedOpenedDate')) : cod;
        wrapper.OpenedDate = fieldVisible.get('	CCDetail_OpenedDate') == false ? Label.Data_Condition_Hidden_Text : opd == 'Invalid' ? String.valueOf(layer1.get('OpenedDate')) : opd;
        wrapper.CardActive = fieldVisible.get('CCDetail_CardActive') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer1.get('CardActive'));
        wrapper.CardRole = fieldVisible.get('CCDetail_CardRole') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer1.get('CardRole'));
        wrapper.ProductType = fieldVisible.get('CCDetail_ProductType') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer1.get('ProductType'));
        wrapper.CardNumber = fieldVisible.get('CCDetail_CardNumber') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer1.get('CardNumber'));
        wrapper.CreditCardType = fieldVisible.get('CCDetail_CreditCardType') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer1.get('CreditCardType'));
        wrapper.MarkedCardNumber = fieldVisible.get('CCDetail_MarkedCardNumber') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer1.get('MarkedCardNumber'));
        wrapper.MarkedOutstanding = (isEmployee == true || fieldVisible.get('CCDetail_MarkedOutstanding') == false ) ? Label.Data_Condition_Hidden_Text : String.valueOf(layer1.get('MarkedOutstanding'));
        wrapper.MarkedVLimit = (isEmployee == true || fieldVisible.get('Creditcard_MarkedVLimit') == false ) ? Label.Data_Condition_Hidden_Text : String.valueOf(layer1.get('MarkedVLimit'));
        wrapper.Params = fieldVisible.get('CCDetail_Params') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer1.get('Params'));
        wrapper.ProductName = fieldVisible.get('CCDetail_ProductName') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer1.get('ProductName'));
        wrapper.SeqGrp = fieldVisible.get('	CCDetail_SeqGrp') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer1.get('SeqGrp'));
        wrapper.Status = fieldVisible.get('CCDetail_Status') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer1.get('Status'));
        wrapper.SubProductGroup = fieldVisible.get('CCDetail_SubProductGroup') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer1.get('SubProductGroup'));
        wrapper.CardPLoan = fieldVisible.get('CCDetail_CardPLoan') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer1.get('CardPLoan'));
        wrapper.AccountStatus = fieldVisible.get('CCDetail_AccountStatus') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(layer1.get('AccountStatus'));
        wrapper.isEmployee = (Boolean) layer1.get('isEmployee');
        // wrapper.Outstanding = (isEmployee == true || fieldVisible.get('CCDetail_Outstanding') == false ) ? Label.Data_Condition_Hidden_Text : String.valueOf(layer1.get('Outstanding'));
        // wrapper.VLimit = (isEmployee == true || fieldVisible.get('CCDetail_VLimit') == false ) ? Label.Data_Condition_Hidden_Text : String.valueOf(layer1.get('VLimit'));
        return wrapper;
    }

    @AuraEnabled
    public static Object getCreditFormat(Object data, String tmbCustId, String recordId){
        try{
            Object result =  RTL_ProductHoldingsLightningUtil.setFormatCreditData(data, tmbCustId);
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(result));
            Map<String, Object> rdc = (Map<String, Object>)jsonMap.get('CreditCardRDCProduct');    
            Boolean isEmployee =  (Boolean) rdc.get('isEmployee');
            Map<String, Boolean> fieldVisible = RTL_ProductHoldingSummaryController.getFieldVisibilityByPage(recordId, 'Credit Card / RDC Product Details');
            String unmaskStr = getUnmaskBalance(); 
            
            String markedVLimit = getCents(Decimal.valueOf(String.valueOf(rdc.get('VLimit'))));
            String markedCreditLimit = getCents(Decimal.valueOf(String.valueOf(rdc.get('CreditLimit'))));
            String markedOutstanding = getCents(Decimal.valueOf(String.valueOf(rdc.get('Outstanding'))));
            String markedCurrentBalance = getCents(Decimal.valueOf(String.valueOf(rdc.get('CurrentBalance'))));
            // rdc.put('VLimit', isEmployee == true ? Label.Data_Condition_Hidden_Text : String.valueOf(rdc.get('VLimit')));
            // rdc.put('CreditLimit', isEmployee == true ? Label.Data_Condition_Hidden_Text : String.valueOf(rdc.get('CreditLimit')));
            // rdc.put('Outstanding', isEmployee == true ? Label.Data_Condition_Hidden_Text : String.valueOf(rdc.get('Outstanding')));
            // rdc.put('CurrentBalance', isEmployee == true ? Label.Data_Condition_Hidden_Text : String.valueOf(rdc.get('CurrentBalance')));

            // rdc.put('MarkedVLimit', isEmployee == true ? Label.Data_Condition_Hidden_Text : markedVLimit);
            // rdc.put('MarkedOutstanding', isEmployee == true ? Label.Data_Condition_Hidden_Text : markedOutstanding);
            // rdc.put('MarkedCreditLimit', isEmployee == true ? Label.Data_Condition_Hidden_Text : markedCreditLimit);
            // rdc.put('MarkedCurrentBalance', isEmployee == true ? Label.Data_Condition_Hidden_Text : markedCurrentBalance);
            rdc.put('MarkedVLimit', isEmployee == true ? Label.Data_Condition_Hidden_Text : String.valueOf(rdc.get('MarkedVLimit')));
            rdc.put('MarkedOutstanding', isEmployee == true ? Label.Data_Condition_Hidden_Text : String.valueOf(rdc.get('MarkedOutstanding')));
            rdc.put('MarkedCreditLimit', isEmployee == true ? Label.Data_Condition_Hidden_Text : String.valueOf(rdc.get('MarkedCreditLimit')));
            rdc.put('MarkedCurrentBalance', isEmployee == true ? Label.Data_Condition_Hidden_Text : String.valueOf(rdc.get('MarkedCurrentBalance')));
            rdc.remove('VLimit');
            rdc.remove('CreditLimit');
            rdc.remove('Outstanding');
            rdc.remove('CurrentBalance');
            
            if(isEmployee == false && unmaskStr != null){
                rdc.put('MarkedCreditLimit', markedCreditLimit.contains('.') ? markedCreditLimit : markedCreditLimit + '.00');
                rdc.put('MarkedCurrentBalance', markedCurrentBalance.contains('.') ? markedCurrentBalance : markedCurrentBalance + '.00');
            }
            Map<String, Object> credit_cards = (Map<String, Object>)jsonMap.get('credit_card');
            Object afterRemove = removethings(credit_cards);
            jsonMap.put('credit_card', afterRemove);
            jsonMap.put('CreditCardRDCProduct', rdc);
            return (Object) jsonMap; 
        }catch(Exception e){
            return data;
        }       
    }
    
    private static Object removethings(Map<String, Object> credit_cards){
        try{
            Map<String, Object> card_balances = (Map<String, Object>)credit_cards.get('card_balances');
            card_balances.remove('balance_credit_limit');
            card_balances.remove('current_balance');
    
            credit_cards.put('card_balances', card_balances);
    
            credit_cards.remove('direct_deposit_account');
            credit_cards.remove('product_id');
            credit_cards.remove('card_id');
            credit_cards.remove('account_id');
    
            Map<String, Object> card_status = (Map<String, Object>)credit_cards.get('card_status');
            card_status.remove('account_agree_status');
            card_status.remove('account_status');
            card_status.remove('block_code');
            card_status.remove('stop_code');
            card_status.remove('stop_code_desc');
    
            credit_cards.put('card_status', card_status);
            return (Object) credit_cards;
        }catch(Exception e){
            return (Object) credit_cards;
        }
    }

    
    public static String getCents(Decimal x){
        try{
            String i = String.valueOf(x);
            if(i.contains('.')){
                String s = ( Decimal.valueOf(i==null||i.trim()==''?'0':i).setScale(2) + 0.001 ).format();
                String p = s.substring(0,s.length()-1);
                return p;
            }
            else{
                List<String> args = new String[]{'0','number','###,###,##0.00'};
                String s = String.format(x.format(), args);
                return s;
            }
        }catch(Exception e){
            return String.valueOf(x);
        }
    }

    @AuraEnabled
    public static string getWatermark() {
        return RTL_ProductHoldingsLightningUtil.getWatermarkHTML();
    }

    @AuraEnabled
    public static Object getUnbilCreditCard(String account_id, String recordId, String tmbCustId){
        String reqBody = '{"query":{"account_id":"' + account_id + '","more_records":"N","search_keys":""}}';
        String endpoint = 'callout:get_unbilled_statement';
        Object response = RTL_ProductHoldingsLightningUtil.getProductSCSCreditCard(endpoint, reqBody, tmbCustId); 
        Map<String, Object> result;
        if(!Test.isRunningTest()){
            result = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(response));
        }
        else{
            result = (Map<String, Object>)JSON.deserializeUntyped('{"status":{"status_code":0},"card_statement":{"total_unbilled_amounts":0,"full_payment_amounts":4717.08,"min_payment_amounts":4717.08,"total_amount_due":4717.08,"minimum_due":4717.08,"interests":0,"cash_advance_fee":0,"total_cash_installment_records":0,"total_spending_installment_records":0,"due_date":"2023-08-09","statement_date":"2023-07-20","promotion_flag":"","point_available":2720.88,"statement_transactions":[{"transaction_code":0,"transaction_amounts":0,"posted_date":"","transaction_type":"","transaction_date":"","mcc_code":"","transaction_description":"","transaction_currency":"","transaction_source_amounts":0,"transaction_source_currency":""}],"point_remain":2720.88,"expiry_date":"0000-00-00","expiry_points":0,"total_spending_this_cycle":0},"total_records":0,"max_records":1,"more_records":"N","search_keys":""}');
        }

        Map<String, Object> returnMap = new Map<String, Object>(result);
        returnMap.put('card_statement', parseCard_statementWrapper(result,recordId));
        return (Object) returnMap;       
    }

    @AuraEnabled
    public static String getMakeValue(String functionName, String value){
        return RTL_ProductHoldingsLightningUtil.MakeValue(functionName, value);
    }

    @AuraEnabled
    public static String getUnmaskBalance(){
        return ProductingUnmaskingSetup.getProductUnmaskSetting();
    }    

    @AuraEnabled
    public static Object getSummaryCreditCardData(String accountId, String tmbCustId, String recordId){
        String reqBody = '{"query":{"accountId":"' + accountId + '"}}';
        String endpoint = 'callout:get_summary';  
        Object result = RTL_ProductHoldingsLightningUtil.getSummaryProductSCSCreditCard(endpoint, reqBody, tmbCustId);  
        Map<String,Object> getSumData; 
        String statusDesc;   
        if(!Test.isRunningTest()){
            getSumData = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(result));
            Map<String, Object> statusObj = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(getSumData.get('status')));
            statusDesc = String.valueOf(statusObj.get('description'));
        }
        else{
            getSumData = (Map<String,Object>)JSON.deserializeUntyped('{"creditCardInfo" : {  "totalAmountOfTransactions" : 0,  "totalNumberOfTransactions" : 0,  "amountOfInterestChargeTransactions" : "",  "numberOfInterestChargeTransactions" : "",  "amountOfNonInterestChargeTransactions" : "",  "numberOfNonInterestChargeTransactions" : "",  "usageBehavior" : "100:0",  "paymentBehavior" : "FULL"},"status" : {  "description" : "success",  "code" : "200"}}');
        }
        if(statusDesc != 'success'){
            return getSumData;
        }
        else{
            return parseSummaryCreditDataWrapper(getSumData, recordId);
        }
    }

    public class Card_statementWrapper{
        @AuraEnabled public String due_date{ get; set; }
    }

    private static Card_statementWrapper parseCard_statementWrapper(Map<String, Object> result, String recordId){
        Map<String, Boolean> fieldVisible = RTL_ProductHoldingSummaryController.getFieldVisibilityByPage(recordId, 'Credit Card / RDC Product Details');
        Map<String, Object> layer1 = (Map<String, Object>)result.get('card_statement');
        Card_statementWrapper wrapper = new Card_statementWrapper();
        String ddd = genDDMMYYYY(String.valueOf(layer1.get('due_date')));
        wrapper.due_date = fieldVisible.get('CCDetail_due_date') == false ? Label.Data_Condition_Hidden_Text : ddd == 'Invalid' ? String.valueOf(layer1.get('due_date')) : ddd;
        return wrapper;

    }

    public class SummaryCreditDataWrapper{
        @AuraEnabled public String amountOfInterestChargeTransactions{get; set;}
        @AuraEnabled public String amountOfNonInterestChargeTransactions{get; set;}
        @AuraEnabled public String numberOfInterestChargeTransactions{get; set;}
        @AuraEnabled public String numberOfNonInterestChargeTransactions{get; set;}
        @AuraEnabled public String paymentBehavior{get; set;}
        @AuraEnabled public String totalAmountOfTransactions{get; set;}
        @AuraEnabled public String totalNumberOfTransactions{get; set;}
        @AuraEnabled public String usageBehavior{get; set;}
    }

    private static Object parseSummaryCreditDataWrapper(Map<String, Object> creditCardInfoMap, String recordId){
        Map<String, Object> returnMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(creditCardInfoMap.get('creditCardInfo'))); 
        Map<String, Boolean> fieldVisible = RTL_ProductHoldingSummaryController.getFieldVisibilityByPage(recordId, 'Credit Card / RDC Product Details');
        SummaryCreditDataWrapper wrapper = new SummaryCreditDataWrapper();
        wrapper.paymentBehavior = fieldVisible.get('CCDetail_paymentBehavior') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(result.get('paymentBehavior'));
        wrapper.usageBehavior = fieldVisible.get('CCDetail_usageBehavior') == false ? Label.Data_Condition_Hidden_Text : String.valueOf(result.get('usageBehavior'));
        wrapper.amountOfInterestChargeTransactions = fieldVisible.get('CCDetail_amountOfInterestChargeTransactions') == false ? Label.Data_Condition_Hidden_Text : result.get('amountOfInterestChargeTransactions') == '' ? '0' : String.valueOf(result.get('amountOfInterestChargeTransactions'));
        wrapper.amountOfNonInterestChargeTransactions = fieldVisible.get('CCDetail_amountOfNonInterestChargeTransactions') == false ? Label.Data_Condition_Hidden_Text : result.get('amountOfNonInterestChargeTransactions') == '' ? '0' : String.valueOf(result.get('amountOfNonInterestChargeTransactions'));
        wrapper.numberOfInterestChargeTransactions = fieldVisible.get('CCDetail_numberOfInterestChargeTransactions') == false ? Label.Data_Condition_Hidden_Text : result.get('numberOfInterestChargeTransactions') == '' ? '0' : String.valueOf(result.get('numberOfInterestChargeTransactions'));
        wrapper.numberOfNonInterestChargeTransactions = fieldVisible.get('CCDetail_numberOfNonInterestChargeTransactions') == false ? Label.Data_Condition_Hidden_Text : result.get('numberOfNonInterestChargeTransactions') == '' ? '0' : String.valueOf(result.get('numberOfNonInterestChargeTransactions'));
        wrapper.totalAmountOfTransactions = fieldVisible.get('CCDetail_totalAmountOfTransactions') == false ? Label.Data_Condition_Hidden_Text : result.get('totalAmountOfTransactions') == '' ? '0' : String.valueOf(result.get('totalAmountOfTransactions'));
        wrapper.totalNumberOfTransactions = fieldVisible.get('CCDetail_totalNumberOfTransactions') == false ? Label.Data_Condition_Hidden_Text : result.get('totalNumberOfTransactions') == '' ? '0' : String.valueOf(result.get('totalNumberOfTransactions'));

        returnMap.put('creditCardInfo', wrapper);
        returnMap.put('status', creditCardInfoMap.get('status'));
        
        return (Object) returnMap;
    }

    public static String genDDMMYYYY(String dateStr){
        try{
            if(dateStr == '0000-00-00'){
                return '';
            }
            else{
                List<String> dList = dateStr.split('-');
                return dList[2] + '/' + dList[1] + '/' + dList[0];
            }
        }catch(Exception e){
            return 'Invalid';
        }
    }
}