public class SmartBDM_Utility {

    private final static Map<String, String> QuickCA_Lead_Stage = new Map<String, String> { 
        '0' => 'NewLead', 
        '1' => 'Contact', 
        '2' => 'AddProduct', 
        '3' => 'Convert', 
        '4' => 'SubmitSLS' 
    };

    private final static Map<String, String> QuickCA_Opportunity_Stage = new Map<String, String> { 
        '0' => 'NewOpportunity', 
        '1' => 'Contact', 
        '2' => 'AddProduct', 
        '3' => 'SubmitSLS'
    };

    @AuraEnabled
    public static void updateLeadStatus(String leadId, String stage)
    {
        try
        {
            Lead ld = new Lead(Id = leadId);
            ld.SmartBDM_QuickCA_ProcessStatus__c = QuickCA_Lead_Stage.get(stage);
            update ld;
        }
        catch(Exception e) 
        {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());           
        }   
    }
    
    @AuraEnabled
    public static void updateOpptyStatus(String opptyId,String stage)
    {
        try
        {
            Opportunity oppty = new Opportunity(Id = opptyId);
            oppty.SmartBDM_QuickCA_ProcessStatus__c = QuickCA_Opportunity_Stage.get(stage);
            update oppty;
        }
        catch(Exception e) 
        {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());           
        }   
    }

    public static String tokenKeyCalculateTools {
        get{
            return (String)Cache.Org.getPartition('local.CreateGateWayToken').get('accesstoken');
        }
    }

    // V1 - Token Gateway for calculate tools only
    public static Cache.OrgPartition orgPartCreateToken(string partitionName, string namedCredentials) {
        Cache.OrgPartition orgPartCreateToken = Cache.Org.getPartition('local.' + partitionName);
        if(orgPartCreateToken.get('accesstoken') == null || orgPartCreateToken.get('accesstoken') == '') {
            Datetime startTime = Datetime.now();
            AuthenticationToken authenTokenCalculateTools = SmartBDM_Service.startCallGetTokenService(namedCredentials);
            Datetime endTime = Datetime.now();
            orgPartCreateToken.put('accesstoken', authenTokenCalculateTools.access_token, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            orgPartCreateToken.put('tokentype', authenTokenCalculateTools.token_type, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            orgPartCreateToken.put('expiresin', authenTokenCalculateTools.expires_in, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            orgPartCreateToken.put('scope', authenTokenCalculateTools.scope, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            orgPartCreateToken.put('jti', authenTokenCalculateTools.jti, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            orgPartCreateToken.put('clientid', authenTokenCalculateTools.client_id, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            orgPartCreateToken.put('version', authenTokenCalculateTools.version, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            
            OnlineServiceLog onlineServiceLogGateWay = new OnlineServiceLog(authenTokenCalculateTools.isSuccess, authenTokenCalculateTools.errorMessage, authenTokenCalculateTools.requestBody, authenTokenCalculateTools.responseBody, startTime, endTime);
            orgPartCreateToken.put('onlineServiceLogGateWay', onlineServiceLogGateWay.parseToJson(), authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
        
            String remark = 'Get-token request:::' 
                        + '\nPlatform cache name: ' + orgPartCreateToken.getName()
                        + '\nSub-platform cache name: ' + '-'
                        //+ '\nToken received: ' + authenTokenCalculateTools.access_token
                        + '\nJTI: ' + authenTokenCalculateTools.jti
                        + '\nExpiresin: ' + authenTokenCalculateTools.expires_in
                        + '\nCall Time: ' + onlineServiceLogGateWay.startTime + '(GMT)'
                        + '\nExpiry Time: ' + pdpaCalloutUtil.getExpiryDateTimeFromToken(authenTokenCalculateTools.access_token)+ '(GMT)';

            RTL_CampaignUtil.remark = remark;
            RTL_CampaignUtil.service = 'GETTOKEN_FROM_SERVICE';
            //RTL_CampaignUtil.saveToOnlineLog(true, '', '', '',  '', '', 'GETTOKEN_FROM_SERVICE', '', '', null,  startTime,  endTime, remark);
        
        }else{
            String js = orgPartCreateToken.get('onlineServiceLogGateWay')+'';
            OnlineServiceLog osl = (OnlineServiceLog)JSON.deserialize(js, OnlineServiceLog.class);
            String remark = 'Get-token request:::' 
                        + '\nPlatform cache name: ' + orgPartCreateToken.getName()
                        + '\nSub-platform cache name: ' + '-'
                        //+ '\nToken received: ' + orgPartCreateToken.get('accesstoken')
                        + '\nJTI: ' + orgPartCreateToken.get('jti')
                        + '\nExpiresin: ' + orgPartCreateToken.get('expiresin')
                        + '\nCall Time: ' + osl.startTime + '(GMT)'
                        + '\nExpiry Time: ' + pdpaCalloutUtil.getExpiryDateTimeFromToken(orgPartCreateToken.get('accesstoken')+'')+ '(GMT)';

            RTL_CampaignUtil.remark = remark;
            RTL_CampaignUtil.service = 'GETTOKEN_FROM_CACHE';
            //RTL_CampaignUtil.saveToOnlineLog(true, '', '', '',  '', '', 'GETTOKEN_FROM_CACHE', '', '', null,  Datetime.now(),  Datetime.now(), remark);
        }
        return orgPartCreateToken;
    }

    public static String getJTI(string partitionName){
        Cache.OrgPartition orgPartCreateToken = Cache.Org.getPartition('local.' + partitionName);
        return orgPartCreateToken.get('jti')+'';
    }

    public static OnlineServiceLog getOnlineServiceLog(string partitionName){
        Cache.OrgPartition orgPartCreateToken = Cache.Org.getPartition('local.' + partitionName);
        String js = orgPartCreateToken.get('onlineServiceLogGateWay')+'';
        OnlineServiceLog onlineServiceLogGateWay = (OnlineServiceLog) System.JSON.deserialize(js, OnlineServiceLog.class);
        return onlineServiceLogGateWay;
    }

    public static String getJTI(string partitionName, string projectKey){
        Cache.OrgPartition orgPartCreateToken = Cache.Org.getPartition('local.' + partitionName);
        return orgPartCreateToken.get(projectKey + 'jti')+'';
    }

    public static OnlineServiceLog getOnlineServiceLog(string partitionName, string projectKey){
        Cache.OrgPartition orgPartCreateToken = Cache.Org.getPartition('local.' + partitionName);
        String js = orgPartCreateToken.get(projectKey + 'onlineServiceLogGateWay')+'';
        OnlineServiceLog osl = (OnlineServiceLog)JSON.deserialize(js, OnlineServiceLog.class);
        return osl;
    }

    // V1 - Token Gateway for calculate tools only
    // V2 - Token Gateway for mapping key another project
    public static Cache.OrgPartition orgPartCreateToken(string partitionName, string namedCredentials, string projectKey) {
        Cache.OrgPartition orgPartCreateToken = Cache.Org.getPartition('local.' + partitionName);
        if(orgPartCreateToken.get(projectKey + 'accesstoken') == null || orgPartCreateToken.get(projectKey + 'accesstoken') == '') {
            Datetime startTime = Datetime.now();
            AuthenticationToken authenTokenCalculateTools = SmartBDM_Service.startCallGetTokenService(namedCredentials);
            Datetime endTime = Datetime.now();
            orgPartCreateToken.put(projectKey + 'accesstoken', authenTokenCalculateTools.access_token, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            orgPartCreateToken.put(projectKey + 'tokentype', authenTokenCalculateTools.token_type, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            orgPartCreateToken.put(projectKey + 'expiresin', authenTokenCalculateTools.expires_in, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            orgPartCreateToken.put(projectKey + 'scope', authenTokenCalculateTools.scope, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            orgPartCreateToken.put(projectKey + 'jti', authenTokenCalculateTools.jti, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            orgPartCreateToken.put(projectKey + 'clientid', authenTokenCalculateTools.client_id, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            orgPartCreateToken.put(projectKey + 'version', authenTokenCalculateTools.version, authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            
            OnlineServiceLog onlineServiceLogGateWay = new OnlineServiceLog(authenTokenCalculateTools.isSuccess, authenTokenCalculateTools.errorMessage, authenTokenCalculateTools.requestBody, authenTokenCalculateTools.responseBody, startTime, endTime);
            orgPartCreateToken.put(projectKey + 'onlineServiceLogGateWay', onlineServiceLogGateWay.parseToJson(), authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
            
            String remark = 'Get-token request:::' 
                        + '\nPlatform cache name: ' + orgPartCreateToken.getName()
                        + '\nSub-platform cache name: ' + projectKey
                        //+ '\nToken received: ' + authenTokenCalculateTools.access_token
                        + '\nJTI: ' + authenTokenCalculateTools.jti
                        + '\nExpiresin: ' + authenTokenCalculateTools.expires_in
                        + '\nCall Time: ' + onlineServiceLogGateWay.startTime + '(GMT)'
                        + '\nExpiry Time: ' + pdpaCalloutUtil.getExpiryDateTimeFromToken(authenTokenCalculateTools.access_token)+ '(GMT)';

            RTL_CampaignUtil.remark = remark;
            RTL_CampaignUtil.service = 'GETTOKEN_FROM_SERVICE';
            //RTL_CampaignUtil.saveToOnlineLog(true, '', '', '',  '', '', 'GETTOKEN_FROM_SERVICE', '', '', null,  startTime,  endTime, remark);
        }else{
            String js = orgPartCreateToken.get(projectKey + 'onlineServiceLogGateWay')+'';
            OnlineServiceLog osl = (OnlineServiceLog)JSON.deserialize(js, OnlineServiceLog.class);
            String remark = 'Get-token request:::' 
                        + '\nPlatform cache name: ' + orgPartCreateToken.getName()
                        + '\nSub-platform cache name: ' + projectKey
                        //+ '\nToken received: ' + orgPartCreateToken.get(projectKey + 'accesstoken')
                        + '\nJTI: ' + orgPartCreateToken.get(projectKey + 'jti')
                        + '\nExpiresin: ' + orgPartCreateToken.get(projectKey + 'expiresin')
                        + '\nCall Time: ' + osl.startTime + '(GMT)'
                        + '\nExpiry Time: ' + pdpaCalloutUtil.getExpiryDateTimeFromToken(orgPartCreateToken.get(projectKey + 'accesstoken')+'')+ '(GMT)';

            RTL_CampaignUtil.remark = remark;
            RTL_CampaignUtil.service = 'GETTOKEN_FROM_CACHE';
            //RTL_CampaignUtil.saveToOnlineLog(true, '', '', '',  '', '', 'GETTOKEN_FROM_CACHE', '', '', null,  Datetime.now(),  Datetime.now(), remark);
        }
        return orgPartCreateToken;
    }

    public static void orgPartCreateOnlineServiceLog(string partitionName, String onlineServiceCacheName, OnlineServiceLog onlineServiceLog) {
        Cache.Org.getPartition('local.' + partitionName).put(onlineServiceCacheName, onlineServiceLog.parseToJson(), Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
    }

    public static OnlineServiceLog onlineServiceLog(String partitionName, String onlineServiceCacheName) {
        return Cache.Org.getPartition('local.' + partitionName).get(onlineServiceCacheName) != null ? (OnlineServiceLog)JSON.deserialize((String)Cache.Org.getPartition('local.' + partitionName).get(onlineServiceCacheName), OnlineServiceLog.class) : null;
    }

    public static String tokenKeyEnliteGateWay {
        get{
            return (String)Cache.Org.getPartition('local.CreateGateWayToken').get('accesstoken');
        }
    }

    

    public static Cache.OrgPartition orgPartCreateTokenEnlite(string partitionName) {
        Cache.OrgPartition orgPartCreateToken = Cache.Org.getPartition('local.' + partitionName);
        if(orgPartCreateToken.get('SmartBDMEnliteToken') == null || orgPartCreateToken.get('SmartBDMEnliteToken') == '') {
            SmartBDM_EnliteService.SmartBDMEnliteTokenWrapper authenTokenEnliteWrapper = SmartBDM_EnliteService.startCallGetTokenService(new SmartBDMEnliteToken.Request(Smart_BDM_Constant.TOKEN_REQUEST_BODY_ENLITE.get('ClientName'), Smart_BDM_Constant.TOKEN_REQUEST_BODY_ENLITE.get('UserName')));
            orgPartCreateToken.put('SmartBDMEnliteToken', authenTokenEnliteWrapper.enliteToken.response.GetTokenResponse != null ? authenTokenEnliteWrapper.enliteToken.response.GetTokenResponse.TokenKey : '', Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
            orgPartCreateToken.put('onlineServiceLogEnliteToken', authenTokenEnliteWrapper.onlineServiceLog.parseToJson(), Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        }
        return orgPartCreateToken;
    }
    
    public static String tokenKeyEnliteRequestBody {
        get{
            return (String)orgPartCreateTokenEnlite('CreateGateWayToken').get('SmartBDMEnliteToken');
        }
    }

    public static void orgPartClearValue(string partitionName, string keyOrgPartition) {
        Cache.Org.getPartition('local.' + partitionName).put(keyOrgPartition, '', Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
    }
}