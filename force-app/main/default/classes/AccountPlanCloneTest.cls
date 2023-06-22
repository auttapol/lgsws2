@isTest
global class AccountPlanCloneTest {
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

    static testmethod void AccountPlanClone() {
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
           
            
            AccountPlanClone ctrl = new AccountPlanClone(sc);
             pageReference clonepage = Page.AccountPlanClone;
               clonepage.getParameters().put('AccountID',AccountList.get(0).id);
               clonepage.getParameters().put('CompanyPortID',comportList.get(0).id);
               clonepage.getParameters().put('GroupID',mastergroup.id);
               clonepage.getParameters().put('CompanyID',comprofile.id);
                clonepage.getParameters().put('WalletID',AcctPlanwallet.id);
               clonepage.getParameters().put('FiscalYearStr',year);
                clonepage.getParameters().put('CompanyIDClone',comprofile.id);
              
               Test.setCurrentPage(clonepage); 

               ctrl.CompanyProfileList = comprofileList;
               ctrl.companyprofileDetail = comprofileList.get(0);
               ctrl.portfolio = portfolio;
               ctrl.groupprofile = groupprofile;
               ctrl.isValid  = true;
               ctrl.YearStr = year;
               ctrl.CompanyIDClone = comprofile.id;

            AccountPlanClone clone = new AccountPlanClone(sc);
            clone.AccountPlanCloneAction();
            clone.AccountPlanNewAction();
            clone.CancelAction();
            clone.getFiscalYear();
            clone.getParameterIsClone();

          
            AccountPlanClone ctrl2 = new AccountPlanClone(sc);
             pageReference clonepage2 = Page.AccountPlanClone;
              clonepage2.getParameters().put('CompanyPortID',comportList.get(0).id);
              
              // clonepage2.getParameters().put('AccountID',AccountList.get(0).id);
              // clonepage2.getParameters().put('GroupID',mastergroup.id);
              // clonepage2.getParameters().put('CompanyID',comprofile.id);
                clonepage2.getParameters().put('WalletID',AcctPlanwallet.id);
               clonepage2.getParameters().put('FiscalYearStr',year);
              
               Test.setCurrentPage(clonepage2); 

               ctrl2.CompanyProfileList = comprofileList;
               ctrl2.companyprofileDetail = comprofileList.get(0);
               ctrl2.portfolio = portfolio;
               ctrl2.groupprofile = groupprofile;
               ctrl2.isValid  = true;

            AccountPlanClone clone2 = new AccountPlanClone(sc);
            clone2.AccountPlanCloneAction();
            clone2.AccountPlanNewAction();
            clone2.CancelAction();
            clone2.getFiscalYear();
            clone2.getParameterIsClone();

          
            AccountPlanClone ctrl3 = new AccountPlanClone(sc);
             pageReference clonepage3 = Page.AccountPlanClone;
              clonepage3.getParameters().put('GroupID',mastergroup.id);
              
              // clonepage3.getParameters().put('AccountID',AccountList.get(0).id);
               //clonepage3.getParameters().put('CompanyPortID',comportList.get(0).id);
               //clonepage3.getParameters().put('CompanyID',comprofile.id);
                clonepage3.getParameters().put('WalletID',AcctPlanwallet.id);
               clonepage3.getParameters().put('FiscalYearStr',year);
              
               Test.setCurrentPage(clonepage3); 

               ctrl3.CompanyProfileList = comprofileList;
               ctrl3.companyprofileDetail = comprofileList.get(0);
               ctrl3.portfolio = portfolio;
               ctrl3.groupprofile = groupprofile;
               ctrl3.isValid  = true;

            AccountPlanClone clone3 = new AccountPlanClone(sc);
            clone3.AccountPlanCloneAction();
            clone3.AccountPlanNewAction();
            clone3.CancelAction();
            clone3.getFiscalYear();
            clone3.getParameterIsClone();

            AccountPlanClone ctrl4 = new AccountPlanClone(sc);
             pageReference clonepage4 = Page.AccountPlanClone;
             clonepage4.getParameters().put('CompanyID',comprofile.id);
               
              // clonepage4.getParameters().put('AccountID',AccountList.get(0).id);
              // clonepage4.getParameters().put('CompanyPortID',comportList.get(0).id);
              // clonepage4.getParameters().put('GroupID',mastergroup.id);
              //  clonepage4.getParameters().put('WalletID',AcctPlanwallet.id);
               clonepage4.getParameters().put('FiscalYearStr',year);
              
               Test.setCurrentPage(clonepage4); 

               ctrl4.CompanyProfileList = comprofileList;
               ctrl4.companyprofileDetail = comprofileList.get(0);
               ctrl4.portfolio = portfolio;
               ctrl4.groupprofile = groupprofile;
               ctrl4.isValid  = true;

            AccountPlanClone clone4 = new AccountPlanClone(sc);
            clone4.AccountPlanCloneAction();
            clone4.AccountPlanNewAction();
            clone4.CancelAction();
            clone4.getFiscalYear();
            clone4.getParameterIsClone();

      
            /*Batch Account Plan Clone*/
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

            AccountPlanCloneBatch batch = new AccountPlanCloneBatch(comprofile.id,year);  
            Database.executeBatch(batch ,100);


//User SalesOwner2 = AccountPlanTestUtilities.createUsers(, 'RM', 'PortfolioMngSESTest', 'portfoliomngSE@test.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID, true, true).get(1);
            /*comprofile.isMiniMode__c = true;
            update comprofile;
            AccountPlanCloneBatch batch2 = new AccountPlanCloneBatch(comprofile.id,year);  
            Database.executeBatch(batch2,100);*/
            AccountPlanCloneUtils.GotoAccountPlanClonePage((String) AccountList.get(0).id, (String)  comportList.get(0).id, (String) mastergroup.id,(String)  comprofile.id,(String)  AcctPlanwallet.id);
       


        }

    }

