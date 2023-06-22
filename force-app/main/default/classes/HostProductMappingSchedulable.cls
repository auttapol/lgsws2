global class HostProductMappingSchedulable implements Schedulable {
	/**
	* @author Keattisak Chinburarat
	* @date 2/21/2016
	* @description Used to schedule 
	*/
	global void execute(SchedulableContext sc) {
        system.debug('=> Invoked HostProductMappingSchedulable ');		
		try{
			HostProductMappingSchedulableDispatcher.execute();			
		}
		catch(Exception ex){
			throw  ex;		
		}	
		
	}



}