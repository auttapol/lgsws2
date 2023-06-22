@isTest
public class BatchMergeCustomerTest {
    
    static List<Branch_And_Zone__c> branchAndZoneList;
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
        //retailProductMasterList = RTL_TestUtility.createRetailProducts(true);
        retailWithBranchUser = RTL_TestUtility.createRetailTestUserWithBranch(true);
        adminUser = TestUtils.createUsers(1,'USERADMIN','TESTCLASS','test_TMB@tmbbank.com',true)[0];
       
        
        RTL_Branch_Manager_Title__c branchTitle = new RTL_Branch_Manager_Title__c(Name='Branch Manager',RTL_Value__c='Branch Manager');
        insert branchTitle;
        //ls = Test.loadData(Branch_And_Zone__c.sObjectType, 'BranchAndZoneMaster');
        ID RMC_ROLE_ID = [SELECT Id FROM UserRole WHERE Name LIKE '%RMC%' LIMIT 1].id;
        System.debug('RMC ROLE ID '+RMC_ROLE_ID);
        
       // queueMap = new Map<String, Group>();
       // for(Group queue : [Select Id, Name, DeveloperName from Group where Type = 'Queue'])
        //    queueMap.put(queue.DeveloperName, queue);
        
        System.runAs(adminUser){
            //create rmc user for test
            rmcUser = TestUtility_Referral.createRMCTestUser(true);
            //create bdm user for test 
            bdmUser = TestUtility_Referral.createBDMTestUser(true);
        }
        
    }

    public static testmethod void testRunBatch(){  

        Test.startTest();

       // TestUtils.createAppConfig();
          
        List<AppConfig__c> appconfig = new List<AppConfig__c>();
        AppConfig__c runTriger = new AppConfig__c();
        runTriger.Name = 'runtrigger';
        runTriger.Value__c = 'false';
       // appconfig.add(runTriger);
        
        AppConfig__c crmadmin = new AppConfig__c();
        crmadmin.Name = 'CRM Admin';
        crmadmin.Value__c = 'testemial@ttbbank.com';
        appconfig.add(crmadmin);
        insert appconfig;

        List<Account> accList = New List<Account>();        

        Account acc1 = new Account();
        acc1.Name = 'First1 Last1';
        acc1.Phone ='050111222';
        acc1.Mobile_Number_PE__c  = '0801112233';
        acc1.ID_Type_PE__c  = 'Citizen ID';
        acc1.ID_Number_PE__c  = '1510100181965';
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acc1.Segment_crm__c = '5';
        acc1.Customer_Type__c = 'Individual';
        acc1.First_name_PE__c = 'First1';
        acc1.Last_name_PE__c = 'Last1';
        acc1.TMB_Customer_ID_PE__c = '001100000000001000000000101772';
        acc1.Murex_Counter_Label__c = 'eclient';

        accList.add(acc1);

        Account acc2 = new Account();
        acc2.Name = 'First2 Last2';
        acc2.Phone ='050111222';
        acc2.Mobile_Number_PE__c  = '0801112233';
        acc2.ID_Type_PE__c  = 'Other ID';
        acc2.ID_Number_PE__c  = '1510100181965';
        acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acc2.Segment_crm__c = '5';
        acc2.Customer_Type__c = 'Individual';
        acc2.First_name_PE__c = 'First2';
        acc2.Last_name_PE__c = 'Last2';
        acc2.TMB_Customer_ID_PE__c = '001100000000001000000000101773';
        acc2.Murex_Counter_Label__c = 'eclient';

        accList.add(acc2);
        
        insert accList; 

        Merge_Customer__c mergeCust = New Merge_Customer__c();
        mergeCust.RM_ID_New__c = '001100000000001000000000101773';
        mergeCust.RM_ID_Old__c = '001100000000001000000000101772';
        mergeCust.Customer_New__c = accList[1].id;
        mergeCust.Customer_Old__c = accList[0].id;
        insert mergeCust;


        //1 insert lead
        Lead leadRecord = new Lead();
        leadRecord.Customer_Type__c = 'Individual';
        leadRecord.Company = 'test lead';
        leadRecord.FirstName = 'first';
        leadRecord.LastName = 'last';
        leadRecord.recordtypeid = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Commercial Account').getRecordTypeId();
        leadRecord.Account__c = accList[0].id;
        insert leadRecord;

        //2 insert contact
        Contact con = New Contact();
        con.FirstName = 'first';
        con.LastName = 'last';
        con.AccountId = accList[0].id;
        con.recordtypeid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Salesforce').getRecordTypeId();
        insert con;

        //3. insert case
        Case cas = New Case();
        cas.AccountId =accList[0].id;
        cas.Current_Service_Template__c = 'General';
        cas.Service_Type_Matrix_Code__c = '00001';
        cas.PTA_Segment__c = 'RBG';
        cas.Category__c = 'Inquiry';
        cas.Sub_Category__c = 'Test11';
        cas.Status = 'New';
        cas.Subject = 'Test';
        cas.recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Retail Service').getRecordTypeId();
        insert cas;

        //4. Move Opportunity
        Opportunity oppty = New Opportunity();
        oppty.AccountId = accList[0].id;
        oppty.recordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SE Credit Product').getRecordTypeId();
        oppty.Name = 'test opp';
        oppty.Expected_submit_date__c = system.today();
        oppty.CloseDate = system.today();
        oppty.StageName = 'Analysis';
        insert oppty;

        //5. Insert visit plan report
        Call_Report__c visit = New Call_Report__c();
        visit.Customer_name__c = accList[0].id;
        visit.Date_of_Visit__c = system.today() +1;
        visit.Categories__c = 'Initiatives';
        visit.Main_purpose__c = 'CB';
        visit.Sub_Purpose__c = 'Cash_Fleet Card';
        visit.Status__c = '1 - Open';
        insert visit;

        //6. insert Director
        Director__c dir = New Director__c();
        dir.Account__c = accList[0].id;
        dir.First_Name_TH__c = 'test';
        dir.Last_Name_TH__c = 'last';
        dir.Director_External_ID__c = 'asdv9999';
        dir.Director_Seq__c = '1';
        insert dir;


        //7. insert Share Holder
        Share_Holder__c shareH = New Share_Holder__c();
        shareH.Account__c = accList[0].id;
        shareH.Share_Holder_External_ID__c = '623223';
        shareH.BAHT_SHARE__c = 400;
        shareH.Percent_Share__c = 20;
        shareH.Ref_Dataset_ID__c = '7234338';
        insert shareH;

        //8. Insert FX order
        FX_Order__c fx = new FX_Order__c();
        fx.FXO_Customer__c = accList[0].id;
        fx.FXO_BuySell__c = 'Buy';
        fx.FXO_Currency__c = 'USD';
        fx.FXO_CurrencyPair__c = '	USD/THB';
        fx.FXO_RequestAmount__c = 12;
        fx.FXO_CustomerRate__c = 12;
        fx.FXO_InterbankRate__c = 12;
        insert fx;

        //9. insert Do Not Contact
        RTL_Do_not_Contact_Info__c donot = new RTL_Do_not_Contact_Info__c();
        donot.Customer__c = accList[0].id;
        donot.Product_Group__c = 'All';
        donot.Channel__c = 'Phone';
        donot.Period__c = 'Other';
        donot.Start_Date__c = system.today();
        donot.End_Date__c = system.today() + 100;
        insert donot;

        //11. insert referral
        RTL_Referral__c refer = new RTL_Referral__c();
        refer.RTL_Account_Name__c = accList[0].id;
        refer.RTL_FirstName__c = 'Test A';
        refer.RTL_LastName__c = 'Test last';
        refer.RTL_Type__c = 'Sell (เพื่อนำเสนอขาย)';
        refer.RTL_Interested_Product__c = 'Payroll';
        refer.RTL_Stage__c = 'New';
        refer.RTL_Mobile1__c = '0911111100';
        refer.RTL_Preferred_Branch__c = branchAndZoneList[0].id;
        insert refer;

        //12. insert E Client Suitability
        E_Client_Suitability__c esuit = new E_Client_Suitability__c();
        esuit.CS_Customer__c = accList[0].id;
        esuit.CS_Key__c = '6387438';
        esuit.CS_Status__c = 'Pending Review';
        esuit.CS_Murex_ID__c = '3456';
        insert esuit;

        //16. insert Customer Migration Note
        RTL_Customer_Migration_Info__c custNote = New RTL_Customer_Migration_Info__c();
        custNote.RTL_Customer__c = accList[0].id;
        custNote.RTL_Migration_Customer_Info_No__c = '34325432534';
        custNote.RTL_Migration_Info_Text__c = 'hello';
        insert custNote;

        //17. insert Customer Note Info
        Customer_Note_Info__c custInfo = new Customer_Note_Info__c();
        custInfo.Customer__c = accList[0].id;
        custInfo.Migration_Customer_Info_No__c = '6253462';
        custInfo.Migration_Info_Text__c = 'test';
        insert custInfo;
        
        //19. insert Account Plan company port
         AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(UserInfo.getUserId(), '2014', 10000000, false);
         insert portfolio;
      	 List<AcctPlanCompanyPort__c> comportList = AccountPlanTestUtilities.createCompanyPortByAccount(accList, portfolio, true);

        //20. insert Collateral
        Collateral__c coll = new Collateral__c();
        coll.Account__c = accList[0].id;
        coll.Collateral_Group_Type_Key__c = '24222223';
        coll.Collateral_Group_Type__c = 'test';
        insert coll;

        //22. Insert Account Annual Performance
        AcctAnnualPerformance__c accAnnual = new AcctAnnualPerformance__c();
        accAnnual.Account__c = accList[0].id;
        accAnnual.External_Key__c = '2343543';
        accAnnual.TMB_CUST_ID__c = '00110000000000000000002345090';
        insert accAnnual;

        //24. insert forecast input
       /* Monthly_Forecast_Input__c forecast = new Monthly_Forecast_Input__c();
        forecast.Customer__c = accList[0].id;
        forecast.Account_Suffix_Ref__c = '345343';
        forecast.Opportunity__c = oppty.id;
        forecast.YearMonthAcctSuffRef__c = 'weiiwor33';
        forecast.adjustMonthYear__c = system.today();
        insert forecast;  */

        //25. insert Product fee
        Product_Fee__c proFee = new Product_Fee__c();
        proFee.Customer__c = accList[0].id;
        proFee.Product_Fee_Vol_Ext__c = 'w343534';
        proFee.As_Of_Date__c = system.today();
        insert proFee;

        //26. insert Product NIM
        Product_NIM__c proNim = new Product_NIM__c();
        proNim.Customer__c = accList[0].id;
        proNim.Product_Fee_Vol_Ext__c = '324353';
        insert proNim;

        //27. insert product performance
       /* Product_Performance__c proPer = new Product_Performance__c();
        proPer.Account__c = accList[0].id;
        proPer.Product_Perf_External_Key__c = '234232gg';
        proPer.NIMC_MTD__c = 3000;
        proPer.Product_Hierachy_Code__c  = 'e35343';
        insert proPer; */

        //28. insert product Transection Risk
        Product_Trans_Risk__c proRisk =new Product_Trans_Risk__c();
        proRisk.Account__c = accList[0].id;
        proRisk.Product_Tran_Risk_Key__c = '323453';
        proRisk.As_of_Date__c = system.today();
        insert proRisk;

        //29. insert product on hand
        Product_Information_On_Hand__c productOnhand = new Product_Information_On_Hand__c();
        productOnhand.Account__c = accList[0].id;
        productOnhand.Product_code__c = '353433';
        insert productOnhand;

        //30. insert Tbank Case
        TBank_Case_History__c tbankCase = new TBank_Case_History__c();
        tbankCase.Customer__c = accList[0].id;
        tbankCase.CONTACT_NAME__c = 'testA';
        tbankCase.CUST_NAME__c = 'cust';
        insert tbankCase;

        //31. insert Tbank complaint
        TBank_Complaint_History__c tbankCom = new TBank_Complaint_History__c();
        tbankCom.Customer__c = accList[0].id;
        tbankCom.ComplainerInfoName__c = 'testB';
        tbankCom.ComplainerInfoSurName__c = 'testC';
        insert tbankCom;

        //32. insert task
        Task tas = new Task();
        tas.whatid = accList[0].id;
        tas.Subject = 'Call';
        tas.Status = 'Not Started';
        insert tas;   
        
        Income_Estimation__c income = new Income_Estimation__c();
        income.Account__c = accList[0].id;
        income.Income_External_Key__c = '34567';
        income.BOT_ID__c = '4656556';
        income.as_of_date__c = system.today();
        income.Valida_date__c = 'ok';
        income.Model_Type__c = 'test';
        insert income;
        
        RTL_Fulfillment__c fulfil = new RTL_Fulfillment__c();
        fulfil.RTL_Customer__c = accList[0].id;
        fulfil.RTL_Fulfillment_ID__c = '34567';
        insert fulfil;

        BatchMergeCustomer1 testbatch = new BatchMergeCustomer1();
        testbatch.execute(null);

        Test.stopTest();
    }

}