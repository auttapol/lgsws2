@isTest
public with sharing class RTL_TaskTriggerHandlerTest {
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
    public static testMethod void customerInteractionTestAccount(){
        System.debug(':::: customerInteractionTestAccount Start ::::');    	
    	Test.startTest(); 
        Id acctId = null;
        String externalAcctId = null;		        
		User retailUser = RTL_TestUtility.createRetailTestUser(true);
		System.runAs(retailUser) {
            List<Account> accountList = RTL_TestUtility.createAccounts(1,true); 
            acctId = accountList[0].Id; 
            externalAcctId = accountList[0].TMB_Customer_ID_PE__c;
            //create retail master product
            RTL_TestUtility.createRetailMasterProducts(true);            
		}
		User apiUser = RTL_TestUtility2.createRetailAPITestUser(true);//this is for user who create NBO
		User apiUser2 = RTL_TestUtility2.createRetailAPITestUser2(true);//this is for agent user
		List<RTL_NBO_History__c> nboHistoryList = null;
		System.runAs(apiUser) {//simulate creating NBO and product with integration API user
			//create NBO History & Product
			RTL_TestUtility2.createNBOHistoryAndProductValid(1, externalAcctId, true);
			nboHistoryList = [select RTL_Customer_Name__c, RTL_Status__c, RTL_NBO_ID__c from RTL_NBO_History__c where RTL_TMB_Customer_ID_PE__c = : externalAcctId];
			//System.assertEquals(acctId, nboHistoryList.get(0).RTL_Customer_Name__c);
			System.assertEquals(RTL_Utility.NBO_STATUS_NEW, nboHistoryList.get(0).RTL_Status__c);
		}
		
		//create task related with customer
		RTL_TestUtility2.createAccountTask(externalAcctId, nboHistoryList.get(0).RTL_NBO_ID__c, true);  
		Task taskObj = [select WhatId, WhoId, RTL_Outcome__c, RTL_Sub_Reason__c, RTL_NBO_History__c, RecordTypeId, lastmodifieddate from task where AccountId = :acctId];
		System.assertEquals(acctId, taskObj.WhatId);
		System.assertEquals(null, taskObj.WhoId);
		System.assertEquals('Rejected All', taskObj.RTL_Outcome__c);
		//System.assertEquals('Marketing - Inattractive promotion', taskObj.RTL_Sub_Reason__c);//comment this as the test case depends on the metadata value
		RTL_NBO_History__c nboHistory = [select RTL_Customer_Name__c, RTL_Status__c, RTL_NBO_ID__c from RTL_NBO_History__c where id = :taskObj.RTL_NBO_History__c];
		System.assertEquals(RTL_Utility.NBO_STATUS_REJECTEDALL, nboHistory.RTL_Status__c);
		System.assertEquals(RTL_TestUtility2.outboundTaskRecordType.Id, taskObj.RecordTypeId);
		
		String nboProductExtId = nboHistoryList.get(0).RTL_NBO_ID__c + '0';
		RTL_NBO_History_Product__c nboHistoryProduct = [select RTL_Offering_Channel__c, RTL_Status__c, RTL_Reject_Reason__c from RTL_NBO_History_Product__c where RTL_NBO_Product_External_ID__c = :nboProductExtId];
		System.assertEquals('Contact Center', nboHistoryProduct.RTL_Offering_Channel__c);//expected result is offering channel is updated with task because the branch offering date is earlier than contact center modified date
		System.assertEquals('Rejected', nboHistoryProduct.RTL_Status__c);
		//System.assertEquals('Marketing - Inattractive promotion', nboHistoryProduct.RTL_Reject_Reason__c);//comment this as the test case depends on reject_reason picklist
		
		//test update task
		taskObj.RTL_Contact_Center_Modified_Date__c = taskObj.lastmodifieddate;
		update taskObj;
		Task updatedTaskObj = [select WhatId, WhoId, RTL_Outcome__c, RTL_Sub_Reason__c, RTL_NBO_History__c, RecordTypeId from task where AccountId = :acctId];
		System.assertEquals('Rejected All', updatedTaskObj.RTL_Outcome__c);
		
    	Test.stopTest();
        System.debug(':::: customerInteractionTestAccount End ::::');       	    	
    }
    
    public static testMethod void customerInteractionTestLead(){
        System.debug(':::: customerInteractionTestLead Start ::::');    	
    	Test.startTest(); 
        Id acctId = null;
        String externalAcctId = null;
        Id newLeadId = null;
        Id convertedLeadId = null;
        Id convertedAccountId = null;     
		User retailUser = RTL_TestUtility.createRetailTestUser(true);
		System.runAs(retailUser) {
            List<Account> accountList = RTL_TestUtility.createAccounts(1,true); 
            acctId = accountList[0].Id; 
            externalAcctId = accountList[0].TMB_Customer_ID_PE__c; 			
            //create retail master product
            RTL_TestUtility.createRetailMasterProducts(true);			
            //create two leads, one is new, another is converted
            List<Lead> leads = RTL_TestUtility.createLeads(2, true);
           	//create interested products for lead
            RTL_TestUtility.createInterestedProducts(leads, true);
            //convert the 2nd lead
            Lead lead = leads[1];
            lead.Status = 'Qualified';
            update lead;
            //convert lead
            //database.leadConvert lc = new database.leadConvert();
            //lc.setLeadId(lead.id);
            //lc.setConvertedStatus('Closed Converted');
            //Database.LeadConvertResult lcr = Database.convertLead(lc);
            //check if the lead conversion is success
            //System.assert(lcr.isSuccess());
            newLeadId = leads[0].Id;
            //convertedLeadId = leads[1].Id;
            //lead = [select convertedAccountId from lead where id =:convertedLeadId];
            //convertedAccountId = lead.convertedAccountId;
		}
		User apiUser = RTL_TestUtility2.createRetailAPITestUser(true);
		List<RTL_NBO_History__c> nboHistoryList = null;
		System.runAs(apiUser) {//simulate creating NBO and product with integration API user
			//create NBO History & Product
			RTL_TestUtility2.createNBOHistoryAndProductValid(1, externalAcctId, true);
			nboHistoryList = [select RTL_Customer_Name__c, RTL_Status__c, RTL_NBO_ID__c from RTL_NBO_History__c where RTL_TMB_Customer_ID_PE__c = : externalAcctId];
			//System.assertEquals(acctId, nboHistoryList.get(0).RTL_Customer_Name__c);
			System.assertEquals(RTL_Utility.NBO_STATUS_NEW, nboHistoryList.get(0).RTL_Status__c);
		}
		
		//create new lead related task
		RTL_TestUtility2.createNewLeadTask(newLeadId, true);
		Task taskObj = [select RTL_Outcome__c, RecordTypeId, RTL_Sub_Reason__c from task where whoId = :newLeadId];
		System.assertEquals('Accepted All', taskObj.RTL_Outcome__c);
		//System.assertEquals('อื่นๆ', taskObj.RTL_Sub_Reason__c);//comment this as the test case depends on the metadata value
		System.assertEquals(RTL_TestUtility2.outboundTaskRecordType.Id, taskObj.RecordTypeId);
		
		String nboProductExtId = nboHistoryList.get(0).RTL_NBO_ID__c + '0';
		RTL_NBO_History_Product__c nboHistoryProduct = [select RTL_Offering_Channel__c, RTL_Status__c, RTL_Reject_Reason__c from RTL_NBO_History_Product__c where RTL_NBO_Product_External_ID__c = :nboProductExtId];
		System.assertEquals('Branch', nboHistoryProduct.RTL_Offering_Channel__c);//expected result is offering channel is not updated with task because the branch offering date is newer than contact center modified date
		System.assertEquals('New', nboHistoryProduct.RTL_Status__c);
		System.assertEquals(null, nboHistoryProduct.RTL_Reject_Reason__c);
		
		//create converted lead related task
		/*RTL_TestUtility2.createConvertedLeadTask(convertedLeadId, true);
		taskObj = [select WhatId, WhoId, RTL_Outcome__c, RecordTypeId, RTL_Sub_Reason__c from task where AccountId = :convertedAccountId];
		System.assertEquals(convertedAccountId, taskObj.WhatId);
		System.assertEquals(null, taskObj.WhoId);
		System.assertEquals('Pending', taskObj.RTL_Outcome__c);
		//System.assertEquals('อื่นๆ', taskObj.RTL_Sub_Reason__c);//comment this as the test case depends on the metadata value
		System.assertEquals(RTL_TestUtility2.outboundTaskRecordType.Id, taskObj.RecordTypeId);*/
					
    	Test.stopTest();
        System.debug(':::: customerInteractionTestLead End ::::');       	    	
    }
    
    public static testMethod void cxmTask() {
                
        Task taskObj = RTL_TestUtilityCXM.cxmCreateTask(true);
        Task updateTaskObj = [select Id, OwnerId, RTL_Task_Subject__c, lastmodifieddate from Task where Id = :taskObj.Id];

        System.debug('Task Id = ' + updateTaskObj.Id);  
        
        RTL_TestUtilityCXM.cxmUpdateTask(updateTaskObj);        
    }        
}