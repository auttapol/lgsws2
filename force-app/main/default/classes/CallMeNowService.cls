public class CallMeNowService {

    public static Integer TIMEOUT_INT_MILLISECS{
    get{
        Integer DEFAULT_TIMEOUT = 60000;
        if(TIMEOUT_INT_MILLISECS == null){
            try{
                TIMEOUT_INT_MILLISECS = DEFAULT_TIMEOUT;
                List<App_Config__mdt> callMeNowTimeOut = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'CallMeNow_TIMEOUT_INT_MILLISECS'];           
                    if (callMeNowTimeOut != null && callMeNowTimeOut.size() > 0) {
                        TIMEOUT_INT_MILLISECS = Integer.valueOf(callMeNowTimeOut.get(0).Value__c);
                    }           
                    
                }catch( Exception e ){
                    TIMEOUT_INT_MILLISECS = DEFAULT_TIMEOUT;
                }
        }
        return TIMEOUT_INT_MILLISECS;
        
    }set;}


    public static void basicAuthCallout(CallMeNowDTO callMeNowObj,String referralName){
        HttpRequest req;
        AppConfig__c mc;
        String endpoint;
        CallMeNowDTO.Response responseObj;

        String requestBody;
        String responseBody;
        try{

            req = new HttpRequest();
            mc = AppConfig__c.getValues('WsCallMeNow');
            endpoint = mc == null ? 'https://sfmashupservices.tmbbank.com/common/CallMeNow/VIT/call-me-now/lead' : mc.Value__c;
            

            requestBody = callMeNowObj.generateJSONContent();

            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-Type','application/json;charset=utf-8');       
            req.setBody(requestBody);
            req.setTimeout(TIMEOUT_INT_MILLISECS);
        
            System.debug(req);
            System.debug('body : '+requestBody);
            System.debug('Timeout : '+TIMEOUT_INT_MILLISECS);
            // Create a new http object to send the request object
            // A response object is generated as a result of the request  
        
            Http http = new Http();
            HTTPResponse res = http.send(req);
            responseBody = res.getBody();
            
            
            System.debug(responseBody);
            //Deserialize json response and check if error
            callMeNowObj.response.rawResponse = responseBody;
            responseObj = processResponse(responseBody);

            callMeNowObj.response.code = responseObj.code;
            callMeNowObj.response.message = responseObj.message;
            

        }
        catch(Exception e){
            callMeNowObj.response.message = 'Error : '+e.getMessage()+' Line : '+e.getLineNumber();
        }   
        
    }

    public static OnlineServiceLog callOutCMNLead(CallMeNowDTO callMeNowObj, String ServiceChannel){
        HttpRequest req;
        String endpoint = 'callout:WsCallMeNow_' + ServiceChannel;
        CallMeNowDTO.Response responseObj;

        String requestBody;
        String responseBody;

        Boolean isSuccess = false;

        Datetime startTime = DateTime.now();

        System.debug('endpoint : ' + endpoint);
        try{
            req = new HttpRequest();

            requestBody = callMeNowObj.generateJSONContent();

            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-Type','application/json;charset=utf-8');       
            req.setBody(requestBody);
            req.setTimeout(TIMEOUT_INT_MILLISECS);
        
            System.debug(req);
            System.debug('body : ' + requestBody);
            System.debug('Timeout : ' + TIMEOUT_INT_MILLISECS);
        
            Http http = new Http();
            HTTPResponse res = http.send(req);
            responseBody = res.getBody();
            
            System.debug(responseBody);
            callMeNowObj.response.rawResponse = responseBody;
            responseObj = processResponse(responseBody);

            callMeNowObj.response.code = responseObj.code;
            callMeNowObj.response.message = responseObj.message;
            isSuccess = callMeNowObj.response.message == 'success';
        }catch(Exception e){
            callMeNowObj.response.message = 'Error : ' + e.getMessage() + ' Line : ' + e.getLineNumber();
        }
        Datetime endTime = DateTime.now();

        OnlineServiceLog oslogDetail = new OnlineServiceLog(isSuccess, callMeNowObj.response.message, requestBody, responseBody, startTime, endTime);

        return oslogDetail;
    }

    private static CallMeNowDTO.Response processResponse(String response){
        return (CallMeNowDTO.Response)JSON.deserialize(response,CallMeNowDTO.Response.class);
    }

}