public with sharing class FXOrderItemSubmitToTraderController {
	private Id recordId;

	public FXOrderItemSubmitToTraderController(ApexPages.StandardController sc)
	{
		recordId = sc.getRecord().Id;
	}

	public PageReference doForward()
	{
		// Use the old page name here
		ApexPages.PageReference pr = Page.FXOrderSubmitToTrader;
		pr.getParameters().put('Id', recordId);
		pr.setRedirect(true);
		return pr; 
	}
}