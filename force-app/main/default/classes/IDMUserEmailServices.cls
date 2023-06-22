public class IDMUserEmailServices {
    //1. create email to new user follow email template
    //2. create email to user movement follow email template
    //3. create email to ITG,CRM,Oper with attach csv
    public map<string,EmailTemplate> mapEmailTemplate {
       get{
         if (mapEmailTemplate == null){
             map<string,EmailTemplate> retDat = new map<string,EmailTemplate>();
             for(EmailTemplate e : [select id,name from EmailTemplate])
             {
                 retDat.put(e.name,e);
             }
             return retDat;
         }else{
             return mapEmailTemplate;
         }
       } set;
    }
    
    public void sendMailToUser(List<String> ListID, String typeEmail)
    {
        // Chatcharin N. Mod 2017/08/11 Start
        //List<String> listOfID = new List<String>();
        //String strSOQL = 'select ID, Email from User where ID in ' + listOfId + 'and IsActive = true';
        SubSendEmailBatch subEmail = new SubSendEmailBatch(ListID,typeEmail);
        Database.executeBatch(subEmail, 200);
        /*
        String EmailTemplateID = mapEmailTemplate.get(typeEmail).ID;
        List<ID> ListUserID = new List<ID>();
        List<Messaging.SingleEmailMessage> ListEmail = new List<Messaging.SingleEmailMessage>();
        try {
            for (User u : [select ID, Email from User where ID in: ListID and IsActive = true])
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[]{u.Email});   
                //mail.setToAddresses(new String[]{'napaporn.pic@tmbbank.com','wrc@ii.co.th'});  
                //mail.setToAddresses(new String[]{'tmbtest1@mailinator.com'});  
                mail.setTargetObjectId(u.ID); 
                mail.setTemplateID(EmailTemplateID);
                //mail.setHtmlBody(getEmailContent(u.ID, typeEmail));
                
                mail.setSenderDisplayName('HCM - Salesforce');
                mail.setSaveAsActivity(false);
                
                ListEmail.add(mail);
            }
            Messaging.sendEmail(ListEmail);
        }catch(exception ex){
            system.debug('Line : '+ex.getLineNumber()+' , Error : '+ex.getMessage());
        }
        */
        // End
    }
    
    public void sendMailResult()
    {
        list<string> listMail = new list<string>();
        listMail.addAll(ListMailFromAppConfig('HCM_CRM'));
        listMail.addAll(ListMailFromAppConfig('Operation Team A'));
        listMail.addAll(ListMailFromAppConfig('Operation Team App monitoring'));
        listMail.addAll(ListMailFromAppConfig('Operation Team B'));
        listMail.addAll(ListMailFromAppConfig('Operation Team C'));
        listMail.addAll(ListMailFromAppConfig('Operation Team D'));
        
        BatchHistory__c bh = [select id,Records_Processed__c,Records_Failed__c,Records_Successed__c 
                              from BatchHistory__c where Batch_Type__c = 'HCM' and createddate = TODAY].get(0);
        
        Messaging.EmailFileAttachment successFile = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(getResultContent(bh.id,'Success'));
        string csvname= 'Success.csv';
        successFile.setFileName(csvname);
        successFile.setBody(csvBlob);
      
        Messaging.EmailFileAttachment failFile = new Messaging.EmailFileAttachment();
        csvBlob = Blob.valueOf(getResultContent(bh.id,'Fail'));
        csvname= 'Fail.csv';
        failFile.setFileName(csvname);
        failFile.setBody(csvBlob);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // send mail to listmail
        //mail.setToAddresses(new String[]{'wrc@ii.co.th'}); 
        mail.setToAddresses(listMail);
        mail.setSubject('IDM User Batch was run completely');
        String bodyDes = 'Description : Batch IDMUserBatch was run completely<br/><br/>';
        String bodyAsof = 'Batch as of : '+String.valueOf(System.today().format()+'<br/><br/>');
        String bodyResult = '*Total Record : '+bh.Records_Processed__c+'<br/><br/>*Total Success : '+bh.Records_Successed__c+'<br/><br/>*Total Fail : '+bh.Records_Failed__c+'<br/><br/>';
        String bodyFooter = '<p style="color:#ff0000;"><strong>อีเมลล์นี้ถูกส่งโดยอัตโนมัติจากระบบ โปรดอย่าตอบกลับ</strong></p><br/><p style="color:#ff0000;"><strong>This is an automatically generated email. Please do not reply.</strong></p><br/>';
        String bodyFooter2 = 'The information contained in this e-mail may be confidential, proprietary and/or legally privileged. If you are not the<br/>intended recipient of this e-mail, please delete and destroy all copies immediately.&nbsp; Any review, dissemination, copy,<br/>retransmission, distribution or use of this e-mail in any form for any purpose is strictly prohibited. The sender accepts no<br/>responsibility for any miss transmission of, or interference with, this e-mail.<br/>';
        mail.setHtmlBody(bodyDes + bodyAsof + bodyResult + bodyFooter + bodyFooter2);  
        mail.setSenderDisplayName('HCM - Salesforce');
        mail.setSaveAsActivity(false);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{successFile, failFile});

        //Savepoint sp = Database.setSavepoint();
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
    }
    
    public list<string> ListMailFromAppConfig(string s)
    {
        if (appConfig__c.getValues(s) != null)
            return appConfig__c.getValues(s).value__c.replace(' ','').split(';');
        else
            return new list<string>();
    }
    
    public string getResultContent(string BatchID, string type)
    {
        string retDat = 'Profile,SFID,EmployeeID,Name,ManageID,Status,Description\n';
        
        for(BatchHistoryDetail__c b :[select message__c from BatchHistoryDetail__c where Batch_History__c =: BatchID and status__c =: type])
        {
            retDat += b.message__c +'\n';
            //system.debug(retDat);  
        }
      
        return retDat;
    }
    

    
}