@IsTest
public class AcctPlanPortfolioTriggerHandlerTest{
    static{
        TestUtils.CreateProceBookAccess();
        TestUtils.CreateProceBook();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        TestUtils.createIdType();
        TestUtils.createTriggerMsg();
        TestUtils.createObjUserPermission();
        AccountPlanTestUtilities.getAcctPlanMode();
    }
       public static testmethod void AcctPlanPortfolioTrigger(){
          User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioInitiateTest', 'portfolio@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
        List<Account> AccountList = AccountPlanTestUtilities.createAccounts(5, 'InitiateTest', 'Individual', SalesOwner.id, true, true);
        List<Account> AccountList2 = AccountPlanTestUtilities.createAccounts(5, 'InitiateTest2', 'Individual', SalesOwner.id, true, true);
        Group__c mastergroup = AccountPlanTestUtilities.createGroupMaster(1,'Initiatetest', false, true).get(0);
        List<Group__c> mastergroupList = AccountPlanTestUtilities.createGroupMaster(1,'Initiatetest2', false, true);
        AcctPlanGroupProfile__c groupprofile = AccountPlanTestUtilities.createGroupProfilebyGroup(mastergroupList,true).get(0);
        groupprofile.Year__c ='2014';
        update groupprofile;
           
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(AccountList2, true);
        for(AcctPlanCompanyProfile__c compro : comprofileList){
            compro.Year__c = '2014';
            compro.AcctPlanGroup__c =  groupprofile.id;
        }
        update comprofileList;
        
        for(account acct  : AccountList){
            acct.Group__c =mastergroup.id;
        }
        for(account acct  : AccountList2){
            acct.Group__c =mastergroupList.get(0).id;
        }
        update AccountList;
        update AccountList2;
        AccountPlanTestUtilities.createAccounts(1, 'InitiateNonGroupTest', 'Individual', SalesOwner.id, true, true);
        List<Target__c> TaragetList = AccountPlanTestUtilities.createTargetNI(5,  SalesOwner.id, true);
       
        System.runAs(SalesOwner){
            AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(SalesOwner.id, '2014', 10000000, false);
            insert portfolio;
            portfolio.TargetNI__c = 6000000;
            update portfolio;
            List<Group__c> groupmasterlist = new List<Group__c>();
                groupmasterlist.add(mastergroup);
            List<AcctPlanGroupPort__c> groupportlist = AccountPlanTestUtilities.createGroupPortbyGroupMaster(groupmasterlist, portfolio, true);
            List<AcctPlanCompanyPort__c> comportList = AccountPlanTestUtilities.createCompanyPortByAccount(AccountList, portfolio, true);
            if(portfolio != null){
                delete portfolio;
            }
            
        }
       }
}