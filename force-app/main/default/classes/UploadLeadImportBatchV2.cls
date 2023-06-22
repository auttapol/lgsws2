/********************************************
 * Bacth for Import lead 
 ********************************************/
global class UploadLeadImportBatchV2 implements Database.Batchable<sObject> ,Database.AllowsCallouts{    
 
    public Set<Id> m_leadLogValidDetailID    {get;set;}
    public String m_LeadLogHeaderID   {get;set;}
    Public List<LeadLogValidDetail__c> Leadafterinsert {get;set;}
    
    global UploadLeadImportBatchV2 (Set<Id> leadLogValidDetailID,String LeadLogHeaderID){
        
        m_leadLogValidDetailID =  leadLogValidDetailID ;
        m_LeadLogHeaderID = LeadLogHeaderID;
        Leadafterinsert = new List<LeadLogValidDetail__c>();
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
        List<LeadLogDetail__c> Indetail = new List<LeadLogDetail__c>();
        List<Lead> InLeads= new List<Lead>();
        
        Map<Integer,LeadLogValidDetail__c> ValidDetailmap = new Map<Integer,LeadLogValidDetail__c>();
        Map<Integer,Integer> rowinsertmap = new Map<Integer,Integer>();
        Integer rowInsert = 0;
        system.debug('###scope.size = '+scope.size());
        for(LeadLogValidDetail__c le : scope)
        {
            system.debug('##Record Type Temp ' +le.LeadRecordtypeId__c);
            if(le.valid__c == True)
            {
                boolean OwnerExceptionFlag;
                if(le.LeadOwnerExceptionFlag__c == 'Yes'){
                    OwnerExceptionFlag = True;
                }else if(le.LeadOwnerExceptionFlag__c == 'No'){
                    OwnerExceptionFlag = False;
                }
                Lead newlead = new Lead();
                newlead.recordtypeId                    = le.LeadRecordtypeId__c;
                if(le.leadOwner__c != null && le.leadOwner__c != ''){
                    newlead.OwnerId                         = le.leadOwner__c;
                }
                if(le.PrimaryCampaign__c != null && le.PrimaryCampaign__c != ''){
                    newlead.Primary_Campaign__c             = le.PrimaryCampaign__c;
                }
                newlead.Exception_Flag__c               = OwnerExceptionFlag;
                if(le.LinktoCustomer__c != null && le.LinktoCustomer__c != ''){
                    newlead.Account__c                      = le.LinktoCustomer__c;
                }
                newlead.Customer_Type__c                = le.CustomerType__c;
                newlead.Company                         = le.CustomerName__c;
                newlead.Customer_Name_EN__c             = le.CustomerNameEN__c;
                newlead.ID_Type__c                      = le.IDType__c;
                newlead.ID_Number__c                    = le.IDNumber__c;
                newlead.Salutation                      = le.ContactTitle__c;
                newlead.FirstName                       = le.ContactFirstname__c;
                newlead.LastName                        = le.ContactLastname__c;
                newlead.Title                           = le.ContactPosition__c;
                newlead.Decision_Map__c                 = le.DecisionMap__c;
                newlead.Phone__c                        = le.ContactPhoneNumber__c;
                if(le.Industry__c != null && le.Industry__c != ''){
                    newlead.Industry__c                 = le.Industry__c;
                }
                if(le.Groupname__c != null && le.Groupname__c != ''){
                    newlead.Group__c                    = le.Groupname__c;
                }
                if(le.NoOfyears__c != '' && le.NoOfyears__c != null){
                    newlead.No_of_Years_Business_Run__c = Decimal.valueof(le.NoOfyears__c);
                }
                if(le.SalesAmountperyear__c != '' && le.SalesAmountperyear__c != null){
                    String salesamount	= le.SalesAmountperyear__c.replace(',','');
                    newlead.Sales_amount_per_year__c    = Double.valueof(salesamount);
                }
                newlead.LeadSource                      = le.LeadSource__c;
                newlead.Other_Source__c                 = le.OtherSource__c;
                if(le.BranchedReferred__c != null && le.BranchedReferred__c != ''){
                    newlead.Branch_Referred__c          = le.BranchedReferred__c;
                }
                newlead.Referral_Staff_ID__c            = le.ReferralStaffID__c;
                newlead.Referral_Staff_Name__c          = le.ReferralStaffName__c;
                if(le.TotalExpectedRevenue__c != '' && le.TotalExpectedRevenue__c != null){
                    String totalamount	= le.TotalExpectedRevenue__c.replace(',','');
                    newlead.Total_Expected_Revenue__c       = Decimal.valueof(totalamount);
                }
                newlead.Address_Line_1__c               = le.Address__c;
                newlead.Address_Line_2__c               = le.SubDistrict__c;
                newlead.Address_Line_3__c               = le.District__c;
                newlead.Province__c                     = le.Province__c;
                newlead.Zipcode__c                      = le.ZipCode__c;
                newlead.Country__c                      = le.Country__c;
                newlead.Mobile_No__c                    = le.MobileNo__c;
                newlead.Office_No__c                    = le.OfficeNo__c;
                newlead.Ext__c                          = le.Ext__c;
                newlead.Email__c                        = le.Email__c;
                newlead.Rating                          = le.Rating__c;
                newlead.Remark__c                       = le.Remark__c;
                newlead.status                          = le.Status__c;
                if(le.Prescreen__c == 'passed'){
                    newlead.Pre_screening_Result__c = 'Passed ';
                }
                String IDNumber =  le.IDNumber__c;
                if(IDNumber != null && IDNumber != ''){
                	newlead.ID_REGEX__c =  IDnumber.substring(IDNumber.length()-3, IDNumber.length());
                }
                if(le.IDType__c != null && le.IDType__c != ''){
                    if(le.IDType__c.tolowercase().trim() == 'citizen id'){
                        newlead.isBypassDuplicateCheck__c = true;
                    }
                }
                
                rowInsert++;
                rowinsertmap.put(rowInsert, integer.valueOf(le.row__c));
                Inleads.add(newlead);
            }
            system.debug('##Record Type Inleads1 ' +Inleads);
            ValidDetailmap.put(integer.valueOf(le.row__c),le);
        }
        Database.SaveResult[] srList = Database.insert(Inleads, false);
        
        // Iterate through each returned result
        Integer databaseRow =1;
        for (Database.SaveResult sr : srList) 
        {
            LeadLogValidDetail__c leadcheck = ValidDetailmap.get(rowinsertmap.get(databaseRow));
            if (sr.isSuccess()) 
            {
                // Operation was successful, so get the ID of the record that was processed
                leadcheck.Id__c = string.valueof(sr.getID());
                leadcheck.Success__c  = 'true';
                leadcheck.Created__c = 'true';
                leadcheck.Error__c = null;
                if(String.isBlank(leadcheck.ErrorMessage__c)) {
                	leadcheck.ErrorMessage__c = null;
                }
            }
            else {
                leadcheck.Id__c = 'null';
                leadcheck.Success__c = 'false';
                leadcheck.Created__c = 'false';
                String ErrorField = '';
                String ErrorMessage = '';
                for(Database.Error objErr : sr.getErrors()) {
                    
                    ErrorField += objErr.getFields()+'';
                    ErrorMessage+= objErr.getMessage()+'';
                }
                leadcheck.Error__c = ErrorField;
                leadcheck.ErrorMessage__c = ErrorMessage;   
            }
            
            Leadafterinsert.add(leadcheck);
            databaseRow++;
        }
        if(Leadafterinsert.size() > 0) {
            update Leadafterinsert;
        }
        system.debug('##Leadafterinsert = '+Leadafterinsert);
       
    }


    global void finish(Database.BatchableContext BC){
        
        LeadLogValidHeader__c validheadername = [Select id,name from LeadLogValidHeader__c where id =: m_LeadLogHeaderID];
        LeadLogHeader__c newheader = new LeadLogHeader__c();
        newheader.name = validheadername.name;
        if(newheader.name != null)
        {
            insert newheader;
        }
        system.debug('##newheader = '+newheader.id);
        List<LeadLogValidDetail__c> tempLogValidDetail = [Select Address__c,
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
                                                          		Status__c,
                                                          		Prescreen__c,
                                                                row__c,
                                                                filename__c 
                                                         FROM LeadLogValidDetail__c
                                                         WHERE LeadLogValidHeader__c =: m_LeadLogHeaderID order by row__c];
        
        List<LeadLogDetail__c> inlog = new List<LeadLogDetail__c>();
        
        system.debug('##Leadafterinsert222 = '+Leadafterinsert);
        for(LeadLogValidDetail__c logfile : tempLogValidDetail)
        {
            if(logfile.Success__c == 'true' || logfile.Success__c == 'false') {
            /*String content = logfile.leadOwner__c+','+logfile.PrimaryCampaign__c+','+logfile.LeadOwnerExceptionFlag__c+',';
			content += logfile.LinktoCustomer__c+','+logfile.CustomerType__c+','+'"'+logfile.CustomerName__c+'"'+','+'"'+logfile.CustomerNameEN__c+'"'+',';
            content += logfile.IDType__c+','+logfile.IDNumber__c+','+logfile.ContactTitle__c+','+logfile.ContactFirstname__c+',';
            content += logfile.ContactLastname__c+','+logfile.ContactPosition__c+','+logfile.DecisionMap__c+','+logfile.ContactPhoneNumber__c+',';
            content += logfile.Industry__c+','+logfile.Groupname__c+','+logfile.NoOfyears__c+','+logfile.SalesAmountperyear__c+',';
            content += logfile.LeadSource__c+','+logfile.OtherSource__c+','+logfile.BranchedReferred__c+','+logfile.ReferralStaffID__c+','+logfile.ReferralStaffName__c+','+logfile.TotalExpectedRevenue__c+',';
            content += logfile.Address__c+','+logfile.SubDistrict__c+','+logfile.District__c+','+logfile.Province__c+',';
            content += logfile.ZipCode__c+','+logfile.Country__c+','+logfile.MobileNo__c+','+logfile.OfficeNo__c+',';
            content += logfile.Ext__c+','+logfile.Email__c+','+logfile.Rating__c+','+logfile.Prescreen__c+','+logfile.Status__c+','+logfile.Remark__c;*/

             String content = '"'+logfile.leadOwner__c+'"'+','+'"'+logfile.PrimaryCampaign__c+'"'+','+'"'+logfile.LeadOwnerExceptionFlag__c+'"'+',';//0,1,2
                content += '"'+logfile.LinktoCustomer__c+'"'+','+'"'+logfile.CustomerType__c+'"'+','+'"'+logfile.CustomerName__c+'"'+','+'"'+logfile.CustomerNameEN__c+'"'+',';//3,4,5,6
                content += '"'+logfile.IDType__c+'"'+','+'"'+logfile.IDNumber__c+'"'+','+'"'+logfile.ContactTitle__c+'"'+','+'"'+logfile.ContactFirstname__c+'"'+',';// 7,8,9,10
                content += '"'+logfile.ContactLastname__c+'"'+','+'"'+logfile.ContactPosition__c+'"'+','+'"'+logfile.DecisionMap__c+'"'+','+'"'+logfile.ContactPhoneNumber__c+'"'+',';//11,12,13,14
                content += '"'+logfile.Industry__c+'"'+','+'"'+logfile.Groupname__c+'"'+','+'"'+logfile.NoOfyears__c+'"'+','+'"'+logfile.SalesAmountperyear__c+'"'+',';//15,16,17,18
                content += '"'+logfile.LeadSource__c+'"'+','+'"'+logfile.OtherSource__c+'"'+','+'"'+logfile.BranchedReferred__c+'"'+','+'"'+logfile.ReferralStaffID__c+'"'+','+'"'+logfile.ReferralStaffName__c+'"'+','+'"'+logfile.TotalExpectedRevenue__c+'"'+',';//19,20,21,22,23,24
                content += '"'+logfile.Address__c+'"'+','+'"'+logfile.SubDistrict__c+'"'+','+'"'+logfile.District__c+'"'+','+'"'+logfile.Province__c+'"'+',';//25,26,27,28
                content += '"'+logfile.ZipCode__c+'"'+','+'"'+logfile.Country__c+'"'+','+'"'+logfile.MobileNo__c+'"'+','+'"'+logfile.OfficeNo__c+'"'+',';//29,30,31,32
                content += '"'+logfile.Ext__c+'"'+','+'"'+logfile.Email__c+'"'+','+'"'+logfile.Rating__c+'"'+','+'"'+logfile.Prescreen__c+'"'+','+'"'+logfile.Status__c+'"'+','+'"'+logfile.Remark__c+'"';//33,34,35,36,37,38
            LeadLogDetail__c log = new LeadLogDetail__c();
            log.Parrent__c = newheader.id;
            log.Error_Message__c = logfile.Errormessage__c;
            log.Success__c = logfile.Success__c;
            log.Lead_ID__c = logfile.Id__c;
            log.Content__c = content;
            log.Lead_Valid__c = False;
            //log.Content__c = logfile.leadOwner+','+logfile.PrimaryCampaign+','+logfile.PrimaryCampaign+','+logfile.LeadOwnerExceptionFlag+','+logfile.LinktoCustomer+','+logfile.CustomerType+','+logfile.CustomerName+','+logfile.CustomerNameEN+','+logfile.IDType+','+logfile.IDNumber+','+logfile.ContactTitle+','+logfile.ContactFirstname+','+logfile.ContactLastname+','+logfile.ContactPosition+','+logfile.DecisionMap+','+logfile.ContactPhoneNumber+','+logfile.Industry+','+logfile.Groupname+','+logfile.NoOfyears+','+logfile.SalesAmountperyear+','+logfile.LeadSource+','+logfile.OtherSource+','+logfile.BranchedReferred+','+logfile.TotalExpectedRevenue+','+logfile.Address+','+logfile.SubDistrict+','+logfile.District+','+logfile.Province+','+logfile.ZipCode+','+logfile.Country+','+logfile.MobileNo+','+logfile.OfficeNo+','+logfile.Ext+','+logfile.Email+','+logfile.Rating+',';
            inlog.add(log);
            }
        }
        system.debug('##inlog = '+inlog);
        
        if(tempLogValidDetail.size() > 0)
        {
            for(LeadLogValidDetail__c logfile : tempLogValidDetail)
            {
                if(logfile.valid__c == false){
                 String content = '"'+logfile.leadOwner__c+'"'+','+'"'+logfile.PrimaryCampaign__c+'"'+','+'"'+logfile.LeadOwnerExceptionFlag__c+'"'+',';//0,1,2
                content += '"'+logfile.LinktoCustomer__c+'"'+','+'"'+logfile.CustomerType__c+'"'+','+'"'+logfile.CustomerName__c+'"'+','+'"'+logfile.CustomerNameEN__c+'"'+',';//3,4,5,6
                content += '"'+logfile.IDType__c+'"'+','+'"'+logfile.IDNumber__c+'"'+','+'"'+logfile.ContactTitle__c+'"'+','+'"'+logfile.ContactFirstname__c+'"'+',';// 7,8,9,10
                content += '"'+logfile.ContactLastname__c+'"'+','+'"'+logfile.ContactPosition__c+'"'+','+'"'+logfile.DecisionMap__c+'"'+','+'"'+logfile.ContactPhoneNumber__c+'"'+',';//11,12,13,14
                content += '"'+logfile.Industry__c+'"'+','+'"'+logfile.Groupname__c+'"'+','+'"'+logfile.NoOfyears__c+'"'+','+'"'+logfile.SalesAmountperyear__c+'"'+',';//15,16,17,18
                content += '"'+logfile.LeadSource__c+'"'+','+'"'+logfile.OtherSource__c+'"'+','+'"'+logfile.BranchedReferred__c+'"'+','+'"'+logfile.ReferralStaffID__c+'"'+','+'"'+logfile.ReferralStaffName__c+'"'+','+'"'+logfile.TotalExpectedRevenue__c+'"'+',';//19,20,21,22,23,24
                content += '"'+logfile.Address__c+'"'+','+'"'+logfile.SubDistrict__c+'"'+','+'"'+logfile.District__c+'"'+','+'"'+logfile.Province__c+'"'+',';//25,26,27,28
                content += '"'+logfile.ZipCode__c+'"'+','+'"'+logfile.Country__c+'"'+','+'"'+logfile.MobileNo__c+'"'+','+'"'+logfile.OfficeNo__c+'"'+',';//29,30,31,32
                content += '"'+logfile.Ext__c+'"'+','+'"'+logfile.Email__c+'"'+','+'"'+logfile.Rating__c+'"'+','+'"'+logfile.Prescreen__c+'"'+','+'"'+logfile.Status__c+'"'+','+'"'+logfile.Remark__c+'"';//33,34,35,36,37,38
                LeadLogDetail__c logs = new LeadLogDetail__c();
                logs.Parrent__c = newheader.id;
                logs.Error_Message__c = logfile.Errormessage__c;
                logs.Content__c = content;
                logs.Lead_Valid__c = True;
                inlog.add(logs);
                }
            }
        }
        if(inlog.size() > 0)
        {
            insert inlog;
        }  
        
        	//Status Validattion run batch
			//List<LeadLogValidHeader__c> logvalidHeader = [SELECT id from LeadLogValidHeader__c WHERE id=: m_LeadLogHeaderID];
        	//Delete logvalidHeader;
        	
        	String fileName ='';
        	LeadLogValidHeader__c  statusValidate = [Select ID,Name,isValidProgress__c,isValidDone__c,isImportProgress__c,isImportDone__c From LeadLogValidHeader__c  where ID= :m_LeadLogHeaderID limit 1];
            if(statusValidate != null){
                statusValidate.isValidProgress__c = false;
                statusValidate.isValidDone__c = true;
                statusValidate.isImportProgress__c = false;
            	statusValidate.isImportDone__c = true;
                update statusValidate;
                fileName = statusValidate.Name;
            }
        
        
			String mainUrl =  'https://' +  System.URL.getSalesforceBaseUrl().getHost() + '/'+'apex/uploadleadvalid?id='+m_LeadLogHeaderID;
			String subject = 'Run Batch Import Upload Lead';
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