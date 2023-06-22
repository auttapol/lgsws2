@isTest
private class CSReleatedSurveyQuestionListCtrlTest {
	
	
	@testSetup static void setup() {
		// Implement test code
	    AppConfig__c mc =new AppConfig__c(Name = 'runtrigger', Value__c = 'false');
        insert mc;

        User u = CSTestUtils.createUsers(1, 'UserTestqqq' ,'Userqqq' , 'test22@email.com' , false).get(0);
        u.IsActive = true;
        insert u;

		Account acc = CSTestUtils.createAccounts(1,false).get(0);
		acc.Murex_Counter_Label__c = 'eclient';
		insert acc;

		List<Survey_Manager__c> smList = CSTestUtils.createSurveyManager(2);
		Survey_Version__c sv1 = CSTestUtils.createSurveyVersion(1,smList[0]);
		Survey_Version__c sv2 = CSTestUtils.createSurveyVersion(2,smList[1]);

		Survey_Sheet__c formA = CSTestUtils.insertSurveySheet(smList[0], acc.Id,u.Id,'FormA');
		Survey_Sheet__c formB = CSTestUtils.insertSurveySheet(smList[1],acc.Id,u.Id,'FormB');

		Survey_Question__c Q1 = CSTestUtils.createSurveyQuestion(sv1.Id);
		Survey_Question__c subQ1 = CSTestUtils.createSurveySubQuestion(sv1.Id,Q1);
		Survey_Choice__c subChoiceA =  CSTestUtils.createSurveyChoiceSub(subQ1);
		Survey_Choice__c choiceQ1 = CSTestUtils.createSurveyChoice(Q1);
		Survey_Answer__c saQ1 = CSTestUtils.createSurveyAnswer(Q1,choiceQ1,formA);

		List<E_Client_Suitability__c> esList = CSTestUtils.createEclient(1,acc.Id,u.Id,formA,formB);
	}

		@isTest static void getQuestionList() {
		// Implement test code
		List<Survey_Question__c> sq = [SELECT Id FROM Survey_Question__c Limit 1];
		CSReleatedSurveyQuestionListController.getQuestionList(sq[0].Id);
	}
	
}