public without sharing class APIGateway_Service implements Database.AllowsCallouts{
    private static String APPID = AppConfig__c.getValues('APPID') == null
                                                ? 'A0291' : AppConfig__c.getValues('APPID').Value__c;

    private static String TOKEN_CACHENAME = AppConfig__c.getValues('TOKEN_CACHENAME') == null
                                                ? 'SmartBDMCalToolsCreateToken' : AppConfig__c.getValues('TOKEN_CACHENAME').Value__c;

    public class RequestToken {
        public String endpoint;
        public String parseEndpoint() {
            return 'callout:' + this.endpoint;   
        }
        public String parseBody() {
            return 'grant_type=client_credentials&client_id={!$Credential.UserName}&client_secret={!$Credential.Password}';   
        }
    }



    private static Cache.OrgPartition orgPartCreateToken(string partitionName, string namedCredentials, string projectKey) {
        Cache.OrgPartition orgPartCreateToken = Cache.Org.getPartition('local.' + partitionName);
        if(orgPartCreateToken.get(projectKey + 'accesstoken') == null || orgPartCreateToken.get(projectKey + 'accesstoken') == '') {
            Datetime startTime = Datetime.now();
            AuthenticationToken authenTokenCalculateTools = startCallGetTokenService(namedCredentials);
            Datetime endTime = Datetime.now();
            orgPartCreateToken.put(projectKey + 'accesstoken', authenTokenCalculateTools.access_token, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            orgPartCreateToken.put(projectKey + 'tokentype', authenTokenCalculateTools.token_type, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            orgPartCreateToken.put(projectKey + 'expiresin', authenTokenCalculateTools.expires_in, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            orgPartCreateToken.put(projectKey + 'scope', authenTokenCalculateTools.scope, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            orgPartCreateToken.put(projectKey + 'jti', authenTokenCalculateTools.jti, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            orgPartCreateToken.put(projectKey + 'clientid', authenTokenCalculateTools.client_id, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            orgPartCreateToken.put(projectKey + 'version', authenTokenCalculateTools.version, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            
            OnlineServiceLog onlineServiceLogGateWay = new OnlineServiceLog(authenTokenCalculateTools.isSuccess
                                                                                , authenTokenCalculateTools.errorMesssage, authenTokenCalculateTools.requestBody
                                                                                , authenTokenCalculateTools.responseBody, startTime, endTime
                                                                                );
            orgPartCreateToken.put(projectKey + 'onlineServiceLogGateWay', onlineServiceLogGateWay.parseToJson(), Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        }
        return orgPartCreateToken;
    }


    public static String getAccessToken(String endpointToken,String projectKey) {
        // return (String)orgPartCreateToken(TOKEN_CACHENAME
        //                     ,endpointToken
        //                     ,projectKey).get(projectKey + 'accesstoken');
        return  SmartBDM_Utility.tokenKeyEnliteGateWay;
    }

    public static AuthenticationToken 
                    startCallGetTokenService(String credentialEndpoint) {
        // Set request body
        APIGateway_Service.RequestToken request 
                    = new APIGateway_Service.RequestToken();
        request.endpoint = credentialEndpoint;
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
                authen.errorMesssage = 'Null response.';
                authen.requestBody = request.parseBody();
                authen.responseBody = res.getBody();
            } else {
                if(res.getStatusCode() != 200) {
                    authen.isSuccess = false;
                    authen.errorMesssage = AuthenticationToken.parse(res.getBody()).status.message;
                    authen.requestBody = request.parseBody();
                    authen.responseBody = res.getBody();
                }
                // Success with POST request
                else {
                    authen = AuthenticationToken.parse(res.getBody());
                    authen.isSuccess = true;
                    authen.errorMesssage = '';
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
            authen.errorMesssage = errorMessage;
            authen.requestBody = request.parseBody() + '\n' + 'Endpoint Callout: ' + request.parseEndpoint() + '\n';

            authen.responseBody =  (res != null ? res.getBody() : '');
            
        }
        return authen;
    }

    public static String 
                    postData(String access_token
                            ,String serviceName
                            ,String reqBody
                            ,Integer TIMEOUT_INT_MILLISECS
                            ,HttpRequest req) {

       Http http = new Http();
       Uuid uuidGenerateor = new Uuid();

       req.setMethod('POST');
       req.setHeader('Content-Type', 'application/json; charset=utf-8');

       //req.setHeader('Request-UID', '7d8277e0-b5cc-41b2-8dc8-9e06d763a713');
       req.setHeader('Request-UID', uuidGenerateor.getValue());
       req.setHeader('Request-App-ID', APPID);
       req.setHeader('Request-Datetime', Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));


       req.setHeader('Authorization', 'bearer ' + access_token);
       req.setEndpoint('callout:' + serviceName);
       req.setBody(reqBody);
       req.setTimeout(TIMEOUT_INT_MILLISECS);
       HttpResponse res = http.send(req);
       return res.getBody();
    }
}