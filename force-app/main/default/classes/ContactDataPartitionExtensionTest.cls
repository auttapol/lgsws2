@isTest
private class ContactDataPartitionExtensionTest {
	
	@testSetup static void setupData() 
	{
        TestUtils.createAppConfig();

        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'User1' , 'test@email.com' , false).get(0);
        u.RTL_Branch_Code__c  = '611';
        insert u;

		Account acct = RTL_TestUtility.createAccounts(1 , true).get(0);

		Contact ct = RTL_TestUtility.createContacts(acct);
        ct.OwnerId = u.id;
        insert ct;
	}

	@isTest static void ContactDataPartitionTest() 
	{
		Test.startTest();
			Contact c = [SELECT id FROM Contact LIMIT 1];
            //Campaign c = [SELECT ID FROM Campaign LIMIT 1];
            ApexPages.StandardController sc = new ApexPages.StandardController(c);

            PageReference pageRef = Page.ContactInformationSensitiveData;
            //pageRef.getParameters().put('sfdcIFrameHost', 'aaa' );
      

            Test.setCurrentPage(pageRef);

            ContactDataPartitionExtension cdpe = new ContactDataPartitionExtension(sc);
            Boolean isSF1 =  cdpe.isSF1;
            String hiddenText  = cdpe.hiddenText;
            //String notAuthorizedMsg   = adpe.notAuthorizedMsg ;


            cdpe.loadData();


            //system.debug(isSF1);

        Test.stopTest();
	}

	
}