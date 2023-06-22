@isTest
global  class AccountPlanPortfolioProcessStepTest {
    public static final Id TMB_Team_Head_Profile_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Team Head Profile' LIMIT 1].Id;

    static{
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'true';        
        apps.add(Aconfig);
        insert apps;
        AccountPlanTestUtilities.AccountPlanStatusCode();
    }
    
 static testmethod void AccountPlanPortfolioProcessStep(){
        //User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        List<User> lstSales = AccountPlanTestUtilities.createUsers(2, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true);   
     	User SalesMng = lstSales[0];  
        SalesMng.ProfileId = TMB_Team_Head_Profile_ID;
     	User SalesOwner = lstSales[1];
     	SalesOwner.ManagerId = SalesMng.id;
     
         AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(SalesOwner.id, '2014', 10000000, true);

        
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(portfolio.id); 
        req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(SalesOwner.id); 
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('Account_Plan_Portfolio_Approval_Flow');
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        
        
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        // Instantiate the new ProcessWorkitemRequest object and populate it

        Approval.ProcessWorkitemRequest req2 =
            new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(newWorkItemIds.get(0));
        // Submit the request for approval
        Approval.ProcessResult result2 =  Approval.process(req2);
        
     
      for(Sobject sobj : portfolio.ProcessSteps){
          system.debug(sobj);
          
      }
       
          
        
               PageReference PortfolioPage = Page.AccountPlanPortfolioManagementV2;
               PortfolioPage.getParameters().put('id',portfolio.id);
               Test.setCurrentPage(PortfolioPage);
        
             ApexPages.StandardController sc = new ApexPages.StandardController(portfolio);
             AccountPlanPortfolioManagementCtrlV2 portfolioCtrl = new AccountPlanPortfolioManagementCtrlV2(sc);
    }
 
}