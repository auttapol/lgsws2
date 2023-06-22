public with sharing class RTL_CampaignToHQCallout implements Queueable, Database.AllowsCallouts {

	private List<ID> logIds; 
	private List<String> emailsNotification{
        get{
            if(emailsNotification==null){
            	emailsNotification = new List<String>();
            	List<RTL_Campaign_Submit_Error_Email_To__mdt> listData = [select id,RTL_Email_to__c,RTL_Status__c
                   from RTL_Campaign_Submit_Error_Email_To__mdt
                   where RTL_Status__c = true];

                   for(RTL_Campaign_Submit_Error_Email_To__mdt item : listData )
                   {
                		emailsNotification.add( item.RTL_Email_to__c );
                   }	
            }
            return emailsNotification;
        }
        set;
    }

    private Integer timeout{
        get{
            if(timeout==null){
            	RTL_Campaign_Submit_Callout_timeout__mdt listData = [select id,RTL_Timeout_Millisecond__c
                   from RTL_Campaign_Submit_Callout_timeout__mdt
                   where DeveloperName = 'timeout'];
                timeout = integer.valueOf(listData.RTL_Timeout_Millisecond__c);
            }
            return timeout;
        }
        set;
    }

	public static Set<ID> MasterCampaignRecordTypeId {
    	get{
	    	if(MasterCampaignRecordTypeId==null){
	    		MasterCampaignRecordTypeId = new Set<ID>();
	    		List<Recordtype> rtl = [ SELECT ID,name from Recordtype WHERE sObjectType ='Campaign' 
	    						AND developerName in ( 'Master_Campaign','Master_Campaign_Active','Master_Campaign_Expired' ) ];
	    		for( Recordtype rt : rtl )
	    		{
					MasterCampaignRecordTypeId.add(rt.id);
				}
	    	}
    		return MasterCampaignRecordTypeId;
    	}
    	set;
    }
    public class MasterChildCampaing
	{
		public Campaign master;
		public List<Campaign> childrenList;
	}

    public RTL_CampaignToHQCallout(List<ID> ids) {
		logIds = ids;
	}

	public void execute(QueueableContext context) {
		// Callout webservice 
		List<RTL_Campaign_To_HQ_Callout_Log__c> camLogList = [SELECT Id,RTL_Campaign_ID__c,RTL_Create_date__c
					FROM RTL_Campaign_To_HQ_Callout_Log__c
	                WHERE ID in :logIds
	                ];

	    List<ID> camIds = new List<ID>();
	    Map<ID,RTL_Campaign_To_HQ_Callout_Log__c> camLogMap = new Map<ID,RTL_Campaign_To_HQ_Callout_Log__c>();

	    for( RTL_Campaign_To_HQ_Callout_Log__c cl : camLogList )
	    {
	    	camIds.add( cl.RTL_Campaign_ID__c );
	    	camLogMap.put( cl.RTL_Campaign_ID__c, cl );
	    }

	    // Process to get all Master and Child Campaign Id to process update RTL_LastSubmittedDate__c
	    // Ignore canceled campaign
	    // Not stamp LastSubmittedDate if child campaign already have last submit date

	    Set<ID> camAllIds = new Set<ID>();
	    MAP<ID,ID> camToSentCamMap = new MAP<ID,ID>();

	    List<Campaign> camList = [SELECT ID,name,RTL_LastSubmittedDate__c,LastModifiedDate , 
	    		parentId,parent.RTL_LastSubmittedDate__c,
		    	(Select Id from ChildCampaigns WHERE status != 'Cancelled' and RTL_LastSubmittedDate__c = null ) 
				FROM Campaign
				WHERE id in : camIds
			];

		for( Campaign cam : camList )
		{
			camAllIds.add( cam.Id );
			camToSentCamMap.put( cam.Id ,cam.Id  );

			// Send child campaign , stamp on master campaign if last submit of master is null
			if( cam.parentId != null )
			{
				if( cam.parent.RTL_LastSubmittedDate__c == null )
				{
					camAllIds.add( cam.parentId );
					camToSentCamMap.put( cam.parentId ,cam.Id  );
				}
			}

			// Send master campaign , stamp only child that LastSubmittedDate = null
			if(  cam.ChildCampaigns != null &&  cam.ChildCampaigns.size() > 0 )
			{
				for( Campaign childCam : cam.ChildCampaigns  )
				{
					camAllIds.add( childCam.Id );
					camToSentCamMap.put( childCam.Id ,cam.Id  );
				}
			}
		}

		// Update submit Date
		stampSubmittedDate( camToSentCamMap,camLogMap );		
		for(ID logId : logIds)
		{			
       		RTL_CampaignToHQCallout.transmitData(logId,emailsNotification,timeout);
       	}
        
	}

	public void stampSubmittedDate(MAP<ID,ID> camToSentCamMap,Map<ID,RTL_Campaign_To_HQ_Callout_Log__c> camLogMap )
	{
		// Update Submit date for all Campaigns before send
		Set<ID> camIds = camToSentCamMap.keySet();
		List<Campaign> camList = [SELECT ID,RTL_LastSubmittedDate__c,
			RTL_Campaign_Code_9_digits__c,RTL_Campaign_Code_10_digits__c
			FROM Campaign WHERE Id in :camIds  ];

		for( Campaign preCamObj : camList )
		{
			preCamObj.RTL_LastSubmittedDate__c = System.now();
			//ID sentCampaignId = camToSentCamMap.get(preCamObj.id);
			//preCamObj.RTL_LastSubmittedDate__c = camLogMap.get(sentCampaignId).RTL_Create_date__c;
		}
		Database.update(camList,false);

	}

	@Future(callout=true)
	public static void transmitData(ID logId,List<String> emailsNotification,Integer timeout)
	{
		ID campaignId;
		RTL_Campaign_To_HQ_Callout_Log__c camLog;
		Campaign cam;

		try{
			
			camLog = [SELECT Id, Name, RTL_Status__c,RTL_Status_text__c ,
					RTL_Campaign__r.RecordTypeId,RTL_No_of_Retry__c,RTL_Create_date__c,
					RTL_Campaign__r.Name,RTL_Campaign__c,RTL_Campaign_ID__c,
					RTL_Campaign__r.RTL_Campaign_Code_9_digits__c,
					RTL_Campaign__r.RTL_Campaign_Code_10_digits__c,
					RTL_Last_Call_Date__c
					FROM RTL_Campaign_To_HQ_Callout_Log__c
	                WHERE ID = :logId
	                ];

	    	campaignId = camLog.RTL_Campaign_ID__c;

	    	cam = [SELECT ID,Name,RTL_LastSubmittedDate__c FROM Campaign WHERE ID =:campaignId ];

		}
		catch(exception e){
			system.debug('callout stop, can not find log of campaign.');
			return;
		}

		RTL_Campaign_Endpoint__c endpointSetting = RTL_Campaign_Endpoint__c.getValues('Campaign TO HQ INT01');
		String endPoint = '';
		if( endpointSetting != null )
		{
			 endPoint = endpointSetting.RTL_Endpoint__c;
		}

		RTL_Campaign_Endpoint__c endpointTestSetting = RTL_Campaign_Endpoint__c.getValues('requestb');

		String endPointTest = '';
		if( endpointTestSetting != null )
		{
			endPointTest = endpointTestSetting.RTL_Endpoint__c;
		}

		//==========================================================
		// Prepare primary data for campaign log and transaction
		// Call date use same value of RTL_LastSubmittedDate__c
	    RTL_Campaign_To_HQ_Callout_Transaction__c camTran = new RTL_Campaign_To_HQ_Callout_Transaction__c();
	    camTran.RTL_Campaign__c = campaignId;
		camTran.RTL_Campaign_To_HQ_Callout_Log__c = logId;
		camTran.RTL_Call_Date__c = cam.RTL_LastSubmittedDate__c;

		camLog.RTL_Last_Call_Date__c = cam.RTL_LastSubmittedDate__c;

		//==========================================================

	    String recordType = camLog.RTL_Campaign__r.RecordTypeId;

	    RTL_CampaignToHQ_tempuriOrgSOAP.BasicHttpsBinding_IService  service = new RTL_CampaignToHQ_tempuriOrgSOAP.BasicHttpsBinding_IService();
 		service.timeout_x = timeout; 

		RTL_CampaingToHQ_CampaignServiceSOAP.Campaign camObj = RTL_CampaignToHQCallout.generateCampaingRequest(campaignId);
		
		String resultDesc = '';
		String resultErrorCode = '';
		String resultStatus = '';
		Boolean IsSuccess = false;
		String errorCodeLog = '';

		String logStatus = '';
		String logRemark= '';
		string CampName = cam.Name;
		Decimal logRetry = 0;

		DateTime StartDate, EndDate;

		Boolean connectStatus = true;

		RTL_CampaignToHQ_schemasDatacontractSOAP.Result resultObj;
		List<String> invalidInputList = RTL_CampaignToHQCallout.validateInput(camObj);

		//******** Section for QA, will remove after VIT ****************
		
		if( endPointTest != '' )
		{
			try
			{	
				service.endpoint_x = endPointTest;
				service.manageCampaign(camObj);
			}
			catch(exception e)
			{
				system.debug( 'Test callout for requestb.in:('+ endPointTest  +') ' + e.getMessage() );
			}
		}
		//******** Section for QA, will remove after VIT ****************

		// Case that all request input validation pass
		if( invalidInputList.size() == 0 )
		{
			try
			{
				service.endpoint_x = endPoint;

				StartDate =  datetime.now();
				resultObj =  service.manageCampaign(camObj);
				EndDate =  datetime.now();

				//System.debug('resultObj ' + resultObj);
				//System.debug('camObj ' + camObj);
				//System.debug('TAE : ' + CampName);

				if( resultObj != null &&  resultObj.Status == '1' )
				{

					if( resultObj.Status == '1' )
					{
						logStatus = 'Success';
					}

					resultDesc = resultObj.Description;
					resultStatus = resultObj.Status;
					resultErrorCode = resultObj.ErrorCode;
					IsSuccess = true;

					
				}
				// Case that got null result
				else 
				{

					Decimal attempNo =  camLog.RTL_No_of_Retry__c;
					// Try to retry 2 more times
					if( camLog.RTL_No_of_Retry__c < 3 )
					{

						// reset create date for next retry call
						logStatus = 'Retry';
						logRetry = camLog.RTL_No_of_Retry__c+1;
						logRemark = 'Failed on Attemp #' + attempNo;
					}
					else 
					{
						// Mask this transaction Permanant failed
						logStatus = 'Fail';	
						logRemark = 'Failed after Attemp #' + attempNo;	

					}

					if(resultObj == null)
					{
						resultDesc = 'Call webservice failed';
						resultStatus = 'Fail';
						resultErrorCode = '';
						
					}
					else if ( resultObj != null && resultObj.Status == '0')
					{
						resultDesc = resultObj.Description;
						resultStatus = resultObj.Status;
						resultErrorCode = resultObj.ErrorCode;
					}
					//callStatus = false;
				}
			}
			catch(exception e)
			{
			//	system.debug( 'Call soap execption: ' + e.getMessage() );

				logStatus = 'Fail';
				logRemark = 'Call soap execption: ' + e.getMessage();
				resultDesc = 'Call soap execption: ' + e.getMessage();
				resultStatus = 'Fail';
				resultErrorCode = '';				
			}

		}
		// Case for validation failed
		else 
		{
			logStatus = 'Fail';
			logRemark= 'Input Validation error';	
			resultDesc = 'Failed Validation on filed(s): ' + String.join(invalidInputList, ',');
			resultStatus = 'Fail';
			resultErrorCode = '';
		}
		

		try{	

			// Failed after 3 times sent notifiaction email
			if( logStatus == 'Fail' )
			{
				RTL_CampaignToHQCallout.sendNotificationEmail(campaignId,emailsNotification);
			}
			// System.debug('logStatus :' + logStatus);
			// Failed call log to Online service log

			User u = [SELECT Id,Name,Employee_ID__c FROM User WHERE id =:UserInfo.getUserId() ];
			RTL_Online_Service_Log__c osLog = new RTL_Online_Service_Log__c();

			if( logStatus == 'Fail' || logStatus == 'Retry' )
			{
				if( resultErrorCode == '' )
				{
					errorCodeLog = 'Salesforce Error';
				} 
				else 
				{
					errorCodeLog = resultErrorCode;
				}

				// resultDesc = errorCodeLog + '|' + resultDesc;
			}

			String campaignCode = '';
			if( camLog.RTL_Campaign__r.RTL_Campaign_Code_10_digits__c != '' && camLog.RTL_Campaign__r.RTL_Campaign_Code_10_digits__c != null )
			{
				campaignCode = camLog.RTL_Campaign__r.RTL_Campaign_Code_10_digits__c;
			}
			else 
			{
				campaignCode = camLog.RTL_Campaign__r.RTL_Campaign_Code_9_digits__c;
			}

			// Account acc = new Account();
			// if( camLog.RTL_Campaign__r.Name != null )
			// {
			// 	acc = [SELECT Id ,Core_Banking_Suggested_Segment__c, Name FROM Account WHERE Name =: camLog.RTL_Campaign__r.Name LIMIT 1];
			// }

			// osLog.RTL_Customer_Name__c = camLog.RTL_Campaign__r.Name;
			// osLog.RTL_Error_Message__c = resultDesc;
			// osLog.RTL_Mulesoft_Log_Id__c = '';
			// osLog.RTL_Name_of_User__c = u.Name;
			// osLog.RTL_RM_ID__c = campaignCode;
			// osLog.RTL_Service_Name__c = 'CampaignMaster';
			// osLog.RTL_Is_Success__c = IsSuccess;

			// insert osLog;

			RTL_CampaignUtil.insertOnlineLogWithResponseINT01(errorCodeLog, resultDesc, campaignCode, 'CampaignMaster', CampName,
			 JSON.serialize(camObj), JSON.serialize(resultObj), StartDate, EndDate);

			// In case result more than 255 truncate it
			if( resultDesc.length() > 255 )
			{
				resultDesc = resultDesc.substring(0,255);
			}

			camLog.RTL_Status__c = logStatus;
			camLog.RTL_No_of_Retry__c = logRetry;
			camLog.RTL_Status_text__c = resultDesc;
			//camLog.RTL_Last_Call_Date__c = Datetime.now();
			camLog.RTL_Status_Code__c = resultErrorCode;
			camLog.RTL_Host_Status__c = resultStatus;
			update camLog;

			// For transaciton, if status is retry , log transaction to failed
			camTran.RTL_Status__c = (logStatus=='Retry')?'Fail':logStatus;
			camTran.RTL_Remark__c = logRemark;	
			camTran.RTL_Status_Text__c = resultDesc;
			//camTran.RTL_Call_Date__c = Datetime.now();
			camTran.RTL_Status_Code__c = resultErrorCode;
			insert camTran;

			// Recursive retry
			// Fail validate input not retry
			if ( invalidInputList.size() == 0 )
			{
				if( camLog.RTL_Status__c == 'Retry' )
				{
					camLog.RTL_Status__c = 'Processing';
					update camLog;				

					List<ID> logIdList = new List<ID>();
					logIdList.add(camLog.id);
					RTL_CampaignToHQCallout calloutProcess = new RTL_CampaignToHQCallout(logIdList);
					System.enqueueJob(calloutProcess);
				}
			}
		} 
		catch(exception e)
		{
			system.debug('Loging exception: ' + e.getMessage());

			logStatus = 'Fail';
			logRemark =  'Loging exception: '+e.getMessage();
			logRetry = camLog.RTL_No_of_Retry__c;
			resultDesc = 'Loging exception: '+e.getMessage();
			resultErrorCode = '';
			resultStatus = 'Fail';
			if( resultDesc.length() > 255 )
			{
				resultDesc = resultDesc.substring(0,255);
			}
			
			camLog.RTL_Status__c = logStatus;
			camLog.RTL_No_of_Retry__c = logRetry;
			camLog.RTL_Status_text__c = resultDesc;
			camLog.RTL_Last_Call_Date__c = Datetime.now();
			camLog.RTL_Status_Code__c = resultErrorCode;
			camLog.RTL_Host_Status__c = resultStatus;
			update camLog;

			// For transaciton, if status is retry , log transaction to failed
			camTran.RTL_Status__c = (logStatus=='Retry')?'Fail':logStatus;
			camTran.RTL_Remark__c = logRemark;	
			camTran.RTL_Status_Text__c = resultDesc;
			camTran.RTL_Call_Date__c = Datetime.now();
			camTran.RTL_Status_Code__c = resultErrorCode;
			insert camTran;
		}
	}

	public static List<String> validateInput(RTL_CampaingToHQ_CampaignServiceSOAP.Campaign camObj)
	{
		List<String> invalidInputList = new List<String>();

		if( camObj == null )
		{
			invalidInputList.add('Generate Campaign input request error.');
		}
		else
		{
			if( camObj.CreatedBy == '' || camObj.CreatedBy == null )
			{
				invalidInputList.add( camObj.Name + ' : Owner.Employee_ID__c');
			}
			if( camObj.Created == null )
			{
				invalidInputList.add( camObj.Name +': CreatedDate');
			}
			if( camObj.UpdatedBy == '' || camObj.UpdatedBy == null )
			{
				invalidInputList.add( camObj.Name +': LastModifiedBy.Employee_ID__c');
			}
			if( camObj.Updated == null )
			{
				invalidInputList.add( camObj.Name + ' : LastModifiedDate');
			}
			if( camObj.Name == '' || camObj.Name == null )
			{
				invalidInputList.add( camObj.Name + ' : RTL_Campaign_Code_9_Digit__c');
			}
			if( camObj.Description == '' || camObj.Description == null )
			{
				invalidInputList.add( camObj.Name + ' : Name');
			}
			if( camObj.PlannedInMarketDate == null )
			{
				invalidInputList.add( camObj.Name + ' : StartDate');
			}
			if(  camObj.PlannedEndDate == null )
			{
				invalidInputList.add( camObj.Name + ' : EndDate');
			}
			if( camObj.CampaignID_SF == '' || camObj.CampaignID_SF == null )
			{
				invalidInputList.add( camObj.Name + ' : ID');
			}
			/*
			if( camObj.TokenID == '' || camObj.TokenID == null )
			{
				invalidInputList.add('Master('+ camObj.Name +'): CustomMetada.PB_Token_ID__c');
			}
			*/

			
			for( RTL_CampaignToHQ_schemasDatacontractSOAP.CampignActivity childCam : camObj.Activity.CampignActivity )
			{
				if( childCam.CampaignActivityID_SF == '' || childCam.CampaignActivityID_SF == null )
				{
					invalidInputList.add( camObj.Name + ' : ID');
				}

				if( childCam.CreateBy == '' || childCam.CreateBy == null )
				{
					invalidInputList.add( camObj.Name + ' : Owner.Employee_ID__c');
				}
				if( childCam.UpdatedBy == '' || childCam.UpdatedBy == null )
				{
					invalidInputList.add( camObj.Name + ' : UpdatedBy.Employee_ID__c');
				}
				if( childCam.Created == null )
				{
					invalidInputList.add( camObj.Name + ' : CreatedDate');
				}
				if( childCam.Updated == null )
				{
					invalidInputList.add( camObj.Name + ' : LastModifiedDate');
				}
				if( childCam.Name == '' || childCam.Name == null )
				{
					invalidInputList.add( camObj.Name + ' : RTL_Campaign_Code_10_digit__c');
				}
				if( childCam.Description == '' || childCam.Description == null )
				{
					invalidInputList.add( camObj.Name + ' : Name');
				}
				if( childCam.PlannedInMarketDate == null )
				{
					invalidInputList.add( camObj.Name + ' : StartDate');
				}
				if( childCam.PlannedEndDate == null )
				{
					invalidInputList.add( camObj.Name + ' : RTL_Campaign_Objective__c');
				}
				if( childCam.Priority == '' || childCam.Priority == null )
				{
					invalidInputList.add( camObj.Name + ' : RTL_Priority__c');
				}
				if( childCam.CampaignActivitySubTypeID == '' || childCam.CampaignActivitySubTypeID == null )
				{
					invalidInputList.add( camObj.Name + ' : RTL_Campaign_Sub_Type__c');
				}
				if( childCam.TreatmentName == '' || childCam.TreatmentName == null )
				{
					invalidInputList.add( camObj.Name + ' : RTL_Campaign_Channel__c');
				}
				
			}
		}

		

		return invalidInputList;
	}

	public static RTL_CampaingToHQ_CampaignServiceSOAP.Campaign generateCampaingRequest(String camId)
	{
		MasterChildCampaing mmco = getMasterChildCampaingObject(camId);

		RTL_CampaingToHQ_CampaignServiceSOAP.Campaign camObj;

		if( mmco.master != null && mmco.childrenList != null )
		{
			camObj = genCampaingObject(mmco.master,mmco.childrenList);
		}

		return camObj;
	}

	public static MasterChildCampaing getMasterChildCampaingObject(String camId)
	{
		MasterChildCampaing mcco = new MasterChildCampaing();
		Campaign masterCam = new Campaign();
		List<Campaign> childrenCamList = new List<Campaign>();


		Campaign cam = queryCampaign(camId).get(0);

		String recordTypeId = cam.RecordTypeId;

		if( MasterCampaignRecordTypeId.contains(recordTypeId) )
		{
			masterCam = cam;
			childrenCamList = queryChildrenCampaign(camId);

		}
		// Child
		else 
		{
			Campaign childCam = cam;
			if( childCam.parentId != null )
			{
				childrenCamList.add(childCam);
				masterCam = queryCampaign(childCam.parentId).get(0);
			}
			else 
			{
				childrenCamList = null;
				masterCam = null;
			}
		}

		mcco.master = masterCam;
		mcco.childrenList = childrenCamList;

		return mcco;
	}

	private static List<Campaign> queryChildrenCampaign(String camID)
	{
		return [ SELECT id,name,parentId,
				RTL_Campaign_Code_9_digits__c,RTL_Campaign_Code_10_digits__c,RTL_Campaign_Objective__c,
				RTL_Campaign_Sub_Type__c,RTL_Priority__c,StartDate,EndDate,RTL_Campaign_Stage__c,
				Status,RTL_Campaign_Channel__c,RTL_Call_Start_Date__c,RTL_Call_End_Date__c,
				RTL_Tracking_Type__c,RecordTypeId,LastModifiedBy.Employee_ID__c,LastModifiedDate,
				Approvedflag__c,Owner.Employee_ID__c,CreatedDate,RTL_CampaignProduct__c,RTL_LastSubmittedDate__c,
				RTL_Campaign_Sub_Type_child2__c
				FROM Campaign WHERE ParentId = :camID
				AND status != 'Cancelled' ];
	}

	private static List<Campaign> queryCampaign(String camID)
	{
		return [ SELECT id,name,parentId,
				RTL_Campaign_Code_9_digits__c,RTL_Campaign_Code_10_digits__c,RTL_Campaign_Objective__c,
				RTL_Campaign_Sub_Type__c,RTL_Priority__c,StartDate,EndDate,RTL_Campaign_Stage__c,
				Status,RTL_Campaign_Channel__c,RTL_Call_Start_Date__c,RTL_Call_End_Date__c,
				RTL_Tracking_Type__c,RecordTypeId,LastModifiedBy.Employee_ID__c,LastModifiedDate,
				Approvedflag__c,Owner.Employee_ID__c,CreatedDate,RTL_CampaignProduct__c,RTL_LastSubmittedDate__c,
				RTL_Campaign_Sub_Type_child2__c
				FROM Campaign WHERE id = :camID ];
	}

	public static void sendNotificationEmail(String cId,List<String> emailsNotification)
    {
    	// Ignore sending email if no email data in custom meta data
    	if( emailsNotification.size() == 0 )
    	{
    		return;
    	}	

    	Campaign camObject = [SELECT ID,Name,Owner.Email FROM Campaign WHERE ID =:cId ];
        
        //Add send meail to owner - TMB don't want to send email to Campaign Owner
    	//emailsNotification.add(camObject.Owner.Email);
        
        String tagerUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/ui/support/servicedesk/ServiceDeskPage#/apex/RTL_CampaignToHQResubmit?campaign_id=' + cId;
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        //message.toAddresses = new String[] { userEmail };
        message.toAddresses = emailsNotification;

        List<String> subjectParam = new String[]{ camObject.Name };
        List<String> bodyParam = new String[]{ camObject.Name , tagerUrl };

        String subjectText = String.format( Label.RTL_Campaign_Resubmit_Error_Email_Subject , subjectParam );
        String bodyText = String.format( Label.RTL_Campaign_Resubmit_Error_Email_Body , bodyParam );

        message.subject = subjectText;
        message.setHtmlBody(bodyText);

        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
    }

	public static RTL_CampaingToHQ_CampaignServiceSoap.Campaign genCampaingObject(Campaign masterCam,List<Campaign> childCams)
	{
		RTL_CampaingToHQ_CampaignServiceSoap.Campaign campaignObject = new RTL_CampaingToHQ_CampaignServiceSoap.Campaign();
		
		// Request from TMB - All Date time send to UTC time but +7
		campaignObject.CreatedBy = masterCam.Owner.Employee_ID__c;
		campaignObject.Created = masterCam.CreatedDate.addHours(7);
		campaignObject.UpdatedBy = masterCam.LastModifiedBy.Employee_ID__c;
		if( masterCam.RTL_LastSubmittedDate__c  != null )
		{
			campaignObject.Updated = masterCam.RTL_LastSubmittedDate__c.addHours(7);
		}
		campaignObject.Name = masterCam.RTL_Campaign_Code_9_digits__c;
		campaignObject.Description = masterCam.Name;
		campaignObject.CampaignStatus_SF = masterCam.RTL_Campaign_Stage__c;
		campaignObject.PlannedInMarketDate =  masterCam.StartDate;
		campaignObject.PlannedEndDate = masterCam.EndDate;
		campaignObject.ApproveFlag =  (masterCam.Approvedflag__c?'1':'0');
		//campaignObject.TokenID = '';
		campaignObject.CampaignID_SF = masterCam.id;
		

		RTL_CampaignToHQ_schemasDatacontractSOAP.ArrayOfCampignActivity atv = new RTL_CampaignToHQ_schemasDatacontractSOAP.ArrayOfCampignActivity();
		atv.CampignActivity = new List<RTL_CampaignToHQ_schemasDatacontractSOAP.CampignActivity>();

		// Child Campaign
		for(Campaign childCam : childCams )
		{
			RTL_CampaignToHQ_schemasDatacontractSOAP.CampignActivity camAct = new RTL_CampaignToHQ_schemasDatacontractSOAP.CampignActivity();

			//camAct.CampaignID_SF = masterCam.id;
			//camAct.CampaignCode = childCam.RTL_Campaign_Code_9_digits__c;
			camAct.CampaignActivityID_SF = childCam.Id;
			//camAct.CampaignBatchCode = childCam.RTL_Campaign_Code_10_digits__c;

			camAct.CreateBy = childCam.Owner.Employee_ID__c;
			camAct.UpdatedBy = childCam.LastModifiedBy.Employee_ID__c;
			camAct.Created = childCam.CreatedDate.addHours(7);
			if( childCam.RTL_LastSubmittedDate__c  != null )
			{
				camAct.Updated = childCam.RTL_LastSubmittedDate__c.addHours(7);
			}
			camAct.Name = childCam.RTL_Campaign_Code_10_digits__c;
			camAct.Description = childCam.Name;
			camAct.PlannedInMarketDate =  string.valueOf(childCam.StartDate);
			camAct.PlannedEndDate =  string.valueOf(childCam.EndDate);
			camAct.CampaignActivityTypeID = masterCam.RTL_Campaign_Objective__c;

			String priorityId = '';
			if( masterCam.RTL_Priority__c != null && masterCam.RTL_Priority__c.split(' ').size() > 0 )
			{
				priorityId =  masterCam.RTL_Priority__c.split(' ').get(0);
			}
			camAct.Priority = priorityId;

			String subtypeId = '';
			// if(  masterCam.RTL_Campaign_Sub_Type__c != null  && masterCam.RTL_Campaign_Sub_Type__c.split(' ').size() > 0 )
			// {
			// 	subtypeId =  masterCam.RTL_Campaign_Sub_Type__c.split(' ').get(0);
			// }

			if(  childCam.RTL_Campaign_Sub_Type_child2__c != null  && childCam.RTL_Campaign_Sub_Type_child2__c.split(' ').size() > 0 )
			{
				subtypeId = childCam.RTL_Campaign_Sub_Type_child2__c.split(' ').get(0);
			}

			// System.debug('ชาย SUB_2 :' + subtypeId + childCam.RTL_Campaign_Sub_Type_child2__c);

			camAct.CampaignActivitySubTypeID = subtypeId;
			
			camAct.CampaignActivityStatusSF = childCam.status;

			
			camAct.CallStartDate = childCam.RTL_Call_Start_date__c;
			camAct.CallEndDate = childCam.RTL_Call_End_Date__c;



			String treatmentName = '';
			List<String> treatmentList = new List<String>();

			if( childCam.RTL_Campaign_Channel__c != null )
			{
				for( String treatmentText : childCam.RTL_Campaign_Channel__c.split(';') )
				{
					Integer spaceIdx = treatmentText.indexOF(' ');
					if( spaceIdx > 0 )
					{
						treatmentList.add( treatmentText.substring( spaceIdx+1, treatmentText.length() ) );
					}
				}

				treatmentName = String.join(treatmentList, ';');
			}

			camAct.TreatmentName = treatmentName;
			camAct.ReferenceCode = childCam.RTL_Tracking_Type__c;

			//Generate product string
			//String productCode = '';
			//List<Retail_Campaign_Products__c> rcpList = [SELECT id,name,
			//			RTL_Campaign__c,RTL_Product_Group__c,RTL_Sub_Group__c,
			//			RTL_Retail_Product_Master__c,
			//			RTL_Retail_Product_Master__r.Product_Code__c
			//			FROM Retail_Campaign_Products__c
			//			WHERE RTL_Campaign__c = :childCam.Id
			//			];

			//for( Retail_Campaign_Products__c rcp: rcpList )
			//{
			//	if( rcp.RTL_Retail_Product_Master__c != null && rcp.RTL_Retail_Product_Master__r.Product_Code__c != null )
			//	{
			//		productCode += '3:'+rcp.RTL_Retail_Product_Master__r.Product_Code__c+';';
			//	}
			//	else if ( rcp.RTL_Sub_Group__c != null )
			//	{
			//		productCode += '2:'+rcp.RTL_Sub_Group__c+';';
			//	}
			//	else if( rcp.RTL_Product_Group__c != null )
			//	{
			//		productCode += '1:'+rcp.RTL_Product_Group__c+';';
			//	}
			//}

			//camAct.ProductCode = (productCode=='')?null:productCode;
			camAct.ProductCode = childCam.RTL_CampaignProduct__c;
			camAct.CampaignId = childCam.Id;
			

			atv.CampignActivity.add(camAct);
		}

		campaignObject.Activity = atv;

		return campaignObject;

	}

	//public static DateTime getUTCDateTime(DateTime dt){
	//    Datetime GMTDate = Datetime.newInstanceGmt(
	//                            dt.yearGmt(),
	//                            dt.monthGmt(),
	//                            dt.dayGmt(),
	//                            dt.hourGmt(),
	//                            dt.minuteGmt(),
	//                            dt.secondGmt() );
	                            
	//    return GMTDate;
	//}

}