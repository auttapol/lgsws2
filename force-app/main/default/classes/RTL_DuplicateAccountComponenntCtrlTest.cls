@isTest
private class RTL_DuplicateAccountComponenntCtrlTest {
	static Id recordTypeId;
	static List <Account> accList ;
	static Campaign camp;
	static Lead lead;
	static List<RTL_product_master__c> retailMasterProductsToInsert;
	static {
        TestUtils.createAppConfig();
		mockData();
    }

	static void mockData(){
		recordTypeId  = [SELECT Id from RecordType WHERE SobjectType = 'Campaign' AND DeveloperName=: 'Dummy_Campaign' AND IsActive = true ].Id;
		accList = new List<Account>();
		Account acc = new Account();
		acc = new Account();
		acc.ID_Type_PE__c = 'Other ID';
		acc.ID_Number_PE__c = '12345';
		acc.Mobile_Number_PE__c = '1234512345';
		acc.Name = 'test Dup';
		accList.add(acc);

		acc = new Account();
		acc.ID_Type_PE__c = 'Other ID';
		acc.ID_Number_PE__c = '454646';
		acc.Mobile_Number_PE__c = '1234512345';
		acc.Name = 'test Dup';
		accList.add(acc);

		acc = new Account();
		acc.ID_Type_PE__c = 'Other ID';
		acc.ID_Number_PE__c = '1234512345';
		acc.Mobile_Number_PE__c = '258585';
		acc.Name = 'test Dup';
		accList.add(acc);

		acc = new Account();
		acc.ID_Type_PE__c = 'Other ID';
		acc.ID_Number_PE__c = '1234512345';
		acc.Mobile_Number_PE__c = '1234512345';
		acc.Name = 'test Dup';
		accList.add(acc);

		acc = new Account();
		acc.ID_Type_PE__c = 'Other ID';
		acc.ID_Number_PE__c = '1234512345';
		acc.Mobile_Number_PE__c = '1234512345';
		acc.Name = 'test Dup';
		accList.add(acc);

		insert accList;

		lead = new Lead();
		lead.Recordtypeid = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Retail Banking').getRecordTypeId();
		lead.LastName = 'xxx';
		lead.RTL_Mobile_Number__c = '0984387103';
		lead.RTL_ID_Type__c = 'Other ID';
		lead.RTL_Citizen_Id__c = '1234512345';
		lead.Status = 'Qualified';
		lead.Company  = 'xxx xxx';
		insert lead;

		camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = Recordtypeid;
        insert camp;

		retailMasterProductsToInsert = new List<RTL_product_master__c>();
                                                                                  
        retailMasterProductsToInsert.add(new RTL_product_master__c ( 
                Active__c = TRUE,
                Name = 'Deposit Product',
                Product_Code__c = '0001',
                Product_Group__c = 'Deposit',
                Product_Sub_group__c = 'Transactional'));

		insert retailMasterProductsToInsert;
	}

	@isTest
	static void TestNewAccLeadDetail(){
		lead.RTL_Mobile_Number__c = '1234512345';
		lead.RTL_Citizen_Id__c = '12119819';
		update lead;
		
		RTL_Interested_products_c__c interProd = new RTL_Interested_products_c__c ( 
                Is_Primary__c = TRUE,
                Lead__c = lead.Id,
                Product_Name__c = retailMasterProductsToInsert[0].Id);
		insert interProd;

		Test.startTest();
		RTL_DuplicateAccountComponentController ext = new RTL_DuplicateAccountComponentController();
		ext.objLead = lead;

		ext.CreateNewAccount();
		Test.stopTest();
	}

