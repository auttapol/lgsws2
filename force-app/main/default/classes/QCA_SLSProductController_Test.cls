@isTest
public class QCA_SLSProductController_Test {

    public static Id CommercialPricebook{
        get{
            if(CommercialPricebook == null){
                CommercialPricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Commercial Pricebook' LIMIT 1].Id;
            }
            return CommercialPricebook;
        }
        set;
    }

    public static Id pb1 {
        get{
            return Test.getStandardPricebookId();
        }
        set;
    }

    @testSetup 
    static void setup() {
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();

        AppConfig__c mc = AppConfig__c.getValues('runtrigger');
        mc.Value__c = 'true';
        update mc;

        TestUtils.CreateProceBook();
        TestUtils.CreateProceBookAccess();

        product2 prod = new product2(
            Name = 'PROD1',
            Product_Domain__c = 'Funding & Borrowing',
            IsActive = true,
            Family = 'CONTINGENT LIABILITIES',
            ProductCode = '12345678'
        );
        insert prod;

        PricebookEntry standardPrice = new PricebookEntry(IsActive = true, UnitPrice = 1, Product2Id = prod.id, Pricebook2Id = pb1, UseStandardPrice = false);
        insert standardPrice;

        pricebookentry pbe = new pricebookentry(IsActive = true, UnitPrice = 1, product2id = prod.id, Pricebook2Id = CommercialPricebook, UseStandardPrice = false);
        insert pbe;

        Host_Product_Mapping__c hostPrd = new Host_Product_Mapping__c(Active_Flag__c = true, Credit_Type_ID__c = '111', Host_Name__c = 'SLS', Host_Prod_Name_Credit_Facility__c = 'Factoring - Accepted invoice', Host_Product_Group__c = 'Supply Chain', Product_Group_ID__c = '9', Product_Program_ID__c = '180', Product_Program__c = 'Factoring', Salesforce_Product__c = prod.id);
        insert hostPrd;

        insert new status_code__c(name = '6003', Status_Message__c = 'Lead Duplicate');

        User User01 = RTL_TestUtility.createUsers(1, 'TestMock', 'SmartBDM', 'smartbdm@tmb.com.test', false).get(0);
		User01.ProfileId = QCA_LeadSimplifiedController_Test.BDM_PROFILE_ID;
		User01.isActive = true;
		User01.title = 'Branch Manager';
		// User01.RTL_Branch_Code__c = bz.Branch_Code__c;
		User01.Employee_ID__c = '123456';
		insert User01;

        String dateInString = DateTime.Now().format('MMddyyyyhhmmss');
        Account acct = TestUtils.createAccounts(1, 'test', 'CType', false).get(0);
		acct.Customer_Type__c = 'Individual';
		acct.OwnerID = User01.Id;
		acct.RecordTypeId = QCA_LeadSimplifiedController_Test.PROSPECT_ID;
        acct.Customer_Type__c = 'Juristic';
        acct.ID_Type_PE__c = 'BRN ID';
        acct.ID_Number_PE__c = dateInString + '99901';
		insert acct;
        List<Lead> leadList = RTL_TestUtility.createLeads(2, false);
        Lead Lead01 = leadList.get(0);
        Lead01.RecordTypeId = QCA_LeadSimplifiedController_Test.COMMERCIAL_ACCOUNT_ID;
        Lead01.OwnerID = User01.Id;
        Lead01.Account__c = acct.Id;
        Lead01.Customer_Type__c = 'Juristic';
        Lead01.ID_Type__c = 'BRN ID';
        Lead01.ID_Number__c = dateInString + '99901';
        insert Lead01;
        Lead01.Status = 'Passed Prescreening';
        Lead01.Pre_screening_Result__c = 'Passed';
        update Lead01;
        Call_Report__c  cr = new Call_Report__c(
            OwnerId = User01.Id,
            // Customer_name__c = a.id,
            Lead__c = Lead01.Id,
            Status__c = 'Open',
            Date_of_Visit__c = Date.today(),
            Categories__c  = 'Sell product',
            Main_purpose__c = 'Sell product',
            Sub_Purpose__c  = 'Product'
        );
        insert cr;
        Opportunity oppty = TestUtils.createOpportunity(1, acct.Id, false).get(0);
        oppty.OwnerId = User01.Id;
        oppty.Converted_Lead_ID__c = Lead01.Id;
        insert oppty;

        OpportunityLineItem opptyLineItem1 = new OpportunityLineItem(
            opportunityid = oppty.id,
            quantity = 1.00,
            PricebookEntryId = standardPrice.id,
            unitprice = 1.00,
            Expected_Revenue__c = 10.00,
            // TotalPrice = 10.00,
            // This_Year_Expected_Fee__c = 10.00,
            Host_Product_Mapping__c = hostPrd.Id
            );
        // OpportunityLineItem opptyLineItem2 = opptyLineItem1.clone(false, false, false, false);
        // opptyLineItem2.PricebookEntryId = pbe.id;
        insert opptyLineItem1;
        // insert opptyLineItem2;

        Product_Interest__c recommendedProduct1 = new Product_Interest__c(
            Opportunity_Type__c = 'Credit',
            Product__c = prod.Id,
            Amount__c = 50000,
            Lead__c = Lead01.Id,
            Host_Product_Mapping__c = hostPrd.Id
        );
        Product_Interest__c recommendedProduct2 = recommendedProduct1.clone(false, false, false, false);
        insert recommendedProduct1;
        insert recommendedProduct2;
    }

