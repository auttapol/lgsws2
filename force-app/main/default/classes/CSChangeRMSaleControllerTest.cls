@isTest
private class CSChangeRMSaleControllerTest {
	
	@testSetup static void setup() {
		// Implement test code
	    AppConfig__c mc =new AppConfig__c(Name = 'runtrigger', Value__c = 'false');
        insert mc;

        User u = CSTestUtils.createUsers(1, 'UserTestqqq' ,'Userqqq' , 'test22@email.com' , false).get(0);
        u.IsActive = true;
        insert u;

		Account acc = CSTestUtils.createAccounts(1,false).get(0);
		acc.Murex_Counter_Label__c = 'eclient';
		insert acc;

		List<Survey_Manager__c> smList = CSTestUtils.createSurveyManager(2);
		Survey_Sheet__c formA = CSTestUtils.insertSurveySheet(smList[0], acc.Id,u.Id,'FormA');
		Survey_Sheet__c formB = CSTestUtils.insertSurveySheet(smList[1],acc.Id,u.Id,'FormB');

		List<E_Client_Suitability__c> esList = CSTestUtils.createEclient(1,acc.Id,u.Id,formA,formB);
	}
	
	@isTest static void getCurrentEclient() {
		// Implement test code
		List<E_Client_Suitability__c> ecList = [SELECT Id,CS_Murex_ID__c,CS_Customer__c,CS_RM__c,CS_Sales_Owner__c FROM E_Client_Suitability__c];
		List<Id> ecId = new List<Id>();
		for(E_Client_Suitability__c ec : ecList)
		{
			ecId.add(ec.Id);
		}
		CSChangeRMSaleController.getCurrentEclient(ecId);
	}

	@isTest static void confirmEclientListView() {
		// Implement test code
		List<E_Client_Suitability__c> ecList = [SELECT Id,CS_Murex_ID__c,CS_Customer__c,CS_RM__c,CS_Sales_Owner__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c FROM E_Client_Suitability__c];
		CSChangeRMSaleController.confirmEclientListView(ecList);
	}

	@isTest static void insertSurveySheet() {
		// Implement test code
		Survey_Manager__c smA = [SELECT Id,Name,Survey_Version__c FROM Survey_Manager__c WHERE CS_Survey_Manager_Key__c  = 'SurveyKeyTest1' ];
		E_Client_Suitability__c ec = [SELECT Id,CS_Murex_ID__c,CS_Customer__c,CS_RM__c,CS_Sales_Owner__c FROM E_Client_Suitability__c Limit 1];
		CSChangeRMSaleController.insertSurveySheet(smA,ec.CS_Customer__c,ec.CS_Sales_Owner__c);
	}
	
	@isTest static void updateCurrentEclient() {
		// Implement test code
		E_Client_Suitability__c ec = [SELECT Id,CS_Murex_ID__c FROM E_Client_Suitability__c Limit 1];
		CSChangeRMSaleController.updateCurrentEclient(ec);
	}

	@isTest static void getCurrentUser() {
		// Implement test code
		CSChangeRMSaleController.getCurrentUser();
	}
}