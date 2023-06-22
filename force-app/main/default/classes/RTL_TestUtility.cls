@isTest
public class RTL_TestUtility {
    public static final Id RTL_BRANCH_SALES_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Retail Channel Sales' LIMIT 1].Id;   
    public static final String SUCCESS_CODE = '0000';
    public static final String QUERY_EXCEPTION_CODE = '1001';
    public static final String CALLOUT_EXCEPTION_CODE = '1002';
    public static final String FOUND_DUP_ALLOW_CREATE = '1010';
    public static final String FOUND_DUP_NOT_ALLOW_CREATE = '1011';
    public static final String WEBSERVICE_ERROR_CODE = '1003';
    public static final String DML_EXCEPTION_CODE = '1000';
    public static String CRON_EXP = '0 0 0 15 3 ? 2025';//dummy cron expression, midnight of March 15
    public static Datetime threemonthsolder = Datetime.now().addDays(-200); //set a date 3 months early
    public static Id acctRT = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
    public static RecordType retailTaskRecordType = [select Id from RecordType where developername='RTL_Retail_Task' and SobjectType = 'Task' and IsActive = true limit 1];
    public static List<RTL_Channel_Referral__c> channelReferralList {
        get
        {
            if(channelReferralList == null){
                channelReferralList = new List<RTL_Channel_Referral__c>();
            }
            return channelReferralList;
        }set;
    }
    
    public static List<RTL_Interested_products_c__c> interestedProductList {
        get
        {
            if(interestedProductList == null){
                interestedProductList = new List<RTL_Interested_products_c__c>();
            }
            return interestedProductList;
        }set;
        
    }
    
    public static final Id SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    public static RecordType masterRt {
        get{
            if( masterRt == null )
            {
                masterRt = [SELECT id FROM recordType WHERE DeveloperName = 'Master_Campaign' ];
            }
            return masterRt;
        }
        set;
    }

