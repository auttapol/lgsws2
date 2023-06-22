@isTest
private class SurveyManagerControllerTest {
	
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

		Survey_Question__c Q2 = CSTestUtils.createSurveyQuestion(sv2.Id);
		Survey_Choice__c choiceQ2 = CSTestUtils.createSurveyChoice(Q2);
		Survey_Answer__c saQ2 = CSTestUtils.createSurveyAnswer(Q2,choiceQ2,formB);

		Survey_Score__c scA = CSTestUtils.createSurveyScore(smList[0]);
		Survey_Score__c scB = CSTestUtils.createSurveyScore(smList[1]);

		List<E_Client_Suitability__c> esList = CSTestUtils.createEclient(1,acc.Id,u.Id,formA,formB);
	}
	
	@isTest static void getSurvey() {
		// Implement test code
		List<Survey_Manager__c> sm = [SELECT id,Name,Survey_Version__c,Survey_Type__c,
						Survey_Version__r.version__c,Survey_Version__r.Active_Status__c
						FROM Survey_Manager__c LIMIT 1];
		SurveyManagerController.getSurvey(sm[0].Name,sm[0].Survey_Version__c);
	}

	@isTest static void genQuestionWrapper() {
		// Implement test code
	}

	@isTest static void generateSubQuestion() {
		// Implement test code
	}

	@isTest static void generateChoice() {
		// Implement test code
	}

	@isTest static void saveDraftSurveySheet() {
		// Implement test code
		Map<String,Map<Object,Object>> surveyAwnser = new Map<String,Map<Object,Object>>();
		List<Survey_Manager__c> smA = [SELECT Id,Name,Survey_Version__c FROM Survey_Manager__c WHERE CS_Survey_Manager_Key__c  = 'SurveyKeyTest0' LIMIT 1];
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c,CS_RM__c,CS_Sales_Owner__c,CS_Customer__c FROM E_Client_Suitability__c Limit 1];
		
		Survey_Sheet__c surveySheet = new Survey_Sheet__c(Id = ec[0].CS_Customer_Survey_A__c);
		surveySheet.Survey_Version__c = smA[0].Survey_Version__c;
		update surveySheet;
								
		SurveyManagerController.saveDraftSurveySheet(surveyAwnser, smA[0], ec[0].CS_Customer_Survey_A__c);
	}

	@isTest static void saveSurveySheet() {
		// Implement test code
		Map<String, Map<Object,Object>> surveyAwnser = new Map<String, Map<Object,Object>>();	
		Map<Object,Object> choiceMap = new Map<Object,Object>();		
		List<Survey_Manager__c> smA = [SELECT Id,Name,Survey_Version__c FROM Survey_Manager__c WHERE CS_Survey_Manager_Key__c  = 'SurveyKeyTest0' LIMIT 1];
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c,CS_RM__c,CS_Sales_Owner__c,CS_Customer__c FROM E_Client_Suitability__c Limit 1];

		List<Survey_Question__c> sq = [SELECT Id,Name,Score_Calculate_Type__c FROM Survey_Question__c ];
		List<Survey_Choice__c> sc = [SELECT Id,Name,Survey_Question__c FROM Survey_Choice__c ];
		List<Survey_Answer__c> sa = [SELECT Id,Choice_Value__c,Survey_Choice__c,Survey_Question__c,Survey_Sheet__c FROM Survey_Answer__c ];
	
		choiceMap.put(sc.get(0).Id,sa.get(0));	
		surveyAwnser.put(sc.get(0).Id, choiceMap);

		Survey_Sheet__c surveySheet = new Survey_Sheet__c(Id = ec[0].CS_Customer_Survey_A__c);
		surveySheet.Survey_Version__c = smA[0].Survey_Version__c;
		update surveySheet;

		SurveyManagerController.saveSurveySheet(surveyAwnser, smA[0], ec[0].CS_Customer_Survey_A__c);
	}

	@isTest static void upsertSurveyAwnser() {
		// Implement test code
		Map<String, Map<Object,Object>> surveyAwnser = new Map<String, Map<Object,Object>>();	
		Map<Object,Object> choiceMap = new Map<Object,Object>();		
		List<Survey_Manager__c> smA = [SELECT Id,Name,Survey_Version__c FROM Survey_Manager__c WHERE CS_Survey_Manager_Key__c  = 'SurveyKeyTest0' LIMIT 1];
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c,CS_RM__c,CS_Sales_Owner__c,CS_Customer__c FROM E_Client_Suitability__c Limit 1];

		List<Survey_Question__c> sq = [SELECT Id,Name FROM Survey_Question__c ];
		List<Survey_Choice__c> sc = [SELECT Id,Name,Survey_Question__c FROM Survey_Choice__c ];
		List<Survey_Answer__c> sa = [SELECT Id,Choice_Value__c,Survey_Choice__c,Choice_Checked__c,Score__c FROM Survey_Answer__c ];
	

		Map<Object, Object> inputSA  = new Map<Object, Object> ();

		inputSA.put((Object)'choiceValue',sa.get(0).Choice_Value__c);
		inputSA.put((Object)'choiceChecked',sa.get(0).Choice_Checked__c);
		inputSA.put((Object)'choiceScore',sa.get(0).Score__c);
		inputSA.put((Object)'answerId',sa.get(0).Id);
		//Map<Object,Object> tmpSA = (Map<Object,Object>)  sa.get(0);
		choiceMap.put(sc.get(0).Id, inputSA );	
		surveyAwnser.put(sc.get(0).Survey_Question__c, choiceMap);

		Survey_Sheet__c surveySheet = new Survey_Sheet__c(Id = ec[0].CS_Customer_Survey_A__c);
		surveySheet.Survey_Version__c = smA[0].Survey_Version__c;
		update surveySheet;

		SurveyManagerController.upsertSurveyAwnser(surveyAwnser, ec[0].CS_Customer_Survey_A__c);
	}

	@isTest static void calculateSurveyScore() {
		// Implement test code
		Map<String, Map<Object,Object>> surveyAwnser = new Map<String, Map<Object,Object>>();	
		Map<Object,Object> choiceMap = new Map<Object,Object>();		
		List<Survey_Manager__c> smA = [SELECT Id,Name,Survey_Version__c FROM Survey_Manager__c WHERE CS_Survey_Manager_Key__c  = 'SurveyKeyTest0' LIMIT 1];
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c,CS_RM__c,CS_Sales_Owner__c,CS_Customer__c FROM E_Client_Suitability__c Limit 1];

		List<Survey_Question__c> sq = [SELECT Id,Name FROM Survey_Question__c ];
		List<Survey_Choice__c> sc = [SELECT Id,Name,Survey_Question__c FROM Survey_Choice__c ];
		List<Survey_Answer__c> sa = [SELECT Id,Choice_Value__c,Survey_Choice__c,Choice_Checked__c,Score__c FROM Survey_Answer__c ];
	
		Map<Object, Object> inputSA  = new Map<Object, Object> ();

		inputSA.put((Object)'choiceValue',sa.get(0).Choice_Value__c);
		inputSA.put((Object)'choiceChecked',sa.get(0).Choice_Checked__c);
		inputSA.put((Object)'choiceScore',sa.get(0).Score__c);
		inputSA.put((Object)'answerId',sa.get(0).Id);

		choiceMap.put(sc.get(0).Id, inputSA );	
		surveyAwnser.put(sc.get(0).Survey_Question__c, choiceMap);

		SurveyManagerController.calculateSurveyScore(surveyAwnser, ec[0].CS_Customer_Survey_A__c);
	}

	@isTest static void getSurveySheet() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c,CS_RM__c,CS_Sales_Owner__c,CS_Customer__c FROM E_Client_Suitability__c Limit 1];
		SurveyManagerController.getSurveySheet(ec[0].CS_Customer_Survey_A__c);
	}

	@isTest static void getSurveyAnswer() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c,CS_RM__c,CS_Sales_Owner__c,CS_Customer__c FROM E_Client_Suitability__c Limit 1];
		List<Survey_Manager__c> smA = [SELECT Id,Name,Survey_Version__c FROM Survey_Manager__c WHERE CS_Survey_Manager_Key__c  = 'SurveyKeyTest0' LIMIT 1];
		Survey_Sheet__c surveySheet = new Survey_Sheet__c(Id = ec[0].CS_Customer_Survey_A__c);
		surveySheet.Survey_Version__c = smA[0].Survey_Version__c;
		update surveySheet;

		SurveyManagerController.getSurveyAnswer(ec[0].CS_Customer_Survey_A__c);
	}

	@isTest static void SurveySheetAnswer() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c,CS_RM__c,CS_Sales_Owner__c,CS_Customer__c FROM E_Client_Suitability__c Limit 1];
		SurveyManagerController.SurveySheetAnswer(ec[0].CS_Customer_Survey_A__c);
		SurveyManagerController.SurveySheetAnswer(ec[0].CS_Customer_Survey_B__c);
	}

	@isTest static void getEClientSuit() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c,CS_RM__c,CS_Sales_Owner__c,CS_Customer__c FROM E_Client_Suitability__c Limit 1];
		SurveyManagerController.getEClientSuit(ec[0].Id);
	}

	@isTest static void SurveyEClient() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c,CS_RM__c,CS_Sales_Owner__c,CS_Customer__c FROM E_Client_Suitability__c Limit 1];
		SurveyManagerController.SurveyEClient(ec[0].Id,'FormA');
		SurveyManagerController.SurveyEClient(ec[0].Id,'FormB');
	}

	@isTest static void getEClientId() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c,CS_RM__c,CS_Sales_Owner__c,CS_Customer__c FROM E_Client_Suitability__c Limit 1];
		SurveyManagerController.getEClientId(ec[0].CS_Customer_Survey_A__c);
	}

	@isTest static void isIdInObject() {
		// Implement test code
		List<Survey_Question__c> sqList = [SELECT Id FROM Survey_Question__c];
		for(Survey_Question__c sq : sqList)
		{
			SurveyManagerController.isIdInObject(sq.Id,'Survey_Question__c' );
		}
	}
}