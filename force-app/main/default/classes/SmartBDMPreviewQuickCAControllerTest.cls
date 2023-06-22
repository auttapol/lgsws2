@isTest

private class SmartBDMPreviewQuickCAControllerTest {

    public static final Id BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;  

    @testSetup static void setup() 
    {
        TestUtils.createAppConfig();

        // --- create account ---
		    List<Account> accList = TestUtils.createAccounts(1, 'test', 'CType', true);

        // --- create opp ---
        List<Opportunity> oppList = TestUtils.createOpportunity(1, accList.get(0).Id, true);
        Opportunity oppty = new Opportunity(Id = oppList[0].Id);
        oppty.Host_System__c = 'SLS';
        oppty.Host_Product_Group__c = 'Supply Chain';
        update oppty;
        // ------		
       product2 prod = new product2(
            Name = 'PROD1',
            Product_Domain__c = 'Funding & Borrowing',
            IsActive = true,
            Family = 'CONTINGENT LIABILITIES',
            ProductCode = '12345678'
        );
        insert prod;

        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry priceEntry = new PricebookEntry( IsActive = true, UnitPrice = 1, Product2Id = prod.id, Pricebook2Id = pricebookId, UseStandardPrice = false);     
        insert priceEntry;

        //List<OpportunityLineItem> oppProd = TestUtils.createOpportunityProduct(1, oppList.get(0).Id, priceEntry, true);
        Host_Product_Mapping__c hostPrd = new Host_Product_Mapping__c(Active_Flag__c = true, Credit_Type_ID__c = '111', Host_Name__c = 'SLS', Host_Prod_Name_Credit_Facility__c = 'Factoring - Accepted invoice', Host_Product_Group__c = 'Supply Chain', Product_Group_ID__c = '9', Product_Program_ID__c = '180', Product_Program__c = 'Factoring', Salesforce_Product__c = prod.id);

        insert hostPrd;

        OpportunityLineItem oppline = new OpportunityLineItem();
        oppline.OpportunityId = oppList.get(0).Id;
        oppline.PricebookEntryId = priceEntry.Id;
        oppline.UnitPrice = 6000;
        oppline.Quantity = 1;
        oppline.Host_Product_Mapping__c = hostPrd.Id;
        insert oppline;

    }
    @isTest static void getProductionList() 
    {
      // Implement test code
      try 
      {
        List<Opportunity> oppty = [SELECT Id, AccountId, Account.Name, Account.Customer_Type__c, Name, CAID__c, Host_Product_Group__c, Owner.Name, Owner.Employee_ID__c, Owner.Zone_Code__c, Owner.Region_Code__c
                                FROM Opportunity LIMIT 1
        ];
      
        SmartBDMPreviewQuickCAController.getProductionList(oppty[0].Id);  
      } catch (Exception e) {
        System.debug('Error!!');
      }

	  }

    @isTest static void getOppty() 
    {
      // Implement test code
      try
      {
        List<Opportunity> oppty = [SELECT Id, AccountId, Account.Name, Account.Customer_Type__c, Name, CAID__c, Host_Product_Group__c, Owner.Name, Owner.Employee_ID__c, Owner.Zone_Code__c, Owner.Region_Code__c
                                FROM Opportunity LIMIT 1
        ];

        SmartBDMPreviewQuickCAController.getOppty(oppty[0].Id);
      }catch (Exception e) {
        System.debug('Error!!');
      }
      
    }
    @isTest static void getHost() {

        SmartBDMPreviewQuickCAController.getHost();
	  }
    @isTest static void submitToHost() 
    {
      // Implement test code
      try 
      {
        List<Opportunity> oppty = [SELECT Id, AccountId, Account.Name, Account.Customer_Type__c, Name, CAID__c, Host_Product_Group__c, Owner.Name, Owner.Employee_ID__c, Owner.Zone_Code__c, Owner.Region_Code__c
                                  FROM Opportunity LIMIT 1
        ];
        SmartBDMPreviewQuickCAController.submitToHost(oppty[0].Id);
      } catch (Exception e) {
        System.debug('Error!!');
      }
      
    }
    @isTest static void getDeepLink() {

        SmartBDMPreviewQuickCAController.getDeepLink();
	  }
}