public class MiniCSV_Controller {
	public static final String ISHAVING = 'มี';
	public static final String ISNOTHAVING = 'ไม่มี';

    public String RED_COLOR = Smart_BDM_Constant.RED_COLOR;
    public String GREEN_COLOR = Smart_BDM_Constant.GREEN_COLOR;
	public String WHITE_COLOR = Smart_BDM_Constant.WHITE_COLOR;
    public String MAX_TOTAL_REVENUS = Smart_BDM_Constant.MAX_TOTAL_REVENUS;
	public String SUCCESS_MESSAGE= Smart_BDM_Constant.SUCCESS_MESSAGE;

	public Id id { get; set; }
	public String fiscalYear { get; set; }
	public String retURL { get; set; }
	public String refType { get; set; }
	public String navTitle { get; set; }
	public String successMsg { get; set; }
	public Account account {
		get {
			if(account == null){
				account = getAccount();
			}
			return account;
		}
		set;
	}
    
    public class colorCodeStatus {
        public string creditInfo {
			get {
				if (creditInfo == null) creditInfo = 'green';
				return creditInfo;
			}
			set;
		}
		public string riskInfo {
			get {
				if (riskInfo == null) riskInfo = 'red';
				return riskInfo;
			}
			set;
		}
		public string businessInfo {
			get {
				if (businessInfo == null) businessInfo = 'red';
				return businessInfo;
			}
			set;
		}
		public string summaryInfo {
			get {
				if (summaryInfo == null) summaryInfo = 'red';
				return summaryInfo;
			}
			set;
		}
    }
    // public class WarningMessage{
    //      public string brlWarning { 
    //         get { if(brlWarning == null)brlWarning = '';
    //                 return brlWarning;
    //             }
    //         set; }
    //      public string csiWarning { 
    //         get { if(csiWarning == null)csiWarning = '';
    //                 return csiWarning;
    //             }
    //         set; }
    // }
    public List<String> warningMsg {
        	get{
                if(warningMsg == null){
                    warningMsg = new List<String>();
			}
				return warningMsg;
			}
        	set;}
    
	public Contact contact { 
		get {
			if(contact == null){
				contact = getContact();
			}
			return contact;
		}	
		set;
	}
	public String FullNameContactInfo { 
		get{
			if(FullNameContactInfo == null){
				FullNameContactInfo = getFullNameContactLead();
			}
			return FullNameContactInfo;
		}
		set;
	}
	// public Lead lead { get; set; }
	public List<Lead> leads { 
		get{
			if(leads == null){
				leads = getLeads();
			}
			return leads;
		}
		set;
	}
	public List<Collateral_Detail__c> collateral_details { 
		get{
			if(collateral_details == null){
				collateral_details = getCollateralDetails();
			}
			return collateral_details;
		}
		set;
	}
	public List<Product_Information_Detail__c> credit_infoes { 
		get{
			if(credit_infoes == null){				
				credit_infoes = getCreditInfoes();
			}
			return credit_infoes;
		}
		set;
	}
	public List<Product_Information_Detail__c> product_holding_info {
		get{
			if(product_holding_info == null){
				product_holding_info = getProductHoldingInfo();
			}
			return product_holding_info;
		}
		set;
	}
	public String Deeplink_iOS { get; set; }
    public String Deeplink_Android { get; set; }
	public String Deeplink_KnowledgeCenter { get; set; }

	public String Deeplink_DEPOSIT_ACCOUNT { get { return Smart_BDM_Constant.SMARTBDM_KM_DEEPLINK_DEPOSIT_ACCOUNT; } }
	public String Deeplink_S1B { get { return Smart_BDM_Constant.SMARTBDM_KM_DEEPLINK_S1B; } }
	public String Deeplink_BIZ_TOUCH { get { return Smart_BDM_Constant.SMARTBDM_KM_DEEPLINK_BIZ_TOUCH; } }
	public String Deeplink_BIZ_WOW { get { return Smart_BDM_Constant.SMARTBDM_KM_DEEPLINK_BIZ_WOW; } }
	public String Deeplink_BUSINESS_CLICK { get { return Smart_BDM_Constant.SMARTBDM_KM_DEEPLINK_BUSINESS_CLICK; } }
	
	public Boolean isDepositAccount { get { if(isDepositAccount == null) isDepositAccount = false; return isDepositAccount;} set; }
	public Boolean isS1B { get { if(isS1B == null) isS1B = false; return isS1B;} set; }
	public Boolean isBIZTOUCH { get { if(isBIZTOUCH == null) isBIZTOUCH = false; return isBIZTOUCH;} set; }
	public Boolean isBIZWOW { get { if(isBIZWOW == null) isBIZWOW = false; return isBIZWOW;} set; }
	// public Boolean isEDC { get { if(isEDC == null) isEDC = false; return isEDC;} set; }
    
	public String BDMLatestMTHTXN { 
		get {
			if(BDMLatestMTHTXN == null){
				BDMLatestMTHTXN = '-';
			}
			return BDMLatestMTHTXN;
		}
		set; 
	}
	public String BDMLatestSIXMTHTXN { 
		get {
			if(BDMLatestSIXMTHTXN == null){
				BDMLatestSIXMTHTXN = '-';
			}
			return BDMLatestSIXMTHTXN;
		}
		set; 
	}
	public String ActionRecommand { 
		get {
			if(ActionRecommand == null) {
				// Start Smart BDM II
				// CheckingProductHoldingInfo();
				// System.debug('isDepositAccount: ' + isDepositAccount + '| isS1B: ' + isS1B + '| isBIZTOUCH: ' + isBIZTOUCH + '| BDMLatestSIXMTHTXN: ' + BDMLatestSIXMTHTXN);
				ActionRecommand = AccountUtility.CalculateRecommendedAction(isDepositAccount, isS1B, isBIZTOUCH, BDMLatestSIXMTHTXN);
			}
			return ActionRecommand;
		}	
		set;
	}
	
