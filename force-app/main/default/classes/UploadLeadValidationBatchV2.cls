/********************************************
 * Bacth for validation when upload lead
 ********************************************/
global class UploadLeadValidationBatchV2 implements Database.Batchable<sObject> ,Database.AllowsCallouts{    
 
    public Set<Id> m_leadLogValidDetailID    {get;set;}
    public String m_LeadLogHeaderID   {get;set;}
    
    global UploadLeadValidationBatchV2 (Set<Id> leadLogValidDetailID,String LeadLogHeaderID){
        
        m_leadLogValidDetailID =  leadLogValidDetailID ;
        m_LeadLogHeaderID = LeadLogHeaderID;
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){  
        //Get Account to Process
        Set<Id> LeadLogValidDetailIDs = m_leadLogValidDetailID ;
        return Database.getQueryLocator([
            SELECT Address__c,BranchedReferredName__c,BranchedReferred__c,ContactFirstname__c,
            ContactLastname__c,ContactPhoneNumber__c,ContactPosition__c,ContactTitle__c,
            Country__c,CreatedById,CreatedDate,Created__c,CustomerNameEN__c,CustomerName__c,
            CustomerType__c,DecisionMap__c,District__c,Email__c,Errormessage__c,Error__c,Ext__c,
            filename__c,Groupname2__c,Groupname__c,Id,IDNumber__c,IDType__c,Id__c,IndustryName__c,
            Industry__c,IsDeleted,LastModifiedById,LastModifiedDate,LeadLogValidHeader__c,LeadOwnerExceptionFlag__c,
            leadOwnerName__c,leadOwner__c,LeadRecordtypeId__c,LeadRecordtypeName__c,LeadSource__c,
            LinktoCustomerName__c,LinktoCustomer__c,MobileNo__c,Name,NoOfyears__c,OfficeNo__c,OtherSource__c,
            PrimaryCampaignName__c,PrimaryCampaign__c,Province__c,Rating__c,ReferralStaffID__c,ReferralStaffName__c,
            Remark__c,Row__c,SalesAmountperyear__c,SubDistrict__c,Success__c,SystemModstamp,TotalExpectedRevenue__c,
            valid__c,ZipCode__c,Prescreen__c,Status__c,Warning_Flag__c
            FROM LeadLogValidDetail__c  
            WHERE  Id IN : LeadLogValidDetailIDs 
        ]);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<LeadLogValidDetail__c> scope){
        // Logic to be Executed batch wise 
        List<LeadLogValidDetail__c> LeadLogValidDetailList = new List<LeadLogValidDetail__c>();
        List<LeadLogValidDetail__c> LeadLogValidDetailListUpdate = new List<LeadLogValidDetail__c>();
        List<Lead> CheckLeads = new List<Lead>();
        
        Map<Integer,Integer> rowleadmap = new Map<Integer,Integer>();
        Map<Integer,CommercialDuplicateCheck.LeadWrapper> mapleadwarpper = new map<Integer,CommercialDuplicateCheck.LeadWrapper>();
        Map<Integer,LeadLogValidDetail__c> mapleadCheckLinktoCust = new map<Integer,LeadLogValidDetail__c>();
        Integer rowInsert = 1;
        
        
        //Tinnakrit new Validate - Jul 24 2016
        LeadValidationV2.Leadvalid(scope,null);
        
        
        for(LeadLogValidDetail__c  item : scope){
            if(item.valid__c == True)
            {
                if(item.IDType__c != null && item.IDType__c != ''){
                if(item.IDType__c.tolowercase().trim() != 'citizen id' && (item.IDNumber__c != null && item.IDNumber__c != ''))
                //if(item.IDNumber__c != null && item.IDNumber__c != '')  
                {
                    boolean OwnerExceptionFlag;
                    if(item.LeadOwnerExceptionFlag__c == 'Yes'){
                        OwnerExceptionFlag = True;
                    }else if(item.LeadOwnerExceptionFlag__c == 'No'){
                        OwnerExceptionFlag = False;
                    }
                    //List Lead for check duplicate
                    Lead newlead = new Lead();
                    newlead.recordtypeId                    = item.LeadRecordtypeId__c;
                    if(item.leadOwner__c != null && item.leadOwner__c != '')
                    {
                        newlead.OwnerId                     = item.leadOwner__c;
                    }
                    if(item.PrimaryCampaign__c != null && item.PrimaryCampaign__c != ''){
                        newlead.Primary_Campaign__c         = item.PrimaryCampaign__c;
                    }
                    newlead.Exception_Flag__c               = OwnerExceptionFlag;
                    newlead.Customer_Type__c                = item.CustomerType__c;
                    newlead.Company                         = item.CustomerName__c;
                    newlead.Customer_Name_EN__c             = item.CustomerNameEN__c;
                    newlead.ID_Type__c                      = item.IDType__c;
                    newlead.ID_Number__c                    = item.IDNumber__c;
                    newlead.Salutation                      = item.ContactTitle__c;
                    newlead.FirstName                       = item.ContactFirstname__c;
                    newlead.LastName                        = item.ContactLastname__c;
                    newlead.Title                           = item.ContactTitle__c;
                    rowleadmap.put(rowInsert,Integer.valueof(item.row__c));
                    mapleadCheckLinktoCust.put(rowInsert,item);
                    CheckLeads.add(newlead);
                    rowInsert++;
                }
                }
            }
        }//End for
        
        
        List<CommercialDuplicateCheck.LeadWrapper> LeadWrapperList = new List<CommercialDuplicateCheck.LeadWrapper>();
        Integer index = 1;
        Map<Integer,CommercialDuplicateCheck.LeadWrapper> LeadWrapperMapSOAP = new map<Integer,CommercialDuplicateCheck.LeadWrapper>();
        Map<Integer,CommercialDuplicateCheck.LeadWrapper> ReLeadDup = new map<Integer,CommercialDuplicateCheck.LeadWrapper>();
        Map<Integer,CommercialDuplicateCheck.LeadWrapper> MapDuplead = new Map<Integer,CommercialDuplicateCheck.LeadWrapper>();
        for(Lead leadRec  : CheckLeads)
        {
            CommercialDuplicateCheck.LeadWrapper LeadWrapper = new CommercialDuplicateCheck.LeadWrapper();
            LeadWrapper.leadRec = LeadRec;
            LeadWrapper.index = rowleadmap.get(index);
            
            if(mapleadCheckLinktoCust.get(index).LinktoCustomer__c == null || mapleadCheckLinktoCust.get(index).LinktoCustomer__c == ''){
                LeadWrapperMapSOAP.put(LeadWrapper.index, leadWrapper);
            }
            //MapDuplead = CommercialDuplicateCheck.CheckDisqualifiedLeadSOAP(LeadWrapperMapSOAP);
            index++;
        }
        MapDuplead = CommercialDuplicateCheck.CheckDisqualifiedLeadSOAP(LeadWrapperMapSOAP);
        system.debug('MapDuplead = : ' + MapDuplead);  
        
        for(LeadLogValidDetail__c rowtrue : scope)
        {
            if(rowtrue.valid__c == true) {
                if(null != MapDuplead && MapDuplead.containsKey(integer.valueof(rowtrue.row__c))) {
                    if(MapDuplead.get(integer.valueof(rowtrue.row__c)).isfoundDuplicate == false || MapDuplead.get(integer.valueof(rowtrue.row__c)).isfoundDuplicate == null)  {
                        rowtrue.valid__c = True; 
                    }else {
                        string AccorLead = MapDuplead.get(integer.valueof(rowtrue.row__c)).Originalrecord.id;
                        system.debug('##AccorLead : '+AccorLead);
                        if(AccorLead.left(3) == '00Q'){
                            if(rowtrue.LeadOwnerExceptionFlag__c == 'Yes'){
                                rowtrue.valid__c = True;
                            }else{
                                rowtrue.valid__c = False;
                                rowtrue.Errormessage__c = MapDuplead.get(integer.valueof(rowtrue.row__c)).ErrorMessage;
                            }
                        }else if(AccorLead.left(3) == '001') {
                            rowtrue.LinktoCustomer__c = AccorLead;
                            rowtrue.valid__c = True;
                        }
                    }
                
            }
                LeadLogValidDetailList.add(rowtrue);
            }
         }//End for
        
            if(LeadLogValidDetailList.size() > 0) {
                update LeadLogValidDetailList;
            }
        
        
        
        /*
         * 
         *  Check owner Account
         *  
         */
        
        system.debug('#####scope = '+scope);
        set<id> setaccId = new set<id>();
        set<id> setaccExId = new set<id>();
        
        Id CommercialLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Commercial Lead').getRecordTypeId();    
        Id CommercialAccount = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Commercial Account').getRecordTypeId();
        String CommercialLeadName = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Commercial Lead').getName();    
        String CommercialAccountName = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Commercial Account').getName();
        system.debug('Id CommercialLead = :' +CommercialLead);
        system.debug('Id CommercialAccount = :' +CommercialAccount);
        
        
         for(LeadLogValidDetail__c checkvalid : scope)
        {
            if(checkvalid.valid__c == true){
                system.debug('checkvalid.LinktoCustomer__c = '+checkvalid.LinktoCustomer__c);
                if(checkvalid.LinktoCustomer__c != null)
                {
                    system.debug('checkvalid.LinktoCustomer__c = '+checkvalid.LinktoCustomer__c.length());
                   if(checkvalid.LinktoCustomer__c.length() == 15 || checkvalid.LinktoCustomer__c.length() == 18 )
                     {
                        setaccId.add(checkvalid.LinktoCustomer__c);
                         system.debug('##setaccId = '+setaccId);
                     }
                    else if(checkvalid.LinktoCustomer__c.length() == 30)
                     {
                        setaccExId.add(checkvalid.LinktoCustomer__c);
                     }
                }
            }
        }
        
        
        
         /***************************Check Account ID*********************************/
        Map<Id,Account> mapaccUserId = new Map<Id,Account>();
        //Map<Id,Id> mapaccMemUserId = new Map<Id,Id>();
        Map<Id,set<Id>> mapAccMemUserId = new Map<Id,set<Id>>();
        set<Id> setaccmemberId = new Set<Id>();
        List<account> tempacc = [Select Id,name,OwnerId,TMB_Customer_ID_PE__c ,Customer_Name_PE_Eng__c,Industry__c,
                                 Customer_Type__c,ID_Type_PE__c,ID_Number_PE__c,Stamp_TMB_Cust_ID__c,
                                 Mobile_Number_PE__c,Primary_Phone_Ext_PE__c,Primary_Address_Line_1_PE__c,
                                 Primary_Address_Line_2_PE__c,Primary_Address_Line_3_PE__c,Province_Primary_PE__c,
                                 Zip_Code_Primary_PE__c,Country_Primary_PE__c,Industry,
                                 Sales_amount_per_year__c,Group__c,No_of_years_business_run__c,phone 
                                 from Account 
                                 where Id IN: setaccId or TMB_Customer_ID_PE__c  IN: setaccExId];
        system.debug('##tempacc = '+tempacc);
        if(tempacc.size() > 0)
        {
            for(Account acc : tempacc)
            {

               setaccmemberId.add(acc.id);                    
                  
               mapaccUserId.put(acc.Id, acc);
            }
            
            /*
            for(AccountTeamMember accmember : [Select Id,UserId,AccountId from AccountTeamMember where AccountId IN: setaccmemberId])
            {
                mapaccMemUserId.put(accmember.AccountId, accmember.UserId);
            }
            */
            
            //********* BAU Issue Upload Lead 2017-03-09 ************//
            List<AccountTeamMember> accmember = [Select Id,UserId,AccountId from AccountTeamMember where AccountId IN: setaccmemberId];
            
            for (Id accId : setaccmemberId)
            {
                set<Id> listAccMemId = new set<Id>();
                for (AccountTeamMember accMem : accmember)
                {
                    if (accMem.AccountId == accId){
                        listAccMemId.add(accMem.UserId);
                    }
                }
                if (listAccMemId.size() > 0){
                    mapaccMemUserId.put(accId,listAccMemId);
                }
            }
            //********* BAU Issue Upload Lead 2017-03-09 ************//
             
        }
        
        
        /*****************************Custom Setting Error Message**********************************/
        Map<String,String> MapErrMsg = new Map<String,String>();
        List<Status_Code__c> errmsg = [Select Id,name,Status_Message__c from Status_Code__c];
        
        for(Status_Code__c er : errmsg) {
            MapErrMsg.put(er.name, er.Status_Message__c);
        }
        
        
        /*****************************Validation************************************/
        
        for(LeadLogValidDetail__c checkvalid : scope)//LeadLogValidDetailList)
        {
            if(checkvalid.valid__c == true) {
                checkvalid.errormessage__c = '';
                //-----------------------------------------------------------------------------------------------
                //-----------------------------------------------------------------------------------------------
                //-----------------------------------------------------------------------------------------------
                if(checkvalid.Prescreen__c == 'passed') {
                    checkvalid.Status__c = 'Passed Prescreening';
                }else {
                    checkvalid.Status__c = 'Open';
                }
                system.debug('checkvalid.Row__c = '+checkvalid.Row__c);
                system.debug('checkvalid.IDType__c = '+checkvalid.IDType__c);
                if(checkvalid.IDType__c != null && checkvalid.IDType__c != ''){
                    if(checkvalid.IDType__c.tolowercase().trim() == 'citizen id'){
                        system.debug('msg  = '+MapErrMsg.get('5049'));
                        checkvalid.errormessage__c += MapErrMsg.get('5049');
                        checkvalid.Warning_Flag__c = True;
                    }
                }
                if(checkvalid.LinktoCustomer__c != null)
                {
                    system.debug('##checkvalid.LinktoCustomer.length()  = '+checkvalid.LinktoCustomer__c.length() );
                    system.debug('##MapaccmemUserId.size() = '+mapaccMemUserId.size() );
                        if((checkvalid.LinktoCustomer__c.length() == 15 || checkvalid.LinktoCustomer__c.length() == 18 ||
                           checkvalid.LinktoCustomer__c.length() == 30) && (mapaccMemUserId.size() != 0 || mapaccUserId.size() != 0))
                        {
                            if(checkvalid.LeadOwnerExceptionFlag__c == 'Yes')
                            {
                                //if(mapaccUserId.get(checkvalid.LinktoCustomer__c).OwnerId != null )
                                system.debug('mapaccUserId.containsKey(checkvalid.LinktoCustomer__c)' + mapaccUserId.containsKey(checkvalid.LinktoCustomer__c));
                                
                                system.debug('checkvalid.LinktoCustomer ken test 1234 = ' +checkvalid.LinktoCustomer__c);
                                    checkvalid.LinktoCustomerName__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Name;
                                    checkvalid.CustomerName__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Name;
                                    checkvalid.CustomerNameEN__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Customer_Name_PE_Eng__c;
                                    checkvalid.CustomerType__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Customer_Type__c;
                                    checkvalid.IDType__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).ID_Type_PE__c;
                                    checkvalid.IDNumber__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).ID_Number_PE__c;
                                    checkvalid.MobileNo__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Mobile_Number_PE__c;
                                    checkvalid.OfficeNo__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).phone;
                                    checkvalid.Ext__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Primary_Phone_Ext_PE__c;
                                    checkvalid.Address__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Primary_Address_Line_1_PE__c;
                                    checkvalid.SubDistrict__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Primary_Address_Line_2_PE__c;
                                    checkvalid.District__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Primary_Address_Line_3_PE__c;
                                    checkvalid.Province__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Province_Primary_PE__c;
                                    checkvalid.ZipCode__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Zip_Code_Primary_PE__c;
                                    checkvalid.Country__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Country_Primary_PE__c;
                                    checkvalid.Industry__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Industry__c;
                                    checkvalid.SalesAmountperyear__c = string.valueof(mapaccUserId.get(checkvalid.LinktoCustomer__c).Sales_amount_per_year__c);
                                    checkvalid.Groupname__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Group__c;
                                    checkvalid.NoOfyears__c = string.valueof(mapaccUserId.get(checkvalid.LinktoCustomer__c).No_of_years_business_run__c);
                                    checkvalid.LeadRecordtypeId__c = CommercialAccount;
                                    checkvalid.LeadRecordtypeName__c = CommercialAccountName;
                                    checkvalid.valid__c = True;  
                                                                
                            }
                            else if(checkvalid.LeadOwnerExceptionFlag__c == 'No')
                            {
                                if(mapaccUserId.containsKey(checkvalid.LinktoCustomer__c))
                                {
                                  if(mapaccUserId.get(checkvalid.LinktoCustomer__c).OwnerId == checkvalid.leadOwner__c)
                                  {
                                    checkvalid.LinktoCustomerName__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Name;
                                    checkvalid.CustomerName__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Name;
                                    checkvalid.CustomerNameEN__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Customer_Name_PE_Eng__c;
                                    checkvalid.CustomerType__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Customer_Type__c;
                                    checkvalid.IDType__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).ID_Type_PE__c;
                                    checkvalid.IDNumber__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).ID_Number_PE__c;
                                    checkvalid.MobileNo__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Mobile_Number_PE__c;
                                    checkvalid.OfficeNo__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).phone;
                                    checkvalid.Ext__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Primary_Phone_Ext_PE__c;
                                    checkvalid.Address__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Primary_Address_Line_1_PE__c;
                                    checkvalid.SubDistrict__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Primary_Address_Line_2_PE__c;
                                    checkvalid.District__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Primary_Address_Line_3_PE__c;
                                    checkvalid.Province__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Province_Primary_PE__c;
                                    checkvalid.ZipCode__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Zip_Code_Primary_PE__c;
                                    checkvalid.Country__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Country_Primary_PE__c;
                                    checkvalid.Industry__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Industry__c;
                                    checkvalid.SalesAmountperyear__c = string.valueof(mapaccUserId.get(checkvalid.LinktoCustomer__c).Sales_amount_per_year__c);
                                    checkvalid.Groupname__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Group__c;
                                    checkvalid.NoOfyears__c = string.valueof(mapaccUserId.get(checkvalid.LinktoCustomer__c).No_of_years_business_run__c);
                                    checkvalid.LeadRecordtypeId__c = CommercialAccount;
                                    checkvalid.LeadRecordtypeName__c = CommercialAccountName;
                                    checkvalid.valid__c = True;
                                  } else if(mapaccMemUserId.containsKey(checkvalid.LinktoCustomer__c)) {
                                    
                                    //********* BAU Issue Upload Lead 2017-03-09 ************//
                                    
                                    set<id> setAcctMember = mapaccMemUserId.get(checkvalid.LinktoCustomer__c);
                                    
                                    //********* BAU Issue Upload Lead 2017-03-09 ************//
                                    //if(mapaccMemUserId.get(checkvalid.LinktoCustomer__c) == checkvalid.leadOwner__c) {
                                      
                                      if(setAcctMember.contains(checkvalid.leadOwner__c)) {
                                        checkvalid.LinktoCustomerName__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Name;
                                        checkvalid.CustomerName__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Name;
                                        checkvalid.CustomerNameEN__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Customer_Name_PE_Eng__c;
                                        checkvalid.CustomerType__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Customer_Type__c;
                                        checkvalid.IDType__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).ID_Type_PE__c;
                                        checkvalid.IDNumber__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).ID_Number_PE__c;
                                        checkvalid.MobileNo__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Mobile_Number_PE__c;
                                        checkvalid.OfficeNo__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).phone;
                                        checkvalid.Ext__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Primary_Phone_Ext_PE__c;
                                        checkvalid.Address__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Primary_Address_Line_1_PE__c;
                                        checkvalid.SubDistrict__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Primary_Address_Line_2_PE__c;
                                        checkvalid.District__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Primary_Address_Line_3_PE__c;
                                        checkvalid.Province__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Province_Primary_PE__c;
                                        checkvalid.ZipCode__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Zip_Code_Primary_PE__c;
                                        checkvalid.Country__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Country_Primary_PE__c;
                                        checkvalid.Industry__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Industry__c;
                                        checkvalid.SalesAmountperyear__c = string.valueof(mapaccUserId.get(checkvalid.LinktoCustomer__c).Sales_amount_per_year__c);
                                        checkvalid.Groupname__c = mapaccUserId.get(checkvalid.LinktoCustomer__c).Group__c;
                                        checkvalid.NoOfyears__c = string.valueof(mapaccUserId.get(checkvalid.LinktoCustomer__c).No_of_years_business_run__c);
                                        checkvalid.LeadRecordtypeId__c = CommercialAccount;
                                        checkvalid.LeadRecordtypeName__c = CommercialAccountName;
                                        checkvalid.valid__c = True; 
                                      }else{
                                          checkvalid.errormessage__c += MapErrMsg.get('5013')+' \r\n';
                                            checkvalid.valid__c = False;
                                      }  
                                  } else {
                                    checkvalid.errormessage__c += MapErrMsg.get('5013')+' \r\n';
                                    checkvalid.valid__c = False;
                                    }
                                }
                            }
                        }else{
                            checkvalid.errormessage__c += MapErrMsg.get('5014')+' \r\n';
                            checkvalid.valid__c = False;
                        }
                }else
                    {
                    system.debug('##checkvalid.IDType = '+checkvalid.IDType__c);
                    system.debug('##CommercialLead = '+CommercialLead);
                    checkvalid.LeadRecordtypeId__c = CommercialLead;
                    checkvalid.LeadRecordtypeName__c = CommercialLeadName;
                    }
                if(checkvalid.errormessage__c != null) {
                    checkvalid.errormessage__c = checkvalid.errormessage__c.removeEnd(',');
                }
            }else if(checkvalid.valid__c == false) {
                if(checkvalid.errormessage__c != null) {
                    checkvalid.errormessage__c = checkvalid.errormessage__c.removeEnd(',');
                }  
            }
            LeadLogValidDetailListUpdate.add(checkvalid);
            
        }
        if(LeadLogValidDetailListUpdate.size() > 0) {
            update LeadLogValidDetailListUpdate;
        }
    }
     

    global void finish(Database.BatchableContext BC){
        
            //Status Validattion run batch
            String fileName ='';
            LeadLogValidHeader__c  statusValidate = [Select ID,Name,isValidProgress__c,isValidDone__c,isImportProgress__c,isImportDone__c From LeadLogValidHeader__c  where ID= :m_LeadLogHeaderID limit 1];
            if(statusValidate != null){
                statusValidate.isValidProgress__c = false;
                statusValidate.isValidDone__c = true;
                statusValidate.isImportProgress__c = false;
                statusValidate.isImportDone__c = false;
                update statusValidate;
                fileName = statusValidate.Name;
            }

        
            String mainUrl =  'https://' + System.URL.getSalesforceBaseUrl().getHost() +'/one/one.app#/alohaRedirect/apex/UploadleadvalidV2?id='+m_LeadLogHeaderID;
            
            String subject = 'Run Batch Validation Upload Lead';
            String htmlMsg =  subject
                              +'<br />Please click below url to view results'
                              +'<br />File Name : '+fileName
                              +'<br />View <a href="'+mainUrl+'"> click here</a>';
        
        
            AsyncApexJob a =  [SELECT a.Id, a.TotalJobItems, a.Status, a.NumberOfErrors, a.JobType, a.JobItemsProcessed, 
                           a.ExtendedStatus, a.CreatedById, a.CompletedDate, a.CreatedBy.Email, a.ParentJobId,
                           a.CreatedDate, a.LastProcessed, a.LastProcessedOffset, a.MethodName, a.ApexClassId
                           FROM AsyncApexJob a 
                           WHERE Id = :BC.getJobId()];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject(subject+' : '+a.Status);
            mail.setHtmlBody(htmlMsg);
            Messaging.sendEmail(new Messaging.SingleEmailMessage [] {mail});
        
    }
}