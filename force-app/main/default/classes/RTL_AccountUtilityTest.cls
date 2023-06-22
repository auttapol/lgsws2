@isTest
public class RTL_AccountUtilityTest {

	private static final string SECTION_ACC = 'ComCust:Account Information';
	private static final string SECTION_ACC2 = 'ComCust:Address Information';
	private static final string SECTION_ACC3 = 'ComCust:Campaign Lead History';

	private static final string SECTION_CONTACT = 'ComCust:Contacts';

	private static final string SECTION_CUSTOM = 'ComCust:Other Information';
    
    static Account mRetailCustomerAcc;
    static User m2ndBranchManagerUser;
    static User mSalesUser;
    static User mZoneManagerUser;
    static Branch_and_Zone__c mMostOperBranch;

	static void setupData() 
	{
		TestUtils.createAppConfig();

        RTL_Branch_Manager_Title__c branchTitle = new RTL_Branch_Manager_Title__c(Name='Branch Manager',RTL_Value__c='Branch Manager');
		insert branchTitle;

		Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
		RecordType rc = [ SELECT id FROM RecordType WHERE SobjectType = 'Account' AND name = 'Existing Customer' ];

		User su = TestUtils.createUsers(1,'AccountOwner', 'Ownertest','OwnerIDtest@tmbbank.com', false).get(0);
		su.Employee_ID__c = '11111';
		su.ProfileId = userinfo.getProfileId();
		insert su;
        
		Account acc1 = TestUtils.createAccounts(1,'TESTACCOUNT','Individual', false).get(0);
		acc1.RTL_Email_2__c = 'test01@tmbbank.com';
		acc1.RecordType = rc;
		acc1.RTL_RM_Name__c = '11111';
		insert acc1;

		Contact cont = TestUtils.createContacts(1, acc1.id, false).get(0);
		cont.Primary_Phone_Ext_PE__c = '0817161233';
		insert cont;

		//String REFER_WITHIN_COMMERCIAL_ID = Schema.SObjectType.RTL_Referral__c.getRecordTypeInfosByName().get('Refer within Commercial').getRecordTypeId();

		//List<RTL_Referral__c> referralList = TestUtility_Referral.createReferralsWithoutAccount(1,null,'SmartBiz','Sell (เพื่อนำเสนอขาย)',false);
  //      referralList[0].RTL_Preferred_Branch_Code__c = '001';
  //      referralList[0].RTL_Sub_Product__c = '';
  //      referralList[0].RTL_Channel_Segment__c = 'Web';
  //      referralList[0].RTL_Customer_Segment__c = 'SE';
  //      referralList[0].RTL_Campaign_Reference__c = 'Normal Request';
  //      referralList[0].RecordTypeId = REFER_WITHIN_COMMERCIAL_ID;

  //      insert referralList;


		List<Data_Security_Matrix__c> dscList = new List<Data_Security_Matrix__c>();
		Data_Security_Matrix__c  dmc1 = new Data_Security_Matrix__c (
			Profile_Name__c = userProfile.name,
			//Record_Type__c = 'Existing Customer',
			Section_Name__c = SECTION_ACC,
			Access_Type__c = 'All'
			);

		Data_Security_Matrix__c  dmc2 = new Data_Security_Matrix__c (
			Profile_Name__c = userProfile.name,
			//Record_Type__c = 'Existing Customer',
			Section_Name__c = SECTION_ACC2,
			Access_Type__c = 'No Access'
			);

		Data_Security_Matrix__c  dmc3 = new Data_Security_Matrix__c (
			Profile_Name__c = userProfile.name,
			//Record_Type__c = 'Existing Customer',
			Section_Name__c = SECTION_ACC3,
			Access_Type__c = 'Authorize Only'
			);

		Data_Security_Matrix__c  dmc4 = new Data_Security_Matrix__c (
			Profile_Name__c = userProfile.name,
			//Record_Type__c = 'Existing Customer',
			Section_Name__c = SECTION_CONTACT,
			Access_Type__c = 'Authorize Only'
			);

		Data_Security_Matrix__c  dmc5 = new Data_Security_Matrix__c (
			Profile_Name__c = userProfile.name,
			//Record_Type__c = 'Existing Customer',
			Section_Name__c = SECTION_CUSTOM,
			Access_Type__c = 'Authorize Only'
			);


		dscList.add(dmc1);
		dscList.add(dmc2);
		dscList.add(dmc3);
		dscList.add(dmc4);
		dscList.add(dmc5);

		insert dscList;

	}
    
