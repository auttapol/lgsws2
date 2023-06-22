public with sharing class RTL_ProductHoldingWebSvcUtils extends AbstractCoreClass{

    public class AccessibleCusHold {
        @AuraEnabled
        public Boolean isAccessibleCusHoldLow {get;set;}
        @AuraEnabled
        public Boolean isAccessibleCusHoldMid {get;set;}
        @AuraEnabled
        public Boolean isAccessibleCusHoldHig {get;set;}

        public AccessibleCusHold(Boolean low, Boolean mid, Boolean hig) {
            this.isAccessibleCusHoldLow = low;
            this.isAccessibleCusHoldMid = mid;
            this.isAccessibleCusHoldHig = hig;
        }

    }
         
    private static final String SECTION_CUST_HOLD_LOW = 'RtlCust:Customer Product Holding (Low)';
    private static final String SECTION_CUST_HOLD_MID = 'RtlCust:Customer Product Holding (Medium)';
    private static final String SECTION_CUST_HOLD_HIG = 'RtlCust:Customer Product Holding (High)';

    private static SCSMessageAPIUtil.INTEGRATE_SYSTEM getIntegateSystem(String systemKey) {
        Map<String, SCSMessageAPIUtil.INTEGRATE_SYSTEM> systemIntegate = new Map<String, SCSMessageAPIUtil.INTEGRATE_SYSTEM> {
            'FloorPlan' => SCSMessageAPIUtil.INTEGRATE_SYSTEM.FloorPlan,
            'CoreHP' => SCSMessageAPIUtil.INTEGRATE_SYSTEM.CoreHP,
            'DWH' => SCSMessageAPIUtil.INTEGRATE_SYSTEM.DWH,
            'EC' => SCSMessageAPIUtil.INTEGRATE_SYSTEM.EC
        };
        return systemIntegate.containsKey(systemKey) ? systemIntegate.get(systemKey) : null;
    }

    private static final Map<string /*company name*/, BA_Insurance_Company__c> BAcompanyNames {
        get {
            if(BAcompanyNames == null){
                BAcompanyNames = BAInsuranceCompanyService.getAllBAInsuranceCompanies();
            }
            return BAcompanyNames;
        }
        set;
    }

    @AuraEnabled
    public static AccessibleCusHold getAccessibleCusHold(String accountId) {
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id = :userinfo.getProfileId() LIMIT 1];
        return new AccessibleCusHold(
            RTL_AccountUtility.verifyFieldSecurity(SECTION_CUST_HOLD_LOW, userProfile.name, accountId ),
            RTL_AccountUtility.verifyFieldSecurity(SECTION_CUST_HOLD_MID, userProfile.name, accountId ),
            RTL_AccountUtility.verifyFieldSecurity(SECTION_CUST_HOLD_HIG, userProfile.name, accountId )
        );
    }
    private static String APPID = AppConfig__c.getValues('APPID') == null ? 'A0291' : AppConfig__c.getValues('APPID').Value__c;
    private static final Integer timeout {
        get {
            // 120000 ms
            if(timeout == null){
                List<App_Config__mdt> productHoldingTimeOut = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'ProductHolding_TIMEOUT_INT_SECS'];
                timeout = productHoldingTimeOut != null && productHoldingTimeOut.size() > 0 ? Integer.valueOf(productHoldingTimeOut.get(0).Value__c) * 1000 : 120000;
            }
            return timeout;
        }
        set;
    }

    private static Boolean isEmployee(String tmbCustId) {
        try {
            return [SELECT RTL_Is_Employee__c FROM Account WHERE TMB_Customer_ID_PE__c = :tmbCustId LIMIT 1 FOR UPDATE].RTL_Is_Employee__c;
        } catch (Exception e) {
            return false;
        }
    }

    private static Account getAccount(String RMID) {
        try {
            // return [SELECT Id, Name, Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c = :RMID LIMIT 1];
            return [SELECT Id, Name, Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c = :RMID LIMIT 1 FOR UPDATE];
        } catch (Exception e) {
            return new Account();
        }
    }

    private static final Map<String /*product code*/, RTLProductMasterDTO> OnlyProductWithProductCode {
        get {
            if(OnlyProductWithProductCode == null){
                OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
            }
            return OnlyProductWithProductCode;
        }
        set;
    }

    private static void saveOnlineSerivceLogProductHolding(Object state, HttpResponse res, String ServiceName) {
        String StatusCode = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('Status.StatusCode', JSON.deserializeUntyped(res.getBody()))) : '';
        String StatusDesc = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('Status.StatusDesc', JSON.deserializeUntyped(res.getBody()))) : '';
        Boolean isSuccess = res != null && String.isNotEmpty(res.getBody()) ? StatusCode == '200' && !StatusDesc.contains('java.lang.Exception') : false;
        Account AccountObj = (Account)JSON.deserialize(JSON.serialize(getResult('Account', state)), Account.Class);
        RTL_CampaignUtil.saveToOnlineLog(
            isSuccess,
            AccountObj != null ? AccountObj.Name : '', // customerName
            String.isNotEmpty(StatusDesc) ? StatusDesc : (res != null ? Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()) : 'Null response'),
            '', // msLogId
            UserInfo.getName(),
            (String)getResult('RMID', state),
            ServiceName,
            // (String)JSON.serializePretty(JSON.deserializeUntyped((String)getResult('body', state))), // Request Body
            parseLogOSCServiceRegEx((String)JSON.serializePretty(JSON.deserializeUntyped((String)getResult('body', state))), ServiceName), // Request Body
            // String.isNotEmpty(res.getBody()) ? parseLogOSCService(res.getBody(), ServiceName) : '', // Response Body
            res != null && String.isNotEmpty(res.getBody()) ? parseLogOSCServiceRegEx(res.getBody(), ServiceName) : '', // Response Body
            AccountObj,
            Datetime.valueofGmt(((String)getResult('StartTime', state)).replace('T', ' ').replace('Z', ' ')), // Start datetime; convert to GMT locale time
            Datetime.now() // End datetime
        );
    }

    // V2 Save online service log when throw exception
    private static void saveOnlineSerivceLogProductHolding(Object state, HttpResponse res, String ServiceName, String errorMsg) {
        // String StatusCode = String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('Status.StatusCode', JSON.deserializeUntyped(res.getBody()))) : '';
        // String StatusDesc = String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('Status.StatusDesc', JSON.deserializeUntyped(res.getBody()))) : '';
        // Boolean isSuccess = String.isNotEmpty(res.getBody()) ? StatusCode == '200' && !StatusDesc.contains('java.lang.Exception') : false;
        Account AccountObj = (Account)JSON.deserialize(JSON.serialize(getResult('Account', state)), Account.Class);
        RTL_CampaignUtil.saveToOnlineLog(
            false,
            AccountObj != null ? AccountObj.Name : '', // customerName
            errorMsg,
            '', // msLogId
            UserInfo.getName(),
            (String)getResult('RMID', state),
            ServiceName,
            // (String)JSON.serializePretty(JSON.deserializeUntyped((String)getResult('body', state))), // Request Body
            parseLogOSCServiceRegEx((String)JSON.serializePretty(JSON.deserializeUntyped((String)getResult('body', state))), ServiceName), // Request Body
            // String.isNotEmpty(res.getBody()) ? parseLogOSCService(res.getBody(), ServiceName) : '', // Response Body
            res != null && String.isNotEmpty(res.getBody()) ? parseLogOSCServiceRegEx(res.getBody(), ServiceName) : '', // Response Body
            AccountObj,
            Datetime.valueofGmt(((String)getResult('StartTime', state)).replace('T', ' ').replace('Z', ' ')), // Start datetime; convert to GMT locale time
            Datetime.now() // End datetime
        );
    }

    private static void saveOnlineServiceLog(Boolean isSuccess, String errorMsg, Object state, HttpResponse res, String responseBody) {
        String tmbCustId = (String)getResult('tmbCustId', state);
        String uuid = (String)getResult('uuid', state);
        List<SObject> sobjList = [SELECT Id, Name, TMB_Customer_ID_PE__c, Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c = :tmbCustId FOR UPDATE];
        Account acct = sobjList.size() > 0 ? (Account)sobjList.get(0) : null;
        
        List<String> endPointList = String.valueOf(getResult('endpoint', state)).remove('callout:').split('\\?');
        Map<String, String> namedCredentialMap = new Map<String, String>();
        for(NamedCredential each : [SELECT Endpoint,DeveloperName FROM NamedCredential]){
            namedCredentialMap.put(each.DeveloperName, each.Endpoint);
        }
        String setEndpoint = namedCredentialMap.containsKey(endPointList.get(0)) ? namedCredentialMap.get(endPointList.get(0)) : '';
        setEndpoint = setEndpoint != '' && endPointList.size() > 1 ? String.format('{0}?{1}', new List<String>{
            setEndpoint, endPointList.get(1)
        }) : setEndpoint;

        RTL_CampaignUtil.saveToOnlineLog(
                isSuccess,
                acct != null ? acct.Name : '', // customerName
                errorMsg, // Error message
                uuid, // msLogId (UUID Get from header)
                UserInfo.getName(),
                tmbCustId != null ? tmbCustId : (String)acct.get('TMB_Customer_ID_PE__c'), // RMId (tmbCustId)
                setEndpoint,
                serializePrettyString((String)getResult('body', state)), // Request Body
                serializePrettyString(responseBody), // Response Body
                acct, // Account
                Datetime.valueofGmt(((String)getResult('startDateTime', state)).replace('T', ' ').replace('Z', ' ')), //first callProduct
                Datetime.now() // End datetime
            );
    }

    public static String parseLogOSCServiceRegEx(String body, String servicename) {
        // initialize information
        Object objBody = JSON.deserializeUntyped(body);
        String regEx = new Map<String, String>{
            'CustomerAccount - OSC01' => '\"(AccountNumber|CardNumber)\"\\s*[:]\\s*\"([0-9]\\w+)\"',
            'DepositAccount - OSC02' => '\"(AccountNumber|AcctId)\"\\s*[:]\\s*\"([0-9]\\w+)\"',
            'CreditCardAccount - OSC03' => '\"(CashWithdrawalAccountNumber|DirectDebitAccountNumber|CardNumber|CardId|CardID)\"\\s*[:]\\s*\"([0-9]\\w+)\"',
            'LoanAccount - OSC04' => '\"(AccountNumber|AcctId)\"\\s*[:]\\s*\"([0-9]\\w+)\"'
            ,'get_cards_balances' => '\"(available_to_transfer)\"\\s*[:]\\s*\"([0-9][0-9.]*[0-9])\"'
            ,'get_card' => '\"(direct_deposit_account)\"\\s*[:]\\s*\"([0-9][0-9.]*[0-9])\"'

        }.get(servicename);
        String link = new Map<String, String> {
            'CustomerAccount - OSC01' => 'OSC01',
            'DepositAccount - OSC02' => 'OSC02',
            'CreditCardAccount - OSC03' => 'OSC03',
            'LoanAccount - OSC04' => 'OSC04'
            ,'get_cards_balances' => 'getCardsBalance'
            ,'get_card' => 'getCard'
        }.get(servicename);

        // seperate type product
        Map<String, String> keyDataOSC01 = new Map<String, String>{
            'DepositAccount' => 'AccountNumber',
            'CreditCardAccount' => 'CardNumber',
            'LoanAccount' => 'AccountNumber'
        };

        Map<String, Object> DataOSC = new Map<String, Map<String, Object>>{
            'CustomerAccount - OSC01' => servicename == 'CustomerAccount - OSC01' ? new Map<String, Object>{
                'DepositAccount' => isNotEmpty((List<Object>)getResult('GetCustomerAccountResponse.DepositAccounts.DepositAccount', objBody)) ? getResult('GetCustomerAccountResponse.DepositAccounts.DepositAccount', objBody) : new List<Object>(),
                'CreditCardAccount' => isNotEmpty((List<Object>)getResult('GetCustomerAccountResponse.CreditCardAccounts.CreditCardAccount', objBody)) ? getResult('GetCustomerAccountResponse.CreditCardAccounts.CreditCardAccount', objBody) : new List<Object>(),
                'LoanAccount' => isNotEmpty((List<Object>)getResult('GetCustomerAccountResponse.LoanAccounts.LoanAccount', objBody)) ? getResult('GetCustomerAccountResponse.LoanAccounts.LoanAccount', objBody) : new List<Object>()
            } : null
        }.get(servicename);

        Map<String, String> transformValueMap = new Map<String, String>{
            // Product Summary OSC01
            'DepositAccount' => 'MarkedDepositAccountNumber',
            'CreditCardAccount' => 'MarkedCardNumber',
            'LoanAccount' => 'MarkedLoanAccountNumber',
            // Deposit - OSC02
            (link == 'OSC02' ? link : '') + 'AccountNumber' => 'MarkedDepositAccountNumber',
            (link == 'OSC02' ? link : '') + 'AcctId' => 'MarkedDepositAccountNumber',
            // Credit Card
            'CashWithdrawalAccountNumber' => 'MarkedCashWithdrawalAccountNumber',
            'DirectDebitAccountNumber' => 'MarkedDirectDebitAccountNumber',
            'CardNumber' => 'MarkedCardNumber',
            'CardId' => 'MarkedCardNumber',
            'CardID' => 'MarkedCardNumber', // In request body
            // Loan - OSC04
            (link == 'OSC04' ? link : '') + 'AccountNumber' => 'MarkedLoanAccountNumber',
            (link == 'OSC04' ? link : '') + 'AcctId' => 'MarkedLoanAccountNumber',
            (link == 'OSC04' ? link : '') + 'SavingAccount' => 'MarkedSavingAccount',
            // M8 Credit Card
            // 'available_to_transfer' => 'Masked_available_to_transfer',
            'direct_deposit_account' => 'Masked_direct_deposit_account',
            'identification_id' => 'Masked_identification_id'
        };


        if(regEx != null) {
            Matcher m = Pattern.compile(regEx).matcher(body);
            while (m.find()) {
                String key = m.group(1);
                String value = m.group(2);
                String valueRegEx = m.group(2);
                if(link == 'OSC01') {
                    // 'Account No' => 'Key of Product type'
                    Map<String, String> valuesMap = new Map<String, String>();
                    for (String keyDataOSC : DataOSC.keySet()) {
                        for (Object valueDataOSC : (List<Object>)DataOSC.get(keyDataOSC)) {
                            String AccountNo = (String)((Map<String, Object>)valueDataOSC).get(keyDataOSC01.get(keyDataOSC));
                            valuesMap.put(AccountNo, keyDataOSC);
                        }
                    }
                    key = valuesMap.get(value);
                }
                else if (link == 'OSC02') {
                    key = link + key;
                }
                else if (link == 'OSC04') {
                    value = new Map<String, String>{
                        'SavingAccount' => key == 'SavingAccount' ? value : '',
                        'AccountNumber' => key == 'AccountNumber' ? value.substring(1).reverse().substring(3).reverse() : '',
                        'AcctId' => key == 'AcctId' ? value.substring(17).reverse().substring(3).reverse() : ''
                    }.get(key);
                    key = link + key;
                }
                else if (link == 'getCardsBalance') {
                    value = new Map<String, String>{
                        // 'available_to_transfer'=> key == 'available_to_transfer' ? value : ''
                    }.get(key);
                }
                else if (link == 'getCard') {
                    value = new Map<String, String>{
                        'direct_deposit_account'=> key == 'direct_deposit_account' ? value : ''
                    }.get(key);
                }
                
                body = transformValueMap.containsKey(key) ? body.replace(valueRegEx, MakeValue(transformValueMap.get(key), value)) : body;
            }
        }
        return body;
    }

    @AuraEnabled
    public static String MakeValue(String functionName, String value){
        return new Map<String, String>{
            // Deposit
            'MarkedDepositAccountNumber' => functionName == 'MarkedDepositAccountNumber' ? NumberHelper.MarkAccountNo(NumberHelper.TrimDepositAccountNo(value)) : '',
            // Credit Card / RDC
            'MarkedCardNumber' => functionName == 'MarkedCardNumber' ? NumberHelper.MarkCardNo(NumberHelper.TrimCardNo(value)) : '',
            'MarkedCashWithdrawalAccountNumber' => functionName == 'MarkedCashWithdrawalAccountNumber' ? NumberHelper.MarkAccountNo(NumberHelper.TrimDirectDebit(value)) : '',
            'MarkedDirectDebitAccountNumber' => functionName == 'MarkedDirectDebitAccountNumber' ?  NumberHelper.MarkAccountNo(NumberHelper.TrimDirectDebit(value)) : '',
            'MarkedCurrentBalance' => functionName == 'MarkedCurrentBalance' ? NumberHelper.MarkDecimal(Decimal.valueOf(value)) : '',
            // Bancassurance
            'BAPlan' => functionName == 'BAPlan' ? (OnlyProductWithProductCode.containsKey(value) ? OnlyProductWithProductCode.get(value).Asset_Class : '') : '',
            'Address' => functionName == 'Address' ? (BAcompanyNames.containsKey(value) ? BAcompanyNames.get(value).Address__c : '') : '',
            'ContactNumber1' => functionName == 'ContactNumber1' ? (BAcompanyNames.containsKey(value) ? BAcompanyNames.get(value).ContactNo1__c : '') : '',
            'ContactNumber2' => functionName == 'ContactNumber2' ? (BAcompanyNames.containsKey(value) ? BAcompanyNames.get(value).ContactNo2__c : '') : '',
            // Loan
            'MarkedLoanAccountNumber' => functionName  == 'MarkedLoanAccountNumber' ? NumberHelper.MarkAccountNo(NumberHelper.TrimLoanAccountNo(value)) : '',
            'MarkedSavingAccount' => functionName  == 'MarkedSavingAccount' ? NumberHelper.MarkAccountNo(NumberHelper.TrimDepositAccountNo(value)) : '',
            'translatedPaymentMethod' => functionName  == 'translatedPaymentMethod' ? (RTL_Payment_Method__c.getValues(value) != null ? RTL_Payment_Method__c.getValues(value).Value__c : '') : ''
            // M8 Credit Card
            ,'Masked_available_to_transfer' => functionName == 'Masked_available_to_transfer' ? NumberHelper.MarkDecimal(Decimal.valueOf(value)) : ''
            ,'Masked_direct_deposit_account' => functionName == 'Masked_direct_deposit_account' ? NumberHelper.MarkAccountNo(NumberHelper.TrimDirectDebit(value)) : ''
        }.get(functionName);
    }

    @AuraEnabled
    public static String callOSC05(String rmId, String tmbCustId){
        String reqBody = '{"GetBancassuranceAccountRequest":{"RMID":"' + rmId + '"}}';
        Http http = new Http();
        Datetime StartTime = (Datetime)Datetime.now();
        Uuid uuidGenerateor = new Uuid();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
        req.setHeader('Request-UID', uuidGenerateor.getValue());
        req.setHeader('Request-App-ID', APPID);
        req.setEndpoint('callout:OSC05_List');
        req.setBody(reqBody);
        req.setTimeout(timeout);

        Map<String, Object> state = new Map<String, Object>{
            'isEmployee' => isEmployee(tmbCustId),
            'body' => reqBody,
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => tmbCustId,
            'Account' => getAccount(tmbCustId)
        };

        HttpResponse res = http.send(req);
        String responseBody = res.getBody();
        saveOnlineSerivceLogProductHolding(state, res, 'BancassuranceAccount - OSC05 High Level', true);

        return responseBody ;
    }

    public static void saveOnlineSerivceLogProductHolding(Object state, HttpResponse res, String ServiceName, Boolean subMessage) {   // Add by support SCR0560980
        String StatusCode = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('Status.StatusCode', JSON.deserializeUntyped(res.getBody()))) : '';
        String StatusDesc = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('Status.StatusDesc', JSON.deserializeUntyped(res.getBody()))) : '';
        if (StatusCode == '200') {
            if (ServiceName == 'BancassuranceAccount - OSC05 High Level') {
                Schema_Json_Result__mdt JsonResult = RTL_ProductHoldingsLightningUtil.JsonResultTagList('OSC05_List');
                StatusCode = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult(JsonResult.Tag_Result_Code__c, JSON.deserializeUntyped(res.getBody()))) : '';
                StatusDesc = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult(JsonResult.Tag_Result_Desc__c, JSON.deserializeUntyped(res.getBody()))) : '';
            }else if (ServiceName == 'BancassuranceAccount - OSC05 Low Level') {
                Schema_Json_Result__mdt JsonResult = RTL_ProductHoldingsLightningUtil.JsonResultTagList('OSC05_Detail');
                StatusCode = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult(JsonResult.Tag_Result_Code__c, JSON.deserializeUntyped(res.getBody()))) : '';
                StatusDesc = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult(JsonResult.Tag_Result_Desc__c, JSON.deserializeUntyped(res.getBody()))) : '';
            }           
        }
        Boolean isSuccess = res != null && String.isNotEmpty(res.getBody()) ? StatusCode == '200' && !StatusDesc.contains('java.lang.Exception') : false;
        Account AccountObj = (Account)JSON.deserialize(JSON.serialize(getResult('Account', state)), Account.Class);
        RTL_CampaignUtil.saveToOnlineLog(
            isSuccess,
            AccountObj != null ? AccountObj.Name : '', // customerName
            String.isNotEmpty(StatusDesc) ? StatusDesc : (res != null ? String.valueOf(getResult('Status.StatusDesc', JSON.deserializeUntyped(res.getBody()))) : 'Null response'),
            '', // msLogId
            UserInfo.getName(),
            (String)getResult('RMID', state),
            ServiceName,
            parseLogOSCServiceRegEx((String)JSON.serializePretty(JSON.deserializeUntyped((String)getResult('body', state))), ServiceName), // Request Body
            res != null && String.isNotEmpty(res.getBody()) ? parseLogOSCServiceRegEx(res.getBody(), ServiceName) : '', // Response Body
            AccountObj,
            Datetime.valueofGmt(((String)getResult('StartTime', state)).replace('T', ' ').replace('Z', ' ')), // Start datetime; convert to GMT locale time
            Datetime.now() // End datetime
        );
    }

    @AuraEnabled
    public static Object calloutOSC06List(String unitHolderNo, String tmbCustId){
        String reqBody = '{"GetInvestmentAccountRequest":{"UnitHolderNo":"' + unitHolderNo + '"}}';
        Http http = new Http();

        Map<String, Object> state = new Map<String, Object>{
            'isEmployee' => isEmployee(tmbCustId),
            'body' => reqBody,
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => tmbCustId,
            'Account' => getAccount(tmbCustId)
        };

        Uuid uuidGenerateor = new Uuid();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
        req.setHeader('Request-UID', uuidGenerateor.getValue());
        req.setHeader('Request-App-ID', APPID);
        req.setEndpoint('callout:OSC06_List');
        req.setBody(reqBody);
        req.setTimeout(timeout);

        HttpResponse res = http.send(req);
        saveOnlineSerivceLogProductHolding(state, res, 'InvestmentAccount - OSC06 High Level');
        String responseBody = res.getBody();
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        try{
            List<Object> products = (List<Object>)getResult('GetInvestmentAccountResponse.GetFundDetails', result);
            Object fundClasses = getResult('GetInvestmentAccountResponse.listFundClass', result) instanceOf List<Object> ? (List<Object>)getResult('GetInvestmentAccountResponse.listFundClass', result) : new List<Object>{ getResult('GetInvestmentAccountResponse.listFundClass', result) };
            result = (Map<String, Object>)putObject('InvestmentAccount', deserializeObject(transformInvestmentProductDTO(products, (List<Object>)fundClasses, OnlyProductWithProductCode)), result);
            return (Object) result ;
        }
        catch(Exception e){
            return (Object) result ;
            // throw new IllegalArgumentException(responseBody);
        }
    }

    @AuraEnabled
    public static String callOSC01(String rmId, String FiiDent, String tmbCustId){
        System.debug('callbackOSC01');
        String reqBody = '{"GetCustomerAccountRequest":{"RMID":"' + rmId +'", "FIIdent":"' + FiiDent + '"}}';
        System.debug('reqBody : '+reqBody);
        String responseBody = '';
        Datetime StartTime = (Datetime)Datetime.now();
        Http http = new Http();
        Uuid uuidGenerateor = new Uuid();
        HttpRequest req = new HttpRequest();
        try {
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
            req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
            req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
            req.setHeader('Request-UID', uuidGenerateor.getValue());
            req.setHeader('Request-App-ID', APPID);
            req.setEndpoint('callout:OSC01');
            req.setBody(reqBody);
            req.setTimeout(timeout);
    
            HttpResponse res = http.send(req);
            responseBody += res.getBody();
    
            return res.getBody();

        }catch (Exception e) {
            String errorMsg = '';
            errorMsg += '\nSystem error : ' + e.getMessage();
            errorMsg += '\nStack Trace : ' + e.getStackTraceString();
            responseBody += errorMsg;
            System.debug(responseBody);
            throw new AuraHandledException(responseBody);
        }
       
        // return '';
    }

    public static Object callbackOSC02(String accountNumber,String accountType,String productType, String rmId, String fiiDent, String tmbCustId){
        String reqBody = '{"GetDepositAccountRequest":{"RMID":"' + rmId +'", "FIIdent":"' + fiiDent + '", "AccountNumber":"' + accountNumber + '", "AccountType":"' + accountType +'", "ProductType":"' + productType + '"}}';
        String responseBody = '';
        Datetime StartTime = (Datetime)Datetime.now();

        Map<String, Object> state = new Map<String, Object>{
            'isEmployee' => isEmployee(tmbCustId),
            'body' => reqBody,
            'StartTime' => StartTime,
            'RMID' => tmbCustId,
            'Account' => getAccount(tmbCustId)
        };
        Http http = new Http();
        Uuid uuidGenerateor = new Uuid();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        if (!Test.isRunningTest()) {
            req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        }
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
        req.setHeader('Request-UID', uuidGenerateor.getValue());
        req.setHeader('Request-App-ID', APPID);
        req.setEndpoint('callout:OSC02');
        req.setBody(reqBody);
        req.setTimeout(timeout);
        
        HttpResponse res = http.send(req);
        saveOnlineSerivceLogProductHolding(state, res, 'DepositAccount - OSC02');
        responseBody = res.getBody();

        try{
            System.debug('responseBody : '+responseBody);
            if(String.isEmpty(res.getBody())) {
                return new Map<String, Object>{
                    'StatusDesc' => res.getStatus(),
                    'Message' => System.Label.ERR002,
                    'Timeout' => true,
                    'StatusCode' => res.getStatusCode(),
                    'StatusDescContinuation' => Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode())
                    // 'StatusCode' => 2000,
                    // 'StatusDescContinuation' => Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(2000)
                };
            }
            Map<String,Object> resultMap = new Map<String,Object>();
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('Status.StatusCode', result) : '404');
            System.debug('StatusCode : '+StatusCode);
            if (StatusCode != '200' || ((Map<String, Object>)getResult('GetDepositAccountDetailResponse.Result', result)).isEmpty()) {
                Object Status = getResult('Status', result);
                Status = putObject('StatusDescContinuation', Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), Status);
                Status = putObject('Message', System.Label.ERR001, Status);
                Status = (Map<String, Object>)putObject('State', state, Status);
                System.debug('Status : '+JSON.serialize(Status));

                return Status;
            }
    
            System.debug('result : '+JSON.serialize(result));

            return result;
        }catch (Exception e) {
            String errorMsg = '';
            errorMsg += '\nSystem error : ' + e.getMessage();
            errorMsg += '\nStack Trace : ' + e.getStackTraceString();
            responseBody += errorMsg;

            saveOnlineSerivceLogProductHolding(state, res, 'LoanAccount - OSC04', errorMsg);
            System.debug(responseBody);
            throw new AuraHandledException(responseBody);
        }   
    }

    public static Object callbackOSC04(String accountNumber,String accountType, String rmId, String fiiDent, String tmbCustId){
        String reqBody = '{"GetLoanAccountRequest":{"RMID":"' + rmId +'", "FIIdent":"' + FiiDent + '", "AccountNumber":"' + accountNumber + '", "AccountType":"' + accountType +'", "ProductType":"' + '' + '"}}';
        String responseBody = '';
        Datetime StartTime = (Datetime)Datetime.now();

        Map<String, Object> state = new Map<String, Object>{
            'isEmployee' => isEmployee(tmbCustId),
            'body' => reqBody,
            'StartTime' => StartTime,
            'RMID' => tmbCustId,
            'Account' => getAccount(tmbCustId)
        };
        Boolean isError = true;
        Http http = new Http();
        Uuid uuidGenerateor = new Uuid();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        if (!Test.isRunningTest()) {
            req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        }
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
        req.setHeader('Request-UID', uuidGenerateor.getValue());
        req.setHeader('Request-App-ID', APPID);
        req.setEndpoint('callout:OSC04');
        req.setBody(reqBody);
        req.setTimeout(timeout);
    
        HttpResponse res = http.send(req);
        try{
            responseBody = res.getBody();
            System.debug('responseBody : '+responseBody);
            saveOnlineSerivceLogProductHolding(state, res, 'LoanAccount - OSC04');
            if(String.isEmpty(res.getBody())) {
            // if (true) {
                return new Map<String, Object>{
                    'StatusDesc' => res.getStatus(),
                    'Message' => System.Label.ERR002,
                    'Timeout' => true,
                    'StatusCode' => res.getStatusCode(),
                    'StatusDescContinuation' => Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode())
                };
            }
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('Status.StatusCode', result) : '404');
            if (StatusCode != '200' || ((Map<String, Object>)getResult('GetLoanAccountResponse', result)).isEmpty()) {
                Object Status = getResult('Status', result);
                Status = putObject('StatusDescContinuation', Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), Status);
                Status = putObject('Message', System.Label.ERR001, Status);
                Status = (Map<String, Object>)putObject('State', state, Status);
                return Status;
            }
    
            return result;
        }catch (Exception e) {
            String errorMsg = '';
            errorMsg += '\nSystem error : ' + e.getMessage();
            errorMsg += '\nStack Trace : ' + e.getStackTraceString();
            responseBody += errorMsg;

            saveOnlineSerivceLogProductHolding(state, res, 'LoanAccount - OSC04', errorMsg);
            System.debug(responseBody);
            throw new AuraHandledException(responseBody);
        }   
    }

    private static List<Object> transformInvestmentProductDTO(List<Object> Products, List<Object> fundClasses, Map<String, RTLProductMasterDTO> OnlyProductWithProductCode) {
        List<Object> returnList = new List<Object>();
        for (Object obj : Products) {
            InvestmentProductDTO prod = new InvestmentProductDTO();
            prod.UnitHolderNo = (String)getResult('detailFund.UnitHolderNo', obj);
            prod.FundCode = (String)getResult('FundCode', obj);
            // prod.IssuerFundHouse = (String)getResult('detailFund.FundHouseCode', obj);
            // prod.OpenedDate = getResult('detailFund.DateAsOf', obj) != null ? Date.valueOf((String)getResult('detailFund.DateAsOf', obj)) : null;
            prod.MarketValue = String.isNotEmpty((String)getResult('detailFund.InvestmentValue', obj)) ? Decimal.valueOf((String)getResult('detailFund.InvestmentValue', obj)) : 0;
            prod.UnrealizedGL = String.isNotEmpty((String)getResult('detailFund.UnrealizedProfit', obj)) ? Decimal.valueOf((String)getResult('detailFund.UnrealizedProfit', obj)) : 0;
            prod.CostOfInvestment = String.isNotEmpty((String)getResult('detailFund.Cost', obj)) ? Decimal.valueOf((String)getResult('detailFund.Cost', obj)) : 0;
            prod.NumberOfUnit = String.isNotEmpty((String)getResult('detailFund.Unit', obj)) ? Decimal.valueOf((String)getResult('detailFund.Unit', obj)) : 0;
            prod.NavUnit = String.isNotEmpty((String)getResult('detailFund.Nav', obj)) ? Decimal.valueOf((String)getResult('detailFund.Nav', obj)) : 0;
            prod.UnitLtf5y = String.isNotEmpty((String)getResult('detailFund.UnitLTF5Y', obj)) ? (String)getResult('detailFund.UnitLTF5Y', obj) == '1' : false;

            String productcode = prod.FundCode != null ? prod.FundCode : '';
            prod.ProductName = prod.UnitHolderNo != null && String.isNotEmpty(productcode) && OnlyProductWithProductCode.containsKey(productcode) ?  OnlyProductWithProductCode.get(productcode).Name : '#N/A';
            prod.SubProductGroup = prod.UnitHolderNo != null && String.isNotEmpty(productcode) && OnlyProductWithProductCode.containsKey(productcode) ?  OnlyProductWithProductCode.get(productcode).Product_Sub_group : '#N/A';
            prod.AssetClass = prod.UnitHolderNo != null && String.isNotEmpty(productcode) && OnlyProductWithProductCode.containsKey(productcode) ?  OnlyProductWithProductCode.get(productcode).Asset_Class : '#N/A';
            prod.SeqGrp = prod.UnitHolderNo != null && String.isNotEmpty(productcode) && OnlyProductWithProductCode.containsKey(productcode) ?  OnlyProductWithProductCode.get(productcode).SEQ_GRP : 'OTHERS';
            prod.IssuerFundHouse = prod.UnitHolderNo != null && String.isNotEmpty(productcode) && OnlyProductWithProductCode.containsKey(productcode) ?  OnlyProductWithProductCode.get(productcode).Issuer_Fund_House : '#N/A';

            Object InvestmentProductObj = (Object)prod;
            String UnrealizedProfitPerc = (String)getResult('detailFund.UnrealizedProfitPerc', obj);
            InvestmentProductObj = putObject('UnrealizedGLPerc', UnrealizedProfitPerc != null && String.isNotEmpty(UnrealizedProfitPerc) ? (Decimal)Decimal.valueOf(UnrealizedProfitPerc) : 0, InvestmentProductObj);
            returnList.add(InvestmentProductObj);
        }
        return returnList;
    }

    public static Object calloutAutoLoan_HpFleetHpList(String company, String rmId, String hpType, String tranDate, String tranTime, String recordId, object state){
        String dataDecrypt;
        String bodyEncrypt;
        String body = '{"Company":"' + company + '","RMID":"' + rmId + '","HPType":"' + hpType + '","TranDate":"' + tranDate + '","TranTime":"' + tranTime + '"}';
        String privateKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), getIntegateSystem('CoreHP'));
        // String bodyEncrypt = (String)SCSMessageAPIUtil.encryptMessageWithKey(body, privateKey);

        Http http = new Http();
        Uuid uuidGenerateor = new Uuid();
        HttpRequest req = new HttpRequest();
        if (Test.isRunningTest()){
            bodyEncrypt = body;
        } else {
            bodyEncrypt = (String)SCSMessageAPIUtil.encryptMessageWithKey(body, privateKey);
        }
        req.setMethod('POST');
        if (!Test.isRunningTest()) {
            req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        }
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
        req.setHeader('Request-UID', uuidGenerateor.getValue());
        req.setHeader('Request-App-ID', APPID);
        req.setEndpoint('callout:AutoLoan_HpFleetHpList');
        req.setBody(bodyEncrypt);
        req.setTimeout(timeout);

        HttpResponse res = http.send(req);

        Map<String, Object> result = new Map<String, Object>();
        if(!String.isEmpty(res.getBody())) {
            if (!Test.isRunningTest()) {
                dataDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(res.getBody(), privateKey);
                result = dataDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(dataDecrypt) : result;
            }
            else{
                result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            }
        }
        // if(!String.isEmpty(res.getBody())) {
            // dataDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(res.getBody(), privateKey);
            // result = dataDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(dataDecrypt) : result;
        // }

        String StatusCode = String.valueOf(!result.isEmpty() ? getResult('RES.RESPONSECODE', result) : '');
        String ErrorMsg = String.valueOf(!result.isEmpty() ? getResult('RES.RESPONSEMESSAGE', result) : getValuesWithRegex(res.getBody(), new List<String>{'StatusDesc', 'errordesc'}));
        Boolean isSuccess = new List<String>{'HP001', 'HP020'}.contains(StatusCode);

        result = (Map<String, Object>)putObject('isError', !isSuccess, result);
        result = (Map<String, Object>)putObject('HTTPStatusCode', res.getStatusCode(), result);
        return (Object)result;
    }


    public static Object calloutAutoLoan_HpFeetHpDetail(String body){
        String dataDecrypt;
        String privateKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), getIntegateSystem('CoreHP'));
        String bodyEncrypt;

        Http http = new Http();
        Uuid uuidGenerateor = new Uuid();
        HttpRequest req = new HttpRequest();
        if (Test.isRunningTest()){
            bodyEncrypt = body;
        } else {
            bodyEncrypt = (String)SCSMessageAPIUtil.encryptMessageWithKey(body, privateKey);
        }
        req.setMethod('POST');
        if (!Test.isRunningTest()) {
            req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        }
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
        req.setHeader('Request-UID', uuidGenerateor.getValue());
        req.setHeader('Request-App-ID', APPID);
        req.setEndpoint('callout:AutoLoan_HpFleetHpDetail');
        req.setBody(bodyEncrypt);
        req.setTimeout(timeout);

        HttpResponse res = http.send(req);

        Map<String, Object> result = new Map<String, Object>();
        if(!String.isEmpty(res.getBody())) {
            if (!Test.isRunningTest()) {
                dataDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(res.getBody(), privateKey);
                result = dataDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(dataDecrypt) : result;
            }
            else{
                result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            }
        }

        String StatusCode = String.valueOf(!result.isEmpty() ? getResult('RES.RESPONSECODE', result) : '');
        String ErrorMsg = String.valueOf(!result.isEmpty() ? getResult('RES.RESPONSEMESSAGE', result) : getValuesWithRegex(res.getBody(), new List<String>{'StatusDesc', 'errordesc'}));
        Boolean isSuccess = new List<String>{'HP001', 'HP020'}.contains(StatusCode);

        result = (Map<String, Object>)putObject('isError', !isSuccess, result);
        result = (Map<String, Object>)putObject('HTTPStatusCode', res.getStatusCode(), result);
        return (Object)result;
    }

    @AuraEnabled
    public static Object callOSC03(String rmId, String more_records, String search_keys, String user_interface, String tmbCustId){
        String serviceName = 'get-cards-balances';
        String endpoint = 'callout:get_cards_balances';
        String reqBody = '{"query":{"rm_id":"'+rmId+'","more_records":"'+more_records+'","search_keys":"'+search_keys+'","user_interface":"'+user_interface+'"}}';
        Object result = RTL_ProductHoldingsLightningUtil.getProductSCSCreditCard(endpoint, reqBody, tmbCustId);

        return result ;
    }

    public static String callOSC05Detail(String reqBody, String tmbCustId){
        Http http = new Http();
        Datetime StartTime = (Datetime)Datetime.now();
        Uuid uuidGenerateor = new Uuid();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        if (!Test.isRunningTest()) {
            req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        }
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
        req.setHeader('Request-UID', uuidGenerateor.getValue());
        req.setHeader('Request-App-ID', APPID);
        req.setEndpoint('callout:OSC05_Detail');
        req.setBody(reqBody);
        req.setTimeout(timeout);

        Map<String, Object> state = new Map<String, Object>{
            'isEmployee' => isEmployee(tmbCustId),
            'body' => reqBody,
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => tmbCustId,
            'Account' => getAccount(tmbCustId)
        };

        HttpResponse res = http.send(req);
        String responseBody = res.getBody();
        saveOnlineSerivceLogProductHolding(state, res, 'BancassuranceAccount - OSC05 Low Level', true);

        return responseBody ;
    }

    @AuraEnabled
    public static Object calloutOSC06Detail(String unitHolderNo, String fundCode, String tmbCustId){
        String reqBody = '{"GetInvestmentAccountRequest":{"UnitHolderNo":"' + unitHolderNo + '","FundCode":"' + fundCode + '"}}';
        Http http = new Http();

        Map<String, Object> state = new Map<String, Object>{
            'isEmployee' => isEmployee(tmbCustId),
            'body' => reqBody,
            'StartTime' => (Datetime)Datetime.now(),
            'RMID' => tmbCustId,
            'Account' => getAccount(tmbCustId)
        };

        Uuid uuidGenerateor = new Uuid();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
        req.setHeader('Request-UID', uuidGenerateor.getValue());
        req.setHeader('Request-App-ID', APPID);
        req.setEndpoint('callout:OSC06_Detail');
        req.setBody(reqBody);
        req.setTimeout(timeout);

        HttpResponse res = http.send(req);
        saveOnlineSerivceLogProductHolding(state, res, 'InvestmentAccount - OSC06 Low Level');
        String responseBody = res.getBody();
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        try{
            Map<String, Object> product = (Map<String, Object>)JSON.deserializeUntyped((String)getResult('body', state));
            String productcode = (String)getResult('GetInvestmentAccountRequest.FundCode', product);
            String UnitHolderNumber = (String)getResult('GetInvestmentAccountRequest.UnitHolderNo', product);
            Map<String, Object> prod = new Map<String, Object>{
                'UnitHolderNo' => UnitHolderNumber,
                'FundCode' => productcode,
                'ProductName' => String.isNotEmpty(productcode) && OnlyProductWithProductCode.containsKey(productcode) ?  OnlyProductWithProductCode.get(productcode).Name : '',
                'SubProductGroup' => String.isNotEmpty(productcode) && OnlyProductWithProductCode.containsKey(productcode) ?  OnlyProductWithProductCode.get(productcode).Product_Sub_group : '',
                'AssetClass' => String.isNotEmpty(productcode) && OnlyProductWithProductCode.containsKey(productcode) ?  OnlyProductWithProductCode.get(productcode).Asset_Class : '',
                'SeqGrp' => String.isNotEmpty(productcode) && OnlyProductWithProductCode.containsKey(productcode) ?  OnlyProductWithProductCode.get(productcode).SEQ_GRP : 'OTHERS',
                'IssuerFundHouse' => String.isNotEmpty(productcode) && OnlyProductWithProductCode.containsKey(productcode) ?  OnlyProductWithProductCode.get(productcode).Issuer_Fund_House : ''
            };
            result = (Map<String, Object>)putObject('product', product, result);
            result = (Map<String, Object>)putObject('InvestmentDetail', prod, result);
            return result;
        }
        catch(Exception e){
            return (Object) result ;
        }
    }

    public static object calloutCYBDetail(String accountNumber, String recordId, String tmbCustId){
        Uuid uuidGenerateor = new Uuid();
        String uuid = uuidGenerateor.getValue();
        String reqBody = '{"cyb_account":{"account_no":"' + accountNumber + '"}}';
        Map<String, Object> state = new Map<String, Object>{
            'service' => 'DWH',
            'recordId' => recordId,
            'tmbCustId' => tmbCustId,
            'startDateTime' => Datetime.now(),
            'body' => reqBody,
            'uuid' => uuid,
            'endpoint' => 'callout:AutoLoan_CYBDetail'
        };
        String privateKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), getIntegateSystem('DWH'));
        String bodyEncrypt = Test.isRunningTest() ? reqBody : (String)SCSMessageAPIUtil.encryptMessageWithKey(reqBody, privateKey);
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        if (!Test.isRunningTest()) {
            req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        }
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
        req.setHeader('Request-UID', uuid);
        req.setHeader('Request-App-ID', APPID);
        req.setEndpoint('callout:AutoLoan_CYBDetail');
        req.setBody(bodyEncrypt);
        req.setTimeout(timeout);

        HttpResponse res = http.send(req);

        String dataDecrypt;
        try {
            Map<String, Object> result = new Map<String, Object>();

            if(!String.isEmpty(res.getBody())) {
                dataDecrypt = Test.isRunningTest() ? res.getBody() : (String)SCSMessageAPIUtil.decryptMessageWithKey(res.getBody(), privateKey);
                result = dataDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(dataDecrypt) : result;
            }

            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('status.code', result) : '9999');

            List<Object> errors = (List<Object>)getResult('errors', result) != null ? (List<Object>)getResult('errors', result) : new List<Object>();

            Boolean isSuccess = errors?.size() > 0 || StatusCode == '0000';
            Boolean isError = false;
            String ErrorMsg = '';
            for (Object obj : errors) {
                String code = (String)getResult('code', obj);
                String message = (String)getResult('message', obj);
                isSuccess = isSuccess && new List<String>{ '0000', '4000' }.contains(code);
                isError = isError || new List<String>{ '5000' }.contains(code);
                ErrorMsg = !(new List<String>{'0000'}.contains(code)) && String.isEmpty(ErrorMsg) ? message : ErrorMsg;
            }
            ErrorMsg = String.isNotEmpty(ErrorMsg) ? ErrorMsg : String.valueOf(!result.isEmpty() ? getResult('status.description', result) : getValuesWithRegex(res.getBody(), new List<String>{'StatusDesc', 'errordesc', 'message', 'description'}));


            saveOnlineServiceLog(isSuccess, isNotEmpty(ErrorMsg) ? ErrorMsg : RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode()), state, res, dataDecrypt != null ? dataDecrypt : res.getBody());
            if(String.isEmpty(res.getBody())) {
                return new Map<String, Object>{
                    'StatusCode' => res.getStatusCode(),
                    'StatusDesc' => res.getStatus(),
                    'Message' => System.Label.ERR002,
                    'isTimeout' => true,
                    'StatusDescContinuation' => RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode())
                };
            }
            if (StatusCode == '9999') {
                Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                String StatusResponse = String.valueOf(!mapResponse.isEmpty() ? getResult('Status.StatusCode', mapResponse) : '404');
                result.put('StatusCode',StatusResponse);
            }
            //     Object Status = getResult('Status', result);
            //     Status = putObject('StatusDescContinuation', Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), Status);
            //     Status = putObject('Message', System.Label.ERR001, Status);
            //     Status = (Map<String, Object>)putObject('State', state, Status);
            //     System.debug('Status : '+JSON.serialize(Status));

            //     return Status;
            // }
            result = (Map<String, Object>)putObject('isSuccess', isSuccess || errors?.size() == 1, result); // for display value
            result = (Map<String, Object>)putObject('isError', !isSuccess || isError, result);
            // result = (Map<String, Object>)putObject('Message', !isSuccess ? System.Label.ERR001 : null, result);
            System.debug('result : '+result);
            return result;
        } catch (Exception e) {
            String errorMsg = String.format('{0}\n{1}\n', new List<String>{
                e.getMessage(),
                e.getStackTraceString()
            });
            
            saveOnlineServiceLog(false, errorMsg, state, res, dataDecrypt != null ? dataDecrypt : res.getBody());
            return new Map<String, Object>{
                'isThrow' => true,
                'message' => errorMsg
            };
        }
    }

    public static object callbackGuarantor(String accountNumber, String recordId, String tmbCustId){
        Uuid uuidGenerateor = new Uuid();
        String uuid = uuidGenerateor.getValue();
        String reqBody = '{"query":{"acct_nbr":"' + accountNumber + '","appl_code":"10"}}';
        Map<String, Object> state = new Map<String, Object>{
            'service' => 'DWH',
            'recordId' => recordId,
            'tmbCustId' => tmbCustId,
            'startDateTime' => Datetime.now(),
            'body' => reqBody,
            'uuid' => uuid,
            'endpoint' => 'callout:AutoLoan_Guarantor'
        };
        String privateKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), getIntegateSystem('DWH'));
        String bodyEncrypt = Test.isRunningTest() ? reqBody : (String)SCSMessageAPIUtil.encryptMessageWithKey(reqBody, privateKey);
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        if (!Test.isRunningTest()) {
            req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        }
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
        req.setHeader('Request-UID', uuid);
        req.setHeader('Request-App-ID', APPID);
        req.setEndpoint('callout:AutoLoan_Guarantor');
        req.setBody(bodyEncrypt);
        req.setTimeout(timeout);

        HttpResponse res = http.send(req);
        System.debug('res : '+res);

        String dataDecrypt;
        try {
           Map<String, Object> result = new Map<String, Object>();
            if(!String.isEmpty(res.getBody())) {
                dataDecrypt = Test.isRunningTest() ? res.getBody() : (String)SCSMessageAPIUtil.decryptMessageWithKey(res.getBody(), privateKey);
                result = dataDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(dataDecrypt) : result;

            }

            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('status.code', result) : '999');
            
            String ErrorMsg = String.valueOf(!result.isEmpty() ? getResult('status.description', result) : getValuesWithRegex(res.getBody(), new List<String>{'StatusDesc', 'errordesc'}));
            Boolean isSuccess = new List<String> {'0000', '4001'}.contains(StatusCode);
            Boolean isNoData = new List<String> {'4001'}.contains(StatusCode);

            saveOnlineServiceLog(isSuccess, isNotEmpty(ErrorMsg) ? ErrorMsg : RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode()), state, res, dataDecrypt != null ? dataDecrypt : res.getBody());
            if(String.isEmpty(res.getBody())) {
                return new Map<String, Object>{
                    'StatusCode' => res.getStatusCode(),
                    'StatusDesc' => res.getStatus(),
                    'Message' => System.Label.ERR002,
                    'isTimeout' => true,
                    'StatusDescContinuation' => RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode())
                };
            }

            if (StatusCode == '999') {
                Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                String StatusResponse = String.valueOf(!mapResponse.isEmpty() ? getResult('Status.StatusCode', mapResponse) : '404');
                result.put('StatusCode',StatusResponse);
            }
            
            result = (Map<String, Object>)putObject('isError', !isSuccess, result);
            result = (Map<String, Object>)putObject('isNoData', isNoData, result);
            
            if (isNoData) {
                System.debug('result : '+result);
                return result;
            }

            result = (Map<String, Object>)putObject('Message', !isSuccess ? System.Label.ERR001 : null, result);
            System.debug('result : '+result);
            return result;
        } catch (Exception e) {
            String errorMsg = String.format('{0}\n{1}\n', new List<String>{
                e.getMessage(),
                e.getStackTraceString()
             });
            System.debug('ERROR' + e.getMessage());
            System.debug('ERROR' + e);
            saveOnlineServiceLog(false, errorMsg, state, res, dataDecrypt != null ? dataDecrypt : res.getBody());
            return new Map<String, Object>{
                'isThrow' => true,
                'message' => errorMsg
            };
        }
    }

}