public with sharing class UploadRetailTaskEmail implements Messaging.InboundEmailHandler {

    
   public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env){ 
   	   Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

   	   try {
   	   		Messaging.InboundEmail.BinaryAttachment[] bAttachments = email.BinaryAttachments;
   	   		List<String> emailOpsList = new List<String>();
            emailOpsList.add(env.fromAddress);
            emailOpsList.add('CRM Admin 2');

            EmailServiceUtil emailQueue = new EmailServiceUtil('Upload_Retail_Task'
                                                              ,'LogACall_External_Id_crmdb__c'
                                                              ,EmailServiceUtil.UPSERT_OPERATION
                                                              ,emailOpsList
                                                              ,env.fromAddress
                                                              ,env.toAddress
                                                              ,true
                                                              ,10000
                                                              );

            Map<String,String> ret = emailQueue.validateAndProcess(bAttachments);

            if (ret.get(emailQueue.IS_SUCCESS) == 'false') {
                result.message = ret.get(emailQueue.MESSAGE);
                result.success = false;
                return result;
            }

            result.message = ret.get(emailQueue.MESSAGE);
            result.success = true;


   	   }catch(Exception e) {
   	   		result.message = RTL_ReportUtility.INTERNAL_SERVER_ERROR+'\n'+e.getMessage() 
                                                + '\n'
                                                +e.getStackTraceString();
            result.success = false;
   	   }

       return result;
   }

}