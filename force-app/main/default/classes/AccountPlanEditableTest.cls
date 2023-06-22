@isTest
global class AccountPlanEditableTest {
    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
        TestUtils.CreateAddress();
        AccountPlanTestUtilities.getAcctPlanMode();
        AccountPlanWalletTestUtilities.createStandardFee();
        AccountPlanWalletTestUtilities.createBanks();
        AccountPlanWalletTestUtilities.createCurrencies();
        AccountPlanTestUtilities.AccountPlanStatusCode();
         List<sObject> ls = 
            Test.loadData(AcctPlan_Questionnaire_Template__c.sObjectType /*API Name*/, 'AcctPlanQuestionnaireTemplate' /*Static Resource Name*/);
   
         }
    
    static testmethod void RenevueContributionEditable(){
      
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
          List<Account> AccountList = AccountPlanTestUtilities.createAccounts(1, 'GroupPro', 'Individual', SalesOwner.id, true, true);
       List<Account> acctForCompanyProfile = new List<Account>();
        acctForCompanyProfile.add(AccountList.get(0));
        system.runAs(SalesOwner){
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
                 
        AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
        
        
        AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
        AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
        AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);
                PageReference revenueEditable = Page.RevenueContributionEditable;
               revenueEditable.getParameters().put('CompanyID',comprofile.id);
               
               revenueEditable.getParameters().put('WalletID',AcctPlanwallet.id);
               revenueEditable.getParameters().put('mode','default');
               Test.setCurrentPage(revenueEditable); 
            ApexPages.StandardController stdController = new ApexPages.StandardController(comprofile);
             RevenueContributionEditatble revenueEdittable = new RevenueContributionEditatble(stdController);
              revenueEdittable.getChildren();
              revenueEdittable.initChildRecord();
            
            AcctPlanContribution__c contribute = new AcctPlanContribution__c();
            contribute.Account_Plan_Company_Profile__c = comprofile.id;
            contribute.EBITDAContributionPercent__c = 10;
            contribute.RevenueContributionPercent__c = 10;
            contribute.RevenueContributionType__c = 'Contribution by service & product';
            AcctPlanContribution__c contribute2 = new AcctPlanContribution__c();
            contribute2.Account_Plan_Company_Profile__c = comprofile.id;
            contribute2.EBITDAContributionPercent__c = 10;
            contribute2.RevenueContributionPercent__c = 10;
            contribute2.RevenueContributionType__c = 'Contribution by service & product';
            revenueEdittable.getChildren().add(contribute);
            revenueEdittable.getChildren().add(contribute2);
              revenueEdittable.insertRecord();
            
            AcctPlanContribution__c contribute3 = new AcctPlanContribution__c();
            contribute3.Account_Plan_Company_Profile__c = comprofile.id;
            contribute3.EBITDAContributionPercent__c = 90;
            contribute3.RevenueContributionPercent__c = 1;
            contribute3.RevenueContributionType__c = 'Contribution by service & product';
            revenueEdittable.getChildren().add(contribute3);
              revenueEdittable.insertRecord();
            contribute3.EBITDAContributionPercent__c = 101;
            revenueEdittable.insertRecord();
             contribute3.RevenueContributionPercent__c = 101;
            revenueEdittable.insertRecord();
            
            
            revenueEditable.getParameters().put('GroupID',AcctPlanwallet.id);
            ApexPages.StandardController stdController2 = new ApexPages.StandardController(comprofile);
             RevenueContributionEditatble revenueEdittable2 = new RevenueContributionEditatble(stdController2);
            
            }
    
    }

    static testmethod void Top5Editable(){
      
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
          List<Account> AccountList = AccountPlanTestUtilities.createAccounts(1, 'GroupPro', 'Individual', SalesOwner.id, true, true);
       List<Account> acctForCompanyProfile = new List<Account>();
        acctForCompanyProfile.add(AccountList.get(0));
        system.runAs(SalesOwner){
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
                 
        AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
        
        
        AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
        AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
        AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);
                PageReference Top5Editable = Page.Top5Editable;
               Top5Editable.getParameters().put('CompanyID',comprofile.id);
               
               Top5Editable.getParameters().put('WalletID',AcctPlanwallet.id);
               Top5Editable.getParameters().put('mode','default');
               Top5Editable.getParameters().put('Segment','Buyer');
               Test.setCurrentPage(Top5Editable); 
            ApexPages.StandardController stdController = new ApexPages.StandardController(comprofile);
             Top5Editable top5 = new Top5Editable(stdController);
              top5.getChildren();
              top5.initChildRecord();
              top5.insertRecord();
            Account_Plan_Company_Top_5__c topbuyer = new Account_Plan_Company_Top_5__c();
            topbuyer.Account_Plan_Company_Profile__c = comprofile.id;
            topbuyer.Customer_Name__c = 'test';
            topbuyer.Percent__c = 50;
           top5.getChildren().add(topbuyer);
           top5.insertRecord();
            
            Account_Plan_Company_Top_5__c topbuyer2 = new Account_Plan_Company_Top_5__c();
            topbuyer2.Account_Plan_Company_Profile__c = comprofile.id;
            topbuyer2.Customer_Name__c = 'test';
            topbuyer2.Percent__c = 51;
           top5.getChildren().add(topbuyer2);
           top5.insertRecord();
            
        
        
            
            PageReference Top5Editable1 = Page.Top5Editable;
               Test.setCurrentPage(Top5Editable1); 
            Top5Editable1.getParameters().put('Segment','Buyer');
            ApexPages.StandardController stdController1 = new ApexPages.StandardController(comprofile);
             Top5Editable top52 = new Top5Editable(stdController1);
             top52.initChildRecord();
            
        }
        
        
        
     
        
    
    }    
    
    static testmethod void SupplierOrBuyer(){
      
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
          List<Account> AccountList = AccountPlanTestUtilities.createAccounts(1, 'GroupPro', 'Individual', SalesOwner.id, true, true);
       List<Account> acctForCompanyProfile = new List<Account>();
        acctForCompanyProfile.add(AccountList.get(0));
        system.runAs(SalesOwner){
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
                 
        AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
        
        
        AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
        AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
        AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);
                PageReference supOrBuy = Page.SupplierOrBuyerEditable;
               supOrBuy.getParameters().put('CompanyID',comprofile.id);
               
               supOrBuy.getParameters().put('WalletID',AcctPlanwallet.id);
               supOrBuy.getParameters().put('mode','default');
               supOrBuy.getParameters().put('segment','Majorraw');
               Test.setCurrentPage(supOrBuy); 
            ApexPages.StandardController stdController = new ApexPages.StandardController(comprofile);
             SupplierOrBuyerEditable supOrBuyCtrl = new SupplierOrBuyerEditable(stdController);
              supOrBuyCtrl.getChildren();
              supOrBuyCtrl.getCurrency();
              supOrBuyCtrl.initChildRecord();
              supOrBuyCtrl.insertRecord();
            AcctPlanSupplierOrBuyer__c supOrBuyitem1 = new AcctPlanSupplierOrBuyer__c();
            supOrBuyitem1.Account_Plan_Company_Profile__c = comprofile.id;
            supOrBuyitem1.Segment__c = 'Major raw material';
            supOrBuyItem1.Percent__c = 90;
           supOrBuyCtrl.getChildren().add(supOrBuyitem1);
           supOrBuyCtrl.insertRecord();
            AcctPlanSupplierOrBuyer__c supOrBuyitem2 = new AcctPlanSupplierOrBuyer__c();
            supOrBuyitem2.Account_Plan_Company_Profile__c = comprofile.id;
            supOrBuyitem2.Segment__c = 'Major raw material';
            supOrBuyItem2.Percent__c = 90;
           supOrBuyCtrl.getChildren().add(supOrBuyitem2);
            supOrBuyCtrl.insertRecord();
            
        
           
            
            PageReference supOrBuy2 = Page.SupplierOrBuyerEditable;
               
               supOrBuy2.getParameters().put('WalletID',AcctPlanwallet.id);
               supOrBuy2.getParameters().put('mode','default');
               supOrBuy2.getParameters().put('segment','Distribution');
               Test.setCurrentPage(supOrBuy2); 
            ApexPages.StandardController stdController2 = new ApexPages.StandardController(comprofile);
             SupplierOrBuyerEditable supOrBuyCtrl2 = new SupplierOrBuyerEditable(stdController2);
            supOrBuyCtrl2.initChildRecord();
            
        }
        
        
        
     
        
    
    }   
    
    static testmethod void CurrencyEdittable(){
      
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
          List<Account> AccountList = AccountPlanTestUtilities.createAccounts(1, 'GroupPro', 'Individual', SalesOwner.id, true, true);
       List<Account> acctForCompanyProfile = new List<Account>();
        acctForCompanyProfile.add(AccountList.get(0));
        system.runAs(SalesOwner){
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
                 
        AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
        
        
        AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
        AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
        AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);
                PageReference currencypage = Page.CurrencyEdittable;
               currencypage.getParameters().put('CompanyID',comprofile.id);
               currencypage.getParameters().put('type','Collection');
               currencypage.getParameters().put('WalletID',AcctPlanwallet.id);
               Test.setCurrentPage(currencypage); 
            ApexPages.StandardController stdController = new ApexPages.StandardController(comprofile);
             CurrencyEdittableController currencyEditCon = new CurrencyEdittableController(stdController);
              currencyEditCon.getChildren();
              currencyEditCon.initChildRecord();
              
              currencyEditCon.refresh();
             currencyEditCon.checkportion();
            currencyEditCon.isCollection = false;
            currencyEditCon.checkportion();
           
            AcctPlanCollectionOrPaymentCurrency__c  payment = new  AcctPlanCollectionOrPaymentCurrency__c();
        payment.AcctPlanWallet__c  = AcctPlanwallet.id;
        payment.Currency_Type__c = 'Payment';
        payment.PaymentPortion__c = 50;
        currencyEditCon.getChildren().add(payment);   
            currencyEditCon.checkportion();
        }
        
        
        
     
        
    
    }   
    
    static testmethod void ForeignTransactionEdittable(){
      
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
          List<Account> AccountList = AccountPlanTestUtilities.createAccounts(1, 'GroupPro', 'Individual', SalesOwner.id, true, true);
       List<Account> acctForCompanyProfile = new List<Account>();
        acctForCompanyProfile.add(AccountList.get(0));
        system.runAs(SalesOwner){
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
                 
        AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
        
        
        AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
        AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
        AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);
                PageReference foreignPage = Page.ForeignTransactionEdittable;
               foreignPage.getParameters().put('CompanyID',comprofile.id);
              
               foreignPage.getParameters().put('WalletID',AcctPlanwallet.id);
               Test.setCurrentPage(foreignPage); 
            ApexPages.StandardController stdController = new ApexPages.StandardController(comprofile);
             ForeignTransactionEdittable foreignTran = new ForeignTransactionEdittable(stdController);
              foreignTran.getChildren();
              foreignTran.initChildRecord();
                foreignTran.checkportion();
                foreignTran.refresh();
            
            AcctPlanForeignTrans__c foreign = new AcctPlanForeignTrans__c();
            foreign.AcctPlanWallet__c = AcctPlanwallet.id;
            foreign.HedgingRatio__c = 50;
            foreign.CCY__c = AccountPlanWalletTestUtilities.jpycurrency.id;
            foreignTran.getChildren().add(foreign);

            foreignTran.checkportion();   
            
             AcctPlanForeignTrans__c foreign1 = new AcctPlanForeignTrans__c();
            foreign1.AcctPlanWallet__c = AcctPlanwallet.id;
            foreign1.HedgingRatio__c = 0.1;           
            foreign1.CCY__c = AccountPlanWalletTestUtilities.jpycurrency.id;
            foreignTran.getChildren().add(foreign1);
            
            foreignTran.checkportion();
            
        List<AcctPlanCollectionOrPaymentCurrency__c> currencyList = new List<AcctPlanCollectionOrPaymentCurrency__c>();
        AcctPlanCollectionOrPaymentCurrency__c  collection = new  AcctPlanCollectionOrPaymentCurrency__c();
        collection.AcctPlanWallet__c  = AcctPlanwallet.id;
        collection.Currency_Type__c = 'Collection';
        collection.CollectionPortion__c = 10;
        collection.CCY__c = AccountPlanWalletTestUtilities.jpycurrency.id;
        currencyList.add(collection);
            
            Currency__c gbpcurrency = new Currency__c();
        gbpcurrency.Name ='GBP';
        gbpcurrency.ShortName__c ='GBP';
        gbpcurrency.FlagForAcctPlan__c = true;
        insert gbpcurrency; 
        AcctPlanCollectionOrPaymentCurrency__c  payment = new  AcctPlanCollectionOrPaymentCurrency__c();
        payment.AcctPlanWallet__c  = AcctPlanwallet.id;
        payment.Currency_Type__c = 'Payment';
        payment.PaymentPortion__c = 10;
        payment.CCY__c =gbpcurrency.id;
        currencyList.add(payment);
        
        insert currencyList;
            ApexPages.StandardController stdController2 = new ApexPages.StandardController(comprofile);
             ForeignTransactionEdittable foreignTran2 = new ForeignTransactionEdittable(stdController2);
             
        }
 
    
    }   
    
    static testmethod void CreditFacilityEdittable(){
      
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
          List<Account> AccountList = AccountPlanTestUtilities.createAccounts(1, 'GroupPro', 'Individual', SalesOwner.id, true, true);
       List<Account> acctForCompanyProfile = new List<Account>();
        acctForCompanyProfile.add(AccountList.get(0));
        system.runAs(SalesOwner){
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
                 
        AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
        
        
        AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
        AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
        AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);
        List<AcctPlanWalletCreditFacility__c> creditlist = AccountPlanWalletTestUtilities.CreateCreditFacility(AcctPlanwallet.id);
                PageReference creditPage = Page.CreditFacilityEditable;
               creditPage.getParameters().put('CompanyID',comprofile.id);
               creditPage.getParameters().put('type','International');
               creditPage.getParameters().put('WalletID',AcctPlanwallet.id);
               Test.setCurrentPage(creditPage); 
            ApexPages.StandardController stdController = new ApexPages.StandardController(acctPlanWallet);
             EditableCreditFacility creditfacility = new EditableCreditFacility(stdController);
             creditfacility.initChildRecord();
             creditfacility.getBanks();
             creditfacility.getChildren().addAll(creditlist);
             creditfacility.checkunique();
             
            
            PageReference creditPage2 = Page.CreditFacilityEditable;
               creditPage2.getParameters().put('CompanyID',comprofile.id);
               creditPage2.getParameters().put('type','Domestic');
               creditPage2.getParameters().put('WalletID',AcctPlanwallet.id);
               Test.setCurrentPage(creditPage2); 
            ApexPages.StandardController stdController2 = new ApexPages.StandardController(acctPlanWallet);
             EditableCreditFacility creditfacility2 = new EditableCreditFacility(stdController2);
             creditfacility2.initChildRecord();
             creditfacility2.getChildren().addAll(creditlist);
             creditfacility2.checkunique();
        }
 
    
    }   
    
    static testmethod void LongtermLoanEdittable(){
      
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
          List<Account> AccountList = AccountPlanTestUtilities.createAccounts(1, 'GroupPro', 'Individual', SalesOwner.id, true, true);
       List<Account> acctForCompanyProfile = new List<Account>();
        acctForCompanyProfile.add(AccountList.get(0));
        system.runAs(SalesOwner){
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
                 
        AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
        
        
        AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
        AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
        AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);
        List<AcctPlanWalletCreditFacility__c> creditlist = AccountPlanWalletTestUtilities.CreateCreditFacility(AcctPlanwallet.id);
        List<AcctPlanExistingLongTermLoan__c> longtermlist = AccountPlanWalletTestUtilities.CreateLongTermLoan(AcctPlanwallet.id);    
                PageReference longtermPage = Page.LongTermLoanEdittable;
               longtermPage.getParameters().put('CompanyID',comprofile.id);
               
               longtermPage.getParameters().put('WalletID',AcctPlanwallet.id);
               Test.setCurrentPage(longtermPage); 
            ApexPages.StandardController stdController = new ApexPages.StandardController(acctPlanWallet);
             EditableLongTermLoan longtermloan = new EditableLongTermLoan(stdController);
             longtermloan.initChildRecord();
             longtermloan.getBanks();
             longtermloan.getCurrency();
             
             longtermloan.getChildrenExpenditure();
             longtermloan.insertRecord();
            
            longtermPage.getParameters().put('type','Existing');
             ApexPages.StandardController stdController2 = new ApexPages.StandardController(acctPlanWallet);
             EditableLongTermLoan longtermloan2 = new EditableLongTermLoan(stdController2);
             longtermloan2.initChildRecord();
             longtermloan2.getBanks();
             longtermloan2.getCurrency();
             
             longtermloan2.getChildrenLongTermLoan();
             longtermloan2.insertRecord();
             
            
           
        }
 
    
    }   
    
    
     static testmethod void DomainIVQuestionnaireEdittable(){
      
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
          List<Account> AccountList = AccountPlanTestUtilities.createAccounts(1, 'GroupPro', 'Individual', SalesOwner.id, true, true);
       List<Account> acctForCompanyProfile = new List<Account>();
        acctForCompanyProfile.add(AccountList.get(0));
        system.runAs(SalesOwner){
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
                 
        AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
        
        
        AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
        AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
        AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);   
                PageReference domaivIVpage = Page.DomainIVQuestionnaireEdittable;
               domaivIVpage.getParameters().put('CompanyID',comprofile.id);
               domaivIVpage.getParameters().put('type','behavior');
               domaivIVpage.getParameters().put('WalletID',AcctPlanwallet.id);
               Test.setCurrentPage(domaivIVpage); 
            ApexPages.StandardController stdController = new ApexPages.StandardController(acctPlanWallet);
             DomainIVQuestionnaireEdittableCtrl domainIVCtrl = new DomainIVQuestionnaireEdittableCtrl(stdController);
             domainIVCtrl.initChildRecord();
             domainIVCtrl.refresh();
             domainIVCtrl.checkportion();
             domainIVCtrl.getChildren();
             domainIVCtrl.initChildRecord();
             domainIVCtrl.checkportion();
             
            
            
            
                       List<AcctPlan_Questionnaire_Template__c> QTemplateList = AccountPlanWalletUtilities.queryQuestionnaireTemplate('Domain IV');
                        Map<String,List<AcctPlanQuestionnaire__c>> QuestionnaireMap = new Map<String,List<AcctPlanQuestionnaire__c>>();
                        Map<String,List< AcctPlan_Questionnaire_Template__c> > QTemplateMap = new Map<String,List< AcctPlan_Questionnaire_Template__c> >();
                      
                      
                         for(AcctPlan_Questionnaire_Template__c QT : QTemplateList){
                                 String Segment = QT.Segment__c;
                                 if(QTemplateMap.containsKey(Segment)){
                                     QTemplateMap.get(Segment).add(qt);
                                 }else{
                                    List< AcctPlan_Questionnaire_Template__c>  QTList = new List< AcctPlan_Questionnaire_Template__c>();
                                     QTList.add(qt);
                                     QTemplateMap.put(Segment,QTList);
                                     
                                 }
                                 
                             }
                      List<AcctPlanQuestionnaire__c> qlist = new List<AcctPlanQuestionnaire__c>();
                      for(AcctPlan_Questionnaire_Template__c qt : QTemplateMap.get('FX Hedging experience')){
                          AcctPlanQuestionnaire__c question = new AcctPlanQuestionnaire__c ();
                          question.SEQ__c = qt.SEQ__c;
                          question.Question_TH__c = qt.Question_TH__C;
                          question.Question__c = qt.Question__c;
                          question.isStandard__c = true;
                          question.Opportunity__c = qt.Opportunity__c;
                          question.Segment__c = 'FX Hedging experience';
                          question.AcctPlanWallet__c = acctplanWallet.id;
                          question.Product_Label__c = qt.Product_Label__c;
                          question.Sub_Domain__c = qt.Sub_Domain__c;
                          question.Sub_Segment_SEQ__c = qt.Sub_Segment_SEQ__c;
                          question.Answer_Type__c = qt.Answer_Field_Type__c;
                          qlist.add(question);
                      }
                    insert qlist;
                   domaivIVpage.getParameters().put('type','exp');   
             ApexPages.StandardController stdController2 = new ApexPages.StandardController(acctPlanWallet);
             DomainIVQuestionnaireEdittableCtrl domainIVCtrl2 = new DomainIVQuestionnaireEdittableCtrl(stdController2);
           
             domaivIVpage.getParameters().put('type','risk');   
             ApexPages.StandardController stdController3 = new ApexPages.StandardController(acctPlanWallet);
             DomainIVQuestionnaireEdittableCtrl domainIVCtrl3 = new DomainIVQuestionnaireEdittableCtrl(stdController3);
           
        }
 
    
    }  
    
    
     static testmethod void ASFeeEdittable(){
      
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
          List<Account> AccountList = AccountPlanTestUtilities.createAccounts(1, 'GroupPro', 'Individual', SalesOwner.id, true, true);
       List<Account> acctForCompanyProfile = new List<Account>();
        acctForCompanyProfile.add(AccountList.get(0));
        system.runAs(SalesOwner){
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
                 
        AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
        
            
        
        AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
        AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
        AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);
                PageReference currencypage = Page.ASFeeEdittable;
               currencypage.getParameters().put('CompanyID',comprofile.id);
               currencypage.getParameters().put('type','Collection');
               currencypage.getParameters().put('WalletID',AcctPlanwallet.id);
                currencypage.getParameters().put('TypeOfFee','Fixed');
               Test.setCurrentPage(currencypage); 
            ApexPages.StandardController stdController = new ApexPages.StandardController(comprofile);
             EditableASFee affeeCon = new EditableASFee(stdController);
              affeeCon.getChildren();
            
            Account_Plan_AS_Fee__c affee4 = (Account_Plan_AS_Fee__c)affeeCon.initChildRecord();
             affee4.AS_Product_Service__c = '2)';
             affee4.Type_of_Fee__c ='Fixed';
             affee4.AS_Fee__c =50;
             affee4.Net_Asset_Value__c = 15000;
             affee4.Fixed_AS_Fee__c  =50000;
             affee4.Account_Plan_Wallet__c = AcctPlanwallet.id;
             insert affee4;
            
            
             Account_Plan_AS_Fee__c affee2 = (Account_Plan_AS_Fee__c)affeeCon.initChildRecord();
             affee2.AS_Product_Service__c = '1)';
             affee2.Type_of_Fee__c ='Fixed';
             affee2.Fixed_AS_Fee__c = 15000;
             affee2.AS_Fee__c =50;
             affee2.Fixed_AS_Fee__c  =50000;
             affee2.Account_Plan_Wallet__c = AcctPlanwallet.id;
            insert affee2;
             affeeCon.childList.add(affee2);
            
            Account_Plan_AS_Fee__c affee3 = (Account_Plan_AS_Fee__c)affeeCon.initChildRecord();
             affee3.AS_Product_Service__c = '2)';
             affee3.Type_of_Fee__c ='Percent';
             affee3.AS_Fee__c =50;
             affee3.Net_Asset_Value__c = 15000;
             affee3.Fixed_AS_Fee__c  =50000;
             affee3.Account_Plan_Wallet__c = AcctPlanwallet.id;
            insert affee3;
             affeeCon.childList.add(affee3);
            
             Account_Plan_AS_Fee__c affee6 = (Account_Plan_AS_Fee__c)affeeCon.initChildRecord();
             affee6.AS_Product_Service__c = '3)';
             affee6.Type_of_Fee__c ='Fixed';
             affee6.AS_Fee__c =50;
             affee6.Net_Asset_Value__c = 15000;
             affee6.Fixed_AS_Fee__c  =50000;
             affee6.Account_Plan_Wallet__c = AcctPlanwallet.id;
            insert affee6;
             affeeCon.childList.add(affee6);
            
             Account_Plan_AS_Fee__c affee5 = (Account_Plan_AS_Fee__c)affeeCon.initChildRecord();
             affee5.AS_Product_Service__c = '4)';
             affee5.Type_of_Fee__c ='Percent';
             affee5.AS_Fee__c =50;
             affee5.Net_Asset_Value__c = 15000;
             affee5.Fixed_AS_Fee__c  =50000;
             affee5.Account_Plan_Wallet__c = AcctPlanwallet.id;
            insert affee5;
             affeeCon.childList.add(affee5);
            
             Account_Plan_AS_Fee__c affee7 = (Account_Plan_AS_Fee__c)affeeCon.initChildRecord();
             affee7.AS_Product_Service__c = '5)';
             affee7.Type_of_Fee__c ='Fixed';
             affee7.AS_Fee__c =50;
             affee7.Net_Asset_Value__c = 15000;
             affee7.Fixed_AS_Fee__c  =50000;
             affee7.Account_Plan_Wallet__c = AcctPlanwallet.id;
             insert affee7;
             affeeCon.childList.add(affee7);
              
              affeeCon.changeTypeOfFee();
              affeeCon.refresh();
              affeeCon.getParameterTypeofFee();
            
              affeeCon.insertRecord();
            
            
             
           
           
          
        }
        
        
        
     
        
    
    }   
}