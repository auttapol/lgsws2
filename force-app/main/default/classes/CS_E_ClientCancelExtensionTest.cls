@isTest
private class CS_E_ClientCancelExtensionTest {
	
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
	
	@isTest static void CS_E_ClientCancelExtension() {
	
		User currentUserInfo = CS_E_ClientCancelExtension.currentUserInfo;
		List<E_Client_Suitability__c> ecl = [SELECT Id,CS_Murex_ID__c,CS_Customer__c,CS_Status__c  FROM E_Client_Suitability__c Limit 1];
		List<E_Client_Suitability__c> ecList = new List<E_Client_Suitability__c>();
		for( E_Client_Suitability__c ec : ecl )
		{
			ec.CS_Status__c = 'Completed';
			ecList.add(ec);
		}
		update ecList;

		System.debug(ecList);

        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(ecl);
		sc.setSelected(ecList);
        CS_E_ClientCancelExtension csex = new CS_E_ClientCancelExtension(sc);   

		csex.cancelConfirm();
		csex.cancelAction();
	}
}