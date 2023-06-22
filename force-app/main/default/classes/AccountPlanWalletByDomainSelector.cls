public  without sharing class AccountPlanWalletByDomainSelector {
    //DA:
    private static string  selectWalletByDomainByWallets(){
        return   'SELECT  Id, OwnerId, Name, Domain__c, SubDomain__c, TypeOfNI__c, Opportunity__c, WalletFromCRMDB__c, '
                +'      AdjWalletUnit__c, Priority__c, Reason__c, AcctPlanWallet__c, Seq__c, WalletFieldName__c,'
                +'      Row__c '
                +'FROM AcctPlanWalletByDomain__c '
                +'WHERE AcctPlanWallet__c IN : walletIds '
                +'ORDER BY Id, Seq__c';
    }
    
    //DA
    public static List<AcctPlanWalletByDomain__c> getWalletByDomainByWallets(Set<Id> walletIds){
        
        if(walletIds == null || walletIds.size() < 1 )
            throw new AccountPlanWalletByDomainSelectorException('Set of walletIds Cannot be null');
        string sql = selectWalletByDomainByWallets();
        system.debug('::: sql' + sql);
        return (List<AcctPlanWalletByDomain__c>) Database.query(sql);        
    } 
    
    // Exception
    public class AccountPlanWalletByDomainSelectorException extends Exception{   
    }
}