public with sharing class AdvisoryPlanningSelector {
    
    public static List<Advisory_Planning_Item__c> getAdvisoryPlanningItemByItemType(Set<String> advisoryPlanIdSet, Set<String> itemTypeSet){
        String objectName = 'Advisory_Planning_Item__c';
        List<String> fieldList = RMC_Utility.getSObjectFieldList(objectName);
        String query        = 'SELECT {0} FROM {1} WHERE {2}';
        String conditions   = '';
        conditions += ' Advisory_Planning__c IN: advisoryPlanIdSet';
        conditions += ' AND Advisory_Item_Type__c IN: itemTypeSet';

        
        String soql         = String.format(query, new List<String>{ String.join(fieldList, ', '), objectName,  conditions});
        System.debug(soql);
        return (List<Advisory_Planning_Item__c>) Database.query(soql);
    }

}