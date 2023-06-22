@isTest
public class AddProductLineItemControllerTest {
    
    static {
        TestUtils.createIdType();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();
        TestUtils.createDisqualifiedReason();
        //TestUtils.CreateTriggerMsg();
        TestInit.createCustomSettingStageApproval();
        
    }
    
    public static Id pb1 {get{return Test.getStandardPricebookId();}set;}
    public static pricebook2 pb2 {get;set;}
    public static product2 prod {get;set;}
    public static pricebookentry pbe {get;set;}
    public static account acct {get;set;}
    public static opportunity oppt {get;set;} 
    public static void setInitial()
    {
        insert new status_code__c(name = '8004', Status_Message__c = 'test');
        insert new status_code__c(name = '8008', Status_Message__c = 'test');
        insert new status_code__c(name = '8011', Status_Message__c = 'test');
        insert new status_code__c(name = '8015', Status_Message__c = 'test');
        insert new status_code__c(name = '8057', Status_Message__c = 'test');
        insert new AppConfig__c(name = 'runtrigger', value__c = 'TRUE');
        insert new Trigger_Msg__c(name = 'Permission_Create_Opportunity', Description__c   = 'description');
        insert new Account_Plan_Fiscal_Year__c(name='2',ad_year__c='2015',be_year__c='2558');
        user u = [select segment__c from user where id =: userinfo.getUserId()];
        if (u.segment__c != null) insert new Price_book_access__c(name=u.segment__c,PricebookItem__c='test');
        else insert new Price_book_access__c(name='MB',PricebookItem__c='test');
        insert new Price_book_access__c(name='Default',PricebookItem__c='test');
        
        pb2 = new pricebook2(name='test',isActive=true,TMB_Pricebook__c='test');insert pb2;
        prod = new product2(name='test',isactive=true,Product_Domain__c='Risk');insert prod;
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
                                                               ,RevisedStartMonth__c='Dec',RevisedStartYear__c=string.valueof(system.today()).substring(0,4)
                                                               ,RevisedStartMonthFee__c='Dec',RevisedStartYearFee__c=string.valueof(system.today()).substring(0,4)
                                                               ,Type_Of_Reference__c='NIIc',Type_Of_Reference_Fee__c='AS Fee');
          insert opptline;
        
        apexpages.StandardController sc = new apexpages.StandardController(oppt);
        AddProductLineItemController app = new AddProductLineItemController(sc);
		app.pricebookid = pb1;
        app.productdomainselected = '1';
        app.productdomainselect();
        app.productdomainselected = '2';
        app.productdomainselect();
        app.productdomainselected = '3';
        app.productdomainselect();
        app.productdomainselected = '4';
        app.productdomainselect();

        Test.setCurrentPage(Page.AddProductLineItem);
        app.SelectDomain();
        list<selectoption> listSelect = app.getFiscalYear();
        
