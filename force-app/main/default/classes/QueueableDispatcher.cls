public without sharing class QueueableDispatcher Implements Queueable, Database.AllowsCallouts {
	/**
	* @author Keattisak Chinburarat
	* @date 2/21/2016
	* @description Defines the interface for Queueable Apex
	*/
	public Interface IQueueableDispatched 
	{ 
	    void execute(QueueableContext sc); 
	}   
	public void execute(QueueableContext sc) 
	{
		Type targettype = Type.forName('QueueableHandler');   
		if(targettype!=null) {
			IQueueableDispatched obj = (IQueueableDispatched)targettype.NewInstance();
			obj.execute(sc);   
		}  
	} 	  
}