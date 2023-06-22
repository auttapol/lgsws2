@isTest
public class AcctPlanGrpProPerformanceCtrlV2Test {

    public static Profile m_Admin;
    public static Profile m_SEProfile;
    public static Profile m_BDMProfile;
    public static User m_SeUser;
    public static User m_BDMUser;
    static {
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();
        TestUtils.createDisqualifiedReason();
        TestUtils.CreateAddress();
        // get Profile
        m_Admin = ServiceTestUtils.getProfileByName(ServiceTestUtils.EProfile.SystemAdmin);
        m_SEProfile = ServiceTestUtils.getProfileByName(ServiceTestUtils.EProfile.TMBRM);
        m_BDMProfile = ServiceTestUtils.getProfileByName(ServiceTestUtils.EProfile.TMBBDM);
        // createUsers(integer startNo, Integer size,String FName,String LName,String Email,ID setProfileID,Boolean isSESegment,Boolean doInsert) {

        system.debug(':::: Profile Id for SE : ' + m_SEProfile.Id);

        //m_SeUser = ServiceTestUtils.createUsers(1, 1, 'tmbbank1', 'TMBLName1', 'tmb@tmbbank.com', m_SEProfile.Id, true, true) [0];
        m_BDMUser = ServiceTestUtils.createUsers(3, 1, 'tmbbank2', 'TMBLName2', 'tmb@tmbbank.com', m_BDMProfile.Id, true, true) [0];
        m_SeUser = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID, false, true).get(0);
        
        System.debug('SE USER : ' + m_SeUser.Id);

        List<sObject> products = Test.loadData(Product2.sObjectType /*API Name*/, 'ProductMaster' /*Static Resource Name*/);
        List<sObject> ls = Test.loadData(AcctPlan_Questionnaire_Template__c.sObjectType /*API Name*/, 'AcctPlanQuestionnaireTemplate' /*Static Resource Name*/);
        List<sObject> sectionConfig = Test.loadData(Account_Plan_Deposit_Section__c.sObjectType /*API Name*/, 'DepositeSection' /*Static Resource Name*/);

