@isTest
public class AccountPlanProductStrategyExTest {

	public static Profile m_Admin;
	public static Profile m_SEProfile;
	public static Profile m_BDMProfile;


	public static User m_SeUser;
	public static User m_BDMUser;



	static {
		TestUtils.createAppConfig();
		TestUtils.createStatusCode();
		TestUtils.createDisqualifiedReason();
		TestUtils.CreateAddress();
		// get Profile
		m_Admin = ServiceTestUtils.getProfileByName(ServiceTestUtils.EProfile.SystemAdmin);
		m_SEProfile = ServiceTestUtils.getProfileByName(ServiceTestUtils.EProfile.TMBSegmentHead);
		m_BDMProfile = ServiceTestUtils.getProfileByName(ServiceTestUtils.EProfile.TMBBDM);
		// createUsers(integer startNo, Integer size,String FName,String LName,String Email,ID setProfileID,Boolean isSESegment,Boolean doInsert) {

		system.debug(':::: Profile Id for SE : ' + m_SEProfile.Id);

		m_SeUser = ServiceTestUtils.createUsers(1, 1, 'tmbbank1', 'TMBLName1', 'tmb@tmbbank.com', m_SEProfile.Id, true, true) [0];
		m_BDMUser = ServiceTestUtils.createUsers(3, 1, 'tmbbank2', 'TMBLName2', 'tmb@tmbbank.com', m_BDMProfile.Id, true, true) [0];

		System.debug('SE USER : ' + m_SeUser.Id);


		List<sObject> ls = Test.loadData(AcctPlan_Questionnaire_Template__c.sObjectType /*API Name*/, 'AcctPlanQuestionnaireTemplate' /*Static Resource Name*/);

		AccountPlanWalletTestUtilities.createStandardFee();
		AccountPlanWalletTestUtilities.createBanks();
		AccountPlanWalletTestUtilities.createCurrencies();
		AccountPlanTestUtilities.getAcctPlanMode();
		AccountPlanTestUtilities.AccountPlanStatusCode();
	}



	@isTest
	private static void test_ConstructorSeWithGroup() {
		string year = System.today().year() + '';
		// Create Account 
		System.debug('Start : ' + m_SeUser.Id);
		List<Account> AccountList = AccountPlanTestUtilities.createAccounts(2, 'InitiateTest', 'Individual', m_SeUser.id, true, true);

		System.debug('Create account to group');
		// Bind to Group
		Group__c mastergroup = AccountPlanTestUtilities.createGroupMaster(1, 'Initiatetest', false, true).get(0);
		for (account acct : AccountList) {
			acct.Group__c = mastergroup.id;
		}
		update AccountList;
		// Set Target
		AccountPlanTestUtilities.createAccounts(1, 'InitiateNonGroupTest', 'Individual', m_SeUser.id, true, true);
		List<Target__c> TaragetList = AccountPlanTestUtilities.createTargetNI(5, m_SeUser.id, true);


		List<Account> acctForCompanyProfile = new List<Account> ();
		acctForCompanyProfile.add(AccountList.get(0));
		system.runAs(m_SeUser) {
			List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
			AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
			List<group__c> mgroupList = new List<group__c> ();
			mgroupList.add(mastergroup);


			AcctPlanGroupProfile__c groupprofile = AccountPlanTestUtilities.createGroupProfilebyGroup(mgroupList, true).get(0);
			groupprofile.Year__c = year;
			update groupprofile;
			comprofile.AcctPlanGroup__c = groupprofile.id;

			update comprofile;




			AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(m_SeUser.id, year, 10000000, true);
			AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);

			AcctPlanCusUnderstanding__c custoutstanding1 = new AcctPlanCusUnderstanding__c();
			custoutstanding1.AcctPlanWallet__c =AcctPlanwallet.id;
			custoutstanding1.Ending_CASA__c =100;
			custoutstanding1.Average_CASA__c =100;
			custoutstanding1.Average_loan_outstanding__c =100;
			custoutstanding1.Ending_loan_outstanding__c =100;
			custoutstanding1.FX_volume__c =100;
			custoutstanding1.TF_Volume__c =100;
			custoutstanding1.Account__c = AccountList.get(0).id;

			insert custoutstanding1;


			List<AcctPlanContribution__c> contributionlist = AccountPlanTestUtilities.createRenevueContribution(3, null, comprofile.id);

			AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
			AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
			AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);
			Test.startTest();
			PageReference groupViewPage = Page.AccountPlanProductStrategy;
			groupViewPage.getParameters().put('GroupID', groupprofile.id);
			groupViewPage.getParameters().put('CompanyID', comprofile.id);
			groupViewPage.getParameters().put('walletID', AcctPlanwallet.id);
			Test.setCurrentPage(groupViewPage);
			ApexPages.StandardController sctrl = new ApexPages.StandardController(new AcctPlanProdStrategy__c());
			AccountPlanProductStrategyEx ctrl = new AccountPlanProductStrategyEx(sctrl);

