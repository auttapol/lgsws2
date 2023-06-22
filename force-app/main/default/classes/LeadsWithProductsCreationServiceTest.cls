@isTest
public class LeadsWithProductsCreationServiceTest {
    
    @testSetup static void setupData(){
        
        TestUtils.createAppConfig();
        
        AppConfig__c mc =new AppConfig__c(Name = 'runtrigger', Value__c = 'false');
        insert mc;
        
        User u = CSTestUtils.createUsers(1, 'UserTestqqq' ,'Userqqq' , 'test22@email.com' , false).get(0);
        insert u;
        Account acc = RTL_TestUtility.createAccounts(1,false).get(0);
        insert acc;
        
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_1';
        camp.Segment__c = 'CB';
        camp.OwnerId  = u.id;
        
        insert camp;
        
	}
    
    @isTest
    public static void insertLeadswEligibleProducts()
    {                 
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        List<Account> acc = [SELECT Id, Name, ID_Type_PE__c, ID_Number_PE__c,RTL_NID__c,TMB_Customer_ID_PE__c FROM Account LIMIT 1];
        List<Campaign> cm = [SELECT Id,Name FROM Campaign LIMIT 1];
        List<LeadsWithProductsCreationService.leads> ldList = new List<LeadsWithProductsCreationService.leads>();
        LeadsWithProductsCreationService.leads ld = new LeadsWithProductsCreationService.leads();    
        ld.tmb_customer_id = '001100000000000000000000135497';
        ld.id_number = '5321379123454';
        ld.id_type = 'Passport ID';  
        ld.customer_type = 'Individual';
        ld.first_name = 'Commercial';
        ld.last_name = 'Lead';
        ld.mobile_number = '0934163327';
        ld.company_name = 'Commercial Lead';
        ld.campaign_id = cm[0].Id;
        ld.channel = 'Lazada';
        
        LeadsWithProductsCreationService.leads ld2 = new LeadsWithProductsCreationService.leads();    
        ld2.tmb_customer_id = acc[0].TMB_Customer_ID_PE__c;
        ld2.id_number = acc[0].ID_Number_PE__c;
        ld2.id_type = acc[0].ID_Type_PE__c;  
        ld2.customer_type = 'Individual';
        ld2.first_name = 'Commercial2';
        ld2.last_name = 'Lead2';
        ld2.mobile_number = '0934163328';
        ld2.company_name = 'Commercial Lead';
        ld2.campaign_id = cm[0].Id;
        ld2.channel = 'Lazada';
                
        List<LeadsWithProductsCreationService.recommended_products> recProList = new List<LeadsWithProductsCreationService.recommended_products>();
        LeadsWithProductsCreationService.recommended_products recPro = new LeadsWithProductsCreationService.recommended_products();    
        recPro.project_code = '12345';
        recPro.product_name = 'SE Lazada Loan WC';
        recPro.product_code = '032814903522';
        recPro.host_product_mapping_id = 'a2N0p0000008Xh7EAE';
        recPro.max_offer_amount = 500000;
        recPro.max_tenor = 1;
        recPro.max_tenor_unit = 'Year';
        recPro.max_installment = 45300;
        recPro.rate = 'MRR + 7%';
        recPro.fee = '0.60%';
        recPro.offer_start_date = Date.valueOf('2017-07-01');
        recPro.offer_end_date = Date.valueOf('2019-07-08');
        recPro.status = 'Initial';
        
        recProList.add(recPro);
        
        ld.recommended_products = recProList;
        ld2.recommended_products = recProList;
        ldList.add(ld);
        ldList.add(ld2);
        
        test.startTest();
        
        RestRequest request = new RestRequest();
        request.requestUri = baseUrl+'/services/apexrest/leads/insertLeadswEligibleProducts';
        request.httpMethod = 'POST';
        
        RestContext.request = request;
        LeadsWithProductsCreationService.leadWrapper results = LeadsWithProductsCreationService.insertLeadswEligibleProducts(ldList);
        
        test.stopTest();
        
    }
    
