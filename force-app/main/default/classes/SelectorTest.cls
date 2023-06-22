/**
 * @author ktc@tmbbank.com.acctplan
 * @description : Code Coverate Only
 *               
*/
@isTest
public class SelectorTest {
    public static II_TestUtility utility;
    static {
        utility = new II_TestUtility();

        List<AppConfig__c> mc = new List<AppConfig__c> ();
        mc.Add(new AppConfig__c(Name = 'CertName', Value__c = 'TMB_RSA'));
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        insert mc;
        AccountPlanTestUtilities.getAcctPlanMode();
        
        TestUtils.createAppConfigRetailtoComm();

    }
    @isTest static void AccountPlanAnnualPerformanceTest() {
        Set<Id> Ids = new Set<Id> { utility.getFakeId(Account.SObjectType) };
        DateTime dt = DateTime.now();
        List<AcctAnnualPerformance__c> ret = AccountPlanAnnualPerformanceSelector.LastCustomerUnderstandardingByAccountIds(Ids);
        ret = AccountPlanAnnualPerformanceSelector.LastCustomerUnderstandardingByAccountIds(Ids);
        List<AcctAnnualPerformance__c> ret3 = AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceRolling12MonthByAccountIds(Ids, dt);
        Map<Id /*Account Id*/, AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo> ret4 = AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDateInGroupMap(Ids, dt);
        List<AcctAnnualPerformance__c> ret5 = AccountPlanAnnualPerformanceSelector.LastCustomerUnderstandarding(utility.getFakeId(Account.SObjectType));



        List<AppConfig__c> mc = new List<AppConfig__c> ();
        mc.Add(new AppConfig__c(Name = 'CertName', Value__c = 'TMB_RSA'));
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        insert mc;
        Account acc = new Account(Name = 'TestAcct',Phone ='050111222',Mobile_Number_PE__c  = '0801112233');
        insert acc;
        // Create On Annul Perfomance
        AcctAnnualPerformance__c acctplanAnnual = new AcctAnnualPerformance__c();
        acctplanAnnual.Account__c = acc.Id;
        acctplanAnnual.AS_FEE__c = 10000;
        acctplanAnnual.AVG_CASA__c = 10000;
        acctplanAnnual.AVG_LOAN_OUT__c = 10000;
        acctplanAnnual.BA_FEE__c = 10000;
        acctplanAnnual.CREDIT_FEE__c = 10000;
        acctplanAnnual.DERIVATIVES_FEE__c = 10000;
        acctplanAnnual.DIRECT_CM_FEE__c = 10000;
        acctplanAnnual.EDC_FEE__c = 10000;
        acctplanAnnual.END_CASA__c = 10000;
        acctplanAnnual.ENG_LOAN_OUT__c = 10000;
        acctplanAnnual.Fee__c = 10000;
        acctplanAnnual.FLEET_FEE__c = 10000;
        acctplanAnnual.FRONT_END_FEE__c = 10000;
        acctplanAnnual.FX_FEE__c = 10000;
        acctplanAnnual.FX_VOLUME__c = 10000;
        acctplanAnnual.IB_FEE__c = 10000;
        acctplanAnnual.LG_FEE__c = 10000;
        acctplanAnnual.NIIc__c = 10000;
        acctplanAnnual.NIId__c = 10000;
        acctplanAnnual.OTHER_CM_FEE__c = 10000;
        acctplanAnnual.OTHER_FEE__c = 10000;
        acctplanAnnual.TF_FEE__c = 10000;
        acctplanAnnual.TF_VOLUME__c = 10000;
        acctplanAnnual.TMB_CUST_ID__c = 'TMBACCOUNTID';
        acctplanAnnual.Transaction_Date__c = Date.today();
        Insert acctplanAnnual;

        ret4 = AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDateInGroupMap(new Set<Id>{acc.Id},dt.addMonths(2));




        try {  ret4 = AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDateInGroupMap(null, null);} catch(Exception e) { }
        try {  ret4 = AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDateInGroupMap(Ids, null);} catch(Exception e) { }




    }



