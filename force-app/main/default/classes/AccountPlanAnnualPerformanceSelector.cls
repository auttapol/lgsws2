public without sharing class AccountPlanAnnualPerformanceSelector {
	public static string sqlAnnualPerformanceLast12MonthByIdAndDate() {
		return 'SELECT Id,MonthYear__c, Account__c,AS_FEE__c,AVG_CASA__c,AVG_LOAN_OUT__c, ' +
		'BA_FEE__c,CREDIT_FEE__c,DERIVATIVES_FEE__c,DIRECT_CM_FEE__c,EDC_FEE__c, ' +
		'END_CASA__c,ENG_LOAN_OUT__c,External_Key__c,Fee__c,FLEET_FEE__c,FRONT_END_FEE__c,FX_FEE__c,FX_VOLUME__c,' +
		'IB_FEE__c,LG_FEE__c,Month__c,Name,NIIc__c,NIId__c,OTHER_CM_FEE__c,OTHER_FEE__c,TF_FEE__c,TF_VOLUME__c, ' +
		'TMB_CUST_ID__c,Transaction_Date__c,Year__c FROM AcctAnnualPerformance__c ';
	}
	public static string sqlSummaryAnnualPerformanceLast12MonthByIdsAndDate() {
		return 'SELECT   '
		+ '      Account__c AccountId,'
		+ '      SUM(AS_FEE__c) AS_FEE,SUM(AVG_CASA__c) AVG_CASA,SUM(AVG_LOAN_OUT__c) AVG_LOAN_OUT, SUM(BA_FEE__c) BA_FEE ,SUM(CREDIT_FEE__c) CREDIT_FEE,'
		+ '      SUM(DERIVATIVES_FEE__c) DERIVATIVES_FEE ,SUM(DIRECT_CM_FEE__c) DIRECT_CM_FEE,SUM(EDC_FEE__c) EDC_FEE, SUM(END_CASA__c) END_CASA,'
		+ '      SUM(ENG_LOAN_OUT__c) ENG_LOAN_OUT ,SUM(Fee__c) Fee,SUM(FLEET_FEE__c) FLEET_FEE,SUM(FRONT_END_FEE__c) FRONT_END_FEE ,SUM(FX_FEE__c) FX_FEE,'
		+ '      SUM(FX_VOLUME__c) FX_VOLUME,SUM(IB_FEE__c) IB_FEE ,SUM(LG_FEE__c) LG_FEE,SUM(NIIc__c) NIIc ,SUM(NIId__c) NIId,SUM(OTHER_CM_FEE__c) OTHER_CM_FEE,'
		+ '      SUM(OTHER_FEE__c) OTHER_FEE,SUM(TF_FEE__c) TF_FEE,SUM(TF_VOLUME__c) TF_VOLUME'
		+ ' FROM  '
		+ '      AcctAnnualPerformance__c '
		+ ' Where '
		+ '      Account__c in :accountIdsInGroup '
		+ '       and  MonthYear__c in  :monthyears ' // ในช่วงที่กำหนด
		+ ' Group By Account__c ';
	}

	public static string sqlGetLastCustomerUnderstandarding() {
		return 'SELECT Id,MonthYear__c, Account__c,AS_FEE__c,AVG_CASA__c,AVG_LOAN_OUT__c,  '
		+ '	BA_FEE__c,CREDIT_FEE__c,DERIVATIVES_FEE__c,DIRECT_CM_FEE__c,EDC_FEE__c,  '
		+ '	END_CASA__c,ENG_LOAN_OUT__c,External_Key__c,Fee__c,FLEET_FEE__c,FRONT_END_FEE__c,FX_FEE__c,FX_VOLUME__c, '
		+ '	IB_FEE__c,LG_FEE__c,Month__c,Name,NIIc__c,NIId__c,OTHER_CM_FEE__c,OTHER_FEE__c,TF_FEE__c,TF_VOLUME__c,  '
		+ '	TMB_CUST_ID__c,Transaction_Date__c,Year__c FROM AcctAnnualPerformance__c '
		+ '	where account__c = :accountId '
		+ '	Order by Transaction_Date__c desc Limit 2 ';
	}

	public static string sqlGetLastCustomerUnderstandardingByAccountIds() {
		return 'SELECT Id,MonthYear__c, Account__c,AS_FEE__c,AVG_CASA__c,AVG_LOAN_OUT__c,  '
		+ '	BA_FEE__c,CREDIT_FEE__c,DERIVATIVES_FEE__c,DIRECT_CM_FEE__c,EDC_FEE__c,  '
		+ '	END_CASA__c,ENG_LOAN_OUT__c,External_Key__c,Fee__c,FLEET_FEE__c,FRONT_END_FEE__c,FX_FEE__c,FX_VOLUME__c, '
		+ '	IB_FEE__c,LG_FEE__c,Month__c,Name,NIIc__c,NIId__c,OTHER_CM_FEE__c,OTHER_FEE__c,TF_FEE__c,TF_VOLUME__c,  '
		+ '	TMB_CUST_ID__c,Transaction_Date__c,Year__c FROM AcctAnnualPerformance__c '
		+ '	where account__c IN :accountIds   and ( Transaction_Date__c = LAST_YEAR  or Transaction_Date__c = THIS_YEAR )'
		+ '	Order by Transaction_Date__c desc  ';




	}

	public static List<AcctAnnualPerformance__c> LastCustomerUnderstandardingByAccountIds(Set<id> accountIds) {
		String sql = '';
		if (accountIds == null)
		throw new AccountPlanAnnualPerformanceSelectorException('accountIds  Cannot be null');

		sql = sqlGetLastCustomerUnderstandardingByAccountIds();
		system.debug('::: sql' + sql);
		return(List<AcctAnnualPerformance__c>) Database.query(sql);
	}


	public static List<AcctAnnualPerformance__c> LastCustomerUnderstandarding(Id accountId) {

		String sql = '';
		if (accountId == null)
		throw new AccountPlanAnnualPerformanceSelectorException('accountIds  Cannot be null');

		sql = sqlGetLastCustomerUnderstandarding();
		system.debug('::: sql' + sql);
		return(List<AcctAnnualPerformance__c>) Database.query(sql);

	}

	//region calucateMonthInQuery
	public static List<String> calucateMonthInQuery(Datetime currentDate) {

		if (currentDate==null)
		{
		    throw new AccountPlanAnnualPerformanceSelectorException('currentDate   Cannot be null');
		}

		Integer month = 1;
		// วันที่ refresh น้อยกว่า 24  จะต้อง m-2
		if (currentDate.day() < 24) {
			currentDate = currentDate.addMonths(- 2);
			month = currentDate.month();
		}
		else {

			currentDate = currentDate.addMonths(- 1);
			month = currentDate.month();
		}
		Integer year = currentDate.year();
		if (UserInfo.getLocale() == 'th_TH') {
			year = year - 543;
		}
		system.debug('::: Date Formate >> ' + currentDate);
		if (currentDate == null)
		throw new AccountPlanAnnualPerformanceSelectorException('currentDate   Cannot be null');
		integer monthScoop = 12;
		system.debug('::: UserInfo   ' + UserInfo.getLocale());
		system.debug('::: Year >> ' + year);
		system.debug('::: Month >> ' + month);
		integer i =1;
		// last 12 Months
		List<string> monthyears = new List<string> ();
		if (month == 1) {
		    monthyears.add('M' + month + 'Y' + year);

			i=2;
			month = 12;
			year = year - 1;
			for (; i <= monthScoop; i++) {
				monthyears.add('M' + month + 'Y' + year);
				month = month - 1;
			}
		}
		else {
			// month = month -1;
			for (; i <= monthScoop; i++) {
				monthyears.add('M' + month + 'Y' + year);
				month = month - 1;
				if (month == 0)
				{
					month = 12;
					year = year - 1;
				}
			}
		}

		system.debug('::: YearMonth String >> ' + monthyears);

		return monthyears;
	}
	//endregion

	public static List<AcctAnnualPerformance__c> selectAnnualPerformanceLast12MonthByIdAndDate(Set<ID> accountIds, Datetime currentDate) {
		String sql = '';
		if (accountIds == null || accountIds.size() < 1)
		throw new AccountPlanAnnualPerformanceSelectorException('Set of Id  Cannot be null');
		if (currentDate == null)
		throw new AccountPlanAnnualPerformanceSelectorException('currentDate   Cannot be null');
		List<String> monthyears = calucateMonthInQuery(currentDate);
		system.debug(':::: selectAnnualPerformanceLast12MonthByIdAndDate >> ' + monthyears);
		sql = sqlAnnualPerformanceLast12MonthByIdAndDate() + ' Where  Account__c in :accountIds and  MonthYear__c in : monthyears Order by Account__c, Transaction_Date__c';
		system.debug('::: sql' + sql);
		return(List<AcctAnnualPerformance__c>) Database.query(sql);
	}

	public static List<AcctAnnualPerformance__c> selectAnnualPerformanceRolling12MonthByAccountIds(Set<ID> accountIds, Datetime currentDate) {

		String sql = '';
		if (accountIds == null || accountIds.size() < 1)
		throw new AccountPlanAnnualPerformanceSelectorException('Set of Id  Cannot be null');
		if (currentDate == null)
		throw new AccountPlanAnnualPerformanceSelectorException('currentDate   Cannot be null');
		List<String> monthyears = calucateMonthInQuery(currentDate);
		sql = sqlAnnualPerformanceLast12MonthByIdAndDate() + ' Where  Account__c in :accountIds and  MonthYear__c in : monthyears Order by Account__c, Transaction_Date__c desc';
		system.debug('::: sql' + sql);

		return(List<AcctAnnualPerformance__c>) Database.query(sql);
	}

	public static List<AccountPlanAnnualPerformanceInfo> selectAnnualPerformanceLast12MonthByIdAndDateInGroup(Set<ID> accountIdsInGroup, Datetime currentDate) {
		String sql = '';
		if (accountIdsInGroup == null || accountIdsInGroup.size() < 1)
		throw new AccountPlanAnnualPerformanceSelectorException('Set of Id  Cannot be null');
		if (currentDate == null)
		throw new AccountPlanAnnualPerformanceSelectorException('currentDate   Cannot be null');
		List<AccountPlanAnnualPerformanceInfo> accAnnualPerformanceInGroups = new List<AccountPlanAnnualPerformanceInfo> ();
		List<String> monthyears = calucateMonthInQuery(currentDate);

		sql = sqlSummaryAnnualPerformanceLast12MonthByIdsAndDate();

		AggregateResult[] results = Database.query(sql);
		if (results != null && results.size() > 0) {
			for (AggregateResult ar : results) {
				AccountPlanAnnualPerformanceInfo annualInfo = new AccountPlanAnnualPerformanceInfo();
				annualInfo.AccouontId = (String) ar.get('AccountId');
				annualInfo.AS_FEE = (ar.get('AS_FEE') == null || ar.get('AS_FEE') == '') ? 0 : (Decimal) ar.get('AS_FEE');
				annualInfo.AVG_CASA = (ar.get('AVG_CASA') == null || ar.get('AVG_CASA') == '') ? 0 : (Decimal) ar.get('AVG_CASA');
				annualInfo.AVG_LOAN_OUT = (ar.get('AVG_LOAN_OUT') == null || ar.get('AVG_LOAN_OUT') == '') ? 0 : (Decimal) ar.get('AVG_LOAN_OUT');
				annualInfo.BA_FEE = (ar.get('BA_FEE') == null || ar.get('BA_FEE') == '') ? 0 : (Decimal) ar.get('BA_FEE');
				annualInfo.CREDIT_FEE = (ar.get('CREDIT_FEE') == null || ar.get('CREDIT_FEE') == '') ? 0 : (Decimal) ar.get('CREDIT_FEE');
				annualInfo.DERIVATIVES_FEE = (ar.get('DERIVATIVES_FEE') == null || ar.get('DERIVATIVES_FEE') == '') ? 0 : (Decimal) ar.get('DERIVATIVES_FEE');
				annualInfo.DIRECT_CM_FEE = (ar.get('DIRECT_CM_FEE') == null || ar.get('DIRECT_CM_FEE') == '') ? 0 : (Decimal) ar.get('DIRECT_CM_FEE');
				annualInfo.EDC_FEE = (ar.get('EDC_FEE') == null || ar.get('EDC_FEE') == '') ? 0 : (Decimal) ar.get('EDC_FEE');
				annualInfo.END_CASA = (ar.get('END_CASA') == null || ar.get('END_CASA') == '') ? 0 : (Decimal) ar.get('END_CASA');
				annualInfo.ENG_LOAN_OUT = (ar.get('ENG_LOAN_OUT') == null || ar.get('ENG_LOAN_OUT') == '') ? 0 : (Decimal) ar.get('ENG_LOAN_OUT');
				annualInfo.Fee = (ar.get('Fee') == null || ar.get('Fee') == '') ? 0 : (Decimal) ar.get('Fee');
				annualInfo.FLEET_FEE = (ar.get('FLEET_FEE') == null || ar.get('FLEET_FEE') == '') ? 0 : (Decimal) ar.get('FLEET_FEE');
				annualInfo.FRONT_END_FEE = (ar.get('FRONT_END_FEE') == null || ar.get('FRONT_END_FEE') == '') ? 0 : (Decimal) ar.get('FRONT_END_FEE');
				annualInfo.FX_FEE = (ar.get('FX_FEE') == null || ar.get('FX_FEE') == '') ? 0 : (Decimal) ar.get('FX_FEE');
				annualInfo.FX_VOLUME = (ar.get('FX_VOLUME') == null || ar.get('FX_VOLUME') == '') ? 0 : (Decimal) ar.get('FX_VOLUME');
				annualInfo.IB_FEE = (ar.get('IB_FEE') == null || ar.get('IB_FEE') == '') ? 0 : (Decimal) ar.get('IB_FEE');
				annualInfo.LG_FEE = (ar.get('LG_FEE') == null || ar.get('LG_FEE') == '') ? 0 : (Decimal) ar.get('LG_FEE');
				annualInfo.NIIc = (ar.get('NIIc') == null || ar.get('NIIc') == '') ? 0 : (Decimal) ar.get('NIIc');
				annualInfo.NIId = (ar.get('NIId') == null || ar.get('NIId') == '') ? 0 : (Decimal) ar.get('NIId');
				annualInfo.OTHER_CM_FEE = (ar.get('OTHER_CM_FEE') == null || ar.get('OTHER_CM_FEE') == '') ? 0 : (Decimal) ar.get('OTHER_CM_FEE');
				annualInfo.OTHER_FEE = (ar.get('OTHER_FEE') == null || ar.get('OTHER_FEE') == '') ? 0 : (Decimal) ar.get('OTHER_FEE');
				annualInfo.TF_FEE = (ar.get('TF_FEE') == null || ar.get('TF_FEE') == '') ? 0 : (Decimal) ar.get('TF_FEE');
				annualInfo.TF_VOLUME = (ar.get('TF_VOLUME') == null || ar.get('TF_VOLUME') == '') ? 0 : (Decimal) ar.get('TF_VOLUME');
				accAnnualPerformanceInGroups.add(annualInfo);
			}
		}
		return accAnnualPerformanceInGroups;
	}

	public static Map<Id /*Account Id*/, AccountPlanAnnualPerformanceInfo> selectAnnualPerformanceLast12MonthByIdAndDateInGroupMap(Set<ID> accountIdsInGroup, Datetime currentDate) {
		String sql = '';
		if (accountIdsInGroup == null || accountIdsInGroup.size() < 1)
		throw new AccountPlanAnnualPerformanceSelectorException('Set of Id  Cannot be null');
		if (currentDate == null)
		throw new AccountPlanAnnualPerformanceSelectorException('currentDate   Cannot be null');
		Map<Id /*Account Id*/, AccountPlanAnnualPerformanceInfo> accAnnualPerformanceInGroups = new Map<Id /*Account Id*/, AccountPlanAnnualPerformanceInfo> ();
		List<String> monthyears = calucateMonthInQuery(currentDate);

		sql = sqlSummaryAnnualPerformanceLast12MonthByIdsAndDate();

		AggregateResult[] results = Database.query(sql);
		if (results != null && results.size() > 0) {
			for (AggregateResult ar : results) {
				AccountPlanAnnualPerformanceInfo annualInfo = new AccountPlanAnnualPerformanceInfo();
				annualInfo.AccouontId = (String) ar.get('AccountId');
				annualInfo.AS_FEE = (ar.get('AS_FEE') == null || ar.get('AS_FEE') == '') ? 0 : (Decimal) ar.get('AS_FEE');
				annualInfo.AVG_CASA = (ar.get('AVG_CASA') == null || ar.get('AVG_CASA') == '') ? 0 : (Decimal) ar.get('AVG_CASA');
				annualInfo.AVG_LOAN_OUT = (ar.get('AVG_LOAN_OUT') == null || ar.get('AVG_LOAN_OUT') == '') ? 0 : (Decimal) ar.get('AVG_LOAN_OUT');
				annualInfo.BA_FEE = (ar.get('BA_FEE') == null || ar.get('BA_FEE') == '') ? 0 : (Decimal) ar.get('BA_FEE');
				annualInfo.CREDIT_FEE = (ar.get('CREDIT_FEE') == null || ar.get('CREDIT_FEE') == '') ? 0 : (Decimal) ar.get('CREDIT_FEE');
				annualInfo.DERIVATIVES_FEE = (ar.get('DERIVATIVES_FEE') == null || ar.get('DERIVATIVES_FEE') == '') ? 0 : (Decimal) ar.get('DERIVATIVES_FEE');
				annualInfo.DIRECT_CM_FEE = (ar.get('DIRECT_CM_FEE') == null || ar.get('DIRECT_CM_FEE') == '') ? 0 : (Decimal) ar.get('DIRECT_CM_FEE');
				annualInfo.EDC_FEE = (ar.get('EDC_FEE') == null || ar.get('EDC_FEE') == '') ? 0 : (Decimal) ar.get('EDC_FEE');
				annualInfo.END_CASA = (ar.get('END_CASA') == null || ar.get('END_CASA') == '') ? 0 : (Decimal) ar.get('END_CASA');
				annualInfo.ENG_LOAN_OUT = (ar.get('ENG_LOAN_OUT') == null || ar.get('ENG_LOAN_OUT') == '') ? 0 : (Decimal) ar.get('ENG_LOAN_OUT');
				annualInfo.Fee = (ar.get('Fee') == null || ar.get('Fee') == '') ? 0 : (Decimal) ar.get('Fee');
				annualInfo.FLEET_FEE = (ar.get('FLEET_FEE') == null || ar.get('FLEET_FEE') == '') ? 0 : (Decimal) ar.get('FLEET_FEE');
				annualInfo.FRONT_END_FEE = (ar.get('FRONT_END_FEE') == null || ar.get('FRONT_END_FEE') == '') ? 0 : (Decimal) ar.get('FRONT_END_FEE');
				annualInfo.FX_FEE = (ar.get('FX_FEE') == null || ar.get('FX_FEE') == '') ? 0 : (Decimal) ar.get('FX_FEE');
				annualInfo.FX_VOLUME = (ar.get('FX_VOLUME') == null || ar.get('FX_VOLUME') == '') ? 0 : (Decimal) ar.get('FX_VOLUME');
				annualInfo.IB_FEE = (ar.get('IB_FEE') == null || ar.get('IB_FEE') == '') ? 0 : (Decimal) ar.get('IB_FEE');
				annualInfo.LG_FEE = (ar.get('LG_FEE') == null || ar.get('LG_FEE') == '') ? 0 : (Decimal) ar.get('LG_FEE');
				annualInfo.NIIc = (ar.get('NIIc') == null || ar.get('NIIc') == '') ? 0 : (Decimal) ar.get('NIIc');
				annualInfo.NIId = (ar.get('NIId') == null || ar.get('NIId') == '') ? 0 : (Decimal) ar.get('NIId');
				annualInfo.OTHER_CM_FEE = (ar.get('OTHER_CM_FEE') == null || ar.get('OTHER_CM_FEE') == '') ? 0 : (Decimal) ar.get('OTHER_CM_FEE');
				annualInfo.OTHER_FEE = (ar.get('OTHER_FEE') == null || ar.get('OTHER_FEE') == '') ? 0 : (Decimal) ar.get('OTHER_FEE');
				annualInfo.TF_FEE = (ar.get('TF_FEE') == null || ar.get('TF_FEE') == '') ? 0 : (Decimal) ar.get('TF_FEE');
				annualInfo.TF_VOLUME = (ar.get('TF_VOLUME') == null || ar.get('TF_VOLUME') == '') ? 0 : (Decimal) ar.get('TF_VOLUME');
				system.debug('::: Account Plan annual info >> ' + annualInfo);
				accAnnualPerformanceInGroups.put(annualInfo.AccouontId, annualInfo);
			}
		}
		system.debug('::: END selectAnnualPerformanceLast12MonthByIdAndDateInGroupMap :::');

		return accAnnualPerformanceInGroups;
	}







	public class AccountPlanAnnualPerformanceInfo {
		public String AccouontId { get; set; }
		public decimal AS_FEE { get; set; }
		public decimal AVG_CASA { get; set; }
		public decimal AVG_LOAN_OUT { get; set; }
		public decimal BA_FEE { get; set; }
		public decimal CREDIT_FEE { get; set; }
		public decimal DERIVATIVES_FEE { get; set; }
		public decimal DIRECT_CM_FEE { get; set; }
		public decimal EDC_FEE { get; set; }
		public decimal END_CASA { get; set; }
		public decimal ENG_LOAN_OUT { get; set; }
		public decimal Fee { get; set; }
		public decimal FLEET_FEE { get; set; }
		public decimal FRONT_END_FEE { get; set; }
		public decimal FX_FEE { get; set; }
		public decimal FX_VOLUME { get; set; }
		public decimal IB_FEE { get; set; }
		public decimal LG_FEE { get; set; }
		public decimal NIIc { get; set; }
		public decimal NIId { get; set; }
		public decimal OTHER_CM_FEE { get; set; }
		public decimal OTHER_FEE { get; set; }
		public decimal TF_FEE { get; set; }
		public decimal TF_VOLUME { get; set; }

	}

	public class AccountPlanAnnualPerformanceSelectorException extends Exception {
	}
}