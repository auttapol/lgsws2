@isTest
private class RTL_GenerateTaskBatchScheduled_Test {
	public static final Id SYSTEM_ADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

	// @isTest static void test_method_one() {
	// 	// Implement test code
	// }

	// @isTest static void test_method_two() {
	// 	// Implement test code
	// }
	@TestSetup
	static void makeData() {
		TestUtils.createAppConfig();
		List < AppConfig__c > mc = new List < AppConfig__c > ();
		mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
		insert mc;

		RTL_Branch_Manager_Title__c branchTitle = new RTL_Branch_Manager_Title__c(Name = 'Branch Manager', RTL_Value__c = 'Branch Manager');
		insert branchTitle;

		Branch_and_zone__c bz = new Branch_and_zone__c();
		bz.Branch_Code__c = '611';
		insert bz;

		List<User> userList = RTL_TestUtility.createUsers(2, 'TestMock', 'TaskBatch', 'taskbatch@tmb.com.test', false);

		User User01 = userList.get(0);
		User01.ProfileId = SYSTEM_ADMIN_PROFILE_ID;
		User01.isActive = true;
		User01.title = 'Branch Manager';
		User01.RTL_Branch_Code__c = bz.Branch_Code__c;
		User01.Employee_ID__c = '123456';
		insert User01;

		User User02 = userList.get(1);
		User02.ProfileId = SYSTEM_ADMIN_PROFILE_ID;
		User02.isActive = false;
		User02.title = 'Branch Manager';
		User02.RTL_Branch_Code__c = bz.Branch_Code__c;
		User02.Employee_ID__c = '123457';
		insert User02;

		RecordType Retail_Customer = [SELECT Id FROM RecordType WHERE developername = 'Retail_Customer'
			AND SobjectType = 'Account'
			and IsActive = true LIMIT 1
		];

		List <Account> lstAccount = RTL_TestUtility.createAccounts(75, false);
		for (Integer i = 0; i < lstAccount.size(); i++) {
			Account acc = lstAccount.get(i);
			// acc.Name = 'Name' + i;
			if (math.mod(i, 2) == 0) {
				acc.Customer_Type__c = 'Individual';
				acc.OwnerID = User01.id;
				acc.RecordType = Retail_Customer;
				acc.RecordTypeId = Retail_Customer.Id;
				acc.Operating_Model__c = '1.Monthly';
				acc.Next_Generate_task_date__c = System.today();
				acc.RTL_Wealth_RM__c = User01.id;
			}else if(math.mod(i, 3)== 0){
				acc.Customer_Type__c = 'Individual';
				acc.OwnerID = User01.id;
				acc.RecordType = Retail_Customer;
				acc.RecordTypeId = Retail_Customer.Id;
				acc.Operating_Model__c = '2.Bi_Monthly';
				acc.Next_Generate_task_date__c = System.today();
				acc.RTL_Wealth_RM__c = User01.id;
			}else if(math.mod(i, 5)== 0){
				acc.Customer_Type__c = 'Individual';
				acc.OwnerID = User01.id;
				acc.RecordType = Retail_Customer;
				acc.RecordTypeId = Retail_Customer.Id;
				acc.Operating_Model__c = '2.Bi_Monthly';
				acc.Next_Generate_task_date__c = System.today();
				acc.RTL_Wealth_RM__c = User02.id;
			}
			else{
				acc.Customer_Type__c = 'Individual';
				acc.OwnerID = User01.id;
				acc.RecordType = Retail_Customer;
				acc.RecordTypeId = Retail_Customer.Id;
				acc.Operating_Model__c = '6.Weekly';
				acc.Next_Generate_task_date__c = System.today();
				acc.RTL_Wealth_RM__c = User01.id;
			}
			// lstAccount.add(acc);
		}
		insert lstAccount;

		Operating_Model__c opm = new Operating_Model__c();
		opm.Days_Month__c = 'Month';
		opm.Day_of_the_month__c = 1;
		opm.Duration__c = 1;
		opm.Day_of_due_date__c = 15;
		opm.Operating_Model_Name__c = '1.Monthly';

		insert opm;

		opm = new Operating_Model__c();
		opm.Days_Month__c = 'Days';
		opm.Duration__c = 2;
		opm.Day_of_due_date__c = 15;
		opm.Operating_Model_Name__c = '6.Weekly';

		insert opm;
		
		opm = new Operating_Model__c();
		opm.Days_Month__c = 'Month';
		opm.Day_of_the_month__c = 31;
		opm.Duration__c = 3;
		opm.Day_of_due_date__c = 15;
		opm.Operating_Model_Name__c = '2.Bi_Monthly';

		insert opm;
	}

	@isTest
	static void testRunBatch() {
		Test.startTest();
		Date d = System.today();
		Datetime myDT = datetime.newInstance(d.year(), d.month(),d.day());
		String toDay = myDT.format('yyyy-MM-dd');
		
		String q = 'SELECT Id, Name, OwnerId, Owner.Zone_Code__c, Owner.Region_Code__c, Operating_Model__c, Next_Generate_task_date__c, Last_Generate_task_date__c, RTL_Wealth_RM__c FROM Account WHERE RTL_Wealth_RM__c != null AND Next_Generate_task_date__c = ' + toDay;


		RTL_GenerateTaskBatch b = new RTL_GenerateTaskBatch(q);
		Database.executebatch(b);

		Map<String, Operating_Model__c> OPModelMap;
		Test.stopTest();
		OPModelMap = b.OPModelMap;
	}

}