@isTest
private class RESTOpportunityProductUtilTest {
    public static final Id SYSTEM_ADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

    public static User sfextapi;
    public static User User01;
	public static User User02;

    static {
		TestUtils.createAppConfig();

		sfextapi = RESTOpportunityProductUtil.sfextapi;

		Branch_and_zone__c bz = new Branch_and_zone__c();
		bz.Branch_Code__c = '611';
		insert bz;

		List<User> userList = RTL_TestUtility.createUsers(2, 'TestMock', 'TaskBatch', 'taskbatch@tmb.com.test', false);

		User01 = userList.get(0);
		User01.ProfileId = SYSTEM_ADMIN_PROFILE_ID;
		User01.isActive = true;
		User01.title = 'Branch Manager';
		User01.RTL_Branch_Code__c = bz.Branch_Code__c;
		User01.Employee_ID__c = '123456';
		insert User01;

		User02 = userList.get(1);
		User02.ProfileId = SYSTEM_ADMIN_PROFILE_ID;
		User02.isActive = false;
		User02.title = 'Branch Manager';
		User02.RTL_Branch_Code__c = bz.Branch_Code__c;
		User02.Employee_ID__c = '123457';
		insert User02;

        List<Account> acct = TestUtils.createAccounts(1, 'TS',  'Individual', false);

		RecordType Prospect = [SELECT Id FROM RecordType WHERE developername = 'Prospect' and SobjectType = 'Account' AND IsActive = true LIMIT 1];

        Account acc1 = acct.get(0);
        acc1.IsDisqualified__c = true;
        acc1.RecordType = Prospect;
        acc1.RecordTypeId = Prospect.Id;

        insert acc1;

        List<Opportunity> opty =  TestUtils.createOpportunity(1, acc1.id, true);

        TestUtils.CreateProceBook();
        // List<Product2> createProduct 

        // createPricebookEntry

	}

    @isTest
    static void RESTOpportunityProductUtilHappyTest() {

        RESTOpportunityProductWrapperClass reqWrap = new RESTOpportunityProductWrapperClass();

        List<RESTOpportunityProductWrapperClass.prodWrap> prdWrap = new List<RESTOpportunityProductWrapperClass.prodWrap> ();

        for(Integer i = 0 ; i < 1 ; i++){
            String temp1 = '000' + i;
            RESTOpportunityProductWrapperClass.prodWrap temp2  = new RESTOpportunityProductWrapperClass.prodWrap();
            temp2.ProductCode = '023216118306';
            temp2.AccountNumber = temp1;

            prdWrap.add(temp2);
        }

        List<Opportunity> opty = [SELECT Id FROM Opportunity LIMIT 1]; 

        reqWrap.HostSystem = 'EOB';
        reqWrap.OpportunityId = opty[0].id;
        reqWrap.Products = prdWrap;

        Test.startTest();

        RESTOpportunityProductUtil.Response resp = RESTOpportunityProductUtil.updateNewOppLineItem(reqWrap);

        Test.stopTest();
        
        
		// Account acc1= new Account();
		// acc1.Name ='Test';
		// insert acc1;
		
		// WSCustomerEdit.JsonAccount acc = new WSCustomerEdit.JsonAccount();
		// acc.id      = acc1.id;
		// acc.name    = 'NameTest';
		// acc.phone   = '1198785496';
		// acc.address = 'Rua x';
		// String myJSON = JSON.serialize(acc);
		

        // RestRequest request = new RestRequest();
        // request.requestUri ='https://tmbbank--devx.cs75.my.salesforce.com/services/apexrest/opportunity-product/updateProductFromHost';
        // request.httpMethod = 'PATCH';
		// request.requestBody = Blob.valueof(myJSON);
		
        // RestContext.request = request;
		// Account accObj = WSCustomerEdit.doPost();
		
    }
}