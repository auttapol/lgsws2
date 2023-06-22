public without sharing class RetailAccountSelector {
	
    private static string selectAccounts() {
		return
		'SELECT                                                                                                         '
		+ '		Id, Name, Account_Plan_Flag__c, Group__c, Group__r.Name, Owner.Segment__c, NI_Actual__c, NI_Plan__c      '
		+ '		, NI_SoW__c, NI_Wallet__c, NIIc_Actual__c, NIIc_Plan__c, NIIc_SoW__c, NIIc_Wallet__c, NIId_Actual__c     '
		+ '		, NIId_Plan__c, NIId_SoW__c, NIId_Wallet__c, Fee_Actual__c, Fee_Plan__c, Fee_SoW__c, Fee_Wallet__c       '
        + '		,CRM_ID__c,TMB_Customer_ID_PE__c,RTL_Is_Employee__c,Core_Banking_Suggested_Segment__c    				'
		+ 'FROM                                                                                                           '
		+ '		Account                                                                                                  '
		+ ' WHERE   Id IN : accountIds ';

	}
    
    public static List<Account> getAccountByIds(Set<Id> accountIds) {

		system.debug('::: accountIds >> ' + accountIds);
		if (accountIds == null || accountIds.size() == 0)
		throw new RetailAccountSelectorException('Set of accountIds Cannot be null');

		string sql = selectAccounts();
		system.debug('::: sql' + sql);

		return(List<Account>) Database.query(sql);

	}


	// Exception
	public class RetailAccountSelectorException extends Exception {
	}
}