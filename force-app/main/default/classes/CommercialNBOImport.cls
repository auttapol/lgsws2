public with sharing class CommercialNBOImport implements Messaging.InboundEmailHandler {
    private final String INTERNAL_SERVER_ERROR = 'INTERNAL_SERVER_ERROR. Please contact Admin.';
    private final String INVALID_ATTACHMENT_NUMBERS = 'INVALID_ATTACHMENT_NUMBERS';
    private final String INVALID_CSV_EXTENTSION = 'INVALID_CSV_EXTENTSION';
    private final String INVALID_UTF8_ENCODING = 'INVALID_UTF8_ENCODING_OR_IMPORT_FILE_INVALID_FORMAT';

    public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                       Messaging.InboundEnvelope env){

        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();  
        try {
            String SendersEmail = env.fromAddress;
            String fileName = '';
            String dataString = '';
            Boolean btt_isNotCSV = true;
            Boolean ttt_isNotCSV = true;

            //get Attachment
            Messaging.InboundEmail.BinaryAttachment[] bAttachments = email.BinaryAttachments;
            Messaging.InboundEmail.TextAttachment[] tAttachments = email.textAttachments;
            System.debug('[ING] BinaryAttachments: '+ bAttachments);
            System.debug('[ING] TextAttachments: '+ tAttachments);

            //Check email has attachment or not
            if((bAttachments == null || bAttachments.size() != 1) && (tAttachments == null || tAttachments.size() != 1))
            {
                result.message = INVALID_ATTACHMENT_NUMBERS;
                result.success = false;
                return result;
            }
            
            //Check which type is not .CSV
            if(bAttachments != null)
            {
                Messaging.InboundEmail.BinaryAttachment btt = bAttachments.get(0);
                fileName = btt.filename;
                if(fileName.endsWithIgnoreCase('.csv'))
                {
                    btt_isNotCSV = false;
                }
            }

            if(tAttachments != null)
            {
                Messaging.InboundEmail.TextAttachment ttt = tAttachments.get(0);
                fileName = ttt.filename;
                if(fileName.endsWithIgnoreCase('.csv'))
                {
                    ttt_isNotCSV = false;
                }
            }

            if((btt_isNotCSV == true) && (ttt_isNotCSV == true))
            {
                result.message = INVALID_CSV_EXTENTSION;
                result.success = false;
                return result;
            }
            else if ((btt_isNotCSV == false) && (ttt_isNotCSV == true))
            {
                //has file .csv type BinaryAttachment
                dataString = RTL_ReportUtility.replaceNewLineForCSV(bAttachments.get(0).body.toString());

            }
            else if ((btt_isNotCSV == true) && (ttt_isNotCSV == false))
            {
                //has file .csv type TextAttachment
                dataString = RTL_ReportUtility.replaceNewLineForCSV(tAttachments.get(0).body);
            }

            //validate encoding must be utf8. to validate by checking first row must have value
            List<String> colHeaderList = RTL_ReportUtility.isValidCSVUTF8Encoding(dataString,'Product_Campaign_Recommend__c');
            
            if (colHeaderList == null) {
                result.message = INVALID_UTF8_ENCODING;
                result.success = false;
                return result;
            }

            Integer totalRecord = 0;

            Integer STRING_LENGTH_LIMIT = 500000;

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
                CommercialNBOImportQueue nboImportQueue = new CommercialNBOImportQueue(subStr
                                                                                    ,colHeaderList
                                                                                    ,SendersEmail);
                System.enqueueJob(nboImportQueue);
                
                dataString = dataString.substring(subStr.length()+1, dataString.length());
            }


            result.message = 'Upload Successfully! \n'
                            +'Your File '
                            + fileName+' has been processing with total '
                            + totalRecord+ ' Records';

            result.success = true;
        }catch(Exception e) {
             //send email to admin
             System.debug(e);
            result.message = INTERNAL_SERVER_ERROR+'\n'+e.getMessage() 
                                                + '\n'
                                                +e.getStackTraceString();
            result.success = false;
        }
        return result;
    }                                        
                   
    class CommercialNBOImportQueue implements Queueable {
        private Integer recordsSuccessful = 0;
        private Integer recordsFailed = 0;
        private Datetime batchStartTime = datetime.now();

        private String BODY = '';
        private String CSV_BODY = '';

        private String SendersEmail;
        private List<String> columList;
        private Integer NUMBER_CUTOFF = 10000;

        private List<Product_Campaign_Recommend__c> SCOPE;

        private List<Product_Campaign_Recommend__c> ROWLOCKLIST = new List<Product_Campaign_Recommend__c>();

        private Map<String,String> mapField = new Map<String,String>();

        public CommercialNBOImportQueue(String body
                                        ,List<String> colHeaderList
                                        ,String senderMail) {
            this.BODY = body;
            this.columList = colHeaderList;
            this.SendersEmail = senderMail;
            this.SCOPE = new List<Product_Campaign_Recommend__c>();
        }

        public CommercialNBOImportQueue(List<Product_Campaign_Recommend__c> sobjList
                                        ,List<String> colHeaderList
                                        ,String senderMail) {
            this.BODY = body;
            this.columList = colHeaderList;
            this.SendersEmail = senderMail;
            this.SCOPE = sobjList;
        }   

        public void execute(QueueableContext context) {
            this.mapField.put('AccountAccount__c','Account.TMB_Customer_ID_PE__c');

            if (this.SCOPE != null && this.SCOPE.size() > 0) {
                upsertCommercialNBO(this.SCOPE);
            }else {
                start();
            }
        }

        public void start() {
            try {
                Map<String,List<Sobject>> valListMap = RTL_ReportUtility.readCSVToSobjectList(this.BODY
                                                                                ,'Product_Campaign_Recommend__c'
                                                                                ,NUMBER_CUTOFF
                                                                                ,this.mapField
                                                                                ,this.columList);

                for (String key : valListMap.keyset() ) {
                    List<Sobject> scope = valListMap.get(key);
                    upsertCommercialNBO(scope);
                }

                sendSummaryEmail();
                //retry for UNABLE_TO_LOCK_ROW
                if (this.ROWLOCKLIST.size() > 0) {
                    CommercialNBOImportQueue nboImportQueue = new CommercialNBOImportQueue(this.ROWLOCKLIST
                                                                                    ,this.columList
                                                                                    ,this.SendersEmail);
                    System.enqueueJob(nboImportQueue);
                }

            }catch(Exception e) {
                String errMessage = 'Exception in CommercialNBOImportQueue'
                                    +'\n'
                                    +e.getMessage() 
                                    + '\n'
                                    +e.getStackTraceString();

                String subject = 'Exception in CommercialNBOImportQueue';
                List<String> emailOpsList = new List<String>();
                emailOpsList.add(this.SendersEmail);
                emailOpsList.add('CRM Admin 2');

                RTL_BatchEmailService.sendSummaryAttachmentEmail(subject
                                            ,errMessage
                                            ,emailOpsList
                                            ,new List<Messaging.Emailfileattachment> ()
                                            ,'FAIL'
                                            );
            }
        }

        private void upsertCommercialNBO(List<Product_Campaign_Recommend__c> scope) {
            Database.UpsertResult[] upr = Database.upsert(scope, false);

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
            emailOpsList.add('CRM Admin 2');

            TimeZone tz = UserInfo.getTimeZone();
            String filename = 'Import_Commercial_NBO_On_'+this.batchStartTime.format('dd/MM/yyyy_HH:mm:ss', tz.toString());

            RTL_BatchEmailService.SendFinishBatchSummaryEmail(this.batchStartTime
                                                        , this.batchStartTime
                                                        , datetime.now()
                                                        , this.recordsSuccessful
                                                        , this.recordsFailed
                                                        ,String.join(this.columList,',')
                                                        +'ErrorMessage,ErrorOnFields,StatusCode'
                                                        , filename
                                                        , 'Product_Campaign_Recommend__c'
                                                        , emailOpsList
                                                        , this.CSV_BODY);
        }   
    }                                 

}