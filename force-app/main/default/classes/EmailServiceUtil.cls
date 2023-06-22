public class EmailServiceUtil implements Queueable {
    private Integer recordsSuccessful = 0;
    private Integer recordsFailed = 0;
    private List<SObject> ROWLOCKLIST = new List<SObject>();
    private String CSV_BODY = '';
    private Map<String, Schema.SObjectField> FIELDMAP;

    private Datetime batchDate = datetime.now();
    private Datetime batchStartTime = datetime.now();
    private List<String> SEND_EMAIL_LIST = null;
    //private List<Id> sucessIdList = new List<Id>();
    private String sobjectName;
    private String jobDailyName;
    private Boolean isEmailNotifySuccessAndError = true;
    private String ERRORLOG_FILENAME = '';
    private List<Map<String,String>> SCOPELST;
    private String REFFIELD;

    private String OPERATION_TYPE;
    public static String INSERT_OPERATION = 'INSERT_OPERATION';
    public static String UPSERT_OPERATION = 'UPSERT_OPERATION';

    public String IS_SUCCESS    = 'IS_SUCCESS';
    public String MESSAGE       = 'MESSAGE';
    
    private String SOSL_QUERY     = null;
    private String SOSL_KEY_FIELD = null;
    private String SOSL_KEY_MAP   = null;
    private String VALIDATE_FIELD   = null;
    private String VALIDATE_FIELD_VAL   = null;
    private String DATA_STRING     = null;

    private String FILENAME = '';
    private String FIELD_HEADER_CHANGE = '';
    private String JOB_CHANGE_NAME = '';
    private Boolean ISSuccessLogAttached = false;

    private String SenderEmail   = '';
    private String EndpointEmail = '';

    //for upload retail task
    private Integer STRING_LENGTH_LIMIT = 500000;

    public EmailServiceUtil(List<Map<String,String>> scopeLst
                            ,String objectName
                            ,String jobName
                            ,String refField
                            ,String operationType
                            ,String soslQuery
                            ,String soslKeyField
                            ,String soslKeyMap
                            ,String validateField
                            ,String validateFieldVal
                            ,List<String> emailList
                            ,String senderEmail
                            ,String endpointEmail
                            ,Boolean isSuccessLogAttch
                            ,String filename
                            ) {

        this.sobjectName = objectName;
        this.ERRORLOG_FILENAME = jobName;
        this.jobDailyName      = jobName;
        this.FIELDMAP = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        this.ROWLOCKLIST = new List<SObject>();
        this.SCOPELST = scopeLst;
        this.REFFIELD = refField;
        this.OPERATION_TYPE = operationType;
        this.SEND_EMAIL_LIST = emailList;
        this.SOSL_QUERY = soslQuery;
        this.SOSL_KEY_FIELD = soslKeyField;
        this.SOSL_KEY_MAP = soslKeyMap;
        this.VALIDATE_FIELD = validateField;
        this.VALIDATE_FIELD_VAL = validateFieldVal;
        this.SenderEmail = senderEmail;
        this.EndpointEmail = endpointEmail;
        this.isSuccessLogAttached = isSuccessLogAttch;

        this.FILENAME = filename;
    }
    

    public EmailServiceUtil(List<SObject> rowLockList
                            ,String objectName
                            ,String jobName
                            ,String refField
                            ,String operationType
                            ,List<String> emailList
                            ,String senderEmail
                            ,String endpointEmail
                            ,Boolean isSuccessLogAttch
                            ,String filename
                            ) {
        this.sobjectName = objectName;
        this.ERRORLOG_FILENAME = jobName;
        this.jobDailyName      = jobName;
        this.FIELDMAP = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        this.ROWLOCKLIST = rowLockList;
        this.REFFIELD = refField;
        this.OPERATION_TYPE = operationType;
        this.SEND_EMAIL_LIST = emailList;

        this.SenderEmail = senderEmail;
        this.EndpointEmail = endpointEmail;
        this.isSuccessLogAttached = isSuccessLogAttch;

        this.FILENAME = filename;
    }


    public EmailServiceUtil(String jobName
                            ,String refField
                            ,String operationType
                            ,List<String> emailList
                            ,String senderEmail
                            ,String endpointEmail
                            ,Boolean isSuccessLogAttch
                            ) {
        
        this.ERRORLOG_FILENAME = jobName;
        this.jobDailyName      = jobName;
        
        this.REFFIELD = refField;
        this.OPERATION_TYPE = operationType;
        this.SEND_EMAIL_LIST = emailList;

        this.SenderEmail = senderEmail;
        this.EndpointEmail = endpointEmail;
        this.isSuccessLogAttached = isSuccessLogAttch;
    }

    public EmailServiceUtil(String jobName
                            ,String refField
                            ,String operationType
                            ,List<String> emailList
                            ,String senderEmail
                            ,String endpointEmail
                            ,Boolean isSuccessLogAttch
                            ,Integer contentLimit
                            ) {
        
        this.ERRORLOG_FILENAME = jobName;
        this.jobDailyName      = jobName;
        
        this.REFFIELD = refField;
        this.OPERATION_TYPE = operationType;
        this.SEND_EMAIL_LIST = emailList;

        this.SenderEmail = senderEmail;
        this.EndpointEmail = endpointEmail;
        this.isSuccessLogAttached = isSuccessLogAttch;
        this.STRING_LENGTH_LIMIT = contentLimit;
    }

    public EmailServiceUtil(String jobName
                            ,String refField
                            ,String operationType
                            ,List<String> emailList
                            ,String senderEmail
                            ,String endpointEmail
                            ,Boolean isSuccessLogAttch
                            ,String fieldHeaderChange
                            ,String jobNameChange
                            ) {
        
        this.ERRORLOG_FILENAME = jobName;
        this.jobDailyName      = jobName;
        
        this.REFFIELD = refField;
        this.OPERATION_TYPE = operationType;
        this.SEND_EMAIL_LIST = emailList;
        this.FIELD_HEADER_CHANGE = fieldHeaderChange;
        this.JOB_CHANGE_NAME = jobNameChange;

        this.SenderEmail = senderEmail;
        this.EndpointEmail = endpointEmail;
        this.isSuccessLogAttached = isSuccessLogAttch;
    }



    public void execute(QueueableContext context) {
        try {
            List<sObject> scope;
            if (this.ROWLOCKLIST.size() > 0) {
                scope = this.ROWLOCKLIST;
            }else {
                if (!String.isEmpty(this.SOSL_QUERY) 
                        && !String.isEmpty(this.SOSL_KEY_FIELD) 
                        && !String.isEmpty(this.SOSL_KEY_MAP)) {
                    this.getSoslSearch();
                }
                
                scope = this.uploadDataToObject(this.sobjectName, this.jobDailyName);
            }

            if (scope != null && scope.size() > 0) doOperation(scope);
            else finish();
        }catch (Exception e) {
            RTL_CampaignUtil.saveToOnlineLog(false
                                , ''
                                , e.getMessage()+ ' '+e.getStackTraceString()
                                , ''
                                , UserInfo.getName()
                                , ''
                                , this.jobDailyName
                                , ''
                                , ''
                                , null
                                ,datetime.now()
                                ,datetime.now()
                                );

            String filename = this.ERRORLOG_FILENAME +'_'+ String.Valueof(Datetime.now());

            RTL_BatchEmailService.SendFinishDailyBatchSummaryEmail(batchDate
                                                        , batchStartTime
                                                        , datetime.now()
                                                        , recordsSuccessful
                                                        , recordsFailed
                                                        , filename
                                                        , sobjectName
                                                        , this.SEND_EMAIL_LIST
                                                        , e.getMessage()+ ' '+e.getStackTraceString()//+this.CSV_BODY_NOTE
                                                        , ''//this.SECONDARY_BODY
                                                        , this.CSV_LOG_SUCCESS
                                                        , this.MAINERR_HEADER
                                                        , ''//this.SECONDARYERR_HEADER
                                                        , this.SUCCESSLOG_HEAEDER
                                                        , ''//this.QUERY_SQL
                                                        );
        }
        
    }

    private void getSoslSearch() {
        List<String> idLst = new List<String>();

        Map<String,Map<String,String>> dataMap = new Map<String,Map<String,String>>();

        List<Map<String,String>> newScopeLst = new List<Map<String,String>>();

        List<String> valueLst = this.SOSL_KEY_MAP.split('=');

        for (Map<String,String> valMap : this.SCOPELST) {
            String valueKey = valMap.get(valueLst.get(0));

            if (String.isNotEmpty(valueKey)) {
                idLst.add(valueKey);
                dataMap.put(valueKey,valMap);
            }
        }

        String searchquery= this.SOSL_QUERY.replace('{%'+valueLst.get(0)+'%}',String.join(idLst,' OR '));
        List<List<SObject>> listofSObject = search.query(searchquery);
        List<SObject> sobjLst = listofSObject.get(0);

        Map<String,Sobject> sobjMap = new Map<String,Sobject>();

        //require to validte field if VALIDATE_FIELD has been configured
        for (SObject sobj : sobjLst) {
            String valueKey = String.valueOf(sobj.get(valueLst.get(0)));

            if (this.VALIDATE_FIELD != null && this.VALIDATE_FIELD.length() > 0) {
                String val = String.valueOf(sobj.get(this.VALIDATE_FIELD));
                if (val <> this.VALIDATE_FIELD_VAL) {
                    //validate fail
                    continue;
                }
            }

            sobjMap.put(valueKey,sobj);
        }
        //require to validte field if VALIDATE_FIELD has been configured

        for (String valKey : dataMap.keySet()) {
            if (sobjMap.containsKey(valKey)) {
                Map<String,String> valueMap = dataMap.get(valKey);
                valueMap.remove(valueLst.get(0));

                SObject sobj = sobjMap.get(valKey);

                Object dataObj = RTL_Utility.getRelationData(sobj,valueLst.get(1));

                if (dataObj != null) {
                    valueMap.put(this.SOSL_KEY_FIELD
                            ,String.Valueof(dataObj));

                    newScopeLst.add(valueMap);
                }else {
                    this.CSV_BODY = this.CSV_BODY 
                                + valKey
                                + ','
                                + 'NOT_FOUND_'+valueLst.get(1)
                                + ','
                                + valueLst.get(1)
                                + ','
                                + ''
                                +'\n';

                    this.recordsFailed++;
                    //newScopeLst.add(dataMap.get(valKey));
                }
            }else {
                this.CSV_BODY = this.CSV_BODY 
                                + valKey
                                + ','
                                + 'NOT_FOUND_'+valueLst.get(0)
                                + ','
                                + valueLst.get(0)
                                + ','
                                + ''
                                +'\n';

                this.recordsFailed++;
                //newScopeLst.add(dataMap.get(valKey));
            }
        }

        this.SCOPELST = newScopeLst;
    }

    public Map<String,String> validateAndProcess(Messaging.InboundEmail.BinaryAttachment[] bAttachments) { 
        Map<String,String> ret = new Map<String,String>();
        
        if (bAttachments == null || bAttachments.size() == 0) {
            ret.put(this.MESSAGE, RTL_ReportUtility.INVALID_ATTACHMENT_NUMBERS);
            ret.put(this.IS_SUCCESS,'false');
            return ret;
        }

        Integer csvCount = 0;
        Integer attachCount = 0;

        Messaging.InboundEmail.BinaryAttachment btt = null;

        for (Messaging.InboundEmail.BinaryAttachment chkbtt : bAttachments) {
            if(chkbtt.filename.endsWithIgnoreCase('.csv')){ 
                csvCount++;
                if (csvCount > 1) {
                    ret.put(this.MESSAGE, RTL_ReportUtility.INVALID_ATTACHMENT_NUMBERS);
                    ret.put(this.IS_SUCCESS,'false');
                    return ret;
                }else {
                    btt = chkbtt;
                }
            }

            attachCount++;
        }

        if (btt == null && attachCount > 0) {
            ret.put(this.MESSAGE, RTL_ReportUtility.INVALID_CSV_EXTENTSION);
            ret.put(this.IS_SUCCESS,'false');
            return ret;
        }


        this.FILENAME     = btt.filename;
        this.DATA_STRING  = btt.body.toString();
        this.DATA_STRING  = RTL_ReportUtility.replaceNewLineForCSV(this.DATA_STRING).replace('"','');

        if (String.isNotEmpty(this.FIELD_HEADER_CHANGE)
            && String.isNotEmpty(this.JOB_CHANGE_NAME)
            && this.DATA_STRING.indexOf('\n') <> -1
           ) {
            String header   = this.DATA_STRING.substringBefore('\n');

            if (header.contains(this.FIELD_HEADER_CHANGE)) {
                this.jobDailyName = this.JOB_CHANGE_NAME;
            }
        }

        
        List<Migration_Info__c> migrateLst = [SELECT Id
                                                        ,Name
                                                        ,Migrated_Field__c
                                                        ,ObjectName__c
                                                        ,Migrated_Field_1__c
                                                        ,SOSL_QUERY__c
                                                        ,SOSL_KEY_FIELD__c
                                                        ,SOSL_KEY_MAP__c
                                                        ,Validate_Field_Value_1__c
                                                        ,Validate_Field_1__c
                                                        ,Migrated_Field_2__c
                                                    FROM  Migration_Info__c 
                                                    WHERE IsActive__c = true 
                                                    AND Name =: this.jobDailyName 
                                                    AND Type__c = 'UPLOAD_EMAIL'
                                                    LIMIT 1];
        if (migrateLst.size() == 0) {
            ret.put(this.MESSAGE, this.jobDailyName + ' is Service Unavailable');
            ret.put(this.IS_SUCCESS,'false');
            return ret;
        }

        Migration_Info__c migrateObj = migrateLst.get(0);
        

        this.FIELDMAP = Schema.getGlobalDescribe().get(migrateObj.ObjectName__c).getDescribe().fields.getMap();
        this.sobjectName = migrateObj.ObjectName__c;            
        List<String> colMigrateLst = new List<String>();
        if (migrateObj.Migrated_Field__c != null)   colMigrateLst.addall(migrateObj.Migrated_Field__c.split(','));
        if (migrateObj.Migrated_Field_1__c != null) colMigrateLst.addall(migrateObj.Migrated_Field_1__c.split(','));
        if (migrateObj.Migrated_Field_2__c != null) colMigrateLst.addall(migrateObj.Migrated_Field_2__c.split(','));

        List<String> colHeaderList = RTL_ReportUtility.isValidCSVUTF8Encoding(this.DATA_STRING,colMigrateLst);
        if (colHeaderList == null) {
            ret.put(this.MESSAGE, RTL_ReportUtility.INVALID_UTF8_ENCODING);
            ret.put(this.IS_SUCCESS,'false');
            return ret;
        }

        //validate migrate field allow or not?
        SObject sObj = Schema.getGlobalDescribe().get(this.sobjectName).newSObject();

        for (String field : colHeaderList) {
            if (!colMigrateLst.contains(field)) {
                ret.put(this.MESSAGE,  'this field '+ field +' is not allowed to execute. for '+this.jobDailyName);
                ret.put(this.IS_SUCCESS,'false');
                return ret;
            }
        }   
        //validate migrate field allow or not?

        Integer totalRecord = this.process(colHeaderList,migrateObj);

        String message = 'Upload Successfully! \n'
                                    +'Your File '
                                    +btt.filename+' has been processing with total '
                                    + totalRecord+ ' Records';
        ret.put(this.MESSAGE,message);
        ret.put(this.IS_SUCCESS,'true');
        return ret;
    }


    private Integer process(List<String> colHeaderList,Migration_Info__c migrateObj ) {

        String header = this.DATA_STRING.substringBefore('\n');
        this.DATA_STRING    = this.DATA_STRING.substring(header.length()+1
                                                 ,this.DATA_STRING.length());

        List<String> headerLst = header.split(',');

        Map<String,Integer> fieldNumMap = new Map<String,Integer>();

        for (Integer i = 0; i < headerLst.size(); i++) {
            String col = headerLst.get(i);
            for (String columnVal : colHeaderList) {
                //if (col.contains(columnVal)) {
                if (col.trim().replace('\n','').equalsIgnoreCase(columnVal.trim().replace('\n',''))) {
                    fieldNumMap.put(columnVal.trim().replace('\n','')
                                    , i);
                    break;
                }
            }
        }

        String dataString = this.DATA_STRING;
        //List<String> dataLines = new List<String>();
        //Integer STRING_LENGTH_LIMIT = 500000;
        Integer lengthBody = dataString.length();
        Integer lengthCount = 0;

        Integer totalRecord = 0;

        while(lengthCount < lengthBody) {
           String  subStr = null;

           if (dataString.length() >= STRING_LENGTH_LIMIT) {
                subStr = dataString.substring(0, STRING_LENGTH_LIMIT);
            } else {
                subStr = dataString.substring(0, dataString.length());
            }

            subStr = subStr.substringBeforeLast('\n');

            Map<String,List<Map<String,String>>> valListMap = RTL_ReportUtility.readCSVToMap(subStr
                                                                                            ,colHeaderList
                                                                                            ,500
                                                                                            ,fieldNumMap);

            for (String key : valListMap.keyset()) {
                List<Map<String,String>> scopeLst = valListMap.get(key);

                EmailServiceUtil emailQueue = new EmailServiceUtil(scopeLst
                                                                    ,this.sobjectName
                                                                    ,this.jobDailyName
                                                                    ,this.REFFIELD
                                                                    ,this.OPERATION_TYPE
                                                                    ,migrateObj.SOSL_QUERY__c
                                                                    ,migrateObj.SOSL_KEY_FIELD__c
                                                                    ,migrateObj.SOSL_KEY_MAP__c
                                                                    ,migrateObj.Validate_Field_1__c
                                                                    ,migrateObj.Validate_Field_Value_1__c
                                                                    ,this.SEND_EMAIL_LIST
                                                                    ,this.SenderEmail
                                                                    ,this.EndpointEmail
                                                                    ,this.isSuccessLogAttached
                                                                    ,this.FILENAME
                                                                    );

                System.enqueueJob(emailQueue);

                totalRecord += scopeLst.size();
            }


            lengthCount   += subStr.length()+1;

            if (dataString.length() >= subStr.length()+1) {
                dataString = dataString.substring(subStr.length()+1, dataString.length());
            }
        }

        return totalRecord;
    }


    private void doOperation(List<sObject> scope) {
        try {
            if (this.OPERATION_TYPE.equals(INSERT_OPERATION)) {
                this.insertObjects(scope);
            }
            else if (this.OPERATION_TYPE.equals(UPSERT_OPERATION)) {
                this.upsertObjects(scope);
            }
        }catch(Exception err) {
            this.CSV_BODY = err.getMessage() +','+err.getStackTraceString();
        }
        finish();
    }

    private List<SObject> uploadDataToObject(String objectName
                                            ,String jobName) {
        List<SObject> sobjLst = new List<SObject>();


        for (Map<String,String> dataObjMap : this.SCOPELST) {
            SObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject() ;
            for (String field : dataObjMap.keySet()) {
                RTL_Utility.setRelationData(sObj,this.FIELDMAP,field, dataObjMap);
            }         

            sobjLst.add(sObj); 
        }
        return sobjLst;
    }

    private void insertObjects(List<sObject> scope) {
        Integer runningIndex = 0;
        Database.SaveResult[]  lsr = Database.Insert(scope, false);
        for (Database.SaveResult sr : lsr) {
            String recordId = (String)scope[runningIndex].get(this.REFFIELD);
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                //System.debug('Successfully Update '+jobName+' with ID: ' + sr.getId());
                recordsSuccessful++;
                //this.sucessIdList.add(sr.Id);
                this.CSV_LOG_SUCCESS = this.CSV_LOG_SUCCESS 
                                        + recordId
                                        + ','
                                        + 'INSERT_SUCCESS'
                                        + '\n';
            }
            else {
                boolean isNotRowLock = true;
                
                for(Database.Error err : sr.getErrors()) {
                    String errorMessage = err.getMessage();
                    //UNABLE_TO_LOCK_ROW Occur?
                    if(errorMessage.containsIgnoreCase('unable to obtain exclusive access to this record')){
                        this.ROWLOCKLIST.add(scope[runningIndex]);
                        isNotRowLock = false;
                        break;
                    }else {
                        this.CSV_BODY = this.CSV_BODY +recordId + ','
                                                    +err.getMessage() + ','
                                                    +String.join(err.getFields(),',') + ','
                                                    +err.getStatusCode()+'\n';
                    }
                }
                if (isNotRowLock) this.recordsFailed++;
            }
            runningIndex++;
        }
    }  

    
    private void upsertObjects(List<SObject> scope) {
        Schema.SObjectField extKey  = null;
        Database.UpsertResult[] upr = null;
        if (this.sobjectName.equals('RTL_Fulfillment__c')) {
            extKey = RTL_Fulfillment__c.Fields.RTL_Fulfillment_ID__c;
            String listType = 'List<' + this.sobjectName + '>';
            List<RTL_Fulfillment__c> castRecords = (List<RTL_Fulfillment__c>)Type.forName(listType).newInstance();
            castRecords.addAll((List<RTL_Fulfillment__c>)scope);
            upr = Database.upsert(castRecords,extKey, false);
        }else if (this.sobjectName.equals('RTL_Do_not_Contact_Info__c')) {
            extKey = RTL_Do_not_Contact_Info__c.Fields.MK_CODE_EXT_KEY__c;
            String listType = 'List<' + this.sobjectName + '>';
            List<RTL_Do_not_Contact_Info__c> castRecords = (List<RTL_Do_not_Contact_Info__c>)Type.forName(listType).newInstance();
            castRecords.addAll((List<RTL_Do_not_Contact_Info__c>)scope);
            upr = Database.upsert(castRecords,extKey, false);
        }else if (this.sobjectName.equals('Account')) {
            extKey = Account.Fields.TMB_Customer_ID_PE__c;
            String listType = 'List<' + this.sobjectName + '>';
            List<Account> castRecords = (List<Account>)Type.forName(listType).newInstance();
            castRecords.addAll((List<Account>)scope);
            upr = Database.upsert(castRecords,extKey, false);
        }else if (this.sobjectName.equals('Task')) {
            extKey = Task.Fields.LogACall_External_Id_crmdb__c;
            String listType = 'List<' + this.sobjectName + '>';
            List<Task> castRecords = (List<Task>)Type.forName(listType).newInstance();
            castRecords.addAll((List<Task>)scope);
            upr = Database.upsert(castRecords,extKey, false);
        }


        Integer runningIndex = 0;
        // Iterate through each returned result
        for (Database.UpsertResult sr : upr) {
            String recordId = (String)scope[runningIndex].get(this.REFFIELD);
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                this.recordsSuccessful++;
                this.CSV_LOG_SUCCESS = this.CSV_LOG_SUCCESS 
                                        + recordId
                                        + ','
                                        + 'UPSERT_SUCCESS'
                                        + '\n';
                //this.sucessIdList.add(sr.Id);
            }else {
                boolean isNotRowLock = true;
                
                for(Database.Error err : sr.getErrors()) {
                    String errorMessage = err.getMessage();
                    //UNABLE_TO_LOCK_ROW Occur?
                    if(errorMessage.containsIgnoreCase('unable to obtain exclusive access to this record')){
                        this.ROWLOCKLIST.add(scope[runningIndex]);
                        isNotRowLock = false;
                        break;
                    }else {
                        this.CSV_BODY = this.CSV_BODY +recordId + ','
                                                    +err.getMessage() + ','
                                                    +String.join(err.getFields(),',') + ','
                                                    +err.getStatusCode()+'\n';
                    }
                }
                if (isNotRowLock) this.recordsFailed++;
            }
            runningIndex++;
        } 
    }

    private String MAINERR_HEADER      = 'RecordId,ErrorMessage,ErrorOnFields,StatusCode\n';
    private String SUCCESSLOG_HEAEDER  = 'RecordId,Description\n';
    private String CSV_LOG_SUCCESS     = '';

    private void finish(){
        if (this.isEmailNotifySuccessAndError || this.recordsFailed > 0) {
            String filename = this.ERRORLOG_FILENAME +'_'+ String.Valueof(Datetime.now());

            if (!this.isSuccessLogAttached) {
                this.CSV_LOG_SUCCESS = '';
            }

            RTL_BatchEmailService.SendFinishDailyBatchSummaryEmail(batchDate
                                                        , batchStartTime
                                                        , datetime.now()
                                                        , recordsSuccessful
                                                        , recordsFailed
                                                        , filename
                                                        , sobjectName
                                                        , this.SEND_EMAIL_LIST
                                                        , this.CSV_BODY//+this.CSV_BODY_NOTE
                                                        , ''//this.SECONDARY_BODY
                                                        , this.CSV_LOG_SUCCESS
                                                        , this.MAINERR_HEADER
                                                        , ''//this.SECONDARYERR_HEADER
                                                        , this.SUCCESSLOG_HEAEDER
                                                        , ''//this.QUERY_SQL
                                                        );
        }

        Boolean isRet = true;
        if (this.recordsFailed > 0) {
            isRet = false;
        }

        this.addUploadEmailLog(isRet
                              ,this.SUCCESSLOG_HEAEDER+this.CSV_LOG_SUCCESS
                              ,this.MAINERR_HEADER+this.CSV_BODY
                              );

        if (this.ROWLOCKLIST.size() > 0 || Test.isRunningTest()) {
            EmailServiceUtil emailRowLockQueue = new EmailServiceUtil(this.ROWLOCKLIST
                                                                    ,this.sobjectName
                                                                    ,this.jobDailyName
                                                                    ,this.REFFIELD
                                                                    ,INSERT_OPERATION
                                                                    ,this.SEND_EMAIL_LIST
                                                                    ,this.SenderEmail
                                                                    ,this.EndpointEmail
                                                                    ,this.isSuccessLogAttached
                                                                    ,this.FILENAME
                                                                    );

            System.enqueueJob(emailRowLockQueue);
        }
    }

    
    private void addUploadEmailLog(Boolean isRet
                                  ,String successLog
                                  ,String errorLog) {
        RTL_Online_Service_Log__c inlog = new RTL_Online_Service_Log__c ();
        inlog.RTL_Name_of_User__c = UserInfo.getName() + ' SenderEmail ('+this.SenderEmail+')';

        inlog.Online_Batch_Log__c = this.jobDailyName;

        String errorMessage = 'Upload Email Service ' + this.jobDailyName;
               errorMessage += '\n Filename Upload ' + this.FILENAME;
               errorMessage += '\n Record Success = ' + this.recordsSuccessful;
               errorMessage += '\n Record Fail = ' + this.recordsFailed;
               errorMessage += '\n SenderEmail = ' + this.SenderEmail;
               errorMessage += '\n EndpointEmail = ' + this.EndpointEmail;

        inlog.RTL_Error_Message__c  = errorMessage ;
        inlog.RTL_Start_DateTime__c = batchStartTime;      
        inlog.RTL_End_DateTime__c   = Datetime.now();
        inlog.RTL_Service_Name__c   = 'UPLOAD_EMAIL';
        inlog.RTL_Is_Success__c     = isRet;
        inlog.RTL_Mulesoft_Log_Id__c = this.FILENAME;

        insert inlog;

        List<Attachment> importattachmentfileList = new List<Attachment>();

        if(!String.isBlank(successLog)) { 
            Attachment requestAttachment = new Attachment();
            requestAttachment.name = 'successLog.txt';
            requestAttachment.IsPrivate = false;
            requestAttachment.body = Blob.valueOf(successLog);
            requestAttachment.ParentId = inlog.Id;
            importattachmentfileList.add(requestAttachment);
        }

        if(!String.isBlank(errorLog)) { 
            Attachment responseAttachment = new Attachment();
            responseAttachment.name = 'errorLog.txt';
            responseAttachment.IsPrivate = false;
            responseAttachment.body = Blob.valueOf(errorLog);
            responseAttachment.ParentId = inlog.Id;
            importattachmentfileList.add(responseAttachment);
        }

        if (importattachmentfileList.size() > 0) insert importattachmentfileList;
    }

    //UPLOAD_EMAIL Migrate 
    /*
    public class UploadDataEmail {
        public Boolean result;
        public String description;
        public Map<String,List<String>> fieldValidateMap;
        public List<String> colHeaderList;
        public Map<String,List<Map<String,String>>> dataMap;
    }

    public EmailServiceUtil(){}

    public EmailServiceUtil.UploadDataEmail getDataForUploadEmail(String jobName,String dataString) {
        EmailServiceUtil.UploadDataEmail uploadDataEmail = new UploadDataEmail();

        Map<String,List<Map<String,String>>> valListMap = new Map<String,List<Map<String,String>>>();

        List<Migration_Info__c> migrateLst = [SELECT Id
                                                        ,Name
                                                        ,Migrated_Field__c
                                                        ,ObjectName__c
                                                        ,Migrated_Field_1__c
                                                        ,Validate_Field_1__c
                                                        ,Validate_Field_Value_1__c
                                                    FROM  Migration_Info__c 
                                                    WHERE IsActive__c = true 
                                                    AND Name =: jobName
                                                    AND Type__c = 'UPLOAD_EMAIL'
                                                    LIMIT 1];
        if (migrateLst.size() == 0) {
            uploadDataEmail.result = false;
            uploadDataEmail.description = jobName+' is Service Unavailable';
            return uploadDataEmail;
        }

        Migration_Info__c migrateObj = migrateLst.get(0);
        List<String> colMigrateLst = new List<String>();
        if (migrateObj.Migrated_Field__c != null) colMigrateLst.addall(migrateObj.Migrated_Field__c.split(','));
        if (migrateObj.Migrated_Field_1__c != null) colMigrateLst.addall(migrateObj.Migrated_Field_1__c.split(','));

        String objectName = migrateObj.ObjectName__c;
        List<String> colHeaderList = RTL_ReportUtility.isValidCSVUTF8Encoding(dataString,objectName);

        if (colHeaderList == null) {
            uploadDataEmail.result = false;
            uploadDataEmail.description = RTL_ReportUtility.INVALID_UTF8_ENCODING;
            return uploadDataEmail;
        }

        uploadDataEmail.colHeaderList = colHeaderList;
        SObject sObj = Schema.getGlobalDescribe().get(migrateObj.ObjectName__c).newSObject();

        for (String field : colHeaderList) {
            if (!colMigrateLst.contains(field)) {
                uploadDataEmail.result = false;
                uploadDataEmail.description = 'this field '+ field +' is not allowed to execute. for '+jobName;
                return uploadDataEmail;
            }
        }       


        String header = dataString.substringBefore('\n');
        dataString    = dataString.substring(header.length()+1,dataString.length());

        List<String> headerLst = header.split(',');

        Map<String,Integer> fieldNumMap = new Map<String,Integer>();

        for (Integer i = 0; i < headerLst.size(); i++) {
            String col = headerLst.get(i);
            for (String columnVal : colHeaderList) {
                if (col.contains(columnVal)) {
                    fieldNumMap.put(columnVal, i);
                    break;
                }
            }
        }

        Integer STRING_LENGTH_LIMIT = 500000;
        Integer lengthBody = dataString.length();
        Integer lengthCount = 0;

        Integer totalRecord = 0;

        while(lengthCount < lengthBody) {
            String  subStr = null;

            if (dataString.length() >= STRING_LENGTH_LIMIT) {
                subStr = dataString.substring(0, STRING_LENGTH_LIMIT);
            } else {
                subStr = dataString.substring(0, dataString.length());
            }

            subStr = subStr.substringBeforeLast('\n');

            Map<String,List<Map<String,String>>> subValListMap = RTL_ReportUtility.readCSVToMap(subStr
                                                                                            ,colHeaderList
                                                                                            ,500
                                                                                            ,fieldNumMap);

            valListMap.putAll(subValListMap);

        }

        if (migrateObj.Validate_Field_1__c != null && migrateObj.Validate_Field_1__c.length() > 0 
            && migrateObj.Validate_Field_Value_1__c != null && migrateObj.Validate_Field_Value_1__c.length() > 0 
           ) 
        {
            List<String> fieldValList = migrateObj.Validate_Field_Value_1__c.split(',');
            uploadDataEmail.fieldValidateMap = new Map<String,List<String>>();
            uploadDataEmail.fieldValidateMap.put(migrateObj.Validate_Field_1__c,fieldValList);
        }

        uploadDataEmail.result = true;
        uploadDataEmail.dataMap = valListMap;

        return uploadDataEmail;
    }*/
    //UPLOAD_EMAIL Migrate 
}