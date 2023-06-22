@isTest
class RTL_ReferralAssignUtility_Test {
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
    static Id referToCommercialRecTypeId 
            = Schema.Sobjecttype.RTL_Referral__c.getRecordTypeInfosByName().get('Refer to Commercial').getRecordTypeId();

	static {
        TestUtils.createAppConfig();
        TestUtility_Referral.createAppConfigReferralAssignment();
        createAppConfigReferralAssignmentForSalesSegment();
        TestUtility_Referral.createAppConfigCallMeNowBH();
        branchAndZoneList = RTL_TestUtility.createBranchZone(9,true);
        retailProductMasterList = RTL_TestUtility.createRetailProducts(true);
        retailWithBranchUser = RTL_TestUtility.createRetailTestUserWithBranch(true);
        adminUser = TestUtils.createUsers(1,'USERADMIN','TESTCLASS','test_TMB@tmbbank.com',true)[0];
        acctList = RTL_TestUtility.createAccounts(2,true);
        // update acct[0] as wealth account
        acctList[0].RTL_RM_Name__c = '00001';
        update acctList[0];
        
        RTL_Branch_Manager_Title__c branchTitle 
        		= new RTL_Branch_Manager_Title__c(Name='Branch Manager'
                                                        ,RTL_Value__c='Branch Manager');
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
        
    }


