@isTest
global class AccountPlanWalletDomainITest {
    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
        TestUtils.CreateAddress();
        AccountPlanTestUtilities.getAcctPlanMode();
        AccountPlanWalletTestUtilities.createStandardFee();
        AccountPlanWalletTestUtilities.createBanks();
         }
    
    static testmethod void InitiateWallet(){
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
          List<Account> AccountList = AccountPlanTestUtilities.createAccounts(1, 'GroupPro', 'Individual', SalesOwner.id, true, true);
       List<Account> acctForCompanyProfile = new List<Account>();
        acctForCompanyProfile.add(AccountList.get(0));
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
        
         AcctPlanWallet__c wallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, false);
        
        
               PageReference walletInitiatepage = Page.AccountPlanWalletInitiate;
               walletInitiatepage.getParameters().put('CompanyID',comprofile.id);
              // walletInitiatepage.getParameters().put('GroupID','Test');
               Test.setCurrentPage(walletInitiatepage); 

             ApexPages.StandardController sc = new ApexPages.StandardController(comprofile);
             AccountPlanWalletDomainIEx walletIEx = new AccountPlanWalletDomainIEx(sc);
        walletIEX.CalculateWallet();
        walletIEx.insertWallet();
             walletIEx.tempEstimatedSalesAmtPerYear = 10000;
             walletIEx.tempEstimatedSalesAmtPerYearStr = '10000';
             walletIEx.tempOperatingExpAmountStr = '10000';
             
             walletIEx.tempTotalDomesticPercent = 101;
             walletIEx.tempTotalDomesticPercentStr = '101';
        walletIEX.CalculateWallet();
        walletIEx.insertWallet();
             walletIEx.tempTotalDomesticPercent = 30;
             walletIEx.tempTotalDomesticPercentStr = '30';
        walletIEX.CalculateWallet();
        walletIEx.insertWallet();
             walletIEx.tempCOGSPercent = 30;
             walletIEx.tempCOGSPercentStr = '30';
            walletIEx.tempTotalPaymentDomesticPercent = 150;
            walletIEx.tempTotalPaymentDomesticPercentStr = '150';
        walletIEX.CalculateWallet();
        walletIEx.insertWallet();
             walletIEx.tempTotalPaymentDomesticPercent = 50;
            walletIEx.tempTotalPaymentDomesticPercentStr = '50';
              walletIEX.CalculateWallet();

        //
        //
        walletIEX.tempOperatingExpAmountStr ='';
         walletIEX.CalculateWallet();
        walletIEx.tempTotalDomesticPercentStr = '101';
        
         walletIEX.CalculateWallet();
        walletIEx.tempCOGSPercentStr = '101';
        
         walletIEX.CalculateWallet();
        boolean Ccurrency =  walletIEx.isCollectCurrencyNull;
        boolean Pcurrency =  walletIEx.isPaymentCurrencyNull;
             walletIEx.cancel();
             walletIEx.initiateWallet();
             walletIEx.insertWallet();
             walletIEx.tempEstimatedSalesAmtPerYear =10000;
             walletIEX.tempTotalDomesticPercent = 50;
             walletIEX.tempCOGSPercent = 30;
             walletIEX.tempTotalPaymentDomesticPercent = 30;
             walletIEx.insertWallet();
             walletIEx.Save();
             walletIEx.getShareBanks();
             walletIEX.editpage();
        
        
        Test.startTest();
        AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
        AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
        AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
                PageReference walletViewPage = Page.AccountPlanWalletDomainIView;
               walletViewPage.getParameters().put('CompanyID',comprofile.id);
               walletViewPage.getParameters().put('GroupID','Test');
               walletViewPage.getParameters().put('WalletID',AcctPlanwallet.id);
               Test.setCurrentPage(walletViewPage); 
                     ApexPages.StandardController sc2 = new ApexPages.StandardController(AcctPlanwallet);
             AccountPlanWalletDomainIEx AcctwalletIEx = new AccountPlanWalletDomainIEx(sc2);
        
             AcctwalletIEx.tempEstimatedSalesAmtPerYear =10000;
             AcctwalletIEx.tempTotalDomesticPercent = 50;
             AcctwalletIEx.tempCOGSPercent = 30;
             AcctwalletIEx.tempTotalPaymentDomesticPercent = 30;
             AcctwalletIEx.insertWallet();
       
        AcctwalletIEx.save();
        
      
        
        
        Test.stopTest();
        
        
    }
    
    
    static testmethod void ExistingWalletTest(){
        
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
          List<Account> AccountList = AccountPlanTestUtilities.createAccounts(1, 'GroupPro', 'Individual', SalesOwner.id, true, true);
       List<Account> acctForCompanyProfile = new List<Account>();
        acctForCompanyProfile.add(AccountList.get(0));
        system.runAs(SalesOwner){
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
                 
        AcctPlanWallet__c AcctPlanwallet2 = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
        
         List<sObject> ls = 
            Test.loadData(AcctPlan_Questionnaire_Template__c.sObjectType /*API Name*/, 'AcctPlanQuestionnaireTemplate' /*Static Resource Name*/);
   
        AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet2.id);
        AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
        AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet2.id);
                PageReference walletViewPage2 = Page.AccountPlanWalletDomainIView;
               walletViewPage2.getParameters().put('CompanyID',comprofile.id);
               walletViewPage2.getParameters().put('GroupID',AcctPlanwallet2.id);
               walletViewPage2.getParameters().put('WalletID',AcctPlanwallet2.id);
               walletViewPage2.getParameters().put('mode','default');
               Test.setCurrentPage(walletViewPage2); 
                     ApexPages.StandardController sc3 = new ApexPages.StandardController(AcctPlanwallet2);
             AccountPlanWalletDomainIEx AcctPlanwallet3 = new AccountPlanWalletDomainIEx(sc3);
                AcctPlanwallet3.save();
            
             for(String segment : AcctPlanwallet3.DomesticPaymentSegment){
            for(AcctPlanQuestionnaire__c question : AcctPlanwallet3.QuestionnaireMap.get(segment)){
                             question.Answer__c ='Yes';
                             question.OptionPercent__c = 10;
            }
        }
            AcctPlanwallet3.DynamicQuestionnaire();
             for(String segment : AcctPlanwallet3.DomesticPaymentSegment){
            for(AcctPlanQuestionnaire__c question : AcctPlanwallet3.QuestionnaireMap.get(segment)){
                             question.Answer__c ='No';
            }
        }
            AcctPlanwallet3.DynamicQuestionnaire();

            
            
            
        }
    }
}