    @isTest
    public static void insertLeadswEligibleProducts2()
    {                 
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        List<Account> acc = [SELECT Id, Name, ID_Type_PE__c, ID_Number_PE__c,RTL_NID__c,TMB_Customer_ID_PE__c FROM Account LIMIT 1];
        List<Campaign> cm = [SELECT Id,Name FROM Campaign LIMIT 1];
        List<LeadsWithProductsCreationService.leads> ldList = new List<LeadsWithProductsCreationService.leads>();
        LeadsWithProductsCreationService.leads ld = new LeadsWithProductsCreationService.leads();    
        ld.tmb_customer_id = '001100000000000000000000135497';
        ld.id_number = '5321379123454';
        ld.id_type = 'Passport ID';  
        ld.customer_type = 'Individual';
        ld.first_name = 'Commercial';
        ld.last_name = 'Lead';
        ld.mobile_number = '0934163327';
        ld.company_name = 'Commercial Lead';
        ld.campaign_id = cm[0].Id;
        ld.channel = 'Lazada';
        
        LeadsWithProductsCreationService.leads ld2 = new LeadsWithProductsCreationService.leads();    
        ld2.tmb_customer_id = '001100000000000000000000235497';
        ld2.id_number = acc[0].ID_Number_PE__c;
        ld2.id_type = acc[0].ID_Type_PE__c;  
        ld2.customer_type = 'Individual';
        ld2.first_name = 'Commercial2';
        ld2.last_name = 'Lead2';
        ld2.mobile_number = '0934163328';
        ld2.company_name = 'Commercial Lead';
        ld2.campaign_id = cm[0].Id;
        ld2.channel = 'Lazada';
                
        List<LeadsWithProductsCreationService.recommended_products> recProList = new List<LeadsWithProductsCreationService.recommended_products>();
        LeadsWithProductsCreationService.recommended_products recPro = new LeadsWithProductsCreationService.recommended_products();    
        recPro.project_code = '12345';
        recPro.product_name = 'SE Lazada Loan WC';
        recPro.product_code = '032814903522';
        recPro.host_product_mapping_id = 'a2N0p0000008Xh7EAE';
        recPro.max_offer_amount = 500000;
        recPro.max_tenor = 1;
        recPro.max_tenor_unit = 'Year';
        recPro.max_installment = 45300;
        recPro.rate = 'MRR + 7%';
        recPro.fee = '0.60%';
        recPro.offer_start_date = Date.valueOf('2017-07-01');
        recPro.offer_end_date = Date.valueOf('2019-07-08');
        recPro.status = 'Initial';
        
        recProList.add(recPro);
        
        ld.recommended_products = recProList;
        ld2.recommended_products = recProList;
        ldList.add(ld);
        ldList.add(ld2);
        
        test.startTest();
        
        RestRequest request = new RestRequest();
        request.requestUri = baseUrl+'/services/apexrest/leads/insertLeadswEligibleProducts';
        request.httpMethod = 'POST';
        
        RestContext.request = request;
        LeadsWithProductsCreationService.leadWrapper results = LeadsWithProductsCreationService.insertLeadswEligibleProducts(ldList);
        
        test.stopTest();
        
    }
    
