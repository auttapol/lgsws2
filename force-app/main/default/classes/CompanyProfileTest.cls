@isTest
global class CompanyProfileTest {
    
    public static void setInitial()
    {
        insert new Account_Plan_Status_Code__c(name = '0001', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '1101a', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '1101b', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '2001', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '2002', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '2006', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '2007', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '2014', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '9003', Status_Message__c = 'test');
        insert new Account_Plan_Status_Code__c(name = '9005', Status_Message__c = 'test');
    }
    
    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
        TestUtils.CreateAddress();
        AccountPlanTestUtilities.getAcctPlanMode();
    }
 
     static testmethod void CompanyProfileTest(){
         setInitial();
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
        List<Account> AccountList = AccountPlanTestUtilities.createAccounts(5, 'GroupPro', 'Individual', SalesOwner.id, true, true);
         List<Account> NewAccountList = AccountPlanTestUtilities.createAccounts(5, 'GroupMaster', 'Individual', SalesOwner.id, true, true);
         List<Account> acctForCompanyProfile = new List<Account>();
         acctForCompanyProfile.add(AccountList.get(0));
         acctForCompanyProfile.add(AccountList.get(2));
         acctForCompanyProfile.add(AccountList.get(3));
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
         AcctPlanCompanyProfile__c comprofile2 = comprofileList.get(1);
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
         comprofile.Parent_Company_Info__c = NewAccountList.get(0).id;
         update comprofile;
         List<AcctPlanContribution__c> contributionlist = AccountPlanTestUtilities.createRenevueContribution(3,null, comprofile.id);
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
         AccountPlanTestUtilities.CreateTop5(2,comprofile.id);
         AccountPlanTestUtilities.CreateSupplierOrBuyer(2,comprofile.id);
         SalesOwner.Segment__c = 'SE';
                update SalesOwner;
         Test.startTest();
          PageReference comProxyPage = Page.CompanyProfileEdit;
               comProxyPage.getParameters().put('GroupID',groupprofile.id);
               comProxyPage.getParameters().put('CompanyID',comprofile.id);
               comProxyPage.getParameters().put('WalletID',wallet.id);
               comProxyPage.getParameters().put('acctKey',AccountList.get(4).id);
               Test.setCurrentPage(comProxyPage); 

             ApexPages.StandardController sc = new ApexPages.StandardController(comprofile);
             CompanyProfilesCreationEx comCtrl = new CompanyProfilesCreationEx(sc);
             comCtrl.getFiscalYear();
            comCtrl.cancel();
            comCtrl.WalletID ='Test';
            comCtrl.mode ='mode';
             comCtrl.redirect();
             List<AcctPlanSupplierOrBuyer__c> dislist = comCtrl.DistributionList;
             List<AcctPlanSupplierOrBuyer__c> buyerlist = comCtrl.BuyerList;
             List<AcctPlanSupplierOrBuyer__c> supplierList = comCtrl.SupplierList;
         
                PageReference comViewPage = Page.CompanyProfileView;
               comViewPage.getParameters().put('GroupID',groupprofile.id);
               comViewPage.getParameters().put('CompanyID',comprofile2.id);
               comViewPage.getParameters().put('WalletId',wallet.id);
               comViewPage.getParameters().put('acctKey',AccountList.get(4).id);
               Test.setCurrentPage(comViewPage); 

             ApexPages.StandardController sc2 = new ApexPages.StandardController(comprofile2);
             CompanyProfilesCreationEx comCtrl2 = new CompanyProfilesCreationEx(sc2);
         
         
         
         
                PageReference comEditPage = Page.CompanyProfileEdit;
         
                
               comEditPage.getParameters().put('AccountID',Newacct.id);
               Test.setCurrentPage(comEditPage); 
                ApexPages.StandardController  NewGroupsc= new ApexPages.StandardController(Newacct);
              CompanyProfilesCreationEx NewComCtrl = new CompanyProfilesCreationEx(NewGroupsc);
         
              NewComCtrl.cancel();
              NewComCtrl.dosave();
         
         NewComCtrl.validate();
         NewComCtrl.GotoAccountPlanClonePage();
         NewComCtrl.AccountCalloutService(Newacct);
            
         Test.stopTest();
         
         
         
         
     }
    
    
     static testmethod void NegativeTest(){
         setInitial();
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
        List<Account> AccountList = AccountPlanTestUtilities.createAccounts(5, 'GroupPro', 'Individual', SalesOwner.id, true, true);
         List<Account> NewAccountList = AccountPlanTestUtilities.createAccounts(5, 'GroupMaster', 'Individual', SalesOwner.id, true, true);
         List<Account> acctForCompanyProfile = new List<Account>();
         acctForCompanyProfile.add(AccountList.get(0));
         acctForCompanyProfile.add(AccountList.get(2));
         acctForCompanyProfile.add(AccountList.get(3));
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
         AcctPlanCompanyProfile__c comprofile2 = comprofileList.get(1);
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
         comprofile.Parent_Company_Info__c = NewAccountList.get(0).id;
         update comprofile;
         //Test.setMock(WebServiceMock.class, new TMBAccountPlanServiceProxyMock());

         
         Account Newacct = NewAccountList.get(1);
         SalesOwner.Segment__c = null;
                update SalesOwner;
         Test.startTest();
          PageReference comProxyPage = Page.CompanyProfileEdit;
               Test.setCurrentPage(comProxyPage); 

             ApexPages.StandardController sc = new ApexPages.StandardController(comprofile);
             CompanyProfilesCreationEx comCtrl = new CompanyProfilesCreationEx(sc);
         
         
                PageReference comProxyPage2 = Page.CompanyProfileEdit;
               
                comProxyPage2.getParameters().put('AccountID',NewAccountList.get(0).id);
                comProxyPage2.getParameters().put('WalletId',NewAccountList.get(0).id);
              Test.setCurrentPage(comProxyPage2); 
             ApexPages.StandardController sc2 = new ApexPages.StandardController(NewAccountList.get(0));
             CompanyProfilesCreationEx comCtrl2 = new CompanyProfilesCreationEx(sc2);
                comCtrl2.dosave();
         
        /* PageReference comProxyPage3 = Page.CompanyProfileProxy;
               
                comProxyPage3.getParameters().put('AccountID',comprofile.id);
                comProxyPage2.getParameters().put('WalletId',NewAccountList.get(0).id);
              Test.setCurrentPage(comProxyPage3); 
             ApexPages.StandardController sc3 = new ApexPages.StandardController(NewAccountList.get(0));
             CompanyProfilesCreationEx comCtrl3 = new CompanyProfilesCreationEx(sc3);
         */
         Test.stopTest();
         
         
         
         
     }
    static testmethod void TestParent (){
        setInitial();
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
        List<Account> AccountList = AccountPlanTestUtilities.createAccounts(5, 'GroupPro', 'Individual', SalesOwner.id, true, true);
         List<Account> NewAccountList = AccountPlanTestUtilities.createAccounts(5, 'GroupMaster', 'Individual', SalesOwner.id, true, true);
         List<Account> acctForCompanyProfile = new List<Account>();
         acctForCompanyProfile.add(AccountList.get(0));
         acctForCompanyProfile.add(AccountList.get(2));
         acctForCompanyProfile.add(AccountList.get(3));
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
         AcctPlanCompanyProfile__c comprofile2 = comprofileList.get(1);
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
         comprofile.Parent_Company_Info__c = NewAccountList.get(0).id;
         update comprofile;
         List<AcctPlanContribution__c> contributionlist = AccountPlanTestUtilities.createRenevueContribution(3,null, comprofile.id);
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
         AccountPlanTestUtilities.CreateTop5(2,comprofile.id);
         AccountPlanTestUtilities.CreateSupplierOrBuyer(2,comprofile.id);
         SalesOwner.Segment__c = 'SE';
                update SalesOwner;
         Test.startTest();
          PageReference comProxyPage = Page.CompanyProfileEdit;
               comProxyPage.getParameters().put('GroupID',groupprofile.id);
               comProxyPage.getParameters().put('CompanyID',comprofile.id);
               comProxyPage.getParameters().put('WalletID',wallet.id);
               comProxyPage.getParameters().put('acctKey',AccountList.get(4).id);
               Test.setCurrentPage(comProxyPage); 

             ApexPages.StandardController sc = new ApexPages.StandardController(comprofile);
             CompanyProfilesCreationEx comCtrl = new CompanyProfilesCreationEx(sc);
             comCtrl.getFiscalYear();
            comCtrl.cancel();
            comCtrl.WalletID ='Test';
            comCtrl.mode ='mode';
             comCtrl.redirect();    
        comCtrl.companyprofile = comprofile;
         comCtrl.dosave();
         
         
         Test.stopTest();
         
    }
    
    
    
    
}