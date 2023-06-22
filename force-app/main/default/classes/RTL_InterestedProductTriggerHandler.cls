public with sharing class RTL_InterestedProductTriggerHandler extends TriggerHandler {

    public static Id RTL_API_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'Retail Integration API Only' LIMIT 1].Id;

    public static Id CURRENT_PROFILE_ID = UserInfo.getProfileId();

    public RTL_InterestedProductTriggerHandler(){
        if(Test.isRunningTest()){
            this.setMaxLoopCount(10);
        }
        else{
            this.setMaxLoopCount(5000);
        }
        System.Debug( 'TMB: -> RTL_InterestedProductTriggerHandler Invoked' );
    }

    protected override void afterInsert(map<id,SObject> newMap) {      
        System.Debug('TMB: -> RTL_InterestedProductTriggerHandler start of afterInsert');
        updateLeadPrimaryCount(null, newMap);
        updateLeadPrimaryInterestedProduct(null, newMap);
    }   
    
    protected override void afterUpdate(map<id,sObject> oldMap, map<id,sObject> newMap) {      
        System.Debug('TMB: -> RTL_InterestedProductTriggerHandler start of afterUpdate');  
        updateLeadPrimaryCount(oldMap,newMap);
        updateLeadPrimaryInterestedProduct(oldMap, newMap);
    }
    
    protected override void afterDelete(map<id,sObject> oldMap) {       
        System.Debug('TMB: -> RTL_InterestedProductTriggerHandler start of afterDelete');
        updateLeadPrimaryCount(oldMap, null);
        updateLeadPrimaryInterestedProduct(oldMap, null);
    }  
    
    /**
     * This is the method to update the primary product from lead counter after insert/update/delete
     * insert: null, newMap
     * update: oldMap, newMap
     * delete: oldMap, null
     **/
    private static void updateLeadPrimaryCount(map<id,SObject> oldMap, map<id,SObject> newMap) {
        List<Lead> leadsToUpdate = new List<Lead>();

        map<id,SObject> tmpMap = null;       
        if (oldMap != null) tmpMap = oldMap;
        if (newMap != null) tmpMap = newMap;

        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Set<Id> leadIds = new Set<Id>();
        //get Leads map from list of interested products
        for (Id productId:tmpMap.keySet())
            leadIds.add(((RTL_Interested_products_c__c)tmpMap.get(productId)).Lead__c);
        for(Lead lead : [SELECT Id, RecordTypeId, FirstName, LastName, RTL_Primary_Interested_Product__c, RTL_Count_InterestedProducts_Primary__c FROM Lead WHERE Id in :leadIds])
            leadMap.put(lead.Id, lead);
        
        RTL_Interested_products_c__c tmpProductObj = null;
        RTL_Interested_products_c__c oldProductObj = null;
        RTL_Interested_products_c__c newProductObj = null;
        Lead leadObj = null;
        for (Id productId:tmpMap.keySet()){
            tmpProductObj = (RTL_Interested_products_c__c)tmpMap.get(productId);
            //only update lead object when lead is not converted into customer
            if (tmpProductObj.Customer__c == null) {
                //only update lead object when a primary product has primary type changed
                leadObj = leadMap.get(tmpProductObj.Lead__c);
                //if (RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(Lead.SObjectType, 'Retail').contains(leadObj.RecordTypeId)) {//only continue if it's retail record type
                    if (oldMap != null && newMap != null) {//update product
                        oldProductObj = (RTL_Interested_products_c__c)oldMap.get(productId);
                        newProductObj = (RTL_Interested_products_c__c)newMap.get(productId);
                        if (newProductObj.Is_Primary__c && !oldProductObj.Is_Primary__c) { 
                            leadObj.RTL_Count_InterestedProducts_Primary__c = leadObj.RTL_Count_InterestedProducts_Primary__c+1;
                            leadsToUpdate.add(leadObj);
                        } else if (oldProductObj.Is_Primary__c && !newProductObj.Is_Primary__c) {
                            leadObj.RTL_Count_InterestedProducts_Primary__c = leadObj.RTL_Count_InterestedProducts_Primary__c-1;
                            leadsToUpdate.add(leadObj);
                        }
                    } else if (oldMap != null) {//delete product
                        //only update lead object when a primary product is deleted
                        if (tmpProductObj.Is_Primary__c) {
                            leadObj.RTL_Count_InterestedProducts_Primary__c = leadObj.RTL_Count_InterestedProducts_Primary__c-1;
                            leadsToUpdate.add(leadObj);
                        }                    
                    } else if (newMap != null) {//insert product
                        //only update lead object when a primary product is added
                        if (tmpProductObj.Is_Primary__c) {
                            if (leadObj.RTL_Count_InterestedProducts_Primary__c != null) {
                                leadObj.RTL_Count_InterestedProducts_Primary__c = leadObj.RTL_Count_InterestedProducts_Primary__c+1;
                            } else {//when creating interested product from web-to-lead
                                leadObj.RTL_Count_InterestedProducts_Primary__c = 1;
                            }
                            leadsToUpdate.add(leadObj);
                        }                    
                    }
                //}
            }       
        }
        
        if (leadsToUpdate.size() > 0) {
            Database.SaveResult[] lsr = Database.update(leadsToUpdate, false);

            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated RTL_Count_InterestedProducts_Primary__c of lead.');
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error updating RTL_Count_InterestedProducts_Primary__c of lead. Error Message is: ' + err.getMessage());
                    }
                }
            }
        }   
    }

    public static Boolean isCampMemberBatch = false;


    private static void updateLeadPrimaryInterestedProduct(map<id,SObject> oldMap, map<id,SObject> newMap) {
        List<Lead> leadsToUpdate = new List<Lead>();
        List<RTL_Interested_products_c__c> updateinterestProductList = new List<RTL_Interested_products_c__c>();
        List<RTL_Interested_products_c__c> updatePrimaryinterestProductList = new List<RTL_Interested_products_c__c>();

        map<id,SObject> tmpMap = null;      
        if (oldMap != null) tmpMap = oldMap;
        if (newMap != null) tmpMap = newMap;
        
        //get Leads map from list of interested products
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Set<Id> leadIds = new Set<Id>();
        for (Id productId:tmpMap.keySet())
            leadIds.add(((RTL_Interested_products_c__c)tmpMap.get(productId)).Lead__c);
        for(Lead lead : [SELECT Id, RecordTypeId, FirstName, LastName, RTL_Primary_Interested_Product__c, RTL_Count_InterestedProducts_Primary__c FROM Lead WHERE Id in :leadIds])
            leadMap.put(lead.Id, lead);

        // get RTL_Interested_products_c__c list
        Map<String, RTL_Interested_products_c__c> interestProductMap = new Map<String, RTL_Interested_products_c__c>();
        Map<String, RTL_Interested_products_c__c> primaryInterestProductMap = new Map<String, RTL_Interested_products_c__c>();
        for(RTL_Interested_products_c__c interestedProduct : [SELECT Id, Lead__c, Product_Name__c, Is_Primary__c FROM RTL_Interested_products_c__c WHERE Lead__c in :leadIds])
        {
            if(interestedProduct.Is_Primary__c)
            {
                primaryInterestProductMap.put(interestedProduct.Lead__c, interestedProduct);
            }
            else
            {
                String key = (String)interestedProduct.Lead__c+interestedProduct.Product_Name__c;
                interestProductMap.put(key, interestedProduct); 
            }                                                        
        }

        RTL_Interested_products_c__c tmpProductObj = null;
        RTL_Interested_products_c__c interestProduct = null;
        RTL_Interested_products_c__c primaryinterestProduct = null;
        RTL_Interested_products_c__c tmpProductObjOld = null;
        Lead leadObj = null;
        for (Id productId:tmpMap.keySet()){
            tmpProductObj = (RTL_Interested_products_c__c)tmpMap.get(productId);
            //only update lead object when lead is not converted into customer

            Boolean isChange = false;

            //String ss = 0;

            if(isCampMemberBatch || RTL_API_PROFILE_ID == CURRENT_PROFILE_ID){
                if (oldMap != null) {
                    tmpProductObjOld = (RTL_Interested_products_c__c)oldMap.get(productId);
                    
                    if(tmpProductObj.Customer__c == tmpProductObjOld.Customer__c){
                        isChange = false;
                    }else{
                        isChange = true;
                    }
                }
            }else{
                isChange = true;
            }
            
           
            if (tmpProductObj.Customer__c == null && isChange) { //add condition check user from batch .net
               
                //only update lead object when a primary product has primary type changed
                leadObj = leadMap.get(tmpProductObj.Lead__c);
                String productLeadKey = (String)leadObj.Id+leadObj.RTL_Primary_Interested_Product__c;
                interestProduct = interestProductMap.get(productLeadKey);
                primaryinterestProduct = primaryInterestProductMap.get(leadObj.Id);
                // System.debug('TEST_tmpProductObj.Is_Primary__c: '+ tmpProductObj.Is_Primary__c);
                // System.debug('TEST_interestProduct.Is_Primary__c: '+ interestProduct);
                // System.debug('TEST_primaryinterestProduct.Is_Primary__c: '+ primaryinterestProduct);
                if (RTL_Utility.getObjectRecordTypeIdsByDevNamePrefix(Lead.SObjectType, 'Retail').contains(leadObj.RecordTypeId)) {//only continue if it's retail record type
                
                if (oldMap != null && newMap != null) {//update product
                        
                        //found existing interested product with input product and lead already has primary product
                        if(primaryinterestProduct != null)
                        {
                            
                           
                            if (tmpProductObj.Is_Primary__c) {
                                leadObj.RTL_Primary_Interested_Product__c = tmpProductObj.Product_Name__c;
                                leadsToUpdate.add(leadObj);
                            }
                        }
                        //no interested product record with input product and lead don't have primary product 
                        else if(interestProduct != null && primaryinterestProduct == null)
                        {
                            
                            if (!tmpProductObj.Is_Primary__c && !interestProduct.Is_Primary__c) {
                                leadObj.RTL_Primary_Interested_Product__c = null;
                                leadsToUpdate.add(leadObj);
                            } 
                        }
                        else if(interestProduct == null && primaryinterestProduct == null)
                        {
                            
                            if (!tmpProductObj.Is_Primary__c) {
                                leadObj.RTL_Primary_Interested_Product__c = null;
                                // Fix bug loop Update lead on trigger
                                // Case change product name and uncheck primary interest product 
                                leadObj.RTL_Count_InterestedProducts_Primary__c = 0;
                                leadsToUpdate.add(leadObj);
                            } 
                        }
                    } else if (oldMap != null) {//delete product
                        //only update lead object when a primary product is deleted
                       
                        if (tmpProductObj.Is_Primary__c) {
                            leadObj.RTL_Primary_Interested_Product__c = null;
                            leadsToUpdate.add(leadObj);
                        }                    
                    } else if (newMap != null) {//insert product
                        //only update lead object when a primary product is added
                        
                        if (tmpProductObj.Is_Primary__c) {
                            // interestProduct
                             
                            if(primaryinterestProduct.Product_Name__c != tmpProductObj.Product_Name__c){
                                leadObj.RTL_Primary_Interested_Product__c = tmpProductObj.Product_Name__c;
                                leadsToUpdate.add(leadObj);
                            }
                            
                        }                
                    }
                }
            }
        }

        System.debug(System.LoggingLevel.DEBUG, leadsToUpdate);
        Map<Id, Lead> leadMapToUpdate = new Map<Id, Lead>();
        leadMapToUpdate.putall(leadsToUpdate);
        if (leadMapToUpdate.values().size() > 0) {
            Database.SaveResult[] lsr = Database.update(leadMapToUpdate.values(), false);

            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated RTL_Primary_Interested_Product__c of lead.');
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error updating RTL_Primary_Interested_Product__c of lead. Error Message is: ' + err.getMessage());
                    }
                }
            }
        }
    }
}