@isTest
private class LeadExtensionV2Test {
    static List<RTL_Referral__c> referralList;
    static List<Branch_And_Zone__c> branchAndZoneList;
    static List<RTL_Product_Master__c> retailProductMasterList;
    static List<Account> acctList;
    static {
          
        TestUtils.createIdType();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();
        TestUtils.createDisqualifiedReason();
        TestUtils.createDateOfBirth();
        TestUtils.CreateProceBookAccess();
        TestUtility_Referral.createAppConfigReferralAssignment();
        TestUtility_Referral.createReferralAssignment();
        TestUtility_Referral.createAppConfigCallMeNowBH();
        retailProductMasterList = retailProductMasterList = RTL_TestUtility.createRetailProducts(true);
        branchAndZoneList = RTL_TestUtility.createBranchZone(9,true); 
        RTL_Branch_Manager_Title__c branchTitle = new RTL_Branch_Manager_Title__c(Name='Branch Manager',RTL_Value__c='Branch Manager');
        insert branchTitle;
        
    }
    
    public static RecordType CommercialLeadRecordType {
        get{
            if(CommercialLeadRecordType ==null){
                CommercialLeadRecordType = [SELECT id,Name FROM RecordType 
                                        WHERE Name='Commercial Lead' 
                                        AND sObjectType='Lead' LIMIT 1];
            }
            return CommercialLeadRecordType;
        }
        set;
        }

    @isTest 
    static void PositiveCaseCommercialAccount() {
        // Implement test code
        List<User> usList = TestUtils.createUsers(2,'Lead','Extension','LeadEx@tmbbank.com',true);
        PageReference LeadCreation = Page.LeadCreation;
        Test.setCurrentPage(LeadCreation);
        
        LisT<Account> acct =  TestUtils.createAccounts(2,'testDisqualified','Individual', false);
        Account firstAcct = acct.get(0);
        firstAcct.ID_Type_PE__c = 'Passport ID';
        firstAcct.ID_Number_PE__c = '13255555';
        firstAcct.Phone = '0877874871';
        firstAcct.OwnerID = usList.get(0).id;
        insert firstacct;
        Lead Lead1 = CreateValidLead(usList.get(0).id);
        Lead Lead2 = CreateValidLead(usList.get(0).id);
         
        Test.startTest();
            ApexPages.StandardController controllerinsert = new ApexPages.StandardController(Lead1);
            LeadExtensionV2 leadex = new LeadExtensionV2(controllerinsert);
            leadex.RecordTypeObj = null;
            RecordType leadRectype = leadEx.recordTypeObj;
            leadex.leadobj = Lead1;
            leadEx.doAction();
            leadEx.viewDetail();
            leadEx.cancelSalesConsole();
            
            
            ApexPages.StandardController controllerinsertmobile = new ApexPages.StandardController(Lead2);
            LeadExtensionV2 leadexmobile = new LeadExtensionV2(controllerinsertmobile);
            leadexmobile.leadobj = Lead2;
            leadexmobile.doActionMobile();
        Test.stopTest();
    }
    
