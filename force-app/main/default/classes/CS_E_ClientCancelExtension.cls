public with sharing class CS_E_ClientCancelExtension {

	private ApexPages.StandardSetController standardController;

	public List<E_Client_Suitability__c> eClientSelected {get;set;}

    public Map<Id,Account> eclientMap {get; set;}

	public static String E_CLIENT_STATUS_COMPLETE = 'Completed';
	

	public static User currentUserInfo{
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

	public CS_E_ClientCancelExtension(ApexPages.StandardSetController standardController) {
		this.standardController = standardController;


		eClientSelected = (List<E_Client_Suitability__c>) standardController.getSelected();

       
        List<Id> ecustomId = new List<Id>();
        for(E_Client_Suitability__c ec: eClientSelected)
        {
            ecustomId.add(ec.CS_Customer__c); 
        }
        eclientMap = new Map<Id, Account>([SELECT Id, OwnerId,CS_Murex_ID__c FROM Account Where Id in : ecustomId]);

		List<E_Client_Suitability__c> eClientValid = new List<E_Client_Suitability__c>();
        List<String> invalidEClientName = new List<String>();


		for( E_Client_Suitability__c ec : eClientSelected )
		{
			if( ec.CS_Status__c == E_CLIENT_STATUS_COMPLETE )
			{
				invalidEClientName.add(ec.name);
			}
			else
			{                
				eClientValid.add(ec);
			}

		}


        eClientSelected = eClientValid;

        if( invalidEClientName.size() > 0 )
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,
                System.Label.E_Client_CS_E_ClientCancelExtension_Error_Msg + String.join(invalidEClientName, ', ') ));
        }
	}

	public PageReference cancelConfirm()
    {       
        for( E_Client_Suitability__c ec : eClientSelected )
        {
            ec = CSCancelEClientController.setCancelEclient(ec,eclientMap.get(ec.CS_Customer__c),currentUserInfo);
        }

        return standardController.save();   

    }

    public PageReference cancelAction()
    {       
    	return standardController.cancel();    
    }
	
}