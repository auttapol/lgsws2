@istest
public class VisitPlanTriggerHandlerTest {

    
     static {
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
        TestUtils.createObjUserPermission();
        TestInit.createCustomSettingTriggerMsg();     
        Sub_Purpose_Mapping__c subpurpose = new Sub_Purpose_Mapping__c();

        subpurpose.Main_purpose__c = 'CB';
        subpurpose.Sub_Purpose__c = 'Sell product';
        subpurpose.Name = 'Subpurpose1';
     insert subpurpose;
    }
    
    
    public static  testmethod  void myUnitTest(){
        
        
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
           acct.Phone ='345345';
        acct.OwnerId =newUser.id;
           Acct.Phone ='050111222';
            Acct.Mobile_Number_PE__c  = '0801112233';
        insert acct;
           
        report.Customer_name__c = acct.id;
        report.Status__c ='1 - Open';
        report.Categories__c = 'Initiavtives';
        report.Main_purpose__c ='CB';
        report.Date_of_Visit__c  = System.today()+1;
        report.Sub_Purpose__c = 'Cash_Fleet Card';
        report.OwnerId = Userinfo.getUserId();
           insert report;
        
         report.Main_purpose__c ='MB';
        update report;
        Test.startTest();
        List<UseR> userlist = TestUtils.createUsers(3, 'TMB', 'Counterparty', 'tmbcounter@tmbbank.com', false);
        user tmbcounter1 = userlist.get(0);
        user tmbcounter2 = userlist.get(1);
        tmbcounter1.Employee_ID__c ='70123';
        tmbcounter2.Employee_ID__c ='70124';
        insert userlist;
        Visit_Plan_Invitee__c invitee = new Visit_Plan_Invitee__c();
        invitee.TMB_Person__c = userlist.get(0).id;
        
        invitee.Visit_Plan_Report__c = report.id;
        insert invitee;
        
        invitee.TMB_Person__c = userlist.get(1).id;
        update invitee;
        
      
        
        
         Visit_Plan_Invitee__c invitee2 = new Visit_Plan_Invitee__c();
        invitee2.TMB_Person__c = userlist.get(0).id;
        invitee2.SEQ__c = 0;
        invitee2.Visit_Plan_Report__c = report.id;
        insert invitee2;
        
        delete invitee2;
        
        Visit_Report__c visitreport = new Visit_Report__c();
        visitreport.Visit_Plan_Report__c = report.id;
        visitreport.Additional_Comments__c = 'test';
        visitreport.Business_Talk_Opportunity__c = 'test';
        
        insert visitreport;
        
        report.OwnerID  = userlist.get(1).id;
        update report;
        
        try{
              Visit_Plan_Invitee__c invitee3 = new Visit_Plan_Invitee__c();
        invitee3.TMB_Person__c = userlist.get(0).id;
        invitee3.SEQ__c = 2;
        invitee3.Visit_Plan_Report__c = report.id;
            
        Visit_Plan_Invitee__c invitee6 = new Visit_Plan_Invitee__c();
        invitee6.TMB_Person__c = userlist.get(0).id;
        invitee6.SEQ__c = 3;
        invitee6.Visit_Plan_Report__c = report.id;
            List<Visit_Plan_Invitee__c> inviteeList = new List<Visit_Plan_Invitee__c>();
            inviteeList.add(invitee3);
            inviteeList.add(invitee6);
        insert inviteeList;
            
            
        }catch(DMLException e){
            System.debug(e.getMessage());
        }  
        
        try{
             
            Visit_Plan_Invitee__c invitee4 = new Visit_Plan_Invitee__c();
        invitee4.TMB_Person__c = report.OwnerId;
        invitee4.SEQ__c = 3;
        invitee4.Visit_Plan_Report__c = report.id;
        insert invitee4;
        }catch(DMLException e){
            System.debug(e.getMessage());
        }   
          
        
        try{
             
            Visit_Plan_Invitee__c invitee5 = new Visit_Plan_Invitee__c();
        invitee5.TMB_Person__c = userlist.get(2).id;
        invitee5.SEQ__c = 3;
        invitee5.Visit_Plan_Report__c = report.id;
        insert invitee5;
            invitee5.TMB_Person__c = [SELECT ID,TMB_Person__c,Visit_Plan_report__c 
                                 FROM Visit_Plan_Invitee__c
                                 WHERE Visit_Plan_report__c =: report.id LIMIT 1].get(0).TMB_Person__c;
            
            update invitee5;
        }catch(Exception e){
            System.debug(e.getMessage());
        }   
        
        
        report.Status__c ='3 - Cancel';
        update report;
        List<Call_Report__c> visitlist = new List<Call_Report__C>();
        visitlist.add(report);
        VisitPlanTriggerHandler.deleteEvents(visitlist);
        TimeZone tz = VisitPlanTriggerHandler.tz;
           
          Test.stopTest();
    }
}