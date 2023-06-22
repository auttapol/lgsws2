public with sharing class SLOSEmailServiceImpl implements SLOSEmailService.ISLOSEmailService {
    public SLOSEmailServiceImpl() {
    }  
    public void emailHostProductMappingNeedProductId(List<Host_Product_Mapping__c> hsprds) {
        if(hsprds.size() > 0){
            list<string> sendTo = getCRMAdminEmails();
            if (sendTo.size() > 0) {
                try{                  
                    System.debug(':::> sendTo.size() > 0');
                    // Step 0: Create a master list to hold the emails we'll send
                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                    // Step 1: Create a new Email
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    // Step 2: Set send to
                    mail.setToAddresses(sendTo);
                    mail.setSenderDisplayName('Salesforce SLOS System');
                    // Step 3. Set email contents - you can use variables!
                    mail.setSubject(SLOSEmailTitle());
                    string body = SLOSEmailBody(hsprds);
                    mail.setHtmlBody(body);
                    // Step 4. Add your email to the master list
                    mails.add(mail);
                    // Step 5: Send all emails in the master list
                    Messaging.sendEmail(mails);
                }catch(Exception emailEx){
                    
                }
            }
        }
    }
    public string SLOSEmailBody(List<Host_Product_Mapping__c> hsprds) {
        string template = getHtmlEmailTemplate('SLOS Host Product Mapping Email');
        string  productsHtmlTable = ' <table border="1" cellpadding="0" cellspacing="0" width="100%" id="emailHeader">';
        productsHtmlTable += '  <tr>                                                                            ';
        productsHtmlTable += '      <th>#</th>                                                                  ';
        productsHtmlTable += '      <th>Host Product Code</th>                                                  ';
        productsHtmlTable += '      <th>Host Product Group</th>                                                 ';
        productsHtmlTable += '      <th>Host Product Program</th>                                               ';
        productsHtmlTable += '      <th>Host Credit Facility</th>                                               ';
        productsHtmlTable += '  </tr>                                                                           ';        
        for(Host_Product_Mapping__c hsprd : hsprds){
            
            productsHtmlTable += '  <tr>                                                                            ';
            productsHtmlTable += '      <td><a href="'+ UrlHelper.protocolAndHost+'/'+ hsprd.id +'/e">Edit</a></td>   ';
            productsHtmlTable += '      <td>'+hsprd.Host_Product_Code__c+'</td>                                     ';
            productsHtmlTable += '      <td>'+hsprd.Host_Product_Group__c+'</td>                                    ';
            productsHtmlTable += '      <td>'+hsprd.Product_Program__c+'</td>                                       ';
            productsHtmlTable += '      <td>'+hsprd.Host_Prod_Name_Credit_Facility__c+'</td>                        ';
            productsHtmlTable += '  </tr>                                                                           ';
            
        }        
        productsHtmlTable += ' </table> ';        
        template = template.replace('{{Products}}', productsHtmlTable);     
        return template;
    }
    public string SLOSEmailTitle() {
        string title = '';       
        AppConfig__c appEmail = AppConfig__c.getValues('SLOS Host Product Mapping Email Title');
        if(null != appEmail){
            title = appEmail.Value__c;
        }
        else{
            title = 'Salesforce Notification : There has been a product from Host which cannot be mapped to Salesforce product';
        }  
        return title;
    }
    public  List<string> getCRMAdminEmails()    {
        
        List<string> emails  = new List<string>();
        AppConfig__c appEmail = AppConfig__c.getValues('SLOS CRM');
        if (null != appEmail) {
            emails.addAll(appEmail.Value__c.split(';'));
        }
        System.debug(':::> emails');
        return emails;
    }    
    public  string  getHtmlEmailTemplate(string templateName){        
        string htmlTemplate = '';        
        AppConfig__c appEmail = AppConfig__c.getValues(templateName);
        if(null != appEmail){
            htmlTemplate = appEmail.Value__c;
        }
        else{
            htmlTemplate = 'Dear CRM Admin, <br /><br />There has been a product from Host which cannot be mapped to Salesforce product. <br /><br /><Products /><br /><br />Please kindly investigate and update the information on Host Product Mapping object.<br /><br />Thanks,<br />';
        }  
        return htmlTemplate;
    }   
    
    public void emailAfterStageChange(List<Opportunity> ListOpty){
    
        list<Messaging.SingleEmailMessage> ListEmail = new list<Messaging.SingleEmailMessage>();
        
        list<contact> cTemp = new list<contact>();
        if (listOpty.get(0).accountid != null){
            cTemp = [select id from contact where accountid =: listOpty.get(0).accountid limit 1];
        }
        
        if (cTemp.size() == 0) // migrate contact first time
        {
            cTemp = [select id,email from contact where createddate < 2015-03-26T19:35:00.000+0000 limit 1];
        }
        if (cTemp.size() == 0) // recordtype core bank
        {
            cTemp = [select id,email from contact where recordtypeid ='01290000001AhOWAA0' limit 1];
        }
        if (cTemp.size() == 0) // recordtype commercial (salesforce)
        {
            cTemp = [select id,email from contact where recordtypeid = '01290000001AhOXAA0' limit 1];
        }
        if (cTemp.size() == 0) // org dev
        {
            cTemp = [select id,email from contact limit 1];
        }
    
        string EmailId = '';
        
        if (mapEmailTemplate.get('SLS:Opportunity Stage Change') != null){
            EmailId = mapEmailTemplate.get('SLS:Opportunity Stage Change').ID;
        }
        
        if (EmailId != ''){    
            for (opportunity o : ListOpty)
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
                mail.setToAddresses(new string[]{o.Owner.Email});
                //mail.setSubject('Email Update Opty Complete');
                //string bodyDes = '';
                //mail.setHtmlBody(bodyDes);  
                
                //email template must have setTargetObjectID
                mail.setTargetObjectId(cTemp.get(0).ID);
                mail.setTreatTargetObjectAsRecipient(false);
                
                mail.setTemplateID(EmailId);
                mail.setWhatId(o.ID);
                mail.setSenderDisplayName('SLS - Salesforce');
                mail.setSaveAsActivity(false);
                
                ListEmail.add(mail);
            }
        }

        try {
            Messaging.sendEmail(ListEmail);
        }catch(exception ex){
            system.debug(ex.getMessage());
        }
        
    }
    
    public map<string,EmailTemplate> mapEmailTemplate {
       get{
         map<string,EmailTemplate> retDat = new map<string,EmailTemplate>();
         for(EmailTemplate e : [select id,name from EmailTemplate])
         {
             retDat.put(e.name,e);
         }
         return retDat;
       } set;
    }
    
    public void emailOppStageMappingNotFound(list<opportunity> listOpp)
    {
        if (listOpp.size() > 0){
                list<string> sendTo = getCRMAdminEmails();
            if (sendTo.size() > 0) {
                try {
                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>(); 
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    //mail.setToAddresses(new string[]{'tnp@ii.co.th'});
                    mail.setToAddresses(sendTo);
                    mail.setSenderDisplayName('Salesforce SLOS System');  
                    mail.setSubject(' Opportunity Stage Mapping Not Found ');
                    string body = '';
                    for (opportunity o: listOpp)
                    {
                        body += ' Opportunity Stage Mapping Not Found <br/><br/>';
                        body += ' <b>Opportunity ID</b> : ' + o.id + '<br/>';
                        body += ' <b>Opportunity Name</b> : ' + o.name + '<br/>';
                        body += ' <b>Host System</b> : ' + ((o.Host_System__c == null) ? '' : o.Host_System__c ) + '<br/>';
                        body += ' <b>Opp/App Status</b> : ' + ((o.Application_Status__c == null) ? '' : o.Application_Status__c) + '<br/>';
                        body += ' <b>Host Result</b> : ' + ((o.Host_Result__c == null) ? '' : o.Host_Result__c) + '<br/><br/>';
                    }
                    mail.setHtmlBody(body);
                    mails.add(mail);
                    Messaging.sendEmail(mails);
                } catch(Exception ex){
                    system.debug(ex.getLineNumber() + ' - ' + ex.getMessage());
                } 
            }    
        }
    }
    
}