    public static List<Account> getAccountList(){
        return [SELECT Id FROM Account];
    }

    public static List<Lead> getLeadList(){
        return [SELECT Id FROM Lead];
    }

    public static List<Opportunity> getOpportunityList(){
        return [SELECT Id FROM Opportunity];
    }

    public static List<Product_Interest__c> getReccomendedProductList(Id recordId){
        return [SELECT Id FROM Product_Interest__c WHERE Lead__c = :recordId];
    }
    public static List<OpportunityLineItem> getOpportunityLineItemList(Id recordId){
        return [SELECT Id FROM OpportunityLineItem WHERE opportunityid = :recordId];
    }

    public static String objRecommendProduct(String ProductInterestId, String HostMappingId, String SalesforceProduct, String Amount) 
    {
        return '[{"Product_Interest_Id": "' + ProductInterestId + '", "Id": "' + HostMappingId +'","Salesforce_Product__c": "' + SalesforceProduct +'","Amount__c": "' + Amount +'"}]';
    }

    public static String objOpportunityLineItemProduct(String ProductInterestId, String HostMappingId, String SalesforceProduct, String Amount) 
    {
        return '[{"OpportunityLineItem_Id": "' + ProductInterestId + '", "Id": "' + HostMappingId +'","Salesforce_Product__c": "' + SalesforceProduct + '","Amount__c": "' + Amount + '"},{"OpportunityLineItem_Id": "", "Id": "' + HostMappingId + '","Salesforce_Product__c": "' + SalesforceProduct + '","Amount__c": "' + Amount + '"}]';
    }

    @isTest
    static void test_QCA_SLSProductController_positive() {
        List<Lead> leadList = getLeadList();
        List<Opportunity> opptyList = getOpportunityList();
        Lead tmpLead1 = leadList.get(0);
        Opportunity tmpOppty1 = opptyList.get(0);
        Product_Interest__c tmpRecommendedProduct = getReccomendedProductList(tmpLead1.Id).get(0);
        OpportunityLineItem tmpOpportunityLineItem = getOpportunityLineItemList(tmpOppty1.Id).get(0);
        
        Test.startTest();
        QCA_SLSProductController.HostProductMappingWrapper productLead = QCA_SLSProductController.onInitQCASLSProduct(tmpLead1.Id, 'QCALeadType');
        QCA_SLSProductController.HostProductMappingWrapper productOpportunity = QCA_SLSProductController.onInitQCASLSProduct(tmpOppty1.Id, 'QCAOpptyType');

        Host_Product_Mapping__c hostProdMapping = productLead.HostProductMappingFieldValues.get(0);
        String prod1 = objRecommendProduct(tmpRecommendedProduct.Id, hostProdMapping.Id, hostProdMapping.Salesforce_Product__c, '123');
        QCA_SLSProductController.saveSLSProduct(prod1, tmpLead1.Id, true);
        
        String prod2 = objOpportunityLineItemProduct(tmpOpportunityLineItem.Id, hostProdMapping.Id, hostProdMapping.Salesforce_Product__c, '123');
        QCA_SLSProductController.saveSLSProduct(prod2, tmpOppty1.Id, false);
        Test.stopTest();
    }

    @isTest
    static void test_QCA_SLSProductController_negative() {  
        new QCA_SLSProductController();
        QCA_SLSProductController.onInitQCASLSProduct((Id)'00Q0l0000000jZA', 'QCALeadType');
        QCA_SLSProductController.onInitQCASLSProduct((Id)'006N00000000OrA', 'QCAOpptyType');
    }

}