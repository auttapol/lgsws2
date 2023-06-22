@isTest
global class AccountPlanCompletionExTest {
    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
        TestUtils.CreateAddress();
        AccountPlanTestUtilities.getAcctPlanMode();
    }
 
     static testmethod void AccountPlanCompletionExTest(){
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
        List<Account> AccountList = AccountPlanTestUtilities.createAccounts(1, 'GroupPro', 'Individual', SalesOwner.id, true, true);
         List<Account> acctForCompanyProfile = new List<Account>();
         acctForCompanyProfile.add(AccountList.get(0));
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
        List <group__c> groupList = AccountPlanTestUtilities.createGroupMaster(2,'PortMngtest', false, true);
        Group__c mastergroup = groupList.get(0);
         for(account acct  : AccountList){
            acct.Group__c =mastergroup.id;
        }
         
         
        update AccountList;

        List<group__c> mgroupList = new List <group__c>();
        mgroupList.add(mastergroup);
        AcctPlanGroupProfile__c groupprofile = AccountPlanTestUtilities.createGroupProfilebyGroup(mgroupList,true).get(0);
         comprofile.AcctPlanGroup__c = groupprofile.id;
         update comprofile;
         
          
        

         
         List<AcctPlanContribution__c> contributionlist = AccountPlanTestUtilities.createRenevueContribution(3,null, comprofile.id);
          contributionlist.get(0).RevenueContributionType__c = 'Contribution by service & product';
          contributionlist.get(1).RevenueContributionType__c = 'Contribution by business unit';
          contributionlist.get(2).RevenueContributionType__c = 'Contribution by regional';
         update contributionlist;
        
         AcctPlanWallet__c wallet = new AcctPlanWallet__c ();
         wallet.AcctPlanCompanyProfile__c = comprofile.id;
         wallet.EstimatedSalesAmtPerYear__c  = 50000000.00 ;
         wallet.TotalDomesticPercent__c = 0.50;
         wallet.BusinessHasSeasonal__c = 'Yes';
         wallet.HighSeasonStartMonth__c ='4';
         wallet.HighSeasonEndMonth__c = '8';
         wallet.TotalPaymentDomesticPercent__c =25;
         wallet.OperatingExpAmount__c  = 34530000;
         wallet.COGSPercent__c =50;
         wallet.FICustomerFlag__c =true;
         insert wallet;
          AcctPlanCollectionOrPaymentCurrency__c  cCurrency = new AcctPlanCollectionOrPaymentCurrency__c();
          cCurrency.CollectionPortion__c =100;
          cCurrency.Currency_Type__c = 'Collection';
          cCurrency.AcctPlanWallet__c = wallet.id;
         insert cCurrency;
         AcctPlanCollectionOrPaymentCurrency__c  pCurrency = new AcctPlanCollectionOrPaymentCurrency__c();
          pCurrency.CollectionPortion__c =100;
          pCurrency.Currency_Type__c = 'Payment';
          pCurrency.AcctPlanWallet__c = wallet.id;
         insert pCurrency;
         AcctPlanCollectionDomestic__c colDomestic = new AcctPlanCollectionDomestic__c();
         colDomestic.AcctPlanCollectionMethodDomestic__c =wallet.id;
         colDomestic.NoOfTransaction__c =100;
         colDomestic.Volume__c = 50;
         colDomestic.Label__c = '3) Bill Payment';
         insert ColDomestic;
         AcctPlanCollectionExport__c colExport = new AcctPlanCollectionExport__c();
         colExport.AcctPlanCollectionMethodExport__c = wallet.id;
         colExport.Label__c = 'B/C Term (D/A)';
         colExport.Volumn__c = 20;
         insert colExport;
         AcctPlanPaymentDomestic__c PayDomestic = new AcctPlanPaymentDomestic__c();
         PayDomestic.AcctPlanPaymentMethodDomestic__c = wallet.id;
         payDomestic.Label__c = '1) Cash';
         payDomestic.Volume__c = 20;
         insert paydomestic;
         AcctPlanPaymentImport__c payImport = new AcctPlanPaymentImport__c();
         payImport.AcctPlanPaymentMethodImport__c = wallet.id;
         payImport.Label__c ='L/C Sight';
         payImport.Volume__c = 20;
         insert payImport;

         
         //FlowHeader 
         //
         Account_Plan_Flow_Header__c fheader1 = new Account_Plan_Flow_Header__c();
         fheader1.EX_ID__C ='CD1';
         fheader1.SEQ__C = 1;
         fheader1.Method__c = 'Collection Domestic';
         fheader1.Label__c = '3) Bill Payment';
         fheader1.isActive__c = true;
         fheader1.isVolumePercent__c = true;
         
         insert fheader1;
         
         Account_Plan_Flow_Details__c fdetail1 = new Account_Plan_Flow_Details__c();
         fdetail1.Account_Plan_Flow_Header__c = fheader1.id;
         fdetail1.Volume__c  =15000000;
         fdetail1.VolumePercent__c = 50;
         fdetail1.NoOfTransaction__c = 5000;
         fdetail1.Account_Plan_Wallet__c = wallet.id;
         insert fdetail1;
         
         
         Account_Plan_Flow_Header__c fheader2 = new Account_Plan_Flow_Header__c();
         fheader2.EX_ID__C ='PD1';
         fheader2.SEQ__C = 1;
         fheader2.Method__c = 'Payment Domestic';
         fheader2.Label__c = '3.1 Bahtnet';
         fheader2.isActive__c = true;
         fheader2.isVolumePercent__c = true;
         
         insert fheader2;
         
         
         
         
        
         
         Account_Plan_Flow_Details__c fdetail2 = new Account_Plan_Flow_Details__c();
         fdetail2.Account_Plan_Flow_Header__c = fheader2.id;
         fdetail2.Volume__c  =15000000;
         fdetail2.VolumePercent__c = 50;
         fdetail2.NoOfTransaction__c = 5000;
         fdetail2.Account_Plan_Wallet__c = wallet.id;
         insert fdetail2;
         
         
          Account_Plan_Flow_Header__c fheader3 = new Account_Plan_Flow_Header__c();
         fheader3.EX_ID__C ='PI1';
         fheader3.SEQ__C = 1;
         fheader3.Method__c = 'Payment Import';
         fheader3.Label__c = 'L/C Term';
         fheader3.isActive__c = true;
         fheader3.isVolumePercent__c = true;
         
         insert fheader3;
         
         Account_Plan_Flow_Details__c fdetail3 = new Account_Plan_Flow_Details__c();
         fdetail3.Account_Plan_Flow_Header__c = fheader3.id;
         fdetail3.Volume__c  =15000000;
         fdetail3.VolumePercent__c = 50;
         fdetail3.NoOfTransaction__c = 5000;
         fdetail3.Account_Plan_Wallet__c = wallet.id;
         insert fdetail3;
         
         
         
         
         
         AcctPlanWorkingCapital__c wCap = new AcctPlanWorkingCapital__c();
         wcap.AcctPlanWallet__c = wallet.id;
         wcap.RecordType__c = 'Normal Period';
         wcap.AvgARDays__c = 14;
         wcap.AvgInvDays__c =14;
         wcap.NimcPercent__c = 0.5;
         wcap.FrontEndFee__c = 500;
         
         insert wcap;
         AcctPlanQuestionnaire__c questionnaire = new AcctPlanQuestionnaire__c();
         questionnaire.Answer__c = 'Yes';
         questionnaire.AcctPlanWallet__c = wallet.id;
         questionnaire.Segment__c ='Credit life insurance';
         insert questionnaire;
         AccountPlanTestUtilities.CreateTop5(2,comprofile.id);
         AccountPlanTestUtilities.CreateSupplierOrBuyer(2,comprofile.id);

         SalesOwner.Segment__c = 'SE';
                update SalesOwner;
        
         
            
            AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(comprofile.id);
            wallet.BusinessHasSeasonal__c = 'No';
            update wallet;
            AccountPlanCompletionEx completionEx2 = new AccountPlanCompletionEx(comprofile.id);
            AccountPlanCompletionEx.MandatoryWrapper mandatoryWrapper1 = new AccountPlanCompletionEx.MandatoryWrapper();
         
         
         
         
         List<Account_Plan_Mandatory__c> MandatoryList = new List<Account_Plan_Mandatory__c>();
         
         for(Integer i=1;i<=57;i++){
             Account_Plan_Mandatory__c manda = new Account_Plan_Mandatory__c();
         manda.SEQ__c = i;
         manda.Domain__C = 'Test Domain';
         manda.Section__c = 'Test Section';
         manda.Required_Field__c = 'RequiredField';
         manda.Condition__c = 'Condition';
             
             MandatoryList.add(manda);
         }
         insert MandatoryList;
            
          Account_Plan_Mandatory__c manda1 = MandatoryList.get(1);
        
         manda1.Domain__C = 'Step 1 Group Company';
         manda1.Section__c = 'Group of Company Profile';
         manda1.Required_Field__c = 'Group Name';
         manda1.Condition__c = 'Mandatory Field';
         
         update  manda1;
         mandatoryWrapper1.Mandatory = manda1;
         mandatoryWrapper1.isHasValue = true;
         String styleClass = mandatoryWrapper1.styleClass;
         String DomainStyle = mandatoryWrapper1.DomainStyle;
         
          Account_Plan_Mandatory__c manda2 = MandatoryList.get(14);
         
         manda2.Domain__C = 'Step 2 Customer Profile';
         manda2.Section__c = 'General Information';
         manda2.Required_Field__c = 'Name';
         manda2.Condition__c = 'Mandatory Field';
         update manda2;
         
         mandatoryWrapper1.Mandatory = manda2;
         mandatoryWrapper1.isHasValue = true;
         String styleClass2 = mandatoryWrapper1.styleClass;
         String DomainStyle2 = mandatoryWrapper1.DomainStyle;
         
          Account_Plan_Mandatory__c manda3 = MandatoryList.get(18);
         
         manda3.Domain__C = 'Step 3 Wallet By Domain - Domain I';
         manda3.Section__c = 'General Information';
         manda3.Required_Field__c = 'Name';
         manda3.Condition__c = 'Mandatory Field';
         update manda3;
         mandatoryWrapper1.Mandatory = manda3;
         mandatoryWrapper1.isHasValue = true;
         String styleClass3 = mandatoryWrapper1.styleClass;
         String DomainStyle3 = mandatoryWrapper1.DomainStyle;
         
          Account_Plan_Mandatory__c manda4 = MandatoryList.get(54);

         manda4.Domain__C = 'Step 4 Product Strategy';
         manda4.Section__c = 'Product Strategy';
         manda4.Required_Field__c = 'Name';
         manda4.Condition__c = 'Mandatory Field';
         update manda4;
         mandatoryWrapper1.Mandatory = manda4;
         mandatoryWrapper1.isHasValue = true;
         String styleClass4 = mandatoryWrapper1.styleClass;
         String DomainStyle4 = mandatoryWrapper1.DomainStyle;
         
          PageReference comProxyPage = Page.AccountPlanMandatory;
               comProxyPage.getParameters().put('GroupID',groupprofile.id);
               comProxyPage.getParameters().put('CompanyID',comprofile.id);
               comProxyPage.getParameters().put('WalletID',wallet.id);
               comProxyPage.getParameters().put('acctKey',AccountList.get(0).id);
               Test.setCurrentPage(comProxyPage); 
         
         
          Test.startTest();
        
              AccountPlanCompletionEx completionEx1 = new AccountPlanCompletionEx();
            AccountPlanCompletionEx completionExCompany = new AccountPlanCompletionEx(comprofile.id);
         

         
         Test.stopTest();
         
         
         
         
     }
    
    
    
    
    
}