public class ProductVolumeInformationTriggerHandler {
    public static void handleBeforeInsert(List<Product_Volume_Information__c> newList){
        stampRecordName(newList);
    }

    public static void stampRecordName (List<Product_Volume_Information__c> newList){
        Set<Id> productIdSet = new Set<Id>();
        Set<Id> acctIdSet = new Set<Id>();

        for(Product_Volume_Information__c eachProductVolume : newList){
            if(eachProductVolume.Product__c != null) productIdSet.add(eachProductVolume.Product__c);
            if(eachProductVolume.Customer__c != null) acctIdSet.add(eachProductVolume.Customer__c);
        }

        Map<Id, Product2> productMap = new Map<Id, Product2>([SELECT Id, Financial_Product_Domain__c, Remark__c FROM Product2 WHERE Id IN :productIdSet]);

        Map<Id, Account> acctIdMap = new Map<Id, Account>([SELECT Id, Segment_crm__c FROM Account WHERE Id IN :acctIdSet]);
        
        for(Product_Volume_Information__c eachProductVolume : newList){
            if(eachProductVolume.Product__c != null && eachProductVolume.Customer__c != null && productMap.containsKey(eachProductVolume.Product__c) && acctIdMap.containsKey(eachProductVolume.Customer__c)){
                Product2 eachProduct = productMap.get(eachProductVolume.Product__c);
                Account eachAccount = acctIdMap.get(eachProductVolume.Customer__c);

                String key =  eachProduct.Financial_Product_Domain__c + eachProduct.Remark__c + eachAccount.Segment_crm__c + eachProductVolume.Account_Suffix_Ref__c;

                eachProductVolume.Name = key.replaceAll( '\\s+', '');
            }
        }
    }
}