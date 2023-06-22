public class MainBankHistoryTableComponent {
    
    @AuraEnabled(cacheable=true)
    public static List<Customer_Main_Bank_Info__c> getMainBankHistoryList(String recordId) {

        Boolean chkPermission = mainBankInfoController.checkPermission(recordId);
        if(chkPermission == false){
           	return null;
        }
        List<Customer_Main_Bank_Info__c> customerMainBankHistoryList= [SELECT Id,toLabel(Main_Bank_Status__c),Calculation_Date__c,Description__c
                                                                        FROM Customer_Main_Bank_Info__c 
                                                                        WHERE Customer__c =: recordId
                                                                        ORDER BY Calculation_Date__c DESC
                                                                        LIMIT 3];
        return customerMainBankHistoryList;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,String> getMainBankLabels() {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType mainBankSchema = schemaMap.get('Customer_Main_Bank_Info__c');
        Map<String, Schema.SObjectField> fieldMap = mainBankSchema.getDescribe().fields.getMap();
        Map<String,String> fieldNameLabelMap = new Map<String,String>();
        for (String fieldName: fieldMap.keySet()) {
            fieldNameLabelMap.put(fieldName,fieldMap.get(fieldName).getDescribe().getLabel());
        }
        return fieldNameLabelMap;
    }

}