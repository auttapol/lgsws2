@isTest
public class SmartBDM_MyCustomer_QuickCACtlr_Test {
    public static final Id BDM_PROFILE_ID {
        get{
            if(BDM_PROFILE_ID == null){
                BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;
            }
            return BDM_PROFILE_ID;
        }
        set;
    }
	// public static final Id SE_SALES_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;
	public static final Id Existing_Customer_ID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Existing Customer').getRecordTypeId();
	public static final Id Prospect_ID = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
	@testSetup static void setup() {
		
		TestUtils.createAppConfig();

		List<AppConfig__c> mc = new List<AppConfig__c> ();
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        insert mc;
		
		RTL_Branch_Manager_Title__c branchTitle = new RTL_Branch_Manager_Title__c(Name='Branch Manager',RTL_Value__c='Branch Manager');
		insert branchTitle;

		Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '611';
        insert bz;

		User User01 = RTL_TestUtility.createUsers(1, 'TestMock', 'SmartBDM', 'smartbdm@tmb.com.test', false).get(0);
		User01.ProfileId = BDM_PROFILE_ID;
		User01.isActive = true;
		User01.title = 'Branch Manager';
		User01.RTL_Branch_Code__c = bz.Branch_Code__c;
		User01.Employee_ID__c = '123456';
		insert User01;
		
		Integer length = 300; 
		// List<Account> acct = RTL_TestUtility.createAccounts(100 , false);
		List<Account> acct = TestUtils.createAccounts(length, 'SmartBDM', 'Individual', false);
		RecordType Existing_Customer = [SELECT Id FROM RecordType WHERE developername='Existing_Customer' AND SobjectType = 'Account' and IsActive = true LIMIT 1];
		RecordType Prospect = [SELECT Id FROM RecordType WHERE developername='Prospect' and SobjectType = 'Account' AND IsActive = true LIMIT 1];
		for (Integer i = 0; i < length; i++ ) {
			Account acc1 = acct.get(i);
			// acc1.IsDisqualified__c = true;
			// acc1.RTL_RM_Name__c = 'TestMock';
			// acc1.RTL_Commercial_RM__c = User01.Id;
			if(Math.mod(i, 2) == 0){
				acc1.Customer_Type__c = 'Individual';
				acc1.RecordType = Existing_Customer;
				acc1.RecordTypeId = Existing_Customer.Id;
			}else {
			   acc1.Customer_Type__c = 'Juristic';
			   acc1.RecordType = Prospect;
			   acc1.RecordTypeId = Prospect.Id;
			}
			acc1.OwnerID = User01.id;
		}
		insert acct;

        Opportunity oppty = TestUtils.createOpportunity(1, acct.get(0).Id, false).get(0);
        oppty.OwnerId = User01.Id;
        oppty.RecordTypeId = Smart_BDM_Constant.SE_CREDIT_PRODUCT_RECORDTYPE_ID_OPPTY;
        insert oppty;
		// Account test_acc = [SELECT RecordTypeId, RecordType.Name FROM Account WHERE Id =: acct.get(0).id LIMIT 1];
		// System.debug(Existing_Customer_ID);
		// System.debug(acct.get(0));
		// System.debug(test_acc.RecordTypeId);
		// System.debug(test_acc.RecordType.Name);
	}

	@isTest static void test_method_BDM_Customer_data() {
		Test.startTest();
		User user = [SELECT Id, Name FROM User WHERE Email = 'smartbdm@tmb.com.test' AND ProfileId =: BDM_PROFILE_ID LIMIT 1];
		System.runAs(user){
			Test.setCurrentPageReference(new PageReference('Page.BDM_Customer_list_mobile'));
			SmartBDM_MyCustomer_QuickCAController ext = new SmartBDM_MyCustomer_QuickCAController();
			Integer records = ext.records;
			Boolean isSF1 = ext.isSF1;
			ext.sortAccColumn();
			ext.sortAccColumn();
			ext.sortAccColumn();

			ext.NextPage();
			ext.PreviousPage();

			ext.currentPage = -1;
			ext.PreviousPage();

            Account acct = [SELECT Id FROM Account WHERE OwnerId =: user.Id LIMIT 1];
            SmartBDM_MyCustomer_QuickCAController.isHasOpportunity(acct.Id);
            Opportunity oppty = [SELECT AccountId FROM Opportunity WHERE AccountId != null LIMIT 1];
			SmartBDM_MyCustomer_QuickCAController.isHasOpportunity(oppty.AccountId);
		}

        Test.stopTest();
	}
	
	@isTest static void test_method_getselectValues() {
		Test.startTest();
		User user = [SELECT Id, Name FROM User WHERE Email = 'smartbdm@tmb.com.test' AND ProfileId =: BDM_PROFILE_ID LIMIT 1];
		System.runAs(user){			
			SmartBDM_MyCustomer_QuickCAController ext = new SmartBDM_MyCustomer_QuickCAController();
			Test.setCurrentPageReference(new PageReference('Page.BDM_Customer_list_mobile'));
			ext.getselectValues();
			ext.filterTypeId = 'Individual';
			ext.searchKey = 'Indi';
			ext.filterCustomerType();
		}
		Test.stopTest();
	}

	@isTest static void test_method_BDM_Customer_data_Negative() {
		Test.startTest();
		User user = [SELECT Id, Name FROM User WHERE Email = 'smartbdm@tmb.com.test' AND ProfileId =: BDM_PROFILE_ID LIMIT 1];
		System.runAs(user){

			Test.setCurrentPageReference(new PageReference('Page.BDM_Customer_list_mobile'));
			System.currentPageReference().getParameters().put('isdtp', 'p1');
			SmartBDM_MyCustomer_QuickCAController ext = new SmartBDM_MyCustomer_QuickCAController();
			Integer records = ext.records;
			Boolean isSF1 = ext.isSF1;
			Account acct = ext.accounts[0];
			delete acct;
			ext.resetShowingPages();

            ext.refAccountId = ext.refAccountId;
            ext.refType = ext.refType;
		}
        Test.stopTest();
	}
}