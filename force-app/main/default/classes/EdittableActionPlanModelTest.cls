@IsTest
public class EdittableActionPlanModelTest{
    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        TestUtils.createIdType();
        TestUtils.createTriggerMsg();
        TestUtils.createObjUserPermission();
        AccountPlanTestUtilities.AccountPlanStatusCode();
    } 
       public static testmethod void EdittableActionPlan(){
           
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
        AcctPlanCompanyProfile__c Company1 = new AcctPlanCompanyProfile__c();
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
        
        
        AcctPlanActionPlan__c acctplan1 = new AcctPlanActionPlan__c();
        acctplan1.AcctPlanWalletByDomain__c = WalletDomain1.id;
        acctplan1.Objective__c = 'Acquire New customers';
        acctplan1.Status__c = 'Post Board';
        acctplan1.WinningPropostion__c = 'Test Class';
        insert acctplan1;   
        
        /*AcctPlanActivity__c activity1 = new AcctPlanActivity__c();
        activity1.AccountPlanActionPlanID__c = acctplan1.id;
        activity1.Account__c= testAccount1.id;
        activity1.Objective__c = 'Acquire New customers';
        activity1.Status__c = 'Post Board';
        activity1.Group__c = 'Group 1 Relationship';
        activity1.Activities__c = 'Work on negative relationship';
        activity1.Date__c = System.Today();
        activity1.CustomerCounterparties__c = cont1.id;
        insert activity1;
        
        Id select1user = [select id from user limit 1].Id;
        AcctPlanStakeholder__c stake1 = new AcctPlanStakeholder__c(AcctPlanActivity__c=activity1.id, User__c=select1user); 
        insert Stake1;*/
        
        PageReference pageRef1 = Page.EdittableActionPlan;
        pageRef1.getParameters().put('CompanyID', String.valueOf(Company1.id));
        pageRef1.getParameters().put('ActionPlanId', String.valueOf(acctplan1.id));
        pageRef1.getParameters().put('AccountId', String.valueOf(testAccount1.id));
        pageRef1.getParameters().put('Objective', 'Acquire New customers');
        pageRef1.getParameters().put('Status', 'Post Board');
        Test.setCurrentPage(pageRef1);
        
        AcctPlanActivity__c act = new AcctPlanActivity__c(AccountPlanActionPlanID__c=acctplan1.id,CheckOther__c='Y',Other__c=null);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(act);
        EdittableActionPlanModel ActCntrl1= new EdittableActionPlanModel(sc1);
        Boolean isSelect = ActCntrl1.isSelected;
        ActCntrl1.initChildRecord();
        List<AcctPlanActivity__c > act1 = ActCntrl1.getChildren();
        for(AcctPlanActivity__c act11: act1 ){
        act11.Group__c='Group 1 Relationship';
        act11.CheckOther__c='Y';
        act11.Other__c=null;
        }
        ActCntrl1.softsave();
        ActCntrl1.dosave();
        
        }
        
        public static testmethod void EdittableValidate1(){
           
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
        AcctPlanCompanyProfile__c Company1 = new AcctPlanCompanyProfile__c();
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
        
        
        AcctPlanActionPlan__c acctplan1 = new AcctPlanActionPlan__c();
        acctplan1.AcctPlanWalletByDomain__c = WalletDomain1.id;
        acctplan1.Objective__c = 'Acquire New customers';
        acctplan1.Status__c = 'Post Board';
        acctplan1.WinningPropostion__c = 'Test Class';
        insert acctplan1;   
        
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
        
        Id select1user = [select id from user limit 1].Id;
        AcctPlanStakeholder__c stake1 = new AcctPlanStakeholder__c(AcctPlanActivity__c=activity1.id, User__c=select1user); 
        insert Stake1;
        
        PageReference pageRef1 = Page.EdittableActionPlan;
        pageRef1.getParameters().put('CompanyID', String.valueOf(Company1.id));
        pageRef1.getParameters().put('ActionPlanId', String.valueOf(acctplan1.id));
        pageRef1.getParameters().put('AccountId', String.valueOf(testAccount1.id));
        pageRef1.getParameters().put('Objective', 'Acquire New customers');
        pageRef1.getParameters().put('Status', 'Post Board');
        Test.setCurrentPage(pageRef1);
        
        //AcctPlanActivity__c act = new AcctPlanActivity__c(AccountPlanActionPlanID__c=acctplan1.id);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(activity1);
        EdittableActionPlanModel ActCntrl1= new EdittableActionPlanModel(sc1);
        Boolean isSelect = ActCntrl1.isSelected;
        List<AcctPlanActivity__c > act1 = ActCntrl1.getChildren();
        for(AcctPlanActivity__c act11: act1 ){
        act11.Group__c='Group 1 Relationship';
        }
        ActCntrl1.softsave();
        ActCntrl1.dosave();
        
        }
}