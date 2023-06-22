@isTest
public class CampaignExtensionTest {
    public static ID CommercialCampaignRecordType = [SELECT ID from RecordType 
                                                     WHERE SobjectType ='Campaign' AND Name ='Commercial' LIMIT 1].id;
    static testmethod void positive()
    {
        test.startTest();
        
        insert new AppConfig__c(name = 'runtrigger', value__c = 'TRUE');
		TestUtils.createAppConfigRetailtoComm();
        
        Campaign ca = new Campaign(Name='campaign Test',Segment__c='MB',IsActive=true,RecordTypeID=CommercialCampaignRecordType);
            insert ca;
        Campaign ca2 = new Campaign(Name='campaign Test2',Segment__c='MB',IsActive=true,RecordTypeID=CommercialCampaignRecordType
                                    );
            insert ca2;
        ca2.ParentId = ca.id;
        update ca2;
        account acct = testutils.createAccounts(1, 'fname', 'Individual', true).get(0);
        Id pb1 = Test.getStandardPricebookId();
        product2 prod = new product2(name='test',isactive=true,Product_Domain__c='Risk');
            insert prod;
        pricebookentry pbe = new pricebookentry(isactive=true,unitprice=1.00,product2id=prod.id,pricebook2id=pb1,usestandardprice=false);
            insert pbe;
        opportunity oppt = new opportunity(accountid = acct.id, name='test', ownerid = acct.ownerid, Expected_submit_date__c = date.today(), closedate = date.today()
                                          ,stagename = 'Analysis', campaignID = ca.id);
            insert oppt;
        opportunitylineitem opptline = new opportunitylineitem(opportunityid = oppt.id, quantity = 1.00, pricebookentryid = pbe.id,unitprice=1.00
                                                               ,RevisedStartMonth__c='JAN',RevisedStartYear__c='2015'
                                                               ,RevisedStartMonthFee__c='JAN',RevisedStartYearFee__c='2015'
                                                               ,Expected_Revenue__c = 10.00, This_Year_Expected_Fee__c = 10.00);
            insert opptline;
        opportunity oppt2 = new opportunity(accountid = acct.id, name='test', ownerid = acct.ownerid, Expected_submit_date__c = date.today(), closedate = date.today()
                                          ,stagename = 'Analysis', campaignID = ca2.id);
            insert oppt2;
        opportunitylineitem opptline2 = new opportunitylineitem(opportunityid = oppt2.id, quantity = 1.00, pricebookentryid = pbe.id,unitprice=1.00
                                                               ,RevisedStartMonth__c='JAN',RevisedStartYear__c='2015'
                                                               ,RevisedStartMonthFee__c='JAN',RevisedStartYearFee__c='2015'
                                                               ,Expected_Revenue__c = 10.00, This_Year_Expected_Fee__c = 10.00);
            insert opptline2;
        
        Apexpages.StandardController sc = new Apexpages.StandardController(ca);
        CampaignExtension app = new CampaignExtension(sc);
        app.summaryExpectedRevenue();
        
        test.stopTest();
    }
    
    static testmethod void parentcampaign1(){
                test.startTest();
        
        insert new AppConfig__c(name = 'runtrigger', value__c = 'TRUE');
		TestUtils.createAppConfigRetailtoComm();
        
        Campaign ca = new Campaign(Name='campaign Test',Segment__c='MB',IsActive=true,RecordTypeID=CommercialCampaignRecordType);
            insert ca;
        List<Campaign> childCamList = new List<Campaign>();
        Campaign ca2 = new Campaign(Name='campaign Test2',Segment__c='MB',IsActive=true,RecordTypeID=CommercialCampaignRecordType
                                    );
            insert ca2;
        Campaign ca3 = new Campaign(Name='campaign Test3',Segment__c='MB',IsActive=true,RecordTypeID=CommercialCampaignRecordType
                                    );
         insert ca3;
        ca2.HierarchyFullDealExpectedRevenueOpty__c = 1000000;
        ca3.HierarchyThisYearExpectedRevenueOpty__c = 1000000;
        
        ca2.ParentId = ca.id;
        ca3.ParentId = ca.id;
        childCamList.add(ca2);
        childCamList.add(ca3);
        update childCamList;
        test.stopTest();
    }
}