    public static  testmethod  void reassignReferal_Test(){
        Test.startTest();
        
        System.runAs(retailWithBranchUser){
        	insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=retailWithBranchUser.Id);
        }
        System.runAs(retailWithBranchUser){
            //Insert referral To commercial List
            TestUtility_Referral.createReferralAssignment();
            createReferralAssignmentForSalesSegment();
            referralList = createReferralToCommercial();
            RTL_Referral__c ref = referralList.get(0);
            //ref.RTL_RM_Owner_Id__c = rmcUser.Id;

            //update ref;

            ApexPages.StandardController stdController 
                            = new ApexPages.StandardController(ref);

            RTL_ReferralAssignUtility refUtility = new RTL_ReferralAssignUtility(stdController);

            RTL_ReferralAssignUtility.doReferralReassign(referralList[0].Id);
            RTL_ReferralAssignUtility.getReferralReassign(referralList[0].Id);

            RTL_ReferralAssignUtility.doReferralReassign(referralList[1].Id);
            RTL_ReferralAssignUtility.getReferralReassign(referralList[1].Id);
        }
        Test.stopTest();

    }
    public static  testmethod  void reassignReferal_Test2(){
        Test.startTest();
        
        System.runAs(retailWithBranchUser){
        	insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=retailWithBranchUser.Id);
        }
        System.runAs(retailWithBranchUser){
            //Insert referral To commercial List
            TestUtility_Referral.createReferralAssignment();
            createReferralAssignmentForSalesSegment();
            referralList = createReferralToCommercial();
            RTL_Referral__c ref = referralList.get(0);
            //ref.RTL_RM_Owner_Id__c = rmcUser.Id;

            //update ref;

            ApexPages.StandardController stdController 
                            = new ApexPages.StandardController(ref);

            RTL_ReferralAssignUtility refUtility = new RTL_ReferralAssignUtility(stdController);

            RTL_ReferralAssignUtility.doReferralReassign(referralList[2].Id);
            RTL_ReferralAssignUtility.getReferralReassign(referralList[2].Id);
        }
        Test.stopTest();

    }
    
    public static  testmethod  void reassignReferalRuleForNull_Test(){
        Test.startTest();
        
        System.runAs(retailWithBranchUser){
        	insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=retailWithBranchUser.Id);
        }
        System.runAs(retailWithBranchUser){
            //Insert referral To commercial List
            createReferralAssignmentForNullCriertia();
            referralList = createReferralToCommercial();

            RTL_Referral__c ref = referralList.get(0);

            ApexPages.StandardController stdController 
                            = new ApexPages.StandardController(ref);

            RTL_ReferralAssignUtility refUtility = new RTL_ReferralAssignUtility(stdController);

            referralList[0].RTL_Account_Name__c = null;

            update referralList[0];

            RTL_ReferralAssignUtility.doReferralReassign(referralList[0].Id);
            RTL_ReferralAssignUtility.getReferralReassign(referralList[0].Id);

            RTL_ReferralAssignUtility.doReferralReassign(referralList[1].Id);
            RTL_ReferralAssignUtility.getReferralReassign(referralList[1].Id);
            RTL_ReferralAssignUtility.getReferralOwnerName(UserInfo.getUserId());
        }
        Test.stopTest();

    }
    
    public static  testmethod  void testCheckCondition2(){     
        Test.startTest();
        	sObject data1 = new RTL_Referral__c();
        	data1.put('RTL_Sales_Amount_Per_Year__c','SE : <100 MB');
			RTL_ReferralAssignUtility.checkCondition2('RTL_Sales_Amount_Per_Year__c',data1,'SE : < 100MB');
        
        	sObject data2 = new RTL_Referral__c();
        	data2.put('RTL_Sales_Amount_Per_Year__c','BB : 100-1,000 MB');
			RTL_ReferralAssignUtility.checkCondition2('RTL_Sales_Amount_Per_Year__c',data2,'BB : 100-1,000 MB');
        
        	sObject data3 = new RTL_Referral__c();
        	data3.put('RTL_Sales_Amount_Per_Year__c','CB : 1,001-5,000 MB');
			RTL_ReferralAssignUtility.checkCondition2('RTL_Sales_Amount_Per_Year__c',data3,'CB : 1,001-5,000 MB');
        
        	sObject data4 = new RTL_Referral__c();
        	data4.put('RTL_Sales_Amount_Per_Year__c','MB : >5,000 MB');
			RTL_ReferralAssignUtility.checkCondition2('RTL_Sales_Amount_Per_Year__c',data4,'MB : >5,000 MB');
        Test.stopTest();

    }
    
    public static testmethod void testdoCallService(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200,'{"code":"1","message":"success"}'));
        Map<String,String> mockMapString = new Map<String,String>();
        mockMapString.put('3','test3');
        mockMapString.put('4','test4');
        mockMapString.put('5','test5');
        mockMapString.put('6','test6');

        Test.startTest();
        	RTL_ReferralAssignUtility.doCallService('00c03ds000sdcb', 'REF-170712-2326', 'Test', 'LastName', 'SmartBiz', '0987654664', 'callmenow_sme', '', 'Web', 'true','Refer to Commercial','',mockMapString);
        Test.stopTest();
    }

    private static List<RTL_Referral__c> createReferralToCommercial() {
        List<RTL_Referral__c> referralList = new List<RTL_Referral__c>();
        
        RTL_Referral__c referralForSE 
                                = new RTL_Referral__c
                                                      (RecordTypeId = referToCommercialRecTypeId,
                                                       RTL_Product_Name__c = retailProductMasterList[0].id,
                                                       RTL_Preferred_Branch__c = branchAndZoneList[0].id,
                                                       RTL_Mobile1__c = '1111111111',
                                                       RTL_Account_Name__c = acctList[0].id,
                                                       RTL_Sales_Amount_Per_Year__c = 'SE : <100 MB'
                                                       );

        RTL_Referral__c referralForCB 
                                = new RTL_Referral__c
                                                      (RecordTypeId = referToCommercialRecTypeId,
                                                       RTL_Product_Name__c = retailProductMasterList[0].id,
                                                       RTL_Preferred_Branch__c = branchAndZoneList[0].id,
                                                       RTL_Mobile1__c = '1111111111',
                                                       RTL_Account_Name__c = acctList[0].id,
                                                       RTL_Sales_Amount_Per_Year__c = 'CB : 1,001-5,000 MB'
                                                       );


        RTL_Referral__c referralForMB 
                                = new RTL_Referral__c
                                                      (RecordTypeId = referToCommercialRecTypeId,
                                                       RTL_Product_Name__c = retailProductMasterList[0].id,
                                                       RTL_Preferred_Branch__c = branchAndZoneList[0].id,
                                                       RTL_Mobile1__c = '1111111111',
                                                       RTL_Account_Name__c = acctList[0].id,
                                                       RTL_Sales_Amount_Per_Year__c = 'MB : >5,000 MB'
                                                       );

        RTL_Referral__c referralForBB 
                                = new RTL_Referral__c
                                                      (RecordTypeId = referToCommercialRecTypeId,
                                                       RTL_Product_Name__c = retailProductMasterList[0].id,
                                                       RTL_Preferred_Branch__c = branchAndZoneList[0].id,
                                                       RTL_Mobile1__c = '1111111111',
                                                       RTL_Account_Name__c = acctList[0].id,
                                                       RTL_Sales_Amount_Per_Year__c = 'BB : 100-1,000 MB'
                                                       );

        //eferralList.add(referralForSE);
        referralList.add(referralForCB);
        referralList.add(referralForMB);
        referralList.add(referralForBB);

        insert referralList;

        return referralList;
    }
    

    private static void createReferralAssignmentForNullCriertia(){
        List<RTL_Referral_Assignment__c> refAssignmentList = new List<RTL_Referral_Assignment__c>();

        RTL_Referral_Assignment__c refAssignment1= new RTL_Referral_Assignment__c();
        refAssignment1.RTL_Priority__c = 1;
        refAssignment1.RTL_Referral_Type__c = 'Refer_to_Commercial';
        refAssignment1.RTL_Referral_Field_Criteria_1__c = 'RTL_Account_Name__c';
        refAssignment1.RTL_Referral_Field_Value_1__c = 'IS NULL';
        refAssignment1.RTL_Reassign_Flag__c = True;
        refAssignment1.RTL_Active_Flag__c   = True;
        refAssignment1.RTL_Assigned_User_field__c = 'RTL_RM_Owner_Id__c';

        refAssignmentList.add(refAssignment1);
        insert refAssignmentList;
    }
    
    private static void createReferralAssignmentForSalesSegment(){
        List<RTL_Referral_Assignment__c> refAssignmentList = new List<RTL_Referral_Assignment__c>();

        RTL_Referral_Assignment__c refAssignment1= new RTL_Referral_Assignment__c();
        refAssignment1.RTL_Priority__c = 1;
        refAssignment1.RTL_Referral_Type__c = 'Refer_to_Commercial';
        refAssignment1.RTL_Referral_Field_Criteria_1__c = 'RTL_Account_Name__c';
        refAssignment1.RTL_Referral_Field_Value_1__c = 'IS NOT NULL';
        refAssignment1.RTL_Reassign_Flag__c = True;
        refAssignment1.RTL_Active_Flag__c   = True;
        refAssignment1.RTL_Assigned_User_field__c = 'RTL_RM_Owner_Id__c';

        RTL_Referral_Assignment__c refAssignment2 = new RTL_Referral_Assignment__c();
        refAssignment2.RTL_Priority__c = 2;
        refAssignment2.RTL_Referral_Type__c = 'Refer_to_Commercial';
        refAssignment2.RTL_Referral_Field_Criteria_1__c = 'RTL_Preferred_Branch__c';
        refAssignment2.RTL_Referral_Field_Value_1__c = 'IS NOT NULL';
        refAssignment2.RTL_Referral_Field_Criteria_2__c = 'RTL_Sales_Amount_Per_Year__c';
        refAssignment2.RTL_Referral_Field_Value_2__c = 'SE : <100 MB';
        refAssignment2.RTL_Default_Queue_Name__c     = 'SME_Sales_Management';
        refAssignment2.RTL_Reassign_Flag__c = True;
        refAssignment2.RTL_Active_Flag__c = True;
        refAssignment2.RTL_Branch_and_Zone_Queue_User_field__c = 'SE_Queue_Name__c';

        RTL_Referral_Assignment__c refAssignment3 = new RTL_Referral_Assignment__c();
        refAssignment3.RTL_Priority__c = 3;
        refAssignment3.RTL_Referral_Type__c = 'Refer_to_Commercial';
        refAssignment3.RTL_Referral_Field_Criteria_1__c = 'RTL_Preferred_Branch__c';
        refAssignment3.RTL_Referral_Field_Value_1__c = 'IS NOT NULL';
        refAssignment3.RTL_Referral_Field_Criteria_2__c = 'RTL_Sales_Amount_Per_Year__c';
        refAssignment3.RTL_Referral_Field_Value_2__c = 'BB : 100-1,000 MB';
        refAssignment3.RTL_Reassign_Flag__c = True;
        refAssignment3.RTL_Active_Flag__c = True;
        refAssignment3.RTL_Branch_and_Zone_Queue_User_field__c = 'BB_Queue_Name__c';
        refAssignment3.RTL_Default_Queue_Name__c     = 'BB_Sales_Management';

        RTL_Referral_Assignment__c refAssignment4 = new RTL_Referral_Assignment__c();
        refAssignment4.RTL_Priority__c = 4;
        refAssignment4.RTL_Referral_Type__c = 'Refer_to_Commercial';
        refAssignment4.RTL_Referral_Field_Criteria_1__c = 'RTL_Sales_Amount_Per_Year__c';
        refAssignment4.RTL_Referral_Field_Value_1__c = 'CB : 1,001-5,000 MB';
        refAssignment4.RTL_Reassign_Flag__c = True;
        refAssignment4.RTL_Active_Flag__c = True;
        refAssignment4.RTL_Assigned_Queue_Name__c = 'CB_Sales_Management';

        RTL_Referral_Assignment__c refAssignment5 = new RTL_Referral_Assignment__c();
        refAssignment5.RTL_Priority__c = 5;
        refAssignment5.RTL_Referral_Type__c = 'Refer_to_Commercial';
        refAssignment5.RTL_Referral_Field_Criteria_1__c = 'RTL_Sales_Amount_Per_Year__c';
        refAssignment5.RTL_Referral_Field_Value_1__c = 'MB : >5,000 MB';
        refAssignment5.RTL_Reassign_Flag__c = True;
        refAssignment5.RTL_Active_Flag__c = True;
        refAssignment5.RTL_Assigned_Queue_Name__c = 'MB_Sales_Management';

        refAssignmentList.add(refAssignment1);
        refAssignmentList.add(refAssignment2);

        refAssignmentList.add(refAssignment3);
        refAssignmentList.add(refAssignment4);
        refAssignmentList.add(refAssignment5); 

        insert refAssignmentList;
    }

    private static void createAppConfigReferralAssignmentForSalesSegment(){     
        
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c appConfig1 = new AppConfig__c();
        appConfig1.Name = 'RTL_Referral_Assignment_SE';
        appConfig1.Value__c = 'SE : <100 MB';
        apps.add(appConfig1);
        
        AppConfig__c appConfig2 = new AppConfig__c();
        appConfig2.Name = 'RTL_Referral_Assignment_CB';
        appConfig2.Value__c = 'CB : 1,001-5,000 MB';
        apps.add(appConfig2);

        AppConfig__c appConfig3 = new AppConfig__c();
        appConfig3.Name = 'RTL_Referral_Assignment_MB';
        appConfig3.Value__c = 'MB : >5,000 MB';
        apps.add(appConfig3);

        AppConfig__c appConfig4 = new AppConfig__c();
        appConfig4.Name = 'RTL_Referral_Assignment_BB';
        appConfig4.Value__c = 'BB : 100-1,000 MB';
        apps.add(appConfig4);
        insert apps;
    }
    
    @isTest
    private static void Test_getNextnBSDate() {
        RTL_ReferralAssignUtility.getNextnBSDate();
    }
    
}