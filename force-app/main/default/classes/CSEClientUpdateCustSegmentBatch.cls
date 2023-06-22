global class CSEClientUpdateCustSegmentBatch implements Database.Batchable<sObject> {
	
	String query;
	
	global CSEClientUpdateCustSegmentBatch() {
		query = 'SELECT id,CS_Stamped_Customer_Segment__c,CS_Key__c,CS_Customer_Segment__c, '+
		'CS_Is_Customer_Segment_Change__c '+
		'FROM E_Client_Suitability__c '+ 
		'WHERE CS_Is_Customer_Segment_Change__c = true ';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		   
		List<E_Client_Suitability__c> eClientList = new List<E_Client_Suitability__c>();   
		for(sObject eclient : scope)
		{
			E_Client_Suitability__c ec = (E_Client_Suitability__c)eclient;
			if(ec != null)
			{
				E_Client_Suitability__c ecs = new E_Client_Suitability__c(CS_Key__c =  ec.CS_Key__c );
				ecs.CS_Stamped_Customer_Segment__c = ec.CS_Customer_Segment__c;

				eClientList.add(ecs);
			}
		}
		if( eClientList.size() > 0 )
		{
			Database.UpsertResult[] upsertResult = Database.upsert(eClientList , E_Client_Suitability__c.Fields.CS_Key__c , false);

		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}