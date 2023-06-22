@isTest

public class ExchangeRateExtensionTest {

    static testmethod void afterInsertTest() {
    
        test.startTest();
        
        AppConfig__c setting = new AppConfig__c();
        setting.Name = 'runtrigger';
        setting.Value__c = 'true';
        insert setting;
        
        list<Exchange_Rate_Of_Thai_FCY__c> a = new list<Exchange_Rate_Of_Thai_FCY__c>();
        Exchange_Rate_Of_Thai_FCY__c b = new Exchange_Rate_Of_Thai_FCY__c();
            b.External_Key__c = 'USD';
            b.Name__c = 'USD';
        a.add(b);
        insert a;
        
        ExchangeRateExtension.afterInsert(a);
        
        test.stopTest();
    
    }

}