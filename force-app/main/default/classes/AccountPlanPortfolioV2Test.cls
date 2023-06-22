@isTest
global class AccountPlanPortfolioV2Test {
    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
        TestUtils.CreateAddress();
        AccountPlanTestUtilities.getAcctPlanMode();
        AccountPlanTestUtilities.AccountPlanStatusCode();
    }
    static testmethod void AccountPlanPortfolioInitiate(){
        
        User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioInitiateTest', 'portfolio@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
        List<Account> AccountList = AccountPlanTestUtilities.createAccounts(5, 'InitiateTest', 'Individual', SalesOwner.id, true, true);
        List<Account> AccountList2 = AccountPlanTestUtilities.createAccounts(5, 'InitiateTest2', 'Individual', SalesOwner.id, true, true);
        Group__c mastergroup = AccountPlanTestUtilities.createGroupMaster(1,'Initiatetest', false, true).get(0);
        List<Group__c> mastergroupList = AccountPlanTestUtilities.createGroupMaster(1,'Initiatetest2', false, true);
        AcctPlanGroupProfile__c groupprofile = AccountPlanTestUtilities.createGroupProfilebyGroup(mastergroupList,true).get(0);
        groupprofile.Year__c ='2015';
        update groupprofile;
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(AccountList2, true);
        for(AcctPlanCompanyProfile__c compro : comprofileList){
            compro.Year__c = '2015';
            compro.AcctPlanGroup__c =  groupprofile.id;
        }
        update comprofileList;
        
        for(account acct  : AccountList){
            acct.Group__c =mastergroup.id;
        }
        for(account acct  : AccountList2){
            acct.Group__c =mastergroupList.get(0).id;
        }
        update AccountList;
        update AccountList2;
        AccountPlanTestUtilities.createAccounts(1, 'InitiateNonGroupTest', 'Individual', SalesOwner.id, true, true);
        List<Target__c> TaragetList = AccountPlanTestUtilities.createTargetNI(5,  SalesOwner.id, true);
       
        System.runAs(SalesOwner){
        AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(SalesOwner.id, '2014', 10000000, false);
        ApexPages.StandardController sc = new ApexPages.StandardController(portfolio);
       
        
        AccountPlanPortfolioInitiateCtrlV2 portfolioCtrl = new AccountPlanPortfolioInitiateCtrlV2(sc);
            portfoliocTrl.portfolio = portfolio;
             //Test.setMock(WebServiceMock.class, new TMBAccountPlanServiceProxyMock());
            Test.startTest();
             
            
            portfolioCtrl.getFiscalYear();
            portfolioCtrl.YearStr ='2015';
            portfolioCtrl.selectedYear();
            portfoliocTrl.portfolio.Year__c = '2015';
            portfoliocTrl.YearStr = '2015';
            portfolioCtrl.Refreshfunction();
            portfolioCtrl.save();
                 
            portfolioCtrl.save();   
            portfolioCtrl.SetPortTableData(AccountList);
            
            //Pagination
            Integer noOfRecords = 0;
            Integer size = 2;
            Boolean hasNext = portfolioCtrl.setCon.getHasNext();
            Boolean hasPrevious = portfolioCtrl.setCon.getHasPrevious();
            Integer pageNumber = portfolioCtrl.setCon.getPageNumber();
            
            AccountPlanPortfolioInitiateCtrlV2.companyPortWrapper pagination = new AccountPlanPortfolioInitiateCtrlV2.companyPortWrapper();
            List<AccountPlanPortfolioInitiateCtrlV2.companyPortWrapper> paginationList = portfolioCtrl.companyPortList;
            
            portfolioCtrl.next();
            portfolioCtrl.first();
            portfolioCtrl.last();
            portfolioCtrl.previous();


            Test.stopTest();            
        }
        
    }
    
    static testmethod void AccountPlanPortfolioManagement(){
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
        List<Account> AccountList = AccountPlanTestUtilities.createAccounts(5, 'InitiateTest', 'Individual', SalesOwner.id, true, true);
        List<Account> AccountList2 = AccountPlanTestUtilities.createAccounts(5, 'InitiateTest2', 'Individual', SalesOwner.id, true, true);
        Group__c mastergroup = AccountPlanTestUtilities.createGroupMaster(1,'Initiatetest', false, true).get(0);
        List<Group__c> mastergroupList = AccountPlanTestUtilities.createGroupMaster(1,'Initiatetest2', false, true);
     
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(AccountList2, true);
        for(AcctPlanCompanyProfile__c compro : comprofileList){
            compro.Year__c = '2015';
            //compro.AcctPlanGroup__c =  groupprofile.id;
        }
        update comprofileList;
        
        for(account acct  : AccountList){
            acct.Group__c =mastergroup.id;
        }
        for(account acct  : AccountList2){
            acct.Group__c =mastergroupList.get(0).id;
        }
        
        Map<Id,Account> acctMap = new Map<Id,Account>();
        for(Account acct : AccountList){
            acctMap.put(acct.id,acct);
        }
        for(Account acct : AccountList2){
            acctMap.put(acct.id,acct);
        }
        
        update acctMap.values();
        //update AccountList;
        //update AccountList2;
  
        
        AccountList.add(AccountPlanTestUtilities.createAccounts(1, 'PortMngNonGroupTest', 'Individual', SalesOwner.id, true, true).get(0));
        List<Target__c> TaragetList = AccountPlanTestUtilities.createTargetNI(5,  SalesOwner.id, true);
       
        
        //Addmore
         List<Account> AccountNewList = AccountPlanTestUtilities.createAccounts(2, 'AddPortMngTest', 'Individual', SalesOwner.id, true, true);
            Group__c Newmastergroup = AccountPlanTestUtilities.createGroupMaster(1,'AddPortMngtest', false, true).get(0);
            for(account acct  : AccountNewList){
                acct.Group__c =Newmastergroup.id;
            }
            AccountNewList.get(0).Group__c = mastergroup.id;
            update AccountNewList;
            AccountNewList.add(AccountPlanTestUtilities.createAccounts(1, 'AddPortMngNonGroupTest', 'Individual', SalesOwner.id, true, true).get(0));
            
         
        
        
        
        
        System.runAs(SalesOwner){
            
            
         
             AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(SalesOwner.id, '2015', 10000000, true);

            List<Group__c> groupmasterlist = new List<Group__c>();
            groupmasterlist.add(mastergroup);
        List<AcctPlanGroupPort__c> groupportlist = AccountPlanTestUtilities.createGroupPortbyGroupMaster(groupmasterlist, portfolio, true);
        List<AcctPlanCompanyPort__c> comportList = AccountPlanTestUtilities.createCompanyPortByAccount(AccountList, portfolio, true);
        
         
      
               PageReference PortfolioPage = Page.AccountPlanPortfolioManagementV2;
               PortfolioPage.getParameters().put('id',portfolio.id);
               Test.setCurrentPage(PortfolioPage);
       
            Test.startTest();
            
            
            
            
             ApexPages.StandardController sc = new ApexPages.StandardController(portfolio);
             AccountPlanPortfolioManagementCtrlV2 portfolioCtrl = new AccountPlanPortfolioManagementCtrlV2(sc);
           
            for(AcctPlanCompanyPort__c comport : comportList){
                comport.Target_NI_By_RM__c =10000000;
                comport.Wallet__c = 200000;
                comport.Target_NI_By_RM__c = 300000;
                comport.Performance__c = 400000;
                comport.ExpectedNIbyAccountPlan__c = 500000;
                comport.AcctPlanGroupPort__c = groupportlist.get(0).id;
            }
            update comportlist;
            
            portfolioCtrl.FiltersOption ='Target';
             portfolioCtrl.AccountPlanFilters();
            portfolioCtrl.FiltersOption ='Flag';
            portfolioCtrl.AccountPlanFilters();
            portfolioCtrl.FiltersOption ='Group';
            portfolioCtrl.AccountPlanFilters();
           
            portfolioCtrl.Refreshfunction();
            portfolioCtrl.RefreshWalletFunction();
            
            for(AcctPlanCompanyPort__c comport : comportList){
                comport.Target_NI_By_RM__c =10000000;
            }
            update comportlist;
            //portfolioCtrl.updateTargetNI();
             
            //Pagination
            Integer noOfRecords = 0;
            Integer size = 2;
            Boolean hasNext = portfolioCtrl.setCon.getHasNext();
            Boolean hasPrevious = portfolioCtrl.setCon.getHasPrevious();
            Integer pageNumber = portfolioCtrl.setCon.getPageNumber();
            
            
            
            
            AccountPlanPortfolioManagementCtrlV2.CompanyPortWrapper pagination = new AccountPlanPortfolioManagementCtrlV2.companyPortWrapper();
            List<AccountPlanPortfolioManagementCtrlV2.companyPortWrapper> paginationList = portfolioCtrl.ComPortListWrapper;
             portfolioCtrl.next();
            portfolioCtrl.first();
            portfolioCtrl.last();
            portfolioCtrl.previous();
            
            
            PortfolioPage.getParameters().put('acctKey',comportList.get(0).id);
            portfolioCtrl.InitiateAccountPlan();
           
            AcctPlanCompanyPort__c comport2 = comportList.get(3);
            List<AcctPlanCompanyProfile__c> comprofileList2 = AccountPlanTestUtilities.createCompanyProfileByAccount(AccountList, true);
        
            
            PortfolioPage.getParameters().put('acctKey',comport2.id);
            portfolioCtrl.InitiateAccountPlan();
            AccountPlanPortfolioManagementCtrlV2.ApprovalWrapper appWrap = new AccountPlanPortfolioManagementCtrlV2.ApprovalWrapper();
            portfolioCtrl.ApprovalExRemoteAction();
            portfolioCtrl.ApprovalEx();
            portfolioCtrl.redirect();
            
             AcctPlanCompanyPort__c comport = comportlist.get(0);
            AcctPlanCompanyProfile__c comprofile =  comprofileList.get(0);
            comport.Account_Plan_Company_Profile__c = comprofile.id;
            
            comprofile.Account__c = comport.Account__c;
            AcctPlanGroupPort__c groupport = groupportlist.get(0);
            groupport.Account_Plan_Group_Profile__c = null;
            comport.AcctPlanGroupPort__c = groupport.id;
            
            //groupprofile.Group__c = groupport.Group__c;
            //groupprofile.Year__c = groupport.Year__c;
            //update groupprofile;
            update groupport;
            update Comprofile;
            AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(Comprofile.id);
            update comport;
            
            
             ApexPages.StandardController sc2 = new ApexPages.StandardController(portfolio);
             AccountPlanPortfolioManagementCtrlV2 portfolioCtrl2 = new AccountPlanPortfolioManagementCtrlV2(sc);
            PortfolioPage.getParameters().put('acctKey',comport.id);
            
            
            portfolioCtrl2.EditAccountPlan();
            AcctPlanGroupProfile__c groupprofile = AccountPlanTestUtilities.createGroupProfilebyGroup(mastergroupList,true).get(0);
                groupprofile.Year__c ='2015';
                groupPort.Group__c = mastergroupList.get(0).id;
                update groupprofile;
                update GroupPort;
            
            portfolioCtrl2.EditAccountPlan();
           
           Test.stopTest();
        }
        
       
           
         
        
    }
    
    
    static testmethod void AccountPlanRefreshGroup(){
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
        List<Account> AccountList = AccountPlanTestUtilities.createAccounts(5, 'InitiateTest', 'Individual', SalesOwner.id, true, true);
         Group__c mastergroup = AccountPlanTestUtilities.createGroupMaster(1,'Initiatetest', false, true).get(0);
        List<Group__c> mastergroupList = AccountPlanTestUtilities.createGroupMaster(1,'Initiatetest2', false, true);
        AcctPlanGroupProfile__c groupprofile = AccountPlanTestUtilities.createGroupProfilebyGroup(mastergroupList,true).get(0);
        groupprofile.Year__c ='2015';
        update groupprofile;
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(AccountList, true);
        Map<Id,AcctPlanCompanyProfile__c> comAcctkeyMap = new Map<ID,AcctPlanCompanyProfile__c>();
        for(AcctPlanCompanyProfile__c compro : comprofileList){
            compro.Year__c = '2015';
            compro.AcctPlanGroup__c =  groupprofile.id;
            comAcctkeyMap.put(compro.Account__c,compro);
        }
        update comprofileList;
        Map<Id,account> accountMap = new Map<ID,Account>();
        for(account acct  : AccountList){
            acct.Group__c =mastergroup.id;
            accountMap.put(acct.id,acct);
        }
       
        
        update AccountList;
  
        
        AccountList.add(AccountPlanTestUtilities.createAccounts(1, 'PortMngNonGroupTest', 'Individual', SalesOwner.id, true, true).get(0));
        List<Target__c> TaragetList = AccountPlanTestUtilities.createTargetNI(5,  SalesOwner.id, true);
       
        
        //Addmore
         List<Account> AccountNewList = AccountPlanTestUtilities.createAccounts(2, 'AddPortMngTest', 'Individual', SalesOwner.id, true, true);
            Group__c Newmastergroup = AccountPlanTestUtilities.createGroupMaster(1,'AddPortMngtest', false, true).get(0);
            for(account acct  : AccountNewList){
                acct.Group__c =Newmastergroup.id;
            }
            AccountNewList.get(0).Group__c = mastergroup.id;
            update AccountNewList;
            AccountNewList.add(AccountPlanTestUtilities.createAccounts(1, 'AddPortMngNonGroupTest', 'Individual', SalesOwner.id, true, true).get(0));
            
         
        
        //ChangeGroup
        //
        List<Group__c> changegroupList = AccountPlanTestUtilities.createGroupMaster(1,'Initiatetest3', false, true);
        AcctPlanGroupProfile__c changegrouppro = AccountPlanTestUtilities.createGroupProfilebyGroup(changegroupList,true).get(0);
        changegrouppro.Year__c ='2015';
        update changegrouppro;
       
        
        
        
        System.runAs(SalesOwner){
            
            
         
             AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(SalesOwner.id, '2015', 10000000, true);

            List<Group__c> groupmasterlist = new List<Group__c>();
            groupmasterlist.add(mastergroup);
        List<AcctPlanGroupPort__c> groupportlist = AccountPlanTestUtilities.createGroupPortbyGroupMaster(groupmasterlist, portfolio, true);
        List<AcctPlanCompanyPort__c> comportList = AccountPlanTestUtilities.createCompanyPortByAccount(AccountList, portfolio, true);
        
         //Changegroup 
         //
          AcctPlanCompanyPort__c comportchange =  comportList.get(1);
        Account acctchange = accountMap.get(comportchange.Account__c);
        AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(comAcctkeyMap.get(comportchange.Account__c).id);         
            
        acctchange.Group__c = changegroupList.get(0).id;
        update acctchange;
            
         //
      
               PageReference PortfolioPage = Page.AccountPlanPortfolioManagementV2;
               PortfolioPage.getParameters().put('id',portfolio.id);
               Test.setCurrentPage(PortfolioPage);
           
           
       
            Test.startTest();
            
            
             ApexPages.StandardController sc = new ApexPages.StandardController(portfolio);
             AccountPlanPortfolioManagementCtrlV2 portfolioCtrl = new AccountPlanPortfolioManagementCtrlV2(sc);
            
                       
            PortfolioPage.getParameters().put('acctKey',comportchange.id);
            portfolioCtrl.RefreshGroupFunction();
           
            
           
           Test.stopTest();
        }
        
       
           
         
        
    }
    
    
    static testmethod void AccountPlanPortfolioManagementEdit(){
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
        List<Account> AccountList = AccountPlanTestUtilities.createAccounts(5, 'PortMngTest', 'Individual', SalesOwner.id, true, true);
        AccountPlanTestUtilities.createCompanyProfileByAccount(AccountList, true);
        Group__c mastergroup = AccountPlanTestUtilities.createGroupMaster(1,'PortMngtest', false, true).get(0);
        List<group__c> mgroupList = new List <group__c>();
        mgroupList.add(mastergroup);
        AccountPlanTestUtilities.createGroupProfilebyGroup(mgroupList,true);
        for(account acct  : AccountList){
            acct.Group__c =mastergroup.id;
        }
        update AccountList;
        AccountList.add(AccountPlanTestUtilities.createAccounts(1, 'PortMngNonGroupTest', 'Individual', SalesOwner.id, true, true).get(0));
        List<Target__c> TaragetList = AccountPlanTestUtilities.createTargetNI(5,  SalesOwner.id, true);
       
        
        //Addmore
         List<Account> AccountNewList = AccountPlanTestUtilities.createAccounts(2, 'AddPortMngTest', 'Individual', SalesOwner.id, true, true);
            Group__c Newmastergroup = AccountPlanTestUtilities.createGroupMaster(1,'AddPortMngtest', false, true).get(0);
            for(account acct  : AccountNewList){
                acct.Group__c =Newmastergroup.id;
            }
            AccountNewList.get(0).Group__c = mastergroup.id;
            update AccountNewList;
            AccountNewList.add(AccountPlanTestUtilities.createAccounts(1, 'AddPortMngNonGroupTest', 'Individual', SalesOwner.id, true, true).get(0));
            
         
        
             AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(SalesOwner.id, '2014', 10000000, true);

            List<Group__c> groupmasterlist = new List<Group__c>();
            groupmasterlist.add(mastergroup);
        List<AcctPlanGroupPort__c> groupportlist = AccountPlanTestUtilities.createGroupPortbyGroupMaster(groupmasterlist, portfolio, true);
        List<AcctPlanCompanyPort__c> comportList = AccountPlanTestUtilities.createCompanyPortByAccount(AccountList, portfolio, true);
              
      
               PageReference PortfolioPage = Page.AccountPlanPortfolioManagementV2;
               PortfolioPage.getParameters().put('id',portfolio.id);
               Test.setCurrentPage(PortfolioPage);
        
        
        
        System.runAs(SalesOwner){
            Test.startTest();
            
            
            
            
           
            for(AcctPlanCompanyPort__c comport : comportList){
                comport.Target_NI_By_RM__c =10000000;
                comport.Wallet__c = 200000;
                comport.Target_NI_By_RM__c = 300000;
                comport.Performance__c = 400000;
                comport.ExpectedNIbyAccountPlan__c = 500000;
            }
            update comportlist;
            
             ApexPages.StandardController sc = new ApexPages.StandardController(portfolio);
            AccountPlanPortfolioManagementEditCtrlV2 portfolioEditCtrl = new AccountPlanPortfolioManagementEditCtrlV2(sc);
            
           
            portfolioEditCtrl.FiltersOption ='Flag';
            portfolioEditCtrl.AccountPlanFilters();
            portfolioEditCtrl.updateTargetNI();
            portfolioEditCtrl.FiltersOption ='Group';
            portfolioEditCtrl.AccountPlanFilters();
            portfolioEditCtrl.updateTargetNI();
            portfolioEditCtrl.FiltersOption ='Target';
            portfolioEditCtrl.AccountPlanFilters();
            portfolioEditCtrl.updateTargetNI();
             
               //Pagination
            Integer noOfRecords = 0;
            Integer size = 2;
            Boolean hasNext = portfolioEditCtrl.setCon.getHasNext();
            Boolean hasPrevious = portfolioEditCtrl.setCon.getHasPrevious();
            Integer pageNumber = portfolioEditCtrl.setCon.getPageNumber();
            
            AccountPlanPortfolioManagementEditCtrlV2.CompanyPortWrapper pagination = new AccountPlanPortfolioManagementEditCtrlV2.companyPortWrapper();
            List<AccountPlanPortfolioManagementEditCtrlV2.companyPortWrapper> paginationList = portfolioEditCtrl.companyPortListEdit;
            
            portfolioEditCtrl.next();
            portfolioEditCtrl.first();
            portfolioEditCtrl.last();
            portfolioEditCtrl.previous();
            
            PortfolioPage.getParameters().put('acctKey',comportList.get(0).id);
            portfolioEditCtrl.redirect();
           Test.stopTest();
        }
        
       
           
         
        
    }
    
    static testmethod void AccountPlanPortfolioApproval(){
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
         AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(SalesOwner.id, '2014', 10000000, true);
         List<Account> AccountList = AccountPlanTestUtilities.createAccounts(1, 'ApprovalTest', 'Individual', SalesOwner.id, true, true);
         AcctPlanCompanyProfile__c comprofile = AccountPlanTestUtilities.createCompanyProfileByAccount(AccountList, true).get(0);
        
        
        
        
                PageReference PortfolioPage = Page.AccountPlanPortfolioApproval;
               PortfolioPage.getParameters().put('id',portfolio.id);
               PortfolioPage.getParameters().put('action','Request');
               Test.setCurrentPage(PortfolioPage);
                ApexPages.StandardController sc = new ApexPages.StandardController(portfolio);
                AccountPlanPortfolioApproval approvalCtrl = new AccountPlanPortfolioApproval(sc);
                approvalCtrl.tempport.SalesOwner__c = SalesOwner.id;
                approvalCtrl.ProcessResult();
                approvalCtrl.approveRecord();
                approvalCtrl.ProcessResult();
                approvalCtrl.rejectRecord();
                approvalCtrl.ProcessResult();
                approvalCtrl.recallrecord();
                approvalCtrl.getWorkItemId(portfolio.id);
        
              PageReference Approval = Page.AccountPlanPortfolioApproval;
               Approval.getParameters().put('ComId',comprofile.id);
               Approval.getParameters().put('action','Request');
               Test.setCurrentPage(Approval);
                ApexPages.StandardController ScCompro = new ApexPages.StandardController(comprofile);
                AccountPlanPortfolioApproval approvalCtrl2 = new AccountPlanPortfolioApproval(ScCompro);
       
    }
    
    static testmethod void AccountPlanPortfolioProcessStep(){
        User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
         
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
        
       
          
        
               PageReference PortfolioPage = Page.AccountPlanPortfolioManagementV2;
               PortfolioPage.getParameters().put('id',portfolio.id);
               Test.setCurrentPage(PortfolioPage);
        
             ApexPages.StandardController sc = new ApexPages.StandardController(portfolio);
             AccountPlanPortfolioManagementCtrlV2 portfolioCtrl = new AccountPlanPortfolioManagementCtrlV2(sc);
    }
 
   
}