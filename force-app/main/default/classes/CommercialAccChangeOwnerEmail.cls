public with sharing class CommercialAccChangeOwnerEmail implements Messaging.InboundEmailHandler {
    private final String INTERNAL_SERVER_ERROR = 'INTERNAL_SERVER_ERROR. Please contact Admin';
    private final String INVALID_ATTACHMENT_NUMBERS = 'INVALID_ATTACHMENT_NUMBERS';
    private final String INVALID_CSV_EXTENTSION = 'INVALID_CSV_EXTENTSION';
    private final String INVALID_UTF8_ENCODING = 'INVALID_UTF8_ENCODING_OR_IMPORT_FILE_INVALID_FORMAT';

    private Map<String,String> getEmpCodeMap() {
        Map<String,String> empMap = new Map<String,String>();
        List<User> userList = [select id ,Employee_ID__c
                                    from User 
                                    where IsActive = true 
                                    and Employee_ID__c <> null];

        for (User user : userList) {
            empMap.put(user.Employee_ID__c,user.Id);
        }

        return empMap;
    }


    public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env){
       Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();    
       try {
            String SendersEmail = env.fromAddress;
            
            //get Attachment
            Messaging.InboundEmail.BinaryAttachment[] bAttachments = email.BinaryAttachments;

            if (bAttachments == null || bAttachments.size() != 1) {
                result.message = INVALID_ATTACHMENT_NUMBERS;
                result.success = false;
                return result;
            }

            Messaging.InboundEmail.BinaryAttachment btt = bAttachments.get(0);

            if(!btt.filename.endsWithIgnoreCase('.csv')){ 
                result.message = INVALID_CSV_EXTENTSION;
                result.success = false;
                return result;
            }

            String dataString  = RTL_ReportUtility.replaceNewLineForCSV(btt.body.toString());

            //validate line header
            List<String> colHeaderList = RTL_ReportUtility.isValidCSVUTF8Encoding(dataString,'Account');
            if (colHeaderList == null) {
                result.message = INVALID_UTF8_ENCODING;
                result.success = false;
                return result;
            }

            Integer totalRecord = 0;

            Integer STRING_LENGTH_LIMIT = 500000;
            Map<String,String> empMap = getEmpCodeMap();

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
                ChangeOwnerAccountQueue changeOwner = new ChangeOwnerAccountQueue(subStr
                                                                                    ,colHeaderList
                                                                                    ,empMap
                                                                                    ,SendersEmail);
                System.enqueueJob(changeOwner);

                dataString = dataString.substring(subStr.length()+1, dataString.length());
            }


            result.message = 'Upload Successfully! \n'
                            +'Your File '
                            +btt.filename+' has been processing with total '
                            + totalRecord+ ' Records';

            result.success = true;
       }catch(Exception e) {
            //send email to admin
            result.message = INTERNAL_SERVER_ERROR+'\n'+e.getMessage() 
                                                + '\n'
                                                +e.getStackTraceString();
            result.success = false;
       }

       return result;                                                  
    }

    class ChangeOwnerAccountQueue implements Queueable {
        private String BODY;
        private Map<String,String> EMPMAP;
        private String SendersEmail;
        private Integer NUMBER_CUTOFF = getNumberCutoff();
        private Integer BATCHROW = getBatchRow();
        private List<String> columList;
        private String TMBID_HEADER = 'TMB_Customer_ID_PE__c';
        private String EMPID_HEADER = 'OwnerId';

        public ChangeOwnerAccountQueue(String body
                                        ,List<String> colHeaderList
                                        ,Map<String,String> empMap
                                        ,String senderMail){
            this.BODY    = body;
            this.EMPMAP  = empMap;
            this.SendersEmail = senderMail;
            this.BATCHROW = batchRow;
            this.columList = colHeaderList;
        }

        private Integer getNumberCutoff() {
            try {
                AppConfig__c cf = AppConfig__c.getValues('RO_CHANGE_OWNER_ROW_CUTOFF');
                return (cf == null ? 2000 : Integer.valueOf(cf.Value__c));
            }catch(Exception e) {
                return 2000;
            }
        }

        private Integer getBatchRow() {
            try {
                AppConfig__c cf = AppConfig__c.getValues('RO_CHANGE_OWNER_BATCH_ROWLIMIT');
                return (cf == null ? 50 : Integer.valueOf(cf.Value__c));
            }catch(Exception e) {
                return 50;
            }
        }


        public void execute(QueueableContext context) {
            try {
                Map<String,List<Map<String,String>>> valListMap = RTL_ReportUtility.readCSVToMap(this.BODY
                                                                                                ,this.columList
                                                                                                ,this.NUMBER_CUTOFF);
               
                for (String key : valListMap.keyset() ) {
                    List<Map<String,String>> mapList = valListMap.get(key);

                    if (mapList != null && mapList.size() > 0) {
                        List<String> tmbCustIdList = new List<String>();
                        Map<String,List<String>> dataMap = new Map<String,List<String>>();

                        for (Map<String,String> tmbIdMap : mapList) {
                            String tmbId  = tmbIdMap.get(this.TMBID_HEADER);
                            String empCode = tmbIdMap.get(this.EMPID_HEADER);

                            if (String.isBlank(tmbId) || String.isBlank(empCode)) continue;

                            tmbCustIdList.add(tmbId);
                            String userId = this.EMPMAP.get(empCode);
                            List<String> info = new List<String>{empCode,userId};
                            dataMap.put(tmbId,info);
                        }

                        if (tmbCustIdList != null && tmbCustIdList.size() > 0) {
                            String keyCriteria = '(\''+String.join(tmbCustIdList,'\',\'')+'\')';
                            String queryAccount = 'SELECT Id,TMB_Customer_ID_PE__c,Owner.Employee_ID__c From Account '
                                                +' Where TMB_Customer_ID_PE__c in '+keyCriteria;

                            if(Test.isRunningTest()){
                                queryAccount += ' LIMIT 200';
                            }

                            List<String> sendToEmail = new List<String>();
                            sendToEmail.add(this.SendersEmail);
                            sendToEmail.add('CRM Admin 2');

                            DailyScheduleBatch updateChangeROBatch = new DailyScheduleBatch(queryAccount
                                                                                            ,DailyScheduleBatch.CHANGE_RO_OWNER_BATCH
                                                                                            ,'Account'
                                                                                            ,dataMap
                                                                                            ,'TMB_Customer_ID_PE__c'
                                                                                            ,sendToEmail);

                            Id batchChangeROId = Database.ExecuteBatch(updateChangeROBatch,this.BATCHROW);
                        }
                    }
                }
            }catch(Exception e) {
                String errMessage = 'Exception in ChangeOwnerCommercialAccountQueue'
                                    +'\n'
                                    +e.getMessage() 
                                    + '\n'
                                    +e.getStackTraceString();

                String subject = 'Exception in ChangeOwnerCommercialAccountQueue';
                List<String> emailOpsList = new List<String>();
                emailOpsList.add(this.SendersEmail);
                emailOpsList.add('CRM Admin 2');

                RTL_BatchEmailService.sendSummaryAttachmentEmail(subject
                                            ,errMessage
                                            ,emailOpsList
                                            ,new List<Messaging.Emailfileattachment> ()
                                            ,'FAIL');
            }
        }
    }
}