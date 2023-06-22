@isTest
public class RTL_LeadTriggerHandlerTest {
    static List<Account> acctList;
    static List<Lead> leadList;
    static Map<String, Group> queueMap;
    public static final Id RTL_BRANCH_SALES_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Retail Channel Sales' LIMIT 1].Id;   

    static {
        TestUtils.createAppConfig(); 
        List<RTL_Lead_Assignment_Rule__c> leadAssignList = new List<RTL_Lead_Assignment_Rule__c>();
        RTL_Lead_Assignment_Rule__c leadAssignmentrule = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule.RTL_Active_Flag__c = true;
        leadAssignmentrule.RTL_Priority__c = 1;
        leadAssignmentrule.RTL_IsInsertProduct__c = true;
        leadAssignmentrule.RTL_Assigned_User_field__c = 'OwnerId';
        leadAssignmentrule.RTL_IsAssign_Campaign__c = true;
        leadAssignmentrule.RTL_Lead_Record_Type__c = 'Retail Banking';
        leadAssignmentrule.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule.RTL_Lead_Field_Value_1__c = 'Others';
        leadAssignList.add(leadAssignmentrule);
        RTL_Lead_Assignment_Rule__c leadAssignmentrule2 = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule2.RTL_Active_Flag__c = true;
        leadAssignmentrule2.RTL_Priority__c = 2;
        leadAssignmentrule2.RTL_IsInsertProduct__c = true;
        leadAssignmentrule2.RTL_Assigned_Queue_Name__c = 'RTLQ_001';
        leadAssignmentrule2.RTL_IsAssign_Campaign__c = true;
        leadAssignmentrule2.RTL_Lead_Record_Type__c = 'Retail Banking';
        leadAssignmentrule2.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule2.RTL_Lead_Field_Value_1__c = 'Website';
        leadAssignList.add(leadAssignmentrule2);

        RTL_Lead_Assignment_Rule__c leadAssignmentrule3 = new RTL_Lead_Assignment_Rule__c ();
        leadAssignmentrule3.RTL_Active_Flag__c = true;
        leadAssignmentrule3.RTL_Priority__c = 2;
        leadAssignmentrule3.RTL_IsInsertProduct__c = true;
        leadAssignmentrule3.RTL_Assigned_Queue_Name__c = 'RTL_284';
        leadAssignmentrule3.RTL_IsAssign_Campaign__c = true;
        leadAssignmentrule3.RTL_Lead_Record_Type__c = 'Retail Banking';
        leadAssignmentrule3.RTL_Lead_Field_Criteria_1__c = 'LeadSource';
        leadAssignmentrule3.RTL_Lead_Field_Value_1__c = 'Branch';
        leadAssignList.add(leadAssignmentrule3);

        insert leadAssignList;
        RTL_TestUtility.enableWebToLeadAutoAssign(true);
        RTL_TestUtility.createCampaignAssignmentRule();
        
    }
    
    static testmethod void testLeadConversion(){
        Test.startTest();
        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        System.runAs(retailUser) {
            RTL_TestUtility.createRetailMasterProducts(true);
            leadList = RTL_TestUtility.createLeads(2,true);
            RTL_TestUtility.createInterestedProducts(leadList, true);
            List<Branch_and_Zone__c> branchList = RTL_TestUtility.createBranchZone(2, true);
            
            leadList[0].Status = 'Qualified';
            update leadList;

            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(leadList[0].id);
            lc.setDoNotCreateOpportunity(false);
            lc.setConvertedStatus('Closed Converted');

            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
        }
        Test.stopTest();
    }
    
    static testmethod void testLeadConversionFail(){
        Test.startTest();
        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        System.runAs(retailUser) {
            RTL_TestUtility.createRetailMasterProducts(true);
            leadList = RTL_TestUtility.createLeads(2,true);
            List<Branch_and_Zone__c> branchList = RTL_TestUtility.createBranchZone(2, true);
            
            

            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(leadList[0].id);
            lc.setDoNotCreateOpportunity(false);
            lc.setConvertedStatus('Closed Converted');
            
            try{
                Database.LeadConvertResult lcr = Database.convertLead(lc);
            }catch(Exception e){
                
            }
            RTL_TestUtility.createInterestedProducts(leadList, true);
            leadList[0].Status = 'Qualified';
            update leadList;

        }
        Test.stopTest();
    }
    
