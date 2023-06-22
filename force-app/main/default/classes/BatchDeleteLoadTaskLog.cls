global with sharing class BatchDeleteLoadTaskLog implements Schedulable
                                                            , Database.Batchable<SObject>
                                                            , Database.Stateful
                                                            , Database.AllowsCallouts {

    private Integer BATCHSIZE = 500;
    private String query;

    private Integer logRecordsProcessed = 0;
	private Integer logRecordsSuccessful = 0;	
	private Integer logRecordsFailed = 0;

    private Integer attRecordsProcessed = 0;
	private Integer attRecordsSuccessful = 0;	
    private Integer attRecordsFailed = 0;
    
    String errorMessage = null;

    public BatchDeleteLoadTaskLog() {

    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(this.query);
    }

    global void execute(Database.BatchableContext bc, List<Load_Task_Log__c> scope){
        Set<ID> parentID = New Set<ID>();
        Set<ID> contentID = New Set<ID>();
        if(scope.size() > 0){
            parentID = (new Map<Id,Load_Task_Log__c>(scope)).keySet();
            List<ContentDocumentLink> attachedFileList = [SELECT ID,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in: parentID AND LinkedEntity.Type='Load_Task_Log__c'];
            if(attachedFileList.size() > 0){
                for(ContentDocumentLink contLink : attachedFileList){
                    contentID.add(contLink.ContentDocumentId);
                }
            }
            List<ContentDocument> contentList = [SELECT ID,FileType FROM ContentDocument WHERE id in: contentID];
            
            try{
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
                Database.DeleteResult[] logDeleteResult = Database.delete(scope, false);
                for (Database.DeleteResult logDelete : logDeleteResult) {
                    if (logDelete.isSuccess()) {
                        logRecordsSuccessful++;
                    }else{
                        logRecordsFailed++;
                    }        
                } 

            }catch(exception e){
                errorMessage = e.getMessage();
            }
        }

    }

    global void execute(SchedulableContext sc){
        //Delete record created more than 90 days
        this.query = 'SELECT ID, Name FROM Load_Task_Log__c WHERE CreatedDate < LAST_N_DAYS:'+90; 
        Id BatchProcessIdForInt = Database.ExecuteBatch(this,BATCHSIZE);
    }

    global void finish(Database.BatchableContext bc){
        logRecordsProcessed = logRecordsSuccessful + logRecordsFailed;
        attRecordsProcessed = attRecordsSuccessful + attRecordsFailed;

        //If run batch fail or have fail record, send email to CRM admin
        if(errorMessage != null || logRecordsFailed > 0 || attRecordsFailed > 0 || Test.isRunningTest()){
            TimeZone tz = UserInfo.getTimeZone();       
            String subject = 'Run Batch purge Load Task Log Failed ';
            String htmlMsg = 'Batch purge Load Task Log run Failed'                       
                            +'<br/><table style="width:100%" border=1>'
                            + '<tr>'                      
                            + ' <th>Object</th>'                  
                            + ' <th>Total</th>'
                            + ' <th>Success</th>'
                            + ' <th>Failed</th>'
                            + '</tr>'
    
                            + '<tr>'                       
                            + ' <td>' + 'Load_Task_Log__c' + '</td>'               
                            + ' <td>' + logRecordsProcessed+ '</td>'
                            + ' <td>' + logRecordsSuccessful + '</td>'
                            + ' <td>' + logRecordsFailed + '</td>'   
                            + '</tr>'
    
                            + '<tr>'                       
                            + ' <td>' + 'ContentDocument (Attachment)'+ '</td>'               
                            + ' <td>' + attRecordsProcessed+ '</td>'
                            + ' <td>' + attRecordsSuccessful + '</td>'
                            + ' <td>' + attRecordsFailed + '</td>'   
                            + '</tr>'
                            + '</table>';   
            if(errorMessage != null){
                htmlMsg = 'Batch purge Load Task Log run Failed <br/>' + errorMessage;
            }           

            AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()];
            String toEmail = AppConfig__c.getValues('CRM Admin').Value__c;
            String[] toAddresses;
            if(toEmail.contains(';')){
                toAddresses = toEmail.split(';');
            }else{
                toAddresses = new String[] {toEmail};
            }
    
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();      
            mail.setToAddresses(toAddresses);
            mail.setSubject(subject);
            mail.setHtmlBody(htmlMsg);
            Messaging.sendEmail(new Messaging.SingleEmailMessage [] {mail});
        }  
    }
}