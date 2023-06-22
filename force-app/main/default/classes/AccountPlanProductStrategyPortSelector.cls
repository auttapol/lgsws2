public  without sharing  class AccountPlanProductStrategyPortSelector {  

    // SOQL Statement
    public static string sqlProductStrategyByAccountIdsAndYear(){
        return   'SELECT AccountId__c,AccountId_PE__c , AccountName__c ,AccountPlanYear__c, Adjust_NI__c,SEQ__c,  WalletSizing__c,ExpectedIncrementalNIFreeText__c,    '
                +'      AnnualizedPerformance__c, AsOfDate__c, AspirationSOW__c, '
                +'      CreatedById, CreatedDate, ExistingSOW__c, ExpectedIncrementalNI__c, '
                +'      GroupCompany__c, Id, IsDeleted, LastModifiedById, LastModifiedDate, '
                +'      Name, SystemModstamp, Year__c,ExpectedIncrementalNIFromStep5__c,TotalCompanyNI__c ,ExpectedSOWPercent__c  '
                +'FROM AcctPlanProdStrategyPort__c  WHERE AccountId__c IN : accountIds AND Year__c =: year ' ;
    }      
    
    //Selectors
    public static List<AcctPlanProdStrategyPort__c> selectProductStrategyPortByAccountIdsAndYear(Set<ID> accountIds , String year){

		system.debug('::: accountIds' + accountIds);
        if(accountIds == null || accountIds .size() < 1 )
            throw new AccountPlanProductStrategyPortSelectorException('Set of acctPlanCompanyIds Cannot be null');
            
        if(String.isBlank(year))
            throw new AccountPlanProductStrategyPortSelectorException('year Cannot be null');
         
            
            
        string sql = sqlProductStrategyByAccountIdsAndYear();
        system.debug('::: sql' + sql);
        return (List<AcctPlanProdStrategyPort__c>) Database.query(sql);
    }
    
    // Exception
    public class AccountPlanProductStrategyPortSelectorException extends Exception{   
    }
}