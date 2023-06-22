@isTest
public class SearchProxyControllerTest {
     static{
        // Initial Data Custom config
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        TestUtils.createIdType();
    }   
    public static TestMethod void P_Redirect(){        
        PageReference SearchProspectEx1 = Page.SearchProspectEx;
        Test.setCurrentPage(SearchProspectEx1);
        Account acc = new Account();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        SearchProxyController searchEx = new SearchProxyController(sc); 
        
        PageReference SearchProspectEx2 = searchEx.NextPage();
        
        system.assertEquals(SearchProspectEx2.getUrl(), SearchProspectEx1.getUrl());
        
    } 
}