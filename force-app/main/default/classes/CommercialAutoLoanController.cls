public without sharing class CommercialAutoLoanController extends AbstractCoreClass {
    private static String APPID = AppConfig__c.getValues('APPID') == null ? 'A0291' : AppConfig__c.getValues('APPID').Value__c;
    
    private static final Integer timeout {
        get {
            // 120000 ms
            if(timeout == null){
                List<App_Config__mdt> productHoldingTimeOut = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'ProductHolding_TIMEOUT_INT_SECS'];
                timeout = productHoldingTimeOut != null && productHoldingTimeOut.size() > 0 ? Integer.valueOf(productHoldingTimeOut.get(0).Value__c) * 1000 : 120000;
            }
            return timeout;
        }
        set;
    }

    private static SCSMessageAPIUtil.INTEGRATE_SYSTEM getIntegateSystem(String systemKey) {
        Map<String, SCSMessageAPIUtil.INTEGRATE_SYSTEM> systemIntegate = new Map<String, SCSMessageAPIUtil.INTEGRATE_SYSTEM> {
            'FloorPlan' => SCSMessageAPIUtil.INTEGRATE_SYSTEM.FloorPlan,
            'CoreHP' => SCSMessageAPIUtil.INTEGRATE_SYSTEM.CoreHP,
            'DWH' => SCSMessageAPIUtil.INTEGRATE_SYSTEM.DWH,
            'EC' => SCSMessageAPIUtil.INTEGRATE_SYSTEM.EC
        };
        return systemIntegate.containsKey(systemKey) ? systemIntegate.get(systemKey) : null;
    }

    @AuraEnabled(cacheable=true)
    public static Object getAccessibleCusHold(String accountId) {
        // Account account = [SELECT Id, RecordType.Name FROM Account WHERE Id = :accountId LIMIT 1];
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id = :userinfo.getProfileId() LIMIT 1];
        String SECTION_CUST_HOLD_LOW = 'CommCust:Customer Product Holding (Low)';
        String SECTION_CUST_HOLD_MID = 'CommCust:Customer Product Holding (Medium)';
        String SECTION_CUST_HOLD_HIG = 'CommCust:Customer Product Holding (High)';
        return new RTL_ProductHoldingsLightningUtil.AccessibleCusHold(
            RTL_AccountUtility.verifyFieldSecurity(SECTION_CUST_HOLD_LOW, userProfile.name, accountId),
            RTL_AccountUtility.verifyFieldSecurity(SECTION_CUST_HOLD_MID, userProfile.name, accountId),
            RTL_AccountUtility.verifyFieldSecurity(SECTION_CUST_HOLD_HIG, userProfile.name, accountId)
        );
    }

    @AuraEnabled(cacheable=true)
    public static Object getAppConfigMdtByKey(String key) {
        Map<String, String> appConfigs = new Map<String, String>();
        for (App_Config__mdt appc : [SELECT DeveloperName, Value__c FROM App_Config__mdt WHERE DeveloperName = :key]) {
            appConfigs.put(appc.DeveloperName, appc.Value__c);
        }
        return appConfigs.containsKey(key) ? appConfigs.get(key) : '';
    }
    
    @AuraEnabled(cacheable=true)
    public static Object getIsALGuarantorMdt() {
        String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        Map<String, RTL_AL_Guarantor__mdt> appConfigs = new Map<String, RTL_AL_Guarantor__mdt>();
        for (RTL_AL_Guarantor__mdt appc : [SELECT Id, Profile_Name__c FROM RTL_AL_Guarantor__mdt]) {
            appConfigs.put(appc.Profile_Name__c, appc);
        }
        return appConfigs.containsKey(profileName);
    }

    @AuraEnabled(cacheable=true)
    public static Object getALDXWFMdt() {
        Map<String, ALDX_WF_Status__mdt> alds_wf_map = new Map<String, ALDX_WF_Status__mdt>();
        for(ALDX_WF_Status__mdt alds_wf : [SELECT STATUS_CODE__c, STATUS_NAME__c, WARNING_MESSAGE__c, IS_ACTIVE__c FROM ALDX_WF_Status__mdt WHERE WARNING_MESSAGE__c <> null]) {
            alds_wf_map.put(String.valueOf(Integer.valueOf(alds_wf.STATUS_CODE__c)), alds_wf);
        }
        return alds_wf_map;
    }

    @AuraEnabled(cacheable=true)
    public static Object getALDXWFMdtAll() {
        Map<String, ALDX_WF_Status__mdt> alds_wf_map = new Map<String, ALDX_WF_Status__mdt>();
        for(ALDX_WF_Status__mdt alds_wf : [SELECT STATUS_CODE__c, STATUS_NAME__c, WARNING_MESSAGE__c, IS_ACTIVE__c FROM ALDX_WF_Status__mdt]) {
            alds_wf_map.put(String.valueOf(Integer.valueOf(alds_wf.STATUS_CODE__c)), alds_wf);
        }
        return alds_wf_map;
    }

    @AuraEnabled(continuation=true)
    public static Object getProduct(String endpoint, String callback, String body, String service, Object state){
        try{ 
            String privateKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), getIntegateSystem(service));
            String bodyEncrypt = (String)SCSMessageAPIUtil.encryptMessageWithKey(body, privateKey);
            
            Uuid uuidGenerateor = new Uuid();
            String uuid = uuidGenerateor.getValue();

            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
            req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
            req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
            req.setHeader('Request-UID', uuid);
            req.setHeader('Request-App-ID', APPID);
            req.setEndpoint(endpoint);
            req.setBody(bodyEncrypt);
            req.setTimeout(timeout);

            Continuation con = new Continuation(timeout/1000 != 0 ? timeout/1000 : 1);
            state = putObject('startDateTime', Datetime.now(), state);
            state = putObject('body', body, state);
            state = putObject('uuid', uuid, state);
            state = putObject('endpoint', endpoint, state);
            con.state = state;
            con.continuationMethod = callback;
            con.addHttpRequest(req);

            return con;
        } catch( Exception e ){
            throw new AuraHandledException(String.format('{0}\n{1}', new List<String>{
                e.getMessage(),
                e.getStackTraceString()
            }));
        }
    }

    @AuraEnabled
    public static Object callbackGuarantor(List<String> labels, Object state){
        String dataDecrypt;

        HttpResponse res = Continuation.getResponse((String)labels.get(0));
        try {
            String service = (String)getResult('service', state);
            String privateKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), getIntegateSystem(service));
            // response body encrypt
            // res.setBody((String)SCSMessageAPIUtil.encryptMessageWithKey(
            //     '{"status":{"code":"999","description":"Success"},"guarantors":[{"c_name":"hhhh","id_no":"4552466","id_birth_date":"24/12/1997"},{"c_name":"iiiiii","id_no":"6432857","id_birth_date":"14/2/1999"},{"c_name":"pppp","id_no":"4552466","id_birth_date":"24/12/1997"},{"c_name":"nnnnn","id_no":"4552466","id_birth_date":"24/12/1997"}]}'    
            // , privateKey));
            // res.setBody('');
            // res.setStatusCode(2002);

            Map<String, Object> result = new Map<String, Object>();
            if(!String.isEmpty(res.getBody())) {
                dataDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(res.getBody(), privateKey);
                result = dataDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(dataDecrypt) : result;

            }

            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('status.code', result) : '999');
            String ErrorMsg = String.valueOf(!result.isEmpty() ? getResult('status.description', result) : getValuesWithRegex(res.getBody(), new List<String>{'StatusDesc', 'errordesc'}));
            Boolean isSuccess = new List<String> {'0000', '4001'}.contains(StatusCode);
            Boolean isNoData = new List<String> {'4001'}.contains(StatusCode);

            saveOnlineServiceLog(isSuccess, isNotEmpty(ErrorMsg) ? ErrorMsg : RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode()), state, res, dataDecrypt != null ? dataDecrypt : res.getBody());
            System.debug('isSuccess-->' + isSuccess);
            System.debug('isNoData-->' + isNoData);
            System.debug('ErrorMsg-->' + ErrorMsg);
            System.debug('res.getBody()-->' + res.getBody());
            if(String.isEmpty(res.getBody())) {
                return new Map<String, Object>{
                    'StatusCode' => res.getStatusCode(),
                    'StatusDesc' => res.getStatus(),
                    'Message' => System.Label.ERR002,
                    'isTimeout' => true,
                    'StatusDescContinuation' => RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode())
                };
            }
            
            result = (Map<String, Object>)putObject('isError', !isSuccess, result);
            result = (Map<String, Object>)putObject('isNoData', isNoData, result);
            
            if (isNoData) {
                return result;
            }
            System.debug('Result-->' + result);
            System.debug('result.keySet()-->' + result.keySet());


            /* Fixed security issue #2 : get id card number and marked 
                CommCust:Customer Product Holding (High)
                Auttapol Pipatpatama
            */
            
            // Check access for customer product holding
            String recordId = (String)getResult('recordId', state);
            String sectionName = (String)getResult('sectionName', state);

            Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id = :userinfo.getProfileId() LIMIT 1];
            Boolean isAccess ;
            if (String.isEmpty(sectionName)) {
                isAccess = true;
            } else {
                isAccess = RTL_AccountUtility.verifyFieldSecurity(sectionName, userProfile.name, recordId );
            }
            System.debug('userProfile-->' + userProfile);
            System.debug('isAccess-->' + isAccess);
            System.debug('Result-->' + getResult('account.guarantors', result));

            List<object> guarantorList = (List<object>) getResult('account.guarantors', result);
            Object accountObj = result.get('account');
            List<Object> objList = new List<Object>();
            Map<String, Object> theObj;
            for (object oin : guarantorList) {
                theObj = (Map<String, Object>) oin;
                if (!theObj.isEmpty()) {
                    if (isAccess) {

                        Boolean isAlGuarantorAccess = (Boolean) getIsALGuarantorMdt();
                        System.debug('isAlGuarantorAccess-->' + isAlGuarantorAccess);
                        if (!isAlGuarantorAccess) {
                            String idNo = (String) theObj.get('id_no');
                            if (idNo.length() > 4) {
                                integer startPosition = idNo.length() - 3;
                                integer endPosition = idNo.length();
                                theObj.put('id_no', 'xxx' + idNo.substring(startPosition, endPosition));
                            } else {
                                theObj.put('id_no', 'xxx' + idNo);
                            }
                        }

                    } else {
                        setNoAccess(theObj);
                    }
    
                    System.debug('theObj-->' + theObj.get('id_no'));    
                }     
            }
            System.debug('guarantorList-->' + guarantorList);
            object newResult = putObjectByPath('account.guarantors', guarantorList, result);

            // result = (Map<String, Object>)putObject('Message', !isSuccess ? System.Label.ERR001 : null, result);
            return newResult;
        } catch (Exception e) {
            String errorMsg = String.format('{0}\n{1}\n', new List<String>{
                e.getMessage(),
                e.getStackTraceString()
             });
            System.debug('ERROR' + e.getMessage());
            System.debug('ERROR' + e);
            saveOnlineServiceLog(false, errorMsg, state, res, dataDecrypt != null ? dataDecrypt : res.getBody());
            return new Map<String, Object>{
                'isThrow' => true,
                'message' => errorMsg
            };
        }
    }
    
    @AuraEnabled
    public static Object callbackFloorPlanList(List<String> labels, Object state){
        String dataDecrypt;
        HttpResponse res = Continuation.getResponse((String)labels.get(0));
        try {
            String service = (String)getResult('service', state);
            String privateKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), getIntegateSystem(service));
            // response body encrypt
            // res.setBody((String)SCSMessageAPIUtil.encryptMessageWithKey(
            //     '{"details":[{"fp_ca_no":"001359502065","car_type_desc":"New Car","approve_date":"20/03/2017","approve_date_th":"20/03/2560","exp_date":"31/10/2018","exp_date_th":"31/10/2561","status":"Active","credit_limit":70000000,"os_balance":17653820,"credit_available":52346180},{"fp_ca_no":"001359502073","car_type_desc":"New Car","approve_date":"20/03/2017","approve_date_th":"20/03/2560","exp_date":"31/10/2018","exp_date_th":"31/10/2561","status":"Active","credit_limit":123568761,"os_balance":6523260,"credit_available":1235321}],"total_record":7,"paging":{"count":5,"limit":5,"offset":0,"total":7},"fp_response":{"code":200,"description":"Success"}}'    
            // , privateKey));
            // res.setBody('');
            // res.setStatusCode(500);

            Map<String, Object> result = new Map<String, Object>();
            if(!String.isEmpty(res.getBody())) {
                dataDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(res.getBody(), privateKey);
                result = dataDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(dataDecrypt) : result;
            }

            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('fp_response.code', result) : '');
            String ErrorMsg = String.valueOf(!result.isEmpty() ? getResult('fp_response.description', result) : getValuesWithRegex(res.getBody(), new List<String>{'StatusDesc', 'errordesc'}));
            Boolean isSuccess = new List<String>{'FP001', 'FP020'}.contains(StatusCode);
            
            saveOnlineServiceLog(isSuccess, isNotEmpty(ErrorMsg) ? ErrorMsg : RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode()), state, res, dataDecrypt != null ? dataDecrypt : res.getBody());

            if(String.isEmpty(res.getBody())) {
                return new Map<String, Object>{
                    'StatusCode' => res.getStatusCode(),
                    'StatusDesc' => res.getStatus(),
                    'Message' => System.Label.ERR002,
                    'isTimeout' => true,
                    'StatusDescContinuation' => RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode())
                };
            }
             
            result = (Map<String, Object>)putObject('isError', !isSuccess, result);
            return result;
        } catch (Exception e) {
            String errorMsg = String.format('{0}\n{1}\n', new List<String>{
                e.getMessage(),
                e.getStackTraceString()
             });
            
            saveOnlineServiceLog(false, errorMsg, state, res, dataDecrypt != null ? dataDecrypt : res.getBody());
            return new Map<String, Object>{
                'isThrow' => true,
                'message' => errorMsg
            };
        }
    }

    @AuraEnabled
    public static Object callbackFloorPlanDetail(List<String> labels, Object state){
        String dataDecrypt;
        HttpResponse res = Continuation.getResponse((String)labels.get(0));
        try {
            String service = (String)getResult('service', state);
            String privateKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), getIntegateSystem(service));

            // response body encrypt
            // res.setBody((String)SCSMessageAPIUtil.encryptMessageWithKey(
            //     '{"fp_ca_no":"001363900563","os_balance":5447140,"details":[{"eff_date":"20/03/2020","eff_date_th":"20/03/2563","fp_ts_no":"4446300717","chassis_no":"MMM142EL0LH633982","engine_no":"LKH G200291138","license_no":"","make_desc":"CHEVROLET","prin_amt":516075,"loan_day":0,"os_balance":516075},{"eff_date":"20/03/2020","eff_date_th":"20/03/2563","fp_ts_no":"4446355555","chassis_no":"MMM142EL0LH633982","engine_no":"LKH G200291138","license_no":"","make_desc":"CHEVROLET","prin_amt":516075,"loan_day":0,"os_balance":516075},{"eff_date":"20/04/2020","eff_date_th":"20/04/2563","fp_ts_no":"4236355666","chassis_no":"MMM142EL0LH677982","engine_no":"LKH G200291138","license_no":"","make_desc":"CHEVROLET","prin_amt":300075,"loan_day":0,"os_balance":102475}],"total_record":20,"paging":{"count":2,"limit":100,"offset":0,"total":2},"fp_response":{"code":200,"description":"Success"}}'
            // , privateKey));

            Map<String, Object> result = new Map<String, Object>();
            if(!String.isEmpty(res.getBody())) {
                dataDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(res.getBody(), privateKey);
                result = dataDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(dataDecrypt) : result;
            }
            
            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('fp_response.code', result) : '');
            String ErrorMsg = String.valueOf(!result.isEmpty() ? getResult('fp_response.description', result) : getValuesWithRegex(res.getBody(), new List<String>{'StatusDesc', 'errordesc'}));
            Boolean isSuccess = new List<String>{'FP001', 'FP020'}.contains(StatusCode);
            saveOnlineServiceLog(isSuccess, isNotEmpty(ErrorMsg) ? ErrorMsg : RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode()), state, res, dataDecrypt != null ? dataDecrypt : res.getBody());

            if(String.isEmpty(res.getBody())) {
                return new Map<String, Object>{
                    'StatusCode' => res.getStatusCode(),
                    'StatusDesc' => res.getStatus(),
                    'Message' => System.Label.ERR002,
                    'isTimeout' => true,
                    'StatusDescContinuation' => RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode())
                };
            }
            result = (Map<String, Object>)putObject('isError', !isSuccess, result);
            return result;
        } catch (Exception e) {
            String errorMsg = String.format('{0}\n{1}\n', new List<String>{
                e.getMessage(),
                e.getStackTraceString()
             });
            
            saveOnlineServiceLog(false, errorMsg, state, res, dataDecrypt != null ? dataDecrypt : res.getBody());
            return new Map<String, Object>{
                'isThrow' => true,
                'message' => errorMsg
            };
        }
    }

    @AuraEnabled
    public static Object callbackLeasingList(List<String> labels, Object state){
        String dataDecrypt;
        HttpResponse res = Continuation.getResponse((String)labels.get(0));
        try {
            String service = (String)getResult('service', state);
            String privateKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), getIntegateSystem(service));
            
            // response body encrypt
            // res.setBody((String)SCSMessageAPIUtil.encryptMessageWithKey(
            //     '{"status":{"code":"200","description":"success"},"leasing_summary_info":[{"ca_no":"001360500152","account_status":"Active","cash_price_vat":"10250.12","principal_amount":"1234","installment_amount":"5000","overdue_no":"78901234","overdue_amount":"12200"}]}'
            // , privateKey));
            // res.setBody('');
            // res.setStatusCode(500);

            Map<String, Object> result = new Map<String, Object>();
            if(!String.isEmpty(res.getBody())) {
                dataDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(res.getBody(), privateKey);
                result = dataDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(dataDecrypt) : result;
            }
            
            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('status.code', result) : '5000');
            String ErrorMsg = String.valueOf(!result.isEmpty() ? getResult('status.description', result) : getValuesWithRegex(res.getBody(), new List<String>{'StatusDesc', 'errordesc', 'description'}));
            Boolean isSuccess = new List<String>{'0000', '4000'}.contains(StatusCode);

            saveOnlineServiceLog(isSuccess, isNotEmpty(ErrorMsg) ? ErrorMsg : RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode()), state, res, dataDecrypt != null ? dataDecrypt : res.getBody());
            if(String.isEmpty(res.getBody())) {
                return new Map<String, Object>{
                    'StatusCode' => res.getStatusCode(),
                    'StatusDesc' => res.getStatus(),
                    'Message' => System.Label.ERR002,
                    'isTimeout' => true,
                    'StatusDescContinuation' => RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode())
                };
            }
            
            result = (Map<String, Object>)putObject('isError', !isSuccess, result);
            result = (Map<String, Object>)putObject('isNotFound', new List<String>{'4000', '5000'}.contains(StatusCode), result);
            return result;
        } catch (Exception e) {
            String errorMsg = String.format('{0}\n{1}\n', new List<String>{
                e.getMessage(),
                e.getStackTraceString()
             });
            
            saveOnlineServiceLog(false, errorMsg, state, res, dataDecrypt != null ? dataDecrypt : res.getBody());
            return new Map<String, Object>{
                'isThrow' => true,
                'message' => errorMsg
            };
        }
    }

    @AuraEnabled
    public static Object callbackLeasingDetail(List<String> labels, Object state){
        String dataDecrypt;
        HttpResponse res = Continuation.getResponse((String)labels.get(0));
        try {
            String service = (String)getResult('service', state);
            String privateKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), getIntegateSystem(service));
            // response body encrypt
            // res.setBody(
            //     (String)SCSMessageAPIUtil.encryptMessageWithKey(
            //         '{"status":{"code":"200","description":"success"},"leasing_detail_info":{"ca_no":"001360500152","approve_date":"","type":"","due_date":"","first_due_date":"","maturity_date":"","installment_no":"","effective_rate":"","installment_amount":"","installment_amount_vat_included":"","down_payment_vat_included":"","cash_price":"","deposit_vat_included":"","residual_value_net_vat_included":"","asset_price_vat_included":"","principal_amount_vat_included":"","last_payment_date":"","overdue_no":"","overdue_dpd":"","overdue_amount":"","brand_name":"","model_description":"","principle_amount_balance":""}}'
            //     , privateKey)
            // );
            // res.setBody('');
            // res.setStatusCode(500);

            Map<String, Object> result = new Map<String, Object>();
            if(!String.isEmpty(res.getBody())) {
                dataDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(res.getBody(), privateKey);
                result = dataDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(dataDecrypt) : result;
            }
            
            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('status.code', result) : '5000');
            String ErrorMsg = String.valueOf(!result.isEmpty() ? getResult('status.description', result) : getValuesWithRegex(res.getBody(), new List<String>{'StatusDesc', 'errordesc', 'description'}));
            Boolean isSuccess = StatusCode == '0000';

            saveOnlineServiceLog(isSuccess, isNotEmpty(ErrorMsg) ? ErrorMsg : RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode()), state, res, dataDecrypt != null ? dataDecrypt : res.getBody());

            if(String.isEmpty(res.getBody())) {
                return new Map<String, Object>{
                    'StatusCode' => res.getStatusCode(),
                    'StatusDesc' => res.getStatus(),
                    'Message' => System.Label.ERR002,
                    'isTimeout' => true,
                    'StatusDescContinuation' => RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode())
                };
            }
            
            result = (Map<String, Object>)putObject('isError', !isSuccess, result);
            return result;
        } catch (Exception e) {
            String errorMsg = String.format('{0}\n{1}\n', new List<String>{
                e.getMessage(),
                e.getStackTraceString()
             });
            
            saveOnlineServiceLog(false, errorMsg, state, res, dataDecrypt != null ? dataDecrypt : res.getBody());
            return new Map<String, Object>{
                'isThrow' => true,
                'message' => errorMsg
            };
        }
    }

    @AuraEnabled
    public static Object callbackLeasingFlag(List<String> labels, Object state){
        String dataDecrypt;
        HttpResponse res = Continuation.getResponse((String)labels.get(0));
        try {
            String service = (String)getResult('service', state);
            String privateKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), getIntegateSystem(service));

            // res.setBody('');
            // res.setStatusCode(500);

            Map<String, Object> result = new Map<String, Object>();
            if(!String.isEmpty(res.getBody())) {
                dataDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(res.getBody(), privateKey);
                result = dataDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(dataDecrypt) : result;
            }
            
            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('status.code', result) : '9999');
            String ErrorMsg = String.valueOf(!result.isEmpty() ? getResult('status.description', result) : getValuesWithRegex(res.getBody(), new List<String>{'StatusDesc', 'errordesc', 'description'}));
            Boolean isSuccess = new List<String> {'0000', '4001'}.contains(StatusCode);

            saveOnlineServiceLog(isSuccess, isNotEmpty(ErrorMsg) ? ErrorMsg : RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode()), state, res, dataDecrypt != null ? dataDecrypt : res.getBody());

            if(String.isEmpty(res.getBody())) {
                return new Map<String, Object>{
                    'StatusCode' => res.getStatusCode(),
                    'StatusDesc' => res.getStatus(),
                    'Message' => System.Label.ERR002,
                    'isTimeout' => true,
                    'StatusDescContinuation' => RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode())
                };
            }
            
            result = (Map<String, Object>)putObject('isError', !isSuccess, result);
            return result;
        } catch (Exception e) {
            String errorMsg = String.format('{0}\n{1}\n', new List<String>{
                e.getMessage(),
                e.getStackTraceString()
             });
            
            saveOnlineServiceLog(false, errorMsg, state, res, dataDecrypt != null ? dataDecrypt : res.getBody());
            return new Map<String, Object>{
                'isThrow' => true,
                'message' => errorMsg
            };
        }
    }

    @AuraEnabled
    public static Object callbackHpFleetHpList(List<String> labels, Object state) {
        HttpResponse res = Continuation.getResponse((String)labels.get(0));
        String dataDecrypt;
        try {
            String service = (String)getResult('service', state);
            String privateKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), getIntegateSystem(service));

            // Mock data for testing 
            // res.setBody((String)SCSMessageAPIUtil.encryptMessageWithKey(
            //     '{"RES":{"RESPONSEMESSAGE":"Successful response","RESPONSECODE":"HP001"},"Output":[{"Channel":"นครปฐม","OverdueAmount":"21270.00","OverdueNo":"3","CurrentOfInstallments":"70","TotalInstallments":"84","NumberOfInstallmentBalance":"14","Installment":"10635.00","OutstandingAmount":"148890.00","HPNetAmount":"834897.00","HPTotalAmount":"893340.00","ContractStatusName":"ล/น เช่าซื้อปกติ (เก็บเงิน)","ContractStatusCode":"10","ContractNo":"455713745"},{"Channel":"สำนักงานใหญ่","OverdueAmount":"0.00","OverdueNo":"0","CurrentOfInstallments":"72","TotalInstallments":"72","NumberOfInstallmentBalance":"0","Installment":"9393.00","OutstandingAmount":"0.00","HPNetAmount":"632052.00","HPTotalAmount":"676296.00","ContractStatusName":"ปิดสัญญาปกติ","ContractStatusCode":"91","ContractNo":"215611574"},{"Channel":"สำนักงานใหญ่-test1","OverdueAmount":"0.00","OverdueNo":"0","CurrentOfInstallments":"72","TotalInstallments":"72","NumberOfInstallmentBalance":"0","Installment":"9393.00","OutstandingAmount":"0.00","HPNetAmount":"632052.00","HPTotalAmount":"676296.00","ContractStatusName":"ขายหนี้","ContractStatusCode":"99","ContractNo":"215611501"},{"Channel":"สำนักงานใหญ่-test2","OverdueAmount":"0.00","OverdueNo":"0","CurrentOfInstallments":"72","TotalInstallments":"72","NumberOfInstallmentBalance":"0","Installment":"9393.00","OutstandingAmount":"0.00","HPNetAmount":"632052.00","HPTotalAmount":"676296.00","ContractStatusName":"รถยึดได้ขายแล้วขาดทุน","ContractStatusCode":"43","ContractNo":"215611502"},{"Channel":"สำนักงานใหญ่","OverdueAmount":"0.00","OverdueNo":"0","CurrentOfInstallments":"72","TotalInstallments":"72","NumberOfInstallmentBalance":"0","Installment":"9393.00","OutstandingAmount":"0.00","HPNetAmount":"632052.00","HPTotalAmount":"676296.00","ContractStatusName":"รอฟ้องคดี","ContractStatusCode":"61","ContractNo":"215611503"}]}'
            // , privateKey));
            // res.setBody('');
            // res.setStatusCode(2002);

            Map<String, Object> result = new Map<String, Object>();
            if(!String.isEmpty(res.getBody())) {
                dataDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(res.getBody(), privateKey);
                result = dataDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(dataDecrypt) : result;
            }
            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('RES.RESPONSECODE', result) : '');
            String ErrorMsg = String.valueOf(!result.isEmpty() ? getResult('RES.RESPONSEMESSAGE', result) : getValuesWithRegex(res.getBody(), new List<String>{'StatusDesc', 'errordesc'}));
            Boolean isSuccess = new List<String>{'HP001', 'HP020'}.contains(StatusCode);

            saveOnlineServiceLog(isSuccess, isNotEmpty(ErrorMsg) ? ErrorMsg : RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode()), state, res, dataDecrypt != null ? dataDecrypt : res.getBody());

            if(String.isEmpty(res.getBody())) {
                return new Map<String, Object>{
                    'StatusCode' => res.getStatusCode(),
                    'StatusDesc' => res.getStatus(),
                    'Message' => System.Label.ERR002,
                    'isTimeout' => true,
                    'StatusDescContinuation' => RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode())
                };
            }
            
            result = (Map<String, Object>)putObject('isError', !isSuccess, result);
            result = (Map<String, Object>)putObject('HTTPStatusCode', res.getStatusCode(), result);
            return result;
        } catch (Exception e) {
            String errorMsg = String.format('{0}\n{1}\n', new List<String>{
                e.getMessage(),
                e.getStackTraceString()
             });
            saveOnlineServiceLog(false, errorMsg, state, res, dataDecrypt != null ? dataDecrypt : res.getBody());
            
            return new Map<String, Object>{
                'isThrow' => true,
                'message' => errorMsg
            };
        }
    }

    @AuraEnabled
    public static Object callbackHpFleetHpDetail(List<String> labels, Object state) {
        String dataDecrypt;
        HttpResponse res = Continuation.getResponse((String)labels.get(0));
        try {
            String service = (String)getResult('service', state);
            String privateKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), getIntegateSystem(service));      
            // response body encrypt
            // res.setBody('');
            // String dataEncrypt = (String)SCSMessageAPIUtil.encryptMessageWithKey(
            //     '{"RES":{"RESPONSEMESSAGE":"Successful response","RESPONSECODE":"HP001"},"Output":[{"GuarantorIDNo4":"","GuarantorBD4":"","GuarantorName4":"","GuarantorIDNo3":"3101702193075","GuarantorBD3":"12/05/2525","GuarantorName3":"นาย 4708743 ทดสอบ4708743 นามสกุล","GuarantorIDNo2":"5750200016304","GuarantorBD2":"23/11/2498","GuarantorName2":"นาย 2078161 ทดสอบ2078161 นามสกุล","GuarantorIDNo1":"3759800074196","GuarantorBD1":"09/01/2509","GuarantorName1":"นาง 3874839 ทดสอบ3874839 นามสกุล","CarEngineSize":"2198","CarEngno":"P4AT1221811","CarChasis":"MM8UP0DD100236703","CarRegProv":"กรุงเทพ ฯ","CarRegno":"4กก7836","CarTypeDesc":"เก๋ง 2 ตอน","CarYear":"2014","ContractStatusName":"อุบัติเหตุ","ContractStatusCode":"36","OutstandingAmount":"148890.00","FirstInstallmentDate10":"20/01/2558","PaymentMethodDesc":"2 :Auto Debit","DueDay":"20","CarDownAmt":"192800.00","MarketingOfficerName":"นาย 3823841 ทดสอบ 3823841 นามสกุล","LastDueDate":"20/12/2564","ProductCode":"NEW","HubOwnerName":"นครปฐม","OverdueNo":"0","PenaltyAmount":"389.00","OverdueAmount":"21270.00","FinancialAmount":"692200.00","ProductCarType":"รถใหม่","CarColorName":"ขาว","CarModel":"BT-50 Pro","CarBrandName":"MAZDA","NumberOfInstallmentBalance":"14","CurrentOfInstallments":"70","TotalInstallments":"84","InterestedRate":"4.15","InstallmentAmount":"10635.00","HPTotalAmount":"893340.00","CarpriceAmt":"885000.00","DealerName":"บจก. 157672 ทดสอบ 157672 นามสกุล","ContractDate10":"12/12/2557","CustomerCode":"3874837","ContractNo":"452015713745"}]}'
            // , privateKey);
            // res.setBody(dataEncrypt);

            Map<String, Object> result = new Map<String, Object>();
            if(!String.isEmpty(res.getBody())) {
                dataDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(res.getBody(), privateKey);
                result = dataDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(dataDecrypt) : result;
            }

            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('RES.RESPONSECODE', result) : 'HP999');
            String ErrorMsg = String.valueOf(!result.isEmpty() ? getResult('RES.RESPONSEMESSAGE', result) : getValuesWithRegex(res.getBody(), new List<String>{'StatusDesc', 'errordesc'}));
            Boolean isSuccess = StatusCode == 'HP001';

            saveOnlineServiceLog(isSuccess, isNotEmpty(ErrorMsg) ? ErrorMsg : RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode()), state, res, dataDecrypt != null ? dataDecrypt : res.getBody());

            if(String.isEmpty(res.getBody())) {
                return new Map<String, Object>{
                    'StatusCode' => res.getStatusCode(),
                    'StatusDesc' => res.getStatus(),
                    'Message' => System.Label.ERR002,
                    'isTimeout' => true,
                    'StatusDescContinuation' => RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode())
                };
            }
            
            result = (Map<String, Object>)putObject('isError', !isSuccess, result);
            result = (Map<String, Object>)putObject('HTTPStatusCode', res.getStatusCode(), result);
            return result;
        } catch (Exception e) {
            String errorMsg = String.format('{0}\n{1}\n', new List<String>{
                e.getMessage(),
                e.getStackTraceString()
             });
            
            saveOnlineServiceLog(false, errorMsg, state, res, dataDecrypt != null ? dataDecrypt : res.getBody());
            return new Map<String, Object>{
                'isThrow' => true,
                'message' => errorMsg
            };
        }
    }

    @AuraEnabled
    public static Object callbackCYBDetail(List<String> labels, Object state) {
        String dataDecrypt;
        HttpResponse res = Continuation.getResponse((String)labels.get(0));
        try {
            String service = (String)getResult('service', state);
            String privateKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), getIntegateSystem(service));

            // mock response body encrypt
            // res.setBody((String)SCSMessageAPIUtil.encryptMessageWithKey(
            //     '{"status":{"code":"0000","description":"Success"},"cyb_product_detail":{"past_due_payment_count":2,"total_past_due_amount":20100,"late_charges_amount":7569.86,"fee_due_amount":200,"license_no":"","chasis_no":"","car_regis_date":"","tax_due_date":"","custdn_status_desc":"","car_details":"","engine_no":"","committee_price":"","req_date":""}}', 
            //     privateKey
            //     )
            // );
            // res.setBody('');
            // res.setStatusCode(2002);

            Map<String, Object> result = new Map<String, Object>();
            if(!String.isEmpty(res.getBody())) {
                dataDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(res.getBody(), privateKey);
                result = dataDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(dataDecrypt) : result;
            }

            String StatusCode = String.valueOf(!result.isEmpty() ? getResult('status.code', result) : '9999');
            List<Object> errors = (List<Object>)getResult('errors', result) != null ? (List<Object>)getResult('errors', result) : new List<Object>();
            Boolean isSuccess = errors?.size() > 0 || StatusCode == '0000';
            Boolean isError = false;
            String ErrorMsg = '';
            for (Object obj : errors) {
                String code = (String)getResult('code', obj);
                String message = (String)getResult('message', obj);
                // List are status codes
                isSuccess = isSuccess && new List<String>{ '0000', '4000' }.contains(code);
                isError = isError || new List<String>{ '5000' }.contains(code);
                ErrorMsg = !(new List<String>{'0000'}.contains(code)) && String.isEmpty(ErrorMsg) ? message : ErrorMsg;
            }
            ErrorMsg = String.isNotEmpty(ErrorMsg) ? ErrorMsg : String.valueOf(!result.isEmpty() ? getResult('status.description', result) : getValuesWithRegex(res.getBody(), new List<String>{'StatusDesc', 'errordesc', 'message', 'description'}));


            saveOnlineServiceLog(isSuccess, isNotEmpty(ErrorMsg) ? ErrorMsg : RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode()), state, res, dataDecrypt != null ? dataDecrypt : res.getBody());
            if(String.isEmpty(res.getBody())) {
                return new Map<String, Object>{
                    'StatusCode' => res.getStatusCode(),
                    'StatusDesc' => res.getStatus(),
                    'Message' => System.Label.ERR002,
                    'isTimeout' => true,
                    'StatusDescContinuation' => RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode())
                };
            }
            result = (Map<String, Object>)putObject('isSuccess', isSuccess || errors?.size() == 1, result); // for display value
            result = (Map<String, Object>)putObject('isError', !isSuccess || isError, result);
            // result = (Map<String, Object>)putObject('Message', !isSuccess ? System.Label.ERR001 : null, result);
            return result;
        } catch (Exception e) {
            String errorMsg = String.format('{0}\n{1}\n', new List<String>{
                e.getMessage(),
                e.getStackTraceString()
            });
            
            saveOnlineServiceLog(false, errorMsg, state, res, dataDecrypt != null ? dataDecrypt : res.getBody());
            return new Map<String, Object>{
                'isThrow' => true,
                'message' => errorMsg
            };
        }
    }

    
    private static void saveOnlineServiceLog(Boolean isSuccess, String errorMsg, Object state, HttpResponse res, String responseBody) {
        String tmbCustId = (String)getResult('tmbCustId', state);
        String uuid = (String)getResult('uuid', state);
        List<SObject> sobjList = [SELECT Id, Name, TMB_Customer_ID_PE__c, Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c = :tmbCustId FOR UPDATE];
        Account acct = sobjList.size() > 0 ? (Account)sobjList.get(0) : null;
        
        List<String> endPointList = String.valueOf(getResult('endpoint', state)).remove('callout:').split('\\?');
        Map<String, String> namedCredentialMap = new Map<String, String>();
        for(NamedCredential each : [SELECT Endpoint,DeveloperName FROM NamedCredential]){
            namedCredentialMap.put(each.DeveloperName, each.Endpoint);
        }
        String setEndpoint = namedCredentialMap.containsKey(endPointList.get(0)) ? namedCredentialMap.get(endPointList.get(0)) : '';
        setEndpoint = setEndpoint != '' && endPointList.size() > 1 ? String.format('{0}?{1}', new List<String>{
            setEndpoint, endPointList.get(1)
        }) : setEndpoint;

        RTL_CampaignUtil.saveToOnlineLog(
                isSuccess,
                acct != null ? acct.Name : '', // customerName
                errorMsg, // Error message
                uuid, // msLogId (UUID Get from header)
                UserInfo.getName(),
                tmbCustId != null ? tmbCustId : (String)acct.get('TMB_Customer_ID_PE__c'), // RMId (tmbCustId)
                setEndpoint,
                serializePrettyString((String)getResult('body', state)), // Request Body
                serializePrettyString(responseBody), // Response Body
                acct, // Account
                Datetime.valueofGmt(((String)getResult('startDateTime', state)).replace('T', ' ').replace('Z', ' ')), //first callProduct
                Datetime.now() // End datetime
            );
    }

    @AuraEnabled
    public static String getUnmaskBalance(){
        return ProductingUnmaskingSetup.getProductUnmaskSetting();
    }

    private static void setNoAccess(Map<String, Object> theObj) {
       
        for(String key: theObj.keySet()) {
            if (theObj.get(key) instanceof String) {
                theObj.put(key, '***********');
            }
        }
    }
}