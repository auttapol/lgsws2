public with sharing class RTL_CampaignToHQResubmitController {

	class TransactionWrapper{
		public RTL_Campaign_To_HQ_Callout_Transaction__c transObj{get;set;}
		public String statusText {get;set;}
	}

	public List<TransactionWrapper> transObj {get;set;}

	private RTL_Campaign_To_HQ_Callout_Log__c ccl;

	public List<RTL_Campaign_To_HQ_Callout_Transaction__c> cctList  {get;set;}
	
	private String campaignId;
	private String recordTypeId;
	private Campaign cam {get;set;}

	public String result {get;set;}
	public String resultText {get;set;}
	public String campaingName {get;set;}

	// Flag to tell this campaing being processed or not
	public Boolean isCalling {get;set;}

	// Flag to tell this campaing allowed to resubmit or not
	public Boolean isApproved {get;set;}

	public RTL_CampaignToHQResubmitController() {

		campaignId = ApexPages.currentPage().getParameters().get('campaign_id');
		
		try{
			cam = [SELECT ID,name,Approvedflag__c FROM Campaign WHERE ID=:campaignId];
        	campaingName = cam.Name;
		} catch(Exception e) {

			isApproved = false;
		}

		if( cam.Approvedflag__c == false )
		{
			isApproved = false;
		}
		else 
		{
			isApproved = true;	
		}

		try {

			ccl = [SELECT Id, Name, RTL_Status__c,RTL_Status_text__c ,RTL_Campaign__r.RecordTypeId,
					RTL_Campaign__r.Name,RTL_Campaign__c,RTL_Campaign_ID__c
					FROM RTL_Campaign_To_HQ_Callout_Log__c 
	                WHERE RTL_Campaign__c = :campaignId
	                LIMIT 1
	              	];
	         
	    // If no Log Object created, then create new
	    } catch(Exception e) {
			
	    	ccl = new RTL_Campaign_To_HQ_Callout_Log__c();
			ccl.RTL_Campaign_ID__c = campaignId;
			ccl.RTL_Campaign__c = campaignId;
			ccl.RTL_No_of_Retry__c = 0;
			ccl.RTL_Status__c = 'None';

		}

		cctList = [SELECT Id,RTL_Status__c,RTL_Status_Code__c,RTL_Status_Text__c,
					RTL_Call_Date__c,RTL_Remark__c
	        		FROM RTL_Campaign_To_HQ_Callout_Transaction__c
	        		WHERE RTL_Campaign__c = :campaignId
	        		ORDER BY RTL_Call_Date__c DESC , name DESC
	        		]; 

        result = getStatusText(ccl.RTL_Status__c);
        resultText = ccl.RTL_Status_text__c;
        //isCalling = false;

        recordTypeId = ccl.RTL_Campaign__r.RecordTypeId;

        //if( ccl.RTL_Status__c == 'Processing' || ccl.RTL_Status__c == 'Open' || ccl.RTL_Status__c == 'Retry' )
        if( ccl.RTL_Status__c == 'Processing' )
        {
        	isCalling = true;
        }
        else 
        {
        	isCalling = false;
        }

        transObj = new List<TransactionWrapper>();

        for( RTL_Campaign_To_HQ_Callout_Transaction__c cctl : cctList )
        {
        	TransactionWrapper transItem = new TransactionWrapper();
        	transItem.transObj = cctl;
        	transItem.statusText = getStatusText(cctl.RTL_Status__c);
        	transObj.add(transItem);
        }

        if( !isApproved )
        {
        	//ApexPages.addMessages(Label.RTL_Campaign_Resubmit_Not_Available);
        	ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,Label.RTL_Campaign_Resubmit_Not_Available));
        }

        if( isCalling )
        {
        	//ApexPages.addMessages(Label.RTL_Campaign_Resubmit_Notice);
        	ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.RTL_Campaign_Resubmit_Notice));
        }
        
	}


	public RTL_Campaign_To_HQ_Callout_Log__c getLog()
	{
		return ccl;
	}

	public PageReference resubmitRequest()
	{
		
		RTL_CampaignToHQCalloutQueue calloutProcess = new RTL_CampaignToHQCalloutQueue();
		
		List<Id> campaignIds = new List<Id>();
		campaignIds.add(campaignId);

		calloutProcess.resubmitCampaigns(campaignIds);

		return ApexPages.currentPage().setRedirect(true);
	}

	//public Continuation resubmitRequest() {
	//	result = 'Processing...';
	//	resultText = 'Processing Resubmit request...';
	//	//isCalling = true;
	//	try
	//	{
	//		Integer TIMEOUT_INT_SECS = 60;  
	//       	Continuation cont = new Continuation(TIMEOUT_INT_SECS);
	//       	cont.continuationMethod = 'processResponse';

	//       	RTL_CampaignToHQ_WSDL_SAMPLE.Campaign camObj = RTL_CampaignToHQCalloutWebServiceQueue.generateCampaingRequest(campaignId,recordTypeId);

	//       	AsyncRTL_CampaignToHQ_WSDL_Sample.AsyncRTL_CampaignToHQ_SOAP service = new AsyncRTL_CampaignToHQ_WSDL_Sample.AsyncRTL_CampaignToHQ_SOAP();
	//       	service.SessionHeader = new RTL_CampaignToHQ_WSDL_SAMPLE.SessionHeader_element();
	//		service.SessionHeader.sessionId =  UserInfo.getSessionId();
	//        camFuture = service.beginManageCampaign(cont,camObj);     

	//    	return cont; 

	//    } catch(Exception e) {
	//    	system.debug(e.getMessage());
	//		ApexPages.addMessages(e);
	//		return null;
	//	}

 //   }

 //   public Object processResponse() {    
 //   	//isCalling = false;
	//    try
	//    {
	//       result = camFuture.getValue().Status;
	//       resultText = camFuture.getValue().Description;

	//       refreshResubmitLogTable();

 //  		}
 //      	catch(Exception e)
	//	{
	//		//String pageMessage = 'Web services callout error with inner exception : ' + e.getMessage();
	//		ApexPages.addMessages(e);
	//	}

	//	return null; 
 //   }

    public PageReference cancel() {

    	PageReference detailpage;
        detailpage = new ApexPages.StandardController(cam).view();
        detailpage.setRedirect(true);          
        return detailpage;
    	
    	//pageReference pg =  new PageReference('/' + campaignId 	);
    	//pg.setRedirect(true);
    	//return pg;

    }

    public String getStatusText(String statusCode)
    {
    	if( statusCode == 'Processing' )
    	{
    		return Label.RTL_Campaign_Resubmit_Status_Processing;
    	}
    	else if( statusCode == 'Success' )
    	{
    		return Label.RTL_Campaign_Resubmit_Status_Success;
    	}
    	else if( statusCode == 'Fail' )
    	{
    		return Label.RTL_Campaign_Resubmit_Status_Failed;
    	}
    	else 
    	{
    		return Label.RTL_Campaign_Resubmit_Status_Unknown;
    	}
    }
}