    @isTest 
    static void PositiveCaseUpdateLead() {
        // Implement test code

        List<User> usList = TestUtils.createUsers(2,'Lead','Extension','LeadEx@tmbbank.com',true);
        PageReference LeadCreation = Page.LeadCreation;
        Test.setCurrentPage(LeadCreation);
        
        Lead Lead1 = CreateValidLead(usList.get(0).id);
        Lead Lead2 = CreateValidLead(usList.get(0).id);
        insert lead1;
        insert lead2;
        ApexPages.currentPage().getParameters().put('ID', lead1.id);
        Test.startTest();
            ApexPages.StandardController controllerinsert = new ApexPages.StandardController(Lead1);
            LeadExtensionV2 leadex = new LeadExtensionV2(controllerinsert);
            leadex.leadobj = Lead1;
            leadEx.doAction();
            leadEx.viewDetail();
            leadEx.cancelSalesConsole();
            RecordType leadRectype = leadEx.recordTypeObj;
            
            ApexPages.StandardController controllerinsertmobile = new ApexPages.StandardController(Lead2);
            LeadExtensionV2 leadexmobile = new LeadExtensionV2(controllerinsertmobile);
            leadexmobile.leadobj = Lead2;
            leadexmobile.doActionMobile();
       
            
        Test.stopTest();
    }
    @isTest 
    static void PositiveCaseUpdateLeadToComAcct() {
    // Implement test code

        List<User> usList = TestUtils.createUsers(2,'Lead','Extension','LeadEx@tmbbank.com',true);
        PageReference LeadCreation = Page.LeadCreation;
        Test.setCurrentPage(LeadCreation);
        
        Lead Lead1 = CreateValidLead(usList.get(0).id);
        Lead Lead2 = CreateValidLead(usList.get(0).id);
        insert lead1;
        insert lead2;
            
        LisT<Account> acct =  TestUtils.createAccounts(2,'testDisqualified','Individual', false);
        Account firstAcct = acct.get(0);
        firstAcct.ID_Type_PE__c = 'Passport ID';
        firstAcct.ID_Number_PE__c = '132555556';
        firstAcct.Phone = '0877874871';
        firstAcct.OwnerID = usList.get(0).id;
        insert firstacct;
        ApexPages.currentPage().getParameters().put('ID', lead1.id);
        Test.startTest();
            ApexPages.StandardController controllerinsert = new ApexPages.StandardController(Lead1);
            LeadExtensionV2 leadex = new LeadExtensionV2(controllerinsert);
            leadex.leadobj = Lead1;
            leadex.leadobj.ID_Number__c ='132555556';
            leadEx.doAction();
            
            ApexPages.StandardController controllerinsertmobile = new ApexPages.StandardController(Lead2);
            LeadExtensionV2 leadexmobile = new LeadExtensionV2(controllerinsertmobile);
            leadexmobile.leadobj = Lead2;
            leadexmobile.leadobj.ID_Number__c ='132555556';
            leadexmobile.doActionMobile();
       
            
         Test.stopTest();
    }
    
    @isTest 
    static void NegativeCaseDupLead() {
        // Implement test code

        List<User> usList = TestUtils.createUsers(2,'Lead','Extension','LeadEx@tmbbank.com',true);
        PageReference LeadCreation = Page.LeadCreation;
        Test.setCurrentPage(LeadCreation);

        Lead Lead1 = CreateValidLead(usList.get(0).id);
        Lead Lead2 = CreateValidLead(usList.get(1).id);
        Lead Lead3 = CreateValidLead(usList.get(0).id);
        insert lead2;
        Test.startTest();
            ApexPages.StandardController controllerinsert = new ApexPages.StandardController(Lead1);
            LeadExtensionV2 leadex = new LeadExtensionV2(controllerinsert);
            leadex.leadobj = Lead1;
            leadEx.doAction();
            
            ApexPages.StandardController controllerinsertmobile = new ApexPages.StandardController(Lead3);
            LeadExtensionV2 leadexmobile = new LeadExtensionV2(controllerinsertmobile);
            leadexmobile.leadobj = Lead3;
            leadexmobile.doActionMobile();
       
            
        Test.stopTest();
    }
    
    @isTest 
    static void NegativeCaseUpdateDupLead() {
        // Implement test code
        List<User> usList = TestUtils.createUsers(2,'Lead','Extension','LeadEx@tmbbank.com',true);
        PageReference LeadCreation = Page.LeadCreation;
        Test.setCurrentPage(LeadCreation);

        Lead Lead1 = CreateValidLead(usList.get(0).id);
        Lead Lead2 = CreateValidLead(usList.get(1).id);
        Lead Lead3 = CreateValidLead(usList.get(0).id);
        insert Lead1;
        insert Lead3;
        Lead2.ID_Number__c ='1555334';
        
        insert Lead2;
        ApexPages.currentPage().getParameters().put('ID', lead1.id);
        Test.startTest();
            ApexPages.StandardController controllerinsert = new ApexPages.StandardController(Lead1);
            LeadExtensionV2 leadex = new LeadExtensionV2(controllerinsert);
            leadex.leadobj = Lead1;
            LeadEx.leadObj.ID_Number__c ='1555334';
            leadEx.doAction();
            
            ApexPages.StandardController controllerinsertmobile = new ApexPages.StandardController(Lead3);
            LeadExtensionV2 leadexmobile = new LeadExtensionV2(controllerinsertmobile);
            leadexmobile.leadobj = Lead3;
            LeadExMobile.leadObj.ID_Number__c ='1555334';
            leadexmobile.doActionMobile();
       
            
         Test.stopTest();
    }
      
