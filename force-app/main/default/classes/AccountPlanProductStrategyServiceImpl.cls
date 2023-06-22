public without sharing class AccountPlanProductStrategyServiceImpl implements IAccountPlanProductStrategyService, Database.AllowsCallouts {

	public class ProductStrategyTemplate {
		public integer Seq { get; set; }
		public String Label { get; set; }
		public String WalletFieldName { get; set; }
		public ProductStrategyTemplate(integer Seq, String Label, String walletFieldName) {
			this.Seq = Seq;
			this.Label = Label;
			this.WalletFieldName = walletFieldName;
		}
		public ProductStrategyTemplate(integer Seq, String Label) {
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
		public Integer WalletDomain { get; set; }

		public WalletByDomainTemplate(Decimal row, Decimal seq, String typeOfNI, String domain, String subDomain, String walletFieldName, Integer walletDomain) {

			this(row, seq, typeOfNI, domain, subDomain, walletFieldName);
			this.WalletDomain = walletDomain;
		}

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

	public static List<WalletByDomainTemplate> getWalletByDomainTemplate {
		get {
			List<WalletByDomainTemplate> template = new List<WalletByDomainTemplate> ();
			template.add(new WalletByDomainTemplate(1, 1.1, 'NIIc Products', 'Loan', 'Working capital', 'TotalWalletNiic__c', 3));
			template.add(new WalletByDomainTemplate(1, 1.2, 'NIIc Products', 'Loan', 'Long term loan : Existing', 'SumofExistingLongTermLoanNIIC__c', 3));
			template.add(new WalletByDomainTemplate(1, 1.3, 'NIIc Products', 'Loan', 'Long term loan : Capital expenditure Plan', 'SumOfCapitalExpenditurePlanNIIC__c', 3));

			template.add(new WalletByDomainTemplate(2, 2.1, 'NIId Products', 'Deposit', 'Operating transaction', 'WalletNiid_OperatingTransaction__c', 2));
			template.add(new WalletByDomainTemplate(2, 2.2, 'NIId Products', 'Deposit', 'Cash on hand/Cash at bank or Investment', 'WalletNiid_CashOnHand__c', 2));

			template.add(new WalletByDomainTemplate(5, 5.1, 'TF Fee Products', 'International', 'Export', 'SumOfCollectionExportWalletTradeFee__c', 1));
			template.add(new WalletByDomainTemplate(5, 5.1, 'TF Fee Products', 'International', 'Import', 'SumOfPaymentImportWalletTFFee__c', 1));

			template.add(new WalletByDomainTemplate(6, 6.1, 'FX Fee Products', 'Hedging', 'Normal business transaction : Trade transaction', 'SumOfWalletFXFeePerYear__c', 4));

			//> 3.3 L/G fee
			template.add(new WalletByDomainTemplate(7, 7.1, 'L/G Fee Products', 'L/G Fee Products', 'L/G issuing : L/G project', 'ShortTermWalletLGFee__c,LongTermWalletLGFee__c', 3));
			template.add(new WalletByDomainTemplate(7, 7.2, 'L/G Fee Products', 'L/G Fee Products', 'L/G issuing : L/G purchase', 'LGPurchaseTotalWalletLGFee__c', 3));
			template.add(new WalletByDomainTemplate(7, 7.3, 'L/G Fee Products', 'L/G Fee Products', 'L/G issuing : Aval/Acceptance', '', 3));
			template.add(new WalletByDomainTemplate(7, 7.4, 'L/G Fee Products', 'L/G Fee Products', 'L/G issuing : International bank guarantee or Standby L/C', '', 3));
			template.add(new WalletByDomainTemplate(7, 7.5, 'L/G Fee Products', 'L/G Fee Products', 'L/G issuing : Shipping guarantee', '', 3));

			// > 3.4 Cash fee
			template.add(new WalletByDomainTemplate(8, 8.1, 'Cash Fee Products', 'Domestic', 'Collection', 'SumOfCollectionWalletCashFee__c', 1));
			template.add(new WalletByDomainTemplate(8, 8.2, 'Cash Fee Products', 'Domestic', 'Payment', 'SumOfPaymentDomesticWalletCashFee__c', 1));


			// 3.5 AS Fee
			template.add(new WalletByDomainTemplate(9, 9.1, 'AS Fee Products', 'Agent & Security Services', '1) Custodian', 'WalletASFee_Custodian__c', 1));
			template.add(new WalletByDomainTemplate(9, 9.2, 'AS Fee Products', 'Agent & Security Services', '2) Fund Supervisor', 'WalletASFee_FundSupervisory__c', 1));
			template.add(new WalletByDomainTemplate(9, 9.3, 'AS Fee Products', 'Agent & Security Services', '3) Middle Office', 'WalletASFee_MiddleOffice__c', 1));
			template.add(new WalletByDomainTemplate(9, 9.4, 'AS Fee Products', 'Agent & Security Services', '4) Agency Service', 'WalletASFee_AgencyService__c', 1));
			template.add(new WalletByDomainTemplate(9, 9.5, 'AS Fee Products', 'Agent & Security Services', '5) Registra & Payment Agent', 'WalletASFee_RegistrarPaymentAgent__c', 1));

			// > 3.6 Credit fee
			template.add(new WalletByDomainTemplate(11, 11.1, 'Credit Fee Products', 'Loan', 'Working capital', 'MaxCreditFeeWorkingCapital__c', 3));
			template.add(new WalletByDomainTemplate(11, 11.2, 'Credit Fee Products', 'Loan', 'Long term loan : Capital expenditure Plan', 'SumOfCapitalExpenditurePlanCreditFee__c', 3));


			// > 3.7 BA fee
			template.add(new WalletByDomainTemplate(12, 12.1, 'BA Fee Products', 'Hedging', 'Insurance : Credit life insurance', 'WalletOfBAFee__c', 4));
			template.add(new WalletByDomainTemplate(12, 12.2, 'BA Fee Products', 'Hedging', 'Insurance : Non credit life insurance', '', 4));
			template.add(new WalletByDomainTemplate(12, 12.3, 'BA Fee Products', 'Hedging', 'Insurance : Non life insurance', '', 4));

			// > 3.8 Derivative fee
			template.add(new WalletByDomainTemplate(13, 13.1, 'Derivative Fee Products', 'Hedging', 'Existing liabilities & Investment plan/Capital expenditure plan', '', 4));

			// > 3.9 Derivative fee
			template.add(new WalletByDomainTemplate(14, 14.1, 'IB Fee Products', 'Hedging', 'Existing liabilities & Investment plan/Capital expenditure plan', '', 4));



			return template;
		}
	}

	public List<ProductStrategyTemplate> getProductStrategyTemplate {
		get {
			List<ProductStrategyTemplate> template = new List<ProductStrategyTemplate> ();
			template.add(new ProductStrategyTemplate(1, '1. NIIc', 'SumOfWalletNiicYearly__c'));
			template.add(new ProductStrategyTemplate(2, '2. NIId', 'TotalWalletNIID__c'));
			template.add(new ProductStrategyTemplate(3, '3. Fee', 'Total_Fee__c'));
			template.add(new ProductStrategyTemplate(4, 'Recurring Fee'));
			template.add(new ProductStrategyTemplate(5, '3.1 TF Fee', 'SumOfWalletTFFee__c'));
			template.add(new ProductStrategyTemplate(6, '3.2 FX Fee', 'SumOfAcctPlanForeignWalletFXFeePerYear__c'));
			template.add(new ProductStrategyTemplate(7, '3.3 L/G Fee', 'SumOfWalletLGFeeYearly__c'));
			template.add(new ProductStrategyTemplate(8, '3.4 Cash Fee', 'SumOfWalletCashFee__c'));
			template.add(new ProductStrategyTemplate(9, '3.5 AS Fee', 'SumOfWalletASFee__c'));
			template.add(new ProductStrategyTemplate(10, 'Non Recurring Fee'));
			template.add(new ProductStrategyTemplate(11, '3.6 Credit Fee', 'SumOfWalletCreditFeeYearly__c'));
			template.add(new ProductStrategyTemplate(12, '3.7 BA Fee', 'TotalWalletBAFee__c'));
			template.add(new ProductStrategyTemplate(13, '3.8 Derivative Fee')); // *****  ไม่มี ที่ Step 3   
			template.add(new ProductStrategyTemplate(14, '3.9 IB Fee'));

			// *****  ไม่มี ที่ Step 3              
			return template;
		}
	}

	public List<AcctPlanProdStrategy__c> createProductStrategyRecordToWallet(String acctPlanCompanyId, String acctPlanWallet) {
		return createProductStrategyRecordToWallet(acctPlanCompanyId, acctPlanWallet, '');
	}

	public List<AcctPlanProdStrategy__c> createProductStrategyRecordToWallet(String acctPlanCompanyId, String acctPlanWallet, String acctPlanGruopId) {

		AcctPlanCompanyProfile__c accPlanProfile;
		system.debug('::: acctPlanCompanyId  >> ' + acctPlanCompanyId);
		List<AcctPlanCompanyProfile__c> accPlanProfiles = AccountPlanCompanyProfileSelector.getCompanyProfileIds(new Set<Id> { acctPlanCompanyId });
		if (accPlanProfiles.size() > 0) {
			accPlanProfile = accPlanProfiles[0];
		}
		else {
			accPlanProfile = new AcctPlanCompanyProfile__c();
		}
		system.debug('::: CompanyProfile -> AccountId  >> ' + accPlanProfile);
		AcctPlanWallet__c wallet;
		List<AcctPlanWallet__c> wallets = AccountPlanWalletSelector.getWalletByIds(new Set<Id> { acctPlanWallet });
		if (wallets.size() > 0) {
			wallet = wallets[0];
		}
		else {
			wallet = new AcctPlanWallet__c();
		}




		/**********************************************************************************************************
		 *    Actual NI (12-mth rolling)
		 * *******************************************************************************************************/
		AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo performance12month;
		// Get Annual Performance 
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

		Map<integer /* SEQ*/, Decimal> mapPerformance12month = new Map<integer /* SEQ*/, Decimal> ();
		mapPerformance12month.put(1, performance12month.NIIc);
		mapPerformance12month.put(2, performance12month.NIId);
		mapPerformance12month.put(3, performance12month.Fee);
		mapPerformance12month.put(4, 0);
		mapPerformance12month.put(5, performance12month.TF_FEE);
		mapPerformance12month.put(6, performance12month.FX_FEE);
		mapPerformance12month.put(7, performance12month.LG_FEE);

		decimal cahsfee = performance12month.DIRECT_CM_FEE +
		performance12month.OTHER_CM_FEE +
		performance12month.EDC_FEE +
		performance12month.FLEET_FEE;

		mapPerformance12month.put(8 /*Cash FEE */, cahsfee);
		mapPerformance12month.put(9, performance12month.AS_FEE);
		mapPerformance12month.put(10, 0);
		Decimal creditFee = performance12month.CREDIT_FEE + performance12month.FRONT_END_FEE;
		mapPerformance12month.put(11, creditFee);
		mapPerformance12month.put(12, performance12month.BA_FEE);
		mapPerformance12month.put(13, performance12month.DERIVATIVES_FEE);
		mapPerformance12month.put(14, performance12month.IB_FEE);

		List<AcctPlanProdStrategy__c> newProductStrategy = new List<AcctPlanProdStrategy__c> ();
		//region SE
		if (accPlanProfile.isMiniMode__c) {
			//SE Casse
			// ต้องแยก SE ดัวย      
			Map<id, Account> accountSEmap = new Map<id, Account> ();
			for (Account acc : AccountSelector.getAccountWithSingleViewInfoByIds(new set<Id> { accPlanProfile.Account__c })) {
				//if (acc.Owner.Segment__c == 'SE') {
				System.debug(accPlanProfile.Name + ' ::: HIT SE CUSTOMER' );
				if (!accountSEmap.containsKey(acc.Id)) {
					accountSEmap.put(acc.Id, acc);
					//accountIds.remove(acc.Id);
					//}
				}
			}
			Account act = accountSEmap.get(accPlanProfile.Account__c);
			for (ProductStrategyTemplate template : getProductStrategyTemplate) {


				AcctPlanProdStrategy__c record = new AcctPlanProdStrategy__c(
				                                                             SEQ__c = template.Seq, Name = template.Label
				                                                             , AccountId__c = accPlanProfile.Account__c
				                                                             , WalletSizing__c = 0
				                                                             , AcctPlanCompanyProfileID__c = acctPlanCompanyId
				                                                             , AcctPlanWallet__c = acctPlanWallet
				                                                             , WalletFieldName__c = template.WalletFieldName
				                                                             , AnnualizedPerformance__c = (Decimal) mapPerformance12month.get(template.Seq)
				                                                             , Adjust_NI__c /* Defual when Create*/ = (Decimal) mapPerformance12month.get(template.Seq)
				);
				if (template.Seq == 1) {
					record.WalletSizing__c = act.NIIc_Wallet__c;
					//record.Adjust_NI__c = act.NIIc_Wallet__c;

				} else if (template.Seq == 2) {
					record.WalletSizing__c = act.NIId_Wallet__c;
					//record.Adjust_NI__c = act.NIId_Wallet__c;
				} else if (template.Seq == 3) {
					record.WalletSizing__c = act.Fee_Wallet__c;
					//record.Adjust_NI__c = act.NIId_Wallet__c;
					//record.Adjust_NI__c = act.Fee_Wallet__c;
				}
				if (acctPlanGruopId != null && acctPlanGruopId != '') {
					record.AcctPlanGroupProfileID__c = acctPlanGruopId;
				}
				newProductStrategy.add(record);

			}

		}
		//endregion
		else {
			/*--------------------------------------------------------------------
			 *           Account Product ProdStrategy
			 * --------------------------------------------------------------------*/

			//Normal Case

			for (ProductStrategyTemplate template : getProductStrategyTemplate) {
				Decimal val;
				if (template.WalletFieldName != '' && template.WalletFieldName != null) {
					val = (Decimal) wallet.get(template.WalletFieldName);
				}

				if (val == null) val = 0;
				AcctPlanProdStrategy__c record = new AcctPlanProdStrategy__c(
				                                                             SEQ__c = template.Seq, Name = template.Label
				                                                             , AccountId__c = accPlanProfile.Account__c /* เอาไว้เพื่อหา AnnulaPerformance ง่ายๆ */
				                                                             , WalletSizing__c = val
				                                                             // ,AcctPlanGroupProfileID__c = acctPlanGruopId 
				                                                             , AcctPlanCompanyProfileID__c = acctPlanCompanyId
				                                                             , AcctPlanWallet__c = acctPlanWallet
				                                                             , WalletFieldName__c = template.WalletFieldName
				                                                             //,Adjust_NI__c = 0
				                                                             , AnnualizedPerformance__c = (Decimal) mapPerformance12month.get(template.Seq)
				                                                             , Adjust_NI__c /* Defual when Create*/ = (Decimal) mapPerformance12month.get(template.Seq)
				);
				if (template.Seq == 3) {
					// Case : 3. Fee  - Tinnakrit Edit to save 3.Fee into records
					//record.Adjust_NI__c = 0;
				}
				if (acctPlanGruopId != null && acctPlanGruopId != '') {
					record.AcctPlanGroupProfileID__c = acctPlanGruopId;
				}
				newProductStrategy.add(record);
			}
		}

		/*--------------------------------------------------------------------
		 *           Account Plan Wallet By Domain 
		 * --------------------------------------------------------------------*/
		List<AcctPlanWalletByDomain__c> newWalletByDoamins = new List<AcctPlanWalletByDomain__c> ();

		for (WalletByDomainTemplate template : getWalletByDomainTemplate) {
			system.debug(' Type Of NI >> ' + template.TypeOfNI + ' SubDomain >> ' + template.Domain);

			Decimal val = 0;
			if (template.WalletFieldName != null && template.WalletFieldName != '') {

				if (template.WalletFieldName.contains(',')) {
					for (String fieldName : template.WalletFieldName.split(',')) {
						system.debug(' fieldName >> ' + fieldName);
						val += (Decimal) (wallet.get(fieldName) == null ? 0 : wallet.get(fieldName));
					}
				}
				else {
					val += (Decimal) (wallet.get(template.WalletFieldName) == null ? 0 : wallet.get(template.WalletFieldName));
				}


			}
			newWalletByDoamins.add(
			                       new AcctPlanWalletByDomain__c(
			                                                     AcctPlanWallet__c = acctPlanWallet
			                                                     , Row__c = template.Row
			                                                     , Seq__c = template.Seq
			                                                     , TypeOfNI__c = template.TypeOfNI
			                                                     , Domain__c = template.Domain
			                                                     , SubDomain__c = template.SubDomain
			                                                     , AdjWalletUnit__c = val
			                                                     , WalletFieldName__c = template.WalletFieldName
			                                                     , WalletDomain__c = template.WalletDomain

			)
			);
		}
		/*--------------------------------------------------------------------
		 *           Account Plan Customer Understanding
		 * --------------------------------------------------------------------*/
		AcctPlanCusUnderstanding__c customerUnderstanding
		= new AcctPlanCusUnderstanding__c(TF_Volume__c = 0,
		                                  Average_CASA__c = 0,
		                                  Average_loan_outstanding__c = 0,
		                                  AcctPlanWallet__c = acctPlanWallet,
		                                  Ending_CASA__c = 0,
		                                  Ending_loan_outstanding__c = 0,
		                                  FX_volume__c = 0);



		system.debug(':::  AcctPlanProdStrategy__c >> ' + newProductStrategy);
		try {
			insert newProductStrategy;
			insert newWalletByDoamins;
			insert customerUnderstanding;

			// Add for support menu
			AcctPlanCompanyProfile__c updCompany = new AcctPlanCompanyProfile__c(Id = acctPlanCompanyId, isHasProdStrategy__c = true);
			//isHasProdStrategy__c
			update updCompany;

		}
		catch(Exception ex) {

			system.debug('::: Error >> ' + ex.getMessage());
			throw ex;

		}
		system.debug('::: Insert New AcctPlanProdStrategy__c >> ' + newProductStrategy.size());
		return newProductStrategy;
	}



	public List<AcctPlanProdStrategy__c> getCompaniesProductStrategy(Set<ID> acctPlanCompanyIds) {
		return AccountPlanProductStrategySelector.selectProductStrategyByIds(acctPlanCompanyIds);
	}

	public List<AccountPlanProductStrategyService.AcctPlanProdStrategyInfo> getCompaniesProductStrategyInfo(Set<ID> acctPlanCompanyIds) {

		List<AccountPlanProductStrategyService.AcctPlanProdStrategyInfo> lstAcctPlanProdStrategyInfo = new List<AccountPlanProductStrategyService.AcctPlanProdStrategyInfo> ();
		for (AcctPlanProdStrategy__c proStrategy : AccountPlanProductStrategySelector.selectProductStrategyByIds(acctPlanCompanyIds)) {
			system.debug(' SEQ >> ' + proStrategy.SEQ__c);
			AccountPlanProductStrategyService.AcctPlanProdStrategyInfo acctInfo =
			new AccountPlanProductStrategyService.AcctPlanProdStrategyInfo();
			acctInfo.Id = proStrategy.Id;
			acctInfo.SEQ = proStrategy.SEQ__c;
			acctInfo.Name = proStrategy.Name;
			acctInfo.AccountPlanYear = proStrategy.AccountPlanYear__c;
			acctInfo.AcctPlanCompanyProfileID = proStrategy.AcctPlanCompanyProfileID__c;
			acctInfo.AcctPlanGroupProfileID = proStrategy.AcctPlanGroupProfileID__c;
			acctInfo.AcctPlanWallet = proStrategy.AcctPlanWallet__c;
			acctInfo.AnnualizedPerformance = proStrategy.AnnualizedPerformance__c == null ? 0 : proStrategy.AnnualizedPerformance__c;
			acctInfo.AspirationSOW = proStrategy.AspirationSOW__c == null ? 0 : proStrategy.AspirationSOW__c;
			acctInfo.CompareSOW = proStrategy.CompareSOW__c == null ? 0 : proStrategy.CompareSOW__c;
			acctInfo.ExistingSOW = proStrategy.ExistingSOW__c == null ? 0 : proStrategy.ExistingSOW__c; // proStrategy.ExistingSOW__c;             
			acctInfo.ExpectedSOWPercent = proStrategy.ExpectedSOWPercent__c == null ? 0 : proStrategy.ExpectedSOWPercent__c; // proStrategy.ExpectedSOWPercent__c;               
			acctInfo.WalletSizing = proStrategy.WalletSizing__c == null ? 0 : proStrategy.WalletSizing__c;
			acctInfo.TotalCompanyNI = proStrategy.TotalCompanyNI__c == null ? 0 : proStrategy.TotalCompanyNI__c;

			//DA: acctInfo.ActualPerformance = 5000;
			acctInfo.ExpectedIncrementalNI = proStrategy.ExpectedIncrementalNI__c == null ? 0 : proStrategy.ExpectedIncrementalNI__c; // proStrategy.ExpectedIncrementalNI__c; //DA: proStrategy.ExpectedIncrementalNI__c + 5000;
			acctInfo.ExpectedIncrementalNIFromStep5 = proStrategy.ExpectedIncrementalNIFromStep5__c == null ? 0 : proStrategy.ExpectedIncrementalNIFromStep5__c;
			acctInfo.AdjustNI = proStrategy.Adjust_NI__c == null ? 0 : proStrategy.Adjust_NI__c;
			acctInfo.RefreshAsOf = proStrategy.RefreshAsOf__c;

			lstAcctPlanProdStrategyInfo.add(acctInfo);
		}
		return lstAcctPlanProdStrategyInfo;
	}
	public List<AccountPlanProductStrategyService.AcctPlanProdStrategyInfo> getGroupCompaniesProductStrategyInfo(Set<ID> groupProfileIds) {
		List<AccountPlanProductStrategyService.AcctPlanProdStrategyInfo> lstAcctPlanProdStrategyInfo =
		new List<AccountPlanProductStrategyService.AcctPlanProdStrategyInfo> ();


		for (AcctPlanProdStrategy__c proStrategy : AccountPlanProductStrategySelector.selectProductStrategyByGroupIds(groupProfileIds)) {
			AccountPlanProductStrategyService.AcctPlanProdStrategyInfo acctInfo =
			new AccountPlanProductStrategyService.AcctPlanProdStrategyInfo();
			acctInfo.Id = proStrategy.Id;
			acctInfo.SEQ = proStrategy.SEQ__c;
			acctInfo.Name = proStrategy.Name;
			acctInfo.AccountPlanYear = proStrategy.AccountPlanYear__c;
			acctInfo.AcctPlanCompanyProfileID = proStrategy.AcctPlanCompanyProfileID__c;
			acctInfo.AcctPlanGroupProfileID = proStrategy.AcctPlanGroupProfileID__c;
			acctInfo.CompanyName = proStrategy.AcctPlanCompanyProfileID__r.Name;
			acctInfo.GroupName = proStrategy.AcctPlanCompanyProfileID__r.Name;
			acctInfo.AcctPlanWallet = proStrategy.AcctPlanWallet__c;
			acctInfo.AnnualizedPerformance = proStrategy.AnnualizedPerformance__c == null ? 0 : proStrategy.AnnualizedPerformance__c;
			acctInfo.AspirationSOW = proStrategy.AspirationSOW__c == null ? 0 : proStrategy.AspirationSOW__c;
			acctInfo.CompareSOW = proStrategy.CompareSOW__c == null ? 0 : proStrategy.CompareSOW__c;
			acctInfo.ExistingSOW = proStrategy.ExistingSOW__c == null ? 0 : proStrategy.ExistingSOW__c;
			acctInfo.ExpectedSOWPercent = proStrategy.ExpectedSOWPercent__c == null ? 0 : proStrategy.ExpectedSOWPercent__c;
			acctInfo.WalletSizing = proStrategy.WalletSizing__c == null ? 0 : proStrategy.WalletSizing__c;
			acctInfo.TotalCompanyNI = proStrategy.TotalCompanyNI__c == null ? 0 : proStrategy.TotalCompanyNI__c;

			//DA: acctInfo.ActualPerformance = 5000;
			acctInfo.ExpectedIncrementalNI = proStrategy.ExpectedIncrementalNI__c == null ? 0 : proStrategy.ExpectedIncrementalNI__c;
			acctInfo.ExpectedIncrementalNIFromStep5 = proStrategy.ExpectedIncrementalNIFromStep5__c == null ? 0 : proStrategy.ExpectedIncrementalNIFromStep5__c;
			acctInfo.AdjustNI = proStrategy.Adjust_NI__c == null ? 0 : proStrategy.Adjust_NI__c;
			acctInfo.RefreshAsOf = proStrategy.RefreshAsOf__c;

			lstAcctPlanProdStrategyInfo.add(acctInfo);

		}

		return lstAcctPlanProdStrategyInfo;

	}


	public void createDefaultProdStrategyPort(string acctYear, Map<string, Map<Id /*Account Id*/, Account>> accountGroup, Map<Id, List<AcctPlanProdStrategyPort__c>> mapPlanProdStrategyPort) {
        Datetime dt = Datetime.now();
		// IF SOME ACCOUNT NOT HAVE PlanProdStrategyPort  THEN DEFAULT 0         
		for (Account item : accountGroup.get('WithOutAccountPlan').values()) {
			if (!mapPlanProdStrategyPort.containsKey(item.Id)) {
				mapPlanProdStrategyPort.put(item.Id, new List<AcctPlanProdStrategyPort__c> ());

				system.debug('::::::::  ไม่พบ PlanProdStrategyPort set defualt for : ' + item.Name + ' || Id = ' + item.Id);
                
				//1    1. NIIc
				mapPlanProdStrategyPort.get(item.Id).add(new AcctPlanProdStrategyPort__c(
				                                                                         SEQ__c = 1.00,
				                                                                         Name = '1. NIIc',
				                                                                         AccountId__c = item.Id,
				                                                                         WalletSizing__c = 0,
				                                                                         AnnualizedPerformance__c = 0,
				                                                                         Adjust_NI__c = 0,
				                                                                         AspirationSOW__c = 0,
				                                                                         Year__c = acctYear,
				                                                                         ExpectedIncrementalNIFreeText__c = 0,
                    																	AsOfDate__c = dt
				));
				//2    2. NIId
				mapPlanProdStrategyPort.get(item.Id).add(new AcctPlanProdStrategyPort__c(
				                                                                         SEQ__c = 2.00,
				                                                                         Name = '2. NIId',
				                                                                         AccountId__c = item.Id,
				                                                                         WalletSizing__c = 0,
				                                                                         AnnualizedPerformance__c = 0,
				                                                                         Adjust_NI__c = 0,
				                                                                         AspirationSOW__c = 0,
				                                                                         Year__c = acctYear,
				                                                                         ExpectedIncrementalNIFreeText__c = 0,
                    																	AsOfDate__c = dt
				));
				//3    3. Fee
				mapPlanProdStrategyPort.get(item.Id).add(new AcctPlanProdStrategyPort__c(
				                                                                         SEQ__c = 3.00,
				                                                                         Name = '3. Fee',
				                                                                         AccountId__c = item.Id,
				                                                                         WalletSizing__c = 0,
				                                                                         AnnualizedPerformance__c = 0,
				                                                                         Adjust_NI__c = 0,
				                                                                         AspirationSOW__c = 0,
				                                                                         Year__c = acctYear,
				                                                                         ExpectedIncrementalNIFreeText__c = 0,
                    																	AsOfDate__c = dt
				));
				//4    Recurring Fee
				mapPlanProdStrategyPort.get(item.Id).add(new AcctPlanProdStrategyPort__c(
				                                                                         SEQ__c = 4.00,
				                                                                         Name = 'Recurring Fee',
				                                                                         AccountId__c = item.Id,
				                                                                         WalletSizing__c = 0,
				                                                                         AnnualizedPerformance__c = 0,
				                                                                         Adjust_NI__c = 0,
				                                                                         AspirationSOW__c = 0,
				                                                                         Year__c = acctYear,
				                                                                         ExpectedIncrementalNIFreeText__c = 0,
                    																	AsOfDate__c = dt
				));
				//5    3.1 TF Fee
				mapPlanProdStrategyPort.get(item.Id).add(new AcctPlanProdStrategyPort__c(
				                                                                         SEQ__c = 5.00,
				                                                                         Name = '3.1 TF Fee',
				                                                                         AccountId__c = item.Id,
				                                                                         WalletSizing__c = 0,
				                                                                         AnnualizedPerformance__c = 0,
				                                                                         Adjust_NI__c = 0,
				                                                                         AspirationSOW__c = 0,
				                                                                         Year__c = acctYear,
				                                                                         ExpectedIncrementalNIFreeText__c = 0,
                    																	AsOfDate__c = dt
				));
				//6    3.2 Fx Fee
				mapPlanProdStrategyPort.get(item.Id).add(new AcctPlanProdStrategyPort__c(
				                                                                         SEQ__c = 6.00,
				                                                                         Name = '3.2 FX Fee',
				                                                                         AccountId__c = item.Id,
				                                                                         WalletSizing__c = 0,
				                                                                         AnnualizedPerformance__c = 0,
				                                                                         Adjust_NI__c = 0,
				                                                                         AspirationSOW__c = 0,
				                                                                         Year__c = acctYear,
				                                                                         ExpectedIncrementalNIFreeText__c = 0,
                    																	AsOfDate__c = dt
				));
				//7    3.3 L/G Fee
				mapPlanProdStrategyPort.get(item.Id).add(new AcctPlanProdStrategyPort__c(
				                                                                         SEQ__c = 7.00,
				                                                                         Name = '3.3 L/G Fee',
				                                                                         AccountId__c = item.Id,
				                                                                         WalletSizing__c = 0,
				                                                                         AnnualizedPerformance__c = 0,
				                                                                         Adjust_NI__c = 0,
				                                                                         AspirationSOW__c = 0,
				                                                                         Year__c = acctYear,
				                                                                         ExpectedIncrementalNIFreeText__c = 0,
                    																	AsOfDate__c = dt
				));
				//8    3.4 Cash Fee
				mapPlanProdStrategyPort.get(item.Id).add(new AcctPlanProdStrategyPort__c(
				                                                                         SEQ__c = 8.00,
				                                                                         Name = '3.4 Cash Fee',
				                                                                         AccountId__c = item.Id,
				                                                                         WalletSizing__c = 0,
				                                                                         AnnualizedPerformance__c = 0,
				                                                                         Adjust_NI__c = 0,
				                                                                         AspirationSOW__c = 0,
				                                                                         Year__c = acctYear,
				                                                                         ExpectedIncrementalNIFreeText__c = 0,
                    																	AsOfDate__c = dt
				));
				//9    3.5 AS Fee
				mapPlanProdStrategyPort.get(item.Id).add(new AcctPlanProdStrategyPort__c(
				                                                                         SEQ__c = 9.00,
				                                                                         Name = '3.5 AS Fee',
				                                                                         AccountId__c = item.Id,
				                                                                         WalletSizing__c = 0,
				                                                                         AnnualizedPerformance__c = 0,
				                                                                         Adjust_NI__c = 0,
				                                                                         AspirationSOW__c = 0,
				                                                                         Year__c = acctYear,
				                                                                         ExpectedIncrementalNIFreeText__c = 0,
                    																	AsOfDate__c = dt
				));
				//10   Non recurring fee
				mapPlanProdStrategyPort.get(item.Id).add(new AcctPlanProdStrategyPort__c(
				                                                                         SEQ__c = 10.00,
				                                                                         Name = 'Non Recurring Fee',
				                                                                         AccountId__c = item.Id,
				                                                                         WalletSizing__c = 0,
				                                                                         AnnualizedPerformance__c = 0,
				                                                                         Adjust_NI__c = 0,
				                                                                         AspirationSOW__c = 0,
				                                                                         Year__c = acctYear,
				                                                                         ExpectedIncrementalNIFreeText__c = 0,
                    																	AsOfDate__c = dt
				));
				//11   3.6 Credit fee
				mapPlanProdStrategyPort.get(item.Id).add(new AcctPlanProdStrategyPort__c(
				                                                                         SEQ__c = 11.00,
				                                                                         Name = '3.6 Credit Fee',
				                                                                         AccountId__c = item.Id,
				                                                                         WalletSizing__c = 0,
				                                                                         AnnualizedPerformance__c = 0,
				                                                                         Adjust_NI__c = 0,
				                                                                         AspirationSOW__c = 0,
				                                                                         Year__c = acctYear,
				                                                                         ExpectedIncrementalNIFreeText__c = 0,
                    																	AsOfDate__c = dt
				));
				//12   3.7 BA Fee
				mapPlanProdStrategyPort.get(item.Id).add(new AcctPlanProdStrategyPort__c(
				                                                                         SEQ__c = 12.00,
				                                                                         Name = '3.7 BA Fee',
				                                                                         AccountId__c = item.Id,
				                                                                         WalletSizing__c = 0,
				                                                                         AnnualizedPerformance__c = 0,
				                                                                         Adjust_NI__c = 0,
				                                                                         AspirationSOW__c = 0,
				                                                                         Year__c = acctYear,
				                                                                         ExpectedIncrementalNIFreeText__c = 0,
                    																	AsOfDate__c = dt
				));
				//13   3.8 Derivative Fee
				mapPlanProdStrategyPort.get(item.Id).add(new AcctPlanProdStrategyPort__c(
				                                                                         SEQ__c = 13.00,
				                                                                         Name = '3.8 Derivative Fee',
				                                                                         AccountId__c = item.Id,
				                                                                         WalletSizing__c = 0,
				                                                                         AnnualizedPerformance__c = 0,
				                                                                         Adjust_NI__c = 0,
				                                                                         AspirationSOW__c = 0,
				                                                                         Year__c = acctYear,
				                                                                         ExpectedIncrementalNIFreeText__c = 0,
                    																	AsOfDate__c = dt
				));
				//14   3.9 IB Fee
				mapPlanProdStrategyPort.get(item.Id).add(new AcctPlanProdStrategyPort__c(
				                                                                         SEQ__c = 14.00,
				                                                                         Name = '3.9 IB Fee',
				                                                                         AccountId__c = item.Id,
				                                                                         WalletSizing__c = 0,
				                                                                         AnnualizedPerformance__c = 0,
				                                                                         Adjust_NI__c = 0,
				                                                                         AspirationSOW__c = 0,
				                                                                         Year__c = acctYear,
				                                                                         ExpectedIncrementalNIFreeText__c = 0,
                    																	AsOfDate__c = dt
				));
			}
		}
	}


	/************************************************************************************
	 *   FIND CUSTOMER NAME
	 * **********************************************************************************/
	private Map<Id /*AccountId*/, String /*Account Name*/> GetCustomerName(Map<string, Map<Id /*Account Id*/, Account>> accountGroup,
	                                                                       Map<Id /*AccountId*/, String /*Account Name*/> mapAcctIdAndCustomerName,
	                                                                       Id groupId, String acctYear,
	                                                                       Map<Id /*Account Id*/, List<AcctPlanProdStrategyPort__c>> mapPlanProdStrategyPort) {

        //List<Acct groupId
		//Fix Default value 
		for (Account item : accountGroup.get('WithAccountPlan').values()) {
			mapAcctIdAndCustomerName.put(item.Id, item.Id + ' Need to refresh <br /> <span class="glyphicon glyphicon-user" aria-hidden="true"></span>');
		}

		if (accountGroup.get('WithAccountPlan').size() > 0) {
			// With Account Plan
			for (AcctPlanCompanyProfile__c item : AccountPlanCompanyProfileSelector.getCompanyProfileByAccountIdsAndYear(accountGroup.get('WithAccountPlan').keySet(), acctYear)) {
				mapAcctIdAndCustomerName.put(item.Account__c, item.AccountName__c == null ? item.Account__c + ' Need to refresh <br /> <span class="glyphicon glyphicon-user" aria-hidden="true"></span> ' : item.AccountName__c + '<br /> <span class="glyphicon glyphicon-user" aria-hidden="true"></span>');
			}
		}


		//Fix Default value 
		for (Account item : accountGroup.get('WithOutAccountPlan').values()) {
			mapAcctIdAndCustomerName.put(item.Id, item.Id + ' Need to refresh <br /> <span class="glyphicon glyphicon-remove-circle" aria-hidden="true"></span>');
		}



		// With Account Plan
		for (Id objId : mapPlanProdStrategyPort.keySet()) {
			//  always contain value
			AcctPlanProdStrategyPort__c item = mapPlanProdStrategyPort.get(objId) [0];
            item.AccountId_PE__c = item.AccountId__c;
			mapAcctIdAndCustomerName.put(objId, item.AccountName__c == null ? objId + ' Need to refresh <br /> <span class="glyphicon glyphicon-remove-circle" aria-hidden="true"></span>' : item.AccountName__c + '<br /> <span class="glyphicon glyphicon-remove-circle" aria-hidden="true"></span>');
		}

		return mapAcctIdAndCustomerName;
	}
    // FIND CUSTOMER NAME : return object
	private Map<String /*AccountId*/, SObject /*Account Name*/> GetCustomerName(Map<string, Map<Id /*Account Id*/, Account>> accountGroup,
	                                                                       Map<String /*AccountId*/, SObject /*Account Name*/> mapAcctIdAndCustomerName,
	                                                                       Id groupId, String acctYear,
	                                                                       Map<Id /*Account Id*/, List<AcctPlanProdStrategyPort__c>> mapPlanProdStrategyPort) {

        //List<Acct groupId
		//Fix Default value 
		for (Account item : accountGroup.get('WithAccountPlan').values()) {
            mapAcctIdAndCustomerName.put(item.Id+'true', item);
		}

		if (accountGroup.get('WithAccountPlan').size() > 0) {
			// With Account Plan
			for (AcctPlanCompanyProfile__c item : AccountPlanCompanyProfileSelector.getCompanyProfileByAccountIdsAndYear(accountGroup.get('WithAccountPlan').keySet(), acctYear)) {
				mapAcctIdAndCustomerName.put(item.Account__c+'true', item );
			}
		}

		//Fix Default value 
		for (Account item : accountGroup.get('WithOutAccountPlan').values()) {
			mapAcctIdAndCustomerName.put(item.Id+'false', item);
		}

		// With Account Plan
		for (Id objId : mapPlanProdStrategyPort.keySet()) {
			//  always contain value
			AcctPlanProdStrategyPort__c item = mapPlanProdStrategyPort.get(objId) [0];
            item.AccountId_PE__c = item.AccountId__c;
			mapAcctIdAndCustomerName.put(objId+'false', item);
		}

		return mapAcctIdAndCustomerName;
	}

	//endregion
	public AccountPlanProductStrategyService.AcctPlanProdStrategyCompanyInfo getGroupCompaniesProductStrategyInfoV2(Id groupProfileId) {
		AccountPlanProductStrategyService.AcctPlanProdStrategyCompanyInfo dto = new AccountPlanProductStrategyService.AcctPlanProdStrategyCompanyInfo();

		/*******************************************************************************
		 *      เก็บ  Account Id => Name
		 *******************************************************************************/
		Map<Id /*AccountId*/, String /*Account Name*/> mapAcctIdAndCustomerName = new Map<Id, String> ();
        Map<String /*AccountId*/, SObject /*Account Name*/> mapAcctIdAndCustomerNameSObject = new Map<String, SObject> ();
		Set<Id> acctCompanyProfileIds = new Set<Id> ();
		AcctPlanGroupProfile__c groupProfile = AccountPlanGroupProfileSelector.getGroupProfileById(groupProfileId);
		string acctYear = groupProfile.Year__c.trim();
		Id groupId = (Id) groupProfile.Group__c;
		system.debug('::: Get Account Plan for year =  ' + acctYear);

		/*******************************************************************************
		 *     STEP 1 :  Split  group of data
		 *******************************************************************************/
		Map<string, Map<Id /*Account Id*/, Account>> accountGroup = new Map<string, Map<Id, Account>> {
			'WithAccountPlan' => new Map<Id, Account> (), //  สำหรับเก็บDataที่มี product strategy
			'WithOutAccountPlan' => new Map<Id, Account> ()
		};
		Map<Id /*Account Id */, Account> accountInGroup = new Map<Id, Account> (AccountSelector.getAccountUnderGroupByGroupProfileId(groupProfileId));
		integer allcustomer = accountInGroup.size();

		system.debug('::: Number of company under ' + groupProfile.Group__r.Name + ' is ' + allcustomer);


		/*******************************************************************************
		 *  STEP 2 :   FIND COMPANY UNDER GROUP IN ACCOUNT PLAN        
		 *******************************************************************************/
		for (AcctPlanCompanyProfile__c item : AccountPlanCompanyProfileSelector.getAllCompanyProfileUnderGroupByGroupProfolioId(New Set<Id> { groupId }, acctYear)) {
			accountGroup.get('WithAccountPlan').put(item.Account__c, new Account(Id = item.Account__c));
			acctCompanyProfileIds.add(item.Id);

			// dto.TotalGroupTargetNIByRm += item.TargetNIByRM__c null ? 0 : item.TargetNIByRM__c;
			if (accountInGroup.containsKey(item.Account__c)) {
				/*******************************************************************************
				 *                  STEP 2.1 ) Make WithAccountPlan
				 *******************************************************************************/
				accountInGroup.remove(item.Account__c);
			}
		}


		for (AcctPlanCompanyPort__c item :
		     AccountPlanCompanyPortSelector.getAllCompanyPortUnderGroupByGroupProfolioId(groupProfile.Id)) {
			dto.TotalGroupTargetNIByRm += item.Target_NI_By_RM__c == null ? 0 : item.Target_NI_By_RM__c;
		}




		/*******************************************************************************
		 *                  STEP 2.2 ) Make WithOutAccountPlan
		 *******************************************************************************/
		for (Account acc : accountInGroup.values()) {
			accountGroup.get('WithOutAccountPlan').put(acc.Id, acc);
		}

		/*******************************************************************************
		 *   STEP 4 Find Product Strategy for Account  that have account plant wallet   
		 *   NOTE ACCOUT PLAN WITH PRODUCT STRATEGY stored in mapPlanProdStrategy
		 *******************************************************************************/
        Map<Id, List<AcctPlanProdStrategy__c>> mapPlanProdStrategy = new Map<Id, List<AcctPlanProdStrategy__c>> ();
        if(acctCompanyProfileIds !=null && acctCompanyProfileIds.size() >0){
            for (AcctPlanProdStrategy__c item : AccountPlanProductStrategySelector.selectProductStrategyByIds(acctCompanyProfileIds)) {
                
                if (!mapPlanProdStrategy.containsKey(item.AcctPlanCompanyProfileID__r.Account__c)) {
                    //system.debug('::::: Add Key to map ' + item.AcctPlanCompanyProfileID__r.Account__c);                
                    mapPlanProdStrategy.put(item.AcctPlanCompanyProfileID__r.Account__c, new List<AcctPlanProdStrategy__c> ());
                }
                mapPlanProdStrategy.get(item.AcctPlanCompanyProfileID__r.Account__c).add(item);
                
            }
            
        }
        
		/*******************************************************************************
		 *   STEP 4.1) F หากยังไม่มี Product Strategy  ก็เอาออกไปไว้ที่  WithOutAccount Plan      
		 *******************************************************************************/
		for (Account item : accountGroup.get('WithAccountPlan').values()) {
			if (!mapPlanProdStrategy.containsKey(item.Id)) {

				accountGroup.get('WithOutAccountPlan').put(item.Id, accountGroup.get('WithAccountPlan').get(item.Id));
				accountGroup.get('WithAccountPlan').remove(item.Id);

			}
		}

		system.debug('==============================================================================');
		system.debug('::: Final WithAccountPlan = ' + accountGroup.get('WithAccountPlan').size());
		system.debug('::: Final WithOutAccountPlan = ' + accountGroup.get('WithOutAccountPlan').size());


		/*******************************************************************************
		 *   STEP 5 ) Temp for Product Strategy Port  Plan      
		 *******************************************************************************/
		Map<Id /*Account Id*/, List<AcctPlanProdStrategyPort__c>> mapPlanProdStrategyPort = new Map<Id, List<AcctPlanProdStrategyPort__c>> ();
        if(accountGroup.get('WithOutAccountPlan').size() >0){
            for (AcctPlanProdStrategyPort__c item : AccountPlanProductStrategyPortSelector.selectProductStrategyPortByAccountIdsAndYear(accountGroup.get('WithOutAccountPlan').keySet(), acctYear)) {
                
                if (!mapPlanProdStrategyPort.containsKey(item.AccountId__c)) {
                    system.debug('::::: Add Key to map mapPlanProdStrategyPort ' + item.AccountId__c);
                    mapPlanProdStrategyPort.put(item.AccountId__c, new List<AcctPlanProdStrategyPort__c> ());
                }
                mapPlanProdStrategyPort.get(item.AccountId__c).add(item);
            }
            
        }
        
		system.debug(':::: Before PlanProdStrategyPort Size = ' + mapPlanProdStrategyPort.size());
		createDefaultProdStrategyPort(acctYear, accountGroup, mapPlanProdStrategyPort);
		system.debug(':::: After  PlanProdStrategyPort Size = ' + mapPlanProdStrategyPort.size());
		


		/*******************************************************************************
		 *   STEP 6 ) Create DTO      
		 *******************************************************************************/

		dto.mapCompanyProfileIds = acctCompanyProfileIds;
		// Contain Product Strategy
		for (Account item : accountGroup.get('WithAccountPlan').values()) {

			if (!dto.GroupWalletSizing.containsKey(item.Id)) {
				dto.GroupWalletSizing.put(item.Id, new Map<Decimal /*SEQ = Row number*/, Decimal> ());
				dto.GroupActualNiRolling.put(item.Id, new Map<Decimal /*SEQ = Row number*/, Decimal> ());
				dto.GroupAdjustedNI.put(item.Id, new Map<Decimal /*SEQ = Row number*/, Decimal> ());
				dto.GroupExpectedIncrementalNI.put(item.Id, new Map<Decimal /*SEQ = Row number*/, Decimal> ());
				//Add new support step5
				dto.GroupExpectedIncrementalNIStep5.put(item.Id, new Map<Decimal /*SEQ = Row number*/, Decimal> ());
				dto.GroupTotalCompanyNI.put(item.Id, new Map<Decimal /*SEQ = Row number*/, Decimal> ());
				dto.GroupExpectedSOW.put(item.Id, new Map<Decimal /*SEQ = Row number*/, Decimal> ());
			}
			// Support Roolup Fee Adjusted NI
			decimal feeAdjustedNi = 0;
			decimal feeAdjustedNiStep5 = 0;
			decimal feegroupNi = 0;


			for (AcctPlanProdStrategy__c pro : mapPlanProdStrategy.get(item.Id)) {

				decimal seq = pro.SEQ__c;

				System.debug('::: Seq ' + seq);
				if (!dto.SumOfExpectedIncrementalNIStep4.containsKey(seq)) {
					dto.SumOfExpectedIncrementalNIStep4.put(seq, new List<decimal> ());
					dto.SumOfExpectedIncrementalNIStep6.put(seq, new List<decimal> ());
				}
				if (!dto.SumOfWalletStep4.containsKey(seq)) {
					dto.SumOfWalletStep4.put(seq, new List<decimal> ());
					dto.SumOfWalletStep6.put(seq, new List<decimal> ());
				}

				//Add by : ktc
				//Add date : 2015-12-15
				if (!dto.GroupRefreshDate.containsKey(pro.AcctPlanCompanyProfileID__r.Account__c))
				{
				  
					dto.GroupRefreshDate.put(pro.AcctPlanCompanyProfileID__r.Account__c, pro.RefreshAsOf__c);
				}

				decimal wallet = pro.WalletSizing__c == null ? 0 : pro.WalletSizing__c;
				decimal adjust = pro.Adjust_NI__c == null ? 0 : pro.Adjust_NI__c;
				dto.GroupAdjustedNI.get(item.Id).put(seq, adjust);
			//	System.debug('Account id ' + item.Id + '::: Seq ' + seq + '|| Adjusted NI >> ' + adjust);

				decimal rolling = pro.AnnualizedPerformance__c == null ? 0 : pro.AnnualizedPerformance__c;
				decimal step5 = pro.ExpectedIncrementalNIFromStep5__c == null ? 0 : pro.ExpectedIncrementalNIFromStep5__c;
				decimal Aspiration = (pro.AspirationSOW__c == null ? 0 : pro.AspirationSOW__c) / 100;




				// SUM(Expected Incremental NI + Wallet) / SUM(Wallet) 
				dto.SumOfWalletStep4.get(seq).add(wallet);
				dto.SumOfWalletStep6.get(seq).add(wallet);
				dto.SumOfExpectedIncrementalNIStep6.get(seq).add(Aspiration * wallet);

				// Group Wallet Sizing (Yearly) 
				dto.GroupWalletSizing.get(item.Id).put(pro.SEQ__c, wallet);
				//Group's Actual NI (12-mth Rolling) 
				dto.GroupActualNiRolling.get(item.Id).put(pro.SEQ__c, rolling);
				dto.GroupExpectedIncrementalNIStep5.get(item.Id).put(pro.SEQ__c, step5);
				dto.GroupTotalCompanyNI.get(item.Id).put(pro.SEQ__c, pro.TotalCompanyNI__c == null ? 0 : pro.TotalCompanyNI__c);


				//  Fix : Adjusted NI
				//===============================================================================
				if (seq > 3.00)
				{
					feeAdjustedNi += adjust;
					feeAdjustedNiStep5 += step5;
					feegroupNi += (pro.TotalCompanyNI__c == null ? 0 : pro.TotalCompanyNI__c);
					// System.debug(':::  feeAdjustedNi > '+  feeAdjustedNi);
				}
				if (seq == 14.00)
				{
					//Rollup AdjustedNi to Fee Row
					System.debug(':::: Rollup AdjustedNi For Fee : ' + mapAcctIdAndCustomerName.get(item.Id) + ' Value : ' + feeAdjustedNi);
					dto.GroupAdjustedNI.get(item.Id).put(3.00, feeAdjustedNi);
					dto.GroupExpectedIncrementalNIStep5.get(item.Id).put(3.00, feeAdjustedNiStep5);
					dto.GroupTotalCompanyNI.get(item.Id).put(3.00, feegroupNi);
					//System.debug('::: Total by company feeAdjustedNi > ' + feeAdjustedNi);

				}
				//>>Fix : Adjusted NI
				//=================================================================================



				dto.GroupExpectedSOW.get(item.Id).put(pro.SEQ__c, pro.ExpectedSOWPercent__c == null ? 0 : pro.ExpectedSOWPercent__c);


				if (pro.SEQ__c == 9.00 || pro.SEQ__c == 13.00 || pro.SEQ__c == 14.00) {
					decimal val = pro.ExpectedIncrementalNIFreeText__c == null ? 0 : pro.ExpectedIncrementalNIFreeText__c;
					dto.GroupExpectedIncrementalNI.get(item.Id).put(pro.SEQ__c, val);
					dto.SumOfExpectedIncrementalNIStep4.get(seq).add(val + adjust);
				}
				else {
					if (pro.ExpectedIncrementalNI__c == null) {
						dto.GroupExpectedIncrementalNI.get(item.Id).put(pro.SEQ__c, 0);
						dto.SumOfExpectedIncrementalNIStep4.get(seq).add(0 + adjust);

					}
					else {
						decimal val = pro.ExpectedIncrementalNI__c == null ? 0 : pro.ExpectedIncrementalNI__c;
						dto.GroupExpectedIncrementalNI.get(item.Id).put(pro.SEQ__c, val);
						dto.SumOfExpectedIncrementalNIStep4.get(seq).add(val + adjust);
					}

				}


				if (dto.RefreshAsOf < pro.RefreshAsOf__c)
				dto.RefreshAsOf = pro.RefreshAsOf__c;
				if (dto.RefreshAsOf == null)
				dto.RefreshAsOf = pro.RefreshAsOf__c;
				// system.debug('>>>>Account => '+mapAcctIdAndCustomerName.get(item.id)+ '  ||  Seq => '+pro.SEQ__c +'   || Value => ' +    dto.GroupExpectedIncrementalNI.get(item.Id).get(pro.SEQ__c)                );  
			}
		}
        Datetime dtdefualt = Datetime.now();
		// Not Contain Product Strategy
		for (Account item : accountGroup.get('WithOutAccountPlan').values()) {
            
               
            //Add by : ktc
            //Add date : 2015-12-15
            if (!dto.GroupRefreshDate.containsKey(item.Id))
            {						
                dto.GroupRefreshDate.put(item.Id, dtdefualt);
            }        
            
            
			if (!dto.GroupWalletSizing.containsKey(item.Id)) {
				dto.GroupWalletSizing.put(item.Id, new Map<Decimal /*SEQ = Row number*/, Decimal> ());
				dto.GroupActualNiRolling.put(item.Id, new Map<Decimal /*SEQ = Row number*/, Decimal> ());
				dto.GroupAdjustedNI.put(item.Id, new Map<Decimal /*SEQ = Row number*/, Decimal> ());
				dto.GroupExpectedIncrementalNI.put(item.Id, new Map<Decimal /*SEQ = Row number*/, Decimal> ());
				//Add new support step5
				dto.GroupExpectedIncrementalNIStep5.put(item.Id, new Map<Decimal /*SEQ = Row number*/, Decimal> ());
				dto.GroupTotalCompanyNI.put(item.Id, new Map<Decimal /*SEQ = Row number*/, Decimal> ());

				dto.GroupExpectedSOW.put(item.Id, new Map<Decimal /*SEQ = Row number*/, Decimal> ());
			}
			// Support Roolup Fee Adjusted NI
			decimal feeAdjustedNi = 0;
			decimal feeAdjustedNiStep5 = 0;
			decimal feegroupNi = 0;
			for (AcctPlanProdStrategyPort__c pro : mapPlanProdStrategyPort.get(item.Id)) {
				decimal seq = pro.SEQ__c;
				if (!dto.SumOfExpectedIncrementalNIStep4.containsKey(seq)) {
					dto.SumOfExpectedIncrementalNIStep4.put(seq, new List<decimal> ());
					dto.SumOfExpectedIncrementalNIStep6.put(seq, new List<decimal> ());
				}
				if (!dto.SumOfWalletStep4.containsKey(seq)) {
					dto.SumOfWalletStep4.put(seq, new List<decimal> ());
					dto.SumOfWalletStep6.put(seq, new List<decimal> ());
				}

				//Add by : ktc
				//Add date : 2015-12-15
				

                if (pro.AsOfDate__c != null)
                {
                    dto.GroupRefreshDate.put(pro.AccountId__c, pro.AsOfDate__c);
                }
              


				



				decimal wallet = pro.WalletSizing__c == null ? 0 : pro.WalletSizing__c;
				decimal adjust = pro.Adjust_NI__c == null ? 0 : pro.Adjust_NI__c;
				decimal Aspiration = (pro.AspirationSOW__c == null ? 0 : pro.AspirationSOW__c) / 100;

				// SUM(Expected Incremental NI + Wallet) / SUM(Wallet) 
				dto.SumOfWalletStep4.get(seq).add(wallet);
				dto.SumOfWalletStep6.get(seq).add(wallet);
				dto.SumOfExpectedIncrementalNIStep6.get(seq).add(Aspiration * wallet);

				// Group Wallet Sizing (Yearly) 
				dto.GroupWalletSizing.get(item.Id).put(pro.SEQ__c, wallet);
				//Group's Actual NI (12-mth Rolling) 
				dto.GroupActualNiRolling.get(item.Id).put(pro.SEQ__c, pro.AnnualizedPerformance__c == null ? 0 : pro.AnnualizedPerformance__c);

				dto.GroupAdjustedNI.get(item.Id).put(pro.SEQ__c, adjust);
				decimal step = pro.ExpectedIncrementalNIFromStep5__c == null ? 0 : pro.ExpectedIncrementalNIFromStep5__c;
				dto.GroupExpectedIncrementalNIStep5.get(item.Id).put(pro.SEQ__c, step);
				dto.GroupTotalCompanyNI.get(item.Id).put(pro.SEQ__c, pro.TotalCompanyNI__c == null ? 0 : pro.TotalCompanyNI__c);



				//  Fix : Adjusted NI
				//===============================================================================
				if (seq > 3.00)
				{
					feeAdjustedNi += adjust;
					feeAdjustedNiStep5 += 0;
					feegroupNi += (pro.TotalCompanyNI__c == null ? 0 : pro.TotalCompanyNI__c);
					// System.debug(':::  feeAdjustedNi > '+  feeAdjustedNi);
				}
				if (seq == 14.00)
				{
					//Rollup AdjustedNi to Fee Row
					System.debug(':::: Rollup AdjustedNi For Fee : ' + mapAcctIdAndCustomerName.get(item.Id) + ' Value : ' + feeAdjustedNi);
					dto.GroupAdjustedNI.get(item.Id).put(3.00, feeAdjustedNi);
					dto.GroupExpectedIncrementalNIStep5.get(item.Id).put(3.00, feeAdjustedNiStep5);
					dto.GroupTotalCompanyNI.get(item.Id).put(3.00, feegroupNi);
					System.debug('::: Total by company feeAdjustedNi > ' + feeAdjustedNi);

				}
				//>>Fix : Adjusted NI
				//=================================================================================


				dto.GroupExpectedSOW.get(item.Id).put(pro.SEQ__c, pro.ExpectedSOWPercent__c == null ? 0 : pro.ExpectedSOWPercent__c);

				if (pro.SEQ__c == 9.00 || pro.SEQ__c == 13.00 || pro.SEQ__c == 14.00) {
					decimal val = pro.ExpectedIncrementalNIFreeText__c == null ? 0 : pro.ExpectedIncrementalNIFreeText__c;
					dto.GroupExpectedIncrementalNI.get(item.Id).put(pro.SEQ__c, val);
					dto.SumOfExpectedIncrementalNIStep4.get(seq).add(val + adjust);
				}
				else {
					if (pro.ExpectedIncrementalNI__c == null) {
						dto.GroupExpectedIncrementalNI.get(item.Id).put(pro.SEQ__c, 0);
						dto.SumOfExpectedIncrementalNIStep4.get(seq).add(0 + adjust);
					}
					else {
						decimal val = pro.ExpectedIncrementalNI__c == null ? 0 : pro.ExpectedIncrementalNI__c;
						dto.GroupExpectedIncrementalNI.get(item.Id).put(pro.SEQ__c, val);
						dto.SumOfExpectedIncrementalNIStep4.get(seq).add(val + adjust);
					}

				}

			}
		}
		/********************************************************************
		 *   Understanding only account with wallet
		 ********************************************************************/
		if (accountGroup.get('WithAccountPlan').size() > 0 && !Test.isRunningTest()) {
			System.debug(':::::  accountInGroup ' + accountGroup.get('WithAccountPlan').keySet());
			AggregateResult[] ar = AccountPlanCustomerUnderstandingSelector.getSummaryByAccountIdsAndYear(accountGroup.get('WithAccountPlan').keySet(), acctYear);
			if (ar.size() > 0) {
				dto.EndCASA = (decimal) ar[0].get('EndCASA');
				dto.AvgCASA = (decimal) ar[0].get('AvgCASA');
				dto.AvgLoan = (decimal) ar[0].get('AvgLoan');
				dto.EndLoan = (decimal) ar[0].get('EndLoan');
				dto.FXvolume = (decimal) ar[0].get('FXvolume');
				dto.TFVolume = (decimal) ar[0].get('TFVolume');
			}
			else {
				dto.EndCASA = 0;
				dto.AvgCASA = 0;
				dto.AvgLoan = 0;
				dto.EndLoan = 0;
				dto.FXvolume = 0;
				dto.TFVolume = 0;
			}
		}
		else {
			dto.EndCASA = 0;
			dto.AvgCASA = 0;
			dto.AvgLoan = 0;
			dto.EndLoan = 0;
			dto.FXvolume = 0;
			dto.TFVolume = 0;
		}

		system.debug('::::::: GET ACCOUNT NAME :::::::::');
		mapAcctIdAndCustomerName = GetCustomerName(accountGroup, mapAcctIdAndCustomerName, groupId, acctYear, mapPlanProdStrategyPort);
		mapAcctIdAndCustomerNameSObject = GetCustomerName(accountGroup, mapAcctIdAndCustomerNameSObject, groupId, acctYear, mapPlanProdStrategyPort);
		
		dto.mapCompanyName = mapAcctIdAndCustomerName;
		dto.mapCompanyNameSObject = mapAcctIdAndCustomerNameSObject;
		dto.GroupId = groupId;
		dto.GroupProfileId = groupProfile.Id; 
		dto.AccountWithAccountPlan = accountGroup.get('WithAccountPlan').keySet();
		dto.AccountWithoutAccountPlan = accountGroup.get('WithOutAccountPlan').keySet();
		dto.Year = acctYear;
		dto.GroupName = groupProfile.Name;

		system.debug(':::: SumOfExpectedIncrementalNIStep4 = ' + dto.SumOfExpectedIncrementalNIStep4);
		system.debug(':::: SumOfWalletStep4 = ' + dto.SumOfWalletStep4);




		return dto;
	}
}