public class RTL_CampaignToHQCalloutQueue 
{

	public RTL_CampaignToHQCalloutQueue()
	{
	}

	//public void execute(QueueableContext context) {
	//public void execute(){
		
	//	// Pick up campaign that oldest create to process first
	//	// When retry , update create time to now 
	//	List<RTL_Campaign_To_HQ_Callout_Log__c> campLogToProcess = [SELECT ID,RTL_Campaign_ID__c, 
	//		RTL_Campaign__r.RecordTypeId , RTL_No_of_Retry__c , RTL_Status__c
	//		FROM RTL_Campaign_To_HQ_Callout_Log__c 
	//		WHERE RTL_Status__c IN ('Open','Retry') AND RTL_Campaign_ID__c != null 
	//		ORDER BY RTL_Create_date__c,RTL_No_of_Retry__c
	//		LIMIT 1
	//		];

	//	//================= Master Campaing Callout =======================
	//	if( campLogToProcess.size() > 0 )
	//	{
			
	//		RTL_Campaign_To_HQ_Callout_Log__c camLog = campLogToProcess.get(0);

	//		String camId = camLog.RTL_Campaign_ID__c;

	//		// Update processing state

	//		camLog.RTL_Status__c = 'Processing';
	//		camLog.RTL_Last_Call_Date__c = Datetime.now();
			
	//		update camLog; 

	//		// Create transaction
	//		RTL_Campaign_To_HQ_Callout_Transaction__c camTran = new RTL_Campaign_To_HQ_Callout_Transaction__c();
	//		camTran.RTL_Campaign__c = camId;
	//		camTran.RTL_Campaign_To_HQ_Callout_Log__c = camLog.id;
	//		camTran.RTL_Call_Date__c = Datetime.now();
	//		camTran.RTL_Status_Text__c = 'Processing';

	//		insert camTran;

	//		// Chain to process callout
	//		// Gade comment - will change to call directly to remove recursive queue
	//		RTL_CampaignToHQCalloutWebServiceQueue calloutWebServiceProcess = new RTL_CampaignToHQCalloutWebServiceQueue(camLog,camTran,userSessionId);

	//		if (!Test.isRunningTest())
	//		{
	//			System.enqueueJob(calloutWebServiceProcess);
	//		}

	//	}
	//	else 
	//	{
	//		system.debug('Finish - no queue');	
	//	}
	//}

	public void resubmitCampaigns(List<ID> campaignIds )
	{

		// Get existing call out log to update
		List<RTL_Campaign_To_HQ_Callout_Log__c> existingLog = [SELECT Id, Name, RTL_Status__c,RTL_Status_text__c ,
					RTL_Campaign__r.RecordTypeId,RTL_No_of_Retry__c,RTL_Create_date__c,
					RTL_Campaign__r.Name,RTL_Campaign__c,RTL_Campaign_ID__c
					FROM RTL_Campaign_To_HQ_Callout_Log__c
	                WHERE RTL_Campaign__c IN :campaignIds
	                ];

        MAP<ID,RTL_Campaign_To_HQ_Callout_Log__c> camIdLogMap = new MAP<ID,RTL_Campaign_To_HQ_Callout_Log__c>();
        for( RTL_Campaign_To_HQ_Callout_Log__c log : existingLog )
        {
        	camIdLogMap.put( log.RTL_Campaign_ID__c , log );
        }


        List<RTL_Campaign_To_HQ_Callout_Log__c> updateLog = new List<RTL_Campaign_To_HQ_Callout_Log__c>();

        for( ID camId : campaignIds )
        {
        	// Existing Log
        	if( camIdLogMap.containsKey(camId) )	
        	{
        		//If status is Open , Retry
        		RTL_Campaign_To_HQ_Callout_Log__c l = camIdLogMap.get(camId);

        		// Ignore Processing status
        		// Reset campaign log data
        		//if( l.RTL_Status__c != 'Processing' )
        		//{
        			l.RTL_Status__c = 'Processing';
        			l.RTL_Status_text__c = '';
        			l.RTL_No_of_Retry__c = 1;
					//l.RTL_Create_date__c = Datetime.now();
					updateLog.add(l);
        		//}

        	}
        	// No exist log
        	else 
        	{
        		// Create new log
    		    RTL_Campaign_To_HQ_Callout_Log__c l = new RTL_Campaign_To_HQ_Callout_Log__c();
    			l.RTL_Status__c = 'Processing';
    			l.RTL_Status_text__c = '';
    			l.RTL_No_of_Retry__c = 1;
				l.RTL_Create_date__c = Datetime.now();
				l.RTL_Campaign_ID__c = camId;
				l.RTL_Campaign__c = camId;
				updateLog.add(l);
        		
        	}
        }
        // Update initiate status to all campaign in Log table
        upsert updateLog RTL_Campaign_ID__c;

        // Process call out for each campaign
        // split to 50 each async job

        List<ID> logIdList = new List<ID>();
        for( RTL_Campaign_To_HQ_Callout_Log__c log : updateLog ) {
			// Check for state change

			logIdList.add(log.id);

			// Set callout size to 50 to avoid limit reach when retry
			if( logIdList.size() >= 50 )
			{
				RTL_CampaignToHQCallout calloutProcess = new RTL_CampaignToHQCallout(logIdList);
				System.enqueueJob(calloutProcess);

				logIdList = new List<ID>();
			}

		}
		if(  logIdList.size() > 0 )
	    {
	        RTL_CampaignToHQCallout calloutProcess = new RTL_CampaignToHQCallout(logIdList);
			System.enqueueJob(calloutProcess);
	    }

        

	}


}