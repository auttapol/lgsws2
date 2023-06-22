@RestResource(urlMapping='/data/V1.0/sobjects/manipulation/*')
global class ManipulationObjectService {
    
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
    
    
    @HttpPost
    global static void InsertUpdate(){
        
        String errorMessage = '';
        String customerName = '';
        String msLogId = '';
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        String rmId = '';
        String serviceName = '';
        String requestBody = '';
        String responseBody = '';
        
        DateTime startTime = DateTime.Now();
        DateTime endTime;
        
        Account accForLog = new Account();
        
        Boolean isSuccess = true;
        
        String endpoint = 'sobjects/';

        String processType;

        try
        {
            Map<String, Object> requestBodyMap = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            String objectName = (String)requestBodyMap.get('object_name');
            String recordId = (String)requestBodyMap.get('record_id');
            String extIdField = (String)requestBodyMap.get('extId_field');
            Object body = (Object)requestBodyMap.get('body');
            map<String,Object> bodyMap = (map<String,Object>) body;

            if(bodyMap.containsKey('q'))
            {
                processType = 'Query';
            }

            //set endpoint
            if(processType == 'Query')
            {
                endpoint = 'parameterizedSearch';
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
            
            HttpResponse res;
            
            if (!Test.isRunningTest()) {
                res = h.send(req); 
            }
            else
            {
                res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setHeader('Sforce-Auto-Assign', 'false');
                res.setBody(JSON.serialize(body));
                res.setStatusCode(200);
            }

            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.statusCode = res.getStatusCode();
            RestContext.response.responseBody = Blob.valueOf(res.getBody());
            
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
            
            endTime = DateTime.Now();
            serviceName = '/services/data/v48.0/sobjects/'+endpoint;
            requestBody = requestHeader.toString() + '\n\n' +RestContext.request.requestBody.toString();
            responseBody = res.getBody();

            if(bodyMap.containsKey('Owner'))
            {
                map<String,Object> userMap = (map<String,Object>) bodyMap.get('Owner');
                System.debug('body:'+userMap.get('Employee_ID__c'));
                System.debug('processType:'+processType);
                System.debug('objectName:'+objectName);
                //Process for send event to click to call
                if(processType == 'Insert' && objectName == 'Task' && bodyMap.get('Type') == 'Outbound Call')
                {
                    //Start Trigger Platform Events
                    Click_To_Call__e c2c = new Click_To_Call__e(
                        Employee_Id__c = (String)userMap.get('Employee_ID__c')
                    );
                    System.debug('c2c:'+c2c);
                    Database.SaveResult results = EventBus.publish(c2c);

                    // Inspect publishing result for each event

                    if(results.isSuccess()){
                        System.debug('Successfully published event.');
                    }
                    else
                    {
                        System.debug('Error returned: ' +
                                    results.getErrors()[0].getStatusCode() +
                                    ' - ' +
                                    results.getErrors()[0].getMessage());

                    }

                }
            }
            OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  msLogId ,  userName,
                                                  rmId ,  serviceName , requestBody , responseBody ,  accForLog , 
                                                  startTime ,  endTime,  null );
            
        }
        catch(exception e)
        {       

            errorMessage = 'Message: ' + e.getMessage();
            isSuccess = false;
            endTime = DateTime.Now();
            serviceName = '/services/data/v48.0/sobjects/'+endpoint;
            requestBody = RestContext.request.headers.toString() + '\n\n' +RestContext.request.requestBody.toString();
            responseBody = errorMessage;

            String reponseString = '{"errorCode":"'+e.getTypeName()+'", "message":"'+e.getMessage()+'"}';
            
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf(reponseString);

            OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  msLogId ,  userName,
                                                  rmId ,  serviceName , requestBody , responseBody ,  accForLog , 
                                                  startTime ,  endTime,  null );
        }
    }
}