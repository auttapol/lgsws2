@isTest
public with sharing class RTL_NBOServiceTest {
    static {
        TestUtils.createAppConfig();
        
        //Add for Test NBO to CXM
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'CXM_SERVICE_CONNECTOR';
        Aconfig.Value__c = 'true';        
        apps.add(Aconfig);
        insert apps;
        TestUtils.prepareIntegrationMapping();
        TestUtils.prepareEIMmaps();
    } 
    	
    public static testMethod void nboValidationTest(){
        System.debug(':::: nboValidationTest Start ::::');
    
        TEST.startTest();
        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        System.runAs(retailUser) {
            List<Account> accountList = RTL_TestUtility.createAccounts(1,true); 
            Id acctId = accountList[0].Id;        	          
            //create retail master product
            RTL_TestUtility.createRetailMasterProducts2(true);
            //create NBO History as existing one
			RTL_TestUtility.createNBOHistoryAndProduct(1, acctId, true);            
    		Map<RTL_NBOService.NBOHistory, List<RTL_NBOService.NBOHistoryProduct>> nboMap = RTL_TestUtility.createNBOMap(acctId);
			RTL_NBOService.validateNBO(acctId, retailUser, nboMap);
		    Set<String> nboExtIdList = new Set<String>();
		    for (RTL_NBOService.NBOHistory nbo : nboMap.keySet()){
				nboExtIdList.add(nbo.RTL_NBO_ID);
		    }        
        	List<RTL_NBO_History__c> nboMapValidated = [select RTL_NBO_ID__c, RTL_Campaign_Name__c, RTL_Campaign_Code__c, RTL_NBO_Group__c,
        											RTL_NBO_SubGroup__c, RTL_Valid_From__c, RTL_Valid_To__c, 
													RTL_Contact_Date__c, 
        											RTL_Channel__c, 
        											RTL_Status__c, 
        											RTL_Number_of_Products__c, RTL_Number_of_Invalid_NBO__c 
        											from RTL_NBO_History__c 
        											where RTL_NBO_ID__c in : nboExtIdList and (RTL_valid_to__c = null or RTL_valid_to__c > TODAY) and RTL_Status__c != : RTL_Utility.NBO_STATUS_INVALID and RTL_Status__c != : RTL_Utility.NBO_STATUS_ACCEPTEDALL and RTL_Customer_Name__c = :acctId];					
    		System.assertEquals(3, nboMapValidated.size());  
    		Integer nboHistoryCount = [select count() from RTL_NBO_History__c where RTL_Customer_Name__c = :acctId];
    		System.assertEquals(4, nboHistoryCount);
    		Integer nboHistoryNewCount = [select count() from RTL_NBO_History__c where RTL_status__c = :RTL_Utility.NBO_STATUS_NEW and RTL_Customer_Name__c = :acctId];
    		System.assertEquals(4, nboHistoryNewCount); 
    		Integer nboHistoryProductCount = [select count() from RTL_NBO_History_Product__c];  
    		System.assertEquals(4, nboHistoryProductCount);
    		//test update valid nbo history product
    		RTL_NBO_History_Product__c nboProduct = [select Id, RTL_Status__c from RTL_NBO_History_Product__c LIMIT 1];
    		System.assertEquals('New', nboProduct.RTL_Status__c);  
    		nboProduct.RTL_Product__c = null;
    		nboProduct.RTL_Product_Group__c = 'test group2';
            nboProduct.RTL_Product_SubGroup__c = null;
            update nboProduct;
            RTL_NBO_History_Product__c validProduct = [select RTL_Product__c, RTL_Product_Group__c, RTL_Product_SubGroup__c, RTL_Status__c from RTL_NBO_History_Product__c where id = :nboProduct.Id];
            System.assertEquals('New', validProduct.RTL_Status__c);
            System.assertEquals(null, validProduct.RTL_Product__c);
            System.assertEquals('test group2', validProduct.RTL_Product_Group__c);
            System.assertEquals(null, validProduct.RTL_Product_SubGroup__c);
            //test update invalid nbo history product
    		validProduct.RTL_Product__c = null;
    		validProduct.RTL_Product_Group__c = 'invalid product group';
            validProduct.RTL_Product_SubGroup__c = null;
            update validProduct; 
            RTL_NBO_History_Product__c invalidProduct = [select RTL_Status__c from RTL_NBO_History_Product__c where id = :validProduct.Id];
            System.assertEquals('Invalid', invalidProduct.RTL_Status__c);                       
        }
    	Test.stopTest();
    	System.debug(':::: nboValidationTest End ::::');
    }

}