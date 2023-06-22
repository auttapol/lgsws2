@IsTest
public class TestInitTest {
    
    public static testmethod void positiveTest(){
        System.debug(':::: positiveTest Start ::::');
        
            TestUtils.createAppConfig();
        	TestUtils.createObjUserPermission();
        
        TestInit.createUser(false);
        TestInit.createAccount(3);
        TestInit.createOpportunity(TestInit.accountList.values());
        TestInit.createTask(TestInit.accountList.values());
        TestInit.createReport(TestInit.accountList.values());
        TestInit.createTarget(TestInit.accountList.values());
        List<Account> accountList = TestInit.accountList.values();
        List<Contact> contactList = TestInit.createContacts(1,accountList.get(0).id, true); 
        TestInit.createAccountTeamMember(1,TestInit.accountList.values().get(0).Id,TestInit.us.Id);
        TestInit.resetData();
        System.debug(':::: positiveTest End ::::');
    }

}