    @isTest
    public static void insertLeadswEligibleProducts3()
    {                 
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        List<Account> acc = [SELECT Id, Name, ID_Type_PE__c, ID_Number_PE__c,RTL_NID__c,TMB_Customer_ID_PE__c FROM Account LIMIT 1];
        List<Campaign> cm = [SELECT Id,Name FROM Campaign LIMIT 1];
        List<LeadsWithProductsCreationService.leads> ldList = new List<LeadsWithProductsCreationService.leads>();
        LeadsWithProductsCreationService.leads ld = new LeadsWithProductsCreationService.leads();    
        ld.tmb_customer_id = acc[0].TMB_Customer_ID_PE__c;
        ld.id_number = '5321379123454';
        ld.id_type = 'Passport ID';  
        ld.customer_type = 'Individual';
        ld.first_name = 'Commercial';
        ld.last_name = 'Lead';
        ld.mobile_number = '0934163327';
        ld.company_name = 'Commercial Lead';
        ld.campaign_id = cm[0].Id;
        ld.channel = 'Lazada';
        
        LeadsWithProductsCreationService.leads ld2 = new LeadsWithProductsCreationService.leads();    
        ld2.tmb_customer_id = '001100000000000000000000235497';
        ld2.id_number = '6329379127779';
        ld2.id_type = 'Passport ID';  
        ld2.customer_type = 'Individual';
        ld2.first_name = 'Commercial2';
        ld2.last_name = 'Lead2';
        ld2.mobile_number = '0934163328';
        ld2.company_name = 'Commercial Lead';
        ld2.campaign_id = cm[0].Id;
        ld2.channel = 'Lazada';
        
        List<LeadsWithProductsCreationService.recommended_products> recProList = new List<LeadsWithProductsCreationService.recommended_products>();
        LeadsWithProductsCreationService.recommended_products recPro = new LeadsWithProductsCreationService.recommended_products();    
        recPro.project_code = '12345';
        recPro.product_name = 'SE Lazada Loan WC';
        recPro.product_code = '032814903522';
        recPro.host_product_mapping_id = 'a2N0p0000008Xh7EAE';
        recPro.max_offer_amount = 500000;
        recPro.max_tenor = 1;
        recPro.max_tenor_unit = 'Year';
        recPro.max_installment = 45300;
        recPro.rate = 'MRR + 7%';
        recPro.fee = '0.60%';
        recPro.offer_start_date = Date.valueOf('2017-07-01');
        recPro.offer_end_date = Date.valueOf('2019-07-08');
        recPro.status = 'Initial';
        
        recProList.add(recPro);
        
        ld.recommended_products = recProList;
        ld2.recommended_products = recProList;
        ldList.add(ld);
        ldList.add(ld2);
        
        test.startTest();
        
        RestRequest request = new RestRequest();
        request.requestUri = baseUrl+'/services/apexrest/leads/insertLeadswEligibleProducts';
        request.httpMethod = 'POST';
        
        RestContext.request = request;
        LeadsWithProductsCreationService.leadWrapper results = LeadsWithProductsCreationService.insertLeadswEligibleProducts(ldList);
        
        test.stopTest();
        
    } 
    
    @isTest
    public static void insertLeadswEligibleProducts4()
    {                 
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        List<Account> acc = [SELECT Id, Name, ID_Type_PE__c, ID_Number_PE__c,RTL_NID__c,TMB_Customer_ID_PE__c FROM Account LIMIT 1];
        List<Campaign> cm = [SELECT Id,Name FROM Campaign LIMIT 1];
        List<LeadsWithProductsCreationService.leads> ldList = new List<LeadsWithProductsCreationService.leads>();
        LeadsWithProductsCreationService.leads ld = new LeadsWithProductsCreationService.leads();    
        ld.tmb_customer_id = acc[0].TMB_Customer_ID_PE__c;
        ld.id_number = '5321379123454';
        ld.id_type = 'Passport ID';  
        ld.customer_type = 'Individual';
        ld.first_name = 'Commercial';
        ld.last_name = 'Lead';
        ld.mobile_number = '0934163327';
        ld.company_name = 'Commercial Lead';
        ld.campaign_id = cm[0].Id;
        ld.channel = 'Lazada';
        
        LeadsWithProductsCreationService.leads ld2 = new LeadsWithProductsCreationService.leads();    
        ld2.tmb_customer_id = acc[0].TMB_Customer_ID_PE__c;
        ld2.id_number = '6329379127779';
        ld2.id_type = 'Passport ID';  
        ld2.customer_type = 'Individual';
        ld2.first_name = 'Commercial2';
        ld2.last_name = 'Lead2';
        ld2.mobile_number = '0934163328';
        ld2.company_name = 'Commercial Lead';
        ld2.campaign_id = cm[0].Id;
        ld2.channel = 'Lazada';
        
        List<LeadsWithProductsCreationService.recommended_products> recProList = new List<LeadsWithProductsCreationService.recommended_products>();
        LeadsWithProductsCreationService.recommended_products recPro = new LeadsWithProductsCreationService.recommended_products();    
        recPro.project_code = '12345';
        recPro.product_name = 'SE Lazada Loan WC';
        recPro.product_code = '032814903522';
        recPro.host_product_mapping_id = 'a2N0p0000008Xh7EAE';
        recPro.max_offer_amount = 500000;
        recPro.max_tenor = 1;
        recPro.max_tenor_unit = 'Year';
        recPro.max_installment = 45300;
        recPro.rate = 'MRR + 7%';
        recPro.fee = '0.60%';
        recPro.offer_start_date = Date.valueOf('2017-07-01');
        recPro.offer_end_date = Date.valueOf('2019-07-08');
        recPro.status = 'Initial';
        
        recProList.add(recPro);
        
        ld.recommended_products = recProList;
        ld2.recommended_products = recProList;
        ldList.add(ld);
        ldList.add(ld2);
        
        test.startTest();
        
        RestRequest request = new RestRequest();
        request.requestUri = baseUrl+'/services/apexrest/leads/insertLeadswEligibleProducts';
        request.httpMethod = 'POST';
        
        RestContext.request = request;
        LeadsWithProductsCreationService.leadWrapper results = LeadsWithProductsCreationService.insertLeadswEligibleProducts(ldList);
        
        test.stopTest();
        
    } 
    
