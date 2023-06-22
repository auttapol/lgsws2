@isTest
global class DeleteAccountPlanDuplicateTest {
static {
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();
        TestUtils.createDisqualifiedReason();
        TestUtils.CreateAddress();
        AccountPlanTestUtilities.getAcctPlanMode();
        AccountPlanWalletTestUtilities.createStandardFee();
        AccountPlanWalletTestUtilities.createBanks();
        AccountPlanWalletTestUtilities.createCurrencies();
        List<sObject> ls =
        Test.loadData(AcctPlan_Questionnaire_Template__c.sObjectType /*API Name*/, 'AcctPlanQuestionnaireTemplate' /*Static Resource Name*/);
        AccountPlanTestUtilities.AccountPlanStatusCode();
        insert new Account_Plan_Fiscal_Year__c(name='test09',AD_Year__c='2016',BE_Year__c='2559');
    }

    static testmethod void DeleteAccountPlan() {
        User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID, false, true).get(0);
        
        List<Account> AccountList = AccountPlanTestUtilities.createAccounts(5, 'InitiateTest', 'Individual', SalesOwner.id, true, true);
        Group__c mastergroup = AccountPlanTestUtilities.createGroupMaster(1, 'Initiatetest', false, true).get(0);
        for (account acct : AccountList) {
            acct.Group__c = mastergroup.id;
        }
        update AccountList;
        AccountPlanTestUtilities.createAccounts(1, 'InitiateNonGroupTest', 'Individual', SalesOwner.id, true, true);
        List<Target__c> TaragetList = AccountPlanTestUtilities.createTargetNI(5, SalesOwner.id, true);

        List<Account> acctForCompanyProfile = new List<Account> ();
        acctForCompanyProfile.add(AccountList.get(0));

        system.runAs(SalesOwner) {
            AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(SalesOwner.id, '2014', 10000000, false);
            insert portfolio;
            List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
            AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
            List<group__c> mgroupList = new List<group__c> ();
            mgroupList.add(mastergroup);
            AcctPlanGroupProfile__c groupprofile = AccountPlanTestUtilities.createGroupProfilebyGroup(mgroupList, true).get(0);
            comprofile.AcctPlanGroup__c = groupprofile.id;
            update comprofile;
            AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
            List<Group__c> groupmasterlist = new List<Group__c>();
                groupmasterlist.add(mastergroup);
            List<AcctPlanGroupPort__c> groupportlist = AccountPlanTestUtilities.createGroupPortbyGroupMaster(groupmasterlist, portfolio, true);
            List<AcctPlanCompanyPort__c> comportList = AccountPlanTestUtilities.createCompanyPortByAccount(AccountList, portfolio, true);
            String year = '2015';
            
           //AccountPlanAdditionalBusOpptCtrl busOpptList = new AccountPlanAdditionalBusOpptCtrl();
           ApexPages.StandardController sc = new ApexPages.StandardController(AccountList.get(0));
           
            
          
      
            
            comprofile.isMiniMode__c = false;
            update comprofile;
            Set<Id> setId = new Set<id>();
            setId.add(comprofileList.get(0).id);
            List<sObject> obj = (List<AcctPlanCompanyProfile__c>) AccountPlanCloneUtils.getObject('AcctPlanCompanyProfile__c','Id',setId); 


            List<AcctPlanContribution__c> contributionlist = AccountPlanTestUtilities.createRenevueContribution(3,null, comprofile.id);
          contributionlist.get(0).RevenueContributionType__c = 'Contribution by service & product';
          contributionlist.get(1).RevenueContributionType__c = 'Contribution by business unit';
          contributionlist.get(2).RevenueContributionType__c = 'Contribution by regional';
         update contributionlist;
            AccountPlanTestUtilities.CreateSupplierOrBuyer(5,comprofile.id);
            AccountPlanTestUtilities.CreateTop5(5,comprofile.id);
            //AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, false);
        AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
        AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);
        AcctPlanQuestionnaire__c questionnaire = new AcctPlanQuestionnaire__c();
         questionnaire.Answer__c = 'Yes';
         questionnaire.AcctPlanWallet__c = acctplanwallet.id;
         questionnaire.Segment__c ='Credit life insurance';
         insert questionnaire;
        //otherbank
        AcctPlanWalletOtherBank__c otherbank1 = new AcctPlanWalletOtherBank__c();
            otherbank1.TableName__c = 'Collection Method Domestic';
            otherbank1.AcctPlanWallet__c = acctplanwallet.id;
            insert otherbank1; 
            AcctPlanWalletOtherBank__c otherbank2 = new AcctPlanWalletOtherBank__c();
            otherbank2.TableName__c = 'Collection Method Export';
            otherbank2.AcctPlanWallet__c = acctplanwallet.id;
            insert otherbank2; 
            AcctPlanWalletOtherBank__c otherbank3 = new AcctPlanWalletOtherBank__c();
            otherbank3.TableName__c = 'Payment Method Domestic';
            otherbank3.AcctPlanWallet__c = acctplanwallet.id;
            insert otherbank3; 
            AcctPlanWalletOtherBank__c otherbank4 = new AcctPlanWalletOtherBank__c();
            otherbank4.TableName__c = 'Payment Method Import';
            otherbank4.AcctPlanWallet__c = acctplanwallet.id;
            insert otherbank4; 
            
        AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);

            AcctPlanPaymentImport__c payImport = new AcctPlanPaymentImport__c();
         payImport.AcctPlanPaymentMethodImport__c = AcctPlanwallet.id;
         payImport.Label__c ='L/C Term';
         payImport.Volume__c = 20;
         insert payImport;

         AcctPlanPaymentDomestic__c PayDomestic = new AcctPlanPaymentDomestic__c();
         PayDomestic.AcctPlanPaymentMethodDomestic__c = AcctPlanwallet.id;
         payDomestic.Label__c = '3.1 Bahtnet';
         payDomestic.Volume__c = 20;
         insert paydomestic;

         AcctPlanCollectionDomestic__c colDomestic = new AcctPlanCollectionDomestic__c();
         colDomestic.AcctPlanCollectionMethodDomestic__c =AcctPlanwallet.id;
         colDomestic.NoOfTransaction__c =100;
         colDomestic.Volume__c = 50;
         colDomestic.Label__c = '3) Bill Payment';
         insert ColDomestic;


        AcctPlanCollectionExport__c colExport = new AcctPlanCollectionExport__c();
         colExport.AcctPlanCollectionMethodExport__c = AcctPlanwallet.id;
         colExport.Label__c = 'L/C Term';
         colExport.Volumn__c = 20;
         insert colExport;

         List<String> APDepositInternationalLabel  = new List<String>{'Transactional','1) Current - USD','Current - Other Currency','2) Saving - USD','Saving - Other Currency','Non Transactional','Time Deposit - USD','Time Deposit - Other Currency','Others - USD','Others - Other Currency','Total'};
             Map<String,AcctPlanDepositInternational__c> APDepositInternationalList = new Map<String,AcctPlanDepositInternational__c> ();
                for(String l : APDepositInternationalLabel){ 
                AcctPlanDepositInternational__c APDepositInternationalitem = new AcctPlanDepositInternational__c();
                APDepositInternationalitem.AccountPlanDepositInternationalDeposit__c = AcctPlanwallet.Id;
                APDepositInternationalitem.Label__c = l;
                APDepositInternationalList.put(l,APDepositInternationalitem);
            }
            insert APDepositInternationalList.values();
            
            List<String> APDepositDomesticLabel = new List<String>{'Transactional','1) Current','2) Saving','Non Transactional','Time Deposit','T-Bill','Mutual Fund','Others','Total'};
           Map<String,AcctPlanDepositDomestic__c> APDepositDomesticList = new Map<String,AcctPlanDepositDomestic__c> ();

            for(String l : APDepositDomesticLabel){ 
                AcctPlanDepositDomestic__c APDepositDomesticitem = new AcctPlanDepositDomestic__c();
                APDepositDomesticitem.AccountPlanDepositDomesticDeposit__c = AcctPlanwallet.Id;
                APDepositDomesticitem.Label__c = l;
                APDepositDomesticList.put(l,APDepositDomesticitem);
            }
            insert APDepositDomesticList.values();

