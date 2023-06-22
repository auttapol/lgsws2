public  without sharing class AcctPlanGroupWalletLockServiceImpl implements IAcctPlanGroupWalletLockService {
	
	public void Lock(Id groupId){
		
		List<AcctPlanGroupWalletLock__c> lock  = 
		AcctPlanGroupWalletLockSelector.getGroupwalletLockByGroupIds(new set<id>{groupId});
		if(lock.size() > 0){
			for(AcctPlanGroupWalletLock__c item : lock){
			   item.IsLock__c = true;	
			}			
			update lock;
		}
		else{
			AcctPlanGroupWalletLock__c item = new AcctPlanGroupWalletLock__c(IsLock__c = true,Group__c = groupId);
			insert item;
		}
	}
	public void UnLock(Id groupId){		
		List<AcctPlanGroupWalletLock__c> lock  =
		AcctPlanGroupWalletLockSelector.getGroupwalletLockByGroupIds(new set<id>{groupId}); 
		
		if(lock.size() > 0){						
			delete lock;
		}		
	}
	public boolean IsLock(id groupId){
	   boolean ret =false;
	   List<AcctPlanGroupWalletLock__c> lock  = 
	   AcctPlanGroupWalletLockSelector.getGroupwalletLockByGroupIds(new set<id>{groupId});
	   if(lock.size() > 0){
	   	 for(AcctPlanGroupWalletLock__c item : lock){
			  ret |= item.IsLock__c;	
			}
	   }
	   return ret;
	}
}