    static void setupData_ForGetWealthRM()
    {
        User mSYSAdmin = [SELECT Id, Name FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1][0];
        
        System.runAs(mSYSAdmin)
        {
            AppConfig__c Aconfig = new AppConfig__c();
            Aconfig.Name = 'runtrigger';
            Aconfig.Value__c = 'true';
            insert Aconfig;  
            
            RTL_Branch_Manager_Title__c branchTitle = new RTL_Branch_Manager_Title__c(Name='Branch Manager',RTL_Value__c='Branch Manager (Service and Relationship)');
            insert branchTitle;
        }
        
        //Query the TMB Retail Channel Sales Profile ID
        Id TMBRetailProfileId = [SELECT Id FROM Profile WHERE Name = 'TMB Retail Channel Sales'][0].Id;
        
        //Create a new Zone Manager Role
        /*UserRole mZoneManagerRole = new UserRole(Name= 'Zone-9999');
        
        //Create a new Branch Manager Role
        UserRole mBranchManagerRole = new UserRole(Name= 'BR-MGR-Zone-9999');  
        
        //Create a new Sales Role
        UserRole mSalesRole = new UserRole(Name= 'BR-Sales-Zone-9999');*/

        //insert new List<UserRole>{mBranchManagerRole, mZoneManagerRole, mSalesRole};
        
        UserRole mZoneManagerRole = [SELECT Id, Name FROM UserRole WHERE Name = 'Zone-6930'];
        UserRole mBranchManagerRole = [SELECT Id, Name FROM UserRole WHERE Name = 'BR-MGR-Zone-6930'];
        UserRole mSalesRole = [SELECT Id, Name FROM UserRole WHERE Name = 'BR-Sales-Zone-6930'];
        
        //Get Account - Retail Customer Record Type
        Id RetailCustomerRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        
        //Create a new Zone Manager User with TMB Retail Channel Sales Profile
        mZoneManagerUser = new User();
        mZoneManagerUser.ProfileId = TMBRetailProfileId;
        mZoneManagerUser.FirstName = 'Test Zone FirstName221118';
        mZoneManagerUser.LastName = 'Test Zone LastName221118';
        mZoneManagerUser.Email = 'test_zonemanager221118@test.com';
        mZoneManagerUser.Username = 'test_zonemanager221118@test.com';
        mZoneManagerUser.CompanyName = 'TEST';
        mZoneManagerUser.Title = 'Zone Manager (Branch Service and Relationship)';
        mZoneManagerUser.Alias = 'zonem';
        mZoneManagerUser.TimeZoneSidKey = 'America/Los_Angeles';
        mZoneManagerUser.EmailEncodingKey = 'UTF-8';
        mZoneManagerUser.LanguageLocaleKey = 'en_US';
        mZoneManagerUser.LocaleSidKey = 'en_US';
        mZoneManagerUser.Zone_Code__c = '9999';
        mZoneManagerUser.UserRoleId = mZoneManagerRole.Id;
        insert mZoneManagerUser;
        
        //Create a new 1st Branch Manager User with TMB Retail Channel Sales Profile
        User m1stBranchManagerUser = new User();
        m1stBranchManagerUser.IsActive = FALSE;
        m1stBranchManagerUser.ProfileId = TMBRetailProfileId;
        m1stBranchManagerUser.ManagerId = mZoneManagerUser.Id;
        m1stBranchManagerUser.FirstName = 'Test BranchM1 FirstName221118';
        m1stBranchManagerUser.LastName = 'Test BranchM1 LastName221118';
        m1stBranchManagerUser.Email = 'test_1stbranchmanager221118@test.com';
        m1stBranchManagerUser.Username = 'test_1stbranchmanager221118@test.com';
        m1stBranchManagerUser.CompanyName = 'TEST';
        m1stBranchManagerUser.Title = 'Branch Manager (Service and Relationship)';
        m1stBranchManagerUser.Alias = 'branch1';
        m1stBranchManagerUser.TimeZoneSidKey = 'America/Los_Angeles';
        m1stBranchManagerUser.EmailEncodingKey = 'UTF-8';
        m1stBranchManagerUser.LanguageLocaleKey = 'en_US';
        m1stBranchManagerUser.LocaleSidKey = 'en_US';
        m1stBranchManagerUser.RTL_Branch_Code__c = '999';
        m1stBranchManagerUser.UserRoleId = mBranchManagerRole.Id;
        insert m1stBranchManagerUser;
        	
        //Create a new 2nd Branch Manager User with TMB Retail Channel Sales Profile
        m2ndBranchManagerUser = new User();
        m2ndBranchManagerUser.ProfileId = TMBRetailProfileId;
        m2ndBranchManagerUser.ManagerId = mZoneManagerUser.Id;
        m2ndBranchManagerUser.FirstName = 'Test BranchM2 FirstName221118';
        m2ndBranchManagerUser.LastName = 'Test BranchM2 LastName221118';
        m2ndBranchManagerUser.Email = 'test_2ndbranchmanager221118@test.com';
        m2ndBranchManagerUser.Username = 'test_2ndbranchmanager221118@test.com';
        m2ndBranchManagerUser.CompanyName = 'TEST';
        m2ndBranchManagerUser.Title = 'Branch Manager (Service and Relationship)';
        m2ndBranchManagerUser.Alias = 'branch2';
        m2ndBranchManagerUser.TimeZoneSidKey = 'America/Los_Angeles';
        m2ndBranchManagerUser.EmailEncodingKey = 'UTF-8';
        m2ndBranchManagerUser.LanguageLocaleKey = 'en_US';
        m2ndBranchManagerUser.LocaleSidKey = 'en_US';
        m2ndBranchManagerUser.RTL_Branch_Code__c = '999';
        m2ndBranchManagerUser.UserRoleId = mBranchManagerRole.Id;
        //insert new List<User>{m1stBranchManagerUser, m2ndBranchManagerUser};
        
        //Create a new Retail Channel Sales User
        mSalesUser = new User();
        mSalesUser.ProfileId = TMBRetailProfileId;
        mSalesUser.ManagerId = m1stBranchManagerUser.Id;
        mSalesUser.FirstName = 'Test Sales FirstName221118';
        mSalesUser.LastName = 'Test Sales LastName221118';
        mSalesUser.Email = 'test_sales221118@test.com';
        mSalesUser.Username = 'test_sales221118@test.com';
        mSalesUser.CompanyName = 'TEST';
        mSalesUser.Title = 'Personal Banker Authorized';
        mSalesUser.Alias = 'sales9';
        mSalesUser.TimeZoneSidKey = 'America/Los_Angeles';
        mSalesUser.EmailEncodingKey = 'UTF-8';
        mSalesUser.LanguageLocaleKey = 'en_US';
        mSalesUser.LocaleSidKey = 'en_US';
        mSalesUser.RTL_Branch_Code__c = '999';
        mSalesUser.UserRoleId = mSalesRole.Id;
        
        
        
        //Create a new Account - Retail Customer Record Type
        mRetailCustomerAcc = new Account();
        mRetailCustomerAcc.Name = 'Test Account Name';
        mRetailCustomerAcc.RecordTypeId = RetailCustomerRecordTypeID;
        mRetailCustomerAcc.RTL_RM_Name__c = '00999';
        mRetailCustomerAcc.ID_Type_PE__c = 'Other ID';
        mRetailCustomerAcc.ID_Number_PE__c = '8989';
        mRetailCustomerAcc.Mobile_Number_PE__c = '0991223344';
        

        mMostOperBranch = new Branch_and_zone__c();
        mMostOperBranch.Name = 'Test Branch Zone';
        mMostOperBranch.Branch_Code__c = '999';
    }