	public colorCodeStatus codeList { get; set; }
    // public WarningMessage warningList { get; set; }
    
    public string brl_color;
    public string csi_color;
    public string seg_color;
    public string total_reven_color;
    public string busi_code_color;
	public string warning_code_account { 
		get{
			warning_code_account = '';
			if(account.Warning_Code__c != null){
				warning_code_account = account.Warning_Code__c.replace(',',', ');
			}	
			return warning_code_account;
		}
		set;
	}
    
    
    public String getBRLColor() {
		string  color;
		try {
            List<Smart_BDM_BRL_Code__mdt> bcList = [SELECT Color_Code__c, Warning_Message__c 
                            FROM Smart_BDM_BRL_Code__mdt 
                            WHERE BRL__c=:account.NAMBRL__c ];
            if(bcList.size() > 0){
                color = bcList[0].Color_Code__c;
                if(color == RED_COLOR){
                	warningMsg.add(bcList[0].Warning_Message__c);
                }
            }else{
                color = WHITE_COLOR;
            }
		} catch (Exception e) {
		   	System.debug('getBRLColor error : ' + e.getMessage());
            // return null;
		}
		return color;
	}
    
    public String getCSIColor() {
		string color = WHITE_COLOR;
		try {
			List<String> CSIList = new List<String>();
			if(account.Warning_Code__c != null){
				CSIList = account.Warning_Code__c.split(',');
				List<Smart_BDM_CSI_Warning__mdt> smartCSIList = [SELECT Color_Code__c,CSI_Code__c , Warning_Message__c 
																FROM Smart_BDM_CSI_Warning__mdt  
																WHERE CSI_Code__c IN:CSIList];
				Map<String, String> warningMap = new Map<String,String>();
				for(Smart_BDM_CSI_Warning__mdt csiMsg : smartCSIList)
				{
					warningMap.put(csiMsg.CSI_Code__c, csiMsg.Warning_Message__c);
				}

				if(smartCSIList.size() > 0) {
					color = RED_COLOR;
					for(String csi : CSIList){
						warningMsg.add(warningMap.get(csi));
					}
				} else {
					color = GREEN_COLOR;
				}
			}
		} catch (Exception e) {
		   	System.debug('getCSIColor error : ' + e.getMessage());
            // return null;
		}
		return color;
	}
    
    public String getSEGColor() {
		string color = WHITE_COLOR;
		try {
            List<Smart_BDM_Segment__mdt>  bdm_segment =	[
									SELECT Color_Code__c, Warning_Message__c 
									FROM Smart_BDM_Segment__mdt 
									WHERE Segment_Code__c =: account.Core_Banking_Suggested_Segment__c];
            if(bdm_segment.size() > 0) {
				color = bdm_segment.get(0).Color_Code__c;        
				warningMsg.add(bdm_segment.get(0).Warning_Message__c);    
            }
		} catch (Exception e) {
		   	System.debug('getSEGColor error : ' + e.getMessage());
		}
		return color;
	}
    
    public String getTOTALREVENColor() {
		string color = WHITE_COLOR;
		try {
			if(account.Total_Revenue_Baht__c != null && account.Total_Revenue_Baht__c >= 0){
				if(account.Total_Revenue_Baht__c > Integer.valueOf(MAX_TOTAL_REVENUS) ){
					color = RED_COLOR;
					warningMsg.add(Smart_BDM_Constant.TOTAL_REVENUS_WARNING_MESSAGE);
				}else{
					color = GREEN_COLOR;
				}
			}
		} catch (Exception e) {
		   	System.debug('getTOTALREVENColor error : ' + e.getMessage());
		}
		return color;
	}
    
    public String getBusinessCodeColor() {
		string color = WHITE_COLOR;
		try {
			if(account.Business_Type_Code__c != null && account.Business_Type_Code__c != ''){
				List<IndustryMaster__c> industMaster = [SELECT TMBCode__c, ColorCode__c
										FROM IndustryMaster__c 
										WHERE TMBCode__c = :account.Business_Type_Code__c ];
				if(industMaster.size() > 0){
					color= industMaster.get(0).ColorCode__c;
					if(color == RED_COLOR){
						warningMsg.add(Smart_BDM_Constant.BUSINESS_CODE_WARNING_MESSAGE);   
					}
				}else{
					color = WHITE_COLOR;
				}
			}
		} catch (Exception e) {
		   	System.debug('getBusinessCodeColor error : ' + e.getMessage());
		}
		return color;
	}
    
    public colorCodeStatus getRiskInfoColor(string brlCode, string csiCode, colorCodeStatus codeList) {
		codeList.riskInfo = WHITE_COLOR;
        try {
            List<Smart_BDM_Risk_Info__mdt>  riskInfoList = [SELECT BRL_Code__c, CSI_Code__c, Color_Code__c
                            FROM Smart_BDM_Risk_Info__mdt  
                            WHERE BRL_Code__c = :brlCode AND CSI_Code__c = :csiCode ];
			codeList.riskInfo = riskInfoList.size() > 0  ? riskInfoList.get(0).Color_Code__c : WHITE_COLOR;
		} catch (Exception e) {
		   	System.debug('getRiskInfoColor error : ' + e.getMessage());
            // return codeList;
		}
        return codeList;
	}
    
    public colorCodeStatus getBusinessColor(string busiCode ,string segCode,string revenueCode,colorCodeStatus codeList) {
		codeList.businessInfo = WHITE_COLOR;
        try {
            List<Smart_BDM_Business_Info_Display__mdt>  busiInfoList = [SELECT Business_Code__c, Segment_Code__c, Status_Total_Revenue__c, Color_Code__c
                            FROM Smart_BDM_Business_Info_Display__mdt   
                            WHERE Business_Code__c=:busiCode  AND Segment_Code__c=:segCode AND Status_Total_Revenue__c  =:revenueCode  ];
			codeList.businessInfo = busiInfoList.size() > 0 ? busiInfoList.get(0).Color_Code__c : WHITE_COLOR;
		} catch (Exception e) {
		   	System.debug('getBusinessColor error : ' + e.getMessage());
		}
        return codeList;
	}
    
