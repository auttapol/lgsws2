@isTest
private class RESTOpportunityControllerTest {
	public static final Id SYSTEM_ADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
	
	public static String dateString1;
	public static String dateString2;
	public static User sfextapi;
	public static User User01;
	public static User User02;
	public static RecordType Retail_Customer;

	static {
		TestUtils.createAppConfig();

		Datetime d = system.now();
		dateString1 = DateTime.newInstance(d.year(), d.month(), d.day()).format('yyyy-MM-dd');
		dateString2 = DateTime.newInstance(d.year(), d.month()+1, d.day()).format('yyyy-MM-dd');

		sfextapi = RESTOpportunityUtil.sfextapi;

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
	}
	
	@isTest static void testMethodGet() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/Opportunity/';  
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        String results = RESTOpportunityController.testReturn();

        Test.stopTest();

		// String now = String.valueOf(Datetime.now().dateGmt()) + 'T' + String.valueOf(Datetime.now().timeGmt().addHours(7) + '|');
		// System.assertEquals(now, results);
	}
	
	@isTest static void testCreateNewAccount() {
		RESTOpportunityUtil ext = new RESTOpportunityUtil();
		
		
		system.runAs(sfextapi){
			Test.startTest();
			RESTOpportunityUtil.Response results = RESTOpportunityController.createOpportunity(dateString1, dateString2, 'Submit to Credit Process', '01290000001AhOZAA0', 'Commercial  Customer 000658 SB', '', '211100000000000000000013290496', '0420181012000401', 'OLAP', 'Commercial', 'Customer 000658', 'Others', '8387637310402', '021124567', 'Individual');

			results = RESTOpportunityController.createOpportunity(dateString1, dateString2, 'Submit to Credit Process', '01290000001AhOZAA0', 'Commercial  Customer 000658 SB', '', '211100000000000000000013290496', '0420181012000401', 'OLAP', 'Commercial', 'Customer 000658', 'Others', '8387637310402', '021124567', 'Individual');
			Test.stopTest();
		}

        // RestRequest request = new RestRequest();
        // request.requestUri ='https://cs13.salesforce.com/services/apexrest/upsertaccount';
        // request.httpMethod = 'POST';
		// request.requestBody = Blob.valueof(myJSON);
		
        // RestContext.request = request;
		// Account accObj = WSCustomerEdit.doPost();
	}

	@isTest static void testDupTMBCustID() {
		List <Account> lstAccount = RTL_TestUtility.createAccounts(1, false);
		Account acc = lstAccount.get(0);
		acc.Customer_Type__c = 'Individual';
		acc.OwnerID = User01.id;
		acc.TMB_Customer_ID_PE__c = '001100000000000000000006163299';
		insert acc;

		
		system.runAs(sfextapi){
			Test.startTest();
			RESTOpportunityUtil.Response results = RESTOpportunityController.createOpportunity(dateString1, dateString2, 'Submit to Credit Process', '01290000001AhOZAA0', 'Commercial  Customer 000658 SB', '', '001100000000000000000006163299', '0420181012000401', 'OLAP', 'Commercial', 'Customer 000658', 'Others', '8387637310402', '021124567', 'Individual');
			Test.stopTest();
		}
	}

	@isTest static void testDupIDandIDtype() {
		List <Account> lstAccount = RTL_TestUtility.createAccounts(1, false);
		Account acc = lstAccount.get(0);
		acc.Customer_Type__c = 'Individual';
		acc.OwnerID = User01.id;
		acc.ID_Number_PE__c = '83402';
		acc.ID_Type_PE__c = 'Other ID';
		acc.RTL_NID__c = '83402';
		insert acc;

		system.runAs(sfextapi){
			Test.startTest();
			RESTOpportunityUtil.Response results = RESTOpportunityController.createOpportunity(dateString1, dateString2, 'Submit to Credit Process', '01290000001AhOZAA0', 'Commercial  Customer 000658 SB', '', '001100000000000000780006163299', '0420181012000401', 'OLAP', 'Commercial', 'Customer 000658', 'Other ID', '83402', '021124567', 'Individual');
			Test.stopTest();
		}
	}

	@isTest static void testCreateAccountFail() {
		system.runAs(sfextapi){
			Test.startTest();
			RESTOpportunityUtil.Response results = RESTOpportunityController.createOpportunity(dateString1, dateString2, 'Submit to Credit Process', '01290000001AhOZAA0', 'Commercial  Customer 000658 SB', '', '001100000000002600000006163299', '0420181012000401', 'OLAP', 'Commercial', 'Customer 000658', 'Citizen ID', '83402', '021124567', 'Individual');
			Test.stopTest();
		}
	}

	@isTest static void testSubFunction() {
		List <Account> lstAccount = RTL_TestUtility.createAccounts(1, false);
		Account acc = lstAccount.get(0);
		acc.Customer_Type__c = 'Individual';
		acc.OwnerID = User01.id;
		acc.ID_Number_PE__c = '83402';
		acc.ID_Type_PE__c = 'Other ID';
		acc.RTL_NID__c = '83402';
		insert acc;

		system.runAs(sfextapi){
			Test.startTest();
			RESTOpportunityUtil ext = new RESTOpportunityUtil();
			List<Account> accs = ext.getAccByID(acc.id);
			System.debug('accs');
			System.debug(accs);
			accs = ext.getAccByID('0010l0000072adBAAQ');
			System.debug('accs');
			System.debug(accs);

			Test.stopTest();
		}
	}

	@isTest static void testMethodPOSTInvalidData() {   
        Test.startTest();
		//expected_submit_date is Blank
        RESTOpportunityUtil.Response results = RESTOpportunityController.createOpportunity('', '2018-10-12', 'Submit to Credit Process', '01290000001AhOZAA0', 'Commercial  Customer 000658 SB', 'BDM007', '211100000000000000000013290496', '0420181012000401', 'OLAP', 'Commercial', 'Customer 000658', 'Citizen ID', '8387637310402', '021124567', 'Individual');

		//expected_complete_date is Blank
		results = RESTOpportunityController.createOpportunity('2018-10-12', '', 'Submit to Credit Process', '01290000001AhOZAA0', 'Commercial  Customer 000658 SB', 'BDM007', '211100000000000000000013290496', '0420181012000401', 'OLAP', 'Commercial', 'Customer 000658', 'Citizen ID', '8387637310402', '021124567', 'Individual');

		//stage is Blank
		results = RESTOpportunityController.createOpportunity('2018-10-12', '2018-10-12', '', '01290000001AhOZAA0', 'Commercial  Customer 000658 SB', 'BDM007', '211100000000000000000013290496', '0420181012000401', 'OLAP', 'Commercial', 'Customer 000658', 'Citizen ID', '8387637310402', '021124567', 'Individual');

		//opportunity_recordtype_id is Blank
		results = RESTOpportunityController.createOpportunity('2018-10-12', '2018-10-12', 'Submit to Credit Process', '', 'Commercial  Customer 000658 SB', 'BDM007', '211100000000000000000013290496', '0420181012000401', 'OLAP', 'Commercial', 'Customer 000658', 'Citizen ID', '8387637310402', '021124567', 'Individual');

		//opportunity_name is Blank
		results = RESTOpportunityController.createOpportunity('2018-10-12', '2018-10-12', 'Submit to Credit Process', '01290000001AhOZAA0', '', 'BDM007', '211100000000000000000013290496', '0420181012000401', 'OLAP', 'Commercial', 'Customer 000658', 'Citizen ID', '8387637310402', '021124567', 'Individual');

		//tmb_customer_id is Blank
		results = RESTOpportunityController.createOpportunity('2018-10-12', '2018-10-12', 'Submit to Credit Process', '01290000001AhOZAA0', 'Commercial  Customer 000658 SB', 'BDM007', '', '0420181012000401', 'OLAP', 'Commercial', 'Customer 000658', 'Citizen ID', '8387637310402', '021124567', 'Individual');

		//app_ref_no is Blank
		results = RESTOpportunityController.createOpportunity('2018-10-12', '2018-10-12', 'Submit to Credit Process', '01290000001AhOZAA0', 'Commercial  Customer 000658 SB', 'BDM007', '211100000000000000000013290496', '', 'OLAP', 'Commercial', 'Customer 000658', 'Citizen ID', '8387637310402', '021124567', 'Individual');

		//leadsource is Blank
		results = RESTOpportunityController.createOpportunity('2018-10-12', '2018-10-12', 'Submit to Credit Process', '01290000001AhOZAA0', 'Commercial  Customer 000658 SB', 'BDM007', '211100000000000000000013290496', '0420181012000401', '', 'Commercial', 'Customer 000658', 'Citizen ID', '8387637310402', '021124567', 'Individual');

		//customer_name is Blank
		results = RESTOpportunityController.createOpportunity('2018-10-12', '2018-10-12', 'Submit to Credit Process', '01290000001AhOZAA0', 'Commercial  Customer 000658 SB', 'BDM007', '211100000000000000000013290496', '0420181012000401', 'OLAP', '', 'Customer 000658', 'Citizen ID', '8387637310402', '021124567', 'Individual');

		//customer_surname is Blank
		results = RESTOpportunityController.createOpportunity('2018-10-12', '2018-10-12', 'Submit to Credit Process', '01290000001AhOZAA0', 'Commercial  Customer 000658 SB', 'BDM007', '211100000000000000000013290496', '0420181012000401', 'OLAP', 'Commercial', '', 'Citizen ID', '8387637310402', '021124567', 'Individual');

		//customer_id_type is Blank
		results = RESTOpportunityController.createOpportunity('2018-10-12', '2018-10-12', 'Submit to Credit Process', '01290000001AhOZAA0', 'Commercial  Customer 000658 SB', 'BDM007', '211100000000000000000013290496', '0420181012000401', 'OLAP', 'Commercial', 'Customer 000658', '', '8387637310402', '021124567', 'Individual');

		//customer_id_number is Blank
		results = RESTOpportunityController.createOpportunity('2018-10-12', '2018-10-12', 'Submit to Credit Process', '01290000001AhOZAA0', 'Commercial  Customer 000658 SB', 'BDM007', '211100000000000000000013290496', '0420181012000401', 'OLAP', 'Commercial', 'Customer 000658', 'Citizen ID', '', '021124567', 'Individual');

		//customer_mobile_number is Blank
		results = RESTOpportunityController.createOpportunity('2018-10-12', '2018-10-12', 'Submit to Credit Process', '01290000001AhOZAA0', 'Commercial  Customer 000658 SB', 'BDM007', '211100000000000000000013290496', '0420181012000401', 'OLAP', 'Commercial', 'Customer 000658', 'Citizen ID', '8387637310402', '', 'Individual');

		//customer_type is Blank
		results = RESTOpportunityController.createOpportunity('2018-10-12', '2018-10-12', 'Submit to Credit Process', '01290000001AhOZAA0', 'Commercial  Customer 000658 SB', 'BDM007', '211100000000000000000013290496', '0420181012000401', 'OLAP', 'Commercial', 'Customer 000658', 'Citizen ID', '8387637310402', '021124567', '');

        Test.stopTest();
	}
}