    @isTest 
    static void NegativeCaseUpdateDupLead2() {
        // Implement test code
        List<User> usList = TestUtils.createUsers(2,'Lead','Extension','LeadEx@tmbbank.com',true);
        PageReference LeadCreation = Page.LeadCreation;
        Test.setCurrentPage(LeadCreation);  
         
        Lead Lead1 = CreateValidLead(usList.get(0).id);
        Lead Lead2 = CreateValidLead(usList.get(1).id);
        Lead Lead3 = CreateValidLead(usList.get(0).id);
        insert Lead1;
        insert Lead3;
        Lead2.ID_Number__c ='1555334';
        LisT<Account> acct =  TestUtils.createAccounts(2,'testDisqualified','Individual', false);
        Account firstAcct = acct.get(0);
        firstAcct.ID_Type_PE__c = 'Passport ID';
        firstAcct.ID_Number_PE__c = '1555334444';
        firstAcct.Phone = '0877874871';
        firstAcct.OwnerID = usList.get(1).id;
        insert firstacct;
        Lead2.Account__c =firstacct.id;
        insert Lead2;
        ApexPages.currentPage().getParameters().put('ID', lead1.id);
        Test.startTest();
            ApexPages.StandardController controllerinsert = new ApexPages.StandardController(Lead1);
            LeadExtensionV2 leadex = new LeadExtensionV2(controllerinsert);
            leadex.leadobj = Lead1;
            LeadEx.leadObj.ID_Number__c ='1555334';
            leadEx.doAction();
            
            ApexPages.StandardController controllerinsertmobile = new ApexPages.StandardController(Lead3);
            LeadExtensionV2 leadexmobile = new LeadExtensionV2(controllerinsertmobile);
            leadexmobile.leadobj = Lead3;
            LeadExMobile.leadObj.ID_Number__c ='1555334';
            leadexmobile.doActionMobile();
       
            
        Test.stopTest();
    }
   
    @isTest 
    static void NegativeCaseDupAccount() {
        // Implement test code

        List<User> usList = TestUtils.createUsers(2,'Lead','Extension','LeadEx@tmbbank.com',true);
        PageReference LeadCreation = Page.LeadCreation;
        Test.setCurrentPage(LeadCreation);

        Lead Lead1 = CreateValidLead(usList.get(0).id);
        Lead Lead3 = CreateValidLead(usList.get(0).id);
            
        LisT<Account> acct =  TestUtils.createAccounts(2,'testDisqualified','Individual', false);
        Account firstAcct = acct.get(0);
        firstAcct.ID_Type_PE__c = 'Passport ID';
        firstAcct.ID_Number_PE__c = '13255555';
        firstAcct.Phone = '0877874871';
        firstAcct.OwnerID = usList.get(1).id;
        insert firstacct;
        Test.startTest();
            ApexPages.StandardController controllerinsert = new ApexPages.StandardController(Lead1);
            LeadExtensionV2 leadex = new LeadExtensionV2(controllerinsert);
            leadex.leadobj = Lead1;
            leadEx.doAction();
            
            ApexPages.StandardController controllerinsertmobile = new ApexPages.StandardController(Lead3);
            LeadExtensionV2 leadexmobile = new LeadExtensionV2(controllerinsertmobile);
            leadexmobile.leadobj = Lead3;
            leadexmobile.doActionMobile();
       
            
        Test.stopTest();
    }
    
