public class ManageAPIGWTokenQueue implements Queueable ,Database.AllowsCallouts {
    public final String partitionName = Smart_BDM_Constant.CACHE_PARTITION_NAME_1; // 'CreateGateWayToken' parttition
    public final Integer addSeconds = Smart_BDM_Constant.ADD_SEC_SCHEDULER_TOKEN;
    public final Cache.OrgPartition orgPartGetToken = Cache.Org.getPartition('local.' + partitionName);
    public final String namedCredentials = Smart_BDM_Constant.SMART_BDM_CAL_TOOLS_NAMED_CREDENTIALS;
    public final String ACCESS_TOKEN_TEXT = 'accesstoken';
    public final String EXPIRES_IN_TEXT = 'expiresin';
    public final String EXPIRY_TIME_TEXT = 'expirytime';
    public final String TOKEN_TYPE_TEXT = 'tokentype';
    public final String SCOPE_TEXT = 'scope';
    public final String JTI_TEXT = 'jti';
    public final String CLIENT_ID_TEXT = 'clientid';
    public final String VERSION_TEXT = 'version';
    public final Integer manageTokenQueueIntervalSec = Smart_BDM_Constant.MANAGE_TOKEN_QUEUE_INTERVAL_SEC;

    public void execute(QueueableContext context) {
        Boolean logIsSuccess = false;
        String logCustomerName = '';
        String logErrorMessage = '';
        String logmsLogId = ''; 
        String loguserName = UserInfo.getName();
        String logrmId = '';
        String logserviceName = '';
        String logrequestBody = '';
        String logresponseBody = '';
        Account logacc;
        DateTime logstartTime = Datetime.now();
        DateTime logendTime = Datetime.now();
        String logremark = '';
        // Long diffTimeMin;
        Long diffTimeSec;

        try {
            System.debug('ManageAPIGWTokenQueue | get token in cache : ' + orgPartGetToken.get(ACCESS_TOKEN_TEXT));
            System.debug('ManageAPIGWTokenQueue | expires in cache : ' + orgPartGetToken.get(EXPIRY_TIME_TEXT));
            if ( orgPartGetToken.contains(ACCESS_TOKEN_TEXT) && orgPartGetToken.contains(EXPIRY_TIME_TEXT) ){
                System.debug('ManageAPIGWTokenQueue | System now : ' + System.now().addHours(7));
                System.debug('ManageAPIGWTokenQueue | get token in cache : ' + orgPartGetToken.get(ACCESS_TOKEN_TEXT));
                System.debug('ManageAPIGWTokenQueue | expires in cache : ' + orgPartGetToken.get(EXPIRY_TIME_TEXT));

                if( System.now().addHours(7) >= (Datetime)(orgPartGetToken.get(EXPIRY_TIME_TEXT)) || orgPartGetToken.get(ACCESS_TOKEN_TEXT) == '' || orgPartGetToken.get(ACCESS_TOKEN_TEXT) == null){
                    System.debug('Token has expired --> get new token');

                    logstartTime = Datetime.now();

                    AuthenticationToken authenTokenCalculateTools = SmartBDM_Service.startCallGetTokenService(namedCredentials);
                    
                    logendTime = Datetime.now();

                    if( (String)orgPartGetToken.get(ACCESS_TOKEN_TEXT) == authenTokenCalculateTools.access_token ){
                        System.debug('New token same as token in cache');
                        Datetime expTimeFrCacheDT = (DateTime)(orgPartGetToken.get(EXPIRY_TIME_TEXT));
                        System.debug('Get expiry time from cache : ' + expTimeFrCacheDT);

                        String oslog = orgPartGetToken.get('onlineServiceLogGateWay') + '';
                        OnlineServiceLog osl = (OnlineServiceLog)JSON.deserialize(oslog, OnlineServiceLog.class);

                        logIsSuccess = true;
                        logserviceName = 'BATCH_GET_TOKEN_FROM_CACHE';
                        logstartTime = Datetime.now();
                        logendTime = Datetime.now();
                        diffTimeSec = ((expTimeFrCacheDT.getTime() - System.now().addHours(7).getTime())/1000);

                        logremark = 'Get-token request(Token in cache is the same as new from WS.):::' 
                                    + '\nPlatform cache name: ' + orgPartGetToken.getName()
                                    + '\nSub-platform cache name: ' + '-'
                                    + '\nJTI: ' + orgPartGetToken.get(JTI_TEXT)
                                    + '\nExpiresin: ' + string.valueOf(diffTimeSec)
                                    + '\nCall Time: ' + osl.startTime + '(GMT+7)'
                                    + '\nExpiry Time: ' + string.valueOfGMT(expTimeFrCacheDT) + '(GMT+7)';

                        ManageAPIGWTokenSchedulerUtil.setupScheduleDT((System.now().addHours(7).addSeconds(addSeconds)));
                    }else{
                        System.debug('ManageAPIGWTokenQueue | get new token gate way : ' + authenTokenCalculateTools.access_token);

                        String expTimeFrToken = pdpaCalloutUtil.getExpiryDateTimeFromToken(authenTokenCalculateTools.access_token);
                        Datetime expTimeFrTokenDT = Datetime.valueOfGmt(expTimeFrToken).addHours(7);

                        System.debug('Get expiry time from token : ' + expTimeFrTokenDT);

                        orgPartGetToken.put(ACCESS_TOKEN_TEXT, authenTokenCalculateTools.access_token, Cache.Visibility.ALL);
                        orgPartGetToken.put(EXPIRES_IN_TEXT, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL);
                        orgPartGetToken.put(EXPIRY_TIME_TEXT, expTimeFrTokenDT, Cache.Visibility.ALL);
                        orgPartGetToken.put(TOKEN_TYPE_TEXT, authenTokenCalculateTools.token_type, Cache.Visibility.ALL);
                        orgPartGetToken.put(SCOPE_TEXT, authenTokenCalculateTools.scope, Cache.Visibility.ALL);
                        orgPartGetToken.put(JTI_TEXT, authenTokenCalculateTools.jti, Cache.Visibility.ALL);
                        orgPartGetToken.put(CLIENT_ID_TEXT, authenTokenCalculateTools.client_id, Cache.Visibility.ALL);
                        orgPartGetToken.put(VERSION_TEXT, authenTokenCalculateTools.version, Cache.Visibility.ALL);
            
                        OnlineServiceLog onlineServiceLogGateWay = new OnlineServiceLog(authenTokenCalculateTools.isSuccess, authenTokenCalculateTools.errorMessage, authenTokenCalculateTools.requestBody, authenTokenCalculateTools.responseBody, logstartTime.addHours(7), logendTime.addHours(7));

                        orgPartGetToken.put('onlineServiceLogGateWay', onlineServiceLogGateWay.parseToJson(), Cache.Visibility.ALL);

                        logIsSuccess = authenTokenCalculateTools.isSuccess;
                        logserviceName = 'BATCH_GET_TOKEN_FROM_SERVICE';
                        logrequestBody = authenTokenCalculateTools.requestBody;
                        logresponseBody = authenTokenCalculateTools.responseBody;
                    
                        logremark = 'Get-token request (Renew):::' 
                                    + '\nPlatform cache name: ' + orgPartGetToken.getName()
                                    + '\nSub-platform cache name: ' + '-'
                                    + '\nJTI: ' + authenTokenCalculateTools.jti
                                    + '\nExpiresin: ' + authenTokenCalculateTools.expires_in
                                    + '\nCall Time: ' + onlineServiceLogGateWay.startTime + '(GMT+7)'
                                    + '\nExpiry Time: ' + expTimeFrTokenDT + '(GMT+7)';
            

                        diffTimeSec = ((expTimeFrTokenDT.getTime() - System.now().addHours(7).getTime())/1000);
        
                        if(diffTimeSec > manageTokenQueueIntervalSec) {
                            System.debug('Expired time more than '+manageTokenQueueIntervalSec+' sec');
                            ManageAPIGWTokenSchedulerUtil.setupScheduleDT(System.now().addHours(7).addSeconds(manageTokenQueueIntervalSec)); // next schedule
                        } else {
                            System.debug('Expired time less than '+manageTokenQueueIntervalSec+' sec');
                            ManageAPIGWTokenSchedulerUtil.setupScheduleDT(expTimeFrTokenDT.addSeconds(1)); // next schedule
                        }
                        // ManageAPIGWTokenSchedulerUtil.setupScheduleDT(expTimeFrTokenDT.addSeconds(1));
                    }

                    // add new code here
                }else{
                    System.debug('Token is not expired yet.');
                    Datetime expTimeFrCacheDT = (DateTime)(orgPartGetToken.get(EXPIRY_TIME_TEXT));
                    System.debug('Get expiry time from cache : ' + expTimeFrCacheDT);

                    String oslog = orgPartGetToken.get('onlineServiceLogGateWay') + '';
                    OnlineServiceLog osl = (OnlineServiceLog)JSON.deserialize(oslog, OnlineServiceLog.class);

                    String startcallTime = osl != null ? string.valueOfGmt(osl.startTime) : '';

                    logIsSuccess = true;
                    logserviceName = 'BATCH_GET_TOKEN_FROM_CACHE';
                    logstartTime = Datetime.now();
                    logendTime = Datetime.now();

                    diffTimeSec = ((expTimeFrCacheDT.getTime() - System.now().addHours(7).getTime())/1000);
                    // diffTimeMin = diffTimeSec/60;

                    logremark = 'Get-token request(Token is not expired):::' 
                                + '\nPlatform cache name: ' + orgPartGetToken.getName()
                                + '\nSub-platform cache name: ' + '-'
                                + '\nJTI: ' + orgPartGetToken.get(JTI_TEXT)
                                + '\nExpiresin: ' + string.valueOf(diffTimeSec)
                                + '\nCall Time: ' + startcallTime + '(GMT+7)'
                                + '\nExpiry Time: ' + string.valueOfGMT(expTimeFrCacheDT) + '(GMT+7)';

                    // Long currentDTLong = DateTime.now().getTime();
                    
                    if(diffTimeSec > manageTokenQueueIntervalSec) {
                        System.debug('Expired time more than '+manageTokenQueueIntervalSec+' sec');
                        ManageAPIGWTokenSchedulerUtil.setupScheduleDT(System.now().addHours(7).addSeconds(manageTokenQueueIntervalSec)); // next schedule
                    } else {
                        System.debug('Expired time less than '+manageTokenQueueIntervalSec+' sec');
                        ManageAPIGWTokenSchedulerUtil.setupScheduleDT(expTimeFrCacheDT.addSeconds(1)); // next schedule
                    }
                    // ManageAPIGWTokenSchedulerUtil.setupScheduleDT((System.now().addHours(7).addSeconds(addSeconds)));
                }
            }else{
                System.debug('Get new token (first time)');

                logstartTime = Datetime.now();

                AuthenticationToken authenTokenCalculateTools = SmartBDM_Service.startCallGetTokenService(namedCredentials);
                
                logendTime = Datetime.now();

                System.debug('ManageAPIGWTokenQueue | get token gate way : ' + authenTokenCalculateTools.access_token);
    
                String expTimeFrToken = pdpaCalloutUtil.getExpiryDateTimeFromToken(authenTokenCalculateTools.access_token);
                Datetime expTimeFrTokenDT = Datetime.valueOfGmt(expTimeFrToken).addHours(7);

                if(Test.isRunningTest()) expTimeFrTokenDT = Datetime.now().addSeconds(Integer.valueOf(AppConfig__c.getValues('TESTGETTOKENADDSECONDS').Value__c));

                System.debug('Get expiry time from token : ' + expTimeFrTokenDT);
    
                orgPartGetToken.put(ACCESS_TOKEN_TEXT, authenTokenCalculateTools.access_token, Cache.Visibility.ALL);
                orgPartGetToken.put(EXPIRES_IN_TEXT, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL);
                orgPartGetToken.put(EXPIRY_TIME_TEXT, expTimeFrTokenDT, Cache.Visibility.ALL);
                orgPartGetToken.put(TOKEN_TYPE_TEXT, authenTokenCalculateTools.token_type, Cache.Visibility.ALL);
                orgPartGetToken.put(SCOPE_TEXT, authenTokenCalculateTools.scope, Cache.Visibility.ALL);
                orgPartGetToken.put(JTI_TEXT, authenTokenCalculateTools.jti, Cache.Visibility.ALL);
                orgPartGetToken.put(CLIENT_ID_TEXT, authenTokenCalculateTools.client_id, Cache.Visibility.ALL);
                orgPartGetToken.put(VERSION_TEXT, authenTokenCalculateTools.version, Cache.Visibility.ALL);
    
                OnlineServiceLog onlineServiceLogGateWay = new OnlineServiceLog(authenTokenCalculateTools.isSuccess, authenTokenCalculateTools.errorMessage, authenTokenCalculateTools.requestBody, authenTokenCalculateTools.responseBody, logstartTime.addHours(7), logendTime.addHours(7));
                orgPartGetToken.put('onlineServiceLogGateWay', onlineServiceLogGateWay.parseToJson(), Cache.Visibility.ALL);

                logIsSuccess = authenTokenCalculateTools.isSuccess;
                logserviceName = 'BATCH_GET_TOKEN_FROM_SERVICE';
                logrequestBody = authenTokenCalculateTools.requestBody;
                logresponseBody = authenTokenCalculateTools.responseBody;
            
                logremark = 'Get-token request (New):::' 
                            + '\nPlatform cache name: ' + orgPartGetToken.getName()
                            + '\nSub-platform cache name: ' + '-'
                            + '\nJTI: ' + authenTokenCalculateTools.jti
                            + '\nExpiresin: ' + authenTokenCalculateTools.expires_in
                            + '\nCall Time: ' + onlineServiceLogGateWay.startTime + '(GMT+7)'
                            + '\nExpiry Time: ' + expTimeFrTokenDT + '(GMT+7)';
            
                // ManageAPIGWTokenSchedulerUtil.setupScheduleDT(expTimeFrTokenDT.addSeconds(1));
                // ManageAPIGWTokenSchedulerUtil.setupScheduleDT(expTimeFrTokenDT.addSeconds(1));

                diffTimeSec = ((expTimeFrTokenDT.getTime() - System.now().addHours(7).getTime())/1000);
        
                if(diffTimeSec > manageTokenQueueIntervalSec) {
                    System.debug('Expired time more than '+manageTokenQueueIntervalSec+' sec');
                    ManageAPIGWTokenSchedulerUtil.setupScheduleDT(System.now().addHours(7).addSeconds(manageTokenQueueIntervalSec)); // next schedule
                } else {
                    System.debug('Expired time less than '+manageTokenQueueIntervalSec+' sec');
                    ManageAPIGWTokenSchedulerUtil.setupScheduleDT(expTimeFrTokenDT.addSeconds(1)); // next schedule
                }

            }
        } catch (Exception e) {
            System.debug('catch access : ' + e.getMessage());
            System.debug('catch access : ' + e.getStackTraceString());
            
            Datetime expTimeFrCacheDT = (DateTime)(orgPartGetToken.get(EXPIRY_TIME_TEXT));
            String oslog = orgPartGetToken.get('onlineServiceLogGateWay')+'';
            OnlineServiceLog osl = (OnlineServiceLog)JSON.deserialize(oslog, OnlineServiceLog.class);

            String startcallTime = osl != null ? string.valueOfGmt(osl.startTime) : '';

            logserviceName = 'ERROR_BATCH_GET_TOKEN_FROM_CACHE';

            logremark = 'Get-token request ERROR !! :::' 
                        + '\nPlatform cache name: ' + orgPartGetToken.getName()
                        + '\nSub-platform cache name: ' + '-'
                        + '\nJTI: ' + orgPartGetToken.get(JTI_TEXT)
                        + '\nExpiresin: ' + orgPartGetToken.get(EXPIRES_IN_TEXT)
                        + '\nCall Time: ' + startcallTime + '(GMT+7)'
                        + '\nExpiry Time: ' + string.valueOfGmt(expTimeFrCacheDT) + '(GMT+7)'
                        + '\n---------------------- Exception ----------------------'
                        + '\n' + e.getMessage() 
                        + '\n' + e.getStackTraceString();
            
            ManageAPIGWTokenSchedulerUtil.setupScheduleDT(System.now().addHours(7).addSeconds(addSeconds));
        }

        RTL_CampaignUtil.saveToOnlineLog(logIsSuccess, logCustomerName, logErrorMessage, logmsLogId, loguserName, logrmId, logserviceName, logrequestBody, logresponseBody, logacc, logstartTime, logendTime, logremark);
    }
}