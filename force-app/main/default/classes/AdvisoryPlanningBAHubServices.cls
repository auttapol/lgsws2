public with sharing class AdvisoryPlanningBAHubServices {

    @AuraEnabled
    public static LightningServiceResult getBancassuranceDetail(String ttbCustomerId, String customerId, String customerName, String coreBankSegment){
        LightningServiceResult result = new LightningServiceResult();
        
        String requestBody      = '';
        String responseBody     = '';
        String logServiceName   = 'AdvisoryPlanning - BA HUB';
        String userName         = UserInfo.getName();
        Datetime startTime      = Datetime.now();
        String startTimeStr     = startTime.format('yyyy-MM-dd\'T\'HH:mm:ss', 'Asia/Bangkok');
        String requestedDateTime =  JSON.serialize(startTime);
        result.executeDateTime  = startTime;

        
        
        try{
            if(String.isBlank(ttbCustomerId) || String.isBlank(customerId)){
                result.isSuccess = false;
                result.errorMessage = 'Unable to get the Bancassurance because it cannot Customer Id or ttb Customer Id.';
                return result;
            }

            //Boolean isSIT        = true;
            String access_token  = SmartBDM_Utility.tokenKeyEnliteGateWay;
            // if(isSIT){
            //     AuthenticationToken authen = RMC_Utility.startCallGetTokenService();
              //   String access_token     = authen.access_token;
            // }

            Map<String, RMC_Constant__mdt> constantMap = RMC_Utility.getRMContants('RM_Cockpits_Get_Recommended_Insurance');
            
            
            String endpoint      = 'callout:RMC_Get_Recommended_Insurance';
            // String privateKey    = (constantMap.containsKey('RMC_BAHUB_ENCRYPT_KEY')) ? String.valueOf(constantMap.get('RMC_BAHUB_ENCRYPT_KEY').Value__c) : 'c3018e70d8b7df129e502b2e12b8e4069e5c4cbae48ed9041a1454f069233265'; 
            Integer timeout      = (constantMap.containsKey('RMC_BAHUB_TIMEOUT')) ? Integer.valueOf(constantMap.get('RMC_BAHUB_TIMEOUT').Value__c) : 120000; 
            String callerId      = (constantMap.containsKey('RMC_BAHUB_CALLER_ID')) ? String.valueOf(constantMap.get('RMC_BAHUB_CALLER_ID').Value__c) :  '192.168.0.99'; 
            String serviceName   = (constantMap.containsKey('RMC_BAHUB_SERVICENAME')) ? String.valueOf(constantMap.get('RMC_BAHUB_SERVICENAME').Value__c) : 'get-recommended-insurance'; 
            String apiKey        = (constantMap.containsKey('RMC_BAHUB_API_KEY')) ? String.valueOf(constantMap.get('RMC_BAHUB_API_KEY').Value__c) : 'get-recommended-insurance'; 
            String privateKey    = '';
            if(Test.isRunningTest()){
                privateKey    = 'c3018e70d8b7df129e502b2e12b8e4069e5c4cbae48ed9041a1454f069233265';
            }else{
                 // privateKey = (String) SCSMessageAPIUtil.getScsEncryptKey('RMC_Get_BA_Hub_Key', SCSMessageAPIUtil.fetchUserSessionId());
                privateKey = (String) SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), SCSMessageAPIUtil.INTEGRATE_SYSTEM.Protection );
            }
            

              
            Uuid uuidGenerateor  = new Uuid();
            String uuid_value = uuidGenerateor.getValue();
            String rmID       = ttbCustomerId.right(14);
            Map<String, Object> bodyRequest = new Map<String, Object>{
                'rmId'          =>  rmID,
                'channelId'     =>  'CRM',
                'callerId'      =>  callerId,
                'requestNo'     =>  uuid_value,
                'timestamp'     =>  startTimeStr
            };
            requestBody          = JSON.serialize(bodyRequest);
            String encryptBody   = (!String.isBlank(privateKey)) ? SCSMessageAPIUtil.encryptMessageWithKey(requestBody, privateKey) : requestBody;
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');

            if (!Test.isRunningTest()) {
                req.setHeader('Authorization', 'Bearer ' + access_token);
            }
            req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
            req.setHeader('Request-Datetime', requestedDateTime);
            req.setHeader('Request-UID', uuid_value);
            req.setHeader('service-name', serviceName);
            req.setHeader('request-app-id', 'CRM');
            req.setHeader('api-key', 'Bearer ' + apiKey);
            
            req.setEndpoint(endpoint);
            req.setTimeout(timeout);
            req.setBody(encryptBody);
            
            System.debug(req.getEndpoint());
            System.debug(req);
            HTTPResponse res = http.send(req);
            responseBody = res.getBody();

            Map<String, Object> resultMap = new Map<String, Object>();
            
            
            System.debug('------ Integration to BA HUB -------');
            System.debug(res.getStatusCode() + ' ' + res.getStatus());
            System.debug(res.getBody());

            if(!String.isBlank(responseBody) && !String.isBlank(privateKey)){
                resultMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                if(resultMap != null && !resultMap.isEmpty()){
                    String initial_vector = (String) resultMap.get('initial_vector');
                    String encrypted_data = (String) resultMap.get('encrypted_data');

                    if(!String.isBlank(initial_vector) && !String.isBlank(encrypted_data)){
                        Blob initializationVector = EncodingUtil.convertFromHex(initial_vector);
                        Blob encryptedData = EncodingUtil.convertFromHex(encrypted_data);
                        Blob secretKey = EncodingUtil.convertFromHex(privateKey);
                        Blob decryptText = Crypto.decrypt('AES256', secretKey, initializationVector, encryptedData);

                        String decryptMessage = decryptText.toString();
                        responseBody = decryptMessage;
                        Map<String, Object> bodyMap = (!String.isBlank(decryptMessage)) ? (Map<String, Object>)JSON.deserializeUntyped(decryptMessage) : resultMap;
                        
                        String StatusCode = String.valueOf(!bodyMap.isEmpty() ? AbstractCoreClass.getResult('statusCode', bodyMap) : res.getStatusCode());
                        String ErrorMsg   = String.valueOf(!bodyMap.isEmpty() ? AbstractCoreClass.getResult('statusName', bodyMap) : AbstractCoreClass.getValuesWithRegex(responseBody, new List<String>{'StatusDesc', 'errordesc', 'statusName'}));
                        Boolean isSuccess = new List<String> {'000', '4001'}.contains(StatusCode);
                        Boolean isNoData  = new List<String> {'4001'}.contains(StatusCode);
                    
                        result.isSuccess    = (isNoData) ? false : isSuccess;
                        result.errorMessage = (isNoData) ? 'No Request Body Found' : ErrorMsg;
                        result.data         = bodyMap;
                    }else{

                        String StatusCode = String.valueOf(!resultMap.isEmpty() ? AbstractCoreClass.getResult('Status.StatusCode', resultMap) : res.getStatusCode());
                        String ErrorMsg   = String.valueOf(!resultMap.isEmpty() ? AbstractCoreClass.getResult('Status.StatusDesc', resultMap) : AbstractCoreClass.getValuesWithRegex(responseBody, new List<String>{'Status.StatusDesc'}));
                        
                        result.isSuccess    = false;
                        result.errorMessage = (!String.isBlank(ErrorMsg)) ? StatusCode + ' : ' + ErrorMsg : 'Cannot find the initial vector or encrypted data.';
                    }
                }else{
                    result.isSuccess        = false;
                    result.errorMessage     = 'Deserialize Response Body return null or empty value.';
                }
            }else{
                result.isSuccess        = false;
                result.errorMessage     = 'No Response body found';
            }
            

            RMC_Utility.saveToOnlineLog(result.isSuccess, customerName, result.errorMessage, null , userName, 
                            ttbCustomerId, logServiceName , requestBody , responseBody , 
                            customerId, coreBankSegment, startTime , DateTime.now(), 'Advisory Planning - BA HUB'); 
            
            return result;
            
        } catch( Exception e ){
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            
            result.isSuccess        = false;
            String errorMsg = String.format('{0}\n{1}\n', new List<String>{
                e.getMessage(),
                e.getStackTraceString()
             });
            result.errorMessage = errorMsg;
            RMC_Utility.saveToOnlineLog(result.isSuccess, customerName, result.errorMessage, null , userName, 
                            ttbCustomerId, logServiceName , requestBody , responseBody , 
                            customerId, coreBankSegment, startTime , DateTime.now(), 'Advisory Planning - BA HUB'); 
            
            return result;
        }
    }
   
}