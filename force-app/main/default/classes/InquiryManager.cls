/*
*********************************************************
Apex Class Name    : InquiryManager
Created Date       : March 21, 2023
@description       : This is class is used for centralize inquiry information from any object by configurable.
@author            : Auttapol Pipatpatama
Modification Log:
Ver    Date         Author                   Modification
1.00   21-03-2022   Auttapol Pipatpatama     Initial Version
1.01   22-06-2022   Jetdilok Ngamkham        Change retrieve configuration from custom metadata to custom object
*********************************************************
*/
public with sharing class InquiryManager {
    private String inquiryName;
    private String inquiryKeyId;
    private Map<String, Object> inquiryKeyMap;

    public class InquiryNameNotFoundException extends Exception{}

    /* For data in object */
    public InquiryManager(String inquiryName, Map<String, Object> inquiryKeyMap) {
        this.inquiryName = inquiryName;
        this.inquiryKeyMap = inquiryKeyMap;
        // isObject = true;
    }


    /*
    *********************************************************
    @Method Name    : getResult
    @author         : Auttapol Pipatpatama
    @description    : method use for get json result from inquiry name
    @param          :
    @return         : List<Map<String, Object>>
    ********************************************************
    */
    public List<Map<String, Object>> getResult() {
        List<Map<String, Object>> jsonResult = null;
        try {
            jsonResult = getJSONResult();


            for (Map<String, Object> resMap: jsonResult) {
                System.debug('resMap-->' + resMap); 
                for (Object obj : resMap.values()) {
                    System.debug('obj-->' + obj);  
                }
            }

            System.debug(jsonResult);
        } catch (Exception e) {
            System.debug('ERROR :: ' + e.getMessage() + ' || ' + e.getLineNumber());
        }

        return jsonResult;
    }

    /*
    *********************************************************
    @Method Name    : getJSONResult
    @author         : Auttapol Pipatpatama
    @description    : method use for get json result from inquiry name
    @param          :
    @return         : List<Map<String, Object>>
    ********************************************************
    */
    private List<Map<String, Object>> getJSONResult() {
        System.debug('Start Prepare Statement :: ' + DateTime.Now());
        List<String> fieldList = new List<String>();
        Map<String, Inquiry_Data__c> inquiryFieldMap = new Map<String, Inquiry_Data__c>();
        
        Inquiry_List__c inquiryList = [SELECT Id, Condition__c, Salesforce_Object__c, Order_By__c, Operation_Format__c  FROM Inquiry_List__c WHERE Inquiry_Name__c =: inquiryName LIMIT 1];
        String objectName = '';

        if (inquiryList != null) {
            objectName = inquiryList.Salesforce_Object__c;
        } else {
            // If inquiryName not found throw Exception
            throw new InquiryNameNotFoundException('Invalid inquiry name');
        }
        
        List<Inquiry_Key__c> inquiryKey = [SELECT Id, Name, Parent_Id__c, Key_Field__c,Key_Parameter__c FROM Inquiry_Key__c WHERE Parent_Id__c =: inquiryList.Id order by Operation_Order__c];

        String keyField = '';
        for (Inquiry_Data__c imd : [SELECT Id, Name, Parent_Id__c, Salesforce_Field__c, JSON_Mapping_Name__c, Date_Format__c, Empty_Value__c, Fixed_Value__c, Field_Order__c, IsActive__c FROM Inquiry_Data__c WHERE Parent_Id__c =:inquiryList.Id AND IsActive__c = true ORDER BY Field_Order__c DESC]) {

            fieldList.add(imd.Salesforce_Field__c);
            inquiryFieldMap.put(imd.Salesforce_Field__c, imd);

        }

        String strQuery = prepareStatement(inquiryList, inquiryKey, fieldList);

        System.debug('End Prepare Statement :: ' + DateTime.Now());
        System.debug('String Query --> ' + strQuery);
        List<SObject> listData = null;
       
        System.debug('Start Query Statement :: ' + DateTime.Now());
        listData = Database.queryWithBinds(strQuery,inquiryKeyMap,AccessLevel.SYSTEM_MODE); 
        System.debug('End Query Statement :: ' + DateTime.Now());
        System.debug('listData --> '+listData);

        List<Map<String, Object>> jsonResult = mappingResult(listData, inquiryFieldMap);

        System.debug('Response --> ' + jsonResult);

        return jsonResult;
    }

    /*
    *********************************************************
    @Method Name    : prepareStatement
    @author         : Auttapol Pipatpatama
    @description    : method use for prepare query from configuration map with key from request
    @param          : inquiryList inquiry object configuration from object Inquiry_List__c
    @param          : inquiryKey inquiry key configuration from object Inquiry_Key__c
    @param          : fieldList list of Salesforce field 
    @return         : String
    ********************************************************
    */
    private String prepareStatement(Inquiry_List__c inquiryList,List<Inquiry_Key__c> inquiryKey, List<String> fieldList) {

        // Inquiry data from Object
        String fnames = String.join(fieldList,',');
        System.debug('fieldName -->' + fnames );
        
        String strQuery = 'select ' + fnames + ' from ' + inquiryList.Salesforce_Object__c;

        if (!this.inquiryKeyMap.isEmpty()) {
            //String pattern = '{1} OR {2}';
            String pattern = inquiryList.Operation_Format__c;
            
            if (String.isNotEmpty(pattern)) {
                integer keyIndex = 1;
                for (Inquiry_Key__c eachkey : inquiryKey) {
                    if(this.inquiryKeyMap.containsKey(eachkey.Key_Field__c )){
                        String target = '{' + keyIndex +'}';
                        String replacement = eachkey.Key_Field__c + '= :' + eachkey.Key_Parameter__c;
                        pattern = pattern.replace(target, replacement);
                        keyIndex++;
                    }
                }
            } else {
                String andConcat = ' and ';
                pattern = '';

                for (Inquiry_Key__c eachkey : inquiryKey) {
                    pattern +=  eachkey.Key_Field__c + '= :' + eachkey.Key_Parameter__c + andConcat;
                }  
                
                System.debug('pattern-->' + pattern);
                
                pattern = pattern.substring(0, ( pattern.length() - andConcat.length() ));
            }
            
            System.debug('pattern->' + pattern);
            strQuery += ' where ' + pattern ;
        
            System.debug('strQuery->' + strQuery);
        }
        
        if (String.isNotEmpty(inquiryList.Condition__c)) {
            strQuery = strQuery + ' AND ' + inquiryList.Condition__c;
        }
        if (String.isNotEmpty(inquiryList.Order_By__c)) {
            strQuery = strQuery + ' ORDER BY ' + inquiryList.Order_By__c;
        }

        return strQuery;
    }

    /*
    *********************************************************
    @Method Name    : mappingResult
    @author         : Auttapol Pipatpatama
    @description    : method use for mapping result from query object to map with json field format
    @param          : listData result list from query
    @param          : inquiryFieldMap field mapping from configuration
    @return         : List<Map<String, Object>>
    ********************************************************
    */
    private List<Map<String, Object>> mappingResult(List<SObject> listData, Map<String, Inquiry_Data__c> inquiryFieldMap) {
        Object objValue = null;
        List<Map<String, Object>> listResMap = new List<Map<String, Object>>();

        for (SObject sobj : listData) {
            System.debug('Record '+ sobj);
            Map<String, Object> resMap = new Map<String, Object>();

            for (Inquiry_Data__c inquiryData : inquiryFieldMap.values()) {
                String fieldName = inquiryData.Salesforce_Field__c;
                // Map<String, Object> fieldsMap = sobj.getPopulatedFieldsAsMap();
                // if (fieldsMap.containsKey(fieldName)) {
                //     objValue = sobj.get((fieldName));
                // }else{
                //     objValue ='';
                // }
                objValue = extractValue(sobj, fieldName, inquiryFieldMap);
                System.debug(fieldName + ' value -->' + objValue);
                // if (objValue == null) {
                //     objValue = '';
                // }

                /* Conversion value
                    1. Fixed value
                    2. Empty value
                    3. Date format value
                */

                String fixValue = inquiryFieldMap.get(fieldName).Fixed_Value__c;
                String emptyValue = inquiryFieldMap.get(fieldName).Empty_Value__c;
                String fieldDateFormat = inquiryFieldMap.get(fieldName).Date_Format__c;

                if (String.isNotEmpty(fixValue)) {
                    resMap.put(inquiryFieldMap.get(fieldName).JSON_Mapping_Name__c,  fixValue);
                } else if (String.isNotEmpty(emptyValue) && objValue == null) {
                    resMap.put(inquiryFieldMap.get(fieldName).JSON_Mapping_Name__c,  emptyValue);
                } else if (String.isNotEmpty(fieldDateFormat)) {
                    System.debug(fieldName + ' Date_Format__c -->' + fieldDateFormat);
                    resMap.put(inquiryFieldMap.get(fieldName).JSON_Mapping_Name__c,  formatDate(objValue, fieldDateFormat));
                } else {
                    System.debug('No conversion');
                    resMap.put(inquiryFieldMap.get(fieldName).JSON_Mapping_Name__c,  objValue);
                }

            }
           
            System.debug('resMap-->' + resMap);

            listResMap.add(resMap);
        }

        return listResMap;
    }

    /*
    *********************************************************
    @Method Name    : extractValue
    @author         : Auttapol Pipatpatama
    @description    : method use for extract value from result list
    @param          : sobj Data object from query
    @param          : fieldName field name
    @param          : inquiryFieldMap field mapping from configuration
    @return         : Object
    ********************************************************
    */
    private Object extractValue(SObject sobj, String fieldName, Map<String, Inquiry_Data__c> inquiryFieldMap) {
        //System.debug('fieldName ' +fieldName);
        //System.debug('sobj -->' + sobj);

        Object objValue = null;
        if (fieldName.contains('.')) {
            List<String> relateFieldList = fieldName.split('\\.');
            SObject innerSObject = sobj;
            Integer listSize = relateFieldList.size();
            Integer pointer = 0;
            Object val = '';
            for (String relateField : relateFieldList) {
                System.debug('relateField -->' +relateField);
                if (pointer == 0) {
                    innerSObject = sobj.getSobject(relateField);
                } else if (pointer == listSize-1) {
                    system.debug('innerSObject --> ' + innerSObject);
                    if (innerSObject != null) {
                        val = innerSObject.get(relateField);
                    }
                    
                } else {
                    innerSObject = innerSObject.getSobject(relateField);
                }
                pointer++;
            }
            
            objValue = val;
        } else {
            
            //System.debug('getfieldName -->' + inquiryFieldMap.get(fieldName));
            //System.debug(inquiryFieldMap);
            //System.debug('JSON_Mapping_Name__c --> ' + inquiryFieldMap.get(fieldName).JSON_Mapping_Name__c);
            
            objValue = sobj.get(inquiryFieldMap.get(fieldName).Salesforce_Field__c);
        }

        return objValue;
    }

    /*
    *********************************************************
    @Method Name    : formatDate
    @author         : Auttapol Pipatpatama
    @description    : method use format date
    @param          : objValue field value from query
    @param          : fieldDateFormat date format pattern
    @return         : String
    ********************************************************
    */
    private String formatDate(Object objValue, String fieldDateFormat) {
        try {
            System.debug('getType :: ' + getType(objValue));
            if (objValue instanceof Datetime) {
                System.debug('Format datetime ' + fieldDateFormat);
                DateTime dt = (DateTime) objValue;
                return dt.format(fieldDateFormat);
            } else  if (objValue instanceof Date) {
                System.debug('Format date ' + fieldDateFormat);
                Date dt = (Date) objValue;
                return dt.format();
            } else {
                System.debug('Format date Not date/time object');
                return String.valueOf(objValue);
            }
            
        } catch (Exception e) {
            System.debug('ERROR :: ' + e.getMessage());
            return String.valueOf(objValue);
        }
    }

    private static string getType(Object o) {
        if(o==null) return '';              // we can't say much about null with our current techniques
        if(o instanceof SObject)            return ((SObject)o).getSObjectType().getDescribe().getName()+''; 
        if(o instanceof Boolean)            return 'Boolean';
        if(o instanceof Id)                 return 'Id';
        if(o instanceof String)             return 'String';
        if(o instanceof Blob)               return 'Blob';
        if(o instanceof Date)               return 'Date';
        if(o instanceof Datetime)           return 'Datetime';
        if(o instanceof Time)               return 'Time';
        if(o instanceof String)             return 'String';
        if(o instanceof Integer)            return 'Integer';
        if(o instanceof Long)               return 'Long';
        if(o instanceof Decimal)            return 'Decimal';  // we can't distinguish between decimal and double
        if(o instanceof Double)             return 'Double';   // we can't distinguish between decimal and double
        if(o instanceof List<object>)       return 'List';
        return 'Object';                    // actually we can't detect maps and sets and maps
    }
}