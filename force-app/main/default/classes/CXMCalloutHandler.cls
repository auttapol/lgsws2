public without sharing class CXMCalloutHandler implements ICalluotSOAPHandler  {
    /**
    *  @author Keattisak
    *  @date 2017-05-22
    *  @description This class used to callout to slos system.
    *
    *   CHANGE HISTORY
    *   ==================================================================
    *   Date            Name                    Description
    *   2017-05-22      Keattisak.C             Created
    */
    
    public static Map<String,RTL_CXM_Config__mdt> mapMetaConf {get{
        Map<String,RTL_CXM_Config__mdt> simList = new Map<String,RTL_CXM_Config__mdt>();
           for( RTL_CXM_Config__mdt conf : [select id,DeveloperName,Value__c from RTL_CXM_Config__mdt ] ){
                simList.put(conf.DeveloperName,conf);
            }
        
        return new Map<String,RTL_CXM_Config__mdt>(simList);
    }set;}
    
    public static Map<String,RTL_CXM_Status_Code__mdt> mapMetaStatusCode {get{
        Map<String,RTL_CXM_Status_Code__mdt> simList = new Map<String,RTL_CXM_Status_Code__mdt>();
        for( RTL_CXM_Status_Code__mdt conf : [select id,Label,Value__c from RTL_CXM_Status_Code__mdt ] ){
            simList.put(conf.Label,conf);
        }        
        return new Map<String,RTL_CXM_Status_Code__mdt>(simList);
    }set;}

    private static String CXM_ENDPOINT_CS {get{
        return [select Value__c from AppConfig__c WHERE NAME = 'CXM_ENDPOINT' LIMIT 1].get(0).Value__c;
    }set;}

    private static User currentUser = [SELECT Id
                                        ,RTL_Branch_Code__c,RTL_Channel__c
                                        ,Employee_Id__c,Zone_Code__c,Region_Code__c 
                                        From User 
                                        Where Id=:Userinfo.getUserId() LIMIT 1];
    
    //Wrapper Class for specific DTO
    public class Task_CXMRequest{        
        public string TaskId {get;set;}
        public string TMBCustomerID {get;set;}
        public string CustomerName {get;set;}
        public string Segment {get;set;}
        public string TaskCreatedBranchCode {get;set;}
        public string TaskCreatedZoneCode {get;set;}
        public string TaskCreatedRegionCode {get;set;}
        public string TaskCreatedEmpId {get;set;}
        public string ProductName {get;set;}
        public string ProductCode {get;set;}
        public string ProductGroup {get;set;}
        public string ProdSubGroup {get;set;}
        public string TaskCreatedChannel {get;set;}
        public string TaskSubject {get;set;}
        public string TaskStatus {get;set;}
        public string LastModifiedDate {get;set;}
        public string DueDate {get;set;}
        
        /*
        public Task_CXMRequest(Task t,Account a,Opportunity o){   
            CXMCalloutHandler outerClass = new CXMCalloutHandler();
            this.TaskId = outerClass.checkNullToEmpty(t.Id);
            this.TMBCustomerID = outerClass.checkNullToEmpty(a.TMB_Customer_ID_PE__c);
            this.CustomerName = outerClass.checkNullToEmpty(a.Name);
            this.Segment = outerClass.checkNullToEmpty(a.Segment_crm__c);
            this.TaskCreatedBranchCode = outerClass.checkNullToEmpty(t.RTL_Task_Created_Branch_Code__c);
            this.TaskCreatedZoneCode = outerClass.checkNullToEmpty(t.RTL_Task_Created_Zone_Code__c);
            this.TaskCreatedRegionCode = outerClass.checkNullToEmpty(t.RTL_Task_Created_Region_Code__c);
            this.TaskCreatedEmpId = outerClass.checkNullToEmpty(t.RTL_Task_Created_Emp_Id__c);
            this.ProductName = outerClass.checkNullToEmpty(o.RTL_Product_Name__r.Name);
            this.ProductCode = outerClass.checkNullToEmpty(o.RTL_Product_Code__c);
            this.ProductGroup = outerClass.checkNullToEmpty(o.RTL_Product_Group__c);
            this.ProdSubGroup = outerClass.checkNullToEmpty(o.RTL_Prod_SubGrp__c);
            this.TaskCreatedChannel = outerClass.checkNullToEmpty(t.RTL_Task_Created_Channel__c);
            this.TaskSubject = outerClass.checkNullToEmpty(t.RTL_Task_Subject__c);
            this.TaskStatus = outerClass.checkNullToEmpty(t.Status);
            this.LastModifiedDate = outerClass.checkNullToEmpty(t.LastModifiedDate.format(FORMAT_DTM,userinfo.getTimeZone().toString()));
            
            Date d = t.ActivityDate;
            String dd = (t.ActivityDate!=null) ? DateTime.newInstance(d.year(),d.month(),d.day()).format(FORMAT_DTM) : '';
            this.DueDate = dd;     
       
        }*/

        public Task_CXMRequest(Task t,Account a,Opportunity o){   
            CXMCalloutHandler outerClass = new CXMCalloutHandler();
            this.TaskId = outerClass.checkNullToEmpty(t.Id);
            this.TMBCustomerID = outerClass.checkNullToEmpty(a.TMB_Customer_ID_PE__c);
            this.CustomerName = outerClass.checkNullToEmpty(a.Name);
            this.Segment = outerClass.checkNullToEmpty(a.Segment_crm__c);

            this.TaskCreatedBranchCode = outerClass.checkNullToEmpty(currentUser.RTL_Branch_Code__c);
            this.TaskCreatedZoneCode = outerClass.checkNullToEmpty(currentUser.Zone_Code__c);
            this.TaskCreatedRegionCode = outerClass.checkNullToEmpty(currentUser.Region_Code__c);
            this.TaskCreatedChannel = outerClass.checkNullToEmpty(currentUser.RTL_Channel__c);
            this.TaskCreatedEmpId = outerClass.checkNullToEmpty(currentUser.Employee_Id__c);

            this.ProductName = outerClass.checkNullToEmpty(o.RTL_Product_Name__r.Name);
            this.ProductCode = outerClass.checkNullToEmpty(o.RTL_Product_Code__c);
            this.ProductGroup = outerClass.checkNullToEmpty(o.RTL_Product_Group__c);
            this.ProdSubGroup = outerClass.checkNullToEmpty(o.RTL_Prod_SubGrp__c);
            this.TaskSubject = outerClass.checkNullToEmpty(t.RTL_Task_Subject__c);
            this.TaskStatus = outerClass.checkNullToEmpty(t.Status);
            this.LastModifiedDate = outerClass.checkNullToEmpty(t.LastModifiedDate.format(FORMAT_DTM,userinfo.getTimeZone().toString()));
            
            Date d = t.ActivityDate;
            String dd = (t.ActivityDate!=null) ? DateTime.newInstance(d.year(),d.month(),d.day()).format(FORMAT_DTM) : '';
            this.DueDate = dd;     
       
        }
    }
    
    public class Event_CXMRequest{  
        public string EventId {get;set;}
        public string TMBCustomerID {get;set;}
        public string CustomerName {get;set;}
        public string Segment {get;set;}
        public string EventCreatedBranchCode {get;set;}
        public string EventCreatedZoneCode {get;set;}
        public string EventCreatedRegionCode {get;set;}
        public string EventCreatedEmpId {get;set;}
        public string ProductName {get;set;}
        public string ProductCode {get;set;}
        public string ProductGroup {get;set;}
        public string ProdSubGroup {get;set;}
        public string EventCreatedChannel {get;set;}
        public string EventSubject {get;set;}
        //public string EventStatus {get;set;}
        public string LastModifiedDate {get;set;}
        //public string DueDate {get;set;}
        
        /*
        public Event_CXMRequest(Event e,Account a,Opportunity o){     
            CXMCalloutHandler outerClass = new CXMCalloutHandler();
            this.EventId = outerClass.checkNullToEmpty(e.Id);
            this.TMBCustomerID = outerClass.checkNullToEmpty(a.TMB_Customer_ID_PE__c);
            this.CustomerName = outerClass.checkNullToEmpty(a.Name);
            this.Segment = outerClass.checkNullToEmpty(a.Segment_crm__c);
            this.EventCreatedBranchCode = outerClass.checkNullToEmpty(e.RTL_Event_Created_Branch_Code__c);
            this.EventCreatedZoneCode = outerClass.checkNullToEmpty(e.RTL_Event_Created_Zone_Code__c);
            this.EventCreatedRegionCode = outerClass.checkNullToEmpty(e.RTL_Event_Created_Region_Code__c);
            this.EventCreatedEmpId = outerClass.checkNullToEmpty(e.RTL_Event_Created_Emp_Id__c);
            this.ProductName = outerClass.checkNullToEmpty(o.RTL_Product_Name__r.Name);
            this.ProductCode = outerClass.checkNullToEmpty(o.RTL_Product_Code__c);
            this.ProductGroup = outerClass.checkNullToEmpty(o.RTL_Product_Group__c);
            this.ProdSubGroup = outerClass.checkNullToEmpty(o.RTL_Prod_SubGrp__c);
            this.EventCreatedChannel =outerClass.checkNullToEmpty(e.RTL_Event_Created_Channel__c);
            this.EventSubject = outerClass.checkNullToEmpty(e.RTL_Event_Subject__c);
            //this.Status = null;// e.Status;
            this.LastModifiedDate = outerClass.checkNullToEmpty(e.LastModifiedDate.format(FORMAT_DTM,userinfo.getTimeZone().toString()));
            //this.DueDate = (e.ActivityDate!=null) ? e.ActivityDate.format() : null;  
        }*/

         public Event_CXMRequest(Event e,Account a,Opportunity o){     
            CXMCalloutHandler outerClass = new CXMCalloutHandler();
            this.EventId = outerClass.checkNullToEmpty(e.Id);
            this.TMBCustomerID = outerClass.checkNullToEmpty(a.TMB_Customer_ID_PE__c);
            this.CustomerName = outerClass.checkNullToEmpty(a.Name);
            this.Segment = outerClass.checkNullToEmpty(a.Segment_crm__c);

            this.EventCreatedBranchCode = outerClass.checkNullToEmpty(currentUser.RTL_Branch_Code__c);
            this.EventCreatedZoneCode = outerClass.checkNullToEmpty(currentUser.Zone_Code__c);
            this.EventCreatedRegionCode = outerClass.checkNullToEmpty(currentUser.Region_Code__c);
            this.EventCreatedEmpId = outerClass.checkNullToEmpty(currentUser.Employee_Id__c);
            this.EventCreatedChannel =outerClass.checkNullToEmpty(currentUser.RTL_Channel__c);

            this.ProductName = outerClass.checkNullToEmpty(o.RTL_Product_Name__r.Name);
            this.ProductCode = outerClass.checkNullToEmpty(o.RTL_Product_Code__c);
            this.ProductGroup = outerClass.checkNullToEmpty(o.RTL_Product_Group__c);
            this.ProdSubGroup = outerClass.checkNullToEmpty(o.RTL_Prod_SubGrp__c);
            
            this.EventSubject = outerClass.checkNullToEmpty(e.RTL_Event_Subject__c);
            //this.Status = null;// e.Status;
            this.LastModifiedDate = outerClass.checkNullToEmpty(e.LastModifiedDate.format(FORMAT_DTM,userinfo.getTimeZone().toString()));
            //this.DueDate = (e.ActivityDate!=null) ? e.ActivityDate.format() : null;  
        }
    }
    
    public class CXMResponse{   
        public string ReqId {get;set;}
        public string Channel {get;set;}
        public string DateTime_x {get;set;}
        public string Code {get;set;}
        public string Description {get;set;}
        
        public CXMResponse(CXMService.ForwardTaskEventResponse_element obj){
            this.ReqId = obj.ReqId;
            this.DateTime_x = obj.DateTime_x;
            this.Code = obj.Code;
            this.Description = obj.Description;
        }
        
    }
    /*#########################   Property   #############################*/    
    /** Constant representing the attachment name used to store callout requests */
    @TestVisible
    public static  String REQUEST_NAME = 'CXM Callout Request';
    /** Constant representing the attachment name used to store callout responses */    
    @TestVisible 
    public static String RESPONSE_NAME = 'CXM Callout Respond';    
    /** Constant representing the endpoint for callouts to use; over time additional endpoints can be stored in other member variables for different callout request types */
    public   static String SERVICE_NAME = 'CXM Callout';      
    @TestVisible 
    public  static String ENDPOINT = '';    
    /** Constant to represent the default callout time limit */
    //@TestVisible 
    public static Integer DEFAULT_CALLOUT_TIME = Integer.valueOf(getConfig('CXM_TIMEOUT','60000'));
    /** Constant representing the conent type for JSON */
    @TestVisible 
    public  static   String JSON_CONTENT_TYPE = 'application/json';
    /** Constant representing the OK status for callout requests */
    @TestVisible 
    public   static  String OK_STATUS = 'OK';
    /** Constant representing the KO status for callout requests */
    @TestVisible 
    public  static   String KO_STATUS = 'KO';
    /** Constant representing the failed status for callout requests */
    @TestVisible 
    public   static  String FAILED_STATUS = 'Failed';
    /** Constant representing the queued status for callout requests */
    @TestVisible 
    public  static   String QUEUED_STATUS = 'Queued';
    
    private static String TASK_OBJECT = 'Task';
    private static String EVENT_OBJECT = 'Event';
    private static String FORMAT_DTM = 'dd/MM/yyyy HH:mm:ss';
    private static String KEY_CHANNEL = 'CRM';
    private static String CODE_SUCCESS = '0000';
    private static String CODE_INVALID_FORMAT = '9901';
    private static String CODE_BAD_REQUEST = '9902';
    private static String CODE_UNPROCESSABLE = '9903';
    /** Constant to represent the maximum callout time limit */
    //@TestVisible
    public  static   Integer MAX_CALLOUT_TIME = Integer.valueOf(getConfig('CXM_TIMEOUT_MAX','120000'));
                                                                 
    //public static String END_POINT = getConfig('CXM_ENDPOINT',null);
    public static String END_POINT = CXM_ENDPOINT_CS;
    public static String CALLOUT_NAME = getConfig('CALLOUT_NAME',null);

    // Thanakorn START
    // Date : 23 / 05 / 2017 14:00
    public static List<CalloutRequest__c> CreateCXMCalloutRequest(String asyncJobType,String keyObject,List<SObject> inputList){            
        List<CalloutRequest__c> calloutReq = new List<CalloutRequest__c>();
        List<Attachment> attachList = new List<Attachment>();
        List<String> accountIdList = new List<String>();
        List<String> oppIdList = new List<String>();
        for( SObject t : inputList ){
            if( t.get('WhatId') != null ){
                accountIdList.add( String.valueOf(t.get('WhatId')) );
            }
            if( t.get('WhatId') != null ){
                oppIdList.add( String.valueOf(t.get('WhatId')) );
            }
        }
        Map<Id,Account> mapAccount = new Map<Id,Account>(getAccountList(accountIdList));
        Map<Id,Opportunity> mapOpportunity = new Map<Id,Opportunity>(getOpportunityList(accountIdList));
        List<AsyncRequest__c> arList = new List<AsyncRequest__c>();
        for( SObject each : inputList ){  
            AsyncRequest__c ar = new AsyncRequest__c( AsyncType__c = asyncJobType);
            arList.add(ar);
        }
        insert arList;
        Integer index = 0;
        for( SObject each : inputList ){            
            /*string jsonPayload = '';
            Account objAcc = (mapAccount.containsKey(String.valueOf(each.get('WhatId')))) ? mapAccount.get(String.valueOf(each.get('WhatId'))) : new Account();
            Opportunity objOpp = (mapOpportunity.containsKey(String.valueOf(each.get('WhatId')))) ? mapOpportunity.get(String.valueOf(each.get('WhatId'))) : new Opportunity();
            if( keyObject == TASK_OBJECT ){
                Task_CXMRequest request = new Task_CXMRequest( (Task)each,objAcc,objOpp );
                jsonPayload  = JSON.serialize(request);   
            }else if( keyObject == EVENT_OBJECT ){
                Event_CXMRequest request = new Event_CXMRequest( (Event)each,objAcc,objOpp );
                jsonPayload  = JSON.serialize(request);   
            }*/
            
            CalloutRequest__c cr = new CalloutRequest__c(
                AsyncRequest__c = arList.get(index).Id,    
                Endpoint__c = END_POINT,
                Method__c ='SOAP',
                CalloutHandlerName__c = CALLOUT_NAME
            );
            calloutReq.add(cr);
            index++;
        }
        try{
            insert calloutReq;    
        }catch( Exception e ){
            System.debug('error : '+e.getMessage());
        }
        
        
        index = 0;
        for( SObject each : inputList ){
            string jsonPayload = '';
            Account objAcc = (mapAccount.containsKey(String.valueOf(each.get('WhatId')))) ? mapAccount.get(String.valueOf(each.get('WhatId'))) : new Account();
            Opportunity objOpp = (mapOpportunity.containsKey(String.valueOf(each.get('WhatId')))) ? mapOpportunity.get(String.valueOf(each.get('WhatId'))) : new Opportunity();
            if( keyObject == TASK_OBJECT ){
                Task_CXMRequest request = new Task_CXMRequest( (Task)each,objAcc,objOpp );
                jsonPayload  = JSON.serialize(request);   
            }else if( keyObject == EVENT_OBJECT ){
                Event_CXMRequest request = new Event_CXMRequest( (Event)each,objAcc,objOpp );
                jsonPayload  = JSON.serialize(request);   
            }
            jsonPayload = '<![CDATA['+jsonPayload+']]>';
            Attachment requestBodyAttachment = new Attachment(ParentId=calloutReq.get(index).Id,
                                                              Name=REQUEST_NAME,
                                                              Body=Blob.valueOf(jsonPayload),ContentType=JSON_CONTENT_TYPE);
            attachList.add(requestBodyAttachment);
            index++;
        }
        
        try{
            insert attachList;
        }catch( Exception e ){
            System.debug('error : '+e.getMessage());
        }
        
        
        return calloutReq; 
    }    
    // Thanakorn END


    public void execute(CalloutRequest__c cr){       
        // Perform HTTP Callout
        Long start = System.now().getTime();
        cr.Sent__c = System.now();
        cr.Submit_DateTime__c = System.now();
        try{
            list<Attachment> requestBody = [SELECT Id, CreatedDate, ParentId, Name, ContentType, Body FROM Attachment WHERE Name = :REQUEST_NAME AND ParentId = :cr.Id ORDER BY CreatedDate DESC LIMIT 1];
            if (requestBody.size() > 0) {
                string jsonPayload  = requestBody[0].Body.toString();        
                // thanakorn comment
                //CXMRequest requestObj = (CXMRequest) JSON.deserialize(jsonPayload, CXMRequest.class);
                
                //DiagnosticsInstrumentation.Push('OpportunityName : ' + slosRequest.Data.Name);
                //DiagnosticsInstrumentation.pop();
                //Calulate time out 
                Integer timeout = calculateTimeout(cr);     
                ////////////////////////////////////////////////////////////////////
                // Implement code here
                ////////////////////////////////////////////////////////////////////    
                CXMHandler cxmObj = new CXMHandler();
                String reqId = cxmObj.getRequestId();
                String channel = KEY_CHANNEL;
                String dtm = System.now().format(FORMAT_DTM);
                String data = jsonPayload;
                cr.RequestId__c = reqId;
                cr.Channel__c = channel;

                CXMService.TaskEventPort cxm = new CXMService.TaskEventPort();                
                CXMService.ForwardTaskEventResponse_element result = new CXMService.ForwardTaskEventResponse_element();                
                
                try{
                    System.debug('call ws');
                    cxm.timeout_x = 1000*Integer.valueOf(cr.Timeout__c);
                    result = cxm.add(cr.RequestId__c,channel,dtm,data);       
                    //result.Code = '0000';
                    //result.Description = getStatusCode(result.Code,null);
                }catch( Exception error ){
                    System.debug('error send cxm add : '+error.getMessage() );
                    result.Code = '8888';
                    result.Description = error.getMessage();
                }
                System.debug('result : '+result);
                cxmObj.updateRunningNumber();
                result.ReqId = reqId;
                //result.Channel = KEY_CHANNEL;
                result.DateTime_x = dtm;

                CXMResponse resObj = new CXMResponse(result);
                String jsonResponse = JSON.serialize(resObj);
                //CXMResponse resObj = (CXMResponse) JSON.deserialize( result.tostring() , CXMResponse.class);
                cr.Response_Code__c = resObj.Code;
                cr.Response_DateTime__c = System.now();
                cr.Response_Description__c = resObj.Description;
                
                processCalloutResponse(data,jsonResponse,cr); 
                updateCalloutRequest(data,cr, start);

                //CR-CXM 16-02-2018
                updateLatestCXMStatusAndResp(jsonPayload,resObj);
                //CR-CXM 16-02-2018
                
                /*production deploy: no use this code, please comment code*/
                /*
                Test_CXM__c obj = new Test_CXM__c();
                obj.RequestId__c = reqId;
                obj.channel__c = channel;
                obj.Date_Time__c = System.now();
                obj.Data__c = data;        
                obj.response__c = jsonResponse;
                obj.Status__c = cr.Status__c;
                obj.Response_Code__c = resObj.Code;
                obj.Response_DateTime__c = System.now();
                obj.Response_Description__c = resObj.Description;
                insert obj;
                */               
            }    
        }          
        catch(Exception ex){            
            throw new CalloutException(SERVICE_NAME + ' Error cause ' + ex.getMessage(), ex);
        }
        //updateCalloutRequest(cr, start);
    }    

    //CR-CXM 16-02-2018
    private void updateLatestCXMStatusAndResp(String jsonPayload,CXMResponse resObj) {
        try {

            Map<String, String> objMap = (Map<String,String>) JSON.deserialize(jsonPayload.replace('<![CDATA[','').replace(']]>','')
                                                                                , Map<String,String>.class);

            if (objMap.containsKey('TaskId')) {
                Task task = new Task(id = objMap.get('TaskId'));

                task.Latest_CXM_Status__c   = resObj.Code;
                task.Latest_CXM_Response__c = resObj.Description;
                //for checkCXMSendDuplicate
                task.RTL_CXM_Send_Next__c   = true;

                update task;

            }else if (objMap.containsKey('EventId')) {
                Event event = new Event(id = objMap.get('EventId'));

                event.Latest_CXM_Status__c   = resObj.Code;
                event.Latest_CXM_Response__c = resObj.Description;
                //for checkCXMSendDuplicate
                event.RTL_CXM_Send_Next__c   = true;

                update event;
            }

        }catch(Exception e) {
            System.debug(' Exception in updateLatestCXMStatusAndResp :'+e.getMessage());
        }
        
    }
    //CR-CXM 16-02-2018


    private static void createResponseBody(String httpResponse, Id crId)
    {

    }
    public void processFailure(CalloutRequest__c cr, Exception ex){

    }
    public void processCalloutResponse(String jsonPayload,String response, CalloutRequest__c cr){                       
        Attachment respondBodyAttachment = new Attachment(ParentId=cr.Id,Name=RESPONSE_NAME,Body=Blob.valueOf(response),ContentType=JSON_CONTENT_TYPE);
        insert respondBodyAttachment;
    }     


    public  Integer calculateTimeout(CalloutRequest__c cr)
    {
        if (cr.Timeout__c==null || cr.Timeout__c <= 0)
        {
            cr.Timeout__c = DEFAULT_CALLOUT_TIME / 1000; 
            return DEFAULT_CALLOUT_TIME; 
        }
        else if ((cr.Timeout__c*1000) > MAX_CALLOUT_TIME)
        {
            cr.Timeout__c = MAX_CALLOUT_TIME / 1000;
            return MAX_CALLOUT_TIME;
        }
        else return Integer.valueOf(cr.Timeout__c*1000);
    }

    // DML for Callout Request
    public void updateCalloutRequest(String jsonPayload,CalloutRequest__c cr, Long start){ 
        // thanakorn START
        try{
            AsyncRequest__c asynReq = [ SELECT Id, AsyncType__c, JobId__c, ScheduledTime__c, Params__c, Attempts__c, MaxAttempts__c, Aborted__c 
                                       FROM AsyncRequest__c where Id = :cr.asyncrequest__c limit 1 ];
            
            asynReq.Attempts__c++;
            asynReq.ScheduledTime__c =  DateTime.now().addSeconds(10);
            
            if( asynReq.Attempts__c >= asynReq.MaxAttempts__c ){
                asynReq.Aborted__c = true;
            }
            
            if( cr.Response_Code__c == CODE_SUCCESS ){
                cr.Status__c = OK_STATUS;         
                asynReq.IsSuccess__c = true;
            }else{
                cr.Status__c = FAILED_STATUS;
                
                if( !asynReq.Aborted__c ){
                    CalloutRequest__c obj = cr.clone(false,true);
                    obj.Status__c = QUEUED_STATUS;
                    obj.Response_Code__c = null;
                    obj.Response_DateTime__c = null;
                    obj.Response_Description__c = null;
                    insert obj;
                    Attachment requestBodyAttachment = new Attachment(ParentId=obj.Id,
                                                                      Name=REQUEST_NAME,
                                                                      Body=Blob.valueOf(jsonPayload),ContentType=JSON_CONTENT_TYPE);
                    insert requestBodyAttachment;
                }
            }
            
            update asynReq;
            
            Decimal timeDiff = System.now().getTime() - start;
            cr.Duration__c = timeDiff.Divide(1000,3);
            update cr;
            CXmHandler cxm = new CXmHandler();
            cxm.CXMSendEmailLog(asynReq.Id);
        }catch( Exception e ){
             System.debug('error : '+e.getMessage());
        }

        // thanakorn END

    } 
    
     public String checkNullToEmpty(String input){ 
        return (input == null) ? '' : input;
    }
    
    public static String getConfig(String confName,String defaultValue){ 
        try{
            //return CXM_Config__c.getValues(confName).Value__c;
            return mapMetaConf.get(confName).Value__c;
        }catch( Exception e ){
            return defaultValue;
        }
    }
    
    public static String getStatusCode(String confName,String defaultValue){ 
        try{
            //return CXM_Status_Code__c.getValues(confName).Value__c;
            return mapMetaStatusCode.get(confName).Value__c;
        }catch( Exception e ){
            return defaultValue;
        }
    }
    
    public static Map<Id,Account> getAccountList(List<Id> idList){
        return new Map<Id,Account>([ select Id,Name,TMB_Customer_ID_PE__c,Segment_crm__c from Account where Id IN :idList ]);
    }
    
    public static Map<Id,Opportunity> getOpportunityList(List<Id> idList){
        return new Map<Id,Opportunity>([ select Id,Name,RTL_Product_Name__r.Name,RTL_Product_Code__c,RTL_Product_Group__c,RTL_Prod_SubGrp__c 
                                        from Opportunity where Id IN :idList ]);
    }
    
}