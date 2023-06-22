public class AccountPlanPortfolioApproval {
    public String  portfolioID {get;set;}
    public String  CompanyProfileID {get;set;}
    public String  Action {get;set;}
    public boolean isRecall {get;set;}
    public Boolean isRequest {get;set;}
    public Boolean isValid {get;set;}
    public ID workitem {get;set;}
    public AcctPlanPortfolio__c  tempport {get;set;}
    public AcctPlanPortfolio__c  portfolio {get;set;}
    public AcctPlanCompanyProfile__c tempcomprofile {get;set;}
    public AcctPlanCompanyProfile__c companyprofile {get;set;}
    public String Comment {get;set;}
    public string Close{get;set;}
     public AccountPlanPortfolioApproval(ApexPages.StandardController controller){
          tempport = new AcctPlanPortfolio__c();
          User currenruser = [SELECT ID,ManagerID FROM USER WHERE ID=: userinfo.getUserId() LIMIT 1];
          tempport.SalesOwner__c = currenruser.ManagerID ;
          tempcomprofile = new AcctPlanCompanyProfile__c();
          portfolioID = ApexPages.currentPage().getParameters().get('id');
          CompanyProfileID = ApexPages.currentPage().getParameters().get('ComId');
          Action= ApexPages.currentPage().getParameters().get('action');
         isValid = false;
         if(Action =='Request'){
             isRequest = true;
         }
         if(Action=='Recall'){
             isRecall = true;
         }
        if(portfolioID !=null && portfolioID !=''){
            //portfolio = AccountPlanUtilities.QueryPortfolioByID(portfolioID);
            portfolio = [SELECT Id,Name,OwnerId,isPendingForApproval__c FROM AcctPlanPortfolio__c WHERE Id = :portfolioID];
            workitem = portfolio.id;
        }else if(CompanyProfileID !=null && CompanyProfileID !=''){
            //companyprofile = AccountPlanUtilities.QueryAcctPlanCompanyProfileByID(CompanyProfileID);
			companyprofile =  [SELECT Id,Name,OwnerId,isPendingForApproval__c FROM AcctPlanCompanyProfile__c WHERE Id = :CompanyProfileID];           
            workitem = companyprofile.id;
        }
         
         System.debug('workitem consutrctor : '+workitem);
         
     }
    
    public void ProcessResult(){
        System.debug('Process');
        System.debug('tempport.SalesOwner__c : '+tempport.SalesOwner__c);
        if(tempport.SalesOwner__c !=null){
            isValid = true; 
        }
        try{
         Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
         request.setObjectID(workitem);
        System.debug(request.getObjectID());
        request.setNextApproverIds(new Id[] {tempport.SalesOwner__c });
        
        Approval.ProcessResult result = Approval.process(request);
            if(companyprofile !=null){
         companyprofile.isPendingForApproval__c = true;
        // companyprofile.Link_to_Company_Profile__c  = 'https://tmbbank--acctplan--c.cs5.visual.force.com/apex/CompanyProfileView?id='+companyprofile.id;
            update companyprofile;
            } else if (portfolio !=null){
                portfolio.isPendingForApproval__c = true;
               
                update portfolio;
                 System.debug(portfolio.isPendingForApproval__c);
            }
         Close ='<script>parent.modalclose(); </script>'; 
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));
            
        }
        
        
         
    }
    
    
    public void approveRecord()
    {
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction('Approve');
        Id workItemId = getWorkItemId(workitem);
        req.setComments(Comment);
        if(workItemId != null)
        {
            IsValid = true;
            req.setWorkitemId(workItemId);
            // Submit the request for approval
            Approval.ProcessResult result =  Approval.process(req);
             if(companyprofile !=null){
            companyprofile.isPendingForApproval__c = false;
            update companyprofile;
             }else if (portfolio !=null){
                portfolio.isPendingForApproval__c = false;
                update portfolio;
            }
            Close ='<script>parent.modalclose(); </script>';
        }
    }
    
    public void rejectRecord()
        {
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Reject');
    		Id workItemId = getWorkItemId(workitem);
			req.setComments(Comment);
            if(workItemId !=null)
            {
                IsValid =true;
                req.setWorkitemId(workItemId);
                // Submit the request for approval
                Approval.ProcessResult result =  Approval.process(req);
                 if(companyprofile !=null){
                companyprofile.isPendingForApproval__c = false;
            	update companyprofile;
                 }else if (portfolio !=null){
                portfolio.isPendingForApproval__c = false;
                update portfolio;
            }
                Close ='<script>parent.modalclose(); </script>';
            }
        }
    
    
    public void recallrecord()
    {
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction('Removed');
        Id workItemId = getWorkItemId(workitem); 
        req.setComments(Comment);
        if(workItemId != null)
        {
            IsValid = true;
            req.setWorkitemId(workItemId);
            // Submit the request for approval
            Approval.ProcessResult result =  Approval.process(req);
             if(companyprofile !=null){
            companyprofile.isPendingForApproval__c = false;
            update companyprofile;
             }else if (portfolio !=null){
                portfolio.isPendingForApproval__c = false;
                update portfolio;
            }
            Close ='<script>parent.modalclose(); </script>';
        }
    }
    
    
    public Id getWorkItemId(Id targetObjectId)
    {
        Id retVal = null;

        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
            where p.ProcessInstance.TargetObjectId =: targetObjectId])
        {
            retVal  =  workItem.Id;
        }

        return retVal;
    }

}