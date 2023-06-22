global without sharing class BatchPurgeCustomerComplaint implements Schedulable
                                            , Database.Batchable<SObject>
                                            , Database.Stateful
                                            , Database.AllowsCallouts {

    private Integer BATCHSIZE = 1000;
    private String query; 

    private TimeZone tz = UserInfo.getTimeZone();	
	private Integer CCRPRecordsProcessed = 0;
	private Integer CCRPRecordsSuccessful = 0;	
	private Integer CCRPRecordsFailed = 0;


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
    public BatchPurgeCustomerComplaint() {

    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(this.query);
    }

    global void execute(Database.BatchableContext bc, List<Customer_Complaint__c> scope){
        if(scope.size() > 0){
            Database.DeleteResult[] CCRPDeletedResult = Database.delete(scope, false);
            for (Database.DeleteResult CCRPDeleted : CCRPDeletedResult) {
                if (CCRPDeleted.isSuccess()) {
                    CCRPRecordsSuccessful++;
                }else{
                    CCRPRecordsFailed++;
                }        
            } 
        }     
       
    }

    global void execute(SchedulableContext sc){

        Integer backdate = Integer.valueof(purge_backDate);
        this.query = 'SELECT Name, TMB_Care__c, LastModifiedDate FROM Customer_Complaint__c WHERE LastModifiedDate  < LAST_N_MONTHS:'+backdate;   
        Id BatchProcessIdForInt = Database.ExecuteBatch(this,this.BATCHSIZE); 
    
    }

    global void finish(Database.BatchableContext bc){

        batchEndTime = datetime.now();
    	CCRPRecordsProcessed = CCRPRecordsSuccessful + CCRPRecordsFailed;

    	String subject = null;
    	String description = null;
    	String status = null;
    	if (CCRPRecordsFailed > 0 ) {//there are failed records
    		subject = 'Batch : Purge Customer Complaint/Customer Care run' + ' completely';
    		description = 'Batch : Purge Customer Complaint/Customer Care run' + ' completely';
    		status = 'Failed';
    	} else {//there are no failed records
    		subject = 'Batch : Purge Customer Complaint/Customer Care run' + ' successfully';
    		description = 'Batch : Purge Customer Complaint/Customer Care run' + ' successfully';
    		status = 'Success';
    	}    	
    	
		AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()];

        string htmlMsg;
        if(CCRPRecordsProcessed > 0 || Test.isRunningTest()){       	

            htmlMsg = description + ' <br/><br/>'
                    + 'Batch as of : ' + batchDate.format('dd/MM/yyyy', tz.toString()) + '<br/><br/>'
                    + 'Batch : Purge Customer Complaint/Customer Care run' + ' : ' + status + '<br/><br/>'
                    + '<table style="width:100%" border=1>'
                    + '<tr>'
                    + '	<th>' + System.Label.RTL_Purge_Email_006 + '</th>'					
                    + '	<th>' + System.Label.RTL_Purge_Email_003 + '</th>'
                    + '	<th>' + System.Label.RTL_Purge_Email_004 + '</th>'
                    + '	<th>' + System.Label.RTL_Purge_Email_005 + '</th>'
                    + '	<th>' + System.Label.RTL_Purge_Email_007 + '</th>'
                    + '	<th>' + System.Label.RTL_Purge_Email_008 + '</th>'
                    + '	<th>' + System.Label.RTL_Purge_Email_009 + '</th>'
                    + '</tr>'
                    + '<tr>'
                    + '	<td>' + 'Customer Complaint/Customer Care' + '</td>'					
                    + '	<td>' + batchDate.format('dd/MM/yyyy', tz.toString()) + '</td>'
                    + '	<td>' + batchStartTime.format('dd/MM/yyyy HH:mm:ss', tz.toString()) + '</td>'
                    + '	<td>' + batchEndTime.format('dd/MM/yyyy HH:mm:ss', tz.toString()) + '</td>'
                    + '	<td>' + CCRPRecordsProcessed + '</td>'
                    + '	<td>' + CCRPRecordsSuccessful + '</td>'
                    + '	<td>' + CCRPRecordsFailed + '</td>'
                    + '</tr>'					
                    + '</table>'
                    + '<br/><font color="red">' + System.Label.RTL_Purge_Email_011 + '</font><br/>'
                    + '<br/>' + System.Label.RTL_Purge_Email_footer + '</font>';
        }else{
            htmlMsg = description + ' <br/><br/>'
                    + 'Batch as of : ' + batchDate.format('dd/MM/yyyy', tz.toString()) + '<br/><br/>'
                    + 'Batch : Purge Customer Complaint/Customer Care run' + ' : ' + status + '<br/><br/>'
                    + '<b>'+'There are no record to process'+'</b>'+'<br/>'
                    + '<br/><font color="red">' + System.Label.RTL_Purge_Email_011 + '</font><br/>'
                    + '<br/>' + System.Label.RTL_Purge_Email_footer + '</font>';

        }
		RTL_BatchEmailService.SendEmail(bc.getJobId(), subject, htmlMsg);
   
    }
    
}