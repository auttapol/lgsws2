@isTest
public class RTL_NBOHistoryDetailProxyCtrlTest {
	static{
       	TestUtils.createAppConfig();
    }
    static testmethod void testPositiveCase(){
    	Id acctId = null;
    	String externalAcctId = null;
		User retailUser = RTL_TestUtility.createRetailTestUser(true);
		System.runAs(retailUser) {
			//create account
            List<Account> accountList = RTL_TestUtility.createAccounts(1,true); 
            acctId = accountList[0].Id; 
            externalAcctId = accountList[0].TMB_Customer_ID_PE__c; 	
            //create retail master product
            RTL_TestUtility.createRetailMasterProducts(true);
		}
		List<RTL_NBO_History__c> nboHistoryList = RTL_TestUtility2.createNBOHistoryOnly(1, externalAcctId, true);
		RTL_NBO_History__c nboHistory = nboHistoryList.get(0);		    	
        Test.startTest();
        	Test.setCurrentPage(Page.RTL_NBOHistory_Detail_Proxy_Page);
        	ApexPages.StandardController std = new ApexPages.StandardController(nboHistory);
        	RTL_NBOHistoryDetailProxyCtrl ext = new RTL_NBOHistoryDetailProxyCtrl(std);
        	ext.redirectPage();
        Test.stopTest();
        
    }
}