@isTest
private class CSGeneratePDFControllerTest {

	@testSetup static void setupData(){

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
		User u = [select Id from User LIMIT 1];
		Account acc = [select Id from Account LIMIT 1];
		E_Client_Suitability__c es = [select Id from E_Client_Suitability__c LIMIT 1];
		CSGeneratePDFController.getEclient(es.Id);
	}

	@isTest static void generatePDFfile() {
		E_Client_Suitability__c es = [select Id from E_Client_Suitability__c LIMIT 1];
		CSGeneratePDFController.generatePDFfile(es.Id);
	}
	
}