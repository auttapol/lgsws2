@isTest
public class EditProductLineItemCtrlSingle2Test {
    
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
        insert new status_code__c(name = '8008', Status_Message__c = 'test');
        insert new status_code__c(name = '8015', Status_Message__c = 'test');
        insert new status_code__c(name = '8057', Status_Message__c = 'test');
        insert new AppConfig__c(name = 'runtrigger', value__c = 'TRUE');
        insert new Trigger_Msg__c(name = 'Permission_Create_Opportunity', Description__c   = 'description');
        insert new Account_Plan_Fiscal_Year__c(name='2',ad_year__c='2015',be_year__c='2558');
        
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
        EditProductLineItemCtrlSingle2 app = new EditProductLineItemCtrlSingle2(sc);
        pagereference pa = app.back();
        list<selectoption> listSelect = app.getFiscalYear();
        app.dosave();
        app.back(); 
		app.OptLine.get(0).RevisedStartMonth__c = 'Jan';
        app.OptLine.get(0).RevisedStartMonthFee__c = 'Jan';
        app.calculateNIBreakdown(250000);
        app.calculateFeeBreakdown(250000);
        app.OptLine.get(0).RevisedStartMonth__c = 'Feb';
        app.OptLine.get(0).RevisedStartMonthFee__c = 'Feb';
        app.calculateNIBreakdown(250000);
        app.calculateFeeBreakdown(250000);
        app.OptLine.get(0).Frequency__c = 'Monthly';
        app.OptLine.get(0).RevisedStartMonth__c = 'Mar';
        app.OptLine.get(0).RevisedStartMonthFee__c = 'Mar';
        app.calculateNIBreakdown(250000);
        app.calculateFeeBreakdown(250000);
        app.OptLine.get(0).Frequency__c = 'Quarterly';
        app.OptLine.get(0).RevisedStartMonth__c = 'Apr';
        app.OptLine.get(0).RevisedStartMonthFee__c = 'Apr';
        app.calculateNIBreakdown(250000);
        app.calculateFeeBreakdown(250000);
        app.OptLine.get(0).Frequency__c = 'Half-yearly';
        app.OptLine.get(0).RevisedStartMonth__c = 'May';
        app.OptLine.get(0).RevisedStartMonthFee__c = 'May';
        app.calculateNIBreakdown(250000);
        app.calculateFeeBreakdown(250000);
        app.OptLine.get(0).Frequency__c = 'Monthly';
        app.OptLine.get(0).RevisedStartMonth__c = 'Jun';
        app.OptLine.get(0).RevisedStartMonthFee__c = 'Jun';
        app.calculateNIBreakdown(250000);
        app.calculateFeeBreakdown(250000);
        app.OptLine.get(0).Frequency__c = 'Annually';
        app.OptLine.get(0).RevisedStartMonth__c = 'Jul';
        app.OptLine.get(0).RevisedStartMonthFee__c = 'Jul';
        app.calculateNIBreakdown(250000);
        app.calculateFeeBreakdown(250000);
        app.OptLine.get(0).RevisedStartMonth__c = 'Aug';
        app.OptLine.get(0).RevisedStartMonthFee__c = 'Aug';
        app.calculateNIBreakdown(250000);
        app.calculateFeeBreakdown(250000);
        app.OptLine.get(0).RevisedStartMonth__c = 'Sep';
        app.OptLine.get(0).RevisedStartMonthFee__c = 'Sep';
        app.calculateNIBreakdown(250000);
        app.calculateFeeBreakdown(250000);
        app.OptLine.get(0).RevisedStartMonth__c = 'Oct';
        app.OptLine.get(0).RevisedStartMonthFee__c = 'Oct';
        app.calculateNIBreakdown(250000);
        app.calculateFeeBreakdown(250000);
        app.OptLine.get(0).RevisedStartMonth__c = 'Nov';
        app.OptLine.get(0).RevisedStartMonthFee__c = 'Nov';
        app.calculateNIBreakdown(250000);
        app.calculateFeeBreakdown(250000);
        app.OptLine.get(0).RevisedStartMonth__c = 'Dec';
        app.OptLine.get(0).RevisedStartMonthFee__c = 'Dec';
        app.calculateNIBreakdown(250000);
        app.calculateFeeBreakdown(250000);

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
        EditProductLineItemCtrlSingle2 app = new EditProductLineItemCtrlSingle2(sc);
        app.dosave();

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
        EditProductLineItemCtrlSingle2 app = new EditProductLineItemCtrlSingle2(sc);
        app.dosave();

        test.stopTest();
        
    }
    
   
    
}