	@isTest
	static void TestMergeAccLeadDetailNegative(){
		lead.RTL_Mobile_Number__c = '1234512345';
		lead.RTL_Citizen_Id__c = '1234512345';
		update lead;
		
		RTL_Interested_products_c__c interProd = new RTL_Interested_products_c__c ( 
                Is_Primary__c = TRUE,
                Lead__c = lead.Id,
                Product_Name__c = retailMasterProductsToInsert[0].Id);
		insert interProd;

		Test.startTest();
		RTL_DuplicateAccountComponentController ext = new RTL_DuplicateAccountComponentController();
		ext.objLead = lead;
		ext.accId = accList[4].Id;

		ext.ClickMerge();
		Test.stopTest();
	}

	
	@isTest 
	static void TestPositive() {
		List<Lead> leads = new List<Lead>();
		leads = RTL_TestUtility.createLeads(2,true);

		Opportunity objOpp = new Opportunity();

		CampaignMember currentObject = new CampaignMember();
		currentObject.LeadId = leads.get(0).id;
        currentObject.CampaignId = camp.id;
        currentObject.RTL_TMB_Campaign_Source__c = 'web';     
        currentObject.RTL_Contact_Status__c = 'Contact';
        currentObject.RTL_Product_Group_1__c = 'Bancassurance';
        currentObject.RTL_OfferResult_Product_1__c = 'Interested';
        insert currentObject;

		Lead objLead = new Lead();
		///////////////////////////////////////////////////////////////////////////////////////////////
		Test.startTest();

		//FROM LEAD DETAIL
		RTL_DuplicateAccountComponentController ext = new RTL_DuplicateAccountComponentController();
		ext.objLead = objLead;

		ext.ClickMerge();
		ext.CreateNewAccount();
		ext.ClickBack();
		ext.backPageSelectAccount();

		ext = new RTL_DuplicateAccountComponentController();
		ext.objLead = lead;

		ext.getLead(lead.id);
		ext.ClickMerge();
		ext.CreateNewAccount();
		ext.ClickBack();
		ext.backPageSelectAccount();
		ext.getConfRecordType();
		ext.getRecordTypeOpportunity();
		ext.getCampaignMember(currentObject.id);

		ext.accId = accList[4].Id;

		ext.ClickMerge();
		ext.CreateNewAccount();
		ext.ClickBack();
		ext.backPageSelectAccount();

		//FROM CAMPAIGN MEMBER
		
		RTL_DuplicateAccountComponentController ext2 = new RTL_DuplicateAccountComponentController();

		ext2.objLead = objLead;
		ext2.currentObject = currentObject;

		RTL_DuplicateAccountComponentController.CampaignProductInterestedWrapper camInterProd = new RTL_DuplicateAccountComponentController.CampaignProductInterestedWrapper(1,'apiProductGroup','apiProductSubGroup',
            'apiProductId', 'apiProductName', objOpp, true, true);

		ext2.close();
		ext2.ClickMerge();
		ext2.CreateNewAccount();
		ext2.ClickBack();
		ext2.backPageSelectAccount();
		ext2.getAccount();
		ext2.accId = accList[4].Id;
		ext2.getAccount();
		
		ext2.ClickMerge();
		ext2.CreateNewAccount();
		ext2.ClickBack();
		ext2.backPageSelectAccount();

		RTL_DuplicateAccountComponentController.settingValueTranformation('00590000003ClbGAAS');
		RTL_DuplicateAccountComponentController.settingValueTranformation('a09O000000NKksqIAD');
		RTL_DuplicateAccountComponentController.settingValueTranformation('003O000001B08NjIAJ');

        Test.stopTest();
	}

	@isTest 
	static void test_method_Lead_Detail_Click_btn() {
		RTL_DuplicateAccountComponentController ext = new RTL_DuplicateAccountComponentController();

		ext.objLead = lead;
		ext.NewConvertLeadDetail();
	}

	@isTest 
	static void test_method_Campaign_Click_btn() {
		RTL_DuplicateAccountComponentController ext = new RTL_DuplicateAccountComponentController();

		CampaignMember currentObject = new CampaignMember();
		currentObject.LeadId = lead.id;
        currentObject.CampaignId = camp.id;
        currentObject.RTL_TMB_Campaign_Source__c = 'web';     
        currentObject.RTL_Contact_Status__c = 'Contact';
        currentObject.RTL_Product_Group_1__c = 'Bancassurance';
        currentObject.RTL_OfferResult_Product_1__c = 'Interested';
		currentObject.ContactId = null;

        insert currentObject;

		Opportunity objOpp = new Opportunity(StageName = 'Sales (Others)', RTL_Status__c = 'Open', RecordTypeId = '01290000000iZYRAA2', Amount = 5, CloseDate = date.newinstance(1960, 2, 17));

		List<RTL_CampaignProductInterestedWrapper> createOppList = new List<RTL_CampaignProductInterestedWrapper>();

		RTL_CampaignProductInterestedWrapper tmp = new RTL_CampaignProductInterestedWrapper(1, 1,'RTL_Product_Group_1__c', 'apiProductSubGroup', 'apiProductId', 'apiProductName', objOpp, true, true);
		createOppList.add(tmp);
		
		ext.objLead = lead;
		ext.currentObject = currentObject;

		ext.NewAccConvertLeadCAMPAIGN();

		ext.accId = accList[4].Id;
		// ext.createOppList = createOppList;

		ext.MergeConvertLeadCAMPAIGN();
	}

