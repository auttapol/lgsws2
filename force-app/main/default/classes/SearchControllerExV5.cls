public class SearchControllerExV5  extends AccountExtensionBase { 
    private ApexPages.StandardController standardController;    
    public Search__c account {get;set;}
    public User ownerUser;
    public Account viewAccount;
    public Map<ID,Account> accountMap;
    // Display in Gridview
    //public List<Account> accounts;    
    public List<List<SObject>> searchList {get{
        if(searchList ==null){
            searchList = new List<List<SObject>> ();
        }
        return searchList;
    }set;}
    // Redirect variable
    public ID acctId{get;set;}
    public ID ownerId {get; set;}    
    // Enable / Disable 
    public static Boolean isValid {get; set;}   
    public static Boolean isButtonDisabled {get; set;} 
    public static boolean searchActive {get; set;} 
    public static boolean searchCustomer {get; set;}
    
    public Boolean isSearchNameonly {get;set;}
    public Boolean isSameOwner {get;set;}
    public Boolean isIDValid {get;set;}
    public Boolean isInformation {get;set;}
    public Boolean isCusonly {get;set;}
    public Boolean isLasNameDisabled {get;set;}
    public Boolean isSearchbyID {get;set;}
    public Boolean isSearchbyTMBCust{get;set;}
    public List<SelectOption> CustTypeOptionList {get;set;}
    public List<SelectOption> IDTypeOptionList {get;set;}
    public String IDTypestr {get;set;}
    public String URLSF1 {get;set;}
    public String IDNumberstr {get;set;}
    public String CustTypestr {get;set;}
    public String TMBCustStr {get;set;}   
    public ID disqualifiedID {get{
        if(disqualifiedID==null){
            disqualifiedID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Disqualified prospect').getRecordTypeId();
        }
        return disqualifiedID;
        
    }set;}
    
    /* In active customer record type */
    public ID inActiveID {get{
        if(inActiveID==null){
            inActiveID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Inactive Customer').getRecordTypeId();
        }
        return inActiveID;
        
    }set;}
    
    
    //<!-- Server Hidden Field -->
    public String hdCusType {get;set;}
    public String hdIdType {get;set;}
    public String hdCheckBoxMode {get;set;}
    
    private Static Final Integer PAGE_NUMBER = 5;
    private Integer SearchResultNumber {get;set;}
    Public Integer noOfRecordsAccount {get; set;}
    Public Integer noOfRecordsLead {get; set;}
    public List<Account> accounts {get{
        accounts = new List<Account>();
        if(AcctconSet !=null){
            for (Account acct : (List<Account>)AcctconSet.getRecords()){
                accounts.add(acct );
            }
        }
        
        return accounts;
        
    }set;}
    
    public List<Lead> leads {get{
        leads = new List<Lead>();
        if(LeadconSet !=null){
            
            for (Lead leadRec : (List<Lead>)LeadconSet.getRecords()){
                leads.add(leadRec );
            }
        }
        
        return leads;
        
    }set;}

    public String maskedLabel {
        get{
            if( maskedLabel == null )
            {
                maskedLabel = 'xxx';
            }
            return maskedLabel;
        }
        set;
    }
    
    public ApexPages.StandardSetController AcctconSet {get;set;}
    public ApexPages.StandardSetController LeadconSet {get;set;}
    
    
        public static RecordType CommercialLeadRecordType {get{
        if(CommercialLeadRecordType ==null){
           CommercialLeadRecordType = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Commercial Lead' 
                                 AND sObjectType='Lead' LIMIT 1];
        }
        return CommercialLeadRecordType;
    }set;}
    
    public static List<String> LeadStatusFilters {get{
        if(LeadStatusFilters==null){
            LeadStatusFilters = new List<String>();
            LeadStatusFilters.add('Open');
            LeadStatusFilters.add('Passed Prescreening');
            LeadStatusFilters.add('Contacted');
        }
        return LeadStatusFilters;
    }set;}
    

    public boolean getSearch_Customer_Access(){
        
       	Profile userProfile = [Select id, name from profile where id = :UserInfo.getProfileId()];        
        
        try{
        	Search_Customer_Access__mdt Search_Customer_Access = [Select id, Block_Search__c from Search_Customer_Access__mdt where Profile_name__c = :userProfile.Name];
			System.debug('Search__c = '+ Search_Customer_Access.Block_Search__c+' , Search_Customer_Access = '+ Search_Customer_Access);
            
            if(Search_Customer_Access != null){
            	//return true;
            	return Search_Customer_Access.Block_Search__c;
            }else{
                return false;
            }
        }catch(Exception e){
            System.debug(e.getMessage());
            return false;
        }
        
        	
	}
    
    public String tabStyle {get;set;}
    // Extension Controller Constructor //
    public SearchControllerExV5(ApexPages.StandardController controller){
        //searchCustomer = true;
        searchCustomer = getSearch_Customer_Access();
        standardController = controller;
        account = (Search__c)standardController.getRecord();
        account.Customer_Type_Temp__c = 'Individual';
        // accounts = new List<Account>();
        isButtonDisabled = true;   
        hdCusType ='--None--';
        IDTypestr='--None--';
        hdIdType = '--None--';
        tabStyle = ApexPages.currentPage().getParameters().get('tab');
    } 
    
    // list for the account responsed from api
    // public List<Account> getAccounts(){
    //     return accounts;
    // }   
    public PageReference search(){
        searchActive = true;
        
        System.debug('== Search Start ==');
        System.debug('1. Customer Type :'+  hdCusType); 
        System.debug('2. First Name/Company Name :'+  account.First_name__c); 
        System.debug('3. Last Name :'+  account.Last_name__c); 
        System.debug('4. Mobile Number :'+  account.Mobile_Number_Temp__c); 
        System.debug('5. Office Number :'+  account.Office_Number_Temp__c); 
        System.debug('6. ID Type :'+  hdIdType); 
        System.debug('7. ID Number :'+  account.ID_Number_Temp__c);
        System.debug('8. TMB Customer ID :'+  account.TMB_Customer_ID_Temp__c);
        System.debug('9. Mode :'+  hdCheckBoxMode);
        System.debug('10. hdIdType :'+  hdIdType);
        
        
        account.Customer_Type_Temp__c = hdCusType;
        isButtonDisabled = true;
        isSearchNameonly =false;
        isSameOwner = false;
        isSearchbyTMBCust = false;
        issearchByID = false;
        Boolean mobileOnly = false;
        // Fix Cust Type Must be select
        if( hdIdType == '--None--' || hdIdType == null|| hdIdType == '' ){          
            
            System.debug(' 1) Check hdIdType');         
            IDTYpeStr =null;
            account.ID_Type__c = null;            
            System.debug('Set hdIdType : '+   account.ID_Type__c);
            
        }   
        else{
            System.debug(' 2) Check hdIdType'); 
            account.ID_Type__c =hdIdType;
        }
        if(hdCusType == '--None--' || hdCusType == '' || hdCusType == null  ){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('3002').Status_Message__c));
            return null;
        }
        
        if(   (account.ID_Number_Temp__c==null || account.ID_Number_Temp__c =='')
           && (account.ID_Type__c == null)
           &&(account.First_name__c == null || account.First_name__c =='')
           &&(account.Mobile_Number_Temp__c == null || account.Mobile_Number_Temp__c =='')
           &&(account.Last_name__c == null || account.Last_name__c =='')
           &&(account.Office_Number_Temp__c == null || account.Office_Number_Temp__c =='')
           &&(account.TMB_Customer_ID_Temp__c == null || account.TMB_Customer_ID_Temp__c == '')){
               System.debug(' 3) All Null'); 
               ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3011').Status_Message__c));
               return null;
           }
        
        if(account.ID_Type__c=='Citizen ID' && (account.ID_Number_Temp__c == null || account.ID_Number_Temp__c =='')){
            System.debug(' 4) Citizen ID Null');
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3001').Status_Message__c));
            return null;
        }
        if(account.ID_Type__c=='Citizen ID'  &&  isIDValid == false)
        {
            System.debug(' 5) Citizen ID Invalid');
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3001').Status_Message__c));
            return null;
        }
        
        
        
        
        System.debug(' 6) ID_Type__c  ' + account.ID_Type__c);
        if(hdCheckBoxMode=='info'){
            if(   (account.ID_Type__c != null) 
               && (account.ID_Number_Temp__c == null || account.ID_Number_Temp__c == '')){
                   System.debug(' 7) info ');
                   
                   System.debug('account.ID_Type__c : ' + account.ID_Type__c);
                   system.debug('++++++++++');
                   system.debug('account.ID_Type__c : '+ account.ID_Type__c);
                   system.debug('account.ID_Number_Temp__c : '+account.ID_Number_Temp__c);
                   
                   ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3004').Status_Message__c));
                   return null;
               }
            
            
            
            if(   (account.ID_Type__c != null) 
               && (account.ID_Number_Temp__c != null || account.ID_Number_Temp__c != '')){
                   String IDNumber = account.ID_Number_Temp__c;
                   
                   if(IDNumber.length()<4){
                       ApexPages.addmessage(new ApexPages.Message
                                            (ApexPages.Severity.ERROR, 'Your search term must have 4 or more characters.'));
                       return null;  
                   }
                   
               }
        }
        else if(hdCheckBoxMode=='cust'){
            if(account.TMB_Customer_ID_Temp__c == null){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3005').Status_Message__c));
                return null;
            }
        }
        
        
        if(account.ID_Type__c == null && account.ID_Number_Temp__c != null){
            System.debug(' 7) Citizen ID Invalid');
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3006').Status_Message__c));
            return null;
        }
        
        try{            
            // accounts = new List<Account>();          
            string accttype = account.Customer_Type_Temp__c.substring(0,1);
            
            
            
            
            //Check Partial search, First Name and Last Name should be more than 5 digits.
            //Edit by: danudath.lee@tmbbank.com
            if((account.First_name__c != null && account.First_name__c != '') && 
               (account.ID_number_Temp__c == '' || account.ID_number_Temp__c == null) &&              
               (account.Office_Number_Temp__c == '' || account.Office_Number_Temp__c == null ) && 
               (account.Mobile_Number_Temp__c == '' || account.Mobile_Number_Temp__c == null)){
                   String nameRemoveSpec = account.First_name__c.replaceAll(' ', '');
                   nameRemoveSpec = nameRemoveSpec.replace('*', '');                     
                   if(nameRemoveSpec.length() < 5 && nameRemoveSpec != ''){               
                       ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('3022').Status_Message__c));
                       return null;
                   }
               }
            
            
            // Custom Setting
            // Type of Id
            
            System.debug('Id Number : ' + account.ID_Number_Temp__c);
            System.debug('ID type : '+account.ID_Type__c);
            System.debug('hdCusType : ' + hdCusType);
            
             List<account> acctList = new List<Account>();
            List<Lead> leadList = new List<lead>();
            
            if(account.ID_Number_Temp__c != null && account.ID_Number_Temp__c.length()>=4   ){
                System.debug('::: Search Only Id ::::');
                 
                /*
                searchList = [FIND :account.ID_Number_Temp__c
                              IN ALL FIELDS
                              RETURNING Account (id, Owner.Name, OwnerID, RecordTypeID,
                                                 Owner.MobilePhone, Name, Customer_Type__c ,
                                                 ID_Type_PE__c, ID_Number_PE__c, 
                                                 Account_Type__c, Segment2__c, 
                                                 Primary_Address_Line_1_PE__c, Primary_Address_Line_2_PE__c, 
                                                 Primary_Address_Line_3_PE__c, Province_Primary_PE__c, Zip_Code_Primary_PE__c
                                                 WHERE ID_Type_PE__c =: account.ID_Type__c
                                                 AND RecordTypeID != :disqualifiedID
                                                 AND Customer_Type__c  =: hdCusType
                                                ),
                              Lead (id, Owner.Name,Owner.phone, OwnerID, RecordTypeID,Company,
                                                  Name, Customer_Type__c ,Owner_Segment__c  ,
                                                 ID_Type__c, ID_Number__c, Customer_Name_EN__c,
                                                 Suggested_Segment__c , 
                                                 Address_Line_1__c , Address_Line_2__c , 
                                                 Address_Line_3__c , Province__c , Zipcode__c 
                                                 WHERE ID_Type__c =: account.ID_Type__c
                                                 //AND RecordTypeID =:CommercialLeadRecordType.id
                                                 AND Status IN: LeadStatusFilters
                                                 AND Customer_Type__c  =: hdCusType
                                                )
                             ];
                */
                
                //Enhance Search
                //
                //
                 String IDNumber =  account.ID_Number_Temp__c;
                 String FiveDigits;
            	 //String LastthreeDigits = IDnumber.substring(IDNumber.length()-3, IDNumber.length());
                 
                       
                        if(IDNumber.length() <=5){
                     	FiveDigits = IDNumber;
                        }else{
                String firstdigit = IDNumber.left(1);
                String last4digits = IDNumber.right(4);
                        FiveDigits =firstdigit+last4digits;
                        
                    }
                
                System.debug('FiveDigits: '+FiveDigits);
                
                acctList = [SELECT id, Owner.Name, OwnerID, RecordTypeID,
                                                             Owner.MobilePhone, Name, Customer_Type__c ,
                                                             ID_Type_PE__c, NID__c, TMB_Customer_ID_PE__c,ID_Number_PE__c,
                                                             Account_Type__c, Segment2__c, Core_Banking_Suggested_Segment__c,
                                                             Primary_Address_Line_1_PE__c, Primary_Address_Line_2_PE__c, 
                                                             Primary_Address_Line_3_PE__c, Province_Primary_PE__c, Zip_Code_Primary_PE__c,RTL_NID__c,Sub_Segment2__c
                                                   			 FROM Account
                                                             WHERE ID_Type_PE__c =: account.ID_Type__c
                                                             AND RecordTypeID != :disqualifiedID
                                                             AND Customer_Type__c  =: hdCusType
                                                   			 AND RTL_NID__c =: FiveDigits
                                                  			 ];
                leadList = [SELECT id, Owner.Name,Owner.phone, OwnerID, RecordTypeID,Company,
                                                  Name, Customer_Type__c ,Owner_Segment__c  ,
                                                 ID_Type__c, ID_Number__c, Customer_Name_EN__c,
                                                 Suggested_Segment__c , ID_REGEX__c,
                                                 Address_Line_1__c , Address_Line_2__c , 
                                                 Address_Line_3__c , Province__c , Zipcode__c ,Owner_Team_Zone__c
                                             	 FROM LEAD
                                                 WHERE ID_Type__c =: account.ID_Type__c
                                                 //AND RecordTypeID =:CommercialLeadRecordType.id
                                                 AND Status IN: LeadStatusFilters
                                                 AND Customer_Type__c  =: hdCusType
                                             	 AND ID_REGEX__C =:FiveDigits
                                                ];
                
                
                //
                //
                
                
                
                isSearchByID = true;
            }
            else if(account.First_name__c != null && account.First_name__c != ''){
                System.debug(':::: Search Only Name ::::');
                
                String acctName = account.First_name__c+' '+(account.Last_name__c==null?'':account.Last_name__c);
                System.debug(acctName);
                searchList = [FIND : acctName
                              IN ALL FIELDS
                              RETURNING Account (id, Owner.Name, OwnerID, RecordTypeID,
                                                 Owner.MobilePhone, Name,Customer_Name_PE_Eng__c,ID_Number_PE__c,
                                                 ID_Type_pe__c, NID__c ,Core_Banking_Suggested_Segment__c,
                                                 Account_Type__c, Segment2__c, TMB_Customer_ID_PE__c,
                                                 Primary_Address_Line_1_PE__c, Primary_Address_Line_2_PE__c, 
                                                 Primary_Address_Line_3_PE__c, Province_Primary_PE__c, Zip_Code_Primary_PE__c,Sub_Segment2__c
                                                 WHERE  RecordTypeID != :disqualifiedID 
                                                 AND RecordTypeID != :inActiveID
                                                 AND Customer_Type__c  =: hdCusType
                                                ),
                             
                             Lead (id, Owner.Name,Owner.phone, OwnerID, RecordTypeID,Company,
                                                  Name, Customer_Type__c ,Customer_Name_EN__c ,
                                                 ID_Type__c, ID_Number__c, Owner_Segment__c ,
                                                 Suggested_Segment__c ,ID_REGEX__c,
                                                 Address_Line_1__c , Address_Line_2__c , 
                                                 Address_Line_3__c , Province__c , Zipcode__c ,Owner_Team_Zone__c
                                                 //WHERE  RecordTypeID =:CommercialLeadRecordType.id
                                                 WHERE Status IN: LeadStatusFilters
                                                 AND Customer_Type__c  =: hdCusType
                                                )
                             
                             ];
                
                
                
                isSearchNameonly = true;
                
            }
            // FIX :  When User Not Input Name But input Only Phone Number           
            else if(
                (account.First_name__c == '' || account.First_name__c == null) 
                && 
                (account.Office_Number_Temp__c != null || account.Mobile_Number_Temp__c != null) 
            ){
                
                
                System.debug(':::: Search Only PHONE ::::');
                
                String searchphone = account.Office_Number_Temp__c==null?'':account.Office_Number_Temp__c.replace(' ','');
                if((account.Office_Number_Temp__c != null && account.Mobile_Number_Temp__c != null) ){
                    searchphone +=' OR ';
                }
                searchphone += account.Mobile_Number_Temp__c==null?'':account.Mobile_Number_Temp__c.replace(' ','');
                
                searchList = [FIND  :searchphone
                              IN PHONE FIELDS
                              RETURNING Account (id, Owner.Name, OwnerID, RecordTypeID,
                                                 Owner.MobilePhone, Name,TMB_Customer_ID_PE__c,ID_Number_PE__c,
                                                 ID_Type_PE__c,NID__c , Mobile_Number_PE__c,Phone,
                                                 Account_Type__c, Segment2__c,Core_Banking_Suggested_Segment__c,
                                                 Primary_Address_Line_1_PE__c, Primary_Address_Line_2_PE__c, 
                                                 Primary_Address_Line_3_PE__c, Province_Primary_PE__c, Zip_Code_Primary_PE__c,Sub_Segment2__c
                                                 WHERE  RecordTypeID != :disqualifiedID 
                                                 AND RecordTypeID != :inActiveID
                                                 AND Customer_Type__c  =: hdCusType
                                                ),
                             Lead (id, Owner.Name,Owner.phone, OwnerID, RecordTypeID,Company,
                                                  Name, Customer_Type__c ,Customer_Name_EN__c ,
                                                 ID_Type__c, ID_Number__c, Owner_Segment__c ,
                                                 Suggested_Segment__c ,Mobile_No__c,Office_No__c,
                                                 Address_Line_1__c , Address_Line_2__c , ID_REGEX__c,
                                                 Address_Line_3__c , Province__c , Zipcode__c ,Owner_Team_Zone__c
                                                 //WHERE  RecordTypeID =:CommercialLeadRecordType.id
                                                 WHERE Status IN: LeadStatusFilters
                                                 AND Customer_Type__c  =: hdCusType
                                                )
                             ];
                
                
                
                
                mobileOnly = true;
            }            
            else if(account.TMB_Customer_ID_Temp__c != null || account.TMB_Customer_ID_Temp__c != '' ){
                System.debug(':::: Search TMB CUST ID TEMP ::::'+account.TMB_Customer_ID_Temp__c);
                System.debug('tmbService.Search_X : '+hdCusType); 
                System.debug('inActiveID : '+inActiveID); 
                isSearchbyTMBCust = true;
                searchList = [FIND  : account.TMB_Customer_ID_Temp__c
                              
                              RETURNING Account (id, Owner.Name, OwnerID, RecordTypeID,
                                                 Owner.MobilePhone, Name,TMB_Customer_ID_PE__c ,ID_Number_PE__c,
                                                 NID__c, ID_Type_PE__c ,Core_Banking_Suggested_Segment__c,
                                                 Account_Type__c, Segment2__c, Customer_type__c,
                                                 Primary_Address_Line_1_PE__c, Primary_Address_Line_2_PE__c, 
                                                 Primary_Address_Line_3_PE__c, Province_Primary_PE__c, Zip_Code_Primary_PE__c,Sub_Segment2__c
                                                 WHERE  RecordTypeID != :disqualifiedID 
                                                 AND RecordTypeID != :inActiveID
                                                 AND Customer_Type__c  =: hdCusType
                                                )];
                
                
            }

            if(!isSearchByID){
                 System.debug('searchList : '+searchList.size());
				if(searchList[0] !=null){
                     acctList.addAll((List<Account>)searchList[0]);
                }
                
               
                
                if(searchList.size()>1){
                  leadList.addAll((LisT<Lead>)searchList[1]);  
                }
            }
            
            for(lead l :leadList )
            {
                string result;
                string firstdigit;
                string lastdigit;
              
                /*if(l.ID_REGEX__c != null)
                {
                    if(l.ID_REGEX__c.length()==5)
                    {
                        firstdigit = l.ID_REGEX__c.substring(0,1);
                        lastdigit = l.ID_REGEX__c.substring(1,5);
                        result =firstdigit + 'xxx' + lastdigit;
                        l.ID_REGEX__c = result;
                    }
                    
                }*/
                
            }
            
            System.debug(acctlist.size());
            System.debug(leadList.size());
            
            List<Account> AccountEnhanceList = new List<Account>();
            List<Lead> LeadEnhanceList = new List<Lead>();
            Boolean isOverStack = false;
           
            
            if(isSearchNameonly)
            {
                integer countAccount=0;
                integer countLead =0;
                System.debug('::Enhance Name Result::');
                String acctName = account.First_name__c;
                Set<Account> acctSet = new Set<Account>();
                Set<Lead> leadSet = new set<Lead>();
                //ACCOUNT OBJECT
                for(Account acct : acctList){
                    
                    
                        String custnametrim = trimStr(acctName);
                        List<String> namesplit = Acct.Name.split(' ');
                        //ThaiName
                        //
                        
                        if(trimStr(acct.Name).containsIgnoreCase(custnametrim)){
                            acctSet.add(acct);
                        }
                        
                        for(String custname : custnametrim.split(' ')){
                            for(String splitstr : namesplit){
                                if(splitstr.containsIgnoreCase(custname)){
                                    acctset.add(acct);
                                }
                            }
                        }
                        
                        
                        
                        //Eng Name
                        String EngName = acct.Customer_Name_PE_Eng__c==null?'':acct.Customer_Name_PE_Eng__c;
                        if(EngName !=null && EngName !=''){
                            if(trimStr(EngName).containsIgnoreCase(custnametrim)){
                                acctSet.add(acct);
                            }
                            
                            
                            String custEngnametrim = trimStr(EngName);
                            for(String custEngname : custEngnametrim.split(' ')){
                                for(String splitstr : namesplit){
                                    if(splitstr.containsIgnoreCase(custEngname)){
                                        acctset.add(acct);
                                    }
                                }
                        	}
                            
                            
                        }
                    
                }
                //ACCOUNT OBJECT
                //
                
                //LEAD OBJECT
                //
                for(Lead leadRec : leadList){
                    
                    
                   
                        String custnametrim = trimStr(acctName);
                        List<String> namesplit = leadRec.Company.split(' ');
                        //ThaiName
                        //
                        //
                        
                        if(trimStr(leadRec.Company).containsIgnoreCase(custnametrim)){
                            System.debug(leadRec.Company+' :: contains:: '+custnametrim);
                            leadSet.add(leadRec);
                        }
                        
                            
                        for(String custname : custnametrim.split(' ')){
                           
                            for(String splitstr : namesplit){
                                
                                if(splitstr.containsIgnoreCase(custname)){
                                    System.debug(splitstr+' :: split :: '+custname);
                                    leadSet.add(leadRec);
                                }
                            }
                        }
                        
                        
                        //Eng Name
                        String EngName = leadRec.Customer_NAME_EN__c==null?'':leadRec.Customer_NAME_EN__c;
                    
                        if(EngName !=null && EngName !=''){
                            if(trimStr(EngName).containsIgnoreCase(custnametrim)){
                                System.debug(EngName+' :: EngName contains:: '+custnametrim);
                                leadSet.add(leadRec);
                            }
                            
                            //Result Split
                                for(String custEngname : EngName.split(' ')){
                                    //Input Split
                                        for(String splitstr : acctname.split(' ')){
                                            if(splitstr.containsIgnoreCase(custEngname)){
                                                System.debug(splitstr+' :: EngName split:: '+custEngname);
                                                leadSet.add(leadrec);
                                            }
                                    }
                                }
                            
                            
                        }
                    			
                    			
                    
                    		
                    
                }                
                //
                //LEADOBJECT
                //
                
                AccountEnhanceList.addAll(acctSet);
                System.debug('leadSet size() : '+leadSet.size());
                LeadEnhanceList.addAll(leadSet);
                System.debug('LeadEnhanceList size() : '+LeadEnhanceList.size());
                
            }
            else if(isSearchByID){
                System.debug('::Enhance IDtype Result::');
                for(Account acct : acctList){
                    if(acct.ID_Number_PE__C == account.ID_Number_Temp__c ){
                        AccountEnhanceList.add(acct);
                    }
                    
                }   
                for(Lead leadrec : leadList){
                    if(leadrec.ID_Number__C == account.ID_Number_Temp__c ){ //Tinnakrit Changed Mon Jun 20 2016
                        LeadEnhanceList.add(leadrec);
                    }
                }
            }
            else if(isSearchbyTMBCust&&!isOverStack){
                System.debug('::Enhance TMB cust Result::');
                for(Account acct : acctList){
                    System.debug(acct.TMB_Customer_ID_PE__c  +' : '+account.TMB_Customer_ID_Temp__c );
                    if(acct.TMB_Customer_ID_PE__c  == account.TMB_Customer_ID_Temp__c ){
                        AccountEnhanceList.add(acct);
                    }
                    
                }   
                
            }
            else if(mobileOnly){
                System.debug('::Enhance Phone Result::');
                Set<Account> EnhanceSet = new Set<Account>();
                Set<Lead> EnhanceLeadSet = new Set<Lead>();
                for(Account acct : acctList){
                    
                    //Mobile
                    
                    if(account.Mobile_Number_Temp__c !=null && account.Mobile_Number_Temp__c !=''
                       && acct.Mobile_Number_PE__c !=null){
                           String numPhone = acct.Mobile_Number_PE__c.replace(' ','');
                           String searchNum = account.Mobile_Number_Temp__c.replace(' ','');
                           if(numPhone  == searchNum){
                               EnhanceSet.add(acct);
                           }
                       }
                    //Office
                    
                    if(account.Office_Number_Temp__c !=null && account.Office_Number_Temp__c !=''
                       && acct.Phone !=null){
                           String numPhone = acct.Phone.replace(' ','');
                           String searchNum = account.Office_Number_Temp__c.replace(' ','');
                           if(numPhone  == searchNum ){
                               EnhanceSet.add(acct);
                           }
                       }
                    
                }
                
                
                for(Lead Leadrec : leadList){
                     //Mobile
                    
                    if(account.Mobile_Number_Temp__c !=null && account.Mobile_Number_Temp__c !=''
                       && Leadrec.Mobile_No__c !=null){
                           String numPhone = Leadrec.Mobile_No__c.replace(' ','');//Tinnakrit Changed Mon Jun 20 2016
                            String searchNum = account.Mobile_Number_Temp__c.replace(' ','');
                           if(numPhone  == searchNum){
                               EnhanceLeadSet.add(Leadrec);
                           }
                       }
                    //Office
                    
                    if(account.Office_Number_Temp__c !=null && account.Office_Number_Temp__c !=''
                       && Leadrec.Office_No__c !=null){
                           String numPhone = Leadrec.Office_No__c.replace(' ','');
                           String searchNum = account.Office_Number_Temp__c.replace(' ','');
                           if(numPhone  == searchNum ){
                               EnhanceLeadSet.add(Leadrec);
                           }
                       }
                    
                }
                
                AccountEnhanceList.addAll(EnhanceSet);
                LeadEnhanceList.addAll(EnhanceLeadSet);
                
                
            }
            else{
                List<Account> acctlistLimit = new List<Account>();
                if(acctlist.size()> 150){
                    integer counter = 0;
                    while(counter<150) {
                        acctlistLimit.add(acctlist.get(counter));
                        counter++;
                    }
                }
                AccountEnhanceList.addAll(acctlistLimit);
            }
            
            
            
             if(AccountEnhanceList.size() >150){
                isOverStack = true;
            }else if(LeadEnhanceList.size() > 150){
                isOverStack = true;
            }
            
            System.debug('AccountEnhanceList:  '+AccountEnhanceList.size());
            System.debug('LeadEnhanceList : '+LeadEnhanceList.size());
            AcctconSet = new ApexPages.StandardSetController(AccountEnhanceList);
            SearchResultNumber = (AccountEnhanceList.size());
            noOfRecordsAccount = AcctconSet.getResultSize();
            AcctconSet.setPageSize(30);
            
            LeadconSet =  new ApexPages.StandardSetController(LeadEnhanceList);
             SearchResultNumber += (LeadEnhanceList.size());
             noOfRecordsLead = LeadconSet.getResultSize();
            LeadconSet.setPagesizE(30);
            // Case 1) if found record(s)
            isButtonDisabled = false;
            isSameOwner = false;
            if(AccountEnhanceList.size() >0){         
                for(Account acct : AccountEnhanceList){
                    if( isSearchbyTMBCust ||isSearchByID){
                        isSameOwner = true;
                    }else if(isSearchNameonly){
                        if(acct.OwnerID == Userinfo.getUserId()){
                            isSameOwner = true;
                        }
                    }
                }
            }
            
            if(LeadEnhanceList.size() >0){
                    if(isSearchByID){
                        isSameOwner = true;
                    }else if(isSearchNameonly){
                       // 
                    }
            }
            if(isSameOwner && !isOverStack){
                System.debug('SAMEOWNER');
                isButtonDisabled = true;
                if(issearchByID || isSearchbyTMBCust){
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('6001').Status_Message__c));
                    
                }else if(isSearchNameonly&& !isOverStack){
                    System.debug('SAMEOWNER');
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('6002').Status_Message__c));
                    
                }
                
            }else if(isOverStack){
                isButtonDisabled =true;
                ApexPages.addmessage(ErrorHandler.Messagehandler(FOUND_DUP_MORE_THAN_30_NOT_ALLOW_CREATE, ''));
                
                
            }else if((accounts.size() >0 ||leads.size()>0) && !isSameOwner && !isOverStack){
                ApexPages.addmessage(ErrorHandler.Messagehandler(FOUND_DUP_ALLOW_CREATE, ''));
            }
            
            
            if(!isButtonDisabled&&accounts.size()<=0 && leads.size()<=0&&!isOverStack){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO, Status_Code__c.GetValues('0000').Status_Message__c));
            }
            nextbuttonSF1(); 
            return null;
        }
        catch(Exception e){
            isButtonDisabled = true;
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.GetValues('1001').Status_Message__c));
            return null;
        }
        
        return null;
    }
    public void resetNextButton(){
        isButtonDisabled = true;        
    }
    
    //region  Redirect
    
    public PageReference nextbutton(){        
        
       // String Url='/001/e?retURL=%2F001%2Fo&RecordType=01290000001AhOT&ent=Account';       // i want to pass one more additional value
       Recordtype CommercialLead = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Commercial Lead' 
                                 AND sObjectType='Lead' LIMIT 1];
        String Url = '/apex/LeadProxyExtension?retURL=%2F001%2Fo&RecordType='+CommercialLead.id;
        Map<String,String> FieldIDMap = new Map<String,String>();
      //  for(Account_Search_Parameters__c para : [SELECT Name,FieldID__c FROM Account_Search_Parameters__c ]){
      //      FieldIDMap.put(para.Name,para.FieldID__c);
     //   }
        
        
        //  Passing parameter
        url += '&customer_type='+account.Customer_Type_Temp__c;
        url += account.First_name__c!=null?'&company_name='+account.First_name__c:'';
        url += account.Mobile_Number_Temp__c!=null?'&mobile_number='+account.Mobile_Number_Temp__c:'';
        url += account.Office_Number_Temp__c!=null?'&office_number='+account.Office_Number_Temp__c:'';
        url += account.ID_Type__c!=null?'&id_type='+account.ID_Type__c:'';
        url += account.ID_Number_Temp__c!=null?'&id_number='+account.ID_Number_Temp__c:'';
        url +='&cancelURL=00Q';
 
        PageReference accountCreationPage=new PageReference(Url);
        accountCreationPage.setRedirect(true);
        return accountCreationPage;
    }     
    
    public PageReference nextbuttonSF1(){        
        URLSF1='';
        //String Url='/001/e?retURL=%2F001%2Fo&RecordType=01290000001AhOT&ent=Account';       // i want to pass one more additional value
        /*String Url = '/apex/LeadCreateMobile?retURL=%2F001%2Fo&RecordType=012p00000008ZNX';
        Map<String,String> FieldIDMap = new Map<String,String>();
        for(Account_Search_Parameters__c para : [SELECT Name,FieldID__c FROM Account_Search_Parameters__c ]){
            FieldIDMap.put(para.Name,para.FieldID__c);
        }*/
        Recordtype CommercialLead = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Commercial Lead' 
                                 AND sObjectType='Lead' LIMIT 1];
        String Url = '/apex/LeadProxyExtension?retURL=%2F001%2Fo&RecordType='+CommercialLead.id;
        Map<String,String> FieldIDMap = new Map<String,String>();
        
        //  Passing parameter
        url += '&customer_type='+account.Customer_Type_Temp__c;
        url += account.First_name__c!=null?'&company_name='+account.First_name__c:'';
        url += account.Mobile_Number_Temp__c!=null?'&mobile_number='+account.Mobile_Number_Temp__c:'';
        url += account.Office_Number_Temp__c!=null?'&office_number='+account.Office_Number_Temp__c:'';
        url += account.ID_Type__c!=null?'&id_type='+account.ID_Type__c:'';
        url += account.ID_Number_Temp__c!=null?'&id_number='+account.ID_Number_Temp__c:'';
        url +='&cancelURL=00Q';
        
        system.debug(Url);
        URLSF1 = Url;
        
        //return URLSF1;
        PageReference accountCreationPage=new PageReference(URLSF1);
        accountCreationPage.setRedirect(true);
        return accountCreationPage;
    }  
    public PageReference cancelSF1(){
        PageReference pr = Page.TaskEventHomeComponentMobile;
        pr.setRedirect(true);
        return pr;
    }
    
    // When user click to view sales
    public PageReference viewOwner(){
        PageReference userPage;
        try{
            System.debug('OWNER : '+ownerId);
            ownerUser = [SELECT Name FROM User WHERE ID=:ownerId];        
            userPage = new ApexPages.StandardController(ownerUser).view();
            userPage.setRedirect(true);
            
        }catch(QueryException E){
            ApexPages.addmessage(ErrorHandler.Messagehandler(QUERY_EXCEPTION_CODE, Status_Code__c.GetValues('1001').Status_Message__c));
            System.debug(logginglevel.ERROR,'Query Exception: '+e.getMessage());
            return null;
        }       
        return ApexPages.hasMessages() ? null : userPage;   
    }
    
    
    // When user click to view prospect or customer
    public PageReference viewProspect(){
        PageReference accountPage;
        try{    
            system.debug('acctId='+acctId);
            viewAccount = [SELECT Name FROM Account WHERE ID=:acctId];
            // Set Id to standard view for redirect
            accountPage = new ApexPages.StandardController(viewAccount).view();
            accountPage.setRedirect(true);
            
        }catch(QueryException e){
            /* QueryException   
* Any problem with SOQL queries, such as assigning a query that returns no records 
* or more than one record to a singleton sObject variable.
* */
            ApexPages.addmessage(ErrorHandler.Messagehandler(QUERY_EXCEPTION_CODE, Status_Code__c.GetValues('1001').Status_Message__c));
            System.debug(logginglevel.ERROR,'Query Exception: '+e.getMessage());          
        }
        return ApexPages.hasMessages() ? null : accountPage;       
        
    }
    
    
    // When user click to view lead
    public PageReference viewLead(){
        PageReference leadPage;
        try{    
            system.debug('acctId='+acctId);
            Lead viewLead = [SELECT Name FROM Lead WHERE ID=:acctId];
            leadPage = new ApexPages.StandardController(viewLead).view();
            leadPage.setRedirect(true);
            
        }catch(QueryException e){
            ApexPages.addmessage(ErrorHandler.Messagehandler(QUERY_EXCEPTION_CODE, Status_Code__c.GetValues('1001').Status_Message__c));
            System.debug(logginglevel.ERROR,'Query Exception: '+e.getMessage());          
        }
        return ApexPages.hasMessages() ? null : leadPage;       
        
    }
    
    
    //Keeps track of current page & max size of article list
    public Integer currentPage {get{
        if(currentPage ==null){
            currentPage = 1;
        }
        
        return currentPage;
    }set;}
    public Integer maxSize{get{
        if(maxSize ==null){
            maxSize = 1;
        }
        
        return maxSize;
    }set;}
    
    
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return AcctconSet.getHasNext();
        }
        set;
    }
    
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return AcctconSet.getHasPrevious();
        }
        set;
    }
    
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return AcctconSet.getPageNumber();
        }
        set;
    }
    
    
    
    // returns the first page of records
    public void first() {
        AcctconSet.first();
    }
    
    // returns the last page of records
    public void last() {
        AcctconSet.last();
    }
    
    // returns the previous page of records
    public void previous() {
        AcctconSet.previous();
    }
    
    // returns the next page of records
    public void next() {
        AcctconSet.next();
    }
    
    
    public String trimStr (String str ){
        List<String> splitStrList = str.split(' ');
        String custnametrim='';
        
        for(String split : splitStrList){
            
            if(split !='' && split !=' '){
                custnametrim += split.trim()+' ';
            }
        }
        return custnametrim;
        
        
    }
    // returns the PageReference of the original page, if known, or the home page.
    public Pagereference cancel() {
        PageReference pageRef = new PageReference('/lightning/page/home');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    //LeadSetController
    //
    //
     //Keeps track of current page & max size of article list
    public Integer LeadcurrentPage {get{
        if(currentPage ==null){
            currentPage = 1;
        }
        
        return LeadcurrentPage;
    }set;}
    public Integer LeadmaxSize{get{
        if(maxSize ==null){
            maxSize = 1;
        }
        
        return maxSize;
    }set;}
    
    
    // indicates whether there are more records after the current page set.
    public Boolean LeadhasNext {
        get {
            return Leadconset.getHasNext();
        }
        set;
    }
    
    // indicates whether there are more records before the current page set.
    public Boolean LeadhasPrevious {
        get {
            return Leadconset.getHasPrevious();
        }
        set;
    }
    
    // returns the page number of the current page set
    public Integer LeadpageNumber {
        get {
            return Leadconset.getPageNumber();
        }
        set;
    }
    
    
    
    // returns the first page of records
    public void Leadfirst() {
        Leadconset.first();
    }
    
    // returns the last page of records
    public void Leadlast() {
        Leadconset.last();
    }
    
    // returns the previous page of records
    public void Leadprevious() {
        Leadconset.previous();
    }
    
    // returns the next page of records
    public void Leadnext() {
        Leadconset.next();
    }
    
    //
    //
    
    
    //endregion
}