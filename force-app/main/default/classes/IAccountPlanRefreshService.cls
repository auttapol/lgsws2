global interface IAccountPlanRefreshService {
   Boolean RefreshDepositInter(String acctPlanCompanyId,String acctPlanWallet,String acctPlanGruopId);
   Boolean RefreshDepositDomestic(String acctPlanCompanyId,String acctPlanWallet,String acctPlanGruopId);
   Boolean refreshWalletAndAnnualPerformanceRolling12Month(Set<ID> listPortfolioId);    
   //Boolean RefreshCompanyProfileProductStrategy(Id companyProfileIds,Id acctPlanWallet);
   Boolean RefreshCompanyPerformanceProductStrategyForStep6(String companyProfileId);
   Boolean RefreshGroupPerformanceProductStrategyForStep6(String groupProfileId);
   Boolean RefreshPortfolioPerformanceProductStrategyForStep0(String portfolioId);
   List<AcctPlanProdStrategy__c> RefreshProductStrategyAndWalletByDomain(String acctPlanCompanyId,String acctPlanWallet,String acctPlanGruopId);
   
   //R5.2  refresh product strategy when refresh Group Wallet & Group Performance
   void RefreshProductStrategyGroupWalletGroupPerformance(Set<Id> acctId,Set<Id> acctPlanCompanyId, Set<Id>  acctPlanWallet, String acctPlanGruopId);
   void RefreshProductStrategyPort(Set<Id> accountIds , string year,Id groupId);
   void RefreshProductStrategy2(Set<Id> accountIds, string year,Id groupId);
  //End R5.2

   void RefreshProductStrategyPort(Set<Id> accountIds , string year);
   void RefreshProductStrategy(Set<Id> accountIds , string year,Id groupProfilesId);
   void RefreshNameProductStrategyPort(Set<Id> accountIds , string year);
   void RefreshGroupPerformance(Set<Id> accountId,string year);

   List<AccountPlanRefreshService.CustomerWalletInfo> initialStep0(string accountIds); 



}