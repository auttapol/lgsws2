@IsTest
public class  ProductSelectionControllerTest {

    public static void setInitial()
    {
        insert new Account_Plan_Status_Code__c(name = '5034', Status_Message__c = 'test');
    }
    
    static{
        TestUtils.CreateProceBookAccess();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        TestUtils.createIdType();
        TestUtils.createTriggerMsg();
        TestUtils.createObjUserPermission();
        TestUtils.CreateProceBook();
        AccountPlanTestUtilities.getAcctPlanMode();
    }
    
     public static testmethod void AddOpportunityProductCtrl(){
         //User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@test.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
         User SalesOwner = TestUtils.createUsers(1,'opptyProduct', 'AddProduct','AddProdTest@tmbbank.com', false).get(0);

               SalesOwner.Zone_Code__c = '1001';
         	   SalesOwner.Employee_ID__c  = '8888888';
        insert SalesOwner;
          Test.startTest();
        System.runAs(SalesOwner){
            
             
            //List<Account> accountList = TestUtils.createAccounts(3,'acctAddOppProductTest','Individual',true);
            List<Account> accountList = AccountPlanTestUtilities.createAccounts(5, 'GroupPro', 'Individual', SalesOwner.id, true, true);
         
            TestInit.createOpportunity( accountList); 
             Opportunity oppty2 = new Opportunity(OwnerId=SalesOwner.id,
                                Name='SalesOwnerPriceBook',
                                StageName = 'Analysis',
                                CloseDate = Date.today(),
                                AccountId = AccountList.get(0).Id, 
                                Probability = 10,
                                Amount = 0,
                                Description = 'desc',
                                CA_Prep_Start_Date__c = Date.today(),
                                Approval_Process_Date__c = Date.today(),
                                Post_Approval_Date__c = Date.today(),
                                Complete_Date__c = Date.today(),
                                Trigger_flag__c = true
                               );
            
            insert oppty2; 
             Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', 
                                           TMB_Pricebook__c ='TMB5412',
                                           Description = 'Price Book 2009 Products', IsActive = true);
        insert pb;
            
            Product2 prod = new Product2(Name = 'Laptop X200',
            						Family = 'Hardware',
                                         
                                    Product_Level__c ='1');
            
        
            insert prod;
            
           

            
            List <OpportunityLineItem> oppItemList = new List<OpportunityLineItem>();
            ID pricebookid = Test.getStandardPricebookId();
            
            PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookid, Product2Id =prod.id,UseStandardPrice =false,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
            
            
            for(Integer i=0;i<3;i++){
                OpportunityLineItem oppItem = new OpportunityLineItem();
                
                oppItem.OpportunityId = oppty2.id;
                oppItem.PricebookEntryId = standardPrice.id;
                
                oppItem.Quantity = 1;
                OppItem.UnitPrice = 1;
                OppItem.isTemporary__c = true;
                oppItemList.add(OppItem);
                
            }
            insert oppItemList;
        PageReference productpage = Page.AddProductsToOpp;
        	   productpage.getParameters().put('pricebookid',Test.getStandardPricebookId());
        	   productpage.getParameters().put('opptyid',oppty2.id);
               Test.setCurrentPage(productpage);
         	 
             ApexPages.StandardController sc3 = new ApexPages.StandardController(oppty2);
             AddOpportunityProductCtrl productselectionCtrl3 = new AddOpportunityProductCtrl(sc3);
             
             productselectionCtrl3.OppLineItem = oppItemList;
             productselectionCtrl3.save();
             productselectionCtrl3.cancel();
        }
        Test.stopTest();
        
        
    }
    
    
    
    public static testmethod void ProductSelectionControllerTest(){
        setInitial();
        Test.startTest();
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'ProductSelect', 'productselection@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);

               SalesOwner.Zone_Code__c = '1001';
        	   SalesOwner.Employee_ID__c  = '8888888';
        update SalesOwner;
        System.runAs(SalesOwner){
            
             //TestInit.createAccount( 3 );
            //List<Account> accountList = TestInit.accountList.values();
            List<Account> accountList = AccountPlanTestUtilities.createAccounts(5, 'GroupPro', 'Individual', SalesOwner.id, true, true);
         
            //TestInit.createTarget( TestInit.accountList.values() ); 
            TestInit.createTarget(accountList);
            
            update accountList.get(0);
            TestInit.createOpportunity( TestInit.accountList.values() ); 
             Opportunity oppty2 = new Opportunity(OwnerId=SalesOwner.id,
                                Name='SalesOwnerPriceBook',
                                StageName = 'Analysis',
                                CloseDate = Date.today(),
                                AccountId = AccountList.get(0).Id, 
                                Probability = 10,
                                Amount = 0,
                                Description = 'desc',
                                CA_Prep_Start_Date__c = Date.today(),
                                Approval_Process_Date__c = Date.today(),
                                Post_Approval_Date__c = Date.today(),
                                Complete_Date__c = Date.today(),
                                Trigger_flag__c = true
                               );
            
            insert oppty2; 
        PageReference productpage = Page.ProductSelection;
               productpage.getParameters().put('AccountName',AccountList.get(0).id);
        	   productpage.getParameters().put('pricebookid',Test.getStandardPricebookId());
        	   productpage.getParameters().put('opptyid',oppty2.id);
        	   productpage.getParameters().put('Domain',oppty2.id);
               Test.setCurrentPage(productpage);
        List<Product2> prodlist = new List<Product2>();
        Product2 prod = new Product2(Name = 'Laptop X200', 
            						Family = 'Hardware',
                                    
                                    Product_Level__c ='1');
        
        Product2 prod2 = new Product2(Name = 'Laptop X201', 
            						Family = 'Hardware',
                                    Product_Domain__c ='Deposit',
                                    Product_Level__c ='2');
        Product2 prod3 = new Product2(Name = 'Laptop X202', 
            						Family = 'Hardware',
                                    Product_Domain__c ='',
                                    Product_Level__c ='3');
        Product2 prod4 = new Product2(Name = 'Laptop X203', 
            						Family = 'Hardware',
                                    Product_Domain__c ='',
                                    Product_Level__c ='4');
        Product2 prod5 = new Product2(Name = 'Laptop X204', 
            						Family = 'Hardware',
                                    Product_Domain__c ='',
                                    Product_Level__c ='5');
        Product2 prod6 = new Product2(Name = 'Laptop X205', 
            						Family = 'Hardware',
                                    Product_Domain__c ='',
                                    Product_Level__c ='6');
        Product2 prod7 = new Product2(Name = 'Laptop X206', 
            						Family = 'Hardware',
                                    Product_Domain__c ='',
                                    Product_Level__c ='7');
        prodlist.add(prod);
        prodlist.add(prod2);
        prodlist.add(prod3);
        prodlist.add(prod4);
        prodlist.add(prod5);
        prodlist.add(prod6);
        prodlist.add(prod7);
        
        Id pricebookId = Test.getStandardPricebookId();
        
       
        
        insert prodlist;
        
         PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oppty2);
             ProductSelectionController productselectionCtrl = new ProductSelectionController(sc);
        productselectionCtrl.pricebookselected = pricebookId;
        Product2 prodlevel4 = new Product2(Name = 'Laptop X203', 
            						Family = 'Hardware',
                                    Product_Domain__c ='level4',
                                    Product_Level__c ='4'
                                    );
        insert prodlevel4;
            
            PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prodlevel4.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        
        	productselectionCtrl.Product1Selected = 'level4';
        
        Product2 prodlevel5 = new Product2(Name = 'Laptop X2035', 
            						Family = 'Hardware',
                                    Product_Domain__c ='level5',
                                    Product_Level__c ='5'
                                    );
        insert prodlevel5;

            productselectionCtrl.Product2Selected = 'level5';
            
            
            Product2 prodlevel6 = new Product2(Name = 'Laptop X2036', 
            						Family = 'Hardware',
                                    Product_Domain__c ='level6',
                                    Product_Level__c ='6'
                                    );
        insert prodlevel6;
            productselectionCtrl.product3selected = 'level6';
            
                        Product2 prodlevel7 = new Product2(Name = 'Laptop X2037', 
            						Family = 'Hardware',
                                    Product_Domain__c ='level7',
                                    Product_Level__c ='7'
                                    );
        insert prodlevel7;
            productselectionCtrl.Product4Selected = 'level7';
            
            PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prodlevel5.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice3;
         PricebookEntry standardPrice4 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prodlevel6.Id,
            UnitPrice = 10, IsActive = true);
        insert standardPrice4;
        PricebookEntry standardPrice5 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prodlevel7.Id,
            UnitPrice = 10, IsActive = true);
        insert standardPrice5;
        	
        	
        	
       		productselectionCtrl.product1select();
            productselectionCtrl.product2select();
            productselectionCtrl.product3select();
            productselectionCtrl.product4select();
        
        	
        	productselectionCtrl.oppty = oppty2;
            
            ProductSelectionController.ProductWrapper prodwrap = new ProductSelectionController.ProductWrapper();
            prodwrap.product = prodlevel7;
            prodWrap.IsSelected = true;
            
            productselectionCtrl.ProductWrapperList.add(prodWrap);
            
        	productselectionCtrl.SelectedProduct();
        	productselectionCtrl.selectpricebook();
        	productselectionCtrl.clarify();
        
        
        	productselectionCtrl.productdomainselected = '1';
        	productselectionCtrl.productdomainselect();
        	productselectionCtrl.productdomainselected = '2';
        	productselectionCtrl.productdomainselect();
        	productselectionCtrl.productdomainselected = '3';
        	productselectionCtrl.productdomainselect();
        	productselectionCtrl.productdomainselected = '4';
        	productselectionCtrl.productdomainselect();
        
        
        
        
           
            
            
         PageReference productpage2 = Page.OpportunityPriceBookSelection;
               productpage2.getParameters().put('AccountName',AccountList.get(0).id);
        	   productpage2.getParameters().put('pricebookid',Test.getStandardPricebookId());
        	   productpage2.getParameters().put('opptyid',oppty2.id);
               Test.setCurrentPage(productpage2);
        
          ApexPages.StandardController sc2 = new ApexPages.StandardController(oppty2);
             ProductSelectionController productselectionCtrl2 = new ProductSelectionController(sc2);
        productselectionCtrl2.pricebookselected = pricebookId;
 
        
        PageReference productpage3 = Page.NIProjectionProduct;
         
            List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(accountList, true);
            AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
            
            //productpage3.getParameters().put('AccountName',AccountList.get(0).id);
            productpage3.getParameters().put('pricebookid',Test.getStandardPricebookId());
            productpage3.getParameters().put('opptyid',oppty2.id);
            productpage3.getParameters().put('Domain','level4');
            productpage3.getParameters().put('CompanyID',comprofile.Id);
               Test.setCurrentPage(productpage3);
            
            ApexPages.StandardController sc3 = new ApexPages.StandardController(oppty2);
            
            
            ProductSelectionController productselectionCtrl3 = new ProductSelectionController(sc3);
            
        	productselectionCtrl3.pricebookselected = pricebookId;
            
             productselectionCtrl3.ProductWrapperList.add(prodWrap);
            productselectionCtrl3.SelectedProduct();
        }
        
        Test.stopTest();
        
    }

   


}