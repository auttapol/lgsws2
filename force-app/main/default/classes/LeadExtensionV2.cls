public without sharing class LeadExtensionV2 {

    public lead leadObj {get;set;}
    public string displayAction {get;set;}
    public boolean launchNextPage {get;set;}
    public boolean isChangeCustomer {get;set;}
    public boolean isPopulateAccountData {get;set;}
    public boolean isPopulateLeadData {get;set;}
    public boolean isHasPermission {get;set;}
    public boolean isFindDuplicate {get;set;}
    public boolean isDisqualified {get;set;}
    public boolean isReferralValid {get;set;} /*If Referral is New or Inprogress & Contacted*/
    public boolean isReferralHasCust {get;set;} /*If Referral is attache with existing customer*/
    public boolean isReferralOwner {get;set;} /*If curren user is referral owner*/
    public boolean isReferralHasLead {get;set;}/*If referral already has lead attached*/
    public boolean isReferralTypeService {get;set;}/*If referral type = Account Opening/Service*/
    public boolean isReferralTypeProductValid {get;set;}/*If referral type = To Product Team and status is New , Inprogress & Contacted or Closed (Service Completed)*/
    //public recordtype recordTypeObj {get;set;}
    public RecordType recordTypeObj {
        get{
        
          if(recordTypeObj ==null){
              List<String> recordTypeNameList = new List<String>();
              /** Need to create list to collect record type name.**/
              Schema.DescribeSObjectResult R = Lead.SObjectType.getDescribe();
              /** You need to change the object name according to your requirement.**/
              List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
              for( Schema.RecordTypeInfo recordType : RT )
              {
                if(recordType.isAvailable())
                { 
                  /** Check if the recordtype is visible for the current user or not. **/
                  if(recordType.Name!='Master') {
                      recordTypeObj = [SELECT ID,Name from RecordType WHERE ID =: recordType.getRecordTypeID() LIMIT 1];
                  /** Collect the record type name in list. **/
                    }
                  }
              }   
          }
        
          return recordTypeObj;
      }set;
    }
    
    public static RecordType CompletedRecordType {
        get{
          if(CompletedRecordType ==null){
              CompletedRecordType = [SELECT id,Name FROM RecordType 
                                    WHERE Name='Commercial Completed' 
                                    AND sObjectType='Lead' LIMIT 1];
            }
          return CompletedRecordType;
      }set;}
    
    public static RecordType AccountRecordType {
        get{
          if(AccountRecordType ==null){
              AccountRecordType = [SELECT id,Name FROM RecordType 
                                   WHERE Name='Commercial Account' 
                                   AND sObjectType='Lead' LIMIT 1];
          }
          return AccountRecordType;
      }set;}
    
    
    public static RecordType CommercialLeadType {
        get{
          if(CommercialLeadType ==null){
              CommercialLeadType = [SELECT id,Name FROM RecordType 
                                    WHERE Name='Commercial Lead' 
                                    AND sObjectType='Lead' LIMIT 1];
          }
        return CommercialLeadType;
      }set;}
    
    public static Map<String, Branch_and_Zone__c> branchNameMap{
      get{
          if(branchNameMap ==null){
            branchNameMap = new Map<String, Branch_and_Zone__c>();
            for(Branch_and_Zone__c branchzone : [Select Id,Name, Branch_Code__c, RTL_Region_Code__c, RTL_Zone_Code__c from Branch_and_Zone__c]) {
                branchNameMap.put(branchzone.Name, branchzone);
            }
          }
          return branchNameMap;
        
      }set;}
    
    public lead tempLead {get;set;}
    public Lead beforeChangeLead {get;set;}
    
    public Account originalAccount {get;set;}
    public Lead leadRec {get;set;}
    public string isStatusPass {get;set;}
    private RTL_Referral__c referral;
    private string referralId;
    public LeadExtensionV2 (ApexPages.StandardController sc)
    {
        tempLead = (lead)sc.getRecord();
        launchNextPage = false;
        isFindDuplicate = false;
        isDisqualified = false;
        isStatusPass = 'no';
        isHasPermission =false;
        /*if (apexPages.currentPage().getParameters().get('recordtype') != null)
        {
            recordTypeObj = [select id,name from recordtype where id =: apexPages.currentPage().getParameters().get('recordtype')];
        }*/
        referralId = ApexPages.currentPage().getParameters().get('referralId');
               
        if (tempLead.id == null)
        {
            leadObj = new lead();
            beforeChangeLead = new Lead();
            displayAction = 'Create';
            isHasPermission =true;
            getPassingParams(leadobj);
            recordTypeObj = CommercialLeadType;
            leadObj.RecordTypeId = CommercialLeadType.id;
            populateReferralInfo(leadObj,displayAction,referralId);
            
        } else {
            leadObj = [select
                       Customer_Type__c, Salutation, firstname, lastname, company, Customer_Name_EN__c, ID_Type__c
                       , ID_Number__c, Primary_Campaign__c, Mobile_No__c, Office_No__c, Ext__c, Email
                       , Remark__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Province__c
                       , Zipcode__c, Country__c, Rating, Parent_Company__c, Group__c, Total_Expected_Revenue__c
                       , Industry, Sales_amount_per_year__c, No_of_Years_Business_Run__c, LeadSource
                       , Other_Source__c, Branch_Referred__c, Referred_Staff__c, Preferred_Branch__c
                       , RecordTypeId, Industry__c,Exception_Flag__c
                       , Status, Decision_Map__c, Phone, Title
                       , Referral_Staff_ID__c, Referral_Staff_Name__c
                       , Account__c,Suggested_Team__c 
                       , owner.name
                       , Phone__c
                       , Email__c
                       , RecordType.name
                       ,Account__r.Name
                       ,isBypassDuplicateCheck__c
                       ,RTL_Referral__c,Link_Document__c, Other_Reason__c
                       ,Lead_Segment__c
                       from lead where id =: tempLead.id];
            displayAction = 'Update';
            beforeChangeLead = leadObj.clone(true,true,true,true);
           
            //if (recordTypeObj == null) recordTypeObj = [select id,name from recordtype where id =: leadObj.RecordTypeId];
            recordTypeObj = [select id,name from recordtype where id =: leadObj.RecordTypeId];
            
            List<UserRecordAccess> RecordAccessList = [SELECT RecordId, HasEditAccess FROM UserRecordAccess 
                                             WHERE UserId =: UserInfo.getUserId() 
                                             AND RecordId =: leadObj.id];
            
            if(RecordAccessList.size()>0){
                for(UserRecordAccess ura : RecordAccessList){
                    
                        if(ura.HasEditAccess){
                            isHasPermission =true;
                        }
                    
                }
            }
            
            if(!isHasPermission){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6014').Status_Message__c));
            }
            
      String pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');

            System.debug('Pagename :'+pageName);
            
            if(pageName.containsIgnoreCase('LeadFindDuplicates')){
                isFindDuplicate = true;
            }
            
            if(isFindDuplicate && isHasPermission){
                //doAction();
            }
            
            
            
        }
        
        if (leadObj.recordtype.name == 'Commercial Completed'){
             isStatusPass = 'yes';
        }
           
        
    }
    
    public pageReference doAction()
    {
        
        Savepoint sp = Database.setSavepoint();
        isChangeCustomer = false;
        isPopulateAccountData  = false;
        isPopulateLeadData = false;       
        
        try 
        {   
            leadObj.recordTypeId = recordTypeObj.id;
            if(leadObj.OwnerId ==null){
               leadObj.OwnerId = Userinfo.getUserId(); 
            }
            
            Boolean isCommercialLead = false;
            Set<ID> AccountPermissionSet =new Set<ID>();
             
            Boolean isDuplicated =false;
            boolean isRequireToCheckDup = false;
            isDisqualified =false;
            
            System.debug(leadobj.Customer_Type__c);
            System.debug(leadobj.ID_Type__c);
            System.debug(leadobj.ID_Number__c);
            
            //Populate Referral Information when Referral Changed
            if(beforeChangeLead.RTL_Referral__c != leadObj.RTL_Referral__c){
                populateReferralInfo(leadObj,displayAction,leadObj.RTL_Referral__c);
            }
            
           //Check Create with ID Type
            if(displayAction =='Create'){
                               
                if(leadObj.Customer_Type__c !=null && leadObj.Customer_Type__c !=''
                  && leadObj.ID_Type__c !=null && leadObj.ID_Type__c !='' && leadObj.ID_Type__c !='--None--'
                    && leadObj.ID_Number__c !=null && leadObj.ID_Number__c !=''
                  )
                {
                    isRequireToCheckDup = true;
                }
            
                System.debug('leadObj :'+leadObj.ID_Number__c);
                // Check Update and Change ID 
            }else if(displayAction =='Update'){
                
                if((leadObj.Customer_Type__c != beforeChangeLead.Customer_Type__c 
                    || leadObj.ID_Type__c != beforeChangeLead.ID_Type__c 
                    || leadObj.ID_Number__c != beforeChangeLead.ID_Number__c
                   ) && leadobj.ID_Number__c !=null
                     && leadobj.ID_Type__c !=null
                   )
                {
                    isRequireToCheckDup = true;
                }
                
                if(leadobj.isBypassDuplicateCheck__c
                    && leadObj.ID_Type__c !=null
                    && leadObj.ID_Number__c !=null )
                {
                     isRequireToCheckDup = true;
                }
            
              //Check Account Link has been changed
              if(displayAction =='Update'
                  && beforeChangeLead.Account__c != leadObj.Account__c)
                {
                  isChangeCustomer = true;
              }
                    
                if(isFindDuplicate){
                    
                    if(leadObj.ID_Type__c !=null && leadObj.ID_Number__c !=null&& leadobj.ID_type__C != '--None--'){
                        isRequireToCheckDup = true;
                    }else{
                        isRequireToCheckDup = false;
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No ID Type/ID Number to check duplication. Please capture ID Type/ID Number before clicking Check Dup button.'));
                    }
     
                }
            }
            

            //Perform Check Dup
            if((isRequireToCheckDup|| isChangeCustomer)){
                //fix 23/08/2016
                //
                leadobj.isBypassDuplicateCheck__c = false;
                //
                
                Map<Integer,CommercialDuplicateCheck.LeadWrapper> leadwrapperMap = 
                CommercialDuplicateCheck.DuplicateCheckLeadSingleRecord(leadObj,beforeChangeLead);
                
                CommercialDuplicateCheck.LeadWrapper LeadWrapper = leadwrapperMap.get(0);
                    
                
                System.debug('isChangeCustomer : '+isChangeCustomer);
                System.debug('LeadWrapper : '+LeadWrapper);
                
                //Check Lead is CommercialLead or Not
                if(leadobj.RecordTypeId == CommercialLeadType.id)
                {
                  isCommercialLead = true;                            
                }
                    
                //IF Found Duplicated with Account
                if((LeadWrapper.isfoundDuplicate && LeadWrapper.OrgininalrecordType=='Account') || isChangeCustomer)
                {
                  ID AcctID;
                    isDuplicated = true;
                    Account acct = (Account)LeadWrapper.Originalrecord;
                    //Set Account ID
                    if(LeadWrapper.isfoundDuplicate && LeadWrapper.OrgininalrecordType=='Account' && leadobj.Account__c == null){
                      AcctID = acct.id;  
                    }else{
                      //in case change Link to Account
                      AcctID = leadobj.Account__c;
                    }
                        
                    //Query Account detail for populate data
                    originalAccount = [SELECT ID,Customer_Type__c,Customer_Name_PE_ENg__c, ParentId, Suggested_Sub_Segment__c  
                                                   ,Name, Mobile_Number_PE__c,phone, ID_Type_PE__c,OwnerID
                                                   ,ID_Number_PE__c,Primary_Address_Line_1_PE__c,Primary_Address_Line_2_PE__c,Primary_Address_Line_3_PE__c
                                                   ,Province_Primary_PE__c,Zip_Code_Primary_PE__c,Country_Primary_PE__c
                                                   ,Industry,Sales_amount_per_year__c,No_of_years_business_run__c
                                                   ,TMB_Employee_ID__c,TMB_Employee_Name__c,Remark__c,Rating,Industry__c
                                                   ,Group__c,Branch_Referred__c,Suggested_Segment__c,Branch_and_Zone__c
                                                    ,Email_Address_PE__c,Primary_Phone_Ext_PE__c
                                                FROM Account
                                                WHERE ID =:AcctID
                                                LIMIT 1];
          //Add OwnerID to permissionset    
          AccountPermissionSet.add(originalAccount.OwnerId);   
                    if(leadobj.Exception_Flag__c==true){
                      AccountPermissionSet.add(leadobj.OwnerID);
                    }
                    
                    //Add AccountTeaam to permissionset
                    for(AccountTeamMember acctTeam :[SELECT ID,AccountId,UserId FROM  AccountTeamMember
                                                          WHERE AccountId =: originalAccount.id])
                    {
                      AccountPermissionSet.add(acctTeam.UserId); 
                    }
                        
                    isCommercialLead =false;
                    isPopulateAccountData =true;
    
                    
                }
                //In case of not found any account but found lead
                else if((LeadWrapper.isfoundDuplicate && LeadWrapper.OrgininalrecordType=='Lead'))
                {
                  Lead originalLead = (Lead)LeadWrapper.Originalrecord;
                    isDuplicated =true;
                        
                    leadRec = [SELECT id, Account__c, OwnerID, RecordTypeID,Account__r.OwnerID,
                                                      Name, Customer_Type__c ,Company ,Mobile_No__c,Office_No__c,
                                                    Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,
                                                    Province__c,Zipcode__c,Country__c,Industry,Sales_amount_per_year__c,
                                                    No_of_Years_Business_Run__c,
                                                     ID_Type__c, ID_Number__c, Customer_Name_EN__c
                                           FROM Lead WHERE ID =: originalLead.id LIMIT 1];
                        
                    // Add LeadOwner to permissions
                    AccountPermissionSet.add(leadRec.OwnerID);
                        
                    if(leadobj.Exception_Flag__c==true){
                      AccountPermissionSet.add(leadobj.OwnerID);
                    }
                            
                    if(leadRec.Account__c!=null ){
                      //leadobj.Account__c = leadRec.Account__c;
                      AccountPermissionSet.add(leadRec.Account__r.OwnerID);
                        for(AccountTeamMember acctTeam :[SELECT ID,AccountId,UserId FROM  AccountTeamMember
                                                              WHERE AccountId =: leadRec.Account__c])
                        {
                          AccountPermissionSet.add(acctTeam.UserId); 
                        }
                                
                        //Query Account detail for populate data
                        originalAccount = [SELECT ID,Customer_Type__c,Customer_Name_PE_ENg__c, ParentId , Suggested_Sub_Segment__c 
                                                   ,Name, Mobile_Number_PE__c,phone, ID_Type_PE__c,OwnerID
                                                   ,ID_Number_PE__c,Primary_Address_Line_1_PE__c,Primary_Address_Line_2_PE__c,Primary_Address_Line_3_PE__c
                                                   ,Province_Primary_PE__c,Zip_Code_Primary_PE__c,Country_Primary_PE__c
                                                   ,Industry,Sales_amount_per_year__c,No_of_years_business_run__c,Branch_and_Zone__c
                                                   ,TMB_Employee_ID__c,TMB_Employee_Name__c,Remark__c,Rating,Industry__c
                                                   ,Group__c,Branch_Referred__c,Suggested_Segment__c
                                                    ,Email_Address_PE__c,Primary_Phone_Ext_PE__c
                                                
                                                  FROM Account
                                                  WHERE ID =:leadRec.Account__c
                                                  LIMIT 1];
                        //Add OwnerID to permissionset    
                        AccountPermissionSet.add(originalAccount.OwnerId);
                        
                        isPopulateAccountData = true;
                                
                    }else{
                      isPopulateLeadData = true;
                    }
                }
                
                
                //Stamp last 3 digits
                //
                if(leadobj.ID_Number__c !=null){
                    String IDNumber =  leadobj.ID_Number__c;
                    //leadobj.ID_REGEX__c =  IDnumber.substring(IDNumber.length()-3, IDNumber.length());
                    
                }
            }
            System.debug('isDuplicated :'+isDuplicated);
            System.debug('isRequireToCheckDup :'+isRequireToCheckDup);    
            System.debug('displayAction :'+displayAction);   
            System.debug('leadobj.Account__c:  '+leadobj.Account__c);
            System.debug('AccountPermissionSet: '
                         +AccountPermissionSet.contains(leadobj.OwnerId)) ;
            System.debug('isCommercialLead: ' 
                         + isCommercialLead );
            System.debug('Lead Owner ID :'+leadobj.OwnerId);
            System.debug('AccountPermissionSet: '+AccountPermissionSet);
            System.debug('Exception_Flag__c :'+leadobj.Exception_Flag__c);
            
            if(isDuplicated 
               && displayAction == 'Create' 
               && 
               ((!AccountPermissionSet.contains(leadobj.OwnerId) && !isCommercialLead)
               || (isCommercialLead && Leadobj.Account__c ==null))
              )
            {
              System.debug('Lead is Duplicated in the system');
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6003').Status_Message__c));
                return null;
            }else 
            {   
              if(isPopulateAccountData){
                           
                        //Populate Data from Original Account record

                        leadObj.Company = originalAccount.Name;
                        leadObj.Customer_Name_EN__c = originalAccount.Customer_Name_PE_Eng__c;
                        leadObj.Customer_Type__c = originalAccount.Customer_Type__c;
                        leadobj.ID_Type__c = originalAccount.ID_Type_PE__c;
                        leadobj.ID_Number__c = originalAccount.ID_Number_PE__c;
                        //leadobj.TMB_Cust_ID__c = originalAccount.TMB_Customer_ID_PE__c;
                        leadobj.Account__c = originalAccount.id;
                        leadObj.Mobile_No__c = originalAccount.Mobile_Number_PE__c;
                        leadobj.Office_No__c = originalAccount.Phone;
                        leadobj.Ext__c = originalAccount.Primary_Phone_Ext_PE__c;
                        leadobj.Email__c = originalAccount.Email_Address_PE__c;
                        leadobj.Address_Line_1__c = originalAccount.Primary_Address_Line_1_PE__c=='None'?'':originalAccount.Primary_Address_Line_1_PE__c;
                        leadobj.Address_Line_2__c = originalAccount.Primary_Address_Line_2_PE__c=='None'?'':originalAccount.Primary_Address_Line_2_PE__c;
                        leadobj.Address_Line_3__c = originalAccount.Primary_Address_Line_3_PE__c=='None'?'':originalAccount.Primary_Address_Line_3_PE__c;
                        leadobj.Province__c = originalAccount.Province_Primary_PE__c;
                        leadobj.Zipcode__c = originalAccount.Zip_Code_Primary_PE__c;
                        leadobj.Country__c = originalAccount.Country_Primary_PE__c;
                        //leadobj.Industry = originalAccount.Industry;
                        leadobj.Industry__c = originalAccount.Industry__c;
                        leadobj.Parent_Company__c = originalAccount.ParentId;
                        leadobj.Sales_amount_per_year__c = originalAccount.Sales_amount_per_year__c;
                        leadobj.Group__c = originalAccount.Group__c;
                        leadobj.No_of_Years_Business_Run__c = originalAccount.No_of_years_business_run__c;
                        leadobj.Preferred_Branch__c = originalAccount.Branch_and_Zone__c;
                            //If has permission or Exception Flag
                            if(AccountPermissionSet.contains(Leadobj.OwnerId)){
                                System.debug('CHANGE TO COMMERCIAL ACCOUNT');
                                leadObj.RecordTypeId = AccountRecordType.id;
                            }else{
                                isDisqualified =true;
                                System.debug('UNQUALIFIED BY DUPLICATED ACCOUNT');
                                //Unqualified because do not have permissions
                                leadObj.Status = 'Unqualified';
                                leadobj.Unqualified_Rejected_List__c = 'Owned by another RM';
                                leadobj.Unqualified_Reasons__c = 'Owned by another RM';
                                leadObj.RecordTypeId = CompletedRecordType.id;
                            }
                        
                }
  
                if(isPopulateLeadData){  
                  //Populate Data from original lead
                    /* leadObj.Customer_Type__c = leadRec.Customer_Type__c;
                            leadObj.Customer_Name_EN__c = leadRec.Customer_Name_EN__c;
                            leadObj.Company = leadRec.Company;
                            leadObj.Mobile_No__c = leadRec.Mobile_No__c;
                            leadobj.Office_No__c = leadRec.Office_No__c;
                            leadobj.ID_Type__c = leadRec.ID_Type__c;
                            leadobj.ID_Number__c = leadRec.ID_Number__c;
                            leadobj.Address_Line_1__c = leadRec.Address_Line_1__c=='None'?'':leadRec.Address_Line_1__c;
                            leadobj.Address_Line_2__c = leadRec.Address_Line_2__c=='None'?'':leadRec.Address_Line_2__c;
                            leadobj.Address_Line_3__c = leadRec.Address_Line_3__c=='None'?'':leadRec.Address_Line_3__c;
                            leadobj.Province__c = leadRec.Province__c;
                            leadobj.Zipcode__c = leadRec.Zipcode__c;
                            leadobj.Country__c = leadRec.Country__c;
                            leadobj.Industry = leadRec.Industry;
                            leadobj.Sales_amount_per_year__c = leadRec.Sales_amount_per_year__c;
                            leadobj.No_of_Years_Business_Run__c = leadRec.No_of_Years_Business_Run__c;
                            */
                            
                            
                                                        
                             //if has permission and not Commercial Lead
                             //&& !isCommercialLead
                            /* if(AccountPermissionSet.contains(leadobj.OwnerId)
                                && !isCommercialLead ){
                                    System.debug('CHANGE TO COMMERCIAL ACCOUNT');
                                leadObj.RecordTypeId = AccountRecordType.id;
                            }else{*/
                    System.debug('UNQUALIFIED BY LEAD');
                    //Do not have permission so Unqualified Lead
                    leadobj.Status ='Unqualified';
                    leadobj.Unqualified_Rejected_List__c = 'Owned by another RM';
                    leadobj.Unqualified_Reasons__c = 'Owned by another RM';
                     
                    leadObj.RecordTypeId = CompletedRecordType.id;
                    isDisqualified = true;
                         //   }
                            
                            
                 } 
                   
                 if(isFindDuplicate
                      &&leadobj.ID_Type__c !=null
                        &&Leadobj.ID_Number__c !=null
                     )
                 {
                       
                       if(isDisqualified){
                           ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6003').Status_Message__c));
                       }else{
                           ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Lead has passed duplicate check.'));

                       }
                   } 
                   
                   //Check Referral Condition
                   if(isReferralOwner == false){
                       ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.RTL_Referral_ERR012));
                       return null;
                   }else if(isReferralHasCust == true){
                       ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.RTL_Referral_ERR002));
                       return null;
                   }else if(isReferralTypeProductValid == false){
                       ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.RTL_Referral_ERR021));
                       return null;
                   }
                   else if(isReferralValid == false){
                       ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.RTL_Referral_ERR010));
                       return null;
                   }else if(isReferralTypeService == true){
                       ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.RTL_Referral_ERR016));
                       return null;

                   }else if(isReferralHasLead == true){
                       ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.RTL_Referral_ERR011));
                       return null;
                   }
                   
               
                if (displayAction == 'Create'){
                    insert leadObj;
                }else{
                   update leadObj;
                }
                //return null;
                   if(isFindDuplicate){
                     return null;  
                   }else{
                        return new pageReference('/'+leadObj.id);
                   }
            }
            
          
           
        }catch(Exception e){
            Database.rollback(sp);
            /*ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            system.debug(ex);
            return null;*/
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            List<String> errormessageList = e.getMessage().split(',');
            String errorMessage = '';
            if(errormessageList.size()>1){
                errorMessage = errormessageList.get(1).replace(': []','');
            }else{
                errorMessage = errormessageList.get(0).replace(': []','');
            }
            System.debug('errormessage : '+errormessage);
            if(errormessage.containsIgnoreCase('Invalid Mobile phone number') && leadObj.Mobile_No__c !=null && leadObj.Phone__c !=null){
                errormessage = 'Mobile No.: '+e.getMessage().split('N,').get(1).replace(': [Phone__c]','');
                System.debug('errormessage2 : '+errormessage);
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,errormessage)); 
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errormessage));
            }
            
            return null;
        }
    }
    
     private void getPassingParams(lead  leadobj){
        
        leadobj.customer_type__c = ApexPages.currentPage().getParameters().get('customer_type');
        leadobj.Company = ApexPages.currentPage().getParameters().get('company_name');
        leadobj.Mobile_No__c = ApexPages.currentPage().getParameters().get('mobile_number');
        leadobj.Office_No__c = ApexPages.currentPage().getParameters().get('office_number');
        leadobj.ID_Type__c = ApexPages.currentPage().getParameters().get('id_type');
        leadobj.ID_Number__c = ApexPages.currentPage().getParameters().get('id_number');
        
        
    }
    
    public void doActionMobile()
    {
        
        
         Savepoint sp = Database.setSavepoint();
        isChangeCustomer = false;
        isPopulateAccountData  = false;
        isPopulateLeadData = false;       
        
        try {
           
            
            leadObj.recordTypeId = recordTypeObj.id;
            if(leadObj.OwnerId ==null){
               leadObj.OwnerId = Userinfo.getUserId(); 
            }
            Boolean isCommercialLead = false;
             Set<ID> AccountPermissionSet =new Set<ID>();
             
             Boolean isDuplicated =false;
             boolean isRequireToCheckDup = false;
             isDisqualified =false;
            
                System.debug(leadobj.Customer_Type__c);
                System.debug(leadobj.ID_Type__c);
                System.debug(leadobj.ID_Number__c);
            
            //Populate Referral Information when Referral Changed
            if(beforeChangeLead.RTL_Referral__c != leadObj.RTL_Referral__c){
                populateReferralInfo(leadObj,displayAction,leadObj.RTL_Referral__c);
            }
            
            
           //Check Create with ID Type
            if(displayAction =='Create'){
                
                
                if(leadObj.Customer_Type__c !=null && leadObj.Customer_Type__c !=''
                && leadObj.ID_Type__c !=null && leadObj.ID_Type__c !=''
                  && leadObj.ID_Number__c !=null && leadObj.ID_Number__c !=''
                  ){
                    isRequireToCheckDup = true;
                }
            
                System.debug('leadObj :'+leadObj.ID_Number__c);
                // Check Update and Change ID 
            }else if(displayAction =='Update'){
                
                if(leadObj.Customer_Type__c != beforeChangeLead.Customer_Type__c 
                  || leadObj.ID_Type__c != beforeChangeLead.ID_Type__c 
                  || leadObj.ID_Number__c != beforeChangeLead.ID_Number__c
                  ){
                    isRequireToCheckDup = true;
                }
                
                if(leadobj.isBypassDuplicateCheck__c
                  && leadObj.ID_Type__c !=null
                  && leadObj.ID_Number__c !=null ){
                     isRequireToCheckDup = true;
                }
                
                if(isFindDuplicate){
                    isRequireToCheckDup = true;
                }
            }
            
            
            //Check Account Link has been changed
            if(displayAction =='Update'
              && beforeChangeLead.Account__c != leadObj.Account__c){
                isChangeCustomer = true;
            }
            
            
            
           
            //Perform Check Dup
            if((isRequireToCheckDup|| isChangeCustomer)){
                 Map<Integer,CommercialDuplicateCheck.LeadWrapper> leadwrapperMap = 
                CommercialDuplicateCheck.DuplicateCheckLeadSingleRecord(leadObj,beforeChangeLead);
                
                CommercialDuplicateCheck.LeadWrapper LeadWrapper = leadwrapperMap.get(0);
                    
                
                System.debug('isChangeCustomer : '+isChangeCustomer);
                System.debug('LeadWrapper : '+LeadWrapper);
                
                //Check Lead is CommercialLead or Not
                if(leadobj.RecordTypeId == CommercialLeadType.id){
                                isCommercialLead = true;                            
                        }
                
                
                
                    //IF Found Duplicated with Account
                    if((LeadWrapper.isfoundDuplicate && LeadWrapper.OrgininalrecordType=='Account') || isChangeCustomer){
                        ID AcctID;
                        isDuplicated = true;
                        Account acct = (Account)LeadWrapper.Originalrecord;
                        //Set Account ID
                        if(LeadWrapper.isfoundDuplicate && LeadWrapper.OrgininalrecordType=='Account' && leadobj.Account__c == null){
                          AcctID = acct.id;  
                        }else{
                            //in case change Link to Account
                          AcctID = leadobj.Account__c;
                        }
                        
                         //Query Account detail for populate data
                           originalAccount = [SELECT ID,Customer_Type__c,Customer_Name_PE_ENg__c, ParentId, Suggested_Sub_Segment__c  
                                                   ,Name, Mobile_Number_PE__c,phone, ID_Type_PE__c,OwnerID
                                                   ,ID_Number_PE__c,Primary_Address_Line_1_PE__c,Primary_Address_Line_2_PE__c,Primary_Address_Line_3_PE__c
                                                   ,Province_Primary_PE__c,Zip_Code_Primary_PE__c,Country_Primary_PE__c
                                                   ,Industry,Sales_amount_per_year__c,No_of_years_business_run__c
                                                   ,TMB_Employee_ID__c,TMB_Employee_Name__c,Remark__c,Rating,Industry__c
                                                   ,Group__c,Branch_Referred__c,Suggested_Segment__c,Branch_and_Zone__c
                                                    ,Email_Address_PE__c,Primary_Phone_Ext_PE__c
                                                FROM Account
                                                  WHERE ID =:AcctID
                                                  LIMIT 1];
                       //Add OwnerID to permissionset    
                        AccountPermissionSet.add(originalAccount.OwnerId);
                        
                        if(leadobj.Exception_Flag__c==true){
                             AccountPermissionSet.add(leadobj.OwnerID);
                        }
                        
                        
                            //Add AccountTeaam to permissionset
                        for(AccountTeamMember acctTeam :[SELECT ID,AccountId,
                             UserId FROM  AccountTeamMember
                                                          WHERE AccountId =: originalAccount.id]){
                                                             AccountPermissionSet.add(acctTeam.UserId); 
                                                          }
                        
                        isCommercialLead =false;
                        isPopulateAccountData =true;
                       
                        
                         
                        
                        //In case of not found any account but found lead
                    }
                  else if((LeadWrapper.isfoundDuplicate && LeadWrapper.OrgininalrecordType=='Lead')){
                        
                         Lead originalLead = (Lead)LeadWrapper.Originalrecord;
                          isDuplicated =true;
                        
                         leadRec = [SELECT id, Account__c, OwnerID, RecordTypeID,Account__r.OwnerID,
                                                      Name, Customer_Type__c ,Company ,Mobile_No__c,Office_No__c,
                                                    Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,
                                                    Province__c,Zipcode__c,Country__c,Industry,Sales_amount_per_year__c,
                                                    No_of_Years_Business_Run__c,
                                                     ID_Type__c, ID_Number__c, Customer_Name_EN__c
                                           FROM Lead WHERE ID =: originalLead.id LIMIT 1];
                        
                        // Add LeadOwner to permissions
                            AccountPermissionSet.add(leadRec.OwnerID);
                        
                        if(leadobj.Exception_Flag__c==true){
                             AccountPermissionSet.add(leadobj.OwnerID);
                        }
                            
                            if(leadRec.Account__c!=null ){
                                //leadobj.Account__c = leadRec.Account__c;
                                AccountPermissionSet.add(leadRec.Account__r.OwnerID);
                                 for(AccountTeamMember acctTeam :[SELECT ID,AccountId,
                                 UserId FROM  AccountTeamMember
                                                              WHERE AccountId =: leadRec.Account__c]){
                                                                 AccountPermissionSet.add(acctTeam.UserId); 
                                                              }
                                
                                 //Query Account detail for populate data
                           originalAccount = [SELECT ID,Customer_Type__c,Customer_Name_PE_ENg__c, ParentId , Suggested_Sub_Segment__c 
                                                   ,Name, Mobile_Number_PE__c,phone, ID_Type_PE__c,OwnerID
                                                   ,ID_Number_PE__c,Primary_Address_Line_1_PE__c,Primary_Address_Line_2_PE__c,Primary_Address_Line_3_PE__c
                                                   ,Province_Primary_PE__c,Zip_Code_Primary_PE__c,Country_Primary_PE__c
                                                   ,Industry,Sales_amount_per_year__c,No_of_years_business_run__c,Branch_and_Zone__c
                                                   ,TMB_Employee_ID__c,TMB_Employee_Name__c,Remark__c,Rating,Industry__c
                                                   ,Group__c,Branch_Referred__c,Suggested_Segment__c
                                                    ,Email_Address_PE__c,Primary_Phone_Ext_PE__c
                                                
                                                  FROM Account
                                                  WHERE ID =:leadRec.Account__c
                                                  LIMIT 1];
                       //Add OwnerID to permissionset    
                        AccountPermissionSet.add(originalAccount.OwnerId);
                        
                                isPopulateAccountData = true;
                                
                            }else{
                                 isPopulateLeadData = true;
                            }
                        
                       
                        
                    }
                
                
                //Stamp last 3 digits
                //
                if(leadobj.ID_Number__c !=null){
                    String IDNumber =  leadobj.ID_Number__c;
                    //leadobj.ID_REGEX__c =  IDnumber.substring(IDNumber.length()-3, IDNumber.length());
                    
                }
                
            }
            
            


            System.debug('isDuplicated :'+isDuplicated);
            System.debug('isRequireToCheckDup :'+isRequireToCheckDup);    
            System.debug('displayAction :'+displayAction);   
            System.debug('leadobj.Account__c:  '+leadobj.Account__c);
            System.debug('AccountPermissionSet: '
                         +AccountPermissionSet.contains(leadobj.OwnerId)) ;
            System.debug('isCommercialLead: ' 
                         + isCommercialLead );
            System.debug('Lead Owner ID :'+leadobj.OwnerId);
            System.debug('AccountPermissionSet: '+AccountPermissionSet);
            System.debug('Exception_Flag__c :'+leadobj.Exception_Flag__c);
            
            if(isDuplicated 
               && displayAction == 'Create' 
               && 
               ((!AccountPermissionSet.contains(leadobj.OwnerId) && !isCommercialLead)
               || (isCommercialLead && Leadobj.Account__c ==null))
              ){
                  System.debug('Lead is Duplicated in the system');
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Lead is Duplicated in the system'));
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6003').Status_Message__c));
            
               }else {
                   
                   
                 if(isPopulateAccountData){
                           
                        //Populate Data from Original Account record

                        leadObj.Company = originalAccount.Name;
                        leadObj.Customer_Name_EN__c = originalAccount.Customer_Name_PE_Eng__c;
                        leadObj.Customer_Type__c = originalAccount.Customer_Type__c;
                        leadobj.ID_Type__c = originalAccount.ID_Type_PE__c;
                        leadobj.ID_Number__c = originalAccount.ID_Number_PE__c;
                        //leadobj.TMB_Cust_ID__c = originalAccount.TMB_Customer_ID_PE__c;
                        leadobj.Account__c = originalAccount.id;
                        leadObj.Mobile_No__c = originalAccount.Mobile_Number_PE__c;
                        leadobj.Office_No__c = originalAccount.Phone;
                        leadobj.Ext__c = originalAccount.Primary_Phone_Ext_PE__c;
                        leadobj.Email__c = originalAccount.Email_Address_PE__c;
                        leadobj.Address_Line_1__c = originalAccount.Primary_Address_Line_1_PE__c=='None'?'':originalAccount.Primary_Address_Line_1_PE__c;
                        leadobj.Address_Line_2__c = originalAccount.Primary_Address_Line_2_PE__c=='None'?'':originalAccount.Primary_Address_Line_2_PE__c;
                        leadobj.Address_Line_3__c = originalAccount.Primary_Address_Line_3_PE__c=='None'?'':originalAccount.Primary_Address_Line_3_PE__c;
                        leadobj.Province__c = originalAccount.Province_Primary_PE__c;
                        leadobj.Zipcode__c = originalAccount.Zip_Code_Primary_PE__c;
                        leadobj.Country__c = originalAccount.Country_Primary_PE__c;
                        //leadobj.Industry = originalAccount.Industry;
                        leadobj.Industry__c = originalAccount.Industry__c;
                        leadobj.Parent_Company__c = originalAccount.ParentId;
                        leadobj.Sales_amount_per_year__c = originalAccount.Sales_amount_per_year__c;
                        leadobj.Group__c = originalAccount.Group__c;
                        leadobj.No_of_Years_Business_Run__c = originalAccount.No_of_years_business_run__c;
                        leadobj.Preferred_Branch__c = originalAccount.Branch_and_Zone__c;
                            //If has permission or Exception Flag
                            if(AccountPermissionSet.contains(Leadobj.OwnerId)){
                                System.debug('CHANGE TO COMMERCIAL ACCOUNT');
                                leadObj.RecordTypeId = AccountRecordType.id;
                            }else{
                                isDisqualified =true;
                                System.debug('UNQUALIFIED BY DUPLICATED ACCOUNT');
                                //Unqualified because do not have permissions
                                leadObj.Status = 'Unqualified';
                                leadobj.Unqualified_Rejected_List__c = 'Owned by another RM';
                                leadobj.Unqualified_Reasons__c = 'Owned by another RM';
                                leadObj.RecordTypeId = CompletedRecordType.id;
                            }
                        
                        }
                  
                   
                 if(isPopulateLeadData){
                            
                           
                            //Populate Data from original lead
                           /* leadObj.Customer_Type__c = leadRec.Customer_Type__c;
                            leadObj.Customer_Name_EN__c = leadRec.Customer_Name_EN__c;
                            leadObj.Company = leadRec.Company;
                            leadObj.Mobile_No__c = leadRec.Mobile_No__c;
                            leadobj.Office_No__c = leadRec.Office_No__c;
                            leadobj.ID_Type__c = leadRec.ID_Type__c;
                            leadobj.ID_Number__c = leadRec.ID_Number__c;
                            leadobj.Address_Line_1__c = leadRec.Address_Line_1__c=='None'?'':leadRec.Address_Line_1__c;
                            leadobj.Address_Line_2__c = leadRec.Address_Line_2__c=='None'?'':leadRec.Address_Line_2__c;
                            leadobj.Address_Line_3__c = leadRec.Address_Line_3__c=='None'?'':leadRec.Address_Line_3__c;
                            leadobj.Province__c = leadRec.Province__c;
                            leadobj.Zipcode__c = leadRec.Zipcode__c;
                            leadobj.Country__c = leadRec.Country__c;
                            leadobj.Industry = leadRec.Industry;
                            leadobj.Sales_amount_per_year__c = leadRec.Sales_amount_per_year__c;
                            leadobj.No_of_Years_Business_Run__c = leadRec.No_of_Years_Business_Run__c;
                            */
                            
                            
                                                        
                             //if has permission and not Commercial Lead
                             //&& !isCommercialLead
                            /* if(AccountPermissionSet.contains(leadobj.OwnerId)
                                && !isCommercialLead ){
                                    System.debug('CHANGE TO COMMERCIAL ACCOUNT');
                                leadObj.RecordTypeId = AccountRecordType.id;
                            }else{*/
                                System.debug('UNQUALIFIED BY LEAD');
                                //Do not have permission so Unqualified Lead
                                leadobj.Status ='Unqualified';
                                leadobj.Unqualified_Rejected_List__c = 'Owned by another RM';
                                leadobj.Unqualified_Reasons__c = 'Owned by another RM';
                                leadObj.RecordTypeId = CompletedRecordType.id;
                     isDisqualified = true;
                         //   }
                            
                            
                        } 
                   
                   
                   if(isFindDuplicate){
                       leadobj.isBypassDuplicateCheck__c = false;
                       if(isDisqualified){
                           ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6003').Status_Message__c));
                       }else{
                           ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Lead has passed duplicate check.'));

                       }
                   }
                   
                   //Check Referral Condition
                   if(isReferralOwner == false){
                       ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.RTL_Referral_ERR012));
                   }else if(isReferralHasCust == true){
                       ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.RTL_Referral_ERR002));
                   }else if(isReferralTypeProductValid == false){
                       ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.RTL_Referral_ERR021));
                   }else if(isReferralValid == false){
                       ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.RTL_Referral_ERR010));
                   }else if(isReferralTypeService == true){
                       ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.RTL_Referral_ERR016));
                   }
                   else if(isReferralHasLead == true){
                       ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.RTL_Referral_ERR011));
                   }
                   
               
                if (displayAction == 'Create'){
                    insert leadObj;
                }else{
                   update leadObj;
                }
                launchNextpage = true;
            }
            
          
           
        }catch(Exception e){
            Database.rollback(sp);
            /*ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            system.debug(ex);
            return null;*/
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            List<String> errormessageList = e.getMessage().split(',');
            String errorMessage = '';
            if(errormessageList.size()>1){
                errorMessage = errormessageList.get(1).replace(': []','');
            }else{
                errorMessage = errormessageList.get(0).replace(': []','');
            }
            System.debug('errormessage : '+errormessage);
            if(errormessage.containsIgnoreCase('Invalid Mobile phone number') && leadObj.Mobile_No__c !=null && leadObj.Phone__c !=null){
                errormessage = 'Mobile No.: '+e.getMessage().split('N,').get(1).replace(': [Phone__c]','');
                System.debug('errormessage2 : '+errormessage);
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,errormessage)); 
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
            
        }
    }
    
    private void populateReferralInfo(Lead leadObj,String action,String referralId){
        Map<String,String> channelLeadSourceMap = RTL_ReferralAssignUtility.channelLeadSourceMap;
        if(referralId != null){
            isReferralValid = true;
            isReferralHasCust = false;
            isReferralOwner = true;
            isReferralHasLead = false;
            isReferralTypeService = false;
            isReferralTypeProductValid = true;
          RTL_Referral__c referral = [SELECT Id,Name,RTL_Mobile1__c,RTL_FirstName__c,RTL_LastName__c,RTL_Title__c,RTL_Ext__c,
                                  RTL_Position__c,RTL_Sales_Amount_Per_Year__c,RTL_Company__c,RTL_Email__c,RTL_Office_Number__c,
                                  RTL_Comment__c,RTL_EmployeeId__c,RTL_Employee_Name__c,RTL_Account_Name__c,OwnerId,
                                  RTL_Preferred_Branch__c,RTL_Branch__c,RTL_Phone1__c,RTL_Stage__c,RTL_Refer_Branch_Name__c,RTL_Type__c,
                                  RecordType.DeveloperName,RTL_Channel_Segment__c,(SELECT Id,Name FROM Leads__r)
                              FROM RTL_Referral__c WHERE ID=:referralId LIMIT 1 ];
          leadObj.RTL_Referral__c = referralId;
            if (referral.OwnerId != System.UserInfo.getUserId()){
                isReferralOwner = false;
            }
            else if(referral.RTL_Account_Name__c != null){
                isReferralHasCust = true;
            } 
            //Error if type = 'To Product Team' and Stage != 'Closed (Service Completed)','New',In progress & Contact','Closed (Interested)'
            else if(referral.RTL_Type__c == 'To Product Team (เพื่อส่งให้ทีม Product)' && referral.RTL_Stage__c != 'New' && referral.RTL_Stage__c != 'In progress_Contacted' &&
                referral.RTL_Stage__c != 'Closed (Service Completed)'){
                //You can create a new opportunity when the referral's stage is "New","Contacted & In Progress", or "Closed (Service Completed)" only.
                isReferralTypeProductValid = false;

            }else if(referral.RTL_Type__c != 'To Product Team (เพื่อส่งให้ทีม Product)' && referral.RTL_Stage__c != 'New' && referral.RTL_Stage__c != 'In progress_Contacted' ){
                //Cannot attached opportunity if referral is closed (lost) and type != To Product Team
                isReferralValid = false;
            }
            else if(referral.RTL_Type__c == 'Account Opening/Service (เพื่อเปิดบัญชี / สมัครบริการ)'){
                   isReferralTypeService = true;
            }
            else if(referral.Leads__r.size() > 0){
                isReferralHasLead = true;
            }
     
          if(action == 'Create'){
            leadObj.LastName = assignValue(leadObj.LastName,referral.RTL_LastName__c);
              leadObj.Salutation = assignValue(leadObj.Salutation,referral.RTL_Title__c);
              leadObj.FirstName = assignValue(leadObj.FirstName,referral.RTL_FirstName__c);
              leadObj.Phone__c = assignValue(leadObj.Phone__c,referral.RTL_Mobile1__c);
              leadObj.Ext__c = assignValue(leadObj.Ext__c,referral.RTL_Ext__c);
              leadObj.Company = assignValue(leadObj.Company,referral.RTL_Company__c==null?referral.RTL_FirstName__c+' '+referral.RTL_LastName__c:referral.RTL_Company__c);
              leadObj.Title = assignValue(leadObj.Title,referral.RTL_Position__c);
              leadObj.Office_No__c = assignValue(leadObj.Office_No__c,referral.RTL_Phone1__c);
                leadObj.Mobile_No__c = assignValue(leadObj.Mobile_No__c,referral.RTL_Mobile1__c);
              leadObj.Email__c = assignValue(leadObj.Email__c,referral.RTL_Email__c);
              leadObj.Remark__c = assignValue(leadObj.Remark__c,referral.RTL_Comment__c);
              leadObj.Preferred_Branch__c = assignValue(leadObj.Preferred_Branch__c,referral.RTL_Preferred_Branch__c);  
          }
          //Referer Information
          leadObj.Referral_Staff_ID__c = assignValue(leadObj.Referral_Staff_ID__c,referral.RTL_EmployeeID__c);
          leadObj.Referral_Staff_Name__c = assignValue(leadObj.Referral_Staff_Name__c,referral.RTL_Employee_Name__c);           
          leadObj.Status = 'Contacted';

          String leadSource = 'Refer from Branch';
          
          //CR Referral Enhancement RQ-008 Add new recordtype 'Refer within Commercial'
          if(referral.RecordType.DeveloperName == 'Refer_within_Commercial'|| referral.RecordType.DeveloperName == 'Closed_Refer_within_Commercial'){
            leadSource = 'Refer within Commercial';
            if(channelLeadSourceMap.containsKey(referral.RTL_Channel_Segment__c)){
                leadSource = channelLeadSourceMap.get(referral.RTL_Channel_Segment__c);
            }
            // if(referral.RTL_Channel_Segment__c == 'Web'){
            //   leadSource = 'Website';
            // }
            // if(referral.RTL_Channel_Segment__c == 'Biztouch'){
            //   leadSource = 'Biztouch';
            // }
            // if(referral.RTL_Channel_Segment__c == 'OLAP'){
            //   leadSource = 'OLAP';
            // }
            // //CR OLAP Phase2 : 15 May 2018 , add channel 'OLAP-Lead'
            // if(referral.RTL_Channel_Segment__c == 'OLAP-Lead'){
            //   leadSource = 'OLAP-Lead';
            // }
          }            
          leadObj.LeadSource = assignValue(leadObj.LeadSource,leadSource);

          leadObj.Contacted_Flag__c  = true;
          leadObj.Pre_screening_Result__c = 'Passed';
          if(branchNameMap.containsKey(referral.RTL_Refer_Branch_Name__c )){
            leadObj.Branch_Referred__c = branchNameMap.get(referral.RTL_Refer_Branch_Name__c ).id;
          }
        }else{
            leadObj.Referral_Staff_ID__c = null;
          leadObj.Referral_Staff_Name__c = null;
        }
        
    }
    
    private static String assignValue(String existingValue,String newValue){
        if(existingValue == null)
            return newValue;
        return existingValue;
    }
    
    public Pagereference viewDetail(){
        PageReference LeadPage;
        LeadPage = new ApexPages.StandardController(leadObj).view();
        LeadPage.setRedirect(true);          
        return LeadPage; 
    }
    public Pagereference cancelSalesConsole(){
        PageReference LeadPage;
        LeadPage = new PageReference('/apex/searchProspectEXV5');  
        LeadPage.setRedirect(true);
        return LeadPage; 
    }
}