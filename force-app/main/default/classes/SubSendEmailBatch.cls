global class SubSendEmailBatch implements Database.Batchable<sObject>,Database.Stateful{
	
    global String query;
    global String dataEmail;
    List<String> listOfId = new List<String>();
    
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
    
    global SubSendEmailBatch (List<String> strSOQL,String typeEmail){
        //query = strSOQL;
        listOfId = strSOQL;
        dataEmail = typeEmail;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<User> testList = [select ID, Email from User where ID in :listOfId and IsActive = true];
        system.debug(listOfId);
        return Database.getQueryLocator([select ID, Email from User where ID in :listOfId and IsActive = true]);
    }
    
    global void execute(Database.BatchableContext BC, List<User> scope) {
        String EmailTemplateID = mapEmailTemplate.get(dataEmail).ID;
        List<Messaging.SingleEmailMessage> ListEmail = new List<Messaging.SingleEmailMessage>();
        try {
            for (User u : scope)
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[]{u.Email});   
                mail.setTargetObjectId(u.ID); 
                mail.setTemplateID(EmailTemplateID);
                mail.setSenderDisplayName('HCM - Salesforce');
                mail.setSaveAsActivity(false);
                
                ListEmail.add(mail);
            }
            Messaging.sendEmail(ListEmail);
        }catch(exception ex){
            system.debug('Line : '+ex.getLineNumber()+' , Error : '+ex.getMessage());
        } 
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}