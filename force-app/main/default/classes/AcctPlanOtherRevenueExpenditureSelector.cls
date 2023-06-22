public without sharing class AcctPlanOtherRevenueExpenditureSelector {
	 // SOQL Statement
    public static string sqlSelectAcctPlanOtherRevenueExpenditureInBusinessOppByWalletIds(){
        return   
				 'SELECT AcctPlanWallet__c,ExpectedAmountOrHistoricalAmount__c, HedgingPolicy__c, Name, Opportunity__c   '
				+'	   ,RevenueOrExpenditure__c, MismatchCurrency__c, Timeline__c,  Currency__c                          '
				+'FROM                                                                                                   '
				+'	AcctPlanOtherRevenueExpenditure__c                                                                   '
				+'WHERE                                                                                                  '
				+'	AcctPlanWallet__c IN : walletIds                                                                     '
				+'      and (                                                                                            '
				+'      		(MismatchCurrency__c = \'Yes\' or MismatchCurrency__c = \'No\')                          '
				+'      		or                                                                                       '
				+'      		(HedgingPolicy__c IN                                                                     '
				+'								(                                                                        '
				+'									\'No hedge\',                                                        '
				+'									\'Natural hedge\',                                                   '
				+'									\'Spot\',                                                            '
				+'									\'Forward\',                                                         '
				+'									\'Option\',                                                          '
				+'									\'Matching\'                                                         '
				+'								)                                                                        '
				+'			)      		                                                                                 '
				+'      	  )                                                                                          ';
      
		
    }
    //Selectors
    public static List<AcctPlanOtherRevenueExpenditure__c> SelectQuestionairByWalletIds(Set<ID> walletIds){


        if(walletIds == null || walletIds.size() < 1 )
            throw new AcctPlanOtherRevenueExpenditureSelectorException('Set of walletIds  Cannot be null');
        string sql = sqlSelectAcctPlanOtherRevenueExpenditureInBusinessOppByWalletIds();
        //system.debug('::: sql' + sql);
        return (List<AcctPlanOtherRevenueExpenditure__c>) Database.query(sql);
    }
    
    
     
    // Exception
    public class AcctPlanOtherRevenueExpenditureSelectorException extends Exception{   
    }
    
}