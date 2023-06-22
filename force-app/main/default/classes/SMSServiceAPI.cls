global without sharing class SMSServiceAPI implements Database.Stateful
                                            , Database.AllowsCallouts {
    private final String query;
    
    private Integration_Info__c intInfo;
   
    private Integer RETRY_COUNT     = 0;
    private Integer MAX_RETRY_COUNT = 3;
    private String  IntegrationName;

    private EIMManager manager = null;
    private Boolean isRetryCallout = false;
    private String ACCOUNT_ID_FIELD = null;
    private String REF_NAME_FIELD   = null;
    private SMSServiceAPI.ValueMapBase valueExecuter;

    private Boolean IS_API_GATEWAY = false;
    private APICallInterface APICALL_HANDLER = null;
    private String STATUS_API_CALL;

    private Boolean IS_SHOW_SQL = false;

    public map<id,String> mapCallResult = new map<id,String>();

    public void setValueMapImpl(SMSServiceAPI.ValueMapBase valueExecImpl) {
        this.valueExecuter = valueExecImpl;
    }

    public virtual class ValueMapBase {
        public virtual 
            Map<String,String> prepareValueMap(SObject sobj,EIMManager manager){ return new Map<String, String>();}


        public virtual 
            Boolean isErrorNotCallout(Map<String,String> valueMap){ return false;}
    } 
    /*    
    private void init_process(Sobject sobj,Map<String,String> valueMap){
        setIntegrationInfo(this.IntegrationName);
        this.manager.getBodyRequest(valueMap,intInfo.Request_Format__c);

        Boolean ret = true;

        if (this.valueExecuter != null) {
            ret = this.valueExecuter.isErrorNotCallout(valueMap);
        }
        if (!ret) {
            this.callout(sobj); 
        }else {
            //Error
            mapCallResult.put(sobj.id, 'Error no valueExecuter');
        }
    }
    */
    private void init_process(Sobject sobj){        
        setIntegrationInfo(this.IntegrationName);
        this.manager.getBodyRequest(sobj,intInfo.Request_Format__c);
        this.callout(sobj);
    }

    public SMSServiceAPI(List<String> IdsLst
                             ,Boolean isAPIGateway
                             ,APICallInterface APICall
                             ,String integrationName
                             ,Boolean isShowSQL
                             ,String accountField
                             ,String refField
                             ) {
        this.IS_SHOW_SQL = isShowSQL;
        this.APICALL_HANDLER = APICall;
        this.IS_API_GATEWAY = isAPIGateway;
        this.IntegrationName = integrationName;

        this.ACCOUNT_ID_FIELD = accountField;
        this.REF_NAME_FIELD  = refField;
        
        String objIds = '(\''+String.join(IdsLst,'\',\'')+'\')';

        String queryForBatch = this.APICALL_HANDLER.getAPIBatchQuery();

        queryForBatch += ' WHERE Id in '+objIds;

        this.query = queryForBatch;

        this.STATUS_API_CALL = this.APICALL_HANDLER.getStatusForAPICall();
    }

    private void setIntegrationInfo(String integrationName) {
        //Query Integration_Info__c
        intInfo = [SELECT Id,Name,Endpoint__c,Timeout__c,Request_Format__c,Response_Format__c 
                    FROM Integration_Info__c 
                   WHERE Name =: integrationName LIMIT 1]; 
    }

    global map<id,String> executeCallOut( List<Sobject> scope){

        this.manager = new EIMManager(this.IntegrationName);
        for (Sobject sobj : scope) {
            try {
                 Map<String,String> valueMap = null;

                if (this.valueExecuter != null) 
                        this.valueExecuter.prepareValueMap(sobj,this.manager);
                
                if (valueMap == null || valueMap.isEmpty()) {
                    init_process(sobj);
                } /*else {
                    init_process(sobj,valueMap);
                } */
            }catch(Exception e) {
   				System.debug('ERROR THIS: '+e.getMessage());
                System.debug('ERROR THIS: '+e.getStackTraceString());
            } 
        }

        return mapCallResult;

    }  

    private Boolean isRetry(SObject sobj) {
        if (this.RETRY_COUNT < this.MAX_RETRY_COUNT) {
            this.RETRY_COUNT = this.RETRY_COUNT + 1;
            this.callout(sobj);
            return true;
        }else {
            return false;
        }
    }

    public Boolean retryCallout(SObject sobj,SObject retailLog,String requestBody) {
        this.IntegrationName = (String)retailLog.get('RTL_Customer_Name__c');
        setIntegrationInfo(this.IntegrationName);
        isRetryCallout = true;
        return this.callout(sobj,requestBody);
    } 

    public Boolean callout(SObject sobj) {
        String requestBody = this.manager.getBodyRequestMap().get(sobj.Id);
        return this.callout(sobj,requestBody);
    }

    public Boolean callout(SObject sobj,String requestBody) {
               
        String endpoint = '';
        String responseBody = '';
        try{
            Integer TIMEOUT_INT_MILLISECS = Integer.valueOf(intInfo.Timeout__c)*1000;
            HttpRequest req = new HttpRequest();

            APIGateway_Service.RequestToken request = new APIGateway_Service.RequestToken();
                request.endpoint = this.IntegrationName; 

            String requestWS = this.APICALL_HANDLER.createRequestWS(sobj
                ,this.STATUS_API_CALL
                ,this.manager.getBodyRequestMap()
                );

            requestBody = requestWS;            

            //Check call for API Gate Way
            if (this.IS_API_GATEWAY) {
                  
                String tokenEndpoint;
                if(this.APICALL_HANDLER.getTokenEndpoint() == null){
                    tokenEndpoint = 'Smart_BDM_Cal_Tools_Create_Token';
                }else{
                    tokenEndpoint = this.APICALL_HANDLER.getTokenEndpoint();
                }
                //call token 
                String access_token = APIGateway_Service.getAccessToken(tokenEndpoint,this.IntegrationName.replaceAll('_',''));

                /*
                AuthenticationToken authenTokenCalculateTools = APIGateway_Service.startCallGetTokenService(this.IntegrationName.replaceAll('_',''));
                String access_token = authenTokenCalculateTools.access_token;
                */

                responseBody = APIGateway_Service.postData(access_token
                                                            ,this.IntegrationName
                                                            ,requestWS
                                                            ,TIMEOUT_INT_MILLISECS
                                                            ,req);

                mapCallResult.put(sobj.id, responseBody);            
            }
            return false;
        }catch(Exception e) {
            System.debug(e.getStackTraceString());
            System.debug('Exception error '+e.getMessage());
            if (Test.isRunningTest()){
                e.setMessage('Read timed out');
            }
           if (e.getMessage().equalsIgnoreCase('Read timed out')) {
                boolean retry = isRetry(sobj);
           }
            return false;
        } 
    }
    
}