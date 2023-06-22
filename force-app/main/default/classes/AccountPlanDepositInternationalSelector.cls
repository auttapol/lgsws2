public without sharing class AccountPlanDepositInternationalSelector {
	 public static string sqlAccountPlanDepositInternationalByWalletIds(){
        return
				'SELECT Id,AmountBank1__c, AmountBank2__c, AmountBank3__c, AmountBank4__c,   '
				+'AmtPerMonth__c,CCY__c,CCY__r.Name, Label__c, RateBank1__c, RateBank2__c, RateBank3__c,   '
				+'RateBank4__c, SharePercentBank1__c, SharePercentBank2__c, SharePercentBank3__c,  '
				+'SharePercentBank4__c, ShareTMBPercent__c, TenorPerPeriod__c,TMBAmount__c,   '
				+'TMBRate__c, AvgRatePercent__c, TransactionType__c, Label_Value__c  '
				+'FROM AcctPlanDepositInternational__c    '
				+'WHERE AccountPlanDepositInternationalDeposit__c  IN :acctplanwalletIds  ';

    } 
	
	public static List<AcctPlanDepositInternational__c> GetAccountPlanDepositInternationalByWalletIds(set<Id> acctplanwalletIds){   
		
		String sql = '';
        if(acctplanwalletIds == null )
            throw new AccountPlanDepositInternationalSelectorException('acctplanwalletIds  Cannot be null'); 
		
		sql = sqlAccountPlanDepositInternationalByWalletIds();  
        system.debug('::: sql' + sql);
        return (List<AcctPlanDepositInternational__c>) Database.query(sql);
		
	}
	
	 public class AccountPlanDepositInternationalSelectorException extends Exception{   
    }
}