@isTest
private class CSESubmitForApproverFormAControllerTest {
    @testSetup static void setup(){
        // Implement test code
        AppConfig__c mc =new AppConfig__c(Name = 'runtrigger', Value__c = 'false');
        insert mc;

        User u = CSTestUtils.createUsers(1, 'UserTestqqq' ,'Userqqq' , 'test22@email.com' , false).get(0);
        u.IsActive = true;
        insert u;

        // Create Team Head user.
        Id TEAMHEAD_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Team Head Profile' LIMIT 1].Id;
        User newUser = new User(FirstName = 'TeamHead' , LastName = 'Test',
                                UserName= 'TeamHead@tmbbank.com.test',
                                Email='TeamHead@tmbbank.com', Alias='TestTH',
                                LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1',
                                CommunityNickname='TeamHead_Test_TMBTesttmb',
                                ProfileId = TEAMHEAD_PROFILE_ID, TimeZoneSidKey='America/New_York',
                                isActive = true, Employee_ID__c ='RMTH01',
                                Title = 'Team Head');
        insert newUser;

        Account acc = CSTestUtils.createAccounts(1,false).get(0);
        acc.Murex_Counter_Label__c = 'eclient';
        insert acc;

        List<Survey_Manager__c> smList = CSTestUtils.createSurveyManager(2);
        Survey_Sheet__c formA = CSTestUtils.insertSurveySheet(smList[0], acc.Id,u.Id,'FormA');
        Survey_Sheet__c formB = CSTestUtils.insertSurveySheet(smList[1],acc.Id,u.Id,'FormB');

        List<E_Client_Suitability__c> esList = CSTestUtils.createEclient(1,acc.Id,u.Id,formA,formB);
    }

    @isTest static void getEClientRecord(){
        // Implement test code
        List<E_Client_Suitability__c> ec = [SELECT Id, Name, CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c FROM E_Client_Suitability__c Limit 1];
        E_Client_Suitability__c record = CSESubmitForApproverFormAController.getRecordInfo(ec[0].Id);
        System.assertEquals(record.Name, ec[0].Name);
    }

    @isTest static void submitEClientRecordForApprove(){
        // Implement test code
        List<E_Client_Suitability__c> ec = [SELECT Id,Name, CS_Murex_ID__c,CS_Customer_Survey_A__c,CS_Customer_Survey_B__c FROM E_Client_Suitability__c Limit 1];
        List<User> userList = CSESubmitForApproverFormAController.fetchUser('TeamHead');
        Boolean result = CSESubmitForApproverFormAController.submitRequest(ec[0].Id, userList[0].Id, '');
    }
}