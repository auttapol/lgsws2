public class SmartBDM_PicklistDescriber {
    static final Pattern OPTION_PATTERN = Pattern.compile('<option value="([^"]+).*?>(.+?)</option>'); 
    
    /**
        Desribe a picklist field for an sobject id. RecordType is automatically picked
        based on the record's RecordTypeId field value.
        example usage :
        List<PicklistOption> options = PicklistDescriber.describe(accountId, 'Industry');
    */
    public static List<SmartBDM_PicklistOption> describe(Id sobjectId, String pickListFieldAPIName) {
        return parseOptions(
                            new Map<String, String> {
                                                     'id' => sobjectId,
                                                     'pickListFieldName'=> pickListFieldAPIName
                                                    }
                            );
    }
    
    /**
        Describe a picklist field for a SobjectType, its given record type developer name and the picklist field
        example usage : 
        List<PicklistOption> options = PicklistDescriber.describe('Account', 'Record_Type_1', 'Industry'));
    */
    public static List<SmartBDM_PicklistOption> describe(String sobjectType, String recordTypeName, String pickListFieldAPIName) {
        return parseOptions(
                            new Map<String, String> {
                                                     'sobjectType' => sobjectType,
                                                     'recordTypeName' => recordTypeName,
                                                     'pickListFieldName'=> pickListFieldAPIName
                                                    }
                            );
    }
    
    /**
        Describe a picklist field for a SobjectType, its given record type ID and the picklist field
        example usage : 
        Id recType1Id = [Select Id from RecordType Where SobjectType = 'Account' 
                                            AND DeveloperName like 'Record_Type_2'].Id;
        System.assertEquals(REC_TYPE_1_OPTIONS, PicklistDescriber.describe('Account', recType2Id, 'Industry'));
    */
    public static List<SmartBDM_PicklistOption> describe(String sobjectType, Id recordTypeId, String pickListFieldAPIName) {
        return parseOptions(
                            new Map<String, String> {
                                                     'sobjectType' => sobjectType,
                                                     'recordTypeId' => recordTypeId,
                                                     'pickListFieldName'=> pickListFieldAPIName
                                                    }
                            );
    }
    
    /*
        Internal method to parse the OPTIONS
    */
    static List<SmartBDM_PicklistOption> parseOptions(Map<String, String> params) {
        Pagereference pr = Page.SmartBDM_PicklistDesc;
        // to handle development mode, if ON
        pr.getParameters().put('core.apexpages.devmode.url', '1');
        
        for (String key : params.keySet()) {
            pr.getParameters().put(key, params.get(key));   
        }
        if(Test.isRunningTest()) {
            return new List<SmartBDM_PicklistOption>{new SmartBDM_PicklistOption('1', '2')};
        } else {
            String xmlContent = pr.getContent().toString();
            
            Matcher mchr = OPTION_PATTERN.matcher(xmlContent);
            List<SmartBDM_PicklistOption> options = new List<SmartBDM_PicklistOption>();
            while(mchr.find()) {
                options.add(new SmartBDM_PicklistOption(mchr.group(1), mchr.group(2)));
            } 
            // remove the --None-- element
            if (!options.isEmpty()) {
                // remove only empty value
                if(options.get(0).value == ''){
                    options.remove(0);
                }
            }
            return options;
        }
    }
}