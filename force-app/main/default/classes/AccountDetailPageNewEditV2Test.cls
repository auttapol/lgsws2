@isTest
public class AccountDetailPageNewEditV2Test {

    @isTest 
    static void testMethod1() {

        String sectionName='ComCust:Other Information';
        String sectionName2='ComCust:Risk Information';
        String sectionName3='ComCust:Account Information';
        String sectionName4='Edit Customer Information';

        AppConfig__c app2 = new AppConfig__c(Name='runtrigger',Value__c='true');
        insert app2;
        Account acc = new Account (Name='TestAcc',Mobile_Number_PE__c ='0987654321');
        insert acc;

        test.startTest();
        AccountDetailPageNewEditV2.getAccountCustomer(acc.id);
        AccountDetailPageNewEditV2.loadData(sectionName,sectionName2,sectionName3,sectionName4,acc.id);
        test.stopTest();
    }
}