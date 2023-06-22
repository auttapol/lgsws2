@isTest
public class MainBankHistoryTableComponentTest {
	@testSetup
    static void testSetup() {
        
    	list<Data_Security_Matrix__c> dsm = new  list<Data_Security_Matrix__c>();
        Data_Security_Matrix__c ds1 = new Data_Security_Matrix__c();
		ds1.Access_Type__c ='All';
        ds1.Profile_Name__c ='System Administrator';
        ds1.Data_Matrix_Key__c ='TMB CM Product Manager ProfileCommCust:Customer Product Holding (Low)';
        ds1.Section_Name__c  ='RtlCust:MI Benefits';
        dsm.add(ds1);
        insert dsm;
        TestUtils.createAppConfig();
        Account acct = TestUtils.createAccounts(1,'TESTACCOUNT','Individual', true).get(0);
        
        List<Customer_Main_Bank_Info__c> mainBankInfoList = new List<Customer_Main_Bank_Info__c>();
        mainBankInfoList.add(new Customer_Main_Bank_Info__c(Calculation_Date__c = System.today() - 30,Customer__c = acct.Id));
        mainBankInfoList.add(new Customer_Main_Bank_Info__c(Calculation_Date__c = System.today() - 60,Customer__c = acct.Id));
        insert mainBankInfoList;
    }
    
    @isTest
    static void testGetMainBankHistoryList() {
        User adminUser = [SELECT Id,Name , Profile.Name FROM User WHERE IsActive = true AND ProfileId =: TestUtils.SYSADMIN_PROFILE_ID LIMIT 1];
        Account acct = [select Id , TMB_Customer_ID_PE__c from Account LIMIT 1];
        acct.TMB_Customer_ID_PE__c ='00000000';
        update acct;
        Test.startTest();
        System.runAs(adminUser) {
            List<Customer_Main_Bank_Info__c> mainBankList = MainBankHistoryTableComponent.getMainBankHistoryList(acct.Id);
            System.assertEquals(mainBankList.size(), 2);
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetMainBankLabels() {
        Map<String,String> fieldNameLabelMap = MainBankHistoryTableComponent.getMainBankLabels();
        System.assert(fieldNameLabelMap.size() > 0, 'Map of field name and label is returned');
    }
}