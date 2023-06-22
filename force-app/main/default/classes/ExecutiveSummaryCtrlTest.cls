@isTest
public class ExecutiveSummaryCtrlTest
{

    static{
        AccountPlanTestUtilities.AccountPlanStatusCode(); 
        AppConfig__c appconfig = new AppConfig__c(Name = 'runtrigger' , Value__c = 'true');
        insert appconfig;
        TestUtils.createAppConfigRetailtoComm();

    }   
    
    public static User headUser = testUsers('headuser','T0001',AccountPlanTestUtilities.TMB_SEGMENTHEAD_PROFILE_ID,null);
    public static User rmUser = testUsers('rmuser','T0002',AccountPlanTestUtilities.TMB_RM_PROFILE_ID,headUser.Id);
    public static User admin = testUsers('admin','T0003',AccountPlanTestUtilities.SYSADMIN_PROFILE_ID,null);

    public static testMethod void positiveTest()
    {
        /** Run as RM same owner as account**/
            Account_Search_Parameters__c param = new Account_Search_Parameters__c(Name = 'Customer Name',FieldID__c = '00NN0000001uzM3');
            insert param;
            Account acct = createAccountwithAcctplan();
                acct.ownerid = rmUser.id;
                update acct;

            system.runAs(rmUser){
                List<AcctAnnualPerformance__c> annualperList = createAnnualPerformance(acct.Id);
                List<AcctPlanCompanyProfile__c> compro = createComProfilewithAcct(acct.Id);

                AcctPlanWallet__c wallet = createWallet(compro.get(0).Id);
                List<AcctPlanProdStrategy__c> prodstrgList = createProductStrgByComprofile(compro.get(0).Id,wallet.id); // this year
                List<AcctPlanProdStrategy__c> prodstrgList2 = createProductStrgByComprofile(compro.get(1).Id,wallet.id); // last year
                
                List<AcctPlanWalletByDomain__c> walletbydomainList = createWalletbyDomain(wallet.Id);
                List<AcctPlanActionPlan__c> actionplanList = createActionPlan(walletbydomainList.get(0).Id);
                List<AcctPlanActivity__c> acctplanactivity = createAcctPlanActivity(acct.Id,actionplanList.get(0).Id);

                List<Executive_Summary__c> exec = createExecutiveSummary(1,acct.Id,compro.get(0).Id);
                
                AcctPlanNIProject__c acctplanNI = new AcctPlanNIProject__c();
                    acctplanNI.AcctPlanActionPlanID__c = actionplanList.get(0).id;
                    insert acctplanNI;
                
                Test.startTest();

                ApexPages.StandardController sc = new ApexPages.StandardController(exec.get(0));
                ApexPages.currentPage().getParameters().put('ID',String.valueOf(exec.get(0).Id));
                ApexPages.currentPage().getParameters().put('CF'+param+'_lkid',String.valueOf(acct.Id));

                
                ExecutiveSummaryCtrl execCtrl = new ExecutiveSummaryCtrl(sc);
                execCtrl.checkUserPermission();
                execCtrl.CloneExecutiveSummary();
                execCtrl.selectAcctPlan();
                execCtrl.retrieveAcctPlan(compro.get(0).Id);
                execCtrl.ExecutiveSummary.Account_Plan_Company_Profile__c = compro.get(0).Id;
                execCtrl.retrieveAcctPlanActivity();
                execCtrl.retrieveNIProject(actionplanList);
                execCtrl.save();
                execCtrl.mobileSave();
                execCtrl.Refresh();
                execCtrl.checkUserPermission();
                execCtrl.cancleSF1();
                Test.stopTest();

            }
            


    }

    public static testMethod void negativeTest(){
        /** Run as RM not account's owner **/
        Account_Search_Parameters__c param = new Account_Search_Parameters__c(Name = 'Customer Name',FieldID__c = '00NN0000001uzM3');
            insert param;
            Account acct = createAccountwithAcctplan();
                acct.ownerid = rmUser.id;
                update acct;

            system.runAs(rmUser){
                
                List<AcctPlanCompanyProfile__c> compro = createComProfilewithAcct(acct.Id);
                List<Executive_Summary__c> exec = createExecutiveSummary(1,acct.Id,compro.get(0).Id);
                
                Test.startTest();
                
                PageReference pg = Page.ExecutiveSummaryEdit;
                ApexPages.currentPage().getParameters().put('ID','');
                ApexPages.currentPage().getParameters().put('CF'+param+'_lkid',String.valueOf(acct.Id));
                ApexPages.currentPage().getParameters().put('clone','');
                Test.setCurrentPage(pg);
                ApexPages.StandardController sc = new ApexPages.StandardController(exec.get(0));
                //ExecutiveSummaryCtrl execCtrl = new ExecutiveSummaryCtrl(sc);
                
                Test.stopTest();

            }
        
    }
    
