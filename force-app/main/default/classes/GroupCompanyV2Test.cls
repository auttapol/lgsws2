@isTest
global class GroupCompanyV2Test {
    
    static void setInitial()
    {
        insert new Account_Plan_Status_Code__c(name = '1002', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '1006', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '1020', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '1021', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '9005', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '1023', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '1022', Status_Message__c = 'test');
        insert new Status_Code__c(name = '4010', Status_Message__c = 'test');
        
        insert new Account_Plan_Fiscal_Year__c(name = '1', AD_Year__c = '2016', BE_Year__c = '2559');
    }
    
    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
        TestUtils.CreateAddress();
        AccountPlanTestUtilities.getAcctPlanMode();
    }
 
     static testmethod void GroupCompanyTest(){
         setInitial();
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
           Test.startTest();
        List<Account> AccountList = AccountPlanTestUtilities.createAccounts(5, 'GroupPro', 'Individual', SalesOwner.id, true, true);
         List<Account> NewAccountList = AccountPlanTestUtilities.createAccounts(5, 'GroupMaster', 'Individual', SalesOwner.id, true, true);
         List<Account> acctForCompanyProfile = new List<Account>();
         acctForCompanyProfile.add(AccountList.get(0));
         acctForCompanyProfile.add(AccountList.get(2));
         acctForCompanyProfile.add(AccountList.get(3));
         AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(SalesOwner.id, '2014', 10000000, false);
        
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
        List <group__c> groupList = AccountPlanTestUtilities.createGroupMaster(2,'PortMngtest', false, true);
        Group__c mastergroup = groupList.get(0);
        Group__c newGroup = groupList.get(1);
         for(account acct  : AccountList){
            acct.Group__c =mastergroup.id;
        }
         for(account Newacct  : NewAccountList){
            Newacct.Group__c =newGroup.id;
        }
         
         
        update AccountList;
        update NewAccountList;

        List<group__c> mgroupList = new List <group__c>();
        mgroupList.add(mastergroup);
        AcctPlanGroupProfile__c groupprofile = AccountPlanTestUtilities.createGroupProfilebyGroup(mgroupList,true).get(0);
         comprofile.AcctPlanGroup__c = groupprofile.id;
         update comprofile;
         List<AcctPlanContribution__c> contributionlist = AccountPlanTestUtilities.createRenevueContribution(3,groupprofile.id, null);
          contributionlist.get(0).RevenueContributionType__c = 'Contribution by service & product';
          contributionlist.get(1).RevenueContributionType__c = 'Contribution by business unit';
          contributionlist.get(2).RevenueContributionType__c = 'Contribution by regional';
         update contributionlist;
         //Test.setMock(WebServiceMock.class, new TMBAccountPlanServiceProxyMock());
         AccountTeamMember teammember = new AccountTeamMember ();
         teammember.AccountID = comprofile.Account__c;
         teammember.TeamMemberRole = 'Sponser';
         teammember.UserId = SalesOwner.id;
         insert teammember;
         AccountTeamMember teammember2 = new AccountTeamMember ();
         teammember2.AccountID = comprofile.Account__c;
         teammember2.TeamMemberRole = 'Sponser';
         teammember2.UserId = Userinfo.getUserId();
         insert teammember2;
         
         Account Newacct = NewAccountList.get(1);
         AcctPlanWallet__c wallet = new AcctPlanWallet__c ();
         wallet.AcctPlanCompanyProfile__c = comprofile.id;
         insert wallet;
         SalesOwner.Segment__c = 'SE';
                update SalesOwner;
      
         AcctPlanCompanyPort__c apcp = new AcctPlanCompanyPort__c(Account_Name__c = Newacct.id);
         insert apcp;
         
          PageReference groupViewPage = Page.GroupCompanyViewV2;
               groupViewPage.getParameters().put('id',groupprofile.id);
               groupViewPage.getParameters().put('Companyid',comprofile.id);
               groupViewPage.getParameters().put('acctKey',AccountList.get(4).id);
                
               groupViewPage.getParameters().put('ComProParameter',comprofile.id);
               groupViewPage.getParameters().put('CompanyPortID',apcp.id);
               Test.setCurrentPage(groupViewPage); 

             ApexPages.StandardController sc = new ApexPages.StandardController(groupprofile);
             GroupCompanyExControllerV2 groupCtrl = new GroupCompanyExControllerV2(sc);
             groupCtrl.getFiscalYear();
             boolean Authorized = groupCtrl.isHasAuthorized;
             boolean IScontribution = groupCtrl.isHasContribution;
             groupCtrl.EditAccountPlan();
             groupCtrl.redirect();
             groupCtrl.cancel();
         
         //Pagination
            Integer noOfRecords = 0;
            Integer size = 2;
            Boolean hasNext = groupCtrl.setCon.getHasNext();
            Boolean hasPrevious = groupCtrl.setCon.getHasPrevious();
            Integer pageNumber = groupCtrl.setCon.getPageNumber();

            List<GroupCompanyExControllerV2.AccountPlanWrapper> paginationList = groupCtrl.AcctWrapperList;
            
            groupCtrl.next();
            groupCtrl.first();
            groupCtrl.last();
            groupCtrl.previous(); 
         
         
                PageReference groupEditPage = Page.GroupCompanyEditV2;
         
                
               groupEditPage.getParameters().put('acctKey',Newacct.id);
         
               groupEditPage.getParameters().put('MasterGroup',newGroup.id);
               Test.setCurrentPage(groupEditPage); 
                ApexPages.StandardController  NewGroupsc= new ApexPages.StandardController(newGroup);
             GroupCompanyExControllerV2 NewgroupCtrlInit = new GroupCompanyExControllerV2();
             GroupCompanyExControllerV2 NewgroupCtrl = new GroupCompanyExControllerV2(NewGroupsc);
                Account queryAcct = [SELECT ID,Name,First_Name_PE__c,Industry ,Group__c,Account_Plan_Flag__c,
                       Group__r.Name,LastModifiedDate,LastModifiedBy.Name,                 
                       Group__r.GroupCompany__c ,
                       //Group__r.GroupIndustry__c , //mm
                       Group__r.Parent_Company__c ,
                       //Group__r.ParentIndustry__c, //mm
                       Group__r.UltimateParent__c,
                       Owner.Name, Owner.Id, Owner.Segment__c
                      FROM Account WHERE ID =:Newacct.id LIMIT 1];
                GroupCompanyExControllerV2.AccountPlanWrapper wrapper = new GroupCompanyExControllerV2.AccountPlanWrapper();
                wrapper.Acct = queryAcct;
             NewGroupCtrl.AccountwithWrapperMap =new Map<Id,GroupCompanyExControllerV2.AccountPlanWrapper>();
             
             
         NewGroupCtrl.AccountwithWrapperMap.put(queryAcct.id,wrapper);
              NewGroupCtrl.cancel();
              NewGroupCtrl.dosave();
              NewGroupCtrl.InitiateAccountPlan();
              NewGroupCtrl.isNew = false;
              NewGroupCtrl.CustomerProfileList = comprofileList;
         groupprofile.Year__c = portfolio.Year__c;
                 update groupprofile;
              NewGroupCtrl.dosave();
         
         boolean hn = NewGroupCtrl.hasNext;
         boolean hp = NewGroupCtrl.hasPrevious;
         integer pn = NewGroupCtrl.pageNumber;
         
         Test.stopTest();
         
         
     }
    
    
}