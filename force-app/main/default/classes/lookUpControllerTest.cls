@isTest
private class lookUpControllerTest {
	
	@testSetup static void setup() {
		// Implement test code
		TestUtils.createAppConfig();
		Account acc = CSTestUtils.createAccounts(1,false).get(0);
		acc.Murex_Counter_Label__c = 'eclient';
		insert acc;

		User u = CSTestUtils.createUsers(1, 'UserTestqqq' ,'Userqqq' , 'test22@email.com' , false).get(0);
        u.IsActive = true;
        insert u;
	}
	
	@isTest static void fetchAccount() {
		// Implement test code	
		List < User > user = [SELECT Id,Name From User where isActive=true];
		lookUpController.fetchAccount(user[0].Name);
	}

	@isTest static void getOwnerName() {
		// Implement test code	
		List < User > user = [SELECT Id,Name From User where isActive=true];
		lookUpController.getOwnerName(user[0].Name);
	}

	@isTest static void fetchUser() {
		// Implement test code	
		lookUpController.fetchUser();
	}

	@isTest static void fetchAccountOwner() {
		// Implement test code	
		Account acc = [SELECT Id FROM Account];
		lookUpController.fetchAccountOwner(acc.Id);	
	}
	
}