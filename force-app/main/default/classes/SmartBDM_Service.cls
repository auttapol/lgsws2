public without sharing class SmartBDM_Service {
    // public virtual class BaseException extends Exception {}
    // public class OtherException extends BaseException {}

    public SmartBDM_Service() {

    }

    public class RequestToken {
        public String endpoint;
        public String parseEndpoint() {
            return 'callout:' + this.endpoint;   
        }
        public String parseBody() {
            return 'grant_type=client_credentials&client_id={!$Credential.UserName}&client_secret={!$Credential.Password}';   
        }
	}

    public static AuthenticationToken startCallGetTokenService(String namedCredentials) {
        // Set request body
        SmartBDM_Service.RequestToken request = new SmartBDM_Service.RequestToken();
        request.endpoint = namedCredentials;
         // Create callout request
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setEndpoint(request.parseEndpoint());
        req.setBody(request.parseBody());
        req.setTimeout(Smart_BDM_Constant.AUTHORIZATION_TIMEOUT);
        AuthenticationToken authen = new AuthenticationToken();
        Datetime startTime = DateTime.now();
        HttpResponse res;
        try {
            res = http.send(req);
            Datetime endTime = DateTime.now();
            if(res == null) {
                authen.isSuccess = false;
                authen.errorMessage = 'Null response.';
                authen.requestBody = request.parseBody();
                authen.responseBody = res.getBody();
            } else {
                if(res.getStatusCode() != 200) {
                    authen.isSuccess = false;
                    authen.errorMessage = AuthenticationToken.parse(res.getBody()).status.message;
                    authen.requestBody = request.parseBody();
                    authen.responseBody = res.getBody();
                }
                // Success with POST request
                else {
                    authen = AuthenticationToken.parse(res.getBody());
                    authen.isSuccess = true;
                    authen.errorMessage = '';
                    authen.requestBody = request.parseBody();
                    authen.responseBody = res.getBody();
                }
            }
        } catch (Exception e) {
            System.debug('System error: ' + e.getMessage());
            System.debug('There is error during processing : ' + e.getStackTraceString());
            String errorMessage = '';
            errorMessage += 'System error: ' + e.getMessage() + '\n';
            errorMessage += 'There is error during processing : ' + e.getStackTraceString();
            Datetime endTime = DateTime.now();
            
            authen.isSuccess = false;
            authen.errorMessage = errorMessage;
            authen.requestBody = request.parseBody() + '\n' + 'Endpoint Callout: ' + request.parseEndpoint() + '\n';
            authen.responseBody = res != null ? res.getBody() : '';
        }
        return authen;
    }
    
    public static SmartBDM_BusinessTypeController.BusinessTypeGroupWrapper startCallGetBusinessTypeService(String token, Integer initial, Integer to) {
        SmartBDMBusinessType.Request bt_request = new SmartBDMBusinessType.Request();
        bt_request.endpoint = Smart_BDM_Constant.SmartBDM_CalculateTools_Settings.get('ENDPOINT_BUSINESS_TYPE');
        bt_request.fields = 'all';
        bt_request.initial = initial != null ? initial : 1;
        bt_request.to = to != null ? to : 100;

        // Create callout request
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json; charset=utf-8');
        req.setHeader('Authorization', 'bearer ' + token);
        req.setEndpoint(bt_request.parseEndpoint());
        req.setTimeout(Smart_BDM_Constant.BUSINESS_TYPE_TIMEOUT);
        HttpResponse res;
        SmartBDM_BusinessTypeController.BusinessTypeGroupWrapper businessTypeGroupWrapper = new SmartBDM_BusinessTypeController.BusinessTypeGroupWrapper();
        try {
            res = http.send(req);
            // System.debug(res);
            // System.debug(res.getBody());
            // System.debug(res.getStatusCode());

            if(res == null) {
                businessTypeGroupWrapper.onlineServiceLog.add(new OnlineServiceLog(false, 'Null response.', bt_request.parseToJSON(), res.getBody()));
            } else {
                if( res.getStatusCode() != 200 ) {
                    SmartBDMBusinessType.Response response = (SmartBDMBusinessType.Response)JSON.deserialize(res.getBody(), SmartBDMBusinessType.Response.class);
                    businessTypeGroupWrapper.onlineServiceLog.add(new OnlineServiceLog(false, response.status.message, bt_request.parseToJSON(), res.getBody()));
                }
                // Success with GET request
                else {
                    Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    businessTypeGroupWrapper.businessType = (List<SmartBDMBusinessType.Response>)JSON.deserialize(JSON.serialize(responseBody.get('data')), List<SmartBDMBusinessType.Response>.class);
                    businessTypeGroupWrapper.onlineServiceLog.add(new OnlineServiceLog(true, bt_request.parseToJSON(), res.getBody()));

                    // List<SmartBDMBusinessType.Response> businessType = (List<SmartBDMBusinessType.Response>)JSON.deserialize(JSON.serialize(responseBody.get('data')), List<SmartBDMBusinessType.Response>.class);
                    if(bt_request.to < (Integer)responseBody.get('total')) {
                        bt_request.initial = initial;
                        bt_request.to = (Integer)responseBody.get('total');
                        SmartBDM_BusinessTypeController.BusinessTypeGroupWrapper businessTypeSecond = startCallGetBusinessTypeService(token, initial+to, (Integer)responseBody.get('total'));
                        
                        businessTypeGroupWrapper.onlineServiceLog.add(new OnlineServiceLog(true, businessTypeSecond.onlineServiceLog.get(0).requestBody, businessTypeSecond.onlineServiceLog.get(0).responseBody));
                        businessTypeGroupWrapper.businessType.addAll(businessTypeSecond.businessType);
                    }
                    return businessTypeGroupWrapper;
                }
            }
        } catch (Exception e) {
            System.debug('System error: ' + e.getMessage());
            System.debug('There is error during processing : ' + e.getStackTraceString());
            String errorMessage = '';
            errorMessage += 'System error: ' + e.getMessage() + '\n';
            errorMessage += 'There is error during processing : ' + e.getStackTraceString();
            businessTypeGroupWrapper.onlineServiceLog.add(new OnlineServiceLog(false, errorMessage, bt_request.parseToJSON(), res != null ? res.getBody() : ''));
        }
        return businessTypeGroupWrapper;
    }

    public static SmartBDM_BusinessTypeController.BusinessTypeGroupWrapper startCallGetBusinessGroupService(String token, Integer initial, Integer to) {
        SmartBDMBusinessType.Request bt_request = new SmartBDMBusinessType.Request();
        bt_request.endpoint = Smart_BDM_Constant.SmartBDM_CalculateTools_Settings.get('ENDPOINT_BUSINESS_GROUP');
        bt_request.fields = 'all';
        bt_request.initial = initial != null ? initial : 1;
        bt_request.to = to != null ? to : 100;

        // Create callout request
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json; charset=utf-8');
        req.setHeader('Authorization', 'bearer ' + token);
        req.setEndpoint(bt_request.parseEndpoint());
        req.setTimeout(Smart_BDM_Constant.BUSINESS_GROUP_TIMEOUT);

        HttpResponse res;
        SmartBDM_BusinessTypeController.BusinessTypeGroupWrapper businessTypeGroupWrapper = new SmartBDM_BusinessTypeController.BusinessTypeGroupWrapper();
        try {
            res = http.send(req);
            // System.debug(res);
            // System.debug(res.getBody());
            // System.debug(res.getStatusCode());

            if(res == null) {
                businessTypeGroupWrapper.onlineServiceLog.add(new OnlineServiceLog(false, 'Null response.', bt_request.parseToJSON(), res.getBody()));
            } else {
                if( res.getStatusCode() != 200 ) {
                    SmartBDMBusinessType.Response response = (SmartBDMBusinessType.Response)JSON.deserialize(res.getBody(), SmartBDMBusinessType.Response.class);
                    businessTypeGroupWrapper.onlineServiceLog.add(new OnlineServiceLog(false, response.status.message, bt_request.parseToJSON(), res.getBody()));
                }
                // Success with GET request
                else {
                    Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    businessTypeGroupWrapper.businessGroup = (List<SmartBDMBusinessType.Response>)JSON.deserialize(JSON.serialize(responseBody.get('data')), List<SmartBDMBusinessType.Response>.class);
                    businessTypeGroupWrapper.onlineServiceLog.add(new OnlineServiceLog(true, bt_request.parseToJSON(), res.getBody()));
                    // List<SmartBDMBusinessType.Response> businessGroup = (List<SmartBDMBusinessType.Response>)JSON.deserialize(JSON.serialize(responseBody.get('data')), List<SmartBDMBusinessType.Response>.class);
                    
                    if(bt_request.to < (Integer)responseBody.get('total')) {
                        bt_request.initial = initial;
                        bt_request.to = (Integer)responseBody.get('total');
                        SmartBDM_BusinessTypeController.BusinessTypeGroupWrapper businessGroupSecond = startCallGetBusinessGroupService(token, initial+to, (Integer)responseBody.get('total'));
                        
                        businessTypeGroupWrapper.onlineServiceLog.add(new OnlineServiceLog(true, businessGroupSecond.onlineServiceLog.get(0).requestBody, businessGroupSecond.onlineServiceLog.get(0).responseBody));
                        businessTypeGroupWrapper.businessGroup.addAll(businessGroupSecond.businessGroup);
                        // businessGroup.addAll(startCallGetBusinessGroupService(token, initial+to, (Integer)responseBody.get('total')));
                    }
                    return businessTypeGroupWrapper;
                }
            }
        } catch (Exception e) {
            System.debug('System error: ' + e.getMessage());
            System.debug('There is error during processing : ' + e.getStackTraceString());
            String errorMessage = '';
            errorMessage += 'System error: ' + e.getMessage() + '\n';
            errorMessage += 'There is error during processing : ' + e.getStackTraceString();
            businessTypeGroupWrapper.onlineServiceLog.add(new OnlineServiceLog(false, errorMessage, bt_request.parseToJSON(), res != null ? res.getBody() : ''));
        }
        return businessTypeGroupWrapper;
    }

    public static Object startCallGetCalculateWorkingCapitalContinuation(SmartBDMWorkingCapital.Request request) {
        Datetime startTime = Datetime.now();
        // Create callout request
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json; charset=utf-8');
        req.setHeader('Authorization', 'bearer ' + SmartBDM_Utility.tokenKeyCalculateTools);
        req.setEndpoint('callout:' + Smart_BDM_Constant.SmartBDM_CalculateTools_Settings.get('ENDPOINT_WORKING_CAPITAL'));
        req.setBody(request.parseToJSON());
        req.setTimeout(Smart_BDM_Constant.WORKING_CAPITAL_TIMEOUT);
        
        OnlineServiceLog onlineServiceLogTokenCalculateTools = SmartBDM_Utility.onlineServiceLog('CreateGateWayToken', 'onlineServiceLogGateWay');
        if(onlineServiceLogTokenCalculateTools.isSuccess) {
            // Create a Continuation for the HTTPRequest        
            Continuation con = new Continuation(Smart_BDM_Constant.WORKING_CAPITAL_TIMEOUT/1000);
            con.state = new SmartBDM_CalculateWCController.WorkingCapitalState(con.addHttpRequest(req), request, Datetime.now());
            con.continuationMethod = 'callBackGetCalculateWorkingCapitalContinuation';
            // Return it to the system for processing
            return con;
        }
        else {
            
            // String remark = 'Current request:::' 
            //             + '\nPlatform cache name: ' + 'local.SmartBDMCalToolsCreateToken'
            //             + '\nSub-platform cache name: ' + '-'
            //             + '\nEndpoint: ' + 'callout:' + Smart_BDM_Constant.SmartBDM_CalculateTools_Settings.get('ENDPOINT_WORKING_CAPITAL')
            //             + '\nJTI: ' + SmartBDM_Utility.getJTI('SmartBDMCalToolsCreateToken')
            //             + '\n'
            //             + 'Get-token request:::' 
            //             + '\nPlatform cache name: ' + 'local.SmartBDMCalToolsCreateToken'
            //             + '\nSub-platform cache name: ' + '-'
            //             + '\nJTI: ' + SmartBDM_Utility.getJTI('SmartBDMCalToolsCreateToken')
            //             + '\nExpiresin: ' + SmartBDM_Utility.getOnlineServiceLog('SmartBDMCalToolsCreateToken').responseBody
            //             + '\nCall Time: ' + SmartBDM_Utility.getOnlineServiceLog('SmartBDMCalToolsCreateToken').startTime + '(GMT)'
            //             + '\nExpiry Time: ' + pdpaCalloutUtil.getExpiryDateTimeFromToken(SmartBDM_Utility.tokenKeyCalculateTools)+ '(GMT)';

            RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, onlineServiceLogTokenCalculateTools.errorMesssage, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, Smart_BDM_Constant.SMARTBDM_CALCULATE_TOOLS_CREATE_JWT_TOKEN, onlineServiceLogTokenCalculateTools.requestBody, onlineServiceLogTokenCalculateTools.responseBody, null /* Account Object*/, onlineServiceLogTokenCalculateTools.startTime, onlineServiceLogTokenCalculateTools.endTime,'');

            SmartBDM_CalculateWCController.WorkingCapitalWrapper wcw = new SmartBDM_CalculateWCController.WorkingCapitalWrapper();
            wcw.isSuccess = false;
            wcw.errorMessage = System.Label.Other_Error;
            wcw.wcLimit = 0;
            return wcw;
        }
    }

    public static SmartBDM_CalculateWCController.WorkingCapitalWrapper callBackGetCalculateWorkingCapitalContinuation(Object state, SmartBDMWorkingCapital.Request request, Datetime startTime) {
        SmartBDM_CalculateWCController.WorkingCapitalWrapper workingCapital = new SmartBDM_CalculateWCController.WorkingCapitalWrapper();
        HttpResponse res = Continuation.getResponse((String)state);
        // System.debug(res);
        // System.debug(res.getBody());
        // System.debug(res.getStatusCode());
        Datetime endTime = DateTime.now();
        try {
            if(res == null) {
                RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, 'Null response.', ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, Smart_BDM_Constant.SMARTBDM_CALCULATE_TOOLS_WORK_CAPITAL, request.parseToJSON(), '', null /* Account Object*/, startTime, endTime);
                workingCapital.isSuccess = false;
                workingCapital.errorMessage = 'Null response.';
            } else {
                // Success with POST request
                if( res.getStatusCode() == 200 ) {
                    SmartBDMWorkingCapital.Response response = (SmartBDMWorkingCapital.Response)JSON.deserialize(res.getBody(), SmartBDMWorkingCapital.Response.class);
                    workingCapital.isSuccess = response.wcLimit != null ? true: false;
                    workingCapital.errorMessage = System.Label.Other_Error;
                    workingCapital.wcLimit = response.wcLimit;
                    RTL_CampaignUtil.saveToOnlineLog(workingCapital.isSuccess, ''/*Account Name*/, workingCapital.isSuccess ? null: response.status.message, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, Smart_BDM_Constant.SMARTBDM_CALCULATE_TOOLS_WORK_CAPITAL, request.parseToJSON(), res.getBody(), null /* Account Object*/, startTime, endTime);
                }
                else if(res.getStatusCode() >= 2000 && res.getStatusCode() <= 2004) { // time out
                    workingCapital.isSuccess = false;
                    workingCapital.errorMessage = System.Label.Timeout_message;
                    RTL_CampaignUtil.saveToOnlineLog(workingCapital.isSuccess, ''/*Account Name*/, Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, Smart_BDM_Constant.SMARTBDM_CALCULATE_TOOLS_WORK_CAPITAL, request.parseToJSON(), res.getBody(), null /* Account Object*/, startTime, endTime);
                }
                else {
                    SmartBDMWorkingCapital.Response response = (SmartBDMWorkingCapital.Response)JSON.deserialize(res.getBody(), SmartBDMWorkingCapital.Response.class);
                    workingCapital.isSuccess = false;
                    workingCapital.errorMessage = System.Label.Other_Error;
                    RTL_CampaignUtil.saveToOnlineLog(workingCapital.isSuccess, ''/*Account Name*/, response.status.message, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, Smart_BDM_Constant.SMARTBDM_CALCULATE_TOOLS_WORK_CAPITAL, request.parseToJSON(), res.getBody(), null /* Account Object*/, startTime, endTime);
                }
            }
        } catch (Exception e) {
            System.debug('System error: ' + e.getMessage());
            System.debug('There is error during processing : ' + e.getStackTraceString());
            String errorMessage = '';
            errorMessage += 'System error: ' + e.getMessage() + '\n';
            errorMessage += 'There is error during processing : ' + e.getStackTraceString();

            RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, errorMessage, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, Smart_BDM_Constant.SMARTBDM_CALCULATE_TOOLS_WORK_CAPITAL, request.parseToJSON(), res.getBody(), null /* Account Object*/, startTime, endTime);
            workingCapital.isSuccess = false;
            workingCapital.errorMessage = System.Label.Other_Error;
        }
        return workingCapital;
    }
}