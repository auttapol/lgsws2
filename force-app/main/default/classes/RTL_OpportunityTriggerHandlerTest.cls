@IsTest
public class RTL_OpportunityTriggerHandlerTest {  
    static List<Account> acctList;
    static List<Branch_And_Zone__c> branchAndZoneList;
    static {
        TestUtils.createAppConfig();

        //Add for Test Oppty to CXM
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'CXM_SERVICE_CONNECTOR';
        Aconfig.Value__c = 'true';        
        apps.add(Aconfig);
        insert apps;
        TestUtils.prepareIntegrationMapping();
        TestUtils.prepareEIMmaps();

    }
    
    public static testmethod void RunPositiveTestOpportunityForChannelReferral(){
        System.debug(':::: RunPositiveTestOpportunityForChannelReferral Start ::::');
        
        TEST.startTest();
        List<User> retailUsers = RTL_TestUtility.createRetailTestUserOppt(true);
        User firstUser = retailUsers[0];//outbound channel
        User secondUser = retailUsers[1];//outbound channel
        User thirdUser = retailUsers[2];//branch channel
        TestInit.createUser(false);
        User adminUser = TestInit.us;  
        List<Account> accountList = null;
        List<Opportunity> opportunityList = null;
        String opptId = null;
        Opportunity updatedOppt = null;
        
        System.runAs(adminUser) {
        	//only system admin can create account
            accountList = RTL_TestUtility.createAccounts(1,true);
            //change the account ownership to retail user for opportunity creation later
            Account acct = accountList[0];
            acct.OwnerId = firstUser.Id;
            update acct;
        }
        System.runAs(firstUser) {
        	//create oppportunity with retail user so that the retail record type is set
            
            opportunityList = RTL_TestUtility.createOpportunity(accountList,true);
            opptId = opportunityList.get(0).Id;
            system.debug('Test_opptId : '+opptId);
            Opportunity oppt = [select OwnerId from Opportunity where Id = :opptId];
            //1st test case: the default channel referral is created
            List<RTL_Channel_Referral__c> defaultOpptReferrals = [Select RTL_Owner__c, RTL_First_Entry__c from RTL_Channel_Referral__c where RTL_Opportunity__c = :opptId];
            //System.assertEquals(1, defaultOpptReferrals.size());
            //check if the opportunity owner is first user
            System.assertEquals(firstUser.Id, oppt.OwnerId);
            //check if the opportunity owner is set as channel referral owner by default
            //System.assertEquals(firstUser.Id, defaultOpptReferrals[0].RTL_Owner__c);
            //2nd test case: change ownership, but the channel is the same (Outbound)                            
            oppt.OwnerId = secondUser.Id;
            //3rd test case: check first entry of first channel referral to be true
            //System.assertEquals(true, defaultOpptReferrals[0].RTL_First_Entry__c);

            //Test Oppty to CXM
            oppt.StageName = 'Closed Lost';
            oppt.RTL_Reason_Lost__c = 'Product - Policy';
            oppt.CampaignId = null;
            oppt.RTL_Is_Create_From_Campaign_Member__c  = false;
            oppt.RTL_Related_to_NBO_History__c = false;

            update oppt;            
        }
        System.runAs(secondUser) {
            //check if the opportunity owner is changed
            updatedOppt = [select OwnerId from Opportunity where Id = :opptId];
            System.assertEquals(secondUser.Id, updatedOppt.OwnerId);
            //check if no additional oppportunity referral is created
            List<RTL_Channel_Referral__c> newOpptReferrals = [Select RTL_Owner__c, RTL_First_Entry__c from RTL_Channel_Referral__c where RTL_Opportunity__c = :opptId];
            //System.assertEquals(1, newOpptReferrals.size());
            //check if the oppportunity referral is not changed
            //System.assertEquals(firstUser.Id, newOpptReferrals[0].RTL_Owner__c);  
            //check first entry of first channel referral to be true
            //System.assertEquals(true, newOpptReferrals[0].RTL_First_Entry__c);
        }
        System.runAs(adminUser) {
            updatedOppt.OwnerId = thirdUser.Id;
            update updatedOppt;
        }
        System.runAs(thirdUser) {
            //check if the opportunity owner is changed
            Opportunity updatedOppt2 = [select OwnerId from Opportunity where Id = :opptId];
            System.assertEquals(thirdUser.Id, updatedOppt2.OwnerId);             
            List<RTL_Channel_Referral__c> updatedOpptReferrals = [Select RTL_Owner__c, RTL_End_Date__c, RTL_First_Entry__c from RTL_Channel_Referral__c where RTL_Opportunity__c = :opptId order by CreatedDate asc];
            //System.assertEquals(2, updatedOpptReferrals.size());
            //check if additional channel refferal is created, the old referral has end date updated
            //System.assertEquals(firstUser.Id, updatedOpptReferrals[0].RTL_Owner__c);  
            //System.assert(updatedOpptReferrals[0].RTL_End_Date__c!=null);
            //check first entry of first channel referral to be true
            //System.assertEquals(true, updatedOpptReferrals[0].RTL_First_Entry__c);            
            //System.assertEquals(thirdUser.Id, updatedOpptReferrals[1].RTL_Owner__c);
            //check 2nd entry of first channel referral to be false
            //System.assertEquals(false, updatedOpptReferrals[1].RTL_First_Entry__c);
        }
        TEST.stopTest();
        System.debug(':::: RunPositiveTestOpportunityForChannelReferral End ::::');
    }
    
