global class PurgePDPAActivityLogBatch implements Database.Batchable<sObject>, Database.stateful {
    private String query; 
    private Date BACKDATE;

    private Integer activityLogDeleteProcessed = 0;
    private Integer activityLogDeleteSuccessful = 0;
    private Integer activityLogDeleteFailed = 0;

	private Datetime batchDate = datetime.now(); 
	private Datetime batchStartTime = datetime.now();
	private Datetime batchEndTime = null;

    public PurgePDPAActivityLogBatch(String q, Date backDate) {
        this.query = q;
        this.BACKDATE = backDate;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('::::::::: Start PurgePDPAActivityLogBatch ::::::::::::::::');
        return Database.getQueryLocator(this.query);
    }

    global void execute(Database.BatchableContext bc, List<PDPA_Activity_Log__c> scope){
        System.debug('::::::::: Execute PurgePDPAActivityLogBatch ::::::::::::::::');
        if(scope.size() > 0){
            Database.DeleteResult[] logDeleteResult = Database.delete(scope, false);
            for (Database.DeleteResult logDelete : logDeleteResult) {
                if (logDelete.isSuccess()) {
                    this.activityLogDeleteSuccessful++;
                }       
            } 
        }       
    }

    global void finish(Database.BatchableContext bc){
        System.debug('::::::::: Finish PurgePDPAActivityLogBatch ::::::::::::::::');
        batchEndTime = datetime.now();

        String filename = 'Purge PDPA Activity Log ' + String.Valueof(Datetime.now());
        String sObjectName = 'PDPA_Activity_Log__c';
        List<String> sendToEmail = new List<String>();
        sendToEmail.add('CRM Admin 2');
        // sendToEmail.add('n.nut.manat@gmail.com'); // **********************

        String csvHeaderStr = '';
        String CSV_BODY = '';

        if(activityLogDeleteFailed + activityLogDeleteSuccessful > 0){
            RTL_BatchEmailService.SendFinishBatchSummaryEmail(batchDate
                                                        , batchStartTime
                                                        , batchEndTime
                                                        , activityLogDeleteSuccessful
                                                        , activityLogDeleteFailed
                                                        , csvHeaderStr
                                                        , filename
                                                        , sObjectName
                                                        , sendToEmail
                                                        , CSV_BODY);
        }
    }
    
}