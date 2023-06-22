public with sharing class CSGeneratePDFMainController {
	public E_Client_Suitability__c ec {get; set;}
	public Survey_Sheet__c shA {get;set;}
	public Survey_Sheet__c shB {get;set;}

	public User userA {get;set;}
	public User userB {get;set;}

	public Account account {get;set;}

	public SurveyManagerController.AwnserWrapper awserDataA {get;set;}
	public SurveyManagerController.AwnserWrapper awserDataB {get;set;}

	public Map<ID,Survey_Answer__c> AnsMapA { get; set; } 
	public Map<ID,Survey_Answer__c> AnsMapB { get; set; } 

	public boolean showCover {get;set;}
	public boolean showFormA {get;set;}
	public boolean showFormB {get;set;}
	public boolean showCSlevel { get{ if( showCSlevel == null ) showCSlevel = false; return showCSlevel; } set; }

	public String approvedDate {get; set;}
	public String sale_ApprovedBy {get; set;}
	public String rm_ApprovedBy {get; set;}

    public CSGeneratePDFMainController()
    {
		Id id = apexpages.currentpage().getparameters().get('id');
		String formView = apexpages.currentpage().getparameters().get('surveySheet');


		if( formView == 'formA' )
		{
			showCover = false;
			showFormA = true;
			showFormB = false;
		}
		else if( formView == 'formB' )
		{
			showCover = false;
			showFormA = false;
			showFormB = true;
		}
		else 
		{
			showCover = true;
			showFormA = true;
			showFormB = true;
		}

		try {
			System.debug('id:'+id);
			ec =  [SELECT Id, OwnerId, Name, CS_Customer_Survey_A__c, CS_Customer_Survey_B__c, CS_RM__r.Name,
					CS_Sales_Owner__r.Name, CS_Status__c, CS_Customer__c,
					LastModifiedBy.Name, CreatedDate, LastModifiedDate,CS_RM_TH_Approved_Date_Tme__c, 
					CS_Sales_TH_Approved_Date_Time__c,CS_Sales_TH__c, CS_RM_TH__c,RM_Submit_Date_Time__c,RM_TH_Approve_DT__c,PDF_Generated_Date_Time__c,Sales_TH_Approved_DT__c
					FROM E_Client_Suitability__c
					WHERE Id =: id
					];
			System.debug('xxxxx:'+ec);
			System.debug('Now:'+System.now());
			System.debug('Last Modified Date :'+ ec.LastModifiedDate);
			System.debug(ec.PDF_Generated_Date_Time__c);
			account = [SELECT Name, Registered_Address_Line_1_PE__c, Registered_Address_Line_2_PE__c, Registered_Address_Line_3_PE__c,
		 				Country_Registered_PE__c, Province_Registered_PE__c, Zip_Code_Registered_PE__c
					FROM Account
					WHERE Id =: ec.CS_Customer__c
					];

			shA = [SELECT Id, OwnerId, Name, LastModifiedDate, Customer__r.Name ,Info_1__c, Customer__c 
					FROM Survey_Sheet__c WHERE Id =: ec.CS_Customer_Survey_A__c];
			shB = [SELECT Id, OwnerId, Name, LastModifiedDate, Customer__r.Name ,Info_1__c, Customer__c, Total_Score__c, Score_Group__c, Status__c
					FROM Survey_Sheet__c WHERE Id =: ec.CS_Customer_Survey_B__c];

			List<String> isStatusShowCSlevelSurveySheet = new List<String>{'Ready for Review', 'Pending Approve', 'Completed'};
			if(isStatusShowCSlevelSurveySheet.contains(shB.Status__c)) showCSlevel = true;

			userA = [SELECT Id, Name FROM User WHERE Id =: shA.OwnerId];
			userB = [SELECT Id, Name FROM User WHERE Id =: shB.OwnerId];


			awserDataA = SurveyManagerController.getSurveyAnswer(shA.id);
			AnsMapA = getAnswer(awserDataA);

			awserDataB = SurveyManagerController.getSurveyAnswer(shB.id);
			AnsMapB = getAnswer(awserDataB);

			// generatedDate = ec.PDF_Generated_Date_Time__c.format('d MMMM yyyy');
			approvedDate = ec.Sales_TH_Approved_DT__c.format('d MMMM yyyy');
			String[] sale_approve = ec.CS_Sales_TH_Approved_Date_Time__c.split(',');
			sale_ApprovedBy = sale_approve[0];
			String[] rm_approve = ec.CS_RM_TH_Approved_Date_Tme__c.split(',');
			rm_ApprovedBy = rm_approve[0];

    	} catch(Exception e) {
    		System.debug( 'pdf query error: ' + e.getMessage() );
    	}
	}


		//Map<question ID,Map<choice ID,Survey_Answer__c>> for get list of answer by QuestionID
	public static Map<ID,Survey_Answer__c> getAnswer(SurveyManagerController.AwnserWrapper awserData){
	
		try {
			Map<ID,Survey_Answer__c> Allans = new Map<ID,Survey_Answer__c>();
			Set<ID> questionId = new Set<ID>();
			questionId = awserData.survey.allQuestionList.KeySet();

			List<Survey_Choice__c> chList = [SELECT id, Survey_Question__c, Name 
						FROM Survey_Choice__c
						WHERE Survey_Question__c IN :questionId];

			Map<Id,Survey_Answer__c> choiceIdAwnserMap = new Map<Id,Survey_Answer__c>();	
			for(Survey_Answer__c ans : awserData.awnser){
				choiceIdAwnserMap.put( ans.Survey_Choice__c , ans );
			}
			
			for(Survey_Choice__c c : chList){

				if(  choiceIdAwnserMap.containsKey(c.Id)  )
				{
					Allans.put(c.id, choiceIdAwnserMap.get(c.Id) );
				}
				else
				{
					Survey_Answer__c x = new Survey_Answer__c();
					x.Choice_Value__c = ' ';
					Allans.put(c.id, x );
				}

			
			}
			
			
			return Allans;

    		
    	} catch(Exception e) {

			throw new AuraHandledException(e.getMessage());
    		return null;
    	}


			
	}


}