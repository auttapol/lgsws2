@isTest
public class VisitPlanComponentControllerTest {
	@testSetup static void setup() {
        User user0 = userTest();
        User user1 = userTest1();
        List<User> user = new List<User>();
        user.add(user0);
        user.add(user1);
        insert user;
        
        Status_Code__c sc = new Status_Code__c(Name='7006',Status_Message__c ='Only Visit Owner and TMB counterparty can create/update Visit Report');
        AppConfig__c app1 = new AppConfig__c(Name='DefaultOwner',Value__c='00000');
        AppConfig__c app2 = new AppConfig__c(Name='runtrigger',Value__c='true');
        AppConfig__c app3 = new AppConfig__c(Name='FilterRetailSegment',Value__c='5');
		List<AppConfig__c> app = new List<AppConfig__c>();
        app.add(app1);
        app.add(app2);
        app.add(app3);
        insert app;
        insert sc;
        
        Account acc = new Account (Name='TestAcc',Mobile_Number_PE__c ='0987654321');
        Call_Report__c visitplan = new Call_Report__c();
        System.runAs(user1){
            insert acc;         
              
            visitplan.Customer_name__c = acc.Id;
            visitplan.Status__c = '1 - Open';
            visitplan.Date_of_Visit__c = date.today();
            visitplan.Start_Visit_Time__c = '9:00';
            visitplan.End_Visit_Time__c = '10:00';
            visitplan.Categories__c = 'Pre boarding';
            visitplan.Main_purpose__c = 'First Visit';
            visitplan.Sub_Purpose__c = 'Credit';
            insert visitplan;

            Opportunity opp = new Opportunity();
            opp.Name = 'winner';
            opp.AccountId = acc.Id;
            opp.StageName = 'Analysis';
            opp.Expected_submit_date__c = date.today();
            opp.CloseDate = date.today();
            insert opp;
        }
    }
    
    @isTest static void testMethod1() {
        User user0 = [Select Id FROM User WHERE user.Username = 'test@tmbbank.com' ];
        User user1 = [Select Id FROM User WHERE user.Username = 'test1@tmbbank.com' ];
        System.debug('user0'+user0);
        System.debug('user1'+user1);
        System.runAs(user1){
            test.startTest();
            Call_Report__c visitplan = [SELECT Id FROM Call_Report__c LIMIT 1];
            
            List<Visit_Plan_Invitee__c> insInvitees = new List<Visit_Plan_Invitee__c>();
            for(Integer i=0;i<1;i++) {
                Visit_Plan_Invitee__c invited = new Visit_Plan_Invitee__c();
                invited.Visit_Plan_Report__c = visitplan.Id;
                invited.TMB_Person__c = user0.Id;
                invited.SEQ__c = i;
                insInvitees.add(invited);
            }
			
            Opportunity opp = [SELECT Id,Name FROM Opportunity WHERE Name = 'winner' LIMIT 1];
			VisitPlanComponentController.insertVisitPlan(visitplan.Id,insInvitees,null);            
            
            
            List<Visit_Plan_Invitee__c> testInvitees = VisitPlanComponentController.getInvitee(visitplan.Id);
            VisitPlanComponentController.updateInvitee(testInvitees,testInvitees,visitplan.Id);
            
            List<Visit_Plan_Invitee__c> newInvitee = testInvitees.clone();
            testInvitees.clear();
            VisitPlanComponentController.updateInvitee(testInvitees,newInvitee,visitplan.Id);
            
            test.stopTest();
        }

    }
    
    public static User userTest(){
		Profile p = [SELECT Id, Name FROM Profile Where Name ='System Administrator' LIMIT 1];
        User user = new User();
        user.Username = 'test@tmbbank.com';
        user.LastName ='test';
        user.Email ='test@tmbbank.com';
        user.Alias ='test';
        user.TimeZoneSidKey ='Asia/Bangkok';
        user.LocaleSidKey ='th_TH';
        user.EmailEncodingKey ='UTF-8';
        user.ProfileId = p.Id;
        user.LanguageLocaleKey ='en_US';
        user.Employee_ID__c = '86790';
        return user ;
    }
    
    public static User userTest1(){
		Profile p = [SELECT Id, Name FROM Profile Where Name ='System Administrator' LIMIT 1];
        User user = new User();
        user.Username = 'test1@tmbbank.com';
        user.LastName ='test1';
        user.Email ='test1@tmbbank.com';
        user.Alias ='test1';
        user.TimeZoneSidKey ='Asia/Bangkok';
        user.LocaleSidKey ='th_TH';
        user.EmailEncodingKey ='UTF-8';
        user.ProfileId = p.Id;
        user.LanguageLocaleKey ='en_US';
        user.Employee_ID__c = '86791';
        return user ;
    }

}