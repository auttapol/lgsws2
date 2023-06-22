@isTest
public without sharing class AdvisoryPlanningEditAllocServices_Test {

    @testSetup 
    static void setup() {
        TestUtils.createAppConfig();

        List<AppConfig__c> mc = new List<AppConfig__c> ();
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        insert mc;

        RMC_AppConfig__c appConfig = new RMC_AppConfig__c();
        appConfig.RMC_Latest_Update_of_MF_Return__c = DateTime.now();
        insert appConfig;

        List<Account> acct = TestUtils.createAccounts(1, 'Fname', 'Individual', false);
        acct[0].TMB_Customer_ID_PE__c = '001100000000000000000000000500';
        acct[0].RTL_Wealth_RM__c = UserInfo.getUserId();
        insert acct;

        Advisory_Planning__c planning = new Advisory_Planning__c(
            Advisory_Planning_Name__c = 'test planning',
            Baseline_Advisory_Planning_Date__c = Date.today(),
            Is_Sync_Product_Holding__c = true,
            Target_Advisory_Planning_Date__c = Date.today().addDays(30),
            Customer__c = acct[0].Id
        );
        insert  planning;

        List<Product2> productList = new List<Product2>();
        Product2 prod1 = new Product2(
            Name = 'Test Product 1',
            Product_Domain__c = '1. Transactional Banking',
            RTL_Product_Name_ENG__c = 'Test Product EN 1',
            RTL_Product_Name_TH__c = 'Test Product TH 1',
            Sub_Family__c = 'Non',
            IsActive = true,
            Family = 'INVESTMENT',
            ProductCode = 'JBPLTF1',
            RMC_1Year_Return__c = 12.021,
            RMC_Latest_Update_of_MF_Return__c = DateTime.now(),
            RTL_Asset_Class__c = 'FF'
        );
        productList.add(prod1);

        Product2 prod2 = new Product2(
            Name = 'Test Product 2',
            RTL_Product_Name_ENG__c = 'Test Product EN 2',
            RTL_Product_Name_TH__c = 'Test Product TH 2',
            Sub_Family__c = 'Non',
            Product_Domain__c = '1. Transactional Banking',
            IsActive = true,
            Family = 'INVESTMENT',
            ProductCode = 'JBPLTF2',
            RTL_Asset_Class__c = 'FF',
            RMC_1Year_Return__c = 12.021,
            RMC_Latest_Update_of_MF_Return__c = DateTime.now()
        );
        productList.add(prod2);

        insert productList;

        List<Advisory_Planning_Item__c> itemList  =  new List<Advisory_Planning_Item__c>();

        Product2 eachProduct = productList.get(0);
        Advisory_Planning_Item__c eachPlanningItem = new Advisory_Planning_Item__c(
            Name = 'Test',
            Advisory_Planning__c = planning.Id,
            Advisory_Item_Type__c = 'Return',
            Is_Product_Holding__c = false,
            Product_Group__c      = 'INVESTMENT',
            Baseline_Amount__c    = 5000,
            Baseline_Allocation__c    = 1,
            Target_Amount__c    = 100000,
            Target_Allocation__c    = 1,
            Product_Master__c = eachProduct.Id ,
            Product_Name__c = eachProduct.RTL_Product_Name_ENG__c,
            Product_Holding_Code__c = eachProduct.ProductCode,
            Product_Sub_Group_Asset_Class__c =  eachProduct.Sub_Family__c
        );
        itemList.add(eachPlanningItem);

        Advisory_Planning_Item__c eachBond = new Advisory_Planning_Item__c(
            Name = 'Test Bond',
            Advisory_Planning__c = planning.Id,
            Advisory_Item_Type__c = 'Return',
            Is_Product_Holding__c = false,
            Product_Group__c      = 'Bond',
            Baseline_Amount__c    = 5000,
            Baseline_Allocation__c    = 1,
            Target_Amount__c    = 100000,
            Target_Allocation__c    = 1,
            Product_Master__c = null ,
            Product_Name__c =  'test bond',
            Product_Holding_Code__c = 'test bond code',
            Product_Sub_Group_Asset_Class__c =  'Debenture'
        );
        itemList.add(eachBond);
        insert itemList;
    }

    @isTest
    private static void Test_getProductInformation_Keyword1() {
        Product2 eachProduct = [SELECT Id FROM Product2 LIMIT 1];

        Test.startTest();
            List<String> existingProduuctIdSet  = new List<String>();
            existingProduuctIdSet.add(eachProduct.Id);

            List<String> productFamilySet = new List<String>();
            productFamilySet.add('INVESTMENT');

            AdvisoryPlanningEditAllocationServices.ProductSearchCriteria criteria = new AdvisoryPlanningEditAllocationServices.ProductSearchCriteria();
            criteria.productFamily = productFamilySet;
            criteria.keyword1 = 'Product TH';
            criteria.keyword2 = 'Product EN';
            criteria.keyword3 = 'Non';
            criteria.existingProduuctIdSet = existingProduuctIdSet;
            criteria.maxReturnRow = 50;
            AdvisoryPlanningEditAllocationServices.getProductInformation(criteria);
        Test.stopTest();

    }

    @isTest
    private static void Test_getProductInformation_Keyword2() {
        Product2 eachProduct = [SELECT Id FROM Product2 LIMIT 1];

        Test.startTest();
            List<String> existingProduuctIdSet  = new List<String>();
            existingProduuctIdSet.add(eachProduct.Id);

            List<String> productFamilySet = new List<String>();
            productFamilySet.add('INVESTMENT');

            AdvisoryPlanningEditAllocationServices.ProductSearchCriteria criteria = new AdvisoryPlanningEditAllocationServices.ProductSearchCriteria();
            criteria.productFamily = productFamilySet;
            criteria.keyword1 = 'Product EN';
            criteria.keyword2 = 'Product TH';
            criteria.keyword3 = 'Non';
            criteria.existingProduuctIdSet = existingProduuctIdSet;
            criteria.maxReturnRow = 50;
            AdvisoryPlanningEditAllocationServices.getProductInformation(criteria);
        Test.stopTest();

    }

    @isTest
    private static void Test_getProductInformation_Keyword3() {
        Product2 eachProduct = [SELECT Id FROM Product2 LIMIT 1];

        Test.startTest();
            List<String> existingProduuctIdSet  = new List<String>();
            existingProduuctIdSet.add(eachProduct.Id);

            List<String> productFamilySet = new List<String>();
            productFamilySet.add('INVESTMENT');

            AdvisoryPlanningEditAllocationServices.ProductSearchCriteria criteria = new AdvisoryPlanningEditAllocationServices.ProductSearchCriteria();
            criteria.productFamily = productFamilySet;
            criteria.keyword1 = 'Product EN';
            criteria.keyword2 = 'Non';
            criteria.keyword3 = 'Product TH';
            criteria.existingProduuctIdSet = existingProduuctIdSet;
            criteria.maxReturnRow = 50;
            AdvisoryPlanningEditAllocationServices.getProductInformation(criteria);
        Test.stopTest();

    }


    @isTest
    private static void Test_saveAdvisoryPlanningItem_Blank() {
        Test.startTest();
            List<Advisory_Planning_Item__c> itemList  =  new List<Advisory_Planning_Item__c>();
            AdvisoryPlanningEditAllocationServices.saveAdvisoryPlanningItem(null, itemList, null);
        Test.stopTest();

    }

    @isTest
    private static void Test_saveAdvisoryPlanningItem() {
        Advisory_Planning__c planning = [SELECT Id FROM Advisory_Planning__c LIMIT 1];
        Product2 eachProduct = [SELECT Id,RTL_Product_Name_ENG__c,ProductCode, Sub_Family__c FROM Product2 LIMIT 1];
        List<Advisory_Planning_Item__c> existingItemList =  [SELECT Id,Advisory_Item_Type__c,Product_Group__c,Target_Allocation__c,Target_Amount__c,Baseline_Allocation__c,Advisory_Planning__c
                                                             FROM Advisory_Planning_Item__c];
        Advisory_Planning_Item__c existingItem = existingItemList.get(0);
        existingItem.Target_Amount__c = 2000000;

        Test.startTest();
            List<Advisory_Planning_Item__c> itemList  =  new List<Advisory_Planning_Item__c>();

            Advisory_Planning_Item__c eachPlanningItem = new Advisory_Planning_Item__c(
                Name = 'Test',
                Advisory_Planning__c = planning.Id,
                Advisory_Item_Type__c = 'Return',
                Is_Product_Holding__c = false,
                Product_Group__c      = 'INVESTMENT',
                Baseline_Amount__c    = 5000,
                Baseline_Allocation__c    = 1,
                Target_Amount__c    = 100000,
                Target_Allocation__c    = 1,
                Product_Master__c = eachProduct.Id ,
                Product_Name__c = eachProduct.RTL_Product_Name_ENG__c,
                Product_Holding_Code__c = eachProduct.ProductCode,
                Product_Sub_Group_Asset_Class__c =  eachProduct.Sub_Family__c
            );
            itemList.add(eachPlanningItem);

            Advisory_Planning_Item__c eachBond = new Advisory_Planning_Item__c(
                Name = 'Test Bond',
                Advisory_Planning__c = planning.Id,
                Advisory_Item_Type__c = 'Return',
                Is_Product_Holding__c = false,
                Product_Group__c      = 'Bond',
                Baseline_Amount__c    = 5000,
                Baseline_Allocation__c    = 1,
                Target_Amount__c    = 100000,
                Target_Allocation__c    = 1,
                Product_Master__c = null ,
                Product_Name__c =  'test bond',
                Product_Holding_Code__c = 'test bond code',
                Product_Sub_Group_Asset_Class__c =  'Debenture'
            );
            itemList.add(eachBond);
            itemList.add(existingItem);
            itemList.add(existingItemList.get(1));

            AdvisoryPlanningEditAllocationServices.saveAdvisoryPlanningItem(planning.Id, itemList, null);
        Test.stopTest();

    }

    @isTest
    private static void Test_saveAdvisoryPlanningItemWithDelete() {
        Advisory_Planning__c planning = [SELECT Id FROM Advisory_Planning__c LIMIT 1];
        Product2 eachProduct = [SELECT Id,RTL_Product_Name_ENG__c,ProductCode, Sub_Family__c FROM Product2 LIMIT 1];
        List<Advisory_Planning_Item__c> existingItemList =  [SELECT Id FROM Advisory_Planning_Item__c LIMIT 1];
        List<String> toDeleteList = new List<String>();
        toDeleteList.add(existingItemList[0].Id);

        Test.startTest();
            List<Advisory_Planning_Item__c> itemList  =  new List<Advisory_Planning_Item__c>();

            Advisory_Planning_Item__c eachPlanningItem = new Advisory_Planning_Item__c(
                Name = 'Test',
                Advisory_Planning__c = planning.Id,
                Advisory_Item_Type__c = 'Return',
                Is_Product_Holding__c = false,
                Product_Group__c      = 'INVESTMENT',
                Baseline_Amount__c    = 5000,
                Baseline_Allocation__c    = 1,
                Target_Amount__c    = 100000,
                Target_Allocation__c    = 1,
                Product_Master__c = eachProduct.Id ,
                Product_Name__c = eachProduct.RTL_Product_Name_ENG__c,
                Product_Holding_Code__c = eachProduct.ProductCode,
                Product_Sub_Group_Asset_Class__c =  eachProduct.Sub_Family__c
            );
            itemList.add(eachPlanningItem);

            Advisory_Planning_Item__c eachBond = new Advisory_Planning_Item__c(
                Name = 'Test Bond',
                Advisory_Planning__c = planning.Id,
                Advisory_Item_Type__c = 'Return',
                Is_Product_Holding__c = false,
                Product_Group__c      = 'Bond',
                Baseline_Amount__c    = 5000,
                Baseline_Allocation__c    = 1,
                Target_Amount__c    = 100000,
                Target_Allocation__c    = 1,
                Product_Master__c = null ,
                Product_Name__c =  'test bond',
                Product_Holding_Code__c = 'test bond code',
                Product_Sub_Group_Asset_Class__c =  'Debenture'
            );
            itemList.add(eachBond);

            AdvisoryPlanningEditAllocationServices.saveAdvisoryPlanningItem(planning.Id, itemList, toDeleteList);
        Test.stopTest();

    }
}