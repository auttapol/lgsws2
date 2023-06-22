@IsTest
public class TaskControllerTest{
static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        TestUtils.createIdType();
        TestUtils.createTriggerMsg();
        TestUtils.createObjUserPermission();
    } 
       public static testmethod void TaskCreation(){
           //Create Account
        Account testAccount = new Account();
        testAccount.Name='Test AccountPlan Step5' ;
        testAccount.Phone ='3453245';
        insert testAccount;

        //Create Account Plan
        AcctPlanCompanyProfile__c Company = new AcctPlanCompanyProfile__c();
        Company.Account__c=testAccount.id;
        //Company.Name='AccountPlan Step5';
        insert Company;
        
        AcctPlanWallet__c Wallet = new AcctPlanWallet__c();
        Wallet.AcctPlanCompanyProfile__c = Company.id;
        insert Wallet;
        
        AcctPlanWalletByDomain__c WalletDomain = new AcctPlanWalletByDomain__c();
        WalletDomain.AcctPlanWallet__c = Wallet.id;
        WalletDomain.WalletDomain__c = 1;
        WalletDomain.Priority__c ='High';
        WalletDomain.SubDomain__c ='Liquidity Management';
        WalletDomain.TypeOfNI__c = 'NIIC';
        insert WalletDomain;
        
        
        AcctPlanActionPlan__c acctplan = new AcctPlanActionPlan__c();
        acctplan.AcctPlanWalletByDomain__c = WalletDomain.id;
        acctplan.Objective__c = 'Acquire New customers';
        acctplan.Status__c = 'Post Board';
        acctplan.WinningPropostion__c = 'Test Class';
        insert acctplan;
        
        AcctPlanActivity__c activity = new AcctPlanActivity__c();
        activity.AccountPlanActionPlanID__c = acctplan.id;
        activity.Objective__c = 'Acquire New customers';
        activity.Status__c = 'Post Board';
        activity.Group__c = 'Group 1 Relationship';
        activity.Activities__c = 'Work on negative relationship';
        activity.Date__c = System.Today();
        insert activity;
        
        PageReference pageRef1 = Page.TaskCreation;
        pageRef1.getParameters().put('AccountID', String.valueOf(testAccount.id));
        pageRef1.getParameters().put('ActivityID', String.valueOf(activity.id));
        Test.setCurrentPage(pageRef1);
        
        Task t1 = new Task();
        ApexPages.StandardController sc = new ApexPages.StandardController(t1);
        TaskController TaskEx = new TaskController(sc);
        User us = [SELECT ID,Segment__c FROM User WHERE ID=:UserInfo.getUserId() LIMIT 1];
        us.Segment__c=null;
        update us;
        TaskEx.reminderTimeStr = '00:00';
        TaskEx.modalsave();

        Task t2 = new Task();
        ApexPages.StandardController sc2 = new ApexPages.StandardController(t2);
        TaskController TaskEx1 = new TaskController(sc2);
        TaskEx1.reminderTimeStr = '00:00';
        String sub=TaskEx1.Subject;
        String obt=TaskEx1.objType;
        String wht=TaskEx1.WhatID;
        TaskEx1.setObjectType('Call');
        String obt1=TaskEx1.getObjectType();
        TaskEx1.setWhatID('A1234567');
        String wht1=TaskEx1.getWhatID();
        List<SelectOption> gs = TaskEx1.getSubjects();
        List<SelectOption> gt = TaskEx1.getTimes();
        TaskEx1.save();
        
        
        Task t4 = new Task();
        ApexPages.StandardController sc4 = new ApexPages.StandardController(t4);
        TaskController TaskEx4 = new TaskController(sc4);
        us.Segment__c='SE';
        update us;
        TaskEx4.reminderTimeStr = '00:00';
        TaskEx4.modalsave();
        
        Task t3 = new Task();
        ApexPages.StandardController sc3 = new ApexPages.StandardController(t3);
        TaskController TaskEx3 = new TaskController(sc3);
        us.Segment__c='MB';
        update us;
        TaskEx3.reminderTimeStr = '00:00';
        TaskEx3.modalsave();
        
        }
}