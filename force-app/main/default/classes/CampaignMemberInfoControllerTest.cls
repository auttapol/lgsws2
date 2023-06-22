@isTest
public with sharing class CampaignMemberInfoControllerTest {  
    
    @testSetup static void setup() {
        // Implement test code
        
        TestUtils.createAppConfig();
        TestUtility_Referral.createAppConfigReferralAssignment();
        TestUtility_Referral.createReferralAssignment();
        TestUtility_Referral.createAppConfigCallMeNowBH();
        
        //Add for Test campaignmember to CXM
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'CXM_SERVICE_CONNECTOR';
        Aconfig.Value__c = 'true';        
        apps.add(Aconfig);
        insert apps;
        TestUtils.prepareIntegrationMapping();
        TestUtils.prepareEIMmaps();
        
        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'User1' , 'test@tmbbank.com' , false).get(0);
        u.RTL_Branch_Code__c  = '001';
        insert u;
        
        Account acc = RTL_TestUtility.createAccounts(1,false).get(0);
        insert acc;
        
        AccountTeamMember atm = new AccountTeamMember(accountid = acc.id, UserId = u.id);
        insert atm;
        
        Contact ct = RTL_TestUtility.createContacts(acc);
        ct.TMB_Customer_ID__c = acc.TMB_Customer_ID_PE__c;
        ct.OwnerId = u.id;
        insert ct;
        
        Lead lead = RTL_TestUtility.createLeads(1,false).get(0);
        insert lead;
        
        
        Branch_And_Zone__c branch = RTL_TestUtility.createBranchZone(1,true).get(0);
        RTL_Referral__c rf = new RTL_Referral__c(RTL_FirstName__c='Test Referral',
                                                 RTL_LastName__c='Without Account',
                                                 RTL_Mobile1__c = '1111111111',
                                                 RTL_Preferred_Branch__c = branch.Id);
        
        insert rf;        
        
        Campaign masterC = new Campaign();
        masterC.Name = 'Test Campaign';
        masterC.OwnerId  = u.id;
        masterC.isActive = true;
        masterC.Approvedflag__c = true;
        masterC.Status = 'In Progress';
        masterC.RTL_Call_Start_Date__c = Date.today();
        masterC.RTL_Call_End_Date__c = Date.today().addDays(7);
        masterC.startDate = Date.today();
        masterC.endDate = Date.today().addDays(7);
        masterC.RTL_Campaign_Code_10_digits__c = 'DFFFLOC11A';
        insert masterC;       
        
        RTL_Campaign_Endpoint__c setting = new RTL_Campaign_Endpoint__c();
        setting.Name = 'Campaign TO HQ INT06';
        setting.RTL_Endpoint__c = 'https://sfmashupservices.tmbbank.com/retail/campaign/UAT/campaign/retrieveCampaign';
        insert setting;
        
        List<Business_Outcome_Mapping__c> outComeList = new List<Business_Outcome_Mapping__c>();
        Business_Outcome_Mapping__c outCome = new Business_Outcome_Mapping__c();
        outCome.Contact_Status__c = 'Contact'; 
        outCome.Uncontact_Reason__c = ''; 
        outCome.Reason__c = ''; 
        outCome.Offer_Result__c = 'Interested'; 
        outCome.Avaya_Completion_Code__c = 'YES Complete Sale'; 
        outCome.IsActive__c = true; 
        outCome.Retail_Product_Group__c = 'Loan';
        
        Business_Outcome_Mapping__c outCome2 = new Business_Outcome_Mapping__c();
        outCome2.Contact_Status__c = 'Uncontact'; 
        outCome2.Uncontact_Reason__c = 'ลูกค้าไม่รับสาย'; 
        outCome2.Reason__c = ''; 
        outCome2.Offer_Result__c = ''; 
        outCome2.Avaya_Completion_Code__c = 'NANS No Answer'; 
        outCome2.IsActive__c = true; 
        
        Business_Outcome_Mapping__c outCome3 = new Business_Outcome_Mapping__c();
        outCome3.Contact_Status__c = 'Contact'; 
        outCome3.Uncontact_Reason__c = ''; 
        outCome3.Reason__c = 'Loan_2_โอนต่างธนาคาร-ช่วงเวลาที่ระบบยังไม่ดึงบัญชี'; 
        outCome3.Offer_Result__c = 'Not Interested'; 
        outCome3.Avaya_Completion_Code__c = 'NIN Not Interest - Recall'; 
        outCome3.IsActive__c = true;
        outCome3.Retail_Product_Group__c = 'Loan';
        
        outComeList.add(outCome);
        outComeList.add(outCome2);
        outComeList.add(outCome3);
        insert outComeList;
    }
    
    @isTest static void getCampaignMemberOBSellPermission() 
    {
        // Implement test code
        CampaignMemberInfoController.getCampaignMemberOBSellPermission();
    }
    
    @isTest static void getCampaign() 
    {
        Test.StartTest();
        // Implement test code  
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Campaign  masterC = [SELECT Id FROM Campaign LIMIT 1];
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.RTL_Product_Group_1__c = 'Deposit';
        insert cm;
        
        Test.StopTest();
        CampaignMemberInfoController.getCampaign(cm.Id);
    }
    
    @isTest static void getCampaignMember() 
    {
        Test.StartTest();
        // Implement test code
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Campaign  masterC = [SELECT Id FROM Campaign LIMIT 1];
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.RTL_Product_Group_1__c = 'Deposit';
        insert cm;
        
        Test.StopTest();
        CampaignMemberInfoController.getCampaignMember(cm.Id);
        CampaignMemberInfoController.checkUpperPicklistValue('CampaignMember','RTL_Sub_Group_1__c','HIRE PURCHASE');
    }
    
    @isTest static void getFieldLabel() 
    {
        // Implement test code
        CampaignMemberInfoController.getFieldLabel('CampaignMember');
    }
    
    @isTest static void retrieveValueTranformation() 
    {
        // Implement test code
        CampaignMemberInfoController.retrieveValueTranformation('7011s000000AV1AAAW');
    }
        
    @isTest static void getProductInBOM() 
    {
        // Implement test code
        CampaignMemberInfoController.getProductInBOM();
    }
    
    @isTest static void getReasonNotInterestFromBOM() 
    {
        // Implement test code
        CampaignMemberInfoController.getReasonNotInterestFromBOM('Loan','Not Interested');
    }
    
    @isTest static void getPickListValues() 
    {
        // Implement test code
        CampaignMemberInfoController.getPickListValues('CampaignMember','RTL_Contact_Status__c');
    }
    
    @isTest static void getDependentPicklistValues() 
    {
        // Implement test code
        CampaignMemberInfoController.getDependentPicklistValues('CampaignMember','RTL_Sub_Group_1__c','Deposit');
    }
    
    @isTest static void getCampaignProductWrapperINT06() 
    {
        Test.StartTest();
        // Implement test code
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Campaign  masterC = [SELECT Id FROM Campaign LIMIT 1];
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.RTL_Product_Group_1__c = 'Deposit';
        insert cm;
        
        Test.StopTest();
        CampaignMemberInfoController.getCampaignProductWrapperINT06(cm);
    }
    
    @isTest static void getCampaignProductWrapper() 
    {
        Test.StartTest();
        // Implement test code
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Campaign  masterC = [SELECT Id FROM Campaign LIMIT 1];
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.RTL_Product_Group_1__c = 'Deposit';
        insert cm;
        
        Test.StopTest();
        CampaignMemberInfoController.getCampaignProductWrapper(cm.Id);
    }
    
    @isTest static void getCampaignProductWrapper2() 
    {
        Test.StartTest();
        // Implement test code
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Campaign  masterC = [SELECT Id FROM Campaign LIMIT 1];
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.RTL_Product_Group_1__c = 'Deposit';
        cm.RTL_OfferResult_Product_1__c = 'Interested';
        insert cm;
        
        Test.StopTest();
        CampaignMemberInfoController.getCampaignProductWrapper(cm.Id);
    }
    
    @isTest static void getCustomerSegment() 
    {
        Test.StartTest();
        User u = [SELECT Id FROM User LIMIT 1];
        Account acc = RTL_TestUtility.createAccounts(1,false).get(0);
        acc.TMB_Customer_ID_PE__c = '001100000000000000000015615613';
        insert acc;
        Contact ct = RTL_TestUtility.createContacts(acc);
        ct.TMB_Customer_ID__c = acc.TMB_Customer_ID_PE__c;
        ct.OwnerId = u.id;
        insert ct;
        CampaignMemberInfoController.getCustomerSegment('DFFFLOC11A1354593880','001100000000000000000015615613');
        Test.StopTest();
    }
    
    @isTest static void saveCampaignMergeLead() 
    {
        Test.StartTest();
        
        Opportunity objOpp = new Opportunity();
        objOpp.StageName = 'Sales (Loans)';
        objOpp.recordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Retail Loans').getRecordTypeId();
        objOpp.RTL_Status__c = 'Open';
        objOpp.Amount = 12345;
        objOpp.CloseDate = Date.today().addDays(2);
        objOpp.Expected_submit_date__c = Date.today();
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String accObj = '{"Id" : "'+ acc.Id +'", "Name" : "Test Test"}';
        //Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Lead ld = [SELECT Id,FirstName,LastName,RTL_ID_Type__c,RTL_Citizen_Id__c,RTL_Mobile_Number__c,OwnerId,Status,IsConverted,RTL_Allow_Convert_Lead__c FROM Lead LIMIT 1];
        
        
        
        RTL_product_master__c retailMasterProducts = new RTL_product_master__c();
        retailMasterProducts.Active__c = TRUE;
        retailMasterProducts.Name = 'Loan Product';
        retailMasterProducts.Product_Code__c = '0001';
        retailMasterProducts.Product_Group__c = 'Loan';
        retailMasterProducts.Product_Sub_group__c = 'Personal Loan';
        insert retailMasterProducts;
        
        RTL_Interested_products_c__c insertPrimaryInterestedProduct = new RTL_Interested_products_c__c ( 
            Branch_Code__c  = '0004',
            Co_borrower_1__c = 'Test Co Borrower1',
            Co_borrower_2__c = 'Test Co Borrower2',
            Collateral_Type__c = 'Test Collateral Type',
            Debt__c = '5000.23',
            Income_SE__c = '3000.23',
            Income_SL__c ='3000.23',
            Is_Primary__c = TRUE,
            Lead__c = ld.Id,
            Loan_Amount__c = '3000.23',
            product_group__c = retailMasterProducts.Product_Group__c,
            Product_Name__c = retailMasterProducts.Id,
            Product_Sub_Group__c = retailMasterProducts.Product_Sub_group__c );
        insert insertPrimaryInterestedProduct;
        
        List<CampaignMemberInfoController.CampaignProductWrapper> cmWarpList = new List<CampaignMemberInfoController.CampaignProductWrapper>();
        CampaignMemberInfoController.CampaignProductWrapper cmWarp = new CampaignMemberInfoController.CampaignProductWrapper();
        cmWarp.numberOfProduct = 1;
        cmWarp.rowNum = 1;
        cmWarp.productGroup = insertPrimaryInterestedProduct.product_group__c;
        cmWarp.productSubGroup = insertPrimaryInterestedProduct.Product_Sub_Group__c;
        cmWarp.productId = insertPrimaryInterestedProduct.Product_Name__c;
        cmWarp.productName = 'Loan Product';
        cmWarp.offerResult = 'Interested';
        cmWarp.offerResultLabel = 'Interested';
        cmWarp.reason = '';
        cmWarp.stageLabel = '';
        cmWarp.statusLabel = '';
        cmWarp.objOpp = objOpp;
        cmWarp.viewGroup = true;
        cmWarp.viewSubGroup = true;
        cmWarp.viewProductName = true;
        cmWarp.viewOfferResult = true;
        cmWarp.viewReason = false;
        cmWarpList.add(cmWarp);
        
        // Implement test code
 
        Campaign  masterC = [SELECT Id,isActive FROM Campaign WHERE isActive = true LIMIT 1];
        
        String leadInput = '{"Name" : "Test Test", "Mobile_Number_PE__c" : "0987654321", "ID_Type_PE__c" : "Other ID", "ID_Number_PE__c" : "123456789"}';
        
        CampaignMember cm = new CampaignMember();
        //cm.ContactId = ct.id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.RTL_Product_Group_1__c = 'LOAN';
        cm.RTL_OfferResult_Product_1__c = 'Interested';
        cm.LeadId = ld.Id;
        cm.RTL_Marketing_Code__c = 'ABCD12345';
        cm.Completion_Code_1__c = 'YES Complete Sale';
        cm.Completion_Code_2__c = 'NIN Not Interest';
        cm.Completion_Code_3__c = 'NQF Not Qualify';
        cm.Completion_Code_4__c = 'NIN Not Interest - Recall';

        insert cm;
        
        Test.StopTest();
        CampaignMemberInfoController.saveCampaign(cmWarpList,null,accObj,cm,true,null,leadInput);
    }
    
     @isTest static void saveCampaignCreatAcc() 
    {
        Test.StartTest();
        
        Account acc = [SELECT Id,Name FROM Account LIMIT 1];
        String accObj = '{"Id" : "'+ acc.Id +'", "Name" : "Test Test"}';
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Lead ld = [SELECT Id,FirstName,LastName,RTL_ID_Type__c,RTL_Citizen_Id__c,RTL_Mobile_Number__c,OwnerId,Status,IsConverted,RTL_Allow_Convert_Lead__c FROM Lead LIMIT 1];
        
        //create retail master product
        
        Opportunity objOpp = new Opportunity();
        objOpp.StageName = 'Sales (Loans)';
        objOpp.recordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Retail Loans').getRecordTypeId();
        objOpp.RTL_Status__c = 'Open';
        objOpp.Amount = 12345;
        objOpp.CloseDate = Date.today().addDays(2);
        objOpp.Expected_submit_date__c = Date.today();
        
        RTL_product_master__c retailMasterProducts = new RTL_product_master__c();
        retailMasterProducts.Active__c = TRUE;
        retailMasterProducts.Name = 'Loan Product';
        retailMasterProducts.Product_Code__c = '0001';
        retailMasterProducts.Product_Group__c = 'Loan';
        retailMasterProducts.Product_Sub_group__c = 'Personal Loan';
        insert retailMasterProducts;
        
        RTL_Interested_products_c__c insertPrimaryInterestedProduct = new RTL_Interested_products_c__c ( 
            Branch_Code__c  = '0004',
            Co_borrower_1__c = 'Test Co Borrower1',
            Co_borrower_2__c = 'Test Co Borrower2',
            Collateral_Type__c = 'Test Collateral Type',
            Debt__c = '5000.23',
            Income_SE__c = '3000.23',
            Income_SL__c ='3000.23',
            Is_Primary__c = TRUE,
            Lead__c = ld.Id,
            Loan_Amount__c = '3000.23',
            product_group__c = retailMasterProducts.Product_Group__c,
            Product_Name__c = retailMasterProducts.Id,
            Product_Sub_Group__c = retailMasterProducts.Product_Sub_group__c );
        insert insertPrimaryInterestedProduct;
        
        List<CampaignMemberInfoController.CampaignProductWrapper> cmWarpList = new List<CampaignMemberInfoController.CampaignProductWrapper>();
        CampaignMemberInfoController.CampaignProductWrapper cmWarp = new CampaignMemberInfoController.CampaignProductWrapper();
        cmWarp.numberOfProduct = 1;
        cmWarp.rowNum = 1;
        cmWarp.productGroup = insertPrimaryInterestedProduct.product_group__c;
        cmWarp.productSubGroup = insertPrimaryInterestedProduct.Product_Sub_Group__c;
        cmWarp.productId = insertPrimaryInterestedProduct.Product_Name__c;
        cmWarp.productName = 'Loan Product';
        cmWarp.offerResult = 'Interested';
        cmWarp.offerResultLabel = '';
        cmWarp.reason = '';
        cmWarp.stageLabel = '';
        cmWarp.statusLabel = '';
        cmWarp.objOpp = objOpp;
        cmWarp.viewGroup = true;
        cmWarp.viewSubGroup = true;
        cmWarp.viewProductName = true;
        cmWarp.viewOfferResult = true;
        cmWarp.viewReason = false;
        cmWarpList.add(cmWarp);
        
        Campaign  masterC = [SELECT Id,isActive FROM Campaign WHERE isActive = true LIMIT 1];
        
        String leadInput = '{"Name" : "Test Test", "Mobile_Number_PE__c" : "0987654321", "ID_Type_PE__c" : "Other ID", "ID_Number_PE__c" : "123456789"}';
        
        CampaignMember cm = new CampaignMember();      
        cm.Customer__c = acc.Id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.RTL_Product_Group_1__c = 'LOAN';
        cm.RTL_OfferResult_Product_1__c = 'Interested';
        cm.LeadId = ld.Id;
        cm.RTL_Marketing_Code__c = 'ABCD12345';
        
        Test.StopTest();
        CampaignMemberInfoController.saveCampaign(cmWarpList,null,accObj,cm,false,null,leadInput);
    }
    
    @isTest static void saveCampaignHaveContact() 
    {
        Test.StartTest();
        
        Opportunity objOpp = new Opportunity();
        objOpp.StageName = 'Sales (Loans)';
        objOpp.recordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Retail Loans').getRecordTypeId();
        objOpp.RTL_Status__c = 'Open';
        objOpp.Amount = 12345;
        objOpp.CloseDate = Date.today().addDays(2);
        objOpp.Expected_submit_date__c = Date.today();
                
        // Implement test code
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String accObj = '{"Id" : "'+ acc.Id +'", "Name" : "Test Test"}';
        Contact ct = [SELECT Id,FirstName,LastName FROM Contact LIMIT 1];
        
        Lead ld = [SELECT Id,FirstName,LastName,RTL_ID_Type__c,RTL_Citizen_Id__c,RTL_Mobile_Number__c,OwnerId,Status,IsConverted,RTL_Allow_Convert_Lead__c FROM Lead LIMIT 1];
        Campaign  masterC = [SELECT Id,isActive FROM Campaign WHERE isActive = true LIMIT 1];
        
        String leadInput = '{"Name" : "Test Test", "Mobile_Number_PE__c" : "0987654321", "ID_Type_PE__c" : "Other ID", "ID_Number_PE__c" : "123456789"}';

        RTL_product_master__c retailMasterProducts = new RTL_product_master__c();
        retailMasterProducts.Active__c = TRUE;
        retailMasterProducts.Name = 'Loan Product';
        retailMasterProducts.Product_Code__c = '0001';
        retailMasterProducts.Product_Group__c = 'Loan';
        retailMasterProducts.Product_Sub_group__c = 'Personal Loan';
        insert retailMasterProducts;
        
        RTL_Interested_products_c__c insertPrimaryInterestedProduct = new RTL_Interested_products_c__c ( 
            Branch_Code__c  = '0004',
            Co_borrower_1__c = 'Test Co Borrower1',
            Co_borrower_2__c = 'Test Co Borrower2',
            Collateral_Type__c = 'Test Collateral Type',
            Debt__c = '5000.23',
            Income_SE__c = '3000.23',
            Income_SL__c ='3000.23',
            Is_Primary__c = TRUE,
            Lead__c = ld.Id,
            Loan_Amount__c = '3000.23',
            product_group__c = retailMasterProducts.Product_Group__c,
            Product_Name__c = retailMasterProducts.Id,
            Product_Sub_Group__c = retailMasterProducts.Product_Sub_group__c );
        insert insertPrimaryInterestedProduct;
        
        List<CampaignMemberInfoController.CampaignProductWrapper> cmWarpList = new List<CampaignMemberInfoController.CampaignProductWrapper>();
        CampaignMemberInfoController.CampaignProductWrapper cmWarp = new CampaignMemberInfoController.CampaignProductWrapper();
        cmWarp.numberOfProduct = 1;
        cmWarp.rowNum = 1;
        cmWarp.productGroup = insertPrimaryInterestedProduct.product_group__c;
        cmWarp.productSubGroup = insertPrimaryInterestedProduct.Product_Sub_Group__c;
        cmWarp.productId = insertPrimaryInterestedProduct.Product_Name__c;
        cmWarp.productName = 'Loan Product';
        cmWarp.offerResult = 'Interested';
        cmWarp.offerResultLabel = '';
        cmWarp.reason = '';
        cmWarp.stageLabel = '';
        cmWarp.statusLabel = '';
        cmWarp.objOpp = objOpp;
        cmWarp.viewGroup = true;
        cmWarp.viewSubGroup = true;
        cmWarp.viewProductName = true;
        cmWarp.viewOfferResult = true;
        cmWarp.viewReason = false;
        cmWarpList.add(cmWarp);
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.RTL_Product_Group_1__c = 'LOAN';
        cm.RTL_OfferResult_Product_1__c = 'Interested';
        cm.LeadId = ld.Id;
        cm.RTL_Marketing_Code__c = 'ABCD12345';
        cm.Customer__c = acc.Id;
        insert cm;
        
        Test.StopTest();
        CampaignMemberInfoController.saveCampaign(cmWarpList,null,accObj,cm,false,null,leadInput);
    }
    
    @isTest static void updateCampaignMember1year() 
    {
        Test.StartTest();
        
        // Implement test code
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Lead ld = [SELECT Id,FirstName,LastName,RTL_ID_Type__c,RTL_Citizen_Id__c,RTL_Mobile_Number__c,OwnerId,Status,IsConverted,RTL_Allow_Convert_Lead__c FROM Lead LIMIT 1];
        Campaign  masterC = [SELECT Id,isActive FROM Campaign WHERE isActive = true LIMIT 1];
        
        String leadInput = '{"Name" : "Test Test", "Mobile_Number_PE__c" : "0987654321", "ID_Type_PE__c" : "Other ID", "ID_Number_PE__c" : "123456789"}';
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.Customer__c = acc.Id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Do Not Contact 1year';
        cm.RTL_Product_Group_1__c = 'LOAN';
        cm.RTL_OfferResult_Product_1__c = 'Interested';
        cm.LeadId = ld.Id;
        cm.RTL_Marketing_Code__c = 'ABCD12345';
        insert cm;
        
        Test.StopTest();
        CampaignMemberInfoController.updateCampaignMember(cm);
    } 
    
    @isTest static void updateCampaignMember6Months() 
    {
        Test.StartTest();
        
        // Implement test code
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Lead ld = [SELECT Id,FirstName,LastName,RTL_ID_Type__c,RTL_Citizen_Id__c,RTL_Mobile_Number__c,OwnerId,Status,IsConverted,RTL_Allow_Convert_Lead__c FROM Lead LIMIT 1];
        Campaign  masterC = [SELECT Id,isActive FROM Campaign WHERE isActive = true LIMIT 1];
        
        String leadInput = '{"Name" : "Test Test", "Mobile_Number_PE__c" : "0987654321", "ID_Type_PE__c" : "Other ID", "ID_Number_PE__c" : "123456789"}';
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.Customer__c = acc.Id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Do Not Contact 6 Months';
        cm.RTL_Product_Group_1__c = 'LOAN';
        cm.RTL_OfferResult_Product_1__c = 'Interested';
        cm.LeadId = ld.Id;
        cm.RTL_Marketing_Code__c = 'ABCD12345';
        insert cm;
        
        Test.StopTest();
        CampaignMemberInfoController.updateCampaignMember(cm);
    }  
    
    @isTest static void updateCampaignMemberLifeTime() 
    {
        Test.StartTest();
        
        // Implement test code
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Lead ld = [SELECT Id,FirstName,LastName,RTL_ID_Type__c,RTL_Citizen_Id__c,RTL_Mobile_Number__c,OwnerId,Status,IsConverted,RTL_Allow_Convert_Lead__c FROM Lead LIMIT 1];
        Campaign  masterC = [SELECT Id,isActive FROM Campaign WHERE isActive = true LIMIT 1];
        
        String leadInput = '{"Name" : "Test Test", "Mobile_Number_PE__c" : "0987654321", "ID_Type_PE__c" : "Other ID", "ID_Number_PE__c" : "123456789"}';
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.Customer__c = acc.Id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Do Not Contact LifeTime';
        cm.RTL_Product_Group_1__c = 'LOAN';
        cm.RTL_OfferResult_Product_1__c = 'Interested';
        cm.LeadId = ld.Id;
        cm.RTL_Marketing_Code__c = 'ABCD12345';
        insert cm;
        
        Test.StopTest();
        CampaignMemberInfoController.updateCampaignMember(cm);
    }  
    
    @isTest static void updateCampaignMember1yearNoId() 
    {
        Test.StartTest();
        
        // Implement test code
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Lead ld = [SELECT Id,FirstName,LastName,RTL_ID_Type__c,RTL_Citizen_Id__c,RTL_Mobile_Number__c,OwnerId,Status,IsConverted,RTL_Allow_Convert_Lead__c FROM Lead LIMIT 1];
        Campaign  masterC = [SELECT Id,isActive FROM Campaign WHERE isActive = true LIMIT 1];
        
        String leadInput = '{"Name" : "Test Test", "Mobile_Number_PE__c" : "0987654321", "ID_Type_PE__c" : "Other ID", "ID_Number_PE__c" : "123456789"}';
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.Customer__c = acc.Id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Do Not Contact 1year';
        cm.RTL_Product_Group_1__c = 'LOAN';
        cm.RTL_OfferResult_Product_1__c = 'Interested';
        cm.LeadId = ld.Id;
        cm.RTL_Marketing_Code__c = 'ABCD12345';
        
        Test.StopTest();
        CampaignMemberInfoController.updateCampaignMember(cm);
    } 
    
    @isTest static void updateCampaignMemberLifeTimeNoId() 
    {
        Test.StartTest();
        
        // Implement test code
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Lead ld = [SELECT Id,FirstName,LastName,RTL_ID_Type__c,RTL_Citizen_Id__c,RTL_Mobile_Number__c,OwnerId,Status,IsConverted,RTL_Allow_Convert_Lead__c FROM Lead LIMIT 1];
        Campaign  masterC = [SELECT Id,isActive FROM Campaign WHERE isActive = true LIMIT 1];
        
        String leadInput = '{"Name" : "Test Test", "Mobile_Number_PE__c" : "0987654321", "ID_Type_PE__c" : "Other ID", "ID_Number_PE__c" : "123456789"}';
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.Customer__c = acc.Id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Do Not Contact LifeTime';
        cm.RTL_Product_Group_1__c = 'LOAN';
        cm.RTL_OfferResult_Product_1__c = 'Interested';
        cm.LeadId = ld.Id;
        cm.RTL_Marketing_Code__c = 'ABCD12345';
        
        Test.StopTest();
        CampaignMemberInfoController.updateCampaignMember(cm);
    } 
    
    @isTest static void updateCampaignMember6MonthsNoId() 
    {
        Test.StartTest();
        
        // Implement test code
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Lead ld = [SELECT Id,FirstName,LastName,RTL_ID_Type__c,RTL_Citizen_Id__c,RTL_Mobile_Number__c,OwnerId,Status,IsConverted,RTL_Allow_Convert_Lead__c FROM Lead LIMIT 1];
        Campaign  masterC = [SELECT Id,isActive FROM Campaign WHERE isActive = true LIMIT 1];
        
        String leadInput = '{"Name" : "Test Test", "Mobile_Number_PE__c" : "0987654321", "ID_Type_PE__c" : "Other ID", "ID_Number_PE__c" : "123456789"}';
        
        CampaignMember cm = new CampaignMember();
        cm.ContactId = ct.id;
        cm.Customer__c = acc.Id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Do Not Contact 6 Months';
        cm.RTL_Product_Group_1__c = 'LOAN';
        cm.RTL_OfferResult_Product_1__c = 'Interested';
        cm.LeadId = ld.Id;
        cm.RTL_Marketing_Code__c = 'ABCD12345';
        
        Test.StopTest();
        CampaignMemberInfoController.updateCampaignMember(cm);
    } 
    
    @isTest static void getStageNameSchema() 
    {
        CampaignMemberInfoController.getStageNameSchema('Loan');
    }
    
    @isTest static void saveLogCampaignmember() 
    {
        Test.StartTest();
        
        Account acc = [SELECT Id,Name FROM Account LIMIT 1];
        Contact ct = [SELECT Id FROM Contact LIMIT 1];
        Lead ld = [SELECT Id,FirstName,LastName,RTL_ID_Type__c,RTL_Citizen_Id__c,RTL_Mobile_Number__c,OwnerId,Status,IsConverted,RTL_Allow_Convert_Lead__c FROM Lead LIMIT 1];
        
        Campaign  masterC = [SELECT Id,isActive FROM Campaign WHERE isActive = true LIMIT 1];

        CampaignMember cm = new CampaignMember();      
        cm.Customer__c = acc.Id;
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.RTL_Product_Group_1__c = 'LOAN';
        cm.RTL_OfferResult_Product_1__c = 'Interested';
        cm.LeadId = ld.Id;
        cm.RTL_Marketing_Code__c = 'ABCD12345';
        insert cm;
        
        Test.StopTest();
        CampaignMemberInfoController.saveLogCampaignmember(cm);
    }
    
    @isTest static void saveCampaignmemberWithCrossSell() 
    {
        Test.StartTest();
                     
        Account acc = [SELECT Id,Name FROM Account LIMIT 1];
        String accObj = '{"Id" : "'+ acc.Id +'", "Name" : "Test Test"}';
        Contact ct = [SELECT Id FROM Contact LIMIT 1];       
        Lead ld = [SELECT Id,FirstName,LastName,RTL_ID_Type__c,RTL_Citizen_Id__c,RTL_Mobile_Number__c,OwnerId,Status,IsConverted,RTL_Allow_Convert_Lead__c FROM Lead LIMIT 1];
        
        //create retail master product
        
        RTL_product_master__c retailMasterProducts = new RTL_product_master__c();
        retailMasterProducts.Active__c = TRUE;
        retailMasterProducts.Name = 'Loan Product';
        retailMasterProducts.Product_Code__c = '0001';
        retailMasterProducts.Product_Group__c = 'Loan';
        retailMasterProducts.Product_Sub_group__c = 'Personal Loan';
        insert retailMasterProducts;
        
        RTL_Interested_products_c__c insertPrimaryInterestedProduct = new RTL_Interested_products_c__c ( 
            Branch_Code__c  = '0004',
            Co_borrower_1__c = 'Test Co Borrower1',
            Co_borrower_2__c = 'Test Co Borrower2',
            Collateral_Type__c = 'Test Collateral Type',
            Debt__c = '5000.23',
            Income_SE__c = '3000.23',
            Income_SL__c ='3000.23',
            Is_Primary__c = TRUE,
            Lead__c = ld.Id,
            Loan_Amount__c = '3000.23',
            product_group__c = retailMasterProducts.Product_Group__c,
            Product_Name__c = retailMasterProducts.Id,
            Product_Sub_Group__c = retailMasterProducts.Product_Sub_group__c );
        insert insertPrimaryInterestedProduct;
                
        Opportunity objOpp = new Opportunity();
        objOpp.StageName = 'Sales (Loans)';
        objOpp.recordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Retail Loans').getRecordTypeId();
        objOpp.RTL_Status__c = 'Open';
        objOpp.Amount = 12345;
        objOpp.CloseDate = Date.today().addDays(2);
        objOpp.Expected_submit_date__c = Date.today();
        
        List<CampaignMemberInfoController.CampaignProductWrapper> cmWarpList = new List<CampaignMemberInfoController.CampaignProductWrapper>();
        CampaignMemberInfoController.CampaignProductWrapper cmWarp = new CampaignMemberInfoController.CampaignProductWrapper();
        cmWarp.numberOfProduct = 1;
        cmWarp.rowNum = 1;
        cmWarp.productGroup = insertPrimaryInterestedProduct.product_group__c;
        cmWarp.productSubGroup = insertPrimaryInterestedProduct.Product_Sub_Group__c;
        cmWarp.productId = insertPrimaryInterestedProduct.Product_Name__c;
        cmWarp.productName = 'Loan Product';
        cmWarp.offerResult = 'Interested';
        cmWarp.offerResultLabel = '';
        cmWarp.reason = 'Test';
        cmWarp.stageLabel = '';
        cmWarp.statusLabel = '';
        cmWarp.objOpp = objOpp;
        cmWarp.viewGroup = true;
        cmWarp.viewSubGroup = true;
        cmWarp.viewProductName = true;
        cmWarp.viewOfferResult = true;
        cmWarp.viewReason = false;
        cmWarpList.add(cmWarp);
        
        Campaign  masterC = [SELECT Id,isActive FROM Campaign WHERE isActive = true LIMIT 1];
        
        String leadInput = '{"Name" : "Test Test", "Mobile_Number_PE__c" : "0987654321", "ID_Type_PE__c" : "Other ID", "ID_Number_PE__c" : "123456789"}';
          String crossSell = '[{"productGroup":"'+insertPrimaryInterestedProduct.product_group__c+'","productSubGroup":"'+insertPrimaryInterestedProduct.Product_Sub_Group__c+'","productName":"So Smart Test","productName_Id":"'+insertPrimaryInterestedProduct.Product_Name__c+'","offerResult":"Interested",'
            			  +'"stage":"Sales (BA)","status":"Open","amount":"012","expectedDate":"2021-03-03","opportunity":"","opptyRecordType_DevName":"Retail_Bancassurance"}]'; 
         
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.LeadId = ld.Id;
        cm.RTL_Marketing_Code__c = 'ABCD12345';     
      
        CampaignMemberInfoController.saveCampaign(cmWarpList,null,null,cm,true,crossSell,leadInput);
        
        Test.StopTest();
    }
    
    @isTest static void MergeConvertLeadCAMPAIGN() 
    {
        Test.StartTest();
        
        Account acc = [SELECT Id,Name FROM Account LIMIT 1];
        String accObj = '{"Id" : "'+ acc.Id +'", "Name" : "Test Test"}';
        Contact ct = [SELECT Id FROM Contact LIMIT 1];       
        //Lead ld = [SELECT Id,FirstName,LastName,RTL_ID_Type__c,RTL_Citizen_Id__c,RTL_Mobile_Number__c,OwnerId,Status,IsConverted,RTL_Allow_Convert_Lead__c FROM Lead LIMIT 1];
        
        Lead lead = new Lead();
        lead.RTL_Mobile_Number__c = '0987654321';
        lead.RTL_ID_Type__c = 'Other ID'; 
        lead.RTL_Citizen_Id__c = '123456789';
        lead.LastName = 'TT01';
        lead.Company = 'T Company';
        lead.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Retail Banking').getRecordTypeId();
        insert lead;
        //create retail master product
        RTL_product_master__c retailMasterProducts = new RTL_product_master__c();
        retailMasterProducts.Active__c = TRUE;
        retailMasterProducts.Name = 'Loan Product';
        retailMasterProducts.Product_Code__c = '0001';
        retailMasterProducts.Product_Group__c = 'Loan';
        retailMasterProducts.Product_Sub_group__c = 'Personal Loan';
        insert retailMasterProducts;
        
        RTL_Interested_products_c__c insertPrimaryInterestedProduct = new RTL_Interested_products_c__c ( 
            Branch_Code__c  = '0004',
            Co_borrower_1__c = 'Test Co Borrower1',
            Co_borrower_2__c = 'Test Co Borrower2',
            Collateral_Type__c = 'Test Collateral Type',
            Debt__c = '5000.23',
            Income_SE__c = '3000.23',
            Income_SL__c ='3000.23',
            Is_Primary__c = TRUE,
            Lead__c = lead.Id,
            Loan_Amount__c = '3000.23',
            product_group__c = retailMasterProducts.Product_Group__c,
            Product_Name__c = retailMasterProducts.Id,
            Product_Sub_Group__c = retailMasterProducts.Product_Sub_group__c );
        insert insertPrimaryInterestedProduct;
        
        Campaign  masterC = [SELECT Id,isActive FROM Campaign WHERE isActive = true LIMIT 1];
        
        String leadInput = '{"Name" : "Test Test", "Mobile_Number_PE__c" : "0987654321", "ID_Type_PE__c" : "Other ID", "ID_Number_PE__c" : "123456789"}';
          String crossSell = '[{"productGroup":"'+insertPrimaryInterestedProduct.product_group__c+'","productSubGroup":"'+insertPrimaryInterestedProduct.Product_Sub_Group__c+'","productName":"So Smart Test","productName_Id":"'+insertPrimaryInterestedProduct.Product_Name__c+'","offerResult":"Interested",'
            			  +'"stage":"Sales (BA)","status":"Open","amount":"012","expectedDate":"2021-03-03","opportunity":"","opptyRecordType_DevName":"Retail_Bancassurance"}]'; 
         
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.LeadId = lead.Id;
        cm.RTL_Marketing_Code__c = 'ABCD12345';
       	insert cm;
        
        List<Object> crossSellObjs = new List<Object>();
        crossSellObjs = (List<Object>)JSON.deserializeUntyped(crossSell);
        
        CampaignMemberInfoController.MergeConvertLeadCAMPAIGN(cm, acc, lead, new List<CampaignMemberInfoController.CampaignProductWrapper>(),
                                                              new List<CampaignMemberInfoController.CampaignProductWrapper>(), crossSellObjs);
        Test.StopTest();
    } 
    
    
     @isTest static void NewAccConvertLeadCAMPAIGN() 
    {
        Test.StartTest();
                     
        Account acc = [SELECT Id,Name FROM Account LIMIT 1];
        String accObj = '{"Id" : "'+ acc.Id +'", "Name" : "Test Test"}';
        Contact ct = [SELECT Id FROM Contact LIMIT 1];       
        //Lead ld = [SELECT Id,FirstName,LastName,RTL_ID_Type__c,RTL_Citizen_Id__c,RTL_Mobile_Number__c,OwnerId,Status,IsConverted,RTL_Allow_Convert_Lead__c FROM Lead LIMIT 1];
        
        Lead lead = new Lead();
        lead.RTL_Mobile_Number__c = '0987654321';
        lead.RTL_ID_Type__c = 'Other ID'; 
        lead.RTL_Citizen_Id__c = '123456789';
        lead.LastName = 'TT01';
        lead.Company = 'T Company';
        lead.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Retail Banking').getRecordTypeId();
        insert lead;
        //create retail master product
       RTL_product_master__c retailMasterProducts = new RTL_product_master__c();
        retailMasterProducts.Active__c = TRUE;
        retailMasterProducts.Name = 'Loan Product';
        retailMasterProducts.Product_Code__c = '0001';
        retailMasterProducts.Product_Group__c = 'Loan';
        retailMasterProducts.Product_Sub_group__c = 'Personal Loan';
        insert retailMasterProducts;
        
        RTL_Interested_products_c__c insertPrimaryInterestedProduct = new RTL_Interested_products_c__c ( 
            Branch_Code__c  = '0004',
            Co_borrower_1__c = 'Test Co Borrower1',
            Co_borrower_2__c = 'Test Co Borrower2',
            Collateral_Type__c = 'Test Collateral Type',
            Debt__c = '5000.23',
            Income_SE__c = '3000.23',
            Income_SL__c ='3000.23',
            Is_Primary__c = TRUE,
            Lead__c = lead.Id,
            Loan_Amount__c = '3000.23',
            product_group__c = retailMasterProducts.Product_Group__c,
            Product_Name__c = retailMasterProducts.Id,
            Product_Sub_Group__c = retailMasterProducts.Product_Sub_group__c );
        insert insertPrimaryInterestedProduct;
                
        Campaign  masterC = [SELECT Id,isActive FROM Campaign WHERE isActive = true LIMIT 1];
        
        String leadInput = '{"Name" : "Test Test", "Mobile_Number_PE__c" : "0987654321", "ID_Type_PE__c" : "Other ID", "ID_Number_PE__c" : "123456789"}';
        String crossSell = '[{"productGroup":"'+insertPrimaryInterestedProduct.product_group__c+'","productSubGroup":"'+insertPrimaryInterestedProduct.Product_Sub_Group__c+'","productName":"So Smart Test","productName_Id":"'+insertPrimaryInterestedProduct.Product_Name__c+'","offerResult":"Interested",'
            			  +'"stage":"Sales (BA)","status":"Open","amount":"012","expectedDate":"2021-03-03","opportunity":"","opptyRecordType_DevName":"Retail_Bancassurance"}]'; 
         
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = masterC.id;
        cm.RTL_Last_Contact_Status__c = 'New';
        cm.RTL_Contact_Status__c = 'Contact';
        cm.LeadId = lead.Id;
        cm.RTL_Marketing_Code__c = 'ABCD12345';
        insert cm;
        
        List<Object> crossSellObjs = new List<Object>();
        crossSellObjs = (List<Object>)JSON.deserializeUntyped(crossSell);

        CampaignMemberInfoController.NewAccConvertLeadCAMPAIGN(cm, lead, new List<CampaignMemberInfoController.CampaignProductWrapper>(),
                                                              new List<CampaignMemberInfoController.CampaignProductWrapper>(), crossSellObjs);
        Test.StopTest();
    } 
    
}