    public colorCodeStatus getSummaryInfoColor(colorCodeStatus codeList) {
		codeList.summaryInfo = WHITE_COLOR;
        try {
			List<Smart_BDM_Summary__mdt> sumInfoList = [SELECT Business_Info_Code__c, Risk_Info_Code__c, Color_Code__c 
								FROM Smart_BDM_Summary__mdt   
								WHERE Business_Info_Code__c=:codeList.riskInfo  
								AND Risk_Info_Code__c=:codeList.businessInfo];
			codeList.summaryInfo = sumInfoList.size() > 0 ? sumInfoList.get(0).Color_Code__c : WHITE_COLOR;
		} catch (Exception e) {
		   	System.debug('getSummaryInfoColor error : ' + e.getMessage());
		}
        return codeList;
	}
    
    // public colorCodeStatus getCreditInfoColor(List<Product_Information_Detail__c> productList,colorCodeStatus codeList) {
	// 	codeList.creditInfo = GREEN_COLOR;
    //     for(Product_Information_Detail__c pid : productList ){
    //         if(pid.Ending_out_Ending_Balance__c > pid.Limit_Balance__c){
    //             codeList.creditInfo = RED_COLOR;
	// 			string msg = Smart_BDM_Constant.CREDIT_INFO_WARNING_MESSAGE;
	// 			warningMsg.add(msg);
    //             return codeList;
    //         }
    //     }
    //     return codeList;
        
	// }

	public class IncomeDetail {
		public String title {get; set;}
		public Income_Estimation__c incomeEstimation {get; set;}
		public String remark {get; set;}

		public IncomeDetail(String title, Income_Estimation__c incomeEstimation, String remark){
			this.title = title;
			this.incomeEstimation = incomeEstimation;
			this.remark = remark;
		}
	}

	public class IncomeInfo {
		// public Date currentMonth {get; set;}
		// public List<IncomeDetail> currentIncomeList {get; set;}
		// public Date previousMonth {get; set;}
		// public List<IncomeDetail> previousIncomeList {get; set;}
		public Date month {get; set;}
		public List<IncomeDetail> incomeList {get; set;}
	}
	public List<IncomeInfo> incomeInfo {
		get {
			if(incomeInfo == null){
				incomeInfo = getIncomeInfo();
			}
			return incomeInfo;
		}
		set;
	}
	public List<IncomeInfo> getIncomeInfo() {
		// SELECT  Id, AVG_Income_amount__c, Account__c, BOT_ID__c, Income_External_Key__c, Model_Type__c, Valida_date__c, as_of_date__c FROM Income_Estimation__c WHERE (as_of_date__c = LAST_N_MONTHS:2 OR as_of_date__c = LAST_MONTH) AND Account__c =: account.Id
		List<IncomeInfo> tmpIncomeInfoList = new List<IncomeInfo>();
		try {
			IncomeInfo incomeInfo = new IncomeInfo();
			List<IncomeDetail> incomeDetailList = new List<IncomeDetail>();
			String title = 'Income Estimation';
			String remark = System.Label.Remark_Income_Estimation;
			for (Income_Estimation__c income : [SELECT  Id, AVG_Income_amount__c, Account__c, BOT_ID__c, Income_External_Key__c, Model_Type__c, Valida_date__c, as_of_date__c FROM Income_Estimation__c WHERE as_of_date__c = LAST_MONTH AND Account__c =: account.Id]) {
				incomeDetailList.add(new IncomeDetail(title, income, remark));
				title = '';
				remark = '';
			}
			incomeInfo.month = incomeDetailList.iterator().hasNext() ? incomeDetailList.iterator().next().incomeEstimation.as_of_date__c : null;
			incomeInfo.incomeList = incomeDetailList;
			tmpIncomeInfoList.add(incomeInfo);

			incomeInfo = new IncomeInfo();
			incomeDetailList = new List<IncomeDetail>();
			for (Income_Estimation__c income : [SELECT  Id, AVG_Income_amount__c, Account__c, BOT_ID__c, Income_External_Key__c, Model_Type__c, Valida_date__c, as_of_date__c FROM Income_Estimation__c WHERE as_of_date__c = LAST_N_MONTHS:2 AND as_of_date__c < LAST_MONTH AND Account__c =: account.Id]) {
				incomeDetailList.add(new IncomeDetail(title, income, remark));
				title = '';
				remark = '';
			}
			incomeInfo.month = incomeDetailList.iterator().hasNext() ? incomeDetailList.iterator().next().incomeEstimation.as_of_date__c : null;
			incomeInfo.incomeList = incomeDetailList;
			tmpIncomeInfoList.add(incomeInfo);
		} catch (Exception e) {
			System.debug('System error: ' + e.getMessage());
            System.debug('There is error during processing : ' + e.getStackTraceString());
		}
		return tmpIncomeInfoList;
	}

	// public IncomeInfo incomeInfo {get {if(incomeInfo == null) incomeInfo = new IncomeInfo(); return incomeInfo;} set;}

