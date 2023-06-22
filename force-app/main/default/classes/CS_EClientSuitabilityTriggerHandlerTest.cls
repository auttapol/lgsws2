@isTest
private class CS_EClientSuitabilityTriggerHandlerTest {
	
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

	@isTest static void CS_EClientSuitabilityTriggerHandler() {

		List<E_Client_Suitability__c> eClientList = [SELECT Id,CS_Murex_ID__c,CS_Key__c,CS_Customer_Segment__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c FROM E_Client_Suitability__c Limit 1];

		Test.startTest();
        	Database.UpsertResult[] upsertResult = Database.upsert(eClientList , E_Client_Suitability__c.Fields.CS_Key__c , false);
        Test.stopTest();      
	}
	
}