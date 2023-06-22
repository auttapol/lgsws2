@isTest
public class CSV_ProxyExtensionTest {
    static {
        TestUtils.createAppConfig();
    }  
    
    public static testMethod void positive() {
        List<Account> accList = RTL_TestUtility.createAccounts(1,true);
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(accList.get(0));
        CSV_ProxyExtension cls = new CSV_ProxyExtension(sc);       
        cls.redirectPage();
        cls.getCSVProxy_CC();
        cls.getProfileName();
        Test.stopTest();
    }
}