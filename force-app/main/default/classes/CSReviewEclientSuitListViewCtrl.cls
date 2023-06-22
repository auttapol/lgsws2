public with sharing class CSReviewEclientSuitListViewCtrl {

	private ApexPages.StandardSetController standardController;

	public Boolean seletedOneEclient {get;set;}
	public Id recordId {get;set;}

	public CSReviewEclientSuitListViewCtrl(ApexPages.StandardSetController standardController) {

		this.standardController = standardController;
		List<E_Client_Suitability__c> ecsList = (List<E_Client_Suitability__c>) standardController.getSelected();

		if( ecsList.size() == 1 )
		{
			recordId = ecsList[0].id;
			seletedOneEclient = true;
		}
		else
		{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, System.Label.E_Client_CSReviewEclientSuitListViewCtrl_Select_Error_Msg));

			seletedOneEclient = false;
		}

	}

	public PageReference cancel()
    {       
    	return standardController.cancel();    
    }

    public PageReference navigateToEclientPage()
    {       
    	ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, System.Label.E_Client_CSReviewEclientSuitListViewCtrl_NavigateToEclientPage_Success_Msg));
        PageReference pg = new PageReference('/'+recordId);
        pg.setRedirect(true);
        return pg;     
    }

    public PageReference errorMsg()
	{
		String errorMessage = Apexpages.currentPage().getParameters().get('errorMessage');
		if( errorMessage == null )
		{
			errorMessage = System.Label.E_Client_VerifyCustomer_E_Client_Review_Failed;
			system.debug('No Error message, use default.');
		}

		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, errorMessage ));
		return null;  
	}

    

}