@IsTest
public class SubmitForApprovalExtensionTest {
    
    static {
        TestUtils.createIdType();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();
        TestUtils.createDisqualifiedReason();
        //TestUtils.CreateTriggerMsg();
        TestInit.createCustomSettingStageApproval();
        
    }
    
    public static testmethod void positiveTest(){        
        //TestUtils.createUsers(1,'AccountOwner', 'Ownertest','OwnerIDtest@tmbbank.com', true).get(0);
        //User u = TestUtils.userList.get(0);
        System.debug(':::: RunPositiveTestTask Start ::::');
        //TestInit.createUser(false);
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'SFDC2', Email='standarduser-ii@tmbbank.com', 
                          EmailEncodingKey='UTF-8', LastName='II', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id,Employee_ID__c='LA002',
                          Zone_Code__c='HHHH',Segment__c='SS',Zone__c = 'TEST',
                          TimeZoneSidKey='America/Los_Angeles', UserName='i2i@tmbbank.com'); 
        insert u;
        TestUtils.CreateTriggerMsg();
        System.runAs(u) {
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
            System.debug('Current User Id: ' + UserInfo.getUserId()); 
            //Test for T02            
            TestInit.createAccount(1);
            List<Account> accountList = TestInit.accountList.values();
            TestInit.createOpportunity(accountList);
            
            List<Opportunity> opportunityList = TestInit.opportunityList.values();
            
             Pricebook2 pb = new Pricebook2(Name = 'Commercial Pricebook', 
                                           TMB_Pricebook__c ='TMB5412',
                                           Description = 'Price Book 2009 Products', IsActive = true);
            insert pb;
            
            Product2 prod = new Product2(Name = 'Laptop X200',
                                    Family = 'Hardware',
                                    Product_Level__c ='1');
            
        
            insert prod;
        
        Product2 prod2 = new Product2(Name = 'Laptop X100',
                                    Family = 'Hardware',
                                    Product_Level__c ='1');
            
        
            insert prod2;
        
        PricebookEntry standardPBE 
            = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                 Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                Product2Id = prod.Id, 
                                                UnitPrice = 1000, IsActive = true);
        insert pbe;
        
        
        PricebookEntry standardPBE2 
            = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                 Product2Id = prod2.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE2;
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                Product2Id = prod2.Id, 
                                                UnitPrice = 1000, IsActive = true);
        insert pbe2;
        
            
            opportunityList.get(0).Pricebook2ID = pb.id;
            update opportunityList.get(0);
            
            OpportunityLineItem oppLine = new OpportunityLineItem(pricebookentryid=pbe2.Id,
                                                                  TotalPrice=2000,Quantity = 2,
                                                                  OpportunityID = opportunityList.get(0).Id);
insert oppLine;
            
            
            System.debug(opportunityList.get(0));
            System.debug(opportunityList.get(0).id);
            ApexPages.StandardController sc = new ApexPages.StandardController(opportunityList.get(0));
            SubmitForApprovalExtension submitApproval = new SubmitForApprovalExtension(sc);
            submitApproval.checkSubmitForApproval();
            //acc = [ select Id,Name,Account_Type__c,ID_populated__c from Account where Id = :acc.Id ];
            //update acc;
            accountList.get(0).Account_Type__c = 'Qualified Prospect';
            update accountList.get(0);
            
            opportunityList.get(0).StageName = 'Closed Lost';
            opportunityList.get(0).Reason_of_Lost__c = 'Closed Lost';
            update opportunityList.get(0);
            submitApproval.checkSubmitForApproval();
            accountList.get(0).ID_Type_PE__c = 'alien Id';
            accountList.get(0).ID_Number_PE__c = '1515011';         
            update accountList.get(0);
            submitApproval.checkSubmitForApproval();
            
            Call_Report__c report = new Call_Report__c();
            report.Customer_name__c = accountList.get(0).id;
            report.Status__c ='2 - Completed';
            report.Categories__c = 'Pre boarding';
        	report.Main_purpose__c ='First visit';
        	report.Date_of_Visit__c  = System.today();
        	report.Complete_Date__c = System.today();
        	report.Outcome__c ='Win Deal';
        	report.OwnerId = Userinfo.getUserId();
        	report.Actual_Visit_Date__c = System.today();
        	report.Sub_Purpose__c = 'Credit';
            
            insert report;
            
            Visit_Report_Opportunity__c visitopp = new Visit_Report_Opportunity__c();
            visitopp.Opportunity__c = opportunityList.get(0).id;
            visitopp.Customer__c = report.id;
            
            insert visitopp;
            
            submitApproval.checkSubmitForApproval(); 
        }
    }
    
}