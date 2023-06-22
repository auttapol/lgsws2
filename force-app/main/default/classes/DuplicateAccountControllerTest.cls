@isTest
private class DuplicateAccountControllerTest {
	static{
        TestUtils.createAppConfig();
        // TestUtility_Referral.createAppConfigCallMeNowBH()	;
    }
	
	@isTest 
	static void test_method_one() {
		Test.startTest();
            Test.setCurrentPage(Page.DuplicateAccount);

			Account acc = new Account();
			acc.ID_Type_PE__c = 'Other ID';
			acc.ID_Number_PE__c = '12345';
			acc.Mobile_Number_PE__c = '1234512345';
			acc.Name = 'test Dup';

			insert acc;

			acc = new Account();
			acc.ID_Type_PE__c = 'Other ID';
			acc.ID_Number_PE__c = '454646';
			acc.Mobile_Number_PE__c = '1234512345';
			acc.Name = 'test Dup';

			insert acc;

			acc = new Account();
			acc.ID_Type_PE__c = 'Other ID';
			acc.ID_Number_PE__c = '1234512345';
			acc.Mobile_Number_PE__c = '258585';
			acc.Name = 'test Dup';

			insert acc;

			acc = new Account();
			acc.ID_Type_PE__c = 'Other ID';
			acc.ID_Number_PE__c = '1234512345';
			acc.Mobile_Number_PE__c = '1234512345';
			acc.Name = 'test Dup';

			insert acc;

			//NO DUP
            Lead lead = new Lead();
			lead.FirstName = 'xxx';
            lead.LastName = 'xxx';
			lead.Company  = 'xxx xxx';
            lead.RTL_Mobile_Number__c = '0984387103';
			lead.RTL_ID_Type__c = 'Other ID';
			lead.RTL_Citizen_Id__c = '125252';
			lead.Status = 'Qualified';
			lead.RTL_Count_InterestedProducts_Primary__c = 1;

			insert lead;
			
            ApexPages.StandardController std = new ApexPages.StandardController(lead);
            ApexPages.currentPage().getParameters().put('Id', lead.id);
			ApexPages.currentPage().getParameters().put('parentpage', 'LeadDetail');
            DuplicateAccountController ext = new DuplicateAccountController(std);
			ext.Newacct = acc;
			ext.accId = acc.Id;
			ext.backToLeadDetailPage();
			ext.ConvertLead();
			ext.checkDupAccToRedirect();

			ext = new DuplicateAccountController(lead.id);

			ext = new DuplicateAccountController(lead.RTL_Citizen_Id__c, lead.RTL_ID_Type__c, lead.RTL_Mobile_Number__c);

			//DUP MOBILE
			lead = new Lead();
			lead.FirstName = 'xxx';
            lead.LastName = 'xxx';
			lead.Company  = 'xxx xxx';
            lead.RTL_Mobile_Number__c = '1234512345';
			lead.RTL_ID_Type__c = 'Other ID';
			lead.RTL_Citizen_Id__c = '1252568';
			lead.Status = 'Qualified';
			lead.RTL_Count_InterestedProducts_Primary__c = 1;

			insert lead;

			ApexPages.StandardController std1 = new ApexPages.StandardController(lead);
            ApexPages.currentPage().getParameters().put('Id', lead.id);
			ApexPages.currentPage().getParameters().put('parentpage', 'LeadDetail');
            DuplicateAccountController ext1 = new DuplicateAccountController(std1);
			ext1.backToLeadDetailPage();
			ext1.ConvertLead();
			ext1.checkDupAccToRedirect();

			ext1 = new DuplicateAccountController(lead.id);

			ext1 = new DuplicateAccountController(lead.RTL_Citizen_Id__c, lead.RTL_ID_Type__c, lead.RTL_Mobile_Number__c);

			//ID NUM DUP
			lead = new Lead();
			lead.FirstName = 'xxx';
            lead.LastName = 'xxx';
			lead.Company  = 'xxx xxx';
            lead.RTL_Mobile_Number__c = '0812345678';
			lead.RTL_ID_Type__c = 'Other ID';
			lead.RTL_Citizen_Id__c = '1234512345';
			lead.Status = 'Qualified';
			lead.RTL_Count_InterestedProducts_Primary__c = 1;

			insert lead;

			ApexPages.StandardController std2 = new ApexPages.StandardController(lead);
            ApexPages.currentPage().getParameters().put('Id', lead.id);
			ApexPages.currentPage().getParameters().put('parentpage', 'LeadDetail');
            DuplicateAccountController ext2 = new DuplicateAccountController(std2);
			ext2.backToLeadDetailPage();
			ext2.ConvertLead();
			ext2.checkDupAccToRedirect();

			ext2 = new DuplicateAccountController(lead.id);

			ext2 = new DuplicateAccountController(lead.RTL_Citizen_Id__c, lead.RTL_ID_Type__c, lead.RTL_Mobile_Number__c);

			//BOTH DUP
			lead = new Lead();
			lead.FirstName = 'xxx';
            lead.LastName = 'xxx';
			lead.Company  = 'xxx xxx';
            lead.RTL_Mobile_Number__c = '1234512345';
			lead.RTL_ID_Type__c = 'Other ID';
			lead.RTL_Citizen_Id__c = '1234512345';
			lead.Status = 'Qualified';
			lead.RTL_Count_InterestedProducts_Primary__c = 1;

			insert lead;

			ApexPages.StandardController std3 = new ApexPages.StandardController(lead);
            ApexPages.currentPage().getParameters().put('Id', lead.id);
			ApexPages.currentPage().getParameters().put('parentpage', 'LeadDetail');
            DuplicateAccountController ext3 = new DuplicateAccountController(std3);
			ext3.backToLeadDetailPage();
			ext3.ConvertLead();
			ext3.checkDupAccToRedirect();

			ext3 = new DuplicateAccountController(lead.id);

			ext3 = new DuplicateAccountController(lead.RTL_Citizen_Id__c, lead.RTL_ID_Type__c, lead.RTL_Mobile_Number__c);

        Test.stopTest();
	}
	
}