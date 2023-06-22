@istest
public class EditCustomerControllerTest {
    @TestSetup
    static void makeData(){
        TestUtils.createAppConfig();
        List<AppConfig__c> mc = new List<AppConfig__c> ();
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        insert mc;
    }
	@istest
    static void test(){
        TestUtils.createAppConfig(); 
        
        Account acc = new Account();
        acc.Name = 'test';
        acc.Phone = '0999932211';
        acc.Mobile_Number_PE__c = '083234222';
        acc.RTL_Date_Of_Birth__c = Date.today();
        acc.RTL_Wealth_RM__c = UserInfo.getUserId();
        insert acc;
        
        List<String> fields = new List<String>{'Id'};
        EditCustomerController.getDescribeFieldResultAndValue(acc.Id, fields, new List<String>());
        
        EditCustomerController.verifyFieldSecurity('section', userinfo.getProfileId(), acc.Id);
        
        EditCustomerController.getInitialDataController(userinfo.getUserId(), acc.Id);
        
        Income_Expense__c ie = new Income_Expense__c();
        ie.Customer__c = acc.Id;
        ie.RecordTypeId = Schema.SObjectType.Income_Expense__c.getRecordTypeInfosByDeveloperName().get('Income').getRecordTypeId();
        insert ie;
        
 		Income_Expense__c ie2 = new Income_Expense__c();
        ie2.Customer__c = acc.Id;
        ie2.RecordTypeId = Schema.SObjectType.Income_Expense__c.getRecordTypeInfosByDeveloperName().get('Expense').getRecordTypeId();
        insert ie2;
        
        Income_Expense__c ie3 = new Income_Expense__c();
        ie3.Customer__c = acc.Id;
        ie3.RecordTypeId = Schema.SObjectType.Income_Expense__c.getRecordTypeInfosByDeveloperName().get('Expense').getRecordTypeId(); 
        
        EditCustomerController.getIncomeExpense(acc.Id);
        
        List<Income_Expense__c> incomeList = new List<Income_Expense__c>();
        incomeList.add(ie);
        List<Income_Expense__c> expenseList = new List<Income_Expense__c>();
        expenseList.add(ie);
        expenseList.add(ie3);
        
        EditCustomerController.submitEditAccount(acc, incomeList, expenseList);
    }

	@istest
    static void getDataAfterRefresh_Test(){
        List<String> fields = new List<String>{ 'C_Home_phone_PE__c', 'Customer_Name_PE_Eng__c', 'RTL_Occupation_Details__r.RTL_Occupation_Desc__c', 'TMB_Customer_ID_PE__c', 'RecordTypeId', 'Hobbies__c'}; 
        List<String> fieldstranslate = new List<String>{'Hobbies__c'};
        List<Account> accList = RTL_TestUtility.createAccounts(1, true);
        Test.startTest();
        Object returnValue = EditCustomerController.getDataAfterRefresh(accList.get(0).Id, fields, fieldstranslate);
        Test.stopTest();
    }
}