@isTest
private class LeadActionValidateControllerTest {
	
	@isTest 
	static void test_method_one() {
        Test.startTest();
            Test.setCurrentPage(Page.LeadConvert_FieldValidate);

            Lead lead = new Lead();
            lead.LastName = 'xxx';
            lead.RTL_Mobile_Number__c = '0984387103';
			lead.RTL_ID_Type__c = 'Other ID';
			lead.RTL_Citizen_Id__c = '1234512345';
			lead.Status = 'Qualified';
			lead.RTL_Count_InterestedProducts_Primary__c = 1;
			
            ApexPages.StandardController std = new ApexPages.StandardController(lead);
            // ApexPages.currentPage().getParameters().put('saveAndNew', 'saveAndNew');
            LeadActionValidateController ext = new LeadActionValidateController(std);

            ext.StatusQualifiedValidation();
            ext.cancelLead();
            ext.getDisplayS1();
        Test.stopTest();
	}
	
	@isTest 
	static void test_method_two() {
		Test.startTest();
            Test.setCurrentPage(Page.LeadConvert_FieldValidate);

            Lead lead = new Lead();
            lead.LastName = 'xxx';
            lead.RTL_Mobile_Number__c = '0984387103';
			lead.RTL_ID_Type__c = 'Other ID';
			lead.RTL_Citizen_Id__c = '1234512345';
			lead.Status = 'New';
			lead.RTL_Count_InterestedProducts_Primary__c = 1;
			
            ApexPages.StandardController std = new ApexPages.StandardController(lead);
            // ApexPages.currentPage().getParameters().put('saveAndNew', 'saveAndNew');
            LeadActionValidateController ext = new LeadActionValidateController(std);

            ext.StatusQualifiedValidation();
            ext.cancelLead();
            ext.getDisplayS1();
        Test.stopTest();
	}
	
}