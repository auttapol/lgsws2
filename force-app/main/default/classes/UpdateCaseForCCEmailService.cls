public with sharing class UpdateCaseForCCEmailService implements Messaging.InboundEmailHandler {

   private String query;
   private Map<String,Map<String,String>> CASEMAP;

   private Integer recordsSuccessful = 0;
   private Integer recordsFailed = 0;
   private Datetime batchStartTime = datetime.now();
   private List<String> COLLST;
   private List<String> FIELDEXCLDE;
   private String SENDEREMAIL;
   private String errorMessageForEmail = '';

   public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env){ 
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

            RTL_Utility.UploadDataEmail uploadDataEmail
                    = RTL_Utility.getDataForUploadEmail('Upload_Case',btt.body.toString());

            if (uploadDataEmail.result) {
                
                Map<String,List<Map<String,String>>> valListMap = uploadDataEmail.dataMap;

                for (String key : valListMap.keyset() ) {
                        List<Map<String,String>> scopeLst = (List<Map<String,String>>)valListMap.get(key);

                        String qry = 'SELECT '+String.join(uploadDataEmail.colHeaderList,',')+ ' FROM CASE Where Id in (';
                        Map<String,Map<String,String>> caseMap = new Map<String,Map<String,String>>();
                        
                        for (Map<String,String> caseObj : scopeLst) {

                            for (String keyCase : caseObj.keySet()) {
                                if (keyCase.endsWithIgnoreCase('casenumber')) {
                                    caseObj.remove(keyCase);
                                }else if (keyCase.endsWithIgnoreCase('id')) {
                                    String caseId = caseObj.get(keyCase);
                                    caseMap.put('\''+caseId+'\'',caseObj);
                                }
                            }                                           
                        }

                        qry += String.join(new List<String>(caseMap.keySet()),',')+')';

                        List<String> sendToEmailList = new List<String>();
                        sendToEmailList.add(SendersEmail);
                        sendToEmailList.add('CRM Admin 2');

                        Map<String,List<String>> fieldValidate = uploadDataEmail.fieldValidateMap;

                        DailyScheduleBatch updateCaseCCBatch = new DailyScheduleBatch(qry
                                                            ,DailyScheduleBatch.UPDATE_CASE_BY_CONTACT_CENTER
                                                            ,'Case'
                                                            ,caseMap
                                                            ,uploadDataEmail.colHeaderList
                                                            ,sendToEmailList
                                                            ,fieldValidate
                                                            );

                        //Id queryExpiredOppBatchId = Database.ExecuteBatch(updateCaseCCBatch);
                        updateCaseCCBatch.executeQuery();
                        updateCaseCCBatch.finish(null);

                        totalRecord += scopeLst.size();
                }

                result.message = 'Upload Successfully! \n'
                                    +'Your File '
                                    +btt.filename+' has been processing with total '
                                    + totalRecord+ ' Records';

                result.success = true;
            }else {
                result.message = uploadDataEmail.description;
                result.success = uploadDataEmail.result;
                return result;
            }

        }catch (Exception e) {
            //send email to admin
            result.message = RTL_ReportUtility.INTERNAL_SERVER_ERROR+'\n'+e.getMessage() 
                                                + '\n'
                                                +e.getStackTraceString();
            result.success = false;
        }
        return result;  
   }

}