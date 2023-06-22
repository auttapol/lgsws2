public with sharing class RTL_Product2TriggerHandler extends TriggerHandler {
    public RTL_Product2TriggerHandler(){
        if(Test.isRunningTest()){
            this.setMaxLoopCount(10);
        }
        else{
            this.setMaxLoopCount(1000);
        }
        System.Debug( 'TMB: -> RTL_Product2TriggerHandler Invoked' );
    }   
    
    protected override void afterInsert(map<id,SObject> newMap) {       
        System.Debug('TMB: -> RTL_Product2TriggerHandler start of afterInsert');
        
        //Sync retail product information from Product2 to Retail Product Master table
        syncProduct2WithRetailProduct(null, newMap);     
                 
        System.Debug('TMB: -> RTL_Product2TriggerHandler end of afterInsert'); 
    }  
    
    protected override void afterUpdate(map<id,sObject> oldMap, map<id,sObject> newMap) {        
        System.Debug('TMB: -> RTL_Product2TriggerHandler start of afterUpdate');  
        
        //Sync retail product information from Product2 to Retail Product Master table
        syncProduct2WithRetailProduct(oldMap, newMap);
        
        System.Debug('TMB: -> RTL_Product2TriggerHandler end of afterUpdate');  
    }   
    
    /*
    * This method is to sync retail product information from Product2 to Retail Product Master table
    */
    private static void syncProduct2WithRetailProduct(map<id,sObject> oldMap, map<id,sObject> newMap) {
        List<RTL_product_master__c> retailProductToInsert = new List<RTL_product_master__c>();
        List<RTL_product_master__c> retailProductToUpdate = new List<RTL_product_master__c>();
        List<RTL_product_master__c> retailProductToDelete = new List<RTL_product_master__c>();
                
        Product2 product2Obj = null;
        Product2 oldProduct2Obj = null;
        Set<String> productCodeList = new Set<String>();
        Set<String> oldProductCodeList = new Set<String>();
        for (Id lId: newMap.keySet()){
            product2Obj = (Product2)newMap.get(lId);
            if (oldMap != null) oldProduct2Obj = (Product2)oldMap.get(lId);
            //get the list of product code for retail product only
            if (product2Obj.FLAG_RTL_Product__c && product2Obj.SF_Product_Key__c != null) {
                productCodeList.add(product2Obj.SF_Product_Key__c);//use SF_Product_Key__c as unique key to map to retail product master
            }
            if (oldProduct2Obj != null && oldProduct2Obj.FLAG_RTL_Product__c && product2Obj.SF_Product_Key__c != null && product2Obj.SF_Product_Key__c != oldProduct2Obj.SF_Product_Key__c) {
                //check if there is change of product code, remove the retail product master with old product code and add new entry
                oldProductCodeList.add(oldProduct2Obj.SF_Product_Key__c);
            }
        }
        
        //keep the list of new product code
        Map<String, RTL_product_master__c> retailProductMap = new Map<String, RTL_product_master__c>();
        for(RTL_product_master__c retailProduct : [select Product_Code__c from RTL_product_master__c where Product_Code__c in :productCodeList]) {
            retailProductMap.put(retailProduct.Product_Code__c, retailProduct);
        } 
        
        //keep the list of old product code
        for(RTL_product_master__c retailProduct : [select Product_Code__c from RTL_product_master__c where Product_Code__c in :oldProductCodeList]) {
            retailProductToDelete.add(retailProduct);
        }         
        
        RTL_product_master__c retailProduct = null;
        //sync product2 with retail product master if the product is retail
        for (Id lId: newMap.keySet()){
            product2Obj = (Product2)newMap.get(lId);
            //sync product2 with retail product master if the product is retail
            retailProduct = retailProductMap.get(product2Obj.SF_Product_Key__c);
            if (retailProduct != null) {//existing retail product (product code is not changed)
                retailProduct.RTL_Product2_Name__c = product2Obj.Name;
                retailProduct.Asset_Class__c = product2Obj.RTL_Asset_Class__c;
                retailProduct.Fund_Type__c = product2Obj.FUND_TYPE__c;
                retailProduct.Product_Group__c = RTL_Utility.convertProductGroup(product2Obj.Family);
                retailProduct.Product_Sub_group__c = product2Obj.Sub_Family__c;
                retailProduct.Description__c = product2Obj.RTL_Product_Name_TH__c; //Added 14DEC18
                retailProduct.RTL_Issuer_Fund_House__c = product2Obj.RTL_Issuer_Fund_House__c; //Added 14DEC18
                retailProductToUpdate.add(retailProduct);
            } else if (product2Obj.FLAG_RTL_Product__c){//new retail product (could be due to the change of product code)
                retailProduct = new RTL_product_master__c();
                retailProduct.Product_Code__c = product2Obj.SF_Product_Key__c;
                retailProduct.Name = product2Obj.RTL_Product_Name_ENG__c; //Updated 25JUN19
                retailProduct.RTL_Product2_Name__c = product2Obj.Name;
                retailProduct.Asset_Class__c = product2Obj.RTL_Asset_Class__c;
                retailProduct.Fund_Type__c = product2Obj.FUND_TYPE__c;
                retailProduct.Product_Group__c = RTL_Utility.convertProductGroup(product2Obj.Family);
                retailProduct.Product_Sub_group__c = product2Obj.Sub_Family__c;
                retailProduct.Description__c = product2Obj.RTL_Product_Name_TH__c; //Added 14DEC18
                retailProduct.RTL_Issuer_Fund_House__c = product2Obj.RTL_Issuer_Fund_House__c; //Added 14DEC18
                // Add on 11-Feb-2021 for AL project.
                if (product2Obj.Family != 'AUTO LOAN')
                {
                    retailProduct.Active__c = true; //Added 14DEC18
                }
                retailProductToInsert.add(retailProduct);
            }
        }

        // insert retail product master
        if (retailProductToInsert.size() > 0) {
            Database.SaveResult[] lsr = Database.insert(retailProductToInsert, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted retail product master with ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error inserting retail product master. Error Message is: ' + err.getMessage());
                    }
                }
            } 
        }
        
        //Update retail product master
        if(retailProductToUpdate.size() > 0){
            Database.SaveResult[] lsr = Database.update(retailProductToUpdate, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated retail product master with ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error updating retail product master. Error Message is: ' + err.getMessage());
                    }
                }
            }            
        }   
        
        // delete retail product master
        if (retailProductToDelete.size() > 0) {
            Database.DeleteResult[] lsr = Database.delete(retailProductToDelete, false);
            // Iterate through each returned result
            for (Database.DeleteResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully deleted retail product master with ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error deleting retail product master. Error Message is: ' + err.getMessage());
                    }
                }
            } 
        }               
    }
}