    public static void createOpportunityRecordMap(){
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
    
    public static void createRetailMasterProducts(Boolean doInsert){
        //List of retail master product records to be inserted 
        List<RTL_product_master__c> retailMasterProductsToInsert = new List<RTL_product_master__c>();
                                                                                  
        retailMasterProductsToInsert.add(new RTL_product_master__c ( 
                Active__c = TRUE,
                Name = 'Deposit Product',
                Product_Code__c = '0001',
                Product_Group__c = 'Deposit',
                Product_Sub_group__c = 'Deposit TestSubgroup'));
        
        retailMasterProductsToInsert.add(new RTL_product_master__c ( 
                Active__c = TRUE,
                Name = 'Credit Card Product',
                Product_Code__c = '0002',
                Product_Group__c = 'Credit Card',
                Product_Sub_group__c = 'Credit Card TestSubgroup'));
        
        retailMasterProductsToInsert.add(new RTL_product_master__c ( 
                Active__c = TRUE,
                Name = 'Bancassuarnce Product',
                Product_Code__c = '0003',
                Product_Group__c = 'Bancassuarnce',
                Product_Sub_group__c = 'Bancassuarnce  TestSubgroup'));
        
        retailMasterProductsToInsert.add(new RTL_product_master__c ( 
                Active__c = TRUE,
                Name = 'Investment Product',
                Product_Code__c = '0004',
                Product_Group__c = 'Investment',
                Product_Sub_group__c = 'Investment TestSubgroup'));
        
        retailMasterProductsToInsert.add(new RTL_product_master__c ( 
                Active__c = TRUE,
                Name = 'Loans Product',
                Product_Code__c = '0005',
                Product_Group__c = 'Loans',
                Product_Sub_group__c = 'Loans TestSubgroup'));
        
        retailMasterProductsToInsert.add(new RTL_product_master__c ( 
                Active__c = TRUE,
                Product_Code__c = '0006',
                Product_Group__c = 'Retentions',
                Product_Sub_group__c = 'Retentions TestSubgroup'));
        
        retailMasterProductsToInsert.add(new RTL_product_master__c ( 
                Active__c = TRUE,
                Name = 'Others Product',
                Product_Code__c = '0007',
                Product_Group__c = 'Others',
                Product_Sub_group__c = 'Others TestSubgroup'));
        
        if(doInsert){
            insert retailMasterProductsToInsert;
        }
        System.debug('::::: insert retailMasterProductsTest is : ' + retailMasterProductsToInsert.size() +' row :::::');
    }
    
    public static List<RTL_Interested_products_c__c> createInterestedProducts(List<Lead> leads, Boolean doInsert){
        //List of interested product records to be inserted after associating with the lead
        List<RTL_Interested_products_c__c> interestedProductsToInsert = new List<RTL_Interested_products_c__c>();

        //select deposit product as master always
        RTL_product_master__c masterProduct = [Select Id, Product_Code__c, Product_Group__c, Product_Sub_group__c
                         from RTL_product_master__c 
                         where Product_Code__c = : '0001' and Active__c = : true limit 1];
        //select credit card as non primary ne always
        RTL_product_master__c masterNoPrimaryProduct = [Select Id, Product_Code__c, Product_Group__c, Product_Sub_group__c
                         from RTL_product_master__c 
                         where Product_Code__c = : '0002' and Active__c = : true limit 1];                              
         
        for (Lead lead:leads){
            //Create New PRIMARY interested product record and then associate with the Lead
            
            interestedProductsToInsert.add(new RTL_Interested_products_c__c ( 
                Branch_Code__c  = '0001',
                Co_borrower_1__c = 'Test Co Borrower1',
                Co_borrower_2__c = 'Test Co Borrower2',
                Collateral_Type__c = 'Test Collateral Type',
                Debt__c = '5000.23',
                Income_SE__c = '3000.23',
                Income_SL__c ='3000.23',
                Is_Primary__c = TRUE,
                Lead__c = lead.Id,
                Loan_Amount__c = '3000.23',
                product_group__c = masterProduct.Product_Group__c,
                Product_Name__c = masterProduct.Id,
                Product_Sub_Group__c = masterProduct.Product_Sub_group__c ));
            
            //Create New NON-PRIMARY interested product record and then associate with the Lead
            interestedProductsToInsert.add(new RTL_Interested_products_c__c ( 
                Branch_Code__c  = '0002',
                Co_borrower_1__c = 'Test Co Borrower1',
                Co_borrower_2__c = 'Test Co Borrower2',
                Collateral_Type__c = 'Test Collateral Type',
                Debt__c = '5000.23',
                Income_SE__c = '3000.23',
                Income_SL__c = '3000.23',
                Is_Primary__c = FALSE,
                Lead__c = lead.Id,
                Loan_Amount__c = '3000.23',
                product_group__c = masterNoPrimaryProduct.Product_Group__c,
                Product_Name__c = masterNoPrimaryProduct.Id,
                Product_Sub_Group__c = masterNoPrimaryProduct.Product_Sub_group__c ));
                            
        }
        interestedProductList = interestedProductsToInsert;
        
        if(doInsert){
            insert interestedProductList;
        }
        System.debug('::::: insert interestedProductsTest is : ' + interestedProductList.size() +' row :::::');
        return interestedProductList;
    }
    
    public static void createChannelReferralToInsert(List<Opportunity> opportunities, User user, Boolean doInsert){
        //List of channel records to be inserted
        List<RTL_Channel_Referral__c> channelReferralsToInsert = new List<RTL_Channel_Referral__c>();
                                                                                  
        for (Opportunity oppt:opportunities){
        //Create New Channel Referral record and then associate with the opportunity
            channelReferralsToInsert.add(new RTL_Channel_Referral__c ( RTL_Branch_Code__c = user.RTL_Branch_Code__c,
                RTL_Opportunity__c = oppt.Id,
                RTL_Start_Date__c =DateTime.now(),
                RTL_Owner__c = user.Id,
                Name = user.RTL_Channel__c));
        }
        channelReferralList = channelReferralsToInsert;
        
        if(doInsert){
            insert channelReferralsToInsert;
        }
        System.debug('::::: insert channelreferralTest is : ' + channelReferralList.size() +' row :::::');
        //return channelReferralsToInsert;
    }
    
    /* This test data is used for lead queue auto assignment */
    public static Map<String, Group> createLeadQueues(Boolean doInsert) {
        //Keep the list of the existing lead queues
        Map<String, Group> queueMap = new Map<String, Group>();
        for(Group queue : [Select Id, Name, DeveloperName from Group where Type = 'Queue'])
            queueMap.put(queue.DeveloperName, queue);
                    
        /* Create two lead queues with name RTLQ_001 & RTLQ_Outbound */
        List<Group> leadQueues = new List<Group>();
        Group queue = new Group(Name='RTLQ_001', DeveloperName='RTLQ_001', Type='Queue');
        if (queueMap.get(queue.DeveloperName) == null) leadQueues.add(queue);
        queue = new Group(Name='RTLQ_Outbound', DeveloperName='RTLQ_Outbound', Type='Queue');
        if (queueMap.get(queue.DeveloperName) == null) leadQueues.add(queue);
        insert leadQueues;

        List<QueuesObject> leadQOs = new List<QueuesObject>();
        QueuesObject qso = null;
        for (Group q: leadQueues) {
            qso = new QueueSObject(QueueID = q.id, SobjectType = 'Lead');
            leadQOs.add(qso);
            queueMap.put(q.DeveloperName, q);
        }
        if(doInsert) insert leadQOs;
        return queueMap;
    }
    
    /* This test data is used for lead queue lookup for branch code from branch_zone */
    public static List<Branch_and_Zone__c> createBranchZone(Integer size, Boolean doInsert) {
        List<Branch_and_Zone__c> branchList = new List<Branch_and_Zone__c>();
        
        /* Create branch zone mapping branch name and branch code */
        for (Integer i=0; i<size; i++) {
            branchList.add(new Branch_and_Zone__c(Name='RTLQ_00'+(i+1)+' (00'+(i+1)+')', Branch_Name__c='RTLQ_00'+(i+1), Branch_Code__c='00'+(i+1),isActive__c = true));
        }
        if(doInsert) insert branchList;
        return branchList;
    }   
    
    /* This test data is used for lead interested product */
    public static List<RTL_product_master__c> createRetailProducts(Boolean doInsert) {
        List<RTL_product_master__c> productList = new List<RTL_product_master__c>();
        
        RTL_product_master__c product = new RTL_product_master__c(Name='So Fast Test', Product_Group__c='Credit Card', Product_Sub_group__c='Credit Card',Active__c=true);
        productList.add(product);
        product = new RTL_product_master__c(Name='So Smart Test', Product_Group__c='Credit Card', Product_Sub_group__c='Credit Card',Active__c=true);
        productList.add(product);
        product = new RTL_product_master__c(Name='Home Loan Test', Product_Group__c='Lending', Product_Sub_group__c='Secured Lending',Active__c=true);
        productList.add(product);
        if (doInsert)   insert productList;
        return productList;
    }
        
    /* This test data is used for web-to-lead assignment criterias */
    public static void createLeadAssignCriterias(Boolean doInsert) {
        List<RTL_Assignment_Criterias__c> criteriaList = new List<RTL_Assignment_Criterias__c>();
        List<RTL_product_master__c> productList = createRetailProducts(true);
        RTL_Assignment_Criterias__c assignCriteria = null;
        for (RTL_product_master__c product: productList) {
            if(product.Name == 'So Fast Test') {
                assignCriteria = new RTL_Assignment_Criterias__c(Product_Name__c=product.Id, Destination_BKK__c='Outbound', Destination_UPC__c='Branch');
            } else if (product.Name == 'So Smart Test') {
                assignCriteria = new RTL_Assignment_Criterias__c(Product_Name__c=product.Id, Destination_BKK__c='Branch', Destination_UPC__c='Branch');
            } else if (product.Name == 'Home Loan Test') {
                assignCriteria = new RTL_Assignment_Criterias__c(Product_Name__c=product.Id, Destination_BKK__c='Outbound', Destination_UPC__c='Outbound');
            }
            criteriaList.add(assignCriteria);
        }
        if (doInsert) insert criteriaList;
    }    
    
    public static User createRetailTestUser(Boolean doInsert) {
        User retailUser = new User(FirstName='retail', LastName='test user',
                                UserName='rtl_testuser@tmb.com',
                                Email='rtl_testuser@tmbbank.com', Alias='RTLUser',
                                LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                ProfileId = RTL_BRANCH_SALES_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                RTL_Branch_Code__c='001', Region_Code__c = '002', Zone_Code__c = '003',
                                Employee_ID__c='RTL01', RTL_Branch__c='RTLQ_001 (001)');

        
        if(doInsert) insert retailUser;
        return retailUser;
    }
    
    public static User createRetailTestUserWithBranch(Boolean doInsert) {
        User retailUser = new User(FirstName='retail', LastName='test user2', 
                                UserName='rtl_testuser2@tmb.com',
                                Email='rtl_testuser2@tmbbank.com', Alias='RTLUser2',
                                LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                ProfileId = RTL_BRANCH_SALES_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                RTL_Branch_Code__c='002',title='Branch Manager',
                                Employee_ID__c='RTL02', RTL_Branch__c='RTLQ_002 (002)');

        
        if(doInsert) insert retailUser;
        return retailUser;
    }       
    
    public static User createRetailTestUserWithoutBranch(Boolean doInsert) {
        User retailUser = new User(FirstName='retail', LastName='test user3', 
                                UserName='rtl_testuser3@tmb.com',
                                Email='rtl_testuser3@tmbbank.com', Alias='RTLUser3',
                                LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                ProfileId = RTL_BRANCH_SALES_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                Employee_ID__c='RTL03');

        
        if(doInsert) insert retailUser;
        return retailUser;
    }       
    
    public static List<User> createRetailTestUserOppt(Boolean doInsert) {
        List<User> users = new List<User>();
        User retailUser1 = new User(Alias = 'RTL1', Email='standarduser-ii@tmbbank.com', 
                          EmailEncodingKey='UTF-8', LastName='rtl1', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = RTL_BRANCH_SALES_PROFILE_ID,Employee_ID__c='RTL04',
                          Zone_Code__c='HHHH',Segment__c='SS',Zone__c = 'TEST',
                          TimeZoneSidKey='America/Los_Angeles', UserName='rtl1@testorg.com',
                          RTL_Channel__c ='Outbound');
        users.add(retailUser1);
        User retailUser2 = new User(Alias = 'RTL2', Email='standarduser-ii2@tmbbank.com', 
                           EmailEncodingKey='UTF-8', LastName='rtl2', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = RTL_BRANCH_SALES_PROFILE_ID,Employee_ID__c='RTL05',
                           Zone_Code__c='HHHH',Segment__c='SS',Zone__c = 'TEST',
                           TimeZoneSidKey='America/Los_Angeles', UserName='rtl2@testorg.com.sit',
                           RTL_Channel__c ='Outbound'); 
        users.add(retailUser2);
        User retailUser3 = new User(Alias = 'RTL3', Email='standarduser-ii2@tmbbank.com', 
                           EmailEncodingKey='UTF-8', LastName='rtl2', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = RTL_BRANCH_SALES_PROFILE_ID,Employee_ID__c='RTL06',
                           Zone_Code__c='HHHH',Segment__c='SS',Zone__c = 'TEST',
                           TimeZoneSidKey='America/Los_Angeles', UserName='rtl3@testorg.com.sit',
                           RTL_Branch_Code__c ='0001', RTL_Channel__c ='Branch'); 
        users.add(retailUser3);         
        
        if(doInsert) insert users;
        return users;
    }    
    
    public static void createLeadTaskAndEvent(List<Lead> leads, Boolean doInsert) {
        List<Task> taskList = new List<Task>();
        List<Event> eventList = new List<Event>();
        
        for (Lead lead:leads){
            taskList.add(new Task(Subject = 'test lead task', WhoID = lead.Id));
            eventList.add(new Event(Subject = 'test lead event', WhoID = lead.Id, DurationInMinutes=6000, ActivityDateTime=datetime.newInstance(2017, 05,05))); 
        }
            
        if(doInsert) {
            insert taskList;
            //insert eventList;
        }
    }    
    
    public static void enableWebToLeadAutoAssign(Boolean doInsert) {
        RTL_Lead_Assignment__c leadAssign = new RTL_Lead_Assignment__c();
        leadAssign.Name = 'Auto Assign';
        leadAssign.Enable__c = true;
        
        if(doInsert) insert leadAssign;
    }     
    
     public static void disableWebToLeadAutoAssign(Boolean doInsert) {
        RTL_Lead_Assignment__c leadAssign = new RTL_Lead_Assignment__c();
        leadAssign.Name = 'Auto Assign';
        leadAssign.Enable__c = false;
        
        if(doInsert) insert leadAssign;
    }     
    
    public static void setOpptRecordTypeMapping(Boolean doInsert) {
        Opportunity_Recordtype_Mapping__c opptMapping = new Opportunity_Recordtype_Mapping__c();
        opptMapping.Name = 'RetailCardandRDCStage';
        opptMapping.Product_Group__c = 'Deposit';
        opptMapping.Record_Type__c = 'Retail Deposit';
        opptMapping.Stage__c = 'Prospect (Deposit)';
    }
    
    public static List<Account> createAccounts(Integer size , Boolean doInsert)
    {
        List<Account> accountsToCreate = new List<Account>();
        RecordType recordType = [select Id from RecordType where developername='Retail_Prospect' and SobjectType = 'Account' and IsActive = true limit 1];
        for(Integer i =1 ; i<=size ;i++)
        {   
            Account acct = new Account(); 
            acct.Name = 'Test RTL Account '+i;
            acct.First_Name_PE__c = 'Test';
            acct.Last_name_PE__c = 'RTL Account '+i;
            acct.Phone ='1111111111';
            acct.Mobile_Number_PE__c  = '1111111111';
            acct.ID_Type_PE__c = 'Passport ID';
            acct.ID_Number_PE__c = '11111' + i;
            acct.RTL_NID__c = '1111' + i;
            acct.RecordType = recordType;
            acct.TMB_Customer_ID_PE__c  =  '001p000000CKy8AAD' + i;
            acct.RTL_RM_Name__c = 'RTL02';
            acct.RecordTypeId = acctRT;
            //acct.TMB_Customer_ID_PE__c = '000000000000000000000'+i;
            
            accountsToCreate.add(acct);    
        }
        
        if(doInsert){
                insert accountsToCreate;
        }
        
        return accountsToCreate;
    }    
    
    public static Lead createLeadWithDupID(Boolean doInsert)
    {
        Lead lead = new Lead();
        RecordType recordType = [select Id from RecordType where developername='Retail_Banking' and IsActive = true limit 1];       
        lead.Title = 'TH';
        lead.Company = 'X';
        lead.FirstName = 'Test';
        lead.LastName = 'TestDupLead';
        lead.Email = 'testduplead@salesforce.com';
        lead.RTL_Mobile_Number__c = '1111111111';
        lead.RTL_Phone_Number__c = '222222222';
        lead.RTL_Office_Number__c = '333333333';
        lead.Status = 'New';
        lead.Street = 'aaa';
        lead.City = 'bbb';
        lead.State = 'CC';
        lead.PostalCode = '1111111';
        lead.Country = 'DD';
        lead.RecordType = recordType;
        lead.RTL_ID_Type__c = 'Passport ID';
        lead.RTL_Citizen_Id__c = '111111';
        
        if(doInsert){
            insert lead;
        }
        return lead;
    } 
    
    public static List<Lead> createLeads(Integer size , Boolean doInsert)
    {
        List<Lead> leads = new List<Lead>();
        Lead lead = null;
        RecordType recordType = [select Id from RecordType where developername='Retail_Banking' and IsActive = true limit 1];
        for(Integer i=0 ; i<size ;i++) {        
            lead = new Lead();
            lead.Title = 'TH';
            lead.Company = 'X';
            lead.FirstName = 'Test'+i;
            lead.LastName = 'TestLead';
            lead.Email = 'test'+i+'@salesforce.com';
            lead.RTL_Mobile_Number__c = '1111111111';
            lead.RTL_Phone_Number__c = '222222222';
            lead.RTL_Office_Number__c = '333333333';
            lead.Status = 'New';
            lead.Street = 'aaa';
            lead.City = 'bbb';
            lead.State = 'CC';
            lead.PostalCode = '1111111';
            lead.Country = 'DD';
            lead.RecordTypeId = recordType.id;
            lead.RTL_ID_Type__c = 'Passport ID';
            lead.RTL_Citizen_Id__c = 'aaaaaa';
            lead.RTL_Web_Unique_ID_c__c = 'Test'+i;
            leads.add(lead);
        }
        
        if(doInsert){
            insert leads;
        }
        return leads;
    }
    
    /* This test data is used for positive test of web-to-lead FR-003 and FR-011 */
    public static void createPositiveWebToLead()
    {
        List<Lead> webToLeads = new List<Lead>();
        RecordType recordType = [select Id from RecordType where developername='Retail_Banking' and IsActive = true limit 1];   
        /* 1st web-to-lead is within region BKK, single product 'So Fast Test'
        * expected result is: 
        * 1. lead is created
        * 2. auto assign lead queue to Outbound queue RTLQ_Outbound (FR-011)
        * 3. interested product is added as primary (FR-003)
        */
        Lead lead = new Lead();
        lead.Company = 'X';
        lead.RTL_TMB_Campaign_Source__c = 'Web';
        lead.FirstName = 'Test1';
        lead.LastName = 'WebToLead';
        lead.Email = 'test1@salesforce.com';
        lead.City = 'Bangkok';
        lead.RTL_Branch_Name__c = '002';
        lead.RTL_Product_Name__c = 'So Fast Test';
        lead.Status = 'New';
        lead.RTL_ID_Type__c = 'Passport ID';
        lead.RTL_Citizen_Id__c = '11111';
        lead.RTL_Address_Line1__c = 'address1';     
        lead.RTL_Address_Line4__c = 'address4'; 
        lead.RecordType = recordType;
        webToLeads.add(lead);
        /* 2nd web-to-lead is outside region BKK, single product 'So Fast Test'
        * expected result is: 
        * 1. lead is created        
        * 2. auto assign lead queue to Branch queue same as branch name: RTLQ_001 (FR-011)
        * 3. interested product is added as primary (FR-003)
        */
        lead = new Lead(); 
        lead.Company = 'X';
        lead.RTL_TMB_Campaign_Source__c = 'Web';
        lead.FirstName = 'Test2';
        lead.LastName = 'WebToLead';
        lead.Email = 'test2@salesforce.com';
        lead.City = 'PhuketIsland';
        lead.RTL_Branch_Name__c = '002';
        lead.RTL_Product_Name__c = 'So Fast Test';
        lead.Status = 'New';
        lead.RTL_ID_Type__c = 'Passport ID';
        lead.RTL_Citizen_Id__c = '22222';   
        lead.RTL_Address_Line1__c = 'address1';     
        lead.RTL_Address_Line4__c = 'address4'; 
        lead.RecordType = recordType;       
        webToLeads.add(lead);
        /* 3rd web-to-lead is within region BKK, multiple products 'So Fast Test;So Smart Test'
        * expected result is: 
        * 1. lead is created        
        * 2. for multiple products, auto assign lead queue to Branch queue, e.g. RTLQ_001 (FR-011)
        * 3. two interested products are added, set 'So Fast Test' as primary (FR-003)
        */
        lead = new Lead(); 
        lead.Company = 'X';
        lead.RTL_TMB_Campaign_Source__c = 'Web';
        lead.FirstName = 'Test3';
        lead.LastName = 'WebToLead';
        lead.Email = 'test3@salesforce.com';
        lead.City = 'Bangkok';
        lead.RTL_Multiple_Interested_Product_s__c = true;
        lead.RTL_Branch_Name__c = '002';
        lead.RTL_Product_Name__c = 'So Fast Test;So Smart Test';
        lead.Status = 'New';    
        lead.RTL_ID_Type__c = 'Passport ID';
        lead.RTL_Citizen_Id__c = '33333';   
        lead.RTL_Address_Line1__c = 'address1';     
        lead.RTL_Address_Line4__c = 'address4';     
        lead.RecordType = recordType;
        webToLeads.add(lead);
        /* 4th web-to-lead is outside region BKK, single product 'Home Loan Test'
        * expected result is: 
        * 1. lead is created
        * 2. auto assign lead queue to Outbound queue RTLQ_Outbound (FR-011)
        * 3. interested product is added as primary (FR-003)
        */
        lead = new Lead();
        lead.Company = 'X';
        lead.RTL_TMB_Campaign_Source__c = 'Web';
        lead.FirstName = 'Test4';
        lead.LastName = 'WebToLead';
        lead.Email = 'test4@salesforce.com';
        lead.City = 'PhuketIsland';
        lead.RTL_Branch_Name__c = '002';
        lead.RTL_Product_Name__c = 'Home Loan Test';
        lead.Status = 'New';
        lead.RTL_ID_Type__c = 'Passport ID';
        lead.RTL_Citizen_Id__c = '44444';   
        lead.RTL_Address_Line1__c = 'address1';     
        lead.RTL_Address_Line4__c = 'address4'; 
        lead.RecordType = recordType;
        webToLeads.add(lead);       
        insert webToLeads;  
    }
    
    /* This test data is used for negative test of web-to-lead FR-003 and FR-011 */
    public static void createNegativeWebToLead()
    {
        List<Lead> webToLeads = new List<Lead>();
        RecordType recordType = [select Id from RecordType where developername='Retail_Banking' and IsActive = true limit 1];
        /* 1st web-to-lead is within region BKK, single product 'Bad Product'
        * expected result is: 
        * 1. lead is created
        * 2. lead queue is not assigned, Lead Owner is running user (FR-011)
        * 3. interested product is not added (FR-003)
        * 4. lead description is added with some explanation contains 'Bad Product'
        */
        Lead lead = new Lead(); 
        lead.Company = 'X';
        lead.RTL_TMB_Campaign_Source__c = 'Web';
        lead.FirstName = 'Test1';
        lead.LastName = 'NegativeWebToLead';
        lead.Email = 'negtest1@salesforce.com';
        lead.City = 'Bangkok';
        lead.RTL_Branch_Name__c = '001';
        lead.RTL_Product_Name__c = 'Bad Product';
        lead.RTL_Description__c = 'Bad Product';
        lead.Status = 'New';    
        lead.RTL_ID_Type__c = 'Passport ID';
        lead.RTL_Citizen_Id__c = '55555';
        lead.RTL_Address_Line1__c = 'address1';     
        lead.RTL_Address_Line4__c = 'address4';         
        lead.RecordType = recordType;       
        webToLeads.add(lead);
        /* 2nd web-to-lead is within region BKK, multiple products 'So Fast Test;Bad Product'
        * expected result is: 
        * 1. lead is created
        * 2. for multiple products, auto assign lead queue to Branch queue, e.g. RTLQ_001 (FR-011)
        * 3. only one interested product 'So Fast Test' is added as primary (FR-003)
        * 4. lead description is added with some explanation contains 'Bad Product'
        */
        lead = new Lead(); 
        lead.Company = 'X';
        lead.RTL_TMB_Campaign_Source__c = 'Web';
        lead.FirstName = 'Test2';
        lead.LastName = 'NegativeWebToLead';
        lead.Email = 'negtest2@salesforce.com';
        lead.City = 'Bangkok';
        lead.RTL_Multiple_Interested_Product_s__c = true;
        lead.RTL_Branch_Name__c = '001';
        lead.RTL_Product_Name__c = 'So Fast Test;Bad Product';
        lead.RTL_Description__c = 'Bad Product';
        lead.Status = 'New';    
        lead.RTL_ID_Type__c = 'Passport ID';
        lead.RTL_Citizen_Id__c = '66666';   
        lead.RTL_Address_Line1__c = 'address1';     
        lead.RTL_Address_Line4__c = 'address4';     
        lead.RecordType = recordType;       
        webToLeads.add(lead);
        /* 3rd web-to-lead is within region BKK, multiple products 'Bad Product;So Fast Test'
        * expected result is: 
        * 1. lead is created
        * 2. for multiple products, auto assign lead queue to Branch queue, e.g. RTLQ_001 (FR-011)
        * 3. only one interested product 'So Fast Test' is added as primary (FR-003)
        * 4. lead description is added with some explanation contains 'Bad Product'
        */
        lead = new Lead(); 
        lead.Company = 'X';
        lead.RTL_TMB_Campaign_Source__c = 'Web';
        lead.FirstName = 'Test3';
        lead.LastName = 'NegativeWebToLead';
        lead.Email = 'negtest3@salesforce.com';
        lead.City = 'Bangkok';
        lead.RTL_Multiple_Interested_Product_s__c = true;
        lead.RTL_Branch_Name__c = '001';
        lead.RTL_Product_Name__c = 'Bad Product;So Fast Test';
        lead.RTL_Description__c = 'Bad Product';
        lead.Status = 'New';
        lead.RTL_ID_Type__c = 'Passport ID';
        lead.RTL_Citizen_Id__c = '77777';   
        lead.RTL_Address_Line1__c = 'address1'; 
        lead.RTL_Address_Line4__c = 'address4';             
        lead.RecordType = recordType;   
        webToLeads.add(lead);
        /* 4th web-to-lead is within region BKK, multiple products 'Bad Product1;Bad Product2'
        * expected result is: 
        * 1. lead is created
        * 2. for multiple products, auto assign lead queue to Branch queue, e.g. RTLQ_001 (FR-011)
        * 3. no interested product is added (FR-003)
        * 4. lead description is added with some explanation contains 'Bad Productx'
        */
        lead = new Lead(); 
        lead.Company = 'X';
        lead.RTL_TMB_Campaign_Source__c = 'Web';
        lead.FirstName = 'Test4';
        lead.LastName = 'NegativeWebToLead';
        lead.Email = 'negtest4@salesforce.com';
        lead.City = 'Bangkok';
        lead.RTL_Multiple_Interested_Product_s__c = true;
        lead.RTL_Branch_Name__c = '001';
        lead.RTL_Product_Name__c = 'Bad Product1;Bad Product2';
        lead.RTL_Description__c = 'Bad Product2';
        lead.Status = 'New';    
        lead.RTL_ID_Type__c = 'Passport ID';
        lead.RTL_Citizen_Id__c = '88888';   
        lead.RTL_Address_Line1__c = 'address1';
        lead.RTL_Address_Line4__c = 'address4';         
        lead.RecordType = recordType;       
        webToLeads.add(lead);
        insert webToLeads;              
    }  
    
    public static List<Opportunity> createOpportunity(List<Account> listAcc, Boolean doInsert) {
        List<Opportunity> opptList = new List<Opportunity>();
        Opportunity o;
        RecordType recordType = [select Id from RecordType where developername='Retail_Deposit' and SobjectType = 'Opportunity' and IsActive = true limit 1];
        for( Integer i = 0 ; i < listAcc.size() ; i++ ){
            o = new Opportunity(Name='II-OPP-'+i,
                                StageName = 'Open',
                                CloseDate = Date.today(),
                                AccountId = listAcc.get(i).Id,
                                Probability = 10,
                                Amount = 0,
                                Description = 'desc'+i,
                                CA_Prep_Start_Date__c = Date.today(),
                                Approval_Process_Date__c = Date.today(),
                                Post_Approval_Date__c = Date.today(),
                                Complete_Date__c = Date.today(),
                                Trigger_flag__c = true,
                                RecordType=recordType
                               );
            opptList.add(o);
            
        }
        if(doInsert){
                insert opptList;
        }
        return opptList;
    }     
    
    public static List<Opportunity> createOpportunities(Account acct,Integer size, Boolean doInsert) {
        List<Opportunity> opptList = new List<Opportunity>();
        Opportunity o;
        RecordType recordType = [select Id from RecordType where developername='Retail_Deposit' and SobjectType = 'Opportunity' and IsActive = true limit 1];
        for( Integer i = 0 ; i < size ; i++ ){
            o = new Opportunity(Name='II-OPP-'+i,
                                StageName = 'Prospect',
                                CloseDate = Date.today(),
                                AccountId = acct.Id,
                                Probability = 10,
                                Amount = 0,
                                Description = 'desc'+i,
                                CA_Prep_Start_Date__c = Date.today(),
                                Approval_Process_Date__c = Date.today(),
                                Post_Approval_Date__c = Date.today(),
                                Complete_Date__c = Date.today(),
                                Trigger_flag__c = true,
                                RecordType=recordType
                               );
            opptList.add(o);
            
        }
        if(doInsert){
                insert opptList;
        }
        return opptList;
    }     
    
    public static List<RTL_NBO_History__c> createNBOHistoryAndProduct(Integer size, Id acctId, Boolean doInsert) {
    	List<RTL_NBO_History__c> nboHistoryList = new List<RTL_NBO_History__c>();
    	List<RTL_NBO_History_Product__c> nboHistoryProductList = new List<RTL_NBO_History_Product__c>();
    	RTL_NBO_History__c nboHistory = null;
    	RTL_NBO_History_Product__c nbohistoryproduct = null;
        for(Integer i = 0; i<size;i++){
	        nboHistory = new RTL_NBO_History__c();
			nboHistory.RTL_Campaign_Name__c = 'NBO test' + i;
			nboHistory.RTL_NBO_ID__c = '001p000000CKy8AAD' + i;
			nboHistory.RTL_NBO_Group__c = 'DEPOSIT';
			nboHistory.RTL_NBO_SubGroup__c = 'TRANSACTIONAL';
			nboHistory.RTL_Campaign_Code__c = '001p000000CKy8AAD' + i;
			//nboHistory.RTL_Campaign_Name__c = 'campaign' + i;
			nboHistory.RTL_Valid_From__c = Date.today();
			nboHistory.RTL_Valid_To__c = Date.today().addDays(30);
			nboHistory.RTL_Customer_Name__c = acctId;
			nboHistory.RTL_Smart_Info__c = 'http://nbo_smart_info';
			nboHistory.RTL_Channel__c = 'branch';
			nboHistory.RTL_Contact_Date__c = Date.today().addDays(10);
			nboHistory.RTL_NBO_Product_Latest_Modified_Date__c = DateTime.now();
			nboHistory.RTL_Product_Branch_Latest_Modified_Date__c = DateTime.now();
            nboHistoryList.add(nboHistory);
        }
        if(doInsert){
        	insert nboHistoryList;
        }
        nboHistoryList = [select RTL_NBO_ID__c from RTL_NBO_History__c where RTL_NBO_ID__c like '001p000000CKy8AAD%'];
        for(RTL_NBO_History__c nboHis: nboHistoryList){
            nbohistoryproduct = new RTL_NBO_History_Product__c();
			nbohistoryproduct.RTL_Related_NBO__c = nboHis.id;
			nbohistoryproduct.RTL_NBO_ID__c = nboHis.RTL_NBO_ID__c;
			nbohistoryproduct.RTL_Product_Group__c = 'test group1';
			nbohistoryproduct.RTL_NBO_Product_External_ID__c = nboHis.RTL_NBO_ID__c + '0';
			nboHistoryProductList.add(nbohistoryproduct);
        }
        if(doInsert){
			insert nboHistoryProductList;
        }        
        return nboHistoryList;
    }      
    
    public static List<Product2> createRetailProduct2(Integer size, Boolean doInsert) {
    	List<Product2> product2List = new List<Product2>();
    	Product2 productObj = null;
    	for (Integer i=0; i<size; i++) {
    		productObj = new Product2();
    		productObj.Name = 'product name ' + i;
    		productObj.RTL_PRODUCT_CODE__c = 'product code ' + i;
    		productObj.RTL_Asset_Class__c = 'asset class ' + i;
    		productObj.FUND_TYPE__c = 'fund type ' + i;
    		productObj.Family = 'family ' + i;
    		productObj.Sub_Family__c = 'sub family ' + i;
    		productObj.FLAG_RTL_Product__c = true;
    		productObj.SF_Product_Key__c = 'product code ' + i;
    		product2List.add(productObj);		
    	}    	
        if(doInsert){
			insert product2List;
        }        
        return product2List;   	
    }      
    
    public static Map<RTL_NBOService.NBOHistory, List<RTL_NBOService.NBOHistoryProduct>> createNBOMap(Id acctId) {
    	Map<RTL_NBOService.NBOHistory, List<RTL_NBOService.NBOHistoryProduct>> nboMapToReturn = new Map<RTL_NBOService.NBOHistory, List<RTL_NBOService.NBOHistoryProduct>>();
    	RTL_NBOService.NBOHistory nboHistory = null;
    	RTL_NBOService.NBOHistoryProduct nboHistoryProduct = null;
    	List<RTL_NBOService.NBOHistoryProduct> nboHistoryProductList = null;
        for(Integer i = 0; i<3;i++){
	        nboHistory = new RTL_NBOService.NBOHistory();
			nboHistory.RTL_Campaign_Name = 'NBO test' + i;
			if (i == 7) nboHistory.RTL_NBO_ID = '001p000000CKy8AAD0';//simulate existing NBO History
			else nboHistory.RTL_NBO_ID = '001p000000CKyAAD7' + i;
			nboHistory.RTL_NBO_Group = 'DEPOSIT';
			nboHistory.RTL_Campaign_Code = '001p000000CKyAAD7' + i;
			//nboHistory.RTL_Campaign_Name = 'campaign' + i;
			nboHistory.RTL_Valid_From = Date.today();
			nboHistory.RTL_Valid_To = Date.today().addDays(30);
			nboHistory.RTL_Contact_Date = Date.today().addDays(10);
			nboHistory.RTL_Customer_Name = acctId;
			nboHistoryProduct = new RTL_NBOService.NBOHistoryProduct();
			nboHistoryProduct.RTL_NBO_ID = nboHistory.RTL_NBO_ID;
			nboHistoryProduct.RTL_NBO_Product_External_ID = nboHistory.RTL_NBO_ID + '0';
			if (i == 0 || i == 7) {//nbo product with valid product group only
				nboHistoryProduct.RTL_Product_Group = 'test group1';
			} 
			if (i == 1) {//nbo product with only valid product subgroup only
				nboHistoryProduct.RTL_Product_SubGroup = 'test subgroup2';
			}
			if (i == 2) {//nbo product with only valid product name
				nboHistoryProduct.RTL_Product = 'test product3';
			}
			if (i == 3) {//nbo product with only invalid product group
				nboHistoryProduct.RTL_Product_Group = 'invalid product group';		
			}
			if (i == 4) {//nbo product with only invalid product subgroup
				nboHistoryProduct.RTL_Product_SubGroup = 'invalid product subgroup';				
			}
			if (i == 5) {//nbo product with only invalid product name
				nboHistoryProduct.RTL_Product = 'invalid product name';			
			}
			if (i == 6) {//none of product group, subgroup and name is provided
				nboHistoryProduct.RTL_Product_Group = null;
				nboHistoryProduct.RTL_Product_SubGroup = null;
				nboHistoryProduct.RTL_Product = null;				
			}			
			nboHistoryProductList = new List<RTL_NBOService.NBOHistoryProduct>();
			if (i != 8) nboHistoryProductList.add(nboHistoryProduct); //test case simulate NBO History without product
			nboMapToReturn.put(nboHistory, nboHistoryProductList);
        }    	
    	return nboMapToReturn;
    } 
    
    public static void createRetailMasterProducts2(Boolean doInsert){
        //List of retail master product records to be inserted 
        List<RTL_product_master__c> retailMasterProductsToInsert = new List<RTL_product_master__c>();
                                                                                  
        retailMasterProductsToInsert.add(new RTL_product_master__c ( 
                Active__c = TRUE,
                Name = 'test product1',
                Product_Code__c = '0001',
                Product_Group__c = 'test group1',
                Product_Sub_group__c = 'test subgroup1'));
        
        retailMasterProductsToInsert.add(new RTL_product_master__c ( 
                Active__c = TRUE,
                Name = 'test product2',
                Product_Code__c = '0002',
                Product_Group__c = 'test group2',
                Product_Sub_group__c = 'test subgroup2'));
        
        retailMasterProductsToInsert.add(new RTL_product_master__c ( 
                Active__c = TRUE,
                Name = 'test product3',
                Product_Code__c = '0003',
                Product_Group__c = 'test group3',
                Product_Sub_group__c = 'test subgroup3'));
        
        retailMasterProductsToInsert.add(new RTL_product_master__c ( 
                Active__c = TRUE,
                Name = 'Deposit Product',
                Product_Code__c = '0004',
                Product_Group__c = 'Deposit',
                Product_Sub_group__c = 'Deposit TestSubgroup'));
        
        retailMasterProductsToInsert.add(new RTL_product_master__c ( 
                Active__c = TRUE,
                Name = 'test product5',
                Product_Code__c = '0005',
                Product_Group__c = 'Loans',
                Product_Sub_group__c = 'Loans TestSubgroup'));

        if(doInsert){
            insert retailMasterProductsToInsert;
        }
    }       
    
    public static Id createOccupation(){
        RTL_Occupation_Details__c  occ = new RTL_Occupation_Details__c(RTL_Occupation_Desc__c = 'Developer');
        insert occ;
        return occ.Id;
    }

    public static void createAddrFieldLength(){
        List<RTL_Address_Field_Length__c> aflList = new List<RTL_Address_Field_Length__c>();
        RTL_Address_Field_Length__c afl1 = new RTL_Address_Field_Length__c();
        afl1.Name = 'Office Address Length';
        afl1.RTL_Field_Name__c = 'Office_Address_Line_1_PE__c';
        afl1.RTL_Min_Field_Length__c = 5;
        aflList.add(afl1);
        
        RTL_Address_Field_Length__c afl2 = new RTL_Address_Field_Length__c();
        afl2.Name = 'Primary Address Length';
        afl2.RTL_Field_Name__c = 'Primary_Address_Line_1_PE__c';
        afl2.RTL_Min_Field_Length__c = 5;
        aflList.add(afl2);
        
        RTL_Address_Field_Length__c afl3 = new RTL_Address_Field_Length__c();
        afl3.Name = 'Registered Address Length';
        afl3.RTL_Field_Name__c = 'Registered_Address_Line_1_PE__c';
        afl3.RTL_Min_Field_Length__c = 5;
        aflList.add(afl3);
        
        insert aflList;
    }
    
    public static List<Account> createAccountDataQuality(boolean doInsert){
        List<Account> accountList = new List<Account>();
        Account acc = new Account();
        	acc.RecordTypeId = acctRT;
            acc.Name = 'retail test 1';
        	acc.Last_name_PE__c ='Test1';
            acc.Email_Address_PE__c = 'retail1@email.com';
            acc.ID_Number_PE__c = '1679900278235';
            acc.ID_Type_PE__c = 'Citizen ID';
            acc.Mobile_Number_PE__c = '0800303967';
        	acc.RTL_Office_Phone_Number__c = '0803958372';
            acc.Office_Address_Line_1_PE__c = '123 street BKK';
            acc.Zip_Code_Office_PE__c = '12345';
            acc.Primary_Address_Line_1_PE__c = '123 street BKK';
            acc.Zip_Code_Primary_PE__c = '54321';
            acc.Registered_Address_Line_1_PE__c = '123 street retail';
            acc.Zip_Code_Registered_PE__c =  '90877';
            acc.RTL_Date_Of_Birth__c = system.today().addYears(30);
            acc.RTL_Occupation_Details__c = createOccupation();
        	acc.Account_Type__c = 'Retail Customer';
			accountList.add(acc);

        if(doInsert){
                insert accountList;
        }
        return accountList;
    }
    
    public static List<Account> createAccountDataQualityFail(boolean doInsert){
        List<Account> accountList = new List<Account>();
        Account acc = new Account();
        	acc.RecordTypeId = acctRT;
            acc.Name = 'retail test 1';
        	acc.Last_name_PE__c ='Test1';
        	acc.RTL_Office_Phone_Number__c = '0803958372';
        	acc.Account_Type__c = 'Retail Customer';
			accountList.add(acc);
        
        Account acc2 = new Account();
        	acc2.RecordTypeId = acctRT;
            acc2.Name = 'retail test 2';
        	acc2.Last_name_PE__c ='Test2';
            acc2.Email_Address_PE__c = 'retail1@email.com';
            acc2.ID_Number_PE__c = '167990027825';
            acc2.ID_Type_PE__c = 'Citizen ID';
            acc2.Mobile_Number_PE__c = '08003039';
        	acc2.RTL_Office_Phone_Number__c = '0803958372';
            acc2.Office_Address_Line_1_PE__c = 'BKK';
            acc2.Zip_Code_Office_PE__c = '123';
            acc2.Primary_Address_Line_1_PE__c = 'BKK';
            acc2.Zip_Code_Primary_PE__c = '543';
            acc2.Registered_Address_Line_1_PE__c = 'BKK';
            acc2.Zip_Code_Registered_PE__c =  '9087';
            acc2.RTL_Date_Of_Birth__c = date.newInstance(1900, 1, 1);
            acc2.RTL_Occupation_Details__c = createOccupation();
        	acc2.Account_Type__c = 'Retail Customer';
			accountList.add(acc2);

        if(doInsert){
                insert accountList;
        }
        return accountList;
    }
    
    public static List<Account> createAccountDataQualityNA(boolean doInsert){
        List<Account> accountList = new List<Account>();
        Account acc = new Account();
        	acc.RecordTypeId = acctRT;
            acc.Name = 'retail test 1';
        	acc.Last_name_PE__c ='Test1';
            acc.Mobile_Number_PE__c = '0800303967';
        	acc.RTL_Office_Phone_Number__c = '0803958372';
        	acc.Account_Type__c = 'Retail Prospect';
			accountList.add(acc);

        if(doInsert){
                insert accountList;
        }
        return accountList;
    }

    public static List<Account> createAccountDataAge(boolean doInsert){
        
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(RecordTypeId = acctRT ,Last_name_PE__c ='Test1',Name = 'retail test' ,Mobile_Number_PE__c = '0800909098' ,
                                                  Segment_crm__c = '5' , RTL_RM_Last_Update__c = system.today().addYears(-1),Account_Type__c='Retail Customer');
        accList.add(acc1);
       
        Account acc2 = new Account(RecordTypeId = acctRT ,Last_name_PE__c ='Test2',Name = 'retail test2' ,Mobile_Number_PE__c = '0803333398' ,
                                                  Segment_crm__c = '5' , RTL_RM_Last_Update__c = system.today().addYears(-2),Account_Type__c='Retail Customer');
        accList.add(acc2);
        
        Account acc3 = new Account(RecordTypeId = acctRT ,Last_name_PE__c ='Test3',Name = 'retail test3' ,Mobile_Number_PE__c = '0803311198' ,
                                                  Segment_crm__c = '6' , RTL_RM_Last_Update__c = system.today().addYears(-2),Account_Type__c='Retail Customer');
        accList.add(acc3);
        
        Account acc4 = new Account(RecordTypeId = acctRT ,Last_name_PE__c ='Test4',Name = 'retail test4' ,Mobile_Number_PE__c = '0802222198' ,
                                                  Segment_crm__c = '6' , RTL_RM_Last_Update__c = system.today().addYears(-3),Account_Type__c='Retail Customer');
        accList.add(acc4);
        
        Account acc5 = new Account(RecordTypeId = acctRT ,Last_name_PE__c ='Test5',Name = 'retail test5' ,Mobile_Number_PE__c = '0802222444' ,
                                                  Segment_crm__c = '7' , RTL_RM_Last_Update__c = system.today().addYears(-4),Account_Type__c='Retail Customer');
        accList.add(acc5);
        
        Account acc6 = new Account(RecordTypeId = acctRT ,Last_name_PE__c ='Test6',Name = 'retail test6' ,Mobile_Number_PE__c = '0802222444' ,
                                                  Segment_crm__c = '7' , RTL_RM_Last_Update__c = system.today().addYears(-6),Account_Type__c='Retail Customer');
        accList.add(acc6);
        
        Account acc7 = new Account(RecordTypeId = acctRT ,Last_name_PE__c ='Test7',Name = 'retail test7' ,Mobile_Number_PE__c = '0802223344' ,
                                                  Segment_crm__c = null , RTL_RM_Last_Update__c = null,Account_Type__c='Retail Customer');
        accList.add(acc7);
        
        Account acc8 = new Account(RecordTypeId = acctRT ,Last_name_PE__c ='Test8',Name = 'retail test8' ,Mobile_Number_PE__c = '0802223344' ,
                                                  Segment_crm__c = null , RTL_RM_Last_Update__c = system.today().addYears(-1),Account_Type__c='Retail Customer');
        accList.add(acc8);
        
        Account acc9 = new Account(RecordTypeId = acctRT ,Last_name_PE__c ='Test9',Name = 'retail test9' ,Mobile_Number_PE__c = '0802223344' ,
                                                  Segment_crm__c = '8' , RTL_RM_Last_Update__c = system.today().addYears(-1),Account_Type__c='Retail Customer');
        accList.add(acc9);

        
        if(doInsert)
        	insert accList;
        return accList;
    }   
    
    public static List<Account>  createAccountMkt(boolean doInsert){
        
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(
            RecordTypeId = acctRT , 
            Last_name_PE__c ='Test1',
            Name = 'retail mkt test1',
            Mobile_Number_PE__c = '0800000800');
        accList.add(acc1);
        
        Account acc2 = new Account(
            RecordTypeId = acctRT , 
            Name = 'retail mkt test1',
            Last_name_PE__c ='Test2',
            Mobile_Number_PE__c = '0800000800');
        accList.add(acc2);
        
        if(doInsert)
            insert accList;
        return accList;
    }
    
    public static List<RTL_Online_Service_Log__c> createOnlineServiceLog(Integer size,boolean doInsert){
        List<RTL_Online_Service_Log__c> onlineServiceLogToCreate = new List<RTL_Online_Service_Log__c>();
        
        for(Integer i = 0;i<size;i++){
            RTL_Online_Service_Log__c onlineServiceLog = new RTL_Online_Service_Log__c();
            onlineServiceLog.RTL_Customer_Name__c = 'Customer'+i;
            onlineServiceLog.RTL_Error_Message__c = 'OSC01 ERRROR'+i;
            onlineServiceLog.RTL_Mulesoft_Log_Id__c = '56730422';
            onlineServiceLog.RTL_Name_of_User__c = 'User'+i;
            onlineServiceLog.RTL_RM_ID__c = '001100000000000000000000051187';
            
            onlineServiceLogToCreate.add(onlineServiceLog);
        }
        
        if(doInsert){
            insert onlineServiceLogToCreate;
        }
        return onlineServiceLogToCreate;
    }
    
    public static void createEmailConfig(){
   		List<AppConfig__c> apps = new  List<AppConfig__c>();
    	AppConfig__c Aconfig = new AppConfig__c();
    	Aconfig.Name = 'Operation Team A';
    	Aconfig.Value__c = 'test1@email.com';        
    	apps.add(Aconfig);
        
        
        AppConfig__c Aconfig2 = new AppConfig__c();
        Aconfig2.Name = 'Operation Team B';
        Aconfig2.Value__c = 'test2@email.com'; 
        apps.add(Aconfig2);
        
        AppConfig__c Aconfig3 = new AppConfig__c();
        Aconfig3.Name = 'Operation Team c';
        Aconfig3.Value__c = 'test3@email.com'; 
        apps.add(Aconfig3);
        
        AppConfig__c Aconfig4 = new AppConfig__c();
        Aconfig4.Name = 'Operation Team D';
        Aconfig4.Value__c = 'test4@email.com'; 
        apps.add(Aconfig4);
        
        AppConfig__c Aconfig5 = new AppConfig__c();
        Aconfig5.Name = 'Operation Team E';
        Aconfig5.Value__c = 'test5@email.com'; 
        apps.add(Aconfig5);
        
        insert apps;
    }
    
    public static Contact createContacts(Account acc){

        Contact cont = new Contact();
        cont.AccountId = acc.id;
        cont.Salutation = 'Mr.';
        cont.LastName = 'TestMock'; 
        cont.Date_of_Birth__c = Date.today();
        cont.Position__c = 'position1';
        cont.Value_Style__c = 'Risk Awareness';
        cont.Decision_Map__c = 'User';
        cont.Product_Decision__c = '';
        cont.Description__c = 'contact description';
        cont.OwnerId  = acc.OwnerId;

        return cont;
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
        
        if(doInsert){
            
            insert userToCreate;
        }
        
        return userToCreate;
    }

    public static Campaign createMasterCampaign(String name , String code9digit , String type , String segment , User ownerUser )
    {
        
        Campaign masterC = new Campaign();
        masterC.Name = name;
        masterC.Segment__c = segment;
        masterC.OwnerId  = ownerUser.id;
        masterC.RecordTypeId = masterRt.id;
        masterC.RTL_Campaign_Code_9_digits__c = code9digit;
        masterC.isActive = true;
        masterC.Status = 'In Progress';
        masterC.RTL_Call_Start_Date__c = Date.today();
        masterC.RTL_Call_End_Date__c = Date.today().addDays(7);
        masterC.RTL_Campaign_Type__c = type;
        masterC.startDate = Date.today();
        masterC.endDate = Date.today().addDays(7);
  

        return masterC;
    }   

    public static Campaign createChildCampaign(String name , String codeLastDigit , Campaign masterCam, RecordType rt )
    {

        Campaign childC = new Campaign();
        childC.Name = name;
        childC.Segment__c = masterCam.Segment__c;
        childC.OwnerId  = masterCam.OwnerId;
        childC.parentId = masterCam.id;
        childC.RecordTypeId = rt.id;
        childC.RTL_Campaign_Code_10_digits__c = masterCam.RTL_Campaign_Code_9_digits__c + codeLastDigit;
        childC.isActive = true;
        childC.Status = 'In Progress';
        childC.RTL_Call_Start_Date__c = Date.today();
        childC.RTL_Call_End_Date__c = Date.today().addDays(7);
        childC.startDate = Date.today();
        childC.endDate = Date.today().addDays(7);
        childC.RTL_Campaign_Type__c = masterCam.RTL_Campaign_Type__c;
        childC.RTL_Category__c = 'Communication';
        childC.RTL_Campaign_Objective__c = 'Loyalty';
        //childC.RTL_Priority__c = '3 Medium';
        //childC.RTL_Campaign_Sub_Type__c = '2 HasCampaignFulfillment';
        //childC.RTL_Campaign_Channel__c = '6 PrintMedia';
        //childC.RTL_Campaign_Sub_Type__c = '2 HasCampaignFulfillment';

        return childC;
    }
    
    public static List<Campaignmember> createCampaignmemberWithLead (List<Lead> leads,Id campaignid,Boolean doInsert){
        List<Campaignmember> listcampaignmember = new List<Campaignmember>();
        for(Integer i = 0;i<leads.size();i++){
            Campaignmember cm = new Campaignmember();
            cm.LeadId = leads.get(i).id;
            cm.CampaignId = campaignid;
            listcampaignmember.add(cm);
        }

        if(doInsert){
            insert listcampaignmember;
        }

        return listcampaignmember;
    }

    public static void createCampaignAssignmentRule(){
        RecordType retailCampaignMember = [SELECT Id,Name FROM RECordType WHERE Name = 'Exclusive Campaign (Active)'];
        User currentUser = [SELECT Id,UserName FROM User WHERE Id =: UserInfo.getUserId()  ];
        Campaign custRequestCampaign = createMasterCampaign('CustomerRequest','DZZZ03471','Exclusive',null,currentUser);
        insert custRequestCampaign;
        Campaign childCampaign = createChildCampaign('CustomerRequest 2561A' , 'A' ,custRequestCampaign ,retailCampaignMember );
        insert childCampaign;

        List<RTL_Campaign_Assignment_Rule__c> campaignAssignmentRuleList = new List<RTL_Campaign_Assignment_Rule__c>();
        RTL_Campaign_Assignment_Rule__c campaignAssignmentRule1 = new RTL_Campaign_Assignment_Rule__c();
        campaignAssignmentRule1.RTL_Campaign_Lead_Source__c = 'Web';
        campaignAssignmentRule1.RTL_Start_Date__c = Date.today();
        campaignAssignmentRule1.RTL_End_Date__c = Date.today().addDays(7);
        campaignAssignmentRule1.RTL_Active__c = true;
        campaignAssignmentRule1.RTL_Campaign__c = childCampaign.id;
        campaignAssignmentRuleList.add(campaignAssignmentRule1);

        RTL_Campaign_Assignment_Rule__c campaignAssignmentRule2 = new RTL_Campaign_Assignment_Rule__c();
        campaignAssignmentRule2.RTL_Campaign_Lead_Source__c = 'ATM Request';
        campaignAssignmentRule2.RTL_Start_Date__c = Date.today();
        campaignAssignmentRule2.RTL_End_Date__c = Date.today().addDays(7);
        campaignAssignmentRule2.RTL_Active__c = true;
        campaignAssignmentRule2.RTL_Campaign__c = childCampaign.id;
        campaignAssignmentRuleList.add(campaignAssignmentRule2);

        RTL_Campaign_Assignment_Rule__c campaignAssignmentRule3 = new RTL_Campaign_Assignment_Rule__c();
        campaignAssignmentRule3.RTL_Campaign_Lead_Source__c = 'Default';
        campaignAssignmentRule3.RTL_Start_Date__c = Date.today();
        campaignAssignmentRule3.RTL_End_Date__c = Date.today().addDays(7);
        campaignAssignmentRule3.RTL_Active__c = true;
        campaignAssignmentRule3.RTL_Campaign__c = childCampaign.id;
        campaignAssignmentRuleList.add(campaignAssignmentRule3);

        insert campaignAssignmentRuleList;
    }

    public static void createOpportunityRecordTypeMapping(){
        List<Opportunity_Recordtype_Mapping__c> opportunityRecordTypeMappingList = new List<Opportunity_Recordtype_Mapping__c>();
        Opportunity_Recordtype_Mapping__c oppTypeMapping1 = new Opportunity_Recordtype_Mapping__c();
        oppTypeMapping1.Name = 'Deposit';
        oppTypeMapping1.Product_Group__c = 'Deposit';
        oppTypeMapping1.Record_Type__c = 'Retail Deposit';
        oppTypeMapping1.Stage__c = 'Prospect';
        opportunityRecordTypeMappingList.add(oppTypeMapping1);


        insert opportunityRecordTypeMappingList;
    }

    public static Lead createLeads2(Boolean doInsert)
    {
        //select deposit product as master always
        RTL_product_master__c masterProduct = [Select Id, Product_Code__c, Product_Group__c, Product_Sub_group__c
                         from RTL_product_master__c 
                         where Product_Code__c = : '0001' and Active__c = : true limit 1];

        Integer i = 99;
        RecordType recordType = [select Id from RecordType where developername='Retail_Banking' and IsActive = true limit 1];
        Lead lead = new Lead();
        lead.Title = 'TH';
        lead.Company = 'X';
        lead.FirstName = 'Test99'+i;
        lead.LastName = 'TestLead';
        lead.Email = 'test'+i+'@salesforce.com';
        lead.RTL_Mobile_Number__c = '1111111111';
        lead.RTL_Phone_Number__c = '222222222';
        lead.RTL_Office_Number__c = '333333333';
        lead.RTL_Primary_Interested_Product__c = masterProduct.Id;
        lead.Status = 'New';
        lead.Street = 'aaa';
        lead.City = 'bbb';
        lead.State = 'CC';
        lead.PostalCode = '1111111';
        lead.Country = 'DD';
        lead.RecordTypeId = recordType.id;
        lead.RTL_ID_Type__c = 'Passport ID';
        lead.RTL_Citizen_Id__c = 'aaaaaa';
        lead.RTL_Web_Unique_ID_c__c = 'Test'+i;
        
        if(doInsert){
            insert lead;
        }
        return lead;
    }

    public static Lead updateLeads2(Lead lead, String masterProductCode, Boolean doUpdate)
    {
        //select deposit product as master always
        RTL_product_master__c masterProduct = [SELECT Id, Product_Code__c, Product_Group__c, Product_Sub_group__c
                         FROM RTL_product_master__c 
                         WHERE Product_Code__c = : masterProductCode and Active__c = : true limit 1];

        lead.RTL_Primary_Interested_Product__c = masterProduct.Id;
        if(doUpdate){
            update lead;
        }
        return lead;
    }

}