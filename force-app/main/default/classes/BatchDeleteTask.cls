global without sharing class BatchDeleteTask Implements Database.Batchable<SObject>, Database.Stateful {
    private List<Task> taskList {get;set;}
    private Integer Success = 0;
    private Integer Failed = 0;
    private String fileName;
    String details = '';
    
    global BatchDeleteTask(List<Task> lists, String fName){
        this.taskList = lists;
        this.fileName = fName;

    }
    global List<Task> start(Database.BatchableContext BC){
        
        return taskList;
    }
    global void execute(Database.BatchableContext bc, List<Task> scope){
        Set<String> externalId = new Set<String>();
        Set<String> setID = new Set<String>();       
     
        for (Task t : scope){
            if (t.LogACall_External_Id_crmdb__c != null && t.LogACall_External_Id_crmdb__c != ''){
                String encoded = EncodingUtil.urlEncode(t.LogACall_External_Id_crmdb__c, 'UTF-8');
                String cleanData1 = encoded.replace('%0D','');
                externalId.add(cleanData1);

            }else if(t.id != null){
                String encoded = EncodingUtil.urlEncode(t.id, 'UTF-8');
                String cleanData2 = encoded.replace('%0D','');
                setID.add(cleanData2);

            }
        }
        
        List<Task> deleteList = new List<Task>();
        if(externalId.size() > 0){
            deleteList = [SELECT Id,LogACall_External_Id_crmdb__c FROM Task WHERE LogACall_External_Id_crmdb__c in:externalId ];
        }else if(setID.size() > 0){
            deleteList = [SELECT Id, LogACall_External_Id_crmdb__c FROM Task WHERE Id in:setID];
        }

        if(deleteList.size() > 0){
            Database.DeleteResult[] deleteResult = Database.delete(deleteList,false);
            for(Integer index = 0 ; index < deleteResult.size(); index++) {
                if(deleteResult[index].isSuccess()) {             
                    this.Success++;
                    details = details + deleteResult[index].getId() + ',Deleted Success\n';  
                }else{
                    String messagefail = '';
                    for(Database.Error err : deleteResult[index].getErrors()) {  
                        messagefail = 'Error :'+err.getFields() + ': ' + err.getMessage();                        
                    } 
                    this.Failed++;
                    details = details + deleteResult[index].getId() + ',' + messagefail+ '\n';
                }
            }
            }else{
            //not found record for deleted
            List<task> taskDelete = scope;
            for(integer i = 0 ; i < taskDelete.size(); i++){ 
                this.Failed++;
                details = details + 'null,Error : Not found record for deleted\n';

            }           

        }

    }

    global void finish(Database.BatchableContext bc){

        Integer total = Success + Failed;
        Load_Task_Log__c resultLog = New Load_Task_Log__c();
        resultLog.name = fileName;
        resultLog.Total_Record__c = Success + Failed;
        resultLog.Success_Record__c = Success;
        resultLog.Failed_Record__c = Failed;
        resultLog.Load_Type__c = 'Delete Task';
        insert resultLog;
        addAttachmentsToContract(resultLog); 

        TimeZone tz = UserInfo.getTimeZone();
        String mainUrl =  'https://' +  System.URL.getSalesforceBaseUrl().getHost() + '/lightning/r/Load_Task_Log__c/'+resultLog.id+ '/view';
        String subject = 'Run Batch Delete Task ';
        String htmlMsg =  'Batch Delete Task have run Completed'                    
                        +'<br />View :<a href="'+mainUrl+'"> Click here</a>'
                        +'<br/><table style="width:100%" border=1>'
                        + '<tr>'                      
                        + ' <th>File Name</th>'                  
                        + ' <th>Total</th>'
                        + ' <th>Success</th>'
                        + ' <th>Failed</th>'           
                        + '</tr>'

                        + '<tr>'                       
                        + ' <td>' + fileName + '</td>'               
                        + ' <td>' + total+ '</td>'
                        + ' <td>' + Success + '</td>'
                        + ' <td>' + Failed + '</td>'               
                        + '</tr>'
                        + '</table>'
                        + '<br/><br/> <p style="color:#ff0000;"><strong>This is an automatically generated email. Please do not reply. </strong></p>'  
                        + '<br/>The information contained in this e-mail may be confidential, proprietary and/or legally privileged. If you are not the'
                        + 'intended recipient of this e-mail, please delete and destroy all copies immediately.&nbsp; Any review, dissemination, copy,'
                        + 'retransmission, distribution or use of this e-mail in any form for any purpose is strictly prohibited. The sender accepts no '
                        + 'responsibility for any miss transmission of, or interference with, this e-mail.';                      
    
        AsyncApexJob a =  [SELECT a.Id, a.TotalJobItems, a.Status, a.NumberOfErrors, a.JobType, a.JobItemsProcessed, 
                        a.ExtendedStatus, a.CreatedById, a.CompletedDate, a.CreatedBy.Email, a.ParentJobId,
                        a.CreatedDate, a.LastProcessed, a.LastProcessedOffset, a.MethodName, a.ApexClassId
                        FROM AsyncApexJob a 
                        WHERE Id = :bc.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject+a.Status);
        mail.setHtmlBody(htmlMsg);
        Messaging.sendEmail(new Messaging.SingleEmailMessage [] {mail});
    }

    private void addAttachmentsToContract(Load_Task_Log__c taskLog) {
     
        ContentVersion contentVer = createContentVersion();

        insert contentVer;

        List<ContentVersion> conver = [select id, ContentDocumentId from ContentVersion where id =: contentVer.id];
        ContentDocumentLink contentDocumentLink = createContentDocumentLink(conver[0].ContentDocumentId, taskLog.Id);

        insert contentDocumentLink;
    }

    private ContentVersion createContentVersion(){

        List<string> strList= new List<string> ();
       
        details = 'Id,Message\n'+details;        
        strList.add(details);
        String allstring = string.join(strList,',');

        ContentVersion ContVerFile = new ContentVersion();
            ContVerFile.VersionData = Blob.valueOf(allstring);
            ContVerFile.Title = fileName; 
            ContVerFile.ContentLocation= 's';
            ContVerFile.PathOnClient= fileName+'.csv';

        return ContVerFile;
    }
    
    private ContentDocumentLink createContentDocumentLink(Id contentDocumentId, Id parentId){
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentDocumentId;
        contentDocumentLink.LinkedEntityId = parentId;
        contentDocumentLink.ShareType = 'V'; // Inferred permission
        contentDocumentLink.Visibility = 'InternalUsers';
        return contentDocumentLink;
    }
    
}