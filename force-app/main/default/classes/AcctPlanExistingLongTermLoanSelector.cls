public  without sharing  class AcctPlanExistingLongTermLoanSelector {
		 // SOQL Statement
    public static string sqlSelectQuestionairByWalletIds(){
        return  
				'SELECT 	                                                                                                              '
				+'		  AcctPlanWallet__c, InterestFullyHedge__c, CCYAmtFullyHedge__c                                                   '
				+'		, Opportunity__c, HedgingTenor__c, BankName__c, Bank__c, EquivalentAmount__c                                      '
				+'		, Collateral__c, CCYName__c, CCY__c, Name, NimcPercent__c, TypeOfLoan__c, WalletNiicYearly__c                     '
				+'		, RemainingTenorsYear__c, LTVPercent__c, InterestType__c, InterestFloatingRate__c, InterestFixedRate__c           '
				+'FROM                                                                                                                    '
				+'		AcctPlanExistingLongTermLoan__c                                                                                   '
				+'		                                                                                                                  '
				+'WHERE                                                                                                                   '
				+'     AcctPlanWallet__c IN : walletIds                                                                                   '
				+'	   and                                                                                                                '
				+'	   (CCYAmtFullyHedge__c =\'Yes\' or CCYAmtFullyHedge__c = \'No\')                                                     '
				+' 	   and                                                                                                                '
				+' 	   (InterestFullyHedge__c = \'Yes\' or InterestFullyHedge__c = \'No\')                                                '
				+' 	   and                                                                                                                '
				+' 	   (HedgingTenor__c IN (\'Full\',\'Partial\',\'No\'))                                                                 '
				+' 	   and  Opportunity__c != null                                                                                        ';
    }
    //Selectors
    public static List<AcctPlanExistingLongTermLoan__c> SelectQuestionairByWalletIds(Set<ID> walletIds){


        if(walletIds == null || walletIds.size() < 1 )
            throw new AcctPlanExistingLongTermLoanSelectorException('Set of walletIds  Cannot be null');
        string sql = sqlSelectQuestionairByWalletIds();
        //system.debug('::: sql' + sql);
        return (List<AcctPlanExistingLongTermLoan__c>) Database.query(sql);
    }
    
    
     
    // Exception
    public class AcctPlanExistingLongTermLoanSelectorException extends Exception{   
    }
    
}