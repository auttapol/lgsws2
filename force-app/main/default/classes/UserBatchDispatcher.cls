public class UserBatchDispatcher {
    public Interface IUserBatchDispatched{
        Id executeBatch();
    }
    @TestVisible
    private static integer emode = 0;    
    public static void execute(){
        try{            
            system.debug('=>2: Invoked UserBatchDispatcher ');             
            if(emode == 1) {integer ret =  3/0;}
            Type targettype = Type.forName('IDMUserBatchHandler');
            if (targettype != null) {
                IUserBatchDispatched obj = (IUserBatchDispatched)targettype.NewInstance();
                Id batchId = obj.executeBatch();   
            }
        }
        catch(exception ex){
            throw new UserBatchDispatcherException('UserBatchDispatcher Error cause :'+ ex.getMessage() ,ex);
        }		
    }
    public class UserBatchDispatcherException extends Exception{
    }
}