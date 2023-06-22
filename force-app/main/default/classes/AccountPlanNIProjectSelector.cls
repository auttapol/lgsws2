public  without sharing  class AccountPlanNIProjectSelector {
    //DA:
    private static string  selectNIProjectByActionPlans(){
        return  ' Select Id, Name, TypeOfNI__c, ExpectedIncrementalNIPerYear1Year__c, TypeOfFee__c, ExpectedIncrementalFeePerYear1Year__c, AcctPlanActionPlanID__c From AcctPlanNIProject__c Where AcctPlanActionPlanID__c IN : actionplanIds ';
    }
    
    //DA
    public static List<AcctPlanNIProject__c> getNIProjectByActionPlans(Set<Id> actionplanIds){
        
        if(actionplanIds== null || actionplanIds.size() < 1 )
            throw new AccountPlanNIProjectSelectorException('Set of actionplanIds Cannot be null');
        string sql = selectNIProjectByActionPlans();
        system.debug('::: sql' + sql);
        return (List<AcctPlanNIProject__c>) Database.query(sql);        
    } 
    
    private static string selectNIProjectByActionPlansByYearAndAccountIds(){
        return 
                 '   SELECT    '
                 +'   		Id, TypeOfNI__c,TypeOfFee__c,ExpectedIncrementalFeePerYear1Year__c, ExpectedIncrementalNIPerYear1Year__c, '
                 +'   		AcctPlanActionPlanId__r.AcctPlanWalletByDomain__r.AcctPlanWallet__r.AcctPlanCompanyProfile__r.Account__c , '
                 +'         AcctPlanActionPlanId__r.AcctPlanWalletByDomain__r.AcctPlanWallet__c ,'
                 +'   		AcctPlanActionPlanId__r.AcctPlanWalletByDomain__r.AcctPlanWallet__r.AcctPlanCompanyProfile__r.Year__c '
                 +'   FROM 	'
                 +'   		AcctPlanNIProject__c '
                 +'   WHERE '
                 +'   		AcctPlanActionPlanId__r.AcctPlanWalletByDomain__r.AcctPlanWallet__r.AcctPlanCompanyProfile__r.Year__c =: year AND '
                 +'      	AcctPlanActionPlanId__r.AcctPlanWalletByDomain__r.AcctPlanWallet__r.AcctPlanCompanyProfile__r.Account__c IN: accountIds ';
        
         
        
        
    }
    public static List<AcctPlanNIProject__c> getNIProjectByActionPlansByYearAndAccountIds(string year , Set<Id> accountIds){
        
        if(accountIds== null || accountIds.size() < 1 )
            throw new AccountPlanNIProjectSelectorException('Set of accountIds Cannot be null');
        string sql = selectNIProjectByActionPlansByYearAndAccountIds();
        system.debug('::: sql' + sql);
        return (List<AcctPlanNIProject__c>) Database.query(sql);        
    } 
    
    
    
    
    // Exception
    public class AccountPlanNIProjectSelectorException extends Exception{   
    }
}