	@isTest 
	static void test_method_Campaign_Click_btn_with_Prod() {
		List<lead> leads = new List<lead>();

		leads = RTL_TestUtility.createLeads(2,true);
		// RTL_TestUtility.createInterestedProducts(leads, true);

		CampaignMember currentObject = new CampaignMember();
		currentObject.LeadId = leads[0].id;
        currentObject.CampaignId = camp.id;
        currentObject.RTL_TMB_Campaign_Source__c = 'web';     
        currentObject.RTL_Contact_Status__c = 'Contact';

		currentObject.RTL_Campaign_Product_1__c = retailMasterProductsToInsert[0].Id;
		currentObject.RTL_Sub_Group_1__c = retailMasterProductsToInsert[0].Product_Sub_group__c;
        currentObject.RTL_Product_Group_1__c = retailMasterProductsToInsert[0].Product_Group__c;
        currentObject.RTL_OfferResult_Product_1__c = 'Interested';
		currentObject.ContactId = null;

        insert currentObject;

		Opportunity objOpp = new Opportunity(
			Name = 'Pass PLS',
			StageName = 'Sales (Others)', 
			RTL_Status__c = 'Open', 
			RecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Retail Deposit').getRecordTypeId(),
			Amount = 5, 
			CloseDate = date.newinstance(2050, 1, 17)
		);

		List<RTL_CampaignProductInterestedWrapper> createOppList = new List<RTL_CampaignProductInterestedWrapper>();

		RTL_CampaignProductInterestedWrapper tmp = new RTL_CampaignProductInterestedWrapper(1, 1,'RTL_Product_Group_1__c', 'RTL_Sub_Group_1__c', 'RTL_Campaign_Product_1__c', 'RTL_Campaign_Product_1__r.Name', objOpp, true, true);
		createOppList.add(tmp);
		
		Test.startTest();

		RTL_DuplicateAccountComponentController ext = new RTL_DuplicateAccountComponentController();
		ext.currentObject = currentObject;
		ext.createOppList = createOppList;

		ext.CreateNewAccount();
		Test.stopTest();
	}

	@isTest 
	static void TestMergeAccCamp() {
		List<lead> leads = new List<lead>();

		User us = [SELECT Id FROM User WHERE IsActive = true and profile.name = 'TMB Retail Contact Center Inbound Voice' LIMIT 1];

		leads = RTL_TestUtility.createLeads(2,true);


		CampaignMember currentObject = new CampaignMember();
		currentObject.LeadId = leads[0].id;
        currentObject.CampaignId = camp.id;
        currentObject.RTL_TMB_Campaign_Source__c = 'web';     
        currentObject.RTL_Contact_Status__c = 'Contact';

		currentObject.RTL_Campaign_Product_1__c = retailMasterProductsToInsert[0].Id;
		currentObject.RTL_Sub_Group_1__c = retailMasterProductsToInsert[0].Product_Sub_group__c;
        currentObject.RTL_Product_Group_1__c = retailMasterProductsToInsert[0].Product_Group__c;
        currentObject.RTL_OfferResult_Product_1__c = 'Interested';
		currentObject.ContactId = null;

        insert currentObject;

		currentObject.RTL_Assigned_Agent__c = us.id;

		Opportunity objOpp = new Opportunity(
			Name = 'PASS SI',
			StageName = 'Sales (Others)', 
			RTL_Status__c = 'Open', 
			RecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Retail Deposit').getRecordTypeId(),
			Amount = 5, 
			CloseDate = date.newinstance(2050, 2, 17)
		);

		List<RTL_CampaignProductInterestedWrapper> createOppList = new List<RTL_CampaignProductInterestedWrapper>();

		RTL_CampaignProductInterestedWrapper tmp = new RTL_CampaignProductInterestedWrapper(1, 1,'RTL_Product_Group_1__c', 'RTL_Sub_Group_1__c', 'RTL_Campaign_Product_1__c', 'RTL_Campaign_Product_1__r.Name', objOpp, true, true);
		createOppList.add(tmp);
		
		Test.startTest();

		RTL_DuplicateAccountComponentController ext = new RTL_DuplicateAccountComponentController();
		ext.currentObject = currentObject;
		ext.createOppList = createOppList;

		ext.accId = accList[4].Id;
		ext.close();
		ext.ClickMerge();
		Test.stopTest();
	}

