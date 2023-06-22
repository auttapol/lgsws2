@IsTest
public class OpoortunityLineItemBreakDownTest {

    public static testmethod void positiveTest(){
        test.startTest();
        insert new AppConfig__c(name = 'runtrigger', value__c = 'TRUE');
        insert new Status_Code__c(name = '8061a', status_message__c = '');
        insert new Status_Code__c(name = '8061b', status_message__c = '');
        TestUtils.createAppConfigRetailtoComm();
        account acct = testutils.createAccounts(1, 'fname', 'Individual', true).get(0);
        Id pb1 = Test.getStandardPricebookId();
        product2 prod = new product2(name='testtesttesttest',isactive=true,Product_Domain__c='Risk');
            insert prod;
        pricebookentry pbe = new pricebookentry(isactive=true,unitprice=1.00,product2id=prod.id,pricebook2id=pb1,usestandardprice=false);
            insert pbe;
        opportunity oppt = new opportunity(accountid = acct.id, name='test', ownerid = acct.ownerid, Expected_submit_date__c = date.today(), closedate = date.today()
                                          ,host_system__c ='SLS',stagename = 'Analysis');
            insert oppt;
        opportunitylineitem opptline = new opportunitylineitem(opportunityid = oppt.id, quantity = 1.00, pricebookentryid = pbe.id,unitprice=1.00
                                                               ,RevisedStartYearFee__c = string.valueof(system.today()).substring(0,4), RevisedStartYear__c = string.valueof(system.today()).substring(0,4)
                                                               ,RevisedStartMonthFee__c = 'Dec', RevisedStartMonth__c = 'Dec'
                                                               ,Type_Of_Reference__c = 'NIIc', Type_Of_Reference_Fee__c = 'AS Fee'
                                                               ,isNiBreakdownCalculate__c = true, isFeeBreakdownCalculate__c = true
                                                               ,This_Year_Expected_NI__c = 1000.05, This_Year_Expected_Fee__c = 1000.05);
            insert opptline;
        opportunitylineitem opptline2 = new opportunitylineitem(opportunityid = oppt.id, quantity = 1.00, pricebookentryid = pbe.id,unitprice=1.00
                                                               ,RevisedStartYearFee__c = string.valueof(system.today()).substring(0,4), RevisedStartYear__c = string.valueof(system.today()).substring(0,4)
                                                               ,RevisedStartMonthFee__c = 'Dec', RevisedStartMonth__c = 'Dec'
                                                               ,Type_Of_Reference__c = 'NIIc', Type_Of_Reference_Fee__c = 'AS Fee');
            insert opptline2;

        PageReference pageRef = new pageReference('/apex/OppProductBreakDown?listoppprodid='+opptline.id+','+opptline2.id+'&Referer=closewon&prevPageNo=1&niNewValue=3000&feeNewValue=3999');
        Test.setCurrentPage(pageRef);
 		OpportunityLineItemBreakDownController app = new OpportunityLineItemBreakDownController();
        
        app.cancel();
        app.save();
        app.validateExpected();
        
        test.stopTest();
    }
    
}