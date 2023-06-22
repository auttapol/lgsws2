public with sharing class CSCancelEClientController {
	public CSCancelEClientController() {
		
	}

	public static String E_CLIENT_STATUS_COMPLETE = 'Completed';

	private static User currentUserInfo{
        get{
            if( currentUserInfo == null )
            {
                currentUserInfo = [SELECT Id, Username, Segment__c, Reporting_Segment__c, Profile.name
                    FROM User 
                    WHERE Id =: UserInfo.getUserId()
                    LIMIT 1];
            }

            return currentUserInfo;
        }
        set;
    }


	@AuraEnabled
	public static E_Client_Suitability__c getEclient(String recordId) {

		try {
			E_Client_Suitability__c ec =  [SELECT Id, OwnerId, Name, CS_RM__r.Name, CS_Sales_Owner__r.Name,
			CS_Customer__r.Name, CS_Status__c, LastModifiedBy.Name, CreatedDate, LastModifiedDate,
			CS_Customer_Survey_A__c, CS_Customer_Survey_B__c
			FROM E_Client_Suitability__c
			WHERE Id =:recordId
			];
			return ec;
		}
		catch (Exception e)
		{
			System.debug(e.getMessage() );
    		throw new AuraHandledException(System.Label.E_Client_CSCancelEClientController_GetEclient_Error_Msg);
		}
	
	}
	
	public static E_Client_Suitability__c setCancelEclient(E_Client_Suitability__c eclient,Account acc,User oUser)
    {
		Id pendingRecordTypeId = Schema.Sobjecttype.E_Client_Suitability__c.getRecordTypeInfosByName().get('Completed').getRecordTypeId();

		eClient.CS_Expiry_Date_Next__c = null;
		eClient.CS_SIgn_Date__c = null;
		eClient.CS_Score__c = 0;
		eClient.CS_Murex_ID__c = acc.CS_Murex_ID__c;

		eClient.CS_Status__c = E_CLIENT_STATUS_COMPLETE;
		eClient.CS_Level__c = 'Basic'; 
		eClient.CS_Cancelled_By__c = UserInfo.getName() + ', ' +  Datetime.now().format();	
		eClient.RecordTypeId = pendingRecordTypeId;

        return eclient;
    }

	@AuraEnabled
	public static E_Client_Suitability__c updateCurrentEclient(E_Client_Suitability__c eClient)
	{

		try 
		{
			System.debug('eClient ' +eClient);
			List<Account> acc  = [SELECT Id, OwnerId,CS_Murex_ID__c FROM Account Where Id =: eClient.CS_Customer__c LIMIT 1];
			User oUser = [Select Id,Name,Username,Country,Email,FirstName,LastName,IsActive 
			FROM User Where Id =: userInfo.getUserId() AND isActive=true LIMIT 1];

			System.debug('acc ' +acc);
			System.debug('oUser ' +oUser);

			eClient = setCancelEclient(eClient,acc[0],oUser);
				
			System.debug('eClient:'+eClient);	
			updateSurveyStatus(eClient.CS_Customer_Survey_A__c);
			updateSurveyStatus(eClient.CS_Customer_Survey_B__c);

			update eClient;
			return eClient;
        }	
		catch(Exception e) 
		{
			System.debug(e.getMessage());
			throw new AuraHandledException(e.getMessage());
			
		}
	}

	@AuraEnabled
    public static void updateSurveyStatus(String idSurveySheet)
    {
		try {
			Survey_Sheet__c sh = new Survey_Sheet__c(Id = idSurveySheet);
    		sh.Status__c = 'Cancelled';
			update sh;

    	} catch(Exception e) {
    		System.debug(e.getMessage() );
    	}
	}
}