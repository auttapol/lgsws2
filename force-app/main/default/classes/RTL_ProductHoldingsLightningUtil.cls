public with sharing class RTL_ProductHoldingsLightningUtil extends AbstractCoreClass {
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
    
    private static final String SessionId {
        get {
            if(SessionId == null) {
                SessionId = fetchUserSessionId();
            }
            return SessionId;
        }
        set;
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
    private static final Map<string /*company name*/, BA_Insurance_Company__c> BAcompanyNames {
        get {
            if(BAcompanyNames == null){
                BAcompanyNames = BAInsuranceCompanyService.getAllBAInsuranceCompanies();
            }
            return BAcompanyNames;
        }
        set;
    }
    private static final String SECTION_CUST_HOLD_LOW = 'RtlCust:Customer Product Holding (Low)';
    private static final String SECTION_CUST_HOLD_MID = 'RtlCust:Customer Product Holding (Medium)';
    private static final String SECTION_CUST_HOLD_HIG = 'RtlCust:Customer Product Holding (High)';

    // Start add by support SCR0560980
    private static List<Screen_Message_Management__mdt> screenMessageList {
        get {
            if (screenMessageList == null) {
                List<Screen_Message_Management__mdt> screenMessageLists = [SELECT Id, isAPI__c, CallOut_Name__c, Service_Name__c, StatusCode__c, StatusDesc__c, Screen_Message__c FROM Screen_Message_Management__mdt];
                if (screenMessageLists.size() > 0) {
                    screenMessageList.addAll(screenMessageLists);
                }
            }
            return screenMessageList;
        }
        set;
    }
    // End add by support SCR0560980

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


    public class SubDebtTransactionWrapper{
        @AuraEnabled
        public String SubDebtTransactionName;
        @AuraEnabled
        public String ProductID;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Term;
        @AuraEnabled
        public String IssueDate;
        @AuraEnabled
        public String Unit;
        @AuraEnabled
        public String Amount;
        @AuraEnabled
        public String InterestRate;
        @AuraEnabled
        public String MaturityDate;
        @AuraEnabled
        public String RemainDate;
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

    @AuraEnabled
    public static Boolean UpdateTotalAccountsAndSumOfDepesite(String accountId, Decimal noOfProduct, Decimal sumOfTotalDepositeOutstanding) {
        return RetailAccountService.UpdateTotalAccountsAndSumOfDepesite(accountId, noOfProduct, sumOfTotalDepositeOutstanding);
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

    @AuraEnabled
    public static List<Invesment_Model__c> getInvestmentModel(String suitability){
        return [SELECT Asset_Class__c, FUND_TARGET_WGT__c From Invesment_Model__c Where Suitability_Model__c =: suitability];
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
                else if (link == 'OSC03') {
                    value = new Map<String, String>{
                        'CashWithdrawalAccountNumber' => key == 'CashWithdrawalAccountNumber' ? value : '',
                        'DirectDebitAccountNumber' => key == 'DirectDebitAccountNumber' ? value.substring(1).reverse().substring(3).reverse() : '',
                        'CardNumber' => key == 'CardNumber' ? value.substring(8) : '',
                        'CardId' => key == 'CardId' ? value.substring(8) : '',
                        'CardID' => key == 'CardID' ? value : ''
                    }.get(key);
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

    public static String parseLogOSCService(String body, String servicename) {
        String link = new Map<String, String> {
            'CustomerAccount - OSC01' => 'OSC01',
            'DepositAccount - OSC02' => 'OSC02',
            'CreditCardAccount - OSC03' => 'OSC03',
            'LoanAccount - OSC04' => 'OSC04'
            // 'BancassuranceAccount - OSC05 High Level' => 'OSC05Hi',
            // 'BancassuranceAccount - OSC05 Low Level' => 'OSC05Low',
            // 'InvestmentAccount - OSC06 High Level' => 'OSC06Hi',
            // 'InvestmentAccount - OSC06 Low Level' => 'OSC06Low'
        }.get(servicename);

        Object objBody = JSON.deserializeUntyped(body);
        if(link == 'OSC01') {
            List<Object> objList = new List<Object>();
            List<Object> DepositAccount = getResult('GetCustomerAccountResponse.DepositAccounts.DepositAccount', objBody) != null ? (List<Object>)getResult('GetCustomerAccountResponse.DepositAccounts.DepositAccount', objBody) : new List<Object>();
            for (Object o : DepositAccount) {
                o = putObject('AccountNumber', MakeValue('MarkedDepositAccountNumber', (String)getResult('AccountNumber', o)), o);
                objList.add(o);
            }
            objBody = DepositAccount.size() > 0 ? putObjectByPath('GetCustomerAccountResponse.DepositAccounts.DepositAccount', objList, objBody) : objBody;

            objList = new List<Object>();
            List<Object> CreditCardAccount = getResult('GetCustomerAccountResponse.CreditCardAccounts.CreditCardAccount', objBody) != null ? (List<Object>)getResult('GetCustomerAccountResponse.CreditCardAccounts.CreditCardAccount', objBody) : new List<Object>();
            for (Object o : CreditCardAccount) {
                o = putObject('CardNumber', MakeValue('MarkedCardNumber', (String)getResult('CardNumber', o)), o);
                objList.add(o);
            }
            objBody = CreditCardAccount.size() > 0 ? putObjectByPath('GetCustomerAccountResponse.CreditCardAccounts.CreditCardAccount', objList, objBody) : objBody;

            objList = new List<Object>();
            List<Object> LoanAccount = getResult('GetCustomerAccountResponse.LoanAccounts.LoanAccount', objBody) != null ? (List<Object>)getResult('GetCustomerAccountResponse.LoanAccounts.LoanAccount', objBody) : new List<Object>();
            for (Object o : LoanAccount) {
                o = putObject('AccountNumber', MakeValue('MarkedLoanAccountNumber', (String)getResult('AccountNumber', o)), o);
                objList.add(o);
            }
            objBody = LoanAccount.size() > 0 ? putObjectByPath('GetCustomerAccountResponse.LoanAccounts.LoanAccount', objList, objBody) : objBody;
        }
        else if(link == 'OSC02') {
            // AccountNumber
            objBody = getResult('GetDepositAccountDetailResponse.Result.DepositAccount.AccountNumber', objBody) != null ? putObjectByPath('GetDepositAccountDetailResponse.Result.DepositAccount.AccountNumber', MakeValue('MarkedDepositAccountNumber', (String)getResult('GetDepositAccountDetailResponse.Result.DepositAccount.AccountNumber', objBody)), objBody) : objBody;
            // AcctId
            objBody = getResult('GetDepositAccountResponse.AcctInqRs.BankAcctRec.DepAcctId.AcctId', objBody) != null ? putObjectByPath('GetDepositAccountResponse.AcctInqRs.BankAcctRec.DepAcctId.AcctId', MakeValue('MarkedDepositAccountNumber', (String)getResult('GetDepositAccountResponse.AcctInqRs.BankAcctRec.DepAcctId.AcctId', objBody)), objBody) : objBody;
        }
        else if(link == 'OSC03') {
            // CashWithdrawalAccountNumber
            objBody = isNotEmpty(getResult('GetCreditCardAccountDetailResponse.Result.CreditCardInfo.CashWithdrawalAccountNumber', objBody)) ? putObjectByPath('GetCreditCardAccountDetailResponse.Result.CreditCardInfo.CashWithdrawalAccountNumber', MakeValue('MarkedCashWithdrawalAccountNumber', (String)getResult('GetCreditCardAccountDetailResponse.Result.CreditCardInfo.CashWithdrawalAccountNumber', objBody)), objBody) : objBody;
            // DirectDebitAccountNumber
            objBody = isNotEmpty(getResult('GetCreditCardAccountDetailResponse.Result.CreditCardInfo.DirectDebitAccountNumber', objBody)) ? putObjectByPath('GetCreditCardAccountDetailResponse.Result.CreditCardInfo.DirectDebitAccountNumber', MakeValue('MarkedDirectDebitAccountNumber', (String)getResult('GetCreditCardAccountDetailResponse.Result.CreditCardInfo.DirectDebitAccountNumber', objBody)), objBody) : objBody;
            // CardNumber
            objBody = isNotEmpty(getResult('GetCreditCardAccountDetailResponse.Result.CreditCardInfo.CardNumber', objBody)) ? putObjectByPath('GetCreditCardAccountDetailResponse.Result.CreditCardInfo.CardNumber', MakeValue('MarkedCardNumber', ((String)getResult('GetCreditCardAccountDetailResponse.Result.CreditCardInfo.CardNumber', objBody)).substring(8)), objBody) : objBody;
            // CardId
            objBody = isNotEmpty(getResult('GetCreditCardAccountResponse.CCStmtInqRs.CCStmtRec.CCStmtInfo.CardRef.CardKeys.CardId', objBody)) ? putObjectByPath('GetCreditCardAccountResponse.CCStmtInqRs.CCStmtRec.CCStmtInfo.CardRef.CardKeys.CardId', MakeValue('MarkedCardNumber', ((String)getResult('GetCreditCardAccountResponse.CCStmtInqRs.CCStmtRec.CCStmtInfo.CardRef.CardKeys.CardId', objBody)).substring(8)), objBody) : objBody;
        }
        else if(link == 'OSC04') {
            // SavingAccount
            objBody = isNotEmpty(getResult('GetLoanAccountDetailResponse.Result.LoanPaymentInformation.LoanPayment.SavingAccount', objBody)) ? putObjectByPath('GetLoanAccountDetailResponse.Result.LoanPaymentInformation.LoanPayment.SavingAccount', MakeValue('MarkedSavingAccount', (String)getResult('GetLoanAccountDetailResponse.Result.LoanPaymentInformation.LoanPayment.SavingAccount', objBody)), objBody) : objBody;
            // AccountNumber
            objBody = isNotEmpty(getResult('GetLoanAccountDetailResponse.Result.LoanInformation.AccountNumber', objBody)) ? putObjectByPath('GetLoanAccountDetailResponse.Result.LoanInformation.AccountNumber', MakeValue('MarkedLoanAccountNumber', ((String)getResult('GetLoanAccountDetailResponse.Result.LoanInformation.AccountNumber', objBody)).substring(1).reverse().substring(3).reverse()), objBody) : objBody;
            // AcctId
            objBody = isNotEmpty(getResult('GetLoanAccountResponse.AcctInqRs.LoanAcctId.AcctId', objBody)) ? putObjectByPath('GetLoanAccountResponse.AcctInqRs.LoanAcctId.AcctId', MakeValue('MarkedLoanAccountNumber', ((String)getResult('GetLoanAccountResponse.AcctInqRs.LoanAcctId.AcctId', objBody)).substring(17).reverse().substring(3).reverse()), objBody) : objBody;
        }
        
        return JSON.serializePretty(objBody);
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

    private static void saveOnlineSerivceLogProductHolding(Object state, HttpResponse res, String ServiceName, Boolean subMessage) {   // Add by support SCR0560980
        String StatusCode = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('Status.StatusCode', JSON.deserializeUntyped(res.getBody()))) : '';
        String StatusDesc = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('Status.StatusDesc', JSON.deserializeUntyped(res.getBody()))) : '';
        if (StatusCode == '200') {
            if (ServiceName == 'BancassuranceAccount - OSC05 High Level') {
                Schema_Json_Result__mdt JsonResult = JsonResultTagList('OSC05_List');
                StatusCode = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult(JsonResult.Tag_Result_Code__c, JSON.deserializeUntyped(res.getBody()))) : '';
                StatusDesc = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult(JsonResult.Tag_Result_Desc__c, JSON.deserializeUntyped(res.getBody()))) : '';
            }else if (ServiceName == 'BancassuranceAccount - OSC05 Low Level') {
                Schema_Json_Result__mdt JsonResult = JsonResultTagList('OSC05_Detail');
                StatusCode = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult(JsonResult.Tag_Result_Code__c, JSON.deserializeUntyped(res.getBody()))) : '';
                StatusDesc = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult(JsonResult.Tag_Result_Desc__c, JSON.deserializeUntyped(res.getBody()))) : '';
            }           
        }
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

    //M8 decrypt body saveonlinelog
    private static void saveOnlineSerivceLogSCSCreditCard(Object state, HttpResponse res, String ServiceName, String uuidGenerateor) {
        String resDecrypt = '';
        try {
            if (ServiceName.contains('get-summary')){
                resDecrypt = JSON.serializePretty(JSON.deserializeUntyped(SCSMessageAPIUtil.decryptSummaryMessage(res.getBody(), SessionId)));
            } else {
                resDecrypt = JSON.serializePretty(JSON.deserializeUntyped(SCSMessageAPIUtil.decryptMessage(res.getBody(), SessionId)));
            }
            // System.debug('Can SCS decrypt :'+ resDecrypt);
        } catch (Exception e) {
            System.debug('Can\'t SCS decrypt:'+ e);
            resDecrypt = res != null && String.isNotEmpty(res.getBody()) ?  res.getBody() : '';
            System.debug('SCS undecrypt : '+ resDecrypt);
        }
        Object resObj = JSON.deserializeUntyped(resDecrypt);
        String StatusCode = '';
        String StatusDesc = '';
        Boolean isSuccess;
        String Message = '';
        // System.debug('ResObj : '+resObj);
        if (getResult('status.status_code', resObj) == 0 || getResult('status.status_code', resObj) == '0') {
            StatusCode = '0';
            StatusDesc = 'success';
            isSuccess = true;
        } else if (ServiceName.contains('get-summary') && getResult('status.code', resObj) == '200') { 
            StatusDesc = 'success';
            isSuccess = true;
        } else {
            isSuccess = false;
            if (res != null && String.isNotEmpty(res.getBody())) {
                //from service
                if (isNotEmpty(getResult('status.error_status', resObj))) {
                    List<Object> error_list = (List<Object>)getResult('status.error_status', resObj);
                    StatusDesc = (String)getResult('status.error_status.0.description', resObj);
                    for (Integer i = 1; i < error_list.size(); i++) {
                        StatusDesc = StatusDesc +' | '+ (String)getResult('status.error_status.'+i+'.description', resObj); 
                    }
                //from internal error
                } else if (isNotEmpty(getResult('Status.StatusDesc', resObj))) {
                    StatusDesc = (String)getResult('Status.StatusDesc', resObj);
                } else if (isNotEmpty(getResult('status.description', resObj))) {
                    StatusDesc = (String)getResult('status.description', resObj);
                } else {
                    StatusDesc = 'Don\'t get description';
                }
            }
        }
        Message = StatusDesc;
        // isSuccess = res != null && String.isNotEmpty(res.getBody()) ? StatusCode == '200' && !StatusDesc.contains('java.lang.Exception') : false;
        Account AccountObj = (Account)JSON.deserialize(JSON.serialize(getResult('Account', state)), Account.Class);
        String parseServiceName = '';
        if(ServiceName.contains('get-cards-balances')) {
            parseServiceName = 'get_cards_balances';
        } else if (ServiceName.contains('get-card')){
            parseServiceName = 'get_card';
        } else if (ServiceName.contains('get-unbilled-statement')){
            parseServiceName = 'get_unbilled_statement';
        } else if (ServiceName.contains('get-summary')){
            parseServiceName = 'get_summary';
        }
        RTL_CampaignUtil.saveToOnlineLog(
            isSuccess,
            AccountObj != null ? AccountObj.Name : '', // customerName
            Message,
            uuidGenerateor, // msLogId
            UserInfo.getName(),
            (String)getResult('RMID', state),
            ServiceName,
            (String)JSON.serializePretty(JSON.deserializeUntyped((String)getResult('body', state))), // Request Body
            // parseLogOSCServiceRegEx((String)JSON.serializePretty(JSON.deserializeUntyped((String)getResult('body', state))), ServiceName), // Request Body
            // String.isNotEmpty(res.getBody()) ? parseLogOSCService(res.getBody(), ServiceName) : '', // Response Body
            parseLogOSCServiceRegEx(resDecrypt, parseServiceName), // Request Body
            // resDecrypt, // Response Body
            AccountObj,
            Datetime.valueofGmt(((String)getResult('StartTime', state)).replace('T', ' ').replace('Z', ' ')), // Start datetime; convert to GMT locale time
            Datetime.now() // End datetime
        );
    }

    //M8 V2 Save online service log when throw exception
    private static void saveOnlineSerivceLogSCSCreditCard(Object state, HttpResponse res, String ServiceName, String errorMsg, String uuidGenerateor) {
        // String StatusCode = String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('Status.StatusCode', JSON.deserializeUntyped(res.getBody()))) : '';
        // String StatusDesc = String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('Status.StatusDesc', JSON.deserializeUntyped(res.getBody()))) : '';
        // Boolean isSuccess = String.isNotEmpty(res.getBody()) ? StatusCode == '200' && !StatusDesc.contains('java.lang.Exception') : false;
        String resDecrypt = '';
        // String sessionID;
        // if (!Test.isRunningTest()) {
        //     sessionID = fetchUserSessionId();
        // } else {
        //     sessionID = '141234156';
        // }
        try {
            if (res != null && String.isNotEmpty(res.getBody())) {
                    resDecrypt =  SCSMessageAPIUtil.decryptMessage(res.getBody(), SessionId);
                    // System.debug('Can SCS decrypt with error : '+ resDecrypt);
                } 
        } catch (Exception e) {
            System.debug('Can\'t SCS decrypt with error:'+ e.getMessage());
            resDecrypt = res != null && String.isNotEmpty(res.getBody()) ? res.getBody() : '';
            System.debug('SCS undecrypt with error: '+ resDecrypt);
        }
        Account AccountObj = (Account)JSON.deserialize(JSON.serialize(getResult('Account', state)), Account.Class);
        String parseServiceName = '';
        if(ServiceName.contains('get-cards-balances')) {
            parseServiceName = 'get_cards_balances';
        } else if (ServiceName.contains('get-card')){
            parseServiceName = 'get_card';
        } else if (ServiceName.contains('get-unbilled-statement')){
            parseServiceName = 'get_unbilled_statement';
        } else if (ServiceName.contains('get-summary')){
            parseServiceName = 'get_summary';
        }
        try {
            RTL_CampaignUtil.saveToOnlineLog(
                false,
                AccountObj != null ? AccountObj.Name : '', // customerName
                errorMsg,
                uuidGenerateor, // msLogId
                UserInfo.getName(),
                (String)getResult('RMID', state),
                ServiceName,
                (String)JSON.serializePretty(JSON.deserializeUntyped((String)getResult('body', state))), // Request Body
                // parseLogOSCServiceRegEx((String)JSON.serializePretty(JSON.deserializeUntyped((String)getResult('body', state))), ServiceName), // Request Body
                // String.isNotEmpty(res.getBody()) ? parseLogOSCService(res.getBody(), ServiceName) : '', // Response Body
                String.isNotEmpty(resDecrypt) ? parseLogOSCServiceRegEx(resDecrypt, parseServiceName) : '', // Request Body
                // resDecrypt, // Response Body
                AccountObj,
                Datetime.valueofGmt(((String)getResult('StartTime', state)).replace('T', ' ').replace('Z', ' ')), // Start datetime; convert to GMT locale time
                Datetime.now() // End datetime
            );
        } catch (Exception e) {
            System.debug('error SaveOnlineSCSLog with Error' + e.getMessage() + e.getStackTraceString());
            //Investigate
            // throw new AuraHandledException(e.getMessage());
        }
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

    @AuraEnabled(continuation=true)
    public static Object getProduct(String endpoint, String callback, String body, String tmbCustId){
        try{
            Datetime StartTime = (Datetime)Datetime.now();
            Uuid uuidGenerateor = new Uuid();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
            req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
            req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
            req.setHeader('Request-UID', uuidGenerateor.getValue());
            req.setHeader('Request-App-ID', APPID);
            req.setEndpoint(endpoint);
            req.setBody(body);
            req.setTimeout(timeout);

            Continuation con = new Continuation(timeout/1000 != 0 ? timeout/1000 : 1);
            con.state = new Map<String, Object>{
                'isEmployee' => isEmployee(tmbCustId),
                'body' => body,
                'StartTime' => StartTime,
                'RMID' => tmbCustId,
                'Account' => getAccount(tmbCustId)
            };
            con.continuationMethod = callback;
            con.addHttpRequest(req);

            return con;
        } catch( Exception e ){
            System.debug('System error : ' + e.getMessage());
            System.debug('Stack Trace : ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled(continuation=true)
    public static Object getProductContinue(String endpoint, String callback, String body, Object state){
        try{
            Uuid uuidGenerateor = new Uuid();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
            req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
            req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
            req.setHeader('Request-UID', uuidGenerateor.getValue());
            req.setHeader('Request-App-ID', APPID);
            req.setEndpoint(endpoint);
            req.setBody(body);
            req.setTimeout(timeout);

            Continuation con = new Continuation(timeout/1000 != 0 ? timeout/1000 : 1);
            con.state = state;
            con.continuationMethod = callback;
            con.addHttpRequest(req);

            return con;
        } catch( Exception e ){
            System.debug('System error : ' + e.getMessage());
            System.debug('Stack Trace : ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static Object getProductHttp(String endpoint, String body, String tmbCustId){
        String serviceName = new Map<String, String>{
            'callout:OSC01' => 'CustomerAccount - OSC01',
            'callout:OSC02' => 'DepositAccount - OSC02',
            'callout:OSC03' => 'CreditCardAccount - OSC03',
            'callout:OSC04' => 'LoanAccount - OSC04',
            'callout:OSC05_List' => 'BancassuranceAccount - OSC05 High Level',
            'callout:OSC05_Detail' => 'BancassuranceAccount - OSC05 Low Level',
            'callout:OSC06_List' => 'InvestmentAccount - OSC06 High Level',
            'callout:OSC06_Detail' => 'InvestmentAccount - OSC06 Low Level'
        }.get(endpoint);

        Map<String, Object> state = new Map<String, Object>{
            'Account' => getAccount(tmbCustId),
            'RMID' => tmbCustId,
            'body' => body,
            'StartTime' => JSON.serialize(Datetime.now()).replace('\"', '')
        };
        
        // Default variable Http response
        HttpResponse res;
        try{
            // AuthenticationToken authenTokenCalculateTools = APIGateway_Service.startCallGetTokenService('Smart_BDM_Cal_Tools_Create_Token');
            
            Uuid uuidGenerateor = new Uuid();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            if (!Test.isRunningTest()) {
                req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
            }
            req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
            req.setHeader('Request-Datetime', (String)state.get('StartTime'));
            req.setHeader('Request-UID', uuidGenerateor.getValue());
            req.setHeader('Request-App-ID', APPID);
            req.setEndpoint(endpoint);
            req.setBody(body);
        
            //For test timeout
            List<String> listTimeout = new List<String>() ;
            // listTimeout.add('callout:OSC01');
            // listTimeout.add('callout:OSC02');
            // listTimeout.add('callout:OSC04');
            // listTimeout.add('callout:OSC05_List');
            // listTimeout.add('callout:OSC06_List');
            if (listTimeout.contains(endpoint)) {
                req.setTimeout(1);
            } else {
                req.setTimeout(timeout);
            }
            //
            Http http = new Http();
            res = http.send(req);
            // Start add by support SCR0560980
            if (serviceName == 'BancassuranceAccount - OSC05 High Level') {
                saveOnlineSerivceLogProductHolding(state, res, serviceName, true);
            }else if (serviceName == 'BancassuranceAccount - OSC05 Low Level') {
                saveOnlineSerivceLogProductHolding(state, res, serviceName, true);
            }else {
            saveOnlineSerivceLogProductHolding(state, res, serviceName);
            }
            // saveOnlineSerivceLogProductHolding(state, res, serviceName);
            // End add by support SCR0560980

            if(res != null && String.isEmpty(res.getBody())) {
                return new Map<String, Object>{
                    'StatusCode' => res.getStatusCode(),
                    'StatusDesc' => res.getStatus(),
                    'Message' => System.Label.ERR002,
                    'StatusDescContinuation' => Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode())
                };
            }

            // Start add by support SCR0560980
            String StatusCodes = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('Status.StatusCode', JSON.deserializeUntyped(res.getBody()))) : '';
            String StatusDescs = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('Status.StatusDesc', JSON.deserializeUntyped(res.getBody()))) : '';
            if (StatusCodes == '200') {
                if (ServiceName == 'BancassuranceAccount - OSC05 High Level') {
                    Schema_Json_Result__mdt JsonResult = JsonResultTagList('OSC05_List');
                    StatusCodes = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult(JsonResult.Tag_Result_Code__c, JSON.deserializeUntyped(res.getBody()))) : '';
                    StatusDescs = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult(JsonResult.Tag_Result_Desc__c, JSON.deserializeUntyped(res.getBody()))) : '';
                }else if (ServiceName == 'BancassuranceAccount - OSC05 Low Level') {
                    Schema_Json_Result__mdt JsonResult = JsonResultTagList('OSC05_Detail');
                    StatusCodes = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult(JsonResult.Tag_Result_Code__c, JSON.deserializeUntyped(res.getBody()))) : '';
                    StatusDescs = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult(JsonResult.Tag_Result_Desc__c, JSON.deserializeUntyped(res.getBody()))) : '';
                }
                if (StatusCodes != '200') {
                    StatusDescs = getErrorMSG(false, endpoint, StatusCodes, StatusDescs);
                }
            }else {
                StatusDescs = getErrorMSG(true, endpoint, StatusCodes, StatusDescs);
            }
            // End add by support SCR0560980

            if (serviceName == 'CustomerAccount - OSC01') {
                Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                String StatusCode = String.valueOf(!result.isEmpty() ? getResult('Status.StatusCode', result) : '404');
                String StatusDesc = String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('Status.StatusDesc', JSON.deserializeUntyped(res.getBody()))) : '';
                
                //BAU11438_INC0179846
                String keyMessage = (StatusDesc.contains('Record not found') || StatusDesc.contains('account not found')) ? 'RecordNotFound' : 'General';
                String errorMessage = new Map<String, String>{
                    'General' => System.Label.ERR001,
                    'RecordNotFound' => System.Label.INT_No_Active_Product
                }.get(keyMessage);
                
                if (StatusCode != '200' || ((Map<String, Object>)getResult('GetCustomerAccountResponse', result)).isEmpty()) {
                    Object Status = getResult('Status', result);
                    Status = putObject('StatusDescContinuation', Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), Status);
                    Status = putObject('Message', errorMessage, Status);
                    return Status;
                }
                
                List<Object> DepositAccount = isNotEmpty(getResult('GetCustomerAccountResponse.DepositAccounts', result)) ? (List<Object>)getResult('GetCustomerAccountResponse.DepositAccounts.DepositAccount', result) : new List<Object>();
                List<Object> CreditCardAccount = isNotEmpty(getResult('GetCustomerAccountResponse.CreditCardAccounts', result)) ? (List<Object>)getResult('GetCustomerAccountResponse.CreditCardAccounts.CreditCardAccount', result) : new List<Object>();
                List<Object> BancassuranceAccount = isNotEmpty(getResult('GetCustomerAccountResponse.BancassuranceAccounts', result)) ? (List<Object>)getResult('GetCustomerAccountResponse.BancassuranceAccounts.BancassuranceAccount', result) : new List<Object>();
                List<Object> LoanAccount = isNotEmpty(getResult('GetCustomerAccountResponse.LoanAccounts', result)) ? (List<Object>)getResult('GetCustomerAccountResponse.LoanAccounts.LoanAccount', result) : new List<Object>();
                List<Object> InvestmentAccount = isNotEmpty(getResult('GetCustomerAccountResponse.InvestmentAccounts', result)) ? (List<Object>)getResult('GetCustomerAccountResponse.InvestmentAccounts.InvestmentAccount', result) : new List<Object>();
                
                for (Integer i = 0; i < DepositAccount.size(); i++) {
                    //String productcode = (String)getResult('GetCustomerAccountResponse.DepositAccounts.DepositAccount.'+i+'.ProductCode', result);
                    String productcode = (String)getResult('ProductCode', DepositAccount[i]);
                    DepositAccount[i] = putObject('SeqGrp', (productcode != '' && OnlyProductWithProductCode.containsKey(productcode)) ? OnlyProductWithProductCode.get(productcode).SEQ_GRP : 'OTHERS', DepositAccount[i]);
                    DepositAccount[i] = putObject('ProductSubGroup', (productcode != '' && OnlyProductWithProductCode.containsKey(productcode)) ? OnlyProductWithProductCode.get(productcode).Product_Sub_group : '#N/A', DepositAccount[i]);
                    DepositAccount[i] = putObject('ProductName', (productcode != '' && OnlyProductWithProductCode.containsKey(productcode)) ? OnlyProductWithProductCode.get(productcode).Name : '#N/A', DepositAccount[i]);
                }
                for (Integer i = 0; i < CreditCardAccount.size(); i++) {
                    //String productcode = (String)getResult('GetCustomerAccountResponse.CreditCardAccounts.CreditCardAccount.'+i+'.CreditCardType', result) + 'CRE';
                    String productcode = (String)getResult('ProductCode', CreditCardAccount[i]);
                    CreditCardAccount[i] = putObject('SeqGrp', (productcode != '' && OnlyProductWithProductCode.containsKey(productcode)) ? OnlyProductWithProductCode.get(productcode).SEQ_GRP : 'OTHERS', CreditCardAccount[i]);
                    CreditCardAccount[i] = putObject('ProductSubGroup', (productcode != '' && OnlyProductWithProductCode.containsKey(productcode)) ? OnlyProductWithProductCode.get(productcode).Product_Sub_group : '#N/A', CreditCardAccount[i]);
                    CreditCardAccount[i] = putObject('ProductName', (productcode != '' && OnlyProductWithProductCode.containsKey(productcode)) ? OnlyProductWithProductCode.get(productcode).Name : '#N/A', CreditCardAccount[i]);
                }
                for (Integer i = 0; i < LoanAccount.size(); i++) {
                    //String productcode = (String)getResult('GetCustomerAccountResponse.LoanAccounts.LoanAccount.'+i+'.ProductCode', result);
                    String productcode = (String)getResult('ProductCode', LoanAccount[i]);
                    LoanAccount[i] = putObject('SeqGrp', (productcode != '' && OnlyProductWithProductCode.containsKey(productcode)) ? OnlyProductWithProductCode.get(productcode).SEQ_GRP : 'OTHERS', LoanAccount[i]);
                    LoanAccount[i] = putObject('ProductSubGroup', (productcode != '' && OnlyProductWithProductCode.containsKey(productcode)) ? OnlyProductWithProductCode.get(productcode).Product_Sub_group : '#N/A', LoanAccount[i]);
                    LoanAccount[i] = putObject('ProductName', (productcode != '' && OnlyProductWithProductCode.containsKey(productcode)) ? OnlyProductWithProductCode.get(productcode).Name : '#N/A', LoanAccount[i]);
                }
                for (Integer i = 0; i < InvestmentAccount.size(); i++) {
                    //String productcode = (String)getResult('GetCustomerAccountResponse.InvestmentAccounts.InvestmentAccount.'+i+'.ProductCode', result);
                    String productcode = (String)getResult('ProductCode', InvestmentAccount[i]);
                }

                Boolean isEmployee = isEmployee(tmbCustId);
                return new Map<String, Object> {
                    'StatusCode' => '200',
                    'DepositAccount' => DepositAccount,
                    'CreditCardAccount' => CreditCardAccount,
                    'LoanAccount' => LoanAccount,
                    'BancassuranceAccount' => BancassuranceAccount,
                    'InvestmentAccount' => InvestmentAccount,
                    'isEmployee' => isEmployee
                };
            }
            else {
                // Start add by support SCR0560980
                // return isNotEmpty(res.getBody()) ? JSON.deserializeUntyped(res.getBody()) : null;
                if (ServiceName == 'BancassuranceAccount - OSC05 High Level' || ServiceName == 'BancassuranceAccount - OSC05 Low Level') {
                    return setResponseErrorOuter(res, StatusCodes, StatusDescs);
                }else {
                return isNotEmpty(res.getBody()) ? JSON.deserializeUntyped(res.getBody()) : null;
            }
                // End add by support SCR0560980
            }

        } catch( Exception e ){
            String errorMsg = '';
            errorMsg += 'System error : ' + e.getMessage();
            errorMsg += '\nStack Trace : ' + e.getStackTraceString();
            
            //error LWC not continuation
            errorMsg = e.getMessage().contains('Read timed out') ? 'The timeout was reached, and the server didn’t get a chance to respond.' : errorMsg;
            errorMsg = e.getMessage().contains('You have uncommitted work pending. Please commit or rollback before calling out') ? 'The timeout was reached, and the server didn’t get a chance to respond.' : errorMsg;
            saveOnlineSerivceLogProductHolding(state, res, serviceName, errorMsg);
            
            System.debug('\n'+errorMsg);
            AuraHandledException aurahandle = new AuraHandledException(errorMsg);
            aurahandle.setMessage(errorMsg);
            return aurahandle;
            // throw aurahandle;
            // throw new AuraHandledException(errorMsg);
            // return errorMsg;
        }
    }
    //mainbank red mdt atk
    @AuraEnabled
    public static list<Show_Red_Product_Code__mdt> getRedProductcode(){
        List<Show_Red_Product_Code__mdt> mcs = [SELECT Show_Red__c, Product_Code__c, Id FROM Show_Red_Product_Code__mdt];
        return mcs;
    }
    //m8
    @AuraEnabled
    public static Object getProductSCSCreditCard(String endpoint, String body, String tmbCustId){
        String requestBody = '';
        Http http = new Http();
        String serviceName = new Map<String, String>{
            'callout:get_card' => 'get-card',
            'callout:get_cards_balances' => 'get-cards-balances',
            'callout:get_unbilled_statement' => 'get-unbilled-statement'
        }.get(endpoint);
        String CredentialName = endpoint.substring(8,endpoint.length());
        NamedCredential NameCredentialObj = [SELECT DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName = :CredentialName LIMIT 1];
        String CredentialURL = NameCredentialObj.Endpoint;
        // System.debug('Service Name: '+ serviceName);
        // System.debug('CredentialName : '+ CredentialName);
        Datetime StartTime = (Datetime)Datetime.now();
        Map<String, Object> state = new Map<String, Object>{
            'isEmployee' => isEmployee(tmbCustId),
            'body' => body,
            'StartTime' => StartTime,
            'RMID' => tmbCustId,
            'Account' => getAccount(tmbCustId)
        };
        HttpResponse res;
        String bodyEncrypt = '';
        // String sessionId = '';
        try {
            // System.debug('body' + body);
            if (Test.isRunningTest()){
                // sessionId = '141235687';
                bodyEncrypt = body;
            } else {
                // sessionId = fetchUserSessionId();
                bodyEncrypt = SCSMessageAPIUtil.encryptMessage(body, SessionId);
            }
            // System.debug('session id --> ' + SessionId);
            // System.debug('body Encrypt'+bodyEncrypt);
            Uuid uuidGenerateor = new Uuid();
            HttpRequest req = new HttpRequest();
            String uuidValue = uuidGenerateor.getValue();

            req.setMethod('GET');
            if (!Test.isRunningTest()) {
                req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
            }
            req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
            req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
            req.setHeader('Request-UID', uuidValue);
            req.setHeader('Request-App-ID', APPID);
            req.setHeader('user-id', '');
            req.setHeader('service-name', serviceName);
            req.setEndpoint(endpoint);
            // req.setTimeout(timeout);
            if (serviceName == 'get-card') {
                req.setTimeout(timeout);
                // req.setTimeout(1);
            } else if (serviceName == 'get-cards-balances') {
                req.setTimeout(timeout);
                // req.setTimeout(1);
            } else if (serviceName == 'get-unbilled-statement') {
                req.setTimeout(timeout);
                // req.setTimeout(1);
            }
            // req.setTimeout(120000);
            // req.setTimeout(1);
            req.setBody(bodyEncrypt);
            
            String resDecrypt = '';
            // Mock service 
            // System.debug('send req');
            res = http.send(req);
            // System.debug('Res from service : '+ res);
            // System.debug('Res Body from service : '+ res.getBody());
            //for convenient in test class
            resDecrypt = res.getBody();
            if (!Test.isRunningTest()) {
                resDecrypt = '';
                resDecrypt = SCSMessageAPIUtil.decryptMessage(res.getBody(), SessionId);
                // System.debug('Success go to savelog');
            }
            saveOnlineSerivceLogSCSCreditCard(state, res, CredentialURL, uuidValue);
            
            // System.debug('\nserviceName : '+ serviceName+ '\nResponse : '+ resDecrypt);
            Map<String, Object> resObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            if (resDecrypt != null){
                Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(resDecrypt);
                String StatusCode = String.valueOf(!result.isEmpty() ? getResult('status.status_code', result) : '404');
                String StatusDesc = String.isNotEmpty(resDecrypt) && StatusCode == '1' ? JSON.serialize(getResult('status.error_status', JSON.deserializeUntyped(resDecrypt))) : '';
                // System.debug('StatusCode : '+StatusCode+'StatusDesc : ' + StatusDesc);
                String keyMessage = StatusDesc.contains('not found') ? 'RecordNotFound' : 'General';
                String isNotFound = String.isNotEmpty(StatusDesc) && StatusDesc.contains('not found') ? 'NOTFND' : 'FOUND';
                // System.debug('keyMessage : '+keyMessage + ' isNotFound : '+ isNotFound);
                String errorMessage = new Map<String, String>{
                    'General' => System.Label.ERR001,
                    'RecordNotFound' => System.Label.INT_No_Active_Product
                }.get(keyMessage);
                // System.debug('result credit_card : '+getResult('credit_card', result));
                // System.debug('isNotEmpty : ' + isNotEmpty(getResult('credit_card', result)));
                if (StatusCode != '0' || !(isNotEmpty(getResult('credit_card', result)) || isNotEmpty(getResult('card_statement', result))) ) {
                    // System.debug('result status : ' + getResult('status', result));
                    Object Status = getResult('status', result);
                    // Status = putObject('StatusDescContinuation', Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), Status);
                    Status = putObject('Message', errorMessage, Status);
                    Status = (Map<String, Object>)putObject('State', state, Status);
                    return Status;
                }
                if (serviceName == 'get-unbilled-statement' ) {
                    return result ;
                } else if (serviceName == 'get-card') {
                    List<Object> CreditCardAccount = new  List<Object>();
                    Object resultCreditCard = isNotEmpty(getResult('credit_card', result)) ? getResult('credit_card', result) : null;
                    resultCreditCard = (Map<String, Object>)putObject('isNotFound', isNotFound, resultCreditCard);
                    // resultCreditCard = putObjectByPath('isNotFound', isNotFound, resultCreditCard);
                    // System.debug('resultCreditCard add Status: \n' + resultCreditCard + '\n*****'+ getResult('isNotFound', resultCreditCard));
                    if (isNotEmpty(resultCreditCard)) {
                        CreditCardAccount.add(resultCreditCard);
                    }
                    Boolean isEmployee = ((Map<String, Object>)state).containsKey('isEmployee') ? (Boolean)((Map<String, Object>)state).get('isEmployee') : false;
                    Map<String, Object> objectResult = new Map<String, Object> {
                        'CreditCardAccount' => getResult('0', deserializeObject(transformCreditCardSCSProductDTO(CreditCardAccount, OnlyProductWithProductCode, isEmployee))) ,
                        'result' => result
                    };
                    // System.debug('Object Result' + JSON.serialize(objectResult));
                    return  objectResult;
                } else if (serviceName == 'get-cards-balances') {
                    List<Object> CreditCardAccounts = new  List<Object>();
                    // System.debug('GetBAL Result : ' + JSON.serialize(result));
                    // System.debug('GetBAL isNotEmpty : ' + isNotEmpty(getResult('max_records', result)));
                    // System.debug('GetBAL max_record from obj : ' + getResult('max_records', result));
                    Integer max_records = 0;
                    if (getResult('max_records', result) instanceof Integer) {
                        max_records =  isNotEmpty(getResult('max_records', result)) ? (Integer)getResult('max_records', result) : 0;
                    } else {
                        max_records =  isNotEmpty(getResult('max_records', result)) ? Integer.valueOf((String)getResult('max_records', result)) : 0;
                    }
                    // System.debug('max_records : '+ max_records);
                    String pathString = '';
                    Boolean isHaveError = false;
                    for (Integer i = 0; i < max_records; i++) {
                        pathString = 'credit_card'+'.'+String.valueOf(i) ;
                        try {
                            if (isNotEmpty(getResult('credit_card', result)) && isNotEmpty(getResult('credit_card.'+''+i+'.card_id', result))) {
                                Object resultCreditCard = isNotEmpty(getResult('credit_card.'+''+i, result)) ? getResult('credit_card.'+''+i, result) : null;
                                // System.debug('GetBAL Result credit_card('+i+')'+ resultCreditCard);
                                resultCreditCard = (Map<String, Object>)putObject('isNotFound', isNotFound, resultCreditCard);
                                // System.debug('resultCreditCard add Status: \n' + resultCreditCard + '\n*****'+ getResult('isNotFound', resultCreditCard));
                                if (isNotEmpty(resultCreditCard)) {
                                    // System.debug('credit '+i+' : '+resultCreditCard);
                                    Boolean isError = (getResult('credit_card.'+''+i+'.card_id', result) == '' || getResult('credit_card.'+''+i+'.account_id', result) == '') ? true : false;
                                    String CreditLine = '';
                                    String MaskedCreditLine = '';
                                    if (getResult('credit_card.'+''+i+'.card_balances.balance_credit_line.current', result) instanceof Decimal) {
                                        CreditLine = String.valueof((Decimal)getResult('credit_card.'+''+i+'.card_balances.balance_credit_line.current', result));
                                        MaskedCreditLine = NumberHelper.MarkDecimal(decimal.valueOf(CreditLine));
                                    } else {
                                        CreditLine = (String)getResult('credit_card.'+''+i+'.card_balances.balance_credit_line.current', result);
                                        MaskedCreditLine = NumberHelper.MarkDecimal(decimal.valueOf(CreditLine));
                                    }
                                    // resultCreditCard = (Map<String, Object>)putObject('card_id', (getResult('credit_card.'+''+i+'.card_id', result) == '') ? 'ErrorData' : getResult('credit_card.'+''+i+'.card_id', result), resultCreditCard);
                                    resultCreditCard = (Map<String, Object>)putObject('isError', isError, resultCreditCard);
                                    resultCreditCard = (Map<String, Object>)putObject('CreditLine', CreditLine, resultCreditCard);
                                    resultCreditCard = (Map<String, Object>)putObject('MaskedCreditLine', MaskedCreditLine, resultCreditCard);
                                    CreditCardAccounts.add(resultCreditCard);
                                }
                            }
                        } catch (Exception e) {
                            String errorMSG = 'System error : ' + e.getMessage();
                            System.debug('System error : ' + e.getMessage());
                            errorMSG += '\nStack Trace : ' + e.getStackTraceString();
                            System.debug('Stack Trace : ' + e.getStackTraceString());
                            isHaveError = true;
                        }
                        
                    }
                    Boolean isEmployee = ((Map<String, Object>)state).containsKey('isEmployee') ? (Boolean)((Map<String, Object>)state).get('isEmployee') : false;
                    Map<String, Object> objectResult = new Map<String, Object> {
                        'CreditCardAccounts' => deserializeObject(transformCreditCardSCSProductDTO(CreditCardAccounts, OnlyProductWithProductCode, isEmployee)) ,
                        'result' => result ,
                        'isHaveError' => isHaveError
                    };
                    return objectResult;
                } else {
                    return result;
                }
            } else if (isNotEmpty(getResult('Status.StatusDesc', resObj)))  {
                resObj = (Map<String, Object>)putObject('Message', System.Label.ERR001, resObj);
                return resObj;
            } else {
                // return res.getBody();
                return 'Response Decrypt is Null';
            }
            
        } catch( Exception e ){
            String errorMSG = 'System error : ' + e.getMessage();
            System.debug('System error : ' + e.getMessage());
            errorMSG += '\nStack Trace : ' + e.getStackTraceString();
            System.debug('Stack Trace : ' + e.getStackTraceString());
            if(errorMSG.contains('Read timed out') || errorMSG.contains('timeout') || errorMSG.contains('Timeout')) {
                saveOnlineSerivceLogSCSCreditCard(state, res, CredentialURL, 'The timeout was reached, and the server didn’t get a chance to respond.', '');
                errorMSG = System.Label.Product_Holding_ReRequest_v2;
                return errorMSG;
            } else {
                saveOnlineSerivceLogSCSCreditCard(state, res, CredentialURL, errorMSG, '');
                return errorMSG;
            }
            // return new AuraHandledException(errorMsg);
        }
    }

    @AuraEnabled
    public static Object getSummaryProductSCSCreditCard(String endpoint, String body, String tmbCustId){
        String requestBody = '';
        Http http = new Http();
        String serviceName = new Map<String, String>{
            'callout:get_summary' => 'get-summary'
        }.get(endpoint);
        String CredentialName = endpoint.substring(8,endpoint.length());
        NamedCredential NameCredentialObj = [SELECT DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName = :CredentialName LIMIT 1];
        String CredentialURL = NameCredentialObj.Endpoint;
        System.debug('Service Name: '+ serviceName);
        Datetime StartTime = (Datetime)Datetime.now();
        Map<String, Object> state = new Map<String, Object>{
            'isEmployee' => isEmployee(tmbCustId),
            'body' => body,
            'StartTime' => StartTime,
            'RMID' => tmbCustId,
            'Account' => getAccount(tmbCustId)
        };
        HttpResponse res;
        // String sessionId = '';
        try{
            // sessionId = fetchUserSessionId();
            System.debug('body' + body);
            String bodyEncrypt = '';
            if (Test.isRunningTest()){
                System.debug('isRunning Test');
                // sessionId = '141235687';
                bodyEncrypt = body;
            } else {
                // sessionId = fetchUserSessionId();
                bodyEncrypt = SCSMessageAPIUtil.encryptSummaryMessage(body, sessionId);
            }

            // System.debug('body Encrpt'+bodyEncrypt);
            Uuid uuidGenerateor = new Uuid();
            HttpRequest req = new HttpRequest();
            String uuidValue = uuidGenerateor.getValue();

            req.setMethod('GET');
            if (!Test.isRunningTest()) {
            req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
            }
            req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
            req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
            req.setHeader('Request-UID', uuidGenerateor.getValue());
            req.setHeader('Request-App-ID', APPID);
            req.setHeader('user-id', '');
            req.setHeader('service-name', serviceName);
            req.setEndpoint(endpoint);
            req.setTimeout(timeout);
            // req.setTimeout(1);
            req.setBody(bodyEncrypt);
            
            String resDecrypt = '';
            
            if (serviceName == 'get-summary') {
                System.debug('send req');
                res = http.send(req);
                System.debug('Res from service'+ res);
                System.debug('Res from service'+ res.getBody());
                resDecrypt = res.getBody();
            	if (!Test.isRunningTest()) {
                	resDecrypt = '';
                	resDecrypt = SCSMessageAPIUtil.decryptSummaryMessage(res.getBody(), sessionId);
                    System.debug('Success go to savelog');
                }
                saveOnlineSerivceLogSCSCreditCard(state, res, CredentialURL, uuidValue);
                System.debug('resDecrypt from service'+ resDecrypt);
                // resDecrypt = res.getBody();
            }
            Map<String, Object> resobj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            // return result;
            if (resDecrypt != null) {
                System.debug('\nserviceName : '+ serviceName+ '\nResponse : '+ resDecrypt);
                Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(resDecrypt);
                String StatusCode = String.valueOf(!result.isEmpty() ? getResult('status.code', result) : '404');
                // if (String.isNotEmpty(resDecrypt) && StatusCode == '1') {
                //     System.debug('error_status JSON.serial: '+ JSON.serialize(getResult('status.error_status', JSON.deserializeUntyped(resDecrypt))));
                // }
                String StatusDesc = String.isNotEmpty(resDecrypt) && StatusCode == '1' ? JSON.serialize(getResult('status.description', JSON.deserializeUntyped(resDecrypt))) : '';
                System.debug('StatusCode : '+StatusCode+'StatusDesc : ' + StatusDesc);
                String keyMessage = StatusDesc.contains('not found') ? 'RecordNotFound' : 'General';
                String isNotFound = String.isNotEmpty(StatusDesc) && StatusDesc.contains('not found') ? 'NOTFND' : 'FOUND';
                System.debug('keyMessage : '+keyMessage + ' isNotFound : '+ isNotFound);
                String errorMessage = new Map<String, String>{
                    'General' => System.Label.ERR001,
                    'RecordNotFound' => System.Label.INT_No_Active_Product
                }.get(keyMessage);
                // System.debug('result credit_card : '+getResult('credit_card', result));
                // System.debug('isNotEmpty : ' + isNotEmpty(getResult('credit_card', result)));
                if (StatusCode != '200') {
                    System.debug('result status : '+getResult('status', result));
                    Object Status = getResult('status', result);
                    // Status = putObject('StatusDescContinuation', Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), Status);
                    Status = putObject('Message', errorMessage, Status);
                    Status = (Map<String, Object>)putObject('State', state, Status);
                    return Status;
                }
                return result;
            } else if (isNotEmpty(getResult('status.description', resObj)))  {
                resObj = (Map<String, Object>)putObject('Message', System.Label.ERR001, resObj);
                return resObj;
            } else {
                return 'Response Decrypt is Null';
                // return res.getBody();
            }
            
        } catch( Exception e ){
            String errorMSG = 'System error : ' + e.getMessage();
            System.debug('System error : ' + e.getMessage());
            errorMSG += '\nStack Trace : ' + e.getStackTraceString();
            System.debug('Stack Trace : ' + e.getStackTraceString());
            if(errorMSG.contains('Read timed out') || errorMSG.contains('timeout')) {
                saveOnlineSerivceLogSCSCreditCard(state, res, CredentialURL, 'The timeout was reached, and the server didn’t get a chance to respond.', '');
                errorMSG = System.Label.Product_Holding_Credit_Card_ReRequest;
                return errorMSG;
            } else {
                saveOnlineSerivceLogSCSCreditCard(state, res, CredentialURL, errorMSG, '');
                return errorMSG;
            }
        }
    }

    @AuraEnabled
    public static Object setFormatCreditData(Object product, String tmbCustId){
        try {
            String CardID = (String)getResult('credit_card.card_id', product);
            //String productcode = (String)getResult('credit_card.product_id', product) + 'CRE'; 
            String productcode = (String)getResult('credit_card.product_id', product); 
            CreditCardRDCProductDTO CreditCardRDCProduct = new CreditCardRDCProductDTO();
            CreditCardRDCProduct.CardNumber = CardID;
            CreditCardRDCProduct.CreditCardType = productcode;
            CreditCardRDCProduct.ProductName = productcode != '' && OnlyProductWithProductCode.containsKey(productcode) ? OnlyProductWithProductCode.get(productcode).Name : '#N/A';
            
            // Map ProductType, UsageStatus for Credit card
            Object CreditCardRDCProductObj = (Object)CreditCardRDCProduct;
            CreditCardInformationDTO CreditCardRDCProductDTO = new CreditCardInformationDTO();
            // CreditCardRDCProductDTO.UsageStatus = (String)getResult('GetCreditCardAccountDetailResponse.Result.CreditCardInfo.UsageStatus', product);
            CreditCardRDCProductDTO.BlockCode = (String)getResult('credit_card.card_status.block_code', product);
            CreditCardRDCProductDTO.DirectDebitAccountNumber = (String.valueOf((Decimal)getResult('credit_card.direct_deposit_account', product)) == '0' ? '' : String.valueOf((Decimal)getResult('credit_card.direct_deposit_account', product)));
            // CreditCardRDCProductDTO.CreditLimit = Decimal.valueOf((Double)getResult('credit_card.card_balances.balance_credit_limit.total', product));
            CreditCardRDCProductDTO.CreditLimit = (Decimal)getResult('credit_card.card_balances.balance_credit_limit.total', product);
            CreditCardRDCProductDTO.CurrentBalance = (Decimal)getResult('credit_card.card_balances.current_balance', product);
            // CreditCardRDCProductDTO.CardAccountStatus = String.valueOf((Decimal)getResult('credit_card.card_status.account_status', product));
            CreditCardRDCProductDTO.CardAccountStatus = (String)getResult('credit_card.card_status.account_status', product);
            //CreditCardRDCProductDTO.AccountAgreementStatus = (String.valueOf((Decimal)getResult('credit_card.card_status.account_agree_status', product)) == '0' ? '' : String.valueOf((Decimal)getResult('credit_card.card_status.account_agree_status', product)));
            CreditCardRDCProductDTO.AccountAgreementStatus = (String)getResult('credit_card.card_status.account_agree_status', product) == '0' ? '' : (String)getResult('credit_card.card_status.account_agree_status', product);
            CreditCardRDCProductDTO.CardStop = String.valueOf((Decimal)getResult('credit_card.card_status.stop_code', product));
            CreditCardRDCProductDTO.CardStopReason = (String)getResult('credit_card.card_status.stop_code_desc', product);
            
            // // Mapping value on temporary object 
            CreditCardRDCProductObj = putObject('ProductType', productcode != '' && OnlyProductWithProductCode.containsKey(productcode) ? OnlyProductWithProductCode.get(productcode).Product_Group : '#N/A', CreditCardRDCProductObj);
            // // CreditCardRDCProductObj = putObject('UsageStatus', CreditCardRDCProductDTO.translatedStatusCode, CreditCardRDCProductObj);
            CreditCardRDCProductObj = putObject('BlockCode', CreditCardRDCProductDTO.translatedBlockCode, CreditCardRDCProductObj);
            CreditCardRDCProductObj = putObject('MarkedCreditLimit', CreditCardRDCProductDTO.MarkedCreditLimit, CreditCardRDCProductObj);
            CreditCardRDCProductObj = putObject('MarkedCurrentBalance', CreditCardRDCProductDTO.MarkedCurrentBalance, CreditCardRDCProductObj);
            CreditCardRDCProductObj = putObject('MarkedDirectDebitAccountNumber', (CreditCardRDCProductDTO.MarkedDirectDebitAccountNumber), CreditCardRDCProductObj);
            CreditCardRDCProductObj = putObject('AccountAgreementStatus', CreditCardRDCProductDTO.translatedAccountAgreementStatus, CreditCardRDCProductObj);
            CreditCardRDCProductObj = putObject('CardAccountStatus', CreditCardRDCProductDTO.translatedCardAccountStatus, CreditCardRDCProductObj);
            CreditCardRDCProductObj = putObject('CardStop', CreditCardRDCProductDTO.translatedCardStop, CreditCardRDCProductObj);
            CreditCardRDCProductObj = putObject('CardStopReason', CreditCardRDCProductDTO.translatedCardStopReason, CreditCardRDCProductObj);
            CreditCardRDCProductObj = putObject('isEmployee', isEmployee(tmbCustId), CreditCardRDCProductObj);
            // for unmasking
            CreditCardRDCProductObj = putObject('CurrentBalance',CreditCardRDCProductDTO.CurrentBalance ,CreditCardRDCProductObj);
            CreditCardRDCProductObj = putObject('CreditLimit',CreditCardRDCProductDTO.CreditLimit, CreditCardRDCProductObj);
            
            product = (Map<String, Object>)putObject('CreditCardRDCProduct', deserializeObject(CreditCardRDCProductObj), product);
            return product;
        } catch( Exception e ){
            String errorMSG = 'System error : ' + e.getMessage();
            System.debug('System error : ' + e.getMessage());
            errorMSG += '\nStack Trace : ' + e.getStackTraceString();
            System.debug('Stack Trace : ' + e.getStackTraceString());
            // saveOnlineSerivceLogProductHolding(state, res, serviceName, errorMSG);
            throw new AuraHandledException(errorMSG);
        }
    }
    
    @AuraEnabled
    public static Object callbackOSC01(List<String> labels, Object state){
        String responseBody = '';
        HttpResponse res = Continuation.getResponse((String)labels.get(0));
        try {
            saveOnlineSerivceLogProductHolding(state, res, 'CustomerAccount - OSC01');

            if(String.isEmpty(res.getBody())) {
            // if(true) {
                return new Map<String, Object>{
                    'StatusDesc' => res.getStatus(),
                    'Message' => System.Label.Product_Holding_ReRequest_v2,
                    'Timeout' => true,
                    'StatusCode' => res.getStatusCode(),
                    'StatusDescContinuation' => Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode())
                    // 'StatusCode' => 2000,
                    // 'StatusDescContinuation' => Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(2000)
                };
            }
            responseBody += res.getBody();
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('Status.StatusCode', result) : '404');
            String StatusDesc = String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('Status.StatusDesc', JSON.deserializeUntyped(res.getBody()))) : '';
            //BAU11438_INC0179846
            String keyMessage = (StatusDesc.contains('Record not found') || StatusDesc.contains('account not found')) ? 'RecordNotFound' : 'General';
            String errorMessage = new Map<String, String>{
                'General' => System.Label.ERR001,
                'RecordNotFound' => System.Label.INT_No_Active_Product
            }.get(keyMessage);
            
            if (StatusCode != '200' || ((Map<String, Object>)getResult('GetCustomerAccountResponse', result)).isEmpty()) {
                Object Status = getResult('Status', result);
                Status = putObject('StatusDescContinuation', Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), Status);
                Status = putObject('Message', errorMessage, Status);
                Status = (Map<String, Object>)putObject('State', state, Status);
                return Status;
            }
            List<Object> BancassuranceAccount = getResult('GetCustomerAccountResponse.BancassuranceAccounts', result) != null ? (List<Object>)getResult('GetCustomerAccountResponse.BancassuranceAccounts.BancassuranceAccount', result) : new List<Object>();
            List<Object> CreditCardAccount = getResult('GetCustomerAccountResponse.CreditCardAccounts', result) != null ? (List<Object>)getResult('GetCustomerAccountResponse.CreditCardAccounts.CreditCardAccount', result) : new List<Object>();
            List<Object> DepositAccount = getResult('GetCustomerAccountResponse.DepositAccounts', result) != null ? (List<Object>)getResult('GetCustomerAccountResponse.DepositAccounts.DepositAccount', result) : new List<Object>();
            List<Object> InvestmentAccount = getResult('GetCustomerAccountResponse.InvestmentAccounts', result) != null ? (List<Object>)getResult('GetCustomerAccountResponse.InvestmentAccounts.InvestmentAccount', result) : new List<Object>();
            List<Object> LoanAccount = getResult('GetCustomerAccountResponse.LoanAccounts', result) != null ? (List<Object>)getResult('GetCustomerAccountResponse.LoanAccounts.LoanAccount', result) : new List<Object>();
            
            // Map<String /*product code*/, RTLProductMasterDTO> OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
            Boolean isEmployee = ((Map<String, Object>)state).containsKey('isEmployee') ? (Boolean)((Map<String, Object>)state).get('isEmployee') : false;
            return new Map<String, Object> {
                'DepositAccount' => deserializeObject(transformDepositeProductDTO(DepositAccount, OnlyProductWithProductCode, isEmployee)),
                'CreditCardAccount' => deserializeObject(transformCreditCardRDCProductDTO(CreditCardAccount, OnlyProductWithProductCode, isEmployee)),
                'LoanAccount' => deserializeObject(transformLoanProductDTO(LoanAccount, OnlyProductWithProductCode)),
                'BancassuranceAccount' => deserializeObject(transformBancassuranceDTO(BancassuranceAccount, OnlyProductWithProductCode, isEmployee)),
                'InvestmentAccount' => InvestmentAccount,
                'result' => result,
                'isEmployee' => isEmployee
            };
        } catch (Exception e) {
            String errorMsg = '';
            errorMsg += '\nSystem error : ' + e.getMessage();
            errorMsg += '\nStack Trace : ' + e.getStackTraceString();
            responseBody += errorMsg;
            saveOnlineSerivceLogProductHolding(state, res, 'CustomerAccount - OSC01', errorMsg);
            System.debug(responseBody);
            throw new AuraHandledException(responseBody);
        }
    }

    @AuraEnabled
    public static Object callbackOSC02(List<String> labels, Object state){
        String responseBody = '';
        HttpResponse res = Continuation.getResponse((String)labels.get(0));
        try {
            saveOnlineSerivceLogProductHolding(state, res, 'DepositAccount - OSC02');
            
            if(String.isEmpty(res.getBody())) {
            // if(true) {
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
            responseBody += res.getBody();
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('Status.StatusCode', result) : '404');
            if (StatusCode != '200' || ((Map<String, Object>)getResult('GetDepositAccountDetailResponse.Result', result)).isEmpty()) {
                Object Status = getResult('Status', result);
                Status = putObject('StatusDescContinuation', Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), Status);
                Status = putObject('Message', System.Label.ERR001, Status);
                Status = (Map<String, Object>)putObject('State', state, Status);
                return Status;
            }
            Boolean isEmployee = ((Map<String, Object>)state).containsKey('isEmployee') ? (Boolean)((Map<String, Object>)state).get('isEmployee') : false;
            DepositeProductDTO DepositeProduct = new DepositeProductDTO();
            DepositeProduct.isEmployee = isEmployee;
            // High level
            if((String)getResult('GetDepositAccountResponse.AcctInqRs.Status.Severity', result) != 'Error'){
                Map<String, Object> AcctBalMap = new Map<String, Object>();
                for (Object obj : (List<Object>)getResult('GetDepositAccountResponse.AcctInqRs.AcctBal', result)) {
                    AcctBalMap.put((String)getResult('BalType', obj), obj);
                }
                DepositeProduct.OutStanding = AcctBalMap.containsKey('Avail') ? Decimal.valueOf((String)getResult('CurAmt.Amt', AcctBalMap.get('Avail'))) : 0;
                DepositeProduct.AvgOutStanding = getResult('GetDepositAccountResponse.Datawarehouse.AvgOutBal', result) != null ? (Decimal)getResult('GetDepositAccountResponse.Datawarehouse.AvgOutBal', result) : 0;
                DepositeProduct.ODLimit = getResult('GetDepositAccountResponse.AcctInqRs.DepAcctRec.DepAcctInfo.ODLimitAmt', result) != null ? Decimal.valueOf((String)getResult('GetDepositAccountResponse.AcctInqRs.DepAcctRec.DepAcctInfo.ODLimitAmt', result)) : 0;
                DepositeProduct.LedgerBalance = AcctBalMap.containsKey('Ledger') ? Decimal.valueOf((String)getResult('CurAmt.Amt', AcctBalMap.get('Ledger'))) : 0;
            }
            // Low level
            DepositeProductDetailDTO DepositeProductDetail = new DepositeProductDetailDTO();
            DepositeProductDetail.isEmployee = isEmployee;
            if((String)getResult('GetDepositAccountDetailResponse.Result.Status', result) == 'SUCCESS') {
                DepositeProductDetail.DepositAccountNumber = (String)getResult('GetDepositAccountDetailResponse.Result.DepositAccount.AccountNumber', result);
                DepositeProductDetail.OutStanding = Decimal.valueOf((String)getResult('GetDepositAccountDetailResponse.Result.DepositAccount.Outstanding', result));
                DepositeProductDetail.AvgBalanceMTD = getResult('GetDepositAccountDetailResponse.Result.DepositAccount.AvgBalanceMTD', result) != null ? Decimal.valueOf((String)getResult('GetDepositAccountDetailResponse.Result.DepositAccount.AvgBalanceMTD', result)) : 0;
                DepositeProductDetail.ODLimit = Decimal.valueOf((String)getResult('GetDepositAccountDetailResponse.Result.DepositAccount.ODLimit', result));
                DepositeProductDetail.LedgerBalance = Decimal.valueOf((String)getResult('GetDepositAccountDetailResponse.Result.DepositAccount.Ledger', result));
                DepositeProductDetail.InterestEarned = getResult('GetDepositAccountDetailResponse.Result.DepositAccount.InterestEarned', result) != null ? Decimal.valueOf((String)getResult('GetDepositAccountDetailResponse.Result.DepositAccount.InterestEarned', result)) : 0;
                // DepositeProductDetail.HasJoint = (String)getResult('GetDepositAccountDetailResponse.Result.DepositAccount.HasJoint', result);
            }
            result = (Map<String, Object>)putObject('DepositeProduct', deserializeObject(DepositeProduct), result);
            result = (Map<String, Object>)putObject('DepositeProductDetail', deserializeObject(DepositeProductDetail), result);
            return result;
        } catch (Exception e) {
            String errorMsg = '';
            errorMsg += '\nSystem error : ' + e.getMessage();
            errorMsg += '\nStack Trace : ' + e.getStackTraceString();
            responseBody += errorMsg;

            saveOnlineSerivceLogProductHolding(state, res, 'DepositAccount - OSC02', errorMsg);
            System.debug(responseBody);
            throw new AuraHandledException(responseBody);
        }
    }

    @AuraEnabled
    public static Object callbackOSC03(List<String> labels, Object state){
        String responseBody = '';
        HttpResponse res = Continuation.getResponse((String)labels.get(0));
        try {
            saveOnlineSerivceLogProductHolding(state, res, 'CreditCardAccount - OSC03');

            if(String.isEmpty(res.getBody())) {
                return new Map<String, Object>{
                    'StatusCode' => res.getStatusCode(),
                    'StatusDesc' => res.getStatus(),
                    'Message' => System.Label.ERR002,
                    'StatusDescContinuation' => Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode())
                };
            }
            responseBody += res.getBody();
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('Status.StatusCode', result) : '404');
            if (StatusCode != '200' || ((Map<String, Object>)getResult('GetCreditCardAccountResponse', result)).isEmpty()) {
                Object Status = getResult('Status', result);
                Status = putObject('StatusDescContinuation', Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), Status);
                Status = putObject('Message', System.Label.ERR001, Status);
                Status = (Map<String, Object>)putObject('State', state, Status);
                return Status;
            }
            String CardID = (String)getResult('GetCreditCardAccountRequest.CardID', JSON.deserializeUntyped((String)getResult('body', state)));
            String productcode = (String)getResult('GetCreditCardAccountRequest.CreditcardType', JSON.deserializeUntyped((String)getResult('body', state)));
            Boolean isSuccessHI = (String)getResult('GetCreditCardAccountResponse.CCStmtInqRs.Status.StatusDesc', result) == 'Success';
            CreditCardRDCProductDTO CreditCardRDCProduct = new CreditCardRDCProductDTO();
            CreditCardRDCProduct.CardNumber = CardID;
            CreditCardRDCProduct.CreditCardType = productcode;
            CreditCardRDCProduct.Outstanding = isSuccessHI && getResult('GetCreditCardAccountResponse.CCStmtInqRs.CCStmtRec.CCStmtInfo.AvailCrLimit.Amt', result) != null ? Decimal.valueOf((String)getResult('GetCreditCardAccountResponse.CCStmtInqRs.CCStmtRec.CCStmtInfo.AvailCrLimit.Amt', result)) : 0;
            CreditCardRDCProduct.VLimit = isSuccessHI && getResult('GetCreditCardAccountResponse.CCStmtInqRs.CCStmtRec.CCStmtInfo.TotalCrLimit.Amt', result) != null ? Decimal.valueOf((String)getResult('GetCreditCardAccountResponse.CCStmtInqRs.CCStmtRec.CCStmtInfo.TotalCrLimit.Amt', result)) : 0;
            CreditCardRDCProduct.ProductName = productcode != '' && OnlyProductWithProductCode.containsKey(productcode) ? OnlyProductWithProductCode.get(productcode).Name : '';
            CreditCardRDCProduct.SubProductGroup = productcode != '' && OnlyProductWithProductCode.containsKey(productcode) ? OnlyProductWithProductCode.get(productcode).Product_Sub_group : '';
            CreditCardRDCProduct.SeqGrp = productcode != '' && OnlyProductWithProductCode.containsKey(productcode) ? OnlyProductWithProductCode.get(productcode).SEQ_GRP : 'OTHERS';
            // Map ProductType, UsageStatus for Credit card
            Object CreditCardRDCProductObj = (Object)CreditCardRDCProduct;
            Boolean isSuccessLow = (String)getResult('GetCreditCardAccountDetailResponse.Result.Status', result) == 'SUCCESS';
            CreditCardInformationDTO CreditCardRDCProductDTO = new CreditCardInformationDTO();
            CreditCardRDCProductDTO.UsageStatus = (String)getResult('GetCreditCardAccountDetailResponse.Result.CreditCardInfo.UsageStatus', result);
            CreditCardRDCProductDTO.BlockCode = (String)getResult('GetCreditCardAccountDetailResponse.Result.CreditCardInfo.BlockCode', result);
            CreditCardRDCProductDTO.CashWithdrawalAccountNumber = (String)getResult('GetCreditCardAccountDetailResponse.Result.CreditCardInfo.CashWithdrawalAccountNumber', result);
            CreditCardRDCProductDTO.DirectDebitAccountNumber = (String)getResult('GetCreditCardAccountDetailResponse.Result.CreditCardInfo.DirectDebitAccountNumber', result);
            CreditCardRDCProductDTO.CreditLimit = isSuccessLow && getResult('GetCreditCardAccountDetailResponse.Result.CreditCardInfo.CreditLimit', result) != null ? Decimal.valueOf((String)getResult('GetCreditCardAccountDetailResponse.Result.CreditCardInfo.CreditLimit', result)) : null;
            CreditCardRDCProductDTO.CurrentBalance = isSuccessLow && getResult('GetCreditCardAccountDetailResponse.Result.CreditCardInfo.CurrentBalance', result) != null ? Decimal.valueOf((String)getResult('GetCreditCardAccountDetailResponse.Result.CreditCardInfo.CurrentBalance', result)) : null;
            // Mapping value on temporary object 
            CreditCardRDCProductObj = putObject('ProductType', productcode != '' && OnlyProductWithProductCode.containsKey(productcode) ? OnlyProductWithProductCode.get(productcode).Product_Group : '', CreditCardRDCProductObj);
            CreditCardRDCProductObj = putObject('UsageStatus', CreditCardRDCProductDTO.translatedStatusCode, CreditCardRDCProductObj);
            CreditCardRDCProductObj = putObject('BlockCode', CreditCardRDCProductDTO.translatedBlockCode, CreditCardRDCProductObj);
            CreditCardRDCProductObj = putObject('MarkedCreditLimit', CreditCardRDCProductDTO.MarkedCreditLimit, CreditCardRDCProductObj);
            CreditCardRDCProductObj = putObject('MarkedCurrentBalance', CreditCardRDCProductDTO.MarkedCurrentBalance, CreditCardRDCProductObj);
            CreditCardRDCProductObj = putObject('MarkedCashWithdrawalAccountNumber', CreditCardRDCProductDTO.MarkedCashWithdrawalAccountNumber, CreditCardRDCProductObj);
            CreditCardRDCProductObj = putObject('MarkedDirectDebitAccountNumber', CreditCardRDCProductDTO.MarkedDirectDebitAccountNumber, CreditCardRDCProductObj);
            result = (Map<String, Object>)putObject('CreditCardRDCProduct', deserializeObject(CreditCardRDCProductObj), result);
            result = (Map<String, Object>)putObject('State', state, result);
            return result;
        } catch (Exception e) {
            String errorMsg = '';
            errorMsg += '\nSystem error : ' + e.getMessage();
            errorMsg += '\nStack Trace : ' + e.getStackTraceString();
            responseBody += errorMsg;

            saveOnlineSerivceLogProductHolding(state, res, 'CreditCardAccount - OSC03', errorMsg);
            System.debug(responseBody);
            throw new AuraHandledException(responseBody);
        }
    }

    @AuraEnabled
    public static Object callbackOSC04(List<String> labels, Object state){
        String responseBody = '';
        HttpResponse res = Continuation.getResponse((String)labels.get(0));
        try {
            saveOnlineSerivceLogProductHolding(state, res, 'LoanAccount - OSC04');

            if(String.isEmpty(res.getBody())) {
            // if (true) {
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
            responseBody += res.getBody();
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('Status.StatusCode', result) : '404');
            if (StatusCode != '200' || ((Map<String, Object>)getResult('GetLoanAccountResponse', result)).isEmpty()) {
                Object Status = getResult('Status', result);
                Status = putObject('StatusDescContinuation', Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), Status);
                Status = putObject('Message', System.Label.ERR001, Status);
                Status = (Map<String, Object>)putObject('State', state, Status);
                return Status;
            }
            LoanProductDTO LoanAccount = new LoanProductDTO();
            if((String)getResult('GetLoanAccountResponse.AcctInqRs.Status.Severity', result) != 'Error'){
                Map<String, Object> AcctBalMap = new Map<String, Object>();
                for (Object obj : (List<Object>)getResult('GetLoanAccountResponse.AcctInqRs.AcctBal', result)) {
                    AcctBalMap.put((String)getResult('BalType', obj), obj);
                }
                LoanAccount.Outstanding = AcctBalMap.containsKey('Principal') ? Decimal.valueOf((String)getResult('CurAmt.Amt', AcctBalMap.get('Principal'))) : 0;
                LoanAccount.VLimit = Decimal.valueOf((String)getResult('GetLoanAccountResponse.AcctInqRs.LOCAcctRec.LoanInfoCommon.LOCLimit.Amt', result));
                String MatDt = (String)getResult('GetLoanAccountResponse.AcctInqRs.LOCAcctRec.LoanInfoCommon.MatDt', result);
                LoanAccount.MuturityDate = MatDt != null && String.isNotEmpty(MatDt) ? Date.valueOf((String)getResult('GetLoanAccountResponse.AcctInqRs.LOCAcctRec.LoanInfoCommon.MatDt', result)) : null;
            }
            result = (Map<String, Object>)putObject('LoanAccount', deserializeObject(LoanAccount), result);
            return result;
        } catch (Exception e) {
            String errorMsg = '';
            errorMsg += '\nSystem error : ' + e.getMessage();
            errorMsg += '\nStack Trace : ' + e.getStackTraceString();
            responseBody += errorMsg;

            saveOnlineSerivceLogProductHolding(state, res, 'LoanAccount - OSC04', errorMsg);
            System.debug(responseBody);
            throw new AuraHandledException(responseBody);
        }

    }

    @AuraEnabled
    public static Object callbackOSC05(List<String> labels, Object state){
        String responseBody = '';
        HttpResponse res = Continuation.getResponse((String)labels.get(0));
        try {
            // saveOnlineSerivceLogProductHolding(state, res, 'BancassuranceAccount - OSC05 High Level');  // Add by support SCR0560980
            saveOnlineSerivceLogProductHolding(state, res, 'BancassuranceAccount - OSC05 High Level', true);  // Add by support SCR0560980

            if(String.isEmpty(res.getBody())) {
            // if(true) {
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
            responseBody += res.getBody();
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('Status.StatusCode', result) : '404');
            // Start Add by support SCR0560980
            String StatusDesc = String.valueOf(!result.isEmpty() ? getResult('Status.StatusDesc', result) : '');
            if (StatusCode == '200') {
                Schema_Json_Result__mdt JsonResult = JsonResultTagList('OSC05_List');
                StatusCode = String.valueOf(!result.isEmpty() ? String.valueOf(getResult(JsonResult.Tag_Result_Code__c, result)) : '');
                StatusDesc = String.valueOf(!result.isEmpty() ? String.valueOf(getResult(JsonResult.Tag_Result_Desc__c, result)) : '');
                if (StatusCode != '200') {
                    StatusDesc = getErrorMSG(false, 'callout:OSC05_List', StatusCode, StatusDesc);
                }
            }else {
                StatusDesc = getErrorMSG(true, 'callout:OSC05_List', StatusCode, StatusDesc);
            }
            // End Add by support SCR0560980
            if (StatusCode != '200' || ((Map<String, Object>)getResult('GetBancassuranceAccountResponse', result)).isEmpty()) {
                result = setResponseErrorOuter(res, StatusCode, StatusDesc);  // Add by support SCR0560980
                Object Status = getResult('Status', result);
                Status = putObject('StatusDescContinuation', Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), Status);
                Status = putObject('Message', StatusDesc, Status);  // Add by support SCR0560980
                // Status = putObject('Message', System.Label.ERR001, Status);  // Add by support SCR0560980
                Status = (Map<String, Object>)putObject('State', state, Status);
                return Status;
            }
            return result;
        } catch (Exception e) {
            String errorMsg = '';
            errorMsg += '\nSystem error : ' + e.getMessage();
            errorMsg += '\nStack Trace : ' + e.getStackTraceString();
            responseBody += errorMsg;

            saveOnlineSerivceLogProductHolding(state, res, 'BancassuranceAccount - OSC05 High Level', errorMsg);
            System.debug(responseBody);
            throw new AuraHandledException(responseBody);
        }
    }

    @AuraEnabled
    public static Object callbackOSC05Detail(List<String> labels, Object state){
        String responseBody = '';
        HttpResponse res = Continuation.getResponse((String)labels.get(0));
        try {
            // saveOnlineSerivceLogProductHolding(state, res, 'BancassuranceAccount - OSC05 Low Level');  // Add by support SCR0560980
            saveOnlineSerivceLogProductHolding(state, res, 'BancassuranceAccount - OSC05 Low Level', true);  // Add by support SCR0560980

            if(String.isEmpty(res.getBody())) {
                return new Map<String, Object>{
                    'StatusCode' => res.getStatusCode(),
                    'StatusDesc' => res.getStatus(),
                    'Message' => System.Label.ERR002,
                    'Timeout' => true,
                    'StatusDescContinuation' => Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode())
                };
            }
            responseBody += res.getBody();
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('Status.StatusCode', result) : '404');
            // Start Add by support SCR0560980
            String StatusDesc = String.valueOf(!result.isEmpty() ? getResult('Status.StatusDesc', result) : '');
            if (StatusCode == '200') {
                Schema_Json_Result__mdt JsonResult = JsonResultTagList('OSC05_Detail');
                StatusCode = String.valueOf(!result.isEmpty() ? String.valueOf(getResult(JsonResult.Tag_Result_Code__c, result)) : '');
                StatusDesc = String.valueOf(!result.isEmpty() ? String.valueOf(getResult(JsonResult.Tag_Result_Desc__c, result)) : '');
                if (StatusCode.isAlpha()) {
                    StatusCode = '200';
                }
                if (StatusCode != '200' && StatusCode.isNumeric()) {
                    StatusDesc = getErrorMSG(false, 'callout:OSC05_Detail', StatusCode, StatusDesc);
                }
            }else {
                StatusDesc = getErrorMSG(true, 'callout:OSC05_Detail', StatusCode, StatusDesc);
            }
            // End Add by support SCR0560980
            if (StatusCode != '200' || ((Map<String, Object>)getResult('GetBancassuranceAccountDetailResponse', result)).isEmpty()) {
                result = setResponseErrorOuter(res, StatusCode, StatusDesc);  // Add by support SCR0560980
                Object Status = getResult('Status', result);
                Status = putObject('StatusDescContinuation', Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), Status);
                Status = putObject('Message', StatusDesc, Status);  // Add by support SCR0560980
                // Status = putObject('Message', System.Label.ERR001, Status);  // Add by support SCR0560980
                Status = (Map<String, Object>)putObject('State', state, Status);
                
                return Status;
            }
            return result;
        } catch (Exception e) {
            String errorMsg = '';
            errorMsg += '\nSystem error : ' + e.getMessage();
            errorMsg += '\nStack Trace : ' + e.getStackTraceString();
            responseBody += errorMsg;
            
            saveOnlineSerivceLogProductHolding(state, res, 'BancassuranceAccount - OSC05 Low Level', errorMsg);
            System.debug(responseBody);
            throw new AuraHandledException(responseBody);
        }
    }

    @AuraEnabled
    public static Object callbackOSC06List(List<String> labels, Object state){
        String responseBody = '';
        HttpResponse res = Continuation.getResponse((String)labels.get(0));
        try {
            saveOnlineSerivceLogProductHolding(state, res, 'InvestmentAccount - OSC06 High Level');

            if(String.isEmpty(res.getBody())) {
            // if(true) {
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
            responseBody += res.getBody();
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('Status.StatusCode', result) : '404');
            String InvestmentAccountStatusCode = String.valueOf(!result.isEmpty() && getResult('GetInvestmentAccountResponse.Status.StatusCode', result) != null ? getResult('GetInvestmentAccountResponse.Status.StatusCode', result) : '404');
            if (StatusCode != '200' || InvestmentAccountStatusCode != '200' 
            || ((List<Object>)getResult('GetInvestmentAccountResponse.GetFundDetails', result)).isEmpty() 
            || ((Map<String, Object>)getResult('GetInvestmentAccountResponse.GetFundDetails.0.detailFund', result)).isEmpty()) {
                Object Status = getResult('Status', result);
                Status = putObject('InvestmentAccountStatusCode', InvestmentAccountStatusCode, Status);
                Status = putObject('StatusDescContinuation', Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), Status);
                Status = putObject('Message', System.Label.ERR001, Status);
                Status = (Map<String, Object>)putObject('State', state, Status);
                Status = putObject('Result', result, Status);
                return Status;
            }

            List<Object> products = (List<Object>)getResult('GetInvestmentAccountResponse.GetFundDetails', result);
            Object fundClasses = getResult('GetInvestmentAccountResponse.listFundClass', result) instanceOf List<Object> ? (List<Object>)getResult('GetInvestmentAccountResponse.listFundClass', result) : new List<Object>{ getResult('GetInvestmentAccountResponse.listFundClass', result) };
            result = (Map<String, Object>)putObject('InvestmentAccount', deserializeObject(transformInvestmentProductDTO(products, (List<Object>)fundClasses, OnlyProductWithProductCode)), result);
            return result;
        } catch (Exception e) {
            String errorMsg = '';
            errorMsg += '\nSystem error : ' + e.getMessage();
            errorMsg += '\nStack Trace : ' + e.getStackTraceString();
            responseBody += errorMsg;

            saveOnlineSerivceLogProductHolding(state, res, 'InvestmentAccount - OSC06 High Level', errorMsg);
            System.debug(responseBody);
            throw new AuraHandledException(responseBody);
        }
    }

    @AuraEnabled
    public static Object callbackOSC06Detail(List<String> labels, Object state){
        String responseBody = '';
        HttpResponse res = Continuation.getResponse((String)labels.get(0));
        try {
            saveOnlineSerivceLogProductHolding(state, res, 'InvestmentAccount - OSC06 Low Level');

            if(String.isEmpty(res.getBody())) {
                return new Map<String, Object>{
                    'StatusCode' => res.getStatusCode(),
                    'StatusDesc' => res.getStatus(),
                    'Message' => System.Label.ERR002,
                    'Timeout' => true,
                    'StatusDescContinuation' => Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode())
                };
            }
            responseBody += res.getBody();
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('Status.StatusCode', result) : '404');
            Boolean GetInvestmentAccountDetailResponseStatus = !result.isEmpty() && getResult('GetInvestmentAccountDetailResponse.Result.Status', result) != null ? ((String)getResult('GetInvestmentAccountDetailResponse.Result.Status', result)).contains('ERROR') : false;
            if (StatusCode != '200' || GetInvestmentAccountDetailResponseStatus || ((Map<String, Object>)getResult('GetInvestmentAccountDetailResponse', result)).isEmpty()) {
                Object Status = getResult('Status', result);
                Status = putObject('StatusDescContinuation', Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), Status);
                Status = putObject('Message', System.Label.ERR001, Status);
                Status = (Map<String, Object>)putObject('State', state, Status);
                Status = putObject('Result', result, Status);
                return Status;
            }
            Map<String, Object> product = (Map<String, Object>)JSON.deserializeUntyped((String)getResult('body', state));
            String productcode = (String)getResult('GetInvestmentAccountRequest.FundCode', product);
            String UnitHolderNo = (String)getResult('GetInvestmentAccountRequest.UnitHolderNo', product);
            Map<String, Object> prod = new Map<String, Object>{
                'UnitHolderNo' => UnitHolderNo,
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
        } catch (Exception e) {
            String errorMsg = '';
            errorMsg += '\nSystem error : ' + e.getMessage();
            errorMsg += '\nStack Trace : ' + e.getStackTraceString();
            responseBody += errorMsg;
            
            saveOnlineSerivceLogProductHolding(state, res, 'InvestmentAccount - OSC06 Low Level', errorMsg);
            System.debug(responseBody);
            throw new AuraHandledException(responseBody);
        }
    }

    private static List<DepositeProductDTO> transformDepositeProductDTO(List<Object> DepositAccount, Map<String, RTLProductMasterDTO> OnlyProductWithProductCode, Boolean isEmployee){
        List<DepositeProductDTO> returnList = new List<DepositeProductDTO>();
        for (Object obj : DepositAccount) {
            DepositeProductDTO prod = new DepositeProductDTO();
            prod.isEmployee = isEmployee;
            prod.DepositAccountNumber = (String)getResult('AccountNumber', obj);
            prod.Status = (String)getResult('AccountStatus', obj);
            prod.AvgOutStanding = Decimal.valueOf((String)getResult('AvgOutstanding', obj));
            prod.FIIdent = (String)getResult('FIIdent', obj);
            prod.HasJoint = (String)getResult('HasJoint', obj);
            prod.IntEarning = Decimal.valueOf((String)getResult('InterestEarned', obj));
            prod.LedgerBalance = Decimal.valueOf((String)getResult('Ledger', obj));
            prod.ODLimit = Decimal.valueOf((String)getResult('ODLimit', obj));
            prod.OpenedDate = String.isNotEmpty((String)getResult('OpenedDate', obj)) ? Date.valueOf((String)getResult('OpenedDate', obj)) : null;
            prod.Outstanding = Decimal.valueOf((String)getResult('Outstanding', obj));
            prod.ProductType = (String)getResult('ProductType', obj);
            prod.DepositProductCode = (String)getResult('ProductCode', obj);
            prod.ProjectCode = (String)getResult('ProjectCode', obj);
            prod.DataSource = (String)getResult('DataSource', obj);

            String productcode = prod.DepositProductCode != null ? prod.DepositProductCode : '' + prod.ProjectCode != null ? prod.ProjectCode : '' + prod.DataSource != null ? prod.DataSource : '';
            prod.ProductName = productcode != '' && OnlyProductWithProductCode.containsKey(productcode) ? OnlyProductWithProductCode.get(productcode).Name : '#N/A';
            prod.SubProductGroup = productcode != '' && OnlyProductWithProductCode.containsKey(productcode) ? OnlyProductWithProductCode.get(productcode).Product_Sub_group : '#N/A';
            prod.SeqGrp = productcode != '' && OnlyProductWithProductCode.containsKey(productcode) ? OnlyProductWithProductCode.get(productcode).SEQ_GRP : 'OTHERS';
            returnList.add(prod);
        }
        return returnList;
    }

    //M8
    private static List<Object> transformCreditCardSCSProductDTO(List<Object> Products, Map<String, RTLProductMasterDTO> OnlyProductWithProductCode, Boolean isEmployee){
        List<Object> returnList = new List<Object>();
        for (Object obj : Products) {
            // System.debug('transformSCS  \nCardBalances : '+ getResult('card_balances.current_balance', obj) +
                        // '\nCardLimit : ' + getResult('card_balances.balance_credit_limit', obj));
            // System.debug('Obj Product: ' + obj);
            CreditCardRDCProductDTO prod = new CreditCardRDCProductDTO();
            prod.isEmployee = isEmployee;
            prod.Status = (String)getResult('isNotFound', obj);
            prod.CardNumber = (String)getResult('card_id', obj);
            //prod.CreditCardType = (String)getResult('product_id', obj)+ 'CRE';
            prod.CreditCardType = (String)getResult('product_id', obj);
            prod.OpenedDate = (String.isNotEmpty((String)getResult('card_info.created_date', obj)) && (String)getResult('card_info.created_date', obj) != '0000-00-00') ? Date.valueOf((String)getResult('card_info.created_date', obj)) : null;
            prod.ProductName = String.isNotEmpty(prod.CreditCardType) && OnlyProductWithProductCode.containsKey(prod.CreditCardType) ? OnlyProductWithProductCode.get(prod.CreditCardType).Name : '#N/A';
            prod.SubProductGroup = String.isNotEmpty(prod.CreditCardType) && OnlyProductWithProductCode.containsKey(prod.CreditCardType) ? OnlyProductWithProductCode.get(prod.CreditCardType).Product_Sub_group : '#N/A';
            prod.SeqGrp = String.isNotEmpty(prod.CreditCardType) && OnlyProductWithProductCode.containsKey(prod.CreditCardType) ? OnlyProductWithProductCode.get(prod.CreditCardType).SEQ_GRP : 'OTHERS';
            prod.Outstanding = Decimal.valueOf(String.valueOf(getResult('card_balances.current_balance', obj)));
            prod.VLimit = Decimal.valueOf(String.valueOf(getResult('card_balances.balance_credit_limit.current', obj)));
            Object result = (Object)prod;
            // result = putObject('isOther', prod.SubProductGroup == '#N/A' || prod.ProductName == '#N/A' ? true : false, result);
            result = putObject('ProductType', String.isNotEmpty(prod.CreditCardType) && OnlyProductWithProductCode.containsKey(prod.CreditCardType) ? OnlyProductWithProductCode.get(prod.CreditCardType).Product_Group : '#N/A', result);
            result = putObject('isError', getResult('isError', obj), result);
            result = putObject('CardRole', String.isNotEmpty((String)getResult('card_status.card_role', obj)) ? getResult('card_status.card_role', obj) : '', result);
            result = putObject('CardPLoan', String.isNotEmpty((String)getResult('card_status.card_ploan_flag', obj)) ? getResult('card_status.card_ploan_flag', obj) : '', result);
            result = putObject('CardActive', String.isNotEmpty((String)getResult('card_status.card_active_flag', obj)) ? getResult('card_status.card_active_flag', obj) : '', result);
            if (String.isNotEmpty((String)getResult('card_status.card_active_flag', obj))) {
                result = putObject('AccountStatus', (String)getResult('card_status.card_active_flag', obj) == 'ACTIVE' ? 'Active' :  'Inactive', result);
            }
            result = putObject('CreditLine', getResult('CreditLine', obj), result);
            result = putObject('MaskedCreditLine', getResult('MaskedCreditLine', obj), result);

            // result = (Map<String, Object>)putObject('State', state, result);
            returnList.add(result);
        }
        return returnList;
    }

    private static List<CreditCardRDCProductDTO> transformCreditCardRDCProductDTO(List<Object> Products, Map<String, RTLProductMasterDTO> OnlyProductWithProductCode, Boolean isEmployee){
        List<CreditCardRDCProductDTO> returnList = new List<CreditCardRDCProductDTO>();
        for (Object obj : Products) {
            CreditCardRDCProductDTO prod = new CreditCardRDCProductDTO();
            prod.isEmployee = isEmployee;
            prod.Status = (String)getResult('AccountStatus', obj);
            prod.CardNumber = (String)getResult('CardNumber', obj);
            //prod.CreditCardType = (String)getResult('CreditCardType', obj) + 'CRE';
            prod.CreditCardType = (String)getResult('CreditCardType', obj);
            prod.OpenedDate = String.isNotEmpty((String)getResult('OpenedDate', obj)) ? Date.valueOf((String)getResult('OpenedDate', obj)) : null;
            prod.ProductName = String.isNotEmpty(prod.CreditCardType) && OnlyProductWithProductCode.containsKey(prod.CreditCardType) ? OnlyProductWithProductCode.get(prod.CreditCardType).Name : '#N/A';
            prod.SubProductGroup = String.isNotEmpty(prod.CreditCardType) && OnlyProductWithProductCode.containsKey(prod.CreditCardType) ? OnlyProductWithProductCode.get(prod.CreditCardType).Product_Sub_group : '#N/A';
            prod.SeqGrp = String.isNotEmpty(prod.CreditCardType) && OnlyProductWithProductCode.containsKey(prod.CreditCardType) ? OnlyProductWithProductCode.get(prod.CreditCardType).SEQ_GRP : 'OTHERS';
            returnList.add(prod);
        }
        return returnList;
    }

    private static List<LoanProductDTO> transformLoanProductDTO(List<Object> Products, Map<String, RTLProductMasterDTO> OnlyProductWithProductCode) {
        List<LoanProductDTO> returnList = new List<LoanProductDTO>();
        for (Object obj : Products) {
            LoanProductDTO prod = new LoanProductDTO();
            prod.LoanAccountNumber = (String)getResult('AccountNumber', obj);
            prod.LoanProductCode = (String)getResult('ProductCode', obj);
            prod.ProjectCode = (String)getResult('ProjectCode', obj);
            prod.DataSource = (String)getResult('DataSource', obj);
            prod.ProductType = (String)getResult('ProductType', obj);
            prod.Fiident = (String)getResult('FIIdent', obj);
            prod.OpenedDate = String.isNotEmpty((String)getResult('OpenedDate', obj)) ? Date.valueOf((String)getResult('OpenedDate', obj)) : null;
            prod.Status = (String)getResult('AccountStatus', obj);
            prod.Outstanding = Decimal.valueOf((String)getResult('Outstanding', obj));
            prod.VLimit = Decimal.valueOf((String)getResult('Limit', obj));
            prod.MuturityDate = getResult('MaturityDate', obj) != null ? Date.valueOf((String)getResult('MaturityDate', obj)) : null;
            prod.HasCoBorrower = (String)getResult('HasCoborrower', obj);
            
            String productcode = prod.LoanProductCode != null ? prod.LoanProductCode : '' + prod.ProjectCode != null ? prod.ProjectCode : '' + prod.DataSource != null ? prod.DataSource : '';
            prod.ProductName = productcode != '' && OnlyProductWithProductCode.containsKey(productcode) ? OnlyProductWithProductCode.get(productcode).Name : '#N/A';
            prod.SubProductGroup = productcode != '' && OnlyProductWithProductCode.containsKey(productcode) ? OnlyProductWithProductCode.get(productcode).Product_Sub_group : '#N/A';
            prod.SeqGrp = productcode != '' && OnlyProductWithProductCode.containsKey(productcode) ? OnlyProductWithProductCode.get(productcode).SEQ_GRP : 'OTHERS';
            returnList.add(prod);
        }
        return returnList;
    }

    private static List<BancassuranceDTO> transformBancassuranceDTO(List<Object> Products, Map<String, RTLProductMasterDTO> OnlyProductWithProductCode, Boolean isEmployee) {
        List<BancassuranceDTO> returnList = new List<BancassuranceDTO>();
        for (Object obj : Products) {
            BancassuranceDTO prod = new BancassuranceDTO();
            prod.PolicyNo = getResult('PolicyNumber', obj) != null ? (String)getResult('PolicyNumber', obj) : '';
            prod.SubProductGroup = (String)getResult('SubProductGroup', obj);
            prod.ProductName = (String)getResult('ProductName', obj);
            prod.InsuranceCompany = (String)getResult('InsuranceCompany', obj);
            // prod.OpenedDate = getResult('OpenedDate', obj) != null ? Date.valueOf((String)getResult('OpenedDate', obj)) : null;
            prod.Status = (String)getResult('PolicyStatus', obj);
            prod.SumInsure = Decimal.valueOf((String)getResult('SumInsure', obj));
            prod.AFYP = Decimal.valueOf((String)getResult('AFVP', obj));
            // prod.ExpiryDate = getResult('ExpiryDate', obj) != null ? Date.valueOf((String)getResult('ExpiryDate', obj)) : null;
            returnList.add(prod);
        }
        return returnList;
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

    @AuraEnabled
    public static string getWatermarkHTML() {
        string userId = UserInfo.getUserId();
        User loginUser = [Select Id, Name, Employee_ID__c From User Where Id =: userId Limit 1];
        string userEmpId = loginUser.Employee_ID__c;
        return userEmpId;
    }
    
    /**
     * @description Method to fetch session id from GetSessionIdVF visualforce page
     * @param NA
     * @return  string  returns valid session id
     *
    */
	public static String fetchUserSessionId(){
     	String sessionId = '';
     	// Get the content of the VF page
     	String vfContent;
     	String ns =  [SELECT NamespacePrefix FROM Organization].NamespacePrefix;

		try {
            String vf_url = '/apex/';
            if(String.isNotBlank(ns)) {
                vf_url += ns + '__' + 'getsessionidvf';    
            } else {
                vf_url += 'getsessionidvf';       
            }

            PageReference pg = new PageReference(vf_url);
    
            if(!test.isRunningTest()) {
                vfContent = pg.getContent().toString();
            }
            else {
                vfContent = String.valueOf('Start_Of_Session_Id Test End_Of_Session_Id');
            }
    
            Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
            endP = vfContent.indexOf('End_Of_Session_Id');
            // Get the Session Id
            sessionId = vfContent.substring(startP, endP);
        } catch(Exception ex) {
            System.debug('***** ex: ' + ex);
        }

    	// Return Session Id
    	return sessionId;
    }

    @AuraEnabled
    public static String getUnmaskBalance(){
        return ProductingUnmaskingSetup.getProductUnmaskSetting();
    }

    @AuraEnabled
    public static List<SubDebtTransactionWrapper> getSubDebtTransaction(Id recordId){
        List<SubDebtTransactionWrapper> listsbwrapper = new List<SubDebtTransactionWrapper>();
        String profileName = [ SELECT Name FROM profile WHERE Id = :UserInfo.getProfileId() limit 1 ].Name;
        List<Sub_Debt_Transaction__c> subDebt = [SELECT Id, Sub_Debt_Transaction_Name__c, Name__c, Unit__c, Interest_Rate__c, 
        Product_ID__c, Term__c, Issue_Date__c, Amount__c, Maturity_Date__c, Remain_Date__c, Customer__c 
        FROM Sub_Debt_Transaction__c WHERE Customer__c = : recordId];
        Object isVisiblehigh = RetailCSVLightningUtil.getVerifyByField('subDebtTranDetail', profileName,recordId);
        System.debug('Record Id: '+ recordId +' '+ profileName +' Is visible high: '+isVisiblehigh);
        String hidden = System.Label.Data_Condition_Hidden_Text;
        for(Sub_Debt_Transaction__c sb: subDebt){
            SubDebtTransactionWrapper sbwrapper = new SubDebtTransactionWrapper(); 
            
            if(!Boolean.valueOf(isVisiblehigh) ){
                sbwrapper.SubDebtTransactionName = hidden;
                sbwrapper.ProductID = hidden;
                sbwrapper.Name = hidden;
                sbwrapper.Term = hidden;
                sbwrapper.IssueDate = hidden;
                sbwrapper.Unit = hidden;
                sbwrapper.Amount = hidden;
                sbwrapper.InterestRate = hidden;
                sbwrapper.MaturityDate = hidden;
                sbwrapper.RemainDate = hidden;
            }else {
                sbwrapper.SubDebtTransactionName = sb.Sub_Debt_Transaction_Name__c;
                sbwrapper.ProductID = sb.Product_ID__c;
                sbwrapper.Name = sb.Name__c;
                sbwrapper.Term = sb.Term__c;
                sbwrapper.IssueDate = String.valueOf(sb.Issue_Date__c);
                sbwrapper.Unit = String.valueOf(sb.Unit__c);
                sbwrapper.Amount = String.valueOf(sb.Amount__c);
                sbwrapper.InterestRate = sb.Interest_Rate__c;
                sbwrapper.MaturityDate = String.valueOf(sb.Maturity_Date__c);
                sbwrapper.RemainDate = sb.Remain_Date__c;
            }listsbwrapper.add(sbwrapper);
            system.debug('listsbwrapper : '+listsbwrapper);         
        }
        return listsbwrapper;   
    }

    public static String getErrorMSG(Boolean isAPI, String callOutName, String statusCode, String StatusDesc) {  // Add by support SCR0560980
        if (String.isBlank(callOutName) || String.isBlank(statusCode) || String.isBlank(StatusDesc)) {
            return StatusDesc;
        }
        List<Screen_Message_Management__mdt> screenMessageLists = new List<Screen_Message_Management__mdt>();
        if (isAPI) {
            screenMessageLists = [SELECT Id, isAPI__c, CallOut_Name__c, Service_Name__c, StatusCode__c, StatusDesc__c, Screen_Message__c 
                                                                    FROM Screen_Message_Management__mdt WHERE isAPI__c =: isAPI AND StatusCode__c =: statusCode AND StatusDesc__c =: StatusDesc
                                                                ];
        }else {
            screenMessageLists = [SELECT Id, isAPI__c, CallOut_Name__c, Service_Name__c, StatusCode__c, StatusDesc__c, Screen_Message__c 
                                                                    FROM Screen_Message_Management__mdt WHERE isAPI__c =: isAPI AND CallOut_Name__c =: callOutName AND StatusCode__c =: statusCode AND StatusDesc__c =: StatusDesc
                                                                ];
        }
        
        if (screenMessageLists.size() < 1) {
            return System.Label.INT_Investment_Incomplete_Info;
        }
        for (Screen_Message_Management__mdt sMSG : screenMessageLists) {
            return sMSG.Screen_Message__c;
        }
        return StatusDesc;
    }

    public static Map<String, Object> setResponseErrorOuter(HttpResponse res, String StatusCodes, String StatusDescs) {  // Add by support SCR0560980
        Map<String, Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        if (resMap.containsKey('Status')) {
            Map<String, Object> resStatusMap = (Map<String, Object>) deserializeObject(resMap.get('Status'));
            if (resStatusMap.containsKey('StatusCode')) {
                resStatusMap.put('StatusCode', (String) StatusCodes);
            }
            if (resStatusMap.containsKey('StatusDesc')) {
                resStatusMap.put('StatusDesc', (String) StatusDescs);
            }
            resMap.put('Status', resStatusMap);
        }
        return resMap.size() > 0 ? resMap : null;
    }

    public static Schema_Json_Result__mdt JsonResultTagList( String DeveloperName ) { // Add by support SCR0560980
        Schema_Json_Result__mdt result = new Schema_Json_Result__mdt();
        if(DeveloperName != null){
            List<Schema_Json_Result__mdt> JsonResultTagLists = [SELECT Id, CallOut_Name__c, Tag_Result_Code__c, Tag_Result_Desc__c FROM  Schema_Json_Result__mdt WHERE DeveloperName = :DeveloperName ];
            if (JsonResultTagLists.size() > 0) {
                result = JsonResultTagLists.get(0);
            }
        }
        return result;
    }

}