public class DoNotContactServiceBatch implements APICallInterface,Schedulable {
  //extends DailyBatchAbstract 
   public String DO_NOT_CONTACT_SERVICE_API = 'DO_NOT_CONTACT_SERVICE_API';

   public String DNCToMISBatch = 'DNCToMISBatch';

   public String OBJECTNAME = 'RTL_Do_not_Contact_Info__c';

   private String SUCCESS_FLAG = 'code';
   
   private IntegrationMapHandler integrateHandler;

   private RTL_Online_Service_Log__c RETAIL_LOG = new RTL_Online_Service_Log__c();
   private List<RTL_Online_Service_Log__c> retryLogLst = null;

   //done_job is a function called by RestfulServiceUtil
    public void done_job() {
      if (this.retryLogLst != null && this.retryLogLst.size() > 0) {
         for (RTL_Online_Service_Log__c onlineLog : this.retryLogLst ) {
            onlineLog.RTL_Error_Message__c += ' Already_Retry_Log';
            onlineLog.RTL_Is_Success__c = true;
         }

         update this.retryLogLst;
      }

      if (!this.RETAIL_LOG.RTL_Is_Success__c) {
        //this.RETAIL_LOG.RTL_Error_Message__c = this.DO_NOT_CONTACT_SERVICE_API+'_Integrated_Successfully';
        this.RETAIL_LOG.RTL_End_DateTime__c = Datetime.now();
        insert this.RETAIL_LOG;
      }
    }



    public void execute(SchedulableContext sc) {
        DoNotContactServiceBatch dncService = new DoNotContactServiceBatch();
        dncService.execute();
    }
    //isUpdateMainObj is a function called by RestfulServiceUtil
   public Boolean isUpdateMainObj() {
      return false;
   }

   public Boolean getIntegrationResult(Map<String,Object>  resMap) {
      if (resMap == null || resMap.size() == 0) {
          return false;
      }
    
      if (resMap.containsKey(this.SUCCESS_FLAG)) {
        return (String.valueOf(resMap.get(this.SUCCESS_FLAG)) == '0000' ? true : false);
      }
      return false;
   }

   public String getTokenEndpoint() {
		return this.integrateHandler.getTokenEndpoint();
	 }


   public void execute() {
      try {
        String DNC_SQL = this.getAPIBatchQuery();

        if (DNC_SQL != null) {
            
            if(Test.isRunningTest()) DNC_SQL += ' LIMIT 200';

            List<String> emailOpsList = new List<String>();
            this.RETAIL_LOG.RTL_Name_of_User__c = UserInfo.getName();
            this.RETAIL_LOG.RTL_RM_ID__c          = '';
            this.RETAIL_LOG.Online_Batch_Log__c   = this.DO_NOT_CONTACT_SERVICE_API;
            this.RETAIL_LOG.RTL_Start_DateTime__c = Datetime.now();  
            this.RETAIL_LOG.RTL_Service_Name__c   = this.DO_NOT_CONTACT_SERVICE_API;
            this.RETAIL_LOG.RTL_Is_Success__c = true;

            //add Operation Team App monitoring, Operation Team A
            emailOpsList.add('Operation Team App monitoring');

            RestfulServiceUtil restService = new RestfulServiceUtil(DNC_SQL
                                                                    ,this.DNCToMISBatch
                                                                    ,true
                                                                    ,this
                                                                    ,true
                                                                    ,true
                                                                    ,emailOpsList
                                                                    ,'Customer__c'
                                                                    ,'Customer__r.Name'
                                                                    ,this.integrateHandler
                                                                    );

            restService.runBatch();



        }
      }catch(Exception e) {
          this.RETAIL_LOG.RTL_Name_of_User__c = UserInfo.getName();
          this.RETAIL_LOG.RTL_RM_ID__c          = '';
          this.RETAIL_LOG.Online_Batch_Log__c   = this.DO_NOT_CONTACT_SERVICE_API+'_Occured_Exception';
          this.RETAIL_LOG.RTL_Start_DateTime__c = Datetime.now();  
          this.RETAIL_LOG.RTL_End_DateTime__c = Datetime.now();  
          this.RETAIL_LOG.RTL_Service_Name__c   = this.DO_NOT_CONTACT_SERVICE_API+'_Occured_Exception';
          this.RETAIL_LOG.RTL_Is_Success__c = false;
          this.RETAIL_LOG.RTL_Error_Message__c = e.getMessage()+ ' '+e.getStackTraceString();
          insert this.RETAIL_LOG;
      }
      
  }
  