	@isTest 
    static void verifyFieldSecurity_Test_ObjIdNull() 
    {
        setupData();
    	User u = [SELECT id,ProfileId From User where Email = 'OwnerIDtest@tmbbank.com'];
    	Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:u.ProfileId LIMIT 1];
    	
    	Id accountId = null;

    	system.runAs(u)
    	{
			Boolean isAccessibleCampHist = RTL_AccountUtility.verifyFieldSecurity(SECTION_ACC,userProfile.name,accountId );
		}
    }

	@isTest 
    static void verifyFieldSecurity_Test_All() 
    {
        setupData();
    	User u = [SELECT id,ProfileId From User where Email = 'OwnerIDtest@tmbbank.com'];
    	Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:u.ProfileId LIMIT 1];

    	Account account = [SELECT id FROM Account WHERE RTL_Email_2__c = 'test01@tmbbank.com'];

    	Id accountId = account.id;

    	system.runAs(u)
    	{
			Boolean isAccessibleCampHist = RTL_AccountUtility.verifyFieldSecurity(SECTION_ACC,userProfile.name,accountId );
		}
    }

    @isTest 
    static void verifyFieldSecurity_Test_NoAccess() 
    {
        setupData();
    	Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];

    	Account account = [SELECT id FROM Account WHERE RTL_Email_2__c = 'test01@tmbbank.com'];

    	Id accountId = account.id;
		Boolean isAccessibleCampHist = RTL_AccountUtility.verifyFieldSecurity(SECTION_ACC2,userProfile.name,accountId );
    }

    @isTest 
    static void verifyFieldSecurity_Test_Authorized() 
    {
        setupData();
    	Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];

    	Account account = [SELECT id FROM Account WHERE RTL_Email_2__c = 'test01@tmbbank.com'];

    	Id accountId = account.id;
		Boolean isAccessibleCampHist = RTL_AccountUtility.verifyFieldSecurity(SECTION_ACC3,userProfile.name,accountId );
    }


    @isTest 
    static void verifyFieldSecurity_Test_Contact() 
    {
        setupData();
    	User u = [SELECT id,ProfileId From User where Email = 'OwnerIDtest@tmbbank.com'];
    	Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:u.ProfileId LIMIT 1];

    	Contact contact = [SELECT id FROM Contact WHERE Primary_Phone_Ext_PE__c = '0817161233'];

    	Id contactId = contact.id;

    	system.runAs(u)
    	{
			Boolean isAccessibleCampHist = RTL_AccountUtility.verifyFieldSecurity(SECTION_CONTACT,userProfile.name,contactId );
		}
    }
    
    static testMethod void testGetWealthRM_PositiveCase_BranchManagerMoreThanOne()
    {
        Test.startTest();
        	setupData_ForGetWealthRM();
        	insert m2ndBranchManagerUser;
        	System.runAs(mSalesUser)
            {
            	insert mRetailCustomerAcc;
            }

            Set<Id> setAssignBRCId = new Set<Id>();
            setAssignBRCId.add(m2ndBranchManagerUser.Id);
            RTL_AccountUtility.generateUserMapId(setAssignBRCId);
        
        	String WealthRMID = RTL_AccountUtility.getWealth_RM(mRetailCustomerAcc);
        	//Wealth RM should be 1st Branch Manager
        	// System.assertEquals(WealthRMID, String.valueOf(m2ndBranchManagerUser.Id));
        Test.stopTest();
    }
    
    static testMethod void testGetWealthRM_NegativeCase_AllBranchManagerInactive()
    {
        Test.startTest();
        	setupData_ForGetWealthRM();
        	
        	m2ndBranchManagerUser.IsActive = FALSE;
        	insert m2ndBranchManagerUser;
        
        	System.runAs(mSalesUser)
            {
            	insert mRetailCustomerAcc;
            }

            Set<Id> setAssignBRCId = new Set<Id>();
            setAssignBRCId.add(m2ndBranchManagerUser.Id);
            RTL_AccountUtility.generateUserMapId(setAssignBRCId);

        	//Wealth RM should be Zone Manager
        	String WealthRMID = RTL_AccountUtility.getWealth_RM(mRetailCustomerAcc);
        	//System.assertEquals(WealthRMID, String.valueOf(mZoneManagerUser.Id));
        Test.stopTest();
    }

    static testMethod void testGetWealthRM_assignBRCActive()
    {
        Test.startTest();
        	setupData_ForGetWealthRM();
        	
        	// m2ndBranchManagerUser.IsActive = FALSE;
        	insert m2ndBranchManagerUser;
        
        	System.runAs(mSalesUser)
            {
                mRetailCustomerAcc.RTL_Assigned_BRC__c = m2ndBranchManagerUser.Id;
                insert mRetailCustomerAcc;
            }


            Set<Id> setAssignBRCId = new Set<Id>();
            setAssignBRCId.add(m2ndBranchManagerUser.Id);
            RTL_AccountUtility.generateUserMapId(setAssignBRCId);

            // update mRetailCustomerAcc;

        	//Wealth RM should be Zone Manager
        	String WealthRMID = RTL_AccountUtility.getWealth_RM(mRetailCustomerAcc);
        	//System.assertEquals(WealthRMID, String.valueOf(mZoneManagerUser.Id));
        Test.stopTest();
    }

    static testMethod void testGetWealthRM_mostOperActive()
    {
        Test.startTest();
        	setupData_ForGetWealthRM();
        	
        	// m2ndBranchManagerUser.IsActive = FALSE;
        	insert m2ndBranchManagerUser;

        	System.runAs(mSalesUser)
            {
                mMostOperBranch.RTL_Branch_Manager_User__c = m2ndBranchManagerUser.Id;
                insert mMostOperBranch;

                mRetailCustomerAcc.RTL_Most_Operating_Branch__c = mMostOperBranch.Id;
                insert mRetailCustomerAcc;
            }

            Set<Id> setMostOprId = new Set<Id>();
            setMostOprId.add(mMostOperBranch.Id);
            RTL_AccountUtility.generateBranchZoneMapId(setMostOprId);

        	//Wealth RM should be Branch and Zone Manager
        	String WealthRMID = RTL_AccountUtility.getWealth_RM(mRetailCustomerAcc);
        	// System.assertEquals(WealthRMID, mMostOperBranch.RTL_Branch_Manager_User__c);
        Test.stopTest();
    }

  //  @isTest 
  //  static void verifyFieldSecurity_Test_Custom() 
  //  {
  //  	//User u = [SELECT id,ProfileId From User where Email = 'OwnerIDtest@tmbbank.com'];
  //  	//Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:u.ProfileId LIMIT 1];

  //  	User retailWithBranchUser = RTL_TestUtility.createRetailTestUserWithBranch(true);

  //  	RTL_Referral__c custom  = [SELECT id FROM RTL_Referral__c limit 1];

  //  	Id customId = custom.id;

  //  	system.runAs(retailWithBranchUser)
  //  	{
		//	Boolean isAccessibleCampHist = RTL_AccountUtility.verifyFieldSecurity(SECTION_CUSTOM, retailWithBranchUser.ProfileId ,customId );
		//}
  //  }
}