    public static Account createAccountwithAcctplan(){
        Account Acct = new Account(); 
            Acct.Name = 'Test Account 1';
            Acct.Phone ='050111222';
            Acct.Mobile_Number_PE__c  = '0801112233';
            Acct.ID_Type_PE__c  = 'Citizen ID';
            Acct.ID_Number_PE__c  = '1510100181965';
            Acct.Customer_Type__c = 'CType';
            Acct.First_name_PE__c = 'Fname';
            Acct.First_Name_ENG_PE__c = 'Fname';
            Acct.Last_name_PE__c = 'TestMock';
            Acct.Last_Name_PE_Eng__c  = 'TestMock';
            Acct.Rating = 'Hot';
            Acct.IsDisqualified__c = false;
            Acct.NIIc_Actual__c = 0;
            Acct.NIId_Actual__c = 0;
            Acct.Fee_Actual__c = 0;
            insert Acct;
        system.debug('>>> Acct : '+Acct);
        return Acct;
        //List<Executive_Summary__c> execList = createExecutiveSummary(1,Acct.Id,comprofile.Id);
        //system.debug('>>> execList : '+execList);

    }

    public static List<AcctPlanCompanyProfile__c> createComProfilewithAcct(Id accId){
        List<AcctPlanCompanyProfile__c> comList = new List<AcctPlanCompanyProfile__c>();
        AcctPlanCompanyProfile__c comprofile1 = new AcctPlanCompanyProfile__c(Account__c = accId,Year__c = '2016');
        AcctPlanCompanyProfile__c comprofile2 = new AcctPlanCompanyProfile__c(Account__c = accId,Year__c = '2015');
        comList.add(comprofile1);
        comList.add(comprofile2);

        insert comList;
        return comList;
    }

    public static void createAccountwithoutAcctplan(){
        List<Account> accList = TestUtils.createAccounts(1, 'test', 'CType', true);

        List<Executive_Summary__c> execList = createExecutiveSummary(1,accList.get(0).Id,null);
        system.debug('>>> execList : '+execList);


    }

    public static User testUsers(String lastName,String empId,Id profileId,Id managerId){
        User user = new User(FirstName=lastName, LastName=lastName, 
                                    UserName=lastName+'_TMBTestTMB@tmbbank.com',
                                    Email=lastName+'@tmbbank.com', Alias=lastName,Segment__c ='BB',ManagerId=managerId ,
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname=lastName+'TMBTesttmb',
                                    ProfileId = profileId, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c =empId);
        insert user;
        return user;
    }

    public static List<Executive_Summary__c> createExecutiveSummary(Integer size,Id accId,Id comprofileId){
        List<Executive_Summary__c> execList = new List<Executive_Summary__c>();
        
        for(Integer i=0 ; i<size ; i++){
            Executive_Summary__c exec = new Executive_Summary__c();
            exec.Customer_Name__c = accId;
            exec.Account_Plan_Company_Profile__c = comprofileId;
            exec.Team_Head__c = rmUser.Id ;
            exec.Talk_Point__c = 'Test talk point';
            execList.add(exec);
        }
        insert execList;
        return execList;

    }

