@isTest
public without sharing class GroupRefreshEntranceBatchTest {
    static {


        List<AppConfig__c> mc = new List<AppConfig__c> ();
        mc.Add(new AppConfig__c(Name = 'CertName', Value__c = 'TMB_RSA'));
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        mc.Add(new AppConfig__c(Name = 'runCustomerNoteTrigger', Value__c = 'false'));
        insert mc;
        AccountPlanTestUtilities.getAcctPlanMode();
        AccountPlanTestUtilities.AccountPlanStatusCode();
        
        TestUtils.createAppConfigRetailtoComm();

    }

    @isTest
    private static void Test_BatchRefreshGroupWallet() {
         /*Account acc = new Account();
        acc.Name = 'xxx';
        acc.Phone ='050111222';
        acc.Mobile_Number_PE__c  = '0801112233';
        insert acc;

        Account acc2 = new Account();
        acc2.Name = 'xxx2';
        acc2.Phone ='0501112222';
        acc2.Mobile_Number_PE__c  = '08011122332';
        insert acc2;*/
        
        User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
        List<Account> AccountList = AccountPlanTestUtilities.createAccounts(5, 'GroupPro', 'Individual', SalesOwner.id, true, true);
        List<Account> acctForCompanyProfile = new List<Account>();
         acctForCompanyProfile.add(AccountList.get(0));
         acctForCompanyProfile.add(AccountList.get(2));
         acctForCompanyProfile.add(AccountList.get(3));
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
        List <group__c> groupList = AccountPlanTestUtilities.createGroupMaster(2,'PortMngtest', false, true);
        Group__c mastergroup = groupList.get(0);
         for(account acct  : AccountList){
            acct.Group__c =mastergroup.id;
        }
        update AccountList;
        List<group__c> mgroupList = new List <group__c>();
        mgroupList.add(mastergroup);
        AcctPlanGroupProfile__c groupprofile = AccountPlanTestUtilities.createGroupProfilebyGroup(mgroupList,true).get(0);
         comprofile.AcctPlanGroup__c = groupprofile.id;
         comprofile.Parent_Company_Info__c = AccountList.get(1).id;
         comprofile.year__c = '2015';
         update comprofile;

         AccountTeamMember teammember = new AccountTeamMember ();
         teammember.AccountID = comprofile.Account__c;
         teammember.TeamMemberRole = 'Sponser';
         teammember.UserId = SalesOwner.id;
         insert teammember;
         AccountTeamMember teammember2 = new AccountTeamMember ();
         teammember2.AccountID = comprofile.Account__c;
         teammember2.TeamMemberRole = 'Sponser';
         teammember2.UserId = Userinfo.getUserId();
         insert teammember2;

         Account Newacct = AccountList.get(0);
         AcctPlanWallet__c AcctPlanwallet = new AcctPlanWallet__c ();
         AcctPlanwallet.AcctPlanCompanyProfile__c = comprofile.id;
         insert AcctPlanwallet;


        II_TestUtility utility = new II_TestUtility();
        IAccountPlanRefreshService mock = new AccountPlanRefreshServiceBatchMock();
        AccountPlanRefreshService.setMockservice(mock);

system.runAs(SalesOwner) {
        MockProductStrategy(comprofile.id,AcctPlanwallet.id);
        String year = '2015';
        Set<Id> AccountWithAccountPlan = new Set<Id>();
                Set<Id> AccountWithoutAccountPlan = new Set<Id>();
                AggregateResult[] ProdStrategyList = [SELECT AccountId__c 
                                                              FROM AcctPlanProdStrategy__c 
                                                              WHERE AcctPlanGroupProfileID__r.Group__c = : comprofile.AcctPlanGroup__r.Group__c
                                                              AND AcctPlanCompanyProfileID__r.Year__c = :year
                                                              GROUP BY AccountId__c];
            
                system.debug('ProdStrategyList='+ProdStrategyList.size());
                /*for(AcctPlanProdStrategy__c item : ProdStrategyList){
                    AccountWithAccountPlan.add(item.AccountId__c);
                }*/
                for (AggregateResult ar : ProdStrategyList){
                    Id accountId = (ID) ar.get('AccountId__c');
                    AccountWithAccountPlan.add(accountId);
                }
                        
                List<Account> accountListInitial = [SELECT Id, Name,Group__c,Group__r.Name 
                                                    FROM Account 
                                                    WHERE Group__c = : comprofile.AcctPlanGroup__r.Group__c
                                                    AND Id NOT IN : AccountWithAccountPlan ];
                system.debug('accountListInitial='+accountListInitial.size());
                for(Account item : accountListInitial){
                    AccountWithoutAccountPlan.add(item.id);
                }


        /*Set<Id> AccountWithAccountPlan = new Set<Id> { utility.getFakeId(Account.SObjectType), acc.Id };
        Set<Id> AccountWithoutAccountPlan = new Set<Id> { utility.getFakeId(Account.SObjectType), acc2.id };
        Id GroupId = utility.getFakeId(Group__c.SObjectType);
        string Year = Datetime.now().year() + '';
        Id GroupProfileId = utility.getFakeId(AcctPlanGroupProfile__c.SObjectType);*/

        GroupWalletRefreshEntranceBatch1 batch =
        new GroupWalletRefreshEntranceBatch1(AccountWithAccountPlan
                                                 , AccountWithoutAccountPlan
                                                 , comprofile.AcctPlanGroup__r.Group__c
                                                 , Year
                                                 , comprofile.AcctPlanGroup__c,false);
        Database.executeBatch(batch, 100);



        GroupWalletRefreshEntranceBatch2 batch2 =
        new GroupWalletRefreshEntranceBatch2(AccountWithAccountPlan
                                                 , AccountWithoutAccountPlan
                                                 , comprofile.AcctPlanGroup__r.Group__c
                                                 , Year
                                                 , comprofile.AcctPlanGroup__c,false);
        

        GroupWalletSummary1 batch3 =
        new GroupWalletSummary1(AccountWithAccountPlan
                                                 , AccountWithoutAccountPlan
                                                 , comprofile.AcctPlanGroup__r.Group__c
                                                 , Year
                                                 , comprofile.AcctPlanGroup__c,false);
        
        GroupWalletSummary2 batch4 =
        new GroupWalletSummary2(AccountWithAccountPlan
                                                 , AccountWithoutAccountPlan
                                                 , comprofile.AcctPlanGroup__r.Group__c
                                                 , Year
                                                 , comprofile.AcctPlanGroup__c,false);
        
}

    }

    @isTest
    private static void Test_BatchRefreshGroupPerformance() {
        /*Account acc = new Account();
        acc.Name = 'xxx';
        acc.Phone ='050111222';
        acc.Mobile_Number_PE__c  = '0801112233';
        insert acc;

        Account acc2 = new Account();
        acc2.Name = 'xxx2';
        acc2.Phone ='0501112222';
        acc2.Mobile_Number_PE__c  = '08011122332';
        insert acc2;*/
 
        User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
        List<Account> AccountList = AccountPlanTestUtilities.createAccounts(5, 'GroupPro', 'Individual', SalesOwner.id, true, true);
        List<Account> acctForCompanyProfile = new List<Account>();
         acctForCompanyProfile.add(AccountList.get(0));
         acctForCompanyProfile.add(AccountList.get(2));
         acctForCompanyProfile.add(AccountList.get(3));
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
        List <group__c> groupList = AccountPlanTestUtilities.createGroupMaster(2,'PortMngtest', false, true);
        Group__c mastergroup = groupList.get(0);
         for(account acct  : AccountList){
            acct.Group__c =mastergroup.id;
        }
        update AccountList;
        List<group__c> mgroupList = new List <group__c>();
        mgroupList.add(mastergroup);
        AcctPlanGroupProfile__c groupprofile = AccountPlanTestUtilities.createGroupProfilebyGroup(mgroupList,true).get(0);
         comprofile.AcctPlanGroup__c = groupprofile.id;
         comprofile.Parent_Company_Info__c = AccountList.get(1).id;
         comprofile.year__c = '2015';
         update comprofile;

         AccountTeamMember teammember = new AccountTeamMember ();
         teammember.AccountID = comprofile.Account__c;
         teammember.TeamMemberRole = 'Sponser';
         teammember.UserId = SalesOwner.id;
         insert teammember;
         AccountTeamMember teammember2 = new AccountTeamMember ();
         teammember2.AccountID = comprofile.Account__c;
         teammember2.TeamMemberRole = 'Sponser';
         teammember2.UserId = Userinfo.getUserId();
         insert teammember2;

         Account Newacct = AccountList.get(0);
         AcctPlanWallet__c AcctPlanwallet = new AcctPlanWallet__c ();
         AcctPlanwallet.AcctPlanCompanyProfile__c = comprofile.id;
         insert AcctPlanwallet;


        II_TestUtility utility = new II_TestUtility();
        IAccountPlanRefreshService mock = new AccountPlanRefreshServiceBatchMock();
        AccountPlanRefreshService.setMockservice(mock);

system.runAs(SalesOwner) {
        MockProductStrategy(comprofile.id,AcctPlanwallet.id);
        String year = '2015';
        Set<Id> AccountWithAccountPlan = new Set<Id>();
                Set<Id> AccountWithoutAccountPlan = new Set<Id>();
                AggregateResult[] ProdStrategyList = [SELECT AccountId__c 
                                                              FROM AcctPlanProdStrategy__c 
                                                              WHERE AcctPlanGroupProfileID__r.Group__c = : comprofile.AcctPlanGroup__r.Group__c
                                                              AND AcctPlanCompanyProfileID__r.Year__c = :year
                                                              GROUP BY AccountId__c];
            
                system.debug('ProdStrategyList='+ProdStrategyList.size());
                /*for(AcctPlanProdStrategy__c item : ProdStrategyList){
                    AccountWithAccountPlan.add(item.AccountId__c);
                }*/
                for (AggregateResult ar : ProdStrategyList){
                    Id accountId = (ID) ar.get('AccountId__c');
                    AccountWithAccountPlan.add(accountId);
                }
                        
                List<Account> accountListInitial = [SELECT Id, Name,Group__c,Group__r.Name 
                                                    FROM Account 
                                                    WHERE Group__c = : comprofile.AcctPlanGroup__r.Group__c
                                                    AND Id NOT IN : AccountWithAccountPlan ];
                system.debug('accountListInitial='+accountListInitial.size());
                for(Account item : accountListInitial){
                    AccountWithoutAccountPlan.add(item.id);
                }


        /*Set<Id> AccountWithAccountPlan = new Set<Id> { utility.getFakeId(Account.SObjectType), acc.Id };
        Set<Id> AccountWithoutAccountPlan = new Set<Id> { utility.getFakeId(Account.SObjectType), acc2.id };
        Id GroupId = utility.getFakeId(Group__c.SObjectType);
        string Year = Datetime.now().year() + '';
        Id GroupProfileId = utility.getFakeId(AcctPlanGroupProfile__c.SObjectType);*/

/*
        GroupWalletRefreshEntranceBatch1 batch =
        new GroupWalletRefreshEntranceBatch1(AccountWithAccountPlan
                                                 , AccountWithoutAccountPlan
                                                 , comprofile.AcctPlanGroup__r.Group__c
                                                 , Year
                                                 , comprofile.AcctPlanGroup__c,false);
        Database.executeBatch(batch, 100);*/



        GroupWalletRefreshEntranceBatch1 batch =
        new GroupWalletRefreshEntranceBatch1(AccountWithAccountPlan
                                                 , AccountWithoutAccountPlan
                                                 , comprofile.AcctPlanGroup__r.Group__c
                                                 , Year
                                                 , comprofile.AcctPlanGroup__c,false);
        Database.executeBatch(batch, 100);



        GroupWalletRefreshEntranceBatch2 batch2 =
        new GroupWalletRefreshEntranceBatch2(AccountWithAccountPlan
                                                 , AccountWithoutAccountPlan
                                                 , comprofile.AcctPlanGroup__r.Group__c
                                                 , Year
                                                 , comprofile.AcctPlanGroup__c,false);
        
        GroupWalletSummary1 batch3 =
        new GroupWalletSummary1(AccountWithAccountPlan
                                                 , AccountWithoutAccountPlan
                                                 , comprofile.AcctPlanGroup__r.Group__c
                                                 , Year
                                                 , comprofile.AcctPlanGroup__c,false);
        

        GroupWalletSummary2 batch4 =
        new GroupWalletSummary2(AccountWithAccountPlan
                                                 , AccountWithoutAccountPlan
                                                 , comprofile.AcctPlanGroup__r.Group__c
                                                 , Year
                                                 , comprofile.AcctPlanGroup__c,false);
        

}

    }


    public class AccountPlanRefreshServiceBatchMock implements IAccountPlanRefreshService {
        public Boolean RefreshDepositInter(String acctPlanCompanyId, String acctPlanWallet, String acctPlanGruopId) {
            return true;
        }
        public Boolean RefreshDepositDomestic(String acctPlanCompanyId, String acctPlanWallet, String acctPlanGruopId) {
            return true;
        }
        public Boolean refreshWalletAndAnnualPerformanceRolling12Month(Set<ID> listPortfolioId) {
            return true;
        }

        public Boolean RefreshCompanyPerformanceProductStrategyForStep6(String companyProfileId) {
            return true;
        }
        public Boolean RefreshGroupPerformanceProductStrategyForStep6(String groupProfileId) { return true; }
        public Boolean RefreshPortfolioPerformanceProductStrategyForStep0(String portfolioId) { return true; }
        public List<AcctPlanProdStrategy__c> RefreshProductStrategyAndWalletByDomain(String acctPlanCompanyId, String acctPlanWallet, String acctPlanGruopId) {
            return new List<AcctPlanProdStrategy__c> ();

        }
        public void RefreshProductStrategyPort(Set<Id> accountIds, string year) { }
        public void RefreshProductStrategy(Set<Id> accountIds, string year, Id groupProfilesId) { }
        public void RefreshNameProductStrategyPort(Set<Id> accountIds, string year) { }
        public void RefreshGroupPerformance(Set<Id> accountId, string year) { }

        public List<AccountPlanRefreshService.CustomerWalletInfo> initialStep0(string accountIds) {
            return new List<AccountPlanRefreshService.CustomerWalletInfo> ();
        }
        /*Start R5.2*/
        public void RefreshProductStrategyGroupWalletGroupPerformance(Set<Id> acctId,Set<Id> acctPlanCompanyId, Set<Id>  acctPlanWallet, String acctPlanGruopId){}
        public void RefreshProductStrategyPort(Set<Id> accountIds , string year,Id groupId){}
        public void RefreshProductStrategy2(Set<Id> accountIds, string year,Id groupId){}
        /*End R5.2*/


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