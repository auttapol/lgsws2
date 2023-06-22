@isTest
public class TestRetailCustomerExtension {
    
    static{
        TestUtils.createAppConfig();
    }
    static testmethod void testPositiveUpdate(){
        Account acct = new Account();
        acct.Name = 'xxx';
        acct.Account_Type__c = 'Retail Customer';
        acct.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        insert acct;
        Test.startTest();
        	Test.setCurrentPage(Page.RetailCustomerEdit);
        	Account acctToUpdate = [SELECT ID FROM Account WHERE id =: acct.id LIMIT 1];
        	ApexPages.StandardController std = new ApexPages.StandardController(acctToUpdate);
        	RetailCustomerExtension ext = new RetailCustomerExtension(std);
        	ext.save();
        	ext.cancelCustomer();
        	ext.getDisplayS1();
        Test.stopTest();
        
    }
    
    static testmethod void testNegativeLeadUpdate(){
        Test.startTest();
        	Test.setCurrentPage(Page.RetailCustomerEdit);  
        	ApexPages.StandardController std = new ApexPages.StandardController(new Account());
        	RetailCustomerExtension ext = new RetailCustomerExtension(std);
        	ext.save();
        Test.stopTest();
        
    }

}