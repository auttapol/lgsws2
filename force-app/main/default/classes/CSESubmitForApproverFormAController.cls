public without sharing class CSESubmitForApproverFormAController {

    @AuraEnabled
    public static E_Client_Suitability__c getRecordInfo(Id eSuitId){
        System.debug('eSuitId : ' + eSuitId);
        return [SELECT Id, Name, CS_Stamped_Customer_Segment__c, Select_RM_TH_Approver__c FROM E_Client_Suitability__c WHERE Id = :eSuitId LIMIT 1];
    }

    @AuraEnabled
    public static Boolean submitRequest(Id eClientId, Id selectApproverId, String remark){
        Boolean isSuccess = false;
        E_Client_Suitability__c eCS = [Select Id, Select_RM_TH_Approver__c From E_Client_Suitability__c Where Id = :eClientId Limit 1];
        if (eCS != null){
            try{
                System.debug('Approver Id is: ' + selectApproverId);
                eCS.Select_RM_TH_Approver__c = selectApproverId;
                update eCS;
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments(remark);
                req.setObjectId(eCS.Id);
                Approval.ProcessResult result;
                try{
                    // submit the approval request for processing
                    result = Approval.process(req);
                    isSuccess = true;
                }catch(Exception e){
                    System.debug('No approval process has been setup yet. \\n Error: '+ e.getMessage() + ' ' + e.getLineNumber());
                }
            }catch(Exception e){
                System.debug('Error happen while update E_Client Record: ' + e.getMessage() + ' ' + e.getLineNumber());
            }
        }

        return isSuccess;
    }

    @AuraEnabled
    public static List<User> fetchUser(String searchKeyWord) {
        String searchKey = searchKeyWord + '%';
        List<User> returnList = new List<User>();
        List<User> listOfUser = [Select id, Name From User Where Name LIKE: searchKey AND Title LIKE: '%Head%' AND isActive = true];

        for (User u: listOfUser) {
            returnList.add(u);
        }

        return returnList;
    }
}