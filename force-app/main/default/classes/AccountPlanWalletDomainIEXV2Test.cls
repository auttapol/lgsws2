@isTest
global class AccountPlanWalletDomainIEXV2Test {
    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
        TestUtils.CreateAddress();
        AccountPlanTestUtilities.getAcctPlanMode();
        AccountPlanWalletTestUtilities.createStandardFee();
        AccountPlanWalletTestUtilities.createBanks();
        AccountPlanTestUtilities.AccountPlanStatusCode();
         }
    
    static testmethod void InitiateWallet(){
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
          List<Account> AccountList = AccountPlanTestUtilities.createAccounts(1, 'GroupPro', 'Individual', SalesOwner.id, true, true);
       List<Account> acctForCompanyProfile = new List<Account>();
        acctForCompanyProfile.add(AccountList.get(0));
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
        
         AcctPlanWallet__c wallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, false);
        
        
               PageReference walletInitiatepage = Page.AccountPlanWalletInitiate;
               walletInitiatepage.getParameters().put('CompanyID',comprofile.id);
              // walletInitiatepage.getParameters().put('GroupID','Test');
               Test.setCurrentPage(walletInitiatepage); 

             ApexPages.StandardController sc = new ApexPages.StandardController(comprofile);
             AccountPlanWalletDomainIExV2 walletIEx = new AccountPlanWalletDomainIExV2(sc);
        walletIEX.CalculateWallet();
        walletIEx.insertWallet();
             walletIEx.tempEstimatedSalesAmtPerYear = 10000;
             walletIEx.tempEstimatedSalesAmtPerYearStr = '10000';
             walletIEx.tempOperatingExpAmountStr = '10000';
             
             walletIEx.tempTotalDomesticPercent = 101;
             walletIEx.tempTotalDomesticPercentStr = '101';
        walletIEX.CalculateWallet();
        walletIEx.insertWallet();
             walletIEx.tempTotalDomesticPercent = 30;
             walletIEx.tempTotalDomesticPercentStr = '30';
        walletIEX.CalculateWallet();
        walletIEx.insertWallet();
             walletIEx.tempCOGSPercent = 30;
             walletIEx.tempCOGSPercentStr = '30';
            walletIEx.tempTotalPaymentDomesticPercent = 150;
            walletIEx.tempTotalPaymentDomesticPercentStr = '150';
        walletIEX.CalculateWallet();
        walletIEx.insertWallet();
             walletIEx.tempTotalPaymentDomesticPercent = 50;
            walletIEx.tempTotalPaymentDomesticPercentStr = '50';
              walletIEX.CalculateWallet();

        //
        //
        walletIEX.tempOperatingExpAmountStr ='';
         walletIEX.CalculateWallet();
        walletIEx.tempTotalDomesticPercentStr = '101';
        
         walletIEX.CalculateWallet();
        walletIEx.tempCOGSPercentStr = '101';
        
         walletIEX.CalculateWallet();
        boolean Ccurrency =  walletIEx.isCollectCurrencyNull;
        boolean Pcurrency =  walletIEx.isPaymentCurrencyNull;
             walletIEx.cancel();
             walletIEx.initiateWallet();
             walletIEx.insertWallet();
             walletIEx.tempEstimatedSalesAmtPerYear =10000;
             walletIEX.tempTotalDomesticPercent = 50;
             walletIEX.tempCOGSPercent = 30;
             walletIEX.tempOperatingExpAmount =50000;
             walletIEX.tempTotalPaymentDomesticPercent = 30;
             walletIEx.insertWallet();
             walletIEx.Save();
             walletIEx.getShareBanks();
             walletIEX.editpage();
        
        
        Test.startTest();
        AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
        AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
        AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
        
        
           
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
        
         AcctPlanCollectionDomestic__c colDomestic = new AcctPlanCollectionDomestic__c();
         colDomestic.AcctPlanCollectionMethodDomestic__c =AcctPlanwallet.id;
         colDomestic.NoOfTransaction__c =100;
         colDomestic.Volume__c = 50;
         colDomestic.Label__c = '3) Bill Payment';
         insert ColDomestic;
         
         Account_Plan_Flow_Details__c fdetail1 = new Account_Plan_Flow_Details__c();
         fdetail1.Account_Plan_Flow_Header__c = fheader1.id;
         fdetail1.Volume__c  =15000000;
         fdetail1.VolumePercent__c = 50;
         fdetail1.NoOfTransaction__c = 5000;
         fdetail1.Account_Plan_Wallet__c = AcctPlanwallet.id;
         insert fdetail1;
         
         Account_Plan_Flow_Header__c fheader21 = new Account_Plan_Flow_Header__c();
         fheader21.EX_ID__C ='PD09';
         fheader21.SEQ__C = 1;
         fheader21.Method__c = 'Payment Domestic';
         fheader21.Label__c = '3) Fund Transfer';
         fheader21.isActive__c = true;
         fheader21.isVolumePercent__c = true;
         
         insert fheader21;
         
         Account_Plan_Flow_Header__c fheader2 = new Account_Plan_Flow_Header__c();
         fheader2.EX_ID__C ='PD1';
         fheader2.SEQ__C = 1;
         fheader2.Account_Plan_Flow_Header__c = fheader21.id;
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
         fdetail2.Account_Plan_Wallet__c = AcctPlanwallet.id;
         insert fdetail2;
         
         
          Account_Plan_Flow_Header__c fheader3 = new Account_Plan_Flow_Header__c();
         fheader3.EX_ID__C ='PI1';
         fheader3.SEQ__C = 1;
         fheader3.Method__c = 'Payment Import';
         fheader3.Label__c = 'L/C Term';
         fheader3.isActive__c = true;
         fheader3.isVolumePercent__c = true;
         
         insert fheader3;
        
        AcctPlanCollectionExport__c colExport = new AcctPlanCollectionExport__c();
         colExport.AcctPlanCollectionMethodExport__c = AcctPlanwallet.id;
         colExport.Label__c = 'L/C Term';
         colExport.Volumn__c = 20;
         insert colExport;
         
         Account_Plan_Flow_Details__c fdetail3 = new Account_Plan_Flow_Details__c();
         fdetail3.Account_Plan_Flow_Header__c = fheader3.id;
         fdetail3.Volume__c  =15000000;
         fdetail3.VolumePercent__c = 50;
         fdetail3.NoOfTransaction__c = 5000;
         fdetail3.Account_Plan_Wallet__c = AcctPlanwallet.id;
         insert fdetail3;
        
        AcctPlanPaymentDomestic__c PayDomestic = new AcctPlanPaymentDomestic__c();
         PayDomestic.AcctPlanPaymentMethodDomestic__c = AcctPlanwallet.id;
         payDomestic.Label__c = '3.1 Bahtnet';
         payDomestic.Volume__c = 20;
         insert paydomestic;
        
        AcctPlanPaymentImport__c payImport = new AcctPlanPaymentImport__c();
         payImport.AcctPlanPaymentMethodImport__c = AcctPlanwallet.id;
         payImport.Label__c ='L/C Term';
         payImport.Volume__c = 20;
         insert payImport;
        
        
                PageReference walletViewPage = Page.AccountPlanWalletDomainIView;
               walletViewPage.getParameters().put('CompanyID',comprofile.id);
               walletViewPage.getParameters().put('GroupID','Test');
               walletViewPage.getParameters().put('WalletID',AcctPlanwallet.id);
               Test.setCurrentPage(walletViewPage); 
                     ApexPages.StandardController sc2 = new ApexPages.StandardController(AcctPlanwallet);
             AccountPlanWalletDomainIExV2 AcctwalletIEx = new AccountPlanWalletDomainIExV2(sc2);
        
             AcctwalletIEx.tempEstimatedSalesAmtPerYear =10000;
             AcctwalletIEx.tempTotalDomesticPercent = 50;
             AcctwalletIEx.tempCOGSPercent = 30;
             AcctwalletIEx.tempTotalPaymentDomesticPercent = 30;
             AcctwalletIEx.insertWallet();
       
        AcctwalletIEx.save();
        
      
        
        
        Test.stopTest();
        
        
    }
    
    
    static testmethod void ExistingWalletTest(){
        
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
          List<Account> AccountList = AccountPlanTestUtilities.createAccounts(1, 'GroupPro', 'Individual', SalesOwner.id, true, true);
       List<Account> acctForCompanyProfile = new List<Account>();
        acctForCompanyProfile.add(AccountList.get(0));
        system.runAs(SalesOwner){
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
                 
        AcctPlanWallet__c AcctPlanwallet2 = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
        AcctPlanWallet2.SumOfPaymentImportVolPercent__c =10;
            update acctplanwallet2;
         List<sObject> ls = 
            Test.loadData(AcctPlan_Questionnaire_Template__c.sObjectType /*API Name*/, 'AcctPlanQuestionnaireTemplate' /*Static Resource Name*/);
   
          
            
            AcctPlanWalletOtherBank__c otherbank1 = new AcctPlanWalletOtherBank__c();
            otherbank1.TableName__c = 'Collection Method Domestic';
            otherbank1.AcctPlanWallet__c = acctplanwallet2.id;
            insert otherbank1; 
            AcctPlanWalletOtherBank__c otherbank2 = new AcctPlanWalletOtherBank__c();
            otherbank2.TableName__c = 'Collection Method Export';
            otherbank2.AcctPlanWallet__c = acctplanwallet2.id;
            insert otherbank2; 
            AcctPlanWalletOtherBank__c otherbank3 = new AcctPlanWalletOtherBank__c();
            otherbank3.TableName__c = 'Payment Method Domestic';
            otherbank3.AcctPlanWallet__c = acctplanwallet2.id;
            insert otherbank3; 
            AcctPlanWalletOtherBank__c otherbank4 = new AcctPlanWalletOtherBank__c();
            otherbank4.TableName__c = 'Payment Method Import';
            otherbank4.AcctPlanWallet__c = acctplanwallet2.id;
            insert otherbank4; 
            
            /*
             * 
             * 
             * SELECT Id,Account_Plan_Wallet__c,AS_Fee__c,AS_Product_Service__c,Fixed_AS_Fee__c,
                            Net_Asset_Value__c,Type_of_Fee__c,Wallet_AS_Fee__c,SEQ__C
                          FROM Account_Plan_AS_Fee__c  
                          WHERE Account_Plan_Wallet__c = :wallet.id */
            
            Account_Plan_AS_Fee__c asfee1 = new Account_Plan_AS_Fee__c();
            asfee1.Account_Plan_Wallet__c =acctplanwallet2.id;
            asfee1.Net_Asset_Value__c =150000;
            asfee1.Fixed_AS_Fee__c  =50;
            asfee1.AS_Product_Service__c ='1)';
            asfee1.Type_of_Fee__c  ='Fixed';
            insert asfee1;
            
            Account_Plan_AS_Fee__c asfee2 = new Account_Plan_AS_Fee__c();
            asfee2.Account_Plan_Wallet__c =acctplanwallet2.id;
            asfee2.Net_Asset_Value__c =150000;
            asfee2.Fixed_AS_Fee__c  =50;
            asfee2.AS_Product_Service__c ='2)';
            asfee2.Type_of_Fee__c  ='Fixed';
            insert asfee2;
            
            Account_Plan_AS_Fee__c asfee3 = new Account_Plan_AS_Fee__c();
            asfee3.Account_Plan_Wallet__c =acctplanwallet2.id;
            asfee3.Net_Asset_Value__c =150000;
            asfee3.Fixed_AS_Fee__c  =50;
            asfee3.AS_Product_Service__c ='3)';
            asfee3.Type_of_Fee__c  ='Fixed';
            insert asfee3;
            
            Account_Plan_AS_Fee__c asfee4 = new Account_Plan_AS_Fee__c();
            asfee4.Account_Plan_Wallet__c =acctplanwallet2.id;
            asfee4.Net_Asset_Value__c =150000;
            asfee4.Fixed_AS_Fee__c  =50;
            asfee4.AS_Product_Service__c ='4)';
            asfee4.Type_of_Fee__c  ='Fixed';
            insert asfee4;
            
            Account_Plan_AS_Fee__c asfee5 = new Account_Plan_AS_Fee__c();
            asfee5.Account_Plan_Wallet__c =acctplanwallet2.id;
            asfee5.Net_Asset_Value__c =150000;
            asfee5.Fixed_AS_Fee__c  =50;
            asfee5.AS_Product_Service__c ='5)';
            asfee5.Type_of_Fee__c  ='Fixed';
            insert asfee5;
                                                                                     
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
        
         
         
         Account_Plan_Flow_Header__c fheader21 = new Account_Plan_Flow_Header__c();
         fheader21.EX_ID__C ='PD09';
         fheader21.SEQ__C = 1;
         fheader21.Method__c = 'Payment Domestic';
         fheader21.Label__c = '3) Fund Transfer';
         fheader21.isActive__c = true;
         fheader21.isVolumePercent__c = true;
         
         insert fheader21;
         
         Account_Plan_Flow_Header__c fheader2 = new Account_Plan_Flow_Header__c();
         fheader2.EX_ID__C ='PD1';
         fheader2.SEQ__C = 1;
         fheader2.Account_Plan_Flow_Header__c = fheader21.id;
         fheader2.Method__c = 'Payment Domestic';
         fheader2.Label__c = '3.1 Bahtnet';
         fheader2.isActive__c = true;
         fheader2.isVolumePercent__c = true;
         
         insert fheader2;
        
         
         
          Account_Plan_Flow_Header__c fheader3 = new Account_Plan_Flow_Header__c();
         fheader3.EX_ID__C ='PI1';
         fheader3.SEQ__C = 1;
         fheader3.Method__c = 'Payment Import';
         fheader3.Label__c = 'L/C Term';
         fheader3.isActive__c = true;
         fheader3.isVolumePercent__c = true;
         
         insert fheader3;
        
            
        AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet2.id);
        AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
        AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet2.id);
                PageReference walletViewPage2 = Page.AccountPlanWalletDomainIView;
               walletViewPage2.getParameters().put('CompanyID',comprofile.id);
               walletViewPage2.getParameters().put('GroupID',AcctPlanwallet2.id);
               walletViewPage2.getParameters().put('WalletID',AcctPlanwallet2.id);
               walletViewPage2.getParameters().put('mode','default');
               Test.setCurrentPage(walletViewPage2); 
            
            
         
                     ApexPages.StandardController sc3 = new ApexPages.StandardController(AcctPlanwallet2);
             AccountPlanWalletDomainIExV2 AcctPlanwallet3 = new AccountPlanWalletDomainIExV2(sc3);
                AcctPlanwallet3.save();
            
             for(String segment : AcctPlanwallet3.DomesticPaymentSegment){
            for(AcctPlanQuestionnaire__c question : AcctPlanwallet3.QuestionnaireMap.get(segment)){
                             question.Answer__c ='Yes';
                             question.OptionPercent__c = 10;
            }
        }
            AcctPlanwallet3.DynamicQuestionnaire();
             for(String segment : AcctPlanwallet3.DomesticPaymentSegment){
            for(AcctPlanQuestionnaire__c question : AcctPlanwallet3.QuestionnaireMap.get(segment)){
                             question.Answer__c ='No';
            }
        }
            AcctPlanwallet3.DynamicQuestionnaire();

            
            
            
        }
    }
}