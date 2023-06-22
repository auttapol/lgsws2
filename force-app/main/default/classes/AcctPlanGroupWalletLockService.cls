global class AcctPlanGroupWalletLockService {
	  


	  /**
	 * @description Support Mock Service
	 */
	@TestVisible
	private static IAcctPlanGroupWalletLockService mock;

	/**
	 * @description 
	 * @param mockService  Mock object to fake Implementation
	 */
	@TestVisible
	private static void setMockservice(IAcctPlanGroupWalletLockService mockService) {
		mock = mockService;
	}


	//Factory Medthod
	@TestVisible
	private static IAcctPlanGroupWalletLockService service() {

		if (Test.isRunningTest() && mock != null) return mock;
		return(IAcctPlanGroupWalletLockService) new AcctPlanGroupWalletLockServiceImpl();
	}

    
     // Services  Method
    global static void Lock(Id groupId){
        
        system.debug('Call Service createProductStrategyRecordToWallet');
        Savepoint sp = Database.setSavepoint();   
      
        try{
            service().Lock(groupId);
        }
        catch(Exception ex){
            Database.rollback(sp);
            system.debug(ex);             
            //throw new AcctPlanGroupWalletLockServiceException(ex);        
        }            
      
        
    }
    // Services  Method
    global  static void  Unlock(Id groupId){
        
        system.debug('Call Service createProductStrategyRecordToWallet');
        Savepoint sp = Database.setSavepoint();   
      
        try{
            service().Unlock(groupId);
        }
        catch(Exception ex){
            Database.rollback(sp);
            system.debug(ex);             
           // throw new AcctPlanGroupWalletLockServiceException(ex);        
        } 
    }
    
    // Services  Method
    global static boolean IsLock(Id groupId){
        boolean ret = false;
        system.debug('Call Service createProductStrategyRecordToWallet');
        try{
           ret = service().IsLock(groupId);
        }
        catch(Exception ex){          
            system.debug(ex);             
           throw new AcctPlanGroupWalletLockServiceException(ex);        
        }            
        return ret;
    }
    
    public class AcctPlanGroupWalletLockServiceException extends Exception{   
    }
}