    public static testmethod void TestBulkDefaultOpportunityName(){
        
        TEST.startTest();
        
        List<Account> accountList = null;
        List<Opportunity> opportunityList = null;
        String opptId = null;
        Opportunity updatedOppt = null;
        List<User> retailUsers = RTL_TestUtility.createRetailTestUserOppt(true);
        User user = retailUsers[0];//outbound channel
        accountList = RTL_TestUtility.createAccounts(1,true);
////////////////// test mock///////////
        RTL_TestUtility.createRetailMasterProducts(true);

        Contact ct = RTL_TestUtility.createContacts(accountList.get(0));
            ct.OwnerId = user.id;
            ct.TMB_Customer_ID__c = '001p000000CKy8AAD1';
            insert ct;
        system.debug('Opportunity : test '+ct);

        RecordType rt = [SELECT id FROM recordType WHERE DeveloperName   = 'Mass_Campaign_Active' ];
        Campaign masterC = RTL_TestUtility.createMasterCampaign('MasterCam1',
            'M20171001',
            'Mass',
            'MB',user
            );

        insert masterC;

        Campaign childC = RTL_TestUtility.createChildCampaign('ChildCam1','1', masterC , rt) ;
        insert childC;

        List<RTL_product_master__c> rpm = [select id,name,Product_Sub_group__c,Product_Group__c from RTL_product_master__c LIMIT 1];

        Retail_Campaign_Products__c rcp = new Retail_Campaign_Products__c();
        rcp.RTL_Campaign__c = childC.id;
        rcp.RTL_Product_Group__c = rpm.get(0).Product_Group__c;

        insert rcp;
////////////////// test mock///////////

        System.runAs(user){
        //create oppportunity with retail user so that the retail record type is set
            try{
                Campaign c = [SELECT ID FROM Campaign where RecordTypeId =: rt.id LIMIT 1];
                    opportunityList = RTL_TestUtility.createOpportunity(accountList,false);
                    opportunityList.get(0).CampaignId = c.Id;
                    opportunityList.get(0).RTL_Product_Name__c = rpm.get(0).id;
                    //opportunityList.get(0).RTL_TMB_Customer_ID_PE__c = '001100000000000000000011279374';
                    insert opportunityList;

                	opportunityList = RTL_TestUtility.createOpportunities(accountList[0],4,true);
                    opportunityList = RTL_TestUtility.createOpportunities(accountList[0],4,true);
            }catch( Exception e ){
                
            }
        }
      
        TEST.stopTest();
    }
    
