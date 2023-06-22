global without sharing class BatchUploadTask Implements Database.AllowsCallouts, Database.Batchable<SObject>, Database.Stateful {
    private String query; 
    private List<Task> taskList {get;set;}
    private Integer Success = 0;
    private Integer Failed = 0;
    List<String> fileHeader = new List<String>();
    private String fileName;

    private String details = '';
   
    global BatchUploadTask (List<Task> tasks, list<String> header, String fName){
        this.taskList = tasks;
        fileHeader = header;
        this.fileName = fName;

    }

    global List<Task> start(Database.BatchableContext BC){        
        return taskList;
    }

    global void execute(Database.BatchableContext bc, List<Task> scope){
        Set<String> custSet =  new Set<String>();
        Set<String> RecordTypeSet =  new Set<String>();
        Set<String> BranchSet =  new Set<String>();
        Set<String> EmployeeSet =  new Set<String>();
        Map<String,String> RecordTypes = new Map<String,String>();
        Map<String,User> branchManager = new Map<String,User>();
        Map<String,User> EmployeeOwner = new Map<String,User>();
        Map<String,Account> Customer = new Map<String,Account>();
        List<Task> TaskScope = scope;
        for (Task t : TaskScope){
            custSet.add(t.WhatId);
            RecordTypeSet.add(t.RecordTypeId);
            String str = t.OwnerId;
            str = str.replace('\"','');
            str = str.replace('	','');
            str = str.replace(' ','');         
       
            if (str.startsWith('00')){
                str = str.Substring(2,str.length());
                BranchSet.add(str);
            }else {
                EmployeeSet.add(str);
            }
        }
        
        for (String types : RecordTypeSet){
            try{
                
                Id devRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(types).getRecordTypeId();
                if(devRecordTypeId != null){
                    RecordTypes.put(types,devRecordTypeId);
                } 
            }catch(exception e){
                system.debug('Error exception : '+ e.getMessage());
            }
                       
        }       

        List<Account> TMBCust = [SELECT Id, TMB_Customer_ID_PE__c FROM Account WHERE TMB_Customer_ID_PE__c in: custSet];
        List<User> ManagerList = [SELECT Id,RTL_Branch_Code__c,RTL_Channel__c,Employee_ID__c,Region_Code__c,Zone_Code__c,Title 
                            FROM User WHERE Title = 'Branch Manager' AND RTL_Branch_Code__c in:BranchSet AND IsActive = true];
        List<User> EmployeeList = [SELECT Id,RTL_Branch_Code__c,RTL_Channel__c,Employee_ID__c,Region_Code__c,Zone_Code__c,Title 
                            FROM User WHERE Employee_ID__c in:EmployeeSet ];

        if (ManagerList.size() > 0){
            for (User u : ManagerList){
                branchManager.put(u.RTL_Branch_Code__c,u);
            }
        }

        for (User u : EmployeeList){
            EmployeeOwner.put(u.Employee_ID__c,u);

        }
        for (Account a : TMBCust){
            Customer.put(a.TMB_Customer_ID_PE__c,a);
        }

        // process each batch of records            
        List<Task> tasks = new List<Task>();
        for (Integer i = 0 ; i < TaskScope.size();i++){
            try {
                Task thisTask = new Task();

                String owneridRevise = TaskScope[i].OwnerId;
                owneridRevise = owneridRevise.replace('\"','');
                owneridRevise = owneridRevise.replace('	','');
                owneridRevise = owneridRevise.replace(' ',''); 
                String branchstr = owneridRevise;
                branchstr = branchstr.Substring(2,branchstr.length());
                
                if (RecordTypes.containsKey(TaskScope[i].RecordTypeId)){
                 
                    TaskScope[i].RecordTypeId = RecordTypes.get(TaskScope[i].RecordTypeId);
                }
                if (Customer.containsKey(TaskScope[i].WhatId)){

                    TaskScope[i].WhatId = Customer.get(TaskScope[i].WhatId).Id;
                }
                if (EmployeeOwner.containsKey(owneridRevise)){
                    User Employee = EmployeeOwner.get(owneridRevise);
                    TaskScope[i].OwnerId = Employee.Id;
                    TaskScope[i].RTL_Task_Created_Branch_Code__c = Employee.RTL_Branch_Code__c;
                    TaskScope[i].RTL_Task_Created_Channel__c = Employee.RTL_Channel__c;
                    TaskScope[i].RTL_Task_Created_Emp_Id__c = Employee.Employee_ID__c;
                    TaskScope[i].RTL_Task_Created_Region_Code__c = Employee.Region_Code__c;
                    TaskScope[i].RTL_Task_Created_Zone_Code__c = Employee.Zone_Code__c;
                    
                }else if (branchManager.containsKey(branchstr)){
                    User Manager = branchManager.get(branchstr);
                    TaskScope[i].OwnerId = Manager.Id;
                    TaskScope[i].RTL_Task_Created_Branch_Code__c = Manager.RTL_Branch_Code__c;
                    TaskScope[i].RTL_Task_Created_Channel__c = Manager.RTL_Channel__c;
                    TaskScope[i].RTL_Task_Created_Emp_Id__c = Manager.Employee_ID__c;
                    TaskScope[i].RTL_Task_Created_Region_Code__c = Manager.Region_Code__c;
                    TaskScope[i].RTL_Task_Created_Zone_Code__c = Manager.Zone_Code__c;
                   
                }
                thisTask = TaskScope.get(i);
                tasks.add(thisTask);

            } catch(Exception e){

                system.debug('Error exception: '+ e.getMessage());

            }
        }

        /*
        //Log file only 'Id,Message'
        Database.UpsertResult[] results = Database.upsert(tasks, Task.LogACall_External_Id_crmdb__c, false); 
        for(Integer index = 0 ; index < results.size(); index++) {
            if(results[index].isSuccess()) {        
                this.Success++;   
                details = details +results[index].getId()+',Success\n' ; 
            }else{
                String messagefail = '';
                for(Database.Error err : results[index].getErrors()) {   
                    messagefail = 'Error :'+ err.getFields() + ': ' + err.getMessage();
                    
                } 
                this.Failed++;
                details = details +results[index].getId()+','+ messagefail +'\n' ; 
            }
        }
        */
       
       
        list<task> tempTask = tasks;
        Database.UpsertResult[] results = Database.upsert(tasks, Task.LogACall_External_Id_crmdb__c, false);   
        for(Integer index = 0 ; index < results.size(); index++) {
            String str = JSON.serialize(tempTask[index]);
            Map<String, Object> detailMap = (Map<String, Object>) JSON.deserializeUntyped(str);

            if(results[index].isSuccess()) {                      
                this.Success++;     
                for(integer j = 0; j < fileHeader.size(); j++){
                    String fieldName = fileHeader[j];
                    if(fieldName != null){ 

                        String fieldValue = (String)detailMap.get(fieldName);
                        if(fieldName == 'LogACall_External_Id_crmdb__c'){
                            fieldValue = EncodingUtil.urlEncode((String)fieldValue, 'UTF-8');
                            fieldValue = fieldValue.replace('%0D',''); //Replace \n 
                        }
                        if( j == 0){
                            details = details + results[index].getId()+','+ fieldValue+',';
                        }else if(j == fileHeader.size() -1){
                            details = details + fieldValue + ',Success'+'\n';

                        }else{
                            details = details + fieldValue +',';                                
                        }                     
                    }                  
                }
                
            }else{
                String messagefail = '';
                for(Database.Error err : results[index].getErrors()) {   
                    messagefail = 'Error :'+err.getFields() + ': ' + err.getMessage();                                
                } 
                this.Failed++;

                for(integer j = 0; j < fileHeader.size(); j++){
                    String fieldName = fileHeader[j];
                    if(fieldName != null){ 

                        String fieldValue = (String)detailMap.get(fieldName);
                        if(fieldName == 'LogACall_External_Id_crmdb__c'){
                            fieldValue = EncodingUtil.urlEncode((String)fieldValue, 'UTF-8');
                            fieldValue = fieldValue.replace('%0D',''); //Replace \n 
                        }
                        if( j == 0){
                            details = details + results[index].getId()+','+ fieldValue+',';
                        }else if(j == fileHeader.size() -1){
                            details = details + fieldValue + ','+ messagefail +'\n';
                        }else{
                            details = details + fieldValue +',';                                
                        }                     
                    }                  
                }
            }
        }
    
    }   

    global void finish(Database.BatchableContext bc){
        
        Integer total = Success + Failed;
        Load_Task_Log__c resultLog = New Load_Task_Log__c();
        resultLog.name = fileName;
        resultLog.Total_Record__c = total;
        resultLog.Success_Record__c = Success;
        resultLog.Failed_Record__c = Failed;
        resultLog.Load_Type__c = 'Upload Task';
        insert resultLog;
        addAttachmentsToContract(resultLog);      
        
        TimeZone tz = UserInfo.getTimeZone();
        String mainUrl =  'https://' +  System.URL.getSalesforceBaseUrl().getHost() + '/lightning/r/Load_Task_Log__c/'+resultLog.id+ '/view';
        String subject = 'Run Batch Upload Task ';
        String htmlMsg =  'Batch Upload Task have run Completed'                    
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

    /*
    //Log file only 'Id,Message'
    private ContentVersion createContentVersion(){
        List<string> strList= new List<string> ();        
        String logFile = 'Id,Message\n' + details;      
        strList.add(logFile);
        String allstring = string.join(strList,',');

        ContentVersion ContVerFile = new ContentVersion();
            ContVerFile.VersionData = Blob.valueOf(allstring);
            ContVerFile.Title = fileName; 
            ContVerFile.ContentLocation= 's';
            ContVerFile.PathOnClient= fileName+'.csv';

        return ContVerFile;
    }
    */
  
  
    private ContentVersion createContentVersion(){
        List<string> strList= new List<string> ();
        String header = '';

        if(fileHeader.size() > 0){
            for(integer j =0; j < fileHeader.size(); j++){
                String fieldName = fileHeader[j];                  
                if(j == fileHeader.size() -1){
                    header = header + fieldName+',Message'+'\n';
                }else{
                    header = header + fieldName+',';
                }                 
            }
        }

        details = 'Id,'+header + details;      
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