        AccountPlanWalletTestUtilities.createStandardFee();
        AccountPlanWalletTestUtilities.createBanks();
        AccountPlanWalletTestUtilities.createCurrencies();
        AccountPlanTestUtilities.getAcctPlanMode();
        AccountPlanTestUtilities.AccountPlanStatusCode();

    }
    @isTest
    private static void test_GroupPerformance() {
        IAccountPlanRefreshService mock = new AccountPlanRefreshServiceBatchMock();
        AccountPlanRefreshService.setMockservice(mock);



        IAcctPlanGroupWalletLockService mock2 = new AcctPlanGroupWalletLockServiceMock();
        AcctPlanGroupWalletLockService.setMockservice(mock2);





        //Test.setMock(WebServiceMock.class, new TMBAccountPlanServiceProxyMock());
        Map<Id, Id> accountsSet = new Map<Id, Id> ();
        string year = System.today().year() + '';
        // Create Account 
        System.debug('Start : ' + m_SeUser.Id);
        List<Account> AccountList = AccountPlanTestUtilities.createAccounts(2, 'InitiateTest', 'Individual', m_SeUser.id, true, true);

        System.debug('Create account to group');
        // Bind to Group
        Group__c mastergroup = AccountPlanTestUtilities.createGroupMaster(1, 'Initiatetest', false, true).get(0);
        for (account acct : AccountList) {
            acct.Group__c = mastergroup.id;
            accountsSet.put(acct.Id, acct.Id);
        }
        update AccountList;
        // Set Target
        AccountPlanTestUtilities.createAccounts(1, 'InitiateNonGroupTest', 'Individual', m_SeUser.id, true, true);
        List<Target__c> TaragetList = AccountPlanTestUtilities.createTargetNI(5, m_SeUser.id, true);


        List<Account> acctForCompanyProfile = new List<Account> ();
        acctForCompanyProfile.add(AccountList.get(0));
        system.runAs(m_SeUser) {
            List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
            AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
            List<group__c> mgroupList = new List<group__c> ();
            mgroupList.add(mastergroup);


            AcctPlanGroupProfile__c groupprofile = AccountPlanTestUtilities.createGroupProfilebyGroup(mgroupList, true).get(0);
            groupprofile.Year__c = year;
            update groupprofile;
            comprofile.AcctPlanGroup__c = groupprofile.id;


            AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(m_SeUser.id, year, 10000000, true);
            AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
            List<AcctPlanContribution__c> contributionlist = AccountPlanTestUtilities.createRenevueContribution(3, null, comprofile.id);






            comprofile.Portfolio__c = portfolio.Id;
            AcctPlanCompanyPort__c comport = new AcctPlanCompanyPort__c();

            comport.Account__c = comprofile.Account__c;
            comport.Account_Plan_Portfolio__c = portfolio.Id;
            comport.Account_Name__c = 'ddd';
            insert comport;
            update comprofile;


            AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
            AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
            AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);




            Test.startTest();

            AcctPlanCompanyProfile__c com1 = comprofileList[0];

            // Create Performance 
            AcctAnnualPerformance__c per = new AcctAnnualPerformance__c();

            per.Account__c = comprofile.Account__c;
            per.Transaction_Date__c = System.today().addMonths(- 3);
            per.CREDIT_FEE__c = 0.0;
            per.TMB_CUST_ID__c = 'TMBCUS00000001';
            insert per;
            AccountPlanRefreshService.initialStep0(com1.Account__c + '');
            AccountPlanRefreshService.RefreshProductStrategyPort(accountsSet.keySet(), year);
            AccountPlanRefreshService.RefreshNameProductStrategyPort(accountsSet.keySet(), year);

            //Start New function for R5.2
            String groupID = groupprofile.group__c;
            String groupProfileID = groupprofile.id;
            Set<id> acctCompanyProfileIds = new Set<id>();
            Set<id> walletIds = new Set<id>();
            if(comprofileList.size()>0){
              for(AcctPlanCompanyProfile__c item : comprofileList){
                acctCompanyProfileIds.add(item.id);
                walletIds.add(item.AccountPlanWalletID__c);
              }
              
            }      
            AccountPlanRefreshService.RefreshProductStrategyPort(accountsSet.keySet(), year, groupID);
            AccountPlanRefreshService.RefreshProductStrategyGroupWalletGroupPerformance(accountsSet.keySet(),acctCompanyProfileIds, walletIds,groupID);
            AccountPlanRefreshService.RefreshProductStrategy2(accountsSet.keySet(),year,groupID );
            //End New function for R5.2

            AccountPlanProductStrategyService.createProductStrategyRecordToWallet(comprofile.Id, AcctPlanwallet.Id, groupprofile.id);

            AccountPlanRefreshService.RefreshWalletAndAnnualPerformanceRolling12Month(new Set<Id> { portfolio.Id });

            PageReference ViewPage = Page.AccountplanGroupPerformanceV3;
            ViewPage.getParameters().put('GroupID', groupprofile.id);
            ViewPage.getParameters().put('CompanyID', comprofile.id);
            ViewPage.getParameters().put('WalletID', AcctPlanwallet.id);
            Test.setCurrentPage(ViewPage);


            ApexPages.StandardController sctrl = new ApexPages.StandardController(new AcctPlanProdStrategy__c());
            AcctPlanGroupProjectedPerformanceCtrlV3 ctrl = new AcctPlanGroupProjectedPerformanceCtrlV3(sctrl);

            ctrl.Refresh();
            ctrl.initGroupWallet();
            ctrl.initGroupWalletV2(new List<AccountPlanProductStrategyService.AcctPlanProdStrategyInfo>());
            ctrl.MasterGroupID = mgroupList.get(0).id;
            AcctPlanCusUnderstanding__c custoutstanding1 = new AcctPlanCusUnderstanding__c();
            custoutstanding1.AcctPlanWallet__c =AcctPlanwallet.id;
            custoutstanding1.Ending_CASA__c =100;
            custoutstanding1.Average_CASA__c =100;
            custoutstanding1.Average_loan_outstanding__c =100;
            custoutstanding1.Ending_loan_outstanding__c =100;
            custoutstanding1.FX_volume__c =100;
            custoutstanding1.TF_Volume__c =100;
            custoutstanding1.Account__c = AccountList.get(0).id;

            insert custoutstanding1;
             MockWalltSizing(mgroupList.get(0).id, year,AccountList.get(0).id,comprofileList.get(0).id);
             List<AcctPlanGroupProjectedPerformanceCtrlV3.walletWrapper> sumaary= ctrl.SummaryReport;


            AcctPlanGroupProjectedPerformanceCtrlV3.walletWrapper w1 = ctrl.SummaryWalletSizingReport;
            List<AccountPlanWalletSizing__c> w2 = ctrl.walletSizingList;
            w2 = ctrl.getWalletSizingListFull();
            List<AcctPlanGroupProjectedPerformanceCtrlV3.walletWrapper> w3 = ctrl.SummaryReport;

            boolean boo = ctrl.hasNext;
            boo = ctrl.hasPrevious;
            integer inte = ctrl.pageNumber;
            ctrl.first();
            ctrl.last();
            ctrl.previous();
            ctrl.next();



            Test.stopTest();
        }
        


    }

 static void MockWalltSizing(Id GroupId, String Year,Id AccountId,Id CompanyID)
    {
        List<AccountPlanWalletSizing__c> walletSizingList = new List<AccountPlanWalletSizing__c>();
            
            /**********************************************************************
            *  Step Create Wallet Sizing and Sum from ProductStrategy
            ***********************************************************************/
            for(integer i=0; i<14;i++){

                    AccountPlanWalletSizing__c  w = new AccountPlanWalletSizing__c();
                    w.NIIc__c = 1 ;
                    
                    w.NIId__c = 2 ;
                    
                    w.Fee__c = 3 ;
                    
                    w.RecurringFee__c ='';
                    
                    w.TFFee__c = 5 ;
                    
                    w.FXFee__c = 6 ;
                    
                    w.LGFee__c = 7 ;
                    
                    w.CashFee__c = 8 ;
                    
                    w.ASFee__c = 9 ;
                    
                    w.NonRecurringFee__c ='';
                    
                    w.CreditFee__c = 11;
                    
                    w.BAFee__c = 12 ;
                    
                    w.DerivativeFee__c = 13 ;
                    
                    w.IBFee__c = 14 ;
                    if(i == 0){
                        w.Account__c = AccountId;
                        w.AccountNamePE__c = 'NamePE'+i;
                        w.SummaryType__c = 'None';
                        w.Account_Plan_Company_Profile__c = CompanyID;
                        w.IsProductStrategy__c = true;
                        w.IsGroupWallet__c = true;
                        w.IsGroupPerformance__c = true;
                    
                    }else if(i==1){
                        w.SummaryType__c = 'WalletSizing'; 
                        w.IsProductStrategy__c = false;
                        w.IsGroupWallet__c = true;
                        w.IsGroupPerformance__c = true;
                    }else if(i==2){
                        w.SummaryType__c = 'ActualNI'; 
                        w.IsProductStrategy__c = false;
                        w.IsGroupWallet__c = true;
                        w.IsGroupPerformance__c = true;
                    }
                    else if(i==3){
                        w.SummaryType__c = 'AdjustedNI'; 
                        w.IsProductStrategy__c = false;
                        w.IsGroupWallet__c = true;
                        w.IsGroupPerformance__c = true;
                    }
                    else if(i==4){
                        w.SummaryType__c = 'AspirationSOW'; 
                        w.IsProductStrategy__c = false;
                        w.IsGroupWallet__c = true;
                        w.IsGroupPerformance__c = true;
                    }
                    else if(i==5){
                        w.SummaryType__c = 'ExpectedIncrementalNI'; 
                        w.IsProductStrategy__c = false;
                        w.IsGroupWallet__c = true;
                        w.IsGroupPerformance__c = false;
                    }
                    else if(i==6){
                        w.SummaryType__c = 'ExpectedIncrementalNIStep5'; 
                        w.IsProductStrategy__c = false;
                        w.IsGroupWallet__c = false;
                        w.IsGroupPerformance__c = true;
                    }
                    else if(i==7){
                        w.SummaryType__c = 'TotalCompanyNI'; 
                        w.IsProductStrategy__c = false;
                        w.IsGroupWallet__c = false;
                        w.IsGroupPerformance__c = true;
                    }
                    else if(i==8){
                        w.SummaryType__c = 'ExpectedIncrementalNIStep6'; 
                        w.IsProductStrategy__c = false;
                        w.IsGroupWallet__c = false;
                        w.IsGroupPerformance__c = false;
                    }
                    else if(i==9){
                        w.SummaryType__c = 'ExistingSOW'; 
                        w.IsProductStrategy__c = false;
                        w.IsGroupWallet__c = true;
                        w.IsGroupPerformance__c = true;
                    }
                    else if(i==10){
                        w.SummaryType__c = 'ExpectedSOW'; 
                        w.IsProductStrategy__c = false;
                        w.IsGroupWallet__c = false;
                        w.IsGroupPerformance__c = true;
                    }
                    else if(i==11){
                        w.SummaryType__c = 'AspirationSOWStep6'; 
                        w.IsProductStrategy__c = false;
                        w.IsGroupWallet__c = false;
                        w.IsGroupPerformance__c = true;
                    }
                    else if(i==12){
                        w.SummaryType__c = 'CompareExpectedtoAspirationSOW'; 
                        w.IsProductStrategy__c = false;
                        w.IsGroupWallet__c = false;
                        w.IsGroupPerformance__c = true;
                    }
                    else if(i==13){
                        w.SummaryType__c = 'TargetbyGroup'; 
                        w.IsProductStrategy__c = false;
                        w.IsGroupWallet__c = false;
                        w.IsGroupPerformance__c = false;
                    }
                    

                    w.Year__c = year;
                    w.Group__c = GroupId;
                    w.RefreshDate__c  =   datetime.now();
                    //w.AccountName__c = MapCompanyProfile.get(item).AccountName__c;
                    walletSizingList.add(w);  
                    
            }
            if(walletSizingList.size()>0){
                insert walletSizingList;
            }
    }

















    public class AcctPlanGroupWalletLockServiceMock implements IAcctPlanGroupWalletLockService {
        public void Lock(Id groupId) { }
        public void Unlock(Id groupId) { }
        public boolean IsLock(id groupId) { return false; }
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
}