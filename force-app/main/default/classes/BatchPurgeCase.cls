global without sharing class BatchPurgeCase implements Schedulable
                                            , Database.Batchable<SObject>
                                            , Database.Stateful
                                            , Database.AllowsCallouts {

    private Integer BATCHSIZE = 1000;
    private String query; 

    private TimeZone tz = UserInfo.getTimeZone();	
	private Integer caseRecordsProcessed = 0;
	private Integer caseRecordsSuccessful = 0;	
	private Integer caseRecordsFailed = 0;

    private Integer attRecordsProcessed = 0;
	private Integer attRecordsSuccessful = 0;	
	private Integer attRecordsFailed = 0;

    private Integer ecmRepoRecordsProcessed = 0;
	private Integer ecmRepoRecordsSuccessful = 0;	
	private Integer ecmRepoRecordsFailed = 0;

	private Datetime batchDate = datetime.now();
	private Datetime batchStartTime = datetime.now();
	private Datetime batchEndTime = null;


    public static String purge_backDate {
        get
        { 
            if( purge_backDate == null)
            {   
                try{
                     purge_backDate = AppConfig__c.getValues('Purge_Case_Back_Date').Value__c;
                }catch(Exception e){
                    purge_backDate = '25';
                }
               
            }
            return purge_backDate;
        } 
        set; 
    }                                           
    public BatchPurgeCase() {

    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(this.query);
    }

    global void execute(Database.BatchableContext bc, List<Case> scope){
        Set<ID> caseID = New Set<ID>();
        Set<ID> contentID = New Set<ID>();
        if(scope.size() > 0){
            caseID = (new Map<Id,Case>(scope)).keySet();
            List<ECM_Repository__c> ecmRepoList = [SELECT ID FROM ECM_Repository__c WHERE Case__c in: caseID];
            List<ContentDocumentLink> attachedFileList = [SELECT ID,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in: caseID AND LinkedEntity.Type='Case'];
            if(attachedFileList.size() > 0){
                for(ContentDocumentLink contLink : attachedFileList){
                    contentID.add(contLink.ContentDocumentId);
                }
            }
            
            List<ContentDocument> contentList = [SELECT ID,FileType FROM ContentDocument WHERE id in: contentID];

            if(ecmRepoList.size() > 0){
                Database.DeleteResult[] ecmRepoDeleteResult = Database.delete(ecmRepoList, false);
                for (Database.DeleteResult ecmRepoDelete : ecmRepoDeleteResult) {
                    if (ecmRepoDelete.isSuccess()) {
                        ecmRepoRecordsSuccessful++;
                    }else{
                        ecmRepoRecordsFailed++;
                    }        
                } 
            }
            if(contentList.size() > 0){
                Database.DeleteResult[] attDeleteResult = Database.delete(contentList, false);
                for (Database.DeleteResult attDelete : attDeleteResult) {
                    if (attDelete.isSuccess()) {
                        attRecordsSuccessful++;
                    }else{
                        attRecordsFailed++;
                    }        
                } 
            } 

            Database.DeleteResult[] caseDeleteResult = Database.delete(scope, false);  
            for (Database.DeleteResult caseDelete : caseDeleteResult) {
                if (caseDelete.isSuccess()) {
                    caseRecordsSuccessful++;
                }else{
                    caseRecordsFailed++;
                }        
            }
        }       
       
    }

    global void execute(SchedulableContext sc){
        
        Integer backdate = Integer.valueof(purge_backDate);
        this.query = 'SELECT ID, Casenumber, ClosedDate FROM Case WHERE IsClosed = true AND ClosedDate < LAST_N_MONTHS:'+backdate;   
        Id BatchProcessIdForInt = Database.ExecuteBatch(this,this.BATCHSIZE); 
    
    }

    global void finish(Database.BatchableContext bc){

        batchEndTime = datetime.now();
    	caseRecordsProcessed = caseRecordsSuccessful + caseRecordsFailed;
    	attRecordsProcessed = attRecordsSuccessful + attRecordsFailed;
        ecmRepoRecordsProcessed = ecmRepoRecordsSuccessful + ecmRepoRecordsFailed;

    	String subject = null;
    	String description = null;
    	String status = null;
    	if (caseRecordsFailed > 0 || attRecordsFailed > 0 || ecmRepoRecordsFailed > 0) {//there are failed records
    		subject = 'Batch : Purge Case run' + ' completely';
    		description = 'Batch : Purge Case run' + ' completely';
    		status = 'Failed';
    	} else {//there are no failed records
    		subject = 'Batch : Purge Case run' + ' successfully';
    		description = 'Batch : Purge Case run' + ' successfully';
    		status = 'Success';
    	}    	
    	
		AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()];
			
    	string htmlMsg = description + ' <br/><br/>'
    				+ 'Batch as of : ' + batchDate.format('dd/MM/yyyy', tz.toString()) + '<br/><br/>'
    				+ 'Batch : Purge Case run' + ' : ' + status + '<br/><br/>'
					+ '<table style="width:100%" border=1>'
					+ '<tr>'
					+ '	<th>No.</th>'
					+ '	<th>' + System.Label.RTL_Purge_Email_006 + '</th>'					
					+ '	<th>' + System.Label.RTL_Purge_Email_003 + '</th>'
					+ '	<th>' + System.Label.RTL_Purge_Email_004 + '</th>'
					+ '	<th>' + System.Label.RTL_Purge_Email_005 + '</th>'
					+ '	<th>' + System.Label.RTL_Purge_Email_007 + '</th>'
					+ '	<th>' + System.Label.RTL_Purge_Email_008 + '</th>'
					+ '	<th>' + System.Label.RTL_Purge_Email_009 + '</th>'
					+ '</tr>'
					+ '<tr>'
					+ '	<td>1</td>'	
					+ '	<td>' + 'Case' + '</td>'					
					+ '	<td>' + batchDate.format('dd/MM/yyyy', tz.toString()) + '</td>'
					+ '	<td>' + batchStartTime.format('dd/MM/yyyy HH:mm:ss', tz.toString()) + '</td>'
					+ '	<td>' + batchEndTime.format('dd/MM/yyyy HH:mm:ss', tz.toString()) + '</td>'
					+ '	<td>' + caseRecordsProcessed + '</td>'
					+ '	<td>' + caseRecordsSuccessful + '</td>'
					+ '	<td>' + caseRecordsFailed + '</td>'
					+ '</tr>'
					+ '<tr>'
					+ '	<td>2</td>'	
					+ '	<td>' + 'Attachments' + '</td>'					
					+ '	<td>' + batchDate.format('dd/MM/yyyy', tz.toString()) + '</td>'
					+ '	<td>' + batchStartTime.format('dd/MM/yyyy HH:mm:ss', tz.toString()) + '</td>'
					+ '	<td>' + batchEndTime.format('dd/MM/yyyy HH:mm:ss', tz.toString()) + '</td>'
					+ '	<td>' + attRecordsProcessed + '</td>'
					+ '	<td>' + attRecordsSuccessful + '</td>'
					+ '	<td>' + attRecordsFailed + '</td>'
					+ '</tr>'
                    + '<tr>' 
                    + '	<td>3</td>'	
					+ '	<td>' + 'ECM_Repository__c' + '</td>'					
					+ '	<td>' + batchDate.format('dd/MM/yyyy', tz.toString()) + '</td>'
					+ '	<td>' + batchStartTime.format('dd/MM/yyyy HH:mm:ss', tz.toString()) + '</td>'
					+ '	<td>' + batchEndTime.format('dd/MM/yyyy HH:mm:ss', tz.toString()) + '</td>'
					+ '	<td>' + ecmRepoRecordsProcessed + '</td>'
					+ '	<td>' + ecmRepoRecordsSuccessful + '</td>'
					+ '	<td>' + ecmRepoRecordsFailed + '</td>'	
                    + '</tr>'				
					+ '</table>'
					+ '<br/><font color="red">' + System.Label.RTL_Purge_Email_011 + '</font><br/>'
					+ '<br/>' + System.Label.RTL_Purge_Email_footer + '</font>';

		RTL_BatchEmailService.SendEmail(bc.getJobId(), subject, htmlMsg);

        
    }
    
}