public class RTL_CaseLightningUtil {
    
    public class PicklistOption{
        @AuraEnabled
        public String value{get;set;}
        @AuraEnabled
        public String label{get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static boolean getCheckPermissionRecord(String recordId){
        try{
            return [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :recordId LIMIT 1].HasEditAccess;
        }catch( Exception e ){
            return false;
        }     
    }

    @AuraEnabled
    public static List<PicklistOption> getPicklist(){
        List<PicklistOption> statusPicklist = new List<PicklistOption>();
        List<CaseStatus> pickListValuesList = [Select Id, MasterLabel From CaseStatus Where IsClosed = true];
        for(CaseStatus c : pickListValuesList){
            PicklistOption pl = new PicklistOption();
            pl.label = c.MasterLabel;
            pl.value = c.MasterLabel;
            statusPicklist.add(pl);
        }
        return statusPicklist;   
    }

    @AuraEnabled
    public static Map<String,Closed_Case_Warning_Message__mdt> getClosedCaseWarningMessage (){
        Map<String,Closed_Case_Warning_Message__mdt> mapWarning = new Map<String,Closed_Case_Warning_Message__mdt>();
        try {
            List<Closed_Case_Warning_Message__mdt> listWarningMessage = [SELECT Id,Category__c,Message__c,Status__c FROM Closed_Case_Warning_Message__mdt];
            if (listWarningMessage.size() > 0){
                for (Closed_Case_Warning_Message__mdt objWarningMessage : listWarningMessage) {
                    mapWarning.put(objWarningMessage.Category__c+objWarningMessage.Status__c,objWarningMessage);
                }
            }
            return mapWarning;
        } catch (Exception e) {
            System.Debug(e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static Boolean isAllowEdit(String caseId){
        Boolean isAllowedEdit;
        UserRecordAccess uAccess = [SELECT RecordID, HasReadAccess, HasEditAccess FROM UserRecordAccess WHERE UserId = : UserInfo.getUserId() AND RecordID = : caseId];
        Case casePermision = [SELECT Id, Is_Edit_Branch_Queue__c, CreatedById, LastModifiedById, Status, All_Previous_Owner__c, Origin, Category__c FROM case WHERE ID = :caseId];

        if ( uAccess.HasEditAccess == true && casePermision.Is_Edit_Branch_Queue__c == true) {
            isAllowedEdit = true;
        } else {
            isAllowedEdit = false;
        }

        return isAllowedEdit;
    }

    
}