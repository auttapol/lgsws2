@isTest
public class SLOSAddproductExtensionTest {
    
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
    public static host_product_mapping__c hostmap {get;set;}
    public static void setInitial()
    {
        insert new status_code__c(name = '8004', Status_Message__c = 'test');
        insert new status_code__c(name = '8008', Status_Message__c = 'test');
        insert new status_code__c(name = '8011', Status_Message__c = 'test');
        insert new status_code__c(name = '8015', Status_Message__c = 'test');
        insert new status_code__c(name = '8023', Status_Message__c = 'test');
        insert new status_code__c(name = '8057', Status_Message__c = 'test');
        insert new AppConfig__c(name = 'runtrigger', value__c = 'TRUE');
        insert new Trigger_Msg__c(name = 'Permission_Create_Opportunity', Description__c   = 'description');
        insert new Account_Plan_Fiscal_Year__c(name='2',ad_year__c='2015',be_year__c='2558');
        user u = [select segment__c from user where id =: userinfo.getUserId()];
        if (u.segment__c != null){ 
            insert new Price_book_access__c(name=u.segment__c,PricebookItem__c='test');
        }
        else insert new Price_book_access__c(name='MB',PricebookItem__c='test');
        insert new Price_book_access__c(name='Default',PricebookItem__c='test');
        
        pb2 = new pricebook2(name='test',isActive=true,TMB_Pricebook__c='test');
        insert pb2;
        prod = new product2(name='test',isactive=true,Product_Domain__c='Risk');
        insert prod;
        pbe = new pricebookentry(isactive=true,unitprice=1.00,product2id=prod.id,pricebook2id=pb1,usestandardprice=false);
        insert pbe;
        
        acct = testutils.createAccounts(1, 'fname', 'Individual', true).get(0);
        oppt = new opportunity(Pricebook2Id=pb1,accountid = acct.id, name='test', ownerid = acct.ownerid,
                               Expected_submit_date__c = date.today(), closedate = date.today(),
                               stagename = 'Analysis');
        insert oppt;
		
        hostmap = new Host_Product_Mapping__c(Active_Flag__c=true,Host_Name__c='SLS',
                                              Host_Product_Group__c='TMB SME SmartBiz',
                                             Product_Program__c='TMB SME SmartBiz',Credit_Type_ID__c='102',
                                             Host_Prod_Name_Credit_Facility__c ='OD for Floating Charge',Product_Group_ID__c='1',
                                             Product_Program_ID__c='1',Salesforce_Product__c=prod.id);
     	insert hostmap;  
    }
    
    static testmethod void positive()
    {
        test.startTest();
        
        setInitial();
        
        
        opportunitylineitem opptline = new opportunitylineitem(opportunityid = oppt.id, quantity = 1.00, pricebookentryid = pbe.id,unitprice=1.00
                                                               ,RevisedStartMonth__c='Dec',RevisedStartYear__c=string.valueof(system.today()).substring(0,4)
                                                               ,RevisedStartMonthFee__c='Dec',RevisedStartYearFee__c=string.valueof(system.today()).substring(0,4)
                                                               ,Type_Of_Reference__c='NIIc',Type_Of_Reference_Fee__c='AS Fee'
                                                               ,host_product_mapping__c=hostmap.id
                                                              );
          insert opptline;

         SLOSDataset.DataSet1();
        
        oppt.Host_System__c ='SLS';
        update oppt;
        apexpages.StandardController sc = new apexpages.StandardController(oppt);
        SLOSAddproductExtension app = new SLOSAddproductExtension(sc);
        app.hostTemp = hostmap;
        app.displayProduct();
        app.addProduct();
        app.redirectDeskTop();

        
            app.oppProd.RevisedStartMonth__c = 'Jan';
            app.oppProd.RevisedStartYear__c = string.valueof(system.today()).substring(0,4);
            app.oppProd.RevisedStartMonthFee__c = 'Jan';
            app.oppProd.RevisedStartYearFee__c = string.valueof(system.today()).substring(0,4);
        
        app.openBreakdown();
        
        
        pageReference pr = app.updateProductGroup();
        app.oppProd.RevisedStartMonth__c = 'Jan';
        app.calculateNIBreakdown(300000.00);
        app.oppProd.RevisedStartMonth__c = 'Feb';
        app.oppProd.Frequency__c = 'Monthly';
        app.calculateNIBreakdown(300000.00);
        app.oppProd.RevisedStartMonth__c = 'Mar';
        app.oppProd.Frequency__c = 'Half-yearly';
        app.calculateNIBreakdown(300000.00);
        app.oppProd.RevisedStartMonth__c = 'Apr';
        app.oppProd.Frequency__c = 'Annually';
        app.calculateNIBreakdown(300000.00);
        app.oppProd.RevisedStartMonth__c = 'May';
        app.calculateNIBreakdown(300000.00);
        app.oppProd.RevisedStartMonth__c = 'Jun';
        app.calculateNIBreakdown(300000.00);
        app.oppProd.RevisedStartMonth__c = 'Jul';
        app.calculateNIBreakdown(300000.00);
        app.oppProd.RevisedStartMonth__c = 'Aug';
        app.calculateNIBreakdown(300000.00);
        app.oppProd.RevisedStartMonth__c = 'Sep';
        app.calculateNIBreakdown(300000.00);
        app.oppProd.RevisedStartMonth__c = 'Oct';
        app.calculateNIBreakdown(300000.00);
        app.oppProd.RevisedStartMonth__c = 'Nov';
        app.calculateNIBreakdown(300000.00);
        app.oppProd.RevisedStartMonth__c = 'Dec';
        app.calculateNIBreakdown(300000.00);
        
        
        
        app.calculateFeeBreakdown(300000.00);
        
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
         SLOSDataset.DataSet1();
        apexpages.StandardController sc = new apexpages.StandardController(oppt);
        SLOSAddproductExtension app = new SLOSAddproductExtension(sc);
        
        //app.displayProduct();
        app.addProduct();
        app.redirectDeskTop();
        
        app.oppProd.UnitPrice = -1;
            app.oppProd.Expected_Util_Year_NI__c = 101;
        
        app.dosave();

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
         SLOSDataset.DataSet1();
        apexpages.StandardController sc = new apexpages.StandardController(oppt);
        SLOSAddproductExtension app = new SLOSAddproductExtension(sc);
        app.displayProduct();
        app.addProduct();
        app.redirectDeskTop();
        
        app.oppProd.RevisedStartMonth__c = 'Jan';
        app.oppProd.UnitPrice = -1;
        app.oppProd.Tenor_Years__c = -2;
        app.dosave();

        test.stopTest();
        
    }
    
    
}