@isTest
public class CampaignProductTriggerHandlerTest {

    static id pb1 {get{return Test.getStandardPricebookId();}set;}
    static pricebook2 pb2 {get;set;}
    static product2 prod {get;set;}
    static product2 prod2 {get;set;}
    static pricebookentry pbe {get;set;}
    static pricebookentry pbe2 {get;set;}
    
    static void setInitial()
    {        
		TestUtils.createAppConfig();
        RTL_CampaignMember_Running_No__c cmrn = new RTL_CampaignMember_Running_No__c(
            Name = 'Campaign Member Running No',
            Running_No__c = '000000'
            );
        insert cmrn;
        
        insert new status_code__c(name = '8001', Status_Message__c = 'test');
        insert new status_code__c(name = '8007', Status_Message__c = 'test');
        insert new AppConfig__c(name = 'runtrigger', value__c = 'TRUE');
        pb2 = new pricebook2(name='Standard Price Book',isActive=true,TMB_Pricebook__c='test');insert pb2;
        prod = new product2(name='test',isactive=true,Product_Domain__c='Risk');insert prod;
        prod2 = new product2(name='test',isactive=true,Product_Domain__c='Risk');insert prod2;
        pricebookentry pbe3 = new pricebookentry(isactive=false,unitprice=1.00,product2id=prod.id,pricebook2id=pb1);insert pbe3;
        pricebookentry pbe4 = new pricebookentry(isactive=false,unitprice=1.00,product2id=prod2.id,pricebook2id=pb1);insert pbe4;
        pbe = new pricebookentry(isactive=true,unitprice=1.00,product2id=prod.id,pricebook2id=pb2.id);insert pbe;
        pbe2 = new pricebookentry(isactive=true,unitprice=1.00,product2id=prod2.id,pricebook2id=pb2.id);insert pbe2;
    	user u = [select segment__c from user where id =: userinfo.getUserId()];
        if (u.segment__c != null){
            insert new Price_book_access__c(name=u.segment__c,PricebookItem__c='Standard Price Book');
            insert new Price_book_access__c(name='Default',PricebookItem__c='Standard Price Book');
    	}else{
            insert new Price_book_access__c(name='MB',PricebookItem__c='Standard Price Book');
            insert new Price_book_access__c(name='Default',PricebookItem__c='Standard Price Book');
        }
    }
    
    static testmethod void positive()
    {
        setInitial();
        
        test.startTest();
        
        CampaignProductTriggerHandler app = new CampaignProductTriggerHandler();
        campaign camp = new campaign(name='test');
        insert camp;
        campaign_product__c camppro = new Campaign_Product__c(Campaign__c=camp.id,amount__c=100.00,product__c=prod.id);insert camppro;
        
        
        Lead leadRec = new Lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'Passport ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Individual';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        
        
         insert leadRec;
        campaignMember cMember = new campaignMember();
        cMember.LeadID = leadRec.id;
        cMember.CampaignId = camp.id;
        insert cMember;
        
        delete cMember;
        test.stopTest();
    }
    
    static testmethod void negative()
    {
        setInitial();
        
        test.startTest();
        
        CampaignProductTriggerHandler app = new CampaignProductTriggerHandler();
        campaign camp = new campaign(name='test');insert camp;
        campaign_product__c camppro = new Campaign_Product__c(Campaign__c=camp.id,amount__c=100.00,product__c=prod.id);insert camppro;
        //update camppro;
        
        test.stopTest();
    }
    
    
}