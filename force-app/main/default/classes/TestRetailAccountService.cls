@isTest
public class TestRetailAccountService {
    static{
        TestUtils.createAppConfig();
    }
        
    static testmethod void testPositiveCase(){
        Account acct = new Account();
        acct.Name = 'acct';
        acct.Account_Type__c = 'Retail Customer';
        acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        insert acct;
        Test.startTest();
        RetailAccountService.setMockservice(new RetailAccountServiceImpl());
        boolean v1 = RetailAccountService.UpdateTotalAccountsAndSumOfDepesite(acct.id,24,3324232);
        Account acct2 = RetailAccountService.getAccountById(acct.id);
        Test.StopTest();
    }
    
    static testmethod void testNegativeCase(){
        Account acct = new Account();
        acct.Name = 'acct';
        acct.Account_Type__c = 'Retail Customer';
        acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        insert acct;
        Test.startTest();
        RetailAccountService.setMockservice(new RetailAccountServiceImpl());
        try{
            boolean v1 = RetailAccountService.UpdateTotalAccountsAndSumOfDepesite(null,24,3324232);
        }catch(Exception e){
            System.assertEquals('Account Id cannot be null',e.getMessage());
        }
        
        try{
			Account acct2 = RetailAccountService.getAccountById(null);            
        }catch(Exception e){
            System.assertEquals('Account Id cannot be null', e.getMessage());
        }
        
        Test.StopTest();
    }
}