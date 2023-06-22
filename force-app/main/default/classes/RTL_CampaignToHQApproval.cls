public class RTL_CampaignToHQApproval {


	public static void calloutCampaingToHQ(list<campaign> listNewCampaign, Map<ID,Campaign> mapOldCampaign)
	{

		Recordtype rt = [ SELECT ID,name from Recordtype WHERE sObjectType ='Campaign' AND name = 'Master Campaign' ];
		String MasterCampaignRecordTypeId = rt.id;

		List<Id> campaignIds = new List<Id>();

		for (Campaign newCam : listNewCampaign )
		{
			Campaign oldCam = mapOldCampaign.get(newCam.id);

			// Check if approval flag is true
			if( newCam.Approvedflag__c == true )
			{
				boolean newCampaignApprove = false;
				// New campaign with approval flag is true
				//system.debug('gade: oldcam ' + oldCam);
				if ( oldCam == null )
				{
					newCampaignApprove = true;
				}

				// Check if tracking filed is change , or new campaign created with approval flag true
				if ( newCampaignApprove || isTrackingFiledChange(oldCam,newCam) )  
				{
					campaignIds.add(newCam.id);
				}

			}
		}

		RTL_CampaignToHQCalloutQueue calloutProcess = new RTL_CampaignToHQCalloutQueue();
		calloutProcess.resubmitCampaigns(campaignIds);

	}


	private static boolean isTrackingFiledChange(Campaign oldCam,Campaign newCam)
	{
		List<String> trackingFields = new List<String> {
			'Name',
			'RTL_Campaign_Code_9_digits__c',
			'RTL_Campaign_Code_10_digits__c',
			'RTL_Campaign_Objective__c',
			'RTL_Campaign_Sub_Type_child2__c',
			'RTL_Campaign_Sub_Type__c',
			'RTL_Priority__c',
			'StartDate',
			'EndDate',
			'RTL_Campaign_Stage__c',
			'Status',
			'RTL_Campaign_Channel__c',
			'RTL_Call_Start_Date__c',
			'RTL_Call_End_Date__c',
			'RTL_Tracking_Type__c',
			'RTL_CampaignProduct__c'
		};

		boolean isChange = false;

		for( String fieldApi : trackingFields )
		{
			if( oldCam.get(fieldApi) != newCam.get(fieldApi) )
			{
				//system.debug('gade: tracking field change ' + fieldApi);
				//system.debug('gade: ' +  oldCam.get(fieldApi) );
				//system.debug('gade: ' +  newCam.get(fieldApi) );
				isChange = true;
				break;
			}
		}

		return isChange;
	}

	public static void updateCampaignProductString(Set<ID> camIds)
	{
		MAP<ID,String> camIdProductStringMap = new MAP<ID,String>();

		List<Retail_Campaign_Products__c> rcpList = [SELECT id,name,
							RTL_Campaign__c,RTL_Product_Group__c,RTL_Sub_Group__c,
							RTL_Retail_Product_Master__c,
							RTL_Retail_Product_Master__r.Product_Code__c
							FROM Retail_Campaign_Products__c
							WHERE RTL_Campaign__c in :camIds
							];

		for( Retail_Campaign_Products__c rcp : rcpList )
		{
			String productCode = '';
			if( camIdProductStringMap.containsKey(rcp.RTL_Campaign__c) )
			{
				productCode = camIdProductStringMap.get(rcp.RTL_Campaign__c);
			}

			if( rcp.RTL_Retail_Product_Master__c != null && rcp.RTL_Retail_Product_Master__r.Product_Code__c != null )
			{
				productCode += '3:'+rcp.RTL_Retail_Product_Master__r.Product_Code__c+';';
			}
			else if ( rcp.RTL_Sub_Group__c != null )
			{
				productCode += '2:'+rcp.RTL_Sub_Group__c+';';
			}
			else if( rcp.RTL_Product_Group__c != null )
			{
				productCode += '1:'+rcp.RTL_Product_Group__c+';';
			}

			camIdProductStringMap.put( rcp.RTL_Campaign__c,productCode );
		}

		// Set no product result campaign to empty product Code string
		for( Id camId : camIds )
		{
			if( !camIdProductStringMap.containsKey(camId) )
			{
				camIdProductStringMap.put( camId,'' );
			}
		}

		Set<ID> camIdsList = camIdProductStringMap.keySet();
		List<Campaign> camList = [SELECT ID,Name,RTL_CampaignProduct__c FROM Campaign WHERE ID in :camIdsList ];

		List<Campaign> updatedCamList = new List<Campaign>();

		for(Campaign cam : camList)
		{
			if( camIdProductStringMap.containsKey(cam.Id) )
			{
				String productCode = camIdProductStringMap.get(cam.Id);

				if( cam.RTL_CampaignProduct__c != productCode )
				{
					cam.RTL_CampaignProduct__c = productCode;
					updatedCamList.add(cam);
				}

			}
		}

		if( updatedCamList.size() > 0 )
		{
			update updatedCamList;
		}
	}
}