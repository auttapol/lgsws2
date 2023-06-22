public without sharing class AccountPlanCompanyProfileSelector {

   private static string selectAll(){
        return  'SELECT Wallet__c,                                '+
                '   FinancialHighlight__c,                        '+
                '   UltimateCompany__c,                           '+
                '   AcctPlanGroup__c,                             '+
                '   Portfolio__c,                                 '+
                '   Status__c,                                    '+
                '   SumOfBuyerPercent__c,                         '+
                '   SumOfBuyerEstimateNo__c,                      '+
                '   SumOfSupplierEstimateNo__c,                   '+
                '   SumOfSupplierPercent__c,                      '+
                '   Top5Buyer1Name__c,                            '+
                '   Top5Buyer2Name__c,                            '+
                '   Top5Buyer3Name__c,                            '+
                '   Top5Buyer4Name__c,                            '+
                '   Top5Buyer5Name__c,                            '+
                '   Top5Buyer1Percent__c,                         '+
                '   Top5Buyer2Percent__c,                         '+
                '   Top5Buyer3Percent__c,                         '+
                '   Top5Buyer4Percent__c,                         '+
                '   Top5Buyer5Percent__c,                         '+
                '   Top5Buyer1TermDays__c,                        '+
                '   Top5Buyer2TermDays__c,                        '+
                '   Top5Buyer3TermDays__c,                        '+
                '   Top5Buyer4TermDays__c,                        '+
                '   Top5Buyer5TermDays__c,                        '+
                '   Top5Supplier1Name__c,                         '+
                '   Top5Supplier1Percent__c,                      '+
                '   Top5Supplier1TermDays__c,                     '+
                '   Top5Supplier2Name__c,                         '+
                '   Top5Supplier2Percent__c,                      '+
                '   Top5Supplier2TermDays__c,                     '+
                '   Top5Supplier3Name__c,                         '+
                '   Top5Supplier3Percent__c,                      '+
                '   Top5Supplier3TermDays__c,                     '+
                '   Top5Supplier4Name__c,                         '+
                '   Top5Supplier4Percent__c,                      '+
                '   Top5Supplier4TermDays__c,                     '+
                '   Top5Supplier5Name__c,                         '+
                '   Top5Supplier5Percent__c,                      '+
                '   Top5Supplier5TermDays__c,                     '+
                '   Top5BuyerNote__c,                             '+
                '   Top5SupplierNote__c,                          '+
                '   CompanyStrategy__c,                           '+
                '   BargainingPowerOfBuyerDescription__c,         '+
                '   BargainingPowerOfBuyer__c,                    '+
                '   BargainingPowerOfSupplierDescription__c,      '+
                '   BargainingPowerOfSupplier__c,                 '+
                '   BarrierOfNewEntrantDescription__c,            '+
                '   BarrierOfNewEntrant__c,                       '+
                '   IndustryCompetitionDescription__c,            '+
                '   IndustryCompetition__c,                       '+
                '   ThreatOfSubstituteProductDescription__c,      '+
                '   ThreatOfSubstituteProduct__c,                 '+
                '   FactorType1Description__c,                    '+
                '   FactorType1__c,                               '+
                '   FactorType2Description__c,                    '+
                '   FactorType2__c,                               '+
                '   FactorType3Description__c,                    '+
                '   FactorType3__c,                               '+
                '   FactorType4Description__c,                    '+
                '   FactorType4__c,                               '+
                '   FactorType5Description__c,                    '+
                '   FactorType5__c,                               '+
                '   SubIndustry__c,                               '+
                '   EstablishedSince__c,                          '+
                '   CustomerSince__c,                             '+
                '   NoOfEmployee__c,                              '+
                '   ShareholdingStructure__c,                     '+
                '   BusinessFlow__c,                              '+
//                '   Company_Industry__c,                          '+
                '   Business_Code__c,                             '+
                '   Year__c,                                      '+
                '   TargetNIByRM__c,                              '+
                '   Performance__c,                               '+
                '   ExpectedNIByAcctPlan__c,                      '+
                '   AccountName__c,                               '+
                '   Account__c,                                   '+
                '   Name,   Id , isMiniMode__c                    '+
             // '   Id,                                           '+
             // '   LastViewedDate,                               '+
             // '   LastReferencedDate                            '+
                'FROM                                             '+
                '   AcctPlanCompanyProfile__c                     ';
   
   }
    
    private static string  selectTargetNIByRMById(){
        return  ' Select Id, TargetNIByRM__c  From AcctPlanCompanyProfile__c Where Id IN :  companyProfileIds ';
    }    
    private static string  selectTargetNIByGroupProfile(){
        return  ' Select SUM(TargetNIByRM__c) Total  From AcctPlanCompanyProfile__c Where Id   IN : groupProfileIds ';
    }      
    
    private static string  selectCompanyProfileByPortfolioId(){
        return  ' Select Id, Name, Account__c, AcctPlanGroup__c, Portfolio__c From AcctPlanCompanyProfile__c Where Portfolio__c IN : portfolioIds ';
    }
    private static string  selectCompanyProfileByGroupProfileId(){
        return  ' Select Id,isMiniMode__c, Name, Account__c, AcctPlanGroup__c From AcctPlanCompanyProfile__c Where AcctPlanGroup__c IN : groupProfileIds ';
    }
    
     private static string  selectCompanyProfileByAccountIdsAndYear(){
        return  ' SELECT Name, AccountName__c, Account__c, Year__c, Wallet__c FROM AcctPlanCompanyProfile__c where Account__c IN : accountIds and Year__c = : year ';
    }
    
    public static List<AcctPlanCompanyProfile__c> getCompanyProfileByAccountIdsAndYear(Set<Id> accountIds ,string year){
         system.debug('::: accountIds >> ' + accountIds);
        if(accountIds == null || accountIds.size() < 1 )
            throw new AccountPlanCompanyProfileSelectorException('Set of accountIds Cannot be null');

        string sql = selectCompanyProfileByAccountIdsAndYear();
        system.debug('::: sql' + sql);
        return (List<AcctPlanCompanyProfile__c>) Database.query(sql);        
    }
    
    
    
    
    
    public static  List<AcctPlanCompanyProfile__c> getTargetNIByRMById(Set<Id> companyProfileIds){
        
        if(companyProfileIds == null || companyProfileIds.size() < 1 )
            throw new AccountPlanCompanyProfileSelectorException('Set of companyProfileIds  Cannot be null');
        string sql = selectTargetNIByRMById();
        system.debug('::: sql' + sql);
        return (List<AcctPlanCompanyProfile__c>) Database.query(sql);
        
    } 
   
    public static List<Decimal> getTargetNIByGroupId(Set<Id> groupProfileIds){
        List<Decimal> Totals = new  List<Decimal>();
        if(groupProfileIds == null || groupProfileIds.size() < 1 ){
            throw new AccountPlanCompanyProfileSelectorException('Set of groupProfileIds  Cannot be null');
        }
        string sql = selectTargetNIByGroupProfile();
        system.debug('::: sql' + sql);
        AggregateResult[] groupedResults = Database.query(sql);
        
        if(groupedResults.size() >0){
            for(AggregateResult ag : groupedResults){
                
                Decimal total = ag.get('Total') == null ? 0 : (Decimal)ag.get('Total');
                Totals.add(total);
            } 
        }        
        return Totals;        
    } 
    
    public static  List<AcctPlanCompanyProfile__c> getCompanyProfileIdByPortfolioIds(Set<Id> portfolioIds){
        system.debug('::: portfolioIds >> ' + portfolioIds);
        if(portfolioIds == null || portfolioIds.size() < 1 )
            throw new AccountPlanCompanyProfileSelectorException('Set of portIds Cannot be null');

        string sql = selectCompanyProfileByPortfolioId();
        system.debug('::: sql' + sql);
        return (List<AcctPlanCompanyProfile__c>) Database.query(sql);        
    }     
   
    public static  List<AcctPlanCompanyProfile__c> getCompanyProfileByGroupProfileIds(Set<Id> groupProfileIds){
        system.debug('::: groupProfileIds >> ' + groupProfileIds);
        if(groupProfileIds == null || groupProfileIds.size() < 1 )
            throw new AccountPlanCompanyProfileSelectorException('Set of groupProfileIds Cannot be null');

        string sql = selectCompanyProfileByGroupProfileId();
        system.debug('::: sql' + sql);
        return (List<AcctPlanCompanyProfile__c>) Database.query(sql);        
    }
    
    
    public static  List<AcctPlanCompanyProfile__c> getCompanyProfileIds(Set<Id> companyProfileIds){
        system.debug('::: companyProfileIds >> ' + companyProfileIds);
        if(companyProfileIds== null || companyProfileIds.size() < 1 )
            throw new AccountPlanCompanyProfileSelectorException('Set of companyProfileIds Cannot be null');
        string sql = selectAll()+ ' WHERE Id IN : companyProfileIds ';
        system.debug('::: sql' + sql);
        return (List<AcctPlanCompanyProfile__c>) Database.query(sql);
        
    } 
    
    
    //Support Group Wallet
     private static string selectAllCompanyProfileUnderGroupByGroupId(){
    	//groupProfileId    
    	return   'SELECT Account__c, AccountName__c,TargetNIByRM__c, AcctPlanGroup__c , AcctPlanGroup__r.Name ,AcctPlanGroup__r.Group__c,AcctPlanGroup__r.Year__c  '
				+'FROM AcctPlanCompanyProfile__c                                                      '
				+'WHERE AcctPlanGroup__r.Group__c  IN : groupId   and  AcctPlanGroup__r.Year__c =:year         ';
   
    }
      public static  List<AcctPlanCompanyProfile__c> getAllCompanyProfileUnderGroupByGroupProfolioId(Set<Id> groupId,String year){
        
        if(groupId == null || groupId.size() < 1 )
            throw new AccountPlanCompanyProfileSelectorException('Set of groupProfileId  Cannot be null');
        string sql = selectAllCompanyProfileUnderGroupByGroupId();
        system.debug('::: sql' + sql);
        return (List<AcctPlanCompanyProfile__c>) Database.query(sql);         
    } 
    
    
    
    
    
    
    // Exception
    public class AccountPlanCompanyProfileSelectorException extends Exception{   
    }
}