    public static List<AcctPlanProdStrategy__c> createProductStrgByComprofile(Id comprofileId,id walletid){
        List<AcctPlanProdStrategy__c> prodstrgList = new List<AcctPlanProdStrategy__c>();
        AcctPlanProdStrategy__c prodstrg1 = new AcctPlanProdStrategy__c(AcctPlanWallet__c = walletid,AcctPlanCompanyProfileID__c = comprofileId , Name='1. NIIc' ,WalletSizing__c = 2000 , ExpectedIncrementalNIFromStep5__c = 2000);
        AcctPlanProdStrategy__c prodstrg2 = new AcctPlanProdStrategy__c(AcctPlanWallet__c = walletid,AcctPlanCompanyProfileID__c = comprofileId , Name='2. NIId' ,WalletSizing__c = 2000 , ExpectedIncrementalNIFromStep5__c = 2000);
        AcctPlanProdStrategy__c prodstrg3 = new AcctPlanProdStrategy__c(AcctPlanWallet__c = walletid,AcctPlanCompanyProfileID__c = comprofileId , Name='3. Fee' ,WalletSizing__c = 2000 , ExpectedIncrementalNIFromStep5__c = 2000);
        AcctPlanProdStrategy__c prodstrg4 = new AcctPlanProdStrategy__c(AcctPlanWallet__c = walletid,AcctPlanCompanyProfileID__c = comprofileId , Name='3.1 TF Fee' ,WalletSizing__c = 2000 , ExpectedIncrementalNIFromStep5__c = 2000);
        AcctPlanProdStrategy__c prodstrg5 = new AcctPlanProdStrategy__c(AcctPlanWallet__c = walletid,AcctPlanCompanyProfileID__c = comprofileId , Name='3.2 FX Fee' ,WalletSizing__c = 2000 , ExpectedIncrementalNIFromStep5__c = 2000);
        AcctPlanProdStrategy__c prodstrg6 = new AcctPlanProdStrategy__c(AcctPlanWallet__c = walletid,AcctPlanCompanyProfileID__c = comprofileId , Name='3.3 L/G Fee' ,WalletSizing__c = 2000 , ExpectedIncrementalNIFromStep5__c = 2000);
        AcctPlanProdStrategy__c prodstrg7 = new AcctPlanProdStrategy__c(AcctPlanWallet__c = walletid,AcctPlanCompanyProfileID__c = comprofileId , Name='3.4 Cash Fee' ,WalletSizing__c = 2000 , ExpectedIncrementalNIFromStep5__c = 2000);
        AcctPlanProdStrategy__c prodstrg8 = new AcctPlanProdStrategy__c(AcctPlanWallet__c = walletid,AcctPlanCompanyProfileID__c = comprofileId , Name='3.5 AS Fee' ,WalletSizing__c = 2000 , ExpectedIncrementalNIFromStep5__c = 2000);
        AcctPlanProdStrategy__c prodstrg9 = new AcctPlanProdStrategy__c(AcctPlanWallet__c = walletid,AcctPlanCompanyProfileID__c = comprofileId , Name='3.6 Credit Fee' ,WalletSizing__c = 2000 , ExpectedIncrementalNIFromStep5__c = 2000);
        AcctPlanProdStrategy__c prodstrg10 = new AcctPlanProdStrategy__c(AcctPlanWallet__c = walletid,AcctPlanCompanyProfileID__c = comprofileId , Name='3.7 BA Fee' ,WalletSizing__c = 2000 , ExpectedIncrementalNIFromStep5__c = 2000);
        AcctPlanProdStrategy__c prodstrg11 = new AcctPlanProdStrategy__c(AcctPlanWallet__c = walletid,AcctPlanCompanyProfileID__c = comprofileId , Name='3.8 Derivative Fee' ,WalletSizing__c = 2000 , ExpectedIncrementalNIFromStep5__c = 2000);   
        AcctPlanProdStrategy__c prodstrg12 = new AcctPlanProdStrategy__c(AcctPlanWallet__c = walletid,AcctPlanCompanyProfileID__c = comprofileId , Name='3.9 IB Fee' ,WalletSizing__c = 2000 , ExpectedIncrementalNIFromStep5__c = 2000);
        prodstrgList.add(prodstrg1);
        prodstrgList.add(prodstrg2);
        prodstrgList.add(prodstrg3);
        prodstrgList.add(prodstrg4);
        prodstrgList.add(prodstrg5);
        prodstrgList.add(prodstrg6);
        prodstrgList.add(prodstrg7);
        prodstrgList.add(prodstrg8);
        prodstrgList.add(prodstrg9);
        prodstrgList.add(prodstrg10);
        prodstrgList.add(prodstrg11);
        prodstrgList.add(prodstrg12);
        insert prodstrgList;
        return prodstrgList;
    }

