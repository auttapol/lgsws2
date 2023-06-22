@isTest
public class RetailCSVCustomerChartController_test {
    public static final RecordType ProspectRecordType {
        get{
            if(ProspectRecordType == null){
                ProspectRecordType = [SELECT ID, Name FROM RecordType WHERE Name = 'Retail_Prospect' AND sObjectType='Lead' LIMIT 1];
            }
            return ProspectRecordType;
        }
        set;
    }
    
    @testSetup static void setup() {
        TestUtils.createAppConfig();
        
        List<AppConfig__c> mc = new List<AppConfig__c> ();
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        insert mc;
        Product2 pd2 = new Product2(Name = 'Test Product', Sub_Family__c = 'test resouce', ProductCode = '0200', RTL_PRODUCT_CODE__c = '0200');
        insert pd2;
        Branch_and_Zone__c BaZ = new Branch_and_Zone__c(Name = 'IIG', Branch_Code__c = '123');
        insert BaZ;
    }
    
    @isTest static void test_getCheckData () {
        List<Account> accList = RTL_TestUtility.createAccounts(2, true);
        User testUser = RTL_TestUtility.createRetailTestUser(true);
        accList.get(1).Account_Type__c = 'Retail Prospect';
        system.debug(accList.get(0) +''+ accList.get(1));
        //insert accList.get(1);
        RetailCSVCustomerChartController.fetchAccount(accList.get(0).Id);
        RetailCSVCustomerChartController.getProduct2SubFamily('');
        RetailCSVCustomerChartController.getProduct2SubFamily('0200');
        Branch_and_Zone__c branch123 = RetailCSVCustomerChartController.getBranch('123');
        RetailCSVCustomerChartController.getBranchFromID(branch123.Id);
        Account accQM_A = RetailCSVCustomerChartController.getAccountForCheckQM_A(accList.get(0).Id);
        RetailCSVCustomerChartController.dataCheckQM_A(accQM_A);
        RetailCSVCustomerChartController.getRemark('0200');
        Account accQM_ARetail = RetailCSVCustomerChartController.getAccountForCheckQM_A(accList.get(1).Id);
        RetailCSVCustomerChartController.dataCheckQM_A(accList.get(1));
        RetailCSVCustomerChartController.getUser(testUser.Id);
    }
    
    @isTest static void Test_GetService07 () {
        List<Account> accList = RTL_TestUtility.createAccounts(1, true);
        Test.startTest();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
        String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;
        List<Integer> usagePercent = RetailCSVCustomerChartController.getUsagePercentageData(accList.get(0).Id, accList.get(0));
        Test.stopTest();
        List<Integer> usagePercent2 = RetailCSVCustomerChartController.getUsagePercentageData(accList.get(0).Id, accList.get(0));
    }
    
    @isTest static void Test_GetCVSObject () {
        List<Account> accList = RTL_TestUtility.createAccounts(1, true);
        accList.get(0).TMB_Customer_ID_PE__c = '001100000000000000000000051187';
        Test.startTest();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
        String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;
        Object CVSObject = RetailCSVCustomerChartController.getCVSObject(accList.get(0).Id, accList.get(0));
        Test.stopTest();
    }
    
    @isTest static void Test_GetCVSObject2 () {
        List<Account> accList = RTL_TestUtility.createAccounts(1, true);
        accList.get(0).TMB_Customer_ID_PE__c = '001100000000000000000000051187';
        Test.startTest();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
        String prdName = RetailCSVCustomerChartController.getProduct2NameFromRTLProductCODE('0200');
        String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;
        Object CVSObject = RetailCSVCustomerChartController.getCVSObject2(accList.get(0).Id, accList.get(0));
        Test.stopTest();
    }

    @isTest static void Test_getUsagePercentageRes () {
        List<Account> accList = RTL_TestUtility.createAccounts(1, true);
        accList.get(0).TMB_Customer_ID_PE__c = '001100000000000000000000051187';
        Test.startTest();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
        String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;
        Object CVSObject = RetailCSVCustomerChartController.getUsagePercentageRes(accList.get(0).Id, accList.get(0));
        Test.stopTest();
    }
    
}