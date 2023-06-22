public with sharing class UserExcelImport implements Messaging.InboundEmailHandler {
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
            Integer totalRecord = 0;

            String dataString  = RTL_ReportUtility.replaceNewLineForCSV(btt.body.toString());
            
            //validate encoding must be utf8. to validate by checking first row must have value
            List<String> colHeaderList = RTL_ReportUtility.isValidCSVUTF8Encoding(dataString,'User');
            
            if (colHeaderList == null) {
                result.message = RTL_ReportUtility.INVALID_UTF8_ENCODING;
                result.success = false;
                return result;
            }

            String header = dataString.substringBefore('\n');
            dataString    = dataString.substring(header.length()+1
                                                 ,dataString.length());

            Integer recordsSuccessful = 0;
            Integer recordsFailed = 0;
            Datetime batchStartTime = datetime.now();


            Map<String,List<Sobject>> valListMap = RTL_ReportUtility.readCSVToSobjectList(dataString
                                                                                ,'User'
                                                                                ,5000 //the number for one list
                                                                                ,new Map<String,String>()
                                                                                ,colHeaderList);
            String errorMessageForEmail = '';

            Schema.SObjectField f = User.Fields.Employee_ID__c;

            for (String key : valListMap.keyset() ) {
                List<User> scope = (List<User>)valListMap.get(key);

                Database.UpsertResult[] upr = Database.upsert(scope,f, false);

                Integer runningIndex = 0;
                // Iterate through each returned result
                for (Database.UpsertResult sr : upr) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            recordsSuccessful++;
                        }else {
                            recordsFailed++;
                            // Operation failed, so get all errors
                            String info = '';
                            for (String field : colHeaderList) {
                                info += scope[runningIndex].get(field)+',';
                            }   

                            for(Database.Error err : sr.getErrors()) {
                               errorMessageForEmail = errorMessageForEmail
                                                        +info
                                                        +err.getMessage() + ','
                                                        +String.join(err.getFields(),',') + ','
                                                        +err.getStatusCode()+'\n';
                            }
                        }
                    runningIndex++;
                } 
            }

            List<String> emailOpsList = new List<String>();
            emailOpsList.add(SendersEmail);
            emailOpsList.add('CRM Admin 2');
            RTL_BatchEmailService.SendFinishBatchSummaryEmail(batchStartTime
                                                        , batchStartTime
                                                        , datetime.now()
                                                        , recordsSuccessful
                                                        , recordsFailed
                                                        ,String.join(colHeaderList,',')
                                                        +'ErrorMessage,ErrorOnFields,StatusCode'
                                                        , 'Import_User_Info'
                                                        , 'User'
                                                        , emailOpsList
                                                        , errorMessageForEmail);

           //result.success = true;

        }catch (Exception e) {
            //send email to admin
            System.debug(e);
            
            result.message = RTL_ReportUtility.INTERNAL_SERVER_ERROR+'\n'+e.getMessage() 
                                                + '\n'
                                                +e.getStackTraceString();
            result.success = false;
        }

        return result;                                                   
    }


}