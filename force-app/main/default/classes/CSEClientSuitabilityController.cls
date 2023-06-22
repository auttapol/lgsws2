public with sharing class CSEClientSuitabilityController {
	public CSEClientSuitabilityController() {
		
	}
	@AuraEnabled
    public static void saveEClientRecordId(String recordIdEClient, String surveySheetId, String formType)
    {
		System.debug(formType);
		E_Client_Suitability__c ec = new E_Client_Suitability__c();
		if(formType == 'FormA') {
			ec.CS_Customer_Survey_A__c = surveySheetId;
		} else if(formType == 'FormB') {
			 ec.CS_Customer_Survey_B__c = surveySheetId;
		}

		ec.Id = recordIdEClient;

		update ec; 

	}

	public Class FormList
	{
	@AuraEnabled
	public Survey_Sheet__c FormA {get;set;}
	@AuraEnabled
	public Survey_Sheet__c FormB {get;set;}
	@AuraEnabled
	public User OwnerA {get;set;}
	@AuraEnabled
	public User OwnerB {get;set;}
	@AuraEnabled
	public E_Client_Suitability__c EClient {get;set;}
	}

	@AuraEnabled
    public static FormList getFormList(String recordId)
    {
		FormList fl = new FormList();
		try {
			fl.EClient = 
				[SELECT 
					Id, OwnerId, Name, CS_Customer_Survey_A__c, CS_Customer_Survey_B__c, CS_RM__c, CS_Status__c, LastModifiedBy.Name, CreatedDate, LastModifiedDate,
					CS_Sales_Owner__c,CS_RM_TH_Approved_Date_Tme__c, CS_Sales_TH_Approved_Date_Time__c,Reverse_Reason__c
					FROM E_Client_Suitability__c
					WHERE Id =:recordId
					];
			String IdFormA = fl.EClient.CS_Customer_Survey_A__c;
			String IdFormB = fl.EClient.CS_Customer_Survey_B__c;
			
			fl.FormA = 
				[SELECT 
					Id, Name, Status__c, Survey_Version__c, Info_1__c, Info_2__c, Total_Score__c, Customer__c, Survey_Type__c, CreatedBy.Name, 
					LastModifiedBy.Name, CreatedDate, LastModifiedDate, OwnerId 
					FROM Survey_Sheet__c
					WHERE Id =:IdFormA
					];
			
			fl.FormB = 
				[SELECT 
					Id, Name, Status__c, Survey_Version__c, Info_1__c, Info_2__c, Total_Score__c, Customer__c, Survey_Type__c, CreatedBy.Name, 
					LastModifiedBy.Name, CreatedDate, LastModifiedDate, OwnerId 
					FROM Survey_Sheet__c
					WHERE Id =:IdFormB
					];
			String IdOwnerA = fl.FormA.OwnerId;
			String IdOwnerB = fl.FormB.OwnerId;

			fl.OwnerA = 
				[SELECT 
					Id, Name 
					FROM User 
					WHERE Id=:IdOwnerA
					];

			fl.OwnerB = 
				[SELECT 
					Id, Name 
					FROM User 
					WHERE Id=:IdOwnerB
					];

			

			return fl;
    	} catch(Exception e) {
    		System.debug(e.getMessage() + ' ' + e.getLineNumber() );
    		return null;
    	}
	}

	
	public Class SurveyEClientWrapper
	{

	@AuraEnabled
	public E_Client_Suitability__c EClient {get;set;}

	}

	@AuraEnabled
	public static E_Client_Suitability__c SurveyEClient(String recordId, String formType) {
		
		try {
			E_Client_Suitability__c sew =  
				[SELECT 
					Id, OwnerId, Name, CS_Customer_Survey_A__c, CS_Customer_Survey_B__c, CS_RM__c, CS_Status__c, LastModifiedBy.Name, CreatedDate, LastModifiedDate
					FROM E_Client_Suitability__c
					WHERE Id =:recordId
					];
			String idSurveySheet; 

			if(formType == 'FormA'){
				idSurveySheet =  sew.CS_Customer_Survey_A__c; 
		
			} else if(formType == 'FormB') {
				idSurveySheet =  sew.CS_Customer_Survey_B__c; 

			}

			return sew;
		}
		catch (Exception e)
		{
			System.debug(e.getMessage() );
    		throw new AuraHandledException(System.Label.E_Client_CSEClientSuitabilityController_GetSurvey_Error_Msg);
		}

		
	}

	// @AuraEnabled
	// public static void saveScore(Integer result, String recordIdEClient)
	// {
	// 	try {
	// 		E_Client_Suitability__c ec = [SELECT Id, CS_Score__c FROM E_Client_Suitability__c WHERE Id=:recordIdEClient limit 1];

	// 		ec.CS_Score__c  = Integer.valueOf(result); 
	// 		update ec;
	// 	} catch(Exception e) {
	// 		System.debug(e.getMessage() );
	// 	}
	// }

	@AuraEnabled
    public static List<Survey_Answer__c> getSurveyAnswer(String surveySheetId)
    {
		try {
			List<Survey_Answer__c> sm = [SELECT Id, Name, Survey_Question__c, Survey_Sheet__c, Survey_Choice__c, Choice_Value__c, Score__c FROM Survey_Answer__c WHERE Survey_Sheet__c =:surveySheetId];
			return sm;
    	} catch(Exception e) {
    		System.debug(e.getMessage() );
    		return null;
    	}
	}

	@AuraEnabled
	public static User getUserName(String recordId)
	{
		try {
			User user = [SELECT Id, Name FROM User WHERE Id=:recordId limit 1];
			return user;
		} catch(Exception e) {
			System.debug(e.getMessage() );
			return null;
		}
	}

	@AuraEnabled
    public static Survey_Sheet__c getSurveySheet(String recordId)
    {
		try {
			Survey_Sheet__c sm = [SELECT Id, Name, Info_1__c, Info_2__c, Total_Score__c, Customer__c, Survey_Version__c,Status__c,Survey_Type__c FROM Survey_Sheet__c WHERE Id =:recordId];

			return sm;
    	} catch(Exception e) {
    		System.debug(e.getMessage() );
    		return null;
    	}
	}


	@AuraEnabled
    public static UserRecordAccess getUserRecordAccess(String recordId)
    {
		try {
			UserRecordAccess userRecord = [SELECT RecordId,HasEditAccess FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId =: recordId ];
			
			return userRecord;
    	} catch(Exception e) {
    		System.debug(e.getMessage() );
    		return null;
    	}
	}

	@AuraEnabled
    public static void updateSurveyStatus(String idSurveySheet)
    {
		try {
			Survey_Sheet__c sh = [SELECT Id, Status__c,Survey_Version__c FROM Survey_Sheet__c WHERE Id =:idSurveySheet limit 1];
    		sh.Status__c = 'In Progress';
			update sh;

    	} catch(Exception e) {
    		System.debug(e.getMessage() );
    	}
	}

	@AuraEnabled
    public static void updateEClientCSLevel(String eClientRecoredId, String surveySheetId)
    {
		
		try{
			
			Survey_Sheet__c surveySheet = [SELECT Id, Score_Group__c, Total_Score__c, Survey_Version__c FROM Survey_Sheet__c WHERE Id =:surveySheetId LIMIT 1];
			E_Client_Suitability__c eClient = [SELECT Id, CS_Level__c,New_CS_Level__c FROM E_Client_Suitability__c WHERE Id=:eClientRecoredId limit 1];

			eClient.CS_Level__c = surveySheet.Score_Group__c;
			eClient.New_CS_Level__c = surveySheet.Score_Group__c;
			update eClient;

		} catch(Exception e){
			System.debug(e.getMessage());
		}

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
}