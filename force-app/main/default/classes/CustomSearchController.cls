public class CustomSearchController {
    
    public class SObjectResult {
        @AuraEnabled
        public String objName;
        @AuraEnabled
        public String objLabel;
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public List<Account> soList;
        
        public SObJectResult(String objNameTemp, List<Account> soLisTemp,String objLabelTemp,String fieldNameTemp) {
            objName = objNameTemp;
            soList = soLisTemp;
            objLabel = objLabelTemp;
            fieldName = fieldNameTemp;
        }
    }
    
    @AuraEnabled
    public static List<SObjectResult> searchContactFromEmail(String recordId) {
        
        try
        {
            Case caseObj = [SELECT Id,ContactEmail,Contact_Person_Email__c,Origin FROM Case WHERE Id =: recordId];
            String searchText;
            if(caseObj.Contact_Person_Email__c == null)
            {
                searchText = caseObj.ContactEmail;
            }
            else {
                searchText = caseObj.Contact_Person_Email__c;
            }

            Set<String> obNameSet = new Set<String>();
            obNameSet.add('account');
            
            List<List <sObject>> sobList =  search.query('find \'' + searchText + '*\' in all fields returning Contact(Id,AccountId)');

            List<Contact> contactList = new List<Contact>();
            sObject[] records = ((List<sObject>)sobList[0]);

            if (!records.isEmpty()) 
            {
                for (Integer i = 0; i < records.size(); i++) 
                {

                    //sObject record = records[i];
                    if (records[i].getSObjectType() == Contact.sObjectType) 
                    {
                        contactList.add((Contact) records[i]);
                    } 
                }
            }  
            
            List<String> accIdList = new List<String>();
            if(contactList.size() > 0)
            {
                for(Contact ct : contactList)
                {
                    if(ct.AccountId != null)
                    {
                        accIdList.add(ct.AccountId);
                    }               
                }
            }
            List<Account> accList = [SELECT Id,Name,Customer_Name_PE_Eng__c,TMB_Customer_ID_PE__c,ID_Type_PE__c,NID__c,Customer_Owner__c FROM Account WHERE Id IN: accIdList];
            List<SObjectResult> SObjectResultList = new List<SObjectResult>();
            SObjectResultList.add( new SObjectResult( 'Account', accList, 'Customer', 'Name'));

            return SObjectResultList;
        }
        catch (Exception e) 
        {
            System.debug('Error:'+e);
            return null;
        }
    }
    
    @AuraEnabled
    public static List<SObjectResult> searchContactFromChat(String recordId) {
        
        try
        {
            LiveChatTranscript liveChat = [SELECT Id, Name, ContactId,First_Name__c,Last_Name__c,Mobile_No__c,Email__c  FROM LiveChatTranscript Where Id =: recordId];
            
            String searchText = liveChat.Mobile_No__c + ' AND ' + liveChat.Email__c; //liveChat.Contact.Email + ' AND ' + liveChat.Contact.MobilePhone + ' AND ' + liveChat.Contact.FirstName + ' AND ' + liveChat.Contact.LastName ;
            
            Set<String> obNameSet = new Set<String>();
            obNameSet.add('account');
            
            List<List <sObject>> sobList =  search.query('find \'' + searchText + '*\' in all fields returning Contact(Id,AccountId)');    

            List<Contact> contactList = new List<Contact>();
            sObject[] records = ((List<sObject>)sobList[0]);

            if (!records.isEmpty()) 
            {
                for (Integer i = 0; i < records.size(); i++) 
                {
                    if (records[i].getSObjectType() == Contact.sObjectType) 
                    {
                        contactList.add((Contact) records[i]);
                    } 
                }
            }  
            
            List<String> accIdList = new List<String>();
            if(contactList.size() > 0)
            {
                for(Contact ct : contactList)
                {
                    if(ct.AccountId != null)
                    {
                        accIdList.add(ct.AccountId);
                    }
                }
            }
            List<Account> accList = [SELECT Id,Name,Customer_Name_PE_Eng__c,TMB_Customer_ID_PE__c,ID_Type_PE__c,NID__c,Customer_Owner__c FROM Account WHERE Id IN: accIdList];
            List<SObjectResult> SObjectResultList = new List<SObjectResult>();
            SObjectResultList.add( new SObjectResult( 'Account', accList, 'Customer', 'Name'));

            return SObjectResultList;
        }
        catch (Exception e) 
        {
            System.debug('Error:'+e);
            return null;
        }
    }
    
    @AuraEnabled
    public static Case getCase(String recordId)
    {
        try 
        {      
            Case caseObj = [SELECT Id,ContactEmail,Origin,AccountId,Contact_Person_Email__c FROM Case WHERE Id =: recordId];

            return caseObj;
            
        } 
        catch (Exception e) 
        {
            System.debug('Error:'+e);
            return null;
        }
        
    }
    
    @AuraEnabled
    public static String getContactFromTranscript(String recordId)
    {
        try 
        {
            LiveChatTranscript liveChat = [SELECT Id, Name, ContactId,First_Name__c,Last_Name__c,Mobile_No__c,Email__c  FROM LiveChatTranscript Where Id =: recordId];

            String searchText = liveChat.Mobile_No__c + ' AND ' + liveChat.Email__c;
            
            List<List <sObject>> sobList =  search.query('find \'' + searchText + '*\' in all fields returning Contact(Id,AccountId)');    

            return liveChat.Mobile_No__c;
            
        }
        catch (Exception e) 
        {
            System.debug('Error:'+e);
            return null;
        }
    }
    
}