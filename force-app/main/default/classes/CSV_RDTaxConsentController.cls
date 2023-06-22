public class CSV_RDTaxConsentController extends AbstractCoreClass {
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

    private static User currentUser {
        get{
            if(currentUser == null){
                currentUser = [SELECT Id, Name, Employee_ID__c, ProfileId, Profile.Name FROM User WHERE Id = :userInfo.getUserId()];
            }
            return currentUser;
        }
        set;
    }

    private static Set<String> taxCertBtnProfilePermssion {
        get{
            if(taxCertBtnProfilePermssion == null){
                taxCertBtnProfilePermssion = new Set<String>();
                List<Tax_Certificate_profile_button__mdt> profileLst = Tax_Certificate_profile_button__mdt.getAll().values();

                for (Tax_Certificate_profile_button__mdt each : profileLst) {
                    taxCertBtnProfilePermssion.add(each.Profile_Name__c);
                }
            }
            return taxCertBtnProfilePermssion;
        }
        set;
    }

    private static Set<String> taxCertBtnBusTypePermission {
        get{
            if(taxCertBtnBusTypePermission == null){
                taxCertBtnBusTypePermission = new Set<String>();
                List<Tax_Certificate_business_type__mdt> busTypeLst = Tax_Certificate_business_type__mdt.getAll().values();
                for (Tax_Certificate_business_type__mdt each : busTypeLst) {
                    taxCertBtnBusTypePermission.add(each.Business_Type__c);
                }
            }
            return taxCertBtnBusTypePermission;
        }
        set;
    }

    private static String recId;

    private static Boolean dataSecureProductHoldingHigh{
        get{
            if(dataSecureProductHoldingHigh == null){
                dataSecureProductHoldingHigh = RTL_AccountUtility.verifyFieldSecurity('RtlCust:Customer Product Holding (High)', currentUser.Profile.Name, recId);
            }
            return dataSecureProductHoldingHigh;
        }
        set;
    }

    private static Boolean dataSecureProductHoldingLow{
        get{
            if(dataSecureProductHoldingLow == null){
                dataSecureProductHoldingLow = RTL_AccountUtility.verifyFieldSecurity('RtlCust:Customer Product Holding (Low)', currentUser.Profile.Name, recId);
            }
            return dataSecureProductHoldingLow;
        }
        set;
    }

    private static String ApiGatewayToken {
        get{
            if(ApiGatewayToken == null){
                ApiGatewayToken = SmartBDM_Utility.tokenKeyCalculateTools;
            }
            return ApiGatewayToken;
        }set;
    }

    public class loanAccountOSC01{
        public String status;
        public String accountNumber;
        public String fiident;
        public String productType;
        public String productCode;
        public String openDate;
        public String accountStatus;
        public String outstanding;
        public String limito;
        public String hasCoborrower;
    }

    public class LoanAccountWrapperClass{
        @AuraEnabled
        public String contractEndDate;
        @AuraEnabled
        public String hasCoborrower;
        @AuraEnabled
        public Boolean taxConsentBtnPermission;
        @AuraEnabled
        public String maskAccountNumber;
        @AuraEnabled
        public String prodName;
        @AuraEnabled
        public String prodSubFamily;
        @AuraEnabled
        public String editConsentUrl;
        @AuraEnabled
        public String accountStatus;
        @AuraEnabled
        public String statusDesc04;
    }

    public class WrapperClassForRT{
        @AuraEnabled
        public List<LoanAccountWrapperClass> loanWrapper;
        @AuraEnabled
        public String employeeId;
        @AuraEnabled
        public String statusDesc01;
        @AuraEnabled
        public Boolean dataPartitionPermission;
       
    }

    public static HTTPResponse getOSC01(String body){
        String responseBody;
        HTTPResponse res;

        try{
            Datetime StartTime = (Datetime)Datetime.now();
            Uuid uuidGenerateor = new Uuid();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + ApiGatewayToken);
            req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
            req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
            req.setHeader('Request-UID', uuidGenerateor.getValue());
            req.setHeader('Request-App-ID', APPID);
            req.setEndpoint('callout:OSC01');
            req.setBody(body);
            req.setTimeout(timeout);

            Http http = new Http();
            res = http.send(req);
            responseBody = res.getBody();
        } catch( Exception e ){
            System.debug('System error : ' + e.getMessage());
            System.debug('Stack Trace : ' + e.getStackTraceString());
            throw e;
        }
        return res;
    }

    public static HTTPResponse getOSC04(String body, String tmbCustId){
        String responseBody;
        HTTPResponse res;

        try{
            Datetime StartTime = (Datetime)Datetime.now();
            Uuid uuidGenerateor = new Uuid();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + ApiGatewayToken);
            req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
            req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
            req.setHeader('Request-UID', uuidGenerateor.getValue());
            req.setHeader('Request-App-ID', APPID);
            req.setEndpoint('callout:OSC04');
            req.setBody(body);
            req.setTimeout(timeout);

            Http http = new Http();
            res = http.send(req);
            responseBody = res.getBody();
        } catch( Exception e ){
            System.debug('System error : ' + e.getMessage());
            System.debug('Stack Trace : ' + e.getStackTraceString());
            throw e ;
        }
        return res;
    }

    @AuraEnabled
    public static WrapperClassForRT getdataosc01(Id recordId){
        recId = recordId;

        WrapperClassForRT wrapperForRT = new WrapperClassForRT();
        List<LoanAccountWrapperClass> loanAccWrapList = new List<LoanAccountWrapperClass>();
        
        wrapperForRT.dataPartitionPermission = dataSecureProductHoldingLow;

        if(!dataSecureProductHoldingLow){
            return wrapperForRT;
        }

        String StatusDesc01;
        String StatusCode01;
        Boolean isSuccess01 = false;
        String responseBody01;

        List<OnlineServiceLog> OnlineServiceLogList = new List<OnlineServiceLog>();

        List<Account> accList = [SELECT Id, Name, TMB_Customer_ID_PE__c, Core_Banking_Suggested_Segment__c FROM Account WHERE Id = :recordId LIMIT 1];

        if(accList.size() <= 0 || accList.get(0).TMB_Customer_ID_PE__c == null || accList.get(0).TMB_Customer_ID_PE__c == '') return wrapperForRT;

        Account acct = accList.get(0);

        String TMB_cusid = acct.TMB_Customer_ID_PE__c;

        String fiident = TMB_cusid.substring(0, 16);
        String rmid = TMB_cusid.substring(14);

        String requestBody01 = '{"GetCustomerAccountRequest":{"RMID":"' + rmid + '","FIIdent":"' + fiident + '","FilterBy":"RMABRDT"}}';
        Datetime StartTime01 = (Datetime)Datetime.now();

        try{
            wrapperForRT.employeeId = currentUser.Employee_ID__c;
            wrapperForRT.loanWrapper = loanAccWrapList;

            HttpResponse res = getOSC01(requestBody01);
            responseBody01 = res.getBody();

            StatusDesc01 = responseBody01 != null && String.isNotEmpty(responseBody01) ? String.valueOf(getResult('Status.StatusDesc', JSON.deserializeUntyped(responseBody01))) : '';
            StatusCode01 = responseBody01 != null && String.isNotEmpty(responseBody01) ? String.valueOf(getResult('Status.StatusCode', JSON.deserializeUntyped(responseBody01))) : '';
            isSuccess01 = StatusDesc01 == 'success' || StatusDesc01.contains('Record not found') || StatusDesc01.contains('account not found');

            if(!isSuccess01){
                if(StatusDesc01 == 'Unauthorized'){
                    wrapperForRT.statusDesc01 = 'Unauthorized';
                }
                else{
                    wrapperForRT.statusDesc01 = 'ERROR';
                }

                RTL_CampaignUtil.saveToOnlineLog(
                    isSuccess01,
                    acct.Name,
                    String.isNotEmpty(StatusDesc01) ? StatusDesc01 : 'Null response',
                    '', // msLogId
                    UserInfo.getName(),
                    TMB_cusid,
                    taxCertificateController.getServiceName('OSC01'),
                    requestBody01,
                    responseBody01,
                    acct,
                    StartTime01,
                    Datetime.now()
                );

                return wrapperForRT;
            }

            String loanAccountlst = getLoanAccount(responseBody01);

            if(loanAccountlst != ''){
                List<loanAccountOSC01> loanAccList = (List<loanAccountOSC01>)JSON.deserialize(loanAccountlst, List<loanAccountOSC01>.class);//มีแต่ของ 01
                List<String> prodCodeLst = new List<String>();
                Map<String, Product2> mapProductCodeProduct2 = new Map<String, Product2>(); 

                for(loanAccountOSC01 loanAcc : loanAccList){
                    if(loanAcc.productCode != null && loanAcc.productCode != '') prodCodeLst.add(loanAcc.productCode);
                }

                for(Product2 prd2 : [SELECT Id, ProductCode, Sub_Family__c, Name FROM Product2 WHERE ProductCode IN :prodCodeLst]){
                    mapProductCodeProduct2.put(prd2.ProductCode, prd2);                   
                }

                for(loanAccountOSC01 loanAcc : loanAccList){
                    LoanAccountWrapperClass loanWrap = new LoanAccountWrapperClass();
                    Blob cmUrl = Blob.valueOf('{"componentDef":"c:LoanTaxCertificate","attributes":{"passRMID":"' + TMB_cusid + '","passAccountType":"' + loanAcc.productType + '","accountNo":"' + loanAcc.accountNumber + '"},"state":{"ws":"/lightning/r/Account/' + recordId + '/view"}}');
                    String encUrl = '/one/one.app#' + EncodingUtil.base64Encode(cmUrl);
                    
                    loanWrap.taxConsentBtnPermission = false;
                    loanWrap.maskAccountNumber = (dataSecureProductHoldingHigh) ? NumberHelper.MarkAccountNo(NumberHelper.TrimLoanAccountNo(loanAcc.accountNumber)) : System.Label.Data_Condition_Hidden_Text;
                    loanWrap.prodSubFamily = (dataSecureProductHoldingLow) ? mapProductCodeProduct2.get(loanAcc.productCode)?.Sub_Family__c : System.Label.Data_Condition_Hidden_Text;
                    loanWrap.prodName = (dataSecureProductHoldingLow) ? mapProductCodeProduct2.get(loanAcc.productCode)?.Name : System.Label.Data_Condition_Hidden_Text;
                    loanWrap.accountStatus = (dataSecureProductHoldingLow) ? loanAcc.accountStatus : System.Label.Data_Condition_Hidden_Text;
                    loanWrap.contractEndDate = System.label.ERR008;
                    loanWrap.hasCoborrower = (dataSecureProductHoldingHigh) ? loanAcc.hasCoborrower : System.Label.Data_Condition_Hidden_Text;
                    loanWrap.statusDesc04 = 'ERROR';
                    loanWrap.editConsentUrl = encUrl;

                    OnlineServiceLog onlineOSC04Log = getDataFrom04(loanAcc.accountNumber);
                    if(onlineOSC04Log.errorMesssage == 'Unauthorized'){
                        wrapperForRT.statusDesc01 = 'Unauthorized';
                    }
                    
                    OnlineServiceLogList.add(onlineOSC04Log);
                    
                    try{ 
                        String responseBodyFrom04 = onlineOSC04Log.responseBody;

                        if(onlineOSC04Log.isSuccess){
                            if(String.valueOf(getResult('GetLoanAccountDetailResponse.Result.LoanInformation', JSON.deserializeUntyped(responseBodyFrom04))) != null ){
                                String businessType = responseBodyFrom04 != null && String.isNotEmpty(responseBodyFrom04) ? String.valueOf(getResult('GetLoanAccountDetailResponse.Result.LoanInformation.BusinessType', JSON.deserializeUntyped(responseBodyFrom04))) : '';
                                String endDateLong = responseBodyFrom04 != null && String.isNotEmpty(responseBodyFrom04) ? String.valueOf(getResult('GetLoanAccountDetailResponse.Result.LoanInformation.ContractEndDate', JSON.deserializeUntyped(responseBodyFrom04))) : '';
                                List<String> endDatelst = endDateLong.split('\\+', 2);
                                String endDate = date.valueOf(endDatelst.get(0)).format();

                                loanWrap.taxConsentBtnPermission = verifyTaxCertifyBtnPermission(businessType);
                                loanWrap.contractEndDate = (dataSecureProductHoldingHigh) ? endDate : System.Label.Data_Condition_Hidden_Text; 
                                loanWrap.statusDesc04 = 'success';
                            }
                        }
                    }catch(Exception e){
                        System.debug(e.getMessage());
                        System.debug(e.getStackTraceString());
                    }
                    loanAccWrapList.add(loanWrap);
                }

                wrapperForRT.loanWrapper = loanAccWrapList;
            }

            String log01Body = RTL_ProductHoldingsLightningUtil.parseLogOSCService(responseBody01, 'CustomerAccount - OSC01');
            
            RTL_CampaignUtil.saveToOnlineLog(
                isSuccess01,
                acct.Name,
                String.isNotEmpty(StatusDesc01) ? StatusDesc01 : 'Null response',
                '', // msLogId
                UserInfo.getName(),
                TMB_cusid,
                taxCertificateController.getServiceName('OSC01'),
                requestBody01,
                log01Body,
                acct,
                StartTime01,
                Datetime.now()
            );

            RTL_CampaignUtil.saveToOnlineLog(OnlineServiceLogList, acct.Name, '', '', UserInfo.getName(), TMB_cusid, taxCertificateController.getServiceName('OSC04'), acct, StartTime01, Datetime.now());
            
        }catch(Exception e){
            RTL_CampaignUtil.saveToOnlineLog(
                isSuccess01,
                acct.Name,
                String.isNotEmpty(StatusDesc01) ? StatusDesc01 : 'Null response',
                '', // msLogId
                UserInfo.getName(),
                TMB_cusid,
                taxCertificateController.getServiceName('OSC01'),
                requestBody01,
                responseBody01,
                acct,
                StartTime01,
                Datetime.now()
            );
            wrapperForRT.statusDesc01 = 'ERROR';
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            if(e.getMessage().toLowerCase().contains('timed out')) wrapperForRT.statusDesc01 = 'TIMEOUT';
            return wrapperForRT;
        }
        return wrapperForRT;
    }

    public static String getLoanAccount(String responseBody){
        if(String.valueOf(getResult('GetCustomerAccountResponse.LoanAccounts.LoanAccount', JSON.deserializeUntyped(responseBody))) != null ){
            Map<String,Object> obj = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
            String strnew = JSON.serializePretty(obj.get('GetCustomerAccountResponse'));
            Map<String,Object> obj2 = (Map<String,Object>) JSON.deserializeUntyped(strnew);
            String strnew2 = JSON.serializePretty(obj2.get('LoanAccounts'));
            Map<String,Object> obj3 = (Map<String,Object>) JSON.deserializeUntyped(strnew2);
            String strnew3 = JSON.serializePretty(obj3.get('LoanAccount'));
            return strnew3;
        }else{
            return '';
        }
    }

    public static Boolean verifyTaxCertifyBtnPermission(String businessType){
        return taxCertBtnProfilePermssion.contains(currentUser.Profile.Name) && taxCertBtnBusTypePermission.contains(businessType);  
    }

    public static OnlineServiceLog getDataFrom04(String accountNumber){
        String body04 = '{"GetLoanAccountRequest":{"RMID":"","FIIdent":"","AccountNumber":"' + accountNumber + '","AccountType":"com.fnis.xes.AL","ProductType":""}}';
        String StatusDesc;
        String StatusCode;
        Boolean isSuccess;
        String responseBody;
        Datetime StartTime = (Datetime)Datetime.now();
        //try catch เพื่อให้กรณีที่ record แรกตาย แต่ให้ record สองยังทำงานต่อได้และยังสามารถ log ต่อได้เพราะไม่ได้ throw ในนี้
        //กรณี catch จะมีพวก timeout, แกะไม่เจอ
        try{
            HTTPResponse res = getOSC04(body04, '');
            responseBody = res.getBody();
            
            StatusDesc = responseBody != null && String.isNotEmpty(responseBody) ? String.valueOf(getResult('Status.StatusDesc', JSON.deserializeUntyped(responseBody))) : '';
            StatusCode = responseBody != null && String.isNotEmpty(responseBody) ? String.valueOf(getResult('Status.StatusCode', JSON.deserializeUntyped(responseBody))) : '';
            isSuccess = StatusDesc == 'success';

            responseBody = RTL_ProductHoldingsLightningUtil.parseLogOSCService(responseBody, 'LoanAccount - OSC04');
        }catch(Exception e){
            isSuccess = false;
            StatusDesc = e.getMessage();
        }
        
        OnlineServiceLog onlineOSC04log = new OnlineServiceLog(isSuccess, StatusDesc, body04, responseBody, StartTime, Datetime.now());
         
        return onlineOSC04log;
    }
}