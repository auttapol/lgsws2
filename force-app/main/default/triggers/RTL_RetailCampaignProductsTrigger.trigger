trigger RTL_RetailCampaignProductsTrigger on Retail_Campaign_Products__c (after insert, after update, after delete) {

	Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ;

	Set<ID> updatedProductCodeCamIds = new Set<ID>();
	if(Trigger.isAfter){

		if( Trigger.isInsert || Trigger.isUpdate )
		{
			for(Retail_Campaign_Products__c rcp : trigger.new){
				updatedProductCodeCamIds.add( rcp.RTL_Campaign__c );
			}	
		}

		if( Trigger.isDelete )
		{
			for(Retail_Campaign_Products__c rcp : trigger.old){
				updatedProductCodeCamIds.add( rcp.RTL_Campaign__c );
			}	
		}
	}

	if( updatedProductCodeCamIds.size() > 0 )
	{
		if( RunTrigger || Test.isRunningTest() )
		{
			RTL_CampaignToHQApproval.updateCampaignProductString(updatedProductCodeCamIds);
		}
	}

	
	

}