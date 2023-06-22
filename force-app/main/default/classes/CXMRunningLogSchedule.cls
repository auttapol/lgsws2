global without sharing class CXMRunningLogSchedule implements Schedulable {
    
    global void scheduleRun() {
        Integer days = Integer.valueOf( CXM_Config__c.getValues('DELETE_LOG_DAYS').Value__c );
        String TimeSchedule = '	0 0 1 1/'+days+' * ? *';
        System.schedule('CXM Running Logs '+TimeSchedule, TimeSchedule, new CXMClearLogSchedule() );
    }

    global void execute (SchedulableContext sc) {
       
        CXMHandler obj = new CXMHandler();
        
        try {
            obj.deleteLogAsyncRequest();
            obj.deleteLogCalloutRequest();
            obj.CXMSendEmailLog(null);
        }catch(exception ex){
            system.debug(ex.getMessage());
        }
        
    }
}