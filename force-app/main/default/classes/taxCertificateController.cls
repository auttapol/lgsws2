public class taxCertificateController extends AbstractCoreClass {
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
                currentUser = [SELECT Id, Name, Employee_ID__c, Profile.Name, UserRole.Name FROM User WHERE Id = :userInfo.getUserId()];
            }
            return currentUser;
        }
        set;
    }

    public static Map<String, Set<String>> taxCertSearchBtnPermssion {
        get{
            if(taxCertSearchBtnPermssion == null){
                taxCertSearchBtnPermssion = new Map<String, Set<String>>();
                List<Tax_Certificate_Admin__mdt> permissionLst = Tax_Certificate_Admin__mdt.getAll().values();

                for (Tax_Certificate_Admin__mdt each : permissionLst) {
                    if(taxCertSearchBtnPermssion.containsKey(each.Profile_Name__c)){
                        String roleName = each.Role_Name__c == null ? 'ALL' : each.Role_Name__c;
                        taxCertSearchBtnPermssion.get(each.Profile_Name__c).add(roleName);
                    } else {
                        Set<String> roleSet = new Set<String>();
                        String roleName = each.Role_Name__c == null ? 'ALL' : each.Role_Name__c;
                        roleSet.add(roleName);
                        taxCertSearchBtnPermssion.put(each.Profile_Name__c, roleSet);
                    }
                }
            }
            return taxCertSearchBtnPermssion;
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

    public class coborrowerWrapperClass{
        @AuraEnabled
        public String RMID;
        @AuraEnabled 
        public String Name;
        @AuraEnabled 
        public String Relationship;
    }
    
    public class loanDetailWrapperClass{
        @AuraEnabled 
        public String fiident;
        @AuraEnabled 
        public String accountNumber;
        @AuraEnabled 
        public String businessType;
        @AuraEnabled 
        public String creditLimit;
        @AuraEnabled 
        public String openDate;
        @AuraEnabled 
        public String prodName;
        @AuraEnabled 
        public List<coborrowerWrapperClass> coborrow;
        @AuraEnabled 
        public String statusDesc04;
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
            throwExcp(e.getMessage());
        }
        return res;
    }

    @AuraEnabled
    public static loanDetailWrapperClass getLoanInformationData(String body, String tmbCustId){
        String accountNumber;
        String responseBody;
        String StatusDesc;
        String StatusCode;
        Boolean isSuccess = false;
        Account acct;
        String logBody;

        if (tmbCustId != '' && tmbCustId != null) {
            List<Account> accList = [SELECT Id, Name, TMB_Customer_ID_PE__c, Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c = :tmbCustId LIMIT 1];
            if(accList.size() > 0){
                System.debug('accList : '+accList);
                acct = accList.get(0);
            }
        }

        String serviceName = getServiceName('OSC04');
        Datetime StartTime = (Datetime)Datetime.now();

        loanDetailWrapperClass loanDetail = new loanDetailWrapperClass();
        List<coborrowerWrapperClass> coborrowerLst = new List<coborrowerWrapperClass>();

        try{
            HTTPResponse res = getOSC04(body, tmbCustId);
            responseBody = res.getBody();

            StatusDesc = responseBody != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('Status.StatusDesc', JSON.deserializeUntyped(res.getBody()))) : '';
            StatusCode = responseBody != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('Status.StatusCode', JSON.deserializeUntyped(res.getBody()))) : '';
            isSuccess = StatusDesc == 'success';

            logBody = RTL_ProductHoldingsLightningUtil.parseLogOSCService(responseBody, 'LoanAccount - OSC04');

            RTL_CampaignUtil.saveToOnlineLog(
                isSuccess,
                acct?.Name == null ? '' : acct.Name, // customerName
                String.isNotEmpty(StatusDesc) ? StatusDesc : 'Null response',
                '', // msLogId
                UserInfo.getName(),
                tmbCustId,
                ServiceName,
                body, // Request Body
                logBody, // Response Body
                acct,
                StartTime, // Start datetime; convert to GMT locale time
                Datetime.now() // End datetime
            );

            if(StatusDesc != 'success'){
                if(StatusDesc == 'Unauthorized'){
                    loanDetail.statusDesc04 = 'Unauthorized';
                }
                else{
                    loanDetail.statusDesc04 = 'ERROR';
                }
                return loanDetail;
            }

            accountNumber = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('GetLoanAccountDetailResponse.Result.LoanInformation.AccountNumber', JSON.deserializeUntyped(res.getBody()))) : '';
            String fiident = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('GetLoanAccountDetailResponse.Result.LoanInformation.FIIdent', JSON.deserializeUntyped(res.getBody()))) : '';
            String businessType = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('GetLoanAccountDetailResponse.Result.LoanInformation.BusinessType', JSON.deserializeUntyped(res.getBody()))) : '';
            String productCode = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('GetLoanAccountDetailResponse.Result.LoanInformation.ProductCode', JSON.deserializeUntyped(res.getBody()))) : '';
            String creditLimit = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('GetLoanAccountDetailResponse.Result.LoanInformation.CreditLimit', JSON.deserializeUntyped(res.getBody()))) : '';
            String openDate = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('GetLoanAccountDetailResponse.Result.LoanInformation.OpenDate', JSON.deserializeUntyped(res.getBody()))) : '';
            String coborrwerStatus = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('GetLoanAccountDetailResponse.Result.CoBorrowerInformation.Status', JSON.deserializeUntyped(res.getBody()))) : '';
            String loanAccountResponseStatusDesc = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('GetLoanAccountResponse.Status.StatusDesc', JSON.deserializeUntyped(res.getBody()))) : '';
            String acctlnqStatusDesc = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('GetLoanAccountResponse.AcctInqRs.Status.StatusDesc', JSON.deserializeUntyped(res.getBody()))) : '';

            if(loanAccountResponseStatusDesc.toLowerCase() != 'success' || acctlnqStatusDesc.toLowerCase() != 'success'){
                loanDetail.statusDesc04 = 'Account not found';
                return loanDetail;
            }
            
            String prodName = '';
            
            List<String> oDate =  openDate.split('\\+', 2);
            String opDate = date.valueOf(oDate.get(0)).format();


            if(coborrwerStatus == 'SUCCESS'){
                String myCoborrower = getCoBorrower(responseBody);
                coborrowerLst = (List<coborrowerWrapperClass>)JSON.deserialize(myCoborrower, List<coborrowerWrapperClass>.class);
            }else{
                loanDetail.statusDesc04 = 'Account not found';
                return loanDetail;
            }

            if(!CSV_RDTaxConsentController.verifyTaxCertifyBtnPermission(businessType)){
                loanDetail.statusDesc04 = 'Account not found';
                return loanDetail;
            }

            if(productCode != ''){
                List<Product2> prodlst = [SELECT Id, Name, ProductCode FROM Product2 WHERE ProductCode = :productCode LIMIT 1];

                if(prodlst.size() > 0){
                    prodName = prodlst.get(0).Name;
                }
            }

            loanDetail.fiident = fiident;
            loanDetail.accountNumber = NumberHelper.MarkAccountNo(NumberHelper.TrimLoanAccountNo(accountNumber));
            loanDetail.businessType = businessType;
            loanDetail.creditLimit = creditLimit;
            loanDetail.openDate = opDate;
            loanDetail.prodName = prodName;
            loanDetail.coborrow = coborrowerLst;

        }catch(Exception e){
            RTL_CampaignUtil.saveToOnlineLog(
                isSuccess,
                acct?.Name == null ? '' : acct.Name, // customerName
                String.isNotEmpty(StatusDesc) ? StatusDesc : 'Null response',
                '', // msLogId
                UserInfo.getName(),
                tmbCustId,
                ServiceName,
                body, // Request Body
                logBody, // Response Body
                acct,
                StartTime, // Start datetime; convert to GMT locale time
                Datetime.now() // End datetime
            );

            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());

            if(e.getMessage().toLowerCase().contains('timed out')) {
                loanDetail.statusDesc04 = 'TIMEOUT';
                return loanDetail;
            }
            else if(e.getMessage().toLowerCase().contains('unauthorized')) {
                loanDetail.statusDesc04 = 'Unauthorized';
                return loanDetail;
            }

            if(accountNumber == null) return loanDetail;
        }
        return loanDetail;
    }

    @AuraEnabled
    public static String getTaxConsentDataByRMID(String rmid){
        Datetime StartTime = (Datetime)Datetime.now();
        String ServiceName = getServiceName('TaxCert_GetConsents'); 
        String result ;
        String StatusDesc;
        String StatusCode;
        Boolean isSuccess = false;
        String body;
        String key ;
        String decryptedBody;
        Account acct;

        List<Account> accList = [SELECT Id, Name, TMB_Customer_ID_PE__c, Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c = :rmid LIMIT 1];

        if(accList.size() > 0){
            acct = accList.get(0);
        }

        try{
            body = '{"query":{"search_type":"rm-id","search_value":"'+  rmid + '"}}';
            key = SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), 'DWH');
            String encryptedBody = SCSMessageAPIUtil.encryptMessageWithKey(body, key);

            Uuid uuidGenerateor = new Uuid();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + ApiGatewayToken);
            req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
            req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
            req.setHeader('Request-UID', uuidGenerateor.getValue());
            req.setHeader('Request-App-ID', APPID);
            req.setEndpoint('callout:TaxCert_GetConsents');
            req.setBody(encryptedBody);
            req.setTimeout(timeout);

            Http http = new Http();
            HTTPResponse res = http.send(req);
            String  responseBody = res.getBody();
            if(responseBody.contains('Unauthorized')){
                result = 'Unauthorized';
                decryptedBody = responseBody;
            }
            else{
                decryptedBody = SCSMessageAPIUtil.decryptMessageWithKey(responseBody, key);
                result = decryptedBody;
    
                StatusDesc = decryptedBody != null && String.isNotEmpty(decryptedBody) ? String.valueOf(getResult('status.description', JSON.deserializeUntyped(decryptedBody))) : '';
                StatusCode = decryptedBody != null && String.isNotEmpty(decryptedBody) ? String.valueOf(getResult('status.code', JSON.deserializeUntyped(decryptedBody))) : '';
                isSuccess = (StatusDesc == 'Success' || StatusDesc == 'Data not found');
            }
            
            RTL_CampaignUtil.saveToOnlineLog(
                isSuccess,
                acct?.Name == null ? '' : acct.Name, // customerName
                String.isNotEmpty(StatusDesc) ? StatusDesc : 'Null response',
                '', // msLogId
                UserInfo.getName(),
                rmid,
                ServiceName,
                body, // Request Body
                decryptedBody, // Response Body
                acct,
                StartTime, // Start datetime; convert to GMT locale time
                Datetime.now() // End datetime
            );
        }catch(Exception e){
            RTL_CampaignUtil.saveToOnlineLog(
                isSuccess,
                acct?.Name == null ? '' : acct.Name, // customerName
                String.isNotEmpty(StatusDesc) ? StatusDesc : 'Null response',
                '', // msLogId
                UserInfo.getName(),
                rmid,
                ServiceName,
                body, // Request Body
                decryptedBody, // Response Body
                acct,
                StartTime, // Start datetime; convert to GMT locale time
                Datetime.now() // End datetime
            );
            System.debug(e.getMessage());

            if(e.getMessage().toLowerCase().contains('timed out')) return 'TIMEOUT';
            else if(e.getMessage().toLowerCase().contains('unauthorized')) return 'Unauthorized';

            throwExcp(e.getMessage());
        }
        return result;
    }

    @AuraEnabled
    public static String CreateUpdateTaxConsent(String rmid, String acctNo, String consentFlag, String fiident, String credentialName){
        String bodyOSC04;
        String responseBody04;
        String StatusDesc04;
        String StatusCode04;
        Boolean isSuccess04 = false;
        String forRT;
        Boolean isSuccess = false;
        String StatusDesc;
        String StatusCode;
        String decryptedBody;
        String serviceName;
        Datetime StartTime;
        Datetime StartTime04 = (Datetime)Datetime.now();

        Account acct;

        List<Account> accList = [SELECT Id, Name, TMB_Customer_ID_PE__c, Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c = :rmid LIMIT 1];
        if(accList.size() > 0){
            acct = accList.get(0);
        }
        
        if(fiident == '' || fiident == null){
            bodyOSC04 = '{"GetLoanAccountRequest":{"RMID":"' + rmid + '","FIIdent":"","AccountNumber":"' + acctNo + '","AccountType":"com.fnis.xes.AL","ProductType":""}}';
            HTTPResponse res = getOSC04(bodyOSC04, '');
            responseBody04 = res.getBody();
            
            fiident = res != null && String.isNotEmpty(res.getBody()) ? String.valueOf(getResult('GetLoanAccountDetailResponse.Result.LoanInformation.FIIdent', JSON.deserializeUntyped(res.getBody()))) : '';
            StatusDesc04 = responseBody04 != null && String.isNotEmpty(responseBody04) ? String.valueOf(getResult('Status.StatusDesc', JSON.deserializeUntyped(responseBody04))) : '';
            StatusCode04 = responseBody04 != null && String.isNotEmpty(responseBody04) ? String.valueOf(getResult('Status.StatusCode', JSON.deserializeUntyped(responseBody04))) : '';
            isSuccess04 = responseBody04 != null && String.isNotEmpty(responseBody04) ? StatusDesc04 == 'success' : StatusDesc04 == 'success' ;
        }

        if(fiident.length() != 16 && fiident != ''){
            throwExcp('Error get fiident fail.');
        }

        String subfiident1 = fiident.substring(0, 4);
        String subfiident2 = fiident.substring(4, 8);
        String subfiident3 = fiident.substring(8, 12);
        String subfiident4 = fiident.substring(12, 16);
        string body;

        if(credentialName == 'TaxCert_CreateConsents'){
            body = '{"customer":{"profile":{"rm_id":"' + rmid + '"},"tax_certificate_consents":{"acct_ctl1":"' + subfiident1 + '","acct_ctl2":"' + subfiident2 + '","acct_ctl3":"' + subfiident3 + '","acct_ctl4":"'+ subfiident4 +'","acct_nbr":"' + acctNo + '","channel":"CRM","flag":"' + consentFlag + '","create_by":"' + currentUser.Employee_ID__c + '"}}}';
        }else{
            body = '{"customer":{"profile":{"rm_id":"' + rmid + '"},"tax_certificate_consents":{"acct_ctl1":"' + subfiident1 + '","acct_ctl2":"' + subfiident2 + '","acct_ctl3":"' + subfiident3 + '","acct_ctl4":"'+ subfiident4 +'","acct_nbr":"' + acctNo + '","channel":"CRM","flag":"' + consentFlag + '","update_by":"' + currentUser.Employee_ID__c + '"}}}';
        }

        try{
            serviceName = getServiceName(credentialName);
            StartTime = (Datetime)Datetime.now();
            String key = SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), 'DWH');
            String encryptedBody = SCSMessageAPIUtil.encryptMessageWithKey(body, key);

            Uuid uuidGenerateor = new Uuid();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + ApiGatewayToken);
            req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
            req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
            req.setHeader('Request-UID', uuidGenerateor.getValue());
            req.setHeader('Request-App-ID', APPID);
            req.setEndpoint('callout:' + credentialName);
            req.setBody(encryptedBody);
            req.setTimeout(timeout);
            //timeout
            Http http = new Http();
            HTTPResponse res = http.send(req);
            String  responseBody = res.getBody();
            if(responseBody.contains('Unauthorized')){
                RTL_CampaignUtil.saveToOnlineLog(
                    isSuccess04,
                    acct?.Name == null ? '' : acct.Name, // customerName
                    String.isNotEmpty(StatusDesc04) ? StatusDesc04 : 'Unauthorized',
                    '', // msLogId
                    UserInfo.getName(),
                    rmid,
                    serviceName,
                    bodyOSC04, // Request Body
                    responseBody04, // Response Body
                    acct,
                    StartTime04, // Start datetime; convert to GMT locale time
                    Datetime.now() // End datetime
                );
                return '401';
            }


            decryptedBody = SCSMessageAPIUtil.decryptMessageWithKey(responseBody, key);

            StatusDesc = decryptedBody != null && String.isNotEmpty(decryptedBody) ? String.valueOf(getResult('status.description', JSON.deserializeUntyped(decryptedBody))) : '';
            StatusCode = decryptedBody != null && String.isNotEmpty(decryptedBody) ? String.valueOf(getResult('status.code', JSON.deserializeUntyped(decryptedBody))) : '';
            isSuccess = decryptedBody != null && String.isNotEmpty(decryptedBody) ? StatusDesc == 'Success' : StatusDesc == 'Success';
            if(isSuccess){
                forRT = 'true';
            }
            else if(!isSuccess){
                forRT = 'false';
            }
            

            RTL_CampaignUtil.saveToOnlineLog(
                isSuccess,
                acct?.Name == null ? '' : acct.Name, // customerName
                String.isNotEmpty(StatusDesc) ? StatusDesc : 'Null response',
                '', // msLogId
                UserInfo.getName(),
                rmid,
                ServiceName,
                body, // Request Body
                decryptedBody, // Response Body
                acct,
                StartTime, // Start datetime; convert to GMT locale time
                Datetime.now() // End datetime
            );

            if(StatusDesc04 != null){
                RTL_CampaignUtil.saveToOnlineLog(
                    isSuccess04,
                    acct?.Name == null ? '' : acct.Name, // customerName
                    String.isNotEmpty(StatusDesc04) ? StatusDesc04 : 'Null response',
                    '', // msLogId
                    UserInfo.getName(),
                    rmid,
                    getServiceName('OSC04'),
                    bodyOSC04, // Request Body
                    responseBody04, // Response Body
                    acct,
                    StartTime04, // Start datetime; convert to GMT locale time
                    Datetime.now() // End datetime
                );
            }
        }catch(Exception e){
            RTL_CampaignUtil.saveToOnlineLog(
                isSuccess,
                acct?.Name == null ? '' : acct.Name, // customerName
                String.isNotEmpty(StatusDesc) ? StatusDesc : 'Null response',
                '', // msLogId
                UserInfo.getName(),
                rmid,
                ServiceName,
                body, // Request Body
                decryptedBody, // Response Body
                acct,
                StartTime, // Start datetime; convert to GMT locale time
                Datetime.now() // End datetime
            );

            if(StatusDesc04 != null){
                RTL_CampaignUtil.saveToOnlineLog(
                    isSuccess04,
                    acct?.Name == null ? '' : acct.Name, // customerName
                    String.isNotEmpty(StatusDesc04) ? StatusDesc04 : 'Null response',
                    '', // msLogId
                    UserInfo.getName(),
                    rmid,
                    getServiceName('OSC04'),
                    bodyOSC04, // Request Body
                    responseBody04, // Response Body
                    acct,
                    StartTime04, // Start datetime; convert to GMT locale time
                    Datetime.now() // End datetime
                );
            }

            System.debug(e.getMessage());
            if(e.getMessage().toLowerCase().contains('timed out')) return 'TIMEOUT';
        }

        return forRT;
    }
    
    public static String getServiceName(String devName){
        List<NamedCredential> endPoint = [SELECT Endpoint, id  FROM NamedCredential WHERE DeveloperName  = :devName LIMIT 1];
        if(endPoint.size() > 0){
            return endPoint.get(0).Endpoint;
        }
        return '';
    }

    public static void throwExcp(String msg){
        AuraHandledException e = new AuraHandledException(msg);
        e.setMessage(msg);
        throw e;
    }

    public static String getCoBorrower(String responseBody){
        Map<String,Object> obj = (Map<String,Object>) JSON.deserializeUntyped(responseBody);
        String strnew = JSON.serializePretty(obj.get('GetLoanAccountDetailResponse'));

        Map<String,Object> obj2 = (Map<String,Object>) JSON.deserializeUntyped(strnew);
        String strnew2 = JSON.serializePretty(obj2.get('Result'));

        Map<String,Object> obj3 = (Map<String,Object>) JSON.deserializeUntyped(strnew2);
        String strnew3 = JSON.serializePretty(obj3.get('CoBorrowerInformation'));

        Map<String,Object> obj4 = (Map<String,Object>) JSON.deserializeUntyped(strnew3);
        String strnew4 = JSON.serializePretty(obj4.get('CoBorrower'));

        return strnew4;
    }

    @AuraEnabled
    public static string getWatermarkHTML() {
        return currentUser.Employee_ID__c;
    }

    @AuraEnabled
    public static Boolean getSearchBtnPermission(){
        System.debug(taxCertSearchBtnPermssion);
        if(taxCertSearchBtnPermssion.containsKey(currentUser.Profile.Name)){
            if(taxCertSearchBtnPermssion.get(currentUser.Profile.Name).contains('ALL')){
                return true;
            }else{
                if(taxCertSearchBtnPermssion.get(currentUser.Profile.Name).contains(currentUser.UserRole.Name)){
                    return true;
                }
            }
        }
        return false;
    }
}