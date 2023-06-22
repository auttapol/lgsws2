public without sharing class SmartBDM_PickListDescController {
    public Sobject sobj {get;set;}
    public String pickListFieldName {get;set;}   
    public SmartBDM_PickListDescController() {
        Map<String, String> reqParams = ApexPages.currentPage().getParameters();
        String sobjId = reqParams.get('id');
        String recordTypeId = reqParams.get('recordTypeId');
        String recordTypeName = reqParams.get('recordTypeName');
        String sobjectTypeName = reqParams.get('sobjectType'); 
        this.pickListFieldName = reqParams.get('picklistFieldName'); 
        
        Schema.SobjectType sobjectType = null;
        
        if (sobjectTypeName != null && sobjectTypeName.trim().length() > 0) {
            sobjectType = Schema.getGlobalDescribe().get(sobjectTypeName);
            // create blank sobject record
            sobj = sobjectType.newSobject();
            
            // if no recordTypeId passed explicitly by user, try loading one from the RecordType table
            if (isBlank(recordTypeId) && !isBlank(recordTypeName)) {
                // queryexception is fine, we don't want to return anything good for bad recordtype
                RecordType recType = [Select Id from RecordType Where SobjectType =:sobjectTypeName 
                                            AND DeveloperName like :recordTypeName];
                recordTypeid = recType.id;                                            
            }
            sobj.put('RecordTypeId', recordTypeid);                                            

        } else if (sobjId != null && sobjId.trim().length() > 0) {
            // find the so
            for (SobjectType sobjType : Schema.getGlobalDescribe().values()){
                String sobjPrefix = sobjType.getDescribe().getKeyPrefix();
                if (sobjPrefix == null) continue;
                System.debug('SobjectType ' + sobjType + ', ' + sobjPrefix);
                if (sobjId.toLowerCase().startsWith(sobjPrefix.toLowerCase())) {
                    sobjectType = sobjType;
                    break;
                }
            }
            // following not working with input:field
            //sobj = sobjectType.newSobject(sobjId);
            sobj = Database.query ('SELECT ' + pickListFieldName + ' FROM ' + sobjectType + ' WHERE ID =:sobjId');
        }
    }

    static boolean isBlank(String val) {
        return val == null || val.trim().length() == 0;
    }
}