@isTest
public without sharing class CustomerNoteInfoTrigger_Test {
    @TestSetup
    static void Setup_AppConfig(){
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';
        apps.add(Aconfig);

        AppConfig__c Aconfig2 = new AppConfig__c();
        Aconfig2.Name = 'runCustomerNoteTrigger';
        Aconfig2.Value__c = 'true';
        apps.add(Aconfig2);

        insert apps;
    }

    @isTest
    private static void Test_CustomerNoteInfoTrigger() {
        System.debug('Start Test Customer Note Info Trigger');
        Test.startTest();
        User admin = userAdmin();
        // Create account Owner and Account Team Member User.
        List<User> listUsers = TestUtils.createUsers(2,'TestNote', 'TestNote','testNote@mail.com', true);

        System.runAs(admin){
            // Create Account
            Account account = new Account();
            account.Name = 'Mockup Data';
            account.RTL_Office_Phone_Number__c = '012345678';
            account.Mobile_Number_PE__c = '0987654321';
            account.TMB_Customer_ID_PE__c = '001100000000000000000012345678';
            account.OwnerId = listUsers.get(0).Id;
            insert account;

            AccountTeamMember accTeam = new AccountTeamMember();
            accTeam.AccountId = account.Id;
            accTeam.UserId = listUsers.get(1).Id;
            accTeam.TeamMemberRole = 'FX Sales';
            accTeam.AccountAccessLevel = 'Read';
            accTeam.CaseAccessLevel = 'Read';
            accTeam.OpportunityAccessLevel = 'Read';
            insert accTeam;

            // Do test after insert.
            Customer_Note_Info__c noteInfo = new Customer_Note_Info__c();
            noteInfo.Customer__c = account.Id;
            noteInfo.Migration_Customer_Info_No__c = '00110000000000000000001234567820201119';
            noteInfo.Migration_Info_Title__c = 'Test Title';
            noteInfo.Migration_Info_Text__c= 'Test Text';
            insert noteInfo;

            list<Customer_Note_Info__Share> listNoteShr = [SELECT Id From Customer_Note_Info__Share Where ParentId =: noteInfo.Id];
            System.assertEquals(3, listNoteShr.size());

            // Do test after update
            noteInfo.Migration_Info_Text__c = 'Test Text2';
            update noteInfo;

            listNoteShr = [SELECT Id From Customer_Note_Info__Share Where ParentId =: noteInfo.Id];
            System.assertEquals(3, listNoteShr.size());

            // Do test before delete
            delete noteInfo;
            listNoteShr = [SELECT Id From Customer_Note_Info__Share Where ParentId =: noteInfo.Id];
            System.assertEquals(0, listNoteShr.size());

        }

        Test.stopTest();
        System.debug('Stop Test Customer Note Info Trigger');
    }

    @isTest
    private static void Test_AccountTeamMemberTrigger() {
        System.debug('Start Test Account Team Member Trigger');
        Test.startTest();
        User admin = userAdmin();
        // Create account Owner and Account Team Member User.
        List<User> listUsers = TestUtils.createUsers(2,'TestNote', 'TestNote','testNote@mail.com', true);

        System.runAs(admin){
            // Create Account
            Account account = new Account();
            account.Name = 'Mockup Data';
            account.RTL_Office_Phone_Number__c = '012345678';
            account.Mobile_Number_PE__c = '0987654321';
            account.TMB_Customer_ID_PE__c = '001100000000000000000012345678';
            account.OwnerId = listUsers.get(0).Id;
            insert account;

            // Do test after insert.
            Customer_Note_Info__c noteInfo = new Customer_Note_Info__c();
            noteInfo.Customer__c = account.Id;
            noteInfo.Migration_Customer_Info_No__c = '00110000000000000000001234567820201119';
            noteInfo.Migration_Info_Title__c = 'Test Title';
            noteInfo.Migration_Info_Text__c= 'Test Text';
            insert noteInfo;

            list<Customer_Note_Info__Share> listNoteShr = [SELECT Id From Customer_Note_Info__Share Where ParentId =: noteInfo.Id];
            System.assertEquals(2, listNoteShr.size());

            // Test add AccountTeamMember.
            AccountTeamMember accTeam = new AccountTeamMember();
            accTeam.AccountId = account.Id;
            accTeam.UserId = listUsers.get(1).Id;
            accTeam.TeamMemberRole = 'FX Sales';
            accTeam.AccountAccessLevel = 'Read';
            accTeam.CaseAccessLevel = 'Read';
            accTeam.OpportunityAccessLevel = 'Read';
            insert accTeam;

            listNoteShr = [SELECT Id From Customer_Note_Info__Share Where ParentId =: noteInfo.Id];
            System.assertEquals(3, listNoteShr.size());

            // Test delete Account Team Member.
            delete accTeam;

            listNoteShr = [SELECT Id From Customer_Note_Info__Share Where ParentId =: noteInfo.Id];
            System.assertEquals(2, listNoteShr.size());
        }

        Test.stopTest();
        System.debug('Stop Test Account Team Member Trigger');
    }

    public static User userAdmin(){
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