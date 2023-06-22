@isTest
public with sharing class PEUpdateHelperTest {
    @isTest
    public static void PEUpdateHelperTest() {
        
        AppConfig__c app2 = new AppConfig__c(Name='runtrigger',Value__c='true');
        String sectionName = 'ComPros:Customer Information';
        String sectionName2 = 'ComPros:Product Interest';
        String sectionName3 = 'ComPros:Customer Source';
        String sectionName4 = 'ComPros:Re-assignment Customer';
        insert app2;
        Account acc = new Account (Name='TestAcc',Mobile_Number_PE__c ='0987654321');
            insert acc;

        test.startTest();
        PEUpdateHelper.getAccountCustomer(acc.ID);
        PEUpdateHelper.loadData(sectionName,acc.ID);
        PEUpdateHelper.loadData(sectionName2,acc.ID);
        PEUpdateHelper.loadData(sectionName3,acc.ID);
        PEUpdateHelper.loadData(sectionName4,acc.ID);
        test.stopTest();
    }
}