static testmethod void AccountPlanCloneSE() {
        User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID, true, true).get(0);

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
            comprofile.isMiniMode__c = true;
            update comprofile;
            AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
            List<Group__c> groupmasterlist = new List<Group__c>();
                groupmasterlist.add(mastergroup);
            List<AcctPlanGroupPort__c> groupportlist = AccountPlanTestUtilities.createGroupPortbyGroupMaster(groupmasterlist, portfolio, true);
            List<AcctPlanCompanyPort__c> comportList = AccountPlanTestUtilities.createCompanyPortByAccount(AccountList, portfolio, true);
            String year = '2015';
            
            AccountPlanCloneBatch batch = new AccountPlanCloneBatch(comprofile.id,year);  
            Database.executeBatch(batch ,100);

            AccountPlanCloneUtils.GotoAccountPlanClonePage((String) AccountList.get(0).id, (String)  comportList.get(0).id, (String) mastergroup.id,(String)  comprofile.id,(String)  AcctPlanwallet.id);
       


        }

    }
    
    static testmethod void othertest()
    {
        test.startTest();
        
        User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID, false, true).get(0);
        
        List<Account> AccountList = AccountPlanTestUtilities.createAccounts(1, 'InitiateTest', 'Individual', userinfo.getuserid(), true, true);
        Group__c mastergroup = AccountPlanTestUtilities.createGroupMaster(1, 'Initiatetest', false, true).get(0);
        for (account acct : AccountList) {
            acct.Group__c = mastergroup.id;
            acct.Account_Plan_Flag__c = 'No';
            acct.Business_Type_Code__c = 'test';
        }
        update AccountList;
        insert new accountTeammember(accountid=accountList.get(0).id,userid=Salesowner.id,AccountAccessLevel='Edit');
        AccountPlanTestUtilities.createAccounts(1, 'InitiateNonGroupTest', 'Individual', userinfo.getuserid(), true, true);
        List<Target__c> TaragetList = AccountPlanTestUtilities.createTargetNI(5, userinfo.getuserid(), true);

        List<Account> acctForCompanyProfile = new List<Account> ();
        acctForCompanyProfile.add(AccountList.get(0));
        
        

    
            AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(userinfo.getuserid(), '2014', 10000000, false);
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
            
           ApexPages.StandardController sc = new ApexPages.StandardController(AccountList.get(0));
           
            
            AccountPlanClone ctrl = new AccountPlanClone(sc);
             pageReference clonepage = Page.AccountPlanClone;
               clonepage.getParameters().put('AccountID',AccountList.get(0).id);
               //clonepage.getParameters().put('CompanyPortID',comportList.get(0).id);
               //clonepage.getParameters().put('GroupID',mastergroup.id);
               //clonepage.getParameters().put('CompanyID',comprofile.id);
                clonepage.getParameters().put('WalletID',AcctPlanwallet.id);
               //clonepage.getParameters().put('FiscalYearStr',year);
                //clonepage.getParameters().put('CompanyIDClone',comprofile.id);
              
               Test.setCurrentPage(clonepage); 

            
            AccountPlanClone clone = new AccountPlanClone(sc);
            clone.YearStr = '2016';
            clone.CompanyIDClone = comprofile.id;
            clone.AccountPlanCloneAction();



          AccountPlanClone ctrl2 = new AccountPlanClone(sc);
             pageReference clonepage2 = Page.AccountPlanClone;
               clonepage2.getParameters().put('AccountID',AccountList.get(0).id);
               clonepage.getParameters().put('GroupID',mastergroup.id);
              
               Test.setCurrentPage(clonepage2); 
        
        AccountPlanClone clone2 = new AccountPlanClone(sc);
            clone2.AccountPlanNewAction();

        
        test.stopTest();
    }

}