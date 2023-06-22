public with sharing class RecordTypeLightningUtil {

    @AuraEnabled(cacheable=true)
    public static List<Object> fetchRecordType(String sObjectName) {
        Map<Id, Object> recordtypemap = new Map<Id, Object>();
        for(RecordTypeInfo rt : ((SObject)Type.forName(sObjectName).newInstance()).getSObjectType().getDescribe().getRecordTypeInfos()){
            if(!rt.isMaster() && rt.isAvailable()) {
                recordtypemap.put(rt.getRecordTypeId(), new Map<String, Object>{
                    'Id' => rt.getRecordTypeId(),
                    'Name' => rt.getName(),
                    'DeveloperName' => rt.getDeveloperName(),
                    'isDefault' => rt.isDefaultRecordTypeMapping()
                });
            }
        }
        for (RecordType r : [SELECT Id, Name, DeveloperName, Description FROM RecordType WHERE SobjectType = :sObjectName AND Id = :recordtypemap.keySet() ORDER BY Name]) {
            if(recordtypemap.containsKey(r.Id)) {
                ((Map<String, Object>)recordtypemap.get(r.Id)).put('Description', r.Description);
            }
        }
        return recordtypemap.values();
    }

    @AuraEnabled(cacheable=true)
    public static String getSObjectLabel(String sObjectName) {
        return Schema.getGlobalDescribe().get(sObjectName.toLowerCase()).getDescribe().getLabel();
    }

}