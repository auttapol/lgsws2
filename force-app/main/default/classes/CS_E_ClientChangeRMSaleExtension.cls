public with sharing class CS_E_ClientChangeRMSaleExtension {

	private ApexPages.StandardSetController standardController;

	public Boolean seletedOneEclient {get;set;}
	public Id recordId {get;set;}
	public List<Id> recordIdList {get;set;}

	public CS_E_ClientChangeRMSaleExtension(ApexPages.StandardSetController standardController) {

		this.standardController = standardController;
		List<E_Client_Suitability__c> ecsList = (List<E_Client_Suitability__c>) standardController.getSelected();
		recordIdList = new List<Id>();
		if( ecsList.size() == 1 )
		{		
			recordId = ecsList[0].id;
			recordIdList.add(recordId);
		}
		else if(ecsList.size() > 1 )
		{
			for(E_Client_Suitability__c ec : ecsList)
			{
				recordIdList.add(ec.Id);
			}
		}
		
	}
	
	public PageReference cancel()
    {       
    	return standardController.cancel();    
    }

	public PageReference navigateToEclientPage()
    {       
		return new ApexPages.Action('{!List}').invoke();  
    }
	
	public PageReference errorMsg()
	{
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, System.Label.E_Client_CS_Change_RM_Sales_Error_Msg));
		return null;  
	}
}