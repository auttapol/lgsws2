public class AcctSingleViewProxyCtrl {
	private final ApexPages.StandardController std;
	private final Account acct;
	private List<RecordType> recTypes;
	public String paramRec { get; set; }


	public AcctSingleViewProxyCtrl(ApexPages.StandardController controller) {
		std = controller;
		acct = (Account) std.getRecord();

		System.debug('Account id is : '+ acct.Id);

		// Get Record TypeID and Name
		recTypes = [select Id, Name, sobjectType, DeveloperName from RecordType where Id = :acct.RecordTypeId];
		paramRec = ApexPages.currentPage().getParameters().get('RecordType');
	}
	public PageReference redirectPage() {
		system.debug(':::: Account Id  = ' + acct.Id);
		string url = '/';
		if (acct.id != null) {

			if (recTypes[0].DeveloperName == 'Existing_Customer') {
				url = '/apex/AccountUpdateV2View?id=' + acct.Id;
			}
			else if (recTypes[0].DeveloperName == 'Prospect') {
				url = '/apex/ProspectUpdatePE?id=' + acct.Id;
			}
			else
			{
				// Retail customer
				url = '/apex/RetailCustomerEdit?id=' + acct.Id + '&RecordType=' + recTypes[0].Id + '&retURL=/' + acct.Id;
			}

		}
		else {
			// New Records
			List<RecordType> re = [select Id, Name, sobjectType, DeveloperName from RecordType where DeveloperName = 'Prospect'];
			url = '/apex/AccountCreationPE?RecordType=' + re[0].Id;
			System.debug('Prospect = ' + re[0].Id);
			System.debug('paramRec = ' + paramRec);

			if (re[0].Id != paramRec)
			{
				// Retail customer
				url = '/apex/RetailCustomerCreation?RecordType=' + paramRec + '&retURL=/001/o';
			}
		}

		system.debug(':::: url  = ' + url);
		PageReference page = new PageReference(url);
		page.setRedirect(true);
		return page;
	}
	public PageReference redirectMobile() {

		system.debug(':::: Account Id  = ' + acct.Id);
	    string url = '/apex/AccountCreationPEMobile';
	    if (acct.id != null) {
	      url += '?id=' + acct.id;
	    }
	    if (recTypes.size() > 0) {
		      if (recTypes[0].Name == 'Existing Customer') {
		        url = '/apex/AccountUpdateV2MobileLayout?id=' + acct.Id;
		      } else if (recTypes[0].Name == 'Prospect') {
		        url = '/apex/ProspectUpdatePEMobile?id=' + acct.Id;
		      }
		      else
		      {
		        // Retail customer
		        if (acct.id != null)
		        	url = '/apex/RetailCustomerEdit?id=' + acct.Id + '&RecordType=' + recTypes[0].Id + '&retURL=/' + acct.Id;
		        else 
		        	url = '/apex/RetailCustomerCreation';
		      }
	    }
	    system.debug(':::: url  = ' + url);
	    PageReference page = new PageReference(url);
	    page.setRedirect(true);
	    return page;
	}
}