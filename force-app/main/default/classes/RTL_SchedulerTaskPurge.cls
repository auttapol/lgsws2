global class RTL_SchedulerTaskPurge implements Schedulable{
	global void execute(SchedulableContext sc){
		//query retail task older than 3 months
        //String query = 'select ID, RTL_NBO_History__c from Task where lastmodifieddate < LAST_N_MONTHS:3 and (recordtype.developername = \'RTL_Retail_Task\' or recordtype.developername = \'RTL_Retail_Outbound_Phone_Call\')';
        
        //Fix Indcident INC0039434 12-12-2017
        Integer PurgeTaskNDays = 90;
        try{
            List<App_Config__mdt> PurgeTaskNDaysMetaData 
            	= [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'PurgeTaskNDays'];

            if (PurgeTaskNDaysMetaData != null && PurgeTaskNDaysMetaData.size() > 0) {
            	PurgeTaskNDays = Integer.valueOf(PurgeTaskNDaysMetaData.get(0).Value__c);
            }      
        }catch( Exception e ){
        	System.debug(e);
        }


        String query = 'select ID, RTL_NBO_History__c from Task where lastmodifieddate < LAST_N_DAYS:'
                        +PurgeTaskNDays
        				+' and recordtype.developername = \'RTL_Retail_Outbound_Phone_Call\'';
        
        RTL_BatchTaskPurge taskPurge = new RTL_BatchTaskPurge(query);
        Id BatchProcessId = Database.ExecuteBatch(taskPurge);
    }   
}