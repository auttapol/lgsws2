@IsTest
public class TestRestReferralWebService{
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

	public static testmethod void testCreateReferral() {
		Map<String,String> jsonInput  = new Map<String,String>();
		Map<String,String> recordType = new Map<String,String>();

		recordType.put('Name','Refer to Commercial');

		jsonInput.put('RTL_FirstName__c','RTL_FirstName__c');

		RESTReferralWebservice.createReferral(jsonInput,recordType);

	}

}