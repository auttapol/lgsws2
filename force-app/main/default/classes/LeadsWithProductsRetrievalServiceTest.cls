@isTest
public class LeadsWithProductsRetrievalServiceTest {
    
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
        
        Lead lead = new Lead();
        lead.Title = 'TH';
        lead.Company = 'X';
        lead.FirstName = 'Test';
        lead.LastName = 'TestLead';
        lead.Email = 'test@salesforce.com';
        lead.Status = 'New';
        lead.Street = 'aaa';
        lead.City = 'bbb';
        lead.State = 'CC';
        lead.PostalCode = '1111111';
        lead.Country = 'DD';
        lead.ID_Number__c = acc.ID_Number_PE__c;
        lead.ID_Type__c = acc.ID_Type_PE__c;
        lead.Account__c = acc.Id;
        lead.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Digital Channel').getRecordTypeId();
        insert lead;      
        
        List<Product_Interest__c> PIList = new List<Product_Interest__c>();
        
        Product_Interest__c PINonCreDit = new Product_Interest__c();
        PINonCreDit.Opportunity_Type__c ='Non-Credit';
        PINonCreDit.Amount__c =500000;
        //PINonCreDit.Product__c = prod.id;
        PINonCreDit.Lead__c = lead.id;
        PIList.add(PINonCreDit);
        
        
        Product_Interest__c PICreDit = new Product_Interest__c();
        PICreDit.Opportunity_Type__c ='Credit';
        PICreDit.Amount__c =500000;
        //PICreDit.Product__c = prod2.id;
        PICreDit.Lead__c = lead.id;
        PIList.add(PICreDit);
        
        insert PIList;
          
	}
    
    @isTest
    public static void getLeadswEligibleProducts()
    {     
        test.startTest();
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        List<Account> acc = [SELECT Id, Name, ID_Type_PE__c, ID_Number_PE__c,RTL_NID__c,TMB_Customer_ID_PE__c FROM Account LIMIT 1];
        List<Lead> lead = [SELECT Id,Name,Account__c,ID_REGEX__c,TMB_Cust_ID__c FROM Lead Where ID_REGEX__c != null LIMIT 1];       

        RestRequest request = new RestRequest();
        request.requestUri = baseUrl +'/services/apexrest/leads/getLeadswEligibleProducts';
        request.httpMethod = 'POST';
        
        RestContext.request = request;
        LeadsWithProductsRetrievalService.leadWrapper results = LeadsWithProductsRetrievalService.getLeadswEligibleProducts(acc[0].ID_Number_PE__c,null,null);
        
        test.stopTest();

    }
  
}