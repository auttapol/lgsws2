/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Apex REST class designed to [Insert Summary Description Here].
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Auttapol Pipatpatama   <atp@ii.co.th>
* @version        1.0
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            atp@ii.co.th
* 2021-10-01      Initial version with comment to control version first time.
*
* v1.1            atp@ii.co.th
* 2021-10-20      Add "callStandardAPI" method.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

global abstract class WebserviceAbstract {
	public static String getKeyFromSystem(RestRequest request) {
		Map<String, String> requestHeader = request.headers;
        //SCSMessageAPIUtil.INTEGRATE_SYSTEM keyName = null;
        String keyName = null;
        String integrationSystem = requestHeader.get('Integration-System');
        System.debug('INTEGRATE_SYSTEM --> ' + integrationSystem);
        if (integrationSystem == null) {
            throw new MissingHeaderException('Missing Request Header [Integration-System]'); 
        }
        

        // New version
        keyName = SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), integrationSystem);
        if (keyName == null) {
            throw new MissingHeaderException('Invalid Request Header [Integration-System]'); 
        }

        return keyName;
        // for (SCSMessageAPIUtil.INTEGRATE_SYSTEM values : SCSMessageAPIUtil.INTEGRATE_SYSTEM.values() ) {
        //     if (integrationSystem.equals(String.valueOf(values)) ) {
		// 		keyName = values;
        //         break;
        //     }
        // }
        
        // if (keyName != null) {
        //     return (String) SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), keyName);
        // } else {
        // 	return null;    
        // }
        
    }
    
    public class MissingHeaderException extends Exception{}

    global class Response {
        public String status {get; set;}
        public String status_code {get; set;}
        public String message {get; set;}
        public Object data {get; set;}
    }

    public static Integer SERVICE_TIMEOUT_MILISEC{
        get{
            Integer DEFAULT_TIMEOUT = 60000;
            if(SERVICE_TIMEOUT_MILISEC == null){
                try{
                    SERVICE_TIMEOUT_MILISEC = DEFAULT_TIMEOUT;
                    List<App_Config__mdt> manipulation_Timeout = [SELECT Id, Label, Value__c FROM App_Config__mdt WHERE Label = 'MANIPULATION_TIMEOUT_MILLISEC' LIMIT 1];  
                    if (manipulation_Timeout != null && manipulation_Timeout.size() > 0) {
                        SERVICE_TIMEOUT_MILISEC = Integer.valueOf(manipulation_Timeout.get(0).Value__c);
                    }           
                    
                }catch( Exception e ){
                    SERVICE_TIMEOUT_MILISEC = DEFAULT_TIMEOUT;
                }
            }
            return SERVICE_TIMEOUT_MILISEC;
            
        }set;
    }

    public static Map<String, Object> callStandardAPI(String restRequestBody, Map<String,String> requestHeader, String encryptKey) {
        String serviceName = '';
        String processType = '';
        Boolean isSuccess = true;
        String errorMessage = '';

        /* Deserialize body from request */
        Map<String, Object> requestBodyMap = (Map<String, Object>)JSON.deserializeUntyped(restRequestBody);

        String objectName = (String)requestBodyMap.get('object_name');
        String recordId = (String)requestBodyMap.get('record_id');
        String extIdField = (String)requestBodyMap.get('extId_field');
        Object body = (Object)requestBodyMap.get('body');
        String apiVersion = requestHeader.get('api-version');
        String reqId = requestHeader.get('ReqId');
        map<String,Object> bodyMap = (map<String,Object>) body;

        if(bodyMap.containsKey('q')) {
            processType = 'Query';
        }

         /* Setting endpoint */
         String endpoint = 'sobjects/';
         if(processType == 'Query') {
            endpoint = 'parameterizedSearch';
        } else {
            if (objectName == 'composite') {
                endpoint = 'composite';
            } else if(recordId != '' && recordId != null)  {
                if(extIdField != '' && extIdField != null) {
                    endpoint += objectName+'/'+extIdField+'/'+recordId+'?_HttpMethod=PATCH';
                } else {
                    endpoint += objectName+'/'+recordId+'?_HttpMethod=PATCH';
                }
                processType = 'Update';

            } else {
                endpoint += objectName+'/';
                processType = 'Insert';
            }
        }
        System.debug('endpoint:'+endpoint);
        System.debug('body:'+body);

        if (apiVersion == null) {
            apiVersion = 'v48.0';
        }
        serviceName = '/services/data/' + apiVersion + '/'+endpoint;
        System.debug('serviceName:'+serviceName);

        /* Call standard API */
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + serviceName);
        req.setBody(JSON.serialize(body));
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        System.debug('SERVICE_TIMEOUT_MILISEC:'+SERVICE_TIMEOUT_MILISEC);
        req.setTimeout(SERVICE_TIMEOUT_MILISEC);
        if(requestHeader.containsKey('Content-Type')) {
            req.setHeader('Content-Type', requestHeader.get('Content-Type'));  
        }
        if(requestHeader.containsKey('Sforce-Auto-Assign')) {
            req.setHeader('Sforce-Auto-Assign', requestHeader.get('Sforce-Auto-Assign'));  
        }
        req.setMethod('POST');

        HttpResponse res;
            
        if (!Test.isRunningTest()) {
            res = h.send(req); 
        } else {
            res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Sforce-Auto-Assign', 'false');
            res.setBody(JSON.serialize(body));
            res.setStatusCode(200);
        }

        RestContext.response.addHeader('Content-Type', 'application/json');
        if (String.isNotEmpty(reqId)) {
            RestContext.response.addHeader('ReqId', reqId);
        }
        RestContext.response.statusCode = res.getStatusCode();
        
        if (String.isNotEmpty(encryptKey)) {
            String resBodyEncrypt = (String)SCSMessageAPIUtil.encryptMessageWithKey(res.getBody(), encryptKey);
            RestContext.response.responseBody = Blob.valueOf(resBodyEncrypt);
        } else {
            RestContext.response.responseBody = Blob.valueOf(res.getBody());
        }

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

        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('isSuccess', isSuccess);
        returnMap.put('errorMessage', errorMessage);
        returnMap.put('responseBody', res.getBody());
        returnMap.put('endpoint', endpoint);

        return returnMap;
    }
}