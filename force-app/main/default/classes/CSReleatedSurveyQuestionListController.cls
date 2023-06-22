public with sharing class CSReleatedSurveyQuestionListController {
	@AuraEnabled
	public static List<Survey_Question__c> getQuestionList(Id recordId){
		List<Survey_Question__c> Ques = [SELECT Id, Name, Survey_Version__c, Question_Number__c, Question_Title__c,  Parent_Question__c, Active_Status__c, Require_Input__c, Question_Grid_Size__c, Choice_Render_Type__c FROM Survey_Question__c WHERE Survey_Version__c=:recordId AND Parent_Question__c=null ORDER BY Question_Number__c];

		return Ques;
	  
	}
}