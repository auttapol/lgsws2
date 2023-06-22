@isTest
global class AccountPlanWalletDomainIVTest {
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
   
         }
    
    static testmethod void AccountPlanWalletDomainIVTest(){
      
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
             AccountPlanWalletDomainIVViewCtrl AcctPlanwalletDoaminIV = new AccountPlanWalletDomainIVViewCtrl();
            AcctPlanwalletDoaminIV.updateSumOfWalletFXFeePerYear();
            AcctPlanwalletDoaminIV.loadCurrency();
            AcctPlanwalletDoaminIV.loadforeign();
            AcctPlanwalletDoaminIV.loadquestionnaire();
            AcctPlanwalletDoaminIV.save();
            AcctPlanwalletDoaminIV.cancel();
            AcctPlanwalletDoaminIV.EditPage();
            AcctPlanwalletDoaminIV.ExisitngLongTermLoan();
            AcctPlanwalletDoaminIV.CapitalExpenditurePlan();
            
            AcctPlanForeignTrans__c fortrans = new AcctPlanForeignTrans__c();
            fortrans.AcctPlanWallet__c = acctplanwallet.id;
            fortrans.HedgingRatio__c = 10;
            fortrans.AmtPerYear__c = 10;
            fortrans.FXMarginStg__c = 0.1;
            insert fortrans;
            AcctPlanwalletDoaminIV.loadforeign();
            
            }
        
        
        
     
        
    
    }
    
}