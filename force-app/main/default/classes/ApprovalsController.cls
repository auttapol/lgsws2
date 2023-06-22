global class ApprovalsController{
    public static boolean runningInTestMode = false;
    
    global class PendingApproval{
        public Id recordId {get;set;}
        public String recordName {get;set;}
        public String approvalInstanceId {get;set;}
        public String approvalStepId {get;set;}
        public String sObjectLabel {get;set;}
        public String sObjectName {get;set;}
        public String submiterName {get;set;}
        public String submiterPhotoUrl {get;set;}
        public String submitDate {get;set;}
        public boolean firstOfSObjectType {get;set;}
        
        public PendingApproval(ProcessInstanceWorkitem p){
            recordId = p.ProcessInstance.TargetObjectId;
            recordName = p.ProcessInstance.TargetObject.Name;
            approvalInstanceId = p.ProcessInstanceId;
            sObjectName = p.ProcessInstance.TargetObject.Type;
            submiterName = p.ProcessInstance.CreatedBy.Name;      
            submiterPhotoUrl = p.ProcessInstance.CreatedBy.SmallPhotoUrl;    
        }
    }
    
    public ApprovalsController(){
        getPendingApprovals();
    }
    
    @RemoteAction
    public static List<PendingApproval> getPendingApprovals(){
        List<PendingApproval> pendingApprovals = new List<PendingApproval>();
        Set<Id> processInstanceIds = new Set<Id>();
        Map<String, String> sObjectName2Label = new Map<String, String>();

        String prevSObjectType;
        
        Set<Id> memberOfQueueIds = new Set<Id>();
        memberOfQueueIds.add(UserInfo.getUserId());
        for (GroupMember m : [  select GroupId from GroupMember where 
                                UserOrGroupId= :UserInfo.getUserId() 
                            	and Group.Type = 'Queue']){
            memberOfQueueIds.add(m.GroupId);                    
        }
        
        List<ProcessInstanceWorkitem> approvals;
        if (runningInTestMode){
            ProcessInstance testInstance = new ProcessInstance();
            testInstance.targetObjectId = new Contact(LastName = 'Test').id;
            ProcessInstanceWorkitem testP = new ProcessInstanceWorkitem(ActorId = UserInfo.getUserId(), 
                                                                        ProcessInstance = testInstance);
            approvals = new List<ProcessInstanceWorkitem>();
            approvals.add(testP);
        }else{
            approvals = [select ProcessInstanceId, ProcessInstance.TargetObjectId, 
                                         ProcessInstance.TargetObject.Name,
                                         ProcessInstance.TargetObject.Type, ProcessInstance.CreatedBy.Name,
                                         ProcessInstance.CreatedDate, ProcessInstance.CreatedBy.SmallPhotoUrl 
                                         from ProcessInstanceWorkitem 
                                         where isDeleted=false and ActorId IN :memberOfQueueIds and 
                         				 ProcessInstance.status='Pending' order by 
                                         ProcessInstance.TargetObject.Type, SystemModstamp desc];
        }
                                             
        for(ProcessInstanceWorkitem p : approvals){
            PendingApproval pa = new PendingApproval(p);
            
            if (p.ProcessInstance.CreatedDate != null){
                pa.submitDate = p.ProcessInstance.CreatedDate.format('MMM dd');
            }
            
            if (p.ProcessInstance.TargetObject.Type != prevSObjectType){
                pa.firstOfSObjectType = true;
            }else{
                pa.firstOfSObjectType = false;
            }

                        
            prevSObjectType = p.ProcessInstance.TargetObject.Type;
            pa.sObjectLabel = sObjectName2Label.get(p.ProcessInstance.TargetObject.Type);

            if (pa.sObjectLabel == null){
                String sObjectType = p.ProcessInstance.TargetObject.Type;
                if (sObjectType != null){
                    if (sObjectType.endsWith('__kav')){
                        sObjectType = sObjectType.left(sObjectType.length()-1);
                    }
    
                    pa.sObjectLabel = Schema.describeSObjects(new String[]{sObjectType})[0].getLabelPlural();
                    sObjectName2Label.put(p.ProcessInstance.TargetObject.Type, pa.sObjectLabel);
                }
            }

            pendingApprovals.add(pa);
            processInstanceIds.add(p.ProcessInstanceId);
        }
        
        Map<Id, Id> processInstance2Step = new Map<Id, Id>();
        for(ProcessInstanceStep step : [select id, ProcessInstanceId, Actor.Name, 
                                        StepStatus from ProcessInstanceStep 
                                        where ProcessInstanceId in :processInstanceIds]){
            processInstance2Step.put(step.ProcessInstanceId, step.Id);
        }
        
        List<PendingApproval> finalPendingApprovals = new List<PendingApproval>();
        for (PendingApproval p : pendingApprovals){
            p.approvalStepId = processInstance2Step.get(p.approvalInstanceId);
            
            if (p.approvalStepId != null) {
                finalPendingApprovals.add(p);
            }
        }

        return finalPendingApprovals;
    }
}