    static testmethod void testChangeLeadOwner(){
        Test.startTest();
        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        User retailUser2 = [select ID from user where isactive = true and ProfileId in (SELECT Id FROM Profile WHERE Name = 'TMB Retail Channel Sales' ) LIMIT 1];
        System.runAs(retailUser) {
            RTL_TestUtility.createRetailMasterProducts(true);
            leadList = RTL_TestUtility.createLeads(2,true);
            RTL_TestUtility.createInterestedProducts(leadList, true);
            List<Branch_and_Zone__c> branchList = RTL_TestUtility.createBranchZone(2, true);
    
        }
        leadList[0].OwnerId = retailUser2.id;       
        update leadList;
        Test.stopTest();
    }
    
    static testmethod void testChangeLeadOwnerQueue(){
        Test.startTest();
        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        System.runAs(retailUser) {
            queueMap = RTL_TestUtility.createLeadQueues(true);
            RTL_TestUtility.createRetailMasterProducts(true);
            leadList = RTL_TestUtility.createLeads(2,true);
            RTL_TestUtility.createInterestedProducts(leadList, true);
            List<Branch_and_Zone__c> branchList = RTL_TestUtility.createBranchZone(2, true);
            leadList[0].OwnerId = queueMap.get('RTLQ_001').id;
            update leadList;
        }        
        Test.stopTest();
    }
    
    static testmethod void testChangeLeadOwnerOutboundQueue(){
        Test.startTest();
        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        System.runAs(retailUser) {
            queueMap = RTL_TestUtility.createLeadQueues(true);
            RTL_TestUtility.createRetailMasterProducts(true);
            leadList = RTL_TestUtility.createLeads(2,true);
            RTL_TestUtility.createInterestedProducts(leadList, true);
            List<Branch_and_Zone__c> branchList = RTL_TestUtility.createBranchZone(2, true);
            leadList[0].OwnerId = queueMap.get('RTLQ_Outbound').id;
            update leadList;
    
        }
  
        Test.stopTest();
    }

    public static testmethod void testWebDropLead(){
 
        System.debug(':::: testWebDropLead Start ::::');
        RTL_TestUtility.enableWebToLeadAutoAssign(true); 
        // RTL_TestUtility.createCampaignAssignmentRule();
        RTL_TestUtility.createOpportunityRecordTypeMapping();
        
        List<RTL_product_master__c> productList = new List<RTL_product_master__c>();
        
        RTL_product_master__c product = new RTL_product_master__c(Name='So Smart Test', Product_Group__c='Credit Card & RDC', Product_Sub_group__c='Credit Card',Active__c=true);
        productList.add(product);

        insert productList;
        
         RTL_CampaignMember_Running_No__c cmrn = new RTL_CampaignMember_Running_No__c(
            Name = 'Campaign Member Running No',
            Running_No__c = '000000'
        );
        
        insert cmrn;

        //create test lead queue
        Map<String, Group> leadQueues = RTL_TestUtility.createLeadQueues(true);

        //create test branch
        RTL_TestUtility.createBranchZone(1, true);
        //create test product and web-to-lead assignment criterias
        RTL_TestUtility.createLeadAssignCriterias(true);

        
        TEST.startTest();     

        for(Integer i =0 ; i < 10 ; i++){
            Lead lead = new Lead();
            lead.Company = 'X';
            lead.RTL_TMB_Campaign_Source__c = 'Web';
            lead.FirstName = 'Test1';
            lead.LastName = 'WebToLead';
            lead.Email = 'test1@salesforce.com';
            lead.City = 'Bangkok';
            lead.RTL_Mobile_Number__c = '0819803882';
            lead.RTL_BranchW2L_Area__c = '10400';
            lead.RTL_Branch_Name__c = '001';
            lead.LeadSource = 'Others';
            lead.RTL_Product_Name__c = 'So Smart Test';
            lead.RTL_TMB_Campaign_Reference__c = 'CMN_web';
            lead.RTL_Customer_Segment__c = 'TMB Web';
            lead.RTL_Web_Unique_ID_c__c  = '20171120'+i;
            lead.RecordTypeId = '01290000000iZYKAA2';
            /////lead.RTL_Multiple_Interested_Product_s__c = true;
            insert lead;
        }
        //
        //RTL_TestUtility.createPositiveWebToLead();
        List<Lead> webtolead = [select RTL_Count_InterestedProducts_Primary__c from Lead ];
        System.debug('web to lead ::: '+ webtolead);
        
        TEST.stopTest();
        System.debug(':::: testWebDropLead End ::::');    
    }

