public without sharing class AccountPlanRefreshServiceImpl implements IAccountPlanRefreshService {
	/*********************************************************************************************************************
	 *   Support sheet 3 Domain 2
	 *********************************************************************************************************************/
	public static boolean RefreshDepositInter(String acctPlanCompanyId, String acctPlanWallet, String acctPlanGruopId) {

		List<AcctPlanCompanyProfile__c> companyProfiles = AccountPlanCompanyProfileSelector.getCompanyProfileIds(new set<id> { acctPlanCompanyId });
		AcctPlanCompanyProfile__c companyProfile = companyProfiles[0];
		boolean ret = true;
		System.debug(':::: Wallet Id = ' + acctPlanWallet);
		AcctPlanWallet__c wallet;
		List<AcctPlanWallet__c> wallets = AccountPlanWalletSelector.getWalletByIds(new Set<Id> { acctPlanWallet });
		//If Wallet if not exist return false
		if (wallets.size() == 0) {
			return false;
		}

		/*********************************************************************************************************************
		 *  STEP 1) Find Current Account Plan wallet
		 *********************************************************************************************************************/
		wallet = wallets[0];
		System.debug(':::: Found Wallet');

		/*********************************************************************************************************************
		 *   STEP 2) DepositInter
		 *   NOTE : For each Wallet will have only 6  items
		 *********************************************************************************************************************/
		List<AcctPlanDepositInternational__c> interes = AccountPlanDepositInternationalSelector.GetAccountPlanDepositInternationalByWalletIds(new set<id> { acctPlanWallet });
		Map<string, AcctPlanDepositInternational__c> interMap = new Map<string, AcctPlanDepositInternational__c> ();
		for (AcctPlanDepositInternational__c item : interes) {
			interMap.put(item.Label__c, item);
		}

		/*********************************************************************************************************************
		 *   STEP 3) Calulate DepositDomestic Summary
		 *********************************************************************************************************************/
		Map<string, TMBShare> newDatas = CalulateDepositInterSummary(interes, companyProfile.Account__c);

		/*********************************************************************************************************************
		 *   STEP 4) Update Data
		 *********************************************************************************************************************/
		for (string label : interMap.keySet()) {
			if (newDatas.containsKey(label)) {
				System.debug('::: Label =' + label);

				System.debug('::: Is newDatas Contain Label = ' + newDatas.containsKey(label));
				AcctPlanDepositInternational__c item = interMap.get(label);
				TMBShare newValue = newDatas.get(label);
				//item.ShareTMBPercent__c =newValue.SharePercentage;
				item.TMBAmount__c = newValue.Amount;
				item.TMBRate__c = newValue.Rate;

				System.debug('::: Refresh International  Values = ' + newValue);
				interMap.put(label, item);
			}
		}

		try {
			update interMap.values();
		} catch(Exception ex) {
			throw ex;
		}
		return ret;
	}

	// Calulate  DepositInter
	public static Map<string, TMBShare> CalulateDepositInterSummary(List<AcctPlanDepositInternational__c> interes, id accountId) {
		Map<id, Product2> mapProductIds = new Map<id, Product2> (ProductSelector.getProductForAccountPlanWallet());
		System.debug(':::: mapProductIds =  ' + mapProductIds);

		/******************************************************************************************************
		 *    Make Return Dto to each rows
		 * ****************************************************************************************************/
		Map<string, TMBShare> newValues = new Map<string, TMBShare> ();
		for (AcctPlanDepositInternational__c item : interes) {
			if (!newValues.containsKey(item.Label__c)) {
				newValues.put(item.Label__c, new TMBShare(0.0, 0.0, 0.0));
			}
		}

		/******************************************************************************************************
		 *    Query all data from Product Infomation Detail
		 * ****************************************************************************************************/
		Map<string /*label*/, List<Product_Performance__c>> dataUsds = new Map<string /*label*/, List<Product_Performance__c>> ();
		for (string label : AccountPlanConfig.getMapDepositInterUsd.values()) {
			if (!dataUsds.containsKey(label)) {
				dataUsds.put(label, new List<Product_Performance__c> ());
			}
		}

		Map<string /*label*/, List<Product_Performance__c>> dataOthers = new Map<string /*label*/, List<Product_Performance__c>> ();
		for (string label : AccountPlanConfig.getMapDepositInterOther.values()) {
			if (!dataOthers.containsKey(label)) {
				dataOthers.put(label, new List<Product_Performance__c> ());
			}
		}

		/******************************************************************************************************
		 *    Data for each rows 
		 * ****************************************************************************************************/
		for (Product_Performance__c item : ProductPerformanceSelector.getProductPerformanceOther(accountId)) {

			/*********************************************************************
			 *  Check Currency
			 * ******************************************************************/
			if (item.ISO_CURRENCY_CD__c == 'USD') {

				System.debug(':::: USD Product Domain  =  ' + item.Product_Hierachy_Code__r.Name.toLowerCase());
				string label = AccountPlanConfig.getMapDepositInterUsd.get(item.Product_Hierachy_Code__r.Name.toLowerCase());
				dataUsds.get(label).add(item);
			}
			else {
				System.debug(':::: Other Product Domain  =  ' + item.Product_Hierachy_Code__r.Name.toLowerCase());
				string label = AccountPlanConfig.getMapDepositInterOther.get(item.Product_Hierachy_Code__r.Name.toLowerCase());
				dataOthers.get(label).add(item);
			}
		}


		// USD
		for (string label : dataUsds.keySet()) {
			// Get all product information
			decimal totalAmount = 0.0;
			decimal totalAmtbyPercent = 0.0;
			for (Product_Performance__c item : dataUsds.get(label)) {

				decimal limitbalance = item.Ending_OS_YTD__c == null ? 0 : item.Ending_OS_YTD__c;
				decimal rate = item.Rate__c == null ? 0 : item.Rate__c;
				totalAmount += limitbalance;
				totalAmtbyPercent += (limitbalance * rate);
			}
			//Update value back
			if (newValues.containsKey(label)) {
				TMBShare udt = newValues.get(label);
				udt.Amount = totalAmount;
				if (totalAmount != 0.0)
				udt.Rate = totalAmtbyPercent / totalAmount;
				else
				udt.Rate = 0;
				system.debug('USD New value for ' + label + '  with  Amount  = ' + udt.Amount + ' Rate = ' + udt.Rate);
				newValues.put(label, udt);
			}
		}
		// Other
		for (string label : dataOthers.keySet()) {
			// Get all product information
			decimal totalAmount = 0.0;
			decimal totalAmtbyPercent = 0.0;
			for (Product_Performance__c item : dataOthers.get(label)) {

				decimal limitbalance = item.Ending_OS_YTD__c == null ? 0 : item.Ending_OS_YTD__c;
				decimal rate = item.Rate__c == null ? 0 : item.Rate__c;
				totalAmount += limitbalance;
				totalAmtbyPercent += (limitbalance * rate);
			}
			//Update value back
			if (newValues.containsKey(label)) {
				TMBShare udt = newValues.get(label);
				udt.Amount = totalAmount;
				if (totalAmount != 0.0)
				udt.Rate = totalAmtbyPercent / totalAmount;
				else
				udt.Rate = 0;
				system.debug('Other New value for ' + label + '  with  Amount  = ' + udt.Amount + ' Rate = ' + udt.Rate);
				newValues.put(label, udt);
			}
		}
		return newValues;
	}

	public static boolean RefreshDepositDomestic(String acctPlanCompanyId, String acctPlanWallet, String acctPlanGruopId) {
		boolean ret = true;
		System.debug(':::: Wallet Id = ' + acctPlanWallet);

		List<AcctPlanCompanyProfile__c> companyProfiles = AccountPlanCompanyProfileSelector.getCompanyProfileIds(new set<id> { acctPlanCompanyId });
		AcctPlanCompanyProfile__c companyProfile = companyProfiles[0];


		AcctPlanWallet__c wallet;
		List<AcctPlanWallet__c> wallets = AccountPlanWalletSelector.getWalletByIds(new Set<Id> { acctPlanWallet });
		//If Wallet if not exist return false
		if (wallets.size() == 0) {
			return false;
		}

		// 1) Find Wallet
		wallet = wallets[0];
		System.debug(':::: Found Wallet');
		// 2) DepositDomestic
		//    For each Wallet will have only 6  items
		List<AcctPlanDepositDomestic__c> domestics
		= AccountPlanDepositDomesticSelector.GetAccountPlanDepositDomesticByWalletIds(new set<id> { acctPlanWallet });


		Map<string, AcctPlanDepositDomestic__c> domesticsMap = new Map<string, AcctPlanDepositDomestic__c> ();

		for (AcctPlanDepositDomestic__c item : domestics) {
			domesticsMap.put(item.Label__c, item);
		}

		// 3) Calulate DepositDomestic Summary
		System.debug(':::: CalulateDepositDomesticSummary ');
		Map<string, TMBShare> newDatas = CalulateDepositDomesticSummary(domestics, companyProfile.Account__c);


		// 4) Update Data
		for (string label : domesticsMap.keySet()) {
			if (newDatas.containsKey(label)) {
				System.debug('::: Label =' + label);

				System.debug('::: Is newDatas Contain Label = ' + newDatas.containsKey(label));
				AcctPlanDepositDomestic__c item = domesticsMap.get(label);
				TMBShare newValue = newDatas.get(label);
				//item.ShareTMBPercent__c =newValue.SharePercentage;
				item.TMBAmount__c = newValue.Amount;
				item.TMBRate__c = newValue.Rate;

				System.debug('::: Refresh Values = ' + newValue);
				domesticsMap.put(label, item);
			}
		}

		for (AcctPlanDepositDomestic__c item : domesticsMap.values()) {
			System.debug('::: item = ' + item);
		}


		try {
			update domesticsMap.values();
		} catch(Exception ex) {
			throw ex;
		}
		return ret;
	}
	// Calulate  DepositDomestic
	public static Map<string, TMBShare> CalulateDepositDomesticSummary(List<AcctPlanDepositDomestic__c> domestics, id accountId) {




		/******************************************************************************************************
		 *    Make Return Dto to each rows
		 * ****************************************************************************************************/
		Map<string /*label*/, TMBShare> newValues = new Map<string, TMBShare> ();
		System.debug(':::: accountId =  ' + accountId);

		for (string label : AccountPlanConfig.getMapDepositDemestic.values()) {
			if (!newValues.containsKey(label)) {
				newValues.put(label, new TMBShare(0.0, 0.0, 0.0));
			}
		}


		/******************************************************************************************************
		 *    Query all data from Product Infomation Detail
		 * ****************************************************************************************************/
		Map<string /*label*/, List<Product_Performance__c>> datas = new Map<string /*label*/, List<Product_Performance__c>> ();


		for (string label : AccountPlanConfig.getMapDepositDemestic.values()) {
			if (!datas.containsKey(label)) {
				datas.put(label, new List<Product_Performance__c> ());
			}
		}


		/******************************************************************************************************
		 *    Data for each rows 
		 * ****************************************************************************************************/

		for (Product_Performance__c item : ProductPerformanceSelector.getProductPerformanceTHB(accountId)) {

			System.debug(':::: Product Domain  =  ' + item.Product_Hierachy_Code__r.Name.toLowerCase());
			string label = AccountPlanConfig.getMapDepositDemestic.get(item.Product_Hierachy_Code__r.Name.toLowerCase());
			datas.get(label).add(item);
		}

		System.debug(':::: datas size  =  ' + datas.size());
		for (string label : datas.keySet()) {
			// Get all product information
			decimal totalAmount = 0.0;
			decimal totalAmtbyPercent = 0.0;
			for (Product_Performance__c item : datas.get(label)) {

				decimal limitbalance = item.Ending_OS_YTD__c == null ? 0 : item.Ending_OS_YTD__c;
				decimal rate = item.Rate__c == null ? 0 : item.Rate__c;
				totalAmount += limitbalance;
				totalAmtbyPercent += (limitbalance * rate);
			}
			//Update value back
			if (newValues.containsKey(label)) {
				TMBShare udt = newValues.get(label);
				udt.Amount = totalAmount;
				if (totalAmount != 0.0)
				udt.Rate = totalAmtbyPercent / totalAmount;
				else
				udt.Rate = 0;
				system.debug('New value for ' + label + '  with  Amount  = ' + udt.Amount + ' Rate = ' + udt.Rate);
				newValues.put(label, udt);
			}
		}
		// Mock Data     
		system.debug('::: Mock Data = ' + newValues);
		return newValues;
	}

	public class TMBShare {
		public TMBShare(decimal sharePercentage, decimal amount, decimal rate) {
			this.SharePercentage = sharePercentage;
			this.Amount = amount;
			this.Rate = rate;
		}
		public decimal SharePercentage { get; set; }
		public decimal Amount { get; set; }
		public decimal Rate { get; set; }

	}

	/********************************************************************************************************
	 *  Refresh Group Wallet New 
	 * *****************************************************************************************************/
	public void RefreshGroupPerformance(Set<Id> accountIds, string year) {
		system.debug('::: CALL RefreshGroupPerformance with year is = ' + year);
		system.debug('::: CALL RefreshGroupPerformance with account is = ' + accountIds);






		// Mapping Type Of Wallet To SEQ
		Map<String, Decimal> labelToSeq = new Map<String, Decimal> {
			'NIIc' => 1.00,
			'NIId' => 2.00,
			'TF Fee' => 5.00,
			'FX fee' => 6.00,
			'L/G fee' => 7.00,
			'Cash fee' => 8.00,
			'AS Fee' => 9.00,
			'Credit Fee' => 11.00,
			'BA fee' => 12.00,
			'Derivative fee' => 13.00,
			'IB Fee' => 14.00
		};

		//Find AcctPlanNIProject__c 
		Set<Id> walletIds = new Set<Id> ();
		Map<Id /*Account Id*/, List<AcctPlanNIProject__c>> mapAccountToNIProject = new Map<Id /*Account Id*/, List<AcctPlanNIProject__c>> ();
		for (AcctPlanNIProject__c item : AccountPlanNIProjectSelector.getNIProjectByActionPlansByYearAndAccountIds(year, accountIds)) {
			if (item.TypeOfNI__c != null || item.TypeOfFee__c != null) {

				// Get WalletId
				Id walletId = item.AcctPlanActionPlanId__r.AcctPlanWalletByDomain__r.AcctPlanWallet__c;
				walletIds.add(walletId);
				Id accouontId = item.AcctPlanActionPlanId__r.AcctPlanWalletByDomain__r.AcctPlanWallet__r.AcctPlanCompanyProfile__r.Account__c;

				if (!mapAccountToNIProject.containsKey(accouontId)) {
					mapAccountToNIProject.put(accouontId, new List<AcctPlanNIProject__c> ());
				}
				mapAccountToNIProject.get(accouontId).add(item);
			}
		}


		//Product Strategy
		Map<id /*Account*/, Map<decimal, AcctPlanProdStrategy__c>> mapAccountIdAcctPlanProdStrategy = new Map<id /*Account*/, Map<decimal, AcctPlanProdStrategy__c>> ();
		Map<id, id> mapCompanyProfileIds = new Map<id, id> ();
		for (AcctPlanProdStrategy__c item : AccountPlanProductStrategySelector.selectProductStrategyByAccountIds(accountIds, year)) {
			if (!mapAccountIdAcctPlanProdStrategy.containsKey(item.AccountId__c)) {
				mapAccountIdAcctPlanProdStrategy.put(item.AccountId__c, new Map<decimal, AcctPlanProdStrategy__c> ());
				mapCompanyProfileIds.put(item.AcctPlanCompanyProfileID__c, item.AcctPlanCompanyProfileID__c);
			}
			mapAccountIdAcctPlanProdStrategy.get(item.AccountId__c).put(item.SEQ__c, item);
		}

		Map<string /*Account - SEQ */, AcctPlanProdStrategy__c> fastUpdate = new Map<string /*Account - SEQ */, AcctPlanProdStrategy__c> ();
		//For Each Accoount
		for (Id /*Account Id */ accountID : mapAccountToNIProject.keySet()) {

			//List Of AcctPlanNIProject__c
			for (AcctPlanNIProject__c item : mapAccountToNIProject.get(accountID)) {
				string key = '';

				// Type Of NI
				if (item.TypeOfNI__c != null) {
					decimal seqNi = labelToSeq.get(item.TypeOfNI__c);
					key = accountID + '-' + seqNi;
					AcctPlanProdStrategy__c proStr = mapAccountIdAcctPlanProdStrategy.get(accountID).get(seqNi);
					if (!fastUpdate.containsKey(key)) {
						proStr.ExpectedIncrementalNIFromStep5__c = 0;
						fastUpdate.put(key, proStr);
					}
					fastUpdate.get(key).ExpectedIncrementalNIFromStep5__c += item.ExpectedIncrementalNIPerYear1Year__c; // Type Of NI

				}

				// Type Of FEE
				if (item.TypeOfFee__c != null) {
					decimal seqFee = labelToSeq.get(item.TypeOfFee__c);
					key = accountID + '-' + seqFee;
					AcctPlanProdStrategy__c proStr = mapAccountIdAcctPlanProdStrategy.get(accountID).get(seqFee);
					if (!fastUpdate.containsKey(key)) {

						proStr.ExpectedIncrementalNIFromStep5__c = 0;
						fastUpdate.put(key, proStr);
					}

					fastUpdate.get(key).ExpectedIncrementalNIFromStep5__c += item.ExpectedIncrementalFeePerYear1Year__c; // Type Of FEE
				}

			}

		}
		update fastUpdate.values();
	}

	//region RefreshWalletAndAnnualPerformanceRolling12Month
	/******************************************************************************************
	 *  Refresh for AccountPlanPortfolioManagement visualforce page function : RefreshFunction
	 ******************************************************************************************/
	public Boolean RefreshWalletAndAnnualPerformanceRolling12Month(Set<ID> listPortfolioId) {
		datetime currentDt = datetime.now();
		// List Of Account Id in specific portfolio
		Map<Id, AcctPlanCompanyPort__c> accountIds = new Map<Id, AcctPlanCompanyPort__c> ();


		Map<Id /*Account Id */, Decimal /* Annual perfoance*/> mapIdAnnual = new Map<Id, Decimal> ();
		Map<Id /*Account Id */, Decimal /* Fee_Wallet__c */> mapIdWallet = new Map<Id, Decimal> ();

		decimal TotalPortFolioPerformance = 0;
		decimal TotalPortFoliowalllet = 0;
		List<Id> listPortfolioIds = new List<Id> (listPortfolioId);

		// Current Version support 1 portfolio at a time
		id portId = listPortfolioIds[0];


		/************************************************
		 * All Account in portfolio
		 *************************************************/
		for (AcctPlanCompanyPort__c port : AccountPlanCompanyPortSelector.getAllAccountInPortfolioIds(listPortfolioId)) {
			accountIds.put(port.Account__c, port); }
		system.debug('::: Account Id >> ' + accountIds);
		/******************************************************************
		 * 1) Calculat Annual Performance
		 *******************************************************************/
		System.debug('::: Calculat Annual Performance :::');
		integer count = 0;
		Id currentId = null;
		if (accountIds.size() > 0)
		{


			for (AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo item
			     : AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDateInGroupMap(accountIds.keySet(), currentDt).values()) {
				Decimal niic = item.NIIc == null ? 0 : item.NIIc;
				Decimal niid = item.NIId == null ? 0 : item.NIId;
				Decimal fee = item.Fee == null ? 0 : item.Fee;
				Decimal total = niic + niid + fee;

				TotalPortFolioPerformance += total;

				mapIdAnnual.put(item.AccouontId, total);
			}
		}
		// if Not have performance set 0 as default
		for (Id accountId : accountIds.keySet()) {
			if (!mapIdAnnual.containsKey(accountId)) {
				mapIdAnnual.put(accountId, 0);
			}
		}

		System.debug('::: End Calculat Annual Performance :::');
		/******************************************************************
		 * 2) Query Wallet
		 *******************************************************************/
		// 2.1 NORMAL CASE
		System.debug('::: Query Wallet :::');
		for (Account wallet :[SELECT Id, NIIc_Wallet__c, Fee_Wallet__c, NIId_Wallet__c FROM Account Where Id IN :accountIds.keySet()]) {
			Decimal val1 = wallet.Fee_Wallet__c == null ? 0 : wallet.Fee_Wallet__c;
			Decimal val2 = wallet.Fee_Wallet__c == null ? 0 : wallet.NIIc_Wallet__c;
			Decimal val3 = wallet.NIId_Wallet__c == null ? 0 : wallet.NIId_Wallet__c;

			decimal total = val1 + val2 + val3;

			mapIdWallet.put(wallet.Id, total);
			TotalPortFoliowalllet += total;
		}
		// if Not have performance set 0 as default
		for (Id accountId : accountIds.keySet()) {
			if (!mapIdWallet.containsKey(accountId)) {
				mapIdWallet.put(accountId, 0);
			}
		}
		// SE ACCOUNT 




		System.debug('::: End Query Wallet :::');
		/******************************************************************
		 * 3)   Update AcctPlanCompanyPort__c
		 ********************************************************************/
		System.debug('::: Update AcctPlanCompanyPort__c :::');
		List<AcctPlanCompanyPort__c> fastUpdate = new List<AcctPlanCompanyPort__c> ();
		for (AcctPlanCompanyPort__c companyPort : accountIds.values()) {
			AcctPlanCompanyPort__c acc
			= new AcctPlanCompanyPort__c(Id = companyPort.Id
			                             , Wallet__c = mapIdWallet.get(companyPort.Account__c)
			                             , Performance__c = mapIdAnnual.get(companyPort.Account__c));

			fastUpdate.add(acc);
		}
		update fastUpdate;


		System.debug('::: SumOfWallet__c = ' + TotalPortFoliowalllet + ' ||   SumOfPerformance__c = ' + TotalPortFolioPerformance);
		AcctPlanPortfolio__c port = new AcctPlanPortfolio__c(id = portId, SumOfWallet__c = TotalPortFoliowalllet, SumOfPerformance__c = TotalPortFolioPerformance);
		update port;
		System.debug('::: End Update AcctPlanCompanyPort__c :::');

		//region Da

		//DA:
		System.debug('::: DA :::');
		Map<Id, Decimal> mapExpectedNI = new Map<Id, Decimal> ();
		Map<String, List<Decimal>> mapCompaniesList = new Map<String, List<Decimal>> ();
		Map<Id /* CompanyID */, Id /* AccountID */> mapCompanyID = new Map<Id, Id> ();
		Map<Id, AcctPlanCompanyProfile__c> mapCompanyIds = new Map<Id, AcctPlanCompanyProfile__c> ();
		
        /*=========== Fixed issue Expexted NI Step 0 : Jantanee =============*/
        /*for (AcctPlanCompanyProfile__c comprofile : AccountPlanCompanyProfileSelector.getCompanyProfileIdByPortfolioIds(listPortfolioId)) {
            mapCompanyIds.put(comprofile.Id, comprofile);
        }*/
        
        AcctPlanPortfolio__c portfolio = AccountPlanUtilities.QueryPortfolioByID(portId);
        String PortfolioOwnerId = portfolio.OwnerId;
        for (AcctPlanCompanyProfile__c comprofile : [Select Id, Name, Account__c, AcctPlanGroup__c, Portfolio__c,OwnerId
                                                     From AcctPlanCompanyProfile__c 
                                                     Where ( OwnerId =: PortfolioOwnerId)  
                                                     AND Portfolio__c IN : listPortfolioId 
                                                    //AND isActive__c = true
                                                    ]){
         mapCompanyIds.put(comprofile.Id, comprofile);
        }   
        
		//System.debug('mapCompanyIds : ' +mapCompanyIds);
		if (mapCompanyIds.size() > 0) {
			for (AcctPlanProdStrategy__c proStrategy :
			     AccountPlanProductStrategySelector.selectProductStrategyByIds(mapCompanyIds.keySet())) {

				if (proStrategy.SEQ__c <= 14) {

					Decimal expectedNI = proStrategy.TotalCompanyNI__c == null ? 0 : proStrategy.TotalCompanyNI__c;

					if (!mapCompaniesList.containsKey(proStrategy.AcctPlanCompanyProfileID__c)) {

						List<Decimal> valueList = new List<Decimal> ();
						valueList.add(expectedNI);

						mapCompaniesList.put(proStrategy.AcctPlanCompanyProfileID__c, valueList);

						mapCompanyID.put(proStrategy.AcctPlanCompanyProfileID__c, proStrategy.AcctPlanCompanyProfileID__r.Account__c);
					} else {
						mapCompaniesList.get(proStrategy.AcctPlanCompanyProfileID__c).add(expectedNI);
					}
				}
			}
			//System.debug('mapCompaniesList : ' +mapCompaniesList);

			//calculateExpectedNI
			System.debug('::: calculateExpectedNI :::');

			for (ID comid : mapCompanyID.keySet()) {
				if (mapCompanyID.containsKey(comid)) {
					ID mapAccountId = mapCompanyID.get(comid);
					Decimal feeTotal = mapCompaniesList.get(comid) [4] +
					mapCompaniesList.get(comid) [5] +
					mapCompaniesList.get(comid) [6] +
					mapCompaniesList.get(comid) [7] +
					mapCompaniesList.get(comid) [8] +
					mapCompaniesList.get(comid) [9] +
					mapCompaniesList.get(comid) [10] +
					mapCompaniesList.get(comid) [11] +
					mapCompaniesList.get(comid) [12] +
					mapCompaniesList.get(comid) [13];
					Decimal total =
					/*1. NIIc */ mapCompaniesList.get(comid) [0] +
					/*2. NIId */ mapCompaniesList.get(comid) [1] +
					/*3. Fee  */ feeTotal; //mapCompaniesList.get(comid)[2];

					mapExpectedNI.put(mapAccountId, total);
					//System.debug('::: total ::: '+ total);
				}
			}
			//System.debug('mapExpectedNI :' + mapExpectedNI);
			System.debug('::: End calculateExpectedNI :::');
			// if Not have performance set 0 as default
			for (Id companyId : mapCompanyIds.keySet()) {
				if (!mapCompanyIds.containsKey(companyId)) {
					AcctPlanCompanyProfile__c comprofile = mapCompanyIds.get(companyId);
					if (!mapExpectedNI.containsKey(comprofile.Account__c)) {
						mapExpectedNI.put(comprofile.Account__c, 0);
					}
				}
			}

			/*---------------------------------------------------------------
			 * 3)                    Update AcctPlanCompanyPort__c
			 *---------------------------------------------------------------*/
			/*=========== Fixed issue Expexted NI Step 0 : Jantanee =============*/
            /*List<Id> acctComProfileID = new List<id>();
            for (Id companyId : mapCompanyIds.keySet()) {
                AcctPlanCompanyProfile__c comprofile = mapCompanyIds.get(companyId);
                acctComProfileID.add(comprofile.Account__c);
            }*/
            Map<Id,AcctPlanCompanyPort__c> comPortMap = new Map<Id,AcctPlanCompanyPort__c>(); 
            List<AcctPlanCompanyPort__c> comportUpdate = new List<AcctPlanCompanyPort__c>();
            
            for(AcctPlanCompanyPort__c comport: [SELECT Id, Account__c, Account_Plan_Portfolio__c, 
                                                 Account_Plan_Company_Profile__c ,ExpectedNIbyAccountPlan__c
                                                 FROM AcctPlanCompanyPort__c 
                                                 Where Account_Plan_Portfolio__c =: portId 
                                                 and Account_Plan_Company_Profile__c IN :mapCompanyIds.keySet() ]){
                comPortMap.put(comport.Account_Plan_Company_Profile__c,comport);                                  
            }
 
			System.debug('::: Update AcctPlanCompanyPort__c :::');
			for (Id companyId : mapCompaniesList.keySet()) {
				/*AcctPlanCompanyProfile__c comprofile = mapCompanyIds.get(companyId);
 
                AcctPlanCompanyPort__c comportInfo = AccountPlanCompanyPortSelector.getCompanyPortByPortfolioIdAndAccountId(comprofile.Portfolio__c, comprofile.Account__c);
                
                AcctPlanCompanyPort__c comport = new AcctPlanCompanyPort__c(Id = comportInfo.Id,
                                                                            ExpectedNIbyAccountPlan__c = mapExpectedNI.get(comprofile.Account__c));
                
                system.debug(':::comport >> ' + comprofile +','+mapExpectedNI.get(comprofile.Account__c));
 
                update comport;*/
                if(comPortMap.containsKey(companyId)){
                    AcctPlanCompanyPort__c comport = comPortMap.get(companyId);
                    comport.ExpectedNIbyAccountPlan__c = mapExpectedNI.get(comport.Account__c);
                    comportUpdate.add(comport);
                    //system.debug(':::comport >> ' + comport  +','+comport.ExpectedNIbyAccountPlan__c);
                } 
			}
            system.debug(':::comport >> ' + comportUpdate.size() );
            if(comportUpdate.size()>0){
                update comportUpdate;
            }
		}

		//endregion
		return true;
	}
	//endregion

	//region    RefreshCompanyPerformanceProductStrategyForStep6
	public Boolean RefreshCompanyPerformanceProductStrategyForStep6(String companyProfileId) {

		Map<String /*Type*/, List<Decimal>> mapTypeOfAll = new Map<String /*Type*/, List<Decimal>> ();
		Map<String /*Type*/, List<Decimal>> mapTypeOfFee = new Map<String /*Type*/, List<Decimal>> ();
		Map<String /*Type*/, List<Decimal>> mapTypeOfNI = new Map<String /*Type*/, List<Decimal>> ();
		Map<String, AcctPlanProdStrategy__c> mapProdStrategyNI = new Map<String, AcctPlanProdStrategy__c> ();

		List<AcctPlanWallet__c> wallets = AccountPlanWalletSelector.getWalletByCompanyProfileIds(new Set<Id> { companyProfileId });
		//system.debug('wallets : ' +wallets);
		if (wallets.size() > 0) {
			Map<Id, AcctPlanWallet__c> maplstWallet = new Map<Id, AcctPlanWallet__c> (wallets);

			List<AcctPlanWalletByDomain__c> lstWalletByDomain = AccountPlanWalletByDomainSelector.getWalletByDomainByWallets(maplstWallet.keySet());
			Map<Id, AcctPlanWalletByDomain__c> maplstWalletByDomain = new Map<Id, AcctPlanWalletByDomain__c> (lstWalletByDomain);
			//system.debug('lstWalletByDomain : ' +lstWalletByDomain);

			if (lstWalletByDomain.size() > 0) {
				List<AcctPlanActionPlan__c> lstActionPlan = AccountPlanActionPlanSelector.getActionPlanByWalletByDomains(maplstWalletByDomain.keySet());
				Map<Id, AcctPlanActionPlan__c> maplstActionPlan = new Map<Id, AcctPlanActionPlan__c> (lstActionPlan);
				//system.debug('lstActionPlan : ' +lstActionPlan);

				if (lstActionPlan.size() > 0) {
					List<AcctPlanNIProject__c> lstNIProject = AccountPlanNIProjectSelector.getNIProjectByActionPlans(maplstActionPlan.keySet());

					for (AcctPlanNIProject__c itemNIProject : lstNIProject) {
						//system.debug('itemNIProject.TypeOfNI__c : ' +itemNIProject.TypeOfNI__c + ', ' +itemNIProject.ExpectedIncrementalNIPerYear1Year__c );
						//system.debug('itemNIProject.TypeOfFee__c : ' +itemNIProject.TypeOfFee__c + ', ' +itemNIProject.ExpectedIncrementalFeePerYear1Year__c );

						//find type of NI
						if (itemNIProject.TypeOfNI__c != null) {

							if (itemNIProject.TypeOfNI__c == 'NIIc' || itemNIProject.TypeOfNI__c == 'NIId') {
								if (!mapTypeOfNI.containsKey(itemNIProject.TypeOfNI__c)) {
									mapTypeOfNI.put(itemNIProject.TypeOfNI__c, new List<Decimal> ());

									mapTypeOfNI.get(itemNIProject.TypeOfNI__c).add(0);
								}

								mapTypeOfNI.get(itemNIProject.TypeOfNI__c).add(itemNIProject.ExpectedIncrementalNIPerYear1Year__c);
								mapTypeOfNI.get(itemNIProject.TypeOfNI__c) [0] += itemNIProject.ExpectedIncrementalNIPerYear1Year__c;
							}
						}

						//find type of Fee
						if (itemNIProject.TypeOfFee__c != null) {

							if (!mapTypeOfFee.containsKey(itemNIProject.TypeOfFee__c)) {
								mapTypeOfFee.put(itemNIProject.TypeOfFee__c, new List<Decimal> ());

								mapTypeOfFee.get(itemNIProject.TypeOfFee__c).add(0);
							}

							mapTypeOfFee.get(itemNIProject.TypeOfFee__c).add(itemNIProject.ExpectedIncrementalFeePerYear1Year__c);
							mapTypeOfFee.get(itemNIProject.TypeOfFee__c) [0] += itemNIProject.ExpectedIncrementalFeePerYear1Year__c;
						}
					}
					//system.debug('mapTypeOfNI : ' +mapTypeOfNI); 
					//system.debug('mapTypeOfFee : ' +mapTypeOfFee); 

					//calculate ExpectedIncremental by NI
					for (String keyTypeNI : mapTypeOfNI.keySet()) {

						mapTypeOfAll.put(keyTypeNI.toUpperCase(), mapTypeOfNI.get(keyTypeNI));
					}

					//calculate ExpectedIncremental by Fee                    
					for (String keyTypeFee : mapTypeOfFee.keySet()) {

						mapTypeOfAll.put(keyTypeFee.toUpperCase(), mapTypeOfFee.get(keyTypeFee));
					}
					//system.debug('mapTypeOfAll : ' +mapTypeOfAll);


					AcctPlanProdStrategy__c FeeProdStr;
					for (AcctPlanProdStrategy__c prodStrategy :
					     AccountPlanProductStrategySelector.selectProductStrategyByIds(new Set<ID> { companyProfileId })) {

						String[] ntype = prodStrategy.Name.split(' ');
						if (ntype.size() > 2) {
							String typeNI2 = ntype[1] + ' ' + ntype[2];
							mapProdStrategyNI.put(typeNI2.toUpperCase(), prodStrategy);
						} else {
							String typeNI1 = ntype[1];
							mapProdStrategyNI.put(typeNI1.toUpperCase(), prodStrategy);
						}

						if(prodStrategy.SEQ__C == 3.00){
								FeeProdStr = prodStrategy;
						}

						//system.debug('n : ' + ntype + ', ' + ntype.size());
						//system.debug('n : ' + ntype[1]);  
					}
					//system.debug('mapProdStrategyNI : ' + mapProdStrategyNI); 

					List<AcctPlanProdStrategy__c> updateExpectedIncrementalNIFromStep5ByCompany = new List<AcctPlanProdStrategy__c> ();
					
					for (String typename : mapProdStrategyNI.keySet()) {
						AcctPlanProdStrategy__c mapprodstrategy = mapProdStrategyNI.get(typename);
						//system.debug('typename : ' +typename);
						Decimal sumExpectedIncrementalNI = 0;
						if (mapTypeOfAll.get(typeName) != null) {
							sumExpectedIncrementalNI = mapTypeOfAll.get(typeName) [0];
						}
				
						
							//system.debug('sumExpectedIncrementalNI' + mapprodstrategy.Name + ', ' +sumExpectedIncrementalNI);
							AcctPlanProdStrategy__c prodStrategy = new AcctPlanProdStrategy__c(Id = mapprodstrategy.id,
																							SEQ__C = mapprodstrategy.SEQ__C,
						                                                                   ExpectedIncrementalNIFromStep5__c = sumExpectedIncrementalNI,
						                                                                   RefreshAsOf__c = System.now()); //RefreshAsOf__c =datetime.now());  

						  updateExpectedIncrementalNIFromStep5ByCompany.add(prodStrategy);                                                                      

						
					}

					Double FeeExpectedIncrementalNI = 0;
					

					for( AcctPlanProdStrategy__c prodStr : updateExpectedIncrementalNIFromStep5ByCompany){

						if(prodStr.SEQ__C != 1.00 && prodStr.SEQ__C != 2.00 && prodStr.SEQ__C != 3.00 && prodStr.SEQ__C != 4.00 && prodStr.SEQ__C != 10.00 ){
							FeeExpectedIncrementalNI += prodStr.ExpectedIncrementalNIFromStep5__c==null?0:prodStr.ExpectedIncrementalNIFromStep5__c;
						}
						
					}


					/*= [SELECT ID,SEQ__c,Name,ExpectedIncrementalNIFromStep5__c 
					from AcctPlanProdStrategy__c WHERE AcctPlanCompanyProfileID__c =:companyProfileId AND SEQ__C = 3.00 LIMIT 1 ];
					*/
					System.debug('FeeExpectedIncrementalNI : '+FeeExpectedIncrementalNI);
					System.debug('FeeProdStr: '+FeeProdStr);
					FeeProdStr.ExpectedIncrementalNIFromStep5__c = FeeExpectedIncrementalNI;

					//system.debug('updateExpectedIncrementalNIFromStep5ByCompany : ' + updateExpectedIncrementalNIFromStep5ByCompany); 
					update updateExpectedIncrementalNIFromStep5ByCompany;
					update FeeProdStr;
					
				}
			}
		}
		return true;
	}
	//endregion  

	//region RefreshGroupPerformanceProductStrategyForStep6
	public Boolean RefreshGroupPerformanceProductStrategyForStep6(String groupProfileId) {

		//Map<Decimal /* SEQ*/, Decimal> mapPerformance12month = new Map<Decimal /* SEQ*/, Decimal> ();
		////Map<Id/*ComID*/, Id/*AccountID*/> mapCompanyAccount = new  Map<Id/*ComID*/, Id/*AccountID*/>();
		////Map<Id/*ComID*/,String/*CompanyName*/> mapCompanyProfile = new  Map<Id/*ComID*/,String/*CompanyName*/>();

		//Map<String /*Type*/, List<Decimal>> mapTypeOfAll = new Map<String /*Type*/, List<Decimal>> ();
		//Map<String /*Type*/, List<Decimal>> mapTypeOfFee = new Map<String /*Type*/, List<Decimal>> ();
		//Map<String /*Type*/, List<Decimal>> mapTypeOfNI = new Map<String /*Type*/, List<Decimal>> ();
		//Map<String, AcctPlanProdStrategy__c> mapProdStrategyNI = new Map<String, AcctPlanProdStrategy__c> ();
		//Map<String, AcctPlanWallet__c> mapWalletCompany = new Map<String, AcctPlanWallet__c> ();

		//List<AcctPlanCompanyProfile__c> lstCompanyProfile =
		//AccountPlanCompanyProfileSelector.getCompanyProfileByGroupProfileIds(new Set<Id> { groupProfileId });
		//if (lstCompanyProfile.size() == 0) { return false; }
		//Map<Id, AcctPlanCompanyProfile__c> maplstCompanyProfile = new Map<Id, AcctPlanCompanyProfile__c> (lstCompanyProfile);

		//List<AcctPlanWallet__c> wallets = AccountPlanWalletSelector.getWalletByCompanyProfileIds(maplstCompanyProfile.keySet());
		//if (wallets.size() == 0) { return false; }
		//Map<Id, AcctPlanWallet__c> maplstWallet = new Map<Id, AcctPlanWallet__c> (wallets);

		//for (Id walletId : maplstWallet.keySet()) {
		//AcctPlanWallet__c wallet = maplstWallet.get(walletId);

		//if (!mapWalletCompany.containsKey(wallet.AcctPlanCompanyProfile__c)) {
		//mapWalletCompany.put(wallet.AcctPlanCompanyProfile__c, wallet);
		//}
		//}

		//for (Id idCompany : maplstCompanyProfile.keySet()) {
		//AcctPlanCompanyProfile__c comprofile = maplstCompanyProfile.get(idCompany);

		//// 1) Get Performance 
		//AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo performance12month;
		////region
		//List<AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo> performance12months
		//= AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDateInGroup(
		//new Set<Id> { comprofile.Account__c }, datetime.now());

		////system.debug('performance12months : ' +performance12months); 

		//if (performance12months.size() > 0) {
		//performance12month = performance12months[0];
		//}
		//else {

		//performance12month = new AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo();
		//performance12month.AccouontId = '';
		//performance12month.AS_FEE = 0;
		//performance12month.AVG_CASA = 0;
		//performance12month.AVG_LOAN_OUT = 0;
		//performance12month.BA_FEE = 0;
		//performance12month.CREDIT_FEE = 0;
		//performance12month.DERIVATIVES_FEE = 0;
		//performance12month.DIRECT_CM_FEE = 0;
		//performance12month.EDC_FEE = 0;
		//performance12month.END_CASA = 0;
		//performance12month.ENG_LOAN_OUT = 0;
		//performance12month.Fee = 0;
		//performance12month.FLEET_FEE = 0;
		//performance12month.FRONT_END_FEE = 0;
		//performance12month.FX_FEE = 0;
		//performance12month.FX_VOLUME = 0;
		//performance12month.IB_FEE = 0;
		//performance12month.LG_FEE = 0;
		//performance12month.NIIc = 0;
		//performance12month.NIId = 0;
		//performance12month.OTHER_CM_FEE = 0;
		//performance12month.OTHER_FEE = 0;
		//performance12month.TF_FEE = 0;
		//performance12month.TF_VOLUME = 0;
		//}
		////endregion
		////Map<Decimal /* SEQ*/,Decimal> mapPerformance12month = new Map<Decimal /* SEQ*/,Decimal>();
		//mapPerformance12month.put(1.00, performance12month.NIIc);
		//mapPerformance12month.put(2.00, performance12month.NIId);
		//mapPerformance12month.put(3.00, performance12month.Fee);
		//mapPerformance12month.put(4.00, 0);
		//mapPerformance12month.put(5.00, performance12month.TF_FEE);
		//mapPerformance12month.put(6.00, performance12month.FX_FEE);
		//mapPerformance12month.put(7.00, performance12month.LG_FEE);
		//decimal cahsfee = performance12month.DIRECT_CM_FEE +
		//performance12month.OTHER_CM_FEE +
		//performance12month.EDC_FEE +
		//performance12month.FLEET_FEE;
		//mapPerformance12month.put(8.00 /*Cash FEE */, cahsfee);
		//mapPerformance12month.put(9.00, performance12month.AS_FEE);
		//mapPerformance12month.put(10.00, 0);
		//Decimal creditFee = performance12month.CREDIT_FEE + performance12month.FRONT_END_FEE;
		//mapPerformance12month.put(11.00, creditFee);
		//mapPerformance12month.put(12.00, performance12month.BA_FEE);
		//mapPerformance12month.put(13.00, performance12month.DERIVATIVES_FEE);
		//mapPerformance12month.put(14.00, performance12month.IB_FEE);

		//}
		///*--------------------------------------------------------------------
		//2)                    Update AcctPlanProdStrategy__c
		//* --------------------------------------------------------------------*/
		//for (Id comid : maplstCompanyProfile.keySet()) {
		//List<AcctPlanProdStrategy__c> acctPlanProdStrategies =
		//AccountPlanProductStrategyService.getCompaniesProductStrategy(new Set<Id> { comid });

		//datetime dt = System.Now(); //datetime.now();
		//for (AcctPlanProdStrategy__c prostr : acctPlanProdStrategies) {

		//prostr.RefreshAsOf__c = dt;

		//Decimal val;
		//if (prostr.WalletFieldName__c != '' && prostr.WalletFieldName__c != null) {
		//AcctPlanWallet__c sobjWallet = mapWalletCompany.get(prostr.AcctPlanCompanyProfileID__c);
		//val = (Decimal) sobjWallet.get(prostr.WalletFieldName__c);
		//}
		//if (val == null) val = 0;
		//prostr.WalletSizing__c = val;
		//prostr.AnnualizedPerformance__c = (Decimal) mapPerformance12month.get(prostr.Seq__c);
		//if (groupProfileId != null && groupProfileId != '') {
		//prostr.AcctPlanGroupProfileID__c = groupProfileId;
		//}
		////system.debug('prostr : ' +groupProfileId + ', ' +prostr.WalletSizing__c +', '+prostr.AnnualizedPerformance__c);
		//}
		////system.debug('acctPlanProdStrategies : ' +acctPlanProdStrategies);
		//update acctPlanProdStrategies;
		//}

		//List<AcctPlanWalletByDomain__c> lstWalletByDomain = AccountPlanWalletByDomainSelector.getWalletByDomainByWallets(maplstWallet.keySet());
		//Map<Id, AcctPlanWalletByDomain__c> maplstWalletByDomain = new Map<Id, AcctPlanWalletByDomain__c> (lstWalletByDomain);
		////system.debug('lstWalletByDomain : ' +lstWalletByDomain);

		//if (lstWalletByDomain.size() > 0) {
		//List<AcctPlanActionPlan__c> lstActionPlan = AccountPlanActionPlanSelector.getActionPlanByWalletByDomains(maplstWalletByDomain.keySet());
		//Map<Id, AcctPlanActionPlan__c> maplstActionPlan = new Map<Id, AcctPlanActionPlan__c> (lstActionPlan);
		////system.debug('lstActionPlan : ' +lstActionPlan);

		//if (lstActionPlan.size() > 0) {
		//List<AcctPlanNIProject__c> lstNIProject = AccountPlanNIProjectSelector.getNIProjectByActionPlans(maplstActionPlan.keySet());
		////system.debug('lstNIProject : ' +lstNIProject);

		//for (AcctPlanNIProject__c itemNIProject : lstNIProject) {

		////find type of NI
		//if (itemNIProject.TypeOfNI__c != null) {
		//if (itemNIProject.TypeOfNI__c == 'NIIc' || itemNIProject.TypeOfNI__c == 'NIId') {
		////system.debug('TypeOfNI__c : ' +itemNIProject.TypeOfNI__c + ', ' +itemNIProject.ExpectedIncrementalNIPerYear1Year__c );

		//if (!mapTypeOfNI.containsKey(itemNIProject.TypeOfNI__c)) {
		//mapTypeOfNI.put(itemNIProject.TypeOfNI__c, new List<Decimal> ());

		//mapTypeOfNI.get(itemNIProject.TypeOfNI__c).add(0);
		//}

		//mapTypeOfNI.get(itemNIProject.TypeOfNI__c).add(itemNIProject.ExpectedIncrementalNIPerYear1Year__c);
		//mapTypeOfNI.get(itemNIProject.TypeOfNI__c) [0] += itemNIProject.ExpectedIncrementalNIPerYear1Year__c;
		//}
		//}

		////find type of Fee
		//if (itemNIProject.TypeOfFee__c != null) {
		////system.debug('TypeOfFee__c : ' +itemNIProject.TypeOfFee__c + ', ' +itemNIProject.ExpectedIncrementalFeePerYear1Year__c );

		//if (!mapTypeOfFee.containsKey(itemNIProject.TypeOfFee__c)) {
		//mapTypeOfFee.put(itemNIProject.TypeOfFee__c, new List<Decimal> ());

		//mapTypeOfFee.get(itemNIProject.TypeOfFee__c).add(0);
		//}

		//mapTypeOfFee.get(itemNIProject.TypeOfFee__c).add(itemNIProject.ExpectedIncrementalFeePerYear1Year__c);
		//mapTypeOfFee.get(itemNIProject.TypeOfFee__c) [0] += itemNIProject.ExpectedIncrementalFeePerYear1Year__c;
		//}
		//}

		////calculate ExpectedIncremental by NI
		//for (String keyTypeNI : mapTypeOfNI.keySet()) {

		//mapTypeOfAll.put(keyTypeNI.toUpperCase(), mapTypeOfNI.get(keyTypeNI));
		//}

		////calculate ExpectedIncremental by Fee                    
		//for (String keyTypeFee : mapTypeOfFee.keySet()) {

		//mapTypeOfAll.put(keyTypeFee.toUpperCase(), mapTypeOfFee.get(keyTypeFee));
		//}

		//for (AcctPlanProdStrategy__c prodStrategy :
		//AccountPlanProductStrategySelector.selectProductStrategyByIds(maplstCompanyProfile.keySet())) {

		//String[] ntype = prodStrategy.Name.split(' ');
		//if (ntype.size() > 2) {
		//String typeNI2 = ntype[1] + ' ' + ntype[2];
		//mapProdStrategyNI.put(typeNI2.toUpperCase(), prodStrategy);
		//} else {
		//String typeNI1 = ntype[1];
		//mapProdStrategyNI.put(typeNI1.toUpperCase(), prodStrategy);
		//}
		//}

		///*---------------------------------------------------------------
		//* 2)                    Update AcctPlanProdStrategy__c
		//*---------------------------------------------------------------*/
		//List<AcctPlanProdStrategy__c> updateExpectedIncrementalNIFromStep5ByCompany = new List<AcctPlanProdStrategy__c> ();
		//for (String typename : mapProdStrategyNI.keySet()) {
		//AcctPlanProdStrategy__c mapprodstrategy = mapProdStrategyNI.get(typename);

		//Decimal sumExpectedIncrementalNI = 0;
		//if (mapTypeOfAll.get(typeName) != null) {
		//sumExpectedIncrementalNI = mapTypeOfAll.get(typeName) [0];
		//}

		//AcctPlanProdStrategy__c prodStrategy = new AcctPlanProdStrategy__c(Id = mapprodstrategy.id,
		//ExpectedIncrementalNIFromStep5__c = sumExpectedIncrementalNI,
		//RefreshAsOf__c = System.now()); //RefreshAsOf__c =datetime.now());            
		//updateExpectedIncrementalNIFromStep5ByCompany.add(prodStrategy);
		//}

		//update updateExpectedIncrementalNIFromStep5ByCompany;
		//}
		//}

		return true;
	}
	//endregion

	//region RefreshPortfolioPerformanceProductStrategyForStep0    
	public Boolean RefreshPortfolioPerformanceProductStrategyForStep0(String portfolioId) {

		//Map<Decimal /* SEQ*/, Decimal> mapPerformance12month = new Map<Decimal /* SEQ*/, Decimal> ();

		////Map<String/*Type*/,List<Decimal>> mapTypeOfAll = new  Map<String/*Type*/,List<Decimal>>();        
		////Map<String/*Type*/,List<Decimal>> mapTypeOfFee = new  Map<String/*Type*/,List<Decimal>>();        
		////Map<String/*Type*/,List<Decimal>> mapTypeOfNI = new  Map<String/*Type*/,List<Decimal>>(); 
		//Map<String, AcctPlanProdStrategy__c> mapProdStrategyNI = new Map<String, AcctPlanProdStrategy__c> ();
		//Map<String, AcctPlanWallet__c> mapWalletCompany = new Map<String, AcctPlanWallet__c> ();

		//List<AcctPlanCompanyProfile__c> lstCompanyProfile =
		//AccountPlanCompanyProfileSelector.getCompanyProfileIdByPortfolioIds(new Set<Id> { portfolioId });
		//if (lstCompanyProfile.size() == 0) { return false; }
		//Map<Id, AcctPlanCompanyProfile__c> maplstCompanyProfile = new Map<Id, AcctPlanCompanyProfile__c> (lstCompanyProfile);

		//List<AcctPlanWallet__c> wallets = AccountPlanWalletSelector.getWalletByCompanyProfileIds(maplstCompanyProfile.keySet());
		//if (wallets.size() == 0) { return false; }
		//Map<Id, AcctPlanWallet__c> maplstWallet = new Map<Id, AcctPlanWallet__c> (wallets);

		//for (Id walletId : maplstWallet.keySet()) {
		//AcctPlanWallet__c wallet = maplstWallet.get(walletId);

		//if (!mapWalletCompany.containsKey(wallet.AcctPlanCompanyProfile__c)) {
		//mapWalletCompany.put(wallet.AcctPlanCompanyProfile__c, wallet);
		//}
		//}

		//for (Id idCompany : maplstCompanyProfile.keySet()) {
		//AcctPlanCompanyProfile__c comprofile = maplstCompanyProfile.get(idCompany);

		//// 1) Get Performance 
		//AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo performance12month;
		////region
		//List<AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo> performance12months
		//= AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDateInGroup(
		//new Set<Id> { comprofile.Account__c }, datetime.now());


		//if (performance12months.size() > 0) {
		//performance12month = performance12months[0];
		//}
		//else {

		//performance12month = new AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo();
		//performance12month.AccouontId = '';
		//performance12month.AS_FEE = 0;
		//performance12month.AVG_CASA = 0;
		//performance12month.AVG_LOAN_OUT = 0;
		//performance12month.BA_FEE = 0;
		//performance12month.CREDIT_FEE = 0;
		//performance12month.DERIVATIVES_FEE = 0;
		//performance12month.DIRECT_CM_FEE = 0;
		//performance12month.EDC_FEE = 0;
		//performance12month.END_CASA = 0;
		//performance12month.ENG_LOAN_OUT = 0;
		//performance12month.Fee = 0;
		//performance12month.FLEET_FEE = 0;
		//performance12month.FRONT_END_FEE = 0;
		//performance12month.FX_FEE = 0;
		//performance12month.FX_VOLUME = 0;
		//performance12month.IB_FEE = 0;
		//performance12month.LG_FEE = 0;
		//performance12month.NIIc = 0;
		//performance12month.NIId = 0;
		//performance12month.OTHER_CM_FEE = 0;
		//performance12month.OTHER_FEE = 0;
		//performance12month.TF_FEE = 0;
		//performance12month.TF_VOLUME = 0;
		//}
		////endregion
		////Map<Decimal /* SEQ*/,Decimal> mapPerformance12month = new Map<Decimal /* SEQ*/,Decimal>();
		//mapPerformance12month.put(1.00, performance12month.NIIc);
		//mapPerformance12month.put(2.00, performance12month.NIId);
		//mapPerformance12month.put(3.00, performance12month.Fee);
		//mapPerformance12month.put(4.00, 0);
		//mapPerformance12month.put(5.00, performance12month.TF_FEE);
		//mapPerformance12month.put(6.00, performance12month.FX_FEE);
		//mapPerformance12month.put(7.00, performance12month.LG_FEE);
		//decimal cahsfee = performance12month.DIRECT_CM_FEE +
		//performance12month.OTHER_CM_FEE +
		//performance12month.EDC_FEE +
		//performance12month.FLEET_FEE;
		//mapPerformance12month.put(8.00 /*Cash FEE */, cahsfee);
		//mapPerformance12month.put(9.00, performance12month.AS_FEE);
		//mapPerformance12month.put(10.00, 0);
		//Decimal creditFee = performance12month.CREDIT_FEE + performance12month.FRONT_END_FEE;
		//mapPerformance12month.put(11.00, creditFee);
		//mapPerformance12month.put(12.00, performance12month.BA_FEE);
		//mapPerformance12month.put(13.00, performance12month.DERIVATIVES_FEE);
		//mapPerformance12month.put(14.00, performance12month.IB_FEE);

		//}

		////system.debug('mapPerformance12month : ' +mapPerformance12month.size() + ', ' +mapPerformance12month);                

		///*--------------------------------------------------------------------
		//2)                    Update AcctPlanProdStrategy__c
		//* --------------------------------------------------------------------*/
		//for (Id comid : maplstCompanyProfile.keySet()) {
		//List<AcctPlanProdStrategy__c> acctPlanProdStrategies =
		//AccountPlanProductStrategyService.getCompaniesProductStrategy(new Set<Id> { comid });
		//AcctPlanCompanyProfile__c cprofile = maplstCompanyProfile.get(comid);
		//String groupProfileId = cprofile.AcctPlanGroup__c;

		//datetime dt = System.now(); //datetime.now();
		//for (AcctPlanProdStrategy__c prostr : acctPlanProdStrategies) {

		//prostr.RefreshAsOf__c = dt;

		//Decimal val;
		//if (prostr.WalletFieldName__c != '' && prostr.WalletFieldName__c != null) {
		//AcctPlanWallet__c sobjWallet = mapWalletCompany.get(prostr.AcctPlanCompanyProfileID__c);
		//val = (Decimal) sobjWallet.get(prostr.WalletFieldName__c);
		//}

		//if (val == null) val = 0;
		//prostr.WalletSizing__c = val;
		//prostr.AnnualizedPerformance__c = (Decimal) mapPerformance12month.get(prostr.Seq__c);
		//if (groupProfileId != null && groupProfileId != '') {
		//prostr.AcctPlanGroupProfileID__c = groupProfileId;
		//}
		////system.debug('prostr : ' +groupProfileId + ', ' +prostr.WalletSizing__c +', '+prostr.AnnualizedPerformance__c);
		//}
		////system.debug('acctPlanProdStrategies : ' +acctPlanProdStrategies);
		//update acctPlanProdStrategies;
		//}

		//for (Id comIdWallet : mapWalletCompany.keySet()) {
		//AcctPlanWallet__c wallet = mapWalletCompany.get(comIdWallet);

		//List<AcctPlanWalletByDomain__c> lstWalletByDomain =
		//AccountPlanWalletByDomainSelector.getWalletByDomainByWallets(new Set<id> { wallet.id }); //(maplstWallet.keySet());
		//Map<Id, AcctPlanWalletByDomain__c> maplstWalletByDomain = new Map<Id, AcctPlanWalletByDomain__c> (lstWalletByDomain);
		////system.debug('lstWalletByDomain : ' +lstWalletByDomain);

		//if (lstWalletByDomain.size() > 0) {
		//List<AcctPlanActionPlan__c> lstActionPlan = AccountPlanActionPlanSelector.getActionPlanByWalletByDomains(maplstWalletByDomain.keySet());
		//Map<Id, AcctPlanActionPlan__c> maplstActionPlan = new Map<Id, AcctPlanActionPlan__c> (lstActionPlan);
		////system.debug('lstActionPlan : ' +lstActionPlan);

		//if (lstActionPlan.size() > 0) {
		//List<AcctPlanNIProject__c> lstNIProject = AccountPlanNIProjectSelector.getNIProjectByActionPlans(maplstActionPlan.keySet());
		////system.debug('lstNIProject : ' +lstNIProject);


		//Map<String /*Type*/, List<Decimal>> mapTypeOfAll = new Map<String /*Type*/, List<Decimal>> ();
		//Map<String /*Type*/, List<Decimal>> mapTypeOfFee = new Map<String /*Type*/, List<Decimal>> ();
		//Map<String /*Type*/, List<Decimal>> mapTypeOfNI = new Map<String /*Type*/, List<Decimal>> ();

		//for (AcctPlanNIProject__c itemNIProject : lstNIProject) {

		////find type of NI
		//if (itemNIProject.TypeOfNI__c != null) {
		//if (itemNIProject.TypeOfNI__c == 'NIIc' || itemNIProject.TypeOfNI__c == 'NIId') {
		////system.debug('TypeOfNI__c : ' +itemNIProject.TypeOfNI__c + ', ' +itemNIProject.ExpectedIncrementalNIPerYear1Year__c );

		//if (!mapTypeOfNI.containsKey(itemNIProject.TypeOfNI__c)) {
		//mapTypeOfNI.put(itemNIProject.TypeOfNI__c, new List<Decimal> ());

		//mapTypeOfNI.get(itemNIProject.TypeOfNI__c).add(0);
		//}

		//mapTypeOfNI.get(itemNIProject.TypeOfNI__c).add(itemNIProject.ExpectedIncrementalNIPerYear1Year__c);
		//mapTypeOfNI.get(itemNIProject.TypeOfNI__c) [0] += itemNIProject.ExpectedIncrementalNIPerYear1Year__c;
		//}
		//}

		////find type of Fee
		//if (itemNIProject.TypeOfFee__c != null) {
		////system.debug('TypeOfFee__c : ' +itemNIProject.TypeOfFee__c + ', ' +itemNIProject.ExpectedIncrementalFeePerYear1Year__c );

		//if (!mapTypeOfFee.containsKey(itemNIProject.TypeOfFee__c)) {
		//mapTypeOfFee.put(itemNIProject.TypeOfFee__c, new List<Decimal> ());

		//mapTypeOfFee.get(itemNIProject.TypeOfFee__c).add(0);
		//}

		//mapTypeOfFee.get(itemNIProject.TypeOfFee__c).add(itemNIProject.ExpectedIncrementalFeePerYear1Year__c);
		//mapTypeOfFee.get(itemNIProject.TypeOfFee__c) [0] += itemNIProject.ExpectedIncrementalFeePerYear1Year__c;
		//}

		////calculate ExpectedIncremental by NI
		//for (String keyTypeNI : mapTypeOfNI.keySet()) {

		//mapTypeOfAll.put(keyTypeNI.toUpperCase(), mapTypeOfNI.get(keyTypeNI));
		//}

		////calculate ExpectedIncremental by Fee                    
		//for (String keyTypeFee : mapTypeOfFee.keySet()) {

		//mapTypeOfAll.put(keyTypeFee.toUpperCase(), mapTypeOfFee.get(keyTypeFee));
		//}

		//for (AcctPlanProdStrategy__c prodStrategy :
		//AccountPlanProductStrategySelector.selectProductStrategyByIds(new Set<Id> { comIdWallet })) { //(maplstCompanyProfile.keySet())){

		//String[] ntype = prodStrategy.Name.split(' ');
		//if (ntype.size() > 2) {
		//String typeNI2 = ntype[1] + ' ' + ntype[2];
		//mapProdStrategyNI.put(typeNI2.toUpperCase(), prodStrategy);
		//} else {
		//String typeNI1 = ntype[1];
		//mapProdStrategyNI.put(typeNI1.toUpperCase(), prodStrategy);
		//}
		//}

		///*---------------------------------------------------------------
		//* 2)                    Update AcctPlanProdStrategy__c
		//*---------------------------------------------------------------*/
		//List<AcctPlanProdStrategy__c> updateExpectedIncrementalNIFromStep5ByCompany = new List<AcctPlanProdStrategy__c> ();
		//for (String typename : mapProdStrategyNI.keySet()) {
		//AcctPlanProdStrategy__c mapprodstrategy = mapProdStrategyNI.get(typename);

		//Decimal sumExpectedIncrementalNI = 0;
		//if (mapTypeOfAll.get(typeName) != null) {
		//sumExpectedIncrementalNI = mapTypeOfAll.get(typeName) [0];
		//}

		//AcctPlanProdStrategy__c prodStrategy = new AcctPlanProdStrategy__c(Id = mapprodstrategy.id,
		//ExpectedIncrementalNIFromStep5__c = sumExpectedIncrementalNI,
		//RefreshAsOf__c = System.now()); //RefreshAsOf__c =datetime.now());            
		//updateExpectedIncrementalNIFromStep5ByCompany.add(prodStrategy);
		//}

		////system.debug('2update : ' +updateExpectedIncrementalNIFromStep5ByCompany);
		//update updateExpectedIncrementalNIFromStep5ByCompany;

		//}
		//}
		//}
		//}
		return true;
	}

	public List<AcctPlanProdStrategy__c> RefreshProductStrategyAndWalletByDomain(String acctPlanCompanyId, String acctPlanWallet, String acctPlanGruopId) {

		// 1) Find Account Profile `
		AcctPlanCompanyProfile__c accPlanProfile;
		system.debug('::: acctPlanCompanyId  >> ' + acctPlanCompanyId);
		List<AcctPlanCompanyProfile__c> accPlanProfiles = AccountPlanCompanyProfileSelector.getCompanyProfileIds(new Set<Id> { acctPlanCompanyId });
		if (accPlanProfiles.size() > 0) {
			accPlanProfile = accPlanProfiles[0];
		}

		// 2) Account Plan Wallet
		AcctPlanWallet__c wallet;
		List<AcctPlanWallet__c> wallets = AccountPlanWalletSelector.getWalletByIds(new Set<Id> { acctPlanWallet });
		if (wallets.size() > 0) {
			wallet = wallets[0];
		}

		// 3) Get Performance 
		AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo performance12month;
		//region
		List<AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo> performance12months
		= AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDateInGroup(new Set<Id> { accPlanProfile.Account__c }, datetime.now());
		if (performance12months.size() > 0) {
			performance12month = performance12months[0];
		}
		else {

			performance12month = new AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo();
			performance12month.AccouontId = '';
			performance12month.AS_FEE = 0;
			performance12month.AVG_CASA = 0;
			performance12month.AVG_LOAN_OUT = 0;
			performance12month.BA_FEE = 0;
			performance12month.CREDIT_FEE = 0;
			performance12month.DERIVATIVES_FEE = 0;
			performance12month.DIRECT_CM_FEE = 0;
			performance12month.EDC_FEE = 0;
			performance12month.END_CASA = 0;
			performance12month.ENG_LOAN_OUT = 0;
			performance12month.Fee = 0;
			performance12month.FLEET_FEE = 0;
			performance12month.FRONT_END_FEE = 0;
			performance12month.FX_FEE = 0;
			performance12month.FX_VOLUME = 0;
			performance12month.IB_FEE = 0;
			performance12month.LG_FEE = 0;
			performance12month.NIIc = 0;
			performance12month.NIId = 0;
			performance12month.OTHER_CM_FEE = 0;
			performance12month.OTHER_FEE = 0;
			performance12month.TF_FEE = 0;
			performance12month.TF_VOLUME = 0;
		}
		//endregion
		Map<Decimal /* SEQ*/, Decimal> mapPerformance12month = new Map<Decimal /* SEQ*/, Decimal> ();
		mapPerformance12month.put(1.00, performance12month.NIIc);
		mapPerformance12month.put(2.00, performance12month.NIId);
		mapPerformance12month.put(3.00, performance12month.Fee);
		mapPerformance12month.put(4.00, 0);
		mapPerformance12month.put(5.00, performance12month.TF_FEE);
		mapPerformance12month.put(6.00, performance12month.FX_FEE);
		mapPerformance12month.put(7.00, performance12month.LG_FEE);
		decimal cahsfee = performance12month.DIRECT_CM_FEE +
		performance12month.OTHER_CM_FEE +
		performance12month.EDC_FEE +
		performance12month.FLEET_FEE;
		mapPerformance12month.put(8.00 /*Cash FEE */, cahsfee);
		mapPerformance12month.put(9.00, performance12month.AS_FEE);
		mapPerformance12month.put(10.00, 0);
		Decimal creditFee = performance12month.CREDIT_FEE + performance12month.FRONT_END_FEE;
		mapPerformance12month.put(11.00, creditFee);
		mapPerformance12month.put(12.00, performance12month.BA_FEE);
		mapPerformance12month.put(13.00, performance12month.DERIVATIVES_FEE);
		mapPerformance12month.put(14.00, performance12month.IB_FEE);


		System.debug(loggingLevel.Error, '*** acctPlanWallet: ' + acctPlanWallet);
		List<AcctPlanCusUnderstanding__c> customerUnderstandings = AccountPlanCustomerUnderstandingSelector.getUnderstandingByWalletIds(new Set<Id> { acctPlanWallet });
		List<AcctAnnualPerformance__c> lastTransaction = AccountPlanAnnualPerformanceSelector.LastCustomerUnderstandarding((id) accPlanProfile.Account__c);
		
		System.debug(loggingLevel.Error, '*** lastTransaction: ' + lastTransaction.size());
		System.debug(loggingLevel.Error, '*** customerUnderstandings: ' + customerUnderstandings.size());
		System.debug(loggingLevel.Error, '*** acctPlanWallet: ' + acctPlanWallet);
		UpsertCustomerUnderstanding(lastTransaction, customerUnderstandings, acctPlanWallet);


		// 4 Update From Product
		/*--------------------------------------------------------------------
		 *           Account Product ProdStrategy
		 * --------------------------------------------------------------------*/
		List<AcctPlanProdStrategy__c> acctPlanProdStrategies = AccountPlanProductStrategyService.getCompaniesProductStrategy(new Set<Id> { acctPlanCompanyId });
		datetime dt = datetime.now();

		/************************************************
		 *  SE CASE
		 ************************************************/
		if (accPlanProfile.isMiniMode__c) {
			//region SINGLE VIEW
			Map<id, Account> accountSEmap = new Map<id, Account> ();
			for (Account acc : AccountSelector.getAccountWithSingleViewInfoByIds(new set<Id> { accPlanProfile.Account__c })) {
				//if (acc.Owner.Segment__c == 'SE') {
					System.debug('::: HIT SE CUSTOMER');
					if (!accountSEmap.containsKey(acc.Id)) {
						accountSEmap.put(acc.Id, acc);
						//accountIds.remove(acc.Id);s
					}
				//}
			}
			//endregion
			Account act = accountSEmap.get(accPlanProfile.Account__c);
			
			for (AcctPlanProdStrategy__c prostr : acctPlanProdStrategies) {

				prostr.RefreshAsOf__c = dt;
				if (prostr.SEQ__c == 1.00) {
					prostr.WalletSizing__c = act.NIIc_Wallet__c;
					wallet.SumofWalletNiicYearly__c = act.NIIc_wallet__c;

				} else if (prostr.SEQ__c == 2.00) {
					prostr.WalletSizing__c = act.NIId_Wallet__c;
					wallet.TotalWalletNIID_Mini__c  = act.NIId_Wallet__c;

				} else if (prostr.SEQ__c == 3.00) {
					prostr.WalletSizing__c = act.Fee_Wallet__c;
					wallet.Total_Fee_Mini__c  = act.Fee_Wallet__c;

				}
				else {
					prostr.WalletSizing__c = 0;

				}


				prostr.AnnualizedPerformance__c = (Decimal) mapPerformance12month.get(prostr.Seq__c);

			}

		}
		/************************************************
		 *  NORMAL CASE
		 ************************************************/
		else {
			for (AcctPlanProdStrategy__c prostr : acctPlanProdStrategies) {
				prostr.RefreshAsOf__c = dt;
				Decimal val;
				if (prostr.WalletFieldName__c != '' && prostr.WalletFieldName__c != null) {
					val = (Decimal) wallet.get(prostr.WalletFieldName__c);
				}
				if (val == null) {
					val = 0;
				}

				System.debug('WalletSizing : '+prostr.Name +'  : '+prostr.WalletSizing__c);
				prostr.WalletSizing__c = val;
				prostr.AnnualizedPerformance__c = (Decimal) mapPerformance12month.get(prostr.Seq__c);
				if (acctPlanGruopId != null && acctPlanGruopId != '') {
					prostr.AcctPlanGroupProfileID__c = acctPlanGruopId;
				}
			}
		}

		// 5 Update From Wallet
		/*--------------------------------------------------------------------
		 *           Account Plan Wallet By Domain 
		 * --------------------------------------------------------------------*/
		List<AcctPlanWalletByDomain__c> walletByDomains = AccountPlanWalletByDomainSelector.getWalletByDomainByWallets(new set<id> { wallet.Id });

		// >> start for
		for (AcctPlanWalletByDomain__c wallDomain : walletByDomains) {

			system.debug(' Type Of NI >> ' + wallDomain.TypeOfNI__c + ' SubDomain >> ' + wallDomain.Domain__c);
			Decimal val = 0;
			if (wallDomain.WalletFieldName__c != null && wallDomain.WalletFieldName__c != '') {
				System.debug('Wallet Field Name : '+wallDomain.WalletFieldName__c);
				if (wallDomain.WalletFieldName__c.contains(',')) {
					for (String fieldName : wallDomain.WalletFieldName__c.split(',')) {
						system.debug(' fieldName >> ' + fieldName);
						val += (Decimal) (wallet.get(fieldName) == null ? 0 : wallet.get(fieldName));
					}
				}
				else {
					val += (Decimal) (wallet.get(wallDomain.WalletFieldName__c) == null ? 0 : wallet.get(wallDomain.WalletFieldName__c));
				}
			}
			wallDomain.AdjWalletUnit__c = val;
		}
		// >> end for           
		try {

			update walletByDomains;
			update acctPlanProdStrategies;
            if (accPlanProfile.isMiniMode__c) {
                update wallet;
            }
            
            
		}
		catch(Exception ex) {

			system.debug('::: Error >> ' + ex.getMessage());
			throw ex;

		}
		return acctPlanProdStrategies;

	}

	
	public void UpsertCustomerUnderstanding(List<AcctAnnualPerformance__c> lastTransaction, List<AcctPlanCusUnderstanding__c> customerUnderstandings, Id acctPlanWallet) {

		if (lastTransaction.size() > 0) {
			if (customerUnderstandings.size() > 0)
			{
				AcctPlanCusUnderstanding__c customerUnderstanding = customerUnderstandings[0];
				customerUnderstanding.Average_loan_outstanding__c = lastTransaction[0].AVG_LOAN_OUT__c;
				customerUnderstanding.Ending_loan_outstanding__c = lastTransaction[0].ENG_LOAN_OUT__c;
				customerUnderstanding.Average_CASA__c = lastTransaction[0].AVG_CASA__c;
				customerUnderstanding.Ending_CASA__c = lastTransaction[0].END_CASA__c;
				customerUnderstanding.TF_Volume__c = lastTransaction[0].TF_VOLUME__c;
				customerUnderstanding.FX_volume__c = lastTransaction[0].FX_VOLUME__c;
				customerUnderstanding.RefreshAsOf__c = datetime.now();
				update customerUnderstanding;
			}
			else {
				AcctPlanCusUnderstanding__c customerUnderstanding = new AcctPlanCusUnderstanding__c();
				customerUnderstanding.AcctPlanWallet__c = acctPlanWallet;
				customerUnderstanding.Average_loan_outstanding__c = lastTransaction[0].AVG_LOAN_OUT__c;
				customerUnderstanding.Ending_loan_outstanding__c = lastTransaction[0].ENG_LOAN_OUT__c;
				customerUnderstanding.Average_CASA__c = lastTransaction[0].AVG_CASA__c;
				customerUnderstanding.Ending_CASA__c = lastTransaction[0].END_CASA__c;
				customerUnderstanding.TF_Volume__c = lastTransaction[0].TF_VOLUME__c;
				customerUnderstanding.FX_volume__c = lastTransaction[0].FX_VOLUME__c;
				customerUnderstanding.RefreshAsOf__c = datetime.now();
				insert customerUnderstanding;
			}
		}
		else {
			if (customerUnderstandings.size() > 0)
			{
				AcctPlanCusUnderstanding__c customerUnderstanding = customerUnderstandings[0];
				customerUnderstanding.AcctPlanWallet__c = acctPlanWallet;
				customerUnderstanding.Average_loan_outstanding__c = 0;
				customerUnderstanding.Ending_loan_outstanding__c = 0;
				customerUnderstanding.Average_CASA__c = 0;
				customerUnderstanding.Ending_CASA__c = 0;
				customerUnderstanding.TF_Volume__c = 0;
				customerUnderstanding.FX_volume__c = 0;
				customerUnderstanding.RefreshAsOf__c = datetime.now();
				update customerUnderstanding;
			}
			else {

				AcctPlanCusUnderstanding__c customerUnderstanding = new AcctPlanCusUnderstanding__c();
				customerUnderstanding.AcctPlanWallet__c = acctPlanWallet;
				customerUnderstanding.Average_loan_outstanding__c = 0;
				customerUnderstanding.Ending_loan_outstanding__c = 0;
				customerUnderstanding.Average_CASA__c = 0;
				customerUnderstanding.Ending_CASA__c = 0;
				customerUnderstanding.TF_Volume__c = 0;
				customerUnderstanding.FX_volume__c = 0;
				customerUnderstanding.RefreshAsOf__c = datetime.now();
				insert customerUnderstanding;
			}

		}

	}


	public class ProductStrategyTemplate {
		public Decimal Seq { get; set; }
		public String Label { get; set; }
		public String WalletFieldName { get; set; }
		public ProductStrategyTemplate(Decimal Seq, String Label, String walletFieldName) {
			this.Seq = Seq;
			this.Label = Label;
			this.WalletFieldName = walletFieldName;
		}
		public ProductStrategyTemplate(Decimal Seq, String Label) {
			this(Seq, Label, '');
		}
	}


	public class WalletByDomainTemplate {
		public Decimal Row { get; set; }
		public Decimal Seq { get; set; }
		public String TypeOfNI { get; set; }
		public String Domain { get; set; }
		public String SubDomain { get; set; }
		public String WalletFieldName { get; set; }

		public WalletByDomainTemplate(Decimal row, Decimal seq, String typeOfNI, String domain, String subDomain, String walletFieldName) {

			this(seq, typeOfNI, domain, subDomain, walletFieldName);
			this.Row = row;
		}

		public WalletByDomainTemplate(Decimal seq, String typeOfNI, String domain, String subDomain, String walletFieldName) {

			this.Seq = seq;
			this.TypeOfNI = typeOfNI;
			this.Domain = domain;
			this.SubDomain = subDomain;
			this.WalletFieldName = walletFieldName;
		}
	}

	public List<WalletByDomainTemplate> getWalletByDomainTemplate {
		get {
			List<WalletByDomainTemplate> template = new List<WalletByDomainTemplate> ();
			template.add(new WalletByDomainTemplate(1.00, 1.1, 'NIIc Products', 'Loan', 'Working capital', 'TotalWalletNiic__c'));
			template.add(new WalletByDomainTemplate(1.00, 1.2, 'NIIc Products', 'Loan', 'Long term loan : Existing', 'SumofExistingLongTermLoanNIIC__c'));
			template.add(new WalletByDomainTemplate(1.00, 1.3, 'NIIc Products', 'Loan', 'Long term loan : Capital expenditure Plan', 'SumOfCapitalExpenditurePlanNIIC__c'));

			template.add(new WalletByDomainTemplate(2.00, 2.1, 'NIId Products', 'Deposit', 'Operating transaction', 'WalletNiid_OperatingTransaction__c'));
			template.add(new WalletByDomainTemplate(2.00, 2.2, 'NIId Products', 'Deposit', 'Cash on hand/Cash at bank or Investment', 'WalletNiid_CashOnHand__c'));

			template.add(new WalletByDomainTemplate(5.00, 5.1, 'TF Fee Products', 'International', 'Export', 'SumOfCollectionExportWalletTradeFee__c'));
			template.add(new WalletByDomainTemplate(5.00, 5.1, 'TF Fee Products', 'International', 'Import', 'SumOfPaymentImportWalletTFFee__c'));

			template.add(new WalletByDomainTemplate(6.00, 6.1, 'FX Fee Products', 'Hedging', 'Normal business transaction : Trade transaction', 'SumOfWalletFXFeePerYear__c'));

			//> 3.3 L/G fee
			template.add(new WalletByDomainTemplate(7.00, 7.1, 'L/G Fee Products', 'L/G Fee Products', 'L/G issuing : L/G project', 'ShortTermWalletLGFee__c,LongTermWalletLGFee__c'));
			template.add(new WalletByDomainTemplate(7.00, 7.2, 'L/G Fee Products', 'L/G Fee Products', 'L/G issuing : L/G purchase', 'LGPurchaseTotalWalletLGFee__c'));
			template.add(new WalletByDomainTemplate(7.00, 7.3, 'L/G Fee Products', 'L/G Fee Products', 'L/G issuing : Aval/Acceptance', ''));
			template.add(new WalletByDomainTemplate(7.00, 7.4, 'L/G Fee Products', 'L/G Fee Products', 'L/G issuing : International bank guarantee or Standby L/C', ''));
			template.add(new WalletByDomainTemplate(7.00, 7.5, 'L/G Fee Products', 'L/G Fee Products', 'L/G issuing : Shipping guarantee', ''));

			// > 3.4 Cash fee
			template.add(new WalletByDomainTemplate(8.00, 8.1, 'Cash Fee Products', 'Domestic', 'Collection', 'SumOfCollectionWalletCashFee__c'));
			template.add(new WalletByDomainTemplate(8.00, 8.2, 'Cash Fee Products', 'Domestic', 'Payment', 'SumOfPaymentDomesticWalletCashFee__c'));

			// 5.2 AS Fee
			template.add(new WalletByDomainTemplate(9, 9.1, 'AS Fee Products', 'Agent & Security Services', '1) Custodian', 'WalletASFee_Custodian__c'));
			template.add(new WalletByDomainTemplate(9, 9.2, 'AS Fee Products', 'Agent & Security Services', '2) Fund Supervisor', 'WalletASFee_FundSupervisory__c'));
			template.add(new WalletByDomainTemplate(9, 9.3, 'AS Fee Products', 'Agent & Security Services', '3) Middle Office', 'WalletASFee_MiddleOffice__c'));
			template.add(new WalletByDomainTemplate(9, 9.4, 'AS Fee Products', 'Agent & Security Services', '4) Agency Service', 'WalletASFee_AgencyService__c'));
			template.add(new WalletByDomainTemplate(9, 9.5, 'AS Fee Products', 'Agent & Security Services', '5) Registra & Payment Agent', 'WalletASFee_RegistrarPaymentAgent__c'));


			// > 3.6 Credit fee
			template.add(new WalletByDomainTemplate(11.00, 11.1, 'Credit Fee Products', 'Loan', 'Working capital', 'MaxCreditFeeWorkingCapital__c'));
			template.add(new WalletByDomainTemplate(11.00, 11.2, 'Credit Fee Products', 'Loan', 'Long term loan : Capital expenditure Plan', 'SumOfCapitalExpenditurePlanCreditFee__c'));


			// > 3.7 BA fee
			template.add(new WalletByDomainTemplate(12.00, 12.1, 'BA Fee Products', 'Hedging', 'Insurance : Credit life insurance', 'WalletOfBAFee__c'));
			template.add(new WalletByDomainTemplate(12.00, 12.2, 'BA Fee Products', 'Hedging', 'Insurance : Non credit life insurance', ''));
			template.add(new WalletByDomainTemplate(12.00, 12.3, 'BA Fee Products', 'Hedging', 'Insurance : Non life insurance', ''));

			// > 3.8 Derivative fee
			template.add(new WalletByDomainTemplate(13.00, 13.1, 'Derivative Fee Products', 'Hedging', 'Existing liabilities & Investment plan/Capital expenditure plan', ''));

			// > 3.9 Derivative fee
			template.add(new WalletByDomainTemplate(14.00, 14.1, 'IB Fee Products', 'Hedging', 'Existing liabilities & Investment plan/Capital expenditure plan', ''));



			return template;
		}
	}

	public Map<decimal, string> getProductStrategyTemplate {
		get {
			Map<decimal, string> template = new Map<decimal, string> ();
			template.put(1.00, 'SumOfWalletNiicYearly__c');
			template.put(2.00, 'TotalWalletNIID__c');
			template.put(3.00, 'Total_Fee__c');
			// template.put(4.00,'Recurring Fee'));
			template.put(5.00, 'SumOfWalletTFFee__c');
			template.put(6.00, 'SumOfAcctPlanForeignWalletFXFeePerYear__c');
			template.put(7.00, 'SumOfWalletLGFeeYearly__c');
			template.put(8.00, 'SumOfWalletCashFee__c');
			template.put(9.00,'SumOfWalletASFee__c');
			//template.put(10.00,'Non recurring fee'));
			template.put(11.00, 'SumOfWalletCreditFeeYearly__c');
			template.put(12.00, 'TotalWalletBAFee__c');
			// template.put(13.00,'3.8 Derivative Fee'));                                        // *****  ไม่มี ที่ Step 3   
			// template.put(14.00,'3.9 IB Fee'));          

			// *****  ไม่มี ที่ Step 3              
			return template;
		}
	}
	//endregion

	/***********************************************************
	 *  Group Wallet Refresh
	 ***********************************************************/
	public void RefreshProductStrategy(Set<Id> accountIds, string year, Id groupProfilesId) {

//		Set<id> seAccount = new Set<id> ();
//		for (AcctPlanCompanyProfile__c item : AccountPlanCompanyProfileSelector.getCompanyProfileByGroupProfileIds(new set<id> { groupProfilesId })) {
//			if (item.isMiniMode__c) {
//				seAccount.add(item.Account__c);
//			}
//		}
//
//		// ต้องแยก SE ดัวย    	
//		Map<id, Account> accountSEmap = new Map<id, Account> ();
//		for (Account acc : AccountSelector.getAccountWithSingleViewInfoByIds(seAccount)) {
//			if (acc.Owner.Segment__c == 'SE') {
//				System.debug('::: HIT SE CUSTOMER');
//				if (!accountSEmap.containsKey(acc.Id)) {
//					accountSEmap.put(acc.Id, acc);
//					//accountIds.remove(acc.Id);
//				}
//			}
//		}
//
//
//
//
//
//
//
//
//
//		/***********************************************************
//		 *  NORMAL CASE  SE
//		 * STEP 1) GET AcctPlanProdStrategy BY ACCOUNT ID IN YEAR
//		 * **********************************************************/
//
//
//
//		//region 
//
//		/***********************************************************
//		 *  NORMAL CASE NONE SE
//		 * STEP 1) GET AcctPlanProdStrategy BY ACCOUNT ID IN YEAR
//		 * **********************************************************/
//
//		Map<id /*Account*/, Map<decimal, AcctPlanProdStrategy__c>> mapAccountIdAcctPlanProdStrategy = new Map<id /*Account*/, Map<decimal, AcctPlanProdStrategy__c>> ();
//		Map<id, id> mapCompanyProfileIds = new Map<id, id> ();
//		for (AcctPlanProdStrategy__c item : AccountPlanProductStrategySelector.selectProductStrategyByAccountIds(accountIds, year)) {
//			if (!mapAccountIdAcctPlanProdStrategy.containsKey(item.AccountId__c)) {
//				mapAccountIdAcctPlanProdStrategy.put(item.AccountId__c, new Map<decimal, AcctPlanProdStrategy__c> ());
//				mapCompanyProfileIds.put(item.AcctPlanCompanyProfileID__c, item.AcctPlanCompanyProfileID__c);
//			}
//			mapAccountIdAcctPlanProdStrategy.get(item.AccountId__c).put(item.SEQ__c, item);
//
//
//		}
//		System.debug('::::: Has Step 4 : ' + mapAccountIdAcctPlanProdStrategy.size());
//
//		/**********************************************************************
//		 *  STEP 2) Calculate Performance
//		 *        ตัวแปรที่ได้ : mapPerformance 
//		 ***********************************************************************/
//		Map<id /*Account Id*/, AcctPlanWallet__c> Wallets = new Map<id, AcctPlanWallet__c> ();
//		Map<id /*wallet id*/, id /*Account Id*/> WalletIds = new Map<id /*Account Id*/, id /*wallet id*/> ();
//		for (AcctPlanWallet__c item : AccountPlanWalletSelector.getWalletByCompanyProfileIds(mapCompanyProfileIds.keySet())) {
//			Wallets.put(item.AcctPlanCompanyProfile__r.Account__c, item);
//
//			WalletIds.put(item.id, item.AcctPlanCompanyProfile__r.Account__c);
//		}
//
//
//		/**********************************************************************
//		 *  STEP 3) Calculate Performance
//		 *        ตัวแปรที่ได้ : mapPerformance 
//		 ***********************************************************************/
//		Map<Id, AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo> mapPerformance
//		= new Map<Id, AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo> ();
//		DateTime dt = datetime.now();
//		for (AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo item : AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDateInGroup(accountIds, dt)) {
//
//			item.AS_FEE = item.AS_FEE == null ? 0 : item.AS_FEE;
//			item.AVG_CASA = item.AVG_CASA == null ? 0 : item.AVG_CASA;
//			item.AVG_LOAN_OUT = item.AVG_LOAN_OUT == null ? 0 : item.AVG_LOAN_OUT;
//			item.BA_FEE = item.BA_FEE == null ? 0 : item.BA_FEE;
//			item.CREDIT_FEE = item.CREDIT_FEE == null ? 0 : item.CREDIT_FEE;
//			item.DERIVATIVES_FEE = item.DERIVATIVES_FEE == null ? 0 : item.DERIVATIVES_FEE;
//			item.DIRECT_CM_FEE = item.DIRECT_CM_FEE == null ? 0 : item.DIRECT_CM_FEE;
//			item.EDC_FEE = item.EDC_FEE == null ? 0 : item.EDC_FEE;
//			item.END_CASA = item.END_CASA == null ? 0 : item.END_CASA;
//			item.ENG_LOAN_OUT = item.ENG_LOAN_OUT == null ? 0 : item.ENG_LOAN_OUT;
//			item.Fee = item.Fee == null ? 0 : item.Fee;
//			item.FLEET_FEE = item.FLEET_FEE == null ? 0 : item.FLEET_FEE;
//			item.FRONT_END_FEE = item.FRONT_END_FEE == null ? 0 : item.FRONT_END_FEE;
//			item.FX_FEE = item.FX_FEE == null ? 0 : item.FX_FEE;
//			item.FX_VOLUME = item.FX_VOLUME == null ? 0 : item.FX_VOLUME;
//			item.IB_FEE = item.IB_FEE == null ? 0 : item.IB_FEE;
//			item.LG_FEE = item.LG_FEE == null ? 0 : item.LG_FEE;
//			item.NIIc = item.NIIc == null ? 0 : item.NIIc;
//			item.NIId = item.NIId == null ? 0 : item.NIId;
//			item.OTHER_CM_FEE = item.OTHER_CM_FEE == null ? 0 : item.OTHER_CM_FEE;
//			item.OTHER_FEE = item.OTHER_FEE == null ? 0 : item.OTHER_FEE;
//			item.TF_FEE = item.TF_FEE == null ? 0 : item.TF_FEE;
//			item.TF_VOLUME = item.TF_VOLUME == null ? 0 : item.TF_VOLUME;
//			mapPerformance.put((Id) item.AccouontId, item);
//		}
//		// Update Value    
//
//		List<AcctPlanProdStrategy__c> updateObject = new List<AcctPlanProdStrategy__c> ();
//
//		for (id accountId : mapAccountIdAcctPlanProdStrategy.keySet()) {
//			AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo performance;
//			decimal cahsfee = 0;
//			decimal creditFee = 0;
//			if (mapPerformance.containsKey(accountId)) {
//				performance = mapPerformance.get(accountId);
//				cahsfee = performance.DIRECT_CM_FEE + performance.OTHER_CM_FEE + performance.EDC_FEE + performance.FLEET_FEE;
//				creditFee = performance.CREDIT_FEE + performance.FRONT_END_FEE;
//			}
//			else {
//				performance = new AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo();
//				performance.AS_FEE = 0;
//				performance.AVG_CASA = 0;
//				performance.AVG_LOAN_OUT = 0;
//				performance.BA_FEE = 0;
//				performance.CREDIT_FEE = 0;
//				performance.DERIVATIVES_FEE = 0;
//				performance.DIRECT_CM_FEE = 0;
//				performance.EDC_FEE = 0;
//				performance.END_CASA = 0;
//				performance.ENG_LOAN_OUT = 0;
//				performance.Fee = 0;
//				performance.FLEET_FEE = 0;
//				performance.FRONT_END_FEE = 0;
//				performance.FX_FEE = 0;
//				performance.FX_VOLUME = 0;
//				performance.IB_FEE = 0;
//				performance.LG_FEE = 0;
//				performance.NIIc = 0;
//				performance.NIId = 0;
//				performance.OTHER_CM_FEE = 0;
//				performance.OTHER_FEE = 0;
//				performance.TF_FEE = 0;
//				performance.TF_VOLUME = 0;
//			}
//			AcctPlanWallet__c wallet = Wallets.get(accountId);
//
//			for (decimal seq : mapAccountIdAcctPlanProdStrategy.get(accountId).keySet()) {
//				AcctPlanProdStrategy__c item = mapAccountIdAcctPlanProdStrategy.get(accountId).get(seq);
//				updateObject.add(item);
//				if (!accountSEmap.containsKey(accountId)) {
//					// Update Wallet
//					if (getProductStrategyTemplate.containsKey(seq)) {
//						Decimal val = (Decimal) wallet.get(getProductStrategyTemplate.get(seq));
//
//						System.debug(' Seq : ' + seq + ' Value = ' + val);
//
//						item.WalletSizing__c = val == null ? 0 : val;
//					}
//				}
//				else {
//					Account act = accountSEmap.get(accountId);
//					// SE
//					if (seq == 1.00) {
//
//						item.AnnualizedPerformance__c = act.NIIc_Wallet__c;
//					} else if (seq == 2.00) {
//
//						item.AnnualizedPerformance__c = act.NIId_Wallet__c;
//					} else if (seq == 3.00) {
//
//						item.AnnualizedPerformance__c = act.Fee_Wallet__c;
//					} else {
//						item.WalletSizing__c = 0;
//					}
//
//				}
//
//				//Annualize
//				if (seq == 1.00) {
//					item.AnnualizedPerformance__c = performance.NIIc;
//				} else if (seq == 2.00) {
//					item.AnnualizedPerformance__c = performance.NIId;
//				} else if (seq == 3.00) {
//					item.AnnualizedPerformance__c = performance.Fee;
//				} else if (seq == 4.00) {
//					item.AnnualizedPerformance__c = 0;
//				} else if (seq == 5.00) {
//					item.AnnualizedPerformance__c = performance.TF_FEE;
//				} else if (seq == 6.00) {
//					item.AnnualizedPerformance__c = performance.FX_FEE;
//				} else if (seq == 7.00) {
//					item.AnnualizedPerformance__c = performance.LG_FEE;
//				} else if (seq == 8.00) {
//					item.AnnualizedPerformance__c = cahsfee;
//				} else if (seq == 9.00) {
//					item.AnnualizedPerformance__c = performance.AS_FEE;
//				} else if (seq == 10.00) {
//					item.AnnualizedPerformance__c = 0;
//				} else if (seq == 11.00) {
//					item.AnnualizedPerformance__c = creditFee;
//				} else if (seq == 12.00) {
//					item.AnnualizedPerformance__c = performance.BA_FEE;
//				} else if (seq == 13.00) {
//					item.AnnualizedPerformance__c = performance.DERIVATIVES_FEE;
//				} else if (seq == 14.00) {
//					item.AnnualizedPerformance__c = performance.IB_FEE;
//				}
//
//				item.RefreshAsOf__c = datetime.now();
//			}
//		}
//		//endregion    
//		update updateObject;
//		// Clear Heap
//		updateObject.clear();
//
//
//
//		/*********************************************************************
//		 *  Update Outstanding
//		 *********************************************************************/
//		Map<id /**Account Id */, AcctAnnualPerformance__c> mapUnderstanding = new Map<id /**Account Id */, AcctAnnualPerformance__c> ();
//		//Map<id/*wallet id*/,id/*Account Id*/> WalletIds= new Map<id/*Account Id*/,id/*wallet id*/>();
//		/*******************************************************************
//		 *  STEP 1) FIND  CUSTOMER UNDERSTANDING >> FIND AcctPlanWallet__c
//		 ******************************************************************/
//		List<AcctPlanCusUnderstanding__c> customerUnderstandings = AccountPlanCustomerUnderstandingSelector.getUnderstandingByWalletIds(WalletIds.keySet());
//
//		List<AcctAnnualPerformance__c> annualPerformances = AccountPlanAnnualPerformanceSelector.LastCustomerUnderstandardingByAccountIds(mapAccountIdAcctPlanProdStrategy.keySet());
//		for (AcctAnnualPerformance__c item : annualPerformances) {
//			if (!mapUnderstanding.containsKey(item.account__c)) {
//				//get first record is always recent record
//				mapUnderstanding.put(item.account__c, item);
//			}
//		}
//		Map<id /*account id */, AcctPlanCusUnderstanding__c> mapUpdateCusUnderstanding = new Map<id, AcctPlanCusUnderstanding__c> ();
//		// เราก็ได้ AcctAnnualPerformance__c  ต่อ Account 
//		for (AcctPlanCusUnderstanding__c item : customerUnderstandings) {
//			id walletid = item.AcctPlanWallet__c;
//			id accountId = WalletIds.get(walletid);
//
//			if (!mapUpdateCusUnderstanding.containsKey(accountId)) {
//				System.debug('::::: HIT AcctPlanCusUnderstanding__c ');
//				System.debug('::::: Wallet Id : ' + walletid);
//
//
//				AcctAnnualPerformance__c lastTransaction;
//				if (mapUnderstanding.containsKey(accountId)) {
//					lastTransaction = mapUnderstanding.get(accountId);
//				}
//				else {
//					lastTransaction = new AcctAnnualPerformance__c();
//					lastTransaction.AVG_LOAN_OUT__c = 0;
//					lastTransaction.ENG_LOAN_OUT__c = 0;
//					lastTransaction.AVG_CASA__c = 0;
//					lastTransaction.END_CASA__c = 0;
//					lastTransaction.TF_VOLUME__c = 0;
//					lastTransaction.FX_VOLUME__c = 0;
//				}
//
//
//
//				item.Average_loan_outstanding__c = lastTransaction.AVG_LOAN_OUT__c;
//				System.debug('::::: Wallet AVG_LOAN_OUT__c : ' + lastTransaction.AVG_LOAN_OUT__c);
//				item.Ending_loan_outstanding__c = lastTransaction.ENG_LOAN_OUT__c;
//				System.debug('::::: Wallet ENG_LOAN_OUT__c : ' + lastTransaction.ENG_LOAN_OUT__c);
//				item.Average_CASA__c = lastTransaction.AVG_CASA__c;
//				System.debug('::::: Wallet AVG_CASA__c : ' + lastTransaction.AVG_CASA__c);
//				item.Ending_CASA__c = lastTransaction.END_CASA__c;
//				System.debug('::::: Wallet END_CASA__c : ' + lastTransaction.END_CASA__c);
//				item.TF_Volume__c = lastTransaction.TF_VOLUME__c;
//				System.debug('::::: Wallet TF_VOLUME__c : ' + lastTransaction.TF_VOLUME__c);
//				item.FX_volume__c = lastTransaction.FX_VOLUME__c;
//				System.debug('::::: Wallet FX_VOLUME__c : ' + lastTransaction.FX_VOLUME__c);
//				item.RefreshAsOf__c = datetime.now();
//				mapUpdateCusUnderstanding.put(accountId, item);
//			}
//		}
//		update mapUpdateCusUnderstanding.values();
//
	}

	public void RefreshNameProductStrategyPort(Set<Id> accountIds, string year) {

		system.debug('::: CALL RefreshNameProductStrategyPort');
		Map<Id, String> mapAccountName = new Map<Id, String> ();


		/*TMBAccountPlanServiceProxy.CUSTOMER_INFO[] customerInfos = new List<TMBAccountPlanServiceProxy.CUSTOMER_INFO> ();
		String tempids = '';
		for (Id acct : accountIds) {
			tempids += acct + ',';
		}

		String ids = tempids.substring(0, tempids.length() - 1);
		system.debug('::: Ids = ' + ids);


		if (Test.isRunningTest()) {
			//unit testing alternative code goes here
			for (string item : accountIds)
			{
				TMBAccountPlanServiceProxy.CUSTOMER_INFO data1 = new TMBAccountPlanServiceProxy.CUSTOMER_INFO();
				data1.SF_ID = item;
				data1.CRM_ID = item;
				data1.TMB_CUST_ID = item;
				data1.FNAME = 'XXXXX' + item;
				data1.LNAME = 'XXXXX' + item;
				System.debug('::: data ' + data1);
				// Insert to List
				customerInfos.add(data1);
			}
		}
		else {
			//execute normally
			customerInfos = TMBAccountPlanServiceProxy.getCustomerByIds(ids);
		}
		system.debug('::::: Return data' + customerInfos);


		if (customerInfos != null) {
			if (customerInfos.size() > 0) {
				for (TMBAccountPlanServiceProxy.CUSTOMER_INFO custinfo : customerInfos) {
					if (string.isBlank(custinfo.LNAME))
					mapAccountName.put(custinfo.SF_ID, custinfo.FNAME);
					else
					mapAccountName.put(custinfo.SF_ID, custinfo.FNAME + ' ' + custinfo.LNAME);
				}
			}
		}*/
		List<Account> accountList = [SELECT ID,Name FROM Account WHERE ID = :accountIds];

		
			if (accountList.size() > 0) {
				for (Account custinfo : accountList) {
					if (string.isBlank(custinfo.Name)){
					mapAccountName.put(custinfo.id, custinfo.id);
					}else{
					mapAccountName.put(custinfo.id, custinfo.Name);
					}
				}
			}
		

          Datetime dt = Datetime.now();
		List<AcctPlanProdStrategyPort__c> quickUpdate = new List<AcctPlanProdStrategyPort__c> ();
		if (mapAccountName.size() > 0) {

			for (AcctPlanProdStrategyPort__c PrdPort : AccountPlanProductStrategyPortSelector.selectProductStrategyPortByAccountIdsAndYear(accountIds, year)) {

				if (mapAccountName.containsKey(PrdPort.AccountId__c))
				quickUpdate.add(new AcctPlanProdStrategyPort__c(id = PrdPort.id, AccountName__c = mapAccountName.get(PrdPort.AccountId__c),AsOfDate__c = dt));
			}
			update quickUpdate;
		}
	}

	public void RefreshProductStrategyPort(Set<Id> accountIds, string year) {

		/**********************************************************************
		 *  STEP 1) Delete all ProductStrategyPort
		 ***********************************************************************/
		List<AcctPlanProdStrategyPort__c> oldPrdPort = AccountPlanProductStrategyPortSelector.selectProductStrategyPortByAccountIdsAndYear(accountIds, year);
		delete oldPrdPort;
		oldPrdPort.clear();

		/**********************************************************************
		 *  STEP 2) Calculate Performance
		 *        ตัวแปรที่ได้ : mapPerformance 
		 ***********************************************************************/
		Map<Id, AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo> mapPerformance
		= new Map<Id, AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo> ();
		DateTime dt = datetime.now();
		for (AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo item
		     : AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDateInGroup(accountIds, dt)) {
			mapPerformance.put((Id) item.AccouontId, item);
		}


		/**********************************************************************
		 *  STEP 3) Get Account With Single View
		 *        ตัวแปรที่ได้ : mapPerformance 
		 ***********************************************************************/
		decimal AS_FEE = 0;
		decimal AVG_CASA = 0;
		decimal AVG_LOAN_OUT = 0;
		decimal BA_FEE = 0;
		decimal CREDIT_FEE = 0;
		decimal DERIVATIVES_FEE = 0;
		decimal DIRECT_CM_FEE = 0;
		decimal EDC_FEE = 0;
		decimal END_CASA = 0;
		decimal ENG_LOAN_OUT = 0;
		decimal Fee = 0;
		decimal FLEET_FEE = 0;
		decimal FRONT_END_FEE = 0;
		decimal FX_FEE = 0;
		decimal FX_VOLUME = 0;
		decimal IB_FEE = 0;
		decimal LG_FEE = 0;
		decimal NIIc = 0;
		decimal NIId = 0;
		decimal OTHER_CM_FEE = 0;
		decimal OTHER_FEE = 0;
		decimal TF_FEE = 0;
		decimal TF_VOLUME = 0;
		List<AcctPlanProdStrategyPort__c> newPrdPort = new List<AcctPlanProdStrategyPort__c> ();








	Map<Id, Account> mapAccount = new Map<Id, Account> (AccountSelector.getAccountWithSingleViewInfoByIds(accountIds));
	System.debug(loggingLevel.Error, '*** mapAccount.size(): ' + mapAccount.size());
	for (Account item : mapAccount.values()) {
		//reset
		AS_FEE = AVG_CASA = AVG_LOAN_OUT = BA_FEE = CREDIT_FEE = DERIVATIVES_FEE = DIRECT_CM_FEE = EDC_FEE = END_CASA = ENG_LOAN_OUT = Fee = FLEET_FEE = FRONT_END_FEE = FX_FEE = FX_VOLUME = IB_FEE = LG_FEE = NIIc = NIId = OTHER_CM_FEE = OTHER_FEE = TF_FEE = TF_VOLUME = 0;
		if (mapPerformance.containsKey(item.Id)) {
			AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo annualInfo = mapPerformance.get(item.Id);
			AS_FEE = annualInfo.AS_FEE == null ? 0 : annualInfo.AS_FEE;
			AVG_CASA = annualInfo.AVG_CASA == null ? 0 : annualInfo.AVG_CASA;
			AVG_LOAN_OUT = annualInfo.AVG_LOAN_OUT == null ? 0 : annualInfo.AVG_LOAN_OUT;
			BA_FEE = annualInfo.BA_FEE == null ? 0 : annualInfo.BA_FEE;
			CREDIT_FEE = annualInfo.CREDIT_FEE == null ? 0 : annualInfo.CREDIT_FEE;
			DERIVATIVES_FEE = annualInfo.DERIVATIVES_FEE == null ? 0 : annualInfo.DERIVATIVES_FEE;
			DIRECT_CM_FEE = annualInfo.DIRECT_CM_FEE == null ? 0 : annualInfo.DIRECT_CM_FEE;
			EDC_FEE = annualInfo.EDC_FEE == null ? 0 : annualInfo.EDC_FEE;
			END_CASA = annualInfo.END_CASA == null ? 0 : annualInfo.END_CASA;
			ENG_LOAN_OUT = annualInfo.ENG_LOAN_OUT == null ? 0 : annualInfo.ENG_LOAN_OUT;
			Fee = annualInfo.Fee == null ? 0 : annualInfo.Fee;
			FLEET_FEE = annualInfo.FLEET_FEE == null ? 0 : annualInfo.FLEET_FEE;
			FRONT_END_FEE = annualInfo.FRONT_END_FEE == null ? 0 : annualInfo.FRONT_END_FEE;
			FX_FEE = annualInfo.FX_FEE == null ? 0 : annualInfo.FX_FEE;
			FX_VOLUME = annualInfo.FX_VOLUME == null ? 0 : annualInfo.FX_VOLUME;
			IB_FEE = annualInfo.IB_FEE == null ? 0 : annualInfo.IB_FEE;
			LG_FEE = annualInfo.LG_FEE == null ? 0 : annualInfo.LG_FEE;
			NIIc = annualInfo.NIIc == null ? 0 : annualInfo.NIIc;
			NIId = annualInfo.NIId == null ? 0 : annualInfo.NIId;
			OTHER_CM_FEE = annualInfo.OTHER_CM_FEE == null ? 0 : annualInfo.OTHER_CM_FEE;
			OTHER_FEE = annualInfo.OTHER_FEE == null ? 0 : annualInfo.OTHER_FEE;
			TF_FEE = annualInfo.TF_FEE == null ? 0 : annualInfo.TF_FEE;
			TF_VOLUME = annualInfo.TF_VOLUME == null ? 0 : annualInfo.TF_VOLUME;


		}
		//(ar.get('AS_FEE')==null || ar.get('AS_FEE') == '')? 0: (Decimal) ar.get('AS_FEE');
		//1    1. NIIc
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               // AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 1.00,
		                                               Name = '1. NIIc',
		                                               AccountId__c = item.Id,
		                                               WalletSizing__c = item.NIIc_Wallet__c == null ? 0 : item.NIIc_Wallet__c,
		                                               AnnualizedPerformance__c = NIIc,
		                                               Adjust_NI__c = NIIc,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
            										   GroupCompany__c = item.Group__c,
		                                               ExpectedIncrementalNIFreeText__c = 0 , AsOfDate__c = Datetime.now()
		));
		//2    2. NIId
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               // AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 2.00,
		                                               Name = '2. NIId',
		                                               AccountId__c = item.Id,
		                                               WalletSizing__c = item.NIId_Wallet__c == null ? 0 : item.NIId_Wallet__c,
		                                               AnnualizedPerformance__c = NIId,
		                                               Adjust_NI__c = NIId,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
            										   GroupCompany__c = item.Group__c,
		                                               ExpectedIncrementalNIFreeText__c = 0, AsOfDate__c = Datetime.now()
		));
		//3    3. Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               // AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 3.00,
		                                               Name = '3. Fee',
		                                               AccountId__c = item.Id,
		                                               WalletSizing__c = item.Fee_Wallet__c == null ? 0 : item.Fee_Wallet__c,
		                                               AnnualizedPerformance__c = Fee,
		                                               Adjust_NI__c = 0,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
                        							   GroupCompany__c = item.Group__c,
		                                               ExpectedIncrementalNIFreeText__c = 0, AsOfDate__c = Datetime.now()
		));
		//4    Recurring Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               //  AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 4.00,
		                                               Name = 'Recurring Fee',
		                                               AccountId__c = item.Id,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = 0,
		                                               Adjust_NI__c = 0,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
             										   GroupCompany__c = item.Group__c,           
		                                               ExpectedIncrementalNIFreeText__c = 0, AsOfDate__c =  Datetime.now()
		));
		//5    3.1 TF Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               // AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 5.00,
		                                               Name = '3.1 TF Fee',
		                                               AccountId__c = item.Id,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = TF_FEE,
		                                               Adjust_NI__c = TF_FEE,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
             										   GroupCompany__c = item.Group__c,        
		                                               ExpectedIncrementalNIFreeText__c = 0 ,AsOfDate__c = Datetime.now()
		));
		//6    3.2 Fx Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               SEQ__c = 6.00,
		                                               Name = '3.2 FX Fee',
		                                               AccountId__c = item.Id,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = FX_FEE,
		                                               Adjust_NI__c = FX_FEE,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
             										   GroupCompany__c = item.Group__c,           
		                                               ExpectedIncrementalNIFreeText__c = 0 ,AsOfDate__c = Datetime.now()
		));
		//7    3.3 L/G Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               //   AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 7.00,
		                                               Name = '3.3 L/G Fee',
		                                               AccountId__c = item.Id,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = LG_FEE,
		                                               Adjust_NI__c = LG_FEE,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
            										   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0 ,AsOfDate__c = Datetime.now()
		));
		//8    3.4 Cash Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               //   AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 8.00,
		                                               Name = '3.4 Cash Fee',
		                                               AccountId__c = item.Id,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = DIRECT_CM_FEE + OTHER_CM_FEE + EDC_FEE + FLEET_FEE,
		                                               Adjust_NI__c = DIRECT_CM_FEE + OTHER_CM_FEE + EDC_FEE + FLEET_FEE,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
            										   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0, AsOfDate__c = Datetime.now()
		));
		//9    3.5 AS Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               //       AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 9.00,
		                                               Name = '3.5 AS Fee',
		                                               AccountId__c = item.Id,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = AS_FEE,
		                                               Adjust_NI__c = AS_FEE,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
            										   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0, AsOfDate__c = Datetime.now()
		));
		//10   Non recurring fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               //    AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 10.00,
		                                               Name = 'Non Recurring Fee',
		                                               AccountId__c = item.Id,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = 0,
		                                               Adjust_NI__c = 0,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
            										   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0, AsOfDate__c = Datetime.now()
		));
		//11   3.6 Credit fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               //    AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 11.00,
		                                               Name = '3.6 Credit Fee',
		                                               AccountId__c = item.Id,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = CREDIT_FEE + FRONT_END_FEE,
		                                               Adjust_NI__c = CREDIT_FEE + FRONT_END_FEE,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
            										   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0, AsOfDate__c = Datetime.now()
		));
		//12   3.7 BA Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               //    AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 12.00,
		                                               Name = '3.7 BA Fee',
		                                               AccountId__c = item.Id,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = BA_FEE,
		                                               Adjust_NI__c = BA_FEE,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
            										   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0, AsOfDate__c = Datetime.now()
		));
		//13   3.8 Derivative Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               //      AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 13.00,
		                                               Name = '3.8 Derivative Fee',
		                                               AccountId__c = item.Id,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = DERIVATIVES_FEE,
		                                               Adjust_NI__c = DERIVATIVES_FEE,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
            										   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0 ,AsOfDate__c = Datetime.now()
		));
		//14   3.9 IB Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               //      AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 14.00,
		                                               Name = '3.9 IB Fee',
		                                               AccountId__c = item.Id,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = IB_FEE,
		                                               Adjust_NI__c = IB_FEE,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
            										   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0, AsOfDate__c = Datetime.now()
		));
	}
	insert newPrdPort;
	}