	private Datetime startTime;
	private String companyDetailRequestLabel;
	private String companyListRequestLabel;
	private SmartBDMEnliteCompany smartBDMEnlite;
	private SmartBDMEnliteCompanyDetail.EnliteDataRequest enliteDataRequest;
    public SmartBDMEnliteCompanyDetail.EnliteDataResponse result {get; set;}
    public Boolean refreshClickHereFlag {get { if(refreshClickHereFlag == null) refreshClickHereFlag = false; return refreshClickHereFlag; } set;}
	public class CompanyInfo {
		public SmartBDMEnliteCompanyDetail.CompanyProfile companyProfile {get; set;}
		// public IndustryMaster__c industryMaster {get; set;}
		public Boolean isNotMappingISIC {
			get {
				if(isNotMappingISIC == null) 
					isNotMappingISIC = false; 
				return isNotMappingISIC;
				} 
			set;
		}
		public Boolean isJuristicType {
			get {
				if(isJuristicType == null) 
					isJuristicType = false; 
				return isJuristicType;
				} 
			set;
		}
		public Decimal netWorth {
			get {
				if(netWorth == null) 
					netWorth = 0; 
				return netWorth;
				} 
			set;
		}
		public Decimal totalRevenue {
			get {
				if(totalRevenue == null) 
					totalRevenue = 0; 
				return totalRevenue;
				} 
			set;
		}
		public List<SmartBDMEnliteCompanyDetail.ShareHolder> shareHolders {
			get {
				if(shareHolders == null) 
					shareHolders = new List<SmartBDMEnliteCompanyDetail.ShareHolder>(); 
				return shareHolders;
			} 
			set;
		}
		public Boolean isSuccess {get { if(isSuccess == null) isSuccess = true; return isSuccess;} set;}
        public String errorMessage {get; set;}
	}

	public Map<String, IndustryMaster__c> getIndustryMaster(String ISICCode)
	{
        Map<String, IndustryMaster__c> intdustryMasterMap = new Map<String, IndustryMaster__c>();
		try {
			for (IndustryMaster__c intdustryMaster : [SELECT Id, Name, APday__c, ARday__c, BusinessType__c, COGday__c, Diversification__c, HighlySelectiveIndustry__c, HighRisk__c, INVday__c, ISICCode__c, Negative__c, SubIndustry__c, ColorCode__c, Suspend__c, TMBCode__c, IncomeFactor__c, BusinessGroupCode__c, BusinessGroupNameTH__c, BusinessGroupNameEN__c FROM IndustryMaster__c WHERE ISICCode__c =: ISICCode]) {
				intdustryMasterMap.put(intdustryMaster.TMBCode__c, intdustryMaster);
			}
		} catch (Exception e) {
			System.debug('System error: ' + e.getMessage());
            System.debug('There is error during processing : ' + e.getStackTraceString());
		}
		return intdustryMasterMap;
	}

	public CompanyInfo companyInfo {get {if(companyInfo == null) companyInfo = new CompanyInfo(); return companyInfo;} set;}

	public Object calloutGetCompanyListService() {
		smartBDMEnlite = new SmartBDMEnliteCompany();
        SmartBDMEnliteCompany.Request request = new SmartBDMEnliteCompany.Request();
        request.ToKenKey = SmartBDM_Utility.tokenKeyEnliteRequestBody;
        request.RequiredTable = 'COMPANY_PROFILE, FINANCIAL_CURRENT';
        request.ResultFields = 'REGISTRATION_ID, NAME_EN, NAME_TH, FS_YEAR';
        request.CriteriaField0 = 'REGISTRATION_ID';
        request.CriteriaOperator0 = 'contains';
        request.CriteriaValues0 = account.ID_Number_PE__c;
        request.CriteriaAndOr0 = 'Or';
        request.CriteriaField1 = 'NAME_EN';
        request.CriteriaOperator1 = 'contains';
        request.CriteriaValues1 = account.ID_Number_PE__c;
        request.CriteriaAndOr1 = 'Or';
        request.CriteriaField2 = 'NAME_TH';
        request.CriteriaOperator2 = 'contains';
        request.CriteriaValues2 = account.ID_Number_PE__c;
        smartBDMEnlite.companyRequest.GetExcuteSearchRequest = request;
		this.refreshClickHereFlag = false;

		startTime = Datetime.now();
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('callout:Smart_BDM_Enlite_Get_Company_List');
        req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Service-Name', 'enlite-getCompanies');
        req.setHeader('Request-UID', Smart_BDM_Constant.SMARTBDM_ENLITE_UID_COMPANYLIST);
        req.setHeader('Request-App-ID', Smart_BDM_Constant.SMARTBDM_ENLITE_APPID_COMPANYLIST);
        req.setHeader('Request-Datetime', String.valueOfGmt(Datetime.now()));
        req.setBody(smartBDMEnlite.companyRequest.parseJson());
        req.setTimeout(Smart_BDM_Constant.CUSTOMER_LIST_TIMEOUT);

        // Create a Continuation for the HTTPRequest        
        Continuation con = new Continuation(Smart_BDM_Constant.CUSTOMER_LIST_TIMEOUT/1000 != 0 ? Smart_BDM_Constant.CUSTOMER_LIST_TIMEOUT/1000 : 1);
        // con.state = new SmartBDMEnliteWrapper(con.addHttpRequest(req), companyList);

        con.continuationMethod = 'calloutGetCompanyDetailService';
        // Return it to the system for processing
		this.companyListRequestLabel = con.addHttpRequest(req);
        return con;
	}
    
