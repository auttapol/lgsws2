global class AccountPlanCloneBatch implements Database.Batchable<sObject> ,Database.AllowsCallouts{ 
    
    public String m_CompanyID {get;set;}
    public String m_Year {get;set;}
    public String m_AccountID {get;set;}
    
    global AccountPlanCloneBatch (String CompanyID,String Year){
        m_CompanyID =  CompanyID;
        m_Year = Year;
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){  
        //Get Account Company Profile Lists
        return Database.getQueryLocator([SELECT ID,AccountName__c,Account__c,AcctPlanGroup__c,Name,AcctPlanGroup__r.Name,LastModifiedDate,
                                         Year__c,Status__c,OwnerID,Owner.Name,LastModifiedByID,LastModifiedBy.name
                                         FROM AcctPlanCompanyProfile__c
                                         WHERE  Id = : m_CompanyID 
                                        ]);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<AcctPlanCompanyProfile__c> scope){
        // Logic to be Executed batch wise 
        if(scope.size() > 0){
            AcctPlanCompanyProfile__c companyProfileOriginal = scope.get(0);
           //m_AccountID = companyProfileOriginal.Account__c;
            AccountPlanCloneUtils.AccountPlanClone(companyProfileOriginal.id,m_Year);
        }
        
    }
    
    // Finish 
    global void finish(Database.BatchableContext BC){
        String mainUrl;
        List<AcctPlanCompanyProfile__c> newAccountPlanList = [SELECT ID,Account__c,CloneSourceId__c
                                                         FROM AcctPlanCompanyProfile__c
                                                         WHERE  CloneSourceId__c = : m_CompanyID 
                                                         AND Year__c = : m_Year];
        AcctPlanCompanyProfile__c newAccountPlan = new AcctPlanCompanyProfile__c();                                                 
        if(newAccountPlanList.size() >0){
            newAccountPlan = newAccountPlanList.get(0);
            m_AccountID = newAccountPlan.Account__c;
            mainUrl =  'https://' +  System.URL.getSalesforceBaseUrl().getHost() + '/'+'apex/CompanyProfileView?CompanyID='+newAccountPlan.id;
        }else{
            AcctPlanCompanyProfile__c oldCompanyProfile = [SELECT ID,AccountName__c,Account__c FROM AcctPlanCompanyProfile__c WHERE ID =: m_CompanyID];
            m_AccountID = oldCompanyProfile.Account__c;
            mainUrl =  'https://' +  System.URL.getSalesforceBaseUrl().getHost() + '/'+'apex/CompanyProfileView?CompanyID='+m_CompanyID;
        }                                                
           
        String subject = 'Run Batch Account Plan Clone';
        String htmlMsg =  subject
            +'<br />Please click below url to view New Account Paln has been Clone'
            +'<br />View <a href="'+mainUrl+'"> click here</a>';
        
        AsyncApexJob a =  [SELECT a.Id, a.TotalJobItems, a.Status, a.NumberOfErrors, a.JobType, a.JobItemsProcessed, 
                           a.ExtendedStatus, a.CreatedById, a.CompletedDate, a.CreatedBy.Email, a.ParentJobId,
                           a.CreatedDate, a.LastProcessed, a.LastProcessedOffset, a.MethodName, a.ApexClassId
                           FROM AsyncApexJob a 
                           WHERE Id = :BC.getJobId()];
        if(a.NumberOfErrors <=0){
            subject = subject+' : '+a.Status;
        }else{
            subject = subject+' : Incomplete';
        }
            system.debug('m_AccountID='+m_AccountID);
            List<AcctPlanGroupWalletLock__c> lock  = [SELECT Id,Account__c,AccountPlanLockClone__c   
                                                FROM AcctPlanGroupWalletLock__c 
                                                Where Account__c =: m_AccountID];
            system.debug('lock='+lock.size());
            if(lock.size() > 0){                        
                delete lock;
            }   

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject(subject);
            mail.setHtmlBody(htmlMsg);
            Messaging.sendEmail(new Messaging.SingleEmailMessage [] {mail});


    }
}