  public String getAPIBatchQuery(){
    integrateHandler = new IntegrationMapHandler('RetailLogForDNC');

    String idRetry = '';
    if (integrateHandler.isActive()) {
        this.retryLogLst = Database.query(integrateHandler.getSQL());
        
        Set<String> idsSet = new Set<String>();

        for (RTL_Online_Service_Log__c sobj : this.retryLogLst) {
            List<String> IdLst = sobj.RTL_Error_Message__c.split(',');
            idsSet.addAll(IdLst);
        }

        if (idsSet.size() > 0) {
            idRetry = 'OR Id in (\''+String.join(new List<String>(idsSet),'\',\'')+'\')';
        }
        
    }

    integrateHandler = new IntegrationMapHandler(this.DNCToMISBatch);

    if (integrateHandler.isActive()) {
        String sql = this.integrateHandler.getSQL();
        return sql.replace('{%id_list%}', idRetry);
    }

    this.RETAIL_LOG.RTL_Name_of_User__c = UserInfo.getName();
    this.RETAIL_LOG.RTL_RM_ID__c          = '';
    this.RETAIL_LOG.Online_Batch_Log__c   = this.DO_NOT_CONTACT_SERVICE_API;
    this.RETAIL_LOG.RTL_Start_DateTime__c = Datetime.now();  
    this.RETAIL_LOG.RTL_Service_Name__c   = this.DO_NOT_CONTACT_SERVICE_API+'_is_unavailable';
    this.RETAIL_LOG.RTL_Is_Success__c = false;
    this.RETAIL_LOG.RTL_End_DateTime__c = Datetime.now();
    this.RETAIL_LOG.RTL_Error_Message__c = this.DO_NOT_CONTACT_SERVICE_API+'_is_unavailable';

    insert this.RETAIL_LOG;

    return null;

  }

  public String getStatusForAPICall() {
    return null;
  }

  public Map<String,String> getCustomizedResponse(String responseBody) {
     /*
           {
        "status": {
          "code": "0000",
          "description": "success"
        }
      }*/

      Map<String,Map<String,String>> respMap = (Map<String,Map<String,String>>)JSON.deserialize(responseBody
                                                          , Map<String,Map<String,String>>.class);
      return respMap.get('status');
    }

  public String createRequestWS(SObject sobj,String status,Map<Id,String> reqMap) {
    String recordId = String.valueOf(sobj.Id);
    String requestWS = reqMap.get(recordId);
    return '{\"crmCustomerDonotcontact\":'+requestWS +'}';
  }

  public void updateResponseWS(SObject sobj,String status,Map<String,Object>  resMap){
    Boolean isResult = true;

    if (resMap == null || resMap.size() == 0) {
        isResult = false;
    }else {
        isResult = (String.valueOf(resMap.get(this.SUCCESS_FLAG)) == '0000' ? true : false);
    }
    //for DNC retry log
    if (!isResult) {
        if (this.RETAIL_LOG.RTL_Error_Message__c != null && this.RETAIL_LOG.RTL_Error_Message__c.length() > 0) {
            this.RETAIL_LOG.RTL_Error_Message__c += ','+sobj.Id;
        }else {
            this.RETAIL_LOG.RTL_Error_Message__c =  sobj.Id;
        }
        
        this.RETAIL_LOG.RTL_Is_Success__c = isResult;
    }
  }
  
}