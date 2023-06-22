public with sharing class UploadInvestmentModelEmail implements Messaging.InboundEmailHandler {

    public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env){
          Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        try {
            /*
            String SendersEmail = env.fromAddress;

            //get Attachment
            Messaging.InboundEmail.BinaryAttachment[] bAttachments = email.BinaryAttachments;
            String jobName = 'Fulfillment_Upload';

             if (bAttachments == null || bAttachments.size() != 1) {
                result.message = RTL_ReportUtility.INVALID_ATTACHMENT_NUMBERS;
                result.success = false;
                return result;
            }

            Messaging.InboundEmail.BinaryAttachment btt = bAttachments.get(0);
            */

            // Delete current Investment Model Data first.
            if(!Test.isRunningTest()){
                List<Invesment_Model__c> InvMoList = [Select Id From Invesment_Model__c];
                try {
                    if (InvMoList.size() > 0){
                        delete InvMoList;
                    }
                } catch (DmlException e) {
                    result.message = RTL_ReportUtility.INTERNAL_SERVER_ERROR+'\n'+e.getMessage()
                                                    + '\n'
                                                    +e.getStackTraceString();
                    result.success = false;
                }
            }

            Messaging.InboundEmail.BinaryAttachment[] bAttachments = email.BinaryAttachments;
            List<String> emailOpsList = new List<String>();
            emailOpsList.add(env.fromAddress);
            emailOpsList.add('CRM Admin 2');

            EmailServiceUtil emailQueue = new EmailServiceUtil('InvestmentModel_Upload'
                                                                ,'Invesment_Model__c'
                                                                ,EmailServiceUtil.INSERT_OPERATION
                                                                ,emailOpsList
                                                                ,env.fromAddress
                                                                ,env.toAddress
                                                                ,false
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