Account_Plan_AS_Fee__c asfee1 = new Account_Plan_AS_Fee__c();
            asfee1.Account_Plan_Wallet__c =acctplanwallet.id;
            asfee1.Net_Asset_Value__c =150000;
            asfee1.Fixed_AS_Fee__c  =50;
            asfee1.AS_Product_Service__c ='1)';
            asfee1.Type_of_Fee__c  ='Fixed';
            insert asfee1;
            
            Account_Plan_AS_Fee__c asfee2 = new Account_Plan_AS_Fee__c();
            asfee2.Account_Plan_Wallet__c =acctplanwallet.id;
            asfee2.Net_Asset_Value__c =150000;
            asfee2.Fixed_AS_Fee__c  =50;
            asfee2.AS_Product_Service__c ='2)';
            asfee2.Type_of_Fee__c  ='Fixed';
            insert asfee2;
            
            Account_Plan_AS_Fee__c asfee3 = new Account_Plan_AS_Fee__c();
            asfee3.Account_Plan_Wallet__c =acctplanwallet.id;
            asfee3.Net_Asset_Value__c =150000;
            asfee3.Fixed_AS_Fee__c  =50;
            asfee3.AS_Product_Service__c ='3)';
            asfee3.Type_of_Fee__c  ='Fixed';
            insert asfee3;
            
            Account_Plan_AS_Fee__c asfee4 = new Account_Plan_AS_Fee__c();
            asfee4.Account_Plan_Wallet__c =acctplanwallet.id;
            asfee4.Net_Asset_Value__c =150000;
            asfee4.Fixed_AS_Fee__c  =50;
            asfee4.AS_Product_Service__c ='4)';
            asfee4.Type_of_Fee__c  ='Fixed';
            insert asfee4;
            
            Account_Plan_AS_Fee__c asfee5 = new Account_Plan_AS_Fee__c();
            asfee5.Account_Plan_Wallet__c =acctplanwallet.id;
            asfee5.Net_Asset_Value__c =150000;
            asfee5.Fixed_AS_Fee__c  =50;
            asfee5.AS_Product_Service__c ='5)';
            asfee5.Type_of_Fee__c  ='Fixed';
            insert asfee5;

            List<AcctPlanWorkingCapital__c> APWorkingCapital = new List<AcctPlanWorkingCapital__c>();     
            
            AcctPlanWorkingCapital__c item1 = new AcctPlanWorkingCapital__c();
            item1.AcctPlanWallet__c = AcctPlanwallet.Id;
            item1.RecordType__c = 'Normal Period';
            item1.AvgAPDays__c = 20;
            item1.AvgARDays__c = 30;
            item1.AvgInvDays__c = 10;
            item1.NimcPercent__c = 15;
            item1.FrontEndFee__c = 30;

            APWorkingCapital.add(item1);
            
            AcctPlanWorkingCapital__c item2 = new AcctPlanWorkingCapital__c();
            item2.AcctPlanWallet__c = AcctPlanwallet.Id;
            item2.RecordType__c = 'High Season Period';
            item2.AvgAPDays__c = 20;
            item2.AvgARDays__c = 30;
            item2.AvgInvDays__c = 10;
            item2.NimcPercent__c = 15;
            item2.FrontEndFee__c = 30;

            APWorkingCapital.add(item2);   
            
            insert APWorkingCapital;

            AcctPlanWalletCreditFacility__c creditFac1 = new AcctPlanWalletCreditFacility__c();
            creditFac1.AcctPlanWallet__c = acctPlanwallet.id;
            creditFac1.Segment__c = 'Domestic';
            creditFac1.LimitAmount__c = 0;
            creditFac1.Outstanding__c = 0;
            insert creditFac1;
            AcctPlanWalletCreditFacility__c creditFac2 = new AcctPlanWalletCreditFacility__c();
            creditFac2.AcctPlanWallet__c = acctPlanwallet.id;
            creditFac2.Segment__c = 'ImportTransaction';
            creditFac2.LimitAmount__c = 10;
            creditFac2.Outstanding__c = 10;
            insert creditFac2;
            AcctPlanWalletCreditFacility__c creditFac3 = new AcctPlanWalletCreditFacility__c();
            creditFac3.AcctPlanWallet__c = acctPlanwallet.id;
            creditFac3.Segment__c = 'ExportTransaction';
            creditFac3.LimitAmount__c = 10;
            creditFac3.Outstanding__c = 10;
            insert creditFac3;
            
            AcctPlanExistingLongTermLoan__c longtermloan1 = new AcctPlanExistingLongTermLoan__c();
            longtermloan1.AcctPlanWallet__c = acctplanwallet.id;
            longtermloan1.EquivalentAmount__c =0;
            longtermloan1.WalletNiicYearly__c = 0;
            insert longtermloan1;

             AcctPlanCapitalExpenditurePlan__c expend1 = new AcctPlanCapitalExpenditurePlan__c();
                expend1.ProjectAmount__c = null;
                expend1.AcctPlanWallet__c = acctplanwallet.id;
                expend1.WalletNiicYearly__c  =null;
                expend1.CreditFee__c = null;
                insert expend1;
            AcctPlanLGProject__c lgproject = new AcctPlanLGProject__c();
            lgproject.AcctPlanWallet__c =  acctplanwallet.id;
            insert lgproject;

            AcctPlanForeignTrans__c fortrans = new AcctPlanForeignTrans__c();
            fortrans.AcctPlanWallet__c = acctplanwallet.id;
            fortrans.HedgingRatio__c = 10;
            fortrans.AmtPerYear__c = 10;
            fortrans.FXMarginStg__c = 0.1;
            insert fortrans;

                 
        
        //Create Contact
        Contact cont = new Contact();
        cont.FirstName='AccountPlan';
        cont.LastName='Step5';
        cont.Position__c = 'Manager';
        cont.Accountid= AccountList.get(0).id;
        insert cont;
        
        
        
        AcctPlanWalletByDomain__c WalletDomain = new AcctPlanWalletByDomain__c();
        WalletDomain.AcctPlanWallet__c = acctPlanwallet.id;
        WalletDomain.WalletDomain__c = 1;
        WalletDomain.Priority__c ='High';
        WalletDomain.SubDomain__c ='Liquidity Management';
        WalletDomain.TypeOfNI__c = 'NIIC';
        insert WalletDomain;
        
        AcctPlanWalletByDomain__c WalletDomaing2 = new AcctPlanWalletByDomain__c();
        WalletDomaing2.AcctPlanWallet__c = acctPlanwallet.id;
        WalletDomaing2.WalletDomain__c = 4;
        WalletDomaing2.Priority__c ='Medium';
        WalletDomaing2.SubDomain__c ='Hedging Normal business transaction : Trade transaction';
        WalletDomaing2.TypeOfNI__c = 'FX Fee';
        insert WalletDomaing2;
        
        AcctPlanActionPlan__c acctplan = new AcctPlanActionPlan__c();
        acctplan.AcctPlanWalletByDomain__c = WalletDomaing2.id;
        acctplan.Objective__c = 'Acquire New customers';
        acctplan.Status__c = 'Post Board';
        acctplan.WinningPropostion__c = 'Test Class';
        insert acctplan;
        
        Task t1=new Task();
        insert t1;
        
        AcctPlanActivity__c activity = new AcctPlanActivity__c();
        activity.AccountPlanActionPlanID__c = acctplan.id;
        activity.Objective__c = 'Acquire New customers';
        activity.Status__c = 'Post Board';
        activity.Group__c = 'Group 1 Relationship';
        activity.Activities__c = 'Work on negative relationship';
        activity.Date__c = System.Today();
        activity.TaskId__c = t1.id;
        insert activity;

        
        AcctPlanStakeholder__c stake = new AcctPlanStakeholder__c();
        stake.AcctPlanActivity__c = activity.id;
        Id select1user = [select id from user limit 1].Id;
        stake.User__c = select1user ;
        insert stake;

            
            AcctPlanNIProject__c nirecord = new AcctPlanNIProject__c();
        nirecord.AcctPlanActionPlanID__c= acctplan.id;
        nirecord.PropsProductOrServices__c = 'OD';
        nirecord.ExpectedIncremental__c = 10000;
        nirecord.TypeOfNI__c = 'NIIc';
        nirecord.NIRecuringType__c='Recurring';
        nirecord.ExpectedNimRate__c=10.00;
        nirecord.ExpectedIncrementalNIPerYear1Year__c=10000;
        nirecord.ExpectedIncrementalNIPerYear2Year__c=10000;
        nirecord.NIStartMonth__c = 'Jan';
        nirecord.NIStartYear__c= '2016';
        nirecord.DealProbability__c= '25%';
        insert nirecord;
       
            MockProductStrategy(comprofile.id, acctPlanwallet.id);
            
            AcctPlanCusUnderstanding__c custoutstanding1 = new AcctPlanCusUnderstanding__c();
            custoutstanding1.AcctPlanWallet__c =AcctPlanwallet.id;
            custoutstanding1.Ending_CASA__c =100;
            custoutstanding1.Average_CASA__c =100;
            custoutstanding1.Average_loan_outstanding__c =100;
            custoutstanding1.Ending_loan_outstanding__c =100;
            custoutstanding1.FX_volume__c =100;
            custoutstanding1.TF_Volume__c =100;
            custoutstanding1.Account__c = AccountList.get(0).id;

            insert custoutstanding1;
            
            Account_Plan_Flow_Header__c fheader21 = new Account_Plan_Flow_Header__c();
         fheader21.EX_ID__C ='PD09';
         fheader21.SEQ__C = 1;
         fheader21.Method__c = 'Payment Domestic';
         fheader21.Label__c = '3) Fund Transfer';
         fheader21.isActive__c = true;
         fheader21.isVolumePercent__c = true;
         
         insert fheader21;
            
          Account_Plan_Flow_Details__c fdetail1 = new Account_Plan_Flow_Details__c();
         fdetail1.Account_Plan_Flow_Header__c = fheader21.id;
         fdetail1.Volume__c  =15000000;
         fdetail1.VolumePercent__c = 50;
         fdetail1.NoOfTransaction__c = 5000;
         fdetail1.Account_Plan_Wallet__c = AcctPlanwallet.id;
         insert fdetail1;
         
         
         
         Account_Plan_Flow_Header__c fheader2 = new Account_Plan_Flow_Header__c();
         fheader2.EX_ID__C ='PD1';
         fheader2.SEQ__C = 1;
         fheader2.Account_Plan_Flow_Header__c = fheader21.id;
         fheader2.Method__c = 'Payment Domestic';
         fheader2.Label__c = '3.1 Bahtnet';
         fheader2.isActive__c = true;
         fheader2.isVolumePercent__c = true;
         
         insert fheader2;
        
         
         Account_Plan_Flow_Details__c fdetail2 = new Account_Plan_Flow_Details__c();
         fdetail2.Account_Plan_Flow_Header__c = fheader2.id;
         fdetail2.Volume__c  =15000000;
         fdetail2.VolumePercent__c = 50;
         fdetail2.NoOfTransaction__c = 5000;
         fdetail2.Account_Plan_Wallet__c = AcctPlanwallet.id;
         insert fdetail2;
         
         
          Account_Plan_Flow_Header__c fheader3 = new Account_Plan_Flow_Header__c();
         fheader3.EX_ID__C ='PI1';
         fheader3.SEQ__C = 1;
         fheader3.Method__c = 'Payment Import';
         fheader3.Label__c = 'L/C Term';
         fheader3.isActive__c = true;
         fheader3.isVolumePercent__c = true;
         
         insert fheader3;
            
            
            
            
       
            Set<Id> AccountCompanyProfileID = new Set<Id>();
            AccountCompanyProfileID.add(comprofile.id);
            DeleteAccountPlanDuplicate deleteAcctplanCRM = new DeleteAccountPlanDuplicate();
            deleteAcctplanCRM.DeleteAccountPlanDuplicateAction(AccountCompanyProfileID,false); //for cleasing dup form users
             deleteAcctplanCRM.DeleteAccountPlanDuplicateAction(AccountCompanyProfileID,true); //for PVT Account Plan
            deleteAcctplanCRM.DeleteAccountPlanDuplicateAction(null,true); //for PVT normal
        }

    }
    static void MockProductStrategy(Id companyProfileId, Id walletId)
    {
        AcctPlanProdStrategy__c prodStrategy1 = new AcctPlanProdStrategy__c();
        prodStrategy1.SEQ__c = 1;
        prodStrategy1.Name = '1. NIIc';
        prodStrategy1.WalletSizing__c = 10000;
        prodStrategy1.AnnualizedPerformance__c = 100;
        prodStrategy1.Adjust_NI__c = 150;
        prodStrategy1.ExpectedIncrementalNIFromStep5__c = 10;

        prodStrategy1.AccountPlanYear__c = 2015;   
        prodStrategy1.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy1.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy1.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy1.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy1.AcctPlanWallet__c = walletId;
        prodStrategy1.AspirationSOW__c = 0.2;        
        prodStrategy1.RefreshAsOf__c = Date.today();
        insert prodStrategy1;
        
        AcctPlanProdStrategy__c prodStrategy2 = new AcctPlanProdStrategy__c();
        prodStrategy2.SEQ__c = 2;
        prodStrategy2.Name = '2. NIId';
        prodStrategy2.WalletSizing__c = 10000;
        prodStrategy2.AnnualizedPerformance__c = 100;
        prodStrategy2.Adjust_NI__c = 150;
        prodStrategy2.ExpectedIncrementalNIFromStep5__c = 10;
        
        prodStrategy2.AccountPlanYear__c = 2015;   
        prodStrategy2.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy2.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy2.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy2.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy2.AcctPlanWallet__c = walletId;
        prodStrategy2.AspirationSOW__c = 0.2;        
        prodStrategy2.RefreshAsOf__c = Date.today();
        insert prodStrategy2;
        
        AcctPlanProdStrategy__c prodStrategy3 = new AcctPlanProdStrategy__c();
        prodStrategy3.SEQ__c = 3;
        prodStrategy3.Name = '3. Fee';
        prodStrategy3.WalletSizing__c = 10000;
        prodStrategy3.AnnualizedPerformance__c = 100;
        prodStrategy3.Adjust_NI__c = 150;
        prodStrategy3.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy3.AccountPlanYear__c = 2015;   
        prodStrategy3.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy3.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy3.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy3.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy3.AcctPlanWallet__c = walletId;
        prodStrategy3.AspirationSOW__c = 0.2;        
        prodStrategy3.RefreshAsOf__c = Date.today();
        insert prodStrategy3;
        
        AcctPlanProdStrategy__c prodStrategy4 = new AcctPlanProdStrategy__c();
        prodStrategy4.SEQ__c = 4;
        prodStrategy4.Name = 'Recurring Fee';
        prodStrategy4.WalletSizing__c = 0;
        prodStrategy4.AnnualizedPerformance__c = 00;
        prodStrategy4.Adjust_NI__c = 0;
        prodStrategy4.ExpectedIncrementalNIFromStep5__c = 0;
                
        prodStrategy4.AccountPlanYear__c = 2015;   
        prodStrategy4.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy4.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy4.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy4.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy4.AcctPlanWallet__c = walletId;
        prodStrategy4.AspirationSOW__c = 0;        
        prodStrategy4.RefreshAsOf__c = Date.today();
        insert prodStrategy4;
        
        AcctPlanProdStrategy__c prodStrategy5 = new AcctPlanProdStrategy__c();
        prodStrategy5.SEQ__c = 5;
        prodStrategy5.Name = '3.1 TF Fee';
        prodStrategy5.WalletSizing__c = 10000;
        prodStrategy5.AnnualizedPerformance__c = 100;
        prodStrategy5.Adjust_NI__c = 150;
        prodStrategy5.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy5.AccountPlanYear__c = 2015;   
        prodStrategy5.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy5.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy5.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy5.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy5.AcctPlanWallet__c = walletId;
        prodStrategy5.AspirationSOW__c = 0.2;        
        prodStrategy5.RefreshAsOf__c = Date.today();
        insert prodStrategy5;
        
        AcctPlanProdStrategy__c prodStrategy6 = new AcctPlanProdStrategy__c();
        prodStrategy6.SEQ__c = 6;
        prodStrategy6.Name = '3.2 FX Fee';
        prodStrategy6.WalletSizing__c = 10000;
        prodStrategy6.AnnualizedPerformance__c = 100;
        prodStrategy6.Adjust_NI__c = 150;
        prodStrategy6.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy6.AccountPlanYear__c = 2015;   
        prodStrategy6.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy6.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy6.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy6.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy6.AcctPlanWallet__c = walletId;
        prodStrategy6.AspirationSOW__c = 0.2;        
        prodStrategy6.RefreshAsOf__c = Date.today();
        insert prodStrategy6;
        
        AcctPlanProdStrategy__c prodStrategy7 = new AcctPlanProdStrategy__c();
        prodStrategy7.SEQ__c = 7;
        prodStrategy7.Name = '3.3 L/G Fee';
        prodStrategy7.WalletSizing__c = 10000;
        prodStrategy7.AnnualizedPerformance__c = 100;
        prodStrategy7.Adjust_NI__c = 150;
        prodStrategy7.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy7.AccountPlanYear__c = 2015;   
        prodStrategy7.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy7.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy7.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy7.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy7.AcctPlanWallet__c = walletId;
        prodStrategy7.AspirationSOW__c = 0.2;        
        prodStrategy7.RefreshAsOf__c = Date.today();
        insert prodStrategy7;
                
        AcctPlanProdStrategy__c prodStrategy8 = new AcctPlanProdStrategy__c();
        prodStrategy8.SEQ__c = 8;
        prodStrategy8.Name = '3.4 Cash Fee';
        prodStrategy8.WalletSizing__c = 10000;
        prodStrategy8.AnnualizedPerformance__c = 100;
        prodStrategy8.Adjust_NI__c = 150;
        prodStrategy8.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy8.AccountPlanYear__c = 2015;   
        prodStrategy8.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy8.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy8.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy8.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy8.AcctPlanWallet__c = walletId;
        prodStrategy8.AspirationSOW__c = 0.2;        
        prodStrategy8.RefreshAsOf__c = Date.today();
        insert prodStrategy8;
        
        AcctPlanProdStrategy__c prodStrategy9 = new AcctPlanProdStrategy__c();
        prodStrategy9.SEQ__c = 9;
        prodStrategy9.Name = '3.5 AS Fee';
        prodStrategy9.WalletSizing__c = 10000;
        prodStrategy9.AnnualizedPerformance__c = 100;
        prodStrategy9.Adjust_NI__c = 150;
        prodStrategy9.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy9.AccountPlanYear__c = 2015;   
        prodStrategy9.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy9.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy9.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy9.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy9.AcctPlanWallet__c = walletId;
        prodStrategy9.AspirationSOW__c = 0.2;        
        prodStrategy9.RefreshAsOf__c = Date.today();
        insert prodStrategy9;
        
        AcctPlanProdStrategy__c prodStrategy10 = new AcctPlanProdStrategy__c();
        prodStrategy10.SEQ__c = 10;
        prodStrategy10.Name = 'Non Recurring Fee';
        prodStrategy10.WalletSizing__c = 0;
        prodStrategy10.AnnualizedPerformance__c = 0;
        prodStrategy10.Adjust_NI__c = 0;
        prodStrategy10.ExpectedIncrementalNIFromStep5__c = 0;
                
        prodStrategy10.AccountPlanYear__c = 2015;   
        prodStrategy10.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy10.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy10.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy10.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy10.AcctPlanWallet__c = walletId;
        prodStrategy10.AspirationSOW__c = 0;        
        prodStrategy10.RefreshAsOf__c = Date.today();
        insert prodStrategy10;
        
        AcctPlanProdStrategy__c prodStrategy11 = new AcctPlanProdStrategy__c();
        prodStrategy11.SEQ__c = 11;
        prodStrategy11.Name = '3.6 Credit Fee';
        prodStrategy11.WalletSizing__c = 10000;
        prodStrategy11.AnnualizedPerformance__c = 100;
        prodStrategy11.Adjust_NI__c = 150;
        prodStrategy11.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy11.AccountPlanYear__c = 2015;   
        prodStrategy11.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy11.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy11.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy11.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy11.AcctPlanWallet__c = walletId;
        prodStrategy11.AspirationSOW__c = 0.2;        
        prodStrategy11.RefreshAsOf__c = Date.today();
        insert prodStrategy11;
        
        AcctPlanProdStrategy__c prodStrategy12 = new AcctPlanProdStrategy__c();
        prodStrategy12.SEQ__c = 12;
        prodStrategy12.Name = '3.7 BA Fee';
        prodStrategy12.WalletSizing__c = 10000;
        prodStrategy12.AnnualizedPerformance__c = 100;
        prodStrategy12.Adjust_NI__c = 150;
        prodStrategy12.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy12.AccountPlanYear__c = 2015;   
        prodStrategy12.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy12.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy12.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy12.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy12.AcctPlanWallet__c = walletId;
        prodStrategy12.AspirationSOW__c = 0.2;        
        prodStrategy12.RefreshAsOf__c = Date.today();
        insert prodStrategy12;
        
        AcctPlanProdStrategy__c prodStrategy13 = new AcctPlanProdStrategy__c();
        prodStrategy13.SEQ__c = 13;
        prodStrategy13.Name = '3.8 Derivative Fee';
        prodStrategy13.WalletSizing__c = 10000;
        prodStrategy13.AnnualizedPerformance__c = 100;
        prodStrategy13.Adjust_NI__c = 150;
        prodStrategy13.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy13.AccountPlanYear__c = 2015;   
        prodStrategy13.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy13.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy13.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy13.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy13.AcctPlanWallet__c = walletId;
        prodStrategy13.AspirationSOW__c = 0.2;        
        prodStrategy13.RefreshAsOf__c = Date.today();
        insert prodStrategy13;
        
        AcctPlanProdStrategy__c prodStrategy14 = new AcctPlanProdStrategy__c();
        prodStrategy14.SEQ__c = 14;
        prodStrategy14.Name = '3.9 IB Fee';
        prodStrategy14.WalletSizing__c = 10000;
        prodStrategy14.AnnualizedPerformance__c = 100;
        prodStrategy14.Adjust_NI__c = 150;
        prodStrategy14.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy14.AccountPlanYear__c = 2015;   
        prodStrategy14.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy14.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy14.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy14.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy14.AcctPlanWallet__c = walletId;
        prodStrategy14.AspirationSOW__c = 0.2;        
        prodStrategy14.RefreshAsOf__c = Date.today();
        insert prodStrategy14;
        
    }
}