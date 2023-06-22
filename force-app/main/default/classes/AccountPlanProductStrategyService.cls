global without sharing class AccountPlanProductStrategyService {
	// Factory
	private static IAccountPlanProductStrategyService service() {
		return(IAccountPlanProductStrategyService) new AccountPlanProductStrategyServiceImpl();
	}
	// Services  Method
	global static List<AcctPlanProdStrategy__c> createProductStrategyRecordToWallet(Id acctPlanCompanyId, Id acctPlanWallet) {

		system.debug('Call Service createProductStrategyRecordToWallet');
		Savepoint sp = Database.setSavepoint();
		List<AcctPlanProdStrategy__c> acctPlanProdStrategies;
		try {
			acctPlanProdStrategies = service().createProductStrategyRecordToWallet(acctPlanCompanyId, acctPlanWallet);
		}
		catch(Exception ex) {
			Database.rollback(sp);
			system.debug(ex);
			throw new AccountPlanProductStrategyServiceException(ex);
		}
		return acctPlanProdStrategies;

	}
	global static List<AcctPlanProdStrategy__c> createProductStrategyRecordToWallet(Id acctPlanCompanyId, Id acctPlanGruopId, Id acctPlanWallet) {

		system.debug('Call Service createProductStrategyRecordToWallet');
		Savepoint sp = Database.setSavepoint();
		List<AcctPlanProdStrategy__c> acctPlanProdStrategies;
		try {
			acctPlanProdStrategies = service().createProductStrategyRecordToWallet(acctPlanCompanyId, acctPlanGruopId, acctPlanWallet);
		}
		catch(Exception ex) {
			Database.rollback(sp);
			system.debug(ex);
			throw new AccountPlanProductStrategyServiceException(ex);
		}
		return acctPlanProdStrategies;

	}
	global static List<AcctPlanProdStrategy__c> getCompaniesProductStrategy(Set<ID> acctPlanCompanyIds) { //Use Interface 
		return service().getCompaniesProductStrategy(acctPlanCompanyIds);
	}
	global static List<AcctPlanProdStrategyInfo> getCompaniesProductStrategyInfo(Set<ID> acctPlanCompanyIds) {

		return service().getCompaniesProductStrategyInfo(acctPlanCompanyIds);
	}
	global static AcctPlanProdStrategyInfoSummary getGroupCompaniesProductStrategyInfo(Set<ID> acctPlanGruopIds) {
		List<AcctPlanProdStrategyInfo> lstAcctPlanProdStrategyInfo = service().getGroupCompaniesProductStrategyInfo(acctPlanGruopIds);

		AcctPlanProdStrategyInfoSummary accplanStrInfoSummary = new AcctPlanProdStrategyInfoSummary();
		accplanStrInfoSummary.AcctPlanProdStrategyInfoes = lstAcctPlanProdStrategyInfo;
		accplanStrInfoSummary.TotalWalletSizing = 0;
		for (AcctPlanProdStrategyInfo info : lstAcctPlanProdStrategyInfo) {
			accplanStrInfoSummary.TotalWalletSizing += info.WalletSizing;
		}
		return accplanStrInfoSummary;
	}
	global static AcctPlanProdStrategyCompanyInfo getGroupCompaniesProductStrategyInfoV2(Id groupProfileId) {
		return service().getGroupCompaniesProductStrategyInfoV2(groupProfileId);
	}

























	// Share Model
	global class AcctPlanProdStrategyInfo {
		public Id Id { get; set; }
		public Decimal SEQ { get; set; }
		public String Name { get; set; }
		public Decimal AccountPlanYear { get; set; }
		public Id AcctPlanCompanyProfileID { get; set; }
		public String CompanyName { get; set; }
		public String GroupName { get; set; }
		public Id AcctPlanGroupProfileID { get; set; }
		public Id AcctPlanWallet { get; set; }
		public Decimal AnnualizedPerformance { get; set; }
		public Decimal AspirationSOW { get; set; }
		public Decimal CompareSOW { get; set; }
		public Decimal ExistingSOW { get; set; }
		public Decimal ExpectedIncrementalNI { get; set; }
		public Decimal ExpectedSOWPercent { get; set; }
		public Decimal WalletSizing { get; set; }
		public Decimal TotalCompanyNI { get; set; }
		public Decimal ActualPerformance { get; set; }
		public Decimal ExpectedIncrementalNIFromStep5 { get; set; }
		public Decimal AdjustNI { get; set; }
		public Datetime RefreshAsOf { get; set; }
	}
	global class AcctPlanProdStrategyInfoSummary {
		public List<AcctPlanProdStrategyInfo> AcctPlanProdStrategyInfoes { get; set; }
		public decimal TotalWalletSizing { get; set; }
	}
	/*************************************************************************
	 *    SUPPORT FOR  AcctPlanProStrGrpWallet Visualforce Page
	 **************************************************************************/
	global class AcctPlanProdStrategyCompanyInfo {
		public AcctPlanProdStrategyCompanyInfo() {
			mapTableLabel = new Map<decimal, String> ();
			mapTableLabel.put(1.00, '1. NIIc');
			mapTableLabel.put(2.00, '2. NIId');
			mapTableLabel.put(3.00, '3. Fee');
			mapTableLabel.put(4.00, 'Recurring Fee');
			mapTableLabel.put(5.00, '3.1 TF Fee');
			mapTableLabel.put(6.00, '3.2 FX Fee');
			mapTableLabel.put(7.00, '3.3 L/G Fee');
			mapTableLabel.put(8.00, '3.4 Cash Fee');
			mapTableLabel.put(9.00, '3.5 AS Fee');
			mapTableLabel.put(10.00, 'Non Recurring Fee');
			mapTableLabel.put(11.00, '3.6 Credit Fee');
			mapTableLabel.put(12.00, '3.7 BA Fee');
			mapTableLabel.put(13.00, '3.8 Derivative Fee');
			mapTableLabel.put(14.00, '3.9 IB Fee');
			GroupWalletSizing = new Map<Id, Map<decimal, Decimal>> ();
			GroupActualNiRolling = new Map<Id, Map<decimal, Decimal>> ();
			GroupAdjustedNI = new Map<Id, Map<decimal, Decimal>> ();
			GroupExpectedIncrementalNI = new Map<Id, Map<decimal, Decimal>> ();
			GroupExpectedSOW = new Map<Id, Map<decimal, Decimal>> ();
			mapCompanyProfileIds = new Set<Id> ();

			//Add new support step5
			GroupTotalCompanyNI = new Map<Id, Map<decimal, Decimal>> ();
			GroupExpectedIncrementalNIStep5 = new Map<Id, Map<decimal, Decimal>> ();



			SumOfExpectedIncrementalNIStep4 = new Map<decimal /*seq*/, List<decimal> /*   Expected Incremental NI + Wallet  */> ();
			SumOfWalletStep4 = new Map<decimal /*seq*/, List<decimal> /*   Wallet  */> ();

			SumOfExpectedIncrementalNIStep6 = new Map<decimal /*seq*/, List<decimal> /*  Aspiration *  Wallet  */> ();
			SumOfWalletStep6 = new Map<decimal /*seq*/, List<decimal> /*   Wallet  */> ();



			AvgCASA = 0;
			AvgLoan = 0;
			EndLoan = 0;
			FXvolume = 0;
			TFVolume = 0;
			TotalGroupTargetNIByRm = 0;

			GroupRefreshDate = new  Map<Id,Datetime>();

		}
		//Add by : ktc
		//Add Date : 2015-12-15

		public Map<Id,Datetime> GroupRefreshDate { get; set; }
        public integer CountGroupRefreshDate{ get{return GroupRefreshDate.size();}}

		public decimal EndCASA { get; set; }
		public decimal AvgCASA { get; set; }
		public decimal AvgLoan { get; set; }
		public decimal EndLoan { get; set; }
		public decimal FXvolume { get; set; }
		public decimal TFVolume { get; set; }
		public decimal TotalGroupTargetNIByRm { get; set; }
		public Id GroupId { get; set; }
		public Id GroupProfileId { get; set; }
		public String GroupName { get; set; }
		public datetime RefreshAsOf { get; set; }

		/*******************************************************
		 *    Support for refresh
		 ********************************************************/
		public Set<Id> AccountWithAccountPlan { get; set; }
		public Set<Id> AccountWithoutAccountPlan { get; set; }
		public string Year { get; set; }
		public Map<Id /*AccountId*/, String> mapCompanyName { get; set; }
        public Map<String /*AccountId*/, SObject> mapCompanyNameSObject { get; set; }
		public Set<Id> mapCompanyProfileIds { get; set; }

		public Map<decimal, String> mapTableLabel { get; set; }
		public integer TotalAccount {
			get { return mapCompanyName.size(); }
		}



		/**********************************************************
		 *    Group Wallet sizing (THB) : Yearly
		 **********************************************************/
		public Map<Id /*Account Id*/, Map<Decimal, Decimal>> GroupWalletSizing { get; set; }
		Map<decimal /*seq*/, decimal> MapGroupWalletSizing = new Map<decimal, decimal> ();

		public decimal getGroupWallet(decimal seq) {

			system.debug('::: getGroupWallet seq no : ' + seq);

			decimal ret = 0;
			for (Id id : GroupWalletSizing.keySet()) {
				ret = ret + GroupWalletSizing.get(id).get(seq);
			}
			return ret;
		}
		public Map<decimal, decimal> getMapGroupWalletSizing {
			get
			{
				system.debug('getGroupWallet ===>' + GroupWalletSizing.size());

				if (MapGroupWalletSizing.size() == 0) {
					for (decimal seq : mapTableLabel.keySet()) {
						decimal ret = getGroupWallet(seq);
						MapGroupWalletSizing.put(seq, ret);

					}
				}
				return MapGroupWalletSizing;
			}
		}

		/**********************************************************
		 *    Group Actual NI (12-mth Rolling)
		 **********************************************************/
		public Map<Id /*Account Id*/, Map<decimal, Decimal>> GroupActualNiRolling { get; set; }
		Map<decimal /*seq*/, decimal> MapGroupActualNiRolling = new Map<decimal, decimal> ();
		public decimal getGroupActualNiRolling(decimal seq) {
			decimal ret = 0;
			for (Id id : GroupActualNiRolling.keySet()) {
				ret = ret + GroupActualNiRolling.get(id).get(seq);
			}
			return ret;
		}
		public Map<decimal, decimal> getMapGroupActualNiRolling {
			get
			{
				if (MapGroupActualNiRolling.size() == 0) {
					for (decimal seq : mapTableLabel.keySet()) {
						decimal ret = getGroupActualNiRolling(seq);
						MapGroupActualNiRolling.put(seq, ret);
					}
				}
				return MapGroupActualNiRolling;
			}
		}

		/**********************************************************
		 *   Group Adjusted NI (12-mth Rolling)
		 **********************************************************/
		public Map<Id /*Account Id*/, Map<decimal /*seq*/, Decimal>> GroupAdjustedNI { get; set; }
		Map<decimal /*seq*/, decimal> MapGroupAdjustedNI = new Map<decimal, decimal> ();
		public decimal getGroupAdjustedNI(decimal seq) {

			System.debug('::: GroupAdjusted NI Seq : ' + seq);
			decimal ret = 0;
			for (Id id : GroupAdjustedNI.keySet()) {



				Boolean cont = GroupAdjustedNI.get(id).containsKey(seq);
				if (cont)
				{
					decimal val = GroupAdjustedNI.get(id).get(seq) == null ? 0 : GroupAdjustedNI.get(id).get(seq);
					System.debug('::: Account Name ' + mapCompanyName.get(id) + '  Seq => ' + seq + ' AdjustedNI = ' + val);
					ret = ret + val;
				}
			}

			return ret;
		}
		public Map<decimal, decimal> geMapGroupAdjustedNI {
			get
			{

				if (MapGroupAdjustedNI.size() == 0) {

					for (decimal seq : mapTableLabel.keySet()) {
						decimal ret = getGroupAdjustedNI(seq) == null ? 0 : getGroupAdjustedNI(seq);
						MapGroupAdjustedNI.put(seq, ret);
					}
				}

				return MapGroupAdjustedNI;
			}
		}



		Map<decimal /*seq*/, string> MapGroupAdjustedNIDebug = new Map<decimal, string> ();
		public Map<decimal, string> getMapGroupAdjustedNIDebug {
			get {

				if (MapGroupAdjustedNIDebug.size() == 0) {
					//>> Get Each Seq 
					for (decimal seq : mapTableLabel.keySet()) {
						string html = '';
						decimal totalvalue = 0;
						//>> Each Company
						for (Id id : GroupAdjustedNI.keySet()) {
							Boolean cont = GroupAdjustedNI.get(id).containsKey(seq);
							if (cont) 
							{
								// html
								string companyName = mapCompanyName.get(id);
								decimal val = GroupAdjustedNI.get(id).get(seq) == null ? 0 : GroupAdjustedNI.get(id).get(seq);
								totalvalue += val;
								html = html + '<p> company : '+ companyName + ' value : ' + val +'</p> '; 
							}
						}

						html  = html + '<p><b> Total = ' +  totalvalue + '</b></p>';
						MapGroupAdjustedNIDebug.put(seq, html);
					}
				}
				return MapGroupAdjustedNIDebug;

			}
		}


		/**********************************************************
		 *   % Existing SOW Group Fomular
		 *   =  Group Adjusted NI (12-mth Rolling) / Group Wallet 
		 **********************************************************/
		public decimal getExistingSOWGroup(decimal seq) {
			decimal ret = 0;
			decimal gw = getGroupWallet(seq);
			decimal gq = getGroupAdjustedNI(seq);
			if (gw == 0)
			return ret;

			ret = (gq / gw ) * 100;
			return ret;
		}

		Map<decimal /*seq*/, decimal> MapExistingSOWGroup = new Map<decimal, decimal> ();

		public Map<decimal, decimal> geMapExistingSOWGroup {
			get
			{
				if (MapExistingSOWGroup.size() == 0) {
					for (decimal seq : mapTableLabel.keySet()) {
						decimal ret = getExistingSOWGroup(seq);
						MapExistingSOWGroup.put(seq, ret);
					}
				}
				return MapExistingSOWGroup;
			}
		}
		/**********************************************************
		 *   Expected incremental NI
		 **********************************************************/
		public Map<Id /*Account Id*/, Map<decimal, Decimal>> GroupExpectedIncrementalNI { get; set; }
		public Map<decimal /*seq*/, decimal> MapGroupExpectedIncrementalNI = new Map<decimal, decimal> ();

		public decimal getGroupExpectedIncrementalNI(decimal seq) {
			decimal ret = 0;
			for (Id id : GroupExpectedIncrementalNI.keySet()) {
				ret = ret + GroupExpectedIncrementalNI.get(id).get(seq);
			}
			return ret;
		}
		public Map<decimal, decimal> getMapGroupExpectedIncrementalNI {
			get
			{
				if (MapGroupExpectedIncrementalNI.size() == 0) {
					for (decimal seq : mapTableLabel.keySet()) {
						decimal ret = getGroupExpectedIncrementalNI(seq);
						MapGroupExpectedIncrementalNI.put(seq, ret);
					}
				}
				return MapGroupExpectedIncrementalNI; }
		}

		/**********************************************************
		 *   Expected incremental NI Step5
		 **********************************************************/
		public Map<Id /*Account Id*/, Map<decimal, Decimal>> GroupExpectedIncrementalNIStep5 { get; set; }
		public Map<decimal /*seq*/, decimal> MapGroupExpectedIncrementalNIStep5 = new Map<decimal, decimal> ();

		public decimal getGroupExpectedIncrementalNIStep5(decimal seq) {
			decimal ret = 0;
			for (Id id : GroupExpectedIncrementalNIStep5.keySet()) {
				ret = ret + GroupExpectedIncrementalNIStep5.get(id).get(seq);
			}
			return ret;
		}
		public Map<decimal, decimal> getMapGroupExpectedIncrementalNIStep5 {
			get
			{
				if (MapGroupExpectedIncrementalNIStep5.size() == 0) {
					for (decimal seq : mapTableLabel.keySet()) {
						decimal ret = getGroupExpectedIncrementalNIStep5(seq);
						MapGroupExpectedIncrementalNIStep5.put(seq, ret);
					}
				}
				return MapGroupExpectedIncrementalNIStep5; }
		}

		/**********************************************************
		 *   Total Company NI
		 **********************************************************/
		public Map<Id /*Account Id*/, Map<decimal, Decimal>> GroupTotalCompanyNI { get; set; }
		public Map<decimal /*seq*/, decimal> MapGroupTotalCompanyNI = new Map<decimal, decimal> ();
		//Each Company
		public decimal getGroupTotalCompanyNI(decimal seq) {
			decimal ret = 0;
			for (Id id : GroupTotalCompanyNI.keySet()) {
				ret = ret + GroupTotalCompanyNI.get(id).get(seq);
			}
			return ret;
		}
		public Map<decimal, decimal> getMapGroupTotalCompanyNI {
			get
			{
				if (MapGroupTotalCompanyNI.size() == 0) {
					for (decimal seq : mapTableLabel.keySet()) {
						decimal ret = getGroupTotalCompanyNI(seq);
						MapGroupTotalCompanyNI.put(seq, ret);
					}
				}
				return MapGroupTotalCompanyNI; }
		}


		/**********************************************************
		 *  % Expected SOW   (Group) Fomular
		 *  = TotalCompanyNI__c / WalletSizing__c
		 **********************************************************/
		public Map<Id /*Account Id*/, Map<decimal, Decimal>> GroupExpectedSOW { get; set; }
		public Map<decimal /*seq*/, decimal> MapExpectedSOW = new Map<decimal, decimal> ();

		public decimal getGroupExpectedSOW(decimal seq) {

			decimal ret = getMapGroupTotalCompanyNI.get(seq);

			decimal wall = getMapGroupWalletSizing.get(seq);
			if (wall == 0) return 0;


			ret = (ret / wall) * 100;
			return ret;
		}






		public Map<decimal, decimal> getMapExpectedSOW {
			get
			{
				if (MapExpectedSOW.size() == 0) {
					for (decimal seq : mapTableLabel.keySet()) {
						decimal ret = getGroupExpectedSOW(seq);
						MapExpectedSOW.put(seq, ret);
					}
				}
				return MapExpectedSOW;

			}
		}

		/**********************************************************
		 *   NEW
		 *   ------------------------------------------------------
		 *   Aspiration %SOW  (Group) Fomular
		 *   =  SUM(Expected Incremental NI + Wallet) / SUM(Wallet)
		 **********************************************************/

		public Map<decimal /*seq*/, List<decimal> /*   Expected Incremental NI + Wallet  */> SumOfExpectedIncrementalNIStep4 { get; set; }
		public Map<decimal /*seq*/, List<decimal> /*   Expected Incremental NI + Wallet  */> SumOfWalletStep4 { get; set; }

		public Map<decimal /*seq*/, decimal> MapAspirationSOWStep4 = new Map<decimal, decimal> ();

		public decimal getAspirationSOWStep4(decimal seq) {
			decimal ret = 0;
			decimal sumEx = 0;
			decimal sumWal = 0;
			for (decimal item : SumOfExpectedIncrementalNIStep4.get(seq)) {
				sumEx += item;
			}
			for (decimal item : SumOfWalletStep4.get(seq)) {
				sumWal += item;
			}

			system.debug('>>> sumEx  = ' + seq + ' >>>  ' + sumEx);
			system.debug('>>> sumWal = ' + seq + ' >>>  ' + sumWal);
			if (sumWal == 0) return ret;
			ret = (sumEx / sumWal) * 100;

			System.debug(' AspirationSOWStep4 for seq ' + seq + ' = ' + ret);

			return ret;
		}


		//Getter Method
		public Map<decimal, decimal> getMapAspirationSOWStep4 {
			get
			{
				if (MapAspirationSOWStep4.size() == 0) {
					for (decimal seq : mapTableLabel.keySet()) {
						system.debug('::: getMapAspirationSOWStep4 ' + seq);
						decimal ret = getAspirationSOWStep4(seq);
						MapAspirationSOWStep4.put(seq, ret);
					}
				}
				return MapAspirationSOWStep4;
			}
		}

		public Map<decimal /*seq*/, List<decimal> /*   Expected Incremental NI + Wallet  */> SumOfExpectedIncrementalNIStep6 { get; set; }
		public Map<decimal /*seq*/, List<decimal> /*   Expected Incremental NI + Wallet  */> SumOfWalletStep6 { get; set; }

		public Map<decimal /*seq*/, decimal> MapAspirationSOWStep6 = new Map<decimal, decimal> ();

		public decimal getAspirationSOWStep6(decimal seq) {
			decimal ret = 0;
			decimal sumEx = 0;
			decimal sumWal = 0;
			for (decimal item : SumOfExpectedIncrementalNIStep6.get(seq)) {
				sumEx += item;
			}
			for (decimal item : SumOfWalletStep6.get(seq)) {
				sumWal += item;
			}

			system.debug('>>> sumEx  = ' + seq + ' >>>  ' + sumEx);
			system.debug('>>> sumWal = ' + seq + ' >>>  ' + sumWal);
			if (sumWal == 0) return ret;
			ret = (sumEx / sumWal) * 100;
			return ret;
		}


		//Getter Method
		public Map<decimal, decimal> getMapAspirationSOWStep6 {
			get
			{
				if (MapAspirationSOWStep6.size() == 0) {
					for (decimal seq : mapTableLabel.keySet()) {
						system.debug('::: getMapAspirationSOWStep6 ' + seq);
						decimal ret = getAspirationSOWStep6(seq);
						MapAspirationSOWStep6.put(seq, ret);
					}
				}
				return MapAspirationSOWStep6;
			}
		}




















		/**********************************************************
		 *   Aspiration %SOW  (Group) Fomular
		 *   =  (expected incremental of all company in group + adjusted ni of all company in group)/ Group Wallet 
		 *   New : update with ii BA on 2015-11-27 
		 **********************************************************/
		Map<decimal /*seq*/, decimal> MapAspirationSOW = new Map<decimal, decimal> ();

		public decimal getAspirationSOW(decimal seq) {
			decimal ret = 0;
			decimal gei = getGroupExpectedIncrementalNI(seq) + getGroupAdjustedNI(seq);
			decimal gw = getGroupWallet(seq);
			if (gw == 0) return ret;
			ret = (gei / gw);
			return ret;
		}
		public Map<decimal, decimal> getMapAspirationSOW {
			get
			{
				if (MapAspirationSOW.size() == 0) {
					for (decimal seq : mapTableLabel.keySet()) {
						decimal ret = getAspirationSOW(seq);
						MapAspirationSOW.put(seq, ret);
					}
				}
				return MapAspirationSOW;
			}
		}
		/**********************************************************
		 *   Support Step 5
		 *   Compare % Aspiration SOW and % Expected SOW
		 *   =  % Expected SOW (Group) - % Aspiration SOW (Group)
		 **********************************************************/
		Map<decimal /*seq*/, decimal> MapCompareExpectedToAspirationSOW = new Map<decimal, decimal> ();
		public Map<decimal, decimal> getMapCompareExpectedToAspirationSOW {
			get
			{
				if (MapCompareExpectedToAspirationSOW.size() == 0) {
					for (decimal seq : mapTableLabel.keySet()) {



						decimal ret = getMapExpectedSOW.get(seq) - getMapAspirationSOWStep6.get(seq);
						MapCompareExpectedToAspirationSOW.put(seq, ret);
					}
				}
				return MapCompareExpectedToAspirationSOW;
			}
		}
		/************************************************************
		 *              TOTOAL GroupWalletSizing
		 *************************************************************/
		public decimal GrandGroupWalletsizing {
			get {
				decimal ret = 0;

				for (decimal v : getMapGroupWalletSizing.keySet()) {

					if (v == 1.00 || v == 2.00 || v == 3.00)
					{
						// Get Only 1,2,3
						ret = ret + getMapGroupWalletSizing.get(v);
					}
				}
				return ret;
			}
		}

		/************************************************************
		 *              TOTOAL GroupActualNiRolling
		 *************************************************************/
		public decimal GrandGroupActualNiRolling {
			get {
				decimal ret = 0;

				for (decimal v : getMapGroupActualNiRolling.keySet()) {

					if (v == 1.00 || v == 2.00 || v == 3.00)
					{
						// Get Only 1,2,3
						ret = ret + getMapGroupActualNiRolling.get(v);
					}
				}
				return ret;
			}
		}

		/************************************************************
		 *              TOTOAL GroupAdjustedNI
		 *************************************************************/
		public decimal GrandGroupAdjustedNI {
			get {
				decimal ret = 0;

				for (decimal v : geMapGroupAdjustedNI.keySet()) {

					if (v == 1.00 || v == 2.00 || v == 3.00)
					{
						ret = ret + geMapGroupAdjustedNI.get(v);
					}
				}
				return ret;
			}
		}




		/************************************************************
		 *              TOTOAL ExpectedIncrementalNI
		 *************************************************************/
		public decimal GrandGroupExpectedIncrementalNI {
			get {
				decimal ret = 0;
				for (decimal v : getMapGroupExpectedIncrementalNI.keySet()) {

					if (v != 3.00 && v != 4.00 && v != 10.0)
					{

						system.debug(':::: GrandGroupExpectedIncrementalNI seq => ' + v + '   Value => ' + getMapGroupExpectedIncrementalNI.get(v));
						ret = ret + getMapGroupExpectedIncrementalNI.get(v);
						system.debug(':::: GrandGroupExpectedIncrementalNI  Total  Value => ' + ret);


					}
				}
				return ret;
			}
		}

		/************************************************************
		 *              TOTOAL ExpectedIncrementalNIStep5
		 *************************************************************/
		public decimal GrandGroupExpectedIncrementalNIStep5 {
			get {
				decimal ret = 0;
				for (decimal v : getMapGroupExpectedIncrementalNIStep5.keySet()) {

					if (v != 3.00 && v != 4.00 && v != 10.0)
					{

						system.debug(':::: GrandGroupExpectedIncrementalNIStep5 seq => ' + v + '   Value => ' + getMapGroupExpectedIncrementalNIStep5.get(v));
						ret = ret + getMapGroupExpectedIncrementalNIStep5.get(v);
						system.debug(':::: GrandGroupExpectedIncrementalNIStep5  Total  Value => ' + ret);


					}
				}
				return ret;
			}
		}

		/************************************************************
		 *              TOTOAL Total Group NI
		 *************************************************************/
		public decimal GrandTotalGroupNI {
			get {
				return getMapGroupTotalCompanyNI.get(1.00) + getMapGroupTotalCompanyNI.get(2.00) + getMapGroupTotalCompanyNI.get(3.00);
			}
		}



		/************************************************************
		 *              TOTOAL FOR EACH COMPANY
		 *************************************************************/
		Map<Id /*account id */, decimal> MapGrandGroupWalletSizingEachCompany = new Map<id, decimal> ();
		public Map<Id, decimal> getMapGrandGroupWalletSizingEachCompany {
			get
			{

				if (MapGrandGroupWalletSizingEachCompany.size() == 0) {
					for (Id accId : mapCompanyName.keySet()) {
						decimal ret = 0;
						for (decimal seq : GroupWalletSizing.get(accId).keySet()) {

							if (seq == 1.00 || seq == 2.00 || seq == 3.00)
							{
								ret = ret + GroupWalletSizing.get(accId).get(seq);
							}
						}
						MapGrandGroupWalletSizingEachCompany.put(accId, ret);
					}
				}
				return MapGrandGroupWalletSizingEachCompany;
			}
		}
	}


	public class AccountPlanProductStrategyServiceException extends Exception {
	}
}