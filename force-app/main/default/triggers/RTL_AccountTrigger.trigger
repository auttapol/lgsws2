/*
     Create By : Yao Jun
     Email : jyao@salesforce.com
     Create Date : 2016-08-11 
     
     This trigger is used to create/update Retail Contact for the batch interfaces of Update New/Existing Customers.
*/

trigger RTL_AccountTrigger on Account (before insert,before update,after insert, after update) {
    
    Integer MAX_FIRSTNAME_LENGTH = 22;
        
    System.debug('START RTL ACCOUNT TRIGGER');
    if(AppConfig__c.getValues('runtrigger').Value__c == 'true') {
        Id acctRT = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        Id contactRT = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Retail Contact').getRecordTypeId();
        //Id accountExistingCustomerRT = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();
        List<Account> newRetailCust = new List<Account>();
        List<Contact> uContacts = new List<Contact>{};
        List<Contact> nContacts = new List<Contact>{};
        Map<Id,Account> uAccounts = new Map<Id,Account>{};
        Map<Id,Account> newAccountMap = new Map<Id,Account>{};
        //Map<Id,Account> AccountMapBefore = new Map<Id,Account>{};

        //FOR INC0062208_Found_Some_Retail_Customer_Dont_have_TMB_ID 16/10/2018
        Map<Id,Account> uAccMap = new Map<Id,Account>();
        //FOR INC0062208_Found_Some_Retail_Customer_Dont_have_TMB_ID 16/10/2018
		
        //INC0082992 
        Map<Id,Account> updatedAccountMap = new Map<Id,Account>();
        //Map<Id,Contact> mapContactsforUpdatedAccount = new Map<Id,Contact>();
        //List<Contact> listContactsforUpdatedAccount = new List<Contact>{};
            
        //INC0089679 
        Map<Id,Contact> mapContactIsNotHaveTMBCustId = new Map<Id,Contact>();
        Map<Id,Contact> mapRetailContact = new Map<Id,Contact>();
        List<Contact> listUpdateContact = new List<Contact>();
        List<Contact> insertRetailContact = new List<Contact>();
        Set<Id> setAssignBRCUser = new Set<Id>();
        Set<Id> setBranchZoneId = new Set<Id>();
        for(Account acc : trigger.new) {
            setAssignBRCUser.add(acc.RTL_Assigned_BRC__c);
            setBranchZoneId.add(acc.RTL_Most_Operating_Branch__c);
        }
        if(setAssignBRCUser.size() > 0 && RTL_AccountUtility.mapUserById == null) {
            RTL_AccountUtility.generateUserMapId(setAssignBRCUser);
        }

        if(setBranchZoneId.size() > 0 && RTL_AccountUtility.mapBranchZoneById == null) {
            RTL_AccountUtility.generateBranchZoneMapId(setBranchZoneId);
        }
              
        for(Account acct : trigger.new) {
            // Only process Retail Customer
            if(acct.RecordTypeId == acctRT) {
                if(trigger.isBefore && trigger.isInsert){
                    //  .add(acct);
                    if(acct.RTL_RM_Name__c != null){
                        acct.RTL_Wealth_RM__c = RTL_AccountUtility.getWealth_RM(acct);
                    }
                    if(acct.OwnerId != null){
                        acct.RTL_Commercial_RM__c = AccountUtility.getCommercial_RM(acct.OwnerId);
                    }
                    
                }else if(trigger.isBefore && trigger.isUpdate){
                    newRetailCust.add(acct);
                    
                    Account nAcct = trigger.newMap.get(acct.Id);
                    Account oAcct = trigger.oldMap.get(acct.Id);
                    boolean rmUpdated = (nAcct.RTL_RM_Name__c != oAcct.RTL_RM_Name__c) || (nAcct.RTL_Assigned_BRC__c != oAcct.RTL_Assigned_BRC__c) || (nAcct.RTL_Most_Operating_Branch__c != oAcct.RTL_Most_Operating_Branch__c);
                    if(rmUpdated){
                        acct.RTL_Wealth_RM__c = RTL_AccountUtility.getWealth_RM(acct);
                    }

                    boolean isUpdateOwner = nAcct.OwnerId != oAcct.OwnerId;
                    if(isUpdateOwner){
                        acct.RTL_Commercial_RM__c = AccountUtility.getCommercial_RM(acct.OwnerId);
                    }

                    // [2020-05-28] update RTL_BRC_Updated_Date__c once RTL_Assigned_BRC__c got update.
                    // System.debug('acct.RTL_Assigned_BRC__c: ' + acct.RTL_Assigned_BRC__c);
                    // System.debug('oAcct.RTL_Assigned_BRC__c: ' + oAcct.RTL_Assigned_BRC__c);
                    if(acct.RTL_Assigned_BRC__c != oAcct.RTL_Assigned_BRC__c){
                        acct.RTL_BRC_Updated_Date__c = System.today();
                    }

                }
                if(trigger.isAfter && trigger.isInsert) {
               
                    Contact contact = new Contact();
                    contact.AccountId = acct.Id;
                    contact.Account__c = acct.Id;
                    contact.RecordTypeId = contactRT;
                    contact.TMB_Customer_ID__c = acct.TMB_Customer_ID_PE__c; 
                    
					contact = RTL_AccountUtility.fillerFirstAndLastName(acct, contact);

                    //contact.LastName = (acct.Last_name_PE__c != null? acct.Last_name_PE__c : acct.First_name_PE__c);
                    nContacts.add(contact);
                    
                    newRetailCust.add(acct);
                }
                else if(trigger.isAfter && trigger.IsUpdate) {
                    Account nAcct = trigger.newMap.get(acct.Id);
                    Account oAcct = trigger.oldMap.get(acct.Id);
                      
                    // INC0082992 
                    updatedAccountMap.put(acct.id,nAcct);                
                    
                    boolean updateContact = nAcct.Email_Address_PE__c != oAcct.Email_Address_PE__c || nAcct.First_name_PE__c != oAcct.First_name_PE__c || nAcct.Last_name_PE__c != oAcct.Last_name_PE__c || nAcct.Mobile_Number_PE__c != oAcct.Mobile_Number_PE__c;
                    if(updateContact) {
                        uAccounts.put(nAcct.Id, nAcct);
                    }

                    //FOR INC0062208_Found_Some_Retail_Customer_Dont_have_TMB_ID 16/10/2018
                    boolean updateContactTMBID = nAcct.TMB_Customer_ID_PE__c != oAcct.TMB_Customer_ID_PE__c;

                    if (updateContactTMBID) uAccMap.put(nAcct.Id,nAcct);
                    //FOR INC0062208_Found_Some_Retail_Customer_Dont_have_TMB_ID 16/10/2018
                }
            }
            
            if(trigger.isAfter && trigger.isUpdate){
                Account nAcct = trigger.newMap.get(acct.Id);
                Account oAcct = trigger.oldMap.get(acct.Id);
                boolean rmUpdated = nAcct.RTL_RM_Name__c != oAcct.RTL_RM_Name__c;
                if(rmUpdated){
                    newAccountMap.put(acct.id,nAcct);
                }
            }
            
        }  // end for
                
        //Update Household RM Manager 
        if(newAccountMap.size() > 0){            
            new RTL_HouseholdRelationshipManager().updateHouseholdRM(newAccountMap);
            
            
        }
        
        if(nContacts.size() > 0)
            insert nContacts;       
        
        //FOR INC0062208_Found_Some_Retail_Customer_Dont_have_TMB_ID 16/10/2018
        if(uAccounts.size() > 0){
            uContacts = [select Id, AccountId, Email, MobilePhone, LastName
                        , FirstName,TMB_Customer_ID__c
                         from Contact 
                         where 
                         RecordType.DeveloperName = 'Retail_Contact'
                         AND AccountId in :uAccounts.keySet()];

            for(Contact contact: uContacts) {
                Account account = uAccounts.get(contact.AccountId);
                //Account oAcct = trigger.oldMap.get(account.Id);
                contact = RTL_AccountUtility.fillerFirstAndLastName(account, contact);
            }

            update uContacts;
        }
        
        //INC0082992 
        if( updatedAccountMap.size() > 0 )
        {     
            //INC0089679 
            List<Contact> contactList = [select Id, AccountId, TMB_Customer_ID__c,RecordType.DeveloperName
                                           from Contact 
                                           where AccountId in :updatedAccountMap.keySet()];
            if(contactList.size() > 0 )
            {
                for(Contact ct : contactList)
                {                   
                    if(ct.RecordType.DeveloperName == 'Retail_Contact')   
                    {
                        mapRetailContact.put(ct.AccountId,ct);
                    }
                    else
                    {
                        if(ct.TMB_Customer_ID__c == null)
                        {
                            mapContactIsNotHaveTMBCustId.put(ct.AccountId,ct);
                        }
                    }
                }   
            }
            
            for(Account acc : updatedAccountMap.values())
            {	
                //INC0141099
                if((!mapContactIsNotHaveTMBCustId.containsKey(acc.Id)) && (!mapRetailContact.containsKey(acc.Id))){
                    
                    Contact contact = new Contact();
                    contact.AccountId = acc.Id;
                    contact.Account__c = acc.Id;
                    contact.RecordTypeId = contactRT;
                    contact.TMB_Customer_ID__c = acc.TMB_Customer_ID_PE__c; 
                    
                    contact = RTL_AccountUtility.fillerFirstAndLastName(acc, contact);
                    insertRetailContact.add(contact);
                }
                else if(mapContactIsNotHaveTMBCustId.containsKey(acc.Id))
                {                 
                    // check this account have retail contact
                    if(mapRetailContact.containsKey(acc.Id))
                    {                       
                        Contact contact = new Contact(Id = mapRetailContact.get(acc.Id).Id);
                        contact.TMB_Customer_ID__c = acc.TMB_Customer_ID_PE__c;  
                        listUpdateContact.add(contact);
                     
                    }
                    else
                    {
                        Contact contact = new Contact();
                        contact.AccountId = acc.Id;
                        contact.Account__c = acc.Id;
                        contact.RecordTypeId = contactRT;
                        contact.TMB_Customer_ID__c = acc.TMB_Customer_ID_PE__c; 
                        
                        contact = RTL_AccountUtility.fillerFirstAndLastName(acc, contact);
                        insertRetailContact.add(contact);
                    }                                     
                } 
            } 
 
              
            /*List<Contact> retailContactList = [select Id, AccountId, TMB_Customer_ID__c
                                           from Contact 
                                           where 
                                           RecordType.DeveloperName = 'Retail_Contact'
                                           AND AccountId in :updatedAccountMap.keySet()];             
              
            if (retailContactList.size() > 0 )
            {
                for(Contact ct : retailContactList)
                {
                    mapContactsforUpdatedAccount.put(ct.AccountId,ct);
                }             
            }

            for(Account acc : updatedAccountMap.values())
            {
                if(!mapContactsforUpdatedAccount.containsKey( acc.Id ) )
                {
                    Contact contact = new Contact();
                    contact.AccountId = acc.Id;
                    contact.Account__c = acc.Id;
                    contact.RecordTypeId = contactRT;
                    contact.TMB_Customer_ID__c = acc.TMB_Customer_ID_PE__c; 
                    
                    contact = RTL_AccountUtility.fillerFirstAndLastName(acc, contact);
                    listContactsforUpdatedAccount.add(contact);
                }
            } */                         
        }
        //Update Retail Contact
        if (listUpdateContact.size() > 0 )
        {
            Database.SaveResult[]  lsr = Database.update(listUpdateContact, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) 
            {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors   
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(err.getMessage());
                    }
                }
            }
        }
        //Insert Retail Contact
        if(insertRetailContact.size() > 0)
        {
            Database.SaveResult[]  lsr = Database.Insert(insertRetailContact, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) 
            {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors   
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(err.getMessage());
                    }
                }
            }
        }
        //------------------------------------

        if (uAccMap.size() > 0) {
            List<Contact> contactTMBID = [select Id
                                            ,TMB_Customer_ID__c
                                            ,AccountId
                                            from Contact 
                                            where 
                                            RecordType.DeveloperName = 'Retail_Contact'
                                            AND AccountId in :uAccMap.keySet()];

            if (contactTMBID != null && contactTMBID.size() > 0 ){
                for(Contact contact: contactTMBID) {
                    contact.TMB_Customer_ID__c = uAccMap.get(contact.AccountId).TMB_Customer_ID_PE__c;
                }

                Database.SaveResult[]  lsr = Database.update(contactTMBID, false);
                // Iterate through each returned result
                for (Database.SaveResult sr : lsr) {
                    if (!sr.isSuccess()) {
                        // Operation failed, so get all errors   
                        for(Database.Error err : sr.getErrors()) {
                            System.debug(err.getMessage());
                        }
                    }
                }
            }
        }
        //FOR INC0062208_Found_Some_Retail_Customer_Dont_have_TMB_ID 16/10/2018
        
        if(newRetailCust.size() > 0){
            RTL_DataQualityCheck dataQualityCheck = new RTL_DataQualityCheck();
            dataQualityCheck.start(newRetailCust);
        }
           
    }
    //---------------------
}