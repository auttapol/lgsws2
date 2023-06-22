trigger RTL_OpportunityTrigger on Opportunity (before insert, after insert,
                                               before update, after update, 
                                               after delete, after undelete) {
    
	Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 	
    Boolean runRetailTrigger = false;
    
    if(Trigger.New != null){
    	for(Opportunity opty: Trigger.New){
    		if(opty.RecordTypeId != null) {
    			String recordTypeName = Schema.SobjectType.Opportunity.getRecordTypeInfosById().get(opty.RecordTypeId).getName();
    			System.debug('RecordTypeName ::: '+recordTypeName);
    			if(recordTypeName.contains('Retail')){
    				runRetailTrigger = true;
    				break;
    			}
    		
    		}
    	} 
    }
    

    if(runRetailTrigger && RunTrigger) {
    	System.debug('RTL_OpporutnityTrigger Executed --- ' + runRetailTrigger);
        new RTL_OpportunityTriggerHandler().run();

		if(Trigger.isAfter && Trigger.isUpdate){ 
			//SEND Oppty to CXM
			CXMServiceProvider cxmService = new CXMServiceProvider(CXMServiceProvider.OPPTY_TO_CXM);
			cxmService.integrateToCXMForSales(Trigger.oldMap,Trigger.NewMap);
		}
    }
    
}