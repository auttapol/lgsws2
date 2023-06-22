public without sharing abstract class AbstractCoreClass {
    public Object getProperty(String param_name) {
        Map<String, Object> untyped_instance = (Map<String, Object>)deserializeObject(this);
        return untyped_instance.get(param_name);
    }

    public static Boolean isNotEmpty(String value) {
        return value != null && String.isNotEmpty(value);
    }

    public static Boolean isNotEmpty(Object value) {
        return value != null;
    }

    public static Boolean isNotEmpty(List<Object> value) {
        return value != null && value.size() > 0;
    }

    public static Boolean isExistingValue(String key, String value, List<Object> objList) {
        Map<String, Object> tempMap = new Map<String, Object>();
        for (Object o : objList) {
            tempMap.put((String)((Map<String, Object>)o).get(key), o);
        }
        return tempMap.containsKey(value);
    }

    public static Boolean isExistingValue(String value, Map<String, Object> objMap) {
        Map<String, Object> tempMap = new Map<String, Object>();
        for (Object s : objMap.values()) {
            tempMap.put((String)s, s);
        }
        return tempMap.containsKey(value);
    }

    public static Object deserializeObject(Object obj) {
        return obj != null ? JSON.deserializeUntyped(JSON.serialize(obj)) : null;
    }

    public static String serializePrettyString(String jsonString) {
        try {
            return isNotEmpty(jsonString) ? JSON.serializePretty(JSON.deserializeUntyped(jsonString)) : jsonString;
        } catch (Exception e) {
            return isNotEmpty(jsonString) ? jsonString.unescapeJava() : jsonString;
        }
    }

    public static Object getResult(String path, Object obj) {
        String key = path.substringBefore('.');
        if(obj == null) return null;
        if(path.contains('.')) {
            return Pattern.matches('([0-9]+)', key) ? getResult(path.substringAfter('.'), ((List<Object>)deserializeObject(obj)).get(Integer.valueOf(key))) : getResult(path.substringAfter('.'), ((Map<String, Object>)deserializeObject(obj)).get(key));
        }
        return Pattern.matches('([0-9]+)', key) ? ((List<Object>)deserializeObject(obj)).get(Integer.valueOf(key)) : ((Map<String, Object>)deserializeObject(obj)).get(key);
    }

    // v.1 one tier
    public static Object putObject(String key, Object objInput, Object obj) {
        Map<String, Object> tempObj = ((Map<String, Object>)deserializeObject(obj));
        tempObj.put(key, objInput);
        return tempObj;
    }

    // v.2 many tier only Key and value Map Class
    public static Object putObjectByPath(String path, Object objInput, Object obj) {
        String key = path.substringAfterLast('.');
        if(path.contains('.')) {
            Map<String, Object> tempObj = (Map<String, Object>)getResult(path.substringBeforeLast('.'), obj);
            if(isNotEmpty(tempObj)) {
                tempObj.put(key, objInput);
                return putObjectByPath(path.substringBeforeLast('.'), tempObj, obj);
            }
            else {
                return putObjectByPath(path.substringBeforeLast('.'), new Map<String, Object>{ key => objInput }, obj);
            }
        }
        else {
            Map<String, Object> tempObj = (Map<String, Object>)obj;
            tempObj.put(path, objInput);
            return tempObj;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List <sObject> fetchLookUpSOSLValues(String searchValue, String fieldName, String ObjectName, String keyField) {
        List<sObject> returnList = new List<sObject>();
        String sQuery = String.format('FIND {0} IN NAME FIELDS RETURNING {1}({2}, {3}) LIMIT 100', new List<String>{
            '\'' + searchValue + '*\'',
            ObjectName,
            keyField,
            fieldName
        });

        List <sObject> lstOfRecords = Search.query(sQuery).get(0);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }

    @AuraEnabled(cacheable=true)
    public static Object getDescribeFieldResultAndValue(String recordId, String sObjectName, List<String> fields) {
        SObject sObjectValues = Database.query('SELECT ' + String.join(fields, ',') + ' FROM ' + sObjectName + ' WHERE Id = :recordId LIMIT 1');
        Map<String, Schema.SObjectField> sObjectField = Schema.getGlobalDescribe().get(sObjectName.toLowerCase()).getDescribe().fields.getMap();
        Map<String, Object> fieldDescribe = new Map<String, Object>();
        for (String f : fields) {
            if(!f.contains('__r')) {
                Schema.DescribeFieldResult dfr = sObjectField.get(f).getDescribe();
                fieldDescribe.put(f, new Map<String, Object> {
                    'name' => dfr.getName(),
                    'value' => sObjectValues.get(dfr.getName()) != null ? sObjectValues.get(dfr.getName()) : '',
                    'label' => dfr.getLabel(),
                    'type' => dfr.getType(),
                    'inlineHelpText' => dfr.getInlineHelpText() != null ? dfr.getInlineHelpText() : '',
                    'isAccessible' => dfr.isAccessible()
                });
            }
            else {
                // Support 1st tier
                Map<String, Object> tempObj = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(sObjectValues));
                Id tempId = tempObj.containsKey(f.substringBefore('.').replace('__r', '__c')) ? (Id)sObjectValues.get(f.substringBefore('.').replace('__r', '__c')) : null;

                if(isNotEmpty(tempId) && tempObj.containsKey(f.substringBefore('.').replace('__r', '__c'))) {
                    String sObjectNameTemp = tempId.getSObjectType().getDescribe().getName();
                    Map<String, Schema.SObjectField> sObjectFieldTemp = Schema.getGlobalDescribe().get(sObjectNameTemp.toLowerCase()).getDescribe().fields.getMap();
                    Schema.DescribeFieldResult dfr = sObjectFieldTemp.get(f.substringAfterLast('.')).getDescribe();
                    fieldDescribe = (Map<String, Object>)putObjectByPath(f, new Map<String, Object>{
                        'name' => dfr.getName(),
                        'label' => dfr.getLabel(),
                        'type' => dfr.getType(),
                        'isAccessible' => dfr.isAccessible(),
                        'inlineHelpText' => dfr.getInlineHelpText() != null ? dfr.getInlineHelpText() : '',
                        'relationshipName' => f.substringBefore('.').replace('__r', '__c'),
                        'value' => sObjectValues.get(f.substringBefore('.').replace('__r', '__c')) != null ? (String)((Map<String, Object>)tempObj.get(f.substringBefore('.'))).get(f.substringAfterLast('.')) : ''
                    }, fieldDescribe);
                } else {
                    fieldDescribe = (Map<String, Object>)putObjectByPath(f, new Map<String, Object>{
                        'name' => f.substringAfterLast('.'),
                        'value' => sObjectValues.get(f.substringBefore('.').replace('__r', '__c')) != null ? (String)((Map<String, Object>)tempObj.get(f.substringBefore('.'))).get(f.substringAfterLast('.')) : ''
                    }, fieldDescribe);
                }
            }
        }
        return JSON.deserializeUntyped(JSON.serialize(fieldDescribe));
    }

    @AuraEnabled(cacheable=true)
    public static Object getDescribeFieldResult(String sObjectName, List<String> fields) {
        Map<String, Schema.SObjectField> sObjectField = Schema.getGlobalDescribe().get(sObjectName.toLowerCase()).getDescribe().fields.getMap();
        Map<String, Object> fieldDescribe = new Map<String, Object>();
        for (String f : fields) {
            f = f.contains('.') ? f.substringBeforeLast('.').replace('__r', '__c') : f;
            Schema.DescribeFieldResult dfr = sObjectField.get(f).getDescribe();
            fieldDescribe.put(f, new Map<String, Object> {
                'name' => dfr.getName(),
                'label' => dfr.getLabel(),
                'type' => dfr.getType(),
                'inlineHelpText' => dfr.getInlineHelpText() != null ? dfr.getInlineHelpText() : '',
                'isAccessible' => dfr.isAccessible()
            });
        }
        return JSON.deserializeUntyped(JSON.serialize(fieldDescribe));
    }

    @AuraEnabled(cacheable=true)
    public static String getSObjectLabelByRecordId(Id recordId) {
        return recordId != null ? recordId.getSObjectType().getDescribe().getName() : '';
    }

    @AuraEnabled(cacheable=true)
    public static Object getReference(Id recordId)
    {
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        Object sObj = Database.query('SELECT Id, Name FROM ' + sObjName + ' WHERE Id = :recordId LIMIT 1');
        Map<String, Object> tempObj = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(((List<Object>)sObj).get(0)));
        return ((Map<String, Object>)tempObj).containsKey('Name') ? ((Map<String, Object>)tempObj).get('Name') : null;
	}
	
    @AuraEnabled(cacheable=true)
    public static Object getReferenceByFieldName(Id recordId, String fieldName)
    {
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        Object sObj = Database.query('SELECT Id, ' + fieldName + ' FROM ' + sObjName + ' WHERE Id = :recordId LIMIT 1');
        Map<String, Object> tempObj = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(((List<Object>)sObj).get(0)));
        return ((Map<String, Object>)tempObj).containsKey(fieldName) ? ((Map<String, Object>)tempObj).get(fieldName) : null;
    }

    @AuraEnabled(cacheable=true)
    public static Object getQueryDatabase(List<String> fields, String sObjectName, String filter) {
        Map<String, Schema.SObjectField> sObjectField = Schema.getGlobalDescribe().get(sObjectName.toLowerCase()).getDescribe().fields.getMap();
        // Checking dulplicate
        Set<String> fieldsTemp = new Set<String>();
        for (String f : fields) {
            String keyMap = f.substringBeforeLast('.').contains('__r') ? f.substringBeforeLast('.').replace('__r', '__c') : f.substringBeforeLast('.');
            if (sObjectField.containsKey(keyMap)) {
                fieldsTemp.add(f);
            }
        }
        fields = new List<String>();
        for (String f : fieldsTemp) {
            fields.add(f);
        }
        return Database.query(String.format('SELECT {0} FROM {1}' + (filter != null ? ' WHERE {2}' : ''), new List<String>{
            String.join(fields, ','),
            sObjectName,
            filter
        }));
    }

    public static String getValuesWithRegex(String body, List<String> keys) {
        Map<String, String> valuesMap = new Map<String, String>();
        String regEx = String.format('\"({0})"\\s*[:]\\s*"(.*)\"', new List<String> {
            String.join(keys, '|')
        });
        Matcher m = Pattern.compile(regEx).matcher(body);
        while (m.find()) {
            String keyTemp = m.group(1);
            String valueTemp = m.group(2);
            if(String.isNotEmpty(valueTemp)) {
                valuesMap.put(keyTemp, valueTemp);
            }
        }
        return valuesMap.values().size() > 0 ? valuesMap.values().get(0) : null;
    }
}