	public Object calloutGetCompanyDetailService() {
		HttpResponse res = Continuation.getResponse(this.companyListRequestLabel);
		Datetime endTime = DateTime.now();
		SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper companyWrapper = new SmartBDM_EnliteSearchCompanyCtrl.CompanyWrapper();
		try {
			if(res == null) {
				companyWrapper.isSuccess = false;
				companyWrapper.errorMessage = 'Null response.';
				SmartBDM_Utility.orgPartCreateOnlineServiceLog('CreateGateWayToken', 'CompanyListMiniCSV', new OnlineServiceLog(companyWrapper.isSuccess, companyWrapper.errorMessage, smartBDMEnlite.companyRequest.parseJson(), '', startTime, endTime));
			} else {
				// Success with POST request
				if( res.getStatusCode() == 200 ) {
					companyWrapper.companyList = smartBDMEnlite.convertToResponseObject(res.getBody());
					companyWrapper.isSuccess = smartBDMEnlite.companyResponse.GetExcuteSearchResponse != null && companyWrapper.companyList.parseList().size() <= Smart_BDM_Constant.LIMIT_OFFSET_RECORD ? true: false;
					companyWrapper.errorMessage = companyWrapper.companyList.parseList().size() > Smart_BDM_Constant.LIMIT_OFFSET_RECORD ? System.Label.Error_message_searching_input : System.Label.Error_message_not_found_information;
					this.fiscalYear = companyWrapper.companyList.parseMap().containsKey(account.ID_Number_PE__c) && companyWrapper.companyList.parseMap().get(account.ID_Number_PE__c).FS_YEAR != null ? companyWrapper.companyList.parseMap().get(account.ID_Number_PE__c).FS_YEAR : null;
					SmartBDM_Utility.orgPartCreateOnlineServiceLog('CreateGateWayToken', 'CompanyListMiniCSV', new OnlineServiceLog(companyWrapper.isSuccess, companyWrapper.isSuccess ? '': (smartBDMEnlite.companyResponse.status == null ? 'Maximum limit exceeded rows exceed returned' : smartBDMEnlite.companyResponse.status.description), smartBDMEnlite.companyRequest.parseJson(), res.getBody(), startTime, endTime));
				}
				else if(res.getStatusCode() >= 2000 && res.getStatusCode() <= 2004) { // time out
					companyWrapper.isSuccess = false;
					companyWrapper.errorMessage = System.Label.Timeout_message;
					this.refreshClickHereFlag = true;
					SmartBDM_Utility.orgPartCreateOnlineServiceLog('CreateGateWayToken', 'CompanyListMiniCSV', new OnlineServiceLog(companyWrapper.isSuccess, Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), smartBDMEnlite.companyRequest.parseJson(), res.getBody(), startTime, endTime));
				}
				else {
					companyWrapper.isSuccess = false;
					companyWrapper.errorMessage = System.Label.Other_Error;
					SmartBDMEnliteCompany.CompanyResponse response = (SmartBDMEnliteCompany.CompanyResponse)JSON.deserialize(res.getBody(), SmartBDMEnliteCompany.CompanyResponse.class);
					SmartBDM_Utility.orgPartCreateOnlineServiceLog('CreateGateWayToken', 'CompanyListMiniCSV', new OnlineServiceLog(companyWrapper.isSuccess, response.status.description, smartBDMEnlite.companyRequest.parseJson(), res.getBody(), startTime, endTime));
				}
			}
		} catch (Exception e) {
			System.debug('System error: ' + e.getMessage());
			System.debug('There is error during processing : ' + e.getStackTraceString());
			String errorMessage = '';
			errorMessage += 'System error: ' + e.getMessage() + '\n';
			errorMessage += 'There is error during processing : ' + e.getStackTraceString();
			
			companyWrapper.isSuccess = false;
			companyWrapper.errorMessage = System.Label.Other_Error;
			SmartBDM_Utility.orgPartCreateOnlineServiceLog('CreateGateWayToken', 'CompanyListMiniCSV', new OnlineServiceLog(companyWrapper.isSuccess, errorMessage, smartBDMEnlite.companyRequest.parseJson(), res != null ? res.getBody() : '', startTime, endTime));
		}

		// if(this.account.Customer_Type__c != 'Juristic') return null;
        SmartBDMEnliteCompanyDetail.Request request = new SmartBDMEnliteCompanyDetail.Request();
        request.ToKenKey = SmartBDM_Utility.tokenKeyEnliteRequestBody;
        request.RegistrationID = account.ID_Number_PE__c;
        request.CompanyName = '?';
        request.FiscalYear = this.fiscalYear;
        request.Language = Smart_BDM_Constant.SMARTBDM_ENLITE_LANGUAGE_SEARCHING;
        request.TagRequired = 'company profile';

        enliteDataRequest = new SmartBDMEnliteCompanyDetail.EnliteDataRequest();
        enliteDataRequest.GetEnliteDataRequest = request;

        startTime = Datetime.now();
        // Create callout request
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Service-Name', 'enlite-getCompanyDetail');
        req.setHeader('Request-UID', Smart_BDM_Constant.SMARTBDM_ENLITE_UID_COMPANYDETAIL);
        req.setHeader('Request-App-ID', Smart_BDM_Constant.SMARTBDM_ENLITE_APPID_COMPANYDETAIL);
        req.setHeader('Request-Datetime', String.valueOfGmt(Datetime.now()));
        req.setEndpoint('callout:Smart_BDM_Enlite_Get_Company_Detail');
        req.setBody(enliteDataRequest.parseJson());
        req.setTimeout(Smart_BDM_Constant.CUSTOMER_DETAIL_TIMEOUT);

       	// Create a Continuation for the HTTPRequest        
        Continuation  con = new Continuation(Smart_BDM_Constant.CUSTOMER_DETAIL_TIMEOUT/1000 != 0 ? Smart_BDM_Constant.CUSTOMER_DETAIL_TIMEOUT/1000 : 1);
        // con.state = con.addHttpRequest(req);
        con.continuationMethod = 'callbackGetCompanyDetailService';
        
