public class DuplicateAccountController {

    public lead leadObj {get;set;}

    public List<Account> accounts {get;set;}
    public Account Newacct {get;set;}

    public List<Account> acctsID {get;set;}
    public List<Account> acctsMobile {get;set;}

    public Id accId {get;set;}
    public Boolean showErrorMessagePage {get; set;}
    public Boolean showSelectAccountDup {get; set;}

    public Boolean isConvertSuccess {get; set;}

    public Id recId = null;

    //Telephony Outbound
    public Account existingCustomer {get;set;}

    //*****************CONVERT FROM LEAD DETAIL PAGE CONSTRUCTOR****************
    public DuplicateAccountController(ApexPages.StandardController controller){
        recId = ApexPages.currentPage().getParameters().get('id');
        showErrorMessagePage = false;
        showSelectAccountDup = false;
        isConvertSuccess = false;

        try {

            leadObj = [SELECT Name, RTL_ID_Type__c, RTL_Citizen_Id__c, RTL_Mobile_Number__c, IsConverted, Customer__c
                        FROM lead 
                        WHERE id =: recId LIMIT 1];

            // //Telephony Outbound Check for existing customer
            if(leadObj.Customer__c != null)
            {
                existingCustomer = [SELECT Id, Name, Mobile_Number_PE__c, ID_Number_PE__c, ID_Type_PE__c FROM Account WHERE Id =: leadObj.Customer__c LIMIT 1];
                if(leadObj.RTL_ID_Type__c == null)
                {
                    leadObj.RTL_ID_Type__c = existingCustomer.ID_Type_PE__c;
                }
                if(leadObj.RTL_Citizen_Id__c == null)
                {
                    leadObj.RTL_Citizen_Id__c = existingCustomer.ID_Number_PE__c;
                }
                if(leadObj.RTL_Mobile_Number__c == null)
                {
                    leadObj.RTL_Mobile_Number__c = existingCustomer.Mobile_Number_PE__c;
                }
            }
            else 
            {                   
                String NID = splitIDtoNID(leadObj.RTL_Citizen_Id__c);

                Map<ID, Account> AccIdMap = new Map<ID, Account>([SELECT Id, name, TMB_Customer_ID_PE__c, ID_Number_PE__c, ID_Type_PE__c, Mobile_Number_PE__c, NID__c, Core_Banking_Suggested_Segment__c, owner.name 
                            FROM account
                            WHERE RTL_NID__c  =: NID]);


                acctsID = AccIdMap.values();

                for(Account acc : acctsID){
                    if(acc.ID_Type_PE__c != leadObj.RTL_ID_Type__c || acc.ID_Number_PE__c != leadObj.RTL_Citizen_Id__c){
                        AccIdMap.remove(acc.Id);
                    }
                }

                acctsID = AccIdMap.values();

                accounts = new List<Account>(); 
                accounts.addAll(acctsID);

                if(leadObj.RTL_ID_Type__c == 'Other ID'){
                    List<List<sObject>> searchList = [FIND :leadObj.RTL_Mobile_Number__c IN ALL FIELDS RETURNING Account(Id, name, TMB_Customer_ID_PE__c, ID_Number_PE__c, ID_Type_PE__c, Mobile_Number_PE__c, NID__c, Core_Banking_Suggested_Segment__c, owner.name)];
                    acctsMobile = (List<Account>)searchList[0];
                    
                    for (Account acc : acctsMobile) {
                        // if(AccIdMap.get(acc.Id) == null && acc.ID_Type_PE__c == leadObj.RTL_ID_Type__c){
                        if(AccIdMap.get(acc.Id) == null){
                            accounts.add(acc);
                        }
                    }
                }
            }
            System.debug('accounts controller: ' + accounts);
        } catch (Exception e) {
            System.debug(e.getmessage());    
        }
    }

