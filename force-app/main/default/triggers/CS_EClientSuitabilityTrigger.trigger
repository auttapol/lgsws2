trigger CS_EClientSuitabilityTrigger on E_Client_Suitability__c ( before insert, before update, before delete, 
                            after insert, after update, after delete, after undelete) {

	new CS_EClientSuitabilityTriggerHandler().run(); 

}