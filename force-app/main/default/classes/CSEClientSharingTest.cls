@isTest
private class CSEClientSharingTest {
	
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
	
	@isTest static void manualShareRead() {
		// Implement test code
		List<E_Client_Suitability__c> ecs = [SELECT Id, OwnerId, Name, CS_Customer_Survey_A__c, CS_Customer_Survey_B__c, CS_RM__c FROM E_Client_Suitability__c Limit 1];
		List<Id> ecIdList = new List<Id>();
		for(E_Client_Suitability__c ec : ecs)
		{
			ecIdList.add(ec.Id);
		}
		CSEClientSharing.manualShareRead(ecIdList, ecs[0].CS_RM__c);
	}

	@isTest static void deleteSharingEclient() {
		// Implement test code
		List<E_Client_Suitability__c> ecs = [SELECT Id, OwnerId, Name, CS_Customer_Survey_A__c, CS_Customer_Survey_B__c, CS_RM__c FROM E_Client_Suitability__c Limit 1];
		List<Id> ecIdList = new List<Id>();
		for(E_Client_Suitability__c ec : ecs)
		{
			ecIdList.add(ec.Id);
		}
		CSEClientSharing.deleteSharingEclient(ecIdList);
	}

	
}