	@isTest 
	static void TestMergeAccCampWithCampID() {
		List<lead> leads = new List<lead>();

		leads = RTL_TestUtility.createLeads(2,true);

		CampaignMember currentObject = new CampaignMember();
		currentObject.LeadId = leads[0].id;
        currentObject.CampaignId = camp.id;
        currentObject.RTL_TMB_Campaign_Source__c = 'web';     
        currentObject.RTL_Contact_Status__c = 'Contact';

		currentObject.RTL_Campaign_Product_1__c = retailMasterProductsToInsert[0].Id;
		currentObject.RTL_Sub_Group_1__c = retailMasterProductsToInsert[0].Product_Sub_group__c;
        currentObject.RTL_Product_Group_1__c = retailMasterProductsToInsert[0].Product_Group__c;
        currentObject.RTL_OfferResult_Product_1__c = 'Interested';
		currentObject.ContactId = null;

		Opportunity objOpp = new Opportunity(
			Name = 'PASS',
			StageName = 'Sales (Others)', 
			RTL_Status__c = 'Open', 
			RecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Retail Deposit').getRecordTypeId(),
			Amount = 5, 
			CloseDate = date.newinstance(2050, 2, 17)
		);

		List<RTL_CampaignProductInterestedWrapper> createOppList = new List<RTL_CampaignProductInterestedWrapper>();

		RTL_CampaignProductInterestedWrapper tmp = new RTL_CampaignProductInterestedWrapper(1, 1,'RTL_Product_Group_1__c', 'RTL_Sub_Group_1__c', 'RTL_Campaign_Product_1__c', 'RTL_Campaign_Product_1__r.Name', objOpp, true, true);
		createOppList.add(tmp);
		
		Test.startTest();

		RTL_DuplicateAccountComponentController ext = new RTL_DuplicateAccountComponentController();
		ext.currentObject = currentObject;
		ext.createOppList = createOppList;

		ext.accId = accList[4].Id;
		ext.ClickMerge();

		Test.stopTest();
	}

	@isTest 
	static void TestNewAccCampErrorWithoutCampID() {
		List<lead> leads = new List<lead>();

		leads = RTL_TestUtility.createLeads(2,true);

		CampaignMember currentObject = new CampaignMember();
		currentObject.LeadId = leads[0].id;
        currentObject.CampaignId = camp.id;
        currentObject.RTL_TMB_Campaign_Source__c = 'web';     
        currentObject.RTL_Contact_Status__c = 'Contact';

		currentObject.RTL_Campaign_Product_1__c = retailMasterProductsToInsert[0].Id;
		currentObject.RTL_Sub_Group_1__c = retailMasterProductsToInsert[0].Product_Sub_group__c;
        currentObject.RTL_Product_Group_1__c = retailMasterProductsToInsert[0].Product_Group__c;
        currentObject.RTL_OfferResult_Product_1__c = 'Interested';
		currentObject.ContactId = null;


		Opportunity objOpp = new Opportunity(
			Name = 'Pass PLS',
			StageName = 'Sales (Others)', 
			RTL_Status__c = 'Open', 
			RecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Retail Deposit').getRecordTypeId(),
			Amount = 5, 
			CloseDate = date.newinstance(2050, 1, 17)
		);

		List<RTL_CampaignProductInterestedWrapper> createOppList = new List<RTL_CampaignProductInterestedWrapper>();

		RTL_CampaignProductInterestedWrapper tmp = new RTL_CampaignProductInterestedWrapper(1, 1,'RTL_Product_Group_1__c', 'RTL_Sub_Group_1__c', 'RTL_Campaign_Product_1__c', 'RTL_Campaign_Product_1__r.Name', objOpp, true, true);
		createOppList.add(tmp);
		
		Test.startTest();

		RTL_DuplicateAccountComponentController ext = new RTL_DuplicateAccountComponentController();
		ext.currentObject = currentObject;
		ext.createOppList = createOppList;

		ext.close();
		ext.CreateNewAccount();
		Test.stopTest();
	}
}