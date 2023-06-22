@isTest
public class VisitControllerTest {
 static {
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
        TestUtils.createObjUserPermission();
        TestInit.createCustomSettingTriggerMsg();     
        Sub_Purpose_Mapping__c subpurpose = new Sub_Purpose_Mapping__c();
      
        subpurpose.Main_purpose__c = 'CB.';
        subpurpose.Sub_Purpose__c = 'Selling';
        subpurpose.Name = 'Subpurpose1';
     insert subpurpose;
    }
    
public static RecordType CommercialLeadRecordType {get{
        if(CommercialLeadRecordType ==null){
           CommercialLeadRecordType = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Commercial Lead' 
                                 AND sObjectType='Lead' LIMIT 1];
        }
        return CommercialLeadRecordType;
    }set;}
    
   public static AcctPlanCompanyProfile__c Company;
   public static AcctPlanWallet__c Wallet;
public static AcctPlanWalletByDomain__c WalletDomain;
public static AcctPlanWalletByDomain__c WalletDomaing2;

   public static testmethod void InsertVisitPlan(){
           Account__c obj = new Account__c(
            Segment__c='BB',Role__c='',Name='Test1'
        );
           
           insert obj;
           
           User newUser = new User(FirstName='VisitFirst', LastName='VisitLast', 
                                    UserName='VisitplanCreate@tmbbank.com', 
                                    Email='VisitplanCreate@tmbbank.com', Alias='visit',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='visittmb',
                                    ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id
                                   , TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='V0001',Zone__c=
                                  '1001',Segment__c ='AA',Zone_Code__c ='1001');
           
           insert newUser;
       
        Call_Report__c report = new Call_Report__c();
           
        Account acct = new Account ();
           //Acct.Office_Number_Temp__c = '0876213284';
            //Acct.Mobile_Number_Temp__c = '05689145';
            Acct.Rating = 'Hot';
            Acct.IsDisqualified__c = false;
            Acct.Customer_Type__c = 'Individual';
            Acct.First_name_PE__c = 'Visit';
            Acct.First_Name_ENG_PE__c = 'Visit';
            Acct.Last_name_PE__c = 'TestMock';
            Acct.Last_Name_PE_Eng__c  = 'TestMock';
            Acct.Name = 'Test Account';
            Acct.Segment_crm__c = '3';
            Acct.Phone ='345345';
            Acct.OwnerId =newUser.id;
            Acct.Phone ='050111222';
            Acct.Mobile_Number_PE__c  = '0801112233';
        insert acct;
           
        report.Customer_name__c = acct.id;
        report.Status__c ='2 - Completed';
        report.Categories__c = 'Initiavtives';
        report.Main_purpose__c ='CB';
        report.Date_of_Visit__c  = System.today()+1;
        report.Complete_Date__c = System.today();
        //report.Actual_Visit_Date__c =System.today()+2;
        report.Outcome__c ='Win Deal';
        report.OwnerId = Userinfo.getUserId();
          
  
           PageReference visitplan = Page.VisitPlanCreation;
           
           RecordType rts = [SELECT ID, name,SObjectType FROM RecordType 
                                     WHERE SObjectType = 'Call_Report__c'
                                     AND Name ='SE Visit Plan / Report'
                                      LIMIT 1];
           
        //Create Account Plan
        Company = new AcctPlanCompanyProfile__c();
        Company.Account__c=acct.id;
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

         AcctPlanActivity__c  activity = new AcctPlanActivity__c ();
         activity.Account__c = acct.id;
         activity.AccountPlanActionPlanID__c = acctplan.id;
         activity.Status__c = 'pre-board';
         insert activity;
       
         AcctPlanStakeholder__c stakeholder = new AcctPlanStakeholder__c();
         stakeholder.User__c = TestUtils.createUsers(1, 'TMB', 'stakeholder', 'tmbstakehold@tmbbank.com', true).get(0).id;
         stakeholder.AcctPlanActivity__c = activity.id;
         insert stakeholder;
         visitplan.getParameters().put('recordType',rts.id);
         visitplan.getParameters().put('AccountID',acct.id);
         visitplan.getParameters().put('ActivityID',activity.id);
         visitplan.getParameters().put('sObjectID',acct.id);
         visitplan.getParameters().put('returl',acct.id);
        Test.setCurrentPage(visitplan);
        Test.startTest();
           
        ApexPages.StandardController stdController = new ApexPages.StandardController(report);
        
        VisitPlanController controller = new VisitPlanController(stdController);
         //controller.save();
         controller.Callreport = report;
         boolean isclosed = controller.isClosed;
        
       Visit_Plan_Invitee__c invitee = new Visit_Plan_Invitee__c();
        List<UseR> userlist = TestUtils.createUsers(2, 'TMB', 'Counterparty', 'tmbcounter@tmbbank.com', false);
        user tmbcounter1 = userlist.get(0);
        user tmbcounter2 = userlist.get(1);
        tmbcounter1.Employee_ID__c ='70123';
        tmbcounter2.Employee_ID__c ='70124';
        insert userlist;
        invitee.TMB_Person__c = userlist.get(0).id;
        invitee.SEQ__c = 0;
       
        Visit_Plan_Invitee__c invitee2 = new Visit_Plan_Invitee__c();
        invitee2.TMB_Person__c = userlist.get(1).id;
        invitee2.SEQ__c = 1;
        
        controller.addTMBPerson();
        controller.VisitPlanInviteeList.add(invitee);
        controller.VisitPlanInviteeList.add(invitee2);
        controller.removeIndex = 0;
        controller.removeTMBPerson();
        controller.Inviteeremovelist = new List<Visit_Plan_Invitee__c>();
         controller.modalsave();
         controller.modalsaveMobile();
         controller.redirectToMobile();
         controller.viewPage();
         controller.cancel();
       
       controller.callreport.Start_Visit_Time__c ='11:00';
        controller.callreport.End_Visit_Time__c =null;
        controller.modalsave();

        
        controller.callreport.Start_Visit_Time__c =null;
        controller.callreport.End_Visit_Time__c ='11:00';
        controller.modalsave();
        
        
        controller.callreport.Start_Visit_Time__c ='11:00';
        controller.callreport.End_Visit_Time__c ='11:00';
        controller.modalsave();
       
       Call_Report__c reportMobile = new Call_Report__c();
         reportMobile.Customer_name__c = acct.id;
        reportMobile.Status__c ='1 - Open';
        reportMobile.Categories__c = 'Initiavtives';
        reportMobile.Main_purpose__c ='CB.';
        reportMobile.Sub_Purpose__c = 'Selling';
        reportMobile.Date_of_Visit__c  = System.today()+1;
        reportMobile.Complete_Date__c = System.today();
        reportMobile.OwnerId = Userinfo.getUserId(); 
       
        ApexPages.StandardController stdController2 = new ApexPages.StandardController(reportMobile);
        
        VisitPlanController controller2 = new VisitPlanController(stdController2);
       controller2.modalsaveMobile();
        Test.stopTest();
    }
    
        
           public static testmethod void InsertVisitPlanForLead(){
          
           User newUser = new User(FirstName='VisitFirst', LastName='VisitLast', 
                                    UserName='VisitplanCreate@tmbbank.com', 
                                    Email='VisitplanCreate@tmbbank.com', Alias='visit',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='visittmb',
                                    ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id
                                   , TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='V0001',Zone__c=
                                  '1001',Segment__c ='AA',Zone_Code__c ='1001');
           
           insert newUser;
       
        Call_Report__c report = new Call_Report__c();
           
        Lead leadRec = new lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'Passport ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Individual';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.RecordTypeId = CommercialLeadRecordType.id;
        leadRec.Interest_result__c = 'Yes';
        leadRec.OwnerID = newUser.id;
       insert leadRec;
        report.Customer_name__c = leadRec.id;
        report.Status__c ='2 - Completed';
        report.Categories__c = 'Initiavtives';
        report.Main_purpose__c ='CB.';
        report.Sub_Purpose__c = 'Selling';
        report.Date_of_Visit__c  = System.today()+1;
        report.Complete_Date__c = System.today();
        //report.Actual_Visit_Date__c =System.today()+2;
        report.Outcome__c ='Win Deal';
        report.OwnerId =newUser.id;
          
  
           PageReference visitplan = Page.VisitPlanCreation;
           
           RecordType rts = [SELECT ID, name,SObjectType FROM RecordType 
                                     WHERE SObjectType = 'Call_Report__c'
                                     AND Name ='SE Visit Plan / Report'
                                      LIMIT 1];
   
         visitplan.getParameters().put('recordType',rts.id);
         visitplan.getParameters().put('ID',leadRec.id);
         visitplan.getParameters().put('sObjectID',leadRec.id);
         visitplan.getParameters().put('returl',leadRec.id);
        Test.setCurrentPage(visitplan);
        Test.startTest();
           
        ApexPages.StandardController stdController = new ApexPages.StandardController(report);
        
        VisitPlanController controller = new VisitPlanController(stdController);
         //controller.save();
         controller.Callreport = report;
         boolean isclosed = controller.isClosed;
        
       Visit_Plan_Invitee__c invitee = new Visit_Plan_Invitee__c();
        List<UseR> userlist = TestUtils.createUsers(2, 'TMB', 'Counterparty', 'tmbcounter@tmbbank.com', false);
        user tmbcounter1 = userlist.get(0);
        user tmbcounter2 = userlist.get(1);
        tmbcounter1.Employee_ID__c ='70123';
        tmbcounter2.Employee_ID__c ='70124';
        insert userlist;
        invitee.TMB_Person__c = userlist.get(0).id;
        invitee.SEQ__c = 0;
       
        Visit_Plan_Invitee__c invitee2 = new Visit_Plan_Invitee__c();
        invitee2.TMB_Person__c = userlist.get(1).id;
        invitee2.SEQ__c = 1;
        
        controller.addTMBPerson();
        controller.VisitPlanInviteeList.add(invitee);
        controller.VisitPlanInviteeList.add(invitee2);
        controller.removeIndex = 0;
        controller.removeTMBPerson();
        controller.Inviteeremovelist = new List<Visit_Plan_Invitee__c>();
         controller.modalsave();
         controller.modalsaveMobile();
         controller.redirectToMobile();
         controller.viewPage();
         controller.cancel();
       
       controller.callreport.Start_Visit_Time__c ='11:00';
        controller.callreport.End_Visit_Time__c =null;
        controller.modalsave();
        
        controller.callreport.Start_Visit_Time__c =null;
        controller.callreport.End_Visit_Time__c ='11:00';
        controller.modalsave();
        
        
        controller.callreport.Start_Visit_Time__c ='11:00';
        controller.callreport.End_Visit_Time__c ='11:00';
        controller.modalsave();
       
       Call_Report__c reportMobile = new Call_Report__c();
         reportMobile.Lead__c = leadRec.id;
        reportMobile.Status__c ='1 - Open';
        reportMobile.Categories__c = 'Initiavtives';
        reportMobile.Main_purpose__c ='CB.';
        reportMobile.Sub_Purpose__c ='Selling';
        reportMobile.Date_of_Visit__c  = System.today()+1;
        reportMobile.Complete_Date__c = System.today();
        reportMobile.OwnerId =  newUser.id;
       
        ApexPages.StandardController stdController2 = new ApexPages.StandardController(reportMobile);
        
        VisitPlanController controller2 = new VisitPlanController(stdController2);
       controller2.modalsaveMobile();
        Test.stopTest();
    }

    
    public static testmethod void UpdateVisitPlan(){
        
        User newUser = new User(FirstName='VisitFirst', LastName='VisitLast', 
                                    UserName='VisitplanUpdate@tmbbank.com', 
                                    Email='VisitplanUpdate@tmbbank.com', Alias='visit',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='visittmb',
                                    ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id
                                   , TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='V0001',Zone__c=
                                  '1001',Segment__c ='AA',Zone_Code__c ='1001');
           
           insert newUser;
       
      Test.startTest();
           
            Account acct = new Account ();
           //Acct.Office_Number_Temp__c = '0876213284';
            //Acct.Mobile_Number_Temp__c = '05689145';
            Acct.Rating = 'Hot';
            Acct.IsDisqualified__c = false;
           Acct.Customer_Type__c = 'Individual';
            Acct.First_Name_PE__c = 'Visit';
            Acct.Last_Name_PE__c = 'TestMock';
            Acct.Name = 'Test Account';
            Acct.Segment_crm__c = '3';
           acct.Phone ='345345';
        acct.OwnerId =newUser.id;
           Acct.Phone ='050111222';
            Acct.Mobile_Number_PE__c  = '0801112233';
        insert acct;
        
        
         Call_Report__c visitplan = new Call_Report__c();  
        visitplan.Customer_name__c = acct.id;
        visitplan.Status__c ='1 - Open';
        visitplan.Categories__c = 'Initiavtives';
        visitplan.Main_purpose__c ='BB.';
        visitplan.Date_of_Visit__c  = System.today()+1;
        visitplan.OwnerId = Userinfo.getUserId();
        visitplan.sub_purpose__c ='Selling';
         insert visitplan;
        
        Visit_Plan_Invitee__c invitee = new Visit_Plan_Invitee__c();
        List<UseR> userlist = TestUtils.createUsers(3, 'TMB', 'Counterparty', 'tmbcounter@tmbbank.com', true);
        invitee.TMB_Person__c = userlist.get(0).id;
        invitee.SEQ__c = 0;
        invitee.Visit_Plan_Report__c = visitplan.id;
        insert invitee;
        Visit_Plan_Invitee__c invitee2 = new Visit_Plan_Invitee__c();
        invitee2.TMB_Person__c = userlist.get(1).id;
        invitee2.SEQ__c = 0;
        invitee2.Visit_Plan_Report__c = visitplan.id;
        
        insert invitee2;
        
        //Account Plan

        Company = new AcctPlanCompanyProfile__c();
        Company.Account__c=acct.id;
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

         AcctPlanActivity__c  activity = new AcctPlanActivity__c ();
         activity.Account__c = acct.id; 
         activity.Status__c = 'pre-board';
         activity.Visit_Plan_Report__c = visitplan.id;
         activity.AccountPlanActionPlanID__c = acctplan.id;
         insert activity;
        
        
        
        PageReference visitplanpage = Page.VisitPlanCreation;
         visitplanpage.getParameters().put('id',visitplan.id);
         visitplanpage.getParameters().put('CallReportID',visitplan.id);
         visitplanpage.getParameters().put('AccountID',acct.id);
          visitplanpage.getParameters().put('ActivityID',activity.id);
        Test.setCurrentPage(visitplanpage);
        
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(visitplan);
        VisitPlanController controller = new VisitPlanController(stdController);
        controller.subpurposeSelectedList.add(new SelectOption('Sell Product','Sell Product'));
        controller.Removeindex = 0;
        controller.callreport.Start_Visit_Time__c ='11:00';
        controller.callreport.End_Visit_Time__c ='12:00';
        
        Visit_Plan_Invitee__c invitee3 = new Visit_Plan_Invitee__c();
        invitee3.TMB_Person__c = userlist.get(2).id;
        invitee3.SEQ__c = 2;
        controller.VisitPlanInviteeList.add(invitee3);
        controller.AcctPlanAct = new List<AcctPlanActivity__c>();
        controller.AcctPlanAct.add(activity);
        controller.modalsave();
        controller.modalsaveMobile();
        
        
        controller.callreport.Start_Visit_Time__c ='11:00';
        controller.callreport.End_Visit_Time__c =null;
        controller.modalsaveMobile();

        
        controller.callreport.Start_Visit_Time__c =null;
        controller.callreport.End_Visit_Time__c ='11:00';
        controller.modalsaveMobile();
        
        
        controller.callreport.Start_Visit_Time__c ='11:00';
        controller.callreport.End_Visit_Time__c ='11:00';
        controller.modalsaveMobile();
        
        controller.ActivityID =null;
        Opportunity opp = new Opportunity();
                opp.OwnerId = newUser.id;
                opp.Expected_submit_date__c = System.today()+1;
                opp.CloseDate = System.today()+1;
                opp.StageName = 'Analysis';
                opp.Name = 'TestVisit';
                opp.AccountId = acct.id;
                opp.Trigger_flag__c = true;
          //  insert opp;
        controller.OppID= opp.id;
        controller.opp = opp;
  //      controller.modalsave();
//        controller.modalsaveMobile();
        
        
        Test.stopTest();
        
    }
    
    public static testmethod void UpdateVisitPlanForLead(){
        
        User newUser = new User(FirstName='VisitFirst', LastName='VisitLast', 
                                    UserName='VisitplanUpdate@tmbbank.com', 
                                    Email='VisitplanUpdate@tmbbank.com', Alias='visit',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='visittmb',
                                    ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id
                                   , TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='V0001',Zone__c=
                                  '1001',Segment__c ='AA',Zone_Code__c ='1001');
           
           insert newUser;
       
      Test.startTest();
           
           Lead leadRec = new lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'Passport ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Individual';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.RecordTypeId = CommercialLeadRecordType.id;
        leadRec.Interest_result__c = 'Yes';
        leadRec.OwnerID = newUser.id;
       insert leadRec;
        
        
         Call_Report__c visitplan = new Call_Report__c();  
        visitplan.lead__c = leadRec.id;
        visitplan.Status__c ='1 - Open';
        visitplan.Categories__c = 'Initiavtives';
        visitplan.Main_purpose__c ='BB.';
        visitplan.Date_of_Visit__c  = System.today()+1;
        visitplan.OwnerId = Userinfo.getUserId();
        visitplan.sub_purpose__c ='Selling';
         insert visitplan;
        
        Visit_Plan_Invitee__c invitee = new Visit_Plan_Invitee__c();
        List<UseR> userlist = TestUtils.createUsers(3, 'TMB', 'Counterparty', 'tmbcounter@tmbbank.com', true);
        invitee.TMB_Person__c = userlist.get(0).id;
        invitee.SEQ__c = 0;
        invitee.Visit_Plan_Report__c = visitplan.id;
        insert invitee;
        Visit_Plan_Invitee__c invitee2 = new Visit_Plan_Invitee__c();
        invitee2.TMB_Person__c = userlist.get(1).id;
        invitee2.SEQ__c = 0;
        invitee2.Visit_Plan_Report__c = visitplan.id;
        
        insert invitee2;
        
        
        
        
        PageReference visitplanpage = Page.VisitPlanCreation;
         visitplanpage.getParameters().put('id',leadRec.id);
         visitplanpage.getParameters().put('CallReportID',visitplan.id);
         visitplanpage.getParameters().put('SobjectId',leadRec.id);
        Test.setCurrentPage(visitplanpage);
        
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(visitplan);
        VisitPlanController controller = new VisitPlanController(stdController);
        controller.subpurposeSelectedList.add(new SelectOption('Sell Product','Sell Product'));
        controller.Removeindex = 0;
        controller.callreport.Start_Visit_Time__c ='11:00';
        controller.callreport.End_Visit_Time__c ='12:00';
        
        Visit_Plan_Invitee__c invitee3 = new Visit_Plan_Invitee__c();
        invitee3.TMB_Person__c = userlist.get(2).id;
        invitee3.SEQ__c = 2;
        controller.VisitPlanInviteeList.add(invitee3);
        controller.modalsave();
        controller.modalsaveMobile();
        
        
        controller.callreport.Start_Visit_Time__c ='11:00';
        controller.callreport.End_Visit_Time__c =null;
        controller.modalsaveMobile();
        
        controller.callreport.Start_Visit_Time__c =null;
        controller.callreport.End_Visit_Time__c ='11:00';
        controller.modalsaveMobile();
        
        
        controller.callreport.Start_Visit_Time__c ='11:00';
        controller.callreport.End_Visit_Time__c ='11:00';
        controller.modalsaveMobile();
        
        controller.ActivityID =null;
    
                        
         Test.stopTest();                
    }           
}