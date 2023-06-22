@isTest
public with sharing class TestUtils { 
    
    //public static final Id SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

    public static final Id SYSADMIN_PROFILE_ID{
        get
        {
            if(SYSADMIN_PROFILE_ID == null){
                SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
            }
            return SYSADMIN_PROFILE_ID;
        }
        set;
    }
    
    public static final Id TMB_SYSADMIN_PROFILE_ID{
        get
        {
            if(TMB_SYSADMIN_PROFILE_ID == null){
                TMB_SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB System Administrator' LIMIT 1].Id;
            }
            return TMB_SYSADMIN_PROFILE_ID;
        }
        set;
    }
    public static final String SUCCESS_CODE = '0000';
    public static final String QUERY_EXCEPTION_CODE = '1001';
    public static final String CALLOUT_EXCEPTION_CODE = '1002';
    public static final String FOUND_DUP_ALLOW_CREATE = '1010';
    public static final String FOUND_DUP_NOT_ALLOW_CREATE = '1011';
    public static final String WEBSERVICE_ERROR_CODE = '1003';
    public static final String DML_EXCEPTION_CODE = '1000';
    public static List<Account> accountList {
        get
        {
            if(accountList == null){
                accountList = new List<Account>();
            }
            return accountList;
            
        }set;
    }
    
    public static List<Contact> contactList {
        get
        {
            if(contactList == null){
                contactList = new List<Contact>();
            }
            return contactList;
            
        }set;
    }
    
    public static List<Campaign> campaignList {
        get
        {
            if(campaignList == null){
                campaignList = new List<Campaign>();
            }
            return campaignList;
            
        }set;
    }
    
    public static List<Opportunity> opportunityList {
        get
        {
            if(opportunityList == null){
                opportunityList = new List<Opportunity>();
            }
            return opportunityList;
            
        }set;
    }
    
    public static List<Product2> productList {
        get
        {
            if(productList == null){
                productList = new List<Product2>();
            }
            return productList;
            
        }set;
    }
    
    public static List<PricebookEntry> pricebookEntryList{
        get{
            if(pricebookEntryList == null){
                pricebookEntryList = new List<PricebookEntry>();
            }
            return pricebookEntryList;
        }set;
    }
    
    public static List<User> userList {
        get
        {
            if(userList == null){
                userList = new List<User>();
            }
            return userList;
            
        }set;
    }
       
    public static List<User> createUsers(Integer size , String FName , String LName , String Email , Boolean doInsert) {
        List<User> userToCreate = new List<User>();
        for(Integer i = 0;i<size;i++){
            User newUser = new User(FirstName = FName+i , LastName = LName+i, 
                                    UserName=FName+i+LName+i+'@tmbbank.com',
                                    Email=Email, Alias='Testtmb'+i,
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname=FName+i+'_'+LName+i+'_'+'TMBTesttmb'+i,
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='MM01'+i);
            userToCreate.add(newUser);
        }
        
        userList = userToCreate;
        if(doInsert){
            
            insert userToCreate;
        }
        
        return userToCreate;
    }
    
    public static List<Account> createAccounts(Integer size , String Fname,String CType, Boolean doInsert)
    {
        List<Account> accountsToCreate = new List<Account>();
        User AdminUser;
        for(Integer i =0 ; i<size ;++i)
        {   
            Account Acct = new Account(); 
            Acct.Name = 'Test Account '+Fname+' '+i;
            Acct.Phone ='050111222';
            Acct.Mobile_Number_PE__c  = '0801112233';
            Acct.ID_Type_PE__c  = 'Citizen ID';
            Acct.ID_Number_PE__c  = '1510100181965';
           
            Acct.Customer_Type__c = CType;
            Acct.First_name_PE__c = Fname;
            Acct.First_Name_ENG_PE__c = Fname;
            Acct.Last_name_PE__c = 'TestMock';
            Acct.Last_Name_PE_Eng__c  = 'TestMock';
            Acct.Rating = 'Hot';
            Acct.IsDisqualified__c = false;
            if(userList.size() > 0){
                AdminUser = userList.get(0);
                Acct.OwnerId = AdminUser.id; 
                
            }else{
                AdminUser = createUsers(1,'AccountOwner', 'Ownertest','OwnerIDtest@tmbbank.com', true).get(0);
                Acct.OwnerId = AdminUser.id;
                
            }
            
            accountsToCreate.add(acct);
            
        }
        accountList = accountsToCreate;
        
        if(doInsert){
            
            System.runAs(AdminUser){
                insert accountsToCreate;
            }
        }
        
        return accountsToCreate;
    }
    
    public static List<Contact> createContacts(Integer size,ID AccountId,Boolean doInsert ){
        List<Contact> contactsToCreate = new List<Contact>();
        for(Integer i=0;i<size;i++){
            Contact cont = new Contact();
            cont.AccountId = AccountId;
            cont.Salutation = 'Mr.';
            cont.LastName = 'contact_'+i; 
            cont.Date_of_Birth__c = Date.today();
            cont.Position__c = 'position1';
            cont.Value_Style__c = 'Risk Awareness';
            cont.Decision_Map__c = 'User';
            cont.Product_Decision__c = '';
            cont.Description__c = 'contact description';
            
                 cont.OwnerId  = userList.get(0).id;
            
                
            
            contactsToCreate.add(cont);
        }
        contactList = contactsToCreate;
        
        if(doInsert){
            insert contactsToCreate;
        }
        return contactsToCreate;
    }
    
    public static void createIdType (){

        
    }

    
    public static List<Status_Code__c> createStatusCode(){
        List<Status_Code__c> codelist = new List<Status_Code__c>();
        Status_Code__c success = new Status_Code__c();
        success.isError__c = false;
        success.Name = SUCCESS_CODE;
        success.Status_Message__c = 'Success : ';
        Status_Code__c error = new Status_Code__c();
        error.isError__c = true;
        error.Name = '0001';
        error.Status_Message__c = 'has an error message from respond :';
        Status_Code__c error04 = new Status_Code__c();
        error04.isError__c = true;
        error04.Name = '0004';
        error04.Status_Message__c = 'has an error message from respond :';
        Status_Code__c error05 = new Status_Code__c();
        error05.isError__c = true;
        error05.Name = '0005';
        error05.Status_Message__c = 'has an error message from respond :';
        Status_Code__c error1 = new Status_Code__c();
        error1.isError__c = true;
        error1.Name = QUERY_EXCEPTION_CODE;
        error1.Status_Message__c = 'Salesforce Error : Query Error';
        Status_Code__c error2 = new Status_Code__c();
        error2.isError__c = true;
        error2.Name = CALLOUT_EXCEPTION_CODE;
        error2.Status_Message__c = 'Salesforce Error : Webservice Callout Error';
        Status_Code__c error3 = new Status_Code__c();
        error3.isError__c = true;
        error3.Name = FOUND_DUP_ALLOW_CREATE;
        error3.Status_Message__c = 'Found duplication but can create';
        Status_Code__c error4 = new Status_Code__c();
        error4.isError__c = true;
        error4.Name = FOUND_DUP_NOT_ALLOW_CREATE;
        error4.Status_Message__c = 'Found duplication and can\'t create';
        Status_Code__c error5 = new Status_Code__c();
        error5.isError__c = true;
        error5.Name = WEBSERVICE_ERROR_CODE;
        error5.Status_Message__c = 'Webservice Error : Connection Timeout';             
        Status_Code__c error6 = new Status_Code__c();
        error6.isError__c = true;
        error6.Name = DML_EXCEPTION_CODE;
        error6.Status_Message__c = 'Salesforce Error : DML Error';  
        codelist.add(success);
        
                Status_Code__c error8 = new Status_Code__c();
        error8.isError__c = false;
        error8.Name = '3010';
        error8.Status_Message__c = 'Success';  
        
        Status_Code__c error9 = new Status_Code__c();
        error9.isError__c = false;
        error9.Name = '3004';
        error9.Status_Message__c = 'Test';  
        
        Status_Code__c error10 = new Status_Code__c();
        error10.isError__c = false;
        error10.Name = '3001';
        error10.Status_Message__c = 'Test';  

        Status_Code__c error11 = new Status_Code__c();
        error11.isError__c = false;
        error11.Name = '3012';
        error11.Status_Message__c = 'Test';  
        Status_Code__c error12 = new Status_Code__c();
        error12.isError__c = false;
        error12.Name = '3008';
        error12.Status_Message__c = 'Test';  
        Status_Code__c error13 = new Status_Code__c();
        error13.isError__c = false;
        error13.Name = '3003';
        error13.Status_Message__c = 'Test';  
                Status_Code__c error14 = new Status_Code__c();
        error14.isError__c = false;
        error14.Name = '3013';
        error14.Status_Message__c = 'Test'; 
                Status_Code__c error15 = new Status_Code__c();
        error15.isError__c = false;
        error15.Name = '3014';
        error15.Status_Message__c = 'Test'; 
        Status_Code__c error16 = new Status_Code__c();
        error16.isError__c = false;
        error16.Name = '3002';
        error16.Status_Message__c = 'Test';
        Status_Code__c error17 = new Status_Code__c();
        error17.isError__c = false;
        error17.Name = '3016';
        error17.Status_Message__c = 'Test'; 
        Status_Code__c error18 = new Status_Code__c();
        error18.isError__c = false;
        error18.Name = '3011';
        error18.Status_Message__c = 'Test'; 
        Status_Code__c error19 = new Status_Code__c();
        error19.isError__c = false;
        error19.Name = '3006';
        error19.Status_Message__c = 'Test';
         Status_Code__c error20 = new Status_Code__c();
        error20.isError__c = false;
        error20.Name = '3005';
        error20.Status_Message__c = 'Test'; 
         Status_Code__c error21 = new Status_Code__c();
        error21.isError__c = false;
        error21.Name = '3009';
        error21.Status_Message__c = 'Test'; 
        //VisitPlan
        Status_Code__c error22 = new Status_Code__c();
        error22.isError__c = false;
        error22.Name = '7001';
        error22.Status_Message__c = 'Test';  
        Status_Code__c error23 = new Status_Code__c();
        error23.isError__c = false;
        error23.Name = '7002';
        error23.Status_Message__c = 'Test';  
                Status_Code__c error24 = new Status_Code__c();
        error24.isError__c = false;
        error24.Name = '7003';
        error24.Status_Message__c = 'Test'; 
                Status_Code__c error25 = new Status_Code__c();
        error25.isError__c = false;
        error25.Name = '7004';
        error25.Status_Message__c = 'Test'; 
        Status_Code__c error26 = new Status_Code__c();
        error26.isError__c = false;
        error26.Name = '7006';
        error26.Status_Message__c = 'Test';
        Status_Code__c error27 = new Status_Code__c();
        error27.isError__c = false;
        error27.Name = '7007';
        error27.Status_Message__c = 'Test'; 
        Status_Code__c error28 = new Status_Code__c();
        error28.isError__c = false;
        error28.Name = '7008';
        error28.Status_Message__c = 'Test'; 
        Status_Code__c error29 = new Status_Code__c();
        error29.isError__c = false;
        error29.Name = '7009';
        error29.Status_Message__c = 'Test';
         Status_Code__c error30 = new Status_Code__c();
        error30.isError__c = false;
        error30.Name = '7010';
        error30.Status_Message__c = 'Test'; 
        
        //Lead
        //
        Status_Code__c error31 = new Status_Code__c();
        error31.isError__c = false;
        error31.Name = '6001';
        error31.Status_Message__c = 'Test';  
        Status_Code__c error32 = new Status_Code__c();
        error32.isError__c = false;
        error32.Name = '6002';
        error32.Status_Message__c = 'Test';  
                Status_Code__c error33 = new Status_Code__c();
        error33.isError__c = false;
        error33.Name = '6003';
        error33.Status_Message__c = 'Test'; 
                Status_Code__c error34 = new Status_Code__c();
        error34.isError__c = false;
        error34.Name = '6004';
        error34.Status_Message__c = 'Test'; 
        Status_Code__c error35 = new Status_Code__c();
        error35.isError__c = false;
        error35.Name = '6005';
        error35.Status_Message__c = 'Test';
        Status_Code__c error36 = new Status_Code__c();
        error36.isError__c = false;
        error36.Name = '6006';
        error36.Status_Message__c = 'Test'; 
        Status_Code__c error37 = new Status_Code__c();
        error37.isError__c = false;
        error37.Name = '6007';
        error37.Status_Message__c = 'Test'; 
        Status_Code__c error38 = new Status_Code__c();
        error38.isError__c = false;
        error38.Name = '6008';
        error38.Status_Message__c = 'Test';
         Status_Code__c error39 = new Status_Code__c();
        error39.isError__c = false;
        error39.Name = '6009';
        error39.Status_Message__c = 'Test';
        Status_Code__c error40 = new Status_Code__c();
        error40.isError__c = false;
        error40.Name = '6010';
        error40.Status_Message__c = 'Test';
        Status_Code__c error41 = new Status_Code__c();
        error41.isError__c = false;
        error41.Name = '6011';
        error41.Status_Message__c = 'Test'; 
        Status_Code__c error42 = new Status_Code__c();
        error42.isError__c = false;
        error42.Name = '6012';
        error42.Status_Message__c = 'Test'; 
        Status_Code__c error43= new Status_Code__c();
        error43.isError__c = false;
        error43.Name = '6013';
        error43.Status_Message__c = 'Test';
         Status_Code__c error44 = new Status_Code__c();
        error44.isError__c = false;
        error44.Name = '6014';
        error44.Status_Message__c = 'Test';
         
        
        // Upload Lead
        Status_Code__c error45 = new Status_Code__c();
        error45.isError__c = false;
        error45.Name = '5001';
        error45.Status_Message__c = 'Test2';
        Status_Code__c error46 = new Status_Code__c();
        error46.isError__c = false;
        error46.Name = '5002';
        error46.Status_Message__c = 'Test2';
        Status_Code__c error47 = new Status_Code__c();
        error47.isError__c = false;
        error47.Name = '5003';
        error47.Status_Message__c = 'Test2';
        Status_Code__c error48 = new Status_Code__c();
        error48.isError__c = false;
        error48.Name = '5004';
        error48.Status_Message__c = 'Test2';
        Status_Code__c error49 = new Status_Code__c();
        error49.isError__c = false;
        error49.Name = '5005';
        error49.Status_Message__c = 'Test2';
        Status_Code__c error50 = new Status_Code__c();
        error50.isError__c = false;
        error50.Name = '5006';
        error50.Status_Message__c = 'Test2';
        Status_Code__c error51 = new Status_Code__c();
        error51.isError__c = false;
        error51.Name = '5007';
        error51.Status_Message__c = 'Test2';
        Status_Code__c error52 = new Status_Code__c();
        error52.isError__c = false;
        error52.Name = '5008';
        error52.Status_Message__c = 'Test2';
        Status_Code__c error53 = new Status_Code__c();
        error53.isError__c = false;
        error53.Name = '5009';
        error53.Status_Message__c = 'Test2';
        Status_Code__c error54 = new Status_Code__c();
        error54.isError__c = false;
        error54.Name = '5010';
        error54.Status_Message__c = 'Test2';
        Status_Code__c error55 = new Status_Code__c();
        error55.isError__c = false;
        error55.Name = '5011';
        error55.Status_Message__c = 'Test2';
        Status_Code__c error56 = new Status_Code__c();
        error56.isError__c = false;
        error56.Name = '5012';
        error56.Status_Message__c = 'Test2';
        Status_Code__c error57 = new Status_Code__c();
        error57.isError__c = false;
        error57.Name = '5013';
        error57.Status_Message__c = 'Test2';
        Status_Code__c error58 = new Status_Code__c();
        error58.isError__c = false;
        error58.Name = '5014';
        error58.Status_Message__c = 'Test2';
        Status_Code__c error59 = new Status_Code__c();
        error59.isError__c = false;
        error59.Name = '5015';
        error59.Status_Message__c = 'Test2';
        Status_Code__c error60 = new Status_Code__c();
        error60.isError__c = false;
        error60.Name = '5016';
        error60.Status_Message__c = 'Test2';
        Status_Code__c error61 = new Status_Code__c();
        error61.isError__c = false;
        error61.Name = '5017';
        error61.Status_Message__c = 'Test2';
        Status_Code__c error62 = new Status_Code__c();
        error62.isError__c = false;
        error62.Name = '5018';
        error62.Status_Message__c = 'Test2';
        Status_Code__c error63 = new Status_Code__c();
        error63.isError__c = false;
        error63.Name = '5019';
        error63.Status_Message__c = 'Test2';
        Status_Code__c error64 = new Status_Code__c();
        error64.isError__c = false;
        error64.Name = '5020';
        error64.Status_Message__c = 'Test2';
        Status_Code__c error65 = new Status_Code__c();
        error65.isError__c = false;
        error65.Name = '5021';
        error65.Status_Message__c = 'Test2';
        Status_Code__c error66 = new Status_Code__c();
        error66.isError__c = false;
        error66.Name = '5022';
        error66.Status_Message__c = 'Test2';
        Status_Code__c error67 = new Status_Code__c();
        error67.isError__c = false;
        error67.Name = '5023';
        error67.Status_Message__c = 'Test2';
        Status_Code__c error69 = new Status_Code__c();
        error69.isError__c = false;
        error69.Name = '5101';
        error69.Status_Message__c = 'Test2';
        Status_Code__c error70 = new Status_Code__c();
        error70.isError__c = false;
        error70.Name = '5102';
        error70.Status_Message__c = 'Test2';
        Status_Code__c error71 = new Status_Code__c();
        error71.isError__c = false;
        error71.Name = '5103';
        error71.Status_Message__c = 'Test2';
        Status_Code__c error72 = new Status_Code__c();
        error72.isError__c = false;
        error72.Name = '5104';
        error72.Status_Message__c = 'Test2';
        Status_Code__c error73 = new Status_Code__c();
        error73.isError__c = false;
        error73.Name = '5105';
        error73.Status_Message__c = 'Test2';
        Status_Code__c error74 = new Status_Code__c();
        error74.isError__c = false;
        error74.Name = '5106';
        error74.Status_Message__c = 'Test2';
        Status_Code__c error75 = new Status_Code__c();
        error75.isError__c = false;
        error75.Name = '5107';
        error75.Status_Message__c = 'Test2';
        Status_Code__c error76 = new Status_Code__c();
        error76.isError__c = false;
        error76.Name = '5108';
        error76.Status_Message__c = 'Test2';
        
        //Action Extension
         Status_Code__c error77 = new Status_Code__c();
        error77.isError__c = false;
        error77.Name = '6100';
        error77.Status_Message__c = 'Test';
         Status_Code__c error78 = new Status_Code__c();
        error78.isError__c = false;
        error78.Name = '6101';
        error78.Status_Message__c = 'Test';
         Status_Code__c error79 = new Status_Code__c();
        error79.isError__c = false;
        error79.Name = '6102';
        error79.Status_Message__c = 'Test';
         Status_Code__c error80 = new Status_Code__c();
        error80.isError__c = false;
        error80.Name = '6103';
        error80.Status_Message__c = 'Test';
         Status_Code__c error81 = new Status_Code__c();
        error81.isError__c = false;
        error81.Name = '6104';
        error81.Status_Message__c = 'Test';
         Status_Code__c error82 = new Status_Code__c();
        error82.isError__c = false;
        error82.Name = '6105';
        error82.Status_Message__c = 'Test';
         Status_Code__c error83 = new Status_Code__c();
        error83.isError__c = false;
        error83.Name = '6106';
        error83.Status_Message__c = 'Test';
        Status_Code__c error84 = new Status_Code__c();
        error84.isError__c = false;
        error84.Name = '6107';
        error84.Status_Message__c = 'Test';
        Status_Code__c error85 = new Status_Code__c();
        error85.isError__c = false;
        error85.Name = '6108';
        error85.Status_Message__c = 'Test';
        Status_Code__c error86 = new Status_Code__c();
        error86.isError__c = false;
        error86.Name = '6109';
        error86.Status_Message__c = 'Test';
        Status_Code__c error87 = new Status_Code__c();
        error87.isError__c = false;
        error87.Name = '6110';
        error87.Status_Message__c = 'Test';
        
        
        Status_Code__c error88 = new Status_Code__c();
        error88.isError__c = false;
        error88.Name = '8001';
        error88.Status_Message__c = 'Test';
        Status_Code__c error89 = new Status_Code__c();
        error89.isError__c = false;
        error89.Name = '8005';
        error89.Status_Message__c = 'Test';
        Status_Code__c error90 = new Status_Code__c();
        error90.isError__c = false;
        error90.Name = '8013';
        error90.Status_Message__c = 'Test';
        
         Status_Code__c error91 = new Status_Code__c();
        error91.isError__c = false;
        error91.Name = '5043';
        error91.Status_Message__c = 'Test';
        
        /*CR R8 by Jantanee Saetung*/
        Status_Code__c error92 = new Status_Code__c();
        error92.isError__c = false;
        error92.Name = '5048';
        error92.Status_Message__c = 'Test5048';
        
        Status_Code__c error93 = new Status_Code__c();
        error93.isError__c = false;
        error93.Name = '5049';
        error93.Status_Message__c = 'Test5049';
        
        Status_Code__c error94 = new Status_Code__c();
        error94.isError__c = false;
        error94.Name = '6020';
        error94.Status_Message__c = 'Test6020';
        
        Status_Code__c error95 = new Status_Code__c();
        error95.isError__c = false;
        error95.Name = '6021';
        error95.Status_Message__c = 'Test6021';
        
        Status_Code__c error96 = new Status_Code__c();
        error96.isError__c = false;
        error96.Name = '6111';
        error96.Status_Message__c = 'Test6111';
        
        Status_Code__c error97 = new Status_Code__c();
        error97.isError__c = false;
        error97.Name = '6112';
        error97.Status_Message__c = 'Test6112';
        
        Status_Code__c error98 = new Status_Code__c();
        error98.isError__c = false;
        error98.Name = '4001';
        error98.Status_Message__c = 'Test4001';
        
        Status_Code__c error99 = new Status_Code__c();
        error99.isError__c = false;
        error99.Name = '4002';
        error99.Status_Message__c = 'Test4002';
        
        Status_Code__c error100 = new Status_Code__c();
        error100.isError__c = false;
        error100.Name = '4003';
        error100.Status_Message__c = 'Test4003';
        
        Status_Code__c error101 = new Status_Code__c();
        error101.isError__c = false;
        error101.Name = '4004';
        error101.Status_Message__c = 'Test4004';
        
        Status_Code__c error102 = new Status_Code__c();
        error102.isError__c = false;
        error102.Name = '4005';
        error102.Status_Message__c = 'Test4005';
        
        Status_Code__c error103 = new Status_Code__c();
        error103.isError__c = false;
        error103.Name = '4006';
        error103.Status_Message__c = 'Test4006';
        
        Status_Code__c error104 = new Status_Code__c();
        error104.isError__c = false;
        error104.Name = '4007';
        error104.Status_Message__c = 'Test4007';
        
        Status_Code__c error105 = new Status_Code__c();
        error105.isError__c = false;
        error105.Name = '4008';
        error105.Status_Message__c = 'Test4008';
        
        Status_Code__c error106 = new Status_Code__c();
        error106.isError__c = false;
        error106.Name = '4009';
        error106.Status_Message__c = 'Test4009';
        
         Status_Code__c error107 = new Status_Code__c();
        error107.isError__c = false;
        error107.Name = '6018';
        error107.Status_Message__c = 'Test6018';
        
         Status_Code__c error108 = new Status_Code__c();
        error108.isError__c = false;
        error108.Name = '6019';
        error108.Status_Message__c = 'Test6019';
        
        //Fixed[2018-03]: BAU_6785 (INC0046474) - CRM-Unable to complete survey & Convert leads
        Status_Code__c error9001 = new Status_Code__c();
        error9001.isError__c = false;
        error9001.Name = '9001';
        error9001.Status_Message__c = 'Test9001';
        
        //202108_INC0171769
        Status_Code__c error6003a = new Status_Code__c();
        error6003a.isError__c = false;
        error6003a.Name = '6003a';
        error6003a.Status_Message__c = 'Test6003a';
        
        codelist.add(error);
        codelist.add(error1);
        codelist.add(error2);
        codelist.add(error3);
        codelist.add(error4);
        codelist.add(error5);
        codelist.add(error6);
        codelist.add(error04);
        codelist.add(error05);
        codelist.add(error8);
        codelist.add(error9);
        codelist.add(error10);
        codelist.add(error11);
        codelist.add(error12);
        codelist.add(error13);
        codelist.add(error14);
        codelist.add(error15);
        codelist.add(error16);
        codelist.add(error17);
        codelist.add(error18);
        codelist.add(error19);
        codelist.add(error20);
        codelist.add(error21);
        codelist.add(error22);
        codelist.add(error23);
        codelist.add(error24);
        codelist.add(error25);
        codelist.add(error26);
        codelist.add(error27);
        codelist.add(error28);
        codelist.add(error29);
        codelist.add(error30);
        
        codelist.add(error31);
        codelist.add(error32);
        codelist.add(error33);
        codelist.add(error34);
        codelist.add(error35);
        codelist.add(error36);
        codelist.add(error37);
        codelist.add(error38);
        codelist.add(error39);
        codelist.add(error40);
        codelist.add(error41);
        codelist.add(error42);
        codelist.add(error43);
        codelist.add(error44);
        
        
        codelist.add(error45);
        codelist.add(error46);
        codelist.add(error47);
        codelist.add(error48);
        codelist.add(error49);
        codelist.add(error50);
        codelist.add(error51);
        codelist.add(error52);
        codelist.add(error53);
        codelist.add(error54);
        codelist.add(error55);
        codelist.add(error56);
        codelist.add(error57);
        codelist.add(error58);
        codelist.add(error59);
        codelist.add(error60);
        codelist.add(error61);
        codelist.add(error62);
        codelist.add(error63);
        codelist.add(error64);
        codelist.add(error65);
        codelist.add(error66);
        codelist.add(error67);
        codelist.add(error69);
        codelist.add(error70);
        codelist.add(error71);
        codelist.add(error72);
        codelist.add(error73);
        codelist.add(error74);
        codelist.add(error75);
        codelist.add(error76);
        codelist.add(error77);
        codelist.add(error78);
        codelist.add(error79);
        codelist.add(error80);
        codelist.add(error81);
        codelist.add(error82);
        codelist.add(error83);
        codelist.add(error84);
        codelist.add(error85);
        codelist.add(error86);
        codelist.add(error87);
        
        codelist.add(error88);
        codelist.add(error89);
        codelist.add(error90);
        codelist.add(error91);
        codelist.add(error92);
        codelist.add(error93);
        codelist.add(error94);
        codelist.add(error95);
        codelist.add(error96);
        codelist.add(error97);
        //4001-4009
        codelist.add(error98);
        codelist.add(error99);
        codelist.add(error100);
        codelist.add(error101);
        codelist.add(error102);
        codelist.add(error103);
        codelist.add(error104);
        codelist.add(error105);
        codelist.add(error106);
        
        codelist.add(error107);
        codelist.add(error108);
        
        codelist.add(error9001);
        
        codelist.add(error6003a);
        
        insert codelist;
        return codelist;
    }
    
    public static void createAppConfig(){     
        
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'false';        
        apps.add(Aconfig);
        
        AppConfig__c AconfigU = new AppConfig__c();
        AconfigU.Name = 'runUserTrigger';
        AconfigU.Value__c = 'false';        
        apps.add(AconfigU);
        
        AppConfig__c Aconfig2 = new AppConfig__c();
        Aconfig2.Name = 'CertName';
        Aconfig2.Value__c = 'TMB-UAT'; 
        apps.add(Aconfig2);

        AppConfig__c Aconfig3 = new AppConfig__c();
        Aconfig3.Name = 'runRetailCampaignMemberTrigger';
        Aconfig3.Value__c = 'true'; 
        apps.add(Aconfig3);
        
        AppConfig__c Aconfig4 = new AppConfig__c();
        Aconfig4.Name = 'runReferralTrigger';
        Aconfig4.Value__c = 'true'; 
        apps.add(Aconfig4);

        AppConfig__c Aconfig5 = new AppConfig__c();
        Aconfig5.Name = 'CXM_ENDPOINT';
        Aconfig5.Value__c = 'https://sfmashupservices.fortestclass.com/common/CXM_FORTEST/UAT_FORTEST/CXMGateway/ForwardTaskEvent';        
        apps.add(Aconfig5);

        AppConfig__c Aconfig6 = new AppConfig__c();
        Aconfig6.Name = 'runCustomerNoteTrigger';
        Aconfig6.Value__c = 'true'; 
        apps.add(Aconfig6);
        
        AppConfig__c smstimeout = new AppConfig__c();
        smstimeout.Name = 'SMS_Timeout';
        smstimeout.Value__c = '60';
        apps.add(smstimeout);
        
        AppConfig__c keyencrypt = new AppConfig__c();
        keyencrypt.Name = 'encrypt_CardKey';
        keyencrypt.Value__c = 'ABCCRM71111f&uexjflmdka(-yjr2ABC';
        apps.add(keyencrypt);
        
        AppConfig__c fcrChannel = new AppConfig__c();
        fcrChannel.Name = 'FCR_Channel';
        fcrChannel.Value__c = 'Email - TMBWeb, Email - Touch, Email - ME, Live Chat, Email - TMB Advisory';
        apps.add(fcrChannel);
        
        AppConfig__c fcrCategory = new AppConfig__c();
        fcrCategory.Name = 'FCR_Category';
        fcrCategory.Value__c = 'Inquiry, Feedback';
        apps.add(fcrCategory);

        AppConfig__c pdpatimeOut = new AppConfig__c();
        pdpatimeOut.Name = 'PDPA_Timeout';
        pdpatimeOut.Value__c = '2';
        apps.add(pdpatimeOut);

        AppConfig__c refAssignNULL = new AppConfig__c();
        refAssignNULL.Name = 'RTL_Referral_Assignment_ISNULL';
        refAssignNULL.Value__c = 'IS NULL';
        apps.add(refAssignNULL);

        AppConfig__c refAssignNotNULL = new AppConfig__c();
        refAssignNotNULL.Name = 'RTL_Referral_Assignment_NOTNULL';
        refAssignNotNULL.Value__c = 'IS NOT NULL';
        apps.add(refAssignNotNULL);

        insert apps;
        
        // Add this method following the CR Change owner from Retail to Commercial 
        createAppConfigRetailtoComm();
        //add SMSHandler Test
        createSMSNotiHandler();
    }

    
    public static void createSMSNotiHandler() {
        List<SMS_Notification_Handler__c> smsLst = new List<SMS_Notification_Handler__c>();

        SMS_Notification_Handler__c smsHandler = new SMS_Notification_Handler__c();
        smsHandler.Name = 'SMS_CASE_Notification';
        smsHandler.Account_Name_Field__c = 'Account.Name';
        smsHandler.Accout_ID_Field__c = 'AccountId';
        smsHandler.Field_Trigger__c = '';
        smsHandler.IsActive__c = true;
        smsHandler.Language__c = 'th';
        smsHandler.Object__c = 'Case';
        smsHandler.Service__c = 'SMS_CASE_Notification';
        smsHandler.SMS_Fee_Charging_1__c = '{"RBG,ME":{"office_code":"1096","service_code":"OTHCRMRTC"},"WBG":{"office_code":"1050","service_code":"OTHCRMCSCC"}}';
        smsHandler.SMS_Fee_Charging_2__c =  '';

        smsHandler.SMS_Fee_Charging_3__c = '';
        smsHandler.force__c = 'true';
        smsHandler.search__c = 'false';
        smsHandler.SMS_Template_Id__c = '{"*":["CaseNumber","Customer_Name__c","Contact_Person_Name__c","Sub_Category__c","Product_Category__c"]}  ';
        smsHandler.SMS_Template_Id_2__c = '{"*":["CaseNumber","Customer_Name__c","Contact_Person_Name__c","Sub_Category__c","Product_Category__c"]} ';
        smsHandler.SMS_To_Phone_Number__c = 'SMS_Mobile_Endpoint__c';
        smsHandler.Sponsor_Class_Field__c = 'PTA_Segment__c';
        smsHandler.TMB_Cust_ID__c = 'Customer_ID__c';

        smsHandler.Field_Update_After_SMS__c = '{"Status" : ["Completed"]}';

        smsLst.add(smsHandler);
        insert smsLst;
              
        List<Case_SMS_Code_Mapping__c> caseSMSCodeList = New List<Case_SMS_Code_Mapping__c>();
        Case_SMS_Code_Mapping__c caseSMSCodeNew = New Case_SMS_Code_Mapping__c();
        caseSMSCodeNew.name = 'S01';
        caseSMSCodeNew.Case_Status__c = 'New';
        caseSMSCodeNew.Field_SMS_Code_API__c = 'SMS_Code_New__c';
        caseSMSCodeList.add(caseSMSCodeNew);
        
        Case_SMS_Code_Mapping__c caseSMSCodeInPro = New Case_SMS_Code_Mapping__c();
        caseSMSCodeInPro.Name = 'S02';
        caseSMSCodeInPro.Case_Status__c = 'In progress';
        caseSMSCodeInPro.Field_SMS_Code_API__c = 'SMS_Code_In_Progress__c';
        caseSMSCodeList.add(caseSMSCodeInPro);
        
        Case_SMS_Code_Mapping__c caseSMSCodeResolve = New Case_SMS_Code_Mapping__c();
        caseSMSCodeResolve.Name = 'S03';
        caseSMSCodeResolve.Case_Status__c = 'Resolved';
        caseSMSCodeResolve.Field_SMS_Code_API__c = 'SMS_Code_Resolved__c';
        caseSMSCodeList.add(caseSMSCodeResolve);
        
        insert caseSMSCodeList;       
       


       List<EIM_Map__c> eimList = new List<EIM_Map__c>();

        EIM_Map__c eim = new EIM_Map__c();
        
        eim.External_Field__c = 'CaseNumber';
        eim.Field_Order__c = Decimal.valueOf('1');
        eim.Field_Type__c = 'Request';
        eim.IsActive__c = true;
        eim.Job_Type__c = 'SMS_CASE_Notification';
        eim.Node__c = 'DataNode';
        eim.SF_Field__c = 'CaseNumber';
        eim.Object__c = 'Case';

        EIM_Map__c eim2 = new EIM_Map__c();
        
        eim2.External_Field__c = 'Customer_ID__c';
        eim2.Field_Order__c = Decimal.valueOf('2');
        eim2.Field_Type__c = 'Request';
        eim2.IsActive__c = true;
        eim2.Job_Type__c = 'SMS_CASE_Notification';
        eim2.Node__c = 'DataNode';
        eim2.SF_Field__c = 'Customer_ID__c';
        eim2.Object__c = 'Case';

        EIM_Map__c eim3 = new EIM_Map__c();
        
        eim3.External_Field__c = 'Send_SMS_Details__c';
        eim3.Field_Order__c = Decimal.valueOf('3');
        eim3.Field_Type__c = 'Request';
        eim3.IsActive__c = true;
        eim3.Job_Type__c = 'SMS_CASE_Notification';
        eim3.Node__c = 'DataNode';
        eim3.SF_Field__c = 'Send_SMS_Details__c';
        eim3.Object__c = 'Case';

        EIM_Map__c eim4 = new EIM_Map__c();
        
        eim4.External_Field__c = 'PTA_Segment__c';
        eim4.Field_Order__c = Decimal.valueOf('4');
        eim4.Field_Type__c = 'Request';
        eim4.IsActive__c = true;
        eim4.Job_Type__c = 'SMS_CASE_Notification';
        eim4.Node__c = 'DataNode';
        eim4.SF_Field__c = 'PTA_Segment__c';
        eim4.Object__c = 'Case';

        EIM_Map__c eim5 = new EIM_Map__c();
        
        eim5.External_Field__c = 'Customer_Name__c';
        eim5.Field_Order__c = Decimal.valueOf('5');
        eim5.Field_Type__c = 'Request';
        eim5.IsActive__c = true;
        eim5.Job_Type__c = 'SMS_CASE_Notification';
        eim5.Node__c = 'DataNode';
        eim5.SF_Field__c = 'Customer_Name__c';
        eim5.Object__c = 'Case';

        EIM_Map__c eim6 = new EIM_Map__c();

        eim6.External_Field__c = 'Contact_Person_Name__c';
        eim6.Field_Order__c = Decimal.valueOf('6');
        eim6.Field_Type__c = 'Request';
        eim6.IsActive__c = true;
        eim6.Job_Type__c = 'SMS_CASE_Notification';
        eim6.Node__c = 'DataNode';
        eim6.SF_Field__c = 'Contact_Person_Name__c';
        eim6.Object__c = 'Case';

        EIM_Map__c eim7 = new EIM_Map__c();

        eim7.External_Field__c = 'Sub_Category__c';
        eim7.Field_Order__c = Decimal.valueOf('7');
        eim7.Field_Type__c = 'Request';
        eim7.IsActive__c = true;
        eim7.Job_Type__c = 'SMS_CASE_Notification';
        eim7.Node__c = 'DataNode';
        eim7.SF_Field__c = 'Sub_Category__c';
        eim7.Object__c = 'Case';

        EIM_Map__c eim8 = new EIM_Map__c();

        eim8.External_Field__c = 'Product_Category__c';
        eim8.Field_Order__c = Decimal.valueOf('8');
        eim8.Field_Type__c = 'Request';
        eim8.IsActive__c = true;
        eim8.Job_Type__c = 'SMS_CASE_Notification';
        eim8.Node__c = 'DataNode';
        eim8.SF_Field__c = 'Product_Category__c';
        eim8.Object__c = 'Case';

        EIM_Map__c eim9 = new EIM_Map__c();

        eim9.External_Field__c = 'SMS_Auto_Completed__c';
        eim9.Field_Order__c = Decimal.valueOf('9');
        eim9.Field_Type__c = 'Request';
        eim9.IsActive__c = true;
        eim9.Job_Type__c = 'SMS_CASE_Notification';
        eim9.Node__c = 'DataNode';
        eim9.SF_Field__c = 'SMS_Auto_Completed__c';
        eim9.Object__c = 'Case';


        
        eimList.add(eim);
        eimList.add(eim2);
        eimList.add(eim3);
        eimList.add(eim4);
        eimList.add(eim5);
        eimList.add(eim6);
        eimList.add(eim7);
        eimList.add(eim8);
        eimList.add(eim9);

        insert eimList;

        List<Integration_Info__c> intInfoList = new List<Integration_Info__c>(); 

        Integration_Info__c intInfo = new Integration_Info__c();
        intInfo.Name = 'SMS_CASE_Notification';
        intInfo.Endpoint__c = 'not_use';
        intInfo.Request_Format__c = 'application/json';
        intInfo.Response_Format__c = 'application/json ';
        intInfo.Timeout__c = Decimal.valueOf('2');

        intInfoList.add(intInfo);
        insert intInfoList;

    }
    
    // Add this method following the CR Change owner from Retail to Commercial 
    public static void createAppConfigRetailtoComm(){     
      List<AppConfig__c> apps = new  List<AppConfig__c>();
                
        AppConfig__c Aconfig3 = new AppConfig__c();
        Aconfig3.Name = 'FilterRetailSegment';
        Aconfig3.Value__c = '5|6|7|8|9';
        apps.add(Aconfig3);
        
        AppConfig__c Aconfig4 = new AppConfig__c();
        Aconfig4.Name = 'DefaultOwner';
        Aconfig4.Value__c = '00000';
        apps.add(Aconfig4);
        
        insert apps;
    }    
    

    
    public static Map<String,ID> CreateAddress(){
        Map<String,ID> addressmap = new Map<String,ID>();
        Sub_District__c   subdistrict = new Sub_District__c ();
        Province__c   province = new Province__C();
        District__c   district = new District__c();
        
        
        province.Name = 'กรุงเทพมหานคร';
        insert province;
        addressMap.put('Province',province.Id);
        district.Name ='เขตห้วยขวาง';
        district.Province__c = province.id;
        insert district;
        addressMap.put('District',district.Id);
        subdistrict.Name = 'ห้วยขวาง';
        subdistrict.Zip_code__c ='10230';
        subdistrict.District__c = district.id;
        insert subdistrict;
        addressMap.put('Sub District',subdistrict.Id);
        return addressMap;
    }
    
    public static List<Disqualified_Reason__c> createDisqualifiedReason(){
        List<Disqualified_Reason__c> disqualifiedReasonList = new List<Disqualified_Reason__c>();
        Disqualified_Reason__c reason1 = new Disqualified_Reason__c();
        reason1.Name = 'Duplicate';
        reason1.Value__c = 'with duplication';
        Disqualified_Reason__c reason2 = new Disqualified_Reason__c();
        reason2.Name = 'Webservice_Timeout';
        reason2.Value__c = 'communication fail';
        disqualifiedReasonList.add(reason1);
        disqualifiedReasonList.add(reason2);
        insert disqualifiedReasonList;
        return disqualifiedReasonList;
    }
    
    public static void createDateOfBirth(){

    }
    
    public static Integer calculateAge(Date birthDate){
        Integer Age;
        //FIX to Thinking same as Formula
        Date day = Date.today();
        
        if(day >= birthDate)
        {
          Age =   day.year() - birthDate.year();
        }
        else{
            Age =   day.year() - (birthDate.year() - 1);
        }  
        return Age;
    }
    
    public static void createObjUserPermission(){     
        
        List<ObjUserPermission__c> PermissionList = new  List<ObjUserPermission__c>();
        //ObjUserPermission__c UserPermission = [SELECT Set_ID__c FROM ObjUserPermission__c WHERE Name = : profileName LIMIT 1];
        //if(UserPermission != null)
        //{
        //}
        ObjUserPermission__c UserPermission = new ObjUserPermission__c();
        UserPermission.Name = 'System Administrator';
        UserPermission.Set_ID__c = SYSADMIN_PROFILE_ID;//UserPermission.Set_ID__c;
        PermissionList.add(UserPermission);
        
        ObjUserPermission__c UserPermission2 = new ObjUserPermission__c();
        UserPermission2.Name = 'TMB System Administrator';
        UserPermission2.Set_ID__c = TMB_SYSADMIN_PROFILE_ID;//UserPermission.Set_ID__c;
        PermissionList.add(UserPermission2);

        insert PermissionList;
                
        //return PermissionList;
    }
    
    public static void createAppConfig_Trigger(){     
        
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';        
        apps.add(Aconfig);
        
       // insert apps;
    }
    
    public static void CreateTriggerMsg(){
        List<Trigger_Msg__c> triggerlist = new List<Trigger_Msg__C>();
         Trigger_Msg__c Tmsg = new Trigger_Msg__c ();
        Tmsg.Name ='User_trigger_error_change';
        Tmsg.Description__c = 'You are not allowed to change user information.';
        triggerlist.add(Tmsg);
        Trigger_Msg__c Tmsg2 = new Trigger_Msg__c ();
        Tmsg2.Name ='User_trigger_error_insert';
        Tmsg2.Description__c = 'You are not allowed to insert user information.';
        triggerlist.add(Tmsg2);
        Trigger_Msg__c Tmsg3 = new Trigger_Msg__c ();
        Tmsg3.Name ='Visit_Plan_Not_Completed';
        Tmsg3.Description__c = 'You are not allowed to insert user information.';
        triggerlist.add(Tmsg3);
        Trigger_Msg__c Tmsg4 = new Trigger_Msg__c ();
        Tmsg4.Name ='Not_found_Visit_Plan';
        Tmsg4.Description__c = 'You are not allowed to insert user information.';
        triggerlist.add(Tmsg4);
        Trigger_Msg__c Tmsg5 = new Trigger_Msg__c ();
        Tmsg5.Name ='Submit_Approval_Success';
        Tmsg5.Description__c = 'You are not allowed to insert user information.';
        triggerlist.add(Tmsg5);
        Trigger_Msg__c Tmsg6 = new Trigger_Msg__c ();
        Tmsg6.Name ='Not_Found_ID_Populated';
        Tmsg6.Description__c = 'You are not allowed to insert user information.';
        triggerlist.add(Tmsg6);
        Trigger_Msg__c Tmsg7 = new Trigger_Msg__c ();
        Tmsg7.Name ='Approval_Qualified_Prospect_Only';
        Tmsg7.Description__c = 'Customer stage must be qualified prospect/Existing Customer and must be input Customer ID';
        triggerlist.add(Tmsg7);
        Trigger_Msg__c Tmsg8 = new Trigger_Msg__c ();
        Tmsg8.Name ='Missing_Product';
        Tmsg8.Description__c = 'Missing_Product';
        triggerlist.add(Tmsg8);
        
        insert triggerlist;
        
    }
    
    public static void CreateOpportunityStage(){
        List<Opportunity_Stage_Mapping__c > OppStgMap = new List< Opportunity_Stage_Mapping__c >();
        Opportunity_Stage_Mapping__c  oppmap1 = new Opportunity_Stage_Mapping__c (Name='1',Application_status__c='Pre Work',Stage__c='CA-Prep',Opportunity_Type__c ='Credit');
        Opportunity_Stage_Mapping__c  oppmap2 = new Opportunity_Stage_Mapping__c (Name='2',Application_status__c='Rejected Appeal',Stage__c='CA-Prep',Opportunity_Type__c ='Credit');
        Opportunity_Stage_Mapping__c  oppmap3 = new Opportunity_Stage_Mapping__c (Name='3',Application_status__c='UW1',Stage__c='Approval Process',Opportunity_Type__c ='Credit');
        Opportunity_Stage_Mapping__c  oppmap4 = new Opportunity_Stage_Mapping__c (Name='4',Application_status__c='UW2',Stage__c='Approval Process',Opportunity_Type__c ='Credit');
        Opportunity_Stage_Mapping__c  oppmap5 = new Opportunity_Stage_Mapping__c (Name='5',Application_status__c='Cancelled',Stage__c='Cancelled',Opportunity_Type__c ='Non-credit');
        Opportunity_Stage_Mapping__c  oppmap6 = new Opportunity_Stage_Mapping__c (Name='6',Application_status__c='Completed',Stage__c='Issued by Centralized',Opportunity_Type__c ='Non-credit');
        oppStgMap.add(oppmap1);
        oppStgMap.add(oppmap2);
        oppStgMap.add(oppmap3);
        oppStgMap.add(oppmap4);
        oppStgMap.add(oppmap5);
        oppStgMap.add(oppmap6);
        insert oppStgMap;
        
    }
    public static void CreateProceBookAccess(){
        List<Price_book_access__c> pbooklist = new List<Price_book_access__c>();
        Price_book_access__c pbook = new Price_book_access__c ();
        pbook.Name ='BB';
        pbook.PricebookItem__c = 'Commercial Pricebook';
        pbooklist.add(pbook);
        Price_book_access__c pbook2 = new Price_book_access__c ();
        pbook2.Name ='CB';
        pbook2.PricebookItem__c = 'Commercial Pricebook';
        pbooklist.add(pbook2);
        Price_book_access__c pbook3 = new Price_book_access__c ();
        pbook3.Name ='Default';
        pbook3.PricebookItem__c = 'Commercial Pricebook';
        pbooklist.add(pbook3);
        Price_book_access__c pbook4 = new Price_book_access__c ();
        pbook4.Name ='MB';
        pbook4.PricebookItem__c = 'Commercial Pricebook';
        pbooklist.add(pbook4);
        Price_book_access__c pbook5 = new Price_book_access__c ();
        pbook5.Name ='RMC';
        pbook5.PricebookItem__c = 'Commercial Pricebook';
        pbooklist.add(pbook5);
        Price_book_access__c pbook6 = new Price_book_access__c ();
        pbook6.Name ='SE';
        pbook6.PricebookItem__c = 'Commercial Pricebook';
        pbooklist.add(pbook6);
        insert pbooklist;
        
    }
    public static void CreateProceBook(){

        List<Pricebook2> pbooklist = new List<Pricebook2>();
        Pricebook2 pbook = new Pricebook2 ();
        pbook.Name ='Standard Price Book';
        pbook.TMB_Pricebook__c = 'TMB0001';
        pbook.Description = 'Standard Price Book Products';
        pbook.IsActive = true;
        pbooklist.add(pbook);
        
        Pricebook2 pbook2 = new Pricebook2 ();
        pbook2.Name ='SE Price Book';
        pbook2.TMB_Pricebook__c = 'TMB0002';
        pbook2.Description = 'SE Price Book Products';
        pbook2.IsActive = true;
        pbooklist.add(pbook2);
        
        Pricebook2 pbook3 = new Pricebook2 ();
        pbook3.Name ='WBG Price Book';
        pbook3.TMB_Pricebook__c = 'TMB0003';
        pbook3.Description = 'WBG Price Book Products';
        pbook3.IsActive = true;
        pbooklist.add(pbook3);
        
        Pricebook2 pbook4 = new Pricebook2 ();
        pbook4.Name ='Commercial Pricebook';
        pbook4.TMB_Pricebook__c = 'TMB0004';
        pbook4.Description = 'Commercial Pricebook Products';
        pbook4.IsActive = true;
        pbooklist.add(pbook4);
        
        insert pbooklist;
        
    }
    
    
    public static List<Campaign> createCampaign(Integer size,String segment,Boolean doInsert ){
        List<Campaign> CampaignToCreate = new List<Campaign>();
        for(Integer i=0;i<size;i++){
            Campaign camp = new Campaign();
            camp.Name = 'Campaign_'+i;
            camp.Segment__c = segment;
            camp.OwnerId  = userList.get(0).id;

            CampaignToCreate.add(camp);
        }
        campaignList = CampaignToCreate;
        
        if(doInsert){
            insert CampaignToCreate;
        }
        return CampaignToCreate;
    }
    // ma
    public static List<Opportunity> createOpportunity(Integer size,Id accountId,Boolean doInsert ){
        List<Opportunity> OpportunityToCreate = new List<Opportunity>();
        for(Integer i=0;i<size;i++){
            Opportunity opp = new Opportunity();
            opp.Name = 'OPP'+i;
            opp.AccountId = accountId;
            opp.StageName = 'Analysis';
            opp.OwnerId  = userList.get(0).id;
            opp.CloseDate = Date.today();
            opp.Expected_submit_date__c = Date.today();
            
            OpportunityToCreate.add(opp);
        }
        opportunityList = OpportunityToCreate;
        
        if(doInsert){
            insert OpportunityToCreate;
        }
        return OpportunityToCreate;
    }
    // ma
    public static List<OpportunityTeamMember> createOpportunityTeam(Integer size,Id opportunityId,List<User> user,Boolean doInsert){
        List<OpportunityTeamMember> OpportunityTeamToCreate = new List<OpportunityTeamMember>();
        for(Integer i = 0 ; i < size && i < user.size() ; i++){
            OpportunityTeamMember oppteam = new OpportunityTeamMember();
            oppteam.OpportunityId = opportunityId;
            oppteam.UserId = user.get(i).Id;
            oppteam.TeamMemberRole = 'Sales Rep';
            
            OpportunityTeamToCreate.add(oppteam);
        }
        if(doInsert){
            insert OpportunityTeamToCreate;
        }
        return OpportunityTeamToCreate;
    }
    // ma
    public static List<Product2> createProduct(Integer size , Boolean doInsert){
        List<Product2> ProductToCreate = new List<Product2>();
        for(Integer i = 0 ; i < size ; i++){
            Product2 prod = new Product2();
            prod.Name = 'PROD'+1;
            prod.Product_Domain__c = '1. Transactional Banking';
            prod.IsActive = true;
            prod.Family = 'Credit Product';
            prod.ProductCode = '12345678';
            ProductToCreate.add(prod);
        }
        productList = ProductToCreate;
        
        if(doInsert){
            insert ProductToCreate;
        }
        return ProductToCreate;
    }
    
    // ma 
    public static List<PricebookEntry> createPricebookEntry(Integer size ,Id pricebookId , List<Product2> product, Boolean doInsert){
        List<PricebookEntry> PricebookEntryToCreate = new List<PricebookEntry>();
        for(integer i = 0 ; i < size && i < product.size() ; i++){
            PricebookEntry priceEntry = new PricebookEntry();
            priceEntry.Pricebook2Id = pricebookId;
            priceEntry.Product2Id = product.get(i).Id;
            priceEntry.UnitPrice = 20000.00;
            priceEntry.IsActive = true;
            priceEntry.UseStandardPrice = false;
            PricebookEntryToCreate.add(priceEntry);
            
        }
        pricebookEntryList = PricebookEntryToCreate;
        if(doInsert){
            insert PricebookEntryToCreate;
        }
        return PricebookEntryToCreate;
    }
    
    public static List<OpportunityLineItem> createOpportunityProduct (Integer size ,Id opportunityId, List<PricebookEntry> pricebookEntry, Boolean doInsert){
        List<OpportunityLineItem> OppProductToCreate = new List<OpportunityLineItem>();
        for(integer i = 0 ; i < size && i < pricebookEntry.size() ; i++){
            OpportunityLineItem oppline = new OpportunityLineItem();
            oppline.OpportunityId = opportunityId;
            oppline.PricebookEntryId = pricebookEntry.get(i).Id;
            //oppline.TotalPrice = 2000;
            oppline.UnitPrice = 6000;
            oppline.Quantity = 1;
            OppProductToCreate.add(oppline);
        }
        If(doInsert){
            insert OppProductToCreate;
        }
        return OppProductToCreate;
    }
    
    public static void prepareEIMmaps(){
        List<EIM_Map__c> eimList = new List<EIM_Map__c>();
        //Case
        EIM_Map__c eim = new EIM_Map__c();
        eim.Attribute__c = '';
        eim.Attribute_value__c = '';
        eim.Default_Value__c = '';
        eim.External_Field__c = 'ID';
        eim.Field_Order__c = Decimal.valueOf('1');
        eim.Field_Type__c = 'Request';
        eim.IsActive__c = true;
        eim.Job_Type__c = 'CXMCaseService';
        eim.Node__c = 'DataNode';
        eim.Object__c = 'Case';
        eim.ParentNode__c = 'DataNode';
        eim.SF_Field__c = 'ID';
        eimList.add(eim);

        EIM_Map__c eim2 = new EIM_Map__c();
        eim2.Attribute__c = '';
        eim2.Attribute_value__c = '';
        eim2.Default_Value__c = '';
        eim2.External_Field__c = 'Status';
        eim2.Field_Order__c = Decimal.valueOf('2');
        eim2.Field_Type__c = 'Request';
        eim2.IsActive__c = true;
        eim2.Job_Type__c = 'CXMCaseService';
        eim2.Node__c = 'DataNode';
        eim2.Object__c = 'Case';
        eim2.ParentNode__c = '';
        eim2.SF_Field__c = 'Status';
        eimList.add(eim2);

        EIM_Map__c eim3 = new EIM_Map__c();
        eim3.Attribute__c = '';
        eim3.Attribute_value__c = '';
        eim3.Default_Value__c = '';
        eim3.External_Field__c = 'CaseNumber';
        eim3.Field_Order__c = Decimal.valueOf('3');
        eim3.Field_Type__c = 'Request';
        eim3.IsActive__c = true;
        eim3.Job_Type__c = 'CXMCaseService';
        eim3.Node__c = 'DataNode';
        eim3.Object__c = 'Case';
        eim3.ParentNode__c = '';
        eim3.SF_Field__c = 'CaseNumber';
        eimList.add(eim3);

        //Canpaign member
        EIM_Map__c eim4 = new EIM_Map__c();
        eim4.Attribute__c = '';
        eim4.Attribute_value__c = '';
        eim4.Default_Value__c = '';
        eim4.External_Field__c = 'ID';
        eim4.Field_Order__c = Decimal.valueOf('0');
        eim4.Field_Type__c = 'Request';
        eim4.IsActive__c = true;
        eim4.Job_Type__c = 'CMP_MEMBER_CXM';
        eim4.Node__c = 'DataNode';
        eim4.Object__c = 'CampaignMember';
        eim4.ParentNode__c = '';
        eim4.SF_Field__c = 'ID';
        eimList.add(eim4);

        EIM_Map__c eim5 = new EIM_Map__c();
        eim5.Attribute__c = '';
        eim5.Attribute_value__c = '';
        eim5.Default_Value__c = '';
        eim5.External_Field__c = 'RTL_CXM_Message_Type__c';
        eim5.Field_Order__c = Decimal.valueOf('1');
        eim5.Field_Type__c = 'Request';
        eim5.IsActive__c = true;
        eim5.Job_Type__c = 'CMP_MEMBER_CXM';
        eim5.Node__c = 'DataNode';
        eim5.Object__c = 'CampaignMember';
        eim5.ParentNode__c = '';
        eim5.SF_Field__c = 'RTL_CXM_Message_Type__c';
        eimList.add(eim5);

        EIM_Map__c eim6 = new EIM_Map__c();
        eim6.Attribute__c = '';
        eim6.Attribute_value__c = '';
        eim6.Default_Value__c = '';
        eim6.External_Field__c = 'RTL_Offer_Result__c';
        eim6.Field_Order__c = Decimal.valueOf('2');
        eim6.Field_Type__c = 'Request';
        eim6.IsActive__c = true;
        eim6.Job_Type__c = 'CMP_MEMBER_CXM';
        eim6.Node__c = 'DataNode';
        eim6.Object__c = 'CampaignMember';
        eim6.ParentNode__c = '';
        eim6.SF_Field__c = 'RTL_Offer_Result__c';
        eimList.add(eim6);

        EIM_Map__c eim7 = new EIM_Map__c();
        eim7.Attribute__c = '';
        eim7.Attribute_value__c = '';
        eim7.Default_Value__c = '';
        eim7.External_Field__c = 'RTL_Contact_status__c';
        eim7.Field_Order__c = Decimal.valueOf('3');
        eim7.Field_Type__c = 'Request';
        eim7.IsActive__c = true;
        eim7.Job_Type__c = 'CMP_MEMBER_CXM';
        eim7.Node__c = 'DataNode';
        eim7.Object__c = 'CampaignMember';
        eim7.ParentNode__c = '';
        eim7.SF_Field__c = 'RTL_Contact_status__c';
        eimList.add(eim7);

        //NBO History
        EIM_Map__c eim8 = new EIM_Map__c();
        eim8.Attribute__c = '';
        eim8.Attribute_value__c = '';
        eim8.Default_Value__c = '';
        eim8.External_Field__c = 'ID';
        eim8.Field_Order__c = Decimal.valueOf('0');
        eim8.Field_Type__c = 'Request';
        eim8.IsActive__c = true;
        eim8.Job_Type__c = 'NBO_PRODUCT_CXM';
        eim8.Node__c = 'DataNode';
        eim8.Object__c = 'RTL_NBO_History_Product__c';
        eim8.ParentNode__c = '';
        eim8.SF_Field__c = 'ID';
        eimList.add(eim8);

        EIM_Map__c eim9 = new EIM_Map__c();
        eim9.Attribute__c = '';
        eim9.Attribute_value__c = '';
        eim9.Default_Value__c = '';
        eim9.External_Field__c = 'RTL_NBO_Product_External_ID__c';
        eim9.Field_Order__c = Decimal.valueOf('1');
        eim9.Field_Type__c = 'Request';
        eim9.IsActive__c = true;
        eim9.Job_Type__c = 'NBO_PRODUCT_CXM';
        eim9.Node__c = 'DataNode';
        eim9.Object__c = 'RTL_NBO_History_Product__c';
        eim9.ParentNode__c = '';
        eim9.SF_Field__c = 'RTL_NBO_Product_External_ID__c';
        eimList.add(eim9);

        EIM_Map__c eim10 = new EIM_Map__c();
        eim10.Attribute__c = '';
        eim10.Attribute_value__c = '';
        eim10.Default_Value__c = '';
        eim10.External_Field__c = 'RTL_NBO_ID__c';
        eim10.Field_Order__c = Decimal.valueOf('2');
        eim10.Field_Type__c = 'Request';
        eim10.IsActive__c = true;
        eim10.Job_Type__c = 'NBO_PRODUCT_CXM';
        eim10.Node__c = 'DataNode';
        eim10.Object__c = 'RTL_NBO_History_Product__c';
        eim10.ParentNode__c = '';
        eim10.SF_Field__c = 'RTL_NBO_ID__c';
        eimList.add(eim10);

        EIM_Map__c eim11 = new EIM_Map__c();
        eim11.Attribute__c = '';
        eim11.Attribute_value__c = '';
        eim11.Default_Value__c = '';
        eim11.External_Field__c = 'RTL_Status__c';
        eim11.Field_Order__c = Decimal.valueOf('3');
        eim11.Field_Type__c = 'Request';
        eim11.IsActive__c = true;
        eim11.Job_Type__c = 'NBO_PRODUCT_CXM';
        eim11.Node__c = 'DataNode';
        eim11.Object__c = 'RTL_NBO_History_Product__c';
        eim11.ParentNode__c = '';
        eim11.SF_Field__c = 'RTL_Status__c';
        eimList.add(eim11);

        //Opportunity
        EIM_Map__c eim12 = new EIM_Map__c();
        eim12.Attribute__c = '';
        eim12.Attribute_value__c = '';
        eim12.Default_Value__c = '';
        eim12.External_Field__c = 'Name';
        eim12.Field_Order__c = Decimal.valueOf('0');
        eim12.Field_Type__c = 'Request';
        eim12.IsActive__c = true;
        eim12.Job_Type__c = 'OPPTY_TO_CXM';
        eim12.Node__c = 'DataNode';
        eim12.Object__c = 'Opportunity';
        eim12.ParentNode__c = '';
        eim12.SF_Field__c = 'Name';
        eimList.add(eim12);

        EIM_Map__c eim13 = new EIM_Map__c();
        eim13.Attribute__c = '';
        eim13.Attribute_value__c = '';
        eim13.Default_Value__c = '';
        eim13.External_Field__c = 'RTL_RecordType_DevName__c';
        eim13.Field_Order__c = Decimal.valueOf('1');
        eim13.Field_Type__c = 'Request';
        eim13.IsActive__c = true;
        eim13.Job_Type__c = 'OPPTY_TO_CXM';
        eim13.Node__c = 'DataNode';
        eim13.Object__c = 'Opportunity';
        eim13.ParentNode__c = '';
        eim13.SF_Field__c = 'RTL_RecordType_DevName__c';
        eimList.add(eim13);

        EIM_Map__c eim14 = new EIM_Map__c();
        eim14.Attribute__c = '';
        eim14.Attribute_value__c = '';
        eim14.Default_Value__c = '';
        eim14.External_Field__c = 'RTL_CXM_Product_Group__c';
        eim14.Field_Order__c = Decimal.valueOf('2');
        eim14.Field_Type__c = 'Request';
        eim14.IsActive__c = true;
        eim14.Job_Type__c = 'OPPTY_TO_CXM';
        eim14.Node__c = 'DataNode';
        eim14.Object__c = 'Opportunity';
        eim14.ParentNode__c = '';
        eim14.SF_Field__c = 'RTL_CXM_Product_Group__c';
        eimList.add(eim14);

        EIM_Map__c eim15 = new EIM_Map__c();
        eim15.Attribute__c = '';
        eim15.Attribute_value__c = '';
        eim15.Default_Value__c = '';
        eim15.External_Field__c = 'RTL_Prod_SubGrp__c';
        eim15.Field_Order__c = Decimal.valueOf('3');
        eim15.Field_Type__c = 'Request';
        eim15.IsActive__c = true;
        eim15.Job_Type__c = 'OPPTY_TO_CXM';
        eim15.Node__c = 'DataNode';
        eim15.Object__c = 'Opportunity';
        eim15.ParentNode__c = '';
        eim15.SF_Field__c = 'RTL_Prod_SubGrp__c';
        eimList.add(eim15);

        EIM_Map__c eim16 = new EIM_Map__c();
        eim16.Attribute__c = '';
        eim16.Attribute_value__c = '';
        eim16.Default_Value__c = '';
        eim16.External_Field__c = 'RTL_Product_Name__c';
        eim16.Field_Order__c = Decimal.valueOf('4');
        eim16.Field_Type__c = 'Request';
        eim16.IsActive__c = true;
        eim16.Job_Type__c = 'OPPTY_TO_CXM';
        eim16.Node__c = 'DataNode';
        eim16.Object__c = 'Opportunity';
        eim16.ParentNode__c = '';
        eim16.SF_Field__c = 'RTL_Product_Name__c';
        eimList.add(eim16);

        insert eimList;

    }

    public static void prepareIntegrationMapping(){
        //for Integration_Mapping__c
        List<Integration_Mapping__c> intMappingLst = new List<Integration_Mapping__c>();

        Integration_Mapping__c intMapp = new Integration_Mapping__c();
        intMapp.Condition_1__c = 'equals';
        intMapp.Condition_2__c = 'equals';
        intMapp.Condition_3__c = 'equals';
        intMapp.Field_Condition_1__c = 'Status';
        intMapp.Field_Condition_2__c = 'PTA_Segment__c';
        intMapp.Field_Condition_3__c = 'Category__c';
        intMapp.Field_Value_1__c = 'Completed';
        intMapp.Field_Value_2__c = 'RBG;ME';
        intMapp.Field_Value_3__c = 'Complaint';
        intMapp.Variable_Field_1__c = 'Id';
        intMapp.Name = 'CXMCaseService';
        intMapp.IsActive__c = true;
        intMappingLst.add(intMapp);

        Integration_Mapping__c intMapp2 = new Integration_Mapping__c();
        intMapp2.Condition_1__c = 'equals';
        intMapp2.Condition_2__c = 'equals';
        intMapp2.Field_Condition_1__c = 'RTL_Contact_Status__c';
        intMapp2.Field_Condition_2__c = 'RTL_Offer_Result__c';
        intMapp2.Field_Condition_3__c = 'RTL_Offer_Result__c';
        intMapp2.Field_Value_1__c = 'Contact,Contact (Walk-in/Call-in)';
        intMapp2.Field_Value_2__c = 'Interested,Not Interested';
        intMapp2.Field_Value_3__c = 'Interested,Not Interested';
        intMapp2.Name = 'CMP_MEMBER_CXM';
        intMapp2.IsActive__c = true;
        intMapp2.Variable_Field_1__c = 'ID';

        intMapp2.CXM_Channel__c = 'CRM-Campaign';
        intMapp2.Field_For_Log__c = 'ID';
        intMapp2.Is_CXM_Retry__c = true;
        intMapp2.ObjectName__c = 'CampaignMember'; 
        intMapp2.Batch_SQL__c = 'LastModifiedBy.RTL_Channel__c <> null';
        intMapp2.Account_Field_Name__c = 'Customer__r.Name';
        intMapp2.Account_Id_Field__c = 'Customer__c';       

        intMappingLst.add(intMapp2);
       

        Integration_Mapping__c intMapp4 = new Integration_Mapping__c();
        intMapp4.Condition_1__c = 'equals';
        intMapp4.Field_Condition_1__c = 'StageName';
        intMapp4.Field_Value_1__c = 'Closed Lost';
        intMapp4.Name = 'OPPTY_TO_CXM';
        intMapp4.IsActive__c = true;
        intMapp4.Variable_Field_1__c = 'ID';

        intMapp4.CXM_Channel__c = 'CRM-OPTY';
        intMapp4.Field_For_Log__c = 'ID';
        intMapp4.Is_CXM_Retry__c = true;
        intMapp4.ObjectName__c = 'Opportunity'; 
        intMapp4.Batch_SQL__c = 'LastModifiedBy.RTL_Channel__c <> null'; 
        intMapp4.Account_Field_Name__c = 'Account.Name';
        intMapp4.Account_Id_Field__c = 'AccountId';        

        intMappingLst.add(intMapp4);
       

        Integration_Mapping__c intMapp6 = new Integration_Mapping__c();
        intMapp6.Condition_1__c = 'equals';
        intMapp6.Field_Condition_1__c = 'Is_Sent_To_CXM__c';
        intMapp6.Field_Value_1__c = 'true';
        intMapp6.Name = 'NBO_PRODUCT_CXM';
        intMapp6.IsActive__c = true;
        intMapp6.Variable_Field_1__c = 'ID';
        intMapp6.CXM_Channel__c = 'CRM-NBO';
        intMapp6.Field_For_Log__c = 'RTL_NBO_Product_External_ID__c';
        intMapp6.Is_CXM_Retry__c = true;
        intMapp6.ObjectName__c = 'RTL_NBO_History_Product__c'; 
        intMapp6.Account_Field_Name__c = 'RTL_Related_NBO__r.RTL_Customer_Name__r.Name';
        intMapp6.Account_Id_Field__c = 'RTL_Related_NBO__r.RTL_Customer_Name__c';         

        intMappingLst.add(intMapp6);
       

        insert intMappingLst;
    }
    
    public static PermissionSet SetupPermissionSet(){
        PermissionSet ps = new PermissionSet(Name='ViewAllRecords',Label='ViewAllRecords');
        insert ps;
        List<ObjectPermissions> op = new List<ObjectPermissions>();
        op.add(new ObjectPermissions(ParentId=ps.Id,
                                     SobjectType='Account',
                                     PermissionsRead=true,
                                     PermissionsEdit=true,
                                     PermissionsViewAllRecords=true));          

        insert op;
        return ps;
    }

}