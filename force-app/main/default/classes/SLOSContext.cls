global without sharing class SLOSContext  {
    /*----------------------------------------------------------------------------------
          Author:        Keattisak Chinburarat
          Company:
          Description:   SLOS Context Layer for integration to  Mulesoft Services
          Inputs:        -
          Base Class:    -
          Test Class:    -
          History
          <Date>      <Authors Name>     <Brief Description of Change>
          2017-01-25  Keattisak.C        First initial class
    ----------------------------------------------------------------------------------*/
    global class SLOSRequest {
        public Opportunity m_opportunity;
        public List<OpportunityLineItem>  m_opplines ;
        public Account m_account;
        public User m_user;
        public MulesoftDTO m_mulesoftDto;
        public SLOSRequest(Opportunity oppt , List<OpportunityLineItem> lines) {
            m_opportunity   =  oppt;
            m_opplines      = lines;
            m_account       = getAccountById(oppt.AccountId);
            m_user          = getUserById(oppt.OwnerId);
            m_mulesoftDto   = new MulesoftDTO(m_opportunity, m_account, m_user);
        }
        public Account getAccountById(Id acctId) {

            if (null != acctId) { 
                return (Account)[Select Id , TMB_Customer_ID_PE__c, Name, ID_Number_PE__c, Customer_Type__c, ID_Type_PE__c,Account_Type__c, Customer_Name_PE_Eng__c,
                                 Mobile_Number_PE__c, Province_Primary_PE__c, Primary_Address_Line_3_PE__c, Primary_Address_Line_2_PE__c, Zip_Code_Primary_PE__c, Country_Primary_PE__c, 
                                 Sales_amount_per_year__c, No_of_years_business_run__c from Account where id = : acctId limit 1] ;
            }
            return new Account();
        }
        public User getUserById(Id usrId) {
            if (null !=  usrId) {
                return (User)[SELECT Email, Id, Region__c, Region_Code__c, Zone_Code__c, Zone__c, UserType, UserRoleId, Employee_ID__c FROM User where id = : usrId limit 1];
            }
            return new User();
        }
    }
    global class SLOSRespond {
        public string Message {get; set;}
        public string ErrorCode   {get; set;}
        public boolean Status {get; set;}  // true or false
        public string AppRefNo {get; set;}
    }
    global class MulesoftDTO {
        public string jobName {get; set;}         //=> FIX ='NC'
        public string caNumber {get; set;}
        public string customerId {get; set;}      //=>   account.TMB_Customer_ID_PE__c
        public string customerName {get; set;}    //=>   account.Name
        public string citizenId {get; set;}       //=>   account.ID_Number_PE__c:Account’s ID Number (when ID Type = Citizen ID)
        //public string customerType {get; set;}    //=>   account.Customer_Type__c
        public integer customerType {get; set;}   //=>   Individual=1,Juristic=2,other=1
        //public string requestType {get; set;}     //=>   FIX =' New Credit '
        public integer requestType {get; set;}     //=>   FIX = 1
        public string bdmId {get; set;}           //=>   User:Employee ID //account.ID_Number_PE__c:Account’s ID Number (when ID Type = BRN ID)
        public string hubCode {get; set;}         //=>   User:User’s Zone Code / Team Code
        public string regionCode {get; set;}      //=>   User:User’s Region Code / Group Code
        public string appInDateBDM {get; set;}    //=>   Opportunity’s Submit Date
        public string appRefNumber {get; set;}    //=>   Opportunity's App Ref Number
        public string parallel_c {get; set;}      //=>   FIX = 'N'
        /*SLS Mobility*/
        public string mobileNo {get; set;}     //=>   account.Mobile_Number_PE__c
        public string province {get; set;}        //=>   account.Province_Primary_PE__c
        public string district {get; set;}        //=>   account.Primary_Address_Line_3_PE__c
        public string subDistrict {get; set;}     //=>   account.Primary_Address_Line_2_PE__c
        public string zipCode {get; set;}         //=>   account.Zip_Code_Primary_PE__c
        public string country {get; set;}         //=>   account.Country_Primary_PE__c
        public decimal saleAmount {get; set;}     //=>   account.Sales_amount_per_year__c
        public integer yearInBusiness {get; set;}  //=>   account.No_of_years_business_run__c
        public integer productGroupId {get; set;}  //=>   Opportunity's Name of Product Group (SLS): Host_Code_Product_Group__c
        public SLOSSoapService.FacilityInfos_element facilityInfos {get; set;}
        public MulesoftDTO(Opportunity oppt, Account acct , User usr) {
            mapping(oppt, acct, usr);
        }
        public void mapping(Opportunity oppt, Account acct , User usr) {
            jobName = 'NC';
            requestType = 1;//'New Credit';
            parallel_c = 'N';
            caNumber = oppt.CAID__c;
            appRefNumber = (!string.isBlank(oppt.App_Ref_Number__c)) ? oppt.App_Ref_Number__c : '';
            Datetime dt = (oppt.Expected_submit_date__c != null) ? oppt.Expected_submit_date__c : datetime.now();
            appInDateBDM = (string) dt.format('yyyy-MM-dd');
            /**************************************
            *  Account INFO
            ***************************************/
            if (null != acct &&  null != acct.id) {

                /*
                if( acct.Account_Type__c == 'Existing Customer'){       
                    if(acct.ID_Type_PE__c == null && acct.ID_Number_PE__c == null){     
                        if(acct.Customer_Type__c =='Individual') {
                            acct.ID_Type_PE__c ='Citizen ID';   
                        }else if(acct.Customer_Type__c =='Juristic'){
                            acct.ID_Type_PE__c ='BRN ID';   
                        }
                        acct.ID_Number_PE__c ='1111111111111';
                    }
                }
                */
                
                //customerId      = acct.TMB_Customer_ID_PE__c;
                string TMBCustomerIDPE = '';
                if (string.isNotBlank(acct.TMB_Customer_ID_PE__c)){
                    TMBCustomerIDPE = acct.TMB_Customer_ID_PE__c.trim();
                }
                customerId = (TMBCustomerIDPE.length() > 14) ? TMBCustomerIDPE.right(14) : TMBCustomerIDPE;               
                
                //customerName    = (!string.isBlank(acct.Customer_Name_PE_Eng__c)) ? acct.Customer_Name_PE_Eng__c : '-';//acct.Name;
                customerName    = (!string.isBlank(acct.Name)) ? acct.Name: '-';
                
                citizenId = '';
                if (acct.ID_Type_PE__c == 'Citizen ID' || acct.ID_Type_PE__c == 'BRN ID') {
                    citizenId =  acct.ID_Number_PE__c;
                }else{
                    citizenId = '1111111111111';
                }
                if (string.isBlank(citizenId) || citizenId.length() != 13) {
                    citizenId = '1111111111111';
                }
                
                /*
                bdmId       = '';
                if (acct.ID_Type_PE__c == 'BRN ID') {
                    //bdmId = acct.ID_Number_PE__c;
                    citizenId = acct.ID_Number_PE__c;
                }
                */
                
                customerType = (acct.Customer_Type__c.toLowerCase().contains('juristic')) ? 2 : 1;


            }
            /**************************************
            *  User INFO
            ***************************************/
            hubCode = '';
            regionCode = '';
            bdmId = '';
            if (null != usr &&  null != usr.id) {
                hubCode    = usr.Zone_Code__c;
                regionCode = usr.Region_Code__c;
                bdmId      = usr.Employee_ID__c;
            }
            
            /*SLS Mobility*/
            //mobileNo = acct.Mobile_Number_PE__c;
            mobileNo = '';
            if(!string.isBlank(acct.Mobile_Number_PE__c)){
                string regExpMobileNo = '[^0-9]';
                string originalMobileNo = acct.Mobile_Number_PE__c;
                string mobileNoFormat = originalMobileNo.replaceAll(regExpMobileNo, '');
                mobileNo = (mobileNoFormat.length() > 10) ? String.valueOf(mobileNoFormat).substring(0, 10) : mobileNoFormat;                
            }
            
            province = acct.Province_Primary_PE__c;
            district = acct.Primary_Address_Line_3_PE__c;
            subDistrict = acct.Primary_Address_Line_2_PE__c;
                           
            //Province
            string cProvince = AppConfig__c.getValues('FilterPrimaryProvince').Value__c;            
            Set<String> filterProvince = New Set<String>();
            filterProvince.addAll(cProvince.split('\\|')); 
            for(string p:filterProvince)  {
                string provincePrimaryPE = acct.Province_Primary_PE__c;
                if(!string.isBlank(provincePrimaryPE) && provincePrimaryPE.startsWith(p)){        
                    province = provincePrimaryPE.right(provincePrimaryPE.length() - p.length()).trim();                    
                }
            } 
            
            //District
            string cDistrict = AppConfig__c.getValues('FilterPrimaryDistrict').Value__c;            
            Set<String> filterDistrict = New Set<String>();
            filterDistrict.addAll(cDistrict.split('\\|')); 
            for(string d:filterDistrict)  {                 
                string primaryAddressLine3PE = acct.Primary_Address_Line_3_PE__c;
                if(!string.isBlank(primaryAddressLine3PE) && primaryAddressLine3PE.startsWith(d)){        
                    district = primaryAddressLine3PE.right(primaryAddressLine3PE.length() - d.length()).trim();                    
                }
            }
            
            //SubDistrict
            string cSubDistrict = AppConfig__c.getValues('FilterPrimarySubDistrict').Value__c;          
            Set<String> filterSubDistrict = New Set<String>();
            filterSubDistrict.addAll(cSubDistrict.split('\\|'));
            for(string sd:filterSubDistrict)  {                
                string primaryAddressLine2PE = acct.Primary_Address_Line_2_PE__c;
                if(!string.isBlank(primaryAddressLine2PE) && primaryAddressLine2PE.startsWith(sd)){        
                    subDistrict = primaryAddressLine2PE.right(primaryAddressLine2PE.length() - sd.length()).trim();                    
                }
            } 
            
            //zipCode = acct.Zip_Code_Primary_PE__c;
            zipCode = '';
            if(!string.isBlank(acct.Zip_Code_Primary_PE__c)){
                string originalZipCode = acct.Zip_Code_Primary_PE__c;
                zipCode = (originalZipCode.length() > 5) ? String.valueOf(originalZipCode).substring(0, 5) : originalZipCode;
            } 
            
            country = acct.Country_Primary_PE__c;
            saleAmount = acct.Sales_amount_per_year__c;
            yearInBusiness =  (acct.No_of_years_business_run__c != null) ? Integer.valueOf(acct.No_of_years_business_run__c) : 0; 
            productGroupId = (!string.isBlank(oppt.Product_Group_ID__c)) ? Integer.valueOf(oppt.Product_Group_ID__c) : 0; 
            List<SLOSSoapService.FacilityInfoRequest> lstFacilityInfoReq = new List<SLOSSoapService.FacilityInfoRequest>();            
            for (OpportunityLineItem ol : [SELECT Id, Product_Group_ID__c, Product_Program_ID__c, UnitPrice, Credit_Type_ID__c 
                                           FROM OpportunityLineItem where OpportunityId = : oppt.Id]) 
            {                             
                    SLOSSoapService.FacilityInfoRequest facilityInfoReq = new SLOSSoapService.FacilityInfoRequest();               
                    facilityInfoReq.ProductProgramId = (!string.isBlank(ol.Product_Program_ID__c)) ? Integer.valueOf(ol.Product_Program_ID__c) : 0;
                    facilityInfoReq.CreditTypeId = (!string.isBlank(ol.Credit_Type_ID__c)) ? Integer.valueOf(ol.Credit_Type_ID__c) : 0;
                    facilityInfoReq.RequestAmount = (ol.UnitPrice != null) ? ol.UnitPrice : 0;
                    lstFacilityInfoReq.add(facilityInfoReq);                  
            }            
            facilityInfos = new SLOSSoapService.FacilityInfos_element();
            facilityInfos.FacilityInfo = lstFacilityInfoReq;  
        }
        public boolean validate() {
            boolean ret = true;
            return ret;
        }
    }         
}