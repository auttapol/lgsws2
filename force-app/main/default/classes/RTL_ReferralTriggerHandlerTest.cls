@isTest
public class RTL_ReferralTriggerHandlerTest {
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

    static {
        TestUtils.createAppConfig();
        TestUtility_Referral.createAppConfigReferralAssignment();
        TestUtility_Referral.createReferralAssignment();
        TestUtility_Referral.createAppConfigCallMeNowBH();
        branchAndZoneList = RTL_TestUtility.createBranchZone(9,true);
        retailProductMasterList = RTL_TestUtility.createRetailProducts(true);
        retailWithBranchUser = RTL_TestUtility.createRetailTestUserWithBranch(true);
        adminUser = TestUtils.createUsers(1,'USERADMIN','TESTCLASS','test_TMB@tmbbank.com',true)[0];
        acctList = RTL_TestUtility.createAccounts(2,true);
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'CXM_SERVICE_CONNECTOR';
        Aconfig.Value__c = 'true';        
        insert Aconfig;
        TestUtils.prepareIntegrationMapping();
        TestUtils.prepareEIMmaps();
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
        
    }
    
    static testmethod void testInsertNewReferral(){
        
        Test.startTest();
        
        System.runAs(retailWithBranchUser){
            insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=retailWithBranchUser.Id);
        }
        System.runAs(retailWithBranchUser){
            //Insert referral without account
            referralList = TestUtility_Referral.createReferralsWithoutAccount(1,branchAndZoneList[0].id,'Payroll','Sell (เพื่อนำเสนอขาย)',true);
            //Insert referral cross channel with account
            referralList = TestUtility_Referral.createReferralsCrossChannelWithAccount(1,acctList[0].id,branchAndZoneList[0].id,retailProductMasterList[0].id,true);
            
            referralList = queryReferral();
            System.assertEquals(2,referralList.size());
        }
        Test.stopTest();
    }
    
    static testmethod void testInsertReferralWithAccount(){
        //assert employee information , refered info , last assign info ,owner info , reporing product for different record type
        Test.startTest();
        
        System.runAs(retailWithBranchUser){
            insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=retailWithBranchUser.Id);
        }
        System.runAs(retailWithBranchUser){
            //Referral with wealth account
            referralList = TestUtility_Referral.createReferralsWithAccount(1,acctList[0].id,branchAndZoneList[0].id,true);
            
            //Referral with non-wealth account
            referralList = TestUtility_Referral.createReferralsWithAccount(1,acctList[1].id,branchAndZoneList[0].id,true);
        }
        Test.stopTest();
    }
    
    static testmethod void testDefaultPreferredBranch(){
        //for refer to commercial
        Test.startTest();
        System.runAs(retailWithBranchUser){
            //Referral without preferred branch
            referralList = TestUtility_Referral.createReferralsWithoutBranch(1,true);
            referralList = queryReferral();
            System.assertNotEquals(null,referralList[0].RTL_Preferred_Branch__c);
        }
        Test.stopTest();
    }
    
    
    static testmethod void testBulkInsertReferralWithAccount(){
         //for refer to commercial
        Test.startTest();
        
        System.runAs(retailWithBranchUser){
            insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=retailWithBranchUser.Id);
        }
        System.runAs(retailWithBranchUser){
            //Referral without preferred branch
            referralList = TestUtility_Referral.createReferralsWithAccount(100,acctList[0].id,branchAndZoneList[0].id,true);
            referralList = queryReferral();
            //assert insert bulk insert success
            System.assertEquals(100,referralList.size());
        }
        Test.stopTest();
    }
    
    static testmethod void testCreateOpportunityWithReferral(){
        //assert referral status changed to closed (interested)
        
        System.runAs(retailWithBranchUser){
            insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=retailWithBranchUser.Id);
        }
        System.runAs(retailWithBranchUser){
            //Referral without preferred branch
            referralList = TestUtility_Referral.createReferralsWithAccount(1,acctList[0].id,branchAndZoneList[0].id,true);
            opportunityList = RTL_TestUtility.createOpportunities(acctList[0],1,true);
            
            List<Opportunity> opptyList = queryOpportunity();
            System.debug('BEFORE OPPORTUNITY   :: '+opptyList);
            
            opptyList[0].RTL_Referral__c = referralList[0].id;
            update opptyList;
            
            opptyList = queryOpportunity();
            List<RTL_Referral__c> refList = queryReferral();
            System.debug('AFTER OPPORTUNITY   :: '+opptyList);
            //Assert referral attached with opportunity
            System.assertequals(referralList[0].id,opptyList[0].RTL_Referral__c);
            //Assert referral stage is Closed (Interested)
            System.assertequals('Closed (Interested)',refList[0].RTL_Stage__c);
        }
        
       
    }
    
    static testmethod void testUpdateReferralContacted(){
        //assert first contacted date
        //
        Test.startTest();
        System.runAs(retailWithBranchUser){
            
            referralList = TestUtility_Referral.createReferralsWithoutAccount(1,branchAndZoneList[0].id,'Payroll','Sell (เพื่อนำเสนอขาย)',true);
            referralList[0].RTL_Stage__c = 'In progress_Contacted';
            update referralList;
            
            referralList = queryReferral();
            System.assertNotEquals(null,referralList[0].RTL_First_Contacted_Date__c);
            
            
        }
        Test.stopTest();
    }
    
    static testmethod void testCloseReferral(){
        //assert first contacted , closed date
        Test.startTest();
        System.runAs(retailWithBranchUser){
            
            referralList = TestUtility_Referral.createReferralsWithoutAccount(1,branchAndZoneList[0].id,'Payroll','Sell (เพื่อนำเสนอขาย)',true);
            referralList[0].RTL_Stage__c = 'Closed (Unable to contact)';
            referralList[0].RTL_Reason__c = 'Busy Line';
            update referralList;
            
            referralList = queryReferral();
            System.assertNotEquals(null,referralList[0].RTL_First_Contacted_Date__c);
            System.assertNotEquals(null,referralList[0].RTL_Closed_Date_Time__c);
            
        }
        Test.stopTest();
    }
    
    static testmethod void testHasPermissionAcceptReferral(){
        //assert change owner success , assert last assign owner
        Test.startTest();
        System.runAs(retailWithBranchUser){
            
            referralList = TestUtility_Referral.createReferralsWithoutAccount(1,branchAndZoneList[0].id,'Payroll','Sell (เพื่อนำเสนอขาย)',true);
            
            //change owner to RMC Queue
            referralList[0].OwnerId = queueMap.get('RMC_Queue').id;
            update referralList;
            
            referralList = queryReferral();
            System.assertEquals(queueMap.get('RMC_Queue').id,referralList[0].OwnerId);
                        
            
        }
        
        
        
        System.runAs(rmcUser){
            RTL_ReferralTriggerHandler.currentUser = null;
            //rmc user accept referral
            String result = RTL_ReferralChangeOwner.acceptReferral(referralList[0].id);   
            System.assertequals('Success',result);
        }
        Test.stopTest();
        
    }
    
    static testmethod void testNoPermissionAcceptReferral(){
        Test.startTest();
        System.runAs(retailWithBranchUser){
            
            referralList = TestUtility_Referral.createReferralsWithoutAccount(1,branchAndZoneList[0].id,'Payroll','Sell (เพื่อนำเสนอขาย)',true);
            
            //change owner to RMC Queue
            referralList[0].OwnerId = queueMap.get('RMC_Queue').id;
            update referralList;
            
            //Branch try to accept referral
            String result = RTL_ReferralChangeOwner.acceptReferral(referralList[0].id);   
            System.assertequals('You are not authorized to accept this referral.',result);
            
            
        }
      
        Test.stopTest();
    }
    
    static testmethod void testHasPermissionEditReferral(){
        Test.startTest();
        
        System.runAs(retailWithBranchUser){
            insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=retailWithBranchUser.Id);
        }
        System.runAs(retailWithBranchUser){
            
            referralList = TestUtility_Referral.createReferralsWithoutAccount(1,branchAndZoneList[0].id,'Payroll','Sell (เพื่อนำเสนอขาย)',true);
            
            //change owner to RMC Queue
            referralList[0].RTL_Account_Name__c = acctList[0].id;
            referralList[0].RTL_Interested_Product__c = 'Payroll';
            update referralList;
            
            //query referral to check result
            referralList = queryReferral();
            
            //System.assertEquals(acctList[0].id,referralList[0].RTL_Account_Name__c );
            //System.assertEquals('EDC',referralList[0].RTL_Interested_Product__c );
            //System.assertEquals('EDC',referralList[0].RTL_Reporting_Product__c );

            
            
        }
      
        Test.stopTest();
    }
    static testmethod void testReferralChangeOwner(){
        Test.startTest();
        System.runAs(retailWithBranchUser){
            
            referralList = TestUtility_Referral.createReferralsWithoutAccount(1,branchAndZoneList[0].id,'Payroll','Sell (เพื่อนำเสนอขาย)',true);
            
            //change owner to Branch Queue
            referralList[0].OwnerId = queueMap.get('RTLQ_001').id;
            update referralList;
            
            referralList = queryReferral();
            //assert change owner success
            System.assertEquals(queueMap.get('RTLQ_001').id, referralList[0].OwnerId);
            
            
        }
      
        Test.stopTest();
    }
    
    static testmethod void testManualCloseInterestedReferral(){
        //assert error message
        Test.startTest();
        System.runAs(retailWithBranchUser){
            
            try{
                
                referralList = TestUtility_Referral.createReferralsWithoutAccount(1,branchAndZoneList[0].id,'Payroll','Sell',true);
                referralList[0].RTL_Stage__c = 'Closed (Interested)';
                update referralList;
                // 1. If we get to this line it means an error was not added and the test class should throw an exception here.
                throw new MyException('An exception should have been thrown by the trigger but was not.'); 
            }catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Stage Closed (Interested) can be set by system only') ? true : false;
                //System.AssertEquals(expectedExceptionThrown, true);
            }
            
        }
        Test.stopTest();
    }
    // static testmethod void testcallAPIReferral(){
    //     Test.startTest();
    //     TestUtils.createAppConfig();

    //     User contextuser = [SELECT Id FROM User WHERE Profile.Name = 'TMB Retail Channel Sales' AND IsActive = true LIMIT 1];

    //     System.runAs(contextuser){

    //     RTL_product_master__c prod = new RTL_product_master__c();
    //     prod.Name = 'CYC';
    //     prod.Active__c = true;
    //     insert prod;
    //     RTL_Contact_Address__c adds = new RTL_Contact_Address__c();
    //     adds.IsActive__c = true;
    //     adds.RTL_Province__c = 'กรุงเทพมหานคร';
    //     adds.RTL_District__c = 'เขตพระนคร';
    //     adds.RTL_Sub_District__c = 'พระบรมมหาราชวัง';
    //     adds.RTL_Zipcode__c = '50000';
    //     insert adds;
    //     Branch_and_Zone__c branch = new Branch_and_Zone__c();
    //     branch.Name = 'AL Marketing';
    //     branch.IsActive__c = true;
    //     insert branch;

    //     Test.setMock(HttpCalloutMock.class, new MockHPAPHttpResponse());

    //     RTL_Referral__c ref = new RTL_Referral__c();
    //     ref.RTL_FirstName__c = 'Fname001';
    //     ref.RTL_LastName__c = 'Lname001';
    //     ref.RTL_Mobile1__c = '0951234560';
    //     ref.RTL_Product_Name__c = [SELECT Id,Name FROM  RTL_product_master__c WHERE Name = 'CYC' LIMIT 1].Id;
    //     ref.RTL_Contact_Address__c = [SELECT Id,Name FROM  RTL_Contact_Address__c WHERE IsActive__c = TRUE LIMIT 1].Id;
    //     ref.RTL_Stage__c = 'New';
    //     ref.RTL_Preferred_Branch__c = branchAndZoneList[0].id;
    //     ref.RTL_AL_contact_channel__c = 'DS';
    //     insert ref;

    //     //RTL_Referral__c updateref = [SELECT Id,Name,RTL_Preferred_Branch__c,RTL_AL_contact_channel__c,RTL_Contact_Address__c FROM RTL_Referral__c WHERE RTL_FirstName__c = 'Fname001' LIMIT 1];
    //     ref.RTL_Preferred_Branch__c = [SELECT Id,Name FROM  Branch_and_Zone__c WHERE Name = 'AL Marketing' LIMIT 1].Id;
    //     ref.countsendHPAP__c = 9;
    //     ref.RTL_Is_Send_To_HPAP__c = false;
    //     ref.wsUpdateFlag__c = true;
    //     update ref;
    //     }
    //     Test.stopTest();

    // }
    public class MyException extends Exception {}
    
    public static List<Opportunity> queryOpportunity(){
        List<Opportunity> oppList = [SELECT Id,Name,RTL_Referral__c FROM Opportunity ];
        return oppList;
    }
    
    public static List<RTL_Referral__c> queryReferral(){
        List<RTL_Referral__c> referralList = [SELECT Id,Name,RTL_Stage__c,RTL_Owner_Branch__c,OwnerId,
                                              RTL_First_Contacted_Date__c,RTL_Closed_Date_Time__c,
                                              RTL_Preferred_Branch__c,RTL_Account_Name__c,RTL_Interested_Product__c,
                                              RTL_Reporting_Product__c,Owner.Name,RTL_Is_Owner__c
                                              FROM RTL_Referral__c];
        return referralList;
    }
    
    
    @isTest
    private static void Test_getSalesAmountPerYear() {
        String segment = null;
        RTL_ReferralTriggerHandler.getSalesAmountPerYear(segment);
    }    

    @isTest
    private static void Test_updateCustomerFnaActivity() {
        TestUtils.createAppConfig();
        Branch_and_Zone__c baz = new Branch_and_Zone__c();
        baz.IsActive__c = true;
        insert baz;

        // AppConfig__c Aconfig = new AppConfig__c();
        // Aconfig.Name = 'runtrigger';
        // Aconfig.Value__c = 'true';
        // insert Aconfig;   

        List<Account> listAccount = new List<Account>();
        Account account = new Account();
        account.Name = 'Mockup Data';
        account.RTL_Office_Phone_Number__c = '012345678';
        account.Mobile_Number_PE__c = '0';
        account.TMB_Customer_ID_PE__c = '001100000000000000000014144590';
        listAccount.add(account);
        insert listAccount;

        List<FNA_Activity__c> listFnaAct = new List<FNA_Activity__c>();
        FNA_Activity__c fnaActivity = new FNA_Activity__c();
        fnaActivity.Customer__c = listAccount[0].Id;
        // fnaActivity.Avatar_Name__c = 'test';
        fnaActivity.Avatar_Url__c = 'test';
        fnaActivity.Have_Referral__c = true;
        fnaActivity.Product_Interested__c = 'test';
        fnaActivity.Product_Holding__c = 'test';
        listFnaAct.add(fnaActivity);
        insert listFnaAct;

        List<RTL_Referral__c> listRTLRef = new List<RTL_Referral__c>();
        RTL_Referral__c RTLRef = new RTL_Referral__c();
        RTLRef.RTL_Preferred_Branch__c = baz.Id;
        RTLRef.FNA_Activity__c = listFnaAct[0].Id;
        RTLRef.RTL_Mobile1__c = '0911111111';
        RTLRef.RTL_Account_Name__c = listAccount[0].Id;
        listRTLRef.add(RTLRef);
        insert listRTLRef;

        Map<Id,RTL_Referral__c> idMapRTL = new Map<Id,RTL_Referral__c>();
        idMapRTL.put(listRTLRef[0].Id,listRTLRef[0]);
        
        RTL_ReferralTriggerHandler.updateCustomerFnaActivity(listRTLRef,idMapRTL);
    }

    @isTest
    private static void test_preferredstaff(){
        TestUtils.createAppConfig();

        //User contextuser = [SELECT Id, RTL_Branch_Code__c FROM User WHERE Profile.Name = 'TMB Retail Channel Sales' AND IsActive = true LIMIT 1];
        Id TMB_RC_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Retail Channel Sales' LIMIT 1].Id;
        system.debug(TMB_RC_PROFILE_ID);

        RTL_product_master__c prod = new RTL_product_master__c();
        prod.Name = 'CYC';
        prod.Active__c = true;
        insert prod;
        Branch_and_Zone__c branch = new Branch_and_Zone__c();
        branch.Name = '797';
        branch.IsActive__c = true;
        insert branch;

        // List<User> userlst = [SELECT Id, ManagerId, Email, RTL_Branch_Code__c FROM User LIMIT 2];
        // for(User u:userlst){
        //     u.RTL_Branch_Code__c = '001';           
        // }
        User ManagerUser = new User(FirstName='TestApproval',LastName='Manager', 
                                    UserName='Manager_TMBTestTMB@tmb.com',
                                    Email='tmbmanager@tmbbank.com', Alias='TmbMr',Segment__c ='MB',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='ManagerNickname',
                                    ProfileId = TMB_RC_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='MN001');
        insert ManagerUser;
        User PreferredStaff = new User(FirstName='TestApproval',LastName='PS', 
                                    UserName='RM_TMBTestTMB@tmb.com',
                                    Email='rmtmb@tmbbank.com', Alias='TmbRM',Segment__c ='MB',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='RMNickname',RTL_Branch_Code__c='001',
                                    ProfileId = TMB_RC_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='RM001',ManagerId = ManagerUser.id);
        insert PreferredStaff;
        System.debug('PreferredStaff Email :'+PreferredStaff.Email);
        System.debug('PreferredStaff Email :'+PreferredStaff.Id);
        System.runAs(PreferredStaff){
        String RecordTypeId = Schema.SObjectType.RTL_Referral__c.getRecordTypeInfosByName().get('Retail Cross Channel Referral').getRecordTypeId();
        RTL_Referral__c ref = new RTL_Referral__c();
        ref.RecordTypeId = RecordTypeId;
        ref.RTL_FirstName__c = 'Fname001';
        ref.RTL_LastName__c = 'Lname001';
        ref.RTL_Mobile1__c = '0951234560';
        ref.RTL_Preferred_Staff__c = PreferredStaff.Id;
        ref.RTL_Product_Name__c = [SELECT Id,Name FROM  RTL_product_master__c WHERE Name = 'CYC' LIMIT 1].Id;
        //ref.RTL_Stage__c = 'New';
        ref.RTL_Preferred_Branch__c = branchAndZoneList[0].id;
        insert ref;
        }
    }
    
    public static testmethod void testAfterUpdateReferraltoCampaignMember(){             
        List<User> retailUsers = RTL_TestUtility.createRetailTestUserOppt(true);
        User firstUser = retailUsers[0];//outbound channel
       
        TestInit.createUser(false);
        User adminUser = TestInit.us;  
        List<Account> accountList = null;
        List<Account> accountList1 = null;
        List<Opportunity> opportunityList = null;
        String opptId = null;
        Account acct = acctList[0];
        acct.OwnerId = firstUser.Id;
        update acct;
                        
        TEST.startTest();      
                System.runAs(firstUser){
     
            
                Id recordTypeId  = [select Id from RecordType where SobjectType = 'Campaign' and DeveloperName=: 'Dummy_Campaign' and IsActive=true ].Id;
                Campaign camp = new Campaign();
                camp.Name = 'Campaign_';
                camp.Segment__c = 'MB';
                camp.OwnerId  = UserInfo.getUserId();
                camp.RecordTypeId = Recordtypeid;
                insert camp;
                
                Contact ct = RTL_TestUtility.createContacts(acctList.get(0));
                ct.OwnerId = firstUser.id;
                insert ct;
                        
                //branchAndZoneList = RTL_TestUtility.createBranchZone(9,true); 
                RTL_Referral__c referral = new RTL_Referral__c();
                referral.RTL_Mobile1__c ='0884129128';
                referral.RTL_Stage__c = 'New';
                referral.RTL_License_No__c = '4325325426';
                referral.RTL_Preferred_Branch__c = branchAndZoneList[0].id;   
                system.debug('branch '+referral.RTL_Preferred_Branch__c);
                insert referral;
                system.debug('refid'+referral.id);  

                Opportunity oppt = new Opportunity(); 
                oppt.Name = 'Test Opp';
                oppt.CloseDate = Date.today().addDays(30);
                oppt.StageName = 'Sales (Investment)';
                //oppt.AccountId = accountList[0].id;
                oppt.RTL_Referral__c = referral.id;
                insert oppt;

                system.debug('opptid'+oppt.id);  
                //mock cm
                CampaignMember cm = new CampaignMember();
                cm.CampaignId = camp.id; 
                cm.ContactId = ct.id;
                cm.RTL_RelatedOpportunity_1__c = oppt.id;
                cm.RTL_RelatedOpportunity_2__c = oppt.id;
                cm.RTL_RelatedOpportunity_3__c = oppt.id;
                cm.RTL_RelatedOpportunity_4__c = oppt.id;
                cm.RTL_RelatedOpportunity_5__c = oppt.id;
                cm.RTL_Referral_ID_1__c = referral.id;
                cm.RTL_Referral_ID_2__c = referral.id; 
                cm.RTL_Referral_ID_3__c = referral.id; 
                cm.RTL_Referral_ID_4__c = referral.id; 
                cm.RTL_Referral_ID_5__c = referral.id;                
                cm.RTL_Hub_Name_1__c = 'test hub';
                insert cm;
                system.debug('oppty '+cm.RTL_RelatedOpportunity_1__c);
                system.debug('refer '+cm.RTL_Referral_ID_1__c);
            
                //update ref
                RTL_Referral__c referralup = new RTL_Referral__c();
                referralup.id = cm.RTL_Referral_ID_1__c;
                referralup.RTL_Stage__c = 'New';
                referralup.RTL_AL_Refer_No__c = 'online';
                referralup.RTL_AL_Req_No1__c = 'online';
                referralup.RTL_AL_Req_No2__c = 'online';
                referralup.RTL_Status__c = 'เปิดใบคำขอเรียบร้อยแล้ว';
                referralup.Details_of_Status__c = 'กรุณาดู status ใบคำขอล่าสุดที่โอกาส';
                referralup.RTL_AL_Refer_No__c = '20220720133195943';
                referralup.RTL_AL_Req_No1__c = 'online';
                referralup.RTL_AL_Req_No2__c = 'online';
                referralup.Corebank_Emp_Id__c = 'online';
                referralup.Corebank_Emp_Name__c= 'online';
                referralup.Corebank_Emp_Phone_No__c = 'online';
                referralup.RTL_Hub_Code__c = '123';
                referralup.RTL_Hub_Name__c = 'test hub';
                referralup.RTL_Account_No__c = 'CYC';
                referralup.HPAP_Status_Code__c = 'oooo';
                referralup.HPAP_Reason_Code__c = 'oooo';
                referralup.HPAP_Reason_Description__c = 'oooo';
                update referralup;
            
            /*RTL_Referral__c referralup1 = new RTL_Referral__c();
            referralup1.id = cm.RTL_Referral_ID_2__c;
            referralup1.RTL_Stage__c = 'New';
            referralup1.RTL_AL_Refer_No__c = 'online';
            referralup1.RTL_AL_Req_No1__c = 'online';
            referralup1.RTL_AL_Req_No2__c = 'online';
            referralup1.RTL_Status__c = 'เปิดใบคำขอเรียบร้อยแล้ว';
            referralup1.Details_of_Status__c = 'กรุณาดู status ใบคำขอล่าสุดที่โอกาส';
            referralup1.RTL_AL_Refer_No__c = '20220720133195943';
            referralup1.RTL_AL_Req_No1__c = 'online';
            referralup1.RTL_AL_Req_No2__c = 'online';
            referralup1.Corebank_Emp_Id__c = 'online';
            referralup1.Corebank_Emp_Name__c= 'online';
            referralup1.Corebank_Emp_Phone_No__c = 'online';
            referralup1.RTL_Hub_Code__c = '123';
            referralup1.RTL_Hub_Name__c = 'test hub';
            referralup1.RTL_Account_No__c = 'CYC';
            referralup1.HPAP_Status_Code__c = 'oooo';
            referralup1.HPAP_Reason_Code__c = 'oooo';
            referralup1.HPAP_Reason_Description__c = 'oooo';
            update referralup1;*/
        
                }
        TEST.stopTest();
        
    }
    public static testmethod void testAfterUpdateReferraltoCampaignMemberCrossSellProduct(){             
        TEST.startTest();
            
        List<User> retailUsers = RTL_TestUtility.createRetailTestUserOppt(true);
        User firstUser = retailUsers[0];
        Account acct = acctList[0];
        acct.OwnerId = firstUser.Id;
        update acct;
        TestInit.createUser(false);
        User adminUser = TestInit.us;  
       
        System.runAs(firstUser) {               
           // branchAndZoneList = RTL_TestUtility.createBranchZone(9,true); 
            Id recordTypeId  = [select Id from RecordType where SobjectType = 'Campaign' and DeveloperName=: 'Dummy_Campaign' and IsActive=true ].Id;
            Campaign camp = new Campaign();
            camp.Name = 'Campaign_';
            camp.Segment__c = 'MB';
            camp.OwnerId  = UserInfo.getUserId();
            camp.RecordTypeId = Recordtypeid;
            insert camp;
            
            Contact ct = RTL_TestUtility.createContacts(acctList.get(0));
            ct.OwnerId = firstUser.id;
            insert ct;
            
            RTL_Referral__c referral = new RTL_Referral__c();
            referral.RTL_Mobile1__c ='0884129128';
            referral.RTL_Stage__c = 'New';
            referral.RTL_License_No__c = '4325325426';
            referral.RTL_Preferred_Branch__c = branchAndZoneList[0].id;   
            insert referral;

            Opportunity oppt = new Opportunity(); 
            oppt.Name = 'Test Opp';
            oppt.CloseDate = Date.today().addDays(30);
            oppt.StageName = 'Sales (Investment)';
            oppt.RTL_Referral__c = referral.id;
            insert oppt;
            
            CampaignMember cm = new CampaignMember();
            cm.CampaignId = camp.id; 
            cm.RTL_Hub_Name_1__c = 'test hub';
            cm.ContactId = ct.id;
            insert cm;
            
            Cross_Sell_Product__c csp = new Cross_Sell_Product__c();
            csp.CampaignMemberId__c = cm.id;
            csp.ReferralID__c = referral.id;
            csp.OpportunityId__c = oppt.id;              
            insert csp;

            AppConfig__c Aconfig1 = AppConfig__c.getValues('runtrigger');
            Aconfig1.Value__c = 'true';    
            update Aconfig1;  
            
            RTL_Referral__c referralup = new RTL_Referral__c();
            referralup.id = csp.ReferralID__c;
            referralup.RTL_AL_Refer_No__c = 'online';
            referralup.RTL_AL_Req_No1__c = 'online';
            referralup.RTL_AL_Req_No2__c = 'online'; 
            update referralup;              
            }
            TEST.stopTest();
        }
}