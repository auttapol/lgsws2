@istest
public class DisplayExpenseIncomeControllerTest {
	@istest
    static void test(){
         TestUtils.createAppConfig();
         Account acct = new Account();
        acct.Name = 'Marilyn Monroe';
        acct.Email_Address_PE__c = 'email.email@email.com';
        acct.Mobile_Number_PE__c = '0384441123';
        insert acct;
        
        Income_Expense__c ie = new Income_Expense__c();
        ie.Customer__c = acct.Id;
        ie.RecordTypeId =  Schema.SObjectType.Income_Expense__c.getRecordTypeInfosByDeveloperName().get('Income').getRecordTypeId();
		insert ie;
        
        ie.Id = null;
        ie.RecordTypeId =  Schema.SObjectType.Income_Expense__c.getRecordTypeInfosByDeveloperName().get('Expense').getRecordTypeId();
        insert ie;
        DisplayExpenseIncomeController.getIncomeExpense(acct.Id);
    }
}