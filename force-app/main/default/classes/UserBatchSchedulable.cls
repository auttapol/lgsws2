global class UserBatchSchedulable implements Schedulable  {
	/**
	* @author Keattisak Chinburarat
	* @date 2/21/2016
	* @description Used to schedule user batch
	*/
	global void execute(SchedulableContext sc) {
        system.debug('=>1: Invoked UserBatchSchedulable ');
		//DiagnosticsInstrumentation.Push('Execute UserBatchSchedulable ');
		try{
			UserBatchDispatcher.execute();			
		}catch(Exception ex){
			//DiagnosticsInstrumentation.DebugException(ex);
		}	
		//DiagnosticsInstrumentation.Pop();
	}
}