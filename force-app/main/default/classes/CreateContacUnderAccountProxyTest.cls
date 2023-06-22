@isTest
public class CreateContacUnderAccountProxyTest {
    static {
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
		TestUtils.createDisqualifiedReason(); 
    }
      static testmethod void UnitTest(){
       
       //PageReference newContactpage = Page.ContactCreationMobileLayout;
       Account acct2 = TestUtils.createAccounts(1,'TestNewContact','TestLog',true).get(0);
       //newContactpage.getParameters().put('accid', acct2.id);

       //Test.setCurrentPage(newContactpage);
       Test.startTest();
       //ApexPages.StandardController sc =
       CreateContacUnderAccountProxy newContact = new CreateContacUnderAccountProxy( new ApexPages.StandardController(acct2));
       PageReference p1 = newContact.redirectMobile(); 
       PageReference p2 = newContact.redirectPage();
       Test.stoptest();
   }
}