    @isTest static void AccountPlanActionPlanSelectorTest() {
        Set<Id> Ids = new Set<Id> { utility.getFakeId(AcctPlanWalletByDomain__c.SObjectType) };
        List<AcctPlanActionPlan__c> ret = AccountPlanActionPlanSelector.getActionPlanByWalletByDomains(Ids);
        try { ret = AccountPlanActionPlanSelector.getActionPlanByWalletByDomains(new Set<Id> ()); } catch(Exception e) { }
    }
    @isTest static void AccountPlanCompanyPortTest() {
        Set<Id> grpIds = new Set<Id> { utility.getFakeId(AcctPlanGroupProfile__c.SObjectType) };
        Set<Id> portIds = new Set<Id> { utility.getFakeId(AcctPlanPortfolio__c.SObjectType) };
        Set<Id> companyIds = new Set<Id> { utility.getFakeId(AcctPlanCompanyProfile__c.SObjectType) };

        List<AcctPlanCompanyProfile__c> ret = AccountPlanCompanyPortSelector.getAllCompanyProfileUnderGroupByGroupProfolioId(grpIds);
        List<AcctPlanCompanyPort__c> ret1 = AccountPlanCompanyPortSelector.getAllAccountInPortfolioIds(portIds);
        AcctPlanCompanyPort__c ret2 = AccountPlanCompanyPortSelector.getCompanyPortByPortfolioIdAndAccountId(utility.getFakeId(AcctPlanPortfolio__c.SObjectType), utility.getFakeId(Account.SObjectType));

        List<AcctPlanCompanyPort__c> ret3 = AccountPlanCompanyPortSelector.getAllCompanyPortUnderGroupByGroupProfolioId(utility.getFakeId(AcctPlanGroupProfile__c.SObjectType));
        List<AcctPlanCompanyPort__c> ret4 = AccountPlanCompanyPortSelector.getTargetNIByRMById(companyIds);





        try { ret = AccountPlanCompanyPortSelector.getAllCompanyProfileUnderGroupByGroupProfolioId(null); } catch(Exception e) { }
        try { ret1 = AccountPlanCompanyPortSelector.getAllAccountInPortfolioIds(null); } catch(Exception e) { }
        try { ret2 = AccountPlanCompanyPortSelector.getCompanyPortByPortfolioIdAndAccountId(null, null); } catch(Exception e) { }
        try { ret3 = AccountPlanCompanyPortSelector.getAllCompanyPortUnderGroupByGroupProfolioId(null); } catch(Exception e) { }
        try { ret4 = AccountPlanCompanyPortSelector.getTargetNIByRMById(null); } catch(Exception e) { }

    }
    @isTest static void AccountPlanCompanyProfileTest() {
        Set<Id> accountIds = new Set<Id> { utility.getFakeId(Account.SObjectType) };
        Set<Id> companyIds = new Set<Id> { utility.getFakeId(AcctPlanCompanyProfile__c.SObjectType) };
        Id groupid = utility.getFakeId(AcctPlanGroupProfile__c.SObjectType);
        Id portfolio = utility.getFakeId(AcctPlanPortfolio__c.SObjectType);

        List<AcctPlanCompanyProfile__c> ret = AccountPlanCompanyProfileSelector.getCompanyProfileByAccountIdsAndYear(accountIds, '2015');
        ret = AccountPlanCompanyProfileSelector.getTargetNIByRMById(companyIds);
        List<Decimal> ret2 = AccountPlanCompanyProfileSelector.getTargetNIByGroupId(new Set<Id> { groupid });
        ret = AccountPlanCompanyProfileSelector.getCompanyProfileIdByPortfolioIds(new Set<Id> { portfolio });
        ret = AccountPlanCompanyProfileSelector.getCompanyProfileByGroupProfileIds(new Set<Id> { portfolio });
        ret = AccountPlanCompanyProfileSelector.getCompanyProfileIds(companyIds);
        ret = AccountPlanCompanyProfileSelector.getAllCompanyProfileUnderGroupByGroupProfolioId(new Set<Id> { portfolio }, '2015');

        try { ret = AccountPlanCompanyProfileSelector.getCompanyProfileByAccountIdsAndYear(null, ''); } catch(Exception e) { }
        try { ret = AccountPlanCompanyProfileSelector.getTargetNIByRMById(null); } catch(Exception e) { }
        try { ret2 = AccountPlanCompanyProfileSelector.getTargetNIByGroupId(null); } catch(Exception e) { }
        try { ret = AccountPlanCompanyProfileSelector.getCompanyProfileIdByPortfolioIds(null); } catch(Exception e) { }
        try { ret = AccountPlanCompanyProfileSelector.getCompanyProfileByGroupProfileIds(null); } catch(Exception e) { }
        try { ret = AccountPlanCompanyProfileSelector.getCompanyProfileIds(null); } catch(Exception e) { }
        try { ret = AccountPlanCompanyProfileSelector.getAllCompanyProfileUnderGroupByGroupProfolioId(null, ''); } catch(Exception e) { }







    }
    @isTest static void AccountPlanCustomerUnderstandingSelectorTest() {
            User m_AdminUser = AccountPlanTestUtilities.createUsers(1, 'RM', 'selectortest', 'selectortest@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
            List<Account> newAccountList = AccountPlanTestUtilities.createAccounts(1, 'InitiateTest', 'Individual', m_AdminUser.id, true, true);

           List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(newAccountList, true);
        AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
        
        
            AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofileList.get(0).id, true);

            AcctPlanCusUnderstanding__c custoutstanding1 = new AcctPlanCusUnderstanding__c();
            custoutstanding1.AcctPlanWallet__c =AcctPlanwallet.id;
            custoutstanding1.Ending_CASA__c =100;
            custoutstanding1.Average_CASA__c =100;
            custoutstanding1.Average_loan_outstanding__c =100;
            custoutstanding1.Ending_loan_outstanding__c =100;
            custoutstanding1.FX_volume__c =100;
            custoutstanding1.TF_Volume__c =100;
            custoutstanding1.Account__c = newAccountList.get(0).id;

            insert custoutstanding1;
        Set<ID> walletsetid = new Set<ID>();
        walletsetid.add(AcctPlanwallet.id);
        Set<ID> acctset = new Set<ID>();
        acctset.add(newAccountList.get(0).id);
        List<AcctPlanCusUnderstanding__c> ret = AccountPlanCustomerUnderstandingSelector.getUnderstandingByWalletIds(walletsetid);
        //AggregateResult[] ret2 = AccountPlanCustomerUnderstandingSelector.getSummaryByAccountIdsAndYear(acctset, '2015');
        try { ret = AccountPlanCustomerUnderstandingSelector.getUnderstandingByWalletIds(null); } catch(Exception e) { }
        //try { ret2 = AccountPlanCustomerUnderstandingSelector.getSummaryByAccountIdsAndYear(null, ''); } catch(Exception e) { }


    }
    @isTest static void AccountPlanDepositDomesticTest() {
        Set<Id> Ids = new Set<Id> { utility.getFakeId(AcctPlanWallet__c.SObjectType) };
        List<AcctPlanDepositDomestic__c> ret = AccountPlanDepositDomesticSelector.GetAccountPlanDepositDomesticByWalletIds(Ids);
        try { ret = AccountPlanDepositDomesticSelector.GetAccountPlanDepositDomesticByWalletIds(null); } catch(Exception e) { }

    }
    @isTest static void AccountPlanDepositInternationalTest() {
        List<sObject> ls = Test.loadData(Account_Plan_Deposit_Section__c.sObjectType /*API Name*/
                                         , 'AccountPlanConfigTestData' /*Static Resource Name*/);
        System.debug(':::: SOME ID ' + ls[0].Id);

        //Ack
        Map<string, string> lst1 = AccountPlanConfig.getMapDepositDemestic;
        //Ack
        Map<string, string> lst2 = AccountPlanConfig.getMapDepositInterUsd;
        //Ack
        Map<string, string> lst3 = AccountPlanConfig.getMapDepositInterOther;

    }
    @isTest static void AccountPlanGroupProfileTest() {

        Group__c gp = new Group__c();
        gp.Name = 'ttt';
        insert gp;
        AcctPlanGroupProfile__c item = new AcctPlanGroupProfile__c();
        item.Name = 'test';
        item.Group__c = gp.Id;
        insert item;

        string grpProfileId = (String) utility.getFakeId(AcctPlanGroupProfile__c.SObjectType);
        AcctPlanGroupProfile__c ret = AccountPlanGroupProfileSelector.getGroupProfileById(grpProfileId);
        try { ret = AccountPlanGroupProfileSelector.getGroupProfileById(null); } catch(Exception e) { }

        ret = AccountPlanGroupProfileSelector.getGroupProfileById(item.Id);
    }
    @isTest static void AccountPlanNIProjectTest() {
        Set<Id> Ids = new Set<Id> { utility.getFakeId(AcctPlanActionPlan__c.SObjectType) };
        List<AcctPlanNIProject__c> ret = AccountPlanNIProjectSelector.getNIProjectByActionPlans(Ids);
        Set<Id> acctIds = new Set<Id> { utility.getFakeId(Account.SObjectType) };
        ret = AccountPlanNIProjectSelector.getNIProjectByActionPlansByYearAndAccountIds('2015', acctIds);
        try { ret = AccountPlanNIProjectSelector.getNIProjectByActionPlans(null); } catch(Exception e) { }
        try { ret = AccountPlanNIProjectSelector.getNIProjectByActionPlansByYearAndAccountIds('', null); } catch(Exception e) { }


    }
    @isTest static void AccountPlanProductStrategyPortTest() {
        Set<Id> Ids = new Set<Id> { utility.getFakeId(Account.SObjectType) };
        List<AcctPlanProdStrategyPort__c> ret = AccountPlanProductStrategyPortSelector.selectProductStrategyPortByAccountIdsAndYear(Ids, '2015');
        try { ret = AccountPlanProductStrategyPortSelector.selectProductStrategyPortByAccountIdsAndYear(null, ''); } catch(Exception e) { }
        try { ret = AccountPlanProductStrategyPortSelector.selectProductStrategyPortByAccountIdsAndYear(Ids, ''); } catch(Exception e) { }
    }
    @isTest static void AccountPlanProductStrategyTest() {

        Set<Id> Ids = new Set<Id> { utility.getFakeId(Account.SObjectType) };
        Set<Id> companyProfileIds = new Set<Id> { utility.getFakeId(AcctPlanCompanyProfile__c.SObjectType) };

        List<AcctPlanProdStrategy__c> ret = AccountPlanProductStrategySelector.selectProductStrategyByAccountIds(Ids, '2015');
        ret = AccountPlanProductStrategySelector.selectProductStrategyByIds(companyProfileIds);
        Set<Id> groupProfileID = new Set<Id> { utility.getFakeId(AcctPlanGroupProfile__c.SObjectType) };
        ret = AccountPlanProductStrategySelector.selectProductStrategyByGroupIds(groupProfileID);
        AggregateResult[] ret2 = AccountPlanProductStrategySelector.selectProductStrategyPortfolioPerformanceByCompanyIds(companyProfileIds);



        try { ret = AccountPlanProductStrategySelector.selectProductStrategyByAccountIds(null, ''); } catch(Exception e) { }
        try { ret = AccountPlanProductStrategySelector.selectProductStrategyByIds(null); } catch(Exception e) { }
        try { ret = AccountPlanProductStrategySelector.selectProductStrategyByGroupIds(null); } catch(Exception e) { }
        try { ret2 = AccountPlanProductStrategySelector.selectProductStrategyPortfolioPerformanceByCompanyIds(null); } catch(Exception e) { }

    }
    @isTest static void AccountPlanWalletByDomainTest() {
        Set<Id> Ids = new Set<Id> { utility.getFakeId(AcctPlanWallet__c.SObjectType) };
        List<AcctPlanWalletByDomain__c> ret = AccountPlanWalletByDomainSelector.getWalletByDomainByWallets(Ids);
        try { ret = AccountPlanWalletByDomainSelector.getWalletByDomainByWallets(null); } catch(Exception e) { }
    }
    @isTest static void AccountPlanWalletTest() {
        Set<Id> Ids = new Set<Id> { utility.getFakeId(AcctPlanWallet__c.SObjectType) };
        Set<Id> grpIds = new Set<Id> { utility.getFakeId(AcctPlanCompanyProfile__c.SObjectType) };
        List<AcctPlanWallet__c> ret = AccountPlanWalletSelector.getWalletByIds(Ids);
        ret = AccountPlanWalletSelector.getWalletByCompanyProfileIds(grpIds);

        try { ret = AccountPlanWalletSelector.getWalletByIds(null); } catch(Exception e) { }
        try { ret = AccountPlanWalletSelector.getWalletByCompanyProfileIds(null); } catch(Exception e) { }


    }
    @isTest static void AccountTest() {
        List<Account> ret = AccountSelector.getAccountUnderGroupByGroupProfileId(utility.getFakeId(AcctPlanGroupProfile__c.SObjectType));
        Set<Id> Ids = new Set<Id> { utility.getFakeId(AcctPlanPortfolio__c.SObjectType) };
        ret = AccountSelector.getSEAccountUnderPortfolioIds(Ids);
        ret = AccountSelector.getAccountUnderPortfolioIds(Ids);
        ret = AccountSelector.getAccountWithSingleViewInfoByIds(Ids);
        try { ret = AccountSelector.getAccountUnderGroupByGroupProfileId(null); } catch(Exception e) { }
        try { ret = AccountSelector.getSEAccountUnderPortfolioIds(null); } catch(Exception e) { }
        try { ret = AccountSelector.getAccountUnderPortfolioIds(null); } catch(Exception e) { }
        try { ret = AccountSelector.getAccountWithSingleViewInfoByIds(null); } catch(Exception e) { }
    }
    @isTest static void AcctPlanCapitalExpenditurePlanTest() {
        Set<Id> Ids = new Set<Id> { utility.getFakeId(AcctPlanWallet__c.SObjectType) };
        List<AcctPlanCapitalExpenditurePlan__c> ret = AcctPlanCapitalExpenditurePlanSelector.SelectQuestionairByWalletIds(Ids);
        try { ret = AcctPlanCapitalExpenditurePlanSelector.SelectQuestionairByWalletIds(null); } catch(Exception e) { }
    }
    @isTest static void AcctPlanExistingLongTermLoanTest() {

        Set<Id> Ids = new Set<Id> { utility.getFakeId(AcctPlanWallet__c.SObjectType) };
        List<AcctPlanExistingLongTermLoan__c> ret = AcctPlanExistingLongTermLoanSelector.SelectQuestionairByWalletIds(Ids);
        try { ret = AcctPlanExistingLongTermLoanSelector.SelectQuestionairByWalletIds(null); } catch(Exception e) { }
    }
    @isTest static void AcctPlanGroupWalletLockTest() {

        Set<Id> grpIds = new Set<Id> { utility.getFakeId(Group__c.SObjectType) };
        List<AcctPlanGroupWalletLock__c> ret = AcctPlanGroupWalletLockSelector.getGroupwalletLockByGroupIds(grpIds);
        try { ret = AcctPlanGroupWalletLockSelector.getGroupwalletLockByGroupIds(null); } catch(Exception e) { }
    }
    @isTest static void AcctPlanOtherRevenueExpenditureTest() {
        Set<Id> Ids = new Set<Id> { utility.getFakeId(AcctPlanWallet__c.SObjectType) };
        List<AcctPlanOtherRevenueExpenditure__c> ret = AcctPlanOtherRevenueExpenditureSelector.SelectQuestionairByWalletIds(Ids);
        try { ret = AcctPlanOtherRevenueExpenditureSelector.SelectQuestionairByWalletIds(null); } catch(Exception e) { }
    }
    @isTest static void ExchangeRateTest() {
        List<Exchange_Rate_Of_Thai_FCY__c> ret = ExchangeRateSelector.getAllExchangeRates();
    }
    @isTest static void ProductPerformanceTest() {
        Id accId = utility.getFakeId(Account.SObjectType);
        List<Product_Performance__c> ret = ProductPerformanceSelector.getProductPerformanceTHB(accId);
        ret = ProductPerformanceSelector.getProductPerformanceUSD(accId);
        ret = ProductPerformanceSelector.getProductPerformanceOther(accId);

        try { ret = ProductPerformanceSelector.getProductPerformanceTHB(null); } catch(Exception e) { }
        try { ret = ProductPerformanceSelector.getProductPerformanceUSD(null); } catch(Exception e) { }
        try { ret = ProductPerformanceSelector.getProductPerformanceOther(null); } catch(Exception e) { }
    }
    @isTest static void ProductTest() {
        List<Product2> ret = ProductSelector.getProductForAccountPlanWallet();
    }
    @isTest static void QuestionnaireTest() {
        Set<Id> Ids = new Set<Id> { utility.getFakeId(AcctPlanWallet__c.SObjectType) };
        List<AcctPlan_Questionnaire_Template__c> ret = QuestionnaireSelector.SelectSelectQuestionairTemplate();
        List<AcctPlanQuestionnaire__c> ret2 = QuestionnaireSelector.SelectQuestionairByWalletIds(Ids);
        try { ret2 = QuestionnaireSelector.SelectQuestionairByWalletIds(null); } catch(Exception e) { }
    }
}