        for(opportunitylineitem o: app.optLine)
        {
            o.RevisedStartMonth__c = 'Jan';
            o.RevisedStartYear__c = string.valueof(system.today()).substring(0,4);
            o.RevisedStartMonthFee__c = 'Jan';
            o.RevisedStartYearFee__c = string.valueof(system.today()).substring(0,4);
        }
        app.dosave();
		opptline.RevisedStartMonth__c = 'Jan';
        opptline.RevisedStartMonthFee__c = 'Jan';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        opptline.RevisedStartMonth__c = 'Feb';
        opptline.RevisedStartMonthFee__c = 'Feb';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
       	opptline.Frequency__c = 'Monthly';
        opptline.RevisedStartMonth__c = 'Mar';
        opptline.RevisedStartMonthFee__c = 'Mar';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
       	opptline.Frequency__c = 'Quarterly';
        opptline.RevisedStartMonth__c = 'Apr';
        opptline.RevisedStartMonthFee__c = 'Apr';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        opptline.Frequency__c = 'Half-yearly';
        opptline.RevisedStartMonth__c = 'May';
        opptline.RevisedStartMonthFee__c = 'May';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        opptline.Frequency__c = 'Monthly';
        opptline.RevisedStartMonth__c = 'Jun';
        opptline.RevisedStartMonthFee__c = 'Jun';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        opptline.Frequency__c = 'Annually';
        opptline.RevisedStartMonth__c = 'Jul';
        opptline.RevisedStartMonthFee__c = 'Jul';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        opptline.RevisedStartMonth__c = 'Aug';
        opptline.RevisedStartMonthFee__c = 'Aug';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        opptline.RevisedStartMonth__c = 'Sep';
        opptline.RevisedStartMonthFee__c = 'Sep';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        opptline.RevisedStartMonth__c = 'Oct';
        opptline.RevisedStartMonthFee__c = 'Oct';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        opptline.RevisedStartMonth__c = 'Nov';
        opptline.RevisedStartMonthFee__c = 'Nov';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        opptline.RevisedStartMonth__c = 'Dec';
        opptline.RevisedStartMonthFee__c = 'Dec';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        
        test.stopTest();
        
    }
    
    static testmethod void positiveMobile()
    {
        test.startTest();
        
        setInitial();
        opportunitylineitem opptline = new opportunitylineitem(opportunityid = oppt.id, quantity = 1.00, pricebookentryid = pbe.id,unitprice=1.00
                                                               ,RevisedStartMonth__c='Dec',RevisedStartYear__c=string.valueof(system.today()).substring(0,4)
                                                               ,RevisedStartMonthFee__c='Dec',RevisedStartYearFee__c=string.valueof(system.today()).substring(0,4)
                                                               ,Type_Of_Reference__c='NIIc',Type_Of_Reference_Fee__c='AS Fee');
          insert opptline;
        
        apexpages.StandardController sc = new apexpages.StandardController(oppt);
        AddProductLineItemController app = new AddProductLineItemController(sc);

        app.pricebookid = pb1;
        app.productdomainselected = '4';
        app.productdomainselect();
        Test.setCurrentPage(Page.AddProductLineItemMobile);
        app.SelectDomain();
        
        for(opportunitylineitem o: app.optLine)
        {
            o.RevisedStartMonth__c = 'Jan';
            o.RevisedStartYear__c = string.valueof(system.today()).substring(0,4);
            o.RevisedStartMonthFee__c = 'Jan';
            o.RevisedStartYearFee__c = string.valueof(system.today()).substring(0,4);
        }
        app.dosaveMobile();

        test.stopTest();
        
    }
    
    static testmethod void negative()
    {
        test.startTest();

        setInitial();
        opportunitylineitem opptline = new opportunitylineitem(opportunityid = oppt.id, quantity = 1.00, pricebookentryid = pbe.id,unitprice=1.00
                                                               ,RevisedStartMonth__c='Dec',RevisedStartYear__c=string.valueof(system.today()).substring(0,4)
                                                               ,RevisedStartMonthFee__c='Dec',RevisedStartYearFee__c=string.valueof(system.today()).substring(0,4)
                                                               ,Type_Of_Reference__c='NIIc',Type_Of_Reference_Fee__c='AS Fee');
          insert opptline;
        
        apexpages.StandardController sc = new apexpages.StandardController(oppt);
        AddProductLineItemController app = new AddProductLineItemController(sc);
        app.pricebookid = pb1;
        app.productdomainselected = '4';
        app.productdomainselect();
        Test.setCurrentPage(Page.AddProductLineItem);
        app.SelectDomain();
        
        for(opportunitylineitem o: app.optLine)
        {
            o.UnitPrice = -1;
            o.Expected_Util_Year_NI__c = 101;
        }
        app.dosave();
		opptline.RevisedStartMonth__c = 'Jan';
        opptline.RevisedStartMonthFee__c = 'Jan';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        opptline.RevisedStartMonth__c = 'Feb';
        opptline.RevisedStartMonthFee__c = 'Feb';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
       	opptline.Frequency__c = 'Monthly';
        opptline.RevisedStartMonth__c = 'Mar';
        opptline.RevisedStartMonthFee__c = 'Mar';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
       	opptline.Frequency__c = 'Quarterly';
        opptline.RevisedStartMonth__c = 'Apr';
        opptline.RevisedStartMonthFee__c = 'Apr';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        opptline.Frequency__c = 'Half-yearly';
        opptline.RevisedStartMonth__c = 'May';
        opptline.RevisedStartMonthFee__c = 'May';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        opptline.Frequency__c = 'Monthly';
        opptline.RevisedStartMonth__c = 'Jun';
        opptline.RevisedStartMonthFee__c = 'Jun';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        opptline.Frequency__c = 'Annually';
        opptline.RevisedStartMonth__c = 'Jul';
        opptline.RevisedStartMonthFee__c = 'Jul';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        opptline.RevisedStartMonth__c = 'Aug';
        opptline.RevisedStartMonthFee__c = 'Aug';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        opptline.RevisedStartMonth__c = 'Sep';
        opptline.RevisedStartMonthFee__c = 'Sep';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        opptline.RevisedStartMonth__c = 'Oct';
        opptline.RevisedStartMonthFee__c = 'Oct';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        opptline.RevisedStartMonth__c = 'Nov';
        opptline.RevisedStartMonthFee__c = 'Nov';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        opptline.RevisedStartMonth__c = 'Dec';
        opptline.RevisedStartMonthFee__c = 'Dec';
        app.calculateNIBreakdown(250000,opptline);
        app.calculateFeeBreakdown(250000,opptline);
        
        test.stopTest();
        
    }
    
    static testmethod void negativeMobile()
    {
        test.startTest();
        
        setInitial();
        opportunitylineitem opptline = new opportunitylineitem(opportunityid = oppt.id, quantity = 1.00, pricebookentryid = pbe.id,unitprice=1.00
                                                               ,RevisedStartMonth__c='Dec',RevisedStartYear__c=string.valueof(system.today()).substring(0,4)
                                                               ,RevisedStartMonthFee__c='Dec',RevisedStartYearFee__c=string.valueof(system.today()).substring(0,4)
                                                               ,Type_Of_Reference__c='NIIc',Type_Of_Reference_Fee__c='AS Fee');
          insert opptline;
        
        apexpages.StandardController sc = new apexpages.StandardController(oppt);
        AddProductLineItemController app = new AddProductLineItemController(sc);
        app.pricebookid = pb1;
        app.productdomainselected = '4';
        app.productdomainselect();
        Test.setCurrentPage(Page.AddProductLineItemMobile);
        app.SelectDomain();
        
        for(opportunitylineitem o: app.optLine)
        {
            o.UnitPrice = -1;
            o.Expected_Util_Year_NI__c = 101;
        }
        app.dosaveMobile();

        test.stopTest();
        
    }
    
    static testmethod void negative2()
    {
        test.startTest();
        
        setInitial();
        opportunitylineitem opptline = new opportunitylineitem(opportunityid = oppt.id, quantity = 1.00, pricebookentryid = pbe.id,unitprice=1.00
                                                               ,Tenor_Years__c=-1,Expected_Util_Year_NI__c=101
                                                               ,RevisedStartMonth__c='Dec',RevisedStartYear__c=string.valueof(system.today()).substring(0,4)
                                                               ,RevisedStartMonthFee__c='Dec',RevisedStartYearFee__c=string.valueof(system.today()).substring(0,4)
                                                               ,Type_Of_Reference__c='NIIc',Type_Of_Reference_Fee__c='AS Fee');
          insert opptline;
        
        apexpages.StandardController sc = new apexpages.StandardController(oppt);
        AddProductLineItemController app = new AddProductLineItemController(sc);
        app.pricebookid = pb1;
        app.productdomainselected = '4';
        app.productdomainselect();
        Test.setCurrentPage(Page.AddProductLineItem);
        app.SelectDomain();
        
        for(opportunitylineitem o: app.optLine)
        {
            o.RevisedStartMonth__c = 'Jan';
        }
        app.dosave();

        test.stopTest();
        
    }
    
    static testmethod void negativeMobile2()
    {
        test.startTest();
        
        setInitial();
        opportunitylineitem opptline = new opportunitylineitem(opportunityid = oppt.id, quantity = 1.00, pricebookentryid = pbe.id,unitprice=1.00
                                                               ,Tenor_Years__c=-1,Expected_Util_Year_NI__c=101
                                                               ,RevisedStartMonth__c='Dec',RevisedStartYear__c=string.valueof(system.today()).substring(0,4)
                                                               ,RevisedStartMonthFee__c='Dec',RevisedStartYearFee__c=string.valueof(system.today()).substring(0,4)
                                                               ,Type_Of_Reference__c='NIIc',Type_Of_Reference_Fee__c='AS Fee');
          insert opptline;
        
        apexpages.StandardController sc = new apexpages.StandardController(oppt);
        AddProductLineItemController app = new AddProductLineItemController(sc);
        app.pricebookid = pb1;
        app.productdomainselected = '4';
        app.productdomainselect();
        Test.setCurrentPage(Page.AddProductLineItemMobile);
        app.SelectDomain();
        
        for(opportunitylineitem o: app.optLine)
        {
            o.RevisedStartMonth__c = 'Jan';
        }
        app.dosaveMobile();

        test.stopTest();
        
    }
    
}