    public static testmethod void testDropLeadWithBranch(){
        List<RTL_product_master__c> productList = new List<RTL_product_master__c>();
        RTL_product_master__c product = new RTL_product_master__c(Name='TMB Cash 2 Go (Normal)_Wealth (Digital Channel)', Product_Group__c='Loan', Product_Sub_group__c='PERSONAL LOAN',Active__c=true);
        RTL_product_master__c product2 = new RTL_product_master__c(Name='TMB Cash 2 Go (Normal)_Wealth', Product_Group__c='Loan', Product_Sub_group__c='PERSONAL LOAN',Active__c=true);
        productList.add(product);
        productList.add(product2);
        insert productList;
        List<User> userList = new List<User>();
        for(integer i=0; i<2; i++){
            User retailUser = new User(FirstName='retail'+i, LastName='test user'+i,
            UserName='rtl_'+i+'testuser@tmb.com',
            Email='rtl_'+i+'testuser@tmbbank.com', Alias='RTL'+i+'User',
            LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
            ProfileId = RTL_BRANCH_SALES_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
            RTL_Branch_Code__c='001', Region_Code__c = '002', Zone_Code__c = '003',
            Employee_ID__c='RTL0'+i, RTL_Branch__c='RTLQ_001 (001)',Title= 'Investment Specialist');
            userList.add(retailUser);
        }

        User retailUser = new User(FirstName='retail4', LastName='test user4',
                                    UserName='rtl_4testuser@tmb.com',
                                    Email='rtl_4testuser@tmbbank.com', Alias='RTL4User',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    ProfileId = RTL_BRANCH_SALES_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    RTL_Branch_Code__c='004', Region_Code__c = '002', Zone_Code__c = '003',
                                    Employee_ID__c='RTL04', RTL_Branch__c='RTLQ_004 (004)',Title= 'Investment Specialist');
        userList.add(retailUser);
        insert userList;
        
        List<Title_and_Product_Group_Mapping__c> titleProductList = new List<Title_and_Product_Group_Mapping__c>();
        Title_and_Product_Group_Mapping__c eachTitle1 = new Title_and_Product_Group_Mapping__c(Title__c = 'Investment Specialist',Product_Group__c = 'Loan');     
        titleProductList.add(eachTitle1);
        insert titleProductList;
        //create test branch
        List<Branch_and_Zone__c> branchList = new List<Branch_and_Zone__c>();   
        /* Create branch zone mapping branch name and branch code */
        branchList.add(new Branch_and_Zone__c(Name='RTLQ_001(001)', Branch_Name__c='RTLQ_001', Branch_Code__c='001',isActive__c = true));
        branchList.add(new Branch_and_Zone__c(Name='RTLQ_002(002)', Branch_Name__c='RTLQ_002', Branch_Code__c='002',isActive__c = true));
        branchList.add(new Branch_and_Zone__c(Name='RTLQ_284(284)', Branch_Name__c='RTLQ_284', Branch_Code__c='284',isActive__c = true,RTL_Branch_Manager_User__c =userList[0].Id));
        insert branchList;
        Test.startTest();  
        System.runAs(userList[0]) {
            List<Lead> leadList = new List<Lead>();
            for(Integer i =0 ; i < 4 ; i++){
                Lead lead = new Lead();
                lead.Company = 'X';
                lead.RTL_TMB_Campaign_Source__c = 'Web';
                lead.FirstName = 'Test'+i;
                lead.LastName = 'WebToLead'+i;
                lead.Email = 'test'+i+'@salesforce.com';
                lead.City = 'Bangkok';
                lead.RTL_Mobile_Number__c = '081980389'+i;
                lead.RTL_BranchW2L_Area__c = '10400';
                lead.RTL_Branch_Name__c = '001';
                lead.LeadSource = 'Website';
                lead.RTL_Product_Name__c = 'TMB Cash 2 Go (Normal)_Wealth (Digital Channel)';
                lead.RTL_TMB_Campaign_Reference__c = 'CMN_web';
                lead.RTL_Customer_Segment__c = 'TMB Web';
                lead.RTL_Web_Unique_ID_c__c  = '20171130'+i;
                lead.RecordTypeId = '01290000000iZYKAA2';
                /////lead.RTL_Multiple_Interested_Product_s__c = true;
                leadList.add(lead);
            }
            // for(Integer i =0 ; i < 2 ; i++){
            Lead lead = new Lead();
            lead.Company = 'X';
            lead.RTL_TMB_Campaign_Source__c = 'Web';
            lead.FirstName = 'Test5';
            lead.LastName = 'WebToLead5';
            lead.Email = 'test5@salesforce.com';
            lead.City = 'Bangkok';
            lead.RTL_Mobile_Number__c = '0819803895';
            lead.RTL_BranchW2L_Area__c = '10400';
            lead.RTL_Branch_Name__c = '004';
            lead.LeadSource = 'Branch';
            lead.RTL_Product_Name__c = 'TMB Cash 2 Go (Normal)_Wealth';
            lead.RTL_TMB_Campaign_Reference__c = 'CMN_web';
            lead.RTL_Customer_Segment__c = 'TMB Web';
            lead.RTL_Web_Unique_ID_c__c  = '201711315';
            lead.RecordTypeId = '01290000000iZYKAA2';
            /////lead.RTL_Multiple_Interested_Product_s__c = true;
            leadList.add(lead);
            // }
            insert leadList;
        }
       

        Test.stopTest();


    }

