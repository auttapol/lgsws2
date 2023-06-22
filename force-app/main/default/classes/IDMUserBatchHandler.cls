public class IDMUserBatchHandler implements UserBatchDispatcher.IUserBatchDispatched{
	public IDMUserBatchHandler() {}
	/******************************************************************
    //Implement Interface for dispatcher
    ******************************************************************/
    public Id executeBatch() { 
        ID batchprocessid;
        system.debug('=>3: Invoked IDMUserBatchHandler ');
        try { 
            IDMUserBatch batch = new IDMUserBatch();
            batchprocessid  = Database.executeBatch(batch);
        } catch (Exception ex) {
            throw new IDMUserBatch.IDMUserBatchException('IDMUserBatch Error'+ex.getMessage());
        }/* catch (UnexpectedException uex){
            throw new IDMUserBatch.IDMUserBatchException('IDMUserBatch Error UnexpectedException'+ uex.getMessage());
        }
        */
        return batchprocessid;
    }
}