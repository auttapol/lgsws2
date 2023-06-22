@isTest
public class SmartBDM_MyLead_QuickCAController_Test {
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
	public static final Id Commercial_Account_ID = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Commercial Account').getRecordTypeId();
    public static RecordType CommercialLeadRecordType {
        get{
            if(CommercialLeadRecordType == null){
                CommercialLeadRecordType = [SELECT id,Name FROM RecordType 
                                        WHERE Name='Commercial Lead' 
                                        AND sObjectType='Lead' LIMIT 1];
            }
            return CommercialLeadRecordType;
        }
        set;
	}

	public static Lead CreateValidLead(Id OwnerID, Id accId){
        Lead leadRec = new lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'Passport ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Individual';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.RecordTypeId = CommercialLeadRecordType.id;
        leadRec.Interest_result__c = 'Yes';
        leadRec.OwnerID = OwnerID;
        leadRec.Account__c = accId;
        return leadRec;
    }

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

		Campaign masterC = RTL_TestUtility.createMasterCampaign('MasterCam1',
        	'D20171001',
        	'Exclusive',
        	'MB', User01
        	);
		insert masterC;

		RecordType rt = [SELECT id FROM recordType WHERE DeveloperName   = 'Exclusive_Campaign_Active' ];
		Campaign childC = RTL_TestUtility.createChildCampaign('ChildCam1','1', masterC , rt) ;
		insert childC;

		Account acct = RTL_TestUtility.createAccounts(1 , false).get(0);
		RecordType Existing_Customer = [SELECT Id FROM RecordType WHERE developername='Existing_Customer' AND SobjectType = 'Account' and IsActive = true LIMIT 1];
		acct.Customer_Type__c = 'Individual';
		acct.RecordType = Existing_Customer;
		acct.RecordTypeId = Existing_Customer.Id;
		insert acct;

		RecordType Commercial_Account = [SELECT Id FROM RecordType WHERE developername='Commercial_Account' AND SobjectType = 'Lead' and IsActive = true LIMIT 1];
		List<Lead> Lead_list = new List<Lead>();

		for (Integer i = 0; i < 100; i++ ) {
			Lead lead = CreateValidLead(User01.id, acct.id);
			lead.RecordType = Commercial_Account;
			lead.RecordTypeId = Commercial_Account.Id;
			if(Math.mod(i, 2) == 0){
				lead.Customer_Type__c = 'Individual';
			}else {
				lead.Customer_Type__c = 'Juristic';
			}
			
			lead.Primary_Campaign__c = childC.id;
			Lead_list.Add(lead);
		}
		insert Lead_list;

	}

	@isTest static void test_method_BDM_Lead_data() {
		Test.startTest();
		User user = [SELECT Id, Name FROM User WHERE Email = 'smartbdm@tmb.com.test' AND ProfileId =: BDM_PROFILE_ID LIMIT 1];
		System.runAs(user){
			Test.setCurrentPageReference(new PageReference('Page.BDM_Lead_list_mobile'));
		

			SmartBDM_MyLead_QuickCAController ext = new SmartBDM_MyLead_QuickCAController();
			Integer records = ext.records;
			Boolean isSF1 = ext.isSF1;
			ext.sortLeadColumn();
			ext.sortLeadColumn();
			ext.sortLeadColumn();

			ext.NextPage();
			ext.PreviousPage();

			ext.currentPage = -1;
			ext.PreviousPage();
			// ext.open_minicsv();
		}
        Test.stopTest();
	}
	
	@isTest static void test_method_getselectValues() {
		
		Test.startTest();
		User user = [SELECT Id, Name FROM User WHERE Email = 'smartbdm@tmb.com.test' AND ProfileId =: BDM_PROFILE_ID LIMIT 1];
		System.runAs(user){
			SmartBDM_MyLead_QuickCAController ext = new SmartBDM_MyLead_QuickCAController();
			Test.setCurrentPageReference(new PageReference('Page.BDM_Lead_list_mobile'));
			
			ext.getselectValues_customerType();
			ext.getselectValues_primaryCampaign();
			ext.searchKey = 'Indi';
			ext.filter_customerType = 'Individual';
			ext.filterCustomerType();
			// ext.filter_primaryCampaign = 'MasterCam1'
			ext.filter_primaryCampaign = '';
			ext.filterPrimaryCampaign();

		}
		Test.stopTest();

	}

	@isTest static void test_method_BDM_Lead_data_Negative() {
		Test.startTest();
		User user = [SELECT Id, Name FROM User WHERE Email = 'smartbdm@tmb.com.test' AND ProfileId =: BDM_PROFILE_ID LIMIT 1];
		System.runAs(user){

			Test.setCurrentPageReference(new PageReference('Page.BDM_Lead_list_mobile'));
			System.currentPageReference().getParameters().put('isdtp', 'p1');
			SmartBDM_MyLead_QuickCAController ext = new SmartBDM_MyLead_QuickCAController();
			Integer records = ext.records;
			Boolean isSF1 = ext.isSF1;
			Lead tmplead = ext.leads[0];
			delete tmplead;
			ext.resetShowingPages();
		}
        Test.stopTest();
	}
}