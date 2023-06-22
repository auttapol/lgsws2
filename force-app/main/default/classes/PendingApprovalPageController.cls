public class PendingApprovalPageController {
    public User currentUser {
        get{
            if(currentUser == null){
                currentUser = [SELECT Id, Name, IsActive, Segment__c, managerid, manager.managerid, Profile.Name FROM User Where Id = :userInfo.getUserId() AND isActive = true];
            }
            return currentUser;
        }
        set;
    }

    public List<workItemWrapperClass> workItemWraplst {get;set;}

    public class workItemWrapperClass {
        public ProcessInstanceWorkitem piwi {get;set;}
        public String customerName {get;set;}
        public String recordtypeName {get;set;}
        public Id customerId {get;set;}
    }

    public PendingApprovalPageController() {
        System.debug('PendingApprovalPageController:::');
        System.debug('currentUser : ' + currentUser);

        workItemWraplst = new List<workItemWrapperClass> ();

        generateApprovalList();
    }

    public void generateApprovalList(){
        Set<Id> approvalHisLst = new Set<Id> ();
        Map<Id, Change_Owner_Approval_History__c> mapApprovalHisId = new Map<Id, Change_Owner_Approval_History__c>();

        List<ProcessInstanceWorkitem> piwilst = [SELECT ProcessInstanceId, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Name, ProcessInstance.TargetObject.Type, ProcessInstance.CreatedBy.Name, ProcessInstance.CreatedDate, ActorId, ProcessInstance.status, CreatedDate, ProcessInstance.SubmittedById, ProcessInstance.TargetObject.RecordtypeId, ProcessInstance.TargetObject.Recordtype.Name
                FROM ProcessInstanceWorkitem 
                WHERE 
                    isDeleted = false 
                    AND ActorId = :currentUser.Id
                    AND ProcessInstance.status = 'Pending'
                    // AND ProcessInstance.TargetObject.Type = 'Change_Owner_Approval_History__c'
                ORDER BY CreatedDate desc];
        
        for (ProcessInstanceWorkitem piwi : piwilst) {
            System.debug('piwi : ' + piwi);
            System.debug('ProcessInstance.TargetObject.Type : ' + piwi.ProcessInstance.TargetObject.Type);
            
            if(piwi.ProcessInstance.TargetObject.Type == 'Change_Owner_Approval_History__c'){
                approvalHisLst.add(piwi.ProcessInstance.TargetObjectId);
            }
        }

        mapApprovalHisId = new Map<Id, Change_Owner_Approval_History__c>([SELECT Id, Name, Account__c, Account__r.Name, RecordTypeId, RecordType.Name FROM Change_Owner_Approval_History__c WHERE Id IN :approvalHisLst]);

        for (ProcessInstanceWorkitem piwi : piwilst) {
            workItemWrapperClass workitemWrap = new workItemWrapperClass();
            workitemWrap.piwi = piwi;

            if(piwi.ProcessInstance.TargetObject.Type == 'Change_Owner_Approval_History__c'){
                workitemWrap.customerId = mapApprovalHisId.get(piwi.ProcessInstance.TargetObjectId).Account__c;
                workitemWrap.customerName = mapApprovalHisId.get(piwi.ProcessInstance.TargetObjectId).Account__r.Name;
                workitemWrap.recordtypeName = mapApprovalHisId.get(piwi.ProcessInstance.TargetObjectId).RecordType.Name;
            }else{
                // workitemWrap.customerId = 'piwi';
                // workitemWrap.customerName = 'piwi';
                // workitemWrap.recordtypeName = 'piwi';
            }

            workItemWraplst.add(workitemWrap);
        }
    }
}