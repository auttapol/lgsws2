public without sharing class CustomLookUpController {
    public class lookupWrapper {
        @AuraEnabled
        public String Name{get;set;}
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
        public Map<String, String> extraValue{get;set;}
    }

    @AuraEnabled
    public static List < lookupWrapper > fetchLookUpValues(String searchKeyWord, String ObjectName, String nameField, String condition, String extraField, String extraSearchField, String customNameField, Boolean hasLastViewedDate, Boolean isSortNameField) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = '';
        String sortKey = ' order by ';
        if (isSortNameField) {
            // searchKey = searchKeyWord + '%';
            sortKey += nameField + ' ASC, ';
        }
        // }else {
        //     searchKey = '%' + searchKeyWord + '%';
        // }
        if (hasLastViewedDate) {
            sortKey += ' LastViewedDate DESC NULLS LAST, ';
        }
        sortKey += ' createdDate DESC NULLS LAST';
        searchKey = '%' + searchKeyWord + '%';
      
        system.debug('Test' + nameField);
        system.debug('@condition->'+condition);
        List < lookupWrapper > returnList = new List < lookupWrapper > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String searchCond = ' where ' + nameField + ' LIKE: searchKey ';
        if(extraSearchField != '' && extraSearchField != null) {
            if (extraSearchField.contains(',')) {
                searchCond = ' where (' + nameField + ' LIKE: searchKey ';
                List<String> searchFields = extraSearchField.split(',');
                for (String each : searchFields) {
                    searchCond += 'OR ' + each + ' LIKE :searchKey ';
                }
                searchCond += ')';
            }else {
                searchCond = ' where ( ' + nameField + ' LIKE :searchKey OR ' + extraSearchField + ' LIKE :searchKey ) ';
            }
        }
        String sQuery =  'select id, ' + nameField + (extraField != ''? ',' + extraField: '') + ' from ' + ObjectName + searchCond + (condition != ''? condition : '') + 
        sortKey  + ' limit 5';
        //order by LastViewedDate DESC NULLS LAST, createdDate DESC NULLS LAST limit 5';
       
        System.debug(sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        System.debug(lstOfRecords);
        List<String> relatedName = null;
        if(nameField.contains('.')){
            relatedName = nameField.split('\\.');
            System.debug(relatedName);
            // if(relatedName.size() == 2) {
            //     relatedName[0] = (String)relatedName[0].replace('__r', '__c');
            // }
        }
        List<String> extraFields = extraField != ''? extraField.split(',') : null;
        for (sObject obj: lstOfRecords) {
            lookupWrapper res = new lookupWrapper();
            res.Name = (relatedName != null && relatedName.size() == 2)? String.valueOf(obj.getSObject(relatedName[0]).get(relatedName[1])) : (String)obj.get(nameField);
            if(customNameField != '' && customNameField != null) {
                List<String> cnfield = customNameField.split(',');
                String innerName = String.valueOf(obj.get(cnfield.remove(0)));
                String desName = '';
                system.debug('obj-->' + obj);
                for(String cname : cnfield) {
                    if(String.valueOf(obj.get(cname)) != null){
                        if(desName != ''){
                            desName += ', ';
                        }
                        if(cname == 'Total_Reward_Point__c'){
                            desName += String.valueOf(Integer.valueOf(obj.get(cname)).format())+' Points';
                        }else{
                            desName += String.valueOf(obj.get(cname));
                        }
                    }
                }
                innerName += ' (' + desName + ')';
                res.Name = innerName;
            }
            res.Id = obj.Id;
            res.extraValue = null;
            if(extraFields != null) {
                res.extraValue = new Map<String, String>();
                for(String fname : extraFields) {
                    res.extraValue.put(fname, String.valueOf(obj.get(fname)));
                    // if(res.extraValue != '') {
                    //     res.extraValue += ',';
                    // }
                    // res.extraValue += obj.get(fname);
                }
            }
            returnList.add(res);
        }
        return returnList;
    }
 
    @AuraEnabled
    public static List<PicklistOption> getPicklistValue(String sobjectName, String fieldName) {
        List<PicklistOption> result = new List<PicklistOption>();
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
		Schema.DescribeSObjectResult sObjectResult = gd.get(sobjectName).getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sObjectResult.fields.getMap();

        Schema.SObjectField targetField = fieldMap.get(fieldName);
        List<Schema.PicklistEntry> ple = targetField.getDescribe().getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			result.add(new PicklistOption(pickListVal.getValue(), pickListVal.getLabel()));
		}     
		return result;
    }

    @AuraEnabled
    public static List < lookupWrapper > fetchLookUpValuesSOSL(String searchKeyWord, String ObjectName,String nameField,String condition,String extraField)
    {
        String searchQuery = 'FIND \'' + searchKeyWord + '\' IN ALL FIELDS RETURNING ' + ObjectName + '(' + nameField + ')' + ' ' + condition + ' Limit 5';
        System.debug('query => '+searchQuery);
        List<List<sObject>> searchList = search.query(searchQuery);
        System.debug('searchList => '+searchList);

        List<String> extraFields = extraField != ''? extraField.split(',') : null;
        List < lookupWrapper > returnList = new List < lookupWrapper > ();
        for (List<sObject> sObjList : searchList) {
            for (sObject obj : sObjList) {
                System.debug('obj => '+obj);
                lookupWrapper res = new lookupWrapper();
                res.Id = obj.Id;
                res.Name = String.valueOf(obj.get('Name'));
                res.extraValue = null;
                if(extraFields != null) {
                    res.extraValue = new Map<String, String>();
                    for(String fname : extraFields) {
                        res.extraValue.put(fname, String.valueOf(obj.get(fname)));
                    }
                }
                returnList.add(res);
            }
        }
        return returnList;
    }

   /* @AuraEnabled
    public static List < sObject > fetchSalesPerson(String searchKeyWord, String ObjectName,String extraSearchField,String ProjectID) {
      system.debug('Enter Quering fecthing SalesPerson Process');

        List < sObject > returnList = new List < sObject > ();

        String sQuery = 'select User__r.id, User__r.Name from Project_Team_Member__c where project__c='+ProjectID+'order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }*/
}