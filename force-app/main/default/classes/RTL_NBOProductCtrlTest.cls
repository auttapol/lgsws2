@isTest
public class RTL_NBOProductCtrlTest {
    static List<Account> acctList;
    static RTL_NBO_History_Product__c nboProduct;
	static List<RTL_NBO_History__c> nboHistoryList;
    static List<Opportunity> opportunityList;
    static{       
        TestUtils.createAppConfig();
        acctList = RTL_TestUtility.createAccounts(2,true);     
        RTL_TestUtility.createRetailMasterProducts2(true);
        RTL_TestUtility2.createOpportunityRecordTypeMapping();
        
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
    
    static testmethod void testCreateOpportunity(){
        nboHistoryList = RTL_TestUtility2.createNBOHistoryAndProductValid2(3,acctList[0].id,true);
        nboProduct = [SELECT ID,Name FROM RTL_NBO_History_Product__c WHERE RTL_NBO_ID__c =:nboHistoryList[2].RTL_NBO_ID__c LIMIT 1];
        nboProduct.RTL_Product__c = 'test product1';
        nboProduct.RTL_Product_Group__c = 'test group1';
        nboProduct.RTL_Product_SubGroup__c = 'test subgroup1';
        update nboProduct;
        Test.startTest();
        	Test.setCurrentPage(new PageReference('/apex/RTL_NBOProductEdit'));
        	ApexPages.currentPage().getParameters().put('tabId','scc-pt-01');
        	ApexPages.StandardController std = new ApexPages.StandardController(nboProduct);
        	RTL_NBOProductCtrl nboProductCtrl = new RTL_NBOProductCtrl(std);
        	nboProductCtrl.nboProduct.RTL_Status__c = 'Accepted';
        	nboProductCtrl.saveNBOProduct();
        	opportunityList = getOpportunity();
        	System.assertEquals(1, opportunityList.size());
        	//System.assertEquals('Others (NBO)', opportunityList[0].Name);
        Test.stopTest();
    }
    
    static testmethod void testCreateDepositOpportunity(){
        nboHistoryList = RTL_TestUtility2.createNBOHistoryAndProductValidByProductGroup(1,acctList[0].id,'Deposit',true);
        nboProduct = [SELECT ID,Name FROM RTL_NBO_History_Product__c WHERE RTL_NBO_ID__c =:nboHistoryList[0].RTL_NBO_ID__c LIMIT 1];

        Test.startTest();
        	Test.setCurrentPage(new PageReference('/apex/RTL_NBOProductEdit'));
        	ApexPages.currentPage().getParameters().put('tabId','scc-pt-01');
        	ApexPages.StandardController std = new ApexPages.StandardController(nboProduct);
        	RTL_NBOProductCtrl nboProductCtrl = new RTL_NBOProductCtrl(std);
        	nboProductCtrl.nboProduct.RTL_Status__c = 'Accepted';
        	nboProductCtrl.saveNBOProduct();
        	opportunityList = getOpportunity();
        	System.assertEquals(1, opportunityList.size());
        	//System.assertEquals('Deposit (NBO)', opportunityList[0].Name);
        Test.stopTest();
    }
    
    static testmethod void testCreateBAOpportunity(){
         	nboHistoryList = RTL_TestUtility2.createNBOHistoryAndProductValidByProductGroup(1,acctList[0].id,'Bancassurance',true);
       		nboProduct = [SELECT ID,Name FROM RTL_NBO_History_Product__c WHERE RTL_NBO_ID__c =:nboHistoryList[0].RTL_NBO_ID__c LIMIT 1];
        	nboProduct.RTL_Product_SubGroup__c = 'Non Life';
        	update nboProduct;
        Test.startTest();
        	Test.setCurrentPage(new PageReference('/apex/RTL_NBOProductEdit'));
        	ApexPages.currentPage().getParameters().put('tabId','scc-pt-01');
        	ApexPages.StandardController std = new ApexPages.StandardController(nboProduct);
        	RTL_NBOProductCtrl nboProductCtrl = new RTL_NBOProductCtrl(std);
        	nboProductCtrl.nboProduct.RTL_Status__c = 'Accepted';
        	nboProductCtrl.saveNBOProduct();
        	opportunityList = getOpportunity();
        	System.assertEquals(1, opportunityList.size());
        	//System.assertEquals('BA Non Life (NBO)', opportunityList[0].Name);

        Test.stopTest();
    }
    
    static testmethod void testCreateCardOpportunity(){
         	nboHistoryList = RTL_TestUtility2.createNBOHistoryAndProductValidByProductGroup(1,acctList[0].id,'Credit Card & RDC',true);
       		nboProduct = [SELECT ID,Name FROM RTL_NBO_History_Product__c WHERE RTL_NBO_ID__c =:nboHistoryList[0].RTL_NBO_ID__c LIMIT 1];
        Test.startTest();
        	Test.setCurrentPage(new PageReference('/apex/RTL_NBOProductEdit'));
        	ApexPages.currentPage().getParameters().put('tabId','scc-pt-01');
        	ApexPages.StandardController std = new ApexPages.StandardController(nboProduct);
        	RTL_NBOProductCtrl nboProductCtrl = new RTL_NBOProductCtrl(std);
        	nboProductCtrl.nboProduct.RTL_Status__c = 'Accepted';
        	nboProductCtrl.saveNBOProduct();
			opportunityList = getOpportunity();
        	System.assertEquals(1, opportunityList.size());
        	//System.assertEquals('Card (NBO)', opportunityList[0].Name);
        Test.stopTest();
    }
    
    static testmethod void testCreateInvestmentOpportunity(){
         	nboHistoryList = RTL_TestUtility2.createNBOHistoryAndProductValidByProductGroup(1,acctList[0].id,'Investment',true);
       		nboProduct = [SELECT ID,Name FROM RTL_NBO_History_Product__c WHERE RTL_NBO_ID__c =:nboHistoryList[0].RTL_NBO_ID__c LIMIT 1];
        Test.startTest();
        	Test.setCurrentPage(new PageReference('/apex/RTL_NBOProductEdit'));
        	ApexPages.currentPage().getParameters().put('tabId','scc-pt-01');
        	ApexPages.StandardController std = new ApexPages.StandardController(nboProduct);
        	RTL_NBOProductCtrl nboProductCtrl = new RTL_NBOProductCtrl(std);
        	nboProductCtrl.nboProduct.RTL_Status__c = 'Accepted';
        	nboProductCtrl.saveNBOProduct();
        	opportunityList = getOpportunity();
        	System.assertEquals(1, opportunityList.size());
        	//System.assertEquals('MF (NBO)', opportunityList[0].Name);

        Test.stopTest();
    }
    
    static testmethod void testCreateLoanOpportunity(){
         	nboHistoryList = RTL_TestUtility2.createNBOHistoryAndProductValidByProductGroup(1,acctList[0].id,'Loan',true);
       		nboProduct = [SELECT ID,Name FROM RTL_NBO_History_Product__c WHERE RTL_NBO_ID__c =:nboHistoryList[0].RTL_NBO_ID__c LIMIT 1];
        Test.startTest();
        	Test.setCurrentPage(new PageReference('/apex/RTL_NBOProductEdit'));
        	ApexPages.currentPage().getParameters().put('tabId','scc-pt-01');
        	ApexPages.StandardController std = new ApexPages.StandardController(nboProduct);
        	RTL_NBOProductCtrl nboProductCtrl = new RTL_NBOProductCtrl(std);
        	nboProductCtrl.nboProduct.RTL_Status__c = 'Accepted';
        	nboProductCtrl.saveNBOProduct();
			opportunityList = getOpportunity();
        	System.assertEquals(1, opportunityList.size());
        	//System.assertEquals('Loan (NBO)', opportunityList[0].Name);
        Test.stopTest();
    }
    
    static testmethod void testCreateOthersOpportunity(){
         	nboHistoryList = RTL_TestUtility2.createNBOHistoryAndProductValidByProductGroup(1,acctList[0].id,'Others',true);
       		nboProduct = [SELECT ID,Name FROM RTL_NBO_History_Product__c WHERE RTL_NBO_ID__c =:nboHistoryList[0].RTL_NBO_ID__c LIMIT 1];
        Test.startTest();
        	Test.setCurrentPage(new PageReference('/apex/RTL_NBOProductEdit'));
        	ApexPages.currentPage().getParameters().put('tabId','scc-pt-01');
        	ApexPages.StandardController std = new ApexPages.StandardController(nboProduct);
        	RTL_NBOProductCtrl nboProductCtrl = new RTL_NBOProductCtrl(std);
        	nboProductCtrl.nboProduct.RTL_Status__c = 'Accepted';
        	nboProductCtrl.saveNBOProduct();
			opportunityList = getOpportunity();
        	System.assertEquals(1, opportunityList.size());
        	//System.assertEquals('Others (NBO)', opportunityList[0].Name);
        Test.stopTest();
    }
    
     static testmethod void testCreateRetentionsOpportunity(){
         	
        Test.startTest();
         	nboHistoryList = RTL_TestUtility2.createNBOHistoryAndProductValidByProductGroup(1,acctList[0].id,'Loan Retention',true);
       		nboProduct = [SELECT ID,Name FROM RTL_NBO_History_Product__c WHERE RTL_NBO_ID__c =:nboHistoryList[0].RTL_NBO_ID__c LIMIT 1];
        	Test.setCurrentPage(new PageReference('/apex/RTL_NBOProductEdit'));
        	ApexPages.currentPage().getParameters().put('tabId','scc-pt-01');
        	ApexPages.StandardController std = new ApexPages.StandardController(nboProduct);
        	RTL_NBOProductCtrl nboProductCtrl = new RTL_NBOProductCtrl(std);
        	nboProductCtrl.nboProduct.RTL_Status__c = 'Accepted';
        	nboProductCtrl.saveNBOProduct();
         	opportunityList = getOpportunity();
        	System.assertEquals(1, opportunityList.size());
        	//System.assertEquals('Retentions (NBO)', opportunityList[0].Name);

        Test.stopTest();
    }
    
    static testmethod void testFailSaveProduct(){
         	nboHistoryList = RTL_TestUtility2.createNBOHistoryAndProductValidByProductGroup(1,acctList[0].id,'Loan Retention',true);
       		nboProduct = [SELECT ID,Name FROM RTL_NBO_History_Product__c WHERE RTL_NBO_ID__c =:nboHistoryList[0].RTL_NBO_ID__c LIMIT 1];
        Test.startTest();
        	Test.setCurrentPage(new PageReference('/apex/RTL_NBOProductEdit'));
        	ApexPages.currentPage().getParameters().put('tabId','scc-pt-01');
        	ApexPages.StandardController std = new ApexPages.StandardController(nboProduct);
        	RTL_NBOProductCtrl nboProductCtrl = new RTL_NBOProductCtrl(std);
        	nboProductCtrl.nboProduct.RTL_Status__c = 'Accepted';
         	nboProductCtrl.nboProduct.RTL_Reject_Reason__c = 'TMB';
        	nboProductCtrl.saveNBOProduct();
			opportunityList = getOpportunity();
        	System.assertEquals(0, opportunityList.size());
        	
        	List<Apexpages.Message> msgs = ApexPages.getMessages();
			boolean b = false;
			for(Apexpages.Message msg:msgs){
    			if (msg.getDetail().contains(System.Label.RTL_NBO_ERR008)) b = true;
			}
			system.assert(b);
        Test.stopTest();
    }
    
    static testmethod void testFailGetProduct(){
         	nboHistoryList = RTL_TestUtility2.createNBOHistoryAndProductValidByProductGroup(1,acctList[0].id,'Test',true);
       		nboProduct = [SELECT ID,Name FROM RTL_NBO_History_Product__c WHERE RTL_NBO_ID__c =:nboHistoryList[0].RTL_NBO_ID__c LIMIT 1];
        	nboProduct.RTL_Product__c = 'Test1';
        	nboProduct.RTL_Product_Group__c = 'Test Group';
        	nboProduct.RTL_Product_SubGroup__c = 'Test SubGroup';
        	update nboProduct;
        Test.startTest();
        	Test.setCurrentPage(new PageReference('/apex/RTL_NBOProductEdit'));
        	ApexPages.currentPage().getParameters().put('tabId','scc-pt-01');
        	ApexPages.StandardController std = new ApexPages.StandardController(nboProduct);
        	RTL_NBOProductCtrl nboProductCtrl = new RTL_NBOProductCtrl(std);
        	nboProductCtrl.nboProduct.RTL_Status__c = 'Accepted';
        	nboProductCtrl.saveNBOProduct();
        	opportunityList = getOpportunity();
        	System.assertEquals(0, opportunityList.size());
        	
        	List<Apexpages.Message> msgs = ApexPages.getMessages();
			boolean b = false;
			for(Apexpages.Message msg:msgs){
    			if (msg.getDetail().contains(System.Label.RTL_NBO_ERR009)) b = true;
			}
			system.assert(b);
			
        Test.stopTest();
    }
    
    static testmethod void testCancel(){
        nboHistoryList = RTL_TestUtility2.createNBOHistoryAndProductValid(1,acctList[0].id,true);
        nboProduct = [SELECT ID,Name FROM RTL_NBO_History_Product__c WHERE RTL_NBO_ID__c =:nboHistoryList[0].RTL_NBO_ID__c LIMIT 1];
        Test.startTest();
        	Test.setCurrentPage(new PageReference('/apex/RTL_NBOProductEdit'));
        	ApexPages.currentPage().getParameters().put('tabId','scc-pt-01');
        	ApexPages.StandardController std = new ApexPages.StandardController(nboProduct);
        	RTL_NBOProductCtrl nboProductCtrl = new RTL_NBOProductCtrl(std);
        	nboProductCtrl.cancel();

        Test.stopTest();
    }
    
    static testmethod void testNboProductDetail(){
        nboHistoryList = RTL_TestUtility2.createNBOHistoryAndProductValid(1,acctList[0].id,true);
        nboProduct = [SELECT ID,Name,CreatedDate FROM RTL_NBO_History_Product__c WHERE RTL_NBO_ID__c =:nboHistoryList[0].RTL_NBO_ID__c LIMIT 1];
        List<RTL_NBO_History_Product__History> history = [SELECT ID ,Field,CreatedById,CreatedDate FROM RTL_NBO_History_Product__History WHERE ParentID  =:nboProduct.id];
        Test.startTest();
        	Test.setCurrentPage(new PageReference('/apex/RTL_NBOProductDetail'));
        	ApexPages.currentPage().getParameters().put('tabId','scc-pt-01');
        	ApexPages.StandardController std = new ApexPages.StandardController(nboProduct);
        	RTL_NBOProductCtrl nboProductCtrl = new RTL_NBOProductCtrl(std);
        	RTL_NBO_History_Product__History h = new RTL_NBO_History_Product__History();
         	h.Field = 'RTL_Status__c';
         	h.ParentId = nboProduct.id;
         	insert h;
        	RTL_GenericHistoryComponentController cont = new RTL_GenericHistoryComponentController();
        	System.debug('NBO PRODUCT :: '+nboProduct);
            System.debug('NBO PRODUCT HISTOYR :: '+history);
        	cont.myObject = nboProduct;
        	cont.recordLimit = 10;
        	cont.getObjectHistory();

        Test.stopTest();
    }
    
    private static List<Opportunity> getOpportunity(){
        List<Opportunity> oppList = [SELECT ID,Name FROM Opportunity];
        return oppList;
    }
}