trigger HostProductMappingTrigger on Host_Product_Mapping__c (before insert,before update,after update) {

    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ;
    
    if (Trigger.new != null && Trigger.isBefore){
        
        System.debug('RUNTRIGGER : '+RunTrigger +' : '+Test.isRunningTest()); 
      
        if(RunTrigger || Test.isRunningTest()){
            System.debug('::: Host_Product_Mapping__c Trigger Start ::::');
            Map<String, Host_Product_Mapping__c> HPMMap = new Map<String, Host_Product_Mapping__c>();
            
            for (Host_Product_Mapping__c item : Trigger.new) {
                    String hostProductUniqueKey = item.Host_Name__c + '|' + item.Host_Product_Group__c + '|' + item.Product_Program__c + '|' + item.Host_Prod_Name_Credit_Facility__c;
                
                if ((hostProductUniqueKey != null) && (Trigger.isInsert || (hostProductUniqueKey != Trigger.oldMap.get(item.Id).UniqueKey__c))){            
                    if (HPMMap.containsKey(hostProductUniqueKey)) {
                        item.addError(status_code__c.getValues('8051').status_message__c);
                    }else{
                        HPMMap.put(hostProductUniqueKey, item);       
                    }
                }
            }

            for (Host_Product_Mapping__c item : [SELECT UniqueKey__c,Id,Active_Flag__c FROM Host_Product_Mapping__c
                                                WHERE UniqueKey__c IN :HPMMap.KeySet() AND Active_Flag__c = TRUE]) {
                Host_Product_Mapping__c newHPM = HPMMap.get(item.UniqueKey__c);
                newHPM.addError(status_code__c.getValues('8052').status_message__c);
            }
        }

    }
    
    if (Trigger.isAfter && Trigger.isUpdate){
    
        if (RunTrigger || Test.isRunningTest()){
            
            list<host_product_response__c> listHostProductResponse = new list<host_product_response__c>();
            map<string,host_product_mapping__c> hostMapOld = new map<string,host_product_mapping__c>();
            if (Trigger.old != null) hostMapOld.putAll(Trigger.old);
           
            for (Host_Product_Mapping__c hm : Trigger.new)
            {
                if (hm.salesforce_product__c != null && hostMapOld.get(hm.id).salesforce_product__c == null){
                    for (Host_Product_Response__c hp : [select id, product2__c, HostProductUniqueKey__c, Host_Application_Response__r.Opportunity__c
                                                        from host_product_response__c
                                                        where product2__c = null
                                                        and HostProductUniqueKey__c =: hm.UniqueKey__c])
                    {
                        hp.product2__c = hm.salesforce_product__c;
                        listHostProductResponse.add(hp);
                    }
                }
            }
            
            if (listHostProductResponse.size() > 0){
                HostProductResponseServiceImpl hprs = new HostProductResponseServiceImpl();
                hprs.reMappingHostProductResponseToOppLineItem(listHostProductResponse);
            }
            
        }
        
    }
    System.debug('::: Host_Product_Mapping__c Trigger End ::::');
}