        this.companyDetailRequestLabel = con.addHttpRequest(req);
        // Return it to the system for processing
        return con;
    }

    public Object callbackGetCompanyDetailService() {
        HttpResponse res = Continuation.getResponse(this.companyDetailRequestLabel);
        Datetime endTime = DateTime.now();
        // System.debug(res);
        // System.debug(res.getBody());
        // System.debug(res.getStatusCode());

		SmartBDMEnliteCompanyDetail companyDetail = new SmartBDMEnliteCompanyDetail();
        try {
			// Gateway failed case, DML after callout service
			OnlineServiceLog onlineServiceLogTokenGW = SmartBDM_Utility.onlineServiceLog('CreateGateWayToken', 'SmartBDMEnliteonlineServiceLogGateWay');
			if(onlineServiceLogTokenGW != null && !onlineServiceLogTokenGW.isSuccess)
				RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, onlineServiceLogTokenGW.errorMesssage, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, Smart_BDM_Constant.SMARTBDM_CALCULATE_TOOLS_CREATE_JWT_TOKEN, onlineServiceLogTokenGW.requestBody, onlineServiceLogTokenGW.responseBody, null /* Account Object*/, onlineServiceLogTokenGW.startTime, onlineServiceLogTokenGW.endTime);

			// Enlite Token failed case, DML after callout service
			OnlineServiceLog onlineServiceLogTokenEnlite = SmartBDM_Utility.onlineServiceLog('CreateGateWayToken', 'onlineServiceLogEnliteToken');
			if(onlineServiceLogTokenEnlite != null && !onlineServiceLogTokenEnlite.isSuccess)
				RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, onlineServiceLogTokenEnlite.errorMesssage, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, Smart_BDM_Constant.SMARTBDM_ENLITE_TOKEN, onlineServiceLogTokenEnlite.requestBody, onlineServiceLogTokenEnlite.responseBody, null /* Account Object*/, onlineServiceLogTokenEnlite.startTime, onlineServiceLogTokenEnlite.endTime);
			
			// Get Company detail case, DML after callout service
			OnlineServiceLog onlineServiceLogCompanyListMiniCSV = SmartBDM_Utility.onlineServiceLog('CreateGateWayToken', 'CompanyListMiniCSV');
			RTL_CampaignUtil.saveToOnlineLog(onlineServiceLogCompanyListMiniCSV.isSuccess, account.Name, onlineServiceLogCompanyListMiniCSV.errorMesssage, ''/*mule id*/, UserInfo.getName(), account.TMB_Customer_ID_PE__c, 'Mini_CSV' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_LIST, onlineServiceLogCompanyListMiniCSV.requestBody, onlineServiceLogCompanyListMiniCSV.responseBody, account, onlineServiceLogCompanyListMiniCSV.startTime, onlineServiceLogCompanyListMiniCSV.endTime);
			
            if(res == null) {
                this.companyInfo.isSuccess = false;
                this.companyInfo.errorMessage = 'Null response.';
                RTL_CampaignUtil.saveToOnlineLog(false, account.Name, this.companyInfo.errorMessage, ''/*mule id*/, UserInfo.getName(), account.TMB_Customer_ID_PE__c,'Mini_CSV' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_DETAIL, enliteDataRequest.parseJson(), '', account, startTime, endTime);
            } else {
                // Success with POST request
                if( res.getStatusCode() == 200 ) {
                    this.result = companyDetail.convertToResponseObject(res.getBody());
					this.companyInfo.isJuristicType = this.account.Customer_Type__c == 'Juristic' ? true : false;
					this.companyInfo.companyProfile = this.result.GetExcuteSearchResponse.CompanyProfile;
					// this.companyInfo.industryMaster = this.getIndustryMaster(this.result.GetExcuteSearchResponse.CompanyProfile.isicCode).get(this.account.Business_Type_Code__c);
					this.companyInfo.isNotMappingISIC = !this.getIndustryMaster(this.result.GetExcuteSearchResponse.CompanyProfile.isicCode).containsKey(this.account.Business_Type_Code__c);
                    this.companyInfo.netWorth = this.result.GetExcuteSearchResponse.getNetWorth();
                    this.companyInfo.totalRevenue = this.result.GetExcuteSearchResponse.getTotalRevenue();
                    this.companyInfo.shareHolders = this.result.GetExcuteSearchResponse.ShareHolder.shareHoldersReachedFiftyOnePercent();
					this.companyInfo.isSuccess = this.companyInfo.companyProfile != null ? true : false;
                    this.companyInfo.errorMessage = System.Label.Other_Error;
                    RTL_CampaignUtil.saveToOnlineLog(this.companyInfo.isSuccess, account.Name, this.companyInfo.isSuccess ? null: this.result.status.description, ''/*mule id*/, UserInfo.getName(), account.TMB_Customer_ID_PE__c, 'Mini_CSV' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_DETAIL, enliteDataRequest.parseJson(), res.getBody(), account, startTime, endTime);
                }
                else if(res.getStatusCode() >= 2000 && res.getStatusCode() <= 2004) { // time out
                    this.companyInfo.isSuccess = false;
                    this.companyInfo.errorMessage = System.Label.Timeout_message;
					this.refreshClickHereFlag = true;
                    RTL_CampaignUtil.saveToOnlineLog(false, account.Name, Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), ''/*mule id*/, UserInfo.getName(), account.TMB_Customer_ID_PE__c, 'Mini_CSV' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_DETAIL, enliteDataRequest.parseJson(), res.getBody(), account, startTime, endTime);
                }
                else {
					SmartBDMEnliteCompanyDetail.EnliteDataResponse responseDetail = companyDetail.convertToResponseObject(res.getBody());
					SmartBDMEnliteCompanyDetail.EnliteDataResponse responseList = companyDetail.convertToResponseObject(onlineServiceLogCompanyListMiniCSV.responseBody);
					this.result = responseList;
                    this.companyInfo.isSuccess = false;
                    this.companyInfo.errorMessage = System.Label.Other_Error;
					if((responseList.status != null && (responseList.status.code == 10006 || responseList.status.code == 10007)) ||
					(responseDetail.status != null && (responseDetail.status.code == 10006 || responseDetail.status.code == 10007))) {
						this.refreshClickHereFlag = true;
						SmartBDM_Utility.orgPartClearValue('CreateGateWayToken', 'SmartBDMEnliteToken');
					}
                    RTL_CampaignUtil.saveToOnlineLog(false, account.Name, responseDetail.status.description, ''/*mule id*/, UserInfo.getName(), account.TMB_Customer_ID_PE__c, 'Mini_CSV' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_DETAIL, enliteDataRequest.parseJson(), res.getBody(), account, startTime, endTime);
                }
            }
        } catch (Exception e) {
            System.debug('System error: ' + e.getMessage());
            System.debug('There is error during processing : ' + e.getStackTraceString());
            String errorMessage = '';
            errorMessage += 'System error: ' + e.getMessage() + '\n';
            errorMessage += 'There is error during processing : ' + e.getStackTraceString();
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errorMessage));

            this.companyInfo.isSuccess = false;
            this.companyInfo.errorMessage = System.Label.Other_Error;
            RTL_CampaignUtil.saveToOnlineLog(false, account.Name, errorMessage, ''/*mule id*/, UserInfo.getName(), account.TMB_Customer_ID_PE__c, 'Mini_CSV' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_DETAIL, enliteDataRequest.parseJson(), res.getBody(), account, startTime, endTime);
        }
        return null;
    }

	public MiniCSV_Controller() {
		this.Id = ApexPages.currentPage().getParameters().get('id');
		this.retURL = ApexPages.currentPage().getParameters().get('retURL');
		this.refType = ApexPages.currentPage().getParameters().get('refType');

		successMsg =  SUCCESS_MESSAGE;
		
		if( navTitle == null){
			if(refType == 'Accountlist'){
				this.navTitle = Label.My_Customers;
			}
			else if(refType == 'Leadlist'){
				this.navTitle = Label.My_Leads;
			}
		}
		
		Smart_BDM_Setting__mdt settings = [SELECT Id, Number_of_Records__c, Deep_link_iOS__c, Deep_link_Android__c, Deep_link_Knowledge_Center__c, Deep_link_Product_Details__c
				FROM Smart_BDM_Setting__mdt 
				WHERE DeveloperName = 'Smart_BDM_Setting'];
		this.Deeplink_iOS = settings.Deep_link_iOS__c;
		this.Deeplink_Android = settings.Deep_link_Android__c;
		this.Deeplink_KnowledgeCenter = settings.Deep_link_Android__c;

		// account = getAccount();
		// warning_code_account = '';
		// if(account.Warning_Code__c != null){
		// 	warning_code_account = account.Warning_Code__c.replace(',',', ');
		// }		
		// leads = getLeads();
		// contact = getContact();
		// FullNameContactInfo = getFullNameContactLead();
		// credit_infoes = getCreditInfoes();
		// collateral_details = getCollateralDetails();
		// product_holding_info = getProductHoldingInfo();
        
		
		// Start Smart BDM II
		 CheckingProductHoldingInfo();
		// // System.debug('isDepositAccount: ' + isDepositAccount + '| isS1B: ' + isS1B + '| isBIZTOUCH: ' + isBIZTOUCH + '| BDMLatestSIXMTHTXN: ' + BDMLatestSIXMTHTXN);
		// ActionRecommand = AccountUtility.CalculateRecommendedAction(isDepositAccount, isS1B, isBIZTOUCH, BDMLatestSIXMTHTXN);

        
        //Traffic Light       
        codeList = new colorCodeStatus();
        // warningList = new WarningMessage();
        brl_color = getBRLColor();
        csi_color = getCSIColor();
        seg_color = getSEGColor();
        total_reven_color = getTOTALREVENColor() ;
        busi_code_color = getBusinessCodeColor() ;
        codeList = getRiskInfoColor(brl_color, csi_color, codeList);
        codeList = getBusinessColor(busi_code_color, seg_color, total_reven_color, codeList);
        // codeList = getCreditInfoColor(credit_infoes,codeList);
        codeList = getSummaryInfoColor(codeList);
	}

	public Account getAccount(){
		try{
			Account acct = [SELECT Id, Name, Customer_Type__c, TMB_Customer_ID_PE__c, ID_Number_PE__c, NAMBRL__c, Warning_Code__c,
					CSI_Waring_Message__c, Core_Banking_Suggested_Segment__c, Total_Revenue_Baht__c,
					Business_Type_Code__c, Business_Type_Description__c, RTL_Registered_Address__c,
					Registered_Address_Line_1_PE__c, Registered_Address_Line_2_PE__c, Registered_Address_Line_3_PE__c,
					Province_Registered_PE__c, Zip_Code_Registered_PE__c,
					Mobile_Number_PE__c, RTL_Office_Phone_Number__c, Phone,
					BIZ_Touch__c, BIZ_Wow__c,
					SALE_PER_YEAR_UW__c, START_DATE__c, Business_CLICK_TEXT__c
					FROM Account 
					WHERE Id =: Id
					LIMIT 1];
			return acct;
		}catch(Exception e){
			System.debug('getAccount error: ' + e.getMessage());
			return null;
		}
	}

	public String getFullNameContactLead() {
		String fullName;
		try {
			fullName = contact != null ? contact.Name : (leads.size() > 0 ? leads.get(0).Name : null );
			// if(contact != null) { fullName = contact.Name; }
			// else if(leads.size() > 0) { fullName = leads.get(0).Name; }
		} catch (Exception e) {
		   	System.debug('getFullNameContactLead error : ' + e.getMessage());
		}
		return fullName;
	}

	public Contact getContact(){
		try{
			Contact tmpContact = [SELECT Id, Name 
						FROM Contact 
						WHERE AccountId =: account.Id 
						AND RecordType.Name IN ('Core Bank', 'Salesforce')
						ORDER BY LastModifiedDate DESC
						LIMIT 1];
			return tmpContact;
		}catch(Exception e){
			System.debug('getContact error: ' + e.getMessage());
			return null;
		}
	}
	
	public List<Lead> getLeads(){
		try{
			List<Lead> tmp_leads = [SELECT Id, Name, Primary_Campaign__c, CreatedDate, Remark__c,
						Primary_Campaign__r.Name, Account__c
						FROM Lead 
						WHERE Account__c  =: account.Id AND Account__c != null
						ORDER BY LastModifiedDate DESC
						];
			return tmp_leads;
		}catch(Exception e){
			System.debug('getLeads error: ' + e.getMessage());
			return new List<Lead>();
		}
	}

	public List<Product_Information_Detail__c> getCreditInfoes(){
		try{
			List<Product_Information_Detail__c> tmp_creditInfoes = [SELECT Id, Name, Product_Information__r.Product_Hierachy_Code__r.Name, 
						Product_Hierachy_Code__c, Product_Description__c, TMB_Account_ID__c,
						Limit_Balance__c, Ending_out_Ending_Balance__c, Rate__c
						FROM Product_Information_Detail__c 
						WHERE Customer__c =: account.Id and Product_Domain__c = 'Funding & Borrowing'
						];
			return tmp_creditInfoes;
		}catch(Exception e){
			System.debug('getCreditInfoes error: ' + e.getMessage());
			return new List<Product_Information_Detail__c>();
		}
	}

	public List<Product_Information_Detail__c> getDepositInfoes(){
		try{
			List<Product_Information_Detail__c> tmp_creditInfoes = [SELECT Id, Account_Name__c,TMB_Account_ID__c, TMB_Suffix__c, Product_Performance_Name__c, Ending_out_Ending_Balance__c, Rate__c
					FROM Product_Information_Detail__c 
					WHERE Customer__c =: account.Id and Product_Domain__c = 'Deposit & Investment'
					];
			return tmp_creditInfoes;
		}catch(Exception e){
			System.debug('getDepositInfoes error: ' + e.getMessage());
			return new List<Product_Information_Detail__c>();
		}
	}

	public List<Collateral_Detail__c> getCollateralDetails(){
		try{
			list<string> collateralID = new list<string>();
			list<Collateral__c> listCollateral = new list<Collateral__c>();
			list<Collateral_Detail__c> listCollateralDetail = new list<Collateral_Detail__c>();

			list<Collateral_Detail__c> tmp_listColDtl = new list<Collateral_Detail__c>();

			for (Collateral__c co : [SELECT Id, Account__c, Appraisal_Value__c, Pledge_Value__c, Collateral_Group_Type__c
									FROM Collateral__c WHERE Account__c =: account.id])
			{
				collateralID.add(co.id);
				listCollateral.add(co);
			}
			
			for (Collateral_Detail__c cod : [SELECT Id, Collateral_Type__c, Collateral_Owner__c, 
											Appraisal_Date__c, Appraisal_Value__c, Pledge_Value__c,
											Collateral_Joint_BOT__c, Collateral__c
											FROM Collateral_Detail__c WHERE Collateral__c in: collateralID])
			{
				listCollateralDetail.add(cod);
			}

			for (Collateral__c co : listCollateral)
			{
				
				for (Collateral_Detail__c cod : listCollateralDetail)
				{
					if (cod.Collateral__c == co.Id)
					{
						tmp_listColDtl.add(cod);
					}
				}
				
			}
			return tmp_listColDtl;
		}catch(Exception e){
			System.debug('getCollateralDetails error: ' + e.getMessage());
			return new List<Collateral_Detail__c>();
		}
	}

	public List<Product_Information_Detail__c> getProductHoldingInfo(){
		try{
			List<Product_Information_Detail__c> tmp_Product_Info = [SELECT Id, Deposit_Account__c, S1B__c, BDM_Latest_SIXMTH_TXN__c, BDM_Latest_MTH_TXN__c
				FROM Product_Information_Detail__c 
				WHERE Customer__c =: account.Id and Product_Domain__c = 'Deposit & Investment'
				];
			return tmp_Product_Info;
		}catch(Exception e){
			System.debug('getCollateralDetails error: ' + e.getMessage());
			return new List<Product_Information_Detail__c>();
		}
	}

	public void CheckingProductHoldingInfo(){
		Map<String, List<Product_Information_Detail__c>> mapSIXMonthTXN = new Map<String, List<Product_Information_Detail__c>>{
			'Low' => new List<Product_Information_Detail__c>(),
			'Medium' => new List<Product_Information_Detail__c>(),
			'High' => new List<Product_Information_Detail__c>()
		};

		Map<String, List<Product_Information_Detail__c>> mapLASTMonthTXN = new Map<String, List<Product_Information_Detail__c>>{
			'Low' => new List<Product_Information_Detail__c>(),
			'Medium' => new List<Product_Information_Detail__c>(),
			'High' => new List<Product_Information_Detail__c>()
		};

		for(Product_Information_Detail__c p : product_holding_info)
		{
			if(p.Deposit_Account__c == ISHAVING) isDepositAccount = true;
			if(p.S1B__c == ISHAVING) isS1B = true;
			mapSIXMonthTXN.get(p.BDM_Latest_SIXMTH_TXN__c).add(p);
			mapLASTMonthTXN.get(p.BDM_Latest_MTH_TXN__c).add(p);
		}
		
		if(account != null && account.BIZ_Touch__c == ISHAVING) isBIZTOUCH = true;
		if(account != null && account.BIZ_Wow__c == ISHAVING) isBIZWOW = true;
		if(isDepositAccount == true || isS1B == true)
        {
            BDMLatestMTHTXN = mapLASTMonthTXN.get('High').size() > 0 ? 'High' : (mapLASTMonthTXN.get('Medium').size() > 0 ? 'Medium': 'Low');
			BDMLatestSIXMTHTXN = mapSIXMonthTXN.get('High').size() > 0 ? 'High' : (mapSIXMonthTXN.get('Medium').size() > 0 ? 'Medium': 'Low');
        }           
	}

	/* check if the VF page is display by SF1 */
    public Boolean isSF1 {
        get {                   
            if(String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
                String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
                ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
                (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
            ) {
                return true;
            }else{
                return false;
            }
        }
    }
}