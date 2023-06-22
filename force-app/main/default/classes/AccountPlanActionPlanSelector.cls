public without sharing class AccountPlanActionPlanSelector {
    //DA:
    private static string  selectActionPlanByWalletByDomains(){
        return  ' Select Id, Name, AcctPlanWalletByDomain__c From AcctPlanActionPlan__c Where AcctPlanWalletByDomain__c IN : walletbydomainIds ';
    }
    
    //DA
    public static List<AcctPlanActionPlan__c> getActionPlanByWalletByDomains(Set<Id> walletbydomainIds){
        
        if(walletbydomainIds == null || walletbydomainIds.size() < 1 )
            throw new AccountPlanActionPlanSelectorException('Set of walletbydomainIds Cannot be null');
        string sql = selectActionPlanByWalletByDomains();
        system.debug('::: sql' + sql);
        return (List<AcctPlanActionPlan__c>) Database.query(sql);        
    } 
    
    // Exception
    public class AccountPlanActionPlanSelectorException extends Exception{   
    }
}