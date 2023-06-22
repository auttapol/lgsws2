@isTest
public with sharing class ProductingUnmaskingSetupTest {
    @isTest
    public static void ProductingUnmaskingSetupTest() {
        Test.startTest();
        String data = RTL_ProductHoldingsLightningUtil.getUnmaskBalance();
        String data2 = CommercialAutoLoanController.getUnmaskBalance();
        System.assertEquals(data, data2);
        Test.stopTest();
    }
}