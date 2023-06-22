@isTest
global class AccountPlanWalletDomainIIITest {
    static{
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
         }
    
    static testmethod void InitiateWallet(){
      
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
          List<Account> AccountList = AccountPlanTestUtilities.createAccounts(1, 'GroupPro', 'Individual', SalesOwner.id, true, true);
       List<Account> acctForCompanyProfile = new List<Account>();
        acctForCompanyProfile.add(AccountList.get(0));
        system.runAs(SalesOwner){
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
                 
        AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
        
        
        AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
        AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
        AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);
                PageReference walletViewPage = Page.AccountPlanWalletDomainIIView;
               walletViewPage.getParameters().put('CompanyID',comprofile.id);
               walletViewPage.getParameters().put('GroupID',AcctPlanwallet.id);
               walletViewPage.getParameters().put('WalletID',AcctPlanwallet.id);
               walletViewPage.getParameters().put('mode','default');
               Test.setCurrentPage(walletViewPage); 
            
            Account_Plan_Status_Code__c acctstatus147 = new Account_Plan_Status_Code__c(Name='9005',Status_Message__c='Error message 9005');
            insert acctstatus147;
                     ApexPages.StandardController sc = new ApexPages.StandardController(AcctPlanwallet);
             AccountPlanWalletDomainIIICtrl AcctPlanwalletDoaminII = new AccountPlanWalletDomainIIICtrl(sc);
            AcctPlanwalletDoaminII.save();
            AcctPlanwalletDoaminII.EditPage();
            AcctPlanwalletDoaminII.View();
            AcctPlanwalletDoaminII.Changetotalpercent();
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

            AcctPlanwalletDoaminII.FICustomerFlagAction();
            AcctPlanwalletDoaminII.workingCapital();
            AcctPlanwalletDoaminII.CreditFacility();
            AcctPlanwalletDoaminII.ExisitngLongTermLoan();
            AcctPlanwalletDoaminII.CapitalExpenditurePlan();
            AcctPlanwalletDoaminII.ContingentLiabilities();
            AcctPlanwalletDoaminII.LGProject();
            AcctPlanwalletDoaminII.LGPurchase();
            
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
            
            AcctPlanwalletDoaminII.workingCapital();
            AcctPlanwalletDoaminII.CreditFacility();
            AcctPlanwalletDoaminII.ExisitngLongTermLoan();
            AcctPlanwalletDoaminII.CapitalExpenditurePlan();
            AcctPlanwalletDoaminII.ContingentLiabilities();
            AcctPlanwalletDoaminII.LGProject();
            AcctPlanwalletDoaminII.LGPurchase();
            AcctPlanwalletDoaminII.TotalDomesticPercentage = 50;
            AcctPlanwalletDoaminII.Changetotalpercent();
            List<SelectOption> months = AcctPlanwalletDoaminII.Months;
            List<SelectOption> Year = AcctPlanwalletDoaminII.Year;
            List<SelectOption> fiscal = AcctPlanwalletDoaminII.getFiscalYear();
            boolean isHasInternationalBank = AcctPlanwalletDoaminII.isHasInternationalBank;
             List<SelectOption>  YesorNo  = AcctPlanwalletDoaminII.YesorNo;
            Test.startTest();
            AcctPlanwalletDoaminII.isHasLGpurchase = true;
            AcctPlanwalletDoaminII.LGPurchase();
            AcctPlanwalletDoaminII.isHasSeasonal = true;
            AcctPlanwalletDoaminII.save();
            AcctPlanwalletDoaminII.APLGProject.ShortTermLGRate__c =101;
            AcctPlanwalletDoaminII.save();
            AcctPlanwalletDoaminII.APLGProject.LongTermLGRate__c =101;
            AcctPlanwalletDoaminII.save();
            AcctPlanwalletDoaminII.acctplanwallet.LGPurchaseRequiredLGPortion__c = 101;
            AcctPlanwalletDoaminII.save();
            
            Test.stopTest();
    }
        
        
        
     
        
    
    }
}