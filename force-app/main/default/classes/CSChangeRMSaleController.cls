public without sharing class CSChangeRMSaleController {
	public CSChangeRMSaleController() {
		
	}
	public static String SURVEY_TYPE = 'E-Client Suitability';
	public static String E_CLIENT_STATUS_COMPLETE = 'Completed';
	public static String E_CLIENT_STATUS_PENDING_RM = 'Pending RM TH';
	public static String E_CLIENT_STATUS_PENDING_SALES = 'Pending Sales TH';
	public static String E_CLIENT_STATUS_SUSPENDED = 'Suspended';

	
	@AuraEnabled
	public static LIst<E_Client_Suitability__c> getCurrentEclient(List<Id> eclientId)
	{
		try 
		{
			List<String> statusNotAvailableToChangeRM = new List<String>();
			statusNotAvailableToChangeRM.add(E_CLIENT_STATUS_COMPLETE);
			statusNotAvailableToChangeRM.add(E_CLIENT_STATUS_PENDING_RM);
			statusNotAvailableToChangeRM.add(E_CLIENT_STATUS_PENDING_SALES);
			statusNotAvailableToChangeRM.add(E_CLIENT_STATUS_SUSPENDED);

			List<E_Client_Suitability__c> eClient = [SELECT Id,Name,CS_Status__c,CS_Basic_Flag__c,
					CS_RM__c,CS_Sales_Owner__c,OwnerId,CS_Expiry_Date_Next__c,CS_Customer__c,
					CS_Customer_Survey_A__c,CS_Customer_Survey_B__c,
					CS_Sales_Owner__r.Name,CS_RM__r.Name
					From E_Client_Suitability__c
					 WHERE Id = : eclientId
					 AND CS_Status__c not in :statusNotAvailableToChangeRM
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
	public static List<E_Client_Suitability__c> confirmEclientListView( List<E_Client_Suitability__c> eClient )
    {
		update eClient;

    	String errorMessage = '';

    	Set<Id> surveySheetIdset = new Set<Id>();
		List<String> ecIdList = new List<String>();
		String userId;
    	for(E_Client_Suitability__c ec : eClient)
    	{
    		surveySheetIdset.add(ec.CS_Customer_Survey_A__c);
    		surveySheetIdset.add(ec.CS_Customer_Survey_B__c);
    	}

    	//system.debug('surveySheetIdset: ' + surveySheetIdset);

    	Map<ID,Survey_Sheet__c> surveySheetIdMap = new Map<ID,Survey_Sheet__c>( [SELECT Id,OwnerId FROM Survey_Sheet__c WHERE id in :surveySheetIdset ] );

		try{
			
			List<Survey_Sheet__c> shList = new List<Survey_Sheet__c>();

			for(E_Client_Suitability__c ec : eClient)
			{				
				if( surveySheetIdMap.containsKey( ec.CS_Customer_Survey_A__c ) )
				{
					Survey_Sheet__c formA = surveySheetIdMap.get(ec.CS_Customer_Survey_A__c);
					formA.OwnerId =  ec.CS_RM__c;
					shList.add(formA);
				}

				if( surveySheetIdMap.containsKey( ec.CS_Customer_Survey_B__c ) )
				{
					Survey_Sheet__c formB = surveySheetIdMap.get(ec.CS_Customer_Survey_B__c);
					formB.OwnerId =  ec.CS_Sales_Owner__c;
					shList.add(formB);
				}

				ecIdList.add(ec.Id);

				userId = ec.CS_RM__c;
			}

			if( shList.size() > 0 )
			{
				update shList;
			}

			if(ecIdList.size() > 0)
			{
				CSEClientController.setManualShareRead(ecIdList,userId);
			}

			return eClient;
		}
		catch(Exception e) 
		{
			errorMessage = e.getMessage();
    		System.debug(e.getMessage() + e.getLineNumber() );
    		
		}

		throw new AuraHandledException( errorMessage );
		return null;
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
			
			return sh;
		}
		catch(Exception e) 
		{
    		System.debug(e.getMessage() + e.getLineNumber() );
    		return null;
		}
	}

	@AuraEnabled
	public static E_Client_Suitability__c updateCurrentEclient(E_Client_Suitability__c eClient)
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
    public static User getCurrentUser(){
     // query current user information  
      User oUser = [Select Id,Name,Username,Country,Email,FirstName,LastName,IsActive,Profile.Name 
                 FROM User Where Id =: userInfo.getUserId() AND isActive=true];
        return oUser;
    }


	@AuraEnabled
   	public static void setManualShareRead(List<E_Client_Suitability__c> eClient )
	{
		try
		{	
			List<String> ecIdList = new List<String>();
			String userId;

			for(E_Client_Suitability__c ec : eClient)
			{								
				ecIdList.add(ec.Id);

				userId = ec.CS_RM__c;
			}

			if(ecIdList.size() > 0)
			{
				CSEClientController.setManualShareRead(ecIdList,userId);
			}
					
		}
		catch(Exception e) {
   			System.debug(e.getMessage() );
   		}
	}

}