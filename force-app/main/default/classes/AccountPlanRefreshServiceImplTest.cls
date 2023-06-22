@isTest
public class AccountPlanRefreshServiceImplTest {
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

		List<sObject> products = Test.loadData(Product2.sObjectType /*API Name*/, 'ProductMaster' /*Static Resource Name*/);
		List<sObject> ls = Test.loadData(AcctPlan_Questionnaire_Template__c.sObjectType /*API Name*/, 'AcctPlanQuestionnaireTemplate' /*Static Resource Name*/);
		List<sObject> sectionConfig = Test.loadData(Account_Plan_Deposit_Section__c.sObjectType /*API Name*/, 'DepositeSection' /*Static Resource Name*/);



		AccountPlanWalletTestUtilities.createStandardFee();
		AccountPlanWalletTestUtilities.createBanks();
		AccountPlanWalletTestUtilities.createCurrencies();
		AccountPlanTestUtilities.getAcctPlanMode();
	}

	@isTest
	private static void test_ConstructorSeWithGroup() {

		//Test.setMock(WebServiceMock.class, new TMBAccountPlanServiceProxyMock());
		Map<Id, Id> accountsSet = new Map<Id, Id> ();
		string year = System.today().year() + '';
		// Create Account 
		System.debug('Start : ' + m_SeUser.Id);
		List<Account> AccountList = AccountPlanTestUtilities.createAccounts(2, 'InitiateTest', 'Individual', m_SeUser.id, true, true);

		System.debug('Create account to group');
		// Bind to Group
		Group__c mastergroup = AccountPlanTestUtilities.createGroupMaster(1, 'Initiatetest', false, true).get(0);
		for (account acct : AccountList) {
			acct.Group__c = mastergroup.id;
			accountsSet.put(acct.Id, acct.Id);
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


			AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(m_SeUser.id, year, 10000000, true);
			AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
			List<AcctPlanContribution__c> contributionlist = AccountPlanTestUtilities.createRenevueContribution(3, null, comprofile.id);






			comprofile.Portfolio__c = portfolio.Id;
			AcctPlanCompanyPort__c comport = new AcctPlanCompanyPort__c();

			comport.Account__c = comprofile.Account__c;
			comport.Account_Plan_Portfolio__c = portfolio.Id;
			comport.Account_Name__c = 'ddd';
			insert comport;
			update comprofile;


			AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
			AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
			AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);




			Test.startTest();

			AcctPlanCompanyProfile__c com1 = comprofileList[0];

			// Create Performance 
			AcctAnnualPerformance__c per = new AcctAnnualPerformance__c();

			per.Account__c = comprofile.Account__c;
			per.Transaction_Date__c = System.today().addMonths(- 3);
			per.CREDIT_FEE__c = 0.0;
			per.TMB_CUST_ID__c = 'TMBCUS00000001';
			insert per;
			AccountPlanRefreshService.initialStep0(com1.Account__c + '');
			AccountPlanRefreshService.RefreshProductStrategyPort(accountsSet.keySet(), year);
			AccountPlanRefreshService.RefreshNameProductStrategyPort(accountsSet.keySet(), year);

			//Start New function for R5.2
			
			String groupID = groupprofile.group__c;
			String groupProfileID = groupprofile.id;
			Set<id> acctCompanyProfileIds = new Set<id>();
        	Set<id> walletIds = new Set<id>();
			if(comprofileList.size()>0){
	          for(AcctPlanCompanyProfile__c item : comprofileList){
	            acctCompanyProfileIds.add(item.id);
	            walletIds.add(item.AccountPlanWalletID__c);
	          }
	          
	        }
	        walletIds.add(AcctPlanwallet.id);
			AccountPlanRefreshService.RefreshProductStrategyPort(accountsSet.keySet(), year, groupID);
			AccountPlanRefreshService.RefreshProductStrategyGroupWalletGroupPerformance(accountsSet.keySet(),acctCompanyProfileIds, walletIds,groupID);
			MockProductStrategy(comprofile.id,AcctPlanwallet.id);
			AccountPlanRefreshService.RefreshProductStrategy2(accountsSet.keySet(),year,groupID );
			//End New function for R5.2

			AccountPlanProductStrategyService.createProductStrategyRecordToWallet(comprofile.Id, AcctPlanwallet.Id, groupprofile.id);

			AccountPlanRefreshService.RefreshWalletAndAnnualPerformanceRolling12Month(new Set<Id> { portfolio.Id });

			//Create Domain II 

			List<String> APDepositInternationalLabel = new List<String> { 'Transactional', '1) Current - USD', 'Current - Other Currency', '2) Saving - USD', 'Saving - Other Currency', 'Non Transactional', 'Time Deposit - USD', 'Time Deposit - Other Currency', 'Others - USD', 'Others - Other Currency', 'Total' };
			Map<String, AcctPlanDepositInternational__c> APDepositInternationalList = new Map<String, AcctPlanDepositInternational__c> ();
			for (String l : APDepositInternationalLabel) {
				AcctPlanDepositInternational__c APDepositInternationalitem = new AcctPlanDepositInternational__c();
				APDepositInternationalitem.AccountPlanDepositInternationalDeposit__c = AcctPlanwallet.Id;
				APDepositInternationalitem.Label__c = l;
				APDepositInternationalList.put(l, APDepositInternationalitem);
			}
			insert APDepositInternationalList.values();
			DepositInternational(AcctPlanwallet.Id);

			List<String> APDepositDomesticLabel = new List<String> { 'Transactional', '1) Current', '2) Saving', 'Non Transactional', 'Time Deposit', 'T-Bill', 'Mutual Fund', 'Others', 'Total' };
			Map<String, AcctPlanDepositDomestic__c> APDepositDomesticList = new Map<String, AcctPlanDepositDomestic__c> ();

			for (String l : APDepositDomesticLabel) {
				AcctPlanDepositDomestic__c APDepositDomesticitem = new AcctPlanDepositDomestic__c();
				APDepositDomesticitem.AccountPlanDepositDomesticDeposit__c = AcctPlanwallet.Id;
				APDepositDomesticitem.Label__c = l;
				APDepositDomesticList.put(l, APDepositDomesticitem);
			}
			insert APDepositDomesticList.values();




			//AccountPlanRefreshService.RefreshDepositInter(comprofile.Id, AcctPlanwallet.Id, groupprofile.id);

			//AccountPlanRefreshService.RefreshDepositDomestic(comprofile.Id, AcctPlanwallet.Id, groupprofile.id);



			Test.stopTest();


		}

	}
	private static void DepositInternational(Id acctplanwallet) {
		List<String> APDepositInternationalLabel = new List<String> { 'Transactional', '1) Current - USD', 'Current - Other Currency', '2) Saving - USD', 'Saving - Other Currency', 'Non Transactional', 'Time Deposit - USD', 'Time Deposit - Other Currency', 'Others - USD', 'Others - Other Currency', 'Total' };
		List<String> APDepositDomesticLabel = new List<String> { 'Transactional', '1) Current', '2) Saving', 'Non Transactional', 'Time Deposit', 'T-Bill', 'Mutual Fund', 'Others', 'Total' };
		Map<String, AcctPlanDepositInternational__c> APDepositInternationalList = new Map<String, AcctPlanDepositInternational__c> ();
		AcctPlanWalletOtherBank__c otherBankInternational;
		Double totalAPDIAverage = 0.0;
		Double totalAPDItransAverage = 0.0;
		Double totalAPDInontransAverage = 0.0;
		Double totalAPDITMB = 0.0;
		Double totalAPDIbank1 = 0.0;
		Double totalAPDIbank2 = 0.0;
		Double totalAPDIbank3 = 0.0;
		Double totalAPDIbank4 = 0.0;
		Double totalAPDItransTMB = 0.0;
		Double totalAPDItransbank1 = 0.0;
		Double totalAPDItransbank2 = 0.0;
		Double totalAPDItransbank3 = 0.0;
		Double totalAPDItransbank4 = 0.0;
		Double totalAPDInontransTMB = 0.0;
		Double totalAPDInontransbank1 = 0.0;
		Double totalAPDInontransbank2 = 0.0;
		Double totalAPDInontransbank3 = 0.0;
		Double totalAPDInontransbank4 = 0.0;
		Boolean isHasDepositInternational = true;

		List<AcctPlanDepositInternational__c> APDepositInternationalTemp = [SELECT Id, AmountBank1__c, AmountBank2__c, AmountBank3__c, AmountBank4__c,
		                                                                    AmtPerMonth__c, CCY__c, CCY__r.Name, Label__c, RateBank1__c, RateBank2__c, RateBank3__c,
		                                                                    RateBank4__c, SharePercentBank1__c, SharePercentBank2__c, SharePercentBank3__c,
		                                                                    SharePercentBank4__c, ShareTMBPercent__c, TenorPerPeriod__c, TMBAmount__c,
		                                                                    TMBRate__c, AvgRatePercent__c, TransactionType__c, Label_Value__c
		                                                                    FROM AcctPlanDepositInternational__c
		                                                                    WHERE AccountPlanDepositInternationalDeposit__c = :acctplanwallet];

		List<AcctPlanWalletOtherBank__c> otherBankInternationalList = [SELECT Id, AcctPlanWallet__c, SharedBank1__c, SharedBank1__r.Name, SharedBank2__c, SharedBank2__r.Name, SharedBank3__c, SharedBank3__r.Name, SharedBank4__c, SharedBank4__r.Name
		                                                               FROM AcctPlanWalletOtherBank__c
		                                                               WHERE AcctPlanWallet__c = :acctplanwallet AND TableName__c = 'Deposit International'];
		if (otherBankInternationalList.size() <= 0) {
			AcctPlanWalletOtherBank__c ob = new AcctPlanWalletOtherBank__c();
			ob.AcctPlanWallet__c = acctplanwallet;
			ob.TableName__c = 'Deposit International';
			otherBankInternational = ob;
		} else {
			otherBankInternational = otherBankInternationalList.get(0);
		}

		if (APDepositInternationalTemp.size() > 0) {
			for (AcctPlanDepositInternational__c item : APDepositInternationalTemp) {
				item.AccountPlanDepositInternationalDeposit__c = acctplanwallet;
				if (item.AmtPerMonth__c == null) {
					item.AmtPerMonth__c = 0;
				}
				if (item.TMBAmount__c == null) {
					item.TMBAmount__c = 0;
				}
				if (item.AmountBank1__c == null) {
					item.AmountBank1__c = 0;
				}
				if (item.AmountBank2__c == null) {
					item.AmountBank2__c = 0;
				}
				if (item.AmountBank3__c == null) {
					item.AmountBank3__c = 0;
				}
				if (item.AmountBank4__c == null) {
					item.AmountBank4__c = 0;
				}

				totalAPDIAverage += item.AmtPerMonth__c;
				totalAPDITMB += item.TMBAmount__c;
				totalAPDIbank1 += item.AmountBank1__c;
				totalAPDIbank2 += item.AmountBank2__c;
				totalAPDIbank3 += item.AmountBank3__c;
				totalAPDIbank4 += item.AmountBank4__c;
				if (item.TransactionType__c) {
					totalAPDItransAverage += item.AmtPerMonth__c;
					totalAPDItransTMB += item.TMBAmount__c;
					totalAPDItransbank1 += item.AmountBank1__c;
					totalAPDItransbank2 += item.AmountBank2__c;
					totalAPDItransbank3 += item.AmountBank3__c;
					totalAPDItransbank4 += item.AmountBank4__c;
				} else {
					totalAPDInontransAverage += item.AmtPerMonth__c;
					totalAPDInontransTMB += item.TMBAmount__c;
					totalAPDInontransbank1 += item.AmountBank1__c;
					totalAPDInontransbank2 += item.AmountBank2__c;
					totalAPDInontransbank3 += item.AmountBank3__c;
					totalAPDInontransbank4 += item.AmountBank4__c;
				}
				if (item.AmtPerMonth__c == 0) {
					item.AmtPerMonth__c = null;
				}
				/*if(item.TMBAmount__c == 0){
				  item.TMBAmount__c = null;
				  }*/
				if (item.AmountBank1__c == 0) {
					item.AmountBank1__c = null;
				}
				if (item.AmountBank2__c == 0) {
					item.AmountBank2__c = null;
				}
				if (item.AmountBank3__c == 0) {
					item.AmountBank3__c = null;
				}
				if (item.AmountBank4__c == 0) {
					item.AmountBank4__c = null;
				}
				APDepositInternationalList.put(item.label__c, item);

				AcctPlanDepositInternational__c APDItemptransaction = new AcctPlanDepositInternational__c();
				APDItemptransaction.AmtPerMonth__c = totalAPDItransAverage;
				APDItemptransaction.TMBAmount__c = totalAPDItransTMB;
				APDItemptransaction.AmountBank1__c = totalAPDItransbank1;
				APDItemptransaction.AmountBank2__c = totalAPDItransbank2;
				APDItemptransaction.AmountBank3__c = totalAPDItransbank3;
				APDItemptransaction.AmountBank4__c = totalAPDItransbank4;
				APDItemptransaction.Label__c = 'Transactional';
				APDepositInternationalList.put(APDItemptransaction.label__c, APDItemptransaction);

				AcctPlanDepositInternational__c APDItempnontransaction = new AcctPlanDepositInternational__c();
				APDItempnontransaction.AmtPerMonth__c = totalAPDInontransAverage;
				APDItempnontransaction.TMBAmount__c = totalAPDInontransTMB;
				APDItempnontransaction.AmountBank1__c = totalAPDInontransbank1;
				APDItempnontransaction.AmountBank2__c = totalAPDInontransbank2;
				APDItempnontransaction.AmountBank3__c = totalAPDInontransbank3;
				APDItempnontransaction.AmountBank4__c = totalAPDInontransbank4;
				APDItempnontransaction.Label__c = 'Non Transactional';
				APDepositInternationalList.put(APDItempnontransaction.Label__c, APDItempnontransaction);

				AcctPlanDepositInternational__c APDItemptotal = new AcctPlanDepositInternational__c();
				APDItemptotal.AmtPerMonth__c = totalAPDIAverage;
				APDItemptotal.TMBAmount__c = totalAPDITMB;
				APDItemptotal.AmountBank1__c = totalAPDIbank1;
				APDItemptotal.AmountBank2__c = totalAPDIbank2;
				APDItemptotal.AmountBank3__c = totalAPDIbank3;
				APDItemptotal.AmountBank4__c = totalAPDIbank4;
				APDItemptotal.Label__c = 'Total';
				APDepositInternationalList.put(APDItemptotal.Label__c, APDItemptotal);
			}
		} else {
			isHasDepositInternational = false;
		}
		if (!isHasDepositInternational) {
			for (String l : APDepositInternationalLabel) {
				AcctPlanDepositInternational__c APDepositInternationalitem = new AcctPlanDepositInternational__c();
				APDepositInternationalitem.AccountPlanDepositInternationalDeposit__c = acctplanwallet;
				APDepositInternationalitem.Label__c = l;
				APDepositInternationalList.put(l, APDepositInternationalitem);
			}
		}
	}
	@isTest
	private static void test_getTemplate() {
		AccountPlanRefreshServiceImpl impl = new AccountPlanRefreshServiceImpl();
		List<AccountPlanRefreshServiceImpl.WalletByDomainTemplate> val1 = impl.getWalletByDomainTemplate;
		Map<decimal, string> val2 = impl.getProductStrategyTemplate;

		AccountPlanRefreshServiceImpl.ProductStrategyTemplate template = new AccountPlanRefreshServiceImpl.ProductStrategyTemplate(1.0, 'Test');


		AccountPlanRefreshServiceImpl.WalletByDomainTemplate template2
		= new AccountPlanRefreshServiceImpl.WalletByDomainTemplate(1.1, 1.0, 'xx', 'xx', 'xx', 'xx');

	}

	@isTest
	private static void test_RefreshProductStrategySeWithGroup() {
		string year = System.today().year() + '';
		// Create Account 
		System.debug('Start : ' + m_BDMUser.Id);
		List<Account> AccountList = AccountPlanTestUtilities.createAccounts(2, 'InitiateTest', 'Individual', m_BDMUser.id, true, true);
		System.debug('Create account to group');
		// Bind to Group
		Group__c mastergroup = AccountPlanTestUtilities.createGroupMaster(1, 'Initiatetest', false, true).get(0);
		for (account acct : AccountList) {
			acct.Group__c = mastergroup.id;
		}
		update AccountList;




		// Set Target
		AccountPlanTestUtilities.createAccounts(1, 'InitiateNonGroupTest', 'Individual', m_BDMUser.id, true, true);
		List<Target__c> TaragetList = AccountPlanTestUtilities.createTargetNI(5, m_BDMUser.id, true);
		//Create Contact
		Contact cont1 = new Contact();
		cont1.FirstName = 'AccountPlan';
		cont1.LastName = 'Step5';
		cont1.Position__c = 'Manager';
		cont1.Accountid = AccountList.get(0).id;
		insert cont1;

		List<Account> acctForCompanyProfile = new List<Account> ();
		acctForCompanyProfile.add(AccountList.get(0));
		system.runAs(m_BDMUser) {
			List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
			AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);

			List<group__c> mgroupList = new List<group__c> ();
			mgroupList.add(mastergroup);


			AcctPlanGroupProfile__c groupprofile = AccountPlanTestUtilities.createGroupProfilebyGroup(mgroupList, true).get(0);
			groupprofile.Year__c = year;
			update groupprofile;
			comprofile.AcctPlanGroup__c = groupprofile.id;
			comprofile.isMiniMode__c = false;
			update comprofile;
			AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(m_SeUser.id, year, 10000000, true);


			AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);


			List<AcctPlanContribution__c> contributionlist = AccountPlanTestUtilities.createRenevueContribution(3, null, comprofile.id);

			AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
			AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
			AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);

			Test.startTest();

			AccountPlanProductStrategyService.createProductStrategyRecordToWallet(comprofile.Id, AcctPlanwallet.Id, groupprofile.id);
			List<AcctPlanProdStrategy__c> retValue = AccountPlanProductStrategySelector.selectProductStrategyByIds(new Set<Id> { comprofile.Id });
			System.assertEquals(14, retValue.size());
			List<AcctPlanWallet__c> walls = AccountPlanWalletSelector.getWalletByIds(new Set<Id> { AcctPlanwallet.Id });
			System.assertEquals(1, walls.size());


			List<AcctPlanWalletByDomain__c> walltbyDomain = AccountPlanWalletByDomainSelector.getWalletByDomainByWallets(new Set<Id> { AcctPlanwallet.Id });
			System.assert(true, walltbyDomain.size() > 0);

			// make data for step 5
			AcctPlanActionPlan__c acctplan1 = new AcctPlanActionPlan__c();
			acctplan1.AcctPlanWalletByDomain__c = walltbyDomain[1].id;
			acctplan1.Objective__c = 'Acquire New customers';
			acctplan1.Status__c = 'Post Board';
			acctplan1.WinningPropostion__c = 'Test Class';
			insert acctplan1;

			AcctPlanActionPlan__c acctplan2 = new AcctPlanActionPlan__c();
			acctplan2.AcctPlanWalletByDomain__c = walltbyDomain[2].id;
			acctplan2.Objective__c = 'Acquire New customers';
			acctplan2.Status__c = 'Post Board';
			acctplan2.WinningPropostion__c = 'Test Class';
			insert acctplan2;

			AcctPlanActionPlan__c acctplan3 = new AcctPlanActionPlan__c();
			acctplan3.AcctPlanWalletByDomain__c = walltbyDomain[3].id;
			acctplan3.Objective__c = 'Acquire New customers';
			acctplan3.Status__c = 'Post Board';
			acctplan3.WinningPropostion__c = 'Test Class';
			insert acctplan3;

			AcctPlanActionPlan__c acctplan4 = new AcctPlanActionPlan__c();
			acctplan4.AcctPlanWalletByDomain__c = walltbyDomain[4].id;
			acctplan4.Objective__c = 'Acquire New customers';
			acctplan4.Status__c = 'Post Board';
			acctplan4.WinningPropostion__c = 'Test Class';
			insert acctplan4;

			AcctPlanActivity__c activity2 = new AcctPlanActivity__c();
			activity2.AccountPlanActionPlanID__c = acctplan1.id;
			activity2.Account__c = AccountList.get(0).id;
			activity2.Objective__c = 'Acquire New customers';
			activity2.Status__c = 'Post Board';
			activity2.Group__c = 'Group 1 Relationship';
			activity2.Activities__c = 'Work on negative relationship';
			activity2.Date__c = System.Today();
			insert activity2;

			AcctPlanActivity__c activity3 = new AcctPlanActivity__c();
			activity3.AccountPlanActionPlanID__c = acctplan2.id;
			activity3.Account__c = AccountList.get(0).id;
			activity3.Objective__c = 'Acquire New customers';
			activity3.Status__c = 'Post Board';
			activity3.Group__c = 'Group 1 Relationship';
			activity3.Activities__c = 'Work on negative relationship';
			activity3.Date__c = System.Today();
			activity3.CustomerCounterparties__c = cont1.id;
			insert activity3;

			AcctPlanActivity__c activity4 = new AcctPlanActivity__c();
			activity4.AccountPlanActionPlanID__c = acctplan2.id;
			activity4.Account__c = AccountList.get(0).id;
			activity4.Objective__c = 'Acquire New customers';
			activity4.Status__c = 'Post Board';
			activity4.Group__c = 'Group 1 Relationship';
			activity4.Activities__c = 'Work on negative relationship';
			activity4.Date__c = System.Today();
			insert activity4;

			AcctPlanActivity__c activity5 = new AcctPlanActivity__c();
			activity5.AccountPlanActionPlanID__c = acctplan3.id;
			activity5.Account__c = AccountList.get(0).id;
			activity5.Objective__c = 'Acquire New customers';
			activity5.Status__c = 'Post Board';
			activity5.Group__c = 'Group 1 Relationship';
			activity5.Activities__c = 'Work on negative relationship';
			activity5.Date__c = System.Today();
			activity5.CustomerCounterparties__c = cont1.id;
			insert activity5;

			AcctPlanActivity__c activity6 = new AcctPlanActivity__c();
			activity6.AccountPlanActionPlanID__c = acctplan3.id;
			activity6.Account__c = AccountList.get(0).id;
			activity6.Objective__c = 'Acquire New customers';
			activity6.Status__c = 'Post Board';
			activity6.Group__c = 'Group 1 Relationship';
			activity6.Activities__c = 'Work on negative relationship';
			activity6.Date__c = System.Today();
			insert activity6;

			AcctPlanActivity__c activity7 = new AcctPlanActivity__c();
			activity7.AccountPlanActionPlanID__c = acctplan4.id;
			activity7.Account__c = AccountList.get(0).id;
			activity7.Objective__c = 'Acquire New customers';
			activity7.Status__c = 'Post Board';
			activity7.Group__c = 'Group 1 Relationship';
			activity7.Activities__c = 'Work on negative relationship';
			activity7.Date__c = System.Today();
			activity7.CustomerCounterparties__c = cont1.id;
			insert activity7;

			AcctPlanActivity__c activity8 = new AcctPlanActivity__c();
			activity8.AccountPlanActionPlanID__c = acctplan4.id;
			activity8.Account__c = AccountList.get(0).id;
			activity8.Objective__c = 'Acquire New customers';
			activity8.Status__c = 'Post Board';
			activity8.Group__c = 'Group 1 Relationship';
			activity8.Activities__c = 'Work on negative relationship';
			activity8.Date__c = System.Today();
			insert activity8;

			AcctPlanNIProject__c nirecord = new AcctPlanNIProject__c();
			nirecord.AcctPlanActionPlanID__c = acctplan1.id;
			nirecord.PropsProductOrServices__c = 'OD';
			nirecord.ExpectedIncremental__c = 10000;
			nirecord.TypeOfNI__c = 'NIIc';
			nirecord.TypeOfFee__c = 'L/G fee';

			nirecord.NIRecuringType__c = 'Recurring';
			nirecord.ExpectedNimRate__c = 10.00;
			nirecord.ExpectedIncrementalNIPerYear1Year__c = 10000;
			nirecord.ExpectedIncrementalNIPerYear2Year__c = 10000;
			nirecord.ExpectedIncrementalFeePerYear2Year__c = 10000;
			nirecord.ExpectedIncrementalFeePerYear1Year__c = 10000;
			nirecord.NIStartMonth__c = 'Jan';
			nirecord.NIStartYear__c = '2016';
			nirecord.DealProbability__c = '25%';
			insert nirecord;
			AccountPlanRefreshService.RefreshCompanyPerformanceProductStrategyForStep6(comprofile.Id, AcctPlanwallet.Id, groupprofile.id);
			//	AccountPlanRefreshService.RefreshProductStrategyAndWalletByDomain(new Set<Id>{comprofile.Account__c},year,groupprofile.id);

			AccountPlanRefreshService.RefreshGroupPerformance(new Set<Id> { comprofile.Account__c }, year);
			AccountPlanRefreshService.RefreshProductStrategy(new Set<Id> { comprofile.Account__c }, year,groupprofile.Id);

			Test.stopTest();
		}

	}

	@isTest
	private static void test_UpsertCustomerUnderstanding() {

		//Create Account
		Account testAccount = new Account();
		testAccount.Name = 'Test AccountPlan Step5';
        testAccount.Phone ='050111222';
        testAccount.Mobile_Number_PE__c  = '0801112233';
		insert testAccount;

		//Create Contact
		Contact cont = new Contact();
		cont.FirstName = 'AccountPlan';
		cont.LastName = 'Step5';
		cont.Position__c = 'Manager';
		cont.Accountid = testAccount.id;
		insert cont;

		//Create Account Plan
		AcctPlanCompanyProfile__c Company = new AcctPlanCompanyProfile__c();
		Company.Account__c = testAccount.id;
		//Company.Name = 'AccountPlan Step5';
		insert Company;

		AcctPlanWallet__c Wallet = new AcctPlanWallet__c();
		Wallet.AcctPlanCompanyProfile__c = Company.id;
		insert Wallet;

		List<AcctPlanCusUnderstanding__c> lstUnder = new List<AcctPlanCusUnderstanding__c> ();
		AcctPlanCusUnderstanding__c under1 = new AcctPlanCusUnderstanding__c();
		under1.AcctPlanWallet__c = Wallet.Id;
		lstUnder.add(under1);
		insert lstUnder;
		List<AcctAnnualPerformance__c> lstPerformancea = new List<AcctAnnualPerformance__c> ();
		AcctAnnualPerformance__c performance = new AcctAnnualPerformance__c();
		performance.Account__c = testAccount.Id;
		performance.AVG_LOAN_OUT__c = 1000000;
		performance.ENG_LOAN_OUT__c = 1000000;
		performance.AVG_CASA__c = 1000000;
		performance.END_CASA__c = 1000000;
		performance.TF_VOLUME__c = 1000000;
		performance.FX_VOLUME__c = 1000000;
		performance.TMB_CUST_ID__c = 'ID0000001';
		lstPerformancea.add(performance);
		insert lstPerformancea;


		AccountPlanRefreshServiceImpl impl = new AccountPlanRefreshServiceImpl();

		impl.UpsertCustomerUnderstanding(lstPerformancea, lstUnder, Wallet.Id);
		impl.UpsertCustomerUnderstanding(lstPerformancea, new List<AcctPlanCusUnderstanding__c> (), Wallet.Id);
		impl.UpsertCustomerUnderstanding(new List<AcctAnnualPerformance__c> (), new List<AcctPlanCusUnderstanding__c> (), Wallet.Id);
		impl.UpsertCustomerUnderstanding(new List<AcctAnnualPerformance__c> (), lstUnder, Wallet.Id);
	}

	@isTest
	private static void test_RefreshDepositInter() {
		//Create Account
		Account testAccount = new Account();
		testAccount.Name = 'Test AccountPlan Step5';
        testAccount.Phone ='050111222';
        testAccount.Mobile_Number_PE__c  = '0801112233';
		insert testAccount;

		//Create Contact
		Contact cont = new Contact();
		cont.FirstName = 'AccountPlan';
		cont.LastName = 'Step5';
		cont.Position__c = 'Manager';
		cont.Accountid = testAccount.id;
		insert cont;

		//Create Account Plan
		AcctPlanCompanyProfile__c Company = new AcctPlanCompanyProfile__c();
		Company.Account__c = testAccount.id;
		//Company.Name = 'AccountPlan Step5';
		insert Company;

		AcctPlanWallet__c Wallet = new AcctPlanWallet__c();
		Wallet.AcctPlanCompanyProfile__c = Company.id;
		insert Wallet;

		//1) Current - USD
		AcctPlanDepositInternational__c item1 = new AcctPlanDepositInternational__c();
		item1.Label_Value__c = '1) Current - USD';
		item1.AccountPlanDepositInternationalDeposit__c = Wallet.Id;
		insert item1;
		//Current - Other Currency
		AcctPlanDepositInternational__c item2 = new AcctPlanDepositInternational__c();
		item2.Label_Value__c = 'Current - Other Currency';
		item2.AccountPlanDepositInternationalDeposit__c = Wallet.Id;
		insert item2;

		AcctPlanDepositDomestic__c domestics = new AcctPlanDepositDomestic__c();
		domestics.Label_Value__c = '1) Current';
		domestics.AccountPlanDepositDomesticDeposit__c = Wallet.Id;
		insert domestics;

		//Current Id = 000037
		//Saving Account id = 4185320137
		//BOND Id = 3216118306
		Map<String, Product2> ProductMaster = new Map<String, Product2> ();
		for (Product2 item :[Select Id, Family, Product_Domain__c, Product_Level__c, ProductCode, SF_Product_Key__c, Name From Product2 Where SF_Product_Key__c = '537310893']) {
			ProductMaster.put(item.Name, item);
		}
		List<Product_Performance__c> newPer = new List<Product_Performance__c> ();

		for (string item : ProductMaster.keySet())
		{
			Product2 pro = ProductMaster.get(item);
			system.debug(':::: Product Name >> ' + pro.Name);
			Product_Performance__c per1 = new Product_Performance__c();
			per1.Account__c = testAccount.Id;
			per1.Ending_OS_YTD__c = 100000;
			per1.Product_Description__c = '?????????????????? ?????? 12 ?????';
			//per1.Product_Domain__c = 'Deposit & investment';
			per1.Product_Hierachy_Code__c = pro.id;
			per1.Product_Name__c = pro.Name;
			per1.Rate__c = 1.00;
			per1.ISO_CURRENCY_CD__c = 'USD';


			Product_Performance__c per2 = new Product_Performance__c();
			per2.Account__c = testAccount.Id;
			per2.Ending_OS_YTD__c = 100000;
			per2.Product_Description__c = '?????????????????? ?????? 12 ?????';
			//per2.Product_Domain__c = 'Deposit & investment';
			per2.Product_Hierachy_Code__c = pro.id;
			per2.Product_Name__c = pro.Name;
			per2.Rate__c = 1.00;
			per2.ISO_CURRENCY_CD__c = 'JPY';


			Product_Performance__c per3 = new Product_Performance__c();
			per3.Account__c = testAccount.Id;
			per3.Ending_OS_YTD__c = 100000;
			per3.Product_Description__c = '?????????????????? ?????? 12 ?????';
			//per2.Product_Domain__c = 'Deposit & investment';
			per3.Product_Hierachy_Code__c = pro.id;
			per3.Product_Name__c = pro.Name;
			per3.Rate__c = 1.00;
			per3.ISO_CURRENCY_CD__c = 'THB';


			newPer.add(per2);
			newPer.add(per1);
		}
		Insert newPer;



		Test.startTest();

		AccountPlanRefreshService.RefreshDepositInter(Company.Id, Wallet.Id, '');
		AccountPlanRefreshService.RefreshDepositDomestic(Company.Id, Wallet.Id, '');
		Test.stopTest();


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