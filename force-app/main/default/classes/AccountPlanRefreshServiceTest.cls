@isTest
global class AccountPlanRefreshServiceTest {
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

    }

    static testmethod void AccountPlanRefreshServiceTest() {

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
            List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
            AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
            List<group__c> mgroupList = new List<group__c> ();
            mgroupList.add(mastergroup);
            AcctPlanGroupProfile__c groupprofile = AccountPlanTestUtilities.createGroupProfilebyGroup(mgroupList, true).get(0);
            comprofile.AcctPlanGroup__c = groupprofile.id;
            update comprofile;
            AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(SalesOwner.id, '2014', 10000000, true);
            AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
            List<AcctPlanContribution__c> contributionlist = AccountPlanTestUtilities.createRenevueContribution(3, null, comprofile.id);

            AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
            AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
            AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);
            AcctPlanPortfolio__c newPort = AccountPlanUtilities.portfolio;
            List<AcctPlanQuestionnaire__c> QuestionnaireList = AccountPlanUtilities.QuestionnaireList;
            List<Account> newAcctList = AccountPlanUtilities.AccountList;
            List<AcctPlanCompanyProfile__c> comlist = AccountPlanUtilities.companyProfileList;
            List<AcctPlanGroupProfile__c> groupProfileList = AccountPlanUtilities.groupProfileList;
            List<AcctPlanProdStrategy__c> AcctPlanProdStrategyList = AccountPlanUtilities.AcctPlanProdStrategyList;
            String GroupProfileID = AccountPlanUtilities.GroupProfileID;
            String CompanyProfileID = AccountPlanUtilities.CompanyProfileID;
            Boolean isSystemAdmin = AccountPlanUtilities.isSystemAdmin;
            boolean ISHASPERMISSION = AccountPlanUtilities.ISHASPERMISSION;
            boolean IsAccountTeamReadWrite = AccountPlanUtilities.IsAccountTeamReadWrite;
            AccountPlanUtilities.QueryPortfolioByID(portfolio.id);
            AccountPlanUtilities.QueryGroupProfileByID(mastergroup.id);
            AccountPlanUtilities.QueryCompanyProfileByID(comprofile.id);
            AccountPlanUtilities.QueryCompanyProfileByGroupID(mastergroup.id);
            AccountPlanUtilities.QueryAccountByOwnerID(SalesOwner.id);
            AccountPlanUtilities.QueryAccountByAcctID(AccountList.get(0).id);
            AccountPlanUtilities.QueryAccountByGroupID(mastergroup.id);
            AccountPlanUtilities.QueryTargetNI12monthsbyOwnerID(SalesOwner.id);
            AccountPlanUtilities.QueryTargetNIbyOwnerIDandYear(SalesOwner.id, 2015);
            AccountPlanUtilities.QueryContributionByGroupProfileID(groupprofile.id);
            AccountPlanUtilities.QueryProductStrategyByCompanyProfileID(comprofile.id);
            AccountPlanUtilities.QueryProductStrategyByGroupProfileID(groupprofile.id);
            AccountPlanUtilities.QueryAcctPlanCompanyProfileByID(comprofile.id);
            AccountPlanUtilities.QueryQuestionnaireByWalletID(AcctPlanwallet.id);
            AccountPlanUtilities.QueryAccountByCompanyProfile(comprofile.id);
            AccountPlanUtilities.QueryCompanyPortbyPortID(portfolio.id);

            List<Account_Plan_Fiscal_Year__c> getFiscalYear = AccountPlanTestUtilities.getFiscalYear;
            List<AcctPlanGroupPort__c> createGroupPortbyGroupMaster = AccountPlanTestUtilities.createGroupPortbyGroupMaster(mgroupList, portfolio, true);
            List<AcctPlanCompanyPort__c> createCompanyPortByAccount = AccountPlanTestUtilities.createCompanyPortByAccount(AccountList, portfolio, true);
            List<AcctPlanSupplierOrBuyer__c> CreateSupplierOrBuyer = AccountPlanTestUtilities.CreateSupplierOrBuyer(3, comprofile.id);
            List<Account_Plan_Company_Top_5__c> CreateTop5 = AccountPlanTestUtilities.CreateTop5(3, comprofile.id);
            AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
            AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
            AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);
            AcctPlanPortfolio__c newPort2 = AccountPlanUtilities.portfolio;
            List<AcctPlanWallet__c> walletList2 = AccountPlanWalletUtilities.walletList;
            List<AcctPlan_Questionnaire_Template__c> questionTemplate1 = AccountPlanWalletUtilities.questionTemplate;
            List<AcctPlan_Questionnaire_Template__c> questionTemplate2 = AccountPlanWalletUtilities.queryQuestionnaireTemplate('Domain I');
            List<AcctPlanStandardFee__c> stfList = AccountPlanWalletTestUtilities.stdFeeList;
            AccountPlanWalletTestUtilities.createQuestionniare(AcctPlanwallet.id);

            try { AccountPlanRefreshService.RefreshDepositInter(null, null, null); } catch(Exception e) { }
            try { AccountPlanRefreshService.RefreshDepositDomestic(null, null, null); } catch(Exception e) { }
            try { AccountPlanRefreshService.RefreshWalletAndAnnualPerformanceRolling12Month(null); } catch(Exception e) { }
            try { AccountPlanRefreshService.RefreshCompanyPerformanceProductStrategyForStep6(null, null, null); } catch(Exception e) { }
            try { AccountPlanRefreshService.RefreshGroupPerformanceProductStrategyForStep6(null); } catch(Exception e) { }
            try { AccountPlanRefreshService.RefreshPortfolioPerformanceProductStrategyForStep0(null); } catch(Exception e) { }
            try { AccountPlanRefreshService.RefreshProductStrategyAndWalletByDomain(null, null, null); } catch(Exception e) { }
            AccountPlanRefreshServiceMock servicemock = new AccountPlanRefreshServiceMock();
            AccountPlanRefreshService.setMockservice(servicemock);
            AccountPlanRefreshService.RefreshProductStrategyPort(null, null);
            AccountPlanRefreshService.RefreshProductStrategy(null, null, null);
            AccountPlanRefreshService.RefreshDepositInter(null, null, null);
            AccountPlanRefreshService.RefreshDepositDomestic(null, null, null);
            AccountPlanRefreshService.RefreshWalletAndAnnualPerformanceRolling12Month(null);
            AccountPlanRefreshService.RefreshCompanyPerformanceProductStrategyForStep6(null, null, null);
            AccountPlanRefreshService.RefreshGroupPerformanceProductStrategyForStep6(null);
            AccountPlanRefreshService.RefreshPortfolioPerformanceProductStrategyForStep0(null);
            AccountPlanRefreshService.RefreshProductStrategyAndWalletByDomain(null, null, null);

            AccountPlanRefreshService.RefreshNameProductStrategyPort(null, null);
            AccountPlanRefreshService.RefreshGroupPerformance(null, null);
            AccountPlanRefreshService.initialStep0(null);
            AccountPlanRefreshService.CustomerWalletInfo custinfo = new AccountPlanRefreshService.CustomerWalletInfo();

            // AccountPlanRefreshServiceImpl
            // 
            AccountPlanRefreshServiceImpl.RefreshDepositInter(comprofile.id + '', acctplanWallet.id + '', groupprofile.id + '');

        }






    }


    public class AccountPlanRefreshServiceMock implements IAccountPlanRefreshService {
        public Boolean RefreshDepositInter(String acctPlanCompanyId, String acctPlanWallet, String acctPlanGruopId) {
            return true;
        }
        public Boolean RefreshDepositDomestic(String acctPlanCompanyId, String acctPlanWallet, String acctPlanGruopId) {
            return true;
        }
        public Boolean refreshWalletAndAnnualPerformanceRolling12Month(Set<ID> listPortfolioId) {
            return true;
        }
        //Boolean RefreshCompanyProfileProductStrategy(Id companyProfileIds,Id acctPlanWallet);
        public Boolean RefreshCompanyPerformanceProductStrategyForStep6(String companyProfileId) {
            return true;
        }
        public Boolean RefreshGroupPerformanceProductStrategyForStep6(String groupProfileId) {
            return true;
        }
        public Boolean RefreshPortfolioPerformanceProductStrategyForStep0(String portfolioId) {
            return true;
        }
        public List<AcctPlanProdStrategy__c> RefreshProductStrategyAndWalletByDomain(String acctPlanCompanyId, String acctPlanWallet, String acctPlanGruopId) {
            return new List<AcctPlanProdStrategy__c> ();
        }
        public void RefreshProductStrategyPort(Set<Id> accountIds, string year) {

        }
        public void RefreshProductStrategy(Set<Id> accountIds, string year, Id groupProfilesId) {

        }
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




}