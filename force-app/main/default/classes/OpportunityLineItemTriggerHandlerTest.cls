@isTest
public class OpportunityLineItemTriggerHandlerTest {
	public static testMethod void RunPositiveTestOpptyTeam(){
        System.debug(':::: RunPositive Test Opportunity Team Member Start ::::');
        TestInit.createUser(false);
        System.runAs(TestInit.us) {
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            System.debug('Current User Id: ' + UserInfo.getUserId()); 
           	// --- create account ---
		    List<Account> accList = TestUtils.createAccounts(1, 'test', 'CType', true);
            system.debug('### accList : '+accList.size());
            
            system.debug('### Test ');
            // --- create opp ---
            List<Opportunity> oppList = TestUtils.createOpportunity(10, accList.get(0).Id, true);
            system.debug('### oppList : '+oppList.size());
            // ------		
			List<Product2> prod = TestUtils.createProduct(250, true);
            system.debug('###prod :'+prod.size());
            Id pricebookId = Test.getStandardPricebookId();
            List<PricebookEntry> priceEntry = TestUtils.createPricebookEntry(200, pricebookId, prod, true);
            system.debug('###priceEntry :'+priceEntry.size());
            
            Test.startTest();
			RunSingleRecord(oppList,priceEntry);
            Run200Records(oppList,priceEntry);
            Test.stopTest();
        }
        System.debug(':::: RunPositive Test Opportunity Team Member End ::::');
    }
    
    public static void RunSingleRecord(List<Opportunity> oppList , List<PricebookEntry> priceEntry){
        List<OpportunityLineItem> oppProd = TestUtils.createOpportunityProduct(1, oppList.get(0).Id, priceEntry, true);
        system.debug('### oppProd : '+oppProd.size());

			try{
				delete oppProd;
			}catch(DmlException e){
				System.debug('### The following exception has occurred: ' + e.getMessage());
			}catch(Exception e){
				System.debug('### An exception occurred: ' + e.getMessage());
			}
        // --- check number of records ---
		List<OpportunityLineItem> oppProdAfterDel = new List<OpportunityLineItem>([SELECT Id FROM OpportunityLineItem]);
		system.debug('### oppProdAfterDel : '+oppProdAfterDel.size());
		System.assertEquals(oppProdAfterDel.size(),0);

    }
    