    //*****************CONVERT FROM EDIT CAMPAING MEMBER PAGE CONSTRUCTOR TO GET DUPLICATE ACCOUNT****************
    public DuplicateAccountController(Id recId){
        try {        
            leadObj = [SELECT Name, RTL_ID_Type__c, RTL_Citizen_Id__c, RTL_Mobile_Number__c, IsConverted
                        FROM lead 
                        WHERE id =: recId LIMIT 1];

            String NID = splitIDtoNID(leadObj.RTL_Citizen_Id__c);

            Map<ID, Account> AccIdMap = new Map<ID, Account>([SELECT Id, name, TMB_Customer_ID_PE__c, ID_Number_PE__c, ID_Type_PE__c, Mobile_Number_PE__c, NID__c, Core_Banking_Suggested_Segment__c, owner.name 
                        FROM account
                        WHERE RTL_NID__c  =: NID]);


            acctsID = AccIdMap.values();

            for(Account acc : acctsID){
                if(acc.ID_Type_PE__c != leadObj.RTL_ID_Type__c || acc.ID_Number_PE__c != leadObj.RTL_Citizen_Id__c){
                    AccIdMap.remove(acc.Id);
                }
            }

            // AccIdMap = new Map<ID, Account>([SELECT Id, name, TMB_Customer_ID_PE__c, ID_Number_PE__c, ID_Type_PE__c, Mobile_Number_PE__c, NID__c, Core_Banking_Suggested_Segment__c, owner.name 
            //             FROM account
            //             LIMIT 100]);

            acctsID = AccIdMap.values();

            accounts = new List<Account>(); 
            accounts.addAll(acctsID);

            if(leadObj.RTL_ID_Type__c == 'Other ID'){
                List<List<sObject>> searchList = [FIND :leadObj.RTL_Mobile_Number__c IN ALL FIELDS RETURNING Account(Id, name, TMB_Customer_ID_PE__c, ID_Number_PE__c, ID_Type_PE__c, Mobile_Number_PE__c, NID__c, Core_Banking_Suggested_Segment__c, owner.name)];
                acctsMobile = (List<Account>)searchList[0];
                
                for (Account acc : acctsMobile) {
                    if(AccIdMap.get(acc.Id) == null){
                        accounts.add(acc);
                    }
                }
            }
            System.debug('accounts recId: ' + accounts);
        } catch (Exception e) {
            System.debug(e.getmessage());
        }
    }

    public DuplicateAccountController(String IdNumber, String IdType, String MobileNum){
        try {
         
            // Check for existing customer Telephony Outbound
            if(leadObj != null)
            {
                if(leadObj.Customer__c != null)
                {
                    existingCustomer = [SELECT Id, Name, Mobile_Number_PE__c, ID_Number_PE__c, ID_Type_PE__c FROM Account WHERE Id =: leadObj.Customer__c LIMIT 1];
                }
            }      

            String NID = splitIDtoNID(IdNumber);

            Map<ID, Account> AccIdMap = new Map<ID, Account>([SELECT Id, name, TMB_Customer_ID_PE__c, ID_Number_PE__c, ID_Type_PE__c, Mobile_Number_PE__c, NID__c, Core_Banking_Suggested_Segment__c, owner.name 
                        FROM account
                        WHERE RTL_NID__c  =: NID]);


            acctsID = AccIdMap.values();

            for(Account acc : acctsID){
                if(acc.ID_Type_PE__c != IdType || acc.ID_Number_PE__c != IdNumber){
                    AccIdMap.remove(acc.Id);
                }
            }

            // AccIdMap = new Map<ID, Account>([SELECT Id, name, TMB_Customer_ID_PE__c, ID_Number_PE__c, ID_Type_PE__c, Mobile_Number_PE__c, NID__c, Core_Banking_Suggested_Segment__c, owner.name 
            //             FROM account
            //             LIMIT 100]);

            acctsID = AccIdMap.values();

            accounts = new List<Account>(); 
            accounts.addAll(acctsID);

            if(IdType == 'Other ID'){
                List<List<sObject>> searchList = [FIND :MobileNum IN ALL FIELDS RETURNING Account(Id, name, TMB_Customer_ID_PE__c, ID_Number_PE__c, ID_Type_PE__c, Mobile_Number_PE__c, NID__c, Core_Banking_Suggested_Segment__c, owner.name)];
                acctsMobile = (List<Account>)searchList[0];
                
                for (Account acc : acctsMobile) {
                    if(AccIdMap.get(acc.Id) == null){
                        accounts.add(acc);
                    }
                }
            }
            
            System.debug('accounts recId: ' + accounts);
            
        } catch (Exception e) {
            System.debug(e.getmessage());
        }
    }

