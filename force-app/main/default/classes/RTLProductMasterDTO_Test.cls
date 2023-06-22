@isTest
public without sharing class RTLProductMasterDTO_Test {

    @isTest
    private static void Test_RTLProductMasterDTO() {
        Product2 prod2 = new Product2();
        prod2.Name = 'test';
        prod2.RTL_Product_Code__c = '';
        insert prod2;
        RTLProductMasterDTO RTLProdMaster = new RTLProductMasterDTO(prod2);
    }
}