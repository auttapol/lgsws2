global class PurgePDPAActivityLogBatchScheduler implements Schedulable {

    private static Integer purge_backDate {
        get { 
            if( purge_backDate == null) {   
                AppConfig__c appConfig = AppConfig__c.getValues('PDPA_Activity_Log_Purge_Days');
                if(appConfig == null) {
                    purge_backDate = 365;
                } else {
                    purge_backDate = Integer.valueOf(appConfig.Value__c);
                }
            }
            return purge_backDate;
        } 
        set; 
    } 
    
    global void execute(SchedulableContext sc) {
        Date backDate = System.Today().addDays(-purge_backDate);
        String q = 'SELECT Id FROM PDPA_Activity_Log__c WHERE CreatedDate <=: BACKDATE';

		database.executebatch(new PurgePDPAActivityLogBatch(q, backDate), 2000);
    }
}