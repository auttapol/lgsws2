@isTest
private class HostProductMappingService_Test {
    //private static = ps
    static Opportunity ps_opportunity;
    @testSetup
    static void initContextData() {
        /****************************************************
        * DataSet1
        * ---------------------------------------------------
        * User in this context is  Employee_ID__c = 'SLOS1'
        * With SE Segmen
        * PriceBook TMB_Pricebook__c = 'TMB0002'
        *****************************************************/
        system.debug('HostProductMapping:::initContextData');        
        SLOSDataset.DataSet1();
    }
    @isTest
    static void verify_DataSet() {
        system.debug('HostProductMapping:::verify_DataSet');       
        List<Product2> product = [select id , name from product2];
        system.debug('product size ' + product.size()); // 250;
        system.assertEquals(250 , product.size());
        Pricebook2 Pricebook = [select Id , Name , TMB_Pricebook__c from Pricebook2 where TMB_Pricebook__c = 'TMB0002' limit 1 ];
        system.debug('price book name : ' + Pricebook.Name);
        system.assertEquals('TMB0002' , Pricebook.TMB_Pricebook__c);
        List<Host_Product_Mapping__c> hpros = [select id , Host_Name__c, Host_Product_Group__c, Salesforce_Product__c, Product_Program__c, Host_Prod_Name_Credit_Facility__c from Host_Product_Mapping__c ];
        system.assertEquals(2 , hpros.size());
    }    
    // Auto Create HostProduct Mapping
    // Case 1 Full Run
    @isTest
    static void test_OpportunityWithSelecteProduct_AutoCreate_ProductMapping() {
        /**********************************************************
        *   Step 1 ) Setup Data
        **********************************************************/
        createAccountWithOpptAndOppLine();
        
        /**********************************************************
        *   Step 2 ) Manual Insert Host Application Respond
        **********************************************************/
        test.startTest();
        opportunity oppTemp = new opportunity(id = ps_opportunity.id, application_status__c = 'RM1', stagename = 'CA-Prep'
                                , Expected_submit_date__c = system.today(), CloseDate = system.today());
        update oppTemp;
       
        Host_Application_Response__c happRespond =  createHostApplicationResponse(ps_opportunity);
        ps_opportunity = [select Id , caid__c, StageName , name , AccountId, App_Ref_Number__c, PriceBook2Id  from Opportunity where id = : ps_opportunity.id limit 1];
        
        system.debug('::: StageName = ' + ps_opportunity.StageName);
        //system.assertEquals('CA-Prep', ps_opportunity.StageName);
        /**********************************************************
        *   Step 3 ) Manual Insert Host Application Respond
        **********************************************************/
        Host_Product_Response__c hpres = new Host_Product_Response__c();
        hpres.App_Ref_Number__c            = happRespond.App_Ref_Number__c;
        hpres.Approved_Amount__c           = 1000;
        hpres.CRM_ID__c                    = happRespond.CRM_ID__c;
        hpres.Host_Name__c                 = 'SLS'; 
        hpres.Host_Application_Response__c = happRespond.Id;
        hpres.Host_Product_Program__c      = 'SmartBiz for Construction';
        hpres.Host_Product_Name__c         = 'Loan - Construction';  // ==>  Host_Prod_Name_Credit_Facility__c
        hpres.Host_Product_Group__c        = 'TMB SME SmartBiz';
        hpres.Host_Product_Code__c         = '0003'; 

        List<OpportunityLineItem> lines = [SELECT Id, Host_Product_Status__c, TotalPrice, UnitPrice, Quantity, Host_Product_Mapping__c FROM OpportunityLineItem where OpportunityId = :  ps_opportunity.Id];
        system.assertEquals(1, lines.size());
        List<Host_Product_Mapping__c> mm = [select Id , Host_Name__c From Host_Product_Mapping__c];
        system.assertEquals(2, mm.size());
        insert hpres;
        //After Insert Opportunity line must have 2 dline
        test.stopTest();
        lines = [SELECT Id, Host_Product_Status__c, TotalPrice, UnitPrice, Quantity, Host_Product_Mapping__c FROM OpportunityLineItem where OpportunityId = :  ps_opportunity.Id];
        //When Cannot find in Host Product Mapping will not creat product line items
        system.assertEquals(1, lines.size());        
        mm = [select Id , Host_Name__c From Host_Product_Mapping__c];
        system.assertEquals(3, mm.size(), 'If Host Product Mapping not contain slos product. System must Automatically create to Host Product Mapping');
    }
    //Case 2 Mini Mode 
    @isTest 
    static void test_AutoCreateHostProductMapping(){
        
        insert new Trigger_Msg__c(name = 'Not_Found_Employee_ID', Description__c   = 'description');
        Id prospectAccountId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        // Create New Account
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.Phone = '050111222';
        acct.Mobile_Number_PE__c  = '0801112233';
        acct.ID_Type_PE__c  = 'BRN ID';
        acct.ID_Number_PE__c  = '1510100181964';
        acct.Customer_Type__c = 'Juristic';
        acct.First_name_PE__c = 'TestMock';
        acct.First_Name_ENG_PE__c = 'TestMock';
        acct.Last_name_PE__c = 'TestMock';
        acct.Last_Name_PE_Eng__c  = 'TestMock';
        acct.Account_Type__c = 'Qualified Prospect';
        acct.RecordTypeId = prospectAccountId;
        insert acct;
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'OPP SLS';
        opp.AccountId = acct.Id;
        opp.StageName = 'Analysis';
        //opp.OwnerId  = usr.id;
        opp.CloseDate = Date.today();
        opp.Expected_submit_date__c = Date.today();
        //opp.PriceBook2Id = Pricebook.Id;
        opp.App_Ref_Number__c = 'slsAppRefnumber1';
        insert opp; 
        system.assertEquals(false ,opp.Pending_Mapping_Product__c);

        system.assert(false == SLOSDataset.isActiveTrigger());
        Host_Application_Response__c happRespond = new Host_Application_Response__c();
        happRespond.Actual_Amount__c =  30000;
        happRespond.App_Ref_Number__c  = 'APPREF001';
        happRespond.CRM_ID__c =  'CRMID';
        happRespond.Host_System__c = 'SLS';
        happRespond.Front_End_App_Status__c = 'RM1';
        happRespond.Front_End_App_Result__c = 'Canceled';
        happRespond.Opportunity__c = opp.id;
        insert happRespond;        
        
        List<Host_Product_Mapping__c> mm = [select Id , Host_Name__c From Host_Product_Mapping__c];
        system.assertEquals(2, mm.size());
        
        Host_Product_Response__c hpres = new Host_Product_Response__c();
        
        hpres.App_Ref_Number__c            = happRespond.App_Ref_Number__c;
        hpres.Approved_Amount__c           = 1000;
        hpres.CRM_ID__c                    = happRespond.CRM_ID__c;
        hpres.Host_Name__c                 = 'SLS'; 
        hpres.Host_Application_Response__c = happRespond.Id;
        
        hpres.Host_Product_Program__c      = 'SmartBiz for Construction';
        hpres.Host_Product_Name__c         = 'Loan - Construction';  // ==>  Host_Prod_Name_Credit_Facility__c
        hpres.Host_Product_Group__c        = 'TMB SME SmartBiz';
        hpres.Host_Product_Code__c         = '0003'; 


        SLOSDataset.toggleTrigger(); // Open Trigger
         system.assert(true == SLOSDataset.isActiveTrigger());
        insert hpres;
        //After Insert Opportunity line must have 2 dline



       
        mm = [select Id , Host_Name__c From Host_Product_Mapping__c];
        system.assertEquals(3, mm.size(), 'If Host Product Mapping not contain slos product. System must Automatically create to Host Product Mapping');
        
    }
    @isTest
    static void test_OpportunityWithSelecteProduct() {
        system.debug('HostProductMapping:::test_OpportunityWithSelecteProduct');   
        /**********************************************************
        *   Step 1 ) Setup Data
        **********************************************************/
        createAccountWithOpptAndOppLine();
        
        /**********************************************************
        *   Step 2 ) Manual Insert Host Application Respond
        **********************************************************/
        test.startTest();
        
        opportunity oppTemp = new opportunity(id = ps_opportunity.id, application_status__c = 'RM1', stagename = 'CA-Prep'
                                , Expected_submit_date__c = system.today(), CloseDate = system.today());
        update oppTemp;
        
        Host_Application_Response__c happRespond =  createHostApplicationResponse(ps_opportunity);
        ps_opportunity = [select Id , caid__c, StageName , name , AccountId, App_Ref_Number__c, PriceBook2Id, recordtypeid  from Opportunity where id = : ps_opportunity.id limit 1];
        
        system.debug('::: StageName = ' + ps_opportunity.StageName);
        //system.assertEquals('CA-Prep', ps_opportunity.StageName);
        /**********************************************************
        *   Step 3 ) Manual Insert Host Application Respond
        **********************************************************/
        Host_Product_Response__c hpres = new Host_Product_Response__c();
        
        hpres.App_Ref_Number__c            = happRespond.App_Ref_Number__c;
        hpres.Approved_Amount__c           = 1000;
        hpres.CRM_ID__c                    = happRespond.CRM_ID__c;
        hpres.Host_Name__c                 = 'SLS';
        hpres.Host_Application_Response__c = happRespond.Id;
        
        hpres.Host_Product_Program__c      = 'SmartBiz for Construction';
        hpres.Host_Product_Name__c         = 'Loan - Land';  // ==>  Host_Prod_Name_Credit_Facility__c
        hpres.Host_Product_Group__c        = 'TMB SME SmartBiz';
        hpres.Host_Product_Code__c         = '';
        
        List<OpportunityLineItem> lines = [SELECT Id, Host_Product_Status__c, TotalPrice, UnitPrice, Quantity, Host_Product_Mapping__c FROM OpportunityLineItem where OpportunityId = :  ps_opportunity.Id];
        system.assertEquals(1, lines.size());
        system.assertEquals(true , SLOSDataset.isActiveTrigger() ,'Trigger not Open !!!!');
        insert hpres;
        //After Insert Opportunity line must have 2 dline
        test.stopTest();
        lines = [SELECT Id, Host_Product_Status__c, TotalPrice, UnitPrice, Quantity, Host_Product_Mapping__c FROM OpportunityLineItem where OpportunityId = :  ps_opportunity.Id];
        system.assertEquals(2, lines.size(), 'New Product Line Item Must Create Automatically');
    }
    private static Host_Application_Response__c createHostApplicationResponse(opportunity oppt) {
        // Fix Host_System__c = SLOS and Opportunity_Type__c = Credit
        // Host_Application_Response__c.Front_End_App_Result__c =>  Opportunity_Stage_Mapping__c.Result__c
        // Host_Application_Response__c.Front_End_App_Status__c =>  Opportunity_Stage_Mapping__c.Application_status__c
        
        //Stage must set to Cancelled
        Host_Application_Response__c happRespond = new Host_Application_Response__c();
        happRespond.Actual_Amount__c =  30000;
        happRespond.App_Ref_Number__c  = oppt.App_Ref_Number__c;
        happRespond.CRM_ID__c =  oppt.caid__c;
        happRespond.Host_System__c = 'SLS';
        happRespond.Front_End_App_Status__c = 'RM1';
        happRespond.Front_End_App_Result__c = 'Canceled';
        happRespond.Opportunity__c = oppt.id;
        insert happRespond;
        return happRespond;
    }
    private static void createAccountWithOpptAndOppLine() {
        /**********************************************************
        *   Step 1 ) Setup Data
        **********************************************************/
        User usr = [Select Id , Username  from User where Employee_ID__c = 'SLOS1' limit 1];
        // Get Opportunity SE Credit Product Recordtype
        RecordType seRecordType = [ SELECT Id, IsActive, Name, SobjectType, DeveloperName
                                   FROM RecordType
                                   Where IsActive = true
                                   and SobjectType = 'Opportunity'
                                   and DeveloperName = 'SE_Credit_Product'
                                   limit 1];
                                   
        // Get Account Prospect Recordtype
        Id prospectAccountId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        System.runAs(usr) {
            // Create New Account
            Account acct = new Account();
            acct.Name = 'Test Account';
            acct.Phone = '050111222';
            acct.Mobile_Number_PE__c  = '0801112233';
            acct.ID_Type_PE__c  = 'BRN ID';
            acct.ID_Number_PE__c  = '1510100181964';
            acct.Customer_Type__c = 'Juristic';
            acct.First_name_PE__c = 'TestMock';
            acct.First_Name_ENG_PE__c = 'TestMock';
            acct.Last_name_PE__c = 'TestMock';
            acct.Last_Name_PE_Eng__c  = 'TestMock';
            acct.Account_Type__c = 'Qualified Prospect';
            acct.RecordTypeId = prospectAccountId;
            insert Acct;
            
            //Create Contact for send Email
            Contact cont = new Contact();
            cont.accountid = acct.id;
            cont.Firstname = 'fcont';
            cont.Lastname = 'lcont';
            insert cont;
            
            // Get TMB0002 PriceBook
            Pricebook2 Pricebook = [select Id , Name , TMB_Pricebook__c from Pricebook2 where TMB_Pricebook__c = 'TMB0002' limit 1 ];
            
            SLOSDataset.toggleTrigger(); // turn on trigger
            
            system.assert(SLOSDataset.isActiveTrigger());
            
            // Create New Opportunity
            Opportunity opp = new Opportunity();
            opp.Name = 'OPP SLS';
            opp.AccountId = acct.Id;
            opp.StageName = 'Analysis';
            opp.OwnerId  = usr.id;
            opp.CloseDate = Date.today();
            opp.Expected_submit_date__c = Date.today();
            opp.PriceBook2Id = Pricebook.Id;
            opp.App_Ref_Number__c = 'slsAppRefnumber2';
            opp.Opportunity_Type__c = 'Credit';

            insert opp;
            
            Opportunity oppt1 = [select Id , caid__c, StageName , name , AccountId, App_Ref_Number__c, PriceBook2Id  from Opportunity where id = : opp.id limit 1];
            system.debug('::: CAID = ' + oppt1.caid__c);
            
            ps_opportunity = oppt1;
            // Add Opporttunity Product
            string hostMappingKey = 'SLS|TMB SME SmartBiz|SmartBiz for Construction|Loan - Land';
            Host_Product_Mapping__c sobj = [select Id, UniqueKey__c , Host_Name__c , Host_Product_Group__c, Salesforce_Product__c
                                            From Host_Product_Mapping__c
                                            Where UniqueKey__c = : hostMappingKey  limit 1 ];
            
            System.assert( null != sobj);
            
            PricebookEntry pbrntry = [SELECT Id, Pricebook2Id, Product2Id FROM PricebookEntry Where Product2Id = : sobj.Salesforce_Product__c and  Pricebook2Id = : Pricebook.Id limit 1];
            System.assert( null != pbrntry);
            OpportunityLineItem oppline = new OpportunityLineItem();
            oppline.OpportunityId = opp.Id;
            oppline.PricebookEntryId = pbrntry.Id;
            oppline.UnitPrice = 100;
            oppline.Quantity = 1;
            insert oppline;
        }
    }
}