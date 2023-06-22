@isTest
public with sharing class RTL_Product2TriggerHandlerTest {
    public static testMethod void product2SyncTest(){
    	Test.startTest();
    	
    	//1st test case, insert a new retail Product2, check if Retail Product Master is auto created
		List<Product2> product2List = RTL_TestUtility.createRetailProduct2(1, true);
		//Check if Product2 is created
		Integer product2Count = [select count() from product2];
		System.assertEquals(1, product2Count);
		Product2 product2 = [select SF_Product_Key__c from Product2 where id = : product2List[0].Id];
		//Check if Retail Product Master is created
		Integer retailProductCount = [select count() from RTL_product_master__c where Product_Code__c =:product2.SF_Product_Key__c];
		System.assertEquals(1, retailProductCount);		
    	
    	//2nd test case, update the name of existing retail Product2, check if the name of Retail Product Master is auto updated
		//Check if Retail Product Master name is updated
		Integer beforeUpdateCount = [select count() from RTL_product_master__c where RTL_Product2_Name__c = 'new product name'];
		System.assertEquals(0, beforeUpdateCount);		    	
    	Product2 productObj = product2List[0];
    	productObj.Name = 'new product name';
    	update productObj;
		//Check if Retail Product Master name is updated
		Integer afterUpdateCount = [select count() from RTL_product_master__c where RTL_Product2_Name__c = 'new product name'];
		System.assertEquals(1, afterUpdateCount);
		
		//3nd test case, update the product code of existing retail Product2, 
		//check if the Retail Product Master with old product code is deleted 
		//and Retail Product Master with new product code is inserted
		//Check if Retail Product Master with new product code is created
		beforeUpdateCount = [select count() from RTL_product_master__c where Product_Code__c = 'new product code'];
		System.assertEquals(0, beforeUpdateCount);
    	productObj.SF_Product_Key__c = 'new product code';
    	update productObj;		
		//Check if Retail Product Master with new product code is created
		Integer newProductCodeCount = [select count() from RTL_product_master__c where Product_Code__c = 'new product code'];
		System.assertEquals(1, newProductCodeCount);		
		//Check if Retail Product Master with old product code is deleted
		Integer oldProductCodeCount = [select count() from RTL_product_master__c where Product_Code__c like 'product code%'];
		System.assertEquals(0, oldProductCodeCount);		
    	Test.stopTest();    	
    }
}