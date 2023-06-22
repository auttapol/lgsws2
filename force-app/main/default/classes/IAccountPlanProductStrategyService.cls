public interface IAccountPlanProductStrategyService {
    List<AcctPlanProdStrategy__c> createProductStrategyRecordToWallet(Id acctPlanCompanyId,Id acctPlanWallet);
    List<AcctPlanProdStrategy__c> createProductStrategyRecordToWallet(Id acctPlanCompanyId,Id acctPlanWallet,Id acctPlanGruopId);
    List<AcctPlanProdStrategy__c> getCompaniesProductStrategy(Set<ID> acctPlanCompanyIds);
    List<AccountPlanProductStrategyService.AcctPlanProdStrategyInfo> getCompaniesProductStrategyInfo(Set<ID> acctPlanCompanyIds);
    List<AccountPlanProductStrategyService.AcctPlanProdStrategyInfo> getGroupCompaniesProductStrategyInfo(Set<ID> acctPlanCompanyIds);
    
    AccountPlanProductStrategyService.AcctPlanProdStrategyCompanyInfo getGroupCompaniesProductStrategyInfoV2(Id groupProfileId);



}