@IsTest
public class newDealSummaryCtlTest {

    public static testmethod void testRun() {
        Test.startTest();
        TestUtils.createAppConfig();
        User gurs = [Select Id, UserRoleId from user where id =: UserInfo.getUserId()];

        Account acct = TestUtils.createAccounts(1,'TESTACCOUNT','Individual', true).get(0);
        List<Opportunity> opptyList = TestUtils.createOpportunity(2,acct.id,true );
       
        list<Opportunity> updateOpptyList = new List<Opportunity>();
        Opportunity oppty =  opptyList.get(0);
        oppty.Application_Status__c = 'Pitching';
        oppty.Probability = 10;
        oppty.OwnerId = gurs.id;
        updateOpptyList.add(oppty);

        Opportunity oppty2 =  opptyList.get(1);
        oppty2.Application_Status__c = null;       
        oppty2.OwnerId = gurs.id;
        updateOpptyList.add(oppty2);

        update updateOpptyList;


        List<Product2> proList =  TestUtils.createProduct(1,true);
        Product2 pro = proList.get(0);
        Id pricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> listpriceBook = TestUtils.createPricebookEntry(1,pricebookId, proList , true );
        OpportunityLineItem oppLineitem = TestUtils.createOpportunityProduct(1,oppty.id, listpriceBook, true).get(0);

       
        Deal_Forecast_Income__c dealForecast = new Deal_Forecast_Income__c();
        dealForecast.Customer__c = acct.id;
        dealForecast.Opportunity__c = oppty.id;
        dealForecast.Product__c = pro.id;
        dealForecast.Frequency__c = 'Monthly';
        dealForecast.Income_Type__c = 'NIIc';
        dealForecast.Last_Update_Adjustment__c = system.now();
        dealForecast.OpportunityLineItem_Limit_Volume__c = 32000;
        dealForecast.NI_Amount__c = 40000;
        dealForecast.NIM_Fee_rate__c = 20;      
        dealForecast.Probability__c = 'High';
        dealForecast.Product_Group__c = 'Deposit';
        dealForecast.Opportunity_Product_Id__c = oppLineitem.id;
        dealForecast.Volume__c = 3000;
        insert dealForecast;


        list<Monthly_Forecast_Input__c> monthlyInputList = new List<Monthly_Forecast_Input__c>();
        DateTime pointer = DateTime.now();


        for(integer i = 0; i < 12; i++){
            Date monthDate = date.newinstance(pointer.year(), pointer.month(), pointer.day());
            Monthly_Forecast_Input__c monthlyInput = New Monthly_Forecast_Input__c();
            monthlyInput.Account_Suffix_Ref__c = 'tZZ0822'+i;
            monthlyInput.Actual_NIM__c = 20;
            monthlyInput.NI__c = 400;
            monthlyInput.Year__c = monthDate.Year()+'';
            monthlyInput.Deal_Forecast_Income__c = dealForecast.id;
            monthlyInput.adjustMonthYear__c = monthDate;
            monthlyInput.Customer__c = acct.id;
            monthlyInput.Opportunity__c = oppty.id;
            monthlyInput.Product__c = pro.id;
            monthlyInput.YearMonthAcctSuffRef__c = 'ABC'+monthDate.Year()+i+'OK';
            monthlyInputList.add(monthlyInput);
            pointer = pointer.addDays(30);
        }
        insert monthlyInputList;

        
        newDealSummaryCtl.getCurrentFYYear();
        newDealSummaryCtl.monthHeader();
        newDealSummaryCtl.fetchOppAppStatus();
        newDealSummaryCtl.getNewDealForecast('');
        newDealSummaryCtl.getNewDealForecast('All Null Status');
        newDealSummaryCtl.getNewDealForecast('Pitching');

        Test.stopTest();
    }
}