    public static List<AcctAnnualPerformance__c> createAnnualPerformance(Id accountId){
        List<AcctAnnualPerformance__c> annualperList = new List<AcctAnnualPerformance__c>();
        AcctAnnualPerformance__c annualper1 = new AcctAnnualPerformance__c(TMB_CUST_ID__c = '1234567899' , Account__c = accountId , Fee__c = 300,NIIc__c = 300 , NIId__c = 300 , Transaction_Date__c = System.today().addYears(-1));
        AcctAnnualPerformance__c annualper2 = new AcctAnnualPerformance__c(TMB_CUST_ID__c = '1234567899' , Account__c = accountId , Fee__c = 300,NIIc__c = 300 , NIId__c = 300 , Transaction_Date__c = System.today().addYears(-1));
        AcctAnnualPerformance__c annualper3 = new AcctAnnualPerformance__c(TMB_CUST_ID__c = '1234567899' , Account__c = accountId , Fee__c = 300,NIIc__c = 300 , NIId__c = 300 , Transaction_Date__c = System.today().addYears(-1));
        AcctAnnualPerformance__c annualper4 = new AcctAnnualPerformance__c(TMB_CUST_ID__c = '1234567899' , Account__c = accountId , Fee__c = 300,NIIc__c = 300 , NIId__c = 300 , Transaction_Date__c = System.today().addYears(-1));
        AcctAnnualPerformance__c annualper5 = new AcctAnnualPerformance__c(TMB_CUST_ID__c = '1234567899' , Account__c = accountId , Fee__c = 300,NIIc__c = 300 , NIId__c = 300 , Transaction_Date__c = System.today());
        AcctAnnualPerformance__c annualper6 = new AcctAnnualPerformance__c(TMB_CUST_ID__c = '1234567899' , Account__c = accountId , Fee__c = 300,NIIc__c = 300 , NIId__c = 300 , Transaction_Date__c = System.today());
        AcctAnnualPerformance__c annualper7 = new AcctAnnualPerformance__c(TMB_CUST_ID__c = '1234567899' , Account__c = accountId , Fee__c = 300,NIIc__c = 300 , NIId__c = 300 , Transaction_Date__c = System.today());
        annualperList.add(annualper1);
        annualperList.add(annualper2);
        annualperList.add(annualper3);
        annualperList.add(annualper4);
        annualperList.add(annualper5);
        annualperList.add(annualper6);
        annualperList.add(annualper7);
        insert annualperList;
        return annualperList;
    }

    //wallet(Id comProfileId)
    public static AcctPlanWallet__c createWallet(Id comprofileId){
        AcctPlanWallet__c wallet = new AcctPlanWallet__c(AcctPlanCompanyProfile__c = comprofileId);
        insert wallet;
        return wallet;
    }
    
    //wallet by domain(Id walletId) create id,WalletDomain__c
    public static List<AcctPlanWalletByDomain__c> createWalletbyDomain(Id walletId){
        List<AcctPlanWalletByDomain__c> walletbyDomainList = new List<AcctPlanWalletByDomain__c>();
        AcctPlanWalletByDomain__c walletbydomain1 = new AcctPlanWalletByDomain__c(AcctPlanWallet__c = walletId , WalletDomain__c = 1);
        AcctPlanWalletByDomain__c walletbydomain2 = new AcctPlanWalletByDomain__c(AcctPlanWallet__c = walletId , WalletDomain__c = 2);
        AcctPlanWalletByDomain__c walletbydomain3 = new AcctPlanWalletByDomain__c(AcctPlanWallet__c = walletId , WalletDomain__c = 3);
        AcctPlanWalletByDomain__c walletbydomain4 = new AcctPlanWalletByDomain__c(AcctPlanWallet__c = walletId , WalletDomain__c = 4);
        walletbyDomainList.add(walletbydomain1);
        walletbyDomainList.add(walletbydomain2);
        walletbyDomainList.add(walletbydomain3);
        walletbyDomainList.add(walletbydomain4);
        insert walletbyDomainList;
        return walletbyDomainList;
    }

    //action plan(Id walletbydomainId) create Id, Objective__c, Status__c, WinningPropostion__c
    public static List<AcctPlanActionPlan__c> createActionPlan(Id walletbydomainId){
        List<AcctPlanActionPlan__c> actionplanList = new List<AcctPlanActionPlan__c>();
        AcctPlanActionPlan__c actionplan1 = new AcctPlanActionPlan__c(AcctPlanWalletByDomain__c = walletbydomainId,Objective__c = 'Maintain', Status__c = 'On Board', WinningPropostion__c = '1');
        actionplanList.add(actionplan1);
        insert actionplanList;
        return actionplanList;
    }

    //action activity(Id action plan) create ID, AccountPlanActionPlanID__c, Date__c> today,Other__c, CustomerCounterparties__c,CustomerCounterparties__r.Name , Activities__c 
    public static List<AcctPlanActivity__c> createAcctPlanActivity(Id accountId,Id actionPlanId){
        List<AcctPlanActivity__c> acctplanactivityList = new List<AcctPlanActivity__c>();
        AcctPlanActivity__c acctplanactivity1 = new AcctPlanActivity__c(Activities__c = 'Economic update' , AccountPlanActionPlanID__c = actionPlanId , Account__c = accountId , Date__c = System.today().addDays(2));
        AcctPlanActivity__c acctplanactivity2 = new AcctPlanActivity__c(Activities__c = 'Others' ,Other__c = 'test', AccountPlanActionPlanID__c = actionPlanId , Account__c = accountId , Date__c = System.today().addDays(1));
        acctplanactivityList.add(acctplanactivity1);
        acctplanactivityList.add(acctplanactivity2);
        insert acctplanactivityList;
        return acctplanactivityList;
    }
}