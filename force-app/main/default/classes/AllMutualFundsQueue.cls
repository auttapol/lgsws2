public with sharing class AllMutualFundsQueue implements Queueable ,Database.AllowsCallouts{
    
    public static final String ALL_MUTUAL_FUNDS_JOB  = 'GetAllMutualFundsJob - ';
    public Integer retryTimeout;
    public Integer maxRetryTime;
    public Integer currentRound;

    public AllMutualFundsQueue(Integer retryTimeout, Integer maxRetryTime, Integer currentRound) {
        this.retryTimeout = retryTimeout;
        this.maxRetryTime = maxRetryTime;
        this.currentRound = currentRound;
    }

    public void execute(QueueableContext context) {
        LightningServiceResult httpResult = executeMFCallout();
        Boolean isUpdateReturnRate        = false;
        Boolean isProcessSuccess          = true;

        try{
            if(httpResult.isSuccess && httpResult.dataMap != null && !httpResult.dataMap.isEmpty()){
                Map<String, Object> fundsMapByFundsCode = processFundMap(httpResult.dataMap);
                if(fundsMapByFundsCode != null && !fundsMapByFundsCode.isEmpty()){
                    RMC_Utility.ProductCodeWrapper productCodeMapSet  = RMC_Utility.getProductInformation(fundsMapByFundsCode.keySet()); 
    
                    Map<String, Product2> productToUpdateMap = new Map<String, Product2>();
                    System.debug(fundsMapByFundsCode);
                    System.debug(fundsMapByFundsCode.size());
                    for(String fundCode : fundsMapByFundsCode.keySet()){
                        Map<String, Object> fundData = (Map<String, Object>) fundsMapByFundsCode.get(fundCode);
                        if(fundData != null && !fundData.isEmpty()){
                            Product2 productMaster = null;
                            if(RMC_Utility.isNotEmpty(productCodeMapSet.product2MapByRTLProductCode) && productCodeMapSet.product2MapByRTLProductCode.containsKey(fundCode)) productMaster = (Product2) productCodeMapSet.product2MapByRTLProductCode.get(fundCode);
                            else if(RMC_Utility.isNotEmpty(productCodeMapSet.product2MapByTMBProductType) && productCodeMapSet.product2MapByTMBProductType.containsKey(fundCode)) productMaster = (Product2) productCodeMapSet.product2MapByTMBProductType.get(fundCode);
                            else if(RMC_Utility.isNotEmpty(productCodeMapSet.product2MapByProductCode) && productCodeMapSet.product2MapByProductCode.containsKey(fundCode)) productMaster = (Product2) productCodeMapSet.product2MapByProductCode.get(fundCode);
    
                            if(productMaster != null  && fundData.containsKey('return1Year')){
                                Product2 updatedProduct = new Product2(Id = productMaster.Id);
                                String return1Year      = (String) fundData.get('return1Year');
                                
                                System.debug(fundCode);
                                System.debug(return1Year);
                                if(!String.isBlank(return1Year)){
                                    updatedProduct.RMC_1Year_Return__c = Decimal.valueOf(return1Year);
                                    updatedProduct.RMC_Latest_Update_of_MF_Return__c = DateTime.now();
                                    isUpdateReturnRate = true;
                                    productToUpdateMap.put(fundCode, updatedProduct);
                                }
                            }
                        }
                    }
    
                    if(productToUpdateMap != null && !productToUpdateMap.isEmpty()){
                        System.debug(productToUpdateMap);
                        update productToUpdateMap.values();

                        RMC_AppConfig__c appConfig = RMC_AppConfig__c.getInstance('RMC_Latest_Update_of_MF_Return__c');
                        appConfig.RMC_Latest_Update_of_MF_Return__c = DateTime.now();
                        update appConfig;
                    }
                }
            }else{
                isProcessSuccess = false;
            }
        }catch(Exception ex){
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            isProcessSuccess = false;
        }

        if(!isProcessSuccess){
            this.currentRound = (this.currentRound == null) ? 1 : this.currentRound;
            Integer nextRound = this.currentRound + 1;
            if(nextRound <= this.maxRetryTime){
                executeRetryProcess(nextRound);
            }
        }
        
    }

    

    public Map<String, Object> processFundMap(Map<String,Object> httpResultMap){
        Map<String, Object> fundsMapByFundsCode = new Map<String, Object>();

        if(httpResultMap != null && !httpResultMap.isEmpty()){
            System.debug(httpResultMap);
            List<Object> fundClassList = (List<Object>) AbstractCoreClass.getResult('Body.fundClassList', httpResultMap);
            System.debug(fundClassList);
            if(fundClassList != null && !fundClassList.isEmpty()){
                for(Integer index  = 0; index < fundClassList.size(); index++){
                    Map<String, Object> eachFund = (Map<String, Object>) fundClassList.get(index);
                    if(eachFund.containsKey('fundCode')){
                        String fundCode = (String) eachFund.get('fundCode');
                        fundsMapByFundsCode.put(fundCode, eachFund);
                    }
                }
            }
        }

        return fundsMapByFundsCode;
    }

    public LightningServiceResult executeMFCallout(){
        LightningServiceResult result = new LightningServiceResult();
        
        String requestBody      = '';
        String responseBody     = '';
        String logServiceName   = 'AdvisoryPlanning - MF All';
        String userName         = UserInfo.getName();
        Datetime startTime      = Datetime.now();
        // String startTimeStr     = startTime.format('yyyy-MM-dd\'T\'HH:mm:ss', 'Asia/Bangkok');
        Uuid uuidGenerateor = new Uuid();
        String requestedDateTime =  JSON.serialize(startTime);

        //Boolean isSIT        = true;
        String access_token  = SmartBDM_Utility.tokenKeyEnliteGateWay;
        // if(isSIT){
        //     AuthenticationToken authen = RMC_Utility.startCallGetTokenService();
        //     access_token     = authen.access_token;
        // }


        Map<String, RMC_Constant__mdt> constantMap = RMC_Utility.getRMContants('RM_Cockpits_Get_All_Mutual_Fund');
        // String privateKey    = (constantMap.containsKey('RMC_MFALL_ENCRYPT_KEY')) ? String.valueOf(constantMap.get('RMC_MFALL_ENCRYPT_KEY').Value__c) : 'f5a3d1d4b72951a139374deb4c9f57d4e8c955d5572785af44a85d5d43f44a3f'; 
        String serviceName   = (constantMap.containsKey('RMC_MFALL_SERVICENAME')) ? String.valueOf(constantMap.get('RMC_MFALL_SERVICENAME').Value__c) : 'get-all-funds'; 
        String tokenKey      = (constantMap.containsKey('RMC_MFALL_REQUEST_TOKEN')) ? String.valueOf(constantMap.get('RMC_MFALL_REQUEST_TOKEN').Value__c) : '3Ts35JKPQs]qwhWOndm5'; 
        Integer timeout      = (constantMap.containsKey('RMC_MFALL_TIMEOUT')) ? Integer.valueOf(constantMap.get('RMC_MFALL_TIMEOUT').Value__c) : 120000; 
        String uuId          = uuidGenerateor.getValue();
        String endpoint      = 'callout:RMC_Get_All_Funds';
        //String endpoint      = 'https://apis-sit.tau2904.com/v1.0/crm/mutualfund/funds/get-all';

        

        try{

            String privateKey = '';
            if(Test.isRunningTest()){
                privateKey = 'f5a3d1d4b72951a139374deb4c9f57d4e8c955d5572785af44a85d5d43f44a3f';
            }else{
                privateKey = (String) SCSMessageAPIUtil.getScsEncryptKey('RMC_Get_All_Funds_Key', SCSMessageAPIUtil.fetchUserSessionId());
            }
        
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            if(!Test.isRunningTest()){ req.setHeader('Authorization', 'Bearer ' + + access_token);  }
            req.setHeader('service-name', serviceName);
            req.setHeader('request-uid', uuId);
            req.setHeader('request-app-id', 'CRM');
            req.setHeader('request-datetime',requestedDateTime);
            req.setHeader('request-token', tokenKey);
            req.setEndpoint(endpoint);
            req.setTimeout(timeout);

            HTTPResponse res    = http.send(req);
            responseBody = res.getBody();

            Map<String, Object> resultMap = new Map<String, Object>();
            System.debug('------ Integration to MF ALL -------');
            System.debug(res.getStatusCode() + ' ' + res.getStatus());
            System.debug(res.getBody());
            
            if(!String.isBlank(responseBody) && !String.isBlank(privateKey)){
                resultMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                String initial_vector = (String) resultMap.get('initialVector');
                String encrypted_data = (String) resultMap.get('encryptedData');
                System.debug(resultMap);

                if(!String.isBlank(initial_vector) && !String.isBlank(encrypted_data)){
                    Blob initializationVector = EncodingUtil.convertFromHex(initial_vector);
                    Blob encryptedData = EncodingUtil.convertFromHex(encrypted_data);
                    Blob secretKey = EncodingUtil.convertFromHex(privateKey);
                    Blob decryptText = Crypto.decrypt('AES256', secretKey, initializationVector, encryptedData);

                    String decryptMessage = decryptText.toString();
                    responseBody          = decryptMessage;
                    Map<String, Object> bodyMap = (!String.isBlank(decryptMessage)) ? (Map<String, Object>)JSON.deserializeUntyped(decryptMessage) : resultMap;
                    
                    String StatusCode = String.valueOf(!bodyMap.isEmpty() ? AbstractCoreClass.getResult('Status.StatusCode', bodyMap) : res.getStatusCode());
                    String ErrorMsg   = String.valueOf(!bodyMap.isEmpty() ? AbstractCoreClass.getResult('Status.StatusDesc', bodyMap) : AbstractCoreClass.getValuesWithRegex(responseBody, new List<String>{'StatusDesc', 'errordesc'}));
                    Boolean isSuccess = new List<String> {'0000', '4001'}.contains(StatusCode);
                    Boolean isNoData  = new List<String> {'4001'}.contains(StatusCode);
                    
                    result.isSuccess    = (isNoData) ? false : isSuccess;
                    result.errorMessage = (isNoData) ? 'No Request Body Found' : ErrorMsg;
                    result.dataMap      = bodyMap;
                }else{

                    String StatusCode = String.valueOf(!resultMap.isEmpty() ? AbstractCoreClass.getResult('Status.StatusCode', resultMap) : res.getStatusCode());
                    String ErrorMsg   = String.valueOf(!resultMap.isEmpty() ? AbstractCoreClass.getResult('Status.StatusDesc', resultMap) : AbstractCoreClass.getValuesWithRegex(responseBody, new List<String>{'StatusDesc', 'errordesc'}));
                    
                    result.isSuccess    = false;
                    if(!String.isBlank(StatusCode) && !String.isBlank(ErrorMsg)){
                        result.errorMessage    = ErrorMsg;
                    }else{
                        result.errorMessage = 'Cannot find the initial vector or encrypted data.';
                    }
                   
                }
            }else{
                result.isSuccess    = false;
                result.errorMessage = 'Http Status Code ' + res.getStatusCode() + ' Error : Cannot find response body';
            }


            RMC_Utility.saveToOnlineLog(result.isSuccess, null, result.errorMessage, null , userName, 
                    null, logServiceName , null , responseBody , null, null, startTime , DateTime.now(), logServiceName); 
            return result;

        } catch( Exception ex ){
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            String errorMsg = String.format('{0}\n{1}\n', new List<String>{
                ex.getMessage(),
                ex.getStackTraceString()
             });
            
            result.isSuccess    = false;
            result.errorMessage = errorMsg;
            RMC_Utility.saveToOnlineLog(result.isSuccess, null, result.errorMessage, null , userName, 
                            null, logServiceName , requestBody , responseBody , 
                            null, null, startTime , DateTime.now(), logServiceName); 
            return result;
        }
    }

    public void executeRetryProcess(Integer nextRound){
        DateTime currentTime = DateTime.now();
        Integer seconds      = (this.retryTimeout == null) ? 20 : this.retryTimeout / 1000;

        DateTime nextScheduleTime = currentTime.addSeconds(seconds);
        Map<String,String> scheduleMap    = RMC_Utility.getScheduleDT(AllMutualFundsQueue.ALL_MUTUAL_FUNDS_JOB , nextScheduleTime);
        if(scheduleMap != null && !scheduleMap.isEmpty()){
            String jobName      = (scheduleMap.containsKey('jobName')) ? scheduleMap.get('jobName') : '';
            String jobSchedule  = (scheduleMap.containsKey('jobSchedule')) ? scheduleMap.get('jobSchedule') : '';

            AllMutualFundsScheduler nextScheduler = new AllMutualFundsScheduler(nextRound);
            System.schedule(jobName, jobSchedule, nextScheduler);
        }
    }

 
}