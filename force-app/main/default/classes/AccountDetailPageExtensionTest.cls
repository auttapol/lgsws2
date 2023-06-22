@isTest
private class AccountDetailPageExtensionTest {
	
	@testSetup static void setupData() 
	{
        TestUtils.createAppConfig();
		Account acct = RTL_TestUtility.createAccounts(1 , true).get(0);
	}

	@isTest static void accountDetailWithSection2Test() {
		Test.startTest();
			Account a = [SELECT id FROM Account LIMIT 1];
            //Campaign c = [SELECT ID FROM Campaign LIMIT 1];
            ApexPages.StandardController sc = new ApexPages.StandardController(a);

            PageReference pageRef = Page.AccountDetailPage;
            pageRef.getParameters().put('sfdcIFrameHost', 'aaa' );
            pageRef.getParameters().put('sfdcIFrameOrigin', 'bbb' );
            pageRef.getParameters().put('isdtp', 'p1' );
            pageRef.getParameters().put('retURL', 'projectone' );

            
            pageRef.getParameters().put('sectionName2', 'Test' );

            Test.setCurrentPage(pageRef);

            AccountDetailPageExtension adpe = new AccountDetailPageExtension(sc);
            Boolean isSF1 =  adpe.isSF1;
            String hiddenText  = adpe.hiddenText;
            String notAuthorizedMsg   = adpe.notAuthorizedMsg ;


            adpe.loadData();
            adpe.loadParameter();

            //system.debug(isSF1);

        Test.stopTest();
	}

	@isTest static void accountDetailWithoutSection2Test() {
		Test.startTest();
			Account a = [SELECT id FROM Account LIMIT 1];
            //Campaign c = [SELECT ID FROM Campaign LIMIT 1];
            ApexPages.StandardController sc = new ApexPages.StandardController(a);

            PageReference pageRef = Page.AccountDetailPage;
            pageRef.getParameters().put('sfdcIFrameHost', '' );
            pageRef.getParameters().put('sfdcIFrameOrigin', '' );
            pageRef.getParameters().put('isdtp', '' );
            pageRef.getParameters().put('retURL', '' );

            
            //pageRef.getParameters().put('section2', 'Test' );
            
            Test.setCurrentPage(pageRef);

            AccountDetailPageExtension adpe = new AccountDetailPageExtension(sc);
            Boolean isSF1 =  adpe.isSF1;
            String hiddenText  = adpe.hiddenText;
            String notAuthorizedMsg   = adpe.notAuthorizedMsg ;


            adpe.loadData();

            //system.debug(isSF1);

        Test.stopTest();
	}

	
}