    public static testmethod void testUpdatePrimaryInterestProduct(){
        Test.startTest();
        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        
        System.runAs(retailUser) {
            //create branch and zone
            List<Branch_and_Zone__c> branchList = RTL_TestUtility.createBranchZone(3, true);            
            //create retail master product
            RTL_TestUtility.createRetailMasterProducts(true);
            //create new test lead with primary interested product
            Lead lead = RTL_TestUtility.createLeads2(true);
            //check result: the count of primary interested product should be 1
            Lead selectlead = [SELECT RTL_Primary_Interested_Product__c, RTL_Count_InterestedProducts_Primary__c FROM Lead WHERE Id=:lead.Id];
            System.assertEquals(1, selectlead.RTL_Count_InterestedProducts_Primary__c);

            Test.setCurrentPage(Page.RetailLeadEdit);
            ApexPages.StandardController stdSetController = new ApexPages.StandardController(lead);
            // stdSetController.setSelected(lead);
            RetailLeadExtension ext = new RetailLeadExtension(stdSetController);
            ext.saveLead();
        
            // Update RTL Primary Interested Product on Lead Object / Master Code 004
            lead = RTL_TestUtility.updateLeads2(lead, '0004', false);
            stdSetController = new ApexPages.StandardController(lead);
            ext = new RetailLeadExtension(stdSetController);
            ext.saveLead();
            RTL_product_master__c masterPrimaryProduct = [SELECT Id, Product_Code__c, Product_Group__c, Product_Sub_group__c
                FROM RTL_product_master__c 
                WHERE Product_Code__c = : '0004' AND Active__c = : true LIMIT 1];
            selectlead = [SELECT Id, RTL_Primary_Interested_Product__c, RTL_Count_InterestedProducts_Primary__c FROM Lead WHERE Id=:lead.Id];
            System.assertEquals(masterPrimaryProduct.id, selectlead.RTL_Primary_Interested_Product__c);

            // // Remove RTL Interest Product on Lead Object
            // lead.RTL_Primary_Interested_Product__c = null;
            // stdSetController = new ApexPages.StandardController(lead);
            // ext = new RetailLeadExtension(stdSetController);
            // ext.saveLead();
            // selectlead = [SELECT Id, RTL_Primary_Interested_Product__c, RTL_Count_InterestedProducts_Primary__c FROM Lead WHERE Id=:lead.Id];
            // System.assertEquals(0, selectlead.RTL_Count_InterestedProducts_Primary__c);

            // Update RTL Primary Interested Product on Lead Object / Master Code 002
            lead = RTL_TestUtility.updateLeads2(lead, '0002', false);
            stdSetController = new ApexPages.StandardController(lead);
            ext = new RetailLeadExtension(stdSetController);
            ext.saveLead();
            masterPrimaryProduct = [SELECT Id, Product_Code__c, Product_Group__c, Product_Sub_group__c
                FROM RTL_product_master__c 
                WHERE Product_Code__c = : '0002' AND Active__c = : true LIMIT 1];
            selectlead = [SELECT Id, RTL_Primary_Interested_Product__c, RTL_Count_InterestedProducts_Primary__c FROM Lead WHERE Id=:lead.Id];
            System.assertEquals(masterPrimaryProduct.id, selectlead.RTL_Primary_Interested_Product__c);
        }
        Test.stopTest();
    }

