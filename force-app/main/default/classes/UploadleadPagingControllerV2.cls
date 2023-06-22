public with sharing class UploadleadPagingControllerV2 {
    
    /***********************************************************************/
    /******instantiate the StandardSetController from a query locator*******/
    /***********************************************************************/
    List<ValidWarpper> validlogs                {get; set;}
    Public Integer noOfRecords                  {get; set;}
    public List<UploadLead> Leadafterinsert     {get; set;}
    public List<LeadLogHeader__c> loghead       {get; set;}
    public List<LeadLogHeader__c> logheadFalse  {get; set;}
    public Id logheaderId						{get; set;}
    public Boolean isValidProgress 				{get; set;}
    public Boolean isValidDone					{get; set;}
    public Boolean isImportProgress				{get; set;}
    public Boolean isImportDone					{get; set;}
    public Boolean isDisable					{get; set;}
    
    public String uploadCompleted  				{get; set;}
    public String validatemeassgeEN  			{get; set;}
    public String validatemeassgeTH  			{get; set;}
    public String validatedelete 				{get; set;}
    public String importemeassgeTH  			{get; set;}
    public String importemeassgeEN  			{get; set;}
    
    public UploadleadPagingControllerV2(){
        //Message
         uploadCompleted = status_code__c.getValues('5107').status_message__c;
         validatemeassgeEN = status_code__c.getValues('5102').status_message__c;
         validatemeassgeTH = status_code__c.getValues('5103').status_message__c;
         validatedelete = status_code__c.getValues('5106').status_message__c;
         importemeassgeEN = status_code__c.getValues('5104').status_message__c;
         importemeassgeTH = status_code__c.getValues('5105').status_message__c;
        
        isDisable = false;
        logheaderId = apexpages.currentpage().getparameters().get('id');
        try{
            if(logheaderId != null){
                LeadLogValidHeader__c  statusValidate = [Select ID,isValidProgress__c ,isValidDone__c,
                                                         isImportProgress__c,isImportDone__c
                                                         From LeadLogValidHeader__c  
                                                         where ID= :logheaderId limit 1];
                isValidProgress = statusValidate.isValidProgress__c ;
                isValidDone = statusValidate.isValidDone__c;
                isImportProgress = statusValidate.isImportProgress__c;
                isImportDone = statusValidate.isImportDone__c;
            }
            
        }catch(exception e){
            isDisable = true;
           	//ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'This section has been delete.'));                    
        }
        system.debug('isValidProgress = '+isValidProgress);
        logfiles();
    }
    
    Public Integer size {get;set;}
    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
                size = 200;
                logheaderId = apexpages.currentpage().getparameters().get('id');
                con = new ApexPages.StandardSetController(Database.getQueryLocator([Select Address__c,
                                                                LeadRecordtypeName__c,
                                                                LeadRecordtypeId__c,
                                                                leadOwnerName__c,
                                                                BranchedReferredName__c,                    
                                                                PrimaryCampaignName__c,
                                                                Groupname2__c,
                                                                IndustryName__c,                    
                                                                BranchedReferred__c,
                                                                ContactFirstname__c,
                                                                ContactLastname__c,
                                                                ContactPhoneNumber__c,
                                                                ContactPosition__c,
                                                                ContactTitle__c,
                                                                Country__c,
                                                                CreatedDate,
                                                                Created__c,
                                                                CustomerNameEN__c,
                                                                CustomerName__c,
                                                                CustomerType__c,
                                                                DecisionMap__c,
                                                                District__c,
                                                                Email__c,
                                                                Errormessage__c,
                                                                Ext__c,
                                                                Groupname__c,
                                                                Id,
                                                                IDNumber__c,
                                                                IDType__c,
                                                                Id__c,
                                                                Industry__c,
                                                                IsDeleted,
                                                                LeadLogValidHeader__c,
                                                                LeadOwnerExceptionFlag__c,
                                                                leadOwner__c,
                                                                LeadSource__c,
                                                                LinktoCustomer__c,
                                                                MobileNo__c,
                                                                Name,
                                                                NoOfyears__c,
                                                                OfficeNo__c,
                                                                OtherSource__c,
                                                                PrimaryCampaign__c,
                                                                Province__c,
                                                                Rating__c,
                                                                ReferralStaffID__c,
                                                                ReferralStaffName__c,
                                                                Remark__c,
                                                                SalesAmountperyear__c,
                                                                SubDistrict__c,
                                                                Success__c,
                                                                TotalExpectedRevenue__c,
                                                                valid__c,
                                                                ZipCode__c,
                                                                Prescreen__c,
                                                                Status__c,                    
                                                                row__c,
                                                                Warning_Flag__c
                                                         FROM LeadLogValidDetail__c
                                                         WHERE LeadLogValidHeader__c =: logheaderId order by row__c]));
                con.setPageSize(size);
                noOfRecords = Con.getResultSize();
            }
            return con;
        }
        set;
    }
    
    
    // returns a list of wrapper objects for the sObjects in the current page set
    public List<ValidWarpper> getvalidlogs() {
        validlogs = new List<ValidWarpper>();
        for (LeadLogValidDetail__c category : (List<LeadLogValidDetail__c>)con.getRecords())
            validlogs.add(new ValidWarpper(category));

        return validlogs;
    }

    // displays the selected items
     public PageReference process() {
         for (ValidWarpper cw : validlogs) {
           //  if (cw.checked)
               // ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,cw.validlogs.name));
         }
         return null;
     }

    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }
    
    
    public Integer pageSize{
        get {
            return con.getPageSize();
        }
        set;
    }
    

    // returns the first page of records
     public void first() {
         con.first();
     }

     // returns the last page of records
     public void last() {
         con.last();
     }

     // returns the previous page of records
     public void previous() {
         con.previous();
     }

     // returns the next page of records
     public void next() {
         con.next();
     }

     // returns the PageReference of the original page, if known, or the home page.
     public void cancel() {
         con.cancel();
     }
    
    
    
    
    
    
    
    
    
    
  

    
    
    /****************************************************************************
    **************Delete files from trigger LeadvalidateHead object**************
    ****************************************************************************/
    Public static void delLogfromtrigger(list<LeadLogValidHeader__c> listlogdelete) {
        List<id> dellead = new List<id>();
        
        for(LeadLogValidHeader__c DelLeadLog : listlogdelete) 
        {
            if(DelLeadLog.delete__c == true)
            {
                dellead.add(DelLeadLog.Id);
            }
        }
        
        if(dellead.size() > 0)
        {
            Database.Delete(dellead);
        }
    }
    
    
    /****************************************************************************
    **************Delete files from trigger LeadlogHeader object*****************
    ****************************************************************************/
    Public static void delLogHeaderfromtrigger(list<LeadLogHeader__c > listlogheaddelete) {
        List<id> delleadlog = new List<id>();
        
        for(LeadLogHeader__c DelLogHeader : listlogheaddelete) 
        {
            if(DelLogHeader.Isdelete__c == true)
            {
                delleadlog.add(DelLogHeader.Id);
            }
        }
        
        if(delleadlog.size() > 0)
        {
            Database.Delete(delleadlog);
        }
    }
    
    
    
    
    /****************************************************************************
    **********************************Log files**********************************
    ****************************************************************************/
    
    Public void  logfiles()
    {
        set<id> headset = new set<id>();
        set<id> logfalseset = new set<id>();
        set<id> logtrueset = new set<id>();
        loghead = new List<LeadLogHeader__c>();
        logheadFalse = new List<LeadLogHeader__c>();
        //loghead = [Select Id,OwnerID,name,Createddate,Row__c from LeadLogHeader__c where OwnerID =: UserInfo.getUserId() order by Createddate desc];
        List<LeadLogHeader__c> temphead = [Select Id,OwnerID,name,Createddate,Row__c   
                                           from LeadLogHeader__c 
                                           where OwnerID =: UserInfo.getUserId() order by Createddate desc];
        for(LeadLogHeader__c sh : temphead) {
            headset.add(sh.Id);
        }
        
        List<LeadLogDetail__c> templogFalse = [Select id,parrent__c,name,Lead_Valid__c 
                                               from LeadLogDetail__c where parrent__c IN: headset and Lead_Valid__c =: True];
        if(templogFalse.size() > 0) {
            for(LeadLogDetail__c sf : templogFalse) {
                logfalseset.add(sf.parrent__c);
            }
        }
        
        /*List<LeadLogDetail__c> templogTrue = [Select id,parrent__c,name,Lead_Valid__c from LeadLogDetail__c where parrent__c IN: headset and Lead_Valid__c =: False];
        if(templogTrue.size() > 0) {
            for(LeadLogDetail__c sf : templogTrue) {
                logtrueset.add(sf.parrent__c);
            }
        }*/
        
        
		loghead = [Select Id,OwnerID,name,Createddate,Row__c,Total_Success__c,Total_Fail__c,Total_Import_Records__c,Total_Invalid__c   
        from LeadLogHeader__c where OwnerID =: UserInfo.getUserId() order by Createddate desc];       
        if(loghead.size() > 0)
        {
            Integer newrow = 1;
            for(LeadLogHeader__c listrow : loghead)
            {
                listrow.Row__c = newrow;
                newrow++;
            }
        }
        
        logheadFalse = [Select Id,OwnerID,name,Createddate,Row__c,Total_Success__c,Total_Fail__c,Total_Import_Records__c,Total_Invalid__c 
                        from LeadLogHeader__c where OwnerID =: UserInfo.getUserId() 
                        and Id IN:logfalseset order by Createddate desc];       
        if(logheadFalse.size() > 0)
        {
            Integer newrow = 1;
            for(LeadLogHeader__c listrow : logheadFalse)
            {
                listrow.Row__c = newrow;
                newrow++;
            }
        }
        system.debug('headset = '+headset);
        system.debug('templogFalse = '+templogFalse);
    }
    
    
    /***************************************************************************
    *****************************Insert fields Batch****************************
    ****************************************************************************/
    public PageReference insertLead()
    {
        
        isValidProgress = false;
        isValidDone = true;
        isImportProgress = true;
        isImportDone = false;
        //Status Validattion run batch
        try {
        LeadLogValidHeader__c  statusValidate = [Select ID,isValidProgress__c ,isValidDone__c,isImportProgress__c,isImportDone__c  From LeadLogValidHeader__c  where ID= :logheaderId limit 1];
        if(statusValidate != null){
            statusValidate.isValidProgress__c  = isValidProgress;
            statusValidate.isValidDone__c = isValidDone;
            statusValidate.isImportProgress__c = isImportProgress;
            statusValidate.isImportDone__c = isImportDone;
        	update statusValidate;
        }
        Set<ID> setLeadLogValidDetailIDs = new Set<ID>(); 
        List<LeadLogValidDetail__c> tempLogValidDetail = [Select ID
                                                         FROM LeadLogValidDetail__c
                                                         WHERE LeadLogValidHeader__c = :logheaderId order by row__c];
        for(LeadLogValidDetail__c item: tempLogValidDetail){
            setLeadLogValidDetailIDs.add(item.ID);
        }
        UploadLeadImportBatchV2 batch = new UploadLeadImportBatchV2( setLeadLogValidDetailIDs,logheaderId);  
        Database.executeBatch(batch ,100); 
        
        
        return null;
        } catch(exception e) {
           PageReference redirectPage = Page.Uploadleadvalid;
           redirectPage.setRedirect(true);
           redirectPage.getParameters().put('id',logheaderId);
           return redirectPage;
        }
    }
    
    
    /****************************************************************************
    *****************************Validation Batch********************************
    ****************************************************************************/
    public PageReference Validatebatch() {
        isValidProgress = true;
        isValidDone = false;
        isImportProgress = false;
        isImportDone = false;
        LeadLogValidHeader__c  statusValidate = [Select ID,isValidProgress__c ,isValidDone__c,isImportProgress__c,isImportDone__c  From LeadLogValidHeader__c  where ID= :logheaderId limit 1];
        if(statusValidate != null){
            statusValidate.isValidProgress__c  = isValidProgress;
            statusValidate.isValidDone__c = isValidDone;
            statusValidate.isImportProgress__c = isImportProgress;
            statusValidate.isImportDone__c = isImportDone;
        	update statusValidate;  
        }
        Set<ID> setLeadLogValidDetailIDs = new Set<ID>();
        //ID LeadLogHeaderID = new ID();
        List<LeadLogValidDetail__c> tempLogValidDetail = [Select ID
                                                         FROM LeadLogValidDetail__c
                                                         WHERE LeadLogValidHeader__c = :logheaderId order by row__c];
        for(LeadLogValidDetail__c item: tempLogValidDetail){
            setLeadLogValidDetailIDs.add(item.ID);
        }
        UploadLeadValidationBatchV2 batch = new UploadLeadValidationBatchV2( setLeadLogValidDetailIDs,logheaderId);  
        Database.executeBatch(batch ,100); 
        
        //Status Validattion run batch
        
        return null;
    }
    
}