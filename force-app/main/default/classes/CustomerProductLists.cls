public class CustomerProductLists {
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

    public String pageMessage1 {get; set;}//DepositAndLoan
    public String pageMessage2 {get; set;}//Bancassurance
    public String pageMessage3 {get; set;}//Investment

	private String userName;/* current user FirstName + LastName */
	public String tmbCustomerID {get; set;}
	public String itemNumber {get; set;}
    public String accountId {get; set;}
    public String productType {get; set;}
    public String tabindex { get; set;}
    public String searchProduct {get; set;}
    public String searchProduct1 {get; set;}//DepositAndLoan
    public String searchProduct2 {get; set;}//Bancassurance
    public String searchProduct3 {get; set;}//Investment

    // public String statusResponseOSC14 {get;set;}
    // public String statusResponseOSC16 {get;set;}

    public String requestBody;
    public String requestLabel;
    public String responseBody {get;set;}
    public String pageMessage {get;set;}
    public String errorCodeText {get;set;}
    private DateTime startTime;
    private DateTime endTime;
    public AppConfig__c mc;
    public AppConfig__c appId;
    public Account accObj {get; set;}
    public CustomIterable paginationObj {
    	get{
    		if(paginationObj == null){
    			List<CaseProductNumberService.CaseProductWrapper> returnList = new List<CaseProductNumberService.CaseProductWrapper>();
    			paginationObj = new CustomIterable(returnList);
    		}
    		return paginationObj;
    	}set;
    }
    public List<String> unitHolderNoslist = new List<String>();

    public Boolean requestOSC014 {get;set;}
    public Boolean requestOSC015 {get;set;}
    public Boolean requestOSC016 {get;set;}

    private static final String OSC001_NAME = [SELECT Endpoint FROM NamedCredential where DeveloperName = 'OSC01'][0].Endpoint;
    private static final String OSC005_NAME = [SELECT Endpoint FROM NamedCredential where DeveloperName = 'OSC05_List'][0].Endpoint;
    private static final String OSC006_NAME = [SELECT Endpoint FROM NamedCredential where DeveloperName = 'OSC06_List'][0].Endpoint;

    private static final String OSC014_NAME = 'customerProductDepositAndLoan';
    private static final String OSC015_NAME = 'customerProductInvestment';
    private static final String OSC016_NAME = 'customerProductBancassurance';

    public static Integer TIMEOUT_INT_SECS {
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

    public transient Map<string /*product code*/, RTLProductMasterDTO> onlyProductWithProductCode{ //{get;set;}
       get{
            //get retail products
            if ( onlyProductWithProductCode == null ) {
                onlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
            }
            return onlyProductWithProductCode;
        }
        set;
    }

    public CustomerProductLists(fnaProductDetailCtrl controller) {
		// //==================Init Product number page========================//
        // //get item number from main page
        // itemNumber = '1';
        // accountId = apexpages.currentpage().getparameters().get('Id');

        // System.debug('accountId : ' + accountId);
       
        // getCustomerSegmentAndTMBCusId(accountId);

        // if(tmbCustomerID == null ){
        // 	pageMessage = Label.Case_Tmb_Cus_Error;
        // 	 ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,Label.Case_Tmb_Cus_Error));
        // }

        // if(caseProductDepositAndLoan!= null){
        //     paginationObj = new CustomIterable (caseProductDepositAndLoan);
        //     paginationObj.setPageSize = productNumberPerPage;
        //     nextDepositAndLoan();
            
        // }

        // userName = UserInfo.getName();

        // requestOSC014 = false;
        // requestOSC015 = false;
        // requestOSC016 = false;
    }


	public CustomerProductLists() {

		//==================Init Product number page========================//
        //get item number from main page
        itemNumber = apexpages.currentpage().getparameters().get('itemNumber');
        accountId = apexpages.currentpage().getparameters().get('accountId');
       
        getCustomerSegmentAndTMBCusId(accountId);

        if(tmbCustomerID == null ){
            pageMessage = Label.Case_Tmb_Cus_Error;
            pageMessage1 = pageMessage;
            pageMessage2 = pageMessage;
            pageMessage3 = pageMessage;
        	ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,Label.Case_Tmb_Cus_Error));
        }

        if(caseProductDepositAndLoan!= null){
            paginationObj = new CustomIterable (caseProductDepositAndLoan);
            paginationObj.setPageSize = productNumberPerPage;
            nextDepositAndLoan();
            
        }

        userName = UserInfo.getName();

        requestOSC014 = false;
        requestOSC015 = false;
        requestOSC016 = false;
		
	}

    public String fnaActivityId {get;set;}
    public Boolean statusStampOffset {get;set;}
    public Boolean sendSMS {get;set;}

    public String setupCustomerList() {
        system.debug('FNA ACTIVITY ID : ' + fnaActivityId);
        // fnaActivityId = UrlHelper.decryptParams(fnaActivityId);
        String customerId;
        List<FNA_Activity__c> listCustomerActivity = [SELECT Customer__c, Customer__r.Id, Customer__r.TMB_Customer_ID_PE__c, Id FROM FNA_Activity__c WHERE Id =: fnaActivityId];
        if(!listCustomerActivity.isEmpty()){
            if(listCustomerActivity[0].Customer__c != null){
                if(listCustomerActivity[0].Customer__r.TMB_Customer_ID_PE__c != null){
                    List<FNA_Product_Offering__c> listCheckProdOffset = [SELECT Id, Flag_Highlight__c, Flag_Interested_Product__c, Flag_Offset_product_holding__c, FNA_Activity__c FROM FNA_Product_Offering__c WHERE FNA_Activity__c =: fnaActivityId AND Flag_Offset_product_holding__c = true];
                    if(listCheckProdOffset.isEmpty()){
                        customerId = listCustomerActivity[0].Customer__r.Id;
                    }
                    else{
                        system.debug('PRODUCT OFFSET ALREADY STAMP');
                        statusStampOffset = false;
                        return null;
                    }
                }
                else{
                    system.debug('CUSTOMER TMB ID NOT FOUND');
                    statusStampOffset = false;
                    return null;
                }
            }
            else{
                system.debug('CUSTOMER NOT FOUND');
                statusStampOffset = false;
                return null;
            }
        }
        else{
            system.debug('FNA ACTIVITY NOT FOUND');	
            statusStampOffset = false;
            return null;
        }

        system.debug('START CALL OSC CUSTOMER ID: ' + customerId);		


		//==================Init Product number page========================//
        //get item number from main page
        itemNumber = '1';
        accountId = customerId;
       
        getCustomerSegmentAndTMBCusId(accountId);

        if(tmbCustomerID == null ){
            pageMessage = Label.Case_Tmb_Cus_Error;
            pageMessage1 = pageMessage;
            pageMessage2 = pageMessage;
            pageMessage3 = pageMessage;
        	 ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,Label.Case_Tmb_Cus_Error));
        }

        if(caseProductDepositAndLoan!= null){
            paginationObj = new CustomIterable (caseProductDepositAndLoan);
            paginationObj.setPageSize = productNumberPerPage;
            nextDepositAndLoan();
            
        }

        userName = UserInfo.getName();

        requestOSC014 = false;
        requestOSC015 = false;
        requestOSC016 = false;
        system.debug('START CALL OSC : ' + accountId);	

        statusStampOffset = true;
        return null;	
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

     public List<CaseProductNumberService.CaseProductWrapper> caseProductDepositAndLoan {
        get{
            if (caseProductDepositAndLoan == null) {
                List<CaseProductNumberService.CaseProductWrapper> returnList = new List<CaseProductNumberService.CaseProductWrapper>();
                return returnList;
            }
            return caseProductDepositAndLoan;
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
    public List<CaseProductNumberService.CaseProductWrapper> caseProductInvestment {
    	get{
            if (caseProductInvestment == null) {
                List<CaseProductNumberService.CaseProductWrapper> returnList = new List<CaseProductNumberService.CaseProductWrapper>();
                return returnList;
            }
            return caseProductInvestment;
        } set;
    }
	public List<CaseProductNumberService.CaseProductWrapper> caseProductInvestmentAll {get;set;}

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

    public CaseInvestmentProduct productInvestment {
        get{
            if ( productInvestment == null ) {
                productInvestment = new CaseInvestmentProduct();
            }
            return productInvestment;
        }
        set;
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
            CaseAccountProduct.Queries query = new  CaseAccountProduct.Queries();
            query.customerId =  tmbcusright;
            reqObj.query =  query;
        }

        requestBody = reqObj.parseObjToJson(reqObj);
        system.debug('requestBody ' + requestBody);

        // Create callout request
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        // Set Request Header
        req.setHeader('Service-Name','customers-accounts-inq');
        req.setHeader('Request-uid',NumberHelper.generateUID());

        appId = AppConfig__c.getValues('WsOSC14_Request_App_Id');
        appIDName = (appId == null)? 'A0291':appId.Value__c;//default app id

        req.setHeader('Request-App-Id',appIDName);
        req.setHeader('Request-datetime', request_dt);
        //req.setHeader('Acronym','7350T61D');
        req.setHeader('Content-Type','application/json');

        mc = AppConfig__c.getValues('WsOSC14');
        endpoint = mc == null ? 'https://tmbcrmservices.tmbbank.com' : mc.Value__c;//default enf point value
        req.setEndpoint(endpoint);//app config end point
        req.setBody(requestBody);
        this.requestLabel = con.addHttpRequest(req);
        system.debug('request : ' + req);
        requestOSC014 = true;

        return con;

    }

    public Object processResponseWsOSC14() {
        system.debug('==== start process response account ============');
        try {
            System.debug('OSC14| this.requestLabel : ' + this.requestLabel);
	        HttpResponse response = Continuation.getResponse(this.requestLabel);
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
                System.debug('OSC14| responseBody : ' + responseBody);

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

		            setPagination(getcaseProductDepositAndLoanList());
		            nextDepositAndLoan();

		            if(caseProductDepositAndLoanAll.size() == 0){
		            	pageMessage = System.Label.Customer_Product_Not_Found_OSC14;
		            	ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,pageMessage));
		            }
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

        // statusResponseOSC14 = fnaUtility.stampOffSetProductHoldingOSC14(accountId,CaseAccountProduct.parseJsonToObj(responseBody));
        return null;
    }


    //============= Start WsOSC15 Investment (MF)======================//
    public Object startCallCaseProductInvestment() {

        String endpoint;
        startTime = DateTime.now();

        // Create continuation with a timeout
        Continuation con = new Continuation(TIMEOUT_INT_SECS);
        // Set callback method
        con.continuationMethod = 'processResponseWsOSC15';

        CaseInvestmentProduct.Request reqObj = new CaseInvestmentProduct.Request();
        CaseInvestmentProduct.Queries query = new  CaseInvestmentProduct.Queries();

        query.unitHolderNos =  unitHolderNoslist;
        reqObj.query =  query;
        

        requestBody = reqObj.parseObjToJson(reqObj);
        system.debug('requestBody ' + requestBody);

        Http http = new Http();
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');

        mc = AppConfig__c.getValues('WsOSC15');
        endpoint = mc == null ? 'https://tmbcrmservices.tmbbank.com' : mc.Value__c;//default enf point value

        req.setEndpoint(endpoint);//app config end point
        req.setBody(requestBody);
        this.requestLabel = con.addHttpRequest(req);
        system.debug('request : ' + req);
		
        requestOSC015 = true;

        return con;

    }

    public List<CaseInvestmentProduct> productInvestmentList {get;set;}

    public Object processResponseWsOSC15() {
	    try {
	        system.debug('==== start process response investment ============');
	        String statusResponse;
	        HttpResponse response = Continuation.getResponse(this.requestLabel);
	        endTime = DateTime.now();
	        responseBody = null;

			if ( response == null ) {
				pageMessage = System.Label.Customer_Product_ERR001+'<br/>'+System.Label.Customer_Product_ERR003;
	            errorCodeText = 'Null response.';
	            responseBody = null;
	            setErrorResponseOnlineServiceLog(OSC015_NAME,pageMessage,errorCodeText,'');
				return null;

			}else{ 

                if(unitHolderNoslist.size() == 0 ){
                    pageMessage = System.Label.Customer_Product_Not_Found_OSC15;
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,pageMessage));
                    return null;
                }
				
				if( response.getStatusCode() == 2000 ) // if timeout
				{
					pageMessage = System.Label.Customer_Product_Timeout+'<br/>'+System.Label.Customer_Product_ReRequest+'<br/>'+System.Label.Customer_Product_ERR003;
					errorCodeText = 'Error occur while calling Webservice : Http Status Code '+response.getStatusCode();
					setErrorResponseOnlineServiceLog(OSC015_NAME,pageMessage,errorCodeText,'');
					return null;
				}
				if( response.getStatusCode() != 200 && response.getStatusCode() != 2000) // if HTTP Status Code is not a success code
				{
					pageMessage = pageMessage = System.Label.Customer_Product_ERR001+'<br/>'+System.Label.Customer_Product_ERR003;
					errorCodeText = 'Error occur while calling Webservice : Http Status Code '+response.getStatusCode();
					setErrorResponseOnlineServiceLog(OSC015_NAME,pageMessage,errorCodeText,'');
					return null;
				}

				responseBody = response.getBody();

				
				if (responseBody == null || responseBody == '') {
					pageMessage = System.Label.Customer_Product_ERR001+'<br/>'+System.Label.Customer_Product_ERR003;
					errorCodeText = 'Null response body.';
					setErrorResponseOnlineServiceLog(OSC015_NAME,pageMessage,errorCodeText,'');
				} else{

					//Success Reponse parse json
					productInvestmentList = CaseInvestmentProduct.parseJsonToObjList(responseBody);
					
					//Get status description
					statusResponse = CaseInvestmentProduct.validateResponseSuccess(productInvestmentList);

					system.debug('MF status : ' + statusResponse);

					if (statusResponse == 'Success') {
						RTL_CampaignUtil.saveToOnlineLog(TRUE, accObj.Name, statusResponse, ''/*mule id*/, userName, tmbCustomerID, OSC015_NAME, requestBody, responseBody, accObj, startTime, endTime);
					}else{
						//found error 
						pageMessage = System.Label.Customer_Product_ERR002+'<br/>'+System.Label.Customer_Product_ERR003;
						RTL_CampaignUtil.saveToOnlineLog(FALSE, accObj.Name, statusResponse, ''/*mule id*/, userName, tmbCustomerID, OSC015_NAME, requestBody, responseBody, accObj, startTime, endTime);
					}

					if (productInvestmentList.size() > 0) {
						caseProductInvestment = CaseInvestmentProduct.getCustomerProductInvestmentListFormat (productInvestmentList,onlyProductWithProductCode,unitHolderNoslist);
						caseProductInvestmentAll = caseProductInvestment;
						
					}else{
						pageMessage = System.Label.Customer_Product_Not_Found_OSC15;
		            	ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,pageMessage));
					}

					setPagination(caseProductInvestment);
					nextInvestment();
				}
			}
			

	        system.debug('==== end process response investment ============');

	    }catch(Exception e) {
			pageMessage = System.Label.Customer_Product_ERR002+'<br/>'+System.Label.Customer_Product_ERR003;
			errorCodeText = e.getStackTraceString();
			setErrorResponseOnlineServiceLog(OSC015_NAME,pageMessage,errorCodeText,'');

	        System.debug('Show Error Message '+pageMessage);
			System.debug('There is error during processing : ' + e.getStackTraceString());

	    }

        return null;
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
        system.debug('requestBody ' + requestBody);

        Http http = new Http();
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');

        mc = AppConfig__c.getValues('WsOSC16');
        endpoint = mc == null ? 'https://tmbcrmservices.tmbbank.com' : mc.Value__c;//default enf point value

        req.setEndpoint(endpoint);//app config end point
        req.setBody(requestBody);
        this.requestLabel = con.addHttpRequest(req);
        system.debug('request : ' + req);
        requestOSC016 = true;
        

        return con;

    }


    public Object processResponseWsOSC16() {

    	try {
	        system.debug('==== start process response bancassurances ============');

	        HttpResponse response = Continuation.getResponse(this.requestLabel);
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
		            		ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,pageMessage));
		            	}

		            	setPagination(caseProductBancassurance);
		            	nextBA();

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

        return null;
    }

    List<CustomerAccountResponse.InvestmentAccount> investmentAccountList = new List<CustomerAccountResponse.InvestmentAccount>();
    public String APPID_CONFIG = AppConfig__c.getValues('APPID') == null ? 'A0291' : AppConfig__c.getValues('APPID').Value__c;
    private Object callWebservice(String callbackName, String endpoint, String body) {
        // Create continuation with a timeout
        Continuation con = new Continuation(TIMEOUT_INT_SECS);
        // // Set callback method
        con.continuationMethod = callbackName;

        startTime = DateTime.now();
        Uuid uuidGenerateor = new Uuid();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
        req.setHeader('Request-UID', uuidGenerateor.getValue());
        req.setHeader('Request-App-ID', APPID_CONFIG);
        req.setEndpoint(endpoint);
        req.setBody(body);
        req.setTimeout(timeout);

        this.requestLabel = con.addHttpRequest(req);
        system.debug('Start Call ' + endpoint + ' request : ' + req);

        return con;
    }

    public List<String> requestLabels = new List<String>();

    private List<String> callMultipleWebservice(String endpoint, List<String> bodies) {
        Http http = new Http();
        List<String> responseBodies = new List<String>();
        String bodiesStr = '';
        String responseBodiesStr = '';
        String status = '';
        Set<String> allStatus = new Set<String>();
        List<String> successList = new List<String>();
        Boolean isSuccess = TRUE;
        Uuid uuidGenerateor = new Uuid();
        HttpRequest req = null;
        startTime = DateTime.now();

        req = new HttpRequest();

        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
        req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
        req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
        req.setHeader('Request-UID', uuidGenerateor.getValue());
        req.setHeader('Request-App-ID', APPID_CONFIG);
        req.setEndpoint(endpoint);
        req.setTimeout(timeout);
        
        try {
            for (String body : bodies) {
                
                req.setBody(body);
                HttpResponse response = http.send(req);
                responseBodies.add(response.getBody());
                InvestmentResponse investmentResponse = (InvestmentResponse) System.JSON.deserialize(response.getBody(), InvestmentResponse.class);
                status = investmentResponse.Status.StatusDesc;
                if (status != null) {
                    if (response.getStatusCode() != 200 || status != 'success') {
                        allStatus.add(status);
                    } else {
                        successList.add(status);
                    }
                }
                
                system.debug('Start Call ' + endpoint + ' request : ' + req);
            }

            if (responseBodies == null || responseBodies.size() == 0) {
                // pageMessage = System.Label.Customer_Product_ERR001+'<br/>'+System.Label.Customer_Product_ERR003;
                pageMessage = System.Label.Customer_Product_Not_Found_Investment;
                errorCodeText = 'Null response body.';
                setErrorResponseOnlineServiceLog(OSC006_NAME, pageMessage, errorCodeText,'');
            } else {
                bodiesStr = '[' + string.join(bodies,',') + ']';
                responseBodiesStr = '[' + string.join(responseBodies,',') + ']';
        
                endTime = DateTime.now();
                if (allStatus.size() == 0 || successList.size() > 0) {
                    pageMessage = 'success';
                    isSuccess = TRUE;
                    RTL_CampaignUtil.saveToOnlineLog(isSuccess,accObj.Name, pageMessage,'', userName, tmbCustomerID, OSC006_NAME, bodiesStr, responseBodiesStr, accObj, startTime, endTime);
                } else {
                    pageMessage = System.Label.Customer_Product_ERR001+'<br/>'+System.Label.Customer_Product_ERR003;
                    errorCodeText = string.join((new List<String>(allStatus)),' | ');
                    setErrorResponseOnlineServiceLog(OSC006_NAME, pageMessage, errorCodeText,'');
                }
            }
    
        } catch (Exception e) {
            pageMessage = System.Label.Customer_Product_Timeout+'<br/>'+System.Label.Customer_Product_ReRequest+'<br/>'+System.Label.Customer_Product_ERR003;
            errorCodeText = 'Timeout';
            setErrorResponseOnlineServiceLog(OSC006_NAME,pageMessage,errorCodeText,'');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
	        System.debug('Show Error Message '+pageMessage);
			System.debug('There is error during processing : ' + e.getStackTraceString());
        }


        return responseBodies;
    }

    private void getInvestmentAccounts(CustomerAccountResponse customerAccountResponse) {
        if (customerAccountResponse.GetCustomerAccountResponse.InvestmentAccounts != null &&
            customerAccountResponse.GetCustomerAccountResponse.InvestmentAccounts.InvestmentAccount != null) {
            
                investmentAccountList.addAll(customerAccountResponse.GetCustomerAccountResponse.InvestmentAccounts.InvestmentAccount);
        }
    }

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

    /* New */
    public Object startCallCaseProductCreditCards() {
        // String responseBody = '';
        requestBody = '{"query": {"rm_id": "' + tmbCustomerID + '", "more_records": "N", "search_keys": "", "user_interface": ""}}';
        String endpoint = 'callout:get_cards_balances';
        String serviceName = 'get-cards-balances';
        String CredentialName = endpoint.substring(8,endpoint.length());
        NamedCredential NameCredentialObj = [SELECT DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName = :CredentialName LIMIT 1];
        String CredentialURL = NameCredentialObj.Endpoint;

        Http http = new Http();
        HttpResponse res;
        System.debug('GET-CARDS-BALNCES| Body request string ' + requestBody);
        // Continuation con = new Continuation(TIMEOUT_INT_SECS);
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
                        responseBody = null;

                    } else {
                        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                        Map<String,Object> status = (Map<String,Object>)result.get('status');
                        Integer statusCode = (Integer)status.get('status_code');
                        if(statusCode == 0) {
                            // Success
                            System.debug('Success');
                            pageMessage = 'Success';
                            // responseBody = resDecrypt;
                            RTL_CampaignUtil.saveToOnlineLog(TRUE,accObj.Name,pageMessage,uuidValue/*mule id*/, userName, tmbCustomerID, CredentialURL, requestBody, responseBody, accObj, startTime, endTime);
                            // return resDecrypt;
                        } else {
                            // Fail
                            System.debug('Fail');
                            pageMessage = System.Label.Customer_Product_ERR001;
                            String StatusDesc = '';
                            if (responseBody != null) {
                                //from service
                                if (status.get('error_status') != null) {
                                    List<Object> error_list = (List<Object>)status.get('error_status');
                                    Map<String,Object> errorData;
                                    Map<String,Object> error1st = (Map<String,Object>)error_list[0];
                                    StatusDesc = (String)error1st.get('description');
                                    if (StatusDesc == 'Invalid CIF number' || (String)error1st.get('error_code') == 'CIF0003') {
                                        // Credit card not found case
                                        System.debug('Success');
                                        RTL_CampaignUtil.saveToOnlineLog(FALSE,accObj.Name,StatusDesc,uuidValue/*mule id*/, userName, tmbCustomerID, CredentialURL, requestBody, responseBody, accObj, startTime, endTime);
                                        responseBody = '';
                                    } else {
                                        for (Integer i = 1; i < error_list.size(); i++) {
                                            errorData = (Map<String,Object>)error_list[i];
                                            StatusDesc = StatusDesc +' | '+ (String)errorData.get('description'); 
                                        }
                                        setErrorResponseOnlineServiceLog(CredentialURL, pageMessage, StatusDesc,uuidValue);
                                    }
                                //from internal error
                                } else if (status.get('description') != null) {
                                    StatusDesc = (String)status.get('description');
                                    setErrorResponseOnlineServiceLog(CredentialURL, pageMessage, StatusDesc,uuidValue);
                                } else {
                                    StatusDesc = 'Don\'t get description';
                                    setErrorResponseOnlineServiceLog(CredentialURL, pageMessage, StatusDesc,uuidValue);
                                }
                            }
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
            }
            return null;

        // return resDecrypt;
            
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
        }
        return null;
        
    }

    /* New */
    public Object startCallCaseProductDeposit2() {
        String FIIdent = tmbCustomerID.substring(0, 16);
        String RMID = tmbCustomerID.substring(14);
        ProductListingRequest reqObj = new ProductListingRequest(RMID, FIIdent, null);

        requestBody = (String) System.JSON.Serialize(reqObj, true);
        System.debug('Body request string ' + requestBody);

        return callWebservice('processResponseWsDeposit', 'callout:OSC01', requestBody);
    }

    /* New */
    public Object startCallCaseProductBA2() {
        String RMID = tmbCustomerID.substring(14);
        ProductListingRequest reqObj = new ProductListingRequest(RMID, null, null);

        requestBody = (string) System.JSON.Serialize(reqObj, true);
        System.debug('Body request string ' + requestBody);

        return callWebservice('processResponseWsBancassurance', 'callout:OSC05_List', requestBody);
    }

    /* New */
    public Object startCallCaseProductInvestment2() {
        List<String> bodies = new List<String>();
        List<String> unitHolderNoList = new List<String>();
        for (CustomerAccountResponse.InvestmentAccount investmentAccount : investmentAccountList) {
            System.debug('Unit Holder No [' + investmentAccount.UnitHoldNo + ']');
            String unitHolderNo = investmentAccount.UnitHoldNo;
            ProductListingRequest reqObj = new ProductListingRequest(null, null, unitHolderNo);

            requestBody = (string) System.JSON.Serialize(reqObj, true);
            System.debug('Body request string ' + requestBody);
            bodies.add(requestBody);
            unitHolderNoList.add(unitHolderNo);
        }

        List<String> responseBodies = callMultipleWebservice('callout:OSC06_List', bodies);
        processResponseWsInvestment(responseBodies, unitHolderNoList);

        return null;
     }

    /* New */
    public Object processResponseWsDeposit() {
        // String responseBody = '';
        try {
            requestOSC014 = true;

            System.debug('processResponseWsDeposit OSC01| this.requestLabel : ' + this.requestLabel);
	        HttpResponse response = Continuation.getResponse(this.requestLabel);
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
                    } else {
                        // Fail
                        System.debug('Fail');
                        pageMessage = System.Label.Customer_Product_ERR001;
		            	errorCodeText = customerAccountResponse.Status.StatusCode + ' : ' + customerAccountResponse.Status.StatusDesc;
		                setErrorResponseOnlineServiceLog(OSC001_NAME, pageMessage, errorCodeText,'');
		                return null;
                    }
                    List<CaseProductNumberService.CaseProductWrapper> caseProductDepositAndLoanList = getcaseProductDepositAndLoanList(customerAccountResponse);
                    setPagination(caseProductDepositAndLoanList);
                    nextDepositAndLoan();

                    /* Get investment account for query in tab3 */
                    getInvestmentAccounts(customerAccountResponse);

                    if(caseProductDepositAndLoanList.size() == 0){
		            	pageMessage = System.Label.Customer_Product_Not_Found_Deposit_Loan;
                        pageMessage1 = pageMessage;
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,pageMessage));
                    } else {
                        caseProductDepositAndLoanAll = new List<CaseProductNumberService.CaseProductWrapper>();
                        caseProductDepositAndLoanAll.addAll(caseProductDepositAndLoanList);
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

        return null;
    }

    /* New */
    public Object processResponseWsBancassurance() {

        // String responseBody = '';
        try {
            requestOSC016 = true;
    
            System.debug('processResponseWsDeposit OSC05| this.requestLabel : ' + this.requestLabel);
	        HttpResponse response = Continuation.getResponse(this.requestLabel);
            System.debug('processResponseWsDeposit OSC05| response : ' + response);

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

				} else {
                    
                    BancassuranceResponse bancassuranceResponse = (BancassuranceResponse) System.JSON.deserialize(responseBody, BancassuranceResponse.class);

                    if(bancassuranceResponse != null && bancassuranceResponse.Status.StatusCode.equals('200')) {
                        // Success
                        pageMessage = bancassuranceResponse.Status.StatusDesc;
                        RTL_CampaignUtil.saveToOnlineLog(TRUE,accObj.Name,pageMessage,''/*mule id*/, userName, tmbCustomerID, OSC005_NAME, requestBody, responseBody, accObj, startTime, endTime);
                        System.debug('Success');
                        if (bancassuranceResponse.GetBancassuranceAccountResponse.InsurancePolicyListCRMInqResponse == null) {
                            responseBody = '';
                        }
                    } else {
                        // Fail
                        System.debug('Fail');
                        pageMessage = System.Label.Customer_Product_ERR001;
		            	errorCodeText = bancassuranceResponse.Status.StatusCode + ' : ' + bancassuranceResponse.Status.StatusDesc;
		                setErrorResponseOnlineServiceLog(OSC005_NAME, pageMessage, errorCodeText,'');
		                return null;
                    }

                    List<CaseProductNumberService.CaseProductWrapper> caseProductBancassuranceList = new List<CaseProductNumberService.CaseProductWrapper>();

                    if (bancassuranceResponse != null && bancassuranceResponse.GetBancassuranceAccountResponse != null && 
                        bancassuranceResponse.GetBancassuranceAccountResponse.InsurancePolicyListCRMInqResponse != null &&
                        bancassuranceResponse.GetBancassuranceAccountResponse.InsurancePolicyListCRMInqResponse.InsurancePolicyListCRMInqResult != null) {
                            List<BancassuranceResponse.DataSets> insurancePolicyList = bancassuranceResponse.GetBancassuranceAccountResponse.InsurancePolicyListCRMInqResponse.InsurancePolicyListCRMInqResult.DataSets;
                            CaseProductNumberService.CaseProductWrapper caseProd = null;
                            Integer count = 1;

                            System.debug('total insurancePolicyList ' + insurancePolicyList.size());

                            for (BancassuranceResponse.DataSets insurancePolicy : insurancePolicyList) {
                                caseProd = new CaseProductNumberService.CaseProductWrapper(
                                    count,
                                    insurancePolicy.POLICY_NO,
                                    insurancePolicy.POLICY_NO,
                                    null,
                                    'Bancassurance',
                                    insurancePolicy.PRODUCT_GROUP,
                                    insurancePolicy.POLICY_NAME);

                                caseProductBancassuranceList.add(caseProd);
                                count++;
                            }
                    }

                    if(caseProductBancassuranceList.size() == 0){
                        pageMessage = System.Label.Customer_Product_Not_Found_Bancassurance;
                        pageMessage2 = pageMessage;
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,pageMessage));
                    } else {
                        caseProductBancassuranceAll = new List<CaseProductNumberService.CaseProductWrapper>();
                        caseProductBancassuranceAll = caseProductBancassuranceList;
                    }

                    System.debug('total bancassurance account ' + caseProductBancassuranceList.size());

                    setPagination(caseProductBancassuranceList);
                    nextBA();
                }
            }
	       
        } catch (Exception e) {
            pageMessage = System.Label.Customer_Product_ERR002+'<br/>'+System.Label.Customer_Product_ERR003;
			errorCodeText = e.getStackTraceString();
			setErrorResponseOnlineServiceLog(OSC005_NAME,pageMessage,errorCodeText,'');
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
	        System.debug('Show Error Message '+pageMessage);
			System.debug('There is error during processing : ' + e.getStackTraceString());
        }

        return null;
     }

    /* New */
    public Object processResponseWsInvestment(List<String> responseBodies, List<String> unitHolderNoList) {
        List<CaseProductNumberService.CaseProductWrapper> caseProductInvestmentList = new List<CaseProductNumberService.CaseProductWrapper>();
        Integer order = 1;
        Set<String> allStatus = new Set<String>();
        List<String> successList = new List<String>();
        String status = '';
        try {

            requestOSC015 = true;
            Integer position = 0;

            for (String responseBody : responseBodies) {
                //System.debug('OSC06| responseBody : ' + order++ + ' : ' + responseBody);
    
                if (responseBody == null || responseBody == '') {
                    // pageMessage = System.Label.Customer_Product_ERR001+'<br/>'+System.Label.Customer_Product_ERR003;
                //     errorCodeText = 'Null response body.';
                //     setErrorResponseOnlineServiceLog(OSC006_NAME, pageMessage, errorCodeText);
                    continue;
                } else {
                    InvestmentResponse investmentResponse = null;
                   
                    System.debug('Order : ' + order);
                    try {
                        investmentResponse = (InvestmentResponse) System.JSON.deserialize(responseBody, InvestmentResponse.class);
                    } catch (Exception e) {
                        System.debug(e.getMessage() + ' Cannot parse json for ' + order++ + ' :: ' + responseBody);
                        continue;
                    }
                    status = investmentResponse.Status.StatusDesc;
                    if (status != null) {
                        if (status != 'success') {
                            allStatus.add(status);
                        } else {
                            successList.add(status);
                        }
                    }

                    if (investmentResponse != null && investmentResponse.GetInvestmentAccountResponse !=null) {
                        List<InvestmentResponse.GetFundDetails> fundDetailList = investmentResponse.GetInvestmentAccountResponse.GetFundDetails;
                        CaseProductNumberService.CaseProductWrapper caseProd = null;
                        Integer count = 1;

                        String fundCode = '';
                        String unitHolderNo = '';
                        if (fundDetailList == null) {
                            continue;
                        }
                        else if(fundDetailList.size() == 0) {
                            fundCode = '';
                            unitHolderNo = unitHolderNoList[position];

                            caseProd = new CaseProductNumberService.CaseProductWrapper();
                            
                            caseProd.rowNum = 1;
                            caseProd.apiAccountNumber = unitHolderNo;
                            caseProd.apiAccountNumberMarking = unitHolderNo;
                            caseProd.apiSuffix = fundCode;
                            caseProd.apiProductType = 'Investment';
                            caseProd.apiProductSubGroup = System.Label.INT_Investment_Record_Not_Found;
                            caseProd.apiProductName =  '';
                            caseProductInvestmentList.add(caseProd);
                            position++;
                        } else if (fundDetailList.size() > 0) {
                            for (InvestmentResponse.GetFundDetails fundDetail : fundDetailList) {
                                fundCode = fundDetail.FundCode;
                                unitHolderNo = fundDetail.detailFund.UnitHolderNo;
        
                                caseProd = new CaseProductNumberService.CaseProductWrapper();
                            
                                caseProd.rowNum = count;
                                caseProd.apiAccountNumber = unitHolderNo;
                                caseProd.apiAccountNumberMarking = unitHolderNo;
                                caseProd.apiSuffix = fundCode;
                                caseProd.apiProductType = 'Investment';
                                
                                if(OnlyProductWithProductCode.containsKey(fundCode)) {
                                    caseProd.apiProductSubGroup = OnlyProductWithProductCode.get(fundCode).Product_Sub_group;
                                    caseProd.apiProductName =  OnlyProductWithProductCode.get(fundCode).Name;
                                } else {
                                    caseProd.apiProductSubGroup = '#N/A';
                                    caseProd.apiProductName =  '#N/A';
                                }
        
                                caseProductInvestmentList.add(caseProd);
                                count++;
                            }
                        }
    
                    }

                    System.debug('Order : ' + order++ + ' Success');
                }
            }
            if(pageMessage3 == null || pageMessage3 == '') {
                if (responseBodies.size() == 0) {
                    // pageMessage = System.Label.Customer_Product_Timeout+'<br/>'+System.Label.Customer_Product_ReRequest+'<br/>'+System.Label.Customer_Product_ERR003;
                    pageMessage = System.Label.Customer_Product_Not_Found_Investment;
                    pageMessage3 = pageMessage;
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,pageMessage));
                } else {
                    if (allStatus.size() != 0 || successList.size() == 0) {
                        pageMessage = System.Label.Customer_Product_ERR001+'<br/>'+System.Label.Customer_Product_ERR003;
                        pageMessage3 = pageMessage;
                    } else {
                        if(caseProductInvestmentList.size() == 0){
                            pageMessage = System.Label.Customer_Product_Not_Found_Investment;
                            pageMessage3 = pageMessage;
                            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,pageMessage));
                        } else {
                            caseProductInvestmentAll = new List<CaseProductNumberService.CaseProductWrapper>();
                            caseProductInvestmentAll = caseProductInvestmentList;
                        }
                    }
                }
            }

            System.debug('total investment account ' + caseProductInvestmentList.size());

            setPagination(caseProductInvestmentList);
            nextInvestment();

        } catch (Exception e) {
            pageMessage = System.Label.Customer_Product_ERR002+'<br/>'+System.Label.Customer_Product_ERR003;
			errorCodeText = e.getStackTraceString();
			setErrorResponseOnlineServiceLog(OSC006_NAME, pageMessage, errorCodeText,'');
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
	        System.debug('Show Error Message '+pageMessage);
			System.debug('There is error during processing : ' + e.getStackTraceString());
        }

        return null;
    }

    //public List<CaseInvestmentProduct> productInvestmentList {get;set;}

    public void setErrorResponseOnlineServiceLog(string serviceName,string pageMessage,string errorCodeText, string muleId){
        paginationObj = null;//Reset pagination
        
        // set pageMessage
        if(serviceName == OSC001_NAME) {
            pageMessage1 = pageMessage;
        } else if(serviceName == OSC005_NAME) {
            pageMessage2 = pageMessage;
        } else if(serviceName == OSC006_NAME) {
            pageMessage3 = pageMessage;
        }

		ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,pageMessage));
		RTL_CampaignUtil.saveToOnlineLog(FALSE,accObj.Name,errorCodeText,muleId/*mule id*/, userName,tmbCustomerID,serviceName,requestBody,responseBody,accObj,startTime,endTime);

    }

    /* New */
    public List<CaseProductNumberService.CaseProductWrapper> getcaseProductDepositAndLoanList(CustomerAccountResponse customerAccountResponse) {
        List<CaseProductNumberService.CaseProductWrapper> returnList = new List<CaseProductNumberService.CaseProductWrapper>();
        CaseProductNumberService.CaseProductWrapper caseProd = null;

        if (customerAccountResponse != null && customerAccountResponse.GetCustomerAccountResponse != null) {
            
            Integer count = 1;

            if (customerAccountResponse.GetCustomerAccountResponse.DepositAccounts != null &&
                customerAccountResponse.GetCustomerAccountResponse.DepositAccounts.DepositAccount != null) {
                    List<CustomerAccountResponse.DepositAccount> depositAccountList = customerAccountResponse.GetCustomerAccountResponse.DepositAccounts.DepositAccount;
                    for (CustomerAccountResponse.DepositAccount depositAccount : depositAccountList) {
                        caseProd = new CaseProductNumberService.CaseProductWrapper();
                        
                        caseProd.rowNum = count;
                        caseProd.apiAccountNumber = NumberHelper.TrimDepositAccountNo10Digit(depositAccount.AccountNumber);
                        caseProd.apiAccountNumberMarking = NumberHelper.MarkAccountNo(NumberHelper.TrimDepositAccountNo10Digit(depositAccount.AccountNumber));
                        caseProd.apiSuffix = NumberHelper.trimSuffixAccountNo(depositAccount.AccountNumber);
                        caseProd.apiProductType = 'Deposit';

                        if(OnlyProductWithProductCode.containsKey(depositAccount.ProductCode)) {
                            caseProd.apiProductSubGroup = OnlyProductWithProductCode.get(depositAccount.ProductCode).Product_Sub_group;
                            caseProd.apiProductName =  OnlyProductWithProductCode.get(depositAccount.ProductCode).Name;
                        } else {
                            caseProd.apiProductSubGroup = '#N/A';
                            caseProd.apiProductName =  '#N/A';
                        }

                        returnList.add(caseProd);
                        count++;
                    }

            }

            if (customerAccountResponse.GetCustomerAccountResponse.LoanAccounts != null &&
                customerAccountResponse.GetCustomerAccountResponse.LoanAccounts.LoanAccount != null) {
                    List<CustomerAccountResponse.LoanAccount> loanAccountList = customerAccountResponse.GetCustomerAccountResponse.LoanAccounts.LoanAccount;
                    for (CustomerAccountResponse.LoanAccount loanAccount: loanAccountList) {
                        caseProd = new CaseProductNumberService.CaseProductWrapper();

                        caseProd.rowNum = count;
                        caseProd.apiAccountNumber = NumberHelper.TrimLoanAccountNo(loanAccount.AccountNumber);
                        caseProd.apiAccountNumberMarking = NumberHelper.MarkAccountNo(NumberHelper.TrimLoanAccountNo(loanAccount.AccountNumber));
                        caseProd.apiSuffix = NumberHelper.trimSuffixAccountNo(loanAccount.AccountNumber);
                        caseProd.apiProductType = 'Loan';
                        if(OnlyProductWithProductCode.containsKey(loanAccount.ProductCode)){
                            //find product subgroup and name from product code
                            caseProd.apiProductSubGroup = OnlyProductWithProductCode.get(loanAccount.ProductCode).Product_Sub_group;
                            caseProd.apiProductName =  OnlyProductWithProductCode.get(loanAccount.ProductCode).Name;
                        } else {
                            caseProd.apiProductSubGroup = '#N/A';
                            caseProd.apiProductName =  '#N/A';
                        }

                        returnList.add(caseProd);
                        count++;
                    }
                    
            }

            System.debug('total deposit/loan account ' + count);
        }

        return returnList;
    }

    /* Old */
    public List<CaseProductNumberService.CaseProductWrapper> getcaseProductDepositAndLoanList() {
        List<CaseProductNumberService.CaseProductWrapper> returnList = new List<CaseProductNumberService.CaseProductWrapper>();

            if (productAccounts != null && (productAccounts.Accounts != null || productAccounts.Accounts.Deposits != null || productAccounts.Accounts.Investments !=null)) {

                Integer count = 1;
                //add deposit to wrapper class
                if (productAccounts.accounts.Deposits.size() > 0 ) {
                    for (CaseAccountProduct.Deposits dp : productAccounts.accounts.Deposits) {
                        CaseProductNumberService.CaseProductWrapper caseProd = new CaseProductNumberService.CaseProductWrapper();

	                       caseProd.rowNum = count;
	                       caseProd.apiAccountNumber = NumberHelper.TrimDepositAccountNo10Digit(dp.accountNumber);
	                       caseProd.apiAccountNumberMarking = NumberHelper.MarkAccountNo(NumberHelper.TrimDepositAccountNo10Digit(dp.accountNumber));
	                       caseProd.apiSuffix = NumberHelper.trimSuffixAccountNo(dp.accountNumber);
	                       caseProd.apiProductType = 'Deposit';
	                       if(OnlyProductWithProductCode.containsKey(dp.productCode)){
	                       		//find product subgroup and name from product code
	                       		caseProd.apiProductSubGroup = OnlyProductWithProductCode.get(dp.productCode).Product_Sub_group;
	                       		caseProd.apiProductName =  OnlyProductWithProductCode.get(dp.productCode).Name;
	                       }else{
	                       		caseProd.apiProductSubGroup = '#N/A';
	                       		caseProd.apiProductName =  '#N/A';
	                       }
	                       
                        returnList.add(caseProd);
                        count++;
                    }

                }

                //add loan to wrapper class
                if (productAccounts.accounts.Loans.size() > 0 ) {
                    for (CaseAccountProduct.Loans loan : productAccounts.accounts.Loans) {

                       CaseProductNumberService.CaseProductWrapper caseProd = new CaseProductNumberService.CaseProductWrapper();

                       caseProd.rowNum = count;
                       caseProd.apiAccountNumber = NumberHelper.TrimLoanAccountNo(loan.accountNumber);
                       caseProd.apiAccountNumberMarking = NumberHelper.MarkAccountNo(NumberHelper.TrimLoanAccountNo(loan.accountNumber));
                       caseProd.apiSuffix = NumberHelper.trimSuffixAccountNo(loan.accountNumber);
                       caseProd.apiProductType = 'Loan';
                       if(OnlyProductWithProductCode.containsKey(loan.productCode)){
                       		//find product subgroup and name from product code
                       		caseProd.apiProductSubGroup = OnlyProductWithProductCode.get(loan.productCode).Product_Sub_group;
                       		caseProd.apiProductName =  OnlyProductWithProductCode.get(loan.productCode).Name;
                       }else{
                       		caseProd.apiProductSubGroup = '#N/A';
                       		caseProd.apiProductName =  '#N/A';
                       }

                        returnList.add(caseProd);
                        count++;
                    }

                }

                //add investment to list
                if(productAccounts.accounts.investments.size() > 0){
                    for (CaseAccountProduct.Deposits inv : productAccounts.accounts.investments) {
                        //collect unitHolderNos for OSCWs16
                        unitHolderNoslist.add(inv.accountNumber);
                    }
                }

                system.debug('unitHolderNoslist'+unitHolderNoslist);
            }
           if(returnList!=null){
           		caseProductDepositAndLoanAll = new List<CaseProductNumberService.CaseProductWrapper>();
           	 	caseProductDepositAndLoanAll.addAll(returnList);

           }
        
        return returnList;

    }


    public PageReference searchProductNumber() {

        List<CaseProductNumberService.CaseProductWrapper> productList = new List<CaseProductNumberService.CaseProductWrapper>();
        productType = apexpages.currentpage().getparameters().get('productType');
        system.debug('productType' + productType);

        if (productType == 'DepositLoan') {
            productList = caseProductDepositAndLoanAll;
            searchProduct = searchProduct1;
        } else if (productType == 'Bancassurance') {
            productList = caseProductBancassuranceAll;
            searchProduct = searchProduct2;
        } else if (productType == 'Investment') {
            productList = caseProductInvestmentAll;
            searchProduct = searchProduct3;
        }

        system.debug('searchProduct : '+searchProduct);


        if (searchProduct != null && productList!= null) {
            Map<String, CaseProductNumberService.CaseProductWrapper> searchlist = new Map<String, CaseProductNumberService.CaseProductWrapper>();

            for (CaseProductNumberService.CaseProductWrapper datalist : productList) {

                if (datalist.apiAccountNumber!= null && containsIgnoreCase(datalist.apiAccountNumber,searchProduct)) {
                    //find account number
                    searchlist.put(datalist.apiAccountNumber, datalist);
                } else if (datalist.apiSuffix!=null && containsIgnoreCase(datalist.apiSuffix,searchProduct)) {
                    //find suffix
                    searchlist.put(datalist.apiAccountNumber, datalist);
                } else if (datalist.apiProductSubGroup!=null && containsIgnoreCase(datalist.apiProductSubGroup,searchProduct)) {
                    //find product sub group
                    searchlist.put(datalist.apiAccountNumber, datalist);
                } else if (datalist.apiProductName!= null && containsIgnoreCase(datalist.apiProductName,searchProduct)) {
                    //find product name
                    searchlist.put(datalist.apiAccountNumber, datalist);
                }

            }

            if (productType == 'DepositLoan') {
                caseProductDepositAndLoan = searchlist.values();
                setPagination(caseProductDepositAndLoan);
                nextDepositAndLoan();
            } else if (productType == 'Bancassurance') {
                caseProductBancassurance = searchlist.values();
                setPagination(caseProductBancassurance);
                nextBA();

            } else if (productType == 'Investment') {
                caseProductInvestment = searchlist.values();
                setPagination(caseProductInvestment);
                nextInvestment();
            }

        }


        return null;

    }

    public PageReference clearSearch() {

        if (productType == 'DepositLoan') {
        	searchProduct1 = null;
            caseProductDepositAndLoan = caseProductDepositAndLoanAll;
            setPagination(caseProductDepositAndLoan);
            nextDepositAndLoan();
        } else if (productType == 'Bancassurance') {
        	searchProduct2 = null;
            caseProductBancassurance = caseProductBancassuranceAll;
            setPagination(caseProductBancassurance);
            nextBA();
        } else if (productType == 'Investment') {
        	searchProduct3 = null;
            caseProductInvestment = caseProductInvestmentAll;
            setPagination(caseProductInvestment);
            nextInvestment();
        }

        return null;

    }

    public static boolean containsIgnoreCase(String strData, String strFind){
	    return strData.toLowerCase().contains(strFind.toLowerCase());
	}

    private Integer productNumberPerPage {
        get{
            if ( productNumberPerPage == null ) {
                Case_Product_Number_Page__mdt prodPerpage = [select id, ProductDisplay__c
                from Case_Product_Number_Page__mdt
                where DeveloperName = 'ProductNumberPagination'];

                productNumberPerPage = integer.valueOf(prodPerpage.ProductDisplay__c);
            }
            return productNumberPerPage;
        }
        set;
    }

    public void setPagination(List<CaseProductNumberService.CaseProductWrapper> lst) {
        paginationObj = new CustomIterable (lst);
        paginationObj.setPageSize = productNumberPerPage;
        system.debug('osc14 : '+requestOSC014+'osc15 : '+requestOSC015+'osc16 : '+requestOSC016);

    }

    public PageReference setPaginationObj() {
        tabindex = apexpages.currentpage().getparameters().get('tabindex');

        if (tabindex == '0' && caseProductDepositAndLoanAll!=null) {
            setPagination(caseProductDepositAndLoanAll);
            nextDepositAndLoan();
        } else if (tabindex == '-1' && caseProductBancassuranceAll !=null) {
    		setPagination(caseProductBancassuranceAll);
        	nextBA();
        }else if (tabindex == '-2' && caseProductInvestmentAll !=null) {
    		setPagination(caseProductInvestmentAll);
    		nextInvestment();
        }else{
        	List<CaseProductNumberService.CaseProductWrapper> blanklist = new List<CaseProductNumberService.CaseProductWrapper> ();
        	setPagination(blanklist);
        }

        
        return null;
    }


    //custom class use for paginate wrapper classs
    class  CustomIterable implements Iterator<list<CaseProductNumberService.CaseProductWrapper>> {
        list<CaseProductNumberService.CaseProductWrapper> ProductList {get; set;}
        list<CaseProductNumberService.CaseProductWrapper> PaginationList {get; set;}

        Integer i {get; set;}
        Integer startNo {get; set;}
        public Integer setPageSize {get; set;}

        public CustomIterable(List<CaseProductNumberService.CaseProductWrapper> lst) {
            ProductList = new list<CaseProductNumberService.CaseProductWrapper >();
            PaginationList = new list<CaseProductNumberService.CaseProductWrapper >();
            ProductList = lst;
            setPageSize = (lst!=null)?lst.size():10;
            i = 0;
        }

        public boolean hasNext() {
            if (i >= ProductList.size()) {
                return false;
            } else {
                return true;
            }
        }

        public boolean hasPrevious() {
            if (i <= setPageSize) {
                return false;
            } else {
                return true;
            }
        }

        public list<CaseProductNumberService.CaseProductWrapper > next() {

            PaginationList = new list<CaseProductNumberService.CaseProductWrapper >();
            integer startNumber;
            integer size = ProductList.size();
            if (hasNext()) {
                if (size <= (i + setPageSize)) {
                    startNumber = i;
                    i = size;
                } else {
                    i = (i + setPageSize);
                    startNumber = (i - setPageSize);
                }
                startNo = startNumber + 1;
                for (integer start = startNumber; start < i; start++) {
                    PaginationList.add(ProductList[start]);
                }
            }
            return PaginationList;
        }

        public list<CaseProductNumberService.CaseProductWrapper > previous() {
            PaginationList = new list<CaseProductNumberService.CaseProductWrapper >();

            integer size = ProductList.size();
            if (i == size) {
                if (math.mod(size, setPageSize) > 0) {
                    i = size - math.mod(size, setPageSize);
                } else {
                    i = (size - setPageSize);
                }
            } else {
                i = (i - setPageSize);
            }
            startNo = (i - setPageSize) + 1;
            for (integer start = (i - setPageSize); start < i; ++start) {
                PaginationList.add(ProductList[start]);
            }
            return PaginationList;
        }
    }


    public Boolean hasNext {
        get
        {
            return paginationObj.hasNext();
        }
        set;
    }

    public Boolean hasPrevious {
        get
        {
            return paginationObj.hasPrevious();
        }
        set;
    }

    public void nextDepositAndLoan() {

        caseProductDepositAndLoan = paginationObj.next();

    }

    public void previousDepositAndLoan() {
        caseProductDepositAndLoan = paginationObj.previous();

    }

    public void nextBA() {

        caseProductBancassurance = paginationObj.next();

    }

    public void previousBA() {
        caseProductBancassurance = paginationObj.previous();

    }

    public void nextInvestment() {

        caseProductInvestment = paginationObj.next();

    }

    public void previousInvestment() {
        caseProductInvestment = paginationObj.previous();

    }

    public Integer allPageNo {
        get
        {
            return paginationObj.ProductList.size();
        }
        set;
    }

    public Integer pageNoFrom {
        get
        {
            return paginationObj.startNo;
        }
        set;
    }

    public Integer pageNoTo {
        get
        {
            return paginationObj.i;
        }
        set;
    }

}