    @isTest
    public static void insertLeadswEligibleProducts5()
    {                 
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        List<Account> acc = [SELECT Id, Name, ID_Type_PE__c, ID_Number_PE__c,RTL_NID__c,TMB_Customer_ID_PE__c FROM Account LIMIT 1];
        
        List<Campaign> cm = [SELECT Id,Name FROM Campaign LIMIT 1];
        List<LeadsWithProductsCreationService.leads> ldList = new List<LeadsWithProductsCreationService.leads>();
        LeadsWithProductsCreationService.leads ld = new LeadsWithProductsCreationService.leads();    
        ld.tmb_customer_id = '001100000000000000000000535497';
        ld.id_number = '9321379123994';
        ld.id_type = 'Passport ID';  
        ld.customer_type = 'Individual';
        ld.first_name = 'Commercial';
        ld.last_name = 'Lead';
        ld.mobile_number = '0934163327';
        ld.company_name = 'Commercial Lead';
        ld.campaign_id = cm[0].Id;
        ld.channel = 'Lazada';
        
        LeadsWithProductsCreationService.leads ld2 = new LeadsWithProductsCreationService.leads();    
        ld2.tmb_customer_id = '001100000000000000000000235497';
        ld2.id_number = '6329379127779';
        ld2.id_type = 'Passport ID';  
        ld2.customer_type = 'Individual';
        ld2.first_name = 'Commercial2';
        ld2.last_name = 'Lead2';
        ld2.mobile_number = '0934163328';
        ld2.company_name = 'Commercial Lead';
        ld2.campaign_id = cm[0].Id;
        ld2.channel = 'Lazada';
        
        List<LeadsWithProductsCreationService.recommended_products> recProList = new List<LeadsWithProductsCreationService.recommended_products>();
        LeadsWithProductsCreationService.recommended_products recPro = new LeadsWithProductsCreationService.recommended_products();    
        recPro.project_code = '12345';
        recPro.product_name = 'SE Lazada Loan WC';
        recPro.product_code = '032814903522';
        recPro.host_product_mapping_id = 'a2N0p0000008Xh7EAE';
        recPro.max_offer_amount = 500000;
        recPro.max_tenor = 1;
        recPro.max_tenor_unit = 'Year';
        recPro.max_installment = 45300;
        recPro.rate = 'MRR + 7%';
        recPro.fee = '0.60%';
        recPro.offer_start_date = Date.valueOf('2017-07-01');
        recPro.offer_end_date = Date.valueOf('2019-07-08');
        recPro.status = 'Initial';
        
        recProList.add(recPro);
        
        ld.recommended_products = recProList;
        ld2.recommended_products = recProList;
        ldList.add(ld);
        ldList.add(ld2);
        
        test.startTest();
        
        RestRequest request = new RestRequest();
        request.requestUri = baseUrl+'/services/apexrest/leads/insertLeadswEligibleProducts';
        request.httpMethod = 'POST';
        
        RestContext.request = request;
        LeadsWithProductsCreationService.leadWrapper results = LeadsWithProductsCreationService.insertLeadswEligibleProducts(ldList);
        
        test.stopTest();
        
    } 
    
}