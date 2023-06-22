public without sharing class QCA_SLSProductController {
    public QCA_SLSProductController() {

    }

    public class HostProductMappingWrapper {
        @AuraEnabled
        public List<Host_Product_Mapping__c> HostProductMappingFieldValues {get; set;}
        @AuraEnabled
        public List<Product_Interest__c> MyRecommendedProduct {get; set;}
        @AuraEnabled
        public List<OpportunityLineItem> MyOpportunityLineItem {get; set;}
    }

    @AuraEnabled
    public static HostProductMappingWrapper onInitQCASLSProduct(Id relatedRecordId, String flowType)
    {
        HostProductMappingWrapper hostProdMapWrapper = new HostProductMappingWrapper();
        hostProdMapWrapper.HostProductMappingFieldValues = getHostProductMappingFieldValues();
        if(flowType == 'QCALeadType'){
            hostProdMapWrapper.MyRecommendedProduct = getMyRecommendedProduct(relatedRecordId);
        }
        else if(flowType == 'QCAOpptyType')
        {
            hostProdMapWrapper.MyOpportunityLineItem = getMyOpportunityLineItem(relatedRecordId);
        }
        return hostProdMapWrapper;
    }

    @AuraEnabled
    public static List<Host_Product_Mapping__c> getHostProductMappingFieldValues()
    {
        return [SELECT Id, Host_Name__c, Host_Product_Group__c, Product_Program__c, Host_Prod_Name_Credit_Facility__c, Salesforce_Product__c, Salesforce_Product__r.Name FROM Host_Product_Mapping__c WHERE Host_Name__c = 'SLS'];
    }

    @AuraEnabled
    public static List<Product_Interest__c> getMyRecommendedProduct(Id leadObjId){
        try {
            return [SELECT Id, Name, Amount__c, Opportunity_Type__c, Lead__c, Product__c, Related_Account__c, Status__c, 
                    Host_Product_Mapping__c, Host_Product_Mapping__r.Name, Host_Product_Mapping__r.Host_Product_Group__c, Host_Product_Mapping__r.Product_Program__c, 
                    Host_Product_Mapping__r.Host_Prod_Name_Credit_Facility__c, Host_Product_Mapping__r.Salesforce_Product__c, 
                    Host_Product_Mapping__r.Salesforce_Product__r.Name FROM Product_Interest__c WHERE Lead__c =: leadObjId AND Host_Product_Mapping__r.Host_Name__c = 'SLS'];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<OpportunityLineItem> getMyOpportunityLineItem(Id opptyId){
        try {
            return [SELECT Id, Name, Product2.Name, product2Id, Host_Product_Mapping__c, Host_Product_Mapping__r.Host_Name__c, Host_Product_Mapping__r.Host_Product_Group__c
                    , Host_Product_Mapping__r.Product_Program__c, Host_Product_Mapping__r.Host_Prod_Name_Credit_Facility__c, Host_Product_Mapping__r.Salesforce_Product__c
                    , Host_Product_Mapping__r.Salesforce_Product__r.Name, Quantity, UnitPrice, PricebookEntryId, opportunity.Host_Product_Group__c,Host_Product_Group__c
                    FROM OpportunityLineItem Where OpportunityId =: opptyId AND Host_Product_Mapping__r.Host_Name__c = 'SLS' ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveSLSProduct(String SLSProductList, Id relatedRecordId, Boolean isNewLead)
    {
        Savepoint sp = Database.setSavepoint();
        try {
            // User u = QCA_LeadSimplifiedController.getUserCurrent();
            // Host Product Mapping
            List<Object> tmpSLSProductList = (List<Object>)JSON.deserializeUntyped(SLSProductList);
            System.debug('tmpSLSProductList.size() ::: ' + tmpSLSProductList.size());
			System.debug('tmpSLSProductList ::: ' + tmpSLSProductList);

            // Lead 
            if(isNewLead == true)
            {
                Map<Id, Product_Interest__c> recommendedProductExistsMap = new Map<Id, Product_Interest__c>([
                    SELECT Id, Host_Product_Mapping__c, Lead__c, Product__c, Amount__c, OwnerId
                    FROM Product_Interest__c 
                    WHERE Lead__c = :relatedRecordId
                    ]);

                // List<Product_Interest__c> changOwnerProudct = new List<Product_Interest__c>();
                // for (Product_Interest__c pi : recommendedProductExistsMap.values()) {
                //     pi.OwnerId = u.Id;
                //     // changOwnerProudct.add(pi);
                // }
                // update recommendedProductExistsMap.values();
                
                Set<Id> selectRecommendedProductSetId = new Set<Id>();
                List<Product_Interest__c> recommendedProductList = new List<Product_Interest__c>();

                // insert & update -> upsert
                for (Object productItem : tmpSLSProductList) {
                    Map<String, Object> tempItemMap = (Map<String, Object>) productItem;
                    Product_Interest__c tmpProductInterest = new Product_Interest__c();

                    if(tempItemMap.get('Product_Interest_Id') != '' && tempItemMap.get('Product_Interest_Id') != null
                        && recommendedProductExistsMap.containsKey((Id)tempItemMap.get('Product_Interest_Id'))){
                        tmpProductInterest.Id = (Id)tempItemMap.get('Product_Interest_Id');
                        selectRecommendedProductSetId.add((Id)tempItemMap.get('Product_Interest_Id'));
                    }

                    tmpProductInterest.Lead__c = relatedRecordId;
                    tmpProductInterest.Host_Product_Mapping__c = (Id)tempItemMap.get('Id');
                    tmpProductInterest.Product__c = (Id)tempItemMap.get('Salesforce_Product__c');
                    tmpProductInterest.Amount__c = Decimal.ValueOf((String)tempItemMap.get('Amount__c'));
                    
                    recommendedProductList.add(tmpProductInterest);
                }

                // Delete
                for (Id recommendedProductId : selectRecommendedProductSetId) {
                    if (recommendedProductExistsMap.containsKey((Id)recommendedProductId)) {
                        recommendedProductExistsMap.remove((Id)recommendedProductId);
                    }
                }
                List<Product_Interest__c> deleteProductInterestList = recommendedProductExistsMap.values();
                if(deleteProductInterestList.size() > 0){
                    System.debug(deleteProductInterestList);
                    delete deleteProductInterestList;
                }

                // Upsert
                if(recommendedProductList.size() > 0){
                    System.debug(recommendedProductList);
                    upsert recommendedProductList;
                }
            }
            // Opportunity 
            else if(isNewLead == false) 
            {
                Map<Id, OpportunityLineItem> opptyProductExistsMap = new Map<Id, OpportunityLineItem>([
                    SELECT Id, Host_Product_Mapping__c, OpportunityId, product2Id, UnitPrice, Host_Product_Group__c 
                    FROM OpportunityLineItem 
                    WHERE OpportunityId = :relatedRecordId
                ]);               

                Set<Id> selectOpptyProductSetId = new Set<Id>();
                List<OpportunityLineItem> opptyLineItemList = new List<OpportunityLineItem>();
                String hostProductGroupName;
                String hostProductSystem;

                // insert & update -> upsert
                for (Object productItem : tmpSLSProductList) {
                    Map<String, Object> tempItemMap = (Map<String, Object>) productItem;
                    OpportunityLineItem tmpProductInterest = new OpportunityLineItem();

                    if(tempItemMap.get('OpportunityLineItem_Id') != '' && tempItemMap.get('OpportunityLineItem_Id') != null
                        && opptyProductExistsMap.containsKey((Id)tempItemMap.get('OpportunityLineItem_Id'))){
                        tmpProductInterest.Id = (Id)tempItemMap.get('OpportunityLineItem_Id');
                        selectOpptyProductSetId.add((Id)tempItemMap.get('OpportunityLineItem_Id'));
                    }
                    else
                    {
                        tmpProductInterest.OpportunityId = relatedRecordId;
                        tmpProductInterest.product2Id = (Id)tempItemMap.get('Salesforce_Product__c');                                           
                    }
                    tmpProductInterest.Host_Product_Mapping__c = (Id)tempItemMap.get('Id'); 
                    tmpProductInterest.UnitPrice = Decimal.ValueOf((String)tempItemMap.get('Amount__c')); 
                    tmpProductInterest.Quantity = 1;                                                   
                    opptyLineItemList.add(tmpProductInterest);

                    hostProductGroupName = (String)tempItemMap.get('Host_Product_Group__c');  
                    hostProductSystem = 'SLS';
                }

                // Delete
                for (Id OpptyProductId : selectOpptyProductSetId) {
                    if (opptyProductExistsMap.containsKey((Id)OpptyProductId)) {
                        opptyProductExistsMap.remove((Id)OpptyProductId);
                    }
                }
                List<OpportunityLineItem> deleteOpptyLineList = opptyProductExistsMap.values();
                if(deleteOpptyLineList.size() > 0){
                    System.debug(deleteOpptyLineList);
                    delete deleteOpptyLineList;
                }

                // Upsert and track host product group
                Opportunity oppty = new Opportunity(
                    Id = relatedRecordId,
                    Host_Product_Group__c = hostProductGroupName,
                    Host_System__c = hostProductSystem
                    );
                // oppty.Host_Product_Group__c = hostProductGroupName;
                update oppty;
                if(opptyLineItemList.size() > 0){
                    System.debug(opptyLineItemList);
                    upsert opptyLineItemList;
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }
}