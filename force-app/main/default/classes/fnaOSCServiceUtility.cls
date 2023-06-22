global without sharing class fnaOSCServiceUtility {

    // Declare inner class to hold state info
    public class StateInfo {
        public String accountIdModel { get; set; }
        public String fnaActivityIdModel { get; set; }
        public String requestBodyModel  { get; set; }
        public DateTime startTimeModel  { get; set; }
        public StateInfo(String fnaActId, String accId, String reqBody, Datetime getStartTime) {
            this.accountIdModel = accId;
            this.requestBodyModel = reqBody;
            this.fnaActivityIdModel = fnaActId;
            this.startTimeModel = getStartTime;
        }
    }
    private static final Integer timeout {
        get {
            // 120000 ms
            if(timeout == null){
                List<App_Config__mdt> productHoldingTimeOut = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'ProductHolding_TIMEOUT_INT_SECS'];
                timeout = productHoldingTimeOut != null && productHoldingTimeOut.size() > 0 ? Integer.valueOf(productHoldingTimeOut.get(0).Value__c) * 1000 : 120000;
            }
            return timeout;
        }
        set;
    }

    private static final String SessionId {
        get {
            if(SessionId == null) {
                SessionId = fetchUserSessionId();
            }
            return SessionId;
        }
        set;
    }

    private static final String OSC001_NAME = [SELECT Endpoint FROM NamedCredential where DeveloperName = 'OSC01'][0].Endpoint;
    private static final String OSC005_NAME = [SELECT Endpoint FROM NamedCredential where DeveloperName = 'OSC05_List'][0].Endpoint;

	private String userName;/* current user FirstName + LastName */
	public String tmbCustomerID {get; set;}
    public String accountId {get; set;}
    public String fnaActivityId {get; set;}

    public String requestBody;
    public String requestLabel;
    public String responseBody;
    public String pageMessage {get;set;}
    public String errorCodeText {get;set;}
    private DateTime startTime;
    private DateTime endTime;
    public AppConfig__c mc;
    public AppConfig__c appId;
    public Account accObj {get; set;}

    private final String OSC014_NAME = 'customerProductDepositAndLoan';
    private final String OSC016_NAME = 'customerProductBancassurance';

    public Integer TIMEOUT_INT_SECS {
        get{
            Integer DEFAULT_TIMEOUT = 60;
            if (TIMEOUT_INT_SECS == null) {
                try {
                    TIMEOUT_INT_SECS = DEFAULT_TIMEOUT;
                    List<App_Config__mdt> customerProductListsTimeOut = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'CustomerProductLists_TIMEOUT_INT_SECS'];
                    if (customerProductListsTimeOut != null && customerProductListsTimeOut.size() > 0) {
                        TIMEOUT_INT_SECS = Integer.valueOf(customerProductListsTimeOut.get(0).Value__c);
                    }

                } catch ( Exception e ) {
                    TIMEOUT_INT_SECS = DEFAULT_TIMEOUT;
                }
            }
            return TIMEOUT_INT_SECS;

        } set;
    }


    public List<CaseProductNumberService.CaseProductWrapper> caseProductDepositAndLoanAll {get;set;}
    public List<CaseProductNumberService.CaseProductWrapper> caseProductBancassurance {
        get{
            if (caseProductBancassurance == null) {
                List<CaseProductNumberService.CaseProductWrapper> returnList = new List<CaseProductNumberService.CaseProductWrapper>();
                return returnList;
            }
            return caseProductBancassurance;
        } set;
    }
    public List<CaseProductNumberService.CaseProductWrapper> caseProductBancassuranceAll {get;set;}

    public CaseAccountProduct productAccounts {
        get{
            if ( productAccounts == null ) {
                productAccounts = new CaseAccountProduct();
            }
            return productAccounts;
        }
        set;
    }

    public CaseBAProduct productBAs {
        get{
            if ( productBAs == null ) {
                productBAs = new CaseBAProduct();
            }
            return productBAs;
        }
        set;
    }

	public fnaOSCServiceUtility(String customerId, String fnaActId) {
        fnaActivityId = fnaActId;

        System.debug('accountId Before : ' + accountId);

        if(accountId == null){
            accountId = customerId;
        }

        getCustomerSegmentAndTMBCusId(accountId);

        if(tmbCustomerID == null ){
        	pageMessage = Label.Case_Tmb_Cus_Error;
        }

        userName = UserInfo.getName();
		
        System.debug('init OSC Service Utility Origi');
	}

	public void getCustomerSegmentAndTMBCusId(String accId) {
        try {

            accObj = [SELECT Name,Segment_crm__c, TMB_Customer_ID_PE__c,Core_Banking_Suggested_Segment__c
                              FROM Account
                              where id = : accId limit 1];
            system.debug('Customer Segement : ' + accObj);

            //get tmb cus id
            if (accObj != null && accObj.TMB_Customer_ID_PE__c != null) {
            	tmbCustomerID = (tmbCustomerID!=null)?null: accObj.TMB_Customer_ID_PE__c;
            }
            system.debug('tmbCustomerID' + tmbCustomerID);

        } catch (Exception e) {
            system.debug('get customer segment on case : ' + e);
        }

    }

    //============= Start WsOSC14 Deposit/Loan======================//
    public Object startCallCaseProductDeposit() {

        String endpoint;
        String appIDName;
        String request_dt = Datetime.now().format('yyyy-MM-dd');
        startTime = DateTime.now();

        // Create continuation with a timeout
        Continuation con = new Continuation(TIMEOUT_INT_SECS);
        // Set callback method
        con.continuationMethod = 'processResponseWsOSC14';

        CaseAccountProduct.Request reqObj = new CaseAccountProduct.Request();

        if (tmbCustomerID != null && tmbCustomerID != '') {
            string tmbcusright = tmbCustomerID.substring(tmbCustomerID.length() - 14);
            CaseAccountProduct.Queries query = new CaseAccountProduct.Queries();
            query.customerId = tmbcusright;
            reqObj.query = query;
        }

        requestBody = reqObj.parseObjToJson(reqObj);

        // con.state = accountId;

        con.state = new StateInfo(fnaActivityId,accountId,requestBody,startTime);

        system.debug('OSC14| customerId ' + accountId);

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        // Set Request Header
        req.setHeader('Service-Name','customers-accounts-inq');
        req.setHeader('Request-uid',NumberHelper.generateUID());
        system.debug('OSC14| generateUID : ' + NumberHelper.generateUID());

        appId = AppConfig__c.getValues('WsOSC14_Request_App_Id');
        appIDName = (appId == null)? 'A0291':appId.Value__c;//default app id

        req.setHeader('Request-App-Id',appIDName);
        system.debug('OSC14| appIDName : ' + appIDName);

        req.setHeader('Request-datetime', request_dt);
        system.debug('OSC14| request_dt : ' + request_dt);

        //req.setHeader('Acronym','7350T61D');
        req.setHeader('Content-Type','application/json');

        mc = AppConfig__c.getValues('WsOSC14');
        endpoint = mc == null ? 'https://tmbcrmservices.tmbbank.com' : mc.Value__c;//default enf point value
        req.setEndpoint(endpoint);//app config end point
        system.debug('OSC14| endpoint ' + endpoint);

        req.setBody(requestBody);
        system.debug('OSC14| requestBody ' + requestBody);

        requestLabel = con.addHttpRequest(req);
        // con.addHttpRequest(req);
        // System.debug(requestLabel);
        system.debug('OSC14| request : ' + req);

        system.debug('OSC14| con ' + con);
        return con;
    }
    // @AuraEnabled
    public Object processResponseWsOSC14(List<String> labels, Object state) {
        System.debug('OSC14| state : ' + state);
        if(state != null){
            StateInfo stateRequestBody = (StateInfo)state;
            System.debug('state request body : ' + stateRequestBody.requestBodyModel);
            requestBody = (String)stateRequestBody.requestBodyModel;
            accountId = (String)stateRequestBody.accountIdModel;
            fnaActivityId = (String)stateRequestBody.fnaActivityIdModel;
            startTime =  (Datetime)stateRequestBody.startTimeModel;
        }
        System.debug('OSC14| labels : ' + labels);
        // System.debug('OSC14| state.accountId : ' + state);
        // System.debug('OSC14| state.requestBody : ' + state.requestBody);
        system.debug('==== start process response account ============');
        try {
	        HttpResponse response = Continuation.getResponse(labels[0]);
            System.debug('OSC14| response : ' + response);

	        endTime = DateTime.now();
	        responseBody = null;

	        if ( response == null ) {
	        	pageMessage = System.Label.Customer_Product_ERR001+'<br/>'+System.Label.Customer_Product_ERR003;
	            errorCodeText = 'Null response.';
	            responseBody = null;
	            setErrorResponseOnlineServiceLog(OSC014_NAME,pageMessage,errorCodeText,'');
	            return null;

	        } else {

	        	if( response.getStatusCode() == 2000 ) // if timeout
				{
					pageMessage = System.Label.Customer_Product_Timeout+'<br/>'+System.Label.Customer_Product_ReRequest+'<br/>'+System.Label.Customer_Product_ERR003;
					errorCodeText = 'Error occur while calling Webservice : Http Status Code '+response.getStatusCode();
					setErrorResponseOnlineServiceLog(OSC014_NAME,pageMessage,errorCodeText,'');
					return null;
				}

				//Error Other Http Code 
				if( response.getStatusCode() != 200 && response.getStatusCode() != 2000) // if HTTP Status Code is not a success code
				{
					pageMessage = pageMessage = System.Label.Customer_Product_ERR001+'<br/>'+System.Label.Customer_Product_ERR003;
					errorCodeText = 'Error occur while calling Webservice : Http Status Code '+response.getStatusCode();
					setErrorResponseOnlineServiceLog(OSC014_NAME,pageMessage,errorCodeText,'');
					return null;
				}

				//success response
	            responseBody = response.getBody();
                system.debug('OSC14| FnaActivityId : ' + accountId);
                system.debug('OSC14| responseBody : ' + responseBody);

	            if (responseBody == null || responseBody == '') {
	            	pageMessage = System.Label.Customer_Product_ERR001+'<br/>'+System.Label.Customer_Product_ERR003;
					errorCodeText = 'Null response body.';
					setErrorResponseOnlineServiceLog(OSC014_NAME,pageMessage,errorCodeText,'');

				}else{
					//success response body
		           	productAccounts = CaseAccountProduct.parseJsonToObj(responseBody);

		            if(productAccounts.status.code == '0000'){
		            	pageMessage = productAccounts.status.description;
		                RTL_CampaignUtil.saveToOnlineLog(TRUE,accObj.Name,pageMessage,''/*mule id*/, userName,tmbCustomerID,OSC014_NAME,requestBody,responseBody,accObj,startTime,endTime);
		            }else{
		            	//code != 0000
		            	pageMessage = System.Label.Customer_Product_ERR001;
		            	errorCodeText = productAccounts.status.code + ' : ' + productAccounts.status.description;
		                setErrorResponseOnlineServiceLog(OSC014_NAME,pageMessage,errorCodeText,'');
		                return null;
		            }

		            // if(caseProductDepositAndLoanAll.size() == 0){
		            // 	pageMessage = System.Label.Customer_Product_Not_Found_OSC14;
		            // }
		        }
	        }

	        system.debug('==== end process response account ============');

	    }catch(Exception e) {
			pageMessage = System.Label.Customer_Product_ERR002+'<br/>'+System.Label.Customer_Product_ERR003;
			errorCodeText = e.getStackTraceString();
			setErrorResponseOnlineServiceLog(OSC014_NAME,pageMessage,errorCodeText,'');

	        System.debug('Show Error Message '+pageMessage);
			System.debug('There is error during processing : ' + e.getStackTraceString());
	           
	    }
        System.debug('OSC14|> fnaActivityId :'+fnaActivityId);
        return responseBody;
        // return fnaUtility.stampOffSetProductHoldingOSC14(fnaActivityId,CaseAccountProduct.parseJsonToObj(responseBody));
    }

    // NEW
    private Boolean checkResponse(HttpResponse response, String serviceName) {
        if ( response == null ) {
            pageMessage = System.Label.Customer_Product_ERR001+'<br/>'+System.Label.Customer_Product_ERR003;
            errorCodeText = 'Null response.';
            responseBody = null;
            setErrorResponseOnlineServiceLog(serviceName,pageMessage,errorCodeText,'');
            return false;

        } else {
            if( response.getStatusCode() == 2000 ) // if timeout
            {
                pageMessage = System.Label.Customer_Product_Timeout+'<br/>'+System.Label.Customer_Product_ReRequest+'<br/>'+System.Label.Customer_Product_ERR003;
                errorCodeText = 'Error occur while calling Webservice : Http Status Code '+response.getStatusCode();
                setErrorResponseOnlineServiceLog(serviceName,pageMessage,errorCodeText,'');
                return false;
            }

            //Error Other Http Code 
            if( response.getStatusCode() != 200 && response.getStatusCode() != 2000) // if HTTP Status Code is not a success code
            {
                pageMessage = System.Label.Customer_Product_ERR001+'<br/>'+System.Label.Customer_Product_ERR003;
                errorCodeText = 'Error occur while calling Webservice : Http Status Code '+response.getStatusCode();
                setErrorResponseOnlineServiceLog(serviceName,pageMessage,errorCodeText,'');
                return false;
            }
        }

        return true;
    }

    public String APPID_CONFIG = AppConfig__c.getValues('APPID') == null ? 'A0291' : AppConfig__c.getValues('APPID').Value__c;

    //============= Start NEW Deposit/Loan======================//
    public Object startCallCaseProductDeposit2() {
        String FIIdent = tmbCustomerID.substring(0, 16);
        String RMID = tmbCustomerID.substring(14);
        ProductListingRequest reqObj = new ProductListingRequest(RMID, FIIdent, null);

        requestBody = (String) System.JSON.Serialize(reqObj, true);
        System.debug('Body request string ' + requestBody);
        Continuation con = new Continuation(TIMEOUT_INT_SECS);
        // // Set callback method
        startTime = DateTime.now();
        con.continuationMethod = 'processResponseCaseProductDeposit';
        con.state = new StateInfo(fnaActivityId,accountId,requestBody,startTime);

        Uuid uuidGenerateor = new Uuid();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
        req.setHeader('Request-UID', uuidGenerateor.getValue());
        req.setHeader('Request-App-ID', APPID_CONFIG);
        req.setEndpoint('callout:OSC01');
        req.setBody(requestBody);
        req.setTimeout(timeout);

        this.requestLabel = con.addHttpRequest(req);
        // system.debug('Start Call ' + endpoint + ' request : ' + req);
        
        return con;
    }
    // @AuraEnabled
    public Object processResponseCaseProductDeposit(List<String> labels, Object state) {
        // String responseBody = '';
        if(state != null){
            StateInfo stateRequestBody = (StateInfo)state;
            System.debug('state request body : ' + stateRequestBody.requestBodyModel);
            requestBody = (String)stateRequestBody.requestBodyModel;
            accountId = (String)stateRequestBody.accountIdModel;
            fnaActivityId = (String)stateRequestBody.fnaActivityIdModel;
            startTime =  (Datetime)stateRequestBody.startTimeModel;
        }
        try {
            // requestOSC014 = true;

            System.debug('processResponseWsDeposit OSC01| this.requestLabel : ' + labels);
	        HttpResponse response = Continuation.getResponse(labels[0]);
            System.debug('processResponseWsDeposit OSC01| response : ' + response);

            endTime = DateTime.now();
	        responseBody = null;

            if (checkResponse(response, OSC001_NAME)) {
                //success response
	            responseBody = response.getBody();
                System.debug('OSC01| responseBody : ' + responseBody);

	            if (responseBody == null || responseBody == '') {
	            	pageMessage = System.Label.Customer_Product_ERR001+'<br/>'+System.Label.Customer_Product_ERR003;
					errorCodeText = 'Null response body.';
                    setErrorResponseOnlineServiceLog(OSC001_NAME, pageMessage, errorCodeText,'');
                    return '';

				} else {
                    CustomerAccountResponse customerAccountResponse = (CustomerAccountResponse) System.JSON.deserialize(responseBody, CustomerAccountResponse.class);

                    if(customerAccountResponse != null && customerAccountResponse.Status.StatusCode == 200) {
                        // Success
                        System.debug('Success');
                        pageMessage = customerAccountResponse.Status.StatusDesc;
                        RTL_CampaignUtil.saveToOnlineLog(TRUE,accObj.Name,pageMessage,''/*mule id*/, userName, tmbCustomerID, OSC001_NAME, requestBody, responseBody, accObj, startTime, endTime);
                        if (customerAccountResponse.GetCustomerAccountResponse == null) {
                            responseBody = '';
                        }
                        return responseBody;
                    } else {
                        // Fail
                        System.debug('Fail');
                        pageMessage = System.Label.Customer_Product_ERR001;
		            	errorCodeText = customerAccountResponse.Status.StatusCode + ' : ' + customerAccountResponse.Status.StatusDesc;
		                setErrorResponseOnlineServiceLog(OSC001_NAME, pageMessage, errorCodeText,'');
                        return '';
                    }
                }
            } 
        } catch (Exception e) {
            pageMessage = System.Label.Customer_Product_ERR002+'<br/>'+System.Label.Customer_Product_ERR003;
			errorCodeText = e.getStackTraceString();
			setErrorResponseOnlineServiceLog(OSC001_NAME,pageMessage,errorCodeText,'');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
	        System.debug('Show Error Message '+pageMessage);
			System.debug('There is error during processing : ' + e.getStackTraceString());
        }

        return '';
    }

    //============= Start WsOSC16 Bancassurance======================//
    public Object startCallCaseProductBA() {

        String endpoint;
        startTime = DateTime.now();

        // Create continuation with a timeout
        Continuation con = new Continuation(TIMEOUT_INT_SECS);
        // Set callback method
        con.continuationMethod = 'processResponseWsOSC16';

        CaseBAProduct.Request reqObj = new CaseBAProduct.Request();

        if (tmbCustomerID != null && tmbCustomerID != '') {
            string tmbcusright = tmbCustomerID.substring(tmbCustomerID.length() - 14);
            CaseBAProduct.Queries query = new  CaseBAProduct.Queries();
            query.customerId =  tmbcusright;
            reqObj.query =  query;
        }

        requestBody = reqObj.parseObjToJson(reqObj);
        system.debug('OSC16| requestBody ' + requestBody);

        // con.state = accountId;
        con.state = new StateInfo(fnaActivityId,accountId,requestBody,startTime);
        system.debug('OSC16| accountId ' + accountId);

        Http http = new Http();
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');

        mc = AppConfig__c.getValues('WsOSC16');
        endpoint = mc == null ? 'https://tmbcrmservices.tmbbank.com' : mc.Value__c;//default enf point value

        req.setEndpoint(endpoint);//app config end point
        req.setBody(requestBody);
        requestLabel = con.addHttpRequest(req);
        system.debug('OSC16| request : ' + req);

        return con;
    }


    public Object processResponseWsOSC16(List<String> labels, Object state) {
        if(state != null){
            StateInfo stateRequestBody = (StateInfo)state;
            System.debug('state request body : ' + stateRequestBody.requestBodyModel);
            requestBody = (String)stateRequestBody.requestBodyModel;
            accountId = (String)stateRequestBody.accountIdModel;
            fnaActivityId = (String)stateRequestBody.fnaActivityIdModel;
            startTime = (Datetime)stateRequestBody.startTimeModel;
        }
        System.debug('OSC16| labels : ' + labels);
    	try {
	        system.debug('==== start process response bancassurances ============');

	        HttpResponse response = Continuation.getResponse(labels[0]);
            System.debug('OSC16| response : ' + response);

	        endTime = DateTime.now();
	        responseBody = null;

	        if ( response == null ) {
	            pageMessage = System.Label.Customer_Product_ERR001+'<br/>'+System.Label.Customer_Product_ERR003;
	            errorCodeText = 'Null response.';
	            responseBody = null;
	            setErrorResponseOnlineServiceLog(OSC016_NAME,pageMessage,errorCodeText,'');
	            return null;

	        } else {

	        	if( response.getStatusCode() == 2000 ) // if timeout
				{
					pageMessage = System.Label.Customer_Product_Timeout+'<br/>'+System.Label.Customer_Product_ReRequest+'<br/>'+System.Label.Customer_Product_ERR003;
					errorCodeText = 'Error occur while calling Webservice : Http Status Code '+response.getStatusCode();
					setErrorResponseOnlineServiceLog(OSC016_NAME,pageMessage,errorCodeText,'');
					return null;

				}
				if( response.getStatusCode() != 200 && response.getStatusCode() != 2000) // if HTTP Status Code is not a success code
				{
					pageMessage = pageMessage = System.Label.Customer_Product_ERR001+'<br/>'+System.Label.Customer_Product_ERR003;
					errorCodeText = 'Error occur while calling Webservice : Http Status Code '+response.getStatusCode();
					setErrorResponseOnlineServiceLog(OSC016_NAME,pageMessage,errorCodeText,'');
					return null;
				}

	            responseBody = response.getBody();
                system.debug('OSC16| responseBody : ' + responseBody);
                system.debug('OSC16| FnaActivityId : ' + accountId);

	            if (responseBody == null || responseBody == '') {
					pageMessage = System.Label.Customer_Product_ERR001+'<br/>'+System.Label.Customer_Product_ERR003;
					errorCodeText = 'Null response body.';
					setErrorResponseOnlineServiceLog(OSC016_NAME,pageMessage,errorCodeText,'');
				} else{

		            productBAs = CaseBAProduct.parseJsonToObj(responseBody);

		            if(productBAs!=null){
		            	//success response
			            if(productBAs.status.code == '0000'){
			            	pageMessage = productBAs.status.description;
			                RTL_CampaignUtil.saveToOnlineLog(TRUE,accObj.Name,pageMessage,''/*mule id*/, userName,tmbCustomerID,OSC016_NAME,requestBody,responseBody,accObj,startTime,endTime);
			            }else{
			            	//code != 0000
			            	pageMessage = System.Label.Customer_Product_ERR001+'<br/>'+System.Label.Customer_Product_ERR003;
			            	errorCodeText = productAccounts.status.code + ' : ' + productAccounts.status.description;
			                setErrorResponseOnlineServiceLog(OSC014_NAME,pageMessage,errorCodeText,'');
			                return null;
			            }


		            	caseProductBancassurance = CaseBAProduct.getCustomerProductBancassuranceList(productBAs);
		            	caseProductBancassuranceAll = caseProductBancassurance;

		            	if(caseProductBancassurance.size() == 0){
		            		pageMessage = System.Label.Customer_Product_Not_Found_OSC16;
		            	}
		            }
		        }
	        }

	        system.debug('==== end process response bancassurances ============');

        }catch(Exception e) {
			pageMessage = System.Label.Customer_Product_ERR002+'<br/>'+System.Label.Customer_Product_ERR003;
			errorCodeText = e.getStackTraceString();
			setErrorResponseOnlineServiceLog(OSC016_NAME,pageMessage,errorCodeText,'');

	        System.debug('Show Error Message '+pageMessage);
			System.debug('There is error during processing : ' + e.getStackTraceString());   
	    }
        System.debug('OSC16|> fnaActivityId :'+fnaActivityId);
        return responseBody;
        // return fnaUtility.stampOffSetProductHoldingOSC16(fnaActivityId,CaseBAProduct.parseJsonToObj(responseBody));
    }

    //============= Start NEW Bancassurance======================//
    public Object startCallCaseProductBA2() {
        String RMID = tmbCustomerID.substring(14);
        ProductListingRequest reqObj = new ProductListingRequest(RMID, null, null);

        requestBody = (String) System.JSON.Serialize(reqObj, true);
        System.debug('Body request string ' + requestBody);
        Continuation con = new Continuation(TIMEOUT_INT_SECS);
        // // Set callback method
        startTime = DateTime.now();
        con.continuationMethod = 'processResponseCaseBancassurance';
        con.state = new StateInfo(fnaActivityId,accountId,requestBody,startTime);

        Uuid uuidGenerateor = new Uuid();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
        req.setHeader('Request-UID', uuidGenerateor.getValue());
        req.setHeader('Request-App-ID', APPID_CONFIG);
        req.setEndpoint('callout:OSC05_List');
        req.setBody(requestBody);
        req.setTimeout(timeout);

        this.requestLabel = con.addHttpRequest(req);
        // system.debug('Start Call ' + endpoint + ' request : ' + req);
        
        return con;
    }
    // @AuraEnabled
    public Object processResponseCaseBancassurance(List<String> labels, Object state) {
        // String responseBody = '';
        if(state != null){
            StateInfo stateRequestBody = (StateInfo)state;
            System.debug('state request body : ' + stateRequestBody.requestBodyModel);
            requestBody = (String)stateRequestBody.requestBodyModel;
            accountId = (String)stateRequestBody.accountIdModel;
            fnaActivityId = (String)stateRequestBody.fnaActivityIdModel;
            startTime =  (Datetime)stateRequestBody.startTimeModel;
        }
        try {
            // requestOSC014 = true;

            System.debug('processResponseWsBancassurance OSC05| this.requestLabel : ' + labels);
            HttpResponse response = Continuation.getResponse(labels[0]);
            System.debug('processResponseWsBancassurance OSC05| response : ' + response);

            endTime = DateTime.now();
            responseBody = null;
            if (checkResponse(response, OSC005_NAME)) {
                //success response
                responseBody = response.getBody();
                System.debug('OSC05| responseBody : ' + responseBody);

                if (responseBody == null || responseBody == '') {
                    pageMessage = System.Label.Customer_Product_ERR001+'<br/>'+System.Label.Customer_Product_ERR003;
                    errorCodeText = 'Null response body.';
                    setErrorResponseOnlineServiceLog(OSC005_NAME, pageMessage, errorCodeText,'');
                    return '';

                } else {
                    BancassuranceResponse bancassuranceResponse = (BancassuranceResponse) System.JSON.deserialize(responseBody, BancassuranceResponse.class);

                    if(bancassuranceResponse != null && bancassuranceResponse.Status.StatusCode.equals('200')) {
                        // Success
                        System.debug('Success');
                        pageMessage = bancassuranceResponse.Status.StatusDesc;
                        RTL_CampaignUtil.saveToOnlineLog(TRUE,accObj.Name,pageMessage,''/*mule id*/, userName, tmbCustomerID, OSC005_NAME, requestBody, responseBody, accObj, startTime, endTime);
                        if (bancassuranceResponse.GetBancassuranceAccountResponse.InsurancePolicyListCRMInqResponse == null) {
                            responseBody = '';
                        }
                        return responseBody;
                    } else {
                        // Fail
                        System.debug('Fail');
                        pageMessage = System.Label.Customer_Product_ERR001;
                        errorCodeText = bancassuranceResponse.Status.StatusCode + ' : ' + bancassuranceResponse.Status.StatusDesc;
                        setErrorResponseOnlineServiceLog(OSC005_NAME, pageMessage, errorCodeText,'');
                        return '';
                    }
                }
            } 
        } catch (Exception e) {
            pageMessage = System.Label.Customer_Product_ERR002+'<br/>'+System.Label.Customer_Product_ERR003;
            errorCodeText = e.getStackTraceString();
            setErrorResponseOnlineServiceLog(OSC005_NAME,pageMessage,errorCodeText,'');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            System.debug('Show Error Message '+pageMessage);
            System.debug('There is error during processing : ' + e.getStackTraceString());
        }

        return '';
    }
    
    //============= Start NEW Credit cards ======================//
    public Object startCallCaseProductCreditCards() {
        // String body = '{"query": {"rm_id": "00000001", "more_records": "N", "search_keys": "", "user_interface": ""}}'; //For test error case
        requestBody = '{"query": {"rm_id": "' + tmbCustomerID + '", "more_records": "N", "search_keys": "", "user_interface": ""}}';
        responseBody = null;
        String endpoint = 'callout:get_cards_balances';
        String serviceName = 'get-cards-balances';
        String CredentialName = endpoint.substring(8,endpoint.length());
        NamedCredential NameCredentialObj = [SELECT DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName = :CredentialName LIMIT 1];
        String CredentialURL = NameCredentialObj.Endpoint;

        Http http = new Http();
        HttpResponse res;
        System.debug('GET-CARDS-BALNCES| Body request string ' + requestBody);
        Continuation con = new Continuation(TIMEOUT_INT_SECS);
        startTime = DateTime.now();

        try {
            String bodyEncrypt = SCSMessageAPIUtil.encryptMessage(requestBody,'');
            System.debug('GET-CARDS-BALNCES| bodyEncrypt ' + bodyEncrypt);
    
            Uuid uuidGenerateor = new Uuid();
            HttpRequest req = new HttpRequest();
            String uuidValue = uuidGenerateor.getValue();
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
            req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
            req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
            req.setHeader('Request-UID', uuidValue);
            req.setHeader('Request-App-ID', APPID_CONFIG);
            req.setHeader('user-id', '');
            req.setHeader('service-name', serviceName);
            req.setEndpoint(endpoint);
            // req.setBody(body);
            req.setBody(bodyEncrypt);
            req.setTimeout(timeout);
    
            res = http.send(req);
            // return res.getBody();
            responseBody = SCSMessageAPIUtil.decryptMessage(res.getBody(), '');
            
            try {
                endTime = DateTime.now();
                // responseBody = null;
                // if (statusCode != null) {
                    //success response
                    System.debug('GET-CARDS-BALNCES| responseBody : ' + responseBody);

                    if (responseBody == null || responseBody == '') {
                        pageMessage = System.Label.Customer_Product_ERR001+'<br/>'+System.Label.Customer_Product_ERR003;
                        // errorCodeText = 'Null response body.';
                        responseBody = res.getBody();
                        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                        Map<String,Object> status = (Map<String,Object>)result.get('Status');
                        errorCodeText = (String)status.get('StatusDesc');
                        setErrorResponseOnlineServiceLog(CredentialURL, pageMessage, errorCodeText,uuidValue);
                        return '';

                    } else {
                        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                        Map<String,Object> status = (Map<String,Object>)result.get('status');
                        Integer statusCode = (Integer)status.get('status_code');
                        if(statusCode == 0) {
                            // Success
                            System.debug('Success');
                            pageMessage = 'Success';
                            RTL_CampaignUtil.saveToOnlineLog(TRUE,accObj.Name,pageMessage,uuidValue/*mule id*/, userName, tmbCustomerID, CredentialURL, requestBody, responseBody, accObj, startTime, endTime);
                            return responseBody;
                        } else {
                            // Fail
                            pageMessage = System.Label.Customer_Product_ERR001;
                            String StatusDesc = '';
                            if (responseBody != null) {
                                //from service
                                if (status != null && status.get('error_status') != null) {
                                    List<Object> error_list = (List<Object>)status.get('error_status');
                                    Map<String,Object> errorData;
                                    Map<String,Object> error1st = (Map<String,Object>)error_list[0];
                                    StatusDesc = (String)error1st.get('description');
                                    if (StatusDesc == 'Invalid CIF number' || (String)error1st.get('error_code') == 'CIF0003') {
                                        // Credit card not found case
                                        System.debug('Success');
                                        RTL_CampaignUtil.saveToOnlineLog(FALSE,accObj.Name,StatusDesc,uuidValue/*mule id*/, userName, tmbCustomerID, CredentialURL, requestBody, responseBody, accObj, startTime, endTime);
                                        return '';
                                    }
                                    System.debug('Fail');
                                    for (Integer i = 1; i < error_list.size(); i++) {
                                        errorData = (Map<String,Object>)error_list[i];
                                        StatusDesc = StatusDesc +' | '+ (String)errorData.get('description'); 
                                    }
                                //from internal error
                                } else if (status.get('description') != null) {
                                    StatusDesc = (String)status.get('description');
                                } else {
                                    StatusDesc = 'Don\'t get description';
                                }
                            }
                            setErrorResponseOnlineServiceLog(CredentialURL, pageMessage, StatusDesc,uuidValue);
                            return '';
                        }
                    }
                // } 
            } catch (Exception e) {
                pageMessage = System.Label.Customer_Product_ERR002+'<br/>'+System.Label.Customer_Product_ERR003;
                errorCodeText = e.getStackTraceString();
                setErrorResponseOnlineServiceLog(CredentialURL,pageMessage,errorCodeText,uuidValue);
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                System.debug('Show Error Message '+pageMessage);
                System.debug('There is error during processing : ' + e.getStackTraceString());
                // return null;
            }

        return responseBody;
            
        } catch (Exception e) {
            pageMessage = System.Label.Customer_Product_ERR002+'<br/>'+System.Label.Customer_Product_ERR003;
            String errorMSG = 'System error : ' + e.getMessage();
            System.debug('System error : ' + e.getMessage());
            errorMSG += '\nStack Trace : ' + e.getStackTraceString();
            System.debug('Stack Trace : ' + e.getStackTraceString()); 
            if(errorMSG.contains('Read timed out') || errorMSG.contains('timeout') || errorMSG.contains('Timeout')) {
                errorMSG = 'The timeout was reached, and the server didn’t get a chance to respond.';
                setErrorResponseOnlineServiceLog(CredentialURL,pageMessage,errorMSG,'');
                // return errorMSG;
            } else {
                setErrorResponseOnlineServiceLog(CredentialURL,pageMessage,errorMSG,'');
                // return errorMSG;
            }
            return errorMSG;
        }

    }
    // @AuraEnabled
    // public Object processResponseCaseCrediCards(List<String> labels, Object state) {
    //     String responseBody = '';
    //     if(state != null){
    //         StateInfo stateRequestBody = (StateInfo)state;
    //         System.debug('state request body : ' + stateRequestBody.requestBodyModel);
    //         requestBody = (String)stateRequestBody.requestBodyModel;
    //         accountId = (String)stateRequestBody.accountIdModel;
    //         fnaActivityId = (String)stateRequestBody.fnaActivityIdModel;
    //         startTime =  (Datetime)stateRequestBody.startTimeModel;
    //     }
    //     HttpResponse response = Continuation.getResponse(labels[0]);
    //     responseBody = response.getBody();
    //     // CreditCardsSCSResponse creditCardsSCSResponse = (CreditCardsSCSResponse) System.JSON.deserialize(responseBody, CreditCardsSCSResponse.class);
    //     return responseBody;
    // }

    public static String fetchUserSessionId(){
     	String sessionId = '';
     	// Get the content of the VF page
     	String vfContent;
     	String ns =  [SELECT NamespacePrefix FROM Organization].NamespacePrefix;

		try {
            String vf_url = '/apex/';
            if(String.isNotBlank(ns)) {
                vf_url += ns + '__' + 'getsessionidvf';    
            } else {
                vf_url += 'getsessionidvf';       
            }

            PageReference pg = new PageReference(vf_url);
    
            if(!test.isRunningTest()) {
                vfContent = pg.getContent().toString();
            }
            else {
                vfContent = String.valueOf('Start_Of_Session_Id Test End_Of_Session_Id');
            }
    
            Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
            endP = vfContent.indexOf('End_Of_Session_Id');
            // Get the Session Id
            sessionId = vfContent.substring(startP, endP);
        } catch(Exception ex) {
            System.debug('***** ex: ' + ex);
        }

    	// Return Session Id
    	return sessionId;
    }

    public void setErrorResponseOnlineServiceLog(string serviceName,string pageMessage,string errorCodeText,string muleId){
        System.debug('requestBody : ' + requestBody);
        // System.debug('responseBody : ' + responseBody);
        System.debug('accObj.Name : ' + accObj.Name);
        System.debug('errorCodeText : ' + errorCodeText);
        System.debug('userName : ' + userName);
        System.debug('tmbCustomerID : ' + tmbCustomerID);
        System.debug('serviceName : ' + serviceName);
        System.debug('accObj : ' + accObj);
        System.debug('startTime : ' + startTime);
        System.debug('endTime : ' + endTime);

		RTL_CampaignUtil.saveToOnlineLog(FALSE,accObj.Name,errorCodeText,muleId/*mule id*/, userName,tmbCustomerID,serviceName,requestBody,responseBody,accObj,startTime,endTime);
    }
}