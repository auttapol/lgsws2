public class RecommendedProductTriggerHandler {

    public RecommendedProductTriggerHandler()
    {
    
    }
    
    
     public static User currentUser {get{
        if(currentUser==null){
            currentUser =[ select Id,Region__c,Zone__c,Segment__c from User where Id = :UserInfo.getUserId() ];
    
        }
        return currentUser;
    }set;}
    
    
    public static String PricebookId {get{
        if(PricebookID==null){
            String user_segment;
            
            if(currentUser.Segment__c ==null){
                user_segment= 'Default';
            }else{
                user_segment = currentUser.Segment__c;
            }
            
           // Price_book_access__c pba = [select PricebookItem__c from Price_book_access__c where name =: user_segment];
            
            PricebookID =  [select id 
                            from pricebook2 
                            where name =: Price_book_access__c.getValues(user_segment).PricebookItem__c
                           ].get(0).id;
        }
        return PricebookID;
    }set;}

    public static void checkProductPricebook(list<Product_Interest__c> listRecomendedProduct, list<Product_Interest__c> listOld)
    {
        system.debug('start RecommendedProductTriggerHandler : checkProductPricebook');
        try {
        
         //   string user_segment = [select segment__c from user where id =: userinfo.getUserId()].segment__c;
           // if (user_segment == null) user_segment = 'Default';
            
           // Price_book_access__c pba = [select PricebookItem__c from Price_book_access__c where name =: user_segment];     
            //string pricebookId = [select id from pricebook2 where name =: pba.PricebookItem__c].get(0).id;

    
            boolean Change = false;
            map<string,string> oldTemp = new map<string,string>();
            for (Product_Interest__c p : listOld)
            {
                oldTemp.put(p.id, p.product__c);
            }
            for (Product_Interest__c p : listRecomendedProduct)
            {
                if (p.product__c != oldTemp.get(p.id))
                    Change = true;
            }
    
            if (Change)
            {
                if (listRecomendedProduct.get(0).product__c != null)
                {   
                    list<pricebookentry> pbe = [select id from pricebookentry 
                                                where Pricebook2id =: pricebookid 
                                                and Product2id =: listRecomendedProduct.get(0).product__c and isActive = true];
                    
                    if (pbe.size() == 0)
                        listRecomendedProduct.get(0).product__c.addError(Status_Code__c.getValues('8001').Status_Message__c);
                }else{
                    listRecomendedProduct.get(0).product__c.addError(Status_Code__c.getValues('8005').Status_Message__c);
                    system.debug('4');
                }
            }
        }catch(exception ex){
            System.debug('StackTraceString : ' + ex.getStackTraceString());
            System.debug('line : ' + ex.getLineNumber());
            System.debug('error : ' + ex.getMessage());
            listRecomendedProduct.get(0).product__c.addError(ex.getMessage());
        }
    }
    
    public static void checkDuplicateRecommendedProduct(list<Product_Interest__c> listRecomendedProduct, list<Product_Interest__c> listOldRecommendedProduct)
    {
        system.debug('start RecommendedProductTriggerHandler : checkDuplicateRecommendedProduct');
        try {
        
            boolean error = false;
            
            set<string> mapOldRecommendredProduct = new set<string>();
            for (Product_Interest__c c : listOldRecommendedProduct)
            {
                mapOldRecommendredProduct.add(string.valueof(c.lead__c)+string.valueof(c.product__c)+c.opportunity_type__c);
            }
            
            set<string> listCheckRecommendedProductDuplicate = new set<string>();
            list<string> listLeadId = new list<string>();
            boolean Change = false;
            
            for (Product_Interest__c c : listRecomendedProduct) // new list campaign product duplicate
            {
                if (!mapOldRecommendredProduct.contains(string.valueof(c.lead__c)+string.valueof(c.product__c)+c.opportunity_type__c))
                {
                    if (listCheckRecommendedProductDuplicate.contains(string.valueof(c.lead__c)+string.valueof(c.product__c)+c.Opportunity_Type__c) && c.Host_Product_Mapping__c == null)
                        error = true;
                    listCheckRecommendedProductDuplicate.add(string.valueof(c.lead__c)+string.valueof(c.product__c)+c.opportunity_type__c);
                    listLeadId.add(c.lead__c);
                    Change = true;
                }
            }
     
            if (Change)
            {
                for (Product_Interest__c c : [select lead__c, product__c, opportunity_type__c, Host_Product_Mapping__c
                                              from Product_Interest__c where lead__c in : listLeadId])
                {
                    if (listCheckRecommendedProductDuplicate.contains(string.valueof(c.lead__c)+string.valueof(c.product__c)+c.opportunity_type__c)
                        && !mapOldRecommendredProduct.contains(string.valueof(c.lead__c)+string.valueof(c.product__c)+c.opportunity_type__c)  && c.Host_Product_Mapping__c == null)
                    {
                        system.debug(c.lead__c);
                        error = true;
                    }
                }
            }

            if (error)
                listRecomendedProduct.get(0).product__c.addError(Status_Code__c.getValues('8013').Status_Message__c);
        }catch(exception ex){
            system.debug('error : ' + ex.getMessage());
            listRecomendedProduct.get(0).product__c.addError(ex.getMessage());
        }
    
    }
    
}