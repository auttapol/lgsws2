public class PopUpSearchController {
    @AuraEnabled
    public static String popUpSearchInCase(String recordId) 
    {
        try
        {
            Case caseObj = [SELECT Id,ContactEmail,Origin,AccountId,Contact_Person_Email__c FROM Case WHERE Id =: recordId];
  
            String searchText;
            if(caseObj.Contact_Person_Email__c == null)
            {
                searchText = caseObj.ContactEmail;
            }
            else {
                searchText = caseObj.Contact_Person_Email__c;
            }
            
            List<List <sObject>> results =  search.query('find \'' + searchText + '*\' in all fields returning Contact(Id,AccountId)');    
            List<String> idList = new List<String>();

            for (List<SObject> sobjs : results) {
                for (SObject sobj : sobjs) {
                    idList.add(sobj.Id);
                }
            }
            System.debug('ids:'+idList);

            if(idList.size() == 1)
            {
                return 'Match';                     
            }
            else if(idList.size() > 1)
            {
                return caseObj.Id;
            }
            else {
                return null;
            }
            
        }
        catch(Exception e)
        {
            System.debug('Error:'+e);
            return null;
        }
    }

    @AuraEnabled
    public static String popUpSearchInChat(String recordId) 
    {
        try
        {
            LiveChatTranscript liveChat = [SELECT Id, Name, CaseId,ContactId,First_Name__c,Last_Name__c,Mobile_No__c,Email__c FROM LiveChatTranscript Where Id =: recordId];

            if(liveChat.ContactId == null)
            {
                String searchText = liveChat.Mobile_No__c + ' AND ' + liveChat.Email__c; //liveChat.Contact.Email + ' AND ' + liveChat.Contact.MobilePhone + ' AND ' + liveChat.Contact.FirstName + ' AND ' + liveChat.Contact.LastName ;

                List<List <sObject>> results =  search.query('find \'' + searchText + '*\' in all fields returning Contact(Id,AccountId)');    

                List<String> idList = new List<String>();

                for (List<SObject> sobjs : results) {
                    for (SObject sobj : sobjs) {
                        idList.add(sobj.Id);
                    }
                }

                if(idList.size() == 1)
                {
					LiveChatTranscript lc = new LiveChatTranscript(Id=liveChat.Id);
                    lc.ContactId = idList[0];
                    update lc;

                    Case caseObj = new Case(Id=liveChat.CaseId);
                    caseObj.ContactId = idList[0];
                    update caseObj;
                    return 'Match';                     
                }
                else if(idList.size() > 1)
                {
                    return liveChat.Id;                     
                }
                else 
                {
                    return null;
                }
            }
            else 
            {
                return 'Match'; 
            }
            
        }
        catch(Exception e)
        {
            System.debug('Error:'+e);
            return null;
        }
    }
}