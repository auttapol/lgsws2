global without sharing class CXMClearLogSchedule implements Schedulable {

    global void scheduleRun() {
        String TimeSchedule = '0 0 1 * * ?';
        //String TimeSchedule = AppConfig__c.getValues('Schedule_Time_Article').Value__c;
        System.schedule('CXM Clear Logs '+TimeSchedule, TimeSchedule, new CXMClearLogSchedule() );
    }

    global void execute (SchedulableContext sc) {
       
        CXMHandler obj = new CXMHandler();
        
        try {
            obj.deleteLogAsyncRequest();
            obj.deleteLogCalloutRequest();
            // obj.CXMSendEmailLog(null);
            obj.deleteErrorLogAsyncRequest();
            obj.deleteErrorLogCalloutRequest();
        }catch(exception ex){
            system.debug(ex.getMessage());
        }
        
    }
}