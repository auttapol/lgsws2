@isTest
private class CSGeneratePDFMainControllerTest {
	
	@testSetup static void setupData(){

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

	@isTest static void getAnswer() {

		E_Client_Suitability__c ec = [SELECT Id, OwnerId, Name, CS_Customer_Survey_A__c, CS_Customer_Survey_B__c, CS_RM__r.Name,
					CS_Sales_Owner__r.Name, CS_Status__c, CS_Customer__c
					FROM E_Client_Suitability__c LIMIT 1];

		Account	ac = [SELECT Id,Name FROM Account LIMIT 1];

		Map<ID, List<Survey_Choice__c>> choiceMap = new Map<ID, List<Survey_Choice__c>>();		
		Survey_Manager__c smA = [SELECT Id,Name,Survey_Version__c FROM Survey_Manager__c WHERE CS_Survey_Manager_Key__c  = 'SurveyKeyTest0' LIMIT 1];

		List<Survey_Choice__c> sc = [SELECT Id,Name,Survey_Question__c FROM Survey_Choice__c ];
		List<Survey_Answer__c> sa = [SELECT Id,Choice_Value__c,Survey_Choice__c,Choice_Checked__c,Score__c FROM Survey_Answer__c ];
	
		choiceMap.put(sc.get(0).Id, sc );	
		

		Test.StartTest();

            PageReference pageRef = Page.CSGeneratePDFMain; // Add your VF page Name here

            pageRef.getParameters().put('id', ec.Id);

            pageRef.getParameters().put('surveySheet', 'formA');

            Test.setCurrentPage(pageRef);

			
            CSGeneratePDFMainController cs = new CSGeneratePDFMainController();
			SurveyManagerController.AwnserWrapper awserDataA = cs.awserDataA;
            SurveyManagerController.AwnserWrapper awserDataB = cs.awserDataB;
			Map<ID,Survey_Answer__c> AnsMapA = cs.AnsMapA;
			Map<ID,Survey_Answer__c> AnsMapB = cs.AnsMapB;
			boolean showCSlevel = cs.showCSlevel;

        Test.StopTest();


		SurveyManagerController.SurveyWrapper sw = new SurveyManagerController.SurveyWrapper();
		sw.survey = smA;
		sw.questionMap = new Map<Id,SurveyQuestionWrapper>();
		sw.questionlist = new List<SurveyQuestionWrapper>();
		sw.allQuestionList = new Map<Id,Survey_Question__c>();
		sw.questionIdChoiceMap = choiceMap;

		SurveyManagerController.AwnserWrapper awserData = new SurveyManagerController.AwnserWrapper();
		awserData.awnser = sa;
		awserData.survey = sw;
		CSGeneratePDFMainController.getAnswer(awserData);
	
	}

	@isTest static void getAnswer2() {

		E_Client_Suitability__c ec = [SELECT Id, OwnerId, Name, CS_Customer_Survey_A__c, CS_Customer_Survey_B__c, CS_RM__r.Name,
					CS_Sales_Owner__r.Name, CS_Status__c, CS_Customer__c
					FROM E_Client_Suitability__c LIMIT 1];

		Account	ac = [SELECT Id,Name FROM Account LIMIT 1];

		Map<ID, List<Survey_Choice__c>> choiceMap = new Map<ID, List<Survey_Choice__c>>();		
		Survey_Manager__c smA = [SELECT Id,Name,Survey_Version__c FROM Survey_Manager__c WHERE CS_Survey_Manager_Key__c  = 'SurveyKeyTest0' LIMIT 1];

		List<Survey_Choice__c> sc = [SELECT Id,Name,Survey_Question__c FROM Survey_Choice__c ];
		List<Survey_Answer__c> sa = [SELECT Id,Choice_Value__c,Survey_Choice__c,Choice_Checked__c,Score__c FROM Survey_Answer__c ];
	
		choiceMap.put(sc.get(0).Id, sc );	
		

		Test.StartTest();

            PageReference pageRef = Page.CSGeneratePDFMain; // Add your VF page Name here

            pageRef.getParameters().put('id', ec.Id);

            pageRef.getParameters().put('surveySheet', 'formB');

            Test.setCurrentPage(pageRef);

			
            CSGeneratePDFMainController cs = new CSGeneratePDFMainController();
			SurveyManagerController.AwnserWrapper awserDataA = cs.awserDataA;
            SurveyManagerController.AwnserWrapper awserDataB = cs.awserDataB;
			Map<ID,Survey_Answer__c> AnsMapA = cs.AnsMapA;
			Map<ID,Survey_Answer__c> AnsMapB = cs.AnsMapB;
			boolean showCSlevel = cs.showCSlevel;

        Test.StopTest();


		SurveyManagerController.SurveyWrapper sw = new SurveyManagerController.SurveyWrapper();
		sw.survey = smA;
		sw.questionMap = new Map<Id,SurveyQuestionWrapper>();
		sw.questionlist = new List<SurveyQuestionWrapper>();
		sw.allQuestionList = new Map<Id,Survey_Question__c>();
		sw.questionIdChoiceMap = choiceMap;

		SurveyManagerController.AwnserWrapper awserData = new SurveyManagerController.AwnserWrapper();
		awserData.awnser = sa;
		awserData.survey = sw;
		CSGeneratePDFMainController.getAnswer(awserData);
	
	}

	@isTest static void getAnswer3() {

		E_Client_Suitability__c ec = [SELECT Id, OwnerId, Name, CS_Customer_Survey_A__c, CS_Customer_Survey_B__c, CS_RM__r.Name,
					CS_Sales_Owner__r.Name, CS_Status__c, CS_Customer__c
					FROM E_Client_Suitability__c LIMIT 1];

		Account	ac = [SELECT Id,Name FROM Account LIMIT 1];

		Map<ID, List<Survey_Choice__c>> choiceMap = new Map<ID, List<Survey_Choice__c>>();		
		Survey_Manager__c smA = [SELECT Id,Name,Survey_Version__c FROM Survey_Manager__c WHERE CS_Survey_Manager_Key__c  = 'SurveyKeyTest0' LIMIT 1];

		List<Survey_Choice__c> sc = [SELECT Id,Name,Survey_Question__c FROM Survey_Choice__c ];
		List<Survey_Answer__c> sa = [SELECT Id,Choice_Value__c,Survey_Choice__c,Choice_Checked__c,Score__c FROM Survey_Answer__c ];
	
		choiceMap.put(sc.get(0).Id, sc );	
		

		Test.StartTest();

            PageReference pageRef = Page.CSGeneratePDFMain; // Add your VF page Name here

            pageRef.getParameters().put('id', ec.Id);

            pageRef.getParameters().put('surveySheet', 'Test');

            Test.setCurrentPage(pageRef);

			
            CSGeneratePDFMainController cs = new CSGeneratePDFMainController();
			SurveyManagerController.AwnserWrapper awserDataA = cs.awserDataA;
            SurveyManagerController.AwnserWrapper awserDataB = cs.awserDataB;
			Map<ID,Survey_Answer__c> AnsMapA = cs.AnsMapA;
			Map<ID,Survey_Answer__c> AnsMapB = cs.AnsMapB;
			boolean showCSlevel = cs.showCSlevel;

        Test.StopTest();


		SurveyManagerController.SurveyWrapper sw = new SurveyManagerController.SurveyWrapper();
		sw.survey = smA;
		sw.questionMap = new Map<Id,SurveyQuestionWrapper>();
		sw.questionlist = new List<SurveyQuestionWrapper>();
		sw.allQuestionList = new Map<Id,Survey_Question__c>();
		sw.questionIdChoiceMap = choiceMap;

		SurveyManagerController.AwnserWrapper awserData = new SurveyManagerController.AwnserWrapper();
		awserData.awnser = sa;
		awserData.survey = sw;
		CSGeneratePDFMainController.getAnswer(awserData);
	
	}
	
}