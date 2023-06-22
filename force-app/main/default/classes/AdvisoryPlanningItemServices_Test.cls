@isTest
public without sharing class AdvisoryPlanningItemServices_Test {
    
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

        String authorized = '{'+
            '"access_token": "eyJ0eXBlIjoiSldUIiwiYWxnIjoiUlM1MTIifQ.eyJhcGlfa2V5IjoiYWRtaW4iLCJzY29wZSI6InJlYWQgd3JpdGUiLCJleHAiOjE1NDY4NTg3MzUsInZlcnNpb24iOiIwMDEtMjAxODExMTEiLCJqdGkiOiIyYTQ4ZmEwYi0yMjEyLTRlMzItYTAzMC1mOWFlMmRkYWFlOTQifQ.HcK3lexOKd-ufV0adiIsKWfHzG34D606gFwFbABC-5QFKpUoLus_xq_DPPttpqj7VQB_cYIqaoFEI0HkD2rbTjXuhDDcbcpvkkaLO6DpGYfXi5RYgk7MQq7BPhgq_CVts4p4zUsLnae-c5s3cd5zC08qkNjOVMGlgNli1DZekCFa5vHdrXHICu7ih_CVV6QLLYnyhrN5-STSasxOaNqlZ5v69q0aADP69wyj2NL1SVdCoG8aPlm0ILSjKIM8lj9RsZ23Xs1LUlMGpYNqjhHEI2BDQazuW-VFz_lXi6q_84uM4XvU1bMV6TJxuVXLYjtpaY4Y2wBQJMICvfbIGN-mOg",'+
            '"token_type": "bearer",'+
            '"expires_in": 3600,'+
            '"scope": "read write",'+
            '"jti": "2a48fa0b-2212-4e32-a030-f9ae2ddaae94",'+
            '"client_id": "xxxxx",'+
            '"version": "001-20181111",'+
            '"isSuccess": true,'+
            '"errorMessage": "",'+
            '"requestBody": "",'+
            '"responseBody": ""'+
        '}';
        
        AuthenticationToken authenTokenCalculateTools = AuthenticationToken.parse(authorized);
        Datetime startTime = Datetime.now();
        Datetime endTime = Datetime.now();
        Cache.OrgPartition orgPartSmartBDMCalToolsCreateToken = Cache.Org.getPartition('local.CreateGateWayToken');
        orgPartSmartBDMCalToolsCreateToken.put('accesstoken', authenTokenCalculateTools.access_token, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('SmartBDMEnliteToken', authenTokenCalculateTools.access_token, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('tokentype', authenTokenCalculateTools.token_type, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('expiresin', authenTokenCalculateTools.expires_in, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('scope', authenTokenCalculateTools.scope, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('jti', authenTokenCalculateTools.jti, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('clientid', authenTokenCalculateTools.client_id, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('version', authenTokenCalculateTools.version, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('isSuccess', authenTokenCalculateTools.isSuccess, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('errorMessage', authenTokenCalculateTools.errorMessage, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('requestBody', authenTokenCalculateTools.requestBody, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('responseBody', authenTokenCalculateTools.responseBody, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('startTime', Datetime.now(), Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('endtime', Datetime.now(), Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);

        OnlineServiceLog onlineServiceLogGateWay = new OnlineServiceLog(authenTokenCalculateTools.isSuccess, authenTokenCalculateTools.errorMessage, authenTokenCalculateTools.requestBody, authenTokenCalculateTools.responseBody, startTime, endTime);
        orgPartSmartBDMCalToolsCreateToken.put('onlineServiceLogGateWay', onlineServiceLogGateWay.parseToJson(), authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
    }


    @isTest
    private static void Test_getAdvisoryPlanningItems() {
        Advisory_Planning__c planning = [SELECT Id FROM Advisory_Planning__c LIMIT 1];
        Test.startTest();
            AdvisoryPlanningItemServices.getAdvisoryPlanningItems(planning.Id, 'Return');
       		AdvisoryPlanningItemServices.getAdvisoryPlanningItems('', '');
        Test.stopTest();
    }

    @isTest
    private static void Test_getColumnByFieldSet() {
        Test.startTest();
            AdvisoryPlanningItemServices.getColumnByFieldSet('Advisory_Planning_Item__c', 'List_Return');
        	AdvisoryPlanningItemServices.getColumnByFieldSet('', '');
        Test.stopTest();
    }

    @isTest
    private static void Test_getAppConfigMdtByKey() {
        Test.startTest();
            AdvisoryPlanningItemServices.getAppConfigMdtByKey('CoreHP_Company');
        Test.stopTest();
    }


    @isTest
    private static void Test_getRedProductcode() {
        Test.startTest();
            AdvisoryPlanningItemServices.getRedProductcode();
        Test.stopTest();
    }

    @isTest
    private static void Test_getALDXWFMdt() {
        Test.startTest();
            AdvisoryPlanningItemServices.getALDXWFMdt();
        Test.stopTest();
    }

    @isTest
    private static void Test_createAdvisoryPlanningItemHolding() {
        Advisory_Planning__c planning = [SELECT Id FROM Advisory_Planning__c LIMIT 1];
        Product2 eachProduct = [SELECT Id,RTL_Product_Name_ENG__c,ProductCode, Sub_Family__c FROM Product2 LIMIT 1];

        Test.startTest();
            List<AdvisoryPlanningItemServices.ProductHolding> planningItemWrapperList = new List<AdvisoryPlanningItemServices.ProductHolding>();
            AdvisoryPlanningItemServices.ProductHolding eachHolding = new AdvisoryPlanningItemServices.ProductHolding();
            eachHolding.itemType        = 'Return';
            eachHolding.family          = 'INVESTMENT';
            eachHolding.subGroup        = 'test';
            eachHolding.productName     = 'test';
            eachHolding.productCode     = 'JBPLTF2';
            eachHolding.baselineAmount      = 10000;
            eachHolding.baselineAllocation  = 1;
            eachHolding.targetAmount        = 20000;
            eachHolding.targetAllocation    = 1;
            planningItemWrapperList.add(eachHolding);
            AdvisoryPlanningItemServices.createAdvisoryPlanningItemHolding(planning.Id, true, planningItemWrapperList);
        
         	AdvisoryPlanningItemServices.createAdvisoryPlanningItemHolding('', true, planningItemWrapperList);
        Test.stopTest();
    }

    @isTest
    private static void Test_getProduct() {
        Account eachAccount = [SELECT Id, TMB_Customer_ID_PE__c FROM Account LIMIT 1];
        Test.startTest();
            AdvisoryPlanningItemServices.getProduct('callout:OSC01', 'advisory_callbackOSC01', '', eachAccount.TMB_Customer_ID_PE__c);
        Test.stopTest();
    }

    @isTest
    private static void Test_getAutoLoanProduct() {
        Account eachAccount = [SELECT Id, TMB_Customer_ID_PE__c FROM Account LIMIT 1];
        Test.startTest();
            try{
                AdvisoryPlanningItemServices.getAutoLoanProduct('callout:AutoLoan_HpFleetHpList', 'advisory_callbackAutoLoan', '', 'CoreHP', '');
            }catch(Exception ex){

            }
            
        Test.stopTest();
    }

    @isTest
    private static void Test_advisory_callbackOSC01() {
        Account eachAccount = [SELECT Id, TMB_Customer_ID_PE__c FROM Account LIMIT 1];
        Test.startTest();
            try{
                AdvisoryPlanningItemServices.advisory_callbackOSC01(new List<String>(), new Map<String, Object>{
                    'isEmployee' => true,
                    'body' => '',
                    'StartTime' => (Datetime)Datetime.now(),
                    'RMID' => eachAccount.TMB_Customer_ID_PE__c,
                    'Account' => eachAccount
                });
            }catch(Exception ex){}
            
        Test.stopTest();
    }

    @isTest
    private static void Test_advisory_callbackOSC02() {
        Account eachAccount = [SELECT Id, TMB_Customer_ID_PE__c FROM Account LIMIT 1];
        Test.startTest();
            try{
                AdvisoryPlanningItemServices.advisory_callbackOSC02(new List<String>(), new Map<String, Object>{
                    'isEmployee' => true,
                    'body' => '',
                    'StartTime' => (Datetime)Datetime.now(),
                    'RMID' => eachAccount.TMB_Customer_ID_PE__c,
                    'Account' => eachAccount
                });
            }catch(Exception ex){}
            
        Test.stopTest();
    }

    @isTest
    private static void Test_advisory_callbackOSC04() {
        Account eachAccount = [SELECT Id, TMB_Customer_ID_PE__c FROM Account LIMIT 1];
        Test.startTest();
            try{
                AdvisoryPlanningItemServices.advisory_callbackOSC04(new List<String>(), new Map<String, Object>{
                    'isEmployee' => true,
                    'body' => '',
                    'StartTime' => (Datetime)Datetime.now(),
                    'RMID' => eachAccount.TMB_Customer_ID_PE__c,
                    'Account' => eachAccount
                });
            }catch(Exception ex){}
            
        Test.stopTest();
    }

    @isTest
    private static void Test_advisory_callbackOSC05() {
        Account eachAccount = [SELECT Id, TMB_Customer_ID_PE__c FROM Account LIMIT 1];
        Test.startTest();
            try{
                AdvisoryPlanningItemServices.advisory_callbackOSC05(new List<String>(), new Map<String, Object>{
                    'isEmployee' => true,
                    'body' => '',
                    'StartTime' => (Datetime)Datetime.now(),
                    'RMID' => eachAccount.TMB_Customer_ID_PE__c,
                    'Account' => eachAccount
                });
            }catch(Exception ex){}
            
        Test.stopTest();
    }

    @isTest
    private static void Test_advisory_callbackOSC06List() {
        Account eachAccount = [SELECT Id, TMB_Customer_ID_PE__c FROM Account LIMIT 1];
        Test.startTest();
            try{
                AdvisoryPlanningItemServices.advisory_callbackOSC06List(new List<String>(), new Map<String, Object>{
                    'isEmployee' => true,
                    'body' => '',
                    'StartTime' => (Datetime)Datetime.now(),
                    'RMID' => eachAccount.TMB_Customer_ID_PE__c,
                    'Account' => eachAccount
                });
            }catch(Exception ex){}
            
        Test.stopTest();
    }

    @isTest
    private static void Test_advisory_callbackHpFleetHpDetail() {
        Account eachAccount = [SELECT Id, TMB_Customer_ID_PE__c FROM Account LIMIT 1];
        Test.startTest();
            try{
                AdvisoryPlanningItemServices.advisory_callbackHpFleetHpDetail(new List<String>(), new Map<String, Object>{
                    'isEmployee' => true,
                    'body' => '',
                    'StartTime' => (Datetime)Datetime.now(),
                    'RMID' => eachAccount.TMB_Customer_ID_PE__c,
                    'Account' => eachAccount
                });
            }catch(Exception ex){}
            
        Test.stopTest();
    }

    @isTest
    private static void Test_advisory_callbackAutoLoan() {
        Account eachAccount = [SELECT Id, TMB_Customer_ID_PE__c FROM Account LIMIT 1];
        Test.startTest();
            try{
                AdvisoryPlanningItemServices.advisory_callbackAutoLoan(new List<String>(), new Map<String, Object>{
                    'isEmployee' => true,
                    'body' => '',
                    'StartTime' => (Datetime)Datetime.now(),
                    'RMID' => eachAccount.TMB_Customer_ID_PE__c,
                    'Account' => eachAccount
                });
            }catch(Exception ex){}
        Test.stopTest();
    }
}