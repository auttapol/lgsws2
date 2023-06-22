@isTest
public class EditProductLineItemCtrlSingleTest {
    
    public static Id pb1 {get{return Test.getStandardPricebookId();}set;}
    public static pricebook2 pb2 {get;set;}
    public static product2 prod {get;set;}
    public static pricebookentry pbe {get;set;}
    public static account acct {get;set;}
    public static opportunity oppt {get;set;}
    public static void setInitial()
    {
        insert new status_code__c(name = '8008', Status_Message__c = 'test');
        insert new status_code__c(name = '8015', Status_Message__c = 'test');
        insert new AppConfig__c(name = 'runtrigger', value__c = 'TRUE');
        insert new Trigger_Msg__c(name = 'Permission_Create_Opportunity', Description__c   = 'description');
        insert new Account_Plan_Fiscal_Year__c(name='2',ad_year__c='2015',be_year__c='2558');
        TestUtils.createAppConfigRetailtoComm();
        
        pb2 = new pricebook2(name='test',isActive=true,TMB_Pricebook__c='test');insert pb2;
        prod = new product2(name='test',isactive=true);insert prod;
        pbe = new pricebookentry(isactive=true,unitprice=1.00,product2id=prod.id,pricebook2id=pb1,usestandardprice=false);insert pbe;
    	acct = testutils.createAccounts(1, 'fname', 'Individual', true).get(0);
        oppt = new opportunity(accountid = acct.id, name='test', ownerid = acct.ownerid, Expected_submit_date__c = date.today(), closedate = date.today()
                                          ,stagename = 'Analysis');insert oppt;
    }
    
    static testmethod void positive()
    {
        test.startTest();
        
        setInitial();
        opportunitylineitem opptline = new opportunitylineitem(opportunityid = oppt.id, quantity = 1.00, pricebookentryid = pbe.id,unitprice=1.00
                                                               ,RevisedStartMonth__c='JAN',RevisedStartYear__c='2015'
                                                               ,RevisedStartMonthFee__c='JAN',RevisedStartYearFee__c='2015');
        	insert opptline;
        
        apexpages.StandardController sc = new apexpages.StandardController(opptline);
        EditProductLineItemCtrlSingle app = new EditProductLineItemCtrlSingle(sc);
        pagereference pa = app.back();
        list<selectoption> listSelect = app.getFiscalYear();
        pagereference pa2 = app.dosave();

        test.stopTest();
        
    }
    
    static testmethod void positiveMobile()
    {
        test.startTest();
        
        setInitial();
        opportunitylineitem opptline = new opportunitylineitem(opportunityid = oppt.id, quantity = 1.00, pricebookentryid = pbe.id,unitprice=1.00
                                                               ,RevisedStartMonth__c='JAN',RevisedStartYear__c='2015'
                                                               ,RevisedStartMonthFee__c='JAN',RevisedStartYearFee__c='2015');
        	insert opptline;
        
        apexpages.StandardController sc = new apexpages.StandardController(opptline);
        EditProductLineItemCtrlSingle app = new EditProductLineItemCtrlSingle(sc);
        pagereference pa = app.back();
        list<selectoption> listSelect = app.getFiscalYear();
        app.dosaveMobile();

        test.stopTest();
        
    }
    
    static testmethod void negative()
    {
        test.startTest();

        setInitial();
        opportunitylineitem opptline = new opportunitylineitem(opportunityid = oppt.id, quantity = 1.00, pricebookentryid = pbe.id,unitprice=1.00
                                                               ,RevisedStartMonth__c='JAN',RevisedStartMonthFee__c='JAN');
        	insert opptline;
        
        apexpages.StandardController sc = new apexpages.StandardController(opptline);
        EditProductLineItemCtrlSingle app = new EditProductLineItemCtrlSingle(sc);
        pagereference pa2 = app.dosave();

        test.stopTest();
        
    }
    
    static testmethod void negativeMobile()
    {
        test.startTest();
        
        setInitial();
        opportunitylineitem opptline = new opportunitylineitem(opportunityid = oppt.id, quantity = 1.00, pricebookentryid = pbe.id,unitprice=1.00
                                                               ,RevisedStartMonth__c='JAN',RevisedStartMonthFee__c='JAN');
        	insert opptline;
        
        apexpages.StandardController sc = new apexpages.StandardController(opptline);
        EditProductLineItemCtrlSingle app = new EditProductLineItemCtrlSingle(sc);
        app.dosaveMobile();

        test.stopTest();
        
    }
    
    static testmethod void negative2()
    {
        test.startTest();
        
        setInitial();
        opportunitylineitem opptline = new opportunitylineitem(opportunityid = oppt.id, quantity = 1.00, pricebookentryid = pbe.id,unitprice=1.00
                                                               ,Tenor_Years__c=-1,Expected_Util_Year_NI__c=101);
        	insert opptline;
        
        apexpages.StandardController sc = new apexpages.StandardController(opptline);
        EditProductLineItemCtrlSingle app = new EditProductLineItemCtrlSingle(sc);
        pagereference pa2 = app.dosave();

        test.stopTest();
        
    }
    
    static testmethod void negativeMobile2()
    {
        test.startTest();
        
        setInitial();
        opportunitylineitem opptline = new opportunitylineitem(opportunityid = oppt.id, quantity = 1.00, pricebookentryid = pbe.id,unitprice=1.00
                                                               ,Tenor_Years__c=-1,Expected_Util_Year_NI__c=101);
        	insert opptline;
        
        apexpages.StandardController sc = new apexpages.StandardController(opptline);
        EditProductLineItemCtrlSingle app = new EditProductLineItemCtrlSingle(sc);
        app.dosaveMobile();

        test.stopTest();
        
    }
    
}