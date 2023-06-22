public class AccountPlanRecallApproval {
    
    @InvocableMethod(label='Recall Company Profile' description='Recall Process Approval on Account Plan Company Profile. ')
     public static void recallAccountPlanApproval(List<ID> CompanyProfileIDs){
        SeT<ID>OwnerIDSet = new Set<ID>();
        Map<ID,ID> OwnerMap = new Map<ID,ID>();
      List<AcctPlanCompanyProfile__c> listCompany = [SELECT Account__c,OwnerId,Year__c,Status__c,isPendingForApproval__C 
         FROM AcctPlanCompanyProfile__c where ID IN :CompanyProfileIDs AND isPendingForApproval__C = true ] ;

                         if(listCompany.size()>0){
                            List<String> TargetObjectIDList = new List<String>();
                             //Tinnakrit - Recall ApprovalProcess
                            for(AcctPlanCompanyProfile__c comprofile : listCompany){
                               // comprofile.Status__c = 'Rejected';
                               // comprofile.isPendingForApproval__C = false;
                                 
                                TargetObjectIDList.add(comprofile.id);
                               
                            }
                        

                            // Retrieve the process work instance id associated to the process instance
                            List<ProcessInstanceWorkitem>  workitemList = new List<ProcessInstanceWorkitem>([select Id,OriginalActorId,CreatedDate,CreatedById,Actor.Name,ActorId  
                                                                                                             from ProcessInstanceWorkitem            
                                where ProcessInstance.TargetObjectId  IN: TargetObjectIDList Order By CreatedDate DESC  ]);
                             
                             System.debug('workitemList: '+workitemList);
                             for(ProcessInstanceWorkitem PIworkitem : workitemList){
                                 OwnerIDset.add(PIworkitem.CreatedById);
                             }
                             
                                for(USER us : [select ID,ManagerID from USER WHERE ID IN: OwnerIDset]){
                                    System.debug(us);
                                    System.debug(us.ManagerID);
                                    OwnerMap.put(us.id,us.ManagerID);
                                }
                             
                             	
                           		Set<ID> ProcessItemList = new Set<ID>();
                             
                             for(ProcessInstanceWorkitem workItem :  workitemList)
                            {
                             	ProcessItemList.add(workitem.id);
                               // workItem.ActorId = [SELECT ID,ManagerID from User WHERE ID =: workitem.CreatedById LIMIT 1].ManagerID;
                               	workItem.ActorId = OwnerMap.get(workitem.CreatedById);
                                
                                if(Test.isRunningTest()){
                                    workItem.ActorId = userinfo.getUserId();
                                }
                            }
                             update workitemlist;
                             
                             
                            for(ProcessInstanceWorkitem workItem :  workitemList)
                            {
                                Approval.ProcessWorkItemRequest pwr = new Approval.ProcessWorkItemRequest();
                                pwr.SetComments('Rejected due to change to new owner');
                                pwr.setWorkItemId(workItem.id);
                                pwr.setAction('Reject');
                                //pwr.setNextApproverIds (new Id[] {Workitem.ActorId});
                                 //Execute process request
                                Approval.ProcessResult pr = Approval.process(pwr);
                            }
                        }

    }

    

}