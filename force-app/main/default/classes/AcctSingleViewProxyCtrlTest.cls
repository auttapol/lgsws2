@isTest 
private class  AcctSingleViewProxyCtrlTest {
    @testSetup static void setupTestData(){
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
    }    
    @isTest static void redirectToProspectLayout() {
        // Get Record Type
        RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name='Prospect' Limit 1];
        Account acc = new Account(Name='Test' , recordTypeId=rt.id,Phone ='050111222',Mobile_Number_PE__c  = '0801112233');
		ApexPages.StandardController scpre = new ApexPages.StandardController(acc);
        AcctSingleViewProxyCtrl AccCreateExpre = new AcctSingleViewProxyCtrl(scpre); 
        PageReference redirectPagepre  = AccCreateExpre.redirectPage();            
        insert acc;        
        //Act
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        AcctSingleViewProxyCtrl AccCreateEx = new AcctSingleViewProxyCtrl(sc); 
        PageReference redirectPage  = AccCreateEx.redirectPage();              
        //Assert
        String nextPage = redirectPage.getUrl();
         
    }
    
    @isTest static void redirectToCustomerLayout() {
        // Get Record Type
        RecordType rt = [select id,Name from RecordType where SobjectType='Account' and Name='Existing Customer' Limit 1];
        Account acc = new Account(Name='Test' , recordTypeId=rt.id);
        insert acc;
        
       //Act
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        AcctSingleViewProxyCtrl AccCreateEx = new AcctSingleViewProxyCtrl(sc); 
        PageReference redirectPage  = AccCreateEx.redirectPage();
        PageReference redirectMobile  = AccCreateEx.redirectMobile();
        //Assert
        String nextPage = redirectPage.getUrl();
           
        String nextPage2 = redirectMobile.getUrl();
       
    }    
}