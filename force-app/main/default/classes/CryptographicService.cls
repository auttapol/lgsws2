/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Apex REST class designed to [Insert Summary Description Here].
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Puntawus Laonan   <ptl@ii.co.th>
* @version        1.0
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            atp@ii.co.th
* 2021-10-01      Initial version with comment to control version first time.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@RestResource(urlMapping='/data/V1.0/cryptographic/*')
global class CryptographicService extends WebserviceAbstract {
    /* get service timeout */
	public static Integer SERVICE_TIMEOUT_MILISEC{
        get{
            Integer DEFAULT_TIMEOUT = 60000;
            if(SERVICE_TIMEOUT_MILISEC == null){
                try{
                    SERVICE_TIMEOUT_MILISEC = DEFAULT_TIMEOUT;
                    List<App_Config__mdt> cryptographic_Timeout = [SELECT Id, Label, Value__c FROM App_Config__mdt WHERE Label = 'CRYPTOGRAPHIC_TIMEOUT_MILLISEC' LIMIT 1];  
                    if (cryptographic_Timeout != null && cryptographic_Timeout.size() > 0) {
                        SERVICE_TIMEOUT_MILISEC = Integer.valueOf(cryptographic_Timeout.get(0).Value__c);
                    }           
                    
                }catch( Exception e ){
                    SERVICE_TIMEOUT_MILISEC = DEFAULT_TIMEOUT;
                }
            }
            return SERVICE_TIMEOUT_MILISEC;
            
        }set;
    }
    
    @HttpPost
    global static void mappingService(){
        /* cast */
        String errorMessage = '';
        String customerName = '';
        String msLogId = '';
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        String rmId = '';
        String serviceName = '';
        String requestBody = '';
        String responseBody = '';
        String requestBodyDecrypt = '';
        String reqId = '';
        DateTime startTime = DateTime.Now();
        DateTime endTime;
        
        Account accForLog = new Account();
        
        Boolean isSuccess = true;
        
        String endpoint = '';

        String processType;
        /* end cast */
        
        /* Additional get key specific from request */
        RestRequest request = RestContext.request;
        String encryptKey = '';
        try {
            encryptKey = getKeyFromSystem(request);
        } catch (WebserviceAbstract.MissingHeaderException e) {
        	encryptKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), SCSMessageAPIUtil.INTEGRATE_SYSTEM.OneApp);
        }
        //String encryptKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), SCSMessageAPIUtil.INTEGRATE_SYSTEM.OneApp);
        
        try{
            
            /* get req id */
            System.debug('get header');
            Map<String, String> headerKeys = RestContext.request.headers;
            reqId = (String)headerKeys.get('ReqId');
            /* decrypt */
            System.debug('decrypt-->' + encryptKey);
            Map<String, Object> requestRawBodyMap = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            requestBodyDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(RestContext.request.requestBody.toString(), encryptKey);
            
            /* deserialize */
            /*
            System.debug('deserialize-->' + requestBodyDecrypt);
            Map<String, Object> requestBodyMap = (Map<String, Object>)JSON.deserializeUntyped(requestBodyDecrypt);
            String objectName = (String)requestBodyMap.get('object_name');
            String recordId = (String)requestBodyMap.get('record_id');
            String extIdField = (String)requestBodyMap.get('extId_field');
            String uri = (String)requestBodyMap.get('uri');
            Object body = (Object)requestBodyMap.get('body');
            map<String,Object> bodyMap = (map<String,Object>) body;
            System.debug('bodymap:'+bodyMap);
            
            if(uri != null)
            {
               endpoint = uri;
            }
            else 
            {  
                if(recordId != '' && recordId != null)
                {                          
                    if(extIdField != '' && extIdField != null)
                    {
                        endpoint += objectName+'/'+extIdField+'/'+recordId+'?_HttpMethod=PATCH';                 
                    }
                    else
                    {
                        endpoint += objectName+'/'+recordId+'?_HttpMethod=PATCH';
                    
                    }
                    processType = 'Update';
                    
                }
                else
                {
                    endpoint += objectName+'/';
                    processType = 'Insert';
                }
            }
            System.debug('endpoint:'+endpoint);
            System.debug('body:'+body);
            Map<String,String> requestHeader = RestContext.request.headers;
            
            //set request inbound call
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v48.0/'+endpoint);
            req.setBody(JSON.serialize(body));
            req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
            System.debug('SERVICE_TIMEOUT_MILISEC:'+SERVICE_TIMEOUT_MILISEC);
            req.setTimeout(SERVICE_TIMEOUT_MILISEC);
            if(requestHeader.containsKey('Content-Type'))
            {
                req.setHeader('Content-Type', requestHeader.get('Content-Type'));  
            }
            if(requestHeader.containsKey('Sforce-Auto-Assign'))
            {
                req.setHeader('Sforce-Auto-Assign', requestHeader.get('Sforce-Auto-Assign'));  
            }
            req.setMethod('POST');
            System.debug('endpoint:'+req.getEndpoint());
            
            HttpResponse res;
            
            System.debug('Send request!');
            //get inbound response
            if (!Test.isRunningTest()) {
                res = h.send(req); 
            }
            else
            {
                res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setHeader('Sforce-Auto-Assign', 'false');
                //encrypt response body
                res.setBody(JSON.serialize(body));
                res.setStatusCode(200);
            }
            System.debug('Response:'+ res.getBody());
            String resBodyEncrypt = (String)SCSMessageAPIUtil.encryptMessageWithKey(res.getBody(), encryptKey);

            RestContext.response.addHeader('Content-Type', 'application/json');
            //Return reference key request id
            RestContext.response.addHeader('ReqId', reqId);
            RestContext.response.statusCode = res.getStatusCode();
            RestContext.response.responseBody = Blob.valueOf(resBodyEncrypt);
            isSuccess = true;
            
            if(res.getStatusCode() == 400)
            {
                isSuccess = false;
                errorMessage = res.getBody();
            }
            else if(res.getStatusCode() == 404)
            {
                isSuccess = false;
                errorMessage = res.getBody();
            }         	
            */
            
            Map<String, Object> result = callStandardAPI(requestBodyDecrypt, headerKeys, encryptKey);

            isSuccess = (Boolean) result.get('isSuccess');
            errorMessage = (String) result.get('errorMessage');

            endTime = DateTime.Now();
            
            requestBody = headerKeys.toString() + '\n\n' + requestBodyDecrypt;
            responseBody = (String) result.get('responseBody');
            endpoint = (String) result.get('endpoint');
            serviceName = '/services/apexrest/data/V1.0/cryptographic'+ '  (' + endpoint + ')';

            OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  reqId ,  userName, 
                                                  rmId ,  serviceName , requestBody , responseBody ,  accForLog , 
                                                  startTime ,  endTime,  null );
                                                     
        }
        catch(exception e)
        {       
			/* catch error log */
            errorMessage = 'Message: ' + e.getMessage();
            isSuccess = false;
            endTime = DateTime.Now();
            
            serviceName = '/services/apexrest/data/V1.0/cryptographic';

            String reponseString = '{\n  "errorCode": "'+e.getTypeName()+'",\n  "message": "'+e.getMessage()+'"\n}';           
            requestBodyDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(RestContext.request.requestBody.toString(), encryptKey);
            requestBody = RestContext.request.headers.toString() + '\n\n' +requestBodyDecrypt;
            responseBody = reponseString;
           
            /* return error response */
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf(reponseString);  
            System.debug('res-->' + errorMessage + ' ' + encryptKey);
            RestContext.response.responseBody = Blob.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(reponseString, encryptKey));
			/* save error to online log */
            OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  reqId ,  userName, 
                                                  rmId ,  serviceName , requestBody , responseBody ,  accForLog , 
                                                  startTime ,  endTime,  null );
        }
        
	}
}