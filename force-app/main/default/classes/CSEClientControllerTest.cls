@isTest
private class CSEClientControllerTest {
	
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
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c FROM E_Client_Suitability__c Limit 1];
		CSEClientController.getCurrentEclient(ec[0].Id);
	}
	
	@isTest static void updateCurrentEclientToBasic() {
	// Implement test code
		User AdminUser = [SELECT Id,Name,Username,Country,Email,FirstName,LastName,IsActive 
			FROM User Where Id =: userInfo.getUserId() AND isActive=true LIMIT 1];
		System.runAS(AdminUser)
		{
			List<E_Client_Suitability__c> ec = [SELECT Id,OwnerId,CS_Murex_ID__c,CS_Customer__c,CS_RM__c,CS_Sales_Owner__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c FROM E_Client_Suitability__c Limit 1];			
			CSEClientController.updateCurrentEclientToBasic(ec[0]);
		}
	}

	@isTest static void updateEclient() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c FROM E_Client_Suitability__c Limit 1];
		CSEClientController.updateEclient(ec[0]);
	}

	@isTest static void saveEClientRecordId() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c FROM E_Client_Suitability__c Limit 1];
		CSEClientController.saveEClientRecordId(ec[0].Id,ec[0].CS_Customer_Survey_A__c,'FormA');
		CSEClientController.saveEClientRecordId(ec[0].Id,ec[0].CS_Customer_Survey_B__c,'FormB');
	}

	@isTest static void getEClientSuit() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c FROM E_Client_Suitability__c Limit 1];
		CSEClientController.getEClientSuit(ec[0].Id);
	}

	@isTest static void getSurveySheet() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c FROM E_Client_Suitability__c Limit 1];
		CSEClientController.getSurveySheet();
	}

	@isTest static void confirmEclient() {
		// Implement test code
		List<Survey_Manager__c> smList = new List<Survey_Manager__c>();

		Survey_Manager__c smA = new Survey_Manager__c();
		smA.Name = 'SurveyTest_A';
		smA.CS_Survey_Manager_Key__c  = 'eclient-formA';
		smList.add(smA);

		Survey_Manager__c smB = new Survey_Manager__c();
		smB.Name = 'SurveyTest_B';
		smB.CS_Survey_Manager_Key__c  = 'eclient-formB';
		smList.add(smB);
		
		insert smList;

		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer__c,CS_RM__c,CS_Sales_Owner__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c FROM E_Client_Suitability__c Limit 1];
		CSEClientController.confirmEclient(ec[0]);
	}

	@isTest static void insertSurveySheet() {
		// Implement test code
		List<Survey_Manager__c> smA = [SELECT Id,Name,Survey_Version__c,CS_Survey_Manager_Key__c FROM Survey_Manager__c LIMIT 1];
		List<Survey_Manager__c> smB = [SELECT Id,Name,Survey_Version__c,CS_Survey_Manager_Key__c FROM Survey_Manager__c LIMIT 1];
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c,CS_Customer__c,CS_RM__c,CS_Sales_Owner__c FROM E_Client_Suitability__c Limit 1];
		CSEClientController.insertSurveySheet(smA[0],ec[0].CS_Customer__c,ec[0].CS_RM__c);
		CSEClientController.insertSurveySheet(smB[0],ec[0].CS_Customer__c,ec[0].CS_Sales_Owner__c);
	}

}