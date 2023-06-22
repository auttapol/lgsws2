@isTest
public class OpportunityReportControllerTest {
	
    public static testmethod void positiveTest(){
        test.startTest();
        insert new AppConfig__c(name = 'runtrigger', value__c = 'TRUE');
        TestUtils.createAppConfigRetailtoComm();
        account acct = testutils.createAccounts(1, 'fname', 'Individual', true).get(0);
        Id pb1 = Test.getStandardPricebookId();
        product2 prod = new product2(name='test',isactive=true,Product_Domain__c='Risk');
            insert prod;
        pricebookentry pbe = new pricebookentry(isactive=true,unitprice=1.00,product2id=prod.id,pricebook2id=pb1,usestandardprice=false);
            insert pbe;
        opportunity oppt = new opportunity(accountid = acct.id, name='test', ownerid = acct.ownerid, Expected_submit_date__c = date.today(), closedate = date.today()
                                          ,host_system__c ='SLS',stagename = 'Analysis');
            insert oppt;
        opportunitylineitem opptline = new opportunitylineitem(opportunityid = oppt.id, quantity = 1.00, pricebookentryid = pbe.id,unitprice=1.00
                                                               ,RevisedStartYearFee__c = string.valueof(system.today()).substring(0,4) ,RevisedStartYear__c = string.valueof(system.today()).substring(0,4));
            insert opptline;
        
        user us = [select id from user where id =: acct.ownerid];
        
        system.runas(us){
            
            PageReference pageRef = new pageReference('/apex/OppReportProxy?prevPageNo=1');
        	Test.setCurrentPage(pageRef);
            OpportunityReportController app = new OpportunityReportController();
            
            boolean ba = app.isNotConsole;
            app.allPage();
            app.firstPage();
            app.lastPage();
            app.nextPage();
            app.searchPage();
            app.previousPage();
            app.showCurrentPage();
            app.backToListView();
        }
        
        test.stopTest();
    }
    
}