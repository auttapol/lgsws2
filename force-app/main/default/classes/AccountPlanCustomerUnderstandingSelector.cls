public without sharing class AccountPlanCustomerUnderstandingSelector {
	public static string sqlAll(){
		return  'SELECT Id, Name,RefreshAsOf__c, Average_loan_outstanding__c, Ending_loan_outstanding__c, Average_CASA__c, Ending_CASA__c, TF_Volume__c, FX_volume__c, AcctPlanWallet__c,AcctPlanWallet__r.AcctPlanCompanyProfile__r.Account__c FROM AcctPlanCusUnderstanding__c ';
	}

	public static string sqlCusUnderstandingByWalletIds(){
		return  sqlAll () + ' Where AcctPlanWallet__c  IN :walletIds';
	}

   public static string sqlSummaryByAccountIds(){
		return   ' SELECT     '
				+' 		SUM(Ending_CASA__c ) EndCASA,'
				+' 		SUM(Average_CASA__c ) AvgCASA,'
				+' 		SUM(Average_loan_outstanding__c ) AvgLoan,'
				+' 		SUM(Ending_loan_outstanding__c ) EndLoan,'
				+' 		SUM(FX_volume__c ) FXvolume,'
				+' 		SUM(TF_Volume__c ) TFVolume,'
				+'		AcctPlanWallet__r.AcctPlanCompanyProfile__r.Account__c							'
				+' FROM    AcctPlanCusUnderstanding__c'
				+' WHERE   AcctPlanWallet__r.AcctPlanCompanyProfile__r.AcctPlanGroup__r.Year__c = :year '
				+'   and   AcctPlanWallet__r.AcctPlanCompanyProfile__r.Account__c IN : accountIds	'
				+' group by AcctPlanWallet__r.AcctPlanCompanyProfile__r.AcctPlanGroup__r.Year__c';
					}
   
   


	public static List<AcctPlanCusUnderstanding__c> getUnderstandingByWalletIds(Set<Id> walletIds) {   
		if(walletIds == null || walletIds.size() < 1 )
		throw new AccountPlanCustomerUnderstandingException('Set of walletIds  Cannot be null');
		string sql = sqlCusUnderstandingByWalletIds();
		system.debug('::: sql' + sql);
		return (List<AcctPlanCusUnderstanding__c>) Database.query(sql);
	}
	
	public static AggregateResult[] getSummaryByAccountIdsAndYear(Set<Id> accountIds ,string year) {   
		if(accountIds == null || accountIds.size() < 1 )
		throw new AccountPlanCustomerUnderstandingException('Set of walletIds  Cannot be null');
		string sql = sqlSummaryByAccountIds();
		system.debug('::: sql' + sql);
		return Database.query(sql);
	}
	
	
	
	
	
	
	
	
	
	// Exception
	public class AccountPlanCustomerUnderstandingException extends Exception{}
}