public class CampaignProductTriggerHandler {

    public CampaignProductTriggerHandler()
    {
    
    }

    public static void checkProductPricebook(list<Campaign_Product__c> listCampaignProduct, list<Campaign_Product__c> listOld)
    {
        system.debug('start CampaignProductTriggerHandler : checkProductPricebook');
        try {
        
            string user_segment = [select segment__c from user where id =: userinfo.getUserId()].segment__c;
            if (user_segment == null) user_segment = 'Default';

            Price_book_access__c pba = [select PricebookItem__c from Price_book_access__c where name =: user_segment];     
            string pricebookId = [select id from pricebook2 where name =: pba.PricebookItem__c].get(0).id;


            boolean Change = false;
            map<string,string> oldTemp = new map<string,string>();
            for (Campaign_Product__c c : listOld)
            {
                oldTemp.put(c.id, c.product__c);
            }
            for (Campaign_Product__c c : listCampaignProduct)
            {
                if (c.product__c != oldTemp.get(c.id))
                    Change = true;
            }
            
            
            if (Change)
            {
                if (listCampaignProduct.get(0).product__c != null)
                {
                    list<pricebookentry> pbe = [select id from pricebookentry where Pricebook2id =: pricebookid and Product2id =: listCampaignProduct.get(0).product__c and isActive = true];
                    if (pbe.size() == 0)
                        listCampaignProduct.get(0).product__c.addError(Status_Code__c.getValues('8001').Status_Message__c);
                }else{
                    listCampaignProduct.get(0).product__c.addError(Status_Code__c.getValues('8005').Status_Message__c);
                }
            }
            
        }catch(exception ex){
            system.debug('error : ' + ex.getMessage());
            listCampaignProduct.get(0).product__c.addError(ex.getMessage());
        }
    }
    
    public static void checkDuplicateCampaignProduct(list<Campaign_Product__c> listCampaignProduct, list<Campaign_Product__c> listOld)
    {
        system.debug('start CampaignProductTriggerHandler : checkDuplicateCampaignProduct');
        try {
        
            boolean error = false;
            
            
            boolean Change = false;
            map<string,string> oldTemp = new map<string,string>();
            for (Campaign_Product__c c : listOld)
            {
                oldTemp.put(c.id, c.product__c+c.Opportunity_Type__c);
            }
            for (Campaign_Product__c c : listCampaignProduct)
            {
                if (c.product__c+c.Opportunity_Type__c != oldTemp.get(c.id))
                    Change = true;
            }
            
            
            if (Change)
            {
                set<string> listCheckCampaignProductDuplicate = new set<string>();
                list<string> listCampaignId = new list<string>();
                for (Campaign_Product__c c : listCampaignProduct) // new list campaign product duplicate
                {
                    if (listCheckCampaignProductDuplicate.contains(string.valueof(c.campaign__c)+string.valueof(c.product__c)+c.Opportunity_Type__c))
                        error = true;
                    listCheckCampaignProductDuplicate.add(string.valueof(c.campaign__c)+string.valueof(c.product__c)+c.opportunity_type__c);
                    listCampaignId.add(c.campaign__c);
                }
            
                for (campaign_product__c c : [select campaign__c, product__c, opportunity_type__c
                                              from campaign_product__c where campaign__c in : listCampaignId])
                {
                    if (listCheckCampaignProductDuplicate.contains(string.valueof(c.campaign__c)+string.valueof(c.product__c)+c.opportunity_type__c))
                        error = true;
                }
            }
                
            if (error)
                listCampaignProduct.get(0).product__c.addError(Status_Code__c.getValues('8007').Status_Message__c);
            
        }catch(exception ex){
            system.debug('error : ' + ex.getMessage());
            listCampaignProduct.get(0).product__c.addError(ex.getMessage());
        }
    }

    public static void calExpectedRevenue(list<Campaign_Product__c> listCampaignProduct)
    {
        system.debug('start CampaignProductTriggerHandler : calExpectdRevenue');
        try {
        
            campaign campaignObj = [select id, expectedRevenue from campaign where id =: listCampaignProduct.get(0).campaign__c];
            decimal revenue = 0.00;
            for (campaign_product__c campaignProduct : [select Amount__c from campaign_product__c where campaign__c =: campaignObj.id])
            {
                revenue += campaignProduct.Amount__c;
            }
            
            campaignObj.expectedRevenue = revenue;
            update campaignObj;
        
        }catch(exception ex){
            system.debug('error : ' + ex.getMessage());
        }
    }
    
}