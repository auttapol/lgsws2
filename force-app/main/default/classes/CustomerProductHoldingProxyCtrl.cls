public class CustomerProductHoldingProxyCtrl {

	public string rmid { get; set; }
	public string acctId { get; set; }
	public string p { get; set; }

	public CustomerProductHoldingProxyCtrl() {
		//rmid = ApexPages.currentPage().getParameters().get('rmid');
		acctId = ApexPages.currentPage().getParameters().get('acctId');
		Account acct = RetailAccountService.GetAccountById(acctId);
		rmid = acct.TMB_Customer_ID_PE__c;		
		p = UrlHelper.encryptParams(rmid + '&' + acctId);
	}

	public PageReference redirect() {

		if (p != null && p != '') {
			PageReference pageRef = new PageReference('/apex/CustomerProductHoldingsView?p=' + p);
			return pageRef;
		}
		else {
			return null;
		}
	}
}