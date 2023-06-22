public class EmailMessageTriggerHandler {
    
    public static List<EmailSuppressionRule__c>  emailRuleList{
        get{
            if(emailRuleList == null){
                emailRuleList = [SELECT Id, Name, Active__c, Email_Suppression_Rule__c, Formula__c, Priority__c, Severity__c, Type__c,Text_Massage__c FROM EmailSuppressionRule__c Where Active__c = true];            	
            }
            return emailRuleList;
        }
        set;
    }
    
    public static void handleBeforeInsert(List<EmailMessage> inputNew) {
        
    }
    
    public static void handleAfterInsert(List<EmailMessage> inputNew){
        new Email2CaseCreateCase(inputNew);
        
        validateEmailSuppression(inputNew);
    }
    
    public static void handleBeforeUpdate(Map<Id,EmailMessage> oldMap,Map<Id,EmailMessage> newMap)
    {
        
    }
    
    public static void handleAfterUpdate(Map<Id,EmailMessage> oldMap,Map<Id,EmailMessage> newMap)
    {
        validateEmailSuppression(newMap.Values());
    }
    
    public static void validateEmailSuppression(List<EmailMessage> emList)
    {
        String errorText = '';
        Set<Id> emailId = new Set<Id>();

        for(EmailMessage em : emList)
        {
            emailId.add(em.Id);
        }
        List<ContentDocumentLink> cotentDocLinkList = [SELECT Id, LinkedEntityId, LinkedEntity.Name, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: emailId];
        
        Map<Id,ContentDocumentLink> docLinkMap = new Map<Id,ContentDocumentLink>();
        Set<Id> docLinkId = new Set<Id>();
        for(ContentDocumentLink docLink : cotentDocLinkList)
        {
            docLinkId.add(docLink.ContentDocumentId);
            docLinkMap.put(docLink.ContentDocumentId,docLink);
        }
        List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId, ContentBodyId, VersionNumber, Title, Description, OwnerId, FileType, VersionData, ContentSize, FileExtension, IsEncrypted 
                                                   FROM ContentVersion Where ContentDocumentId IN:docLinkId];
        system.debug('contentVersionList:'+contentVersionList);
        
        List<Email_Suppression_Log_Event__e> emailLogList = new List<Email_Suppression_Log_Event__e >();

        Map<String,String> textMessageMap = new Map<String,String>();
        
        for(EmailMessage em : emList)
        {
            System.debug('em:'+em);
            
            if(!em.Incoming)
            {
                String textbody = '';
                String[] textbodyNew = new String[] { };
                    
                    if(em.TextBody != null)
                {
                    if(em.TextBody.length()>0)
                    {
                        
                        textbody = em.TextBody.replaceall('\n',' ');
                        if(textbody.contains('--------------- ข้อความต้นฉบับ ---------------') || textbody.contains('--------------- Original Message ---------------'))
                        {
                            if(textbody.contains('--------------- ข้อความต้นฉบับ ---------------'))
                            {
                                textbodyNew = textbody.split('--------------- ข้อความต้นฉบับ ---------------');
                            }
                            if(textbody.contains('--------------- Original Message ---------------'))
                            {
                                textbodyNew = textbody.split('--------------- Original Message ---------------');
                            }
                            
                            if(textbodyNew[0].contains('--------------- ข้อความต้นฉบับ ---------------') || textbodyNew[0].contains('--------------- Original Message ---------------'))
                            {
                                if(textbodyNew[0].contains('--------------- ข้อความต้นฉบับ ---------------'))
                                {
                                    textbodyNew[0] = textbody.split('--------------- ข้อความต้นฉบับ ---------------')[0];
                                }
                                if(textbodyNew[0].contains('--------------- Original Message ---------------'))
                                {
                                    textbodyNew[0] = textbody.split('--------------- Original Message ---------------')[0];
                                }
                            }
                            
                            
                        }
                        else
                        {
                            textbodyNew.add(textbody); 
                        }                 
                        
                        //System.debug('textbody:'+ textbodyNew[0]);
                    }
                }
                
                Map<String,EmailSuppressionRule__c> patternMap = new  Map<String,EmailSuppressionRule__c>();
                List<Pattern> patternList = new List<Pattern>();
                
                for(EmailSuppressionRule__c emRule : emailRuleList)
                {
                    patternList.add(Pattern.compile(emRule.Formula__c));
                    patternMap.put(Pattern.compile(emRule.Formula__c).ToString(),emRule);
                }
                for(Pattern pt : patternList)
                {
                    //System.debug('Match:'+pt.matcher(textbodyNew[0]).matches());
                    if(pt.matcher(textbodyNew[0]).matches())
                    {
                        if(em.Status == '3')
                        {
                            if(patternMap.containsKey(pt.ToString()))
                            {
                                Email_Suppression_Log_Event__e  emailLog = new Email_Suppression_Log_Event__e ();
                                emailLog.Agent__c  = UserInfo.getUserId();
                                emailLog.Case__c = em.ParentId;
                                emailLog.Email_Suppression_Rule__c = patternMap.get(pt.ToString()).Email_Suppression_Rule__c;
                                emailLog.Severity__c = patternMap.get(pt.ToString()).Severity__c;
                                emailLog.Type__c = patternMap.get(pt.ToString()).Type__c;
                                emailLogList.add(emailLog);
                            }
                        }
                    }
                    if(em.HasAttachment)
                    {   
                        for(ContentVersion ct : contentVersionList)
                        {
                            //System.debug('FileType:'+ct.FileExtension);
                            if(pt.matcher(ct.FileExtension).matches()) // zip rar exe
                            {    
                                if(em.Status == '3')
                                {
                                    if(patternMap.containsKey(pt.ToString()))
                                    {
                                        Email_Suppression_Log_Event__e  emailLog = new Email_Suppression_Log_Event__e ();
                                        emailLog.Agent__c  = UserInfo.getUserId();
                                        emailLog.Case__c = em.ParentId;
                                        emailLog.Email_Suppression_Rule__c = patternMap.get(pt.ToString()).Email_Suppression_Rule__c;
                                        emailLog.Severity__c = patternMap.get(pt.ToString()).Severity__c;
                                        emailLog.Type__c = patternMap.get(pt.ToString()).Type__c;
                                        emailLogList.add(emailLog);
                                    }
                                }
                            }
                        }
                    }
                    
                    // Error Handler
                    if(pt.matcher(textbodyNew[0]).matches())
                    {     
                        if(patternMap.containsKey(pt.ToString()))
                        {       
                            if(patternMap.containsKey(pt.ToString()))
                            {
                                if(patternMap.get(pt.ToString()).Severity__c == 'Block')
                                {
                                    if(!textMessageMap.containsKey(pt.ToString()))
                                    {
                                        if(errorText == '')
                                        {
                                            errorText += patternMap.get(pt.ToString()).Text_Massage__c;                    
                                        }
                                        else
                                        {
                                            errorText += ' , ' + patternMap.get(pt.ToString()).Text_Massage__c;
                                        }
                                        textMessageMap.put(pt.ToString(),patternMap.get(pt.ToString()).Text_Massage__c);
                                        em.TextBody.addError(errorText);
                                    }
                                }     
                            }                                    
                        }
                    }
                    if(em.HasAttachment)
                    {                                            
                        for(ContentVersion ct : contentVersionList)
                        {
                            //System.debug('Type:'+ct.FileExtension);
                            //System.debug('Match:'+pt.matcher(ct.FileExtension).matches());
                            if(pt.matcher(ct.FileExtension).matches()) // zip rar exe
                            {    
                                if(patternMap.containsKey(pt.ToString()))
                                {
                                    if(patternMap.get(pt.ToString()).Severity__c == 'Block')
                                    {
                                        if(!textMessageMap.containsKey(pt.ToString()))
                                        {
                                            if(errorText == '')
                                            {
                                                errorText += patternMap.get(pt.ToString()).Text_Massage__c;                    
                                            }
                                            else
                                            {
                                                errorText += ' , ' + patternMap.get(pt.ToString()).Text_Massage__c;
                                            }
                                            textMessageMap.put(pt.ToString(),patternMap.get(pt.ToString()).Text_Massage__c);  
                                            em.TextBody.addError(errorText);  
                                        }                                  
                                    }  
                                }
                            } 
                        }                                    
                    }
                }           
            }
        }
        //System.debug('errorText:'+errorText);
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(emailLogList);
        
        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage());
                }
            }       
        }
    }
     
}