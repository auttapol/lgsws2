@IsTest

public with sharing class RTL_InterestedProductTriggerHandlerTest {
    static {
        TestUtils.createAppConfig();
    }   
    
    public static testmethod void checkPrimaryProductCountLead(){
        System.debug(':::: checkPrimaryProductCountLead Start ::::');  
    
        TEST.startTest();
        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        //create test lead queue
        RTL_TestUtility.createLeadQueues(true); 
        System.runAs(retailUser) {
            //create branch and zone
            List<Branch_and_Zone__c> branchList = RTL_TestUtility.createBranchZone(2, true);            
            //create retail master product
            RTL_TestUtility.createRetailMasterProducts(true);
            //create new test lead     
            List<Lead> leads = RTL_TestUtility.createLeads(1, true);
            //create 2 new interested products for lead with 1 primary and 1 non-primary
            RTL_TestUtility.createInterestedProducts(leads, true);
            //check result: the count of primary interested product should be 1
            Lead lead = [select RTL_Count_InterestedProducts_Primary__c from Lead where Id=:leads[0].Id];
            System.assertEquals(1, lead.RTL_Count_InterestedProducts_Primary__c);
            
            //update the non-primary intested product into primary for the same lead
            RTL_Interested_products_c__c nonPrimaryProduct = [select Is_Primary__c from RTL_Interested_products_c__c where Lead__c = :lead.Id and Is_Primary__c = false];
            nonPrimaryProduct.Is_Primary__c = true;
            //check result: the update should be failed because no more than one primary interested product is allowed
            boolean errMsgMatch = false;
            try {
              update nonPrimaryProduct;
            } catch (Exception ex) {
              System.debug('no more than one primary interested product test case err msg = ' + ex.getMessage());
                errMsgMatch = ex.getMessage().contains(System.Label.LeadError_NoMoreThanOneInterestedProduct);
                System.assert(errMsgMatch);              
            }     
            
            //update one of the primary intested product into non-primary for the same lead
            RTL_Interested_products_c__c primaryProduct = [select Is_Primary__c from RTL_Interested_products_c__c where Lead__c = :lead.Id and Is_Primary__c = true limit 1];
            primaryProduct.Is_Primary__c = false;
            update primaryProduct;
            //check result: the count of primary interested product should be 1-1=0
            lead = [select RTL_Count_InterestedProducts_Primary__c from Lead where Id=:leads[0].Id];
            System.assertEquals(0, lead.RTL_Count_InterestedProducts_Primary__c);                   
            
            //delete the non-primary interested product from the same lead
            nonprimaryProduct = [select Id, Is_Primary__c from RTL_Interested_products_c__c where Lead__c = :lead.Id and Is_Primary__c = false limit 1];
            delete nonprimaryProduct;
            //check result: the count of primary interested product has no change, should be 0
            lead = [select RTL_Count_InterestedProducts_Primary__c from Lead where Id=:leads[0].Id];
            System.assertEquals(0, lead.RTL_Count_InterestedProducts_Primary__c);                                     
        }   

        TEST.stopTest();
        System.debug(':::: checkPrimaryProductCountLead End ::::');
    }    
    
    public static testmethod void checkPrimaryProductCountWebtoLead(){
        System.debug(':::: checkPrimaryProductCountWebtoLead Start ::::'); 

        TEST.startTest();
        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        TestInit.createUser(false);
        User adminUser = TestInit.us;        
        System.runAs(adminUser) {
            //create test lead queue
            Map<String, Group> leadQueues = RTL_TestUtility.createLeadQueues(true);

            //create test branch
            RTL_TestUtility.createBranchZone(1, true);
            //create test product and web-to-lead assignment criterias
            RTL_TestUtility.createLeadAssignCriterias(true);
        }
        System.runAs(retailUser) {
            //create positive test data
            RTL_TestUtility.createPositiveWebToLead();
            Lead webtolead = [select RTL_Count_InterestedProducts_Primary__c from Lead where LastName='WebToLead' and FirstName='Test1'];
            //System.assertEquals(1, webtolead.RTL_Count_InterestedProducts_Primary__c);          
        }
        
        TEST.stopTest();
        System.debug(':::: checkPrimaryProductCountWebtoLead End ::::');    
    }    

    public static testmethod void checkAddInterestedProduct(){
        System.debug(':::: checkAddInterestedProduct Start ::::'); 
        Test.startTest();

        User retailUser = RTL_TestUtility.createRetailTestUser(true);
        System.runAs(retailUser) {
            //create branch and zone
            List<Branch_and_Zone__c> branchList = RTL_TestUtility.createBranchZone(3, true);            
            //create retail master product
            RTL_TestUtility.createRetailMasterProducts(true);
            //create new test lead     
            List<Lead> leads = RTL_TestUtility.createLeads(1, true);
            
            //check result: the count of primary interested product should be 0
            Lead lead = [select RTL_Count_InterestedProducts_Primary__c from Lead where Id=:leads[0].Id];
            System.assertEquals(0, lead.RTL_Count_InterestedProducts_Primary__c);

            
            RTL_product_master__c masterPrimaryProduct = [SELECT Id, Product_Code__c, Product_Group__c, Product_Sub_group__c
                        FROM RTL_product_master__c 
                        WHERE Product_Code__c = : '0004' AND Active__c = : true LIMIT 1];
            lead.RTL_Primary_Interested_Product__c = masterPrimaryProduct.Id;
            update lead;
            lead = [select RTL_Count_InterestedProducts_Primary__c from Lead where Id=:leads[0].Id];
            System.assertEquals(1, lead.RTL_Count_InterestedProducts_Primary__c);

            RTL_Interested_products_c__c removePrimaryInterestedProduct = [
                SELECT Id, Lead__c, Product_Name__c 
                FROM RTL_Interested_products_c__c
                WHERE Is_Primary__c = true
            ];
            delete removePrimaryInterestedProduct;

            RTL_product_master__c masterProduct = [SELECT Id, Product_Code__c, Product_Group__c, Product_Sub_group__c
                        FROM RTL_product_master__c 
                        WHERE Product_Code__c = : '0004' AND Active__c = : true LIMIT 1];
            RTL_Interested_products_c__c insertPrimaryInterestedProduct = new RTL_Interested_products_c__c ( 
                Branch_Code__c  = '0004',
                Co_borrower_1__c = 'Test Co Borrower1',
                Co_borrower_2__c = 'Test Co Borrower2',
                Collateral_Type__c = 'Test Collateral Type',
                Debt__c = '5000.23',
                Income_SE__c = '3000.23',
                Income_SL__c ='3000.23',
                Is_Primary__c = TRUE,
                Lead__c = lead.Id,
                Loan_Amount__c = '3000.23',
                product_group__c = masterProduct.Product_Group__c,
                Product_Name__c = masterProduct.Id,
                Product_Sub_Group__c = masterProduct.Product_Sub_group__c );
            insert insertPrimaryInterestedProduct;

            lead.RTL_Primary_Interested_Product__c = null;
            update lead;

        }


        Test.stopTest();
        System.debug(':::: checkAddInterestedProduct End ::::');    

    }
}