    public static testmethod void testAutoCreateOrderFromOpty(){
        
        System.debug(':::: testAutoCreateOrderFromOpty Start ::::');
        TestUtility_Referral.createAppConfigReferralAssignment();
        TestUtility_Referral.createReferralAssignment();
        branchAndZoneList = RTL_TestUtility.createBranchZone(9,true);
        acctList = RTL_TestUtility.createAccounts(2,true);
        RTL_Branch_Manager_Title__c branchTitle = new RTL_Branch_Manager_Title__c(Name='Branch Manager',RTL_Value__c='Branch Manager');
        insert branchTitle;
        
        AppConfig__c Aconfig1 = AppConfig__c.getValues('runtrigger');
        Aconfig1.Value__c = 'true';    
        update Aconfig1;

        User currentUser = [Select id,RTL_License_No_Paper_1__c FROM User Where id =: UserInfo.getUserId() ];
        currentUser.RTL_License_No_Paper_1__c = '4325325426';
        update currentUser;

        Id retailOrderRecType = Schema.Sobjecttype.RTL_Referral__c.getRecordTypeInfosByName().get('Retail Order Transaction').getRecordTypeId();
        RTL_Referral__c referral = new RTL_Referral__c();
        referral.RecordTypeId = retailOrderRecType;
        System.debug('RecordTypeId: ' +referral.RecordTypeId);
        referral.RTL_Account_Name__c = acctList[0].id;
        referral.RTL_Stage__c = 'New';
        referral.RTL_License_No__c = '4325325426';
        referral.RTL_Preferred_Branch__c = branchAndZoneList[0].id;   
        insert referral;
        
        TEST.startTest();
        	Id retailInvestment = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Retail Investment').getRecordTypeId();
        	Opportunity opp = new Opportunity();
        	opp.Name = 'Test Opp';
        	opp.recordTypeId = retailInvestment;
        	opp.CloseDate = Date.today().addDays(30);
        	opp.Amount = 1;
            opp.StageName = 'Sales (Investment)';
        	opp.AccountId = acctList[0].id;
            System.debug('oppacc ' +opp.AccountId);
        	opp.RTL_Referral__c = referral.id;
        	insert opp;
        TEST.stopTest();
        System.debug(':::: testAutoCreateOrderFromOpty End ::::');
    }

