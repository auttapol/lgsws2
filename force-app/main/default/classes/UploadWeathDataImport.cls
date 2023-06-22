public with sharing class UploadWeathDataImport implements Messaging.InboundEmailHandler {
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                       Messaging.InboundEnvelope env){
         
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        try {
            String SendersEmail = env.fromAddress;
            
            //get Attachment
            Messaging.InboundEmail.BinaryAttachment[] bAttachments = email.BinaryAttachments;

            if (bAttachments == null || bAttachments.size() != 1) {
                result.message = RTL_ReportUtility.INVALID_ATTACHMENT_NUMBERS;
                result.success = false;
                return result;
            }

            Messaging.InboundEmail.BinaryAttachment btt = bAttachments.get(0);

            if(!btt.filename.endsWithIgnoreCase('.csv')){ 
                result.message = RTL_ReportUtility.INVALID_CSV_EXTENTSION;
                result.success = false;
                return result;
            }

            String dataString  = RTL_ReportUtility.replaceNewLineForCSV(btt.body.toString());

            //validate line header
            List<String> colHeaderList = RTL_ReportUtility.isValidCSVUTF8Encoding(dataString,'Account');
            if (colHeaderList == null) {
                result.message = RTL_ReportUtility.INVALID_UTF8_ENCODING;
                result.success = false;
                return result;
            }

            Integer totalRecord = 0;

            
            AppConfig__c uploadWealthLimitCF = AppConfig__c.getValues('Upload_Weath_Data_String_Len');
            Integer STRING_LENGTH_LIMIT = 100000;

            try {
                STRING_LENGTH_LIMIT = Integer.valueOf(uploadWealthLimitCF.Value__c);
            }catch(Exception e) {}

            

            

            String header = dataString.substringBefore('\n');
            dataString    = dataString.substring(header.length()+1
                                                ,dataString.length());

            Integer lengthBody = dataString.length();
            Integer lengthCount = 0;


            while(lengthCount < lengthBody) {
                String  subStr = null;

                if (dataString.length() >= STRING_LENGTH_LIMIT) {
                    subStr = dataString.substring(0, STRING_LENGTH_LIMIT);
                } else {
                    subStr = dataString.substring(0, dataString.length());
                }

                subStr = subStr.substringBeforeLast('\n');

                List<String> dataLines = subStr.split('\n');
                totalRecord = totalRecord + dataLines.size();

                lengthCount   += subStr.length()+1;

                //call queue
                UploadWealthDataQueue nboImportQueue = new UploadWealthDataQueue(subStr
                                                                                    ,colHeaderList
                                                                                    ,SendersEmail);
                System.enqueueJob(nboImportQueue);
                
                dataString = dataString.substring(subStr.length()+1, dataString.length());
            }

            result.message = 'Upload Successfully! \n'
                            +'Your File '
                            +btt.filename+' has been processing with total '
                            + totalRecord+ ' Records';

            result.success = true;
        }catch(Exception e) {
            //send email to admin
            result.message = RTL_ReportUtility.INTERNAL_SERVER_ERROR+'\n'+e.getMessage() 
                                                + '\n'
                                                +e.getStackTraceString();
            result.success = false;
        }

        return result;              
                                                       
     }


     class UploadWealthDataQueue implements Queueable {
        private Integer recordsSuccessful = 0;
        private Integer recordsFailed = 0;
        private Datetime batchStartTime = datetime.now();

        private String BODY = '';
        private String CSV_BODY = '';

        private String SendersEmail;
        private List<String> columList;
        private Integer NUMBER_CUTOFF = 9000;

        private List<Account> SCOPE;

        private List<Account> ROWLOCKLIST = new List<Account>();

        private Map<String,String> mapField = new Map<String,String>();

        public UploadWealthDataQueue(String body
                                        ,List<String> colHeaderList
                                        ,String senderMail){
            this.BODY    = body;
            this.SendersEmail = senderMail;
            this.columList = colHeaderList;
        }

         public UploadWealthDataQueue(List<Account> sobjList
                                        ,List<String> colHeaderList
                                        ,String senderMail) {
            this.BODY = body;
            this.columList = colHeaderList;
            this.SendersEmail = senderMail;
            this.SCOPE = sobjList;
        }   
        
        public void execute(QueueableContext context) {
            if (this.SCOPE != null && this.SCOPE.size() > 0) {
                upsertWeathDataAccount(this.SCOPE);
            }else {
                start();
            }
        }

        public void start() {
            try {
                Map<String,List<Sobject>> valListMap = RTL_ReportUtility.readCSVToSobjectList(
                                                                                this.BODY
                                                                                ,'Account'
                                                                                ,NUMBER_CUTOFF
                                                                                ,this.mapField
                                                                                ,this.columList);

                for (String key : valListMap.keyset() ) {
                    List<Sobject> scope = valListMap.get(key);
                    upsertWeathDataAccount(scope);
                }

                sendSummaryEmail();
                //retry for UNABLE_TO_LOCK_ROW
                if (this.ROWLOCKLIST.size() > 0 || Test.isRunningTest()) {
                    UploadWealthDataQueue nboImportQueue = new UploadWealthDataQueue(this.ROWLOCKLIST
                                                                                    ,this.columList
                                                                                    ,this.SendersEmail);
                    System.enqueueJob(nboImportQueue);
                }

            }catch(Exception e) {
                String errMessage = 'Exception in UploadWealthDataQueue'
                                    +'\n'
                                    +e.getMessage() 
                                    + '\n'
                                    +e.getStackTraceString();

                String subject = 'Exception in UploadWealthDataQueue';
                List<String> emailOpsList = new List<String>();
                emailOpsList.add(this.SendersEmail);

                RTL_BatchEmailService.sendSummaryAttachmentEmail(subject
                                            ,errMessage
                                            ,emailOpsList
                                            ,new List<Messaging.Emailfileattachment> ()
                                            ,'FAIL'
                                            );
            }
        }

        private void upsertWeathDataAccount(List<Account> scope) {
            Schema.SObjectField extKey = Account.Fields.TMB_Customer_ID_PE__c;
            Database.UpsertResult[] upr = Database.upsert(scope,extKey, false);

            Integer runningIndex = 0;
            // Iterate through each returned result
            for (Database.UpsertResult sr : upr) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        this.recordsSuccessful++;
                    }
                    else {
                        // Operation failed, so get all errors
                        String info = '';
                        for (String field : this.columList) {
                            if (this.mapField.containsKey(field)) {
                                String sffield = this.mapField.get(field);
                                List<String> sffieldList = sffield.split('\\.');
                                SObject sobj = scope[runningIndex];
                                SObject tempSobj = sobj.getSobject(field.replace('__c','__r'));
                                
                                if (tempSobj != null) {
                                    info +=  (String)tempSobj.get(sffieldList.get(1))+',';
                                } 
                            }else {
                                info += scope[runningIndex].get(field)+',';
                            }
                            
                        }        

                        boolean isNotRowLock = true;

                        for(Database.Error err : sr.getErrors()) {
                                String errorMessage = err.getMessage();
                                //UNABLE_TO_LOCK_ROW Occur?
                                if(errorMessage.containsIgnoreCase('unable to obtain exclusive access to this record')){
                                    this.ROWLOCKLIST.add(scope[runningIndex]);
                                    isNotRowLock = false;
                                    break;
                                }else {
                                    this.CSV_BODY = this.CSV_BODY 
                                                    +info
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

        private void sendSummaryEmail() {
            List<String> emailOpsList = new List<String>();
            emailOpsList.add(this.SendersEmail);
            //emailOpsList.add('CRM Admin 2');

            TimeZone tz = UserInfo.getTimeZone();
            String filename = 'Upload_Weath_Data_Import_On_'+this.batchStartTime.format('dd/MM/yyyy_HH:mm:ss'
                                                                , tz.toString());

            RTL_BatchEmailService.SendFinishBatchSummaryEmail(this.batchStartTime
                                                        , this.batchStartTime
                                                        , datetime.now()
                                                        , this.recordsSuccessful
                                                        , this.recordsFailed
                                                        ,String.join(this.columList,',')
                                                        +'ErrorMessage,ErrorOnFields,StatusCode'
                                                        , filename
                                                        , 'Account'
                                                        , emailOpsList
                                                        , this.CSV_BODY);
        }   

     }

}