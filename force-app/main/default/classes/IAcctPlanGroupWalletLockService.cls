global interface IAcctPlanGroupWalletLockService {	
	void Lock(Id groupId);
	void Unlock(Id groupId);
	boolean IsLock(id groupId);	
}