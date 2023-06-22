@isTest
public class SLOSDataset {
    public static Pricebook2 Pricebook;
    public static void DataSet1() {
        //get time stamp uniq value
        DateTime dateTimeNow = dateTime.now();
        String unixTime = '' + dateTimeNow.getTime() / 1000;
        //SE Profile
        Profile seProfile = ServiceTestUtils.getProfileByName(ServiceTestUtils.EProfile.TMBSegmentHead);
        User seUser       = ServiceTestUtils.createUsers(1, 1, 'tmbfnam', 'tmblname', 'slostmb' + unixTime + '@tmbbank.com', seProfile.Id, true, false) [0];
        seUser.Employee_ID__c = 'SLOS1';
        insert seUser;
        TestUtils.createStatusCode();
        TestUtils.CreateTriggerMsg();
        TestUtils.createAppConfig();
        createProduct2();
        system.debug('Context:::SLOSDataset | PriceBook:::' + Pricebook.id );
        createOpportunityStageMapping();

    }

    public static void createOpportunityStageMapping() {
        List<Opportunity_Stage_Mapping__c> mm = new List<Opportunity_Stage_Mapping__c>();
        Opportunity_Stage_Mapping__c m1 = new Opportunity_Stage_Mapping__c();
        m1.Name ='SLS1';
        m1.Host_System__c           = 'SLS';
        m1.Application_status__c    = 'OPC';
        m1.Opportunity_Type__c      = 'Credit';
        m1.Result__c                = 'Cancelled';
        m1.Stage__c                 = 'Cancelled';
        mm.add(m1);
        Opportunity_Stage_Mapping__c m2 = new Opportunity_Stage_Mapping__c();
        m2.Name ='SLS2';
        m2.Host_System__c           = 'SLS';
        m2.Opportunity_Type__c      = 'Credit';
        m2.Application_status__c    = 'RM1';      //****        
        m2.Result__c                = 'Cancelled';//****
        m2.Stage__c                 = 'Post Approval';
        mm.add(m2);
        Opportunity_Stage_Mapping__c m3 = new Opportunity_Stage_Mapping__c();
        m3.Name ='SLS3';
        m3.Host_System__c           = 'SLS';
        m3.Application_status__c    = '';
        m3.Opportunity_Type__c      = 'Credit';
        m3.Result__c                = 'Completed';
        m3.Stage__c                 = 'Set Up';
        mm.add(m3);
        insert mm;

    }

    public static void createProduct2() {
        // Step 1) Create Pricebook
        testUtils.CreateProceBook();
        Pricebook = [select Id , Name , Description from Pricebook2 where TMB_Pricebook__c = 'TMB0002' limit 1 ];
        List<Product2> prods = createProduct(250, true);
        Id pricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> priceEntryStandard = TestUtils.createPricebookEntry(250, pricebookId, prods, true);
        //Uniq by product name  >> prod.Name = 'PROD'+1;
        List<PricebookEntry> priceEntrySe = TestUtils.createPricebookEntry(250, Pricebook.Id, prods, true);
        create2HostProductMapping(prods);
    }
    public static List<Product2> createProduct(Integer size , Boolean doInsert) {
        List<Product2> ProductToCreate = new List<Product2>();
        for (Integer i = 0 ; i < size ; i++) {
            Product2 prod = new Product2();
            prod.Name = 'PROD' + i;
            prod.Product_Domain__c = '1. Transactional Banking';
            prod.IsActive = true;
            prod.Family = 'Credit Product';
            prod.ProductCode = '12345678';
            ProductToCreate.add(prod);
        }
        if (doInsert) {
            insert ProductToCreate;
        }
        return ProductToCreate;
    }
    public static void create2HostProductMapping(List<Product2> prods) {

        Host_Product_Mapping__c sobj = new Host_Product_Mapping__c(
            Host_Name__c = 'SLS',                                        // Host Name
            Host_Product_Group__c = 'TMB SME SmartBiz',                   // Host Product Group
            Salesforce_Product__c = prods[0].Id,                          // Salesforce Product
            Product_Program__c = 'SmartBiz for Construction',                      // Host Product Program
            Host_Prod_Name_Credit_Facility__c = 'Loan - Land'   // Host Prod Name/Credit Facility
        );
        insert sobj;
        Host_Product_Mapping__c sobj2 = new Host_Product_Mapping__c(
            Host_Name__c = 'SLS',                                          // Host Name
            Host_Product_Group__c = 'TMB SME SmartBiz',                     // Host Product Group
            Salesforce_Product__c = prods[1].Id   ,                         // Salesforce Product
            Product_Program__c = 'TMB SME SmartBiz',                        // Host Product Program
            Host_Prod_Name_Credit_Facility__c = 'L/G Utility'               // Host Prod Name/Credit Facility
        );
        insert sobj2;
    }

    public static void toggleTrigger() {
        AppConfig__c tg = AppConfig__c.getValues('runtrigger');
        if (null != tg) {
            if ( tg.Value__c == 'true') tg.Value__c = 'false';
            else  tg.Value__c = 'true';


            update tg;
            system.debug('Toggle Trigger to ' + tg.Value__c);
        }
    }

    public static boolean isActiveTrigger() {
        AppConfig__c tg = AppConfig__c.getValues('runtrigger');
        if (null != tg ) {
            if (tg.Value__c == 'true') return true;
        }
        return false;
    }
}