    public static testmethod void testAfterUpdateOpportunitytoCampaignMember(){       
        List<User> retailUsers = RTL_TestUtility.createRetailTestUserOppt(true);
        User firstUser = retailUsers[0];//outbound channel
        // firstUser.Employee_ID__c = 'RTL02';
        // update firstUser;
    	// RTL_Branch_Manager_Title__c BMconfig = new RTL_Branch_Manager_Title__c();
    	// BMconfig.Name = 'Branch Manager';
    	// // BMconfig.Value__c = 'Branch Manager';
        // BMconfig.RTL_Value__c = 'Branch Manager';        
    	// insert BMconfig;
        TestInit.createUser(false);
        User adminUser = TestInit.us;  
        List<Account> accountList = null;
        String opptId = null;
        Id retailAutoloan = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Retail Auto Loan').getRecordTypeId();

        TEST.startTest();    

        System.runAs(firstUser){
        
        /*opportunityList = RTL_TestUtility.createOpportunity(accountList,true);
        opptId = opportunityList.get(0).Id;
        system.debug('Test_opptId1 : '+opptId);*/
        accountList = RTL_TestUtility.createAccounts(1,true);
            
        Account acct = accountList[0];
        acct.OwnerId = firstUser.Id;
        update acct;

        //branchAndZoneList = RTL_TestUtility.createBranchZone(9,true); 
        Id recordTypeId  = [select Id from RecordType where SobjectType = 'Campaign' and DeveloperName=: 'Dummy_Campaign' and IsActive=true ].Id;
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = Recordtypeid;
        insert camp;
        
        Contact ct = RTL_TestUtility.createContacts(accountList.get(0));
        ct.OwnerId = firstUser.id;
        insert ct;
        // RTL_product_master__c prod = new RTL_product_master__c();
        // prod.Name = 'CYC';
        // prod.Product_Group__c = 'Auto Loan';
        // prod.Product_Sub_group__c = 'HIRE PURCHASE';
        // prod.Active__c = true;
        // insert prod;

        branchAndZoneList = RTL_TestUtility.createBranchZone(9,true); 
        RTL_Referral__c referral = new RTL_Referral__c();
        //referral.RTL_Account_Name__c = accountList[0].id;
        referral.RTL_Mobile1__c ='0884129128';
        referral.RTL_Stage__c = 'New';
        referral.RTL_License_No__c = '4325325426';
        referral.RTL_Preferred_Branch__c = branchAndZoneList[0].id;   
        // referral.RTL_Account_Name__c = acct.Id;
        system.debug('branch '+referral.RTL_Preferred_Branch__c);
        insert referral;
        system.debug('refid'+referral.id);  

        Opportunity oppt = new Opportunity(); 
        oppt.Name = 'Test Opp';
        oppt.CloseDate = Date.today().addDays(30);
        oppt.StageName = 'Sales (Investment)';
        oppt.recordtypeId = retailAutoloan;
        // oppt.RTL_Product_Group__c = 'Auto Loan';
        // oppt.RTL_Product_Name__c = prod.Id;
        //oppt.AccountId = accountList[0].id;
        oppt.RTL_Referral__c = referral.id;
        // oppt.AccountId = acct.Id;

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
        // cm.RTL_Product_Group_1__c = 'Auto Loan';
        // cm.RTL_Sub_Group_1__c = 'HIRE PURCHASE';
        // cm.RTL_Campaign_Product_1__c = prod.Id;
        // cm.RTL_OfferResult_Product_1__c = 'Referred';
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

        AppConfig__c Aconfig1 = AppConfig__c.getValues('runtrigger');
        Aconfig1.Value__c = 'true';    
        update Aconfig1;    
        
        //update op
        Opportunity opp = new Opportunity();   
        // opp.CampaignId = cm.CampaignId;
        //opp.RTL_Referral__c = referral.id;
        opp.id = cm.RTL_RelatedOpportunity_1__c;
        system.debug('oppty '+opp.id);
        opp.RTL_Hub_Name__c = 'test hub';
        update opp;  
        // Opportunity oppt2 = new Opportunity(); 
        // oppt2.Name = 'Test Opp2';
        // oppt2.CloseDate = Date.today().addDays(30);
        // oppt2.StageName = 'Sales (Investment)';
        // oppt2.recordtypeId = retailAutoloan;
        // oppt2.RTL_Product_Group__c = 'Auto Loan';
        // oppt2.RTL_Product_Name__c = prod.Id;
        // oppt2.RTL_Referral__c = referral.id;
        // oppt2.AccountId = acct.Id;
        // insert oppt2;


    }
    TEST.stopTest();
}
    public static testmethod void testbeforeInsertOpportunitytoCampaignMember(){       
        List<User> retailUsers = RTL_TestUtility.createRetailTestUserOppt(false);
        User firstUser = retailUsers[0];//outbound channel
        firstUser.Employee_ID__c = 'RTL02';
        insert firstUser;

        RTL_Branch_Manager_Title__c BMconfig = new RTL_Branch_Manager_Title__c();
        BMconfig.Name = 'Branch Manager';
        // BMconfig.Value__c = 'Branch Manager';
        BMconfig.RTL_Value__c = 'Branch Manager';        
        insert BMconfig;

        TestInit.createUser(false);
        User adminUser = TestInit.us;  
        List<Account> accountList = null;
        Account acct = null;
        String opptId = null;
        Id retailAutoloan = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Retail Auto Loan').getRecordTypeId();

        TEST.startTest();    
        System.runAs(adminUser) {
            AppConfig__c Aconfig = AppConfig__c.getValues('runtrigger');
            Aconfig.Value__c = 'false';    
            update Aconfig;    
            accountList = RTL_TestUtility.createAccounts(1,false);
            acct = accountList[0];
            acct.OwnerId = firstUser.Id;
            insert acct;
        }
        System.runAs(firstUser){
        
            Id recordTypeId  = [select Id from RecordType where SobjectType = 'Campaign' and DeveloperName=: 'Dummy_Campaign' and IsActive=true ].Id;
            Campaign camp = new Campaign();
            camp.Name = 'Campaign_';
            camp.Segment__c = 'MB';
            camp.OwnerId  = UserInfo.getUserId();
            camp.RecordTypeId = Recordtypeid;
            insert camp;
            
            Contact ct = RTL_TestUtility.createContacts(accountList.get(0));
            ct.OwnerId = firstUser.id;
            insert ct;
            RTL_product_master__c prod = new RTL_product_master__c();
            prod.Name = 'CYC';
            prod.Product_Group__c = 'Auto Loan';
            prod.Product_Sub_group__c = 'HIRE PURCHASE';
            prod.Active__c = true;
            insert prod;

            branchAndZoneList = RTL_TestUtility.createBranchZone(9,true); 

            CampaignMember cm = new CampaignMember();
            cm.CampaignId = camp.id; 
            cm.ContactId = ct.id;                
            cm.RTL_Hub_Name_1__c = 'test hub';
            cm.RTL_Product_Group_1__c = 'Auto Loan';
            cm.RTL_Sub_Group_1__c = 'HIRE PURCHASE';
            cm.RTL_Campaign_Product_1__c = prod.Id;
            cm.RTL_OfferResult_Product_1__c = 'Referred';
            cm.RTL_Marketing_Code__c = 'DTX123456';
            cm.RTL_Web_Unique_ID__c = 'WEB123456';
            insert cm;

            RTL_Referral__c referral = new RTL_Referral__c();
            //referral.RTL_Account_Name__c = accountList[0].id;
            referral.RTL_Mobile1__c ='0884129128';
            referral.RTL_Stage__c = 'New';
            referral.RTL_License_No__c = '4325325426';
            referral.RTL_Preferred_Branch__c = branchAndZoneList[0].id;   
            referral.RTL_Account_Name__c = acct.Id;
            referral.RTL_Campaign_Member__c = cm.Id;
            insert referral;

            // AppConfig__c Aconfig1 = AppConfig__c.getValues('runtrigger');
            // Aconfig1.Value__c = 'true';    
            // update Aconfig1;    
            
            Opportunity oppt2 = new Opportunity(); 
            oppt2.Name = 'Test Opp2';
            oppt2.CloseDate = Date.today().addDays(30);
            oppt2.StageName = 'Sales (Investment)';
            oppt2.recordtypeId = retailAutoloan;
            oppt2.RTL_Product_Group__c = 'Auto Loan';
            oppt2.RTL_Product_Name__c = prod.Id;
            oppt2.RTL_Referral__c = referral.id;
            oppt2.RTL_External_Ref_ID__c = cm.Id;
            oppt2.AccountId = acct.Id;
            insert oppt2;
            List<Opportunity> listopp = new List<Opportunity>();
            List<Opportunity> listopp2 = new List<Opportunity>();
            List<Opportunity> listopp3 = new List<Opportunity>();

            listopp.add(oppt2);
            RTL_OpportunityTriggerHandler.updateOpptyByReferral(listopp);
            RTL_OpportunityTriggerHandler.updateOpptyByCampaignMember(listopp);

            oppt2.RTL_External_Ref_ID__c = 'DTX123456';
            listopp2.add(oppt2);
            RTL_OpportunityTriggerHandler.updateOpptyByCampaignMember(listopp2);

            oppt2.RTL_External_Ref_ID__c = 'WEB123456';
            listopp3.add(oppt2);
            RTL_OpportunityTriggerHandler.updateOpptyByCampaignMember(listopp3);

        }
    TEST.stopTest();
    }
    public static testmethod void testAfterUpdateOpportunitytoMassCampaignMember(){       
        TEST.startTest();    
        List<User> retailUsers = RTL_TestUtility.createRetailTestUserOppt(true);
        User firstUser = retailUsers[0];//outbound channel
        System.runAs(firstUser){

        // TestInit.createUser(false);
        // User adminUser = TestInit.us;  
        List<Account> accountList = null;
        String opptId = null;
        Id retailAutoloan = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Retail Auto Loan').getRecordTypeId();



        /*opportunityList = RTL_TestUtility.createOpportunity(accountList,true);
        opptId = opportunityList.get(0).Id;
        system.debug('Test_opptId1 : '+opptId);*/
        accountList = RTL_TestUtility.createAccounts(1,true);
            
        Account acct = accountList[0];
        acct.OwnerId = firstUser.Id;
        acct.TMB_Customer_ID_PE__c  = '11111110000000';
        update acct;

        //branchAndZoneList = RTL_TestUtility.createBranchZone(9,true); 
        Id MasterrecordTypeId  = [select Id from RecordType where SobjectType = 'Campaign' and DeveloperName=: 'Master_Campaign' and IsActive=true ].Id;
        Campaign Mastercamp = new Campaign();
        Mastercamp.Name = 'Master_Campaign_';
        Mastercamp.Segment__c = 'MB';
        Mastercamp.OwnerId  = UserInfo.getUserId();
        Mastercamp.RecordTypeId = MasterrecordTypeId;
        Mastercamp.RTL_Campaign_Type__c = 'Mass';
        Mastercamp.RTL_Campaign_Code_9_digits__c = 'MTX123458';
        Mastercamp.StartDate = Date.today();
        Mastercamp.EndDate = Date.today().addDays(7);
        Mastercamp.IsActive = true;
        Mastercamp.Approvedflag__c = true;
        Mastercamp.Status = 'In Progress';
        Mastercamp.RTL_Call_Start_Date__c = Date.today();
        Mastercamp.RTL_Call_End_Date__c = Date.today().addDays(7);
        insert Mastercamp;
        
        Contact ct = RTL_TestUtility.createContacts(accountList.get(0));
        ct.OwnerId = firstUser.id;
        ct.TMB_Customer_ID__c = '11111110000000';
        insert ct;

        Id MassrecordTypeId  = [select Id from RecordType where SobjectType = 'Campaign' and DeveloperName=: 'Mass_Campaign' and IsActive=true ].Id;
        Campaign Masscamp = new Campaign();
        Masscamp.Name = 'Child_Mass_Campaign_';
        Masscamp.Segment__c = 'MB';
        Masscamp.OwnerId  = UserInfo.getUserId();
        Masscamp.ParentId = Mastercamp.Id;
        Masscamp.RecordTypeId = MassrecordTypeId;
        Masscamp.RTL_Campaign_Type__c = 'Mass';
        Masscamp.RTL_Campaign_Code_10_digits__c = 'MTX1234589';
        Masscamp.StartDate = Date.today();
        Masscamp.EndDate = Date.today().addDays(6);
        Masscamp.IsActive = true;
        Masscamp.Approvedflag__c = true;
        Masscamp.Status = 'In Progress';
        Masscamp.RTL_Call_Start_Date__c = Date.today();
        Masscamp.RTL_Call_End_Date__c = Date.today().addDays(6);
        // Masscamp.ContactId = ct.id;
        // Masscamp.RTL_Last_Contact_Status__c = 'New';
        // Masscamp.RTL_Contact_Status__c = 'Contact';
        // Masscamp.RTL_Product_Group_1__c = 'Deposit';
        insert Masscamp;

        RTL_product_master__c prod = new RTL_product_master__c();
        prod.Name = 'CYC';
        prod.Product_Group__c = 'Auto Loan';
        prod.Product_Sub_group__c = 'AL PERSONAL LOAN';
        prod.Active__c = true;
        insert prod;

        AppConfig__c Aconfig1 = AppConfig__c.getValues('runtrigger');
        Aconfig1.Value__c = 'true';    
        update Aconfig1;    
        System.debug('Masscamp.IsActive : ' + Masscamp.IsActive);

        Opportunity oppt = new Opportunity(); 
        oppt.Name = 'Test Opp';
        oppt.CloseDate = Date.today().addDays(30);
        oppt.StageName = 'Sales (Investment)';
        oppt.recordtypeId = retailAutoloan;
        oppt.CampaignId = Masscamp.id;
        oppt.AccountId = accountList[0].id;
        oppt.RTL_Is_Create_From_Campaign_Member__c  = true;
        oppt.RTL_Product_Name__c = prod.Id;
        insert oppt;

    }
    TEST.stopTest();
    }

