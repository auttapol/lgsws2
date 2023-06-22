public without sharing class AccountPlanDepositDomesticSelector {
	
	 public static string sqlAccountPlanDepositDomesticByWalletIds(){
        return
			       'SELECT Id,AvgRatePercent__c,ShareTMBPercent__c,TMBAmount__c,TMBRate__c,SharePercentBank1__c,  '
			      +' AmountBank1__c,RateBank1__c,SharePercentBank2__c,AmountBank2__c,RateBank2__c,SharePercentBank3__c,'
			      +' AmountBank3__c,RateBank3__C,SharePercentBank4__c,AmountBank4__c,RateBank4__c,Label__c,'
			      +' TransactionType__c,Label_Value__c'
			      +' FROM AcctPlanDepositDomestic__c'
			      +' WHERE AccountPlanDepositDomesticDeposit__c IN :acctplanwalletIds';
    } 
	
	public static List<AcctPlanDepositDomestic__c> GetAccountPlanDepositDomesticByWalletIds(set<Id> acctplanwalletIds){   
		
		String sql = '';
        if(acctplanwalletIds == null )
            throw new AccountPlanDepositDomesticSelectorException('acctplanwalletIds  Cannot be null'); 
		
		sql = sqlAccountPlanDepositDomesticByWalletIds();  
        system.debug('::: sql' + sql);
        return (List<AcctPlanDepositDomestic__c>) Database.query(sql);
		
	}
	
	 public class AccountPlanDepositDomesticSelectorException extends Exception{   
    }
}