			ctrl.InitData();
			ctrl.refresh();
			ctrl.EditPage();
			ctrl.cancel();
			AccountPlanProductStrategyService.getGroupCompaniesProductStrategyInfo(new Set<Id> { groupprofile.Id });
			AccountPlanProductStrategyService.AcctPlanProdStrategyCompanyInfo dto = AccountPlanProductStrategyService.getGroupCompaniesProductStrategyInfoV2(groupprofile.Id);
			decimal val1 = dto.TotalAccount;
			dto.getMapGroupWalletSizing.get(1.00);
			dto.getMapGroupActualNiRolling.get(1.00);
			decimal val2 = dto.GrandGroupAdjustedNI;
			dto.geMapGroupAdjustedNI.get(1.00);
			dto.getMapGroupAdjustedNIDebug.get(1.00);
			dto.getMapGroupExpectedIncrementalNIStep5.get(1.00);
			dto.geMapExistingSOWGroup.get(1.00);
			dto.getMapGroupExpectedIncrementalNI.get(1.00);
			dto.getMapGroupTotalCompanyNI.get(1.00);

			dto.getMapAspirationSOWStep4.get(1.00);
			dto.getMapAspirationSOWStep6.get(1.00);
			dto.getMapAspirationSOW.get(1.00);
			//
			dto.getMapCompareExpectedToAspirationSOW.get(1.00);
			decimal val3 = dto.GrandGroupWalletsizing;
			dto.getMapGrandGroupWalletSizingEachCompany.get(AccountList[0].Id);
			//
			decimal val4 = dto.GrandTotalGroupNI;
			decimal val5 = dto.GrandGroupExpectedIncrementalNIStep5;	
			decimal val6 = dto.GrandGroupExpectedIncrementalNI;
			decimal val7 = dto.GrandGroupActualNiRolling;
			Test.stopTest();           
			 
		}

	}


	@isTest
	private static void test_ConstructorNonSeNoneGroup() {

		// Create Account 
		System.debug('Start : ' + m_SeUser.Id);
		List<Account> AccountList = AccountPlanTestUtilities.createAccounts(2, 'InitiateTest', 'Individual', m_BDMUser.id, true, true);


		// Set Target
		AccountPlanTestUtilities.createAccounts(1, 'InitiateNonGroupTest', 'Individual', m_SeUser.id, true, true);
		List<Target__c> TaragetList = AccountPlanTestUtilities.createTargetNI(5, m_SeUser.id, true);


		List<Account> acctForCompanyProfile = new List<Account> ();
		acctForCompanyProfile.add(AccountList.get(0));
		system.runAs(m_BDMUser) {
			List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
			AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
			comprofile.isMiniMode__c = false;
			update comprofile;
			string year = System.today().year() + '';

			AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(m_SeUser.id, year, 10000000, true);


			AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);


			List<AcctPlanContribution__c> contributionlist = AccountPlanTestUtilities.createRenevueContribution(3, null, comprofile.id);

			AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
			AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
			AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);

			Test.startTest();
			PageReference groupViewPage = Page.AccountPlanProductStrategy;
			groupViewPage.getParameters().put('GroupID', '');
			groupViewPage.getParameters().put('CompanyID', comprofile.id);
			groupViewPage.getParameters().put('walletID', AcctPlanwallet.id);
			Test.setCurrentPage(groupViewPage);
			ApexPages.StandardController sctrl = new ApexPages.StandardController(new AcctPlanProdStrategy__c());
			AccountPlanProductStrategyEx ctrl = new AccountPlanProductStrategyEx(sctrl);
			ctrl.InitData();
			ctrl.refresh();
			ctrl.save();


			AccountPlanProductStrategyService.getCompaniesProductStrategyInfo(new Set<Id> { comprofile.Id });



			Test.stopTest();



		}

	}

	@isTest
	private static void test_ConstructorNonSeNoneGroupAsFee() {

		// Create Account 
		System.debug('Start : ' + m_SeUser.Id);
		List<Account> AccountList = AccountPlanTestUtilities.createAccounts(2, 'InitiateTest', 'Individual', m_BDMUser.id, true, true);


		// Set Target
		AccountPlanTestUtilities.createAccounts(1, 'InitiateNonGroupTest', 'Individual', m_SeUser.id, true, true);
		List<Target__c> TaragetList = AccountPlanTestUtilities.createTargetNI(5, m_SeUser.id, true);


		List<Account> acctForCompanyProfile = new List<Account> ();
		acctForCompanyProfile.add(AccountList.get(0));
		system.runAs(m_BDMUser) {
			List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
			AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
			comprofile.isMiniMode__c = false;
			update comprofile;
			string year = System.today().year() + '';

			AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(m_SeUser.id, year, 10000000, true);


			AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);


			List<AcctPlanContribution__c> contributionlist = AccountPlanTestUtilities.createRenevueContribution(3, null, comprofile.id);

			AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
			AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
			AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);

			Test.startTest();
			PageReference groupViewPage = Page.AccountPlanProductStrategy;
			groupViewPage.getParameters().put('GroupID', '');
			groupViewPage.getParameters().put('CompanyID', comprofile.id);
			groupViewPage.getParameters().put('walletID', AcctPlanwallet.id);
			Test.setCurrentPage(groupViewPage);
			MockProductStrategy(comprofile.id,AcctPlanwallet.id);
			ApexPages.StandardController sctrl = new ApexPages.StandardController(new AcctPlanProdStrategy__c());
			AccountPlanProductStrategyEx ctrl = new AccountPlanProductStrategyEx(sctrl);
			ctrl.InitData();
			ctrl.refresh();
			ctrl.save();


			AccountPlanProductStrategyService.getCompaniesProductStrategyInfo(new Set<Id> { comprofile.Id });



			ApexPages.StandardController sctrl2 = new ApexPages.StandardController(new AcctPlanProdStrategy__c());
			AccountPlanProductStrategyEx ctrl2 = new AccountPlanProductStrategyEx(sctrl2);
			ctrl2.InitData();





			Test.stopTest();



		}

	}

	 static void MockProductStrategy(Id companyProfileId, Id walletId)
    {
        AcctPlanProdStrategy__c prodStrategy1 = new AcctPlanProdStrategy__c();
        prodStrategy1.SEQ__c = 1;
        prodStrategy1.Name = '1. NIIc';
        prodStrategy1.WalletSizing__c = 10000;
        prodStrategy1.AnnualizedPerformance__c = 100;
        prodStrategy1.Adjust_NI__c = 150;
        prodStrategy1.ExpectedIncrementalNIFromStep5__c = 10;

		prodStrategy1.AccountPlanYear__c = 2015;   
        prodStrategy1.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy1.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy1.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy1.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy1.AcctPlanWallet__c = walletId;
        prodStrategy1.AspirationSOW__c = 0.2;        
        prodStrategy1.RefreshAsOf__c = Date.today();
        insert prodStrategy1;
        
        AcctPlanProdStrategy__c prodStrategy2 = new AcctPlanProdStrategy__c();
        prodStrategy2.SEQ__c = 2;
        prodStrategy2.Name = '2. NIId';
        prodStrategy2.WalletSizing__c = 10000;
        prodStrategy2.AnnualizedPerformance__c = 100;
        prodStrategy2.Adjust_NI__c = 150;
        prodStrategy2.ExpectedIncrementalNIFromStep5__c = 10;
        
		prodStrategy2.AccountPlanYear__c = 2015;   
        prodStrategy2.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy2.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy2.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy2.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy2.AcctPlanWallet__c = walletId;
        prodStrategy2.AspirationSOW__c = 0.2;        
        prodStrategy2.RefreshAsOf__c = Date.today();
        insert prodStrategy2;
        
        AcctPlanProdStrategy__c prodStrategy3 = new AcctPlanProdStrategy__c();
        prodStrategy3.SEQ__c = 3;
        prodStrategy3.Name = '3. Fee';
        prodStrategy3.WalletSizing__c = 10000;
        prodStrategy3.AnnualizedPerformance__c = 100;
        prodStrategy3.Adjust_NI__c = 150;
        prodStrategy3.ExpectedIncrementalNIFromStep5__c = 10;
                
		prodStrategy3.AccountPlanYear__c = 2015;   
        prodStrategy3.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy3.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy3.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy3.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy3.AcctPlanWallet__c = walletId;
        prodStrategy3.AspirationSOW__c = 0.2;        
        prodStrategy3.RefreshAsOf__c = Date.today();
        insert prodStrategy3;
        
        AcctPlanProdStrategy__c prodStrategy4 = new AcctPlanProdStrategy__c();
        prodStrategy4.SEQ__c = 4;
        prodStrategy4.Name = 'Recurring Fee';
        prodStrategy4.WalletSizing__c = 0;
        prodStrategy4.AnnualizedPerformance__c = 00;
        prodStrategy4.Adjust_NI__c = 0;
        prodStrategy4.ExpectedIncrementalNIFromStep5__c = 0;
                
		prodStrategy4.AccountPlanYear__c = 2015;   
        prodStrategy4.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy4.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy4.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy4.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy4.AcctPlanWallet__c = walletId;
        prodStrategy4.AspirationSOW__c = 0;        
        prodStrategy4.RefreshAsOf__c = Date.today();
        insert prodStrategy4;
        
        AcctPlanProdStrategy__c prodStrategy5 = new AcctPlanProdStrategy__c();
        prodStrategy5.SEQ__c = 5;
        prodStrategy5.Name = '3.1 TF Fee';
        prodStrategy5.WalletSizing__c = 10000;
        prodStrategy5.AnnualizedPerformance__c = 100;
        prodStrategy5.Adjust_NI__c = 150;
        prodStrategy5.ExpectedIncrementalNIFromStep5__c = 10;
                
		prodStrategy5.AccountPlanYear__c = 2015;   
        prodStrategy5.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy5.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy5.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy5.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy5.AcctPlanWallet__c = walletId;
        prodStrategy5.AspirationSOW__c = 0.2;        
        prodStrategy5.RefreshAsOf__c = Date.today();
        insert prodStrategy5;
        
        AcctPlanProdStrategy__c prodStrategy6 = new AcctPlanProdStrategy__c();
        prodStrategy6.SEQ__c = 6;
        prodStrategy6.Name = '3.2 FX Fee';
        prodStrategy6.WalletSizing__c = 10000;
        prodStrategy6.AnnualizedPerformance__c = 100;
        prodStrategy6.Adjust_NI__c = 150;
        prodStrategy6.ExpectedIncrementalNIFromStep5__c = 10;
                
		prodStrategy6.AccountPlanYear__c = 2015;   
        prodStrategy6.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy6.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy6.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy6.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy6.AcctPlanWallet__c = walletId;
        prodStrategy6.AspirationSOW__c = 0.2;        
        prodStrategy6.RefreshAsOf__c = Date.today();
        insert prodStrategy6;
        
        AcctPlanProdStrategy__c prodStrategy7 = new AcctPlanProdStrategy__c();
        prodStrategy7.SEQ__c = 7;
        prodStrategy7.Name = '3.3 L/G Fee';
        prodStrategy7.WalletSizing__c = 10000;
        prodStrategy7.AnnualizedPerformance__c = 100;
        prodStrategy7.Adjust_NI__c = 150;
        prodStrategy7.ExpectedIncrementalNIFromStep5__c = 10;
                
		prodStrategy7.AccountPlanYear__c = 2015;   
        prodStrategy7.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy7.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy7.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy7.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy7.AcctPlanWallet__c = walletId;
        prodStrategy7.AspirationSOW__c = 0.2;        
        prodStrategy7.RefreshAsOf__c = Date.today();
        insert prodStrategy7;
                
        AcctPlanProdStrategy__c prodStrategy8 = new AcctPlanProdStrategy__c();
        prodStrategy8.SEQ__c = 8;
        prodStrategy8.Name = '3.4 Cash Fee';
        prodStrategy8.WalletSizing__c = 10000;
        prodStrategy8.AnnualizedPerformance__c = 100;
        prodStrategy8.Adjust_NI__c = 150;
        prodStrategy8.ExpectedIncrementalNIFromStep5__c = 10;
                
		prodStrategy8.AccountPlanYear__c = 2015;   
        prodStrategy8.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy8.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy8.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy8.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy8.AcctPlanWallet__c = walletId;
        prodStrategy8.AspirationSOW__c = 0.2;        
        prodStrategy8.RefreshAsOf__c = Date.today();
        insert prodStrategy8;
        
        AcctPlanProdStrategy__c prodStrategy9 = new AcctPlanProdStrategy__c();
        prodStrategy9.SEQ__c = 9;
        prodStrategy9.Name = '3.5 AS Fee';
        prodStrategy9.WalletSizing__c = 10000;
        prodStrategy9.AnnualizedPerformance__c = 100;
        prodStrategy9.Adjust_NI__c = 150;
        prodStrategy9.ExpectedIncrementalNIFromStep5__c = 10;
                
		prodStrategy9.AccountPlanYear__c = 2015;   
        prodStrategy9.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy9.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy9.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy9.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy9.AcctPlanWallet__c = walletId;
        prodStrategy9.AspirationSOW__c = 0.2;        
        prodStrategy9.RefreshAsOf__c = Date.today();
        insert prodStrategy9;
        
        AcctPlanProdStrategy__c prodStrategy10 = new AcctPlanProdStrategy__c();
        prodStrategy10.SEQ__c = 10;
        prodStrategy10.Name = 'Non Recurring Fee';
        prodStrategy10.WalletSizing__c = 0;
        prodStrategy10.AnnualizedPerformance__c = 0;
        prodStrategy10.Adjust_NI__c = 0;
        prodStrategy10.ExpectedIncrementalNIFromStep5__c = 0;
                
		prodStrategy10.AccountPlanYear__c = 2015;   
        prodStrategy10.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy10.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy10.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy10.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy10.AcctPlanWallet__c = walletId;
        prodStrategy10.AspirationSOW__c = 0;        
        prodStrategy10.RefreshAsOf__c = Date.today();
        insert prodStrategy10;
        
        AcctPlanProdStrategy__c prodStrategy11 = new AcctPlanProdStrategy__c();
        prodStrategy11.SEQ__c = 11;
        prodStrategy11.Name = '3.6 Credit Fee';
        prodStrategy11.WalletSizing__c = 10000;
        prodStrategy11.AnnualizedPerformance__c = 100;
        prodStrategy11.Adjust_NI__c = 150;
        prodStrategy11.ExpectedIncrementalNIFromStep5__c = 10;
                
		prodStrategy11.AccountPlanYear__c = 2015;   
        prodStrategy11.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy11.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy11.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy11.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy11.AcctPlanWallet__c = walletId;
        prodStrategy11.AspirationSOW__c = 0.2;        
        prodStrategy11.RefreshAsOf__c = Date.today();
        insert prodStrategy11;
        
        AcctPlanProdStrategy__c prodStrategy12 = new AcctPlanProdStrategy__c();
        prodStrategy12.SEQ__c = 12;
        prodStrategy12.Name = '3.7 BA Fee';
        prodStrategy12.WalletSizing__c = 10000;
        prodStrategy12.AnnualizedPerformance__c = 100;
        prodStrategy12.Adjust_NI__c = 150;
        prodStrategy12.ExpectedIncrementalNIFromStep5__c = 10;
                
		prodStrategy12.AccountPlanYear__c = 2015;   
        prodStrategy12.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy12.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy12.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy12.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy12.AcctPlanWallet__c = walletId;
        prodStrategy12.AspirationSOW__c = 0.2;        
        prodStrategy12.RefreshAsOf__c = Date.today();
        insert prodStrategy12;
        
        AcctPlanProdStrategy__c prodStrategy13 = new AcctPlanProdStrategy__c();
        prodStrategy13.SEQ__c = 13;
        prodStrategy13.Name = '3.8 Derivative Fee';
        prodStrategy13.WalletSizing__c = 10000;
        prodStrategy13.AnnualizedPerformance__c = 100;
        prodStrategy13.Adjust_NI__c = 150;
        prodStrategy13.ExpectedIncrementalNIFromStep5__c = 10;
                
		prodStrategy13.AccountPlanYear__c = 2015;   
        prodStrategy13.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy13.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy13.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy13.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy13.AcctPlanWallet__c = walletId;
        prodStrategy13.AspirationSOW__c = 0.2;        
        prodStrategy13.RefreshAsOf__c = Date.today();
        insert prodStrategy13;
        
        AcctPlanProdStrategy__c prodStrategy14 = new AcctPlanProdStrategy__c();
        prodStrategy14.SEQ__c = 14;
        prodStrategy14.Name = '3.9 IB Fee';
        prodStrategy14.WalletSizing__c = 10000;
        prodStrategy14.AnnualizedPerformance__c = 100;
        prodStrategy14.Adjust_NI__c = 150;
        prodStrategy14.ExpectedIncrementalNIFromStep5__c = 10;
                
		prodStrategy14.AccountPlanYear__c = 2015;   
        prodStrategy14.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy14.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        //prodStrategy14.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy14.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy14.AcctPlanWallet__c = walletId;
        prodStrategy14.AspirationSOW__c = 0.2;        
        prodStrategy14.RefreshAsOf__c = Date.today();
        insert prodStrategy14;
        
    }






}