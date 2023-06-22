@IsTest
public class AccountPlanActionPlanControllerTest{
    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        TestUtils.createIdType();
        TestUtils.createTriggerMsg();
        TestUtils.createObjUserPermission();
        AccountPlanTestUtilities.AccountPlanStatusCode();
    }
public static Account testAccount;
public static Contact cont;
public static AcctPlanCompanyProfile__c Company;
public static AcctPlanCompanyProfile__c Company1;
public static AcctPlanWallet__c Wallet;
public static AcctPlanWalletByDomain__c WalletDomain;
public static AcctPlanWalletByDomain__c WalletDomaing2;

       public static testMethod void ActionPlanGlobal(){
       
              //Create Account
        testAccount = new Account();
        testAccount.Name='Test AccountPlan Step5' ;
        testAccount.Phone ='050111222';
        testAccount.Mobile_Number_PE__c  = '0801112233';   
        insert testAccount;
        
        //Create Contact
        cont = new Contact();
        cont.FirstName='AccountPlan';
        cont.LastName='Step5';
        cont.Position__c = 'Manager';
        cont.Accountid= testAccount.id;
        insert cont;
        
        //Create Account Plan
        Company = new AcctPlanCompanyProfile__c();
        Company.Account__c=testAccount.id;
        //Company.Name='AccountPlan Step5';
        insert Company;
        
        Wallet = new AcctPlanWallet__c();
        Wallet.AcctPlanCompanyProfile__c = Company.id;
        insert Wallet;
        
        WalletDomain = new AcctPlanWalletByDomain__c();
        WalletDomain.AcctPlanWallet__c = Wallet.id;
        WalletDomain.WalletDomain__c = 1;
        WalletDomain.Priority__c ='High';
        WalletDomain.SubDomain__c ='Liquidity Management';
        WalletDomain.TypeOfNI__c = 'NIIC';
        insert WalletDomain;
        
        WalletDomaing2 = new AcctPlanWalletByDomain__c();
        WalletDomaing2.AcctPlanWallet__c = Wallet.id;
        WalletDomaing2.WalletDomain__c = 4;
        WalletDomaing2.Priority__c ='Medium';
        WalletDomaing2.SubDomain__c ='Hedging Normal business transaction : Trade transaction';
        WalletDomaing2.TypeOfNI__c = 'FX Fee';
        insert WalletDomaing2;
        
        AccountPlanActionPlan();
        ActionPlanActivities();
       }
       
       public static testMethod void ActionPlanGlobal2(){
       
              //Create Account
        testAccount = new Account();
        testAccount.Name='Test AccountPlan Step5' ;
        testAccount.Phone ='050111222';
        testAccount.Mobile_Number_PE__c  = '0801112233';    
        insert testAccount;
        
        //Create Contact
        cont = new Contact();
        cont.FirstName='AccountPlan';
        cont.LastName='Step5';
        cont.Position__c = 'Manager';
        cont.Accountid= testAccount.id;
        insert cont;
        
        //Create Account Plan
        Company = new AcctPlanCompanyProfile__c();
        Company.Account__c=testAccount.id;
        //Company.Name='AccountPlan Step5';
        insert Company;
        
        Wallet = new AcctPlanWallet__c();
        Wallet.AcctPlanCompanyProfile__c = Company.id;
        insert Wallet;
        
        WalletDomain = new AcctPlanWalletByDomain__c();
        WalletDomain.AcctPlanWallet__c = Wallet.id;
        WalletDomain.WalletDomain__c = 1;
        WalletDomain.Priority__c ='High';
        WalletDomain.SubDomain__c ='Liquidity Management';
        WalletDomain.TypeOfNI__c = 'NIIC';
        insert WalletDomain;
        
        WalletDomaing2 = new AcctPlanWalletByDomain__c();
        WalletDomaing2.AcctPlanWallet__c = Wallet.id;
        WalletDomaing2.WalletDomain__c = 4;
        WalletDomaing2.Priority__c ='Medium';
        WalletDomaing2.SubDomain__c ='Hedging Normal business transaction : Trade transaction';
        WalletDomaing2.TypeOfNI__c = 'FX Fee';
        insert WalletDomaing2;
        
        AcctPlanActionPlan__c acctplan = new AcctPlanActionPlan__c();
        acctplan.AcctPlanWalletByDomain__c = WalletDomaing2.id;
        acctplan.Objective__c = 'Acquire New customers';
        acctplan.Status__c = 'Post Board';
        acctplan.WinningPropostion__c = 'Test Class';
        insert acctplan;
        
        Task t1=new Task();
        insert t1;
        
        AcctPlanActivity__c activity = new AcctPlanActivity__c();
        activity.AccountPlanActionPlanID__c = acctplan.id;
        activity.Objective__c = 'Acquire New customers';
        activity.Status__c = 'Post Board';
        activity.Group__c = 'Group 1 Relationship';
        activity.Activities__c = 'Work on negative relationship';
        activity.Date__c = System.Today();
        activity.TaskId__c = t1.id;
        insert activity;

        
        AcctPlanStakeholder__c stake = new AcctPlanStakeholder__c();
        stake.AcctPlanActivity__c = activity.id;
        Id select1user = [select id from user limit 1].Id;
        stake.User__c = select1user ;
        insert stake;

        AccountPlanActivitiesSummary();
       }
       
       public static testMethod void ActionPlanGlobal3(){
       
              //Create Account
        testAccount = new Account();
        testAccount.Name='Test AccountPlan Step5' ;
        testAccount.Phone ='050111222';
        testAccount.Mobile_Number_PE__c  = '0801112233';    
        insert testAccount;
        
        //Create Contact
        cont = new Contact();
        cont.FirstName='AccountPlan';
        cont.LastName='Step5';
        cont.Position__c = 'Manager';
        cont.Accountid= testAccount.id;
        insert cont;
        
        //Create Account Plan
        Company = new AcctPlanCompanyProfile__c();
        Company.Account__c=testAccount.id;
        //Company.Name='AccountPlan Step5';
        insert Company;
        
        Wallet = new AcctPlanWallet__c();
        Wallet.AcctPlanCompanyProfile__c = Company.id;
        insert Wallet;
        
        WalletDomain = new AcctPlanWalletByDomain__c();
        WalletDomain.AcctPlanWallet__c = Wallet.id;
        WalletDomain.WalletDomain__c = 1;
        WalletDomain.Priority__c ='High';
        WalletDomain.SubDomain__c ='Liquidity Management';
        WalletDomain.TypeOfNI__c = 'NIIC';
        insert WalletDomain;
        
        WalletDomaing2 = new AcctPlanWalletByDomain__c();
        WalletDomaing2.AcctPlanWallet__c = Wallet.id;
        WalletDomaing2.WalletDomain__c = 4;
        WalletDomaing2.Priority__c ='Medium';
        WalletDomaing2.SubDomain__c ='Hedging Normal business transaction : Trade transaction';
        WalletDomaing2.TypeOfNI__c = 'FX Fee';
        insert WalletDomaing2;
        
        AcctPlanActionPlan__c acctplan = new AcctPlanActionPlan__c();
        acctplan.AcctPlanWalletByDomain__c = WalletDomaing2.id;
        acctplan.Objective__c = 'Acquire New customers';
        acctplan.Status__c = 'Post Board';
        acctplan.WinningPropostion__c = 'Test Class';
        insert acctplan;
        
        AcctPlanNIProject__c nirecord = new AcctPlanNIProject__c();
        nirecord.AcctPlanActionPlanID__c= acctplan.id;
        nirecord.PropsProductOrServices__c = 'OD';
        nirecord.ExpectedIncremental__c = 10000;
        nirecord.TypeOfNI__c = 'NIIc';
        nirecord.NIRecuringType__c='Recurring';
        nirecord.ExpectedNimRate__c=10.00;
        nirecord.ExpectedIncrementalNIPerYear1Year__c=10000;
        nirecord.ExpectedIncrementalNIPerYear2Year__c=10000;
        nirecord.NIStartMonth__c = 'Jan';
        nirecord.NIStartYear__c= '2016';
        nirecord.DealProbability__c= '25%';
        insert nirecord;
        
        AccountPlanNIProjectionsSummary();
       }

       static void AccountPlanActionPlan(){
       

            
        PageReference pageRef = Page.AccountPlanActionPlan;
        //pageRef.getParameters().put('GroupID', String.valueOf(GroupID));
        pageRef.getParameters().put('CompanyID', String.valueOf(Company.id));
        //pageRef.getParameters().put('WalletID', String.valueOf(WalletID));
        Test.setCurrentPage(pageRef);
        

        AccountPlanActionPlanController AcctPlanCntrl= new AccountPlanActionPlanController();
        AcctPlanCntrl.actionPlan();
        AcctPlanCntrl.getAccountName();
        System.assertEquals(AcctPlanCntrl.AccountName, 'Test AccountPlan Step5');
        
        Integer conSize=AcctPlanCntrl.getCont().size();
        System.assertEquals(conSize, 1);
        //System.assertEquals(AcctPlanCntrl.cont.Position__c , 'Manager');
        List<AcctPlanWalletByDomain__c>  actiondmList = AcctPlanCntrl.actiondomainList;
        System.assertEquals(actiondmList.size(), 1);
        /*System.assertEquals(actiondmList.WalletDomain__c, 1);
        System.assertEquals(actiondmList.Priority__c , 'High');
        System.assertEquals(actiondmList.SubDomain__c, 'Liquidity Management');
        System.assertEquals(actiondmList.TypeOfNI__c , 'NIIC');*/
        
        AcctPlanCntrl.selectedHigh = 'Medium';
        AcctPlanCntrl.selectPriority();
        List<AcctPlanWalletByDomain__c>  actiondmList2 = AcctPlanCntrl.actiondomainList;
        System.assertEquals(actiondmList2.size(), 1);
         
        AcctPlanCntrl.selectedHigh = 'All';
        AcctPlanCntrl.selectPriority();
        List<AcctPlanWalletByDomain__c>  actiondmList3 = AcctPlanCntrl.actiondomainList;
        System.assertEquals(actiondmList3.size(), 2);
        /*System.assertEquals(actiondmList2.WalletDomain__c, 4);
        System.assertEquals(actiondmList2.Priority__c , 'Medium');
        System.assertEquals(actiondmList2.SubDomain__c, 'Hedging Normal business transaction : Trade transaction');
        System.assertEquals(actiondmList2.TypeOfNI__c , 'FX Fee');*/
    

           
        }
        
        static void ActionPlanActivities(){
        
        PageReference pageRef = Page.ActionPlanActivitiesView;
        //pageRef.getParameters().put('GroupID', String.valueOf(GroupID));
        pageRef.getParameters().put('CompanyID', String.valueOf(Company.id));
        pageRef.getParameters().put('WalletDomainID', String.valueOf(WalletDomain.id));
        Test.setCurrentPage(pageRef);
        
 
        AccountPlanActionPlanController AcctPlanCntrl= new AccountPlanActionPlanController();
        AcctPlanCntrl.planSelection();
        Account_Plan_Completion__c completion = AcctPlanCntrl.Acctplancompletion;
        boolean isHasNI = AcctPlanCntrl.isHasNiProjection;
        integer i= AcctPlanCntrl.ZERO;
        /*System.assertEquals(AcctPlanCntrl.Domain , '1');
        System.assertEquals(AcctPlanCntrl.Sub , 'Liquidity Management');
        System.assertEquals(AcctPlanCntrl.Type , 'NIIC');
        System.assertEquals(AcctPlanCntrl.ActionPlanID , null);
        System.assertEquals(AcctPlanCntrl.Objective, null);
        System.assertEquals(AcctPlanCntrl.Status, null);
        System.assertEquals(AcctPlanCntrl.Winning , null);
        System.assertEquals(AcctPlanCntrl.actionactivityList.size(), 0);
        System.assertEquals(AcctPlanCntrl.NIProjectList.size(), 0);
        System.assertEquals(AcctPlanCntrl.ActivityID, null);*/
        
        AcctPlanCntrl.RequiredField();
        
        AcctPlanActionPlan__c acctplan = new AcctPlanActionPlan__c();
        acctplan.AcctPlanWalletByDomain__c = WalletDomaing2.id;
        acctplan.Objective__c = 'Acquire New customers';
        acctplan.Status__c = 'Post Board';
        acctplan.WinningPropostion__c = 'Test Class';
        insert acctplan;
        
        Task t1=new Task();
        insert t1;
        
        AcctPlanActivity__c activity = new AcctPlanActivity__c();
        activity.AccountPlanActionPlanID__c = acctplan.id;
        activity.Objective__c = 'Acquire New customers';
        activity.Status__c = 'Post Board';
        activity.Group__c = 'Group 1 Relationship';
        activity.Activities__c = 'Work on negative relationship';
        activity.Date__c = System.Today();
        activity.TaskId__c = t1.id;
        insert activity;
        
        AcctPlanStakeholder__c stake = new AcctPlanStakeholder__c();
        stake.AcctPlanActivity__c = activity.id;
        Id select1user = [select id from user limit 1].Id;
        stake.User__c = select1user ;
        insert stake;
        
        AcctPlanNIProject__c nirecord = new AcctPlanNIProject__c();
        nirecord.AcctPlanActionPlanID__c= acctplan.id;
        nirecord.PropsProductOrServices__c = 'OD';
        nirecord.ExpectedIncremental__c = 10000;
        nirecord.TypeOfNI__c = 'NIIc';
        nirecord.NIRecuringType__c='Recurring';
        nirecord.ExpectedNimRate__c=10.00;
        nirecord.ExpectedIncrementalNIPerYear1Year__c=10000;
        nirecord.ExpectedIncrementalNIPerYear2Year__c=10000;
        nirecord.NIStartMonth__c = 'Jan';
        nirecord.NIStartYear__c= '2016';
        nirecord.DealProbability__c= '25%';
        insert nirecord;
        
        PageReference pageRef2 = Page.ActionPlanActivitiesView;
        //pageRef.getParameters().put('GroupID', String.valueOf(GroupID));
        pageRef2.getParameters().put('CompanyID', String.valueOf(Company.id));
        pageRef2.getParameters().put('WalletDomainID', String.valueOf(WalletDomaing2.id));
        Test.setCurrentPage(pageRef2);
        
        AccountPlanActionPlanController AcctPlanCntrl2= new AccountPlanActionPlanController();
        AcctPlanCntrl2.planSelection();
        AcctPlanCntrl2.UpdateComprofile();
        /*System.assertEquals(AcctPlanCntrl2.Domain , '4');
        System.assertEquals(AcctPlanCntrl2.Sub , 'Hedging Normal business transaction : Trade transaction');
        System.assertEquals(AcctPlanCntrl2.Type , 'FX Fee');
        System.assertEquals(AcctPlanCntrl2.ActionPlanID , String.valueOf(acctplan.id));
        System.assertEquals(AcctPlanCntrl2.Objective, 'Acquire New customers');
        System.assertEquals(AcctPlanCntrl2.Status, 'Post Board');
        System.assertEquals(AcctPlanCntrl2.Winning , 'Test Class');
        System.assertEquals(AcctPlanCntrl2.actionactivityList.size(), 1);
        System.assertEquals(AcctPlanCntrl2.StakeHolderMap.size(), 1);
        System.assertEquals(AcctPlanCntrl2.NIProjectList.size(), 1);*/
        
        


        }
        
        public static void AccountPlanActivitiesSummary(){
        
        PageReference pageRef3 = Page.AccountPlanActivitiesSummary;
        //pageRef.getParameters().put('GroupID', String.valueOf(GroupID));
        pageRef3.getParameters().put('CompanyID', String.valueOf(Company.id));
        pageRef3.getParameters().put('WalletDomainID', String.valueOf(WalletDomaing2.id));
        Test.setCurrentPage(pageRef3);
        
        AccountPlanActionPlanController AcctPlanCntrl3= new AccountPlanActionPlanController();
        AcctPlanCntrl3.actSummary();
        
        
        
           
           
        }
        
        public static void AccountPlanNIProjectionsSummary(){
        
         PageReference pageRef4 = Page.AccountPlanNIProjectionsSummary;
        //pageRef.getParameters().put('GroupID', String.valueOf(GroupID));
        pageRef4.getParameters().put('CompanyID', String.valueOf(Company.id));
        pageRef4.getParameters().put('WalletDomainID', String.valueOf(WalletDomaing2.id));
        Test.setCurrentPage(pageRef4);
        
        AccountPlanActionPlanController AcctPlanCntrl4= new AccountPlanActionPlanController();
        AcctPlanCntrl4.NISummary();
           
           
        }
        
        
        public static testmethod void TestSummaryNorecord(){
        
        //Create Account
        Account  testAccount1 = new Account();
        testAccount1.Name='Test AccountPlan Step5' ;
        testAccount1.Phone ='050111222';
        testAccount1.Mobile_Number_PE__c  = '0801112233';     
        insert testAccount1;
        
        //Create Contact
        Contact cont1 = new Contact();
        cont1.FirstName='AccountPlan';
        cont1.LastName='Step5';
        cont1.Position__c = 'Manager';
        cont1.Accountid= testAccount1.id;
        insert cont1;
        
        //Create Account Plan
        Company1 = new AcctPlanCompanyProfile__c();
        Company1.Account__c=testAccount1.id;
        //Company1.Name='AccountPlan Step5';
        insert Company1;
        
         AcctPlanWallet__c Wallet1 = new AcctPlanWallet__c();
        Wallet1.AcctPlanCompanyProfile__c = Company1.id;
        insert Wallet1;
        
        AcctPlanWalletByDomain__c WalletDomain1 = new AcctPlanWalletByDomain__c();
        WalletDomain1.AcctPlanWallet__c = Wallet1.id;
        WalletDomain1.WalletDomain__c = 1;
        WalletDomain1.Priority__c ='High';
        WalletDomain1.SubDomain__c ='Liquidity Management';
        WalletDomain1.TypeOfNI__c = 'NIIC';
        insert WalletDomain1;
        
        // Test No records
        PageReference pageRef7 = Page.ActivitiesVisitCreation;
        pageRef7.getParameters().put('CompanyID', String.valueOf(Company1.id));
        Test.setCurrentPage(pageRef7);
        
        AccountPlanActionPlanController AcctPlanCntrl7= new AccountPlanActionPlanController();
        AcctPlanCntrl7.getBookActivityToVisit();
        
         AcctPlanCntrl7.newVisit();
         
         PageReference pageRef8 = Page.ActivitiesTaskCreation;
        pageRef8.getParameters().put('CompanyID', String.valueOf(Company1.id));
        Test.setCurrentPage(pageRef8);
        
        AccountPlanActionPlanController AcctPlanCntrl8= new AccountPlanActionPlanController();
        AcctPlanCntrl8.getBookActivityToTask();
        
        AcctPlanCntrl8.newTask();
        
        }
        
        
        public static testmethod void ActivitiesVisitCreation(){
        
        
        
        //Create Account
        Account  testAccount1 = new Account();
        testAccount1.Name='Test AccountPlan Step5' ;
        testAccount1.Phone ='050111222';
        testAccount1.Mobile_Number_PE__c  = '0801112233';     
        insert testAccount1;
        
        //Create Contact
        Contact cont1 = new Contact();
        cont1.FirstName='AccountPlan';
        cont1.LastName='Step5';
        cont1.Position__c = 'Manager';
        cont1.Accountid= testAccount1.id;
        insert cont1;
        
        //Create Account Plan
        Company1 = new AcctPlanCompanyProfile__c();
        Company1.Account__c=testAccount1.id;
        //Company1.Name='AccountPlan Step5';
        insert Company1;
        
        AcctPlanWallet__c Wallet1 = new AcctPlanWallet__c();
        Wallet1.AcctPlanCompanyProfile__c = Company1.id;
        insert Wallet1;
        
        AcctPlanWalletByDomain__c WalletDomain1 = new AcctPlanWalletByDomain__c();
        WalletDomain1.AcctPlanWallet__c = Wallet1.id;
        WalletDomain1.WalletDomain__c = 1;
        WalletDomain1.Priority__c ='High';
        WalletDomain1.SubDomain__c ='Liquidity Management';
        WalletDomain1.TypeOfNI__c = 'NIIC';
        insert WalletDomain1;
        
        AcctPlanWalletByDomain__c WalletDomain2 = new AcctPlanWalletByDomain__c();
        WalletDomain2.AcctPlanWallet__c = Wallet1.id;
        WalletDomain2.WalletDomain__c = 2;
        WalletDomain2.Priority__c ='Medium';
        WalletDomain2.SubDomain__c ='Liquidity Management';
        WalletDomain2.TypeOfNI__c = 'NIIC';
        insert WalletDomain2;
        
        AcctPlanWalletByDomain__c WalletDomain3 = new AcctPlanWalletByDomain__c();
        WalletDomain3.AcctPlanWallet__c = Wallet1.id;
        WalletDomain3.WalletDomain__c = 3;
        WalletDomain3.Priority__c ='High';
        WalletDomain3.SubDomain__c ='Liquidity Management';
        WalletDomain3.TypeOfNI__c = 'NIID';
        insert WalletDomain3;
        
        AcctPlanWalletByDomain__c WalletDomain4 = new AcctPlanWalletByDomain__c();
        WalletDomain4.AcctPlanWallet__c = Wallet1.id;
        WalletDomain4.WalletDomain__c = 4;
        WalletDomain4.Priority__c ='High';
        WalletDomain4.SubDomain__c ='Liquidity Management';
        WalletDomain4.TypeOfNI__c = 'NIIC';
        insert WalletDomain4;
        
        AcctPlanActionPlan__c acctplan1 = new AcctPlanActionPlan__c();
        acctplan1.AcctPlanWalletByDomain__c = WalletDomain1.id;
        acctplan1.Objective__c = 'Acquire New customers';
        acctplan1.Status__c = 'Post Board';
        acctplan1.WinningPropostion__c = 'Test Class';
        insert acctplan1;
        
        AcctPlanActionPlan__c acctplan2 = new AcctPlanActionPlan__c();
        acctplan2.AcctPlanWalletByDomain__c = WalletDomain2.id;
        acctplan2.Objective__c = 'Acquire New customers';
        acctplan2.Status__c = 'Post Board';
        acctplan2.WinningPropostion__c = 'Test Class';
        insert acctplan2;
        
        AcctPlanActionPlan__c acctplan3 = new AcctPlanActionPlan__c();
        acctplan3.AcctPlanWalletByDomain__c = WalletDomain3.id;
        acctplan3.Objective__c = 'Acquire New customers';
        acctplan3.Status__c = 'Post Board';
        acctplan3.WinningPropostion__c = 'Test Class';
        insert acctplan3;
        
        AcctPlanActionPlan__c acctplan4 = new AcctPlanActionPlan__c();
        acctplan4.AcctPlanWalletByDomain__c = WalletDomain4.id;
        acctplan4.Objective__c = 'Acquire New customers';
        acctplan4.Status__c = 'Post Board';
        acctplan4.WinningPropostion__c = 'Test Class';
        insert acctplan4;
  
        
        AcctPlanActivity__c activity1 = new AcctPlanActivity__c();
        activity1.AccountPlanActionPlanID__c = acctplan1.id;
        activity1.Account__c= testAccount1.id;
        activity1.Objective__c = 'Acquire New customers';
        activity1.Status__c = 'Post Board';
        activity1.Group__c = 'Group 1 Relationship';
        activity1.Activities__c = 'Work on negative relationship';
        activity1.Date__c = System.Today();
        activity1.CustomerCounterparties__c = cont1.id;
        insert activity1;
        
        AcctPlanActivity__c activity2 = new AcctPlanActivity__c();
        activity2.AccountPlanActionPlanID__c = acctplan1.id;
        activity2.Account__c= testAccount1.id;
        activity2.Objective__c = 'Acquire New customers';
        activity2.Status__c = 'Post Board';
        activity2.Group__c = 'Group 1 Relationship';
        activity2.Activities__c = 'Work on negative relationship';
        activity2.Date__c = System.Today();
        insert activity2;
        
        AcctPlanActivity__c activity3 = new AcctPlanActivity__c();
        activity3.AccountPlanActionPlanID__c = acctplan2.id;
        activity3.Account__c= testAccount1.id;
        activity3.Objective__c = 'Acquire New customers';
        activity3.Status__c = 'Post Board';
        activity3.Group__c = 'Group 1 Relationship';
        activity3.Activities__c = 'Work on negative relationship';
        activity3.Date__c = System.Today();
        activity3.CustomerCounterparties__c = cont1.id;
        insert activity3;
        
        AcctPlanActivity__c activity4 = new AcctPlanActivity__c();
        activity4.AccountPlanActionPlanID__c = acctplan2.id;
        activity4.Account__c= testAccount1.id;
        activity4.Objective__c = 'Acquire New customers';
        activity4.Status__c = 'Post Board';
        activity4.Group__c = 'Group 1 Relationship';
        activity4.Activities__c = 'Work on negative relationship';
        activity4.Date__c = System.Today();
        insert activity4;
        
        AcctPlanActivity__c activity5 = new AcctPlanActivity__c();
        activity5.AccountPlanActionPlanID__c = acctplan3.id;
        activity5.Account__c= testAccount1.id;
        activity5.Objective__c = 'Acquire New customers';
        activity5.Status__c = 'Post Board';
        activity5.Group__c = 'Group 1 Relationship';
        activity5.Activities__c = 'Work on negative relationship';
        activity5.Date__c = System.Today();
        activity5.CustomerCounterparties__c = cont1.id;
        insert activity5;
        
        AcctPlanActivity__c activity6 = new AcctPlanActivity__c();
        activity6.AccountPlanActionPlanID__c = acctplan3.id;
        activity6.Account__c= testAccount1.id;
        activity6.Objective__c = 'Acquire New customers';
        activity6.Status__c = 'Post Board';
        activity6.Group__c = 'Group 1 Relationship';
        activity6.Activities__c = 'Work on negative relationship';
        activity6.Date__c = System.Today();
        insert activity6;
        
        AcctPlanActivity__c activity7 = new AcctPlanActivity__c();
        activity7.AccountPlanActionPlanID__c = acctplan4.id;
        activity7.Account__c= testAccount1.id;
        activity7.Objective__c = 'Acquire New customers';
        activity7.Status__c = 'Post Board';
        activity7.Group__c = 'Group 1 Relationship';
        activity7.Activities__c = 'Work on negative relationship';
        activity7.Date__c = System.Today();
        activity7.CustomerCounterparties__c = cont1.id;
        insert activity7;
        
        AcctPlanActivity__c activity8 = new AcctPlanActivity__c();
        activity8.AccountPlanActionPlanID__c = acctplan4.id;
        activity8.Account__c= testAccount1.id;
        activity8.Objective__c = 'Acquire New customers';
        activity8.Status__c = 'Post Board';
        activity8.Group__c = 'Group 1 Relationship';
        activity8.Activities__c = 'Work on negative relationship';
        activity8.Date__c = System.Today();
        insert activity8;
        
        PageReference pageRef5 = Page.ActivitiesVisitCreation;
        pageRef5.getParameters().put('CompanyID', String.valueOf(Company1.id));
        Test.setCurrentPage(pageRef5);
        
       
        
        AccountPlanActionPlanController AcctPlanCntrl5= new AccountPlanActionPlanController();
        AcctPlanCntrl5.getBookActivityToVisit();
        
         AcctPlanCntrl5.newVisit();
        
         List<AcctPlanActivity__c> ActVisit= AcctPlanCntrl5.bookActList;
         for(AcctPlanActivity__c book: ActVisit){
                book.isBook__c = true;
        }
        AcctPlanCntrl5.newVisit();
        
        

        ActivitiesTaskCreation();
           
        }
        
        public static void ActivitiesTaskCreation(){
        
        PageReference pageRef6 = Page.ActivitiesTaskCreation;
        pageRef6.getParameters().put('CompanyID', String.valueOf(Company1.id));
        Test.setCurrentPage(pageRef6);
        
        AccountPlanActionPlanController AcctPlanCntrl6= new AccountPlanActionPlanController();
        AcctPlanCntrl6.getBookActivityToTask();
        
        AcctPlanCntrl6.newTask();
        
        List<AcctPlanActivity__c> ActTask= AcctPlanCntrl6.bookActList;
         for(AcctPlanActivity__c book: ActTask){
                book.isBook__c = true;
        }
        AcctPlanCntrl6.newTask();
     
        }
        

        
 }