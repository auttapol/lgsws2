public  without sharing class AccountPlanProductStrategySelector {  

    // SOQL Statement
    public static string sqlProductStrategyByIds(){
        return   'SELECT  '
        +'      Id,SEQ__c,Name,AccountPlanYear__c,AcctPlanCompanyProfileID__c,AcctPlanGroupProfileID__c,  '
        +'      AcctPlanWallet__c,AnnualizedPerformance__c,AspirationSOW__c,CompareSOW__c,  '
        +'      CreatedById,CreatedDate,ExistingSOW__c,ExpectedIncrementalNI__c,ExpectedSOWPercent__c,  '
        +'      IsDeleted,LastModifiedById,LastModifiedDate, '
        +'      ParentRecord__c,SystemModstamp,WalletSizing__c,TotalCompanyNI__c, '
        +'      AcctPlanCompanyProfileID__r.Name, AcctPlanGroupProfileID__r.Name,AsOfDate__c,RefreshAsOf__c, '
        +'      AcctPlanCompanyProfileID__r.Account__c,WalletFieldName__c,Adjust_NI__c,ExpectedIncrementalNIFreeText__c ,  '
        +'      ExpectedIncrementalNIFromStep5__c,AcctPlanCompanyProfileID__r.isMiniMode__c,AccountId__c  '    
        +' FROM  '
        +'       AcctPlanProdStrategy__c  '
        +' Where  '
        +'       AcctPlanCompanyProfileID__c IN : acctPlanCompanyIds Order by  SEQ__c  ';
    }
    
    public static string sqlProductStrategyByGroupIds(){
        return   'SELECT  '
        +'      Id,SEQ__c,Name,AccountPlanYear__c,AcctPlanCompanyProfileID__c,AcctPlanGroupProfileID__c,  '
        +'      AcctPlanWallet__c,AnnualizedPerformance__c,AspirationSOW__c,CompareSOW__c,  '
        +'      CreatedById,CreatedDate,ExistingSOW__c,ExpectedIncrementalNI__c,ExpectedSOWPercent__c,  '
        +'      IsDeleted,LastModifiedById,LastModifiedDate, WalletFieldName__c ,Adjust_NI__c,AsOfDate__c,RefreshAsOf__c,  '
        +'      ParentRecord__c,SystemModstamp,WalletSizing__c,TotalCompanyNI__c ,ExpectedIncrementalNIFreeText__c , '
        +'      AcctPlanCompanyProfileID__r.Name,AcctPlanGroupProfileID__r.Name,AcctPlanCompanyProfileID__r.Account__c, '
        +'      ExpectedIncrementalNIFromStep5__c,AcctPlanCompanyProfileID__r.isMiniMode__c,AccountId__c  '    
        +' FROM  '
        +'       AcctPlanProdStrategy__c  '
        +' Where  '
        +'       AcctPlanGroupProfileID__c IN : groupProfileIds  Order By AcctPlanCompanyProfileID__r.Name ,SEQ__c ';
    }
    
     public static string sqlProductStrategyByAccountIds(){
        return   'SELECT  '
        +'      Id,SEQ__c,Name,AccountPlanYear__c,AcctPlanCompanyProfileID__c,AcctPlanGroupProfileID__c,AccountId__c,  '
        +'      AcctPlanWallet__c,AnnualizedPerformance__c,AspirationSOW__c,CompareSOW__c,  '
        +'      CreatedById,CreatedDate,ExistingSOW__c,ExpectedIncrementalNI__c,ExpectedSOWPercent__c,  '
        +'      IsDeleted,LastModifiedById,LastModifiedDate, WalletFieldName__c ,Adjust_NI__c,AsOfDate__c,RefreshAsOf__c,  '
        +'      ParentRecord__c,SystemModstamp,WalletSizing__c,TotalCompanyNI__c ,ExpectedIncrementalNIFreeText__c , '
        +'      AcctPlanCompanyProfileID__r.Name,AcctPlanGroupProfileID__r.Name,AcctPlanCompanyProfileID__r.Account__c, '
        +'      ExpectedIncrementalNIFromStep5__c,AcctPlanCompanyProfileID__r.isMiniMode__c  '    
        +' FROM  '
        +'       AcctPlanProdStrategy__c  '
        +' Where  '
        +'       AccountId__c IN : accountIds and AcctPlanCompanyProfileID__r.Year__c = :year   Order By AcctPlanCompanyProfileID__r.Name ,SEQ__c ';
    }
    
    
    
    
    public static string sqlProductStrategyPortfolioPerformanceByCompanyIds(){
        return   'SELECT Name, AcctPlanGroupProfileID__c, '
        +'      SUM(WalletSizing__c)WalletSizing, SUM(TotalCompanyNI__c)TotalCompanyNI '
        +' FROM  '
        +'       AcctPlanProdStrategy__c '
        +' Where  '
        +'       AcctPlanCompanyProfileID__c IN : acctPlanCompanyIds '
        +' GROUP BY AcctPlanGroupProfileID__c, Name '
        +' Order by AcctPlanGroupProfileID__c, Name ';
    }
    
    public static List<AcctPlanProdStrategy__c> selectProductStrategyByAccountIds(Set<ID> accountIds,string year){


        if(accountIds == null || accountIds.size() < 1 )
            throw new AccountPlanProductStrategySelectorException('Set of acctPlanCompanyIds Cannot be null');
       
        string sql = sqlProductStrategyByAccountIds();   
        return (List<AcctPlanProdStrategy__c>) Database.query(sql);
    }

    //Selectors
    public static List<AcctPlanProdStrategy__c> selectProductStrategyByIds(Set<ID> acctPlanCompanyIds){


        if(acctPlanCompanyIds == null || acctPlanCompanyIds.size() < 1 )
            throw new AccountPlanProductStrategySelectorException('Set of acctPlanCompanyIds Cannot be null');
        string sql = sqlProductStrategyByIds();
        system.debug('::: sql' + sql);
        return (List<AcctPlanProdStrategy__c>) Database.query(sql);
    }

    public static List<AcctPlanProdStrategy__c> selectProductStrategyByGroupIds(Set<ID> groupProfileIds){
      if(groupProfileIds == null || groupProfileIds.size() < 1 )
            throw new AccountPlanProductStrategySelectorException('Set of groupProfileIds Cannot be null');
        string sql = sqlProductStrategyByGroupIds();
        system.debug('::: sql' + sql);
        return (List<AcctPlanProdStrategy__c>) Database.query(sql);
    }
    
    public static AggregateResult[] selectProductStrategyPortfolioPerformanceByCompanyIds(Set<ID> acctPlanCompanyIds){
      if(acctPlanCompanyIds == null || acctPlanCompanyIds.size() < 1 )
            throw new AccountPlanProductStrategySelectorException('Set of acctPlanCompanyIds Cannot be null');
        string sql = sqlProductStrategyPortfolioPerformanceByCompanyIds();
        system.debug('::: sql' + sql);
        return (AggregateResult[]) Database.query(sql);
    }
    
    
     
    
    
    
    
    
    
    // Exception
    public class AccountPlanProductStrategySelectorException extends Exception{   
    }
}