    //*************CHECK FOR CONVERT LEAD IF HAVE NO ACCOUNT DUPLICATE*************
    public PageReference checkDupAccToRedirect(){
        System.debug('Check convert Lead Step (Lead Detail no duplicate account) : Lead => '+ leadObj.Id);
        PageReference pg;

        // Check for existing customer
        if(existingCustomer != null)
        {        
            MergeConvertLeadDetail();
        }
        else 
        {            
            if(accounts.size() <= 0){
                return ConvertLead();
            }else{
                showSelectAccountDup = true;
            }
        }
        return pg;
    }

    public PageReference ConvertLead(){
        Savepoint sp = Database.setSavepoint();
        System.debug('CONVERT LEAD');
        try{ 
            if( leadObj.Id != null && !leadObj.IsConverted ){
                System.debug('Convert Lead Step : Lead => '+ leadObj.Id);
                
                // FOR SKIP CHECK UP CONVERT LEAD
                leadObj.RTL_Allow_Convert_Lead__c = true;
                leadObj.Status = 'Qualified';

                update leadObj;


                LeadStatus convertStatus = [SELECT Id, MasterLabel 
                FROM LeadStatus WHERE IsConverted=true and Masterlabel = 'Closed Converted' LIMIT 1];

                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(leadObj.id);
                lc.setDoNotCreateOpportunity(false);  
                lc.setConvertedStatus(convertStatus.MasterLabel);
                Database.LeadConvertResult lcr;
                lcr = Database.convertLead(lc);
                accId = lcr.getAccountId();
                System.debug('Convert Lead finish : Account => '+ accId);
                isConvertSuccess = true;
                System.debug('CONVERT LEAD DONE');

            }                    
        }catch( Exception e ){
            Database.rollback(sp);
            System.debug('CRM : '+ e.getMessage());
            showErrorMessagePage = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() ));
            return null;
        }
        return null;
    }

    public void MergeConvertLeadDetail(){
        Id conId;
        Id accountId = existingCustomer.Id;
        // PageReference pg = new PageReference('/' + accId);
        // pg.setRedirect(true);
        Savepoint sp = Database.setSavepoint();

        try{ 
            if( leadObj.Id != null && !leadObj.IsConverted ){
                System.debug('Convert Lead Step (MERGE ACCOUNT LEAD DETAIL PAGE) : Lead => '+ leadObj.Id);              
                // FOR SKIP CHECK UP CONVERT LEAD
                leadObj.RTL_Allow_Convert_Lead__c = true;
                leadObj.Status = 'Qualified';

                update leadObj;

                //GET CONTACT
				List<Contact> ExistingConList = [SELECT Id,FirstName,LastName,AccountID
											FROM Contact WHERE AccountID =: accountId
											];
				for(contact existingCon : ExistingConList){
					conId = existingCon.Id;
				}

                //GET convertStatus
                LeadStatus convertStatus = [SELECT Id, MasterLabel 
                FROM LeadStatus WHERE IsConverted=true and Masterlabel = 'Closed Converted' LIMIT 1];

                Database.LeadConvert lc = new database.LeadConvert();
                
                //CONVERT LEAD SETTING ARGC
                lc.setDoNotCreateOpportunity(false);
                lc.setLeadId(leadObj.id);
				lc.setAccountId(accountId);
				lc.setContactId(conId);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                
                //CONVERT STEP
                Database.LeadConvertResult lcr;
                lcr = Database.convertLead(lc);
                accId = lcr.getAccountId();
                System.debug('Convert Lead finish : Account => '+ accId);
                isConvertSuccess = true;
                System.debug('CONVERT LEAD DONE');

            }              
        }catch( Exception e ){
            Database.rollback(sp);
            System.debug('CRM : '+ e.getMessage());
            showErrorMessagePage = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() ));
            //return null;
        }
        //return null;
    }      

    //*****BACK BUTTON FOR ERROR MESSAGE PAGE*****
    public PageReference backToLeadDetailPage(){
        PageReference pg = new PageReference('/' + leadObj.id);
        return pg;
    }

    private String splitIDtoNID(String idNumber){
        String nid;
        if (idNumber != null && idNumber.length() > 0) {
            nid = (idNumber.length() <= 5) ?  idNumber: idNumber.substring(0,1)+idNumber.substring(idNumber.length()-4); 
        }
        return nid;
    }
    
}