public  without sharing  class AcctPlanCapitalExpenditurePlanSelector {
     // SOQL Statement
    public static string sqlSelectAcctPlanCapitalExpenditurePlanInBusinessOppByWalletIds(){
        return   
			 'SELECT 	  Id, FrontEndFee__c, FinancingRation__c, InvestmentLocation__c       '
			+'		, MisMatchCCY__c, Name, NeedToHedgeInterest__c, NimcPercent__c            '
			+'		, OppForForeignCCY__c, Opportunity__c, ProjectAmount__c, Purpose__c       '
			+'		, TenorYearly__c, WalletNiicYearly__c                                     '
			+'FROM                                                                            '
			+'	AcctPlanCapitalExpenditurePlan__c                                             '
			+'WHERE                                                                           '
			+'	   AcctPlanWallet__c IN : walletIds                                           '
			+'	   and                                                                        '
			+'     (OppForForeignCCY__c =\'Yes\' or OppForForeignCCY__c =\'No\')              '
			+'     and                                                                        '
			+'     (MisMatchCCY__c =\'Yes\' or MisMatchCCY__c =\'No\')                        '
			+'     and                                                                        '
			+'     (NeedToHedgeInterest__c =\'Yes\' or NeedToHedgeInterest__c =\'No\')        ';
      
		
    }
    //Selectors
    public static List<AcctPlanCapitalExpenditurePlan__c> SelectQuestionairByWalletIds(Set<ID> walletIds){


        if(walletIds == null || walletIds.size() < 1 )
            throw new AcctPlanCapitalExpenditurePlanSelectorException('Set of walletIds  Cannot be null');
        string sql = sqlSelectAcctPlanCapitalExpenditurePlanInBusinessOppByWalletIds();
        //system.debug('::: sql' + sql);
        return (List<AcctPlanCapitalExpenditurePlan__c>) Database.query(sql);
    }
    
    
     
    // Exception
    public class AcctPlanCapitalExpenditurePlanSelectorException extends Exception{   
    }
    
}