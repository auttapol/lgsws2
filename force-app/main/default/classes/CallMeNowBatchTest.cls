@isTest
private class CallMeNowBatchTest {

	static List<sObject> ls;
    static List<Account> acctList;
    static List<Lead> leadList;
    static Map<String, Group> queueMap;
    static List<Branch_And_Zone__c> branchAndZoneList;
    static List<RTL_Product_Master__c> retailProductMasterList;
    static List<RTL_Referral__c> referralList;
    static List<Opportunity> opportunityList;
    static User retailWithBranchUser;
    static User rmcUser;
    static User bdmUser;
    static User adminUser;
    static final String REFER_WITHIN_COMMERCIAL_ID;
    static final String REFER_TO_COMMERCIAL_ID;

    static {
        TestUtils.createAppConfig();
        TestUtility_Referral.createAppConfigReferralAssignment();
        TestUtility_Referral.createReferralAssignment();
        branchAndZoneList = RTL_TestUtility.createBranchZone(9,true);
        retailProductMasterList = RTL_TestUtility.createRetailProducts(true);
        retailWithBranchUser = RTL_TestUtility.createRetailTestUserWithBranch(true);
        adminUser = TestUtils.createUsers(1,'USERADMIN','TESTCLASS','test_TMB@tmbbank.com',true)[0];
        acctList = RTL_TestUtility.createAccounts(2,true);
        // update acct[0] as wealth account
        acctList[0].RTL_RM_Name__c = '00001';
        update acctList[0];
        
        RTL_Branch_Manager_Title__c branchTitle = new RTL_Branch_Manager_Title__c(Name='Branch Manager',RTL_Value__c='Branch Manager');
        insert branchTitle;
        //ls = Test.loadData(Branch_And_Zone__c.sObjectType, 'BranchAndZoneMaster');
        ID RMC_ROLE_ID = [SELECT Id FROM UserRole WHERE Name LIKE '%RMC%' LIMIT 1].id;
        System.debug('RMC ROLE ID '+RMC_ROLE_ID);
        
        queueMap = new Map<String, Group>();
        for(Group queue : [Select Id, Name, DeveloperName from Group where Type = 'Queue'])
            queueMap.put(queue.DeveloperName, queue);
        
        System.runAs(adminUser){
            //create rmc user for test
            rmcUser = TestUtility_Referral.createRMCTestUser(true);
            //create bdm user for test 
            bdmUser = TestUtility_Referral.createBDMTestUser(true);
        }

        REFER_WITHIN_COMMERCIAL_ID = Schema.SObjectType.RTL_Referral__c.getRecordTypeInfosByName().get('Refer within Commercial').getRecordTypeId();
        REFER_TO_COMMERCIAL_ID = Schema.SObjectType.RTL_Referral__c.getRecordTypeInfosByName().get('Refer to Commercial').getRecordTypeId();

        
    }
	
	@isTest static void testReferralFromWebNonOfficeHour() {
		Test.startTest();
		List<Id> referralId = new List<Id>();
        System.runAs(retailWithBranchUser){
            //Insert referral without account
            referralList = TestUtility_Referral.createReferralsWithoutAccount(1,null,'SmartBiz','Sell (เพื่อนำเสนอขาย)',false);
            referralList[0].RTL_Preferred_Branch_Code__c = '001';
            referralList[0].RTL_Sub_Product__c = '';
            referralList[0].RTL_Channel_Segment__c = 'Web';
            referralList[0].RTL_Customer_Segment__c = 'SE';
            referralList[0].RTL_Campaign_Reference__c = 'Normal Request';
            referralList[0].RecordTypeId = REFER_WITHIN_COMMERCIAL_ID;

            insert referralList;

            referralId.add(referralList[0].id);
            CallMeNowBatch callmeNow = new CallMeNowBatch(referralId);
            DataBase.executeBatch(callmeNow,100);
        }
        Test.stopTest();
	}

	
	
}