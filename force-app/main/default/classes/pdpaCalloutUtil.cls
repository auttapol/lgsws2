global class pdpaCalloutUtil {
    private static String f2fWebApiKey {
        get{
            if(f2fWebApiKey == null){
                if(UiThemeDisplay == 'Theme4t'){
                    f2fWebApiKey = AppConfig__c.getValues('PDPA_F2F_CANVAS_Tablet_Token') != null ? AppConfig__c.getValues('PDPA_F2F_CANVAS_Tablet_Token').Value__c : '5N03qpyC68vj7Nubuvxz8STd';
                }else{
                    f2fWebApiKey = AppConfig__c.getValues('PDPA_F2F_CANVAS_Brance_Token') != null ? AppConfig__c.getValues('PDPA_F2F_CANVAS_Brance_Token').Value__c : 'BHKhFmuIeC4kh3zG0wQErWsP';
                }
            }
            return f2fWebApiKey;
        }set;
    }

    private static String ETEAppId {
        get{
            if(ETEAppId == null){
                if(UiThemeDisplay == 'Theme4t'){
                    ETEAppId = AppConfig__c.getValues('PDPA_ETE_Digital_App_ID') != null ? AppConfig__c.getValues('PDPA_ETE_Digital_App_ID').Value__c : 'A0291-SF1';
                }else{
                    ETEAppId = AppConfig__c.getValues('PDPA_ETE_Paper_App_ID') != null ? AppConfig__c.getValues('PDPA_ETE_Paper_App_ID').Value__c : 'A0291';
                }
            }
            return ETEAppId;
        }set;
    }

    private static String UiThemeDisplay {
        get{
            return UserInfo.getUiThemeDisplayed();
        }set;
    }
    
    private static String ApiGatewayToken {
        get{
            if(ApiGatewayToken == null){
                if(!Test.isRunningTest()){
                    System.debug('ApiGatewayToken:::::');
                    ApiGatewayToken = SmartBDM_Utility.tokenKeyCalculateTools;
                    System.debug('ApiGatewayToken : ' + ApiGatewayToken);
                }else{
                    ApiGatewayToken = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBfbmFtZSI6IkNSTSBTYWxlcyBNY' +
                        'W5hZ2VtZW50IFN5c3RlbXMvU2FsZXNGb3JjZSAtIFNJVCIsInNjb3BlIjpbInJlYWQiLCJ' +
                        '3cml0ZSJdLCJleHAiOjE1ODMyMDgzNTAsImFwcF9pZCI6IkEwMjkxIiwianRpIjoiZTQ3N' +
                        '2QxZTgtNGY0MC00MzdmLTk0NWYtY2UxOThkMzgwZjA3IiwiY2xpZW50X2lkIjoiZjc5Njk' +
                        '4YTc5OWE0ODVlNDBhMGVkN2RjNDNmNDRmMTcifQ.EDqwHxlr8e8bn60NPoik9KCFK9wFUv' +
                        '9lZ_BtRhqMpykrEwao_XcTko_oQyt7gSEp7Iq51PzlS5pT6QZDL3dbJwW0d3Z0XBalP8h-' +
                        'rhsiPLgFqCaeHWeu1Fbakcnj-tukFGay8Mvkyqh1V2Yv3mWkN79JsP6Pw5hgwA2';
                }
            }
            orgPartCreateToken = Cache.Org.getPartition('local.CreateGateWayToken');
            return ApiGatewayToken;
        }set;
    }

    public static Integer timeout{
        get{
            if(timeout == null){
                AppConfig__c appCF = AppConfig__c.getValues('PDPA_Timeout');
                if(appCF == null){
                    timeout = 2;
                }else{
                    timeout =  Integer.valueOf(appCF.Value__c);
                }
            }
            return timeout;
        }
        set;
    }

    public static Boolean isGetHistSuccess = false;
    public static Cache.OrgPartition orgPartCreateToken;
    public static String tokenNullErrorMessage = 'Call out isn\'t start. ApiGatewayToken is null.';

    public static String getPDPAF2FServiceToken(String closeAction, String closeActionType, String consentAction, String consentType, String customerId, String staffId, String branchCode, String language, String firstName, String lastName, String IdType, String IdNumberEncrypt){
        System.debug('getPDPAF2FServiceToken::::');
        DateTime startTime = DateTime.now();
        String serviceName = 'PDPA_GET_F2F_Service_Token';
        String tmbCustId = customerId;
        String result = '';

        if(ApiGatewayToken == null || ApiGatewayToken == ''){
            onlineLog(serviceName, false, tmbCustId, tokenNullErrorMessage, null, '', '', startTime, startTime,'');
            return result;
        }

        customerId = customerId == '' ? customerId : customerId.length() == 30 ? customerId.substring(16, 30) : customerId;

        String requestBody = '{' +
            '"f2fWebApiKey": "' + f2fWebApiKey + '",' +
            '"closeAction": "' + closeAction + '",' +
            '"closeActionType": "' + closeActionType + '",' +
            '"consentAction": "' + consentAction + '",' +
            '"consentType": "' + consentType + '",' +
            '"customerId": "' + customerId + '",' +
            '"staffId": "' + staffId + '",' +
            '"branchCode": "' + branchCode + '",' +
            '"language": "' + language + '",' +
            '"firstName": "' + firstName + '",' +
            '"lastName": "' + lastName + '"';

        requestBody = IdType == 'PP' || IdType == 'CI' ? requestBody +
            ',"identification": {' +
            '    "type": "' + IdType + '",' +
            '    "value": "' + IdNumberEncrypt + '"' +
            '}' : requestBody + '';
        
        requestBody += '}';

		System.debug('PDPA_GET_F2F_Service_Token');
        System.debug('requestBody : ' + requestBody);

        HttpRequest req = new HttpRequest();
        Http http = new Http();
        Uuid uuidGenerateor = new Uuid();

        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=utf-8');
        req.setHeader('Authorization', 'Bearer ' + ApiGatewayToken);
        // req.setHeader('acronym', uuidGenerateor.getValue());
        req.setHeader('request-uid', uuidGenerateor.getValue());
        req.setHeader('request-datetime', Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));

        req.setEndpoint('callout:PDPA_and_Market_Consent_F2F_AUTH');
        req.setBody(requestBody);
        req.setTimeout(timeout * 1000);
        
		Boolean isSuccess = false;
        String errorMessage = '';
        try {
            HttpResponse res = http.send(req);
            result = res.getBody();
            
            isSuccess = true;
            errorMessage = 'Success';
            Integer statusCode = res.getStatusCode();
            System.debug('statusCode: ' + statusCode);
            if(statusCode == 200){
                System.debug('PDPAStructure.parseJsonToObj(result).status.code : ' + PDPAStructure.parseJsonToObj(result).status.code);
                System.debug('PDPAStructure.parseJsonToObj(result).status.description : ' + PDPAStructure.parseJsonToObj(result).status.description);
                if(PDPAStructure.parseJsonToObj(result).status.code == '0000'){
                    isSuccess = true;
                    errorMessage = 'Success';
                }else{
                    isSuccess = false;
                    errorMessage = PDPAStructure.parseJsontoObj(result).status.description;
                }
            }else{
                isSuccess = false;
                errorMessage = PDPAStructure.parseJsontoObj(result).status.description;
                System.debug('errorMessage : ' + errorMessage);
            }
            
        } catch (Exception e) {
            result = e.getMessage();
            errorMessage = e.getMessage();
        }
        String msLogId = uuidGenerateor.getValue();
        String responseBody = result;
        
        DateTime endTime = DateTime.now();
        onlineLog(serviceName, isSuccess, tmbCustId, errorMessage, msLogId, requestBody, responseBody, startTime, endTime, 'callout:PDPA_and_Market_Consent_F2F_AUTH');
        return result;
    }

    @AuraEnabled
    public static String getFagPdpa(String tmbCustId, String serviceName){
        String result = '';
        String requestBody = '';
        String responseBody;
        String response;
        Boolean isSuccess = false;
        String errorMessage;
        String webServiceErrorMessage;
        DateTime startTime = DateTime.now();

        if(ApiGatewayToken == null || ApiGatewayToken == ''){
            onlineLog(serviceName, false, tmbCustId, tokenNullErrorMessage, null, '', '', startTime, startTime,'');
            result = '{"isSuccess":'+isSuccess+',"errorMessage":"invalid_token"}';
            return result;
        }

        String customerId = tmbCustId.substring(16,30);
        String financialId = tmbCustId.substring(0,16);

        requestBody = '{"customerId":"' + customerId + '","financialId":"' + financialId + '"}';

        HttpRequest req = new HttpRequest();
        APIGateway_Service.RequestToken request = new APIGateway_Service.RequestToken();
        request.endpoint = 'PDPA_and_Market_Consent_getFlag';        

        Http http = new Http();
        Uuid uuidGenerateor = new Uuid();

        req.setMethod('POST');

        req.setHeader('Content-Type', 'application/json; charset=utf-8');
        req.setHeader('Request-UID', uuidGenerateor.getValue());
        req.setHeader('Authorization', 'bearer ' + ApiGatewayToken);
        req.setHeader('Request-Datetime', Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
        req.setHeader('Request-App-ID', ETEAppId);      

        req.setEndpoint(request.parseEndpoint());
        req.setBody(requestBody);
        req.setTimeout(timeout * 1000);
        HttpResponse res;
        
        try{
            res = http.send(req);
            responseBody = res.getBody();
            response = responseBody;
            // response = '{' +
            //     '"status": {' +
            //     '  "code": "0000",' +
            //     '  "description": "Success"' +
            //     '},' +
            //     '"data": {' +
            //     '  "customerId": "00000000000500",' +
            //     '  "financialId": "0011000000000000",' +
            //     '  "consents": [' +
            //     '    {' +
            //     '      "type": "MARKET",' +
            //     '      "flag": "Y",' +
            //     '      "version": "15",' +
            //     '      "channel": "MB",' +
            //     '      "consentBy": "9882741D",' +
            //     '      "consentDateTime": "2020-02-18T10:21:51",' +
            //     '      "consentSignDate": "",' +
            //     '      "needUpdateFlag": "Y",' +
            //     '      "needUpdateFlagReason": ""' +
            //     '    },' +
            //     '    {' +
            //     '      "type": "DATA-ANALYTIC",' +
            //     '      "flag": "Y",' +
            //     '      "version": "2",' +
            //     '      "channel": "MEIB",' +
            //     '      "consentBy": "98750099",' +
            //     '      "consentDateTime": "2020-02-18T10:21:51",' +
            //     '      "consentSignDate": "2020-02-18",' +
            //     '      "needUpdateFlag": "Y",' +
            //     '      "needUpdateFlagReason": ""' +
            //     '    },' +
            //     '    {' +
            //     '      "type": "PDPA-DEPOSIT",' +
            //     '      "flag": "Y",' +
            //     '      "version": "2",' +
            //     '      "channel": "MEIB",' +
            //     '      "consentBy": "98750099",' +
            //     '      "consentDateTime": "2020-02-18T10:21:51",' +
            //     '      "consentSignDate": "2020-02-18",' +
            //     '      "needUpdateFlag": "Y",' +
            //     '      "needUpdateFlagReason": ""' +
            //     '    }' +
            //     '  ]' +
            //     '}' +
            //   '}';
            // System.debug(response.getStatusCode());
            
            if(response != null){  
                if(response.contains('"consentDateTime": ""')){
                    response = response.replace('"consentDateTime": ""', '"consentDateTime": null');
                }                
                if(response.contains('"consentSignDate": ""')){
                    response = response.replace('"consentSignDate": ""', '"consentSignDate": null');
                }
            } 
            
            Integer statusCode = res.getStatusCode();
            if(statusCode == 200){
                if(PDPAStructure.parseJsonToObj(response).status.code == '0000'){
                    isSuccess = true;
                    errorMessage = 'Success';
                }else{
                    isSuccess = false;
                    errorMessage = PDPAStructure.parseJsontoObj(response).status.description;
                }
            } else if(statusCode == 401) {
                onlineLog(serviceName, false, tmbCustId, PDPAStructure.parseJsontoObj(response).status.description, uuidGenerateor.getValue(), requestBody, responseBody, startTime, startTime,request.parseEndpoint());
                result = '{"isSuccess":'+isSuccess+',"errorMessage":"invalid_token"}';
                return result;
            } else{
                isSuccess = false;
                errorMessage = PDPAStructure.parseJsontoObj(response).status.description;
            }
            webServiceErrorMessage = errorMessage;
        }catch(Exception e){
            System.debug('System error: ' + e.getMessage());
            System.debug('There is error during processing : ' + e.getStackTraceString());
            // result = result == '' ? result + '"message":"' + e.getMessage() + '"' : result + ',"message":"' + e.getMessage() + '"';
            errorMessage = e.getMessage();
        }
        
        DateTime endTime = DateTime.now();
		        
        if(isSuccess){
            PDPAStructure pdpaData = New PDPAStructure();
            try {
                pdpaData = PDPAStructure.parseJsontoObj(response);
                

                String errorMessageRespone = pdpaData.status.description;
                
                for (PDPAStructure.PDPAconsents consent : pdpaData.data.consents) {
                    if(consent.type == 'PDPA-DEPOSIT' || consent.type == 'MARKET'){
                        String type = consent.type == 'PDPA-DEPOSIT' ? 'PDPA' : consent.type;
                        
                        result = result == '' ? result + '"' + type + 'Fag":"' + consent.flag + '"' : result + ',"' + type + 'Fag":"' + consent.flag + '"';
                        result = result == '' ? result + '"' + type + 'NeedUpdate":"' + consent.needUpdateFlag + '"' : result + ',"' + type + 'NeedUpdate":"' + consent.needUpdateFlag + '"';
                    }
                }
            } catch (Exception e) {
                System.debug('error : ' + e.getMessage());
            }
        }
        
        onlineLog(serviceName, isSuccess, tmbCustId, errorMessage, uuidGenerateor.getValue(), requestBody, responseBody, startTime, endTime,'PDPA_and_Market_Consent_getFlag');
        
        result = result == '' ? result + '"isSuccess":"' + isSuccess + '"' : result + ',"isSuccess":"' + isSuccess + '"';
        result = result == '' ? result + '"errorMessage":"' + webServiceErrorMessage + '"' : result + ',"errorMessage":"' + webServiceErrorMessage + '"';
        result = '{' + result + '}';
        
        return result;
    }
    
    public static String callHistService(Account currAccount, String rmId){
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();

		String serviceName = 'PDPA_MARKET_CONSENT_VIEW_HISTORY';
        String callendPoint = 'PDPA_and_Market_Consent_getHistory';
        String customerName = currAccount.Name;
        String customerId = currAccount.TMB_Customer_ID_PE__c.substring(16, 30);
        String errorMessage;
        String responseBody;
        String response;
        DateTime startTime = DateTime.now();
        Integer timeout = Integer.valueOf(AppConfig__c.getValues('PDPA_Timeout').Value__c);   
        HttpRequest req = new HttpRequest();
        String msLogId;
        String tmbCustId = currAccount.TMB_Customer_ID_PE__c;
        
        isGetHistSuccess = false;

        if(ApiGatewayToken == null  || ApiGatewayToken == ''){
            onlineLog(serviceName, false, tmbCustId, tokenNullErrorMessage, null, '', '', startTime, startTime,'');
            response = '{"isSuccess":false,"errorMessage":"invalid_token"}';
            return response;
        }

        APIGateway_Service.RequestToken requestToken = new APIGateway_Service.RequestToken();
        requestToken.endpoint = callendPoint;

        Http http = new Http();
        Uuid uuidGenerateor = new Uuid();
        
        String consentDateFrom = DateTime.now().Addyears(-2).format('yyyy-MM-dd');
        String consentDateTo = DateTime.now().format('yyyy-MM-dd');    
        String requestBody = '{' +
            '"customerId":"' + customerId + '",' +
            '"tcifNo":"' + '",' +
            '"customerNo":"' + '",' +
            '"consentType":"' + '",' +
            '"consentDateFrom":"' + consentDateFrom +'",' +
            '"consentDateTo":"' + consentDateTo +
            '"}';
        System.debug('requestBody : ' + requestBody);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json; charset=utf-8');
        req.setHeader('Request-UID', uuidGenerateor.getValue());
        req.setHeader('Authorization', 'bearer ' + ApiGatewayToken);
        req.setHeader('Request-Datetime', Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));        
        req.setEndpoint(requestToken.parseEndpoint());
        req.setBody(requestBody);
        req.setTimeout(timeout * 1000);
        
        try {
            HttpResponse res = http.send(req);
            responseBody = res.getBody();
            response = responseBody;
            System.debug('responseBody : ' + responseBody);
            System.debug('response : ' + response);
    
            msLogId = uuidGenerateor.getValue();
            Integer statusCode = res.getStatusCode();   
            
            if(response != null){  
                if(response.contains('"consentDateTime": ""')){
                    response = response.replace('"consentDateTime": ""', '"consentDateTime": null');
                }                
                if(response.contains('"consentSignDate": ""')){
                    response = response.replace('"consentSignDate": ""', '"consentSignDate": null');
                }
            } 
    
            if(statusCode == 200){
                if(PDPAStructure.parseJsonToObj(response).status.code == '0000'){
                    isGetHistSuccess = true;
                    errorMessage = 'Success';
                }else{
                    isGetHistSuccess = false;
                    errorMessage = PDPAStructure.parseJsontoObj(response).status.description;
                }
            }else if(statusCode == 401) {
                // onlineLog(serviceName, false, tmbCustId, PDPAStructure.parseJsontoObj(response).status.description, uuidGenerateor.getValue(), requestBody, responseBody, startTime, startTime,request.parseEndpoint());
                isGetHistSuccess = false;
                response = '{"isSuccess":false,"errorMessage":"invalid_token"}';
                errorMessage = PDPAStructure.parseJsontoObj(response).status.description;
                // return result;
            }else{
                isGetHistSuccess = false;
                errorMessage = PDPAStructure.parseJsontoObj(response).status.description;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            errorMessage = e.getMessage();
        }

        DateTime endTime = DateTime.now();
        
        onlineLog(serviceName, isGetHistSuccess, tmbCustId, errorMessage, msLogId, requestBody, responseBody, startTime, endTime,'PDPA_and_Market_Consent_getHistory');
        
        return response;
    }

    private static void onlineLog(String serviceName, boolean isSuccess, String tmbCustId, String errorMessageRespone, String uidLogId, String requestBody, String responseBody, DateTime startTime, DateTime endTime,String endp){
        Account currAccount = [SELECT Id, Name, TMB_Customer_ID_PE__c, Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c =: tmbCustId];
        
        String customerId = currAccount.TMB_Customer_ID_PE__c == null ? currAccount.TMB_Customer_ID_PE__c : currAccount.TMB_Customer_ID_PE__c.length() == 30 ? currAccount.TMB_Customer_ID_PE__c.substring(16, 30) : currAccount.TMB_Customer_ID_PE__c;
        String customerName = currAccount.Name;
        String rmId = currAccount.TMB_Customer_ID_PE__c;
        
        // String base64Data = '';
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();

        // Cache.OrgPartition orgPartCreateToken = Cache.Org.getPartition('local.SmartBDMCalToolsCreateToken');
        String tokenlog = (String) orgPartCreateToken.get('onlineServiceLogGateWay');
        if(tokenlog == null) {
            tokenlog = '{}';
        }
        OnlineServiceLog onlineServiceLogGateWay = (OnlineServiceLog) System.JSON.deserialize(tokenlog, OnlineServiceLog.class);

        
        //Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(onlineServiceLogGateWay.responseBody);
        //String token = m.get('access_token')+'';

        // Platform cache name: SmartBDMCalToolsCreateToken
        // Sub-platform cache name: -
        // Token received: ABCD1-ABCD2-ABCD3-ABCD4
        // JTI: 67f3fb84-f689-4fa4-8d0b-986e82fadd45
        // Expiresin: 34696
        // Call Time: 2021-07-19 02:13:37(GMT)
        // Expiry Time: {Decode from token} 

        

        System.debug(onlineServiceLogGateWay);
        // String remark = 'Current request:::' 
        //                 + '\nPlatform cache name: ' + orgPartCreateToken.getName()
        //                 + '\nSub-platform cache name: ' + '-'
        //                 + '\nEndpoint: ' + endp
        //                 + '\nJTI: ' + (String) orgPartCreateToken.get('jti')
        //                 + '\n'
        //                 + 'Get-token request:::' 
        //                 + '\nPlatform cache name: ' + orgPartCreateToken.getName()
        //                 + '\nSub-platform cache name: ' + '-'
        //                 + '\nJTI: ' + (String) orgPartCreateToken.get('jti')
        //                 + '\nExpiresin: ' + String.valueOf(orgPartCreateToken.get('expiresin'))
        //                 + '\nCall Time: ' + onlineServiceLogGateWay.startTime + '(GMT)'
        //                 + '\nExpiry Time: ' + pdpaCalloutUtil.getExpiryDateTimeFromToken(token)+ '(GMT)';
        // OnlineServiceLogUtils.saveToOnlineLog(isSuccess ,customerName, errorMessageRespone, uidLogId , userName, rmId , serviceName ,requestBody ,responseBody , currAccount , startTime , endTime, base64Data );
        
        //MOVE TO SAVE OSLOG WITH ATTACHMENT
        RTL_CampaignUtil.saveToOnlineLog(isSuccess, customerName, errorMessageRespone, uidLogId,  userName, rmId, serviceName, requestBody, responseBody, currAccount,  startTime,  endTime, '');
    }

    public static String getExpiryDateTimeFromToken(String accessToken){
        try {
            String sDecode = EncodingUtil.base64Decode(accessToken.split('\\.').get(1)).toString();

            
            Map<String, Object> m = 
               (Map<String, Object>)
                  JSON.deserializeUntyped(sDecode);
            
            string unixDatetime = m.get('exp')+'000';
            return datetime.newinstance(long.valueOf(unixDateTime))+'';
            
        } catch (Exception e) {
            return '';
        }
    }
}