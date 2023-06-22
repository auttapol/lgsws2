trigger SurveyVersionTrigger on Survey_Version__c (after insert,after update) {

	new SurveyVersionTriggerHandler().run(); 

}