    public static testmethod void testAfterUpdateOpportunitytoCampaignMemberCrossSellProduct(){             
        TEST.startTest();
            
        List<User> retailUsers = RTL_TestUtility.createRetailTestUserOppt(true);
        User firstUser = retailUsers[0];//outbound channel
       
        TestInit.createUser(false);
        User adminUser = TestInit.us;  
        List<Account> accountList = null;
       
        System.runAs(firstUser) {               
            accountList = RTL_TestUtility.createAccounts(1,true);
            
            Account acct = accountList[0];
            acct.OwnerId = firstUser.Id;
            update acct;

            branchAndZoneList = RTL_TestUtility.createBranchZone(9,true); 
            Id recordTypeId  = [select Id from RecordType where SobjectType = 'Campaign' and DeveloperName=: 'Dummy_Campaign' and IsActive=true ].Id;
            Campaign camp = new Campaign();
            camp.Name = 'Campaign_';
            camp.Segment__c = 'MB';
            camp.OwnerId  = UserInfo.getUserId();
            camp.RecordTypeId = Recordtypeid;
            insert camp;
            
            Contact ct = RTL_TestUtility.createContacts(accountList.get(0));
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
            //system.debug('csp:'+csp.OpportunityId__c);
            //csp.RTL_Hub_Name__c = 'test hub';
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

            Opportunity opptup = new Opportunity(); 
            opptup.id = csp.OpportunityId__c;
            opptup.RTL_AL_Refer_No__c = 'online';
            opptup.RTL_AL_Req_No1__c = 'online';
            opptup.RTL_AL_Req_No2__c = 'online'; 
            update opptup;
        
            TEST.stopTest();
    
            }
        }
}