    public static Lead CreateValidLead(Id OwnerID){
        Lead leadRec = new lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'Passport ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Individual';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.RecordTypeId = CommercialLeadRecordType.id;
        leadRec.Interest_result__c = 'Yes';
        leadRec.OwnerID = OwnerID;
        
        return leadRec;
    }
    /************   CR Referral   **************/
    @isTest
    public static void testCreateLeadWithReferral(){
        PageReference LeadCreation = Page.LeadCreation;
        Test.setCurrentPage(LeadCreation);
        
        List<User> usList = TestUtils.createUsers(2,'Lead','Extension','LeadEx@tmbbank.com',true);
        referralList = TestUtility_Referral.createReferralsWithoutAccount(2,branchAndZoneList[0].id,'Payroll','Sell (เพื่อนำเสนอขาย)',true);
        Lead Lead1 = CreateValidLead(usList.get(0).id);
        Lead Lead2 = CreateValidLead(usList.get(0).id);
        
        Test.startTest();
            ApexPages.StandardController controllerinsert = new ApexPages.StandardController(Lead1);
            ApexPages.currentPage().getParameters().put('referralId',referralList[0].id);
            LeadExtensionV2 leadex = new LeadExtensionV2(controllerinsert);
            leadex.leadobj = Lead1;
            leadEx.doAction();
            
            ApexPages.StandardController controllerinsertmobile = new ApexPages.StandardController(Lead2);
            ApexPages.currentPage().getParameters().put('referralId',referralList[1].id);
            LeadExtensionV2 leadexmobile = new LeadExtensionV2(controllerinsertmobile);
            leadexmobile.leadobj = Lead2;
            leadexmobile.doActionMobile();
       
            
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateLeadWithClosedReferral(){
        PageReference LeadCreation = Page.LeadCreation;
        Test.setCurrentPage(LeadCreation);
        
        List<User> usList = TestUtils.createUsers(2,'Lead','Extension','LeadEx@tmbbank.com',true);
        referralList = TestUtility_Referral.createReferralsWithoutAccount(1,branchAndZoneList[0].id,'Payroll','Sell (เพื่อนำเสนอขาย)',true);
        Lead Lead1 = CreateValidLead(usList.get(0).id);
        Lead Lead2 = CreateValidLead(usList.get(0).id);
        //set referral status to closed
        referralList[0].RTL_Stage__c = 'Closed (Unable to contact)';
        referralList[0].RTL_Reason__c = 'Busy Line';
        update referralList;
        
        Boolean messageFound = false;
        ApexPages.Message[] pageMessages;
        Test.startTest();
            ApexPages.StandardController controllerinsert = new ApexPages.StandardController(Lead1);
            ApexPages.currentPage().getParameters().put('referralId',referralList[0].id);
            LeadExtensionV2 leadex = new LeadExtensionV2(controllerinsert);
            leadex.leadobj = Lead1;
            leadEx.doAction();
            //Get Apex page messages
            pageMessages = ApexPages.getMessages();
            System.assertNotEquals(0, pageMessages.size());

            // Check that the error message you are expecting is in pageMessages
            for(ApexPages.Message message : pageMessages) {
                //If Referral Stage is Closed
                if(message.getDetail() == System.Label.RTL_Referral_ERR010) {
                    messageFound = true;        
                }
            }

            System.assert(messageFound);
            
            ApexPages.StandardController controllerinsertmobile = new ApexPages.StandardController(Lead2);
            ApexPages.currentPage().getParameters().put('referralId',referralList[0].id);
            LeadExtensionV2 leadexmobile = new LeadExtensionV2(controllerinsertmobile);
            leadexmobile.leadobj = Lead2;
            leadexmobile.doActionMobile();
            
            //Get Apex page message
            pageMessages = ApexPages.getMessages();
            System.assertNotEquals(0, pageMessages.size());

            // Check that the error message you are expecting is in pageMessages
            messageFound = false;

            for(ApexPages.Message message : pageMessages) {
                //If Referral Stage is Closed
                if(message.getDetail() == System.Label.RTL_Referral_ERR010) {
                    messageFound = true;        
                }
            }

            System.assert(messageFound);
       
            
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateLeadWithReferralNotOwn(){
        PageReference LeadCreation = Page.LeadCreation;
        Test.setCurrentPage(LeadCreation);
        
        List<User> usList = TestUtils.createUsers(2,'Lead','Extension','LeadEx@tmbbank.com',true);
        referralList = TestUtility_Referral.createReferralsWithoutAccount(1,branchAndZoneList[0].id,'Payroll','Sell (เพื่อนำเสนอขาย)',true);
        Lead Lead1 = CreateValidLead(usList.get(0).id);
        Lead Lead2 = CreateValidLead(usList.get(0).id);
        //change referral owner
        referralList[0].OwnerId = usList[0].id;
        update referralList;
        
        Boolean messageFound = false;
        ApexPages.Message[] pageMessages;
        Test.startTest();
            ApexPages.StandardController controllerinsert = new ApexPages.StandardController(Lead1);
            ApexPages.currentPage().getParameters().put('referralId',referralList[0].id);
            LeadExtensionV2 leadex = new LeadExtensionV2(controllerinsert);
            leadex.leadobj = Lead1;
            leadEx.doAction();
            //Get Apex page messages
            pageMessages = ApexPages.getMessages();
            System.assertNotEquals(0, pageMessages.size());

            // Check that the error message you are expecting is in pageMessages
            for(ApexPages.Message message : pageMessages) {
                //If Referral Stage is Closed
                if(message.getDetail() == System.Label.RTL_Referral_ERR012) {
                    messageFound = true;        
                }
            }

            System.assert(messageFound);
            
            ApexPages.StandardController controllerinsertmobile = new ApexPages.StandardController(Lead2);
            ApexPages.currentPage().getParameters().put('referralId',referralList[0].id);
            LeadExtensionV2 leadexmobile = new LeadExtensionV2(controllerinsertmobile);
            leadexmobile.leadobj = Lead2;
            leadexmobile.doActionMobile();
            
            //Get Apex page message
            pageMessages = ApexPages.getMessages();
            System.assertNotEquals(0, pageMessages.size());

            // Check that the error message you are expecting is in pageMessages
            messageFound = false;

            for(ApexPages.Message message : pageMessages) {
                //If Referral Stage is Closed
                if(message.getDetail() == System.Label.RTL_Referral_ERR012) {
                    messageFound = true;        
                }
            }

            System.assert(messageFound);
       
            
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateLeadWithReferralWithAccount(){
        PageReference LeadCreation = Page.LeadCreation;
        Test.setCurrentPage(LeadCreation);
        
        List<User> usList = TestUtils.createUsers(2,'Lead','Extension','LeadEx@tmbbank.com',true);
        acctList = TestUtils.createAccounts(1,'ACCT','Existing Customer',true);
        referralList = TestUtility_Referral.createReferralsWithAccount(1,acctList[0].id,branchAndZoneList[0].id,true);
        Lead Lead1 = CreateValidLead(usList.get(0).id);
        Lead Lead2 = CreateValidLead(usList.get(0).id);
        
        Boolean messageFound = false;
        ApexPages.Message[] pageMessages;
        Test.startTest();
            ApexPages.StandardController controllerinsert = new ApexPages.StandardController(Lead1);
            ApexPages.currentPage().getParameters().put('referralId',referralList[0].id);
            LeadExtensionV2 leadex = new LeadExtensionV2(controllerinsert);
            leadex.leadobj = Lead1;
            leadEx.doAction();
            //Get Apex page messages
            pageMessages = ApexPages.getMessages();
            System.assertNotEquals(0, pageMessages.size());

            // Check that the error message you are expecting is in pageMessages
            for(ApexPages.Message message : pageMessages) {
                //If Referral Stage is Closed
                if(message.getDetail() == System.Label.RTL_Referral_ERR002) {
                    messageFound = true;        
                }
            }

            System.assert(messageFound);
            
            ApexPages.StandardController controllerinsertmobile = new ApexPages.StandardController(Lead2);
            ApexPages.currentPage().getParameters().put('referralId',referralList[0].id);
            LeadExtensionV2 leadexmobile = new LeadExtensionV2(controllerinsertmobile);
            leadexmobile.leadobj = Lead2;
            leadexmobile.doActionMobile();
            
            //Get Apex page message
            pageMessages = ApexPages.getMessages();
            System.assertNotEquals(0, pageMessages.size());

            // Check that the error message you are expecting is in pageMessages
            messageFound = false;

            for(ApexPages.Message message : pageMessages) {
                //If Referral Stage is Closed
                if(message.getDetail() == System.Label.RTL_Referral_ERR002) {
                    messageFound = true;        
                }
            }

            System.assert(messageFound);
       
            
        Test.stopTest();
    }
    
    @isTest
    public static void testUpdateLeadWithReferral(){
        
    }
    
}