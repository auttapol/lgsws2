@isTest
private class SurveyVersionTriggerHandlerTest {
	
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
		Survey_Version__c sv1 = CSTestUtils.createSurveyVersion(1,smList[0]);
		Survey_Version__c sv2 = CSTestUtils.createSurveyVersion(2,smList[1]);

		Survey_Sheet__c formA = CSTestUtils.insertSurveySheet(smList[0], acc.Id,u.Id,'FormA');
		Survey_Sheet__c formB = CSTestUtils.insertSurveySheet(smList[1],acc.Id,u.Id,'FormB');

		List<E_Client_Suitability__c> esList = CSTestUtils.createEclient(1,acc.Id,u.Id,formA,formB);
	}

	@isTest static void SurveyVersionTriggerHandler() {

		List<Survey_Version__c> svList = [SELECT Id,Active_Status__c FROM Survey_Version__c ];
		List<Survey_Version__c> svUpdate = new List<Survey_Version__c>();

		Test.startTest();
			for(Survey_Version__c sv : svList)
			{
				// sv.Active_Status__c = true;
				sv.Active_Status__c = false;
				svUpdate.add(sv);
			}
        	update svUpdate;
        Test.stopTest();      
	}
	
}