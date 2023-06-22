public class SmartBDM_NewMiniCSV {

    private Datetime startTime;
    private String companyDetailRequestLabel;
    private String companyListRequestLabel;
    private SmartBDMEnliteCompany smartBDMEnlite;
    private SmartBDMEnliteCompanyDetail.EnliteDataRequest enliteDataRequest;
    public SmartBDMEnliteCompanyDetail.EnliteDataResponse result {get; set;}
    public Boolean refreshClickHereFlag {get { if(refreshClickHereFlag == null) refreshClickHereFlag = false; return refreshClickHereFlag; } set;}
    public String deeplinkToKony {get {return Smart_BDM_Constant.DEEP_LINK_TO_KONY_LANDING;}}

    public class CompanyInfo {
		public SmartBDMEnliteCompanyDetail.CompanyProfile companyProfile {get; set;}
        public Account account {get {if(account == null) account = new Account(); return account;} set;}
		// public IndustryMaster__c industryMaster {get; set;}
		// public Boolean isJuristicType {
		// 	get {
		// 		if(isJuristicType == null) 
		// 			isJuristicType = true; 
		// 		return isJuristicType;
		// 		} 
		// 	set;
		// }
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

    public String AccountName {get; set;}
    public String ResgiterID {get; set;}
    public String fiscalYear {get; set;}
    public String retURL {get; set;}
    public CompanyInfo companyInfo {get {if(companyInfo == null) companyInfo = new CompanyInfo(); return companyInfo;} set;}
    
    public SmartBDM_NewMiniCSV() {
        
        this.ResgiterID = ApexPages.currentPage().getParameters().get('Id');
        this.AccountName = ApexPages.currentPage().getParameters().get('AccountName');
		this.retURL = ApexPages.currentPage().getParameters().get('retURL');	
		// this.refType = ApexPages.currentPage().getParameters().get('refType');
        
    }

    public Object calloutGetCompanyListService() {
		smartBDMEnlite = new SmartBDMEnliteCompany();
        SmartBDMEnliteCompany.Request request = new SmartBDMEnliteCompany.Request();
        request.ToKenKey = SmartBDM_Utility.tokenKeyEnliteRequestBody;
        request.RequiredTable = 'COMPANY_PROFILE, FINANCIAL_CURRENT';
        request.ResultFields = 'REGISTRATION_ID, NAME_EN, NAME_TH, FS_YEAR';
        request.CriteriaField0 = 'REGISTRATION_ID';
        request.CriteriaOperator0 = 'contains';
        request.CriteriaValues0 = this.ResgiterID;
        request.CriteriaAndOr0 = 'Or';
        request.CriteriaField1 = 'NAME_EN';
        request.CriteriaOperator1 = 'contains';
        request.CriteriaValues1 = this.ResgiterID;
        request.CriteriaAndOr1 = 'Or';
        request.CriteriaField2 = 'NAME_TH';
        request.CriteriaOperator2 = 'contains';
        request.CriteriaValues2 = this.ResgiterID;
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
				SmartBDM_Utility.orgPartCreateOnlineServiceLog('CreateGateWayToken', 'CompanyListNewMiniCSV', new OnlineServiceLog(companyWrapper.isSuccess, companyWrapper.errorMessage, smartBDMEnlite.companyRequest.parseJson(), '', startTime, endTime));
			} else {
				// Success with POST request
				if( res.getStatusCode() == 200 ) {
					companyWrapper.companyList = smartBDMEnlite.convertToResponseObject(res.getBody());
					companyWrapper.isSuccess = smartBDMEnlite.companyResponse.GetExcuteSearchResponse != null && companyWrapper.companyList.parseList().size() <= Smart_BDM_Constant.LIMIT_OFFSET_RECORD ? true: false;
					companyWrapper.errorMessage = companyWrapper.companyList.parseList().size() > Smart_BDM_Constant.LIMIT_OFFSET_RECORD ? System.Label.Error_message_searching_input : System.Label.Error_message_not_found_information;
					this.fiscalYear = companyWrapper.companyList.parseMap().containsKey(this.ResgiterID) && companyWrapper.companyList.parseMap().get(this.ResgiterID).FS_YEAR != null ? companyWrapper.companyList.parseMap().get(this.ResgiterID).FS_YEAR : null;
					SmartBDM_Utility.orgPartCreateOnlineServiceLog('CreateGateWayToken', 'CompanyListNewMiniCSV', new OnlineServiceLog(companyWrapper.isSuccess, companyWrapper.isSuccess ? '': (smartBDMEnlite.companyResponse.status == null ? 'Maximum limit exceeded rows exceed returned' : smartBDMEnlite.companyResponse.status.description), smartBDMEnlite.companyRequest.parseJson(), res.getBody(), startTime, endTime));
				}
				else if(res.getStatusCode() >= 2000 && res.getStatusCode() <= 2004) { // time out
					companyWrapper.isSuccess = false;
					companyWrapper.errorMessage = System.Label.Timeout_message;
                    this.refreshClickHereFlag = true;
					SmartBDM_Utility.orgPartCreateOnlineServiceLog('CreateGateWayToken', 'CompanyListNewMiniCSV', new OnlineServiceLog(companyWrapper.isSuccess, Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), smartBDMEnlite.companyRequest.parseJson(), res.getBody(), startTime, endTime));
				}
				else {
					companyWrapper.isSuccess = false;
					companyWrapper.errorMessage = System.Label.Other_Error;
					SmartBDMEnliteCompany.CompanyResponse response = (SmartBDMEnliteCompany.CompanyResponse)JSON.deserialize(res.getBody(), SmartBDMEnliteCompany.CompanyResponse.class);
					SmartBDM_Utility.orgPartCreateOnlineServiceLog('CreateGateWayToken', 'CompanyListNewMiniCSV', new OnlineServiceLog(companyWrapper.isSuccess, response.status.description, smartBDMEnlite.companyRequest.parseJson(), res.getBody(), startTime, endTime));
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
			SmartBDM_Utility.orgPartCreateOnlineServiceLog('CreateGateWayToken', 'CompanyListNewMiniCSV', new OnlineServiceLog(companyWrapper.isSuccess, errorMessage, smartBDMEnlite.companyRequest.parseJson(), res != null ? res.getBody() : '', startTime, endTime));
		}

        SmartBDMEnliteCompanyDetail.Request request = new SmartBDMEnliteCompanyDetail.Request();
        request.ToKenKey = SmartBDM_Utility.tokenKeyEnliteRequestBody;
        request.RegistrationID = this.ResgiterID;
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
            OnlineServiceLog onlineServiceLogCompanyListNewMiniCSV = SmartBDM_Utility.onlineServiceLog('CreateGateWayToken', 'CompanyListNewMiniCSV');
            RTL_CampaignUtil.saveToOnlineLog(onlineServiceLogCompanyListNewMiniCSV.isSuccess, '', onlineServiceLogCompanyListNewMiniCSV.errorMesssage, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, 'SmartBDM_NewMiniCSV_EnliteData' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_LIST, onlineServiceLogCompanyListNewMiniCSV.requestBody, onlineServiceLogCompanyListNewMiniCSV.responseBody, null /* Account */, onlineServiceLogCompanyListNewMiniCSV.startTime, onlineServiceLogCompanyListNewMiniCSV.endTime);
        
            if(res == null) {                
                this.companyInfo.isSuccess = false;
                this.companyInfo.errorMessage = 'Null response.';
                RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, this.companyInfo.errorMessage, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/,'SmartBDM_NewMiniCSV_EnliteData' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_DETAIL, enliteDataRequest.parseJson(), '', null /* Account Object*/, startTime, endTime);
            } else {
                // Success with POST request
                if( res.getStatusCode() == 200 ) {
                    this.result = companyDetail.convertToResponseObject(res.getBody());
                    this.companyInfo.companyProfile = this.result.GetExcuteSearchResponse.CompanyProfile;
                    this.companyInfo.account = this.result.GetExcuteSearchResponse.CompanyProfile.parseToAccount();
                    this.companyInfo.netWorth = this.result.GetExcuteSearchResponse.getNetWorth();
                    this.companyInfo.totalRevenue = this.result.GetExcuteSearchResponse.getTotalRevenue();
                    this.companyInfo.shareHolders = this.result.GetExcuteSearchResponse.ShareHolder.shareHoldersReachedFiftyOnePercent();
                    this.companyInfo.isSuccess = this.result.GetExcuteSearchResponse.CompanyProfile != null ? true : false;
                    this.companyInfo.errorMessage = System.Label.Other_Error;
                    RTL_CampaignUtil.saveToOnlineLog(this.companyInfo.isSuccess, ''/*Account Name*/, this.companyInfo.isSuccess ? null: this.result.status.description, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, 'SmartBDM_NewMiniCSV_EnliteData' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_DETAIL, enliteDataRequest.parseJson(), res.getBody(), null /* Account Object*/, startTime, endTime);
                }
                else if(res.getStatusCode() >= 2000 && res.getStatusCode() <= 2004) { // time out
                    this.companyInfo.isSuccess = false;
                    this.companyInfo.errorMessage = System.Label.Timeout_message;
                    this.refreshClickHereFlag = true;
                    RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, Smart_BDM_Constant.STATUS_CODE_CONTINUATION.get(res.getStatusCode()), ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, 'SmartBDM_NewMiniCSV_EnliteData' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_DETAIL, enliteDataRequest.parseJson(), res.getBody(), null /* Account Object*/, startTime, endTime);
                }
                else {
                    SmartBDMEnliteCompanyDetail.EnliteDataResponse responseDetail = companyDetail.convertToResponseObject(res.getBody());
					SmartBDMEnliteCompanyDetail.EnliteDataResponse responseList = companyDetail.convertToResponseObject(onlineServiceLogCompanyListNewMiniCSV.responseBody);
					this.result = responseList;
                    this.companyInfo.isSuccess = false;
                    this.companyInfo.errorMessage = System.Label.Other_Error;
                    if((responseList.status != null && (responseList.status.code == 10006 || responseList.status.code == 10007)) ||
					(responseDetail.status != null && (responseDetail.status.code == 10006 || responseDetail.status.code == 10007))) {
                        this.refreshClickHereFlag = true;
                        SmartBDM_Utility.orgPartClearValue('CreateGateWayToken', 'SmartBDMEnliteToken');
                    }
                    RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, responseDetail.status.description, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, 'SmartBDM_NewMiniCSV_EnliteData' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_DETAIL, enliteDataRequest.parseJson(), res.getBody(), null /* Account Object*/, startTime, endTime);
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
            RTL_CampaignUtil.saveToOnlineLog(false, ''/*Account Name*/, errorMessage, ''/*mule id*/, UserInfo.getName(), ''/*tmbCustomerID*/, 'SmartBDM_NewMiniCSV_EnliteData' + Smart_BDM_Constant.SMARTBDM_ENLITE_COMPANY_DETAIL, enliteDataRequest.parseJson(), res.getBody(), null /* Account Object*/, startTime, endTime);
        }
        return null;
    }

}