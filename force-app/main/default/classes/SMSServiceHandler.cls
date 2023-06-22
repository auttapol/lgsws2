global without sharing class SMSServiceHandler implements APICallInterface {
	//get custom setting
	private String SERVICE_NAME;
	private List<RTL_Online_Service_Log__c> logLst = new List<RTL_Online_Service_Log__c>();

	private final String office_code  = 'office_code';
	private final String service_code = 'service_code';
	private final String template_name = 'template_name';

	private String SMS_STATUS_LOG;
	private String SMS_STATUS;
	private Map<String,String> SMS_STATUS_TEMPLATE_NAME = new Map<String,String>();

	private SMSServiceHandler.SMSHeader smsHeader;
    private List<SMSServiceHandler.SMSRecord> recordLst;
    private Map<String,String> paramsMap;
    private String API_BATCH_QUERY;
    private SMS_Notification_Handler__c SMSHANDLER;


    private Datetime batchStartTime = datetime.now();
    private Datetime batchEndTime = null;
    private Integer recordsSuccessful = 0;
    private Integer recordsFailed = 0;

    public String SMS_SENT_SUCESS     = 'SMS_SENT_SUCESS';
    public String SMS_FAIL_SENT       = 'SMS_FAIL_SENT';
    public String SMS_NO_SEND_BEFORE  = 'SMS_NO_SEND_BEFORE';
    public String SMS_IN_PROCESS      = 'SMS_IN_PROCESS';
    public String NOT_ALLOWED_TO_SMS    = 'NOT_ALLOWED_TO_SMS';
    public String SMS_SERVICE_UNAVAILABLE    = 'SMS_SERVICE_UNAVAILABLE';

    //always set false
    private String Bulk_Send_SMS_Field = 'Bulk_Send_SMS__c';
    private String SMS_Result_Field    = 'success';
    private String ISAutoField    = 'SMS_Auto_';

    private Map<Id,String> MAP_BULK_ERROR;
    private String CSV_BODY = '';

    public class SMSServiceException extends Exception {}

	public class SMSHeader {
		public List<SMSServiceHandler.SMSRecord> record;
		public String office_code;
		public String service_code;
	}

	public class SMSRecord{
		public String rm_id;
		public String language;
		public SMS sms;
		public Map<String,String> params;
	}

	public class SMS{
		public String endpoint;
		public Boolean force;
		public Boolean search;
	}

	public void done_job() {}


    public Boolean isUpdateMainObj() {
      return true;
    }

    public Map<String,String> getCustomizedResponse(String responseBody) {
    	return null;
    }

    public Boolean getIntegrationResult(Map<String,Object>  resMap) {
      if (resMap == null || resMap.size() == 0) {
          return false;
      }

      if (resMap.containsKey(this.SMS_Result_Field)) {
      	return Boolean.valueOf(resMap.get(this.SMS_Result_Field));
      }
      return false;
   }

	public SMSServiceHandler(String serviceName,String smsStatusLog) {
		//Get Request field for this jobName

		this.SERVICE_NAME = serviceName;
		this.SMS_STATUS_LOG = smsStatusLog;
		
		List<SMS_Notification_Handler__c> smsNotiLst = [SELECT Id
														,Field_Trigger__c
														,Object__c
														,Service__c
														,Accout_ID_Field__c
														,Account_Name_Field__c
														,SMS_Fee_Charging_1__c
														,SMS_Fee_Charging_2__c
														,SMS_Fee_Charging_3__c
														,SMS_Template_Id__c
														,SMS_Template_Id_2__c
														,SMS_To_Phone_Number__c
														,TMB_Cust_ID__c
														,Sponsor_Class_Field__c
														,Language__c
														,IsActive__c
														,search__c
														,force__c
														,Field_Update_After_SMS__c
														,TOKEN_ENDPOINT_NAME__c
													From SMS_Notification_Handler__c 
													WHERE Name =: this.SERVICE_NAME 
													LIMIT 1];
		System.debug(' smsNotiLst ' + smsNotiLst);
	
		if (smsNotiLst != null && smsNotiLst.size() == 1) {
			this.SMSHANDLER = smsNotiLst.get(0);

			List<EIM_Map__c> eimMapList = [SELECT SF_Field__c
                                     	FROM EIM_Map__c Where Job_Type__c 
                                     		=: this.SERVICE_NAME 
                                          AND IsActive__c = true
                                          AND Field_Type__c = 'Request'
                                     ORDER BY Field_Order__c ASC 
                                     ];

			List<String> fieldLst = new List<String>();


			for (EIM_Map__c eimMap : eimMapList) {
				fieldLst.add(eimMap.SF_Field__c);
			}
			
			this.API_BATCH_QUERY = 'SELECT '+String.join(fieldLst,',');

			if (this.SMSHANDLER.Accout_ID_Field__c != null 
					&& this.SMSHANDLER.Accout_ID_Field__c.length() > 0
					&& !fieldLst.contains(this.SMSHANDLER.Accout_ID_Field__c)
				) {
					
			System.debug(eimMapList);
				this.API_BATCH_QUERY += ','+ this.SMSHANDLER.Accout_ID_Field__c;
			}

			if (this.SMSHANDLER.Account_Name_Field__c != null
				&& this.SMSHANDLER.Account_Name_Field__c.length() > 0
				&& !fieldLst.contains(this.SMSHANDLER.Account_Name_Field__c)
				) {
				this.API_BATCH_QUERY += ','+ this.SMSHANDLER.Account_Name_Field__c ;
			}

			this.API_BATCH_QUERY +=  ' FROM '+this.SMSHANDLER.Object__c;
		}
	}


	public String getTokenEndpoint() {
		return this.SMSHANDLER.TOKEN_ENDPOINT_NAME__c;
	}

	private Boolean getSMSFeeChargingMap(String sponsorValue) {
		return covnertStringToSMSFeeMap(this.SMSHANDLER.SMS_Fee_Charging_1__c,sponsorValue) 
				|| covnertStringToSMSFeeMap(this.SMSHANDLER.SMS_Fee_Charging_2__c,sponsorValue) 
				|| covnertStringToSMSFeeMap(this.SMSHANDLER.SMS_Fee_Charging_3__c,sponsorValue);
	}

	private Boolean covnertStringToSMSFeeMap(String jsonInput,String sponsorValue) {
		if (jsonInput != null && jsonInput.length() > 0) {
			Map<String,Map<String,String>> smsFeeMap = (Map<String,Map<String,String>>)
										JSON.deserialize(jsonInput
											, Map<String,Map<String,String>>.class);


			if (smsFeeMap == null || smsFeeMap.size() == 0) return false;

			for (String key : smsFeeMap.keySet()) {
				List<String> classKeyLst = key.split(',');
				if (classKeyLst.contains(sponsorValue)) {
					if (this.smsHeader != null) {
						Map<String,String> feeMap = smsFeeMap.get(key);
						this.smsHeader.office_code  = String.valueOf(feeMap.get(this.office_code));
	    				this.smsHeader.service_code = String.valueOf(feeMap.get(this.service_code));
					}
					return true;
				}
			} 

		}

		return false;
	}

	private Map<String,List<String>> covnertStringToSMSTemplateMap(String jsonInput) {
		if (jsonInput != null && jsonInput.length() > 0) {
			return (Map<String,List<String>>)
					JSON.deserialize(jsonInput, Map<String,List<String>>.class);
		}

		return null;
	}


	private Boolean getSMSTemplateMap(SObject sobj,String key) {
		if (this.SMS_STATUS_TEMPLATE_NAME != null 
				&& this.SMS_STATUS_TEMPLATE_NAME.size() > 0) {

			String SMS_TEMPLATE_NAME = this.SMS_STATUS_TEMPLATE_NAME.get(key);
			/// CRMRBG_006 SMS code resoved
			this.paramsMap.put(this.template_name
								,SMS_TEMPLATE_NAME);

			Map<String,List<String>> smsTemplateMap1 
								= covnertStringToSMSTemplateMap(this.SMSHANDLER.SMS_Template_Id__c);

			if (smsTemplateMap1 != null 
					&& smsTemplateMap1.size() > 0
					&& (smsTemplateMap1.keySet().contains(SMS_TEMPLATE_NAME)
						|| smsTemplateMap1.keySet().contains('*'))
					) {
				List<String> templateList = smsTemplateMap1.get(SMS_TEMPLATE_NAME);

				if (templateList == null) templateList = smsTemplateMap1.get('*');


				for (String templateField : templateList) {
					this.paramsMap.put(templateField,String.valueOf(sobj.get(templateField)));
				}
				return true;
			}

			Map<String,List<String>> smsTemplateMap2 
					= covnertStringToSMSTemplateMap(this.SMSHANDLER.SMS_Template_Id_2__c);

			if (smsTemplateMap2 != null 
					&& smsTemplateMap2.size() > 0
					&& smsTemplateMap2.keySet().contains(SMS_TEMPLATE_NAME)) {
				List<String> templateList = smsTemplateMap2.get(SMS_TEMPLATE_NAME);

				for (String templateField : templateList) {
					this.paramsMap.put(templateField,String.valueOf(sobj.get(templateField)));
				}
				return true;
			}
		}

		return false;
	}

	public String getAPIBatchQuery(){
		return this.API_BATCH_QUERY;
	}

	public void updateResponseWS(SObject sobj,String status,Map<String,Object> resMap){
		String smsStatusLog = String.valueOf(sobj.get(this.SMS_STATUS_LOG));
		Map<String,Map<String,Object>> respSMSMap = new Map<String,Map<String,String>>();

		if (smsStatusLog != null && smsStatusLog.length() > 0) {
			respSMSMap = (Map<String,Map<String,String>>)
										JSON.deserialize(smsStatusLog
														,Map<String,Map<String,String>>.class);
		}


		if (resMap == null || resMap.size() == 0) {
			//to test set timeout as low handdle exception case
			resMap = new Map<String,String>();
			resMap.put(SMS_Result_Field,'false');
		}

		if (this.smsHeader != null) {
			resMap.put('office_code',this.smsHeader.office_code);
			resMap.put('service_code',this.smsHeader.service_code );
		}
		

		respSMSMap.put(status,resMap);

		if(this.SERVICE_NAME != 'SMS_Link_URL' && this.SERVICE_NAME != 'SMS_Verify_OTP'){
			sobj.put(this.Bulk_Send_SMS_Field,false);
			sobj.put('Send_SMS_Status_'+status.replace(' ','_')+'__c'
					,(resMap.get(SMS_Result_Field) == 'true' ? 'Success' : 'Fail'));

		}
		
		sobj.put(this.SMS_STATUS_LOG,JSON.serialize(respSMSMap));

		

		String fieldUpdateAfterSMS = this.SMSHANDLER.Field_Update_After_SMS__c;

		//if (fieldUpdateAfterSMS != null && fieldUpdateAfterSMS.length() > 0 && resMap.get(SMS_Result_Field) == 'true') {
			if (fieldUpdateAfterSMS != null && fieldUpdateAfterSMS.length() > 0) {
			Map<String,List<String>> fieldUpdateMap 
									= (Map<String,List<String>>)
														JSON.deserialize(fieldUpdateAfterSMS
																	, Map<String,List<String>>.class);

			for (String fieldStatus : fieldUpdateMap.keySet()) {
				List<String> fieldUpdateLst = fieldUpdateMap.get(fieldStatus);

				for (String fieldUpdate : fieldUpdateLst) {
					String fieldAPI = this.ISAutoField+fieldUpdate+'__c';
					Boolean isUpdate = Boolean.valueOf(sobj.get(fieldAPI));
					if (isUpdate) {
						if (resMap.get(SMS_Result_Field) == 'true') {
						sobj.put(fieldStatus,fieldUpdate);
						// sobj.put(fieldAPI,false);
						}
					}
				}
			}
		}
	}

	public String getEnableToSentSMS(SObject sobj,String status,Boolean isQueryAgain) {
		if (!this.SMSHANDLER.IsActive__c) {
			insertSMSFailLog('',this.SMS_SERVICE_UNAVAILABLE+' FOR '+this.SERVICE_NAME);
			return this.SMS_SERVICE_UNAVAILABLE;
		}
		System.debug('getEnableToSentSMS Status : ' + status);
		String sponsorValue = String.valueOf(sobj.get(this.SMSHANDLER.Sponsor_Class_Field__c));

    	//find SMS Fee Charging
    	Boolean isSucForSMSFee = getSMSFeeChargingMap(sponsorValue);

    	if (!isSucForSMSFee) return this.NOT_ALLOWED_TO_SMS;

    	if (isQueryAgain) {
    		String query = 'SELECT Id,'+this.SMS_STATUS_LOG+' FROM '+this.SMSHANDLER.Object__c+' WHERE Id = \''+sobj.Id+'\'';

    		List<SObject> sobjList = Database.query(query);

    		sobj = sobjList.get(0);
    	}
    	
		System.debug(sobj);
		String statusDesc = String.valueOf(sobj.get(this.SMS_STATUS_LOG));
		if (statusDesc != null && statusDesc.length() > 0) {
			Map<String,Map<String,String>> statusMap 
							= (Map<String,Map<String,String>>)
							JSON.deserialize(statusDesc,Map<String,Map<String,String>>.class);

			Map<String,String> resultMap = statusMap.get(status);

			if (resultMap != null && resultMap.containsKey(SMS_Result_Field)) {
				String result = resultMap.get(SMS_Result_Field);

				if (result == 'true') {
					return this.SMS_SENT_SUCESS;
				}else if (result == 'in_process') {
					return this.SMS_IN_PROCESS;
				}else if (result == 'false') {
					return this.SMS_FAIL_SENT;
				}
			}

			
		}
		return this.SMS_NO_SEND_BEFORE;
	}


	private void updateSMSLogInProcess(SObject sobj,String status) {
		Map<String,Map<String,String>> smsInfoMap;
		String statusDesc = String.valueOf(sobj.get(this.SMS_STATUS_LOG));
		if (statusDesc != null && statusDesc.length() > 0) {
			smsInfoMap = (Map<String,Map<String,String>>)
								JSON.deserialize(statusDesc,Map<String,Map<String,String>>.class);
		}else {
			smsInfoMap = new Map<String,Map<String,String>>();
		}

		Map<String,String> statusMap = smsInfoMap.get(status);

		if (statusMap == null) statusMap = new Map<String,String>();

		statusMap.put(SMS_Result_Field,'in_process');

		sobj.put(this.SMS_STATUS_LOG,JSON.serialize(smsInfoMap));
		update sobj;
	}


	public String getStatusForAPICall() {
		return this.SMS_STATUS;
	}


	public String createRequestWS(SObject sobj,String status,Map<Id,String> reqMap){
		//clear init object
		this.smsHeader  = new SMSServiceHandler.SMSHeader();
		this.recordLst  = new List<SMSServiceHandler.SMSRecord>();
		this.paramsMap  = new Map<String,String>();
		//clear init object

    	this.smsHeader.record = recordLst;
    	String sponsorValue = String.valueOf(sobj.get(this.SMSHANDLER.Sponsor_Class_Field__c));

    	//find SMS Fee Charging
    	Boolean isSucForSMSFee = getSMSFeeChargingMap(sponsorValue);

    	if (!isSucForSMSFee) {
    		//keep log
    		throw new SMSServiceException(NOT_ALLOWED_TO_SMS+'_'+sponsorValue);
    	}
    	//find SMS Fee Charging
    	//find SMS Template 
    	Boolean isSucForSMSTemplate = getSMSTemplateMap(sobj,sobj.Id);
    	if (!isSucForSMSFee) {
    		//keep log
    		String SMS_TEMPLATE_NAME = this.SMS_STATUS_TEMPLATE_NAME.get(status);
    		throw new SMSServiceException('NO_SMS_TEMPLTE_FOR_'+SMS_TEMPLATE_NAME);
    	}
    	//find SMS Template 


    	SMSServiceHandler.SMSRecord record = new SMSServiceHandler.SMSRecord();
		if(this.SMSHANDLER.TMB_Cust_ID__c != '' && this.SMSHANDLER.TMB_Cust_ID__c != null){
			record.rm_id = String.valueOf(sobj.get(this.SMSHANDLER.TMB_Cust_ID__c));
		}
    	

    	SMS sms = new SMS();
    	sms.endpoint = String.valueOf(sobj.get(this.SMSHANDLER.SMS_To_Phone_Number__c));

    	sms.force  = Boolean.valueOf(this.SMSHANDLER.force__c);
    	sms.search = Boolean.valueOf(this.SMSHANDLER.search__c);

    	record.params = this.paramsMap;

    	record.sms = sms;

		if(this.SMSHANDLER.TMB_Cust_ID__c != '' && this.SMSHANDLER.TMB_Cust_ID__c != null){
			record.rm_id = String.valueOf(sobj.get(this.SMSHANDLER.TMB_Cust_ID__c));
		}
    	record.language = this.SMSHANDLER.Language__c;
    	
    	recordLst.add(record);
    	return JSON.serialize(this.smsHeader);
	}

	public void setMapBulkError(Map<Id,String> mapBulkError ) {
		this.MAP_BULK_ERROR = mapBulkError;
	}


	/*recordIdsMap = Id and Template code*/
	public void sendSMS(Map<String,Map<Id,String>> recordStatusIdsMap) {
		/// recordStatusIdsMap => status : {caseid : case sms code Resolved}
		try {
			if (!this.SMSHANDLER.IsActive__c) {
				insertSMSFailLog('',this.SMS_SERVICE_UNAVAILABLE+' FOR '+this.SERVICE_NAME);
				return;
			}

			List<String> emailList = new List<String>();
			emailList.add(UserInfo.getUserEmail());
			//emailList.add('CRM Admin 2');
			
			for (String caseStatus : recordStatusIdsMap.keySet()) {
				this.SMS_STATUS = caseStatus;
				List<String> idLst = new List<String>();

				Map<Id,String> recordIdsMap = recordStatusIdsMap.get(caseStatus);

				for (Id sobjId : recordIdsMap.KeySet()) {
					this.SMS_STATUS_TEMPLATE_NAME.put(String.valueOf(sobjId)
													 ,recordIdsMap.get(sobjId)); 
													 ///// caseid , case sms code Resolved
					idLst.add(sobjId);
				}


				Boolean isEmailSumSent = true;

				if (idLst.size() == 1 && recordStatusIdsMap.size() == 1) {
					isEmailSumSent = false;
					//update field sms log
					String query='SELECT Id,'+SMS_STATUS_LOG 
									+ ' FROM '+this.SMSHANDLER.Object__c
									+ ' WHERE Id = \''+idLst.get(0)+'\'';

					List <SObject> sobjLst =Database.query(query);
					this.updateSMSLogInProcess(sobjLst.get(0),this.SMS_STATUS);
				}

				//// service send SMS
				System.debug('idLst' + idLst);
				System.debug('This' + this);
				System.debug('this.SERVICE_NAME' + this.SERVICE_NAME);
				System.debug('isEmailSumSent' + isEmailSumSent);
				System.debug('emailList' + emailList);
				System.debug('this.SMSHANDLER.Accout_ID_Field__c' + this.SMSHANDLER.Accout_ID_Field__c);
				System.debug('this.SMSHANDLER.Account_Name_Field__c' + this.SMSHANDLER.Account_Name_Field__c);
				RestfulServiceUtil restfulService = new RestfulServiceUtil(idLst
																			,true
																			,this
																			,this.SERVICE_NAME
																			,false
																			,isEmailSumSent
																			,emailList
																			,this.SMSHANDLER.Accout_ID_Field__c
																			,this.SMSHANDLER.Account_Name_Field__c
																			);

				restfulService.runBatch();

			}
			
		}catch(Exception e) {
			//insert log before call batch
			insertSMSFailLog(''
								,JSON.serialize(recordLst)
								+' '
								+e.getMessage()
								+' '
								+e.getStackTraceString());
		}
	}


	private void insertSMSFailLog(String recordId,String errMsg) {
		RTL_Online_Service_Log__c inlog = new RTL_Online_Service_Log__c ();
	    inlog.RTL_Name_of_User__c = UserInfo.getName();
	    inlog.RTL_RM_ID__c = null;
	    inlog.Online_Batch_Log__c   = this.SERVICE_NAME;
	    inlog.RTL_Error_Message__c  = errMsg;
	    inlog.RTL_Start_DateTime__c = Datetime.now();   
	    inlog.RTL_End_DateTime__c   = Datetime.now();
	    inlog.RTL_Service_Name__c   = this.SERVICE_NAME;
	    inlog.RTL_Is_Success__c     = false;
	    inlog.RTL_Mulesoft_Log_Id__c = recordId;
	    logLst.add(inlog);
	    recordsFailed++;

	    this.CSV_BODY = this.CSV_BODY 
	    				+recordId
	    				+','
	    				+errMsg
	    				+ '\n';
	}

	public void endCall() {
		List<String> emailOpsList = new List<String>();
        emailOpsList.add('CRM Admin 2');
        emailOpsList.add(UserInfo.getUserEmail());

		if (this.MAP_BULK_ERROR != null && this.MAP_BULK_ERROR.size() > 0) {
			List<SObject> updateSObjLst = new List<SObject>();

			for (Id sobjId : this.MAP_BULK_ERROR.keySet()) {
	    		this.CSV_BODY = this.CSV_BODY 
	    				+sobjId
	    				+','
	    				+this.MAP_BULK_ERROR.get(sobjId)
	    				+ '\n';

	    		recordsFailed++;

	    		SObject newSObj = sobjId.getSObjectType().newSObject(sobjId);

	    		newSObj.put(this.Bulk_Send_SMS_Field,false);

	    		updateSObjLst.add(newSObj);
			}

			if (updateSObjLst != null && updateSObjLst.size() > 0) update updateSObjLst;
		}

		if (logLst.size() > 0) {
			insert logLst;
		}

		if (this.CSV_BODY != null && this.CSV_BODY.length() > 0) {
			batchEndTime = datetime.now();
			String MAINERR_HEADER = 'RecordId,ErrorMessage\n';
        	
			//send email notification.
			RTL_BatchEmailService.SendFinishDailyBatchForFuture(batchStartTime
                                                        , batchStartTime
                                                        , batchEndTime
                                                        , recordsSuccessful
                                                        , recordsFailed
                                                        , this.SERVICE_NAME+'_FAIL_TO_SEND_SMS'
                                                        , this.SMSHANDLER.Object__c
                                                        , emailOpsList
                                                        , this.CSV_BODY
                                                        , ''
                                                        , ''
                                                        , MAINERR_HEADER
                                                        , ''
                                                        , ''
                                                        , ''
                                                        );
		}
		
	}
	//Send SMS by batch update case progress every n days
	public map<id,string> sendSMSCallOut(List<String> idList, List<Sobject> objectList, Map<String,String> mapSMSCode) {

		map<id,String> sentSMSResult = new map<id,string>();
		try {
			if (!this.SMSHANDLER.IsActive__c) {
				insertSMSFailLog('',this.SMS_SERVICE_UNAVAILABLE+' FOR '+this.SERVICE_NAME);
				return null;
			}

			//List<String> emailList = new List<String>();
			//emailList.add(UserInfo.getUserEmail());
			this.SMS_STATUS_TEMPLATE_NAME = mapSMSCode;
			SMSServiceAPI ServiceAPI = new SMSServiceAPI(idList
														,true
														,this
														,this.SERVICE_NAME
														,false											
														,this.SMSHANDLER.Accout_ID_Field__c
														,this.SMSHANDLER.Account_Name_Field__c
														);

			sentSMSResult = ServiceAPI.executeCallOut(objectList);
	
		}catch(Exception e) {
			System.debug(e.getStackTraceString());

		}
		
		return sentSMSResult;

	}
}