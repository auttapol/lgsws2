global class RTL_UpdateCampaignMemberOfferResultBatch implements Database.Batchable<sObject> {
	
	private String query;
	private List<ID> expiringCampaignId;
	static final String PENDING_TEXT = 'Pending';
	static final String CONTACT_STATUS_NEW = 'New';
	static final String CONTACT_STATUS_UNUSED = 'Unused';
	
	global RTL_UpdateCampaignMemberOfferResultBatch(List<ID> expiringCampaignIdArg) {

		expiringCampaignId = expiringCampaignIdArg;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([SELECT id,RTL_Offer_Result__c,RTL_OfferResult_Product_1__c,RTL_OfferResult_Product_2__c,
                        RTL_OfferResult_Product_3__c,RTL_OfferResult_Product_4__c,
                        RTL_OfferResult_Product_5__c,
                        RTL_Product_Group_1__c,RTL_Product_Group_2__c,RTL_Product_Group_3__c,
                        RTL_Product_Group_4__c,RTL_Product_Group_5__c,
                        RTL_Contact_Status__c,RTL_Offer_Result_Eng__c
                        FROM CampaignMember
                        WHERE CampaignId in :expiringCampaignId
                        AND ( RTL_Offer_Result_Eng__c = :PENDING_TEXT OR RTL_Contact_Status__c = :CONTACT_STATUS_NEW )
         ]);

		// Query to get both campaign member
	}

   	global void execute(Database.BatchableContext BC, List<CampaignMember> scope) {
	
		 for(CampaignMember cm : scope)
		 {
		 	// All camapign member that campaign expired and offer result and contact status are in scope to change data
		 	//Update for Offer Result Product to N/A if campaing offer result is pending
		 	if( cm.RTL_Offer_Result_Eng__c == PENDING_TEXT )
		 	{

			 	if( cm.RTL_Product_Group_1__c != '' && cm.RTL_Product_Group_1__c != null && cm.RTL_OfferResult_Product_1__c == null )
	            {
	                cm.RTL_OfferResult_Product_1__c = 'N/A';
	            }

	            if( cm.RTL_Product_Group_2__c != '' && cm.RTL_Product_Group_2__c != null && cm.RTL_OfferResult_Product_2__c == null )
	            {
	                cm.RTL_OfferResult_Product_2__c = 'N/A';
	            }

	            if( cm.RTL_Product_Group_3__c != '' && cm.RTL_Product_Group_3__c != null && cm.RTL_OfferResult_Product_3__c == null )
	            {
	                cm.RTL_OfferResult_Product_3__c = 'N/A';
	            }

	            if( cm.RTL_Product_Group_4__c != '' && cm.RTL_Product_Group_4__c != null && cm.RTL_OfferResult_Product_4__c == null )
	            {
	                cm.RTL_OfferResult_Product_4__c = 'N/A';
	            }
	            if( cm.RTL_Product_Group_5__c != '' && cm.RTL_Product_Group_5__c != null && cm.RTL_OfferResult_Product_5__c == null )
	            {
	                cm.RTL_OfferResult_Product_5__c = 'N/A';
	            }

	        }

	        // Update contact status to unused if contact status is new
	        if( cm.RTL_Contact_Status__c == CONTACT_STATUS_NEW )
	        {
	        	cm.RTL_Contact_Status__c = CONTACT_STATUS_UNUSED;
	        }

	        cm.RTL_isBatchUpdateCampaignMember__c = true;
		 }

		//Set Update force flag
   		//RTL_CampaignMemberUtil.setCampaignForceUpdateCampaignMemberFlag( expiringCampaignId , true );

		update scope;

		//RTL_CampaignMemberUtil.setCampaignForceUpdateCampaignMemberFlag( expiringCampaignId , false );

	}
	
	global void finish(Database.BatchableContext BC) {
		system.debug('Finish Batch update campaign member Offer Status');
	}
	
}