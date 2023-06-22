public with sharing class UploadDNCByUser  implements Messaging.InboundEmailHandler {
     public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                       Messaging.InboundEnvelope env){
        
     	Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();


     	try {
            Messaging.InboundEmail.BinaryAttachment[] bAttachments = email.BinaryAttachments;
            List<String> emailOpsList = new List<String>();
            emailOpsList.add(env.fromAddress);
            emailOpsList.add('CRM Admin 2');

            EmailServiceUtil emailQueue = new EmailServiceUtil('CXM_BulkUpload_Do_Not_Contact'
                                                              ,'MK_CODE_EXT_KEY__c'
                                                              ,EmailServiceUtil.UPSERT_OPERATION
                                                              ,emailOpsList
                                                              ,env.fromAddress
                                                              ,env.toAddress
                                                              ,true
                                                              ,'Customer__r.TMB_Customer_ID_PE__c'
                                                              ,'CXM_BulkUpload_DNC_By_CUST_ID'
                                                              );

            Map<String,String> ret = emailQueue.validateAndProcess(bAttachments);

            if (ret.get(emailQueue.IS_SUCCESS) == 'false') {
                result.message = ret.get(emailQueue.MESSAGE);
                result.success = false;
                return result;
            }

            result.message = ret.get(emailQueue.MESSAGE);
            result.success = true;
     	}catch(Exception e){
     		result.message = RTL_ReportUtility.INTERNAL_SERVER_ERROR+'\n'+e.getMessage() 
                                                + '\n'
                                                +e.getStackTraceString();
            result.success = false;
     	}

        return result;                                                  
     }


}