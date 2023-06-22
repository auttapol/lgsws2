@isTest
public without sharing class RTL_DoNotContactTrigger_Test {
    @TestSetup
    static void Setup_AppConfig(){
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';
        apps.add(Aconfig);

        // AppConfig__c Aconfig2 = new AppConfig__c();
        // Aconfig2.Name = 'runCustomerNoteTrigger';
        // Aconfig2.Value__c = 'true';
        // apps.add(Aconfig2);

        AppConfig__c Aconfig4 = new AppConfig__c();
        Aconfig4.Name = 'DefaultOwner';
        Aconfig4.Value__c = '00000';
        apps.add(Aconfig4);

        AppConfig__c Aconfig3 = new AppConfig__c();
        Aconfig3.Name = 'FilterRetailSegment';
        Aconfig3.Value__c = '5|6|7|8|9';
        apps.add(Aconfig3);

        insert apps;
    }

    // @isTest
    // private static void Test_DoNotContactInsertTrigger() {
    //     System.debug('Start Test Do not Contact Insert Trigger');
    //     Test.startTest();
    //     User tmbadmin = userTMBSysAdmin();
    //     // Create account Owner and Account Team Member User.
    //     List<User> listUsers = TestUtils.createUsers(1,'TestDNC', 'TestDNC','testDnc@mail.com', true);

    //     System.runAs(tmbadmin){
    //         // Create Account
    //         Account account = new Account();
    //         account.Name = 'Mockup Data';
    //         account.RTL_Office_Phone_Number__c = '012345678';
    //         account.Mobile_Number_PE__c = '0987654321';
    //         account.TMB_Customer_ID_PE__c = '001100000000000000000012345678';
    //         account.OwnerId = listUsers.get(0).Id;
    //         insert account;

    //         // Do test after insert.
    //         RTL_Do_not_Contact_Info__c dnc = new RTL_Do_not_Contact_Info__c();
    //         dnc.Customer__c = account.Id;
    //         dnc.Product_Group__c = 'All';
    //         dnc.Channel__c = 'Phone; Email; SMS; MIB; All';
    //         dnc.Period__c = 'Other';
    //         dnc.Start_Date__c = Date.today();
    //         dnc.End_Date__c = Date.today().addMonths(6);
    //         dnc.Reason__c = 'Test';
    //         insert dnc;

    //         list<Account> listAcc = [Select Id, DNC_Expired_Date__c From Account where Id =: account.Id];
    //         System.assertEquals(Date.today().addMonths(6), listAcc[0].DNC_Expired_Date__c);

    //         // Do test after delete
    //         delete dnc;
    //         listAcc = [Select Id, DNC_Expired_Date__c From Account where Id =: account.Id];
    //         System.assertEquals(null, listAcc[0].DNC_Expired_Date__c);

    //     }

    //     Test.stopTest();
    //     System.debug('Stop Test Do not Contact Insert Trigger');
    // }

    @isTest
    private static void Test_DoNotContactInsertDeleteTrigger() {
        System.debug('Start Test Do not Contact Insert and Delete Trigger');
        Test.startTest();
        User tmbadmin = userTMBSysAdmin();
        // Create account Owner and Account Team Member User.
        List<User> listUsers = TestUtils.createUsers(1,'TestDNC', 'TestDNC','testDnc@mail.com', true);

        System.runAs(tmbadmin){
            // Create Account
            Account account = new Account();
            account.Name = 'Mockup Data';
            account.RTL_Office_Phone_Number__c = '012345678';
            account.Mobile_Number_PE__c = '0987654321';
            account.TMB_Customer_ID_PE__c = '001100000000000000000012345678';
            account.OwnerId = listUsers.get(0).Id;
            insert account;

            // Do test after insert.
            RTL_Do_not_Contact_Info__c dnc = new RTL_Do_not_Contact_Info__c();
            dnc.Customer__c = account.Id;
            dnc.Product_Group__c = 'All';
            dnc.Channel__c = 'Phone; Email; SMS; MIB; All';
            dnc.Period__c = 'Other';
            dnc.Start_Date__c = Date.today();
            dnc.End_Date__c = Date.today().addMonths(6);
            dnc.Reason__c = 'Test';
            insert dnc;

            // Do test after insert.
            RTL_Do_not_Contact_Info__c dnc2 = new RTL_Do_not_Contact_Info__c();
            dnc2.Customer__c = account.Id;
            dnc2.Product_Group__c = 'All';
            dnc2.Channel__c = 'Phone; Email; SMS; MIB; All';
            dnc2.Period__c = 'Other';
            dnc2.Start_Date__c = Date.today();
            dnc2.End_Date__c = Date.today().addMonths(10);
            dnc2.Reason__c = 'Test';
            insert dnc2;

            list<Account> listAcc = [Select Id, DNC_Expired_Date__c From Account where Id =: account.Id];
            System.assertEquals(Date.today().addMonths(10), listAcc[0].DNC_Expired_Date__c);

            // Do test after delete
            delete dnc2;
            listAcc = [Select Id, DNC_Expired_Date__c From Account where Id =: account.Id];
            System.assertEquals(Date.today().addMonths(6), listAcc[0].DNC_Expired_Date__c);

            // Do test after delete to null
            delete dnc;
            listAcc = [Select Id, DNC_Expired_Date__c From Account where Id =: account.Id];
            System.assertEquals(null, listAcc[0].DNC_Expired_Date__c);

        }

        Test.stopTest();
        System.debug('Stop Test Do not Contact Insert and Delete Trigger');
    }

    public static User userTMBSysAdmin(){
		Profile p = [SELECT Id, Name FROM Profile Where Name ='TMB System Administrator' LIMIT 1];
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
        user.Employee_ID__c = '1006791';
        return user ;
    }
}