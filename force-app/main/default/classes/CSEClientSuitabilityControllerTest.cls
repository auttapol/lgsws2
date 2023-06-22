@isTest
private class CSEClientSuitabilityControllerTest {
	
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
	
	@isTest static void saveEClientRecordId() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c FROM E_Client_Suitability__c Limit 1];
		CSEClientSuitabilityController.saveEClientRecordId(ec[0].Id,ec[0].CS_Customer_Survey_A__c,'FormA');
		CSEClientSuitabilityController.saveEClientRecordId(ec[0].Id,ec[0].CS_Customer_Survey_B__c,'FormB');
	}

	@isTest static void getFormList() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c FROM E_Client_Suitability__c Limit 1];
		CSEClientSuitabilityController.getFormList(ec[0].Id);
	}

	@isTest static void SurveyEClient() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c FROM E_Client_Suitability__c Limit 1];
		CSEClientSuitabilityController.SurveyEClient(ec[0].Id,'FormA');
		CSEClientSuitabilityController.SurveyEClient(ec[0].Id,'FormB');
	}

	@isTest static void getSurveyAnswer() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c FROM E_Client_Suitability__c Limit 1];
		CSEClientSuitabilityController.getSurveyAnswer(ec[0].CS_Customer_Survey_A__c);
	}

	@isTest static void getUserName() {
		// Implement test code
		User AdminUser = [SELECT Id,Name,Username,Country,Email,FirstName,LastName,IsActive 
			FROM User Where Id =: userInfo.getUserId() AND isActive=true LIMIT 1];	
		CSEClientSuitabilityController.getUserName(AdminUser.Id);
	}

	@isTest static void getSurveySheet() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c FROM E_Client_Suitability__c Limit 1];
		CSEClientSuitabilityController.getSurveySheet(ec[0].CS_Customer_Survey_A__c);	
	}

	@isTest static void getUserRecordAccess() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c FROM E_Client_Suitability__c Limit 1];
		CSEClientSuitabilityController.getUserRecordAccess(ec[0].Id);	
	}

	@isTest static void updateSurveyStatus() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c FROM E_Client_Suitability__c Limit 1];
		CSEClientSuitabilityController.updateSurveyStatus(ec[0].CS_Customer_Survey_A__c);	
	}

	@isTest static void updateEClientCSLevel() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c FROM E_Client_Suitability__c Limit 1];
		CSEClientSuitabilityController.updateEClientCSLevel(ec[0].Id,ec[0].CS_Customer_Survey_A__c);	
	}

	@isTest static void getEClientId() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c FROM E_Client_Suitability__c Limit 1];
		CSEClientSuitabilityController.getEClientId(ec[0].CS_Customer_Survey_A__c);	
	}
}