/**********************************************************************
	 * Group Wallet & Group Performance R5.2
***********************************************************************/
/*Start R5.2 refresh product strategy when refresh Group Wallet & Group Performance*/
	public void RefreshProductStrategyGroupWalletGroupPerformance(Set<Id> acctId,Set<Id> acctPlanCompanyId, Set<Id>  acctPlanWallet, String acctPlanGroupId) {

		// 1) Find Account Profile `
		//AcctPlanCompanyProfile__c accPlanProfile;
		system.debug('::: acctPlanCompanyId  >> ' + acctPlanCompanyId);
		List<AcctPlanCompanyProfile__c> accPlanProfiles = AccountPlanCompanyProfileSelector.getCompanyProfileIds(acctPlanCompanyId);
		/*if (accPlanProfiles.size() > 0) {
			accPlanProfile = accPlanProfiles[0];
		}*/

		// 2) Account Plan Wallet
		//AcctPlanWallet__c wallet;
		Map<id,AcctPlanWallet__c> walletMap = new Map<id,AcctPlanWallet__c>();
		List<AcctPlanWallet__c> wallets = AccountPlanWalletSelector.getWalletByIds(acctPlanWallet);
		if (wallets.size() > 0) {
			//wallet = wallets[0];
			for(AcctPlanWallet__c item : wallets){
				walletMap.put(item.id,item);
			}
		}

		// 3) Get Performance 
		//AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo performance12month;
		//region
		List<AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo> performance12months
		= AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDateInGroup(acctId, datetime.now());

		//Map<id,List<AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo> > mapperformance12months = new Map<id,List<AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo> >();
		/*if (performance12months.size() > 0) {
			performance12month = performance12months[0];
		}
		else {

			performance12month = new AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo();
			performance12month.AccouontId = '';
			performance12month.AS_FEE = 0;
			performance12month.AVG_CASA = 0;
			performance12month.AVG_LOAN_OUT = 0;
			performance12month.BA_FEE = 0;
			performance12month.CREDIT_FEE = 0;
			performance12month.DERIVATIVES_FEE = 0;
			performance12month.DIRECT_CM_FEE = 0;
			performance12month.EDC_FEE = 0;
			performance12month.END_CASA = 0;
			performance12month.ENG_LOAN_OUT = 0;
			performance12month.Fee = 0;
			performance12month.FLEET_FEE = 0;
			performance12month.FRONT_END_FEE = 0;
			performance12month.FX_FEE = 0;
			performance12month.FX_VOLUME = 0;
			performance12month.IB_FEE = 0;
			performance12month.LG_FEE = 0;
			performance12month.NIIc = 0;
			performance12month.NIId = 0;
			performance12month.OTHER_CM_FEE = 0;
			performance12month.OTHER_FEE = 0;
			performance12month.TF_FEE = 0;
			performance12month.TF_VOLUME = 0;
		}*/
		//endregion
		Map<Id,Map<Decimal,Decimal>> MapIdPerformance12monthMap = new Map<Id,Map<Decimal,Decimal>>();
		Map<Id, AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo> mapPerformance
		= new Map<Id, AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo> ();
		//DateTime dt = datetime.now();
		for (AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo item : performance12months) {
			mapPerformance.put((Id) item.AccouontId, item);
		}

		for (Id item : acctId) {
		if (mapPerformance.containsKey(item)) {
			AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo performance12month = mapPerformance.get(item);
			system.debug('(performance12month.NIId ='+performance12month.NIId );
			system.debug('(performance12month.NIIc ='+performance12month.NIIc );
			Map<Decimal /* SEQ*/, Decimal> mapPerformance12month = new Map<Decimal /* SEQ*/, Decimal> ();
			mapPerformance12month.put(1.00, (performance12month.NIIc == null ? 0 : performance12month.NIIc));
			mapPerformance12month.put(2.00, (performance12month.NIId == null ? 0 : performance12month.NIId));
			mapPerformance12month.put(3.00, (performance12month.Fee == null ? 0 : performance12month.Fee));
			mapPerformance12month.put(4.00, 0);
			mapPerformance12month.put(5.00, (performance12month.TF_FEE == null ? 0 : performance12month.TF_FEE));
			mapPerformance12month.put(6.00, (performance12month.FX_FEE == null ? 0 : performance12month.FX_FEE));
			mapPerformance12month.put(7.00, (performance12month.LG_FEE == null ? 0 : performance12month.LG_FEE));
			decimal cahsfee = (performance12month.DIRECT_CM_FEE == null ? 0 : performance12month.DIRECT_CM_FEE) +
			(performance12month.OTHER_CM_FEE == null ? 0 : performance12month.OTHER_CM_FEE) +
			(performance12month.EDC_FEE == null ? 0 : performance12month.EDC_FEE) +
			(performance12month.FLEET_FEE == null ? 0 : performance12month.FLEET_FEE);
			mapPerformance12month.put(8.00 /*Cash FEE */, cahsfee);
			mapPerformance12month.put(9.00, (performance12month.AS_FEE == null ? 0 : performance12month.AS_FEE));
			mapPerformance12month.put(10.00, 0);
			Decimal creditFee = (performance12month.CREDIT_FEE == null ? 0 : performance12month.CREDIT_FEE)
			 + (performance12month.FRONT_END_FEE == null ? 0 : performance12month.FRONT_END_FEE);
			mapPerformance12month.put(11.00, creditFee);
			mapPerformance12month.put(12.00, (performance12month.BA_FEE == null ? 0 : performance12month.BA_FEE));
			mapPerformance12month.put(13.00, (performance12month.DERIVATIVES_FEE == null ? 0 : performance12month.DERIVATIVES_FEE));
			mapPerformance12month.put(14.00, (performance12month.IB_FEE == null ? 0 : performance12month.IB_FEE));

			MapIdPerformance12monthMap.put(item,mapPerformance12month);
		}
		}

		System.debug(loggingLevel.Error, '*** acctPlanWallet: ' + acctPlanWallet);
		List<AcctPlanCusUnderstanding__c> customerUnderstandings = AccountPlanCustomerUnderstandingSelector.getUnderstandingByWalletIds(acctPlanWallet);
		List<AcctAnnualPerformance__c> lastTransaction = [SELECT Id,MonthYear__c, Account__c,AS_FEE__c,AVG_CASA__c,AVG_LOAN_OUT__c,  
			BA_FEE__c,CREDIT_FEE__c,DERIVATIVES_FEE__c,DIRECT_CM_FEE__c,EDC_FEE__c,  
			END_CASA__c,ENG_LOAN_OUT__c,External_Key__c,Fee__c,FLEET_FEE__c,FRONT_END_FEE__c,FX_FEE__c,FX_VOLUME__c, 
			IB_FEE__c,LG_FEE__c,Month__c,Name,NIIc__c,NIId__c,OTHER_CM_FEE__c,OTHER_FEE__c,TF_FEE__c,TF_VOLUME__c,  
			TMB_CUST_ID__c,Transaction_Date__c,Year__c FROM AcctAnnualPerformance__c 
			where account__c IN : acctId  order by Account__c,Transaction_Date__c desc];
		
		System.debug(loggingLevel.Error, '*** lastTransaction: ' + lastTransaction.size());
		System.debug(loggingLevel.Error, '*** customerUnderstandings: ' + customerUnderstandings.size());
		System.debug(loggingLevel.Error, '*** acctPlanWallet: ' + acctPlanWallet);
		//UpsertCustomerUnderstanding(lastTransaction, customerUnderstandings, acctPlanWallet);
		Map<id,AcctPlanCusUnderstanding__c> customerUnderstandingsMap = new Map<id,AcctPlanCusUnderstanding__c>();
		List<AcctPlanCusUnderstanding__c> customerUnderstandingUpdateListRefreshDate = new List<AcctPlanCusUnderstanding__c>();
		for(AcctPlanCusUnderstanding__c item : customerUnderstandings){
			if(!customerUnderstandingsMap.containsKey(item.AcctPlanWallet__r.AcctPlanCompanyProfile__r.Account__c)){
				customerUnderstandingsMap.put(item.AcctPlanWallet__r.AcctPlanCompanyProfile__r.Account__c,item);
			}	
				item.RefreshAsOf__c = datetime.now();
				customerUnderstandingUpdateListRefreshDate.add(item);

		}
		if(customerUnderstandingUpdateListRefreshDate.size()>0){
			update customerUnderstandingUpdateListRefreshDate;
		}

		Map<id,AcctAnnualPerformance__c> AcctAnnualPerformanceMap = new Map<id,AcctAnnualPerformance__c>();
		for(AcctAnnualPerformance__c item : lastTransaction){
			if(!AcctAnnualPerformanceMap.containsKey(item.Account__c)){
				AcctAnnualPerformanceMap.put(item.Account__c,item);
			}	
		}

		if (lastTransaction.size() > 0) {
			System.debug(loggingLevel.Error, '*** acctPlanWallet: ' + acctPlanWallet);
			if (customerUnderstandings.size() > 0)
			{
				System.debug(loggingLevel.Error, '*** AcctAnnualPerformanceMap.keySet(): ' + AcctAnnualPerformanceMap.keySet());
				List<AcctPlanCusUnderstanding__c> customerUnderstandingUpdateList = new List<AcctPlanCusUnderstanding__c>();
				for(Id item : AcctAnnualPerformanceMap.keySet()){
					if (customerUnderstandingsMap.containsKey(item)) {
						System.debug(loggingLevel.Error, '*** customerUnderstandingsMap.containsKey(item): ' + customerUnderstandingsMap.containsKey(item));
				
					AcctPlanCusUnderstanding__c customerUnderstanding = customerUnderstandingsMap.get(item);
					customerUnderstanding.Average_loan_outstanding__c = AcctAnnualPerformanceMap.get(item).AVG_LOAN_OUT__c;
					customerUnderstanding.Ending_loan_outstanding__c = AcctAnnualPerformanceMap.get(item).ENG_LOAN_OUT__c;
					customerUnderstanding.Average_CASA__c = AcctAnnualPerformanceMap.get(item).AVG_CASA__c;
					customerUnderstanding.Ending_CASA__c = AcctAnnualPerformanceMap.get(item).END_CASA__c;
					customerUnderstanding.TF_Volume__c = AcctAnnualPerformanceMap.get(item).TF_VOLUME__c;
					customerUnderstanding.FX_volume__c = AcctAnnualPerformanceMap.get(item).FX_VOLUME__c;
					customerUnderstanding.RefreshAsOf__c = datetime.now();
					customerUnderstandingUpdateList.add(customerUnderstanding);
					}
				}
				update customerUnderstandingUpdateList;
			}
			
		}
		


		// 4 Update From Product
		/*--------------------------------------------------------------------
		 *           Account Product ProdStrategy
		 * --------------------------------------------------------------------*/
		List<AcctPlanProdStrategy__c> acctPlanProdStrategies = AccountPlanProductStrategyService.getCompaniesProductStrategy(acctPlanCompanyId);
		datetime dt = datetime.now();



Map<id, Account> accountSEmap = new Map<id, Account> ();
	for (Account acc : AccountSelector.getAccountWithSingleViewInfoByIds(acctId)) {
				//if (acc.Owner.Segment__c == 'SE') {
					System.debug('::: HIT SE CUSTOMER');
					if (!accountSEmap.containsKey(acc.Id)) {
						accountSEmap.put(acc.Id, acc);
						//accountIds.remove(acc.Id);s
					}
				//}
			}
		/************************************************
		 *  SE CASE
		 ************************************************/
		
List<AcctPlanProdStrategy__c> acctPlanProdStrategiesUpdate = new  List<AcctPlanProdStrategy__c>();
		
			for (AcctPlanProdStrategy__c prostr : acctPlanProdStrategies) {
				prostr.RefreshAsOf__c = dt;
				if(prostr.AcctPlanCompanyProfileID__r.isMiniMode__c){
					
					if (prostr.SEQ__c == 1.00) {
						prostr.WalletSizing__c = accountSEmap.get(prostr.AccountId__c).NIIc_Wallet__c;


					} else if (prostr.SEQ__c == 2.00) {
						prostr.WalletSizing__c = accountSEmap.get(prostr.AccountId__c).NIId_Wallet__c;


					} else if (prostr.SEQ__c == 3.00) {
						prostr.WalletSizing__c = accountSEmap.get(prostr.AccountId__c).Fee_Wallet__c;


					}
					else {
						prostr.WalletSizing__c = 0;

					}
					//prostr.AnnualizedPerformance__c = (Decimal) mapPerformance12month.get(prostr.Seq__c);
				}else{
					Decimal val;
					if (prostr.WalletFieldName__c != '' && prostr.WalletFieldName__c != null) {
						//val = (Decimal) walletMap.get(prostr.AcctPlanWallet__c).WalletFieldName__c;
						AcctPlanWallet__c walletItem = walletMap.get(prostr.AcctPlanWallet__c);
						val = (Decimal) walletItem.get(prostr.WalletFieldName__c);
					}
					if (val == null) {
						val = 0;
					}
					prostr.WalletSizing__c = val;
					
					/*if (acctPlanGruopId != null && acctPlanGruopId != '') {
						prostr.AcctPlanGroupProfileID__c = acctPlanGroupId;
					}*/
				}
				if (MapIdPerformance12monthMap.containsKey(prostr.AccountId__c)) {
				system.debug('MapIdPerformance12monthMap= '+MapIdPerformance12monthMap);
				system.debug('MapIdPerformance12monthMap.get(prostr.AccountId__c= '+MapIdPerformance12monthMap.get(prostr.AccountId__c));
				
				system.debug('prostr.AccountId__c= '+prostr.AccountId__c);
				
				Map<Decimal,Decimal> MapPerformance12month =  MapIdPerformance12monthMap.get(prostr.AccountId__c);
				system.debug('MapPerformance12month= '+MapPerformance12month);
				system.debug('Map= '+MapPerformance12month.get(prostr.Seq__c));
				prostr.AnnualizedPerformance__c = MapPerformance12month.get(prostr.Seq__c);
				}

				if (acctPlanGroupId != null && acctPlanGroupId != '') {
					prostr.AcctPlanGroupProfileID__c = acctPlanGroupId;
				}
				
				acctPlanProdStrategiesUpdate.add(prostr);
			}

			/*--------------------------------------------------------------------
		 *           Account Plan Wallet By Domain 
		 * --------------------------------------------------------------------*/
		List<AcctPlanWalletByDomain__c> walletByDomains = AccountPlanWalletByDomainSelector.getWalletByDomainByWallets(walletMap.keyset());
		List<AcctPlanWalletByDomain__c> walletByDomainsUpdate = new List<AcctPlanWalletByDomain__c>();
		// >> start for
		for (AcctPlanWalletByDomain__c wallDomain : walletByDomains) {
			AcctPlanWallet__c walletItem = walletMap.get(wallDomain.AcctPlanWallet__c);
			system.debug(' Type Of NI >> ' + wallDomain.TypeOfNI__c + ' SubDomain >> ' + wallDomain.Domain__c);
			Decimal val = 0;
			if (wallDomain.WalletFieldName__c != null && wallDomain.WalletFieldName__c != '') {
				System.debug('Wallet Field Name : '+wallDomain.WalletFieldName__c);
				if (wallDomain.WalletFieldName__c.contains(',')) {
					for (String fieldName : wallDomain.WalletFieldName__c.split(',')) {
						system.debug(' fieldName >> ' + fieldName);
						
						val += (Decimal) ( walletItem.get(fieldName) == null ? 0 :  walletItem.get(fieldName));
					}
				}
				else {
					val += (Decimal) (walletItem.get(wallDomain.WalletFieldName__c) == null ? 0 : walletItem.get(wallDomain.WalletFieldName__c));
				}
			}
			wallDomain.AdjWalletUnit__c = val;
			walletByDomainsUpdate.add(wallDomain);
		}
		/*for (AcctPlanWalletByDomain__c wallDomain : walletByDomains) {

			system.debug(' Type Of NI >> ' + wallDomain.TypeOfNI__c + ' SubDomain >> ' + wallDomain.Domain__c);
			Decimal val = 0;
			if (wallDomain.WalletFieldName__c != null && wallDomain.WalletFieldName__c != '') {
				System.debug('Wallet Field Name : '+wallDomain.WalletFieldName__c);
				if (wallDomain.WalletFieldName__c.contains(',')) {
					for (String fieldName : wallDomain.WalletFieldName__c.split(',')) {
						system.debug(' fieldName >> ' + fieldName);
						val += (Decimal) (wallet.get(fieldName) == null ? 0 : wallet.get(fieldName));
					}
				}
				else {
					val += (Decimal) (wallet.get(wallDomain.WalletFieldName__c) == null ? 0 : wallet.get(wallDomain.WalletFieldName__c));
				}
			}
			wallDomain.AdjWalletUnit__c = val;
		}*/

		try {

			update walletByDomainsUpdate;
			//update acctPlanProdStrategies;
			update acctPlanProdStrategiesUpdate;
		}
		catch(Exception ex) {

			system.debug('::: Error >> ' + ex.getMessage());
			throw ex;

		}



	}
	/*End R5.2 refresh product strategy when refresh Group Wallet & Group Performance*/

	public void RefreshProductStrategyPort(Set<Id> accountIds, string year,Id groupId) {

		/**********************************************************************
		 *  STEP 1) Delete all ProductStrategyPort
		 ***********************************************************************/
		List<AcctPlanProdStrategyPort__c> oldPrdPort = AccountPlanProductStrategyPortSelector.selectProductStrategyPortByAccountIdsAndYear(accountIds, year);
		System.debug(loggingLevel.Error, '*** oldPrdPort.size(): ' + oldPrdPort.size());

        if(oldPrdPort.size()>0){
			delete oldPrdPort;
			oldPrdPort.clear();
        }
        
        List<AccountPlanWalletSizing__c> walletWrapperListQuery = [SELECT Id 
                                                                   FROM AccountPlanWalletSizing__c
                                                                   WHERE Group__c = :groupId
                                                                   AND Year__c = :year
                                                                   AND Account__c IN :accountIds
                                                                   ];
         System.debug(loggingLevel.Error, '*** walletWrapperListQuery.size(): ' + walletWrapperListQuery.size());
                     
        if(walletWrapperListQuery.size()>0){
        	delete walletWrapperListQuery;
       	 	walletWrapperListQuery.clear();
        }
		/**********************************************************************
		 *  STEP 2) Calculate Performance
		 *        ตัวแปรที่ได้ : mapPerformance 
		 ***********************************************************************/
		Map<Id, AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo> mapPerformance
		= new Map<Id, AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo> ();
		DateTime dt = datetime.now();
		for (AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo item
		     : AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDateInGroup(accountIds, dt)) {
			mapPerformance.put((Id) item.AccouontId, item);
		}


		/**********************************************************************
		 *  STEP 3) Get Account With Single View
		 *        ตัวแปรที่ได้ : mapPerformance 
		 ***********************************************************************/
		decimal AS_FEE = 0;
		decimal AVG_CASA = 0;
		decimal AVG_LOAN_OUT = 0;
		decimal BA_FEE = 0;
		decimal CREDIT_FEE = 0;
		decimal DERIVATIVES_FEE = 0;
		decimal DIRECT_CM_FEE = 0;
		decimal EDC_FEE = 0;
		decimal END_CASA = 0;
		decimal ENG_LOAN_OUT = 0;
		decimal Fee = 0;
		decimal FLEET_FEE = 0;
		decimal FRONT_END_FEE = 0;
		decimal FX_FEE = 0;
		decimal FX_VOLUME = 0;
		decimal IB_FEE = 0;
		decimal LG_FEE = 0;
		decimal NIIc = 0;
		decimal NIId = 0;
		decimal OTHER_CM_FEE = 0;
		decimal OTHER_FEE = 0;
		decimal TF_FEE = 0;
		decimal TF_VOLUME = 0;
		List<AcctPlanProdStrategyPort__c> newPrdPort = new List<AcctPlanProdStrategyPort__c> ();

		/************************************************************************************
		 *  STEP 3.1) Get Account With Single View --> Insert to AccountPlanWalletSizing__c
		 *            And Sum AccountPlanWalletSizing__c (Group Wallet Sizing (Yearly))
		 *************************************************************************************/
        List<AccountPlanWalletSizing__c> walletSizing = new List<AccountPlanWalletSizing__c>();
        List<AcctPlanCusUnderstanding__c> customerUnderstandingList = new List<AcctPlanCusUnderstanding__c>();
        Map<Id, Account> mapAccount = new Map<Id, Account> (AccountSelector.getAccountWithSingleViewInfoByIds(accountIds));
        System.debug(loggingLevel.Error, '*** mapAccount.size(): ' + mapAccount.size());

        List<AccountPlanWalletSizing__c> SumWalletSizingList = [SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,AccountId_PE__c,
                                                                NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,AccountNamePE__c
                                                                FROM AccountPlanWalletSizing__c
                                                                WHERE Group__c = :groupId
                                                                AND Year__c = :year
                                                                AND SummaryType__c  = 'WalletSizing' LIMIT 1];
        AccountPlanWalletSizing__c SumWalletSizing = new AccountPlanWalletSizing__c();
        System.debug(loggingLevel.Error, '*** SumWalletSizingList.size(): ' + SumWalletSizingList.size());
        if(SumWalletSizingList.size()>0){
            SumWalletSizing = SumWalletSizingList.get(0);
        }
        

        /******************************************************************************************************
		 *  Start loop create ProductStrategyPort, WalletSizing and Sum WalletSizing Yearly
		 ******************************************************************************************************/
        for (Account item : mapAccount.values()) {
		//reset

		AS_FEE = AVG_CASA = AVG_LOAN_OUT = BA_FEE = CREDIT_FEE = DERIVATIVES_FEE = DIRECT_CM_FEE = EDC_FEE = END_CASA = ENG_LOAN_OUT = Fee = FLEET_FEE = FRONT_END_FEE = FX_FEE = FX_VOLUME = IB_FEE = LG_FEE = NIIc = NIId = OTHER_CM_FEE = OTHER_FEE = TF_FEE = TF_VOLUME = 0;
		if (mapPerformance.containsKey(item.Id)) {
			AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo annualInfo = mapPerformance.get(item.Id);
			AS_FEE = annualInfo.AS_FEE == null ? 0 : annualInfo.AS_FEE;
			AVG_CASA = annualInfo.AVG_CASA == null ? 0 : annualInfo.AVG_CASA;
			AVG_LOAN_OUT = annualInfo.AVG_LOAN_OUT == null ? 0 : annualInfo.AVG_LOAN_OUT;
			BA_FEE = annualInfo.BA_FEE == null ? 0 : annualInfo.BA_FEE;
			CREDIT_FEE = annualInfo.CREDIT_FEE == null ? 0 : annualInfo.CREDIT_FEE;
			DERIVATIVES_FEE = annualInfo.DERIVATIVES_FEE == null ? 0 : annualInfo.DERIVATIVES_FEE;
			DIRECT_CM_FEE = annualInfo.DIRECT_CM_FEE == null ? 0 : annualInfo.DIRECT_CM_FEE;
			EDC_FEE = annualInfo.EDC_FEE == null ? 0 : annualInfo.EDC_FEE;
			END_CASA = annualInfo.END_CASA == null ? 0 : annualInfo.END_CASA;
			ENG_LOAN_OUT = annualInfo.ENG_LOAN_OUT == null ? 0 : annualInfo.ENG_LOAN_OUT;
			Fee = annualInfo.Fee == null ? 0 : annualInfo.Fee;
			FLEET_FEE = annualInfo.FLEET_FEE == null ? 0 : annualInfo.FLEET_FEE;
			FRONT_END_FEE = annualInfo.FRONT_END_FEE == null ? 0 : annualInfo.FRONT_END_FEE;
			FX_FEE = annualInfo.FX_FEE == null ? 0 : annualInfo.FX_FEE;
			FX_VOLUME = annualInfo.FX_VOLUME == null ? 0 : annualInfo.FX_VOLUME;
			IB_FEE = annualInfo.IB_FEE == null ? 0 : annualInfo.IB_FEE;
			LG_FEE = annualInfo.LG_FEE == null ? 0 : annualInfo.LG_FEE;
			NIIc = annualInfo.NIIc == null ? 0 : annualInfo.NIIc;
			NIId = annualInfo.NIId == null ? 0 : annualInfo.NIId;
			OTHER_CM_FEE = annualInfo.OTHER_CM_FEE == null ? 0 : annualInfo.OTHER_CM_FEE;
			OTHER_FEE = annualInfo.OTHER_FEE == null ? 0 : annualInfo.OTHER_FEE;
			TF_FEE = annualInfo.TF_FEE == null ? 0 : annualInfo.TF_FEE;
			TF_VOLUME = annualInfo.TF_VOLUME == null ? 0 : annualInfo.TF_VOLUME;

			
		}
        
        AcctPlanCusUnderstanding__c customerUnderstanding = new AcctPlanCusUnderstanding__c();
				//customerUnderstanding.AcctPlanWallet__c = acctPlanWallet;
				customerUnderstanding.Average_loan_outstanding__c = AVG_LOAN_OUT;
				customerUnderstanding.Ending_loan_outstanding__c = ENG_LOAN_OUT;
				customerUnderstanding.Average_CASA__c = AVG_CASA;
				customerUnderstanding.Ending_CASA__c = END_CASA;
				customerUnderstanding.TF_Volume__c = TF_VOLUME;
				customerUnderstanding.FX_volume__c = FX_VOLUME;
				customerUnderstanding.RefreshAsOf__c = datetime.now();
				customerUnderstanding.Account__c = item.id;
				customerUnderstanding.year__c = year;
				customerUnderstanding.AccountName__c = item.Name;
				customerUnderstandingList.add(customerUnderstanding);
        
        AccountPlanWalletSizing__c  ws = new AccountPlanWalletSizing__c ();
		//(ar.get('AS_FEE')==null || ar.get('AS_FEE') == '')? 0: (Decimal) ar.get('AS_FEE');
		//1    1. NIIc
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               // AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 1.00,
		                                               Name = '1. NIIc',
		                                               AccountId__c = item.Id,
            										   AccountId_PE__c = item.Id,
            										   AccountName__c = item.Name,
		                                               WalletSizing__c = item.NIIc_Wallet__c == null ? 0 : item.NIIc_Wallet__c,
		                                               AnnualizedPerformance__c = NIIc,
		                                               Adjust_NI__c = NIIc,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
                        							   GroupCompany__c = item.Group__c,
		                                               ExpectedIncrementalNIFreeText__c = 0 , AsOfDate__c = Datetime.now()
		));
            ws.NIIc__c = item.NIIc_Wallet__c == null ? 0 : item.NIIc_Wallet__c;
            SumWalletSizing.NIIc__c = (SumWalletSizing.NIIc__c == null ? 0.00 : SumWalletSizing.NIIc__c)  + ws.NIIc__c ;
            
		//2    2. NIId
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               // AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 2.00,
		                                               Name = '2. NIId',
		                                               AccountId__c = item.Id,
            										   AccountId_PE__c = item.Id,
            										   AccountName__c = item.Name,
		                                               WalletSizing__c = item.NIId_Wallet__c == null ? 0 : item.NIId_Wallet__c,
		                                               AnnualizedPerformance__c = NIId,
		                                               Adjust_NI__c = NIId,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
                        							   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0, AsOfDate__c = Datetime.now()
		));
            ws.NIId__c = item.NIId_Wallet__c == null ? 0 : item.NIId_Wallet__c;
            SumWalletSizing.NIId__c = (SumWalletSizing.NIId__c == null ? 0.00 : SumWalletSizing.NIId__c)  + ws.NIId__c ;
		//3    3. Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               // AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 3.00,
		                                               Name = '3. Fee',
		                                               AccountId__c = item.Id,
            										   AccountId_PE__c = item.Id,
            										   AccountName__c = item.Name,
		                                               WalletSizing__c = item.Fee_Wallet__c == null ? 0 : item.Fee_Wallet__c,
		                                               AnnualizedPerformance__c = Fee,
		                                               Adjust_NI__c = 0,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
                        							   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0, AsOfDate__c = Datetime.now()
		));
            ws.Fee__c = item.Fee_Wallet__c == null ? 0 : item.Fee_Wallet__c;
            SumWalletSizing.Fee__c = (SumWalletSizing.Fee__c == null ? 0.00 : SumWalletSizing.Fee__c)  + ws.Fee__c ;
		//4    Recurring Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               //  AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 4.00,
		                                               Name = 'Recurring Fee',
		                                               AccountId__c = item.Id,
            										   AccountId_PE__c = item.Id,
            										   AccountName__c = item.Name,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = 0,
		                                               Adjust_NI__c = 0,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
                        							   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0, AsOfDate__c =  Datetime.now()
		));
            ws.RecurringFee__c = '';
            SumWalletSizing.RecurringFee__c = '';
		//5    3.1 TF Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               // AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 5.00,
		                                               Name = '3.1 TF Fee',
		                                               AccountId__c = item.Id,
            										   AccountId_PE__c = item.Id,
            										   AccountName__c = item.Name,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = TF_FEE,
		                                               Adjust_NI__c = TF_FEE,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
                        							   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0 ,AsOfDate__c = Datetime.now()
		));
            ws.TFFee__c = 0;
            SumWalletSizing.TFFee__c = (SumWalletSizing.TFFee__c == null ? 0.00 : SumWalletSizing.TFFee__c)  + ws.TFFee__c ;
		//6    3.2 Fx Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               SEQ__c = 6.00,
		                                               Name = '3.2 FX Fee',
		                                               AccountId__c = item.Id,
            										   AccountId_PE__c = item.Id,
            										   AccountName__c = item.Name,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = FX_FEE,
		                                               Adjust_NI__c = FX_FEE,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
                        							   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0 ,AsOfDate__c = Datetime.now()
		));
            ws.FXFee__c = 0;
            SumWalletSizing.FXFee__c = (SumWalletSizing.FXFee__c == null ? 0.00 : SumWalletSizing.FXFee__c)  + ws.FXFee__c ;
		//7    3.3 L/G Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               //   AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 7.00,
		                                               Name = '3.3 L/G Fee',
		                                               AccountId__c = item.Id,
            										   AccountId_PE__c = item.Id,
            										   AccountName__c = item.Name,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = LG_FEE,
		                                               Adjust_NI__c = LG_FEE,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
                        							   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0 ,AsOfDate__c = Datetime.now()
		));
            ws.LGFee__c = 0;
            SumWalletSizing.LGFee__c = (SumWalletSizing.LGFee__c == null ? 0.00 : SumWalletSizing.LGFee__c)  + ws.LGFee__c ;
		//8    3.4 Cash Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               //   AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 8.00,
		                                               Name = '3.4 Cash Fee',
		                                               AccountId__c = item.Id,
            										   AccountId_PE__c = item.Id,
            										   AccountName__c = item.Name,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = DIRECT_CM_FEE + OTHER_CM_FEE + EDC_FEE + FLEET_FEE,
		                                               Adjust_NI__c = DIRECT_CM_FEE + OTHER_CM_FEE + EDC_FEE + FLEET_FEE,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
                        							   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0, AsOfDate__c = Datetime.now()
		));
            ws.CashFee__c = 0;
            SumWalletSizing.CashFee__c = (SumWalletSizing.CashFee__c == null ? 0.00 : SumWalletSizing.CashFee__c)  + ws.CashFee__c ;
		//9    3.5 AS Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               //       AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 9.00,
		                                               Name = '3.5 AS Fee',
		                                               AccountId__c = item.Id,
            										   AccountId_PE__c = item.Id,
            										   AccountName__c = item.Name,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = AS_FEE,
		                                               Adjust_NI__c = AS_FEE,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
                        							   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0, AsOfDate__c = Datetime.now()
		));
            ws.ASFee__c = 0;
            SumWalletSizing.ASFee__c = (SumWalletSizing.ASFee__c == null ? 0.00 : SumWalletSizing.ASFee__c)  + ws.ASFee__c ;
		//10   Non recurring fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               //    AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 10.00,
		                                               Name = 'Non Recurring Fee',
		                                               AccountId__c = item.Id,
            										   AccountId_PE__c = item.Id,
            										   AccountName__c = item.Name,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = 0,
		                                               Adjust_NI__c = 0,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
                        							   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0, AsOfDate__c = Datetime.now()
		));
            ws.NonRecurringFee__c = '';
            SumWalletSizing.NonRecurringFee__c = '';
		//11   3.6 Credit fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               //    AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 11.00,
		                                               Name = '3.6 Credit Fee',
		                                               AccountId__c = item.Id,
            										   AccountId_PE__c = item.Id,
            										   AccountName__c = item.Name,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = CREDIT_FEE + FRONT_END_FEE,
		                                               Adjust_NI__c = CREDIT_FEE + FRONT_END_FEE,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
                        							   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0, AsOfDate__c = Datetime.now()
		));
        
            ws.CreditFee__c = 0;
            SumWalletSizing.CreditFee__c = (SumWalletSizing.CreditFee__c == null ? 0.00 : SumWalletSizing.CreditFee__c)  + ws.CreditFee__c ;
		//12   3.7 BA Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               //    AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 12.00,
		                                               Name = '3.7 BA Fee',
		                                               AccountId__c = item.Id,
            										   AccountId_PE__c = item.Id,
            										   AccountName__c = item.Name,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = BA_FEE,
		                                               Adjust_NI__c = BA_FEE,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
                        							   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0, AsOfDate__c = Datetime.now()
		));
            ws.BAFee__c = 0;
            SumWalletSizing.BAFee__c = (SumWalletSizing.BAFee__c == null ? 0.00 : SumWalletSizing.BAFee__c)  + ws.BAFee__c ;
		//13   3.8 Derivative Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               //      AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 13.00,
		                                               Name = '3.8 Derivative Fee',
		                                               AccountId__c = item.Id,
            										   AccountId_PE__c = item.Id,
            										   AccountName__c = item.Name,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = DERIVATIVES_FEE,
		                                               Adjust_NI__c = DERIVATIVES_FEE,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
                        							   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0 ,AsOfDate__c = Datetime.now()
		));
            ws.DerivativeFee__c  = 0;
            SumWalletSizing.DerivativeFee__c = (SumWalletSizing.DerivativeFee__c == null ? 0.00 : SumWalletSizing.DerivativeFee__c)  + ws.DerivativeFee__c ;
		//14   3.9 IB Fee
		newPrdPort.add(new AcctPlanProdStrategyPort__c(
		                                               //      AccountName__c = mapAccountName.get(item.Id),
		                                               SEQ__c = 14.00,
		                                               Name = '3.9 IB Fee',
		                                               AccountId__c = item.Id,
            										   AccountId_PE__c = item.Id,
            										   AccountName__c = item.Name,
		                                               WalletSizing__c = 0,
		                                               AnnualizedPerformance__c = IB_FEE,
		                                               Adjust_NI__c = IB_FEE,
		                                               AspirationSOW__c = 0,
		                                               Year__c = year,
                        							   GroupCompany__c = item.Group__c,            
		                                               ExpectedIncrementalNIFreeText__c = 0, AsOfDate__c = Datetime.now()
		));
            ws.IBFee__c  = 0;
            SumWalletSizing.IBFee__c = (SumWalletSizing.IBFee__c == null ? 0.00 : SumWalletSizing.IBFee__c)  + ws.IBFee__c ;
        
            ws.Account__c = item.Id;
            ws.AccountId_PE__c  = item.Id;
            ws.AccountNamePE__c = item.Name;
            ws.Group__c = item.Group__c;
            ws.Year__c = year;
            ws.IsProductStrategy__c = false;
            ws.IsGroupWallet__c = true;
            ws.IsGroupPerformance__c = true;
            ws.SummaryType__c = 'None';
			ws.RefreshDate__c  =  datetime.now();

            
            walletSizing.add(ws);
	}
        SumWalletSizing.Group__c = GroupId;
        SumWalletSizing.Year__c = year ;
        SumWalletSizing.IsProductStrategy__c = false;
        SumWalletSizing.IsGroupWallet__c = true;
        SumWalletSizing.IsGroupPerformance__c = true;
        SumWalletSizing.SummaryType__c = 'WalletSizing';
        
        insert newPrdPort;
        insert walletSizing;
        upsert SumWalletSizing;
        insert customerUnderstandingList;

		//List<AcctPlanCusUnderstanding__c> customerUnderstandingGrandTotal = new List<AcctPlanCusUnderstanding__c>();
        List<AcctPlanCusUnderstanding__c> customerUnderstandingUpdate = new List<AcctPlanCusUnderstanding__c>();
        Map<Id, Decimal> MapGrandTotal = new Map<Id,Decimal>();


        for(AccountPlanWalletSizing__c item : [SELECT Id,Grandtotal__C,Account__c FROM AccountPlanWalletSizing__c
                                                                    WHERE Group__c = :groupId
                                                                    AND Year__c = :year
                                                                    AND SummaryType__c  = 'None']){
            	MapGrandTotal.put(item.Account__c,item.GrandTotal__c); 
            }

        for(AcctPlanCusUnderstanding__c item : customerUnderstandingList){
				item.GrandTotal__c = MapGrandTotal.get(item.Account__c);
				if(item.GrandTotal__c == null ){
					item.GrandTotal__c = 0;
				}
				customerUnderstandingUpdate.add(item);
			}
			if(customerUnderstandingUpdate.size() >0){
				update customerUnderstandingUpdate;
			}
	}

    public void RefreshProductStrategy2(Set<Id> accountIds, string year,Id groupId) {
        /**********************************************************************
        *  Step Reset Wallet Sizing 
        ***********************************************************************/
        List<AccountPlanWalletSizing__c> walletWrapperListQuery = [SELECT Id 
                                                                   FROM AccountPlanWalletSizing__c
                                                                   WHERE Group__c = :groupId
                                                                   AND Year__c = :year
                                                                   AND Account__c IN :accountIds
                                                                   ];
        if(walletWrapperListQuery.size() >0 ){
            delete walletWrapperListQuery;
            walletWrapperListQuery.clear();
        }
        system.debug('accountIds='+accountIds);
        List<AcctPlanProdStrategy__c> listProduct =[SELECT Id,SEQ__c,Name,AccountPlanYear__c,AcctPlanCompanyProfileID__c,AcctPlanGroupProfileID__c,  
                                                    AcctPlanWallet__c,AnnualizedPerformance__c,AspirationSOW__c,CompareSOW__c,  
                                                    CreatedById,CreatedDate,ExistingSOW__c,ExpectedIncrementalNI__c,ExpectedSOWPercent__c,  
                                                    IsDeleted,LastModifiedById,LastModifiedDate, 
                                                    ParentRecord__c,SystemModstamp,WalletSizing__c,TotalCompanyNI__c, 
                                                    AcctPlanCompanyProfileID__r.Name, AcctPlanGroupProfileID__r.Name,AsOfDate__c,RefreshAsOf__c, 
                                                    AcctPlanCompanyProfileID__r.Account__c,WalletFieldName__c,Adjust_NI__c,ExpectedIncrementalNIFreeText__c ,  
                                                    ExpectedIncrementalNIFromStep5__c,AccountId__c,AcctPlanCompanyProfileID__r.AccountName__c
                                                    FROM AcctPlanProdStrategy__c  
                                                    WHERE AcctPlanCompanyProfileID__r.Account__c IN :accountIds
                                                    AND AcctPlanCompanyProfileID__r.Year__c = :year];
        
        Map<Decimal, Map<Id, Decimal>> AcctPlanWalletSizing = new Map<Decimal, Map<Id, Decimal>>();
        Map<Id, DateTime> MapRefreshDate = new Map<Id,DateTime>();
        Map<Id, Id> MapCompanyProfile = new Map<Id,Id>();
        Map<Id, String> MapCompanyProfileName = new Map<Id,String>();
        Map<Id, Decimal> MapGrandTotal = new Map<Id,Decimal>();
        Set<Id> WalletIDList = new Set<Id>();
        Map<Id, AcctPlanProdStrategy__c> MapWalletID = new Map<Id,AcctPlanProdStrategy__c>();
        
        if(listProduct.size() >0){
            for(AcctPlanProdStrategy__c item : listProduct){
                if(item.WalletSizing__c == null){
                    item.WalletSizing__c = 0;
                }
                if(!AcctPlanWalletSizing.containsKey(item.SEQ__c)){
                    AcctPlanWalletSizing.put(item.SEQ__c,new Map<Id, Decimal>{item.AccountId__c  => item.WalletSizing__c});
                }else{
                    AcctPlanWalletSizing.get(item.SEQ__c).put(item.AccountId__c ,item.WalletSizing__c);
                } 
                if(!MapRefreshDate.containsKey(item.AccountId__c)){
                    MapRefreshDate.put(item.AccountId__c ,item.RefreshAsOf__c);
                }
                if(!MapCompanyProfile.containsKey(item.AccountId__c)){
                    MapCompanyProfile.put(item.AccountId__c ,item.AcctPlanCompanyProfileID__c);
                }
                WalletIDList.add(item.AcctPlanWallet__c);
                MapWalletID.put(item.AcctPlanWallet__c,item);
            }
			 system.debug('WalletIDList='+WalletIDList);

            List<AcctPlanCusUnderstanding__c> customerUnderstandings = AccountPlanCustomerUnderstandingSelector.getUnderstandingByWalletIds(WalletIDList);
			List<AcctPlanCusUnderstanding__c> customerUnderstandingGrandTotal = new List<AcctPlanCusUnderstanding__c>();
        	List<AcctPlanCusUnderstanding__c> customerUnderstandingUpdate = new List<AcctPlanCusUnderstanding__c>();
        
			for(AcctPlanCusUnderstanding__c item : customerUnderstandings){
				item.Account__c = MapWalletID.get(item.AcctPlanWallet__c).AccountId__c;
				item.year__c = year;
				item.AccountName__c = MapWalletID.get(item.AcctPlanWallet__c).AcctPlanCompanyProfileID__r.AccountName__c;
				customerUnderstandingGrandTotal.add(item);
				MapCompanyProfileName.put(MapWalletID.get(item.AcctPlanWallet__c).AccountId__c,MapWalletID.get(item.AcctPlanWallet__c).AcctPlanCompanyProfileID__r.AccountName__c);
			}

            /**********************************************************************
            *  Step initiate Sum Wallet Sizing 
            ***********************************************************************/
            List<AccountPlanWalletSizing__c> SumWalletSizingList = [SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                                    IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,IsProductStrategy__c,AccountNamePE__c,
                                                                    NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c,
                                                                     Account_Plan_Company_Profile__c
                                                                    FROM AccountPlanWalletSizing__c
                                                                    WHERE Group__c = :groupId
                                                                    AND Year__c = :year
                                                                    AND SummaryType__c  = 'WalletSizing' LIMIT 1];
            AccountPlanWalletSizing__c SumWalletSizing = new AccountPlanWalletSizing__c();
            if(SumWalletSizingList.size()>0){
                SumWalletSizing = SumWalletSizingList.get(0);
            }
            List<AccountPlanWalletSizing__c> walletSizingList = new List<AccountPlanWalletSizing__c>();
            
            /**********************************************************************
            *  Step Create Wallet Sizing and Sum from ProductStrategy
            ***********************************************************************/
            if(AcctPlanWalletSizing.size()>0){
                for(Id item : accountIds){
                    AccountPlanWalletSizing__c  w = new AccountPlanWalletSizing__c();
                    w.NIIc__c = AcctPlanWalletSizing.get(1.00).get(item) ;
                    SumWalletSizing.NIIc__c = (SumWalletSizing.NIIc__c == null ? 0.00 : SumWalletSizing.NIIc__c)  + (w.NIIc__c == null ? 0.00 : w.NIIc__c);
                    
                    w.NIId__c = AcctPlanWalletSizing.get(2.00).get(item) ;
                    SumWalletSizing.NIId__c = (SumWalletSizing.NIId__c == null ? 0.00 : SumWalletSizing.NIId__c)  + (w.NIId__c == null ? 0.00 : w.NIId__c);
                    
                    w.Fee__c = AcctPlanWalletSizing.get(3.00).get(item) ;
                    SumWalletSizing.Fee__c = (SumWalletSizing.Fee__c == null ? 0.00 : SumWalletSizing.Fee__c)  + (w.Fee__c == null ? 0.00 : w.Fee__c);
                    
                    w.RecurringFee__c ='';
                    SumWalletSizing.RecurringFee__c = '' ;
                    
                    w.TFFee__c = AcctPlanWalletSizing.get(5.00).get(item) ;
                    SumWalletSizing.TFFee__c = (SumWalletSizing.TFFee__c == null ? 0.00 : SumWalletSizing.TFFee__c)  + (w.TFFee__c == null ? 0.00 : w.TFFee__c);
                    
                    w.FXFee__c = AcctPlanWalletSizing.get(6.00).get(item) ;
                    SumWalletSizing.FXFee__c = (SumWalletSizing.FXFee__c == null ? 0.00 : SumWalletSizing.FXFee__c)  + (w.FXFee__c == null ? 0.00 : w.FXFee__c);
                    
                    w.LGFee__c = AcctPlanWalletSizing.get(7.00).get(item) ;
                    SumWalletSizing.LGFee__c = (SumWalletSizing.LGFee__c == null ? 0.00 : SumWalletSizing.LGFee__c)  + (w.LGFee__c == null ? 0.00 : w.LGFee__c);
                    
                    w.CashFee__c = AcctPlanWalletSizing.get(8.00).get(item) ;
                    SumWalletSizing.CashFee__c = (SumWalletSizing.CashFee__c == null ? 0.00 : SumWalletSizing.CashFee__c)  + (w.CashFee__c == null ? 0.00 : w.CashFee__c);
                    
                    w.ASFee__c = AcctPlanWalletSizing.get(9.00).get(item) ;
                    SumWalletSizing.ASFee__c = (SumWalletSizing.ASFee__c == null ? 0.00 : SumWalletSizing.ASFee__c)  + (w.ASFee__c == null ? 0.00 : w.ASFee__c);
                    
                    w.NonRecurringFee__c ='';
                    SumWalletSizing.NonRecurringFee__c = '' ;
                    
                    w.CreditFee__c = AcctPlanWalletSizing.get(11.00).get(item) ;
                    SumWalletSizing.CreditFee__c = (SumWalletSizing.CreditFee__c == null ? 0.00 : SumWalletSizing.CreditFee__c)  + (w.CreditFee__c == null ? 0.00 : w.CreditFee__c);
                    
                    w.BAFee__c = AcctPlanWalletSizing.get(12.00).get(item) ;
                    SumWalletSizing.BAFee__c = (SumWalletSizing.BAFee__c == null ? 0.00 : SumWalletSizing.BAFee__c)  + (w.BAFee__c == null ? 0.00 : w.BAFee__c);
                    
                    w.DerivativeFee__c = AcctPlanWalletSizing.get(13.00).get(item) ;
                    SumWalletSizing.DerivativeFee__c = (SumWalletSizing.DerivativeFee__c == null ? 0.00 : SumWalletSizing.DerivativeFee__c)  + (w.DerivativeFee__c == null ? 0.00 : w.DerivativeFee__c);
                    
                    w.IBFee__c = AcctPlanWalletSizing.get(14.00).get(item) ;
                    SumWalletSizing.IBFee__c = (SumWalletSizing.IBFee__c == null ? 0.00 : SumWalletSizing.IBFee__c)  + (w.IBFee__c == null ? 0.00 : w.IBFee__c);
                    
                    w.Account__c = item;
                    w.AccountNamePE__c = MapCompanyProfileName.get(item);
                    w.Group__c = GroupId;
                    w.Year__c = year;
                    w.IsProductStrategy__c = true;
                    w.IsGroupWallet__c = true;
                    w.IsGroupPerformance__c = true;
                    w.SummaryType__c = 'None';
                    w.RefreshDate__c  =  MapRefreshDate.get(item);
                    w.Account_Plan_Company_Profile__c = MapCompanyProfile.get(item);
                    //w.AccountName__c = MapCompanyProfile.get(item).AccountName__c;
                    walletSizingList.add(w);  
                    
                }
                SumWalletSizing.Group__c = groupId;
                SumWalletSizing.Year__c = year ;
                SumWalletSizing.IsProductStrategy__c = false;
                SumWalletSizing.IsGroupWallet__c = true;
                SumWalletSizing.IsGroupPerformance__c = true;
                SumWalletSizing.SummaryType__c = 'WalletSizing';

            }
            if(walletSizingList.size()>0){
                insert walletSizingList;
                upsert SumWalletSizing;
            }

            for(AccountPlanWalletSizing__c item : [SELECT Id,Grandtotal__C,Account__c FROM AccountPlanWalletSizing__c
                                                                    WHERE Group__c = :groupId
                                                                    AND Year__c = :year
                                                                    AND SummaryType__c  = 'None']){
            	MapGrandTotal.put(item.Account__c,item.GrandTotal__c); 
            }
            
			for(AcctPlanCusUnderstanding__c item : customerUnderstandingGrandTotal){
				item.GrandTotal__c = MapGrandTotal.get(item.Account__c);
				if(item.GrandTotal__c == null ){
					item.GrandTotal__c = 0;
				}
				customerUnderstandingUpdate.add(item);
			}
			if(customerUnderstandingUpdate.size() >0){
				update customerUnderstandingUpdate;
			}
        }
    }






	public List<AccountPlanRefreshService.CustomerWalletInfo> initialStep0(string accountIds) {
		Set<Id> accts = new Set<Id> ();

		try
		{
			String[] ar = accountIds.split(',');

			for (string strid : ar)
			{
				Id obj = (Id) strid;
				accts.add(obj);
			}
		}
		catch(Exception e)
		{
			System.debug(e);
			return null;
		}
		system.debug('::: All Account Id = ' + accts);

		Map<Id /*Account Id*/, AccountPlanRefreshService.CustomerWalletInfo> accounts = new Map<Id /*Account Id*/, AccountPlanRefreshService.CustomerWalletInfo> ();

		/**************************************************************
		 *   SET UP WALLET FROM SINGLE VIEW
		 ***************************************************************/
		for (Account item : AccountSelector.getAccountWithSingleViewInfoByIds(accts))
		{
			AccountPlanRefreshService.CustomerWalletInfo obj = new AccountPlanRefreshService.CustomerWalletInfo();
			obj.Id = item.Id;

			decimal niic = item.NIIc_Wallet__c == null ? 0 : item.NIIc_Wallet__c;
			decimal niid = item.NIId_Wallet__c == null ? 0 : item.NIId_Wallet__c;
			decimal fee = item.Fee_Wallet__c == null ? 0 : item.Fee_Wallet__c;
			obj.Wallet = (niic + niid + fee).setScale(0);
			obj.Annual = 0;


			accounts.put(item.Id, obj);
		}

		/**************************************************************
		 *   SET UP ANNUAL ROLLING 12 MONTH
		 ***************************************************************/
		datetime currentDt = Datetime.now();
		for (AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo item
		     : AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDateInGroupMap(accts, currentDt).values()) {
			Decimal niic = item.NIIc == null ? 0 : item.NIIc;
			Decimal niid = item.NIId == null ? 0 : item.NIId;
			Decimal fee = item.Fee == null ? 0 : item.Fee;
			Decimal total = niic + niid + fee;
			AccountPlanRefreshService.CustomerWalletInfo obj = accounts.get((Id) item.AccouontId);
			obj.Annual = total.setScale(0);
			accounts.put(obj.id, obj);
			system.debug('::: Single View for ' + obj.Id + ' = ' + obj);


		}
		return accounts.values();
	}









}