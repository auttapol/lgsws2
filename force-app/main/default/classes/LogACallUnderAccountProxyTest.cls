@isTest
public class LogACallUnderAccountProxyTest {
    
    static{
        TestUtils.createAppConfig();       
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
    }
    
    static testmethod void UnitTestContact(){
        
        PageReference logacallpage = Page.LogACallMobileLayout;
        Account acct2 = TestUtils.createAccounts(1,'TestLogacall','TestLog',true).get(0);
        Contact con = TestUtils.createContacts(1,acct2.id, true).get(0);
        logacallpage.getParameters().put('what_id',acct2.id);
        logacallpage.getParameters().put('sObjectType','Contact');
        logacallpage.getParameters().put('who_ID',con.id);
        Test.setCurrentPage(logacallpage);
        Test.startTest();
        LogACallUnderAccountProxy logacall = new LogACallUnderAccountProxy(new ApexPages.StandardController(con));
        logacall.NextPage(); 
        Test.stoptest();
        
    }
    
    
    static testmethod void UnitTestAccount(){
        
        PageReference logacallpage = Page.LogACallMobileLayout;
        Account acct2 = TestUtils.createAccounts(1,'TestLogacall','TestLog',true).get(0);
        logacallpage.getParameters().put('what_id',acct2.id);
        logacallpage.getParameters().put('sObjectType','Account');
        Test.setCurrentPage(logacallpage);
        Test.startTest();
        LogACallUnderAccountProxy logacallact = new LogACallUnderAccountProxy(new ApexPages.StandardController(acct2));
        logacallact.NextPage(); 
        Test.stoptest();
        
        
    }
    
    
    static testmethod void UnitTestOpp(){       
        // ######################   Arrang    #############################
        PageReference logacallpageopp = Page.LogACallMobileLayout;        
        List<Account> acct3 = TestUtils.createAccounts(1,'TestLogacall','TestLog',true);      
        logacallpageopp.getParameters().put('what_id',acct3[0].id);
        logacallpageopp.getParameters().put('sObjectType','Opportunity');  
        system.debug('Account   : ' +  acct3);        
        TestInit.createOpportunity( acct3);   
        //> Pevent Trigger Fire
        Opportunity opp = new Opportunity();
        opp.AccountId = acct3[0].Id;
        opp.Name ='XXXX';
        opp.StageName ='Open';  
        // ######################     Act    ######################        
        Test.setCurrentPage(logacallpageopp);
        Test.startTest();
        LogACallUnderAccountProxy logacallopp = new LogACallUnderAccountProxy(new ApexPages.StandardController(opp));
        string nextPage =  logacallopp.NextPage().getUrl();    
        Test.stoptest();        
        system.debug('Next Page Url  : ' +  nextPage);        
        // ######################    Assert     ###################### 
        System.assertNotEquals('', nextPage);  
        System.assertEquals('/apex/LogACallMobileLayout?what_id='+opp.Id, nextPage);
    }
    
    static testmethod void Unit_Should_Return_Null(){       
        // ######################   Arrang    #############################
        PageReference logacallpageopp = Page.LogACallMobileLayout;   
        Task task = new Task();
        // ######################     Act    ######################        
        Test.setCurrentPage(logacallpageopp);
        Test.startTest();
        LogACallUnderAccountProxy logacallopp = new LogACallUnderAccountProxy(new ApexPages.StandardController(task));
        PageReference nextPage =  logacallopp.NextPage();    
        Test.stoptest();        
        
        // ######################    Assert     ###################### 
        System.assertEquals(null, nextPage);  
        
    }
    
}