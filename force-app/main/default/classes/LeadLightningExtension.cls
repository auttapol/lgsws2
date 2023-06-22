public without sharing class LeadLightningExtension {
    public static lead afterEditLead {get;set;}
    public static lead beforeEditLead {get;set;}
    public static boolean isChangeCustomer {get;set;}
    public static boolean isPopulateAccountData {get;set;}
    public static boolean isPopulateLeadData {get;set;}
    public static boolean isHasPermission {get;set;}
    public static boolean isFindDuplicate {get;set;}
    @AuraEnabled public static boolean isDisqualified {get;set;}
    @AuraEnabled public static boolean isDuplicated {get;set;} 
    @AuraEnabled public static boolean isBypassDuplicateCheck {get;set;}
    @AuraEnabled public static boolean isAccDup {get;set;} 
    @AuraEnabled public static String isAccDupID {get;set;} 
    public static string displayAction {get;set;}
    public static string afterId {get;set;}
    public static string beforeId {get;set;}
    @AuraEnabled public static Account AccRec {get;set;}
    @AuraEnabled public static String myMsg {get;set;}
    @AuraEnabled public static boolean isReferralValid {get;set;} /*If Referral is New or Inprogress & Contacted*/
    @AuraEnabled public static boolean isReferralHasCust {get;set;} /*If Referral is attache with existing customer*/
    @AuraEnabled public static boolean isReferralOwner {get;set;} /*If curren user is referral owner*/
    @AuraEnabled public static boolean isReferralHasLead {get;set;}/*If referral already has lead attached*/
    @AuraEnabled public static boolean isReferralTypeService {get;set;}/*If referral type = Account Opening/Service*/
    @AuraEnabled public static boolean isReferralTypeProductValid {get;set;}
    public static Lead leadRec {get;set;}
    public static Account originalAccount {get;set;}

    //202108_INC0171769
    @AuraEnabled public static boolean acctNotMatch {get;set;}

    /*public RecordType recordTypeObj {
        get{
        
          if(recordTypeObj ==null){
              List<String> recordTypeNameList = new List<String>();
              // Need to create list to collect record type name.
              Schema.DescribeSObjectResult R = Lead.SObjectType.getDescribe();
              // You need to change the object name according to your requirement.
              List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
              for( Schema.RecordTypeInfo recordType : RT )
              {
                if(recordType.isAvailable())
                { 
                  // Check if the recordtype is visible for the current user or not. 
                  if(recordType.Name!='Master') {
                      recordTypeObj = [SELECT ID,Name from RecordType WHERE ID =: recordType.getRecordTypeID() LIMIT 1];
                  // Collect the record type name in list. 
                    }
                  }
              }   
          }
    
          return recordTypeObj;
      }set;
    }
    */
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


    public LeadLightningExtension(){
}


///edit Lead///
@AuraEnabled
    public static List<String> getLeadRecordByFields (Lead leadfields,Id RecordId){  
        System.debug(RecordId);
        isAccDup = false;
        isAccDupID = 'false';
        beforeEditLead = getLeadRecord(RecordId);        
        afterEditLead = leadfields.clone(true,true,true,true);
        isDisqualified = false;
        if(afterEditLead.Account__c!= null){
            Account acc = getAccountInfo(afterEditLead.Account__c);
            afterEditLead.Customer_Type__c = acc.Customer_Type__c;
            afterEditLead.ID_Type__c = acc.ID_Type_PE__c;
            afterEditLead.ID_Number__c = acc.ID_Number_PE__c;
            //checkAccountCondition(afterEditLead, beforeEditLead);
        }
        System.debug('id from fields '+afterEditLead.Id);
        System.debug(beforeEditLead.ID_Number__c);
        System.debug(afterEditLead.ID_Type__c);
        checkReferralCondition(afterEditLead,beforeEditLead);
        System.debug('hascustomer'+isReferralHasCust);
        System.debug('bypass dup' + beforeEditLead.isBypassDuplicateCheck__c);
        if(afterEditLead.ID_Number__c==beforeEditLead.ID_Number__c || afterEditLead.ID_Number__c== null ||afterEditLead.ID_Type__c == null){
            isDuplicated =false;
            if(beforeEditLead.isBypassDuplicateCheck__c == true){
                isBypassDuplicateCheck = true;
            }else{
                isBypassDuplicateCheck = false;
            }
            if(afterEditLead.ID_Number__c== null || afterEditLead.ID_Type__c == null){
                System.debug(beforeEditLead.ID_Type__c);
                System.debug(afterEditLead.ID_Type__c);
                System.debug(isBypassDuplicateCheck);
            }else{
                System.debug(isBypassDuplicateCheck);
                checkCondition();
            }
            System.debug('inmethod no'+isDuplicated);
            
        }
        else{
            if(beforeEditLead.isBypassDuplicateCheck__c == true){
                isBypassDuplicateCheck = true;
            }else{
                isBypassDuplicateCheck = false;
            }
            System.debug('Account' +afterEditLead.Parent_Company__c);
            checkCondition();
            System.debug('inmethod'+isDuplicated);
        }
        List<String> checklist = new List<String>();
        checklist.add(String.valueOf(isDuplicated));
        checklist.add(String.valueOf(isBypassDuplicateCheck));
        String refError = getReferralErrorMessage();
        System.debug('check ref '+referror);
        checklist.add(refError);
        checklist.add(String.valueOf(isAccDup));
        checklist.add(String.valueOf(isAccDupID));
        checklist.add(AccountRecordType.id);
        checklist.add(CommercialLeadType.id);
        checklist.add(String.valueOf(isDisqualified));
        checklist.add(CompletedRecordType.id);

        //202108_INC0171769
        checklist.add(String.valueOf(acctNotMatch));
        String acctError = getAcctErrorMessage();
        //System.debug('acctError '+acctError);
        checklist.add(acctError);

        System.debug('check edit list'+checklist);
        System.debug('check edit list'+checklist[3]=='null' + checklist[3]);
        System.debug('check edit list'+checklist[4]=='null'+ checklist[4]);
        return checklist ;
    }
    ///create Lead///
@AuraEnabled
    public static List<String> getLeadCreateRecordByFields (Lead leadfields){
        afterEditLead = leadfields.clone(true,true,true,true);
        beforeEditLead = new Lead();
        isAccDup = false;
        isAccDupID = 'false';
        isDisqualified = false;
        /*if(afterEditLead.Account__c!= null){
            Account acc = getAccountInfo(afterEditLead.Account__c);
            afterEditLead.Customer_Type__c = acc.Customer_Type__c;
            afterEditLead.ID_Type__c = acc.ID_Type_PE__c;
            afterEditLead.ID_Number__c = acc.ID_Number_PE__c;
            //checkAccountCondition(afterEditLead, beforeEditLead);
        }*/
        System.debug(afterEditLead.Account__c);
        System.debug(afterEditLead.RTL_Referral__c);
        checkReferralCondition(afterEditLead,beforeEditLead);
        System.debug('hascustomer'+isReferralHasCust);
        System.debug(afterEditLead.ID_Number__c);
        displayAction = 'Create';
        isHasPermission =true;
        System.debug('idtype' + afterEditLead.ID_Type__c);
        System.debug(afterEditLead.ID_Number__c);
        if(afterEditLead.ID_Number__c== null || afterEditLead.ID_Type__c==null){
            System.debug('no Id number value ');
            isDuplicated =false;
            System.debug('inmethod'+isDuplicated);
        }
        else{
            checkCondition();
            System.debug('inmethod'+isDuplicated);
        }
        List<String> checklist= new List<String>();
        checklist.add(String.valueOf(isDuplicated));
        String refError = getReferralErrorMessage();
        System.debug('check ref '+referror);
        checklist.add(refError);
        checklist.add(String.valueOf(isAccDup));
        checklist.add(String.valueOf(isAccDupID));
        checklist.add(AccountRecordType.id);
        checklist.add(CommercialLeadType.id);
        checklist.add(String.valueOf(isDisqualified));
        checklist.add(CompletedRecordType.id);
        System.debug('check '+checklist);
        return checklist;
    }


// get record in database
@AuraEnabled
    public static Lead getLeadRecord (Id editRecordId) {
        Lead editleadrec= new Lead();
        editleadrec = [SELECT  Id, Customer_Type__c, Salutation, firstname, lastname, company, Customer_Name_EN__c, ID_Type__c
        , ID_Number__c, Primary_Campaign__c, Mobile_No__c, Office_No__c, Ext__c, Email
        , Remark__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Province__c
        , Zipcode__c, Country__c, Rating, Parent_Company__c, Group__c, Total_Expected_Revenue__c
        , Industry, Sales_amount_per_year__c, No_of_Years_Business_Run__c, LeadSource
        , Other_Source__c, Branch_Referred__c, Preferred_Branch__c
        , RecordTypeId, Industry__c
        , Status, Decision_Map__c, Phone, Title
        , Referral_Staff_ID__c, Referral_Staff_Name__c
        , Account__c,Account__r.ID_Number_PE__c,Account__r.ID_Type_PE__c
        , Suggested_Team__c 
        , OwnerId
        , Phone__c
        , Email__c
        ,isBypassDuplicateCheck__c
        ,RTL_Referral__c,Link_Document__c, Other_Reason__c
        ,Lead_Segment__c FROM Lead where Id =:editRecordId];
        displayAction = 'Update';
        return editleadrec;

    }
//get Lead Record Type
    @AuraEnabled
    public static string getRecordTypeName(Id recordTypeId){
        String recordTypeName = [SELECT Id,Name from RecordType WHERE ID =:recordTypeId  LIMIT 1].Name;
        System.debug(recordTypeId);
        return recordTypeName;   
    }
//////////Condition from Lead ExtensionV2//////
@AuraEnabled
    public static void checkCondition(){

        //202108_INC0171769
        acctNotMatch = false;

        System.debug('Check Condition');
        isChangeCustomer = false;
        isPopulateAccountData  = false;
        isPopulateLeadData = false;
        Boolean isCommercialLead = false;
        Set<ID> AccountPermissionSet =new Set<ID>();
        
        isDuplicated =false;
        boolean isRequireToCheckDup = true;
        isDisqualified =false;
        System.debug('type');
        System.debug(afterEditLead.ID_Type__c);
        System.debug('number');
        System.debug(afterEditLead.ID_Number__c );
        if(displayAction =='Create'){
                               
            if(afterEditLead.Customer_Type__c !=null && afterEditLead.Customer_Type__c !=''
              && afterEditLead.ID_Type__c !=null && afterEditLead.ID_Type__c !='' && afterEditLead.ID_Type__c !='--None--'
                && afterEditLead.ID_Number__c !=null && afterEditLead.ID_Number__c !=''
              )
            {
                isRequireToCheckDup = true;
            }
        
            System.debug('leadObj :'+afterEditLead.ID_Number__c);
            System.debug('Checkdup :'+isRequireToCheckDup);
            
   
        }else if(displayAction =='Update'){
            if((afterEditLead.Customer_Type__c != beforeEditLead.Customer_Type__c 
            || afterEditLead.ID_Type__c != beforeEditLead.ID_Type__c 
            || afterEditLead.ID_Number__c != beforeEditLead.ID_Number__c
            ) && afterEditLead.ID_Number__c !=null
             && afterEditLead.ID_Type__c !=null
            )
            {
                isRequireToCheckDup = true;
            }
            if(afterEditLead.isBypassDuplicateCheck__c
                    && afterEditLead.ID_Type__c !=null
                    && afterEditLead.ID_Number__c !=null )
            {
                     isRequireToCheckDup = true;
            }
            if(displayAction =='Update'
                && beforeEditLead.Account__c != afterEditLead.Account__c)
            {
                isChangeCustomer = true;
            }
        }
        // check duplication
        if(isRequireToCheckDup||isChangeCustomer){
            System.debug('Checkdup :'+isRequireToCheckDup);
            afterEditLead.isBypassDuplicateCheck__c = false;
            Map<Integer,CommercialDuplicateCheck.LeadWrapper> leadwrapperMap = 
            CommercialDuplicateCheck.DuplicateCheckLeadSingleRecord(afterEditLead,beforeEditLead);
            CommercialDuplicateCheck.LeadWrapper LeadWrapper = leadwrapperMap.get(0);
            System.debug('isChangeCustomer : '+isChangeCustomer);
            System.debug('Checkdup :'+isRequireToCheckDup);
            System.debug('new ID '+afterEditLead.ID_Number__c);
            System.debug('old ID '+beforeEditLead.ID_Number__c);
            System.debug(CommercialLeadType.id);
            System.debug('leadWrap' + LeadWrapper.isfoundDuplicate);
            isCommercialLead = true;
            isAccDup = false;
            isAccDupID = 'false';                         
            //////// Perform check ID Dup//////////
            if((LeadWrapper.isfoundDuplicate && LeadWrapper.OrgininalrecordType=='Account') || isChangeCustomer){
                System.debug('leadWrap' + LeadWrapper.isfoundDuplicate +'account');
                System.debug('ischange'+isChangeCustomer);
                System.debug('LeadWrapp'+LeadWrapper.isfoundDuplicate);
                ID AcctID;
                isAccDup =true;
                Account acct = (Account)LeadWrapper.Originalrecord;

                if(acct == null || (beforeEditLead.Account__c != null && afterEditLead.ID_Number__c != beforeEditLead.Account__r.ID_Number_PE__c)){ //202108_INC0171769
                    acctNotMatch = true;                    
                }else{

                    isAccDupID = acct.Id;
                    //Set Account ID
                    Id tmpAccountId = afterEditLead.Account__c;
                    if(tmpAccountId == null) {
                        tmpAccountId = beforeEditLead.Account__c;             
                    }
    
                    if(LeadWrapper.isfoundDuplicate && LeadWrapper.OrgininalrecordType=='Account' && tmpAccountId == null ){
                        AcctID = acct.id;  
                    }else{
                            //in case change Link to Account
                        AcctID =tmpAccountId; 
                        System.debug(AcctID);
                    }
                    //Add OwnerID to permissionset   
                    originalAccount = getAccountInfo(AcctID);
                    isAccDupID = originalAccount.Id;
                    AccountPermissionSet.add(originalAccount.OwnerId);
                    System.debug(originalAccount.OwnerId);  
                    if(afterEditLead.Exception_Flag__c==true){
                        AccountPermissionSet.add(afterEditLead.OwnerID); 
                    }
                    for(AccountTeamMember acctTeam :[SELECT ID,AccountId,UserId FROM  AccountTeamMember
                                                                WHERE AccountId =: originalAccount.id]){
                        AccountPermissionSet.add(acctTeam.UserId); 
                        }
                    isCommercialLead =false;
                    isPopulateAccountData =true;
                    System.debug(acct);
                    System.debug('AccountPermissionSet: '+AccountPermissionSet.contains(afterEditLead.OwnerId));
                    System.debug(AccountPermissionSet);
                    System.debug(isAccDupID);
                }
                
            }
            if((LeadWrapper.isfoundDuplicate && LeadWrapper.OrgininalrecordType=='Lead')){

                Lead originalLead = (Lead)LeadWrapper.Originalrecord;
                isDuplicated =true;
                leadRec =   [SELECT id, Account__c, OwnerID, RecordTypeID,Account__r.OwnerID,
                            Name, Customer_Type__c ,Company ,Mobile_No__c,Office_No__c,
                            Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,
                            Province__c,Zipcode__c,Country__c,Industry,Sales_amount_per_year__c,
                            No_of_Years_Business_Run__c,
                            ID_Type__c, ID_Number__c, Customer_Name_EN__c
                            FROM Lead WHERE ID =: originalLead.id LIMIT 1];

                // Add LeadOwner to permissions
                AccountPermissionSet.add(leadRec.OwnerID);

                if(afterEditLead.Exception_Flag__c==true){
                    AccountPermissionSet.add(afterEditLead.OwnerID);
                }
                if(leadRec.Account__c!=null ){
                    //leadobj.Account__c = leadRec.Account__c;
                    AccountPermissionSet.add(leadRec.Account__r.OwnerID);
                    for(AccountTeamMember acctTeam :[SELECT ID,AccountId,
                                                     UserId FROM  AccountTeamMember 
                                                     WHERE AccountId =: leadRec.Account__c]){
                        AccountPermissionSet.add(acctTeam.UserId);
                    }
                    originalAccount =   [SELECT ID,Customer_Type__c,Customer_Name_PE_ENg__c, ParentId , Suggested_Sub_Segment__c 
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
                    isPopulateAccountData = true;                      
                }else{
                    isPopulateLeadData = true;
                }    
            }

            if((isDuplicated || isAccDup) && displayAction == 'Create' && 
               ((!AccountPermissionSet.contains(afterEditLead.OwnerId) && !isCommercialLead)
               || (isCommercialLead && afterEditLead.Account__c ==null))
              ){
                System.debug('hello');
                isDuplicated =true;
            }else{
                if(isPopulateAccountData){
                    if(AccountPermissionSet.contains(afterEditLead.OwnerId)){
                        System.debug('CHANGE TO COMMERCIAL ACCOUNT');
                    }else{
                        System.debug('UNQUALIFIED BY DUPLICATED ACCOUNT');
                        isDisqualified= true;
                    }
                }
                if(isPopulateLeadData){
                    System.debug('UNQUALIFIED BY LEAD');
                    isDisqualified = true;
                }
            }

            if(afterEditLead.ID_Number__c == beforeEditLead.ID_Number__c || 
                (!acctNotMatch && afterEditLead.ID_Number__c == beforeEditLead.Account__r.ID_Number_PE__c) ){
                isDuplicated =false;
                if(afterEditLead.ID_Type__c==beforeEditLead.ID_Type__c || 
                    (!acctNotMatch && afterEditLead.ID_Type__c == beforeEditLead.Account__r.ID_Type_PE__c) ){
                    isDisqualified = false;
                }
                
            }

            System.debug('new ID'+isDuplicated);
        }
    }
    //202108_INC0171769
    @AuraEnabled
    public static String getAcctErrorMessage(){
        myMsg = Status_Code__c.GetValues('6003a').Status_Message__c;
        return myMsg;
    }
    @AuraEnabled
    public static String getErrorMessage(){
        myMsg = Status_Code__c.GetValues('6003').Status_Message__c;
        return myMsg;
    }
    @AuraEnabled
    public static String getReferralErrorMessage(){
        System.debug(isReferralHasCust);
        System.debug(afterEditLead);
        
        if(isReferralOwner == false){
            myMsg = System.Label.RTL_Referral_ERR012;
        }else if(isReferralHasCust == true){
            myMsg = System.Label.RTL_Referral_ERR002;
        }else if(isReferralTypeProductValid == false){
            myMsg = System.Label.RTL_Referral_ERR021;
        }
        else if(isReferralValid == false){
            myMsg = System.Label.RTL_Referral_ERR010;
        }else if(isReferralTypeService == true){
            myMsg = System.Label.RTL_Referral_ERR016;
        }else if(isReferralHasLead == true){
            myMsg = System.Label.RTL_Referral_ERR011;
        }else{
            myMsg='No Referral Error';
        }

        return myMsg;
    }
    
    @AuraEnabled
    public static Boolean getBypassDuplicateCheck(){
        System.debug('isBypassDuplicateCheck' + isBypassDuplicateCheck);
        return isBypassDuplicateCheck;
    }
    @AuraEnabled
    public static Account getAccountInfo(Id AccId){
            AccRec = [SELECT ID,Customer_Type__c,Customer_Name_PE_ENg__c, ParentId , Suggested_Sub_Segment__c 
            ,Name, Mobile_Number_PE__c,phone, ID_Type_PE__c,OwnerID
            ,ID_Number_PE__c,Primary_Address_Line_1_PE__c,Primary_Address_Line_2_PE__c,Primary_Address_Line_3_PE__c
            ,Province_Primary_PE__c,Zip_Code_Primary_PE__c,Country_Primary_PE__c
            ,Industry,Sales_amount_per_year__c,No_of_years_business_run__c,Branch_and_Zone__c
            ,TMB_Employee_ID__c,TMB_Employee_Name__c,Remark__c,Rating,Industry__c
            ,Group__c,Branch_Referred__c,Suggested_Segment__c
            ,Email_Address_PE__c,Primary_Phone_Ext_PE__c
        FROM Account
        WHERE ID =:AccId
        LIMIT 1];
        System.debug(AccRec);
        return AccRec;
    }

    @AuraEnabled
    public static void checkReferralCondition(Lead afterEditLead,Lead beforeEditLead){
            isReferralValid = true;
            isReferralHasCust = false;
            isReferralOwner = true;
            isReferralHasLead = false;
            isReferralTypeService = false;
            isReferralTypeProductValid = true;
            
        if(afterEditLead.RTL_Referral__c !=null){
            RTL_Referral__c referral = [SELECT Id,Name,RTL_Mobile1__c,RTL_FirstName__c,RTL_LastName__c,RTL_Title__c,RTL_Ext__c,
                                  RTL_Position__c,RTL_Sales_Amount_Per_Year__c,RTL_Company__c,RTL_Email__c,RTL_Office_Number__c,
                                  RTL_Comment__c,RTL_EmployeeId__c,RTL_Employee_Name__c,RTL_Account_Name__c,OwnerId,
                                  RTL_Preferred_Branch__c,RTL_Branch__c,RTL_Phone1__c,RTL_Stage__c,RTL_Refer_Branch_Name__c,RTL_Type__c,
                                  RecordType.DeveloperName,RTL_Channel_Segment__c,(SELECT Id,Name FROM Leads__r)
                              FROM RTL_Referral__c WHERE ID=:afterEditLead.RTL_Referral__c LIMIT 1 ];
            System.debug(referral.RTL_Account_Name__c);
            System.debug(afterEditLead.RTL_Referral__c + ''+beforeEditLead.RTL_Referral__c);
            if (referral.OwnerId != afterEditLead.OwnerId){
                isReferralOwner = false;
            }
            else if(referral.RTL_Account_Name__c != null){
                isReferralHasCust = true;
                System.debug('have customer'+referral.RTL_Account_Name__c + isReferralHasCust);
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
            else if(afterEditLead.RTL_Referral__c != beforeEditLead.RTL_Referral__c){
                if(referral.Leads__r.size() > 0){
                    isReferralHasLead = true;
                    System.debug(referral.Leads__r+'lead');
                    System.debug(isReferralHasLead);
                }
                else{
                    isReferralHasLead = false;
                    System.debug(referral.Leads__r+ 'no lead');
                    System.debug(isReferralHasLead);
                }
            }
            
            System.debug('isReferralTypeProductValid'+isReferralTypeProductValid);
        }else{
            System.debug('isReferralTypeProductValid'+isReferralTypeProductValid);
        }
    }
    @AuraEnabled
    public static RTL_Referral__c populateReferralInfo(Id referralId){
        RTL_Referral__c referral = [SELECT Id,Name,RTL_Mobile1__c,RTL_FirstName__c,RTL_LastName__c,RTL_Title__c,RTL_Ext__c,
                                  RTL_Position__c,RTL_Sales_Amount_Per_Year__c,RTL_Company__c,RTL_Email__c,RTL_Office_Number__c,
                                  RTL_Comment__c,RTL_EmployeeId__c,RTL_Employee_Name__c,RTL_Account_Name__c,OwnerId,
                                  RTL_Preferred_Branch__c,RTL_Branch__c,RTL_Phone1__c,RTL_Stage__c,RTL_Refer_Branch_Name__c,RTL_Type__c,
                                  RecordType.DeveloperName,RTL_Channel_Segment__c,(SELECT Id,Name FROM Leads__r)
                              FROM RTL_Referral__c WHERE ID=:referralId LIMIT 1 ];
        return referral;
    }
    
    @AuraEnabled
    public static void linkCustomerBypass(Id leadId, Id accountId, Boolean disqualifiedFlag ){
        Lead leadrec= new Lead();
        leadrec = [SELECT  Id, Customer_Type__c, Salutation, firstname, lastname, company, Customer_Name_EN__c, ID_Type__c
        , ID_Number__c, Primary_Campaign__c, Mobile_No__c, Office_No__c, Ext__c, Email
        , Remark__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Province__c
        , Zipcode__c, Country__c, Rating, Parent_Company__c, Group__c, Total_Expected_Revenue__c
        , Industry, Sales_amount_per_year__c, No_of_Years_Business_Run__c, LeadSource
        , Other_Source__c, Branch_Referred__c, Preferred_Branch__c
        , RecordTypeId, Industry__c
        , Status, Decision_Map__c, Phone, Title
        , Referral_Staff_ID__c, Referral_Staff_Name__c
        , Account__c,Suggested_Team__c 
        , OwnerId
        , Phone__c
        , Email__c
        ,isBypassDuplicateCheck__c
        ,RTL_Referral__c,Link_Document__c, Other_Reason__c
        ,Lead_Segment__c FROM Lead where Id =:leadId];
        leadrec.Account__c = accountId;
        if(disqualifiedFlag == true){
            leadrec.RecordTypeId = CompletedRecordType.id; 
        }else{
            leadrec.RecordTypeId = AccountRecordType.id;
        }
        
        update leadrec;
    }

    @AuraEnabled
    public static Boolean checkAccess(Id leadId){
        Boolean isHasAccess = false;
        List<UserRecordAccess> RecordAccessList = [SELECT RecordId, HasEditAccess FROM UserRecordAccess 
                                             WHERE UserId =: UserInfo.getUserId() 
                                             AND RecordId =:LeadId];
            
        if(RecordAccessList.size()>0){
            for(UserRecordAccess ura : RecordAccessList){
                if(ura.HasEditAccess){
                    isHasAccess =true;
                }
                    
            }
        }
        return isHasAccess; 
        
    }
    @AuraEnabled
    public static void completeBypass(Id leadId){
        Lead leadrec= new Lead();
        leadrec = [SELECT  Id, Customer_Type__c, Salutation, firstname, lastname, company, Customer_Name_EN__c, ID_Type__c
        , ID_Number__c, Primary_Campaign__c, Mobile_No__c, Office_No__c, Ext__c, Email
        , Remark__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Province__c
        , Zipcode__c, Country__c, Rating, Parent_Company__c, Group__c, Total_Expected_Revenue__c
        , Industry, Sales_amount_per_year__c, No_of_Years_Business_Run__c, LeadSource
        , Other_Source__c, Branch_Referred__c, Preferred_Branch__c
        , RecordTypeId, Industry__c
        , Status, Decision_Map__c, Phone, Title
        , Referral_Staff_ID__c, Referral_Staff_Name__c
        , Account__c,Suggested_Team__c 
        , OwnerId
        , Phone__c
        , Email__c
        ,isBypassDuplicateCheck__c
        ,RTL_Referral__c,Link_Document__c, Other_Reason__c
        ,Lead_Segment__c FROM Lead where Id =:leadId];
        leadrec.RecordTypeId = CompletedRecordType.id;
        update leadrec;

        
    }
    /*
    @AuraEnabled
    public static void checkAccountCondition(Lead afterEditLead,Lead beforeEditLead){
        Set<ID> AccountPermissionSet =new Set<ID>();
        if(afterEditLead.Account__c!=beforeEditLead.Account__c){
            System.debug(afterEditLead.Account__c);
            System.debug(beforeEditLead.Account__c);
            if(afterEditLead.Account__c==null){
                isAccDup =false;
                isAccDupID = 'false';   
            }else{
                Map<Integer,CommercialDuplicateCheck.LeadWrapper> leadwrapperMap = 
                CommercialDuplicateCheck.DuplicateCheckLeadSingleRecord(afterEditLead,afterEditLead);
                CommercialDuplicateCheck.LeadWrapper LeadWrapper = leadwrapperMap.get(0);
                isChangeCustomer = true;
                System.debug(isChangeCustomer);
                if((LeadWrapper.isfoundDuplicate && LeadWrapper.OrgininalrecordType=='Account') || isChangeCustomer){
                    System.debug('ischange'+isChangeCustomer);
                    System.debug('LeadWrapp'+LeadWrapper.isfoundDuplicate);
                    ID AcctID;
                    isDuplicated = true;
                    isAccDup =true;
                    Account acct = (Account)LeadWrapper.Originalrecord;
                    //Set Account ID
                    if(LeadWrapper.isfoundDuplicate && LeadWrapper.OrgininalrecordType=='Account' && afterEditLead.Account__c == null){
                        AcctID = acct.id;  
                    }else{
                        //in case change Link to Account
                        AcctID = afterEditLead.Account__c;
                    }
                    //Add OwnerID to permissionset   
                    Account originalAccount = getAccountInfo(AcctID);
                    AccountPermissionSet.add(originalAccount.OwnerId);
                    
                    if(afterEditLead.Exception_Flag__c==true){
                        AccountPermissionSet.add(afterEditLead.OwnerID);
                    }
                    for(AccountTeamMember acctTeam :[SELECT ID,AccountId,UserId FROM  AccountTeamMember
                                                            WHERE AccountId =: originalAccount.id])
                        {
                        AccountPermissionSet.add(acctTeam.UserId); 
                        }
                    System.debug('AccountPermissionSet: '+AccountPermissionSet.contains(afterEditLead.OwnerId));
                    System.debug(AccountPermissionSet);
                    System.debug(isDuplicated);
                }
            }
        }else{

        }
        
    }*/
}