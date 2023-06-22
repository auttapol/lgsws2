trigger RTL_NBOHistoryProductTrigger on RTL_NBO_History_Product__c ( before insert, before update, before delete, 
                            after insert, after update, after delete, after undelete ) {       

    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 		
    if(RunTrigger || Test.isRunningTest()){                 
    	new RTL_NBOHistoryProductTriggerHandler().run();

        if(Trigger.isAfter && Trigger.isUpdate){ 
                //SEND NBOProduct to CXM
                CXMServiceProvider cxmService = new CXMServiceProvider(CXMServiceProvider.NBO_PRODUCT_CXM);
                cxmService.integrateToCXMForSales(Trigger.oldMap,Trigger.NewMap);
                //SEND NBOProduct to CXM
        }
	}
}