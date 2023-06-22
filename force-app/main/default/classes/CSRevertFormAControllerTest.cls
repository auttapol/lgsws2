@isTest
private class CSRevertFormAControllerTest {
	
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
	
	@isTest static void getEclient() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id, OwnerId, Name, CS_RM__r.Name, CS_Sales_Owner__r.Name,
			CS_Customer__r.Name, CS_Status__c, LastModifiedBy.Name, CreatedDate, LastModifiedDate,
			CS_Customer_Survey_A__c, CS_Customer_Survey_B__c FROM E_Client_Suitability__c Limit 1];
        
		CSRevertFormAController.getEclient(ec[0].Id);
	}
    
    @isTest static void revertFormA() {
		// Implement test code
		List<E_Client_Suitability__c> ec = [SELECT Id, OwnerId, Name, CS_RM__r.Name, CS_Sales_Owner__r.Name,
			CS_Customer__r.Name, CS_Status__c, LastModifiedBy.Name, CreatedDate, LastModifiedDate,
			CS_Customer_Survey_A__c, CS_Customer_Survey_B__c FROM E_Client_Suitability__c Limit 1];
        
		CSRevertFormAController.revertFormA(ec[0].Id,'Test Comment');
	}


}