    public static void Run200Records(List<Opportunity> oppList , List<PricebookEntry> priceEntry){
        system.debug('### test : ');
        List<OpportunityLineItem> oppProd1 = TestUtils.createOpportunityProduct(50, oppList.get(1).Id, priceEntry, true);
        List<OpportunityLineItem> oppProd2 = TestUtils.createOpportunityProduct(50, oppList.get(2).Id, priceEntry, true);
        List<OpportunityLineItem> oppProd3 = TestUtils.createOpportunityProduct(50, oppList.get(3).Id, priceEntry, true);
        List<OpportunityLineItem> oppProd4 = TestUtils.createOpportunityProduct(50, oppList.get(4).Id, priceEntry, true);
        List<OpportunityLineItem> oppProdAll = new List<OpportunityLineItem>();
        oppProdAll.addAll(oppProd1);
        oppProdAll.addAll(oppProd2);
        oppProdAll.addAll(oppProd3);
        oppProdAll.addAll(oppProd4);
        
		system.debug('### oppProdAll : '+oppProdAll.size());
			try{
				delete oppProdAll;
			}catch(DmlException e){
				System.debug('### The following exception has occurred: ' + e.getMessage());
			}catch(Exception e){
				System.debug('### An exception occurred: ' + e.getMessage());
			}
        // --- check number of records ---
		List<OpportunityLineItem> oppProdAfterDel2 = new List<OpportunityLineItem>([SELECT Id FROM OpportunityLineItem]);
		system.debug('### oppProdAfterDel2 : '+oppProdAfterDel2.size());
		System.assertEquals(oppProdAfterDel2.size(),0);
    }
    static testmethod void testOppLineItemTriggerHandler()
    {
        test.startTest();
        OpportunityLineItemTriggerHandler olth = new OpportunityLineItemTriggerHandler();
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
        map<id,opportunitylineitem> mapOppLine = new map<id,opportunitylineitem>();
        mapOppLine.putAll(listoppline);
        OpportunityLineItemTriggerHandler.CalculateOpportunityTotalVol(new list<opportunitylineitem>());
        OpportunityLineItemTriggerHandler.getDeletedRecord(mapOppLine);
        
        //Fix BAU_8571_INC0086691                                       
        Host_Product_Mapping__c hostProdMapp = new Host_Product_Mapping__c();
        hostProdMapp.Product_Group_ID__c = '1';
        hostProdMapp.Product_Program_ID__c = '1';
        hostProdMapp.Credit_Type_ID__c = '1';        
        insert hostProdMapp;
        
        OpportunityLineItem oppline = new OpportunityLineItem();
            oppline.OpportunityId = listopp.get(0).id;
            oppline.PricebookEntryId = listpricebook.get(0).id;
            oppline.UnitPrice = 6000;
            oppline.Quantity = 1;
            oppline.Expected_Revenue__c = 10000.00; 
            oppline.Expected_Revenue_Fee__c = 10000.00;
            oppline.This_Year_Expected_Fee__c = 10000.00;
            oppline.This_Year_Expected_NI__c = 10000.00;
        	oppline.Host_Product_Mapping__c = hostProdMapp.Id;
        	insert oppline; 
        list<opportunitylineitem> listnewopp = [select id,OpportunityID,Expected_Revenue_Total__c,This_Year_Expected_Revenue__c 
                                                from opportunitylineitem where id =: oppline.id];
        OpportunityLineItemTriggerHandler.summaryExpectedRevenue(listnewopp,new list<opportunitylineitem>(),'insert');
        
        list<opportunitylineitem> listnewopp2 = listnewopp;
        	listnewopp.get(0).Expected_Revenue__c = 1000.00; 
            listnewopp.get(0).Expected_Revenue_Fee__c = 1000.00;
            listnewopp.get(0).This_Year_Expected_Fee__c = 1000.00;
            listnewopp.get(0).This_Year_Expected_NI__c = 1000.00;
        	update listnewopp;
        list<opportunitylineitem> listnewopp3 = [select id,OpportunityID,Expected_Revenue_Total__c,This_Year_Expected_Revenue__c 
                                                from opportunitylineitem where id =: oppline.id];
        
        OpportunityLineItemTriggerHandler.summaryExpectedRevenue(listnewopp3,listnewopp2,'update');
        
        OpportunityLineItem oppline4 = new OpportunityLineItem();
            oppline4.OpportunityId = listopp.get(1).id;
            oppline4.PricebookEntryId = listpricebook.get(0).id;
            oppline4.UnitPrice = 6000;
            oppline4.Quantity = 1;
            oppline4.Expected_Revenue__c = 10000.00; 
            oppline4.Expected_Revenue_Fee__c = 10000.00;
            oppline4.This_Year_Expected_Fee__c = 10000.00;
            oppline4.This_Year_Expected_NI__c = 10000.00;
        	insert oppline4; 
        opportunitylineitem newopp4 = [select id,OpportunityID,Expected_Revenue_Total__c,This_Year_Expected_Revenue__c 
                                                from opportunitylineitem where id =: oppline4.id];
        listnewopp3.add(newopp4);
        OpportunityLineItemTriggerHandler.summaryExpectedRevenue(null,listnewopp3,'delete');
        
        test.stopTest();
    }
    static testmethod void testTriggerSyncDealForecast()
    {
        test.startTest();
        OpportunityLineItemTriggerHandler olth = new OpportunityLineItemTriggerHandler();
        testutils.createAppConfig();
        Id pricebookId = Test.getStandardPricebookId();
        Campaign camp = new Campaign();
            camp.Name = 'Campaign_1';
            camp.Segment__c = 'SE';
            camp.OwnerId  = userinfo.getUserId();
        	insert camp;
        list<account> listacc = testutils.createAccounts(1,'f','Individual',true);
        list<opportunity> listopp = testutils.createOpportunity(1,listacc.get(0).id,true);
        	listopp.get(0).campaignid = camp.id;
        	listopp.get(0).RecordTypeId = '01290000001AhOYAA0';
        	update listopp;
        list<product2> listpro = testutils.createProduct(1,true);
        	listpro.get(0).Remark__c = 'ST loan';
        	update listpro;
        
        list<pricebookentry> listpricebook = testutils.createPricebookEntry(1,pricebookId,listpro,true);
        
        OpportunityLineItem oppline = new OpportunityLineItem();
            oppline.OpportunityId = listopp.get(0).id;
        	oppline.Product2Id = listpro.get(0).id;
        	oppline.Quantity = 1;
        	oppline.Deal_Probability__c = 'Low';
        	oppline.UnitPrice = 10000000;
        insert oppline; 
        list<opportunitylineitem> listnewopp = [select id,OpportunityId,Product2Id,Deal_Probability__c,UnitPrice 
                                                from opportunitylineitem where id =: oppline.id];
        
        OpportunityLineItemTriggerHandler.GenerateDealForecast(listnewopp);
        
        map<Id, opportunitylineitem> mapnewopp = new map<Id, opportunitylineitem>([select id,OpportunityId,Product2Id,Deal_Probability__c,UnitPrice 
                                                from opportunitylineitem where id =: oppline.id]);
        
        map<Id, opportunitylineitem> mapnewopp2 = mapnewopp;
            mapnewopp.get(oppline.id).Deal_Probability__c = 'Medium';
        	mapnewopp.get(oppline.id).UnitPrice = 15000000;
        	update mapnewopp.values();
        
        map<Id, opportunitylineitem> mapnewopp3 = new map<Id, opportunitylineitem>([select id,OpportunityId,Product2Id,Deal_Probability__c,UnitPrice 
                                                from opportunitylineitem where id =: oppline.id]);
        
        OpportunityLineItemTriggerHandler.syncDealForecast(mapnewopp2,mapnewopp3);
        
        Deal_Forecast_Income__c deal1 = new Deal_Forecast_Income__c();
        deal1.Customer__c = listacc.get(0).Id;
        deal1.Opportunity__c = listopp.get(0).Id;
        deal1.Opportunity_Product_Id__c = oppline.id;
        deal1.Product__c = listpro.get(0).Id;
        deal1.OpportunityLineItem_Limit_Volume__c = 15000000;
        deal1.Probability__c = 'Medium';
        insert deal1;
        
        OpportunityLineItemTriggerHandler.deleteDealForecast(mapnewopp3);
        
        test.stopTest();
    }
}