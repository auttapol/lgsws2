@isTest
private class CSCancelEClientControllerTest {
	
	@testSetup static void setup() {
		// Implement test code
		AppConfig__c mc = new AppConfig__c(Name = 'runtrigger', Value__c = 'false');
        insert mc;

        User u = CSTestUtils.createUsers(1, 'UserTest' ,'User' , 'test11@email.com' , false).get(0);
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
	
	@isTest static void getEclient() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,CS_Murex_ID__c FROM E_Client_Suitability__c Limit 1];
		CSCancelEClientController.getEclient(ec[0].Id);
	}

	@isTest static void updateCurrentEclient() {
		// Implement test code		
		User AdminUser = [SELECT Id,Name,Username,Country,Email,FirstName,LastName,IsActive 
			FROM User Where Id =: userInfo.getUserId() AND isActive=true LIMIT 1];
		System.runAS(AdminUser)
		{
			List<E_Client_Suitability__c> ec = [SELECT Id,OwnerId,CS_Murex_ID__c,CS_Customer__c,CS_RM__c,CS_Sales_Owner__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c FROM E_Client_Suitability__c Limit 1];				
			CSCancelEClientController.updateCurrentEclient(ec[0]);
		}	
	}

	@isTest static void updateSurveyStatus() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id,OwnerId,CS_Murex_ID__c,CS_Customer__c,CS_RM__c,CS_Sales_Owner__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c FROM E_Client_Suitability__c Limit 1];			
		CSCancelEClientController.updateSurveyStatus(ec[0].CS_Customer_Survey_A__c);
	}
}