public without sharing class CSEClientController {
	
	public static String SURVEY_TYPE = 'E-Client Suitability';

	@AuraEnabled
	public static E_Client_Suitability__c getCurrentEclient(Id eclientId)
	{
		Datetime dt = System.now();
		String gmtString = dt.format('yyyy');
		Integer currentYear = Integer.valueOf(gmtString);

		try 
		{
			E_Client_Suitability__c eClient = [SELECT Id,Name,CS_Status__c,CS_Basic_Flag__c,
					CS_RM__c,CS_Sales_Owner__c,OwnerId,CS_Expiry_Date_Next__c,CS_Customer__c,
					CS_Score__c,CS_Murex_ID__c,CS_SIgn_Date__c,CS_New_Customer_flag__c 
					From E_Client_Suitability__c
					 WHERE Id = : eclientId
					];

			return eClient;

		} 
		catch(Exception e) 
		{
			System.debug(e.getMessage());
			return null;
			
		}
		
	}

	@AuraEnabled
	public static E_Client_Suitability__c updateCurrentEclientToBasic(E_Client_Suitability__c eClient)
	{

		try 
		{
			List<Account> acc  = [SELECT Id, OwnerId,CS_Murex_ID__c FROM Account Where Id =: eClient.CS_Customer__c LIMIT 1];
			User oUser = [SELECT Id,Name,Username,Country,Email,FirstName,LastName,IsActive 
                 FROM User Where Id =: userInfo.getUserId() AND isActive=true LIMIT 1];
			Id pendingRecordTypeId = Schema.Sobjecttype.E_Client_Suitability__c.getRecordTypeInfosByName().get('Completed').getRecordTypeId();

			eClient.CS_Level__c = 'Basic';
			eClient.New_CS_Level__c = 'Basic';
			eClient.CS_Score__c = 0;
			eClient.CS_Expiry_Date_Next__c = null;
			eClient.CS_SIgn_Date__c = null;
			eClient.CS_Murex_ID__c = acc[0].CS_Murex_ID__c;
			if(eClient.CS_RM__c == null)
			{
				eClient.CS_RM__c = acc[0].OwnerId;
			}

			eClient.CS_Sales_Owner__c = oUser.Id;
			eClient.Sale_Submitted_By__c = oUser.FirstName +' '+ oUser.LastName + ', ' + DateTime.now().format('dd/MM/yyyy HH:mm');	 
			eClient.Sale_Submit_Date_Time__c = Datetime.now();
			eClient.RecordTypeId = pendingRecordTypeId;
			eClient.OwnerId = oUser.Id;

			update eClient;
			return eClient;
		}
		catch(Exception e) 
		{
			System.debug(e.getMessage()  +  e.getLineNumber() );
			//throw new AuraHandledException(e.getMessage());
			return null;
			
		}
	}

	@AuraEnabled
	public static E_Client_Suitability__c updateEclient(E_Client_Suitability__c eClient)
	{

		try 
		{
			update eClient;
			return eClient;
		}
		catch(Exception e) 
		{
			System.debug(e.getMessage());
			return null;
			
		}
	}

	@AuraEnabled
    public static void saveEClientRecordId(String recordIdEClient, String surveySheetId, String formType)
    {
		System.debug('recordIdEClient: ' + recordIdEClient);
		try {
			E_Client_Suitability__c ec = new E_Client_Suitability__c();

			if(formType == 'FormA') {
				ec.CS_Customer_Survey_A__c = surveySheetId;

			} else if(formType == 'FormB') {
				ec.CS_Customer_Survey_B__c = surveySheetId;

			}		
			ec.Id = recordIdEClient;

			update ec; 
		}
		catch(Exception e) {
    		System.debug(e.getMessage() );
    	}
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
    		System.debug(e.getMessage() );
    		return null;
    	}
	}
	@AuraEnabled
    public static List<Survey_Manager__c> getSurveySheet()
    {
		try {
			List<Survey_Manager__c> svm = [SELECT Id, Name, Survey_Version__c FROM Survey_Manager__c];

			return svm;
    	} catch(Exception e) {

    		System.debug(e.getMessage() );
    		return null;
    	}
	}


	@AuraEnabled
	public static E_Client_Suitability__c confirmEclient( E_Client_Suitability__c eClient )
    {
		List<String> ecList = new List<String>(); 
		try{
			Survey_Manager__c smA = [SELECT Id,Name,Survey_Version__c FROM Survey_Manager__c WHERE CS_Survey_Manager_Key__c  = 'eclient-formA' ];
			Survey_Manager__c smB = [SELECT Id,Name,Survey_Version__c FROM Survey_Manager__c WHERE CS_Survey_Manager_Key__c  = 'eclient-formB' ];


			Survey_Sheet__c formA = insertSurveySheet(smA, eClient.CS_Customer__c, eClient.CS_RM__c);
			Survey_Sheet__c formB = insertSurveySheet(smB,eClient.CS_Customer__c,eClient.CS_Sales_Owner__c);

			List<Survey_Sheet__c> shList = new List<Survey_Sheet__c>();
			shList.add(formA);
			shList.add(formB);

			insert shList;

			eClient.CS_Customer_Survey_A__r = formA;
			eClient.CS_Customer_Survey_B__r = formB;

			eClient.CS_Customer_Survey_A__c = formA.Id;
			eClient.CS_Customer_Survey_B__c = formB.Id;
			updateEclient(eClient);

			ecList.add(eClient.Id);
			setManualShareRead(ecList,eClient.CS_RM__c);
			// setManualShareReadSurvey(formA.Id,eClient.CS_Sales_Owner__c);
			// setManualShareReadSurvey(formB.Id,eClient.CS_RM__c);

			return eClient;
		}
		catch(Exception e) 
		{
    		System.debug(e.getMessage() + e.getLineNumber() );
    		return null;
		}
	}

	@AuraEnabled
	public static Survey_Sheet__c insertSurveySheet( Survey_Manager__c sm , String  eCustomerId ,String ownerNameId )
    {
		try
		{
			Survey_Sheet__c sh = new Survey_Sheet__c();
			sh.Survey_Version__c = sm.Survey_Version__c;
			sh.Info_1__c = sm.name;
			sh.Customer__c = eCustomerId;
			sh.OwnerId = ownerNameId;
			sh.Survey_Type__c = SURVEY_TYPE;
			sh.Status__c = 'New';
			
			return sh;
		}
		catch(Exception e) 
		{
    		System.debug(e.getMessage() + e.getLineNumber() );
    		return null;
		}
	}

	@AuraEnabled
    public static void setManualShareRead(List<String> recId,String userId)
	{
		List<Id> recordId = recId;

		Id userOrGroupId = userId;
		try
		{	
			CSEClientSharing.deleteSharingEclient(recordId);		
			CSEClientSharing.manualShareRead(recordId, userOrGroupId);	
				
		}
		catch(Exception e) {
    		System.debug(e.getMessage() );
    	}
	}

	// @AuraEnabled
    // public static void setManualShareReadSurvey(String recId,String userId)
	// {
	// 	Id recordId = recId;
	// 	Id userOrGroupId = userId;
	// 	try
	// 	{	
	// 		CSEClientSharing.manualShareReadSurveySheet(recordId, userOrGroupId);		
	// 	}
	// 	catch(Exception e) {
    // 		System.debug(e.getMessage() );
    // 	}
	// }

	
	// @AuraEnabled
    // public static void setManualShareEdit(String recId,String userId)
	// {
	// 	Id recordId = recId;
	// 	Id userOrGroupId = userId;
	// 	try
	// 	{	
	// 		CSEClientSharing.manualShareEditSurveySheet(recordId, userOrGroupId);		
	// 	}
	// 	catch(Exception e) {
    // 		System.debug(e.getMessage() );
    // 	}
	// }

}