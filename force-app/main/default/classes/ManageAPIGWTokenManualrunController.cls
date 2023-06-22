public class ManageAPIGWTokenManualrunController {

    public static String partitionName = Smart_BDM_Constant.CACHE_PARTITION_NAME_1;
    public static Cache.OrgPartition orgPartGetToken = Cache.Org.getPartition('local.' + partitionName);

    public static String APPID = AppConfig__c.getValues('APPID') == null ? 'A0291' : AppConfig__c.getValues('APPID').Value__c;

    public static final String REQBODY = AppConfig__c.getValues('Admin Dashboard WS Test Body') == null ? '{"GetCustomerAccountRequest" : {"FIIdent" : "0000000000000000","RMID" : "0000000000000000"}}' : AppConfig__c.getValues('Admin Dashboard WS Test Body').Value__c;
    public static final String REQNAMEDCRED = AppConfig__c.getValues('Admin Dashboard WS Test End point') == null ? 'callout:OSC01' : AppConfig__c.getValues('Admin Dashboard WS Test End point').Value__c;

    public static final Integer timeout {
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

    public static String ApiGatewayToken {
        get{
            if(ApiGatewayToken == null){
                ApiGatewayToken = SmartBDM_Utility.tokenKeyCalculateTools;
            }
            return ApiGatewayToken;
        }set;
    }

    public class PlatformCacheDetailWrapperClass {
        @AuraEnabled
        public String partitionName;

        @AuraEnabled
        public String JTI;

        @AuraEnabled
        public String clientID;

        @AuraEnabled
        public String lastCallTime;

        @AuraEnabled
        public String expiryTime;

        @AuraEnabled
        public String version;

        @AuraEnabled
        public Boolean isAccess;

        @AuraEnabled
        public Boolean isUnauthorized;
    }

    public class CrontriggerWrapperClass {
        @AuraEnabled
        public String CronJobDetailName;

        @AuraEnabled
        public String NextFireTime;

        @AuraEnabled
        public String State;

        @AuraEnabled
        public String CronExpression;

        @AuraEnabled
        public String TimeZoneSidKey;
    }

    @AuraEnabled
    public static void runGetAPIGWToken(){
        try{
            System.debug('enqueueJob ManageAPIGWTokenQueue');
            System.enqueueJob(new ManageAPIGWTokenQueue());
            ManageAPIGWTokenSchedulerUtil.abortOldJobs();
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static CrontriggerWrapperClass getAsyncQueueAPIGWTokenCrontrigger(){
        try {
            CrontriggerWrapperClass result = new CrontriggerWrapperClass();

            List<Crontrigger> crontrig = [SELECT Id, CronJobDetailId, CronJobDetail.Name, NextFireTime, State, CronExpression, TimeZoneSidKey FROM CronTrigger WHERE CronJobDetail.Name LIKE 'getTokenGatewayJob%' ORDER BY NextFireTime DESC LIMIT 1];
            
            result.CronJobDetailName = crontrig.size() > 0 ? crontrig.get(0).CronJobDetail != null ? crontrig.get(0).CronJobDetail.Name : '-' : '-';
            result.NextFireTime = crontrig.size() > 0 ? crontrig.get(0).NextFireTime != null ? string.valueOfGMT(crontrig.get(0).NextFireTime.addHours(7)) : '-' : '-';
            result.State = crontrig.size() > 0 ? crontrig.get(0).State : '-';
            result.CronExpression = crontrig.size() > 0 ? crontrig.get(0).CronExpression : '-';
            result.TimeZoneSidKey = crontrig.size() > 0 ? crontrig.get(0).TimeZoneSidKey : '-';

            return result;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static PlatformCacheDetailWrapperClass getTokenDataInPlatformCache(){
        try {
            PlatformCacheDetailWrapperClass result = new PlatformCacheDetailWrapperClass();

            result.isAccess = false;
            result.isUnauthorized = false;

            String accessTokenResult = SmartBDM_Utility.tokenKeyEnliteGateWay;

            if(accessTokenResult != null && accessTokenResult != ''){
                result.isAccess = true;
            }

            if(result.isAccess){
                Datetime startTime01 = Datetime.now();

                HttpResponse res = testWebSerivceToken();

                String responseBody01 = res.getBody();

                if(res.getStatusCode() == 401){
                    result.isUnauthorized = true;
                }

                RTL_CampaignUtil.saveToOnlineLog(
                    true,
                    'Admin Dashboard Test',
                    result.isUnauthorized ? 'Unauthorized' : 'SUCCESS',
                    '',
                    UserInfo.getName(),
                    'Admin Dashboard Test',
                    REQNAMEDCRED,
                    REQBODY,
                    responseBody01,
                    null,
                    startTime01,
                    Datetime.now()
                );
            }else{
                RTL_CampaignUtil.saveToOnlineLog(
                    true,
                    'Admin Dashboard Test',
                    result.isUnauthorized ? 'Unauthorized' : 'Token is null',
                    '',
                    UserInfo.getName(),
                    'Admin Dashboard Test',
                    REQNAMEDCRED,
                    null,
                    null,
                    null,
                    Datetime.now(),
                    Datetime.now()
                );
            }

            result.partitionName = orgPartGetToken.getName();
            result.JTI = string.valueOf(orgPartGetToken.get('jti') == null ? '-' : orgPartGetToken.get('jti'));
            result.clientID = string.valueOf(orgPartGetToken.get('clientid') == null ? '-' : orgPartGetToken.get('clientid'));
            result.lastCallTime = '-';
            result.expiryTime = orgPartGetToken.get('expirytime') != null ? string.valueOfGMT((DateTime)(orgPartGetToken.get('expirytime'))) + '(GMT+7)' : '-';
            result.version = string.valueOf(orgPartGetToken.get('version') == null ? '-' : orgPartGetToken.get('version'));

            if(orgPartGetToken.get('onlineServiceLogGateWay') != null){
                String oslog = orgPartGetToken.get('onlineServiceLogGateWay') + '';
                OnlineServiceLog osl = (OnlineServiceLog)JSON.deserialize(oslog, OnlineServiceLog.class);

                result.lastCallTime = osl.startTime + '(GMT+7)';
            }

            return result;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static HTTPResponse testWebSerivceToken(){
        String responseBody;
        HTTPResponse res;

        try{
            Datetime StartTime = (Datetime)Datetime.now();
            Uuid uuidGenerateor = new Uuid();
            HttpRequest req = new HttpRequest();

            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + ApiGatewayToken);

            req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
            req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
            req.setHeader('Request-UID', uuidGenerateor.getValue());
            req.setHeader('Request-App-ID', APPID);
            req.setEndpoint(REQNAMEDCRED);
            req.setBody(REQBODY);
            req.setTimeout(timeout);

            Http http = new Http();
            res = http.send(req);
            responseBody = res.getBody();
        } catch( Exception e ){
            System.debug('System error : ' + e.getMessage());
            System.debug('Stack Trace : ' + e.getStackTraceString());
            throw e;
        }
        return res;
    }
}