    public static testmethod void testUpdatePrimaryInterestProduct2(){
        Test.startTest();
        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        
        System.runAs(retailUser) {
            //create branch and zone
            List<Branch_and_Zone__c> branchList = RTL_TestUtility.createBranchZone(3, true);            
            //create retail master product
            RTL_TestUtility.createRetailMasterProducts(true);
            //create new test lead with primary interested product
            Lead lead = RTL_TestUtility.createLeads2(true);
            //check result: the count of primary interested product should be 1
            Lead selectlead = [SELECT RTL_Primary_Interested_Product__c, RTL_Count_InterestedProducts_Primary__c FROM Lead WHERE Id=:lead.Id];
            System.assertEquals(1, selectlead.RTL_Count_InterestedProducts_Primary__c);

            Test.setCurrentPage(Page.RetailLeadEdit);
            ApexPages.StandardController stdSetController = new ApexPages.StandardController(lead);
            // stdSetController.setSelected(lead);
            RetailLeadExtension ext = new RetailLeadExtension(stdSetController);
            ext.saveLead();
        
            // Remove RTL Interest Product on Lead Object
            lead.RTL_Primary_Interested_Product__c = null;
            stdSetController = new ApexPages.StandardController(lead);
            ext = new RetailLeadExtension(stdSetController);
            ext.saveLead();
            selectlead = [SELECT Id, RTL_Primary_Interested_Product__c, RTL_Count_InterestedProducts_Primary__c FROM Lead WHERE Id=:lead.Id];
            System.assertEquals(0, selectlead.RTL_Count_InterestedProducts_Primary__c);

            // Update RTL Primary Interested Product on Lead Object / Master Code 002
            lead = RTL_TestUtility.updateLeads2(lead, '0002', false);
            stdSetController = new ApexPages.StandardController(lead);
            ext = new RetailLeadExtension(stdSetController);
            ext.saveLead();
            RTL_product_master__c masterPrimaryProduct = [SELECT Id, Product_Code__c, Product_Group__c, Product_Sub_group__c
                FROM RTL_product_master__c 
                WHERE Product_Code__c = : '0002' AND Active__c = : true LIMIT 1];
            selectlead = [SELECT Id, RTL_Primary_Interested_Product__c, RTL_Count_InterestedProducts_Primary__c FROM Lead WHERE Id=:lead.Id];
            System.assertEquals(masterPrimaryProduct.id, selectlead.RTL_Primary_Interested_Product__c);
        }
        Test.stopTest();
    }

}