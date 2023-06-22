public class RTL_CampaigntoHQButtonController {

//	private ApexPages.StandardController standardSetController;
	public List<RTL_Campaign_To_HQ_Callout_Log__c> failLogList {get;set;}
	public RTL_Campaign_To_HQ_Callout_Log__c logObj {get;set;}
	public String PageMessage {get;set;}

	public RTL_CampaigntoHQButtonController(ApexPages.StandardSetController controller) {
		//controller.setPageSize(10);
		//this.standardSetController = standardSetController;
		DateTime today = system.now();

		logObj = new RTL_Campaign_To_HQ_Callout_Log__c();

		// Get list of failed or processing more than 1 day
		failLogList = [SELECT id,Name,RTL_Status__c  , RTL_Last_Call_Date__c,RTL_Campaign_ID__c,
					RTL_Campaign__r.Name
					FROM RTL_Campaign_To_HQ_Callout_Log__c
					WHERE RTL_Status__c = 'Fail' 
					OR ( RTL_Status__c = 'Processing' AND RTL_Last_Call_Date__c != LAST_N_DAYS:1 )
					ORDER BY RTL_Last_Call_Date__c DESC
					];

	}


	public PageReference resubmitAll()
	{


		List<Id> campaignIds = new List<Id>();

		for( RTL_Campaign_To_HQ_Callout_Log__c log : failLogList )
		{
			campaignIds.add(log.RTL_Campaign_ID__c);
		}

		RTL_CampaignToHQCalloutQueue calloutProcess = new RTL_CampaignToHQCalloutQueue();

		calloutProcess.resubmitCampaigns(campaignIds);

		//ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Successfully Resubmit All.'));

		PageMessage = Label.RTL_Campaign_Resubmit_All_Notice;
		return null;
	}

}