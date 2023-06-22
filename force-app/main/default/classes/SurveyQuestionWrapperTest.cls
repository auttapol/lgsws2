@isTest
private class SurveyQuestionWrapperTest {
	
	@isTest static void test_method_one() {
		// Implement test code
		SurveyQuestionWrapper sc = new SurveyQuestionWrapper();
		sc.getSubQuestionList();
		sc.genTitleGridStyleClass();
		sc.genChoiceGridStyleClass();

		Survey_Question__c question = new Survey_Question__c();
		question.Choice_Render_Type__c = 'Choice Render On Right';
		question.Question_Grid_Size__c = 2;

		sc.question = question;

		List<SurveyManagerController.choiceWrapper> choiceList = sc.choiceList;
		List<SurveyQuestionWrapper> subQuestionList = sc.subQuestionList;
		String gridTitleStyleClass = sc.gridTitleStyleClass;
		String gridChoiceStyleClass = sc.gridChoiceStyleClass;
		List<SurveyManagerController.choiceWrapper> getChoice = sc.getChoiceList();
		List<SurveyQuestionWrapper> getSubQuestion = sc.getSubQuestionList();
		sc.genTitleGridStyleClass();
		sc.genChoiceGridStyleClass();
	}

	
}