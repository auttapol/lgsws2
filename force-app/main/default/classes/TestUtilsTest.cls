@isTest
public class TestUtilsTest {
    static testmethod void TestUtilsTest(){
        Test.startTest();
            List<Account> acctList = TestUtils.accountList;
            List<Contact> contList = TestUtils.contactList;
            List<User> userList = TestUtils.userList;
            //List<Type_of_id__c> typeList = TestUtils.IdTypeList;
            TestUtils.createAppConfig();
        	TestUtils.createObjUserPermission();
            TestUtils.createUsers(1,'TestUtilTest', 'Utiltest','testUtil@tmbbank.com', true);
            TestUtils.createAccounts(1,'AccountTest','Individual',true);
            
            TestUtils.createContacts(1,TestUtils.accountList.get(0).id, true);
            //TestUtils.createIdType();
            TestUtils.createStatusCode();
            TestUtils.createDisqualifiedReason();
            TestUtils.createDateOfBirth();
            TestUtils.CreateAddress();
            TestUtils.CreateOpportunityStage();
            TestUtils.createAppConfig_Trigger();
            String age1 = TestUtils.calculateAge(Date.newInstance(1900, 1, 1))+'';
            String age2 = TestUtils.calculateAge(Date.newInstance(1992, 1, 1))+'';
        
        	TestUtils.CreateProceBook();
        	TestUtils.CreateProceBookAccess();
        	TestUtils.CreateTriggerMsg();
            
            TestUtils.prepareIntegrationMapping();
            TestUtils.prepareEIMmaps();

            
        Test.stopTest();
    }
}