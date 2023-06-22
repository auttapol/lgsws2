global without sharing class RestfulServiceUtil implements Database.Batchable<sObject>
                                            , Database.Stateful
                                            , Database.AllowsCallouts {
    private final String query;
    private String JOB_NAME;
    
    private Integration_Info__c intInfo;
    private List<Sobject> FORUPDATE_SOBJLIST = new List<Sobject>();
   
    private Integer RETRY_COUNT     = 0;
    private Integer MAX_RETRY_COUNT = 3;
    private String  IntegrationName;
    private Datetime startDatetime = Datetime.now();
    private Integer recordsSuccessful = 0;
    private Integer recordsFailed = 0;

    private EIMManager manager = null;
    private String MAXRETRY_LOG = 'MAXRETRY_LOG';
    private String ERROR_INTEGRATION_LOG = 'ERROR_EXTWS_LOG';
    private String SUCCESS_INTEGRATION_LOG = 'SUCCESS_EXTWS_LOG';
    private String SUCCESS_BULK_LOG = 'SUCCESS_BULK_LOG';
    private String NO_CALLOUT_LOG = 'NO_CALLOUT_LOG';
    private Boolean isRetryCallout = false;
    private String ACCOUNT_ID_FIELD = null;
    private String REF_NAME_FIELD   = null;


    private List<RTL_Online_Service_Log__c> LogList = new List<RTL_Online_Service_Log__c>();

    private Map<Id, List<ContentVersion>> filesAttachMap 
                    = new Map<Id, List<ContentVersion>>();

    private List<Sobject> SobjList = new List<SObject>();
    private RestfulServiceUtil.ValueMapBase valueExecuter;

    private Boolean IS_API_GATEWAY = false;
    private DailyScheduleBatch DAILY_BATCH;
    private APICallInterface APICALL_HANDLER = null;
    private String STATUS_API_CALL;

    private Boolean IS_SHOW_SQL = false;
    private Boolean IS_EMAIL_SUM_SENT = false;
    private String  QUERY_SQL;
    private String  OBJECTNAME = null;
    private List<String> emailOpsList = new List<String>(); 

    private String CSV_LOG_SUCCESS = '';
    private String CSV_BODY = '';

    private String MAINERR_HEADER      = 'RecordId,ErrorMessage,ErrorOnFields,StatusCode\n';
    private String SUCCESSLOG_HEAEDER  = 'RecordId,Description\n';

    private IntegrationMapHandler INTEGRATION_HANDLER = null;

    public void setValueMapImpl(RestfulServiceUtil.ValueMapBase valueExecImpl) {
        this.valueExecuter = valueExecImpl;
    }

    public virtual class ValueMapBase {
        public virtual 
            Map<String,String> prepareValueMap(SObject sobj,EIMManager manager){ return new Map<String, String>();}


        public virtual 
            Boolean isErrorNotCallout(Map<String,String> valueMap){ return false;}
    } 
        
    private void init_process(Sobject sobj,Map<String,String> valueMap){
        setIntegrationInfo(this.IntegrationName);
        this.manager.getBodyRequest(valueMap,intInfo.Request_Format__c);

        Boolean ret = true;

        if (this.valueExecuter != null) 
            ret = this.valueExecuter.isErrorNotCallout(valueMap);

        if (!ret) {
            this.callout(sobj); 
        }else {
            //insert log
            String requestBody = JSON.serialize(sobj);
            addIntegrationLog(startDatetime
                                ,DateTime.now()
                                //,this.objectId
                                ,sobj
                                ,NO_CALLOUT_LOG
                                ,ERROR_INTEGRATION_LOG
                                ,false
                                ,requestBody
                                ,''
                                ,'');
        }
    }

    private void init_process(Sobject sobj){
        setIntegrationInfo(this.IntegrationName);
        this.manager.getBodyRequest(sobj,intInfo.Request_Format__c);
        this.callout(sobj);
    }

    global RestfulServiceUtil(String q,String integrationName){
         if (q.toLowerCase().contains('where')) query = q+' AND Is_Exectued__c = false';
        else query = q+' WHERE Is_Exectued__c = false';

        this.IntegrationName = integrationName;
        //this.manager = new EIMManager(this.IntegrationName);
    }

    global RestfulServiceUtil(String q,String integrationName,String accountField,String refField){
        if (q.toLowerCase().contains('where')) query = q+' AND Is_Exectued__c = false';
        else query = q+' WHERE Is_Exectued__c = false';

        this.IntegrationName = integrationName;
        //this.manager = new EIMManager(this.IntegrationName);
        this.ACCOUNT_ID_FIELD = accountField;
        this.REF_NAME_FIELD  = refField;
    }

    
    public RestfulServiceUtil(   String query
                                ,String integrationName
                                ,Boolean isAPIGateway
                                ,APICallInterface APICall
                                ,Boolean isShowSQL
                                ,Boolean isEmailSumSent
                                ,List<String> emailList
                                ,String accountField
                                ,String refField
                                ,IntegrationMapHandler intHandler
                            ){
        this.IS_API_GATEWAY = isAPIGateway;
        this.query = query;
        //this.DAILY_BATCH = dailyBatch;
        this.IntegrationName = integrationName;
        this.APICALL_HANDLER = APICall;
        this.IS_SHOW_SQL = isShowSQL;
        this.IS_EMAIL_SUM_SENT = isEmailSumSent;
        this.emailOpsList.addAll(emailList);
        this.ACCOUNT_ID_FIELD = accountField;
        this.REF_NAME_FIELD  = refField;

        this.INTEGRATION_HANDLER = intHandler;
    }

    public RestfulServiceUtil(String integrationName
                            ,Boolean isAPIGateway
                            ,DailyScheduleBatch dailyBatch){
        this.IS_API_GATEWAY = isAPIGateway;
        this.DAILY_BATCH = dailyBatch;
        this.IntegrationName = integrationName;
    }

    public RestfulServiceUtil(List<String> IdsLst
                             ,Boolean isAPIGateway
                             ,APICallInterface APICall
                             ,String integrationName
                             ,Boolean isShowSQL
                             ,Boolean isEmailSumSent
                             ,List<String> emailList
                             ,String accountField
                             ,String refField
                             ) {
        this.IS_SHOW_SQL = isShowSQL;
        this.IS_EMAIL_SUM_SENT = isEmailSumSent;
        this.APICALL_HANDLER = APICall;
        this.IS_API_GATEWAY = isAPIGateway;
        this.IntegrationName = integrationName;
        this.emailOpsList.addAll(emailList);

        this.ACCOUNT_ID_FIELD = accountField;
        this.REF_NAME_FIELD  = refField;
        
        String objIds = '(\''+String.join(IdsLst,'\',\'')+'\')';

        String queryForBatch = this.APICALL_HANDLER.getAPIBatchQuery();

        queryForBatch += ' WHERE Id in '+objIds;

        this.query = queryForBatch;

        this.STATUS_API_CALL = this.APICALL_HANDLER.getStatusForAPICall();
    }

    global RestfulServiceUtil(String integrationName,String accountField,String refField){
        this.IntegrationName = integrationName;
        this.ACCOUNT_ID_FIELD = accountField;
        this.REF_NAME_FIELD  = refField;
    }

    private void setIntegrationInfo(String integrationName) {
        //Query Integration_Info__c
        intInfo = [SELECT Id,Name,Endpoint__c,Timeout__c,Request_Format__c,Response_Format__c 
                    FROM Integration_Info__c 
                   WHERE Name =: integrationName]; 
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        if (this.IS_SHOW_SQL) this.QUERY_SQL = this.query;
        return Database.getQueryLocator(this.query);
    }

    global void execute(Database.BatchableContext bc, List<Sobject> scope){
        this.manager = new EIMManager(this.IntegrationName);
        for (Sobject sobj : scope) {
            try {
                 Map<String,String> valueMap = null;


                if (this.valueExecuter != null) 
                        this.valueExecuter.prepareValueMap(sobj,this.manager);
                
                if (valueMap == null || valueMap.isEmpty()) {
                    init_process(sobj);
                }else {
                    init_process(sobj,valueMap);
                }
            }catch(Exception e) {
                addIntegrationLog(startDatetime
                                    ,DateTime.now()
                                    //,this.objectId
                                    ,sobj
                                    ,e.getMessage()+ ' '+e.getStackTraceString()
                                    ,ERROR_INTEGRATION_LOG
                                    ,false
                                    ,''
                                    ,''
                                    ,'');
            }
        }
    }  

    global void finish(Database.BatchableContext bc){
        this.finish_job();
    }

    public void finish_job() {
        
        if (!this.FORUPDATE_SOBJLIST.isEmpty()) {
            Integer runningIndex = 0;
            Database.SaveResult[]  lsr = Database.update(this.FORUPDATE_SOBJLIST
                                                        , false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully Update '
                                +' with ID: ' 
                                + sr.getId());
                }else {
                    // Operation failed, so get all errors                
                    //Id recordId = this.FORUPDATE_SOBJLIST.get(runningIndex).Id;
                    Sobject sobj = this.FORUPDATE_SOBJLIST.get(runningIndex);
                    for(Database.Error err : sr.getErrors()) {
                            String detail =  err.getMessage() + ','
                                                +String.join(err.getFields(),',') + ','
                                                +err.getStatusCode()+'\n';

                            addIntegrationLog(startDatetime
                                              ,DateTime.now()
                                              ,sobj
                                              ,detail
                                              ,ERROR_INTEGRATION_LOG
                                              ,false
                                              ,''
                                              ,''
                                              ,'');
                    }
                }
              runningIndex++;
            } 
        }
        
        //for APICAllInterface
        if (this.APICALL_HANDLER != null) {
            this.APICALL_HANDLER.done_job();
        }

        //Send Email
        if (this.IS_EMAIL_SUM_SENT) {
            this.emailOpsList.add('CRM Admin 2');
            String emailTitle = this.integrationName;

            if (this.STATUS_API_CALL != null && this.STATUS_API_CALL.length() > 0) {
                emailTitle += '_'+this.STATUS_API_CALL;
            }

            if (this.CSV_BODY != null && this.CSV_BODY.length() < 50000) {
                this.CSV_BODY = this.CSV_BODY.replaceAll(' ',RTL_ReportUtility.DELIMETER_FOR_REPORT);
            }

            RTL_BatchEmailService.SendFinishDailyBatchSummaryEmail(startDatetime
                                                        , startDatetime
                                                        , Datetime.now()
                                                        , recordsSuccessful
                                                        , recordsFailed
                                                        , emailTitle
                                                        , this.OBJECTNAME
                                                        , this.emailOpsList
                                                        , this.CSV_BODY
                                                        , ''
                                                        , this.CSV_LOG_SUCCESS
                                                        , this.MAINERR_HEADER
                                                        , ''
                                                        , this.SUCCESSLOG_HEAEDER
                                                        , this.QUERY_SQL
                                                        );
        }

        List<ContentVersion> allcvList = new List<ContentVersion>();    
        List<ContentDocumentLink> allcdList = new List<ContentDocumentLink>();
        List<ContentDocumentLink> removeCDList = new List<ContentDocumentLink>();

        if (!this.LogList.isEmpty()) {
            insert this.LogList;
            for (RTL_Online_Service_Log__c log : this.LogList) {
                List<ContentVersion> cvList
                                        = filesAttachMap.get(log.RTL_RM_ID__c); 

                allcvList.addAll(cvList);
            }

            Savepoint sp = Database.setSavepoint();

            try
            {
                if (allcvList.size() > 0) {
                    insert allcvList;

                    Map<Id,Id> cvLogIdMap = new Map<Id,Id>();
                    
                    for (RTL_Online_Service_Log__c log : this.LogList) {
                        List<ContentVersion> cvList = filesAttachMap.get(log.RTL_RM_ID__c);
                        for (ContentVersion cv : cvList) {
                            cvLogIdMap.put(cv.Id,log.Id);
                        }
                    }

                    OnlineServiceLogUtils.GenerateContentDocumentLink(cvLogIdMap
                                                                    ,allcdList
                                                                    ,removeCDList
                                                                    );
                    if (allcdList.size() > 0)    insert allcdList;
                    if (removeCDList.size() > 0) delete removeCDList;
                }
            }catch(Exception e){
                System.debug(e.getMessage());
                Database.rollback(sp);
            }
            
        }else if (this.INTEGRATION_HANDLER != null && this.INTEGRATION_HANDLER.isLogOnlyBulkSuccess()) {
            RTL_Online_Service_Log__c logBulkSuccess = doInsertSuccessBulkLog();
            
            List<ContentVersion> cvList = filesAttachMap.get(logBulkSuccess.Id); 
            
            Savepoint sp = Database.setSavepoint();

            try
            {
                if (cvList.size() > 0) {
                    insert cvList;

                    Map<Id,Id> cvLogIdMap = new Map<Id,Id>();
                    for (ContentVersion cv : cvList) {
                        cvLogIdMap.put(cv.Id,logBulkSuccess.Id);
                    }
                    
                    OnlineServiceLogUtils.GenerateContentDocumentLink(cvLogIdMap
                                                                    ,allcdList
                                                                    ,removeCDList
                                                                    );
                    if (allcdList.size() > 0)    insert allcdList;
                    if (removeCDList.size() > 0) delete removeCDList;
                }
            }catch(Exception e){
                System.debug(e.getMessage());
                Database.rollback(sp);
            }
            
        }
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

            //Check call for API Gate Way
            if (this.IS_API_GATEWAY) {
                //call token
                           
                String requestWS = this.APICALL_HANDLER.createRequestWS(sobj
                                                                            ,this.STATUS_API_CALL
                                                                            ,this.manager.getBodyRequestMap()
                                                                            );
                //for error log
                requestBody = requestWS;
                //for error log

                //AuthenticationToken authenTokenCalculateTools = APIGateway_Service.startCallGetTokenService('Create_API_GateWay_Token');
                //authenTokenCalculateTools.access_token
                String access_token = APIGateway_Service.getAccessToken(this.APICALL_HANDLER.getTokenEndpoint()
                                                                        ,this.IntegrationName.replaceAll('_','')
                                                                        );

                if (this.OBJECTNAME == null) {
                    this.OBJECTNAME = sobj.Id.getSObjectType().getDescribe().getName();
                }

                responseBody = APIGateway_Service.postData(access_token
                                                                ,this.IntegrationName
                                                                ,requestWS
                                                                ,TIMEOUT_INT_MILLISECS
                                                                ,req);

                endpoint = req.getEndpoint();
                String statusAPICALL = '';

                if (this.STATUS_API_CALL != null) {
                    statusAPICALL = 'Status API Call '
                                     + this.STATUS_API_CALL;
                }

                Map<String,String>  resMap = this.APICALL_HANDLER.getCustomizedResponse(responseBody);

                if (resMap == null) {
                    resMap = this.manager.getResponseInfo(responseBody,intInfo.Response_Format__c);
                }
                            

                Boolean isResultFromWS = this.APICALL_HANDLER.getIntegrationResult(resMap);
                String egLog = sobj.Id +'_'+startDatetime.getTime();
                
                if (this.APICALL_HANDLER.isUpdateMainObj() && isResultFromWS) {
                    this.APICALL_HANDLER.updateResponseWS(sobj,this.STATUS_API_CALL,resMap);
                    addIntegrationLog(startDatetime
                                    ,DateTime.now()
                                    ,sobj
                                    ,String.valueOf(requestWS)
                                        +' '+responseBody
                                        +' '+statusAPICALL
                                        +' '+endpoint
                                    ,SUCCESS_INTEGRATION_LOG
                                    ,isResultFromWS
                                    ,String.valueOf(requestWS)
                                    ,responseBody
                                    ,egLog);

                    
                    this.FORUPDATE_SOBJLIST.add(sobj);
                }else if (isResultFromWS){
                    addIntegrationLog(startDatetime
                                    ,DateTime.now()
                                    ,sobj
                                    ,String.valueOf(requestWS)
                                        +' '+responseBody
                                        +' '+statusAPICALL
                                        +' '+endpoint
                                    ,SUCCESS_INTEGRATION_LOG
                                    ,isResultFromWS
                                    ,String.valueOf(requestWS)
                                    ,responseBody
                                    ,egLog);
                }else {
                    addIntegrationLog(startDatetime
                                    ,DateTime.now()
                                    ,sobj
                                    ,String.valueOf(requestWS)
                                        +' '+responseBody
                                        +' '+statusAPICALL
                                        +' '+endpoint
                                    ,ERROR_INTEGRATION_LOG
                                    ,isResultFromWS
                                    ,String.valueOf(requestWS)
                                    ,responseBody
                                    ,egLog);
                }

            }else {
                endpoint = intInfo.Endpoint__c;
                    
                req.setEndpoint(endpoint);
                req.setTimeout(TIMEOUT_INT_MILLISECS);
                req.setMethod('POST');
                req.setHeader('Content-Type',intInfo.Request_Format__c);

                String egLog = sobj.Id +'_'+startDatetime.getTime();
                req.setHeader('From',egLog);

                req.setBody(requestBody);

                Http http = new Http();
                HTTPResponse res = http.send(req);
                responseBody = res.getBody();

                Map<String,Object>  RET_MAP = this.manager.getResponseInfo(responseBody, intInfo.Response_Format__c);
                    
                if (sobj != null && !RET_MAP.isEmpty()) {

                    for (String key : RET_MAP.keySet()) {
                        sobj.put(key, RET_MAP.get(key));
                    }

                    sobj.put('Is_Exectued__c', true);

                    this.FORUPDATE_SOBJLIST.add(sobj);

                    if (this.manager.isIntegrationSuccess) {
                        addIntegrationLog(startDatetime
                                      ,DateTime.now()
                                      //,this.objectId
                                      ,sobj
                                      ,SUCCESS_INTEGRATION_LOG+' '+endpoint 
                                      ,SUCCESS_INTEGRATION_LOG
                                      ,this.manager.isIntegrationSuccess
                                      ,requestBody
                                      ,responseBody
                                      ,egLog);

                            return this.manager.isIntegrationSuccess;
                        }        
                }

                addIntegrationLog(startDatetime
                                      ,DateTime.now()
                                      //,this.objectId
                                      ,sobj
                                      ,ERROR_INTEGRATION_LOG+' '+endpoint
                                      ,ERROR_INTEGRATION_LOG
                                      ,false
                                      ,requestBody
                                      ,responseBody
                                      ,egLog);
            }
            return false;
        }catch(Exception e) {
            System.debug(e.getStackTraceString());
           if (e.getMessage().equalsIgnoreCase('Read timed out')) {
                if (!isRetry(sobj)) {
                    addIntegrationLog(startDatetime
                                ,DateTime.now()
                                //,this.objectId
                                ,sobj
                                ,requestBody+ ' '+endpoint
                                ,MAXRETRY_LOG
                                ,false
                                ,requestBody
                                ,responseBody
                                ,sobj.Id +'_'+startDatetime.getTime());
                }
            }else {
                addIntegrationLog(startDatetime
                                ,DateTime.now()
                                //,this.objectId
                                ,sobj
                                ,e.getMessage()+ ' '+e.getStackTraceString()+ ' '+endpoint
                                ,ERROR_INTEGRATION_LOG
                                ,false
                                ,requestBody
                                ,responseBody
                                ,sobj.Id +'_'+startDatetime.getTime());
            }
            return false;
        }
    }

    public void runBatch() {
        Id BatchProcessIdForInt = Database.ExecuteBatch(this,90);
    }

    private List<String> requestBodyLst  = new List<String>();
    private List<String> responseBodyLst = new List<String>();

    private RTL_Online_Service_Log__c doInsertSuccessBulkLog() {
        RTL_Online_Service_Log__c inlog = new RTL_Online_Service_Log__c ();
        inlog.RTL_Name_of_User__c = UserInfo.getName();
        inlog.Online_Batch_Log__c = SUCCESS_BULK_LOG;
        inlog.RTL_Error_Message__c = SUCCESS_BULK_LOG;
        inlog.RTL_Start_DateTime__c = startDatetime;      
        inlog.RTL_End_DateTime__c   = Datetime.now();
        inlog.RTL_Service_Name__c   = this.IntegrationName;
        inlog.RTL_Is_Success__c     = true;
        
        insert inlog;
        
        List<ContentVersion> cvList = new List<ContentVersion>();

        if(requestBodyLst.size() > 0) { 
            Integer countRow  = 0;
            Integer fileIndex = 1;

            String reqBodyContent = '';
            for (String reqBody : requestBodyLst) {
                reqBodyContent += reqBody + '\n';
                if (countRow == 1000) {
                    OnlineServiceLogUtils.GenerateContentVersions (
                                                    'requestBodySuccessBulk_'+fileIndex+'.txt'
                                                            ,reqBodyContent
                                                            ,cvList);

                    countRow  = 0;
                    fileIndex++;
                    reqBodyContent = '';
                }else {
                    countRow++;
                }
            }

            OnlineServiceLogUtils.GenerateContentVersions ('requestBodySuccessBulk_'+fileIndex+'.txt'
                                                            ,reqBodyContent
                                                            ,cvList);
        }

        if(responseBodyLst.size() > 0) { 
            Integer countRow  = 0;
            Integer fileIndex = 1;

            String resBodyContent = '';
            for (String resBody : responseBodyLst) {
                resBodyContent += resBody + '\n';
                if (countRow == 1000) {
                    OnlineServiceLogUtils.GenerateContentVersions ('responseBodySuccessBulk_'+fileIndex+'.txt'
                                                            ,resBodyContent
                                                            ,cvList);

                    countRow  = 0;
                    fileIndex++;
                    resBodyContent = '';
                }else {
                    countRow++;
                }
            }

            OnlineServiceLogUtils.GenerateContentVersions ('responseBodySuccessBulk_'+fileIndex+'.txt'
                                                            ,resBodyContent
                                                            ,cvList);
            
        }


        filesAttachMap.put(inlog.Id,cvList);

        return inlog;
    }
    
    private Map<Id,List<Attachment>> bodyAttMap     = new Map<Id,List<Attachment>>();

    private void addIntegrationLog(DateTime startDatetime
                                  ,DateTime endDatetime
                                  ,Sobject sobj
                                  ,String errorMessages
                                  ,String logType
                                  ,Boolean isRet
                                  ,String requestBody
                                  ,String responseBody
                                  ,String egLog) {

        if (this.INTEGRATION_HANDLER != null && this.INTEGRATION_HANDLER.isLogOnlyBulkSuccess()) {
            requestBodyLst.add(requestBody);
            responseBodyLst.add(responseBody);
        }else {
            RTL_Online_Service_Log__c inlog = new RTL_Online_Service_Log__c ();
            inlog.RTL_Name_of_User__c = UserInfo.getName();
            inlog.RTL_RM_ID__c = sobj.Id;
            inlog.Online_Batch_Log__c = logType;
            inlog.RTL_Error_Message__c = errorMessages;
            inlog.RTL_Start_DateTime__c = startDatetime;      
            inlog.RTL_End_DateTime__c   = endDatetime;
            inlog.RTL_Service_Name__c   = this.IntegrationName;
            inlog.RTL_Is_Success__c     = isRet;
            inlog.RTL_Mulesoft_Log_Id__c = egLog;
            
            if (this.ACCOUNT_ID_FIELD != null  && this.ACCOUNT_ID_FIELD.length() > 0) {
                if (this.ACCOUNT_ID_FIELD.contains('.')) {
                    List<String> sffieldList = this.ACCOUNT_ID_FIELD.split('\\.');
                    SObject tempSobj = null;

                    for (Integer i=0;i<sffieldList.size()-1;i++) {
                        if (tempSobj == null) {
                            tempSobj =  sobj.getSobject(sffieldList.get(i));
                        }else {
                            tempSobj =  tempSobj.getSobject(sffieldList.get(i));
                        }
                            
                    }  

                    if (tempSobj != null) {
                        String value = String.valueof(tempSobj.get(sffieldList.get(sffieldList.size()-1)));
                        inlog.RTL_Account__c =  Id.valueOf(value);
                   }
                }else if(sobj.get(this.ACCOUNT_ID_FIELD) != null) {
                    inlog.RTL_Account__c = Id.valueOf((String)sobj.get(this.ACCOUNT_ID_FIELD));
                }
            }

            if (this.REF_NAME_FIELD != null && this.REF_NAME_FIELD.length() > 0) {
                if (this.REF_NAME_FIELD.contains('.')) {
                    List<String> sffieldList = this.REF_NAME_FIELD.split('\\.');
                    SObject tempSobj = null;

                    for (Integer i=0;i<sffieldList.size()-1;i++) {
                        if (tempSobj == null) {
                            tempSobj =  sobj.getSobject(sffieldList.get(i));
                        }else {
                            tempSobj =  tempSobj.getSobject(sffieldList.get(i));
                        }
                            
                    }          
                    
                    if (tempSobj != null) {
                        String value = String.valueof(tempSobj.get(sffieldList.get(sffieldList.size()-1)));
                        inlog.RTL_Customer_Name__c = value;
                    }
                }else if(sobj.get(this.REF_NAME_FIELD) != null){
                    inlog.RTL_Customer_Name__c = String.valueof(sobj.get(this.REF_NAME_FIELD));
                }
            }
            
            LogList.add(inlog);

            List<ContentVersion> cvList = new List<ContentVersion>();

            if(!String.isBlank(requestBody)) { 
                OnlineServiceLogUtils.GenerateContentVersions ('requestBody.txt',requestBody,cvList);
            }

            if(!String.isBlank(responseBody)) { 
                OnlineServiceLogUtils.GenerateContentVersions ('responseBody.txt',responseBody,cvList);
            }


            filesAttachMap.put(sobj.Id,cvList);
            //insert content version for file*/
        }

        

        //count record
        if (this.DAILY_BATCH != null) {
            if (isRet) {
                //this info for email notification
                this.DAILY_BATCH.CSV_LOG_SUCCESS 
                                            = this.DAILY_BATCH.CSV_LOG_SUCCESS + 
                                              +sobj.Id
                                              +','
                                              +this.IntegrationName+'_Integrated_Successfully'
                                              +'\n';
                this.DAILY_BATCH.recordsSuccessful++;
            }else {
                //this info for email notification
                this.DAILY_BATCH.CSV_BODY = this.DAILY_BATCH.CSV_BODY
                                                        +sobj.Id 
                                                        + ','
                                                        +errorMessages 
                                                        + ','
                                                        +'' 
                                                        + ','
                                                        +''
                                                        +'\n';

                this.DAILY_BATCH.recordsFailed++;
            }
        }else {
            if (isRet) {
                //this info for email notification
                this.CSV_LOG_SUCCESS = this.CSV_LOG_SUCCESS + 
                                              +sobj.Id 
                                              +','
                                              +this.IntegrationName+'_Integrated_Successfully'
                                              +'\n';
                this.recordsSuccessful++;
            }else {
                //this info for email notification
                this.CSV_BODY = this.CSV_BODY
                                                        +sobj.Id 
                                                        + ','
                                                        +errorMessages 
                                                        + ','
                                                        +'' 
                                                        + ','
                                                        +''
                                                        +'\n';

                this.recordsFailed++;
            }
        }

        //Handle for Exception to update Response WS
        if (!isRet && this.APICALL_HANDLER != null) {
            this.APICALL_HANDLER.updateResponseWS(sobj
                                                  ,this.STATUS_API_CALL
                                                  ,null);

            if (this.APICALL_HANDLER.isUpdateMainObj())
                this.FORUPDATE_SOBJLIST.add(sobj);
        }
    }

}