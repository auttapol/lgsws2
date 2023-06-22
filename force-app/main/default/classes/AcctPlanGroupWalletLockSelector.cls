public  without sharing class  AcctPlanGroupWalletLockSelector {
	//SQL
	public static string sqlAllField(){
		return 'SELECT Id,Group__c,IsLock__c   FROM AcctPlanGroupWalletLock__c Where Group__c IN : groupIds';
	}
	
	
	
	
	 //Selectors
    public static List<AcctPlanGroupWalletLock__c> getGroupwalletLockByGroupIds(Set<ID> groupIds){
        if(groupIds == null || groupIds.size() < 1 )
            throw new AcctPlanGroupWalletLockSelectorException('Set of walletIds  Cannot be null');
        string sql = sqlAllField();
        //system.debug('::: sql' + sql);
        return (List<AcctPlanGroupWalletLock__c>) Database.query(sql);
    }
    
    
     
    // Exception
    public class AcctPlanGroupWalletLockSelectorException extends Exception{   
    }
	
}