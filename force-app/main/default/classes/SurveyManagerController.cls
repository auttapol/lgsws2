public class SurveyManagerController {
	
	public Class choiceWrapper
	{
		@AuraEnabled
        public Survey_Choice__c choice {get;set;}
        @AuraEnabled
        public Id mainQuestionId {get;set;}
        @AuraEnabled
        public SurveyQuestionWrapper dependentQuestion {get;set;}
        @AuraEnabled
        public String gridStyleClass {get;set;}
	}

    public Class SurveyWrapper
    {
    	@AuraEnabled
        public Survey_Manager__c survey {get;set;}
        @AuraEnabled
        public List<SurveyQuestionWrapper> questionlist {get;set;}
        @AuraEnabled
        public Map<Id,Survey_Question__c> allQuestionList {get;set;}
        @AuraEnabled
        public Map<ID,List<Survey_Choice__c>> questionIdChoiceMap {get;set;}
		public Survey_Question__c opp {get; set;}
		public Boolean isInMap(){return questionIdChoiceMap.containskey(opp.ID);}

        public Map<Id,SurveyQuestionWrapper> questionMap {get;set;}
        public List<SurveyQuestionWrapper> getQuestionList()
        {
        	if( questionMap != null )
        	{
        		return questionMap.values();
        	}
        	else 
        	{
        		return null;	
        	}
        }
        

    }

    public Class AwnserWrapper
    {
        @AuraEnabled
        public List<Survey_Answer__c> awnser {get;set;}
        @AuraEnabled
        public SurveyWrapper survey{get;set;}
    }

	@AuraEnabled
    public static SurveyWrapper getSurvey(String SurveyName,String SurveyVersionId)
    {
    	try {
				Survey_Manager__c sm;
				Map<ID,Survey_Question__c> sqMap;
				if(SurveyVersionId == null)
				{
					sm = [SELECT id,Name,Survey_Version__c,Survey_Type__c,
						Survey_Version__r.version__c,Survey_Version__r.Active_Status__c
						FROM Survey_Manager__c WHERE name =:SurveyName LIMIT 1];


					sqMap = new Map<ID,Survey_Question__c>([SELECT id,Name,Active_Status__c,
						Choice_Render_Type__c,Question_Grid_Size__c,
						Parent_Question__c,Question_Number__c,Question_Title__c,Require_Input__c , 
						( SELECT id, name , Dependent_Question_Render_Type__c FROM Dependent_Question__r)
						FROM Survey_Question__c
						WHERE Survey_Version__c =: sm.Survey_Version__c AND Active_Status__c = true
						ORDER BY Question_Number__c
						]);
				}
				else
				{
					sm = [SELECT id,Name,Survey_Version__c,Survey_Type__c,
						Survey_Version__r.version__c,Survey_Version__r.Active_Status__c
						FROM Survey_Manager__c WHERE name =:SurveyName LIMIT 1];


					sqMap = new Map<ID,Survey_Question__c>([SELECT id,Name,Active_Status__c,
						Choice_Render_Type__c,Question_Grid_Size__c,
						Parent_Question__c,Question_Number__c,Question_Title__c,Require_Input__c , 
						( SELECT id, name , Dependent_Question_Render_Type__c FROM Dependent_Question__r)
						FROM Survey_Question__c
						WHERE Survey_Version__c =: SurveyVersionId AND Active_Status__c = true
						ORDER BY Question_Number__c
						]);
				}
    		List<Survey_Question__c> sqList = sqMap.values();

    		List<ID> questionIdList = new List<ID>();

    		for( Survey_Question__c sqTemp : sqList)
    		{
    			questionIdList.add(sqTemp.id);
    		}

    		Map<ID, Survey_Choice__c> choiceMap = new Map<ID, Survey_Choice__c> ([SELECT Id, Score__c, 
    				Prefix__c, Suffix__c,Option_Type__c,
    				Ordering__c, Active_Status__c, 
    				Label__c, Dependent_Question__c, Dependent_Type__c, Survey_Question__c,
    				Dependent_Question_Render_Type__c,
    				Survey_Question__r.Question_Grid_Size__c, List_Values__c ,Input_Text_Type__c,Require_Type__c
    				FROM Survey_Choice__c
    				WHERE Active_Status__c = true
    				AND Survey_Question__c in :questionIdList
    				ORDER BY Ordering__c
    				]);


    		Map<ID,List<Survey_Question__c>> parentIdchildQuestionMap = new Map<ID,List<Survey_Question__c>>();
    		Map<ID,List<Survey_Choice__c>> questionIdChoiceMap = new Map<ID,List<Survey_Choice__c>> ();

    		for( Survey_Choice__c c : choiceMap.values() )
    		{
    			if( !questionIdChoiceMap.containsKey(c.Survey_Question__c ) )
				{
					questionIdChoiceMap.put( c.Survey_Question__c  , new List<Survey_Choice__c>() );
				}
    			questionIdChoiceMap.get( c.Survey_Question__c ).add(c) ;
    		}


    		SurveyWrapper sw = new SurveyWrapper();
    		sw.survey = sm;
    		sw.questionMap = new Map<Id,SurveyQuestionWrapper>();
    		sw.questionlist = new List<SurveyQuestionWrapper>();
    		sw.allQuestionList = new Map<Id,Survey_Question__c>();
            sw.questionIdChoiceMap = questionIdChoiceMap;
   		
    		List<Survey_Question__c> firstLevelQuestionList = new List<Survey_Question__c>();
    		Set<ID> questionIDSet = new Set<ID>();

    		for( Survey_Question__c sq : sqList )
    		{
                sw.allQuestionList.put(sq.id,sq);

    			questionIDSet.add(sq.id);

    			if( sq.Parent_Question__c == null )
    			{
    				firstLevelQuestionList.add(sq);
    			}
    			else 
    			{
    				if( !parentIdchildQuestionMap.containsKey(sq.Parent_Question__c) )
    				{
    					parentIdchildQuestionMap.put( sq.Parent_Question__c , new List<Survey_Question__c>() );
    				}

    				parentIdchildQuestionMap.get( sq.Parent_Question__c ).add(sq) ;
    			}
    		}

    		Integer questionDept = 0;

    		for ( Survey_Question__c fsq : firstLevelQuestionList )
    		{

    			SurveyQuestionWrapper qwParent = genQuestionWrapper( fsq , parentIdchildQuestionMap , questionIdChoiceMap , sqMap ,questionDept );
    			sw.questionMap.put( fsq.id, qwParent );
    			sw.questionlist.add(qwParent);

    		}
    		return sw;

    		
    	} catch(Exception e) {
    		System.debug(e.getMessage() + e.getLineNumber() );
			throw new AuraHandledException(e.getMessage());
    		return null;
    	}
    	
    }

    private static SurveyQuestionWrapper genQuestionWrapper(Survey_Question__c sq,Map<ID,List<Survey_Question__c>> parentIdchildQuestionMap , Map<ID,List<Survey_Choice__c>> questionIdChoiceMap , Map<ID,Survey_Question__c> sqMap , Integer questionDept)
    {
		try{
			questionDept++;

			if( questionDept > 5 )
			{
				return null;
			}

			SurveyQuestionWrapper qwParent = new SurveyQuestionWrapper();
			qwParent.question = sq;

			qwParent.subQuestionMap = generateSubQuestion(sq.Id , parentIdchildQuestionMap , questionIdChoiceMap , sqMap , questionDept );
			qwParent.subQuestionList = qwParent.getSubQuestionList();

			qwParent.choiceMap = generateChoice( sq.id, parentIdchildQuestionMap, questionIdChoiceMap , sqMap , questionDept );
			qwParent.choiceList = qwParent.getChoiceList();

			qwParent.gridTitleStyleClass  = qwParent.genTitleGridStyleClass();
			qwParent.gridChoiceStyleClass  = qwParent.genChoiceGridStyleClass();

			return qwParent;
		}
		catch(Exception e) {
    		System.debug(e.getMessage() + e.getLineNumber() );
			throw new AuraHandledException(e.getMessage());
    		return null;
    	}
    }

    private static Map<ID,SurveyQuestionWrapper> generateSubQuestion(ID qId,Map<ID,List<Survey_Question__c>> parentIdchildQuestionMap , Map<ID,List<Survey_Choice__c>> questionIdChoiceMap , Map<ID,Survey_Question__c> sqMap , Integer questionDept )
    {	
		try
		{
			if( parentIdchildQuestionMap.containsKey( qId ) )
			{
				Map<ID,SurveyQuestionWrapper> subQuestion = new Map<ID,SurveyQuestionWrapper>();

				for( Survey_Question__c sq : parentIdchildQuestionMap.get(qId) )
				{

					if( sq.Dependent_Question__r.size() == 0 )
					{
						SurveyQuestionWrapper qw = genQuestionWrapper( sq , parentIdchildQuestionMap , questionIdChoiceMap , sqMap , questionDept );
						subQuestion.put( sq.id , qw );
					}
					else 
					{
						
						Survey_Choice__c dependentChoiceData = sq.Dependent_Question__r.get(0);

						if( dependentChoiceData.Dependent_Question_Render_Type__c  == 'After All Choice' )    
						{
							SurveyQuestionWrapper qw = genQuestionWrapper( sq , parentIdchildQuestionMap , questionIdChoiceMap , sqMap , questionDept );
							subQuestion.put( sq.id , qw );       
						}
					}

				}

				return subQuestion;
				
			}
			else 
			{
				return null;	
			}
		}
		catch(Exception e) {
    		System.debug(e.getMessage() + e.getLineNumber() );
			throw new AuraHandledException(e.getMessage());
    		return null;
    	}

    }

    private static Map<ID,choiceWrapper> generateChoice(ID qId ,Map<ID,List<Survey_Question__c>> parentIdchildQuestionMap , Map<ID,List<Survey_Choice__c>> questionIdChoiceMap , Map<ID,Survey_Question__c> sqMap , Integer questionDept)
    {
		try{
			if(  questionIdChoiceMap.containsKey(qId) )
			{
				Map<ID,choiceWrapper> choiceMap = new Map<ID,choiceWrapper>();

				List<Survey_Choice__c> scList = questionIdChoiceMap.get(qId);

				for( Survey_Choice__c c : scList )
				{
					choiceWrapper cw = new choiceWrapper();
					cw.choice = c;
					cw.mainQuestionId = qId;

					if(  c.Dependent_Question__c != null && sqMap.containsKey(c.Dependent_Question__c) && c.Dependent_Question_Render_Type__c != 'After All Choice' )
					{	
						cw.dependentQuestion = genQuestionWrapper( sqMap.get(c.Dependent_Question__c) , parentIdchildQuestionMap, questionIdChoiceMap , sqMap , questionDept );
					}

					choiceMap.put( c.id , cw );
				}

				return choiceMap;


			}
			else 
			{
				return null;	
			}
		}
		catch(Exception e) {
    		System.debug(e.getMessage() + e.getLineNumber() );
			throw new AuraHandledException(e.getMessage());
    		return null;
    	}
    }

    Class SurveyAwnser
    {
        public Integer choiceScore {get;set;}
        public String choiceType {get;set;}
        public String choiceValue {get;set;}
        public Boolean isChecked {get;set;}
    }
   
	@AuraEnabled
    public static String saveDraftSurveySheet ( Map<String, Map<Object,Object>> surveyAwnser , Survey_Manager__c survey, String surveySheetId)
    {
    	String errorMsg = null;
    	try{
			Survey_Sheet__c surveySheet = [SELECT Id, Score_Group__c, Total_Score_Roll_up__c, Total_Score__c, Survey_Version__c , Survey_Version__r.Survey_Manager__c FROM Survey_Sheet__c WHERE Id =:surveySheetId LIMIT 1];
    		
			upsertSurveyAwnser(surveyAwnser, surveySheetId);
			
			Decimal TotalScoreScoreSheet = calculateSurveyScore(surveyAwnser,surveySheetId);
			surveySheet.Total_Score__c = TotalScoreScoreSheet;

			Survey_Manager__c sm = [SELECT Id  FROM Survey_Manager__c WHERE id =: surveySheet.Survey_Version__r.Survey_Manager__c ];
			List<Survey_Score__c> ssList = [SELECT 
						Id, Low_score_range__c, Survey_Manager__c, Hight_score_range__c, Score_Group__c 
						FROM Survey_Score__c
						WHERE Survey_Manager__c =: sm.Id 
						AND Low_score_range__c <=:  TotalScoreScoreSheet
						AND Hight_score_range__c  >=: TotalScoreScoreSheet
						LIMIT 1
						]; 

			if( ssList.size() > 0 ) {
				Survey_Score__c ss = ssList[0];
				surveySheet.Score_Group__c = ss.Score_Group__c;
			}

			update surveySheet;
    	}
		catch(Exception e) {
    		System.debug(e.getMessage() + e.getLineNumber() );
			throw new AuraHandledException(e.getMessage());
    	}

    	if( errorMsg != null )
		{
			throw new AuraHandledException( errorMsg  );
		}
		else
		{
			return null;
		}
    }

    @AuraEnabled
    public static String saveSurveySheet( Map<String, Map<Object,Object>> surveyAwnser , Survey_Manager__c survey, String surveySheetId)
    { 
		String errorMsg = null;
		try{
			
			Survey_Sheet__c surveySheet = [SELECT Id, Status__c, Score_Group__c, Survey_Version__c, Total_Score__c, Total_Score_Roll_up__c , Survey_Version__r.Survey_Manager__c FROM Survey_Sheet__c WHERE Id =:surveySheetId];
			surveySheet.Status__c = 'Ready for Review';

			upsertSurveyAwnser(surveyAwnser,surveySheetId);	

			Decimal TotalScoreScoreSheet = calculateSurveyScore(surveyAwnser,surveySheetId);
			surveySheet.Total_Score__c = TotalScoreScoreSheet;

			Survey_Manager__c sm = [SELECT Id  FROM Survey_Manager__c WHERE id =: surveySheet.Survey_Version__r.Survey_Manager__c];
			List<Survey_Score__c> ssList = [SELECT Id, Low_score_range__c, Survey_Manager__c, Hight_score_range__c, Score_Group__c 
						FROM Survey_Score__c
						WHERE Survey_Manager__c =: sm.Id 
						AND Low_score_range__c <=:  TotalScoreScoreSheet
						AND Hight_score_range__c  >=: TotalScoreScoreSheet
						LIMIT 1
						]; 
			if( ssList.size() > 0 ) {
				Survey_Score__c ss = ssList[0];				
				surveySheet.Score_Group__c = ss.Score_Group__c;
			}
			update surveySheet;

			// if( result != null )
			// { 
			// 	errorMsg = result;
			// }
		}
		catch(Exception e) {
    		System.debug(e.getMessage() + e.getLineNumber() );
			throw new AuraHandledException(e.getMessage());
    	}

		if( errorMsg != null )
		{
			throw new AuraHandledException( errorMsg  );
		}
		else
		{
			return null;
		}
    }


	public static void upsertSurveyAwnser( Map<String,Map<Object,Object> > surveyAwnser , String surveySheetId )
	{
		List<Survey_Answer__c> saList = new List<Survey_Answer__c>();
		System.debug(surveyAwnser);
		for( String questionId : surveyAwnser.keySet() )
		{

			// IE 11 MAP problem fix
			if( !isIdInObject( questionId , 'Survey_Question__c' ) )
			{
				continue;
			}

			Map<Object,Object> choiceSet = surveyAwnser.get(questionId);

			for( Object choiceId : choiceSet.keySet() )
			{
				// IE 11 MAP problem fix
				if( !isIdInObject( (String)choiceId , 'Survey_Choice__c' ) )
				{
					continue;
				}

				Map<Object,Object> choiceTmp = (Map<Object,Object>)choiceSet.get(choiceId);

				Survey_Answer__c sa = new Survey_Answer__c();

				if( choiceTmp.get('answerId') != null && choiceTmp.get('answerId') != '')  
				{	
					sa.Id = String.valueOf(choiceTmp.get('answerId'));
				}
				else
				{
					sa.Survey_Sheet__c = surveySheetId;
					sa.Survey_Question__c = questionId;
					sa.Survey_Choice__c = (Id)choiceId;
				}

				sa.Choice_Value__c = String.valueOf(choiceTmp.get('choiceValue'));
				sa.Choice_Checked__c = (Boolean)choiceTmp.get('choiceChecked');	
				sa.Score__c = (Decimal)choiceTmp.get('choiceScore');
				
				saList.add(sa);

			}
		}
		upsert saList Id;
	}

	public static Decimal calculateSurveyScore(Map<String, Map<Object,Object>> surveyAwnser, String surveySheetId){
		Decimal TotalScore = 0;
		Set<String> questionID = surveyAwnser.keySet();
		Map<Id, Survey_Question__c> mapChoiceCalculateType = new Map<Id, Survey_Question__c>([SELECT Id, Score_Calculate_Type__c FROM Survey_Question__c WHERE Id in :questionID ]);
		
		for(String qID : questionID)
		{

			// IE 11 MAP problem fix
			if( !isIdInObject( qID , 'Survey_Question__c' ) )
			{
				continue;
			}

			Map<Object,Object> choiceSet = surveyAwnser.get(qID);
			Map<String, List<Decimal>> questionIdScore = new Map<String, List<Decimal>>();
			for( Object choiceId : choiceSet.keySet() )
			{
				// IE 11 MAP problem fix
				if( !isIdInObject( (String)choiceId , 'Survey_Choice__c' ) )
				{
					continue;
				}
				Map<Object, Object> choiceTmp = (Map<Object, Object>)choiceSet.get(choiceId);
				Boolean ChoiceChecked = (Boolean)choiceTmp.get('choiceChecked');
				// Check choice is really user answser
				if(ChoiceChecked == true){
					System.debug('Question ID::: ' + qID + ' | ' + 'Question calculate type::: ' + mapChoiceCalculateType.get(qID).Score_Calculate_Type__c + ' | ' + choiceTmp);

					switch on mapChoiceCalculateType.get(qID).Score_Calculate_Type__c {
						when 'Sum' {
							TotalScore += (Decimal)choiceTmp.get('choiceScore');
						}
						when 'Min' {
							if(!questionIdScore.containsKey(qID))
							{
								questionIdScore.put(qID, new List<Decimal>());
							}
							questionIdScore.get(qID).add((Decimal)choiceTmp.get('choiceScore')) ;
						}
						when 'Max' {
							if(!questionIdScore.containsKey(qID))
							{
								questionIdScore.put(qID, new List<Decimal>());
							}
							questionIdScore.get(qID).add((Decimal)choiceTmp.get('choiceScore')) ;
						}
						// Default Sum
						when else {
							TotalScore += (Decimal)choiceTmp.get('choiceScore');
						}
					}
				}
			}

			// Get score max/min
			if(questionIdScore.containsKey(qID)){
				questionIdScore.get(qID).sort();
				if(mapChoiceCalculateType.get(qID).Score_Calculate_Type__c == 'Min'){
					TotalScore += questionIdScore.get(qID)[0];
				}
				else if(mapChoiceCalculateType.get(qID).Score_Calculate_Type__c == 'Max'){
					TotalScore += questionIdScore.get(qID)[questionIdScore.get(qID).size() - 1];
				}
			}
		}
		
		// System.debug('Total Scorce::: '+ TotalScore);
		return TotalScore;
	}

	@AuraEnabled
    public static Survey_Sheet__c getSurveySheet(String recordId)
    {
		try {
			Survey_Sheet__c sm = [SELECT Id, Name, Info_1__c, Info_2__c, Total_Score__c, Customer__c, Survey_Version__c FROM Survey_Sheet__c WHERE Id =:recordId];

			return sm;
    	} catch(Exception e) {
    		System.debug(e.getMessage() + e.getLineNumber() );
			throw new AuraHandledException(e.getMessage());
    		return null;
    	}
	}

	@AuraEnabled
    public static AwnserWrapper getSurveyAnswer(String recordId)
    {
        AwnserWrapper aws = new AwnserWrapper();	
		Map<String,Survey_Answer__c> answerMap = new Map<String,Survey_Answer__c>();
		try {
			List<Survey_Answer__c> sm = [SELECT Id, Name, Survey_Question__c, Survey_Sheet__c, Survey_Choice__c, Choice_Value__c, Choice_Checked__c, Score__c ,
                                            Survey_Sheet__r.Survey_Version__r.Survey_Manager__r.name
                                            FROM Survey_Answer__c WHERE Survey_Sheet__c =:recordId Order by LastModifiedDate ASC];

	
			for(Survey_Answer__c s : sm )
			{
				answerMap.put(s.Survey_Choice__c,s);				
			}

			List<Survey_Answer__c> saList = new List<Survey_Answer__c>();
			for(Survey_Answer__c s : answerMap.values() )
			{
				saList.add(s);						
			}
													
            Survey_Sheet__c sh = [SELECT id,Name,Survey_Version__r.Survey_Manager__r.name FROM Survey_Sheet__c WHERE Id = :recordId LIMIT 1];
            aws.awnser = saList;
            aws.survey = SurveyManagerController.getSurvey(sh.Survey_Version__r.Survey_Manager__r.name, sh.Survey_Version__c);
			return aws;

    	} catch(Exception e) {
    		System.debug(e.getMessage() + e.getLineNumber() );
			throw new AuraHandledException(e.getMessage());
    		return null;
    	}
	}

 
	public Class SurveySheetAnswerWrapper
    {
		@AuraEnabled
		public Survey_Sheet__c SurveySheet {get;set;}
		@AuraEnabled
		public List<Survey_Answer__c> SurveyAnswer {get;set;}
    }
 
	@AuraEnabled
	public static SurveySheetAnswerWrapper SurveySheetAnswer(String recordId) {

		SurveySheetAnswerWrapper saw = new SurveySheetAnswerWrapper();

		try
		{
			saw.SurveySheet =
				[SELECT 
					Id, Name, Info_1__c, Info_2__c, Total_Score__c, Customer__c, Survey_Version__c 
					FROM Survey_Sheet__c 
					WHERE Id =:recordId
					];

			saw.SurveyAnswer =
				[SELECT 
					Id, Name, Survey_Question__c, Survey_Sheet__c, Survey_Choice__c, Choice_Value__c, Score__c 
					FROM Survey_Answer__c 
					WHERE Survey_Sheet__c =:recordId
					];
		}
		catch(Exception e) {
    		System.debug(e.getMessage() + e.getLineNumber() );
			throw new AuraHandledException(e.getMessage());
    		return null;
    	}

		return saw;
	   
	}

	@AuraEnabled
    public static E_Client_Suitability__c getEClientSuit(String recordId)
    {
		try {
			E_Client_Suitability__c sm = [SELECT 
											Id, OwnerId, Name, CS_Customer_Survey_A__c, CS_Customer_Survey_B__c, CS_RM__c, CS_Status__c, LastModifiedBy.Name, CreatedDate, LastModifiedDate
											FROM E_Client_Suitability__c
											WHERE Id =:recordId
											];
 
			return sm;

    	} catch(Exception e) {
    		System.debug(e.getMessage() + e.getLineNumber() );
			throw new AuraHandledException(e.getMessage());
    		return null;
    	}
	}

	public Class SurveyEClientWrapper
    {
		@AuraEnabled
		public Survey_Sheet__c SurveySheet {get;set;}
		@AuraEnabled
		public List<Survey_Answer__c> SurveyAnswer {get;set;}
		@AuraEnabled
		public E_Client_Suitability__c EClient {get;set;}
    }

	@AuraEnabled
	public static SurveyEClientWrapper SurveyEClient(String recordId, String formType) {
		SurveyEClientWrapper sew = new SurveyEClientWrapper();

		
		try {
			sew.EClient = 
				[SELECT 
					Id, OwnerId, Name, CS_Customer_Survey_A__c, CS_Customer_Survey_B__c
					FROM E_Client_Suitability__c
					WHERE Id =:recordId 
					];
			String idSurveySheet; 


			if(formType == 'FormA'){
				idSurveySheet =  sew.EClient.CS_Customer_Survey_A__c; 
			} else if(formType == 'FormB') {
				idSurveySheet =  sew.EClient.CS_Customer_Survey_B__c;
			}

			sew.SurveySheet =
				[SELECT 
					Id, Name, Info_1__c, Info_2__c, Total_Score__c, Customer__c, Survey_Version__c 
					FROM Survey_Sheet__c 
					WHERE Id =:idSurveySheet
					];

			sew.SurveyAnswer =
				[SELECT 
					Id, Name, Survey_Question__c, Survey_Sheet__c, Survey_Choice__c, Choice_Value__c, Score__c 
					FROM Survey_Answer__c 
					WHERE Survey_Sheet__c =:idSurveySheet
					];

		}
		catch(Exception e) {
    		System.debug(e.getMessage() + e.getLineNumber() );
			throw new AuraHandledException(e.getMessage());
    		return null;
    	}

		return sew;
	}
	@AuraEnabled
    public static E_Client_Suitability__c getEClientId(String surveySheetId)
    {
		try {
			E_Client_Suitability__c sm = [SELECT 
											Id, OwnerId, Name, CS_Customer_Survey_A__c, CS_Customer_Survey_B__c
											FROM E_Client_Suitability__c
											WHERE CS_Customer_Survey_A__c =:surveySheetId OR CS_Customer_Survey_B__c =:surveySheetId
											];
 
			return sm;

    	} catch(Exception e) {
    		System.debug(e.getMessage() + e.getLineNumber() );
			throw new AuraHandledException(e.getMessage());
    		return null;
    	}
	}

	public static Boolean isIdInObject(String IdString , String ObjectName)
	{
		Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;

        Schema.SObjectType s = m.get(ObjectName) ;
        
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        String keyPrefix = r.getKeyPrefix();

        return IdString.startsWithIgnoreCase( keyPrefix );

	}


}