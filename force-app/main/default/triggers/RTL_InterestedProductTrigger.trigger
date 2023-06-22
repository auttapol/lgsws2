trigger RTL_InterestedProductTrigger on RTL_Interested_products_c__c (before insert, before update, before delete, 
                            after insert, after update, after delete, after undelete) {
	new RTL_InterestedProductTriggerHandler().run();
}