public without sharing class SmartBDM_EnliteService {
   
   public class SmartBDMEnliteWrapper {
       public String state {get; set;}
       public SmartBDMEnliteCompanyDetail companyDetail {get; set;}
       public SmartBDMEnliteCompany companyList {get; set;}
       public Datetime startTime {get; set;}
       
        public SmartBDMEnliteWrapper(String state, SmartBDMEnliteCompanyDetail companyDetail) {
            this.state = state;
            this.companyDetail = companyDetail;
            this.startTime = Datetime.now();
        }
        public SmartBDMEnliteWrapper(String state, SmartBDMEnliteCompany companyList) {
            this.state = state;
            this.companyList = companyList;
            this.startTime = Datetime.now();
        }
   }

   public class SmartBDMEnliteTokenWrapper {
       public String serviceName {get;set;}
       public OnlineServiceLog onlineServiceLog {get;set;}
       public SmartBDMEnliteToken enliteToken {get; set;}
       
        public SmartBDMEnliteTokenWrapper(String serviceName, SmartBDMEnliteToken enliteToken) {
            this.serviceName = serviceName;
            this.enliteToken = enliteToken;
        }
   }

    public static SmartBDMEnliteTokenWrapper startCallGetTokenService(SmartBDMEnliteToken.Request request) {
        SmartBDMEnliteToken tokenHttp = new SmartBDMEnliteToken();
        tokenHttp.request.GetTokenRequest = request;

        Http http = new Http();
        HttpRequest req = new HttpRequest();

        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Service-Name', 'enlite-getToken');
        req.setHeader('Request-UID', '{!$Credential.Username}');
        req.setHeader('Request-App-ID', '{!$Credential.Password}');
        req.setHeader('Request-Datetime', String.valueOfGmt(Datetime.now()));
        req.setEndpoint('callout:Smart_BDM_Enlite_Get_Token');
        req.setBody(tokenHttp.request.parseJson());
        req.setTimeout(Smart_BDM_Constant.TOKEN_ENLITE_TIMEOUT);
        
        Datetime startTime = DateTime.now();
        HttpResponse res;
        Datetime endTime;
        SmartBDMEnliteTokenWrapper enliteTokenWrapper = new SmartBDMEnliteTokenWrapper(Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_LIST, tokenHttp);
        try {
            res = http.send(req);
            // System.debug(res);
            // System.debug(res.getBody());
            // System.debug(res.getStatusCode());
            endTime = DateTime.now();
            if(res == null) {
                enliteTokenWrapper.onlineServiceLog = new OnlineServiceLog(false, 'Null response.', tokenHttp.request.parseJson(), '', startTime, endTime);
            } else {
                if(res.getStatusCode() != 200) {
                    tokenHttp.response = (SmartBDMEnliteToken.TokenResponse)JSON.deserialize(res.getBody(), SmartBDMEnliteToken.TokenResponse.class);
                    enliteTokenWrapper.enliteToken = tokenHttp;
                    enliteTokenWrapper.onlineServiceLog = new OnlineServiceLog(false, tokenHttp.response.status.description, tokenHttp.request.parseJson(), res.getBody(), startTime, endTime);
                }
                // Success with POST request
                else {
                    tokenHttp.response.convertToObject(res.getBody());
                    enliteTokenWrapper.enliteToken = tokenHttp;
                    enliteTokenWrapper.onlineServiceLog = new OnlineServiceLog(true, tokenHttp.response.status != null ? tokenHttp.response.status.description : '', tokenHttp.request.parseJson(), res.getBody(), startTime, endTime);
                }
            }
        } catch (Exception e) {
            System.debug('System error: ' + e.getMessage());
            System.debug('There is error during processing : ' + e.getStackTraceString());
            endTime = DateTime.now();
            String errorMessage = '';
            errorMessage += 'System error: ' + e.getMessage() + '\n';
            errorMessage += 'There is error during processing : ' + e.getStackTraceString();
            enliteTokenWrapper.onlineServiceLog = new OnlineServiceLog(false, errorMessage, tokenHttp.request.parseJson(), res != null ? res.getBody() : '', startTime, endTime);
        }
        return enliteTokenWrapper;
    }

    public static Object startCallGetCompanyListService(SmartBDMEnliteCompany companyList) {
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('callout:Smart_BDM_Enlite_Get_Company_List');
        req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Service-Name', 'enlite-getCompanies');
        req.setHeader('Request-UID', Smart_BDM_Constant.SMARTBDM_ENLITE_UID_COMPANYLIST);
        req.setHeader('Request-App-ID', Smart_BDM_Constant.SMARTBDM_ENLITE_APPID_COMPANYLIST);
        req.setHeader('Request-Datetime', String.valueOfGmt(Datetime.now()));
        req.setBody(companyList.companyRequest.parseJson());
        req.setTimeout(Smart_BDM_Constant.CUSTOMER_LIST_TIMEOUT);

        // Create a Continuation for the HTTPRequest        
        Continuation con = new Continuation(Smart_BDM_Constant.CUSTOMER_LIST_TIMEOUT/1000 != 0 ? Smart_BDM_Constant.CUSTOMER_LIST_TIMEOUT/1000 : 1);
        con.state = new SmartBDMEnliteWrapper(con.addHttpRequest(req), companyList);
        con.continuationMethod = 'callBackGetCompanyListServiceContinuation';
        // Return it to the system for processing
        return con;
    }

    public static Object callBackGetCompanyListServiceContinuation(Object state) {
        SmartBDMEnliteWrapper smartBDMEnliteWrapper  = (SmartBDMEnliteWrapper)state;
        HttpResponse res = Continuation.getResponse((String)smartBDMEnliteWrapper.state);
        Datetime endTime = DateTime.now();
        // System.debug(res);
        // System.debug(res.getBody());
        // System.debug(res.getStatusCode());
        
        SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper companyWrapper = new SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper();
        try {
            // Gateway failed case, DML after callout service
            OnlineServiceLog onlineServiceLogTokenGW = SmartBDM_Utility.onlineServiceLog('CreateGateWayToken', 'SmartBDMEnliteonlineServiceLogGateWay');
            if(onlineServiceLogTokenGW != null && !onlineServiceLogTokenGW.isSuccess)
                RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, onlineServiceLogTokenGW.errorMesssage, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, Smart_BDM_Constant.SMARTBDM_CALCULATE_TOOLS_CREATE_JWT_TOKEN, onlineServiceLogTokenGW.requestBody, onlineServiceLogTokenGW.responseBody, null /* Account Object*/, onlineServiceLogTokenGW.startTime, onlineServiceLogTokenGW.endTime);
            
            // Enlite Token failed case, DML after callout service
            OnlineServiceLog onlineServiceLogTokenEnlite = SmartBDM_Utility.onlineServiceLog('CreateGateWayToken', 'onlineServiceLogEnliteToken');
            if(onlineServiceLogTokenEnlite != null && !onlineServiceLogTokenEnlite.isSuccess) 
                RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, onlineServiceLogTokenEnlite.errorMesssage, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, Smart_BDM_Constant.SMARTBDM_ENLITE_TOKEN, onlineServiceLogTokenEnlite.requestBody, onlineServiceLogTokenEnlite.responseBody, null /* Account Object*/, onlineServiceLogTokenEnlite.startTime, onlineServiceLogTokenEnlite.endTime);

            if(res == null) {
                companyWrapper.isSuccess = false;
                companyWrapper.errorMessage = 'Null response.';
                RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, companyWrapper.errorMessage, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/,'SmartBDM_EnliteSearchingCompany' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_LIST, smartBDMEnliteWrapper.companyList.companyRequest.parseJson(), '', null /* Account Object*/, smartBDMEnliteWrapper.startTime, endTime);
            } else {
                // Success with POST request
                if( res.getStatusCode() == 200 ) {
                    smartBDMEnliteWrapper.companyList.companyResponse = smartBDMEnliteWrapper.companyList.convertToResponseObject(res.getBody());
                    companyWrapper.companyList = smartBDMEnliteWrapper.companyList.companyResponse;
                    companyWrapper.isSuccess = smartBDMEnliteWrapper.companyList.companyResponse.GetExcuteSearchResponse != null && companyWrapper.companyList.parseList().size() <= Smart_BDM_Constant.LIMIT_OFFSET_RECORD ? true: false;
                    companyWrapper.errorMessage = companyWrapper.companyList.parseList().size() > Smart_BDM_Constant.LIMIT_OFFSET_RECORD ? System.Label.Error_message_searching_input : System.Label.Error_message_not_found_information;
                    RTL_CampaignUtil.saveToOnlineLog(companyWrapper.isSuccess, ''/*Account Name*/, companyWrapper.isSuccess ? '': (smartBDMEnliteWrapper.companyList.companyResponse.status == null ? 'Maximum limit exceeded rows exceed returned' : smartBDMEnliteWrapper.companyList.companyResponse.status.description), ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, 'SmartBDM_EnliteSearchingCompany' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_LIST, smartBDMEnliteWrapper.companyList.companyRequest.parseJson(), res.getBody(), null /* Account Object*/, smartBDMEnliteWrapper.startTime, endTime);
                }
                else if(res.getStatusCode() >= 2000 && res.getStatusCode() <= 2004) { // time out
                    companyWrapper.isSuccess = false;
                    companyWrapper.errorMessage = System.Label.Timeout_message;
                    RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, 'SmartBDM_EnliteSearchingCompany' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_LIST, smartBDMEnliteWrapper.companyList.companyRequest.parseJson(), res.getBody(), null /* Account Object*/, smartBDMEnliteWrapper.startTime, endTime);
                }
                else {
                    SmartBDMEnliteCompany.CompanyResponse response = (SmartBDMEnliteCompany.CompanyResponse)JSON.deserialize(res.getBody(), SmartBDMEnliteCompany.CompanyResponse.class);
                    companyWrapper.isSuccess = false;
                    companyWrapper.errorMessage = response.status.code == 10006 || response.status.code == 10007 ? System.Label.Timeout_message : System.Label.Other_Error;
                    if(response.status.code == 10006 || response.status.code == 10007) SmartBDM_Utility.orgPartClearValue('CreateGateWayToken', 'SmartBDMEnliteToken');
                    RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, response.status.description, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, 'SmartBDM_EnliteSearchingCompany' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_LIST, smartBDMEnliteWrapper.companyList.companyRequest.parseJson(), res.getBody(), null /* Account Object*/, smartBDMEnliteWrapper.startTime, endTime);
                }
            }
        } catch (Exception e) {
            System.debug('System error: ' + e.getMessage());
            System.debug('There is error during processing : ' + e.getStackTraceString());
            String errorMessage = '';
            errorMessage += 'System error: ' + e.getMessage() + '\n';
            errorMessage += 'There is error during processing : ' + e.getStackTraceString();
            
            companyWrapper.isSuccess = false;
            companyWrapper.errorMessage = System.Label.Other_Error;
            RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, errorMessage, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, 'SmartBDM_EnliteSearchingCompany' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_LIST, smartBDMEnliteWrapper.companyList.companyRequest.parseJson(), res.getBody(), null /* Account Object*/, smartBDMEnliteWrapper.startTime, endTime);
        }
        return companyWrapper;
    }

    public static Object startCallGetCompanyDetailService(SmartBDMEnliteCompanyDetail companyDetail) {
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('callout:Smart_BDM_Enlite_Get_Company_Detail');
        req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Service-Name', 'enlite-getCompanyDetail');
        req.setHeader('Request-UID', Smart_BDM_Constant.SMARTBDM_ENLITE_UID_COMPANYDETAIL);
        req.setHeader('Request-App-ID', Smart_BDM_Constant.SMARTBDM_ENLITE_APPID_COMPANYDETAIL);
        req.setHeader('Request-Datetime', String.valueOfGmt(Datetime.now()));
        req.setBody(companyDetail.enliteDataRequest.parseJson());
        req.setTimeout(Smart_BDM_Constant.CUSTOMER_DETAIL_TIMEOUT);

        // Create a Continuation for the HTTPRequest        
        Continuation con = new Continuation(Smart_BDM_Constant.CUSTOMER_DETAIL_TIMEOUT/1000 != 0 ? Smart_BDM_Constant.CUSTOMER_DETAIL_TIMEOUT/1000 : 1);
        con.state = new SmartBDMEnliteWrapper(con.addHttpRequest(req), companyDetail);
        con.continuationMethod = 'callBackGetCompanyDetailServiceContinuation';
        
        // Return it to the system for processing
        return con;
    }

    public static Object callBackGetCompanyDetailServiceContinuation(Object state) {
        SmartBDM_EnliteService.SmartBDMEnliteWrapper smartBDMEnliteWrapper  = (SmartBDM_EnliteService.SmartBDMEnliteWrapper)state;
        HttpResponse res = Continuation.getResponse((String)smartBDMEnliteWrapper.state);
        Datetime endTime = DateTime.now();
        // System.debug(res);
        // System.debug(res.getBody());
        // System.debug(res.getStatusCode());
        
        SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper companyWrapper = new SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper();
        try {
            // Gateway failed case, DML after callout service
            OnlineServiceLog onlineServiceLogTokenGW = SmartBDM_Utility.onlineServiceLog('CreateGateWayToken', 'SmartBDMEnliteonlineServiceLogGateWay');
            if(onlineServiceLogTokenGW != null && !onlineServiceLogTokenGW.isSuccess)
                RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, onlineServiceLogTokenGW.errorMesssage, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, Smart_BDM_Constant.SMARTBDM_CALCULATE_TOOLS_CREATE_JWT_TOKEN, onlineServiceLogTokenGW.requestBody, onlineServiceLogTokenGW.responseBody, null /* Account Object*/, onlineServiceLogTokenGW.startTime, onlineServiceLogTokenGW.endTime);
            
            // Enlite Token failed case, DML after callout service
            OnlineServiceLog onlineServiceLogTokenEnlite = SmartBDM_Utility.onlineServiceLog('CreateGateWayToken', 'onlineServiceLogEnliteToken');
            if(onlineServiceLogTokenEnlite != null && !onlineServiceLogTokenEnlite.isSuccess)
                RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, onlineServiceLogTokenEnlite.errorMesssage, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, Smart_BDM_Constant.SMARTBDM_ENLITE_TOKEN, onlineServiceLogTokenEnlite.requestBody, onlineServiceLogTokenEnlite.responseBody, null /* Account Object*/, onlineServiceLogTokenEnlite.startTime, onlineServiceLogTokenEnlite.endTime);

            if(res == null) {
                companyWrapper.isSuccess = false;
                companyWrapper.errorMessage = 'Null response.';
                RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, companyWrapper.errorMessage, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/,'SmartBDM_EnliteSearchingCompany' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_DETAIL, smartBDMEnliteWrapper.companyDetail.enliteDataRequest.parseJson(), '', null /* Account Object*/, smartBDMEnliteWrapper.startTime, endTime);
            } else {
                // Success with POST request
                if( res.getStatusCode() == 200 ) {
                    smartBDMEnliteWrapper.companyDetail.convertToResponseObject(res.getBody());
                    companyWrapper.companyDetail = smartBDMEnliteWrapper.companyDetail.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile;
                    companyWrapper.isSuccess = smartBDMEnliteWrapper.companyDetail.enliteDataResponse.GetExcuteSearchResponse.CompanyProfile != null ? true : false;
                    companyWrapper.errorMessage = System.Label.Other_Error;
                    RTL_CampaignUtil.saveToOnlineLog(companyWrapper.isSuccess, ''/*Account Name*/, companyWrapper.isSuccess ? null: smartBDMEnliteWrapper.companyDetail.enliteDataResponse.status.description, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, 'SmartBDM_EnliteSearchingCompany' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_DETAIL, smartBDMEnliteWrapper.companyDetail.enliteDataRequest.parseJson(), res.getBody(), null /* Account Object*/, smartBDMEnliteWrapper.startTime, endTime);
                  
                }
                else if(res.getStatusCode() >= 2000 && res.getStatusCode() <= 2004) { // time out
                    companyWrapper.isSuccess = false;
                    companyWrapper.errorMessage = System.Label.Timeout_message;
                    RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, 'SmartBDM_EnliteSearchingCompany' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_DETAIL, smartBDMEnliteWrapper.companyDetail.enliteDataRequest.parseJson(), res.getBody(), null /* Account Object*/, smartBDMEnliteWrapper.startTime, endTime);
                }
                else {
                    SmartBDMEnliteCompanyDetail.EnliteDataResponse response = (SmartBDMEnliteCompanyDetail.EnliteDataResponse)JSON.deserialize(res.getBody(), SmartBDMEnliteCompanyDetail.EnliteDataResponse.class);
                    companyWrapper.isSuccess = false;
                    companyWrapper.errorMessage = response.status.code == 10006 || response.status.code == 10007 ? System.Label.Timeout_message : System.Label.Other_Error;
                    if(response.status.code == 10006 || response.status.code == 10007) SmartBDM_Utility.orgPartClearValue('CreateGateWayToken', 'SmartBDMEnliteToken');
                    RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, response.status.description, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, 'SmartBDM_EnliteSearchingCompany' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_DETAIL, smartBDMEnliteWrapper.companyDetail.enliteDataRequest.parseJson(), res.getBody(), null /* Account Object*/, smartBDMEnliteWrapper.startTime, endTime);
                }
            }
        } catch (Exception e) {
            System.debug('System error: ' + e.getMessage());
            System.debug('There is error during processing : ' + e.getStackTraceString());
            String errorMessage = '';
            errorMessage += 'System error: ' + e.getMessage() + '\n';
            errorMessage += 'There is error during processing : ' + e.getStackTraceString();
            
            companyWrapper.isSuccess = false;
            companyWrapper.errorMessage = System.Label.Other_Error;
            RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, errorMessage, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, 'SmartBDM_EnliteSearchingCompany' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_DETAIL, smartBDMEnliteWrapper.companyDetail.enliteDataRequest.parseJson(), res.getBody(), null /* Account Object*/, smartBDMEnliteWrapper.startTime, endTime);
        }
        return companyWrapper;
    }
    
}