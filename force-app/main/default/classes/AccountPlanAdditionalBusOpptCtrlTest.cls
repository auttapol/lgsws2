@isTest
global class AccountPlanAdditionalBusOpptCtrlTest {
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

    static testmethod void AccountPlanAdditionalBusOppt() {
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
            AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
            
           AccountPlanAdditionalBusOpptCtrl busOpptList = new AccountPlanAdditionalBusOpptCtrl();
            
        }

    }

}