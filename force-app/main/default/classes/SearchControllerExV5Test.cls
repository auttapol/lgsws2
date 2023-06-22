@isTest
global  class SearchControllerExV5Test {
    // This method will Run First
    static{
        // Initial Data Custom config
       TestUtils.createIdType();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();
        TestUtils.createDisqualifiedReason();
        TestUtils.createDateOfBirth();
        TestUtils.CreateProceBookAccess();
    }  
    
     public static RecordType CommercialLeadRecordType {get{
        if(CommercialLeadRecordType ==null){
           CommercialLeadRecordType = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Commercial Lead' 
                                 AND sObjectType='Lead' LIMIT 1];
        }
        return CommercialLeadRecordType;
    }set;}

    
    
    static testmethod void SearchbyID(){
        // Initial Data
        Search__c acc = new Search__c();  
        PageReference searchPage = Page.SearchProspectExV5;
        Test.setCurrentPage(searchPage);
         Account acct =  TestUtils.createAccounts(1,'SearchbyID','Individual', false).get(0);
        
        acct.ID_Type_PE__c ='Alien ID';
        acct.ID_Number_PE__c ='1510100100181965';
        insert acct;
        
        
        Lead leadRec = new Lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'Alien ID';
        leadRec.ID_Number__c = '1510100100181965';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Individual';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.Status = 'Open';
        leadRec.RecordTypeId = CommercialLeadRecordType.id;
        leadRec.Interest_result__c = 'Yes';
         insert leadRec;
        
        
        Id [] fixedSearchResults= new Id[2];
       fixedSearchResults[0] = acct.id;
       fixedSearchResults[1] = leadRec.id;
       Test.setFixedSearchResults(fixedSearchResults);

        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        SearchControllerExV5 searchEx = new SearchControllerExV5(sc);   
        // Search Individual By ID
        searchEx.hdCusType ='Individual';
        searchEx.hdIdType = 'info';
        searchEx.account.ID_Type__c ='Alien ID';
        searchEx.account.ID_Number_Temp__c ='1510100100181965'; 
        
        Test.startTest();            
        searchEx.search();
        searchEx.next();
        searchEx.viewOwner();
        searchEx.viewProspect(); 
        searchEx.viewLead();
        searchEx.resetNextButton();
        searchEx.nextbutton();
        integer currentPage = searchEx.currentPage;
        integer maxSize =searchEx.maxSize;
        boolean hasNext =searchEx.hasNext;
        boolean hasPrevious =searchEx.hasPrevious;
        integer pageNumber =searchEx.pageNumber;
        searchEx.first();
        searchEx.last();
        searchEx.next();
        searchEx.previous();
        
        integer leadcurrentPage = searchEx.LeadcurrentPage;
        integer leadmaxSize =searchEx.LeadmaxSize;
        boolean leadhasNext =searchEx.LeadhasNext;
        boolean leadhasPrevious =searchEx.LeadhasPrevious;
        integer leadpageNumber =searchEx.LeadpageNumber;
        searchEx.Leadfirst();
        searchEx.Leadlast();
        searchEx.Leadnext();
        searchEx.Leadprevious();
       
        Test.stopTest();  
        
        
        
        
    }
    
    
    static testmethod void SearchbyName(){
        // Initial Data
        Search__c acc = new Search__c();  
        PageReference searchPage = Page.SearchProspectExV5;
        Test.setCurrentPage(searchPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        SearchControllerExV5 searchEx = new SearchControllerExV5(sc);   
        
        Account acct =  TestUtils.createAccounts(1,'webserviceTESTACCOUNT','Individual', false).get(0);
        acct.First_Name_PE__c ='Tinnakrit';
        acct.Customer_Name_PE_Eng__c = 'Tinnakrit';
        acct.Last_name_PE__c  ='Kidmai'; 
        acct.ID_Type_PE__c = 'Passport ID';
        acct.ID_Number_PE__c = '13255555';
        insert acct;
        
        
         Lead leadRec = new Lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'Tinnakrit Kidmai';
        leadRec.Customer_NAME_EN__c = 'tinnakrit';
        leadRec.ID_Type__c = 'Passport ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Individual';
        leadRec.FirstName =  'Tinnakrit';
        leadRec.LastName = 'Kidmai';
        
        
         insert leadRec;
        
        
        Id [] fixedSearchResults= new Id[2];
       fixedSearchResults[0] = acct.id;
       fixedSearchResults[1] = leadRec.id;
       Test.setFixedSearchResults(fixedSearchResults);
        
        
        // Search Individual By Full Name
        searchEx.hdCusType ='Individual';
        searchEx.hdIdType = 'info';
        searchEx.account.First_Name__c ='Tin';         
        searchEx.search();
        searchEx.account.First_Name__c ='Tinnakrit';
        searchEx.account.Last_Name__c ='Kidmai';           
        searchEx.search();  
        
        
        
        
    }
    
    static testmethod void SearchbyPhone(){
        // Initial Data
        Search__c acc = new Search__c();  
        
        Account acct =  TestUtils.createAccounts(1,'SearchbyID','Individual', false).get(0);
        
        acct.ID_Type_PE__c ='Alien ID';
        acct.ID_Number_PE__c ='1510100100181965';
        acct.Phone = '053532198';
        acct.Mobile_Number_PE__c = '053532198';
        insert acct;
        
        
        Lead leadRec = new Lead();
        leadRec.Phone = '053532198';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'Alien ID';
        leadRec.ID_Number__c = '1510100100181965';
        leadRec.Office_No__c = '053532198';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Individual';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.Status = 'Open';
        leadRec.RecordTypeId = CommercialLeadRecordType.id;
        leadRec.Interest_result__c = 'Yes';
         insert leadRec;
        
        
        Id [] fixedSearchResults= new Id[2];
       fixedSearchResults[0] = acct.id;
       fixedSearchResults[1] = leadRec.id;
       Test.setFixedSearchResults(fixedSearchResults);

        
        
        PageReference searchPage = Page.SearchProspectExV5;
        Test.setCurrentPage(searchPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        SearchControllerExV5 searchEx = new SearchControllerExV5(sc);   
        // Search Individual By Phone
        searchEx.hdCusType ='Individual';
        searchEx.hdIdType = 'info';
        searchEx.account.Office_Number_Temp__c ='053532198';
        searchEx.account.Mobile_Number_Temp__c ='053532198'; 

        
        Test.startTest();            
        searchEx.search();    
        Test.stopTest();  
        
        
        
        
    }
    
    
    static testmethod void SearchbyCUSTID(){
        // Initial Data
        Search__c acc = new Search__c();  
        PageReference searchPage = Page.SearchProspectExV5;
        Test.setCurrentPage(searchPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        SearchControllerExV5 searchEx = new SearchControllerExV5(sc);   
        // Search Individual By Cust ID
        searchEx.hdCusType ='Individual';
        searchEx.hdIdType = 'info';
        searchEx.account.TMB_Customer_ID_Temp__c ='053532198';

        
        Test.startTest();            
        searchEx.search();    
        Test.stopTest();  
    }
    
    
    static testmethod void InvalidPrerequisite(){
        // Initial Data
        Search__c acc = new Search__c(); 
        PageReference searchPage = Page.SearchProspectExV5;
        Test.setCurrentPage(searchPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        SearchControllerExV5 searchEx = new SearchControllerExV5(sc);   
        // Search 
        searchEx.search();  
        searchEx.hdCusType = 'Individual';
        searchEx.search(); 
    }
    
    static testmethod void InvalidCitizen(){
        // Initial Data
        Search__c acc = new Search__c();         
        PageReference searchPage = Page.SearchProspectExV5;
        Test.setCurrentPage(searchPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        SearchControllerExV5 searchEx = new SearchControllerExV5(sc);   
        // Search 
        Test.startTest();
        searchEx.hdCusType = 'Individual';
        searchEx.hdIdType = 'Citizen ID';
        searchEx.search();  
        searchEx.hdIdType = 'Alien ID';
        searchEx.hdCheckBoxMode = 'info';
        searchEx.search();
        searchEx.hdCheckBoxMode = 'cust';
        searchEx.search(); 
        searchEx.hdIdType = 'Citizen ID';
        searchEx.account.ID_Number_Temp__c ='151515151';
        searchEx.isIDValid = false;
        searchEx.search(); 
        searchEx.hdCheckBoxMode = 'info';
        searchEx.hdIdType = null;
        searchEx.search();
        Test.stopTest();
    }
 
     static testmethod void SearchDuplicated(){
        // Initial Data
        Search__c acc = new Search__c();  
        Account acct = TestUtils.createAccounts(1, 'CitizenID', 'Individual', false).get(0);
         acct.ID_Type_PE__c ='Citizen ID'; 
         acct.ID_Number_PE__c ='1510100181965'; 
         acct.Customer_Type__c = 'Individual';
         insert acct;
         
        Id [] fixedSearchResults = new Id[]{acct.Id};
        Test.setFixedSearchResults(fixedSearchResults);

        PageReference searchPage = Page.SearchProspectExV5;
        Test.setCurrentPage(searchPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        SearchControllerExV5 searchEx = new SearchControllerExV5(sc);   
        // Search Individual By ID
        searchEx.hdCusType ='Individual';
        searchEx.hdIdType = 'Citizen ID';
        searchEx.account.ID_Number_Temp__c ='1510100181965'; 
                    
        searchEx.search();  
        acct.OwnerId = Userinfo.getUserId();
         update acct;
         searchEx.search();
        
        
        
    }
    

}