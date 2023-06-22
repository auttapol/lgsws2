@IsTest
public class DigitalLeadExpiredServiceBatch_Test{
    private static void createCustomSettingForDigitalLeadExpired() {
        List<Digital_Lead_Expire_Batch__c> digitalLeadList = new List<Digital_Lead_Expire_Batch__c>();

        Digital_Lead_Expire_Batch__c digitalLead = new Digital_Lead_Expire_Batch__c();
        digitalLead.Name = 'Lazada_Lead_Expire Test';
        digitalLead.Active__c = true;
        digitalLead.SQL__c = 'SELECT Id,Lead__c '
                                + 'FROM Product_Interest__c '
                                + 'Where Offer_end_date__c < TODAY '
                                + 'AND Lead__r.RecordType.DeveloperName = \'Commercial_Digital_Channel\' '
                                + 'AND Lead__r.LeadSource = \'Lazada\' '
                                + 'AND Lead__r.Status <> \'Converted\' '
                                + 'AND Lead__r.Status <> \'Expired\'';

        Digital_Lead_Expire_Batch__c digitalLead2 = new Digital_Lead_Expire_Batch__c();
        digitalLead2.Name = 'Lazada_Lead_Expire Test 2';
        digitalLead2.Active__c = true;
        digitalLead2.SQL__c = 'SELECT Id,Lead__c '
                                + 'FROM Product_Interest__c '
                                + 'Where Offer_end_date__c < TODAY '
                                + 'AND Lead__r.RecordType.DeveloperName = \'Commercial_Digital_Channel\' '
                                + 'AND Lead__r.LeadSource = \'Lazada\' '
                                + 'AND Lead__r.Status <> \'Expired\'';

        digitalLeadList.add(digitalLead);
        digitalLeadList.add(digitalLead2);

        insert digitalLeadList;
    }

    public static void createProductInterest(){
        // Id commercialProfile = [SELECT Id FROM Profile WHERE Name = 'TMB RM Profile' LIMIT 1].Id;
        // User commercialUser = new User( FirstName = 'NewUser' , LastName = 'Commercial', 
        //                                 UserName='newUserCommercial@tmbbank.com',
        //                                 Email='newUserCommercial@tmbbank.com', Alias='Testtmb',
        //                                 LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
        //                                 CommunityNickname='commercialUser',
        //                                 ProfileId = commercialProfile, TimeZoneSidKey='America/New_York',isActive = true,
        //                                 Employee_ID__c ='MM101', segment__c = 'MB');
        insert new Price_book_access__c(name='Default',PricebookItem__c='Commercial Pricebook');        
        
        // System.runAs(commercialUser){

            // Create Lead.
            Id digitalLeadRecordTypeId = [SELECT id,Name FROM RecordType 
                                            WHERE DeveloperName='Commercial_Digital_Channel' 
                                            AND sObjectType='Lead' LIMIT 1].Id;
            Lead leadRec = new Lead();
            leadRec.Phone = '0877874871';
            leadRec.Company = 'LeadExtension';
            leadRec.ID_Type__c = 'BRN ID';
            leadRec.ID_Number__c = '13255555';
            leadRec.Mobile_No__c = '053532198';
            leadRec.Customer_Type__c = 'Juristic';
            leadRec.FirstName =  'LeadExFirst';
            leadRec.LastName = 'LeadExLast';
            leadRec.RecordTypeId = digitalLeadRecordTypeId;
            leadRec.Interest_result__c = 'Yes';
            leadRec.LeadSource = 'Lazada';
            insert leadRec;
            // System.debug('Lead Id: ' + leadRec);

            // Create Product
            Pricebook2 pb = new Pricebook2( Name = 'Commercial Pricebook', 
                                            TMB_Pricebook__c ='TMB5412',
                                            Description = 'Price Book 2009 Products', IsActive = true);
            insert pb;
            Product2 prod = new Product2(Name = 'Laptop X200',
                                        Family = 'Hardware',
                                        Product_Level__c ='1',
                                        IsActive = true);
            insert prod;
            // System.debug('Prod Id: ' + prod.Id);
            Product2 prod2 = new Product2(Name = 'Laptop X100',
                                        Family = 'Hardware',
                                        Product_Level__c ='1',
                                        IsActive = true);
            insert prod2;
            System.debug('Prod2 Id: ' + prod2.Id);

            // Insert Pricebook
            PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                            Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
            insert standardPBE;
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                    Product2Id = prod.Id, 
                                                    UnitPrice = 1000, IsActive = true);
            insert pbe;
            
            PricebookEntry standardPBE2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                            Product2Id = prod2.Id, UnitPrice = 1000, IsActive = true);
            insert standardPBE2;
            PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                    Product2Id = prod2.Id, 
                                                    UnitPrice = 1000, IsActive = true);
            insert pbe2;

            // Create Product Interest.
            List<Product_Interest__c> PIList = new List<Product_Interest__c>();

            Product_Interest__c PINonCreDit = new Product_Interest__c();
            PINonCreDit.Opportunity_Type__c ='Non-Credit';
            PINonCreDit.Amount__c =500000;
            PINonCreDit.Product__c = prod.id;
            PINonCreDit.Lead__c = leadRec.id;
            PINonCreDit.Offer_end_date__c = system.Today().addDays(-1);
            PIList.add(PINonCreDit);

            Product_Interest__c PICreDit = new Product_Interest__c();
            PICreDit.Opportunity_Type__c ='Credit';
            PICreDit.Amount__c =500000;
            PICreDit.Product__c = prod2.id;
            PICreDit.Lead__c = leadRec.id;
            PICreDit.Offer_end_date__c = system.Today().addDays(-1);
            PIList.add(PICreDit);

            //insert PIList;
        // }
    }


    public static testmethod void testForDigitalLeadExpriedSchedule(){
	 	Test.startTest();
        TestUtils.createAppConfig();
        createProductInterest();
        createCustomSettingForDigitalLeadExpired();
        
            System.schedule('DigitalLeadExpiredServiceBatch_Test'+' '+'0 0 12 * * ? *'
                          , '0 0 12 * * ? *'
                          , new DigitalLeadExpiredServiceBatch());
        Test.stopTest();

    }

}