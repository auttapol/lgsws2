public with sharing class CS_EClientSuitabilityUtil {

	public static List<CS_Segment_To_Queue_Mapping__mdt> queue 
	{
		get{

			if(queue == null)
			{

				queue = [SELECT Fx_Sales_Segment__c,Queue__c FROM CS_Segment_To_Queue_Mapping__mdt];
			}

			return queue;
		}
		set;
	}

	public static Id getSaleOwner( String tmbCustId , Map<String,Account> idAccountMap , Map<String,List<AccountTeamMember>> idAccountTeamMap)
	{
		if( idAccountTeamMap.containsKey( tmbCustId ) )
		{
			AccountTeamMember accTeamUser = new AccountTeamMember();
			List<AccountTeamMember> accTeamList =  idAccountTeamMap.get( tmbCustId );

			if( accTeamList.size() == 1 )
			{						
				return accTeamList[0].UserId;
			}
			else
			{
				return null;
			}

		}
		else
		{
			return null;
		}
	}

   	public static Id getEClientOwner( String tmbCustId , Map<String,Account> idAccountMap , Map<String,List<AccountTeamMember>> idAccountTeamMap ,Map<String,Group> segmentQueueMap )
	{
		Id saleOwnerId = null;
		Boolean isFoundAccountTeam = false;

		system.debug('gade: ' + idAccountTeamMap.containsKey( tmbCustId ));

		if( idAccountTeamMap.containsKey( tmbCustId ) )
		{
			AccountTeamMember accTeamUser = new AccountTeamMember();
			
			List<AccountTeamMember> accTeamList = idAccountTeamMap.get( tmbCustId );

			if( accTeamList.size() == 1 )
			{						
				saleOwnerId = accTeamList[0].UserId;
				isFoundAccountTeam = true;
			}
		}

				system.debug('gade: idAccountMap ' +idAccountMap);
				system.debug('gade: tmbCustId' + tmbCustId);

		if(!isFoundAccountTeam)
		{
			if( idAccountMap.containsKey( tmbCustId ) )
			{

				Account accFXSale = idAccountMap.get( tmbCustId );
				String segment;
				
				if(accFXSale.Customer_Segment_Team__c  == 'MB : MB-FI')
				{
					segment = 'FI';
				}
				else
				{
					segment = accFXSale.Core_Banking_Suggested_Segment__c;
				}

				if(segment != 'MB' && segment != 'CB' && segment != 'FI' && segment != 'BB' && segment != 'SE')
				{
					segment = 'Other';
				}

				system.debug('gade: segmentQueueMap ' +segmentQueueMap);
				system.debug('gade: segment' + segment);

				if( segmentQueueMap.containsKey( segment ))
				{	
					if(segmentQueueMap.get(segment) != null)
					{
						saleOwnerId = segmentQueueMap.get(segment).Id;	
					}
				}
			}
		}
		return saleOwnerId;
	}


   	public static Id getRM(String tmbCustId , Map<String,Account> idAccountMap )
	{
		if( idAccountMap.containsKey( tmbCustId ) )
		{
			return idAccountMap.get(tmbCustId).ownerId;			
		}
		else
		{
			return null;
		}
	}
}