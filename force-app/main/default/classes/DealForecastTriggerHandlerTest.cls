@isTest
public class DealForecastTriggerHandlerTest {
    public static testmethod void teatInsertTrigger() {
        Test.startTest();
        DealForecastTriggerHandler dfth = new DealForecastTriggerHandler();
        testutils.createAppConfig();
        Id pricebookId = Test.getStandardPricebookId();
        Campaign camp = new Campaign();
            camp.Name = 'Campaign_1';
            camp.Segment__c = 'SE';
            camp.OwnerId  = userinfo.getUserId();
        	insert camp;
        list<account> listacc = testutils.createAccounts(1,'f','Individual',true);
        list<opportunity> listopp = testutils.createOpportunity(2,listacc.get(0).id,true);
        	listopp.get(0).campaignid = camp.id;
        	listopp.get(1).campaignid = camp.id;
        	update listopp;
        list<product2> listpro = testutils.createProduct(1,true);
        list<pricebookentry> listpricebook = testutils.createPricebookEntry(1,pricebookId,listpro,true);
        list<OpportunityLineItem> listoppline = testutils.createOpportunityProduct(1,listopp.get(0).id,listpricebook,true);
        
        Deal_Forecast_Income__c deal1 = new Deal_Forecast_Income__c();
        deal1.Customer__c = listacc.get(0).Id;
        deal1.Opportunity__c = listopp.get(0).Id;
        deal1.Opportunity_Product_Id__c = listoppline.get(0).Id;
        deal1.Product__c = listpro.get(0).Id;
        deal1.OpportunityLineItem_Limit_Volume__c = 1000000;
        deal1.Probability__c = 'Low';
        deal1.Volume__c = 1000000;
        insert deal1;
        
        list<Deal_Forecast_Income__c> listnewDeal = [select id,Customer__c,Volume__c,Opportunity__c,Opportunity_Product_Id__c,Product__c
                                                		from Deal_Forecast_Income__c where id =: deal1.id];

        DealForecastTriggerHandler.generateForecastInput(listnewDeal);
            
        Test.stopTest();
    }
    public static testmethod void teatUpdateTrigger() {
        Test.startTest();
        DealForecastTriggerHandler dfth = new DealForecastTriggerHandler();
        testutils.createAppConfig();
        Id pricebookId = Test.getStandardPricebookId();
        Campaign camp = new Campaign();
            camp.Name = 'Campaign_1';
            camp.Segment__c = 'SE';
            camp.OwnerId  = userinfo.getUserId();
        	insert camp;
        list<account> listacc = testutils.createAccounts(1,'f','Individual',true);
        list<opportunity> listopp = testutils.createOpportunity(2,listacc.get(0).id,true);
        	listopp.get(0).campaignid = camp.id;
        	listopp.get(1).campaignid = camp.id;
        	update listopp;
        list<product2> listpro = testutils.createProduct(1,true);
        list<pricebookentry> listpricebook = testutils.createPricebookEntry(1,pricebookId,listpro,true);
        list<OpportunityLineItem> listoppline = testutils.createOpportunityProduct(1,listopp.get(0).id,listpricebook,true);
        
        Deal_Forecast_Income__c deal1 = new Deal_Forecast_Income__c();
        deal1.Customer__c = listacc.get(0).Id;
        deal1.Opportunity__c = listopp.get(0).Id;
        deal1.Opportunity_Product_Id__c = listoppline.get(0).Id;
        deal1.Product__c = listpro.get(0).Id;
        deal1.OpportunityLineItem_Limit_Volume__c = 1000000;
        deal1.Probability__c = 'Low';
        deal1.Volume__c = 1000000;
        insert deal1;
        
        Id RTNewDeal = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('New Deal').getRecordTypeId();
        Monthly_Forecast_Input__c forecastInput = new Monthly_Forecast_Input__c();
        forecastInput.Deal_Forecast_Income__c = deal1.id;
        forecastInput.RecordTypeId = RTNewDeal;
        forecastInput.Ending_Balance__c = 1000000;
        forecastInput.Customer__c = listacc.get(0).Id;
        forecastInput.Opportunity__c = listopp.get(0).Id;
        forecastInput.OpportunityLineItem_Id__c = listoppline.get(0).Id;
        forecastInput.Product__c = listpro.get(0).Id;
        forecastInput.adjustMonthYear__c = Date.Today();
        forecastInput.Year__c = String.valueOf(Date.Today().Year());
        forecastInput.Month__c = Date.Today().Month() < 10 ? '0' + String.valueOf(Date.Today().Month()) : String.valueOf(Date.Today().Month());
        
        forecastInput.Account_Suffix_Ref__c = forecastInput.OpportunityLineItem_Id__c; 
        forecastInput.YearMonthAcctSuffRef__c = forecastInput.Year__c + forecastInput.Month__c + deal1.Id + forecastInput.OpportunityLineItem_Id__c;
        insert forecastInput;
        
        map<Id, Deal_Forecast_Income__c> listnewDeal = new map<Id, Deal_Forecast_Income__c>([select id,Opportunity_Product_Id__c,Probability__c,OpportunityLineItem_Limit_Volume__c,Volume__c 
                                                		from Deal_Forecast_Income__c where id =: deal1.id]);
        
        map<Id, Deal_Forecast_Income__c> listnewDeal2 = listnewDeal;
        listnewDeal.get(deal1.id).OpportunityLineItem_Limit_Volume__c = 2000000;
        listnewDeal.get(deal1.id).Probability__c = 'Medium';
        listnewDeal.get(deal1.id).Volume__c = 2000000;
        update listnewDeal.values();
        
        map<Id, Deal_Forecast_Income__c> listnewDeal3 = new map<Id, Deal_Forecast_Income__c>([select id,Opportunity_Product_Id__c,Probability__c,OpportunityLineItem_Limit_Volume__c,Volume__c 
                                                		from Deal_Forecast_Income__c where id =: deal1.id]);
        
        
        DealForecastTriggerHandler.updateOpportunitylineitem(listnewDeal2, listnewDeal3);
        DealForecastTriggerHandler.updateForecastInput(listnewDeal3);
            
        Test.stopTest();
    }
    public static testmethod void teatDeleteTrigger() {
        Test.startTest();
        DealForecastTriggerHandler dfth = new DealForecastTriggerHandler();
        testutils.createAppConfig();
        Id pricebookId = Test.getStandardPricebookId();
        Campaign camp = new Campaign();
            camp.Name = 'Campaign_1';
            camp.Segment__c = 'SE';
            camp.OwnerId  = userinfo.getUserId();
        	insert camp;
        list<account> listacc = testutils.createAccounts(1,'f','Individual',true);
        list<opportunity> listopp = testutils.createOpportunity(2,listacc.get(0).id,true);
        	listopp.get(0).campaignid = camp.id;
        	listopp.get(1).campaignid = camp.id;
        	update listopp;
        list<product2> listpro = testutils.createProduct(1,true);
        list<pricebookentry> listpricebook = testutils.createPricebookEntry(1,pricebookId,listpro,true);
        list<OpportunityLineItem> listoppline = testutils.createOpportunityProduct(1,listopp.get(0).id,listpricebook,true);
        
        Deal_Forecast_Income__c deal1 = new Deal_Forecast_Income__c();
        deal1.Customer__c = listacc.get(0).Id;
        deal1.Opportunity__c = listopp.get(0).Id;
        deal1.Opportunity_Product_Id__c = listoppline.get(0).Id;
        deal1.Product__c = listpro.get(0).Id;
        deal1.OpportunityLineItem_Limit_Volume__c = 1000000;
        deal1.Probability__c = 'Low';
        insert deal1;
        
        map<Id, Deal_Forecast_Income__c> listnewDeal = new map<Id, Deal_Forecast_Income__c>([select id,Opportunity_Product_Id__c,Probability__c,OpportunityLineItem_Limit_Volume__c,Main_Deal_forecast__c 
                                                		from Deal_Forecast_Income__c where id =: deal1.id]);
        Deal_Forecast_Income__c subdeal1 = new Deal_Forecast_Income__c();
        subdeal1.Customer__c = listacc.get(0).Id;
        subdeal1.Opportunity__c = listopp.get(0).Id;
        subdeal1.Opportunity_Product_Id__c = listoppline.get(0).Id;
        subdeal1.Product__c = listpro.get(0).Id;
        subdeal1.Main_Deal_forecast__c = deal1.id;
        insert subdeal1;
        
        Id RTNewDeal = Schema.Sobjecttype.Monthly_Forecast_Input__c.getRecordTypeInfosByName().get('New Deal').getRecordTypeId();
        Monthly_Forecast_Input__c forecastInput = new Monthly_Forecast_Input__c();
        forecastInput.Deal_Forecast_Income__c = deal1.id;
        forecastInput.RecordTypeId = RTNewDeal;
        forecastInput.Customer__c = listacc.get(0).Id;
        forecastInput.Opportunity__c = listopp.get(0).Id;
        forecastInput.OpportunityLineItem_Id__c = listoppline.get(0).Id;
        forecastInput.Product__c = listpro.get(0).Id;
        forecastInput.adjustMonthYear__c = Date.Today();
        forecastInput.Year__c = String.valueOf(Date.Today().Year());
        forecastInput.Month__c = Date.Today().Month() < 10 ? '0' + String.valueOf(Date.Today().Month()) : String.valueOf(Date.Today().Month());
        
        forecastInput.Account_Suffix_Ref__c = forecastInput.OpportunityLineItem_Id__c; 
        forecastInput.YearMonthAcctSuffRef__c = forecastInput.Year__c + forecastInput.Month__c + deal1.Id + forecastInput.OpportunityLineItem_Id__c;
        insert forecastInput;
        
        DealForecastTriggerHandler.syncOpportunitylineitem(listnewDeal);
        DealForecastTriggerHandler.deleteSubDealForecast(listnewDeal);
        DealForecastTriggerHandler.deleteForecastInput(listnewDeal);
        Test.stopTest();
    }
}