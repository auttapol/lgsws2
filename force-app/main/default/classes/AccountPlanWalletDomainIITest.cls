@isTest
global class AccountPlanWalletDomainIITest {
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
                     ApexPages.StandardController sc = new ApexPages.StandardController(AcctPlanwallet);
             AccountPlanWalletDomainIICtrl AcctPlanwalletDoaminII = new AccountPlanWalletDomainIICtrl(sc);
            AcctPlanwalletDoaminII.getCurrency();
            AcctPlanwalletDoaminII.getShareBanks();
            AcctPlanwalletDoaminII.EditPage();
            AcctPlanwalletDoaminII.View();
            AcctPlanwalletDoaminII.save();
            
            List<String> APDepositInternationalLabel  = new List<String>{'Transactional','1) Current - USD','Current - Other Currency','2) Saving - USD','Saving - Other Currency','Non Transactional','Time Deposit - USD','Time Deposit - Other Currency','Others - USD','Others - Other Currency','Total'};
             Map<String,AcctPlanDepositInternational__c> APDepositInternationalList = new Map<String,AcctPlanDepositInternational__c> ();
                for(String l : APDepositInternationalLabel){ 
                AcctPlanDepositInternational__c APDepositInternationalitem = new AcctPlanDepositInternational__c();
                APDepositInternationalitem.AccountPlanDepositInternationalDeposit__c = AcctPlanwallet.Id;
                APDepositInternationalitem.Label__c = l;
                APDepositInternationalList.put(l,APDepositInternationalitem);
            }
            insert APDepositInternationalList.values();
            AcctPlanwalletDoaminII.DepositInternational();
            
            List<String> APDepositDomesticLabel = new List<String>{'Transactional','1) Current','2) Saving','Non Transactional','Time Deposit','T-Bill','Mutual Fund','Others','Total'};
           Map<String,AcctPlanDepositDomestic__c> APDepositDomesticList = new Map<String,AcctPlanDepositDomestic__c> ();

            for(String l : APDepositDomesticLabel){ 
                AcctPlanDepositDomestic__c APDepositDomesticitem = new AcctPlanDepositDomestic__c();
                APDepositDomesticitem.AccountPlanDepositDomesticDeposit__c = AcctPlanwallet.Id;
                APDepositDomesticitem.Label__c = l;
                APDepositDomesticList.put(l,APDepositDomesticitem);
            }
            insert APDepositDomesticList.values();
            
            
            
            
            AcctPlanwalletDoaminII.DepositDomestic();
            AcctPlanwalletDoaminII.RefreshDomestic();
            AcctPlanwalletDoaminII.Refresh();
            AcctPlanwalletDoaminII.RefreshInternational();
    }
        
        
        
     
        
    
    }
    
    /*   
    global class MockService implements IAccountPlanRefreshService{  
  
   Boolean RefreshDepositInter(String acctPlanCompanyId,String acctPlanWallet,String acctPlanGruopId){ 
    return true; 
   } 
   Boolean RefreshDepositDomestic(String acctPlanCompanyId,String acctPlanWallet,String acctPlanGruopId){ 
    return true; 
   } 
   Boolean refreshWalletAndAnnualPerformanceRolling12Month(Set<ID> listPortfolioId){ 
     return true; 
   }  
    
   Boolean RefreshCompanyPerformanceProductStrategyForStep6(String companyProfileId){ 
     return true; 
   } 
   Boolean RefreshGroupPerformanceProductStrategyForStep6(String groupProfileId){ 
     return true; 
   } 
   Boolean RefreshPortfolioPerformanceProductStrategyForStep0(String portfolioId){ 
     return true; 
   } 
   List<AcctPlanProdStrategy__c> RefreshProductStrategyAndWalletByDomain(String acctPlanCompanyId,String acctPlanWallet,String acctPlanGruopId){ 
     return null; 
   } 
   void RefreshProductStrategyPort(Set<Id> accountIds , string year){ 
     
   } 
   void RefreshProductStrategy(Set<Id> accountIds , string year,Id groupProfilesId){ 
     
   } 
   void RefreshNameProductStrategyPort(Set<Id> accountIds , string year){ 
     
   } 
   void RefreshGroupPerformance(Set<Id> accountId,string year){ 
     
   } 
   List<AccountPlanRefreshService.CustomerWalletInfo> initialStep0(string accountIds){ 
     return null; 
   } 
 }
   */
}