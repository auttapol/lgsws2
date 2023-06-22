@isTest
public class RTL_NBODetailCtrlTest {
	static List<Account> acctList;
	static List<RTL_NBO_History__c> nboHistoryList;
    static{       
        TestUtils.createAppConfig();
        acctList = RTL_TestUtility.createAccounts(2,true);  
        nboHistoryList = RTL_TestUtility2.createNBOHistoryAndProductValid(1,acctList[0].TMB_Customer_ID_PE__c,true);
        RTL_TestUtility.createRetailMasterProducts2(true);
        
    }
    
    static testmethod void testSuccessNBODetailCtrl(){
        Test.startTest(); 
        	Test.setCurrentPage(new PageReference('/apex/RTL_NBODetailView'));
        	ApexPages.currentPage().getParameters().put('p',nboHistoryList[0].RTL_NBO_ID__c);
        	RTL_NBODetailCtrl nboDetailCtrl = new RTL_NBODetailCtrl();
        Test.stopTest();
    }
    
    static testmethod void testFailNBODetailCtrl(){        
        Test.startTest(); 
        	Test.setCurrentPage(new PageReference('/apex/RTL_NBODetailView'));
        	ApexPages.currentPage().getParameters().put('p','');
        	RTL_NBODetailCtrl nboDetailCtrl = new RTL_NBODetailCtrl();
        Test.stopTest();
    }
}