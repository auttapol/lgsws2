public class CustomerWealthGetProductSummary {
    
    public class ContinuationState {
        public String name {get; set;}
        public String userName {get; set;}
        public String tmbCustomerID {get; set;}
        public String requestBody {get; set;}
        public DateTime startTime {get; set;}
        public Account accObj {get; set;}

        public ContinuationState(String n, String user, String custId, String request, DateTime stTime, Account obj){
            this.name = n;
            this.userName = user;
            this.tmbCustomerID = custId;
            this.requestBody = request;
            this.startTime = stTime;
            this.accObj = obj;
        }
    }

    public class ProductSummary{
        public String BA;
        public String MF;
        public String Deposit;
        public String Credit;
        public String CreditLimit;
        public String Loan;
        public String LoanLimit;
    }

    private static String userName;/* current user FirstName + LastName */
	public static String tmbCustomerID {get; set;}
    public static String citizenId {get; set;}
	public static String itemNumber {get; set;}
    public static String accountId {get; set;}
    public static String productType {get; set;}
    public static String tabindex { get; set;}
    public static String searchProduct {get; set;}
    public static String searchProduct1 {get; set;}//DepositAndLoan
    public static String searchProduct2 {get; set;}//Bancassurance
    public static String searchProduct3 {get; set;}//Investment

    public static String requestBody;
    public static String requestLabel;
    public static String responseBody;
    public static String errorCodeText {get;set;}
    private static DateTime startTime;
    private static DateTime endTime;
    public static AppConfig__c mc;
    public static AppConfig__c appId;
    public static Account accObj {get; set;}

    // Name of product group
    private static final String  CREDIT = 'CREDIT';
    private static final String  CREDIT_LIMIT = 'CREDIT LIMIT';
    private static final String  LOAN = 'LOAN';
    private static final String  LOAN_LIMIT = 'LOAN LIMIT';
    private static final String  DEPOSIT = 'DEPOSIT';
    private static final String  MF = 'MF';
    private static final String  BA = 'BA';
    // Add new variable for sum amount
    public static Map<String,Double> BalanceSum = new Map<String, Double>();

    private static final String OSC014_NAME = 'customerProductDepositAndLoan';
    private static final String OSC015_NAME = 'customerProductInvestment';
    private static final String OSC016_NAME = 'customerProductBancassurance';
    private static final String OSC017_NAME = 'customerProductWealth';

	public static List<CaseProductNumberService.CaseProductWrapper> caseProductInvestmentAll {get;set;}
    
    public static List<CaseInvestmentProduct> productInvestmentList {get;set;}
    public static List<CaseProductNumberService.CaseProductWrapper> caseProductBancassuranceAll {get;set;}

    public static CaseBAProduct productBAs {
        get{
            if ( productBAs == null ) {
                productBAs = new CaseBAProduct();
            }
            return productBAs;
        }
        set;
    }

    public static CsvGetWealthCustomer custInfo {
        get{
            if ( custInfo == null ) {
                custInfo = new CsvGetWealthCustomer();
            }
            return custInfo;
        }
        set;
    }

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

    @AuraEnabled
    public static String getCustomerInfo(String accId) {
        String lastUpdate;
        getCustomerSegmentAndTMBCusId(accId);
        
        lastUpdate = accObj.LastGetOsc17__c.format('dd/MM/yyyy HH:mm:ss');

        return lastUpdate;

    }

	public static void getCustomerSegmentAndTMBCusId(String accId) {
        try {

            accObj = [SELECT Name
                             ,Segment_crm__c
                             ,TMB_Customer_ID_PE__c
                             ,Core_Banking_Suggested_Segment__c
                             ,ID_Number_PE__c
                             ,Owner.UserProfileName__c
                             ,LastGetOsc17__c
                             ,Osc17TempValueJson__c
                      FROM Account
                      Where id = : accId limit 1];
            system.debug('Customer Segement : ' + accObj);

            //get tmb cus id
            if (accObj != null && accObj.TMB_Customer_ID_PE__c != null) {
            	tmbCustomerID = (tmbCustomerID!=null)?null: accObj.TMB_Customer_ID_PE__c;
                citizenId = (citizenId!=null)?null: accObj.ID_Number_PE__c;
            }
            system.debug('tmbCustomerID' + tmbCustomerID);

        } catch (Exception e) {
            system.debug('get customer segment on case : ' + e);
        }

    }

    @AuraEnabled
    public static Boolean isNeedUpdateOsc17 (String custId){
        Boolean isNeedUpdate = false;
        Datetime lastUpdate = DateTime.now();
        if (custId != null && custId != ''){
            getCustomerSegmentAndTMBCusId(custId);
            // system.debug('Customer Segement : ' + acc);
            if (accObj.LastGetOsc17__c != null){
                if (accObj.LastGetOsc17__c < lastUpdate.addHours(-6)){
                    isNeedUpdate = true;
                }
            }
            else{
                isNeedUpdate = true;
            }
        }
        else{
            isNeedUpdate = true;
        }
        return isNeedUpdate;
    }

    @AuraEnabled
    public static List<List<String>> getOsc17FromStampValue (String custId){
        List<List<String>> result = new List<List<String>>();
        List<String> ban = new List<String>();
        List<String> mutualFund = new List<String>();
        List<String> depo = new List<String>();
        List<String> lo = new List<String>();
        List<String> loLimit = new List<String>();
        List<String> cd = new List<String>();
        List<String> cdLimit = new List<String>();

        getCustomerSegmentAndTMBCusId(custId);
        ProductSummary prdSum = (ProductSummary) System.JSON.deserialize((String)accObj.Osc17TempValueJson__c, ProductSummary.class);

        // index 0 is BA
        ban.add(BA);
        ban.add(prdSum.BA);
        // index 1 is MF
        mutualFund.add(MF);
        mutualFund.add(prdSum.MF);
        // index 2 is Deposit
        depo.add(DEPOSIT);
        depo.add(prdSum.Deposit);
        // index 3 is Credit
        cd.add(CREDIT);
        cd.add(prdSum.Credit);
        // index 4 is Credit Limit
        cdLimit.add(CREDIT_LIMIT);
        cdLimit.add(prdSum.CreditLimit);
        // index 5 is Loan
        lo.add(LOAN);
        lo.add(prdSum.Loan);
        // index 6 is Loan Limit
        loLimit.add(LOAN_LIMIT);
        loLimit.add(prdSum.LoanLimit);
        
        result.add(ban);
        result.add(mutualFund);
        result.add(depo);
        result.add(cd);
        result.add(cdLimit);
        result.add(lo);
        result.add(loLimit);

        return result;
    }

    @AuraEnabled
    public static void updateOsc17ToCustomer (String custId, List<List<String>> newValue){
        
        Account acc = [SELECT Id
                             ,LastGetOsc17__c
                             ,Osc17TempValueJson__c
                       FROM Account
                       Where id = : custId limit 1];

        ProductSummary prdSum = new ProductSummary();
        
        // index 0 is BA, value at index 1
        prdSum.BA = newValue[0][1];
        // index 1 is MF, value at index 1
        prdSum.MF = newValue[1][1];
        // index 2 is Deposit, value at index 1
        prdSum.Deposit = newValue[2][1];
        // index 3 is Credit, value at index 1
        prdSum.Credit = newValue[3][1];
        // index 4 is Credit Limit, value at index 1
        prdSum.CreditLimit = newValue[4][1];
        // index 5 is Loan, value at index 1
        prdSum.Loan = newValue[5][1];
        // index 6 is Loan Limit, value at index 1
        prdSum.LoanLimit = newValue[6][1];

        // update field Osc17 Temp Value Json.
        acc.Osc17TempValueJson__c = (string) System.JSON.Serialize(prdSum);

        // update timestamp as well
        acc.LastGetOsc17__c = DateTime.now();


        // update Osc17 value.
        update acc;
    }

    //=================== Get API Token ==========================//
    @AuraEnabled
    public static String getAccessToken(String endpoint, String projectKey) {
        String access_token = APIGateway_Service.getAccessToken(endpoint, projectKey);
        // system.debug('Token: ' + access_token);
        return access_token;
    }

    //============= Start Call All Product ======================//
    @AuraEnabled (continuation=true cacheable=true)
    public static Object startCallAllProducts(String custId, String nameCredential, String serviceName) {

        system.debug('custId: ' + custId);
        getCustomerSegmentAndTMBCusId(custId);
        String accessToken = getAccessToken(nameCredential, serviceName);
        // system.debug('unitHolderNoslist: ' + unitHolderNoslist);
        // getCustomerSegmentAndTMBCusId(aId);
        userName = UserInfo.getName();
        String endpoint;
        startTime = DateTime.now();
        String request_dt = Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        system.debug('request_dt: ' + request_dt);

        // Create continuation with a timeout
        Continuation con = new Continuation(TIMEOUT_INT_SECS);
        // Set callback method
        con.continuationMethod = 'processResponseAllProduct';
        // Set State to pass parameter
        con.state = new ContinuationState('Call All Product', userName,tmbCustomerID, requestBody, startTime, accObj);

        //============= Start WsOSC16 Bancassurance======================//
        CaseBAProduct.Request reqObjBa = new CaseBAProduct.Request();
        if (tmbCustomerID != null && tmbCustomerID != '') {
            string tmbcusright = tmbCustomerID.substring(tmbCustomerID.length() - 14);
            CaseBAProduct.Queries queryBa = new  CaseBAProduct.Queries();
            queryBa.customerId =  tmbcusright;
            reqObjBa.query =  queryBa;
        }
        requestBody = reqObjBa.parseObjToJson(reqObjBa);
        system.debug('requestBody ' + requestBody);
        // Create callout request
        HttpRequest reqBa = new HttpRequest();
        reqBa.setMethod('POST');
        mc = AppConfig__c.getValues('WsOSC16');
        endpoint = mc == null ? 'https://tmbcrmservices.tmbbank.com' : mc.Value__c;//default enf point value
        reqBa.setEndpoint(endpoint);//app config end point
        reqBa.setBody(requestBody);
        con.addHttpRequest(reqBa);
        system.debug('request : ' + reqBa);
        //============= End WsOSC16 Bancassurance======================//

        //============= Start WsOSC17 Depoist MF Loan Credit======================//
        CsvGetWealthCustomer.Request reqObj = new CsvGetWealthCustomer.Request();

        system.debug('citizenId: ' + citizenId);

        if (citizenId != null && citizenId != '') {
            // string tmbcusright = tmbCustomerID.substring(tmbCustomerID.length() - 14);
            CsvGetWealthCustomer.CustomerInformationRequest requestInfo = new  CsvGetWealthCustomer.CustomerInformationRequest();
            requestInfo.GetCustomerWealth =  new CsvGetWealthCustomer.GetCustomerWealthRequest();
            requestInfo.GetCustomerWealth.CitizenID = citizenId;
            reqObj.CustomerInformation =  requestInfo;
        }

        requestBody = reqObj.parseObjToJson(reqObj);
        system.debug('requestBody ' + requestBody);

        // Create callout request
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        // Set Request Header
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('ChannelName', 'BA');
        req.setHeader('RqID', NumberHelper.generateUID());
        req.setHeader('RqDT', request_dt);
        // system.debug('Header: ' + req.getHeader('ChannelName') + req.getHeader('RqID') + req.getHeader('RqDT'));

        // appId = AppConfig__c.getValues('WsOSC17_Request_App_Id');
        // appIDName = (appId == null)? 'A0291':appId.Value__c;//default app id

        // mc = AppConfig__c.getValues('WsOSC17');
        // endpoint = mc == null ? 'https://tmbcrmservices.tmbbank.com' : mc.Value__c;//default enf point value
        // req.setEndpoint(endpoint);//app config end point

        //================Set Endpoin via API Gateway==============
        req.setHeader('Authorization', 'bearer ' + accessToken);
        // system.debug('Authorization: ' + req.getHeader('Authorization'));
        // req.setEndpoint('https://apis-uat.tau2904.com/v1.0/customers/portfolio/financial');
        req.setEndpoint('callout:' + serviceName);
        

        req.setBody(requestBody);
        // system.debug('Request Body: ' + req.getBody());
        con.state = new ContinuationState('Call OSC17', userName,tmbCustomerID, requestBody, startTime, accObj);
        con.addHttpRequest(req);
        system.debug('request : ' + req);
        //============= End WsOSC17 Depoist MF Loan Credit======================//

        return con;
    }

    @AuraEnabled (cacheable=true)
    public static List<List<String>> processResponseAllProduct(List<String> labels, Object state) {
	    
        ContinuationState state1 = (ContinuationState)state;
        List<List<String>> resultList = new List<List<String>>();
        Map<String, String> result = new Map<String, String>();
        Integer i = 0;
        try {
	        system.debug('==== start process response all products ============');
            system.debug('labels: ' + labels);

            // Process OSC16 response
	        HttpResponse responseOsc16 = Continuation.getResponse(labels[i]);
            List<String> resultOsc16 = getResultOSC16(responseOsc16, state1);
            if (resultOsc16.size() > 0){
                resultList.add(resultOsc16);
            }
            i = i + 1;

            // Process OSC17 response
            HttpResponse responseOsc17 = Continuation.getResponse(labels[i]);
            List<List<String>> resultOsc17 = getResultOSC17(responseOsc17, state1);
            if (resultOsc17.size() > 0){
                resultList.addAll(resultOsc17);
            }

            system.debug('resultList: ' + resultList);
			
	        system.debug('==== end process response all products ============');

	    }catch(DMLException e) {
			String pageMessage = System.Label.Customer_Product_ERR002+'<br/>'+System.Label.Customer_Product_ERR003;
			errorCodeText = e.getStackTraceString();
			setErrorResponseOnlineServiceLog(OSC017_NAME, state1, errorCodeText);

	        System.debug('Show Error Message '+pageMessage);
			System.debug('There is error during processing : ' + e.getStackTraceString());
            AuraHandledException ex = new AuraHandledException(System.Label.Customer_Product_ERR002+'\n'+System.Label.Customer_Product_ERR003);
            ex.setMessage(System.Label.Customer_Product_ERR002+'\n'+System.Label.Customer_Product_ERR003);
            system.debug(e);
            throw e;
	    }

        return resultList;
    }

    @AuraEnabled
    public static Map<String, Double> getMapData(){
        return BalanceSum;
    }

    public static void setErrorResponseOnlineServiceLog(string serviceName, ContinuationState state,string errorCodeText){
        String accJSON = JSON.serialize(state.accObj);
		RTL_CampaignUtil.saveToOnlineLogFuture( FALSE
                                                ,state.accObj.Name
                                                ,errorCodeText
                                                ,''/*mule id*/
                                                ,state.userName
                                                ,state.tmbCustomerID
                                                ,serviceName
                                                ,state.requestBody
                                                ,responseBody
                                                ,accJSON
                                                ,state.startTime
                                                ,endTime);
    }

    public static List<String> getResultOSC16(HttpResponse response, ContinuationState state1){
        List<String> result = new List<String>();

        String accJSON = JSON.serialize(state1.accObj);
        system.debug('state.accObj: ' + accJSON);
        endTime = DateTime.now();
        responseBody = null;
        String statusResponse;

        if ( response == null ) {
	            errorCodeText = 'Null response.';
	            responseBody = null;
	            setErrorResponseOnlineServiceLog(OSC016_NAME, state1, errorCodeText);
	            AuraHandledException e = new AuraHandledException(System.Label.Customer_Product_ERR001+'\n'+System.Label.Customer_Product_ERR003);
                e.setMessage(System.Label.Customer_Product_ERR001+'\n'+System.Label.Customer_Product_ERR003);
                system.debug(e);
                throw e;
        } 
        else {
            if( response.getStatusCode() == 2000 ) // if timeout
            {
                errorCodeText = 'Error occur while calling Webservice : Http Status Code '+response.getStatusCode();
                setErrorResponseOnlineServiceLog(OSC016_NAME, state1, errorCodeText);
                AuraHandledException e = new AuraHandledException(System.Label.Customer_Product_Timeout+'\n'+System.Label.Customer_Product_ReRequest+'\n'+System.Label.Customer_Product_ERR003);
                e.setMessage(System.Label.Customer_Product_Timeout+'\n'+System.Label.Customer_Product_ReRequest+'\n'+System.Label.Customer_Product_ERR003);
                system.debug(e);
                throw e;
            }
            if( response.getStatusCode() != 200 && response.getStatusCode() != 2000) // if HTTP Status Code is not a success code
            {
                errorCodeText = 'Error occur while calling Webservice : Http Status Code '+response.getStatusCode();
                setErrorResponseOnlineServiceLog(OSC016_NAME, state1, errorCodeText);
                AuraHandledException e = new AuraHandledException(System.Label.Customer_Product_ERR001+'\n'+System.Label.Customer_Product_ERR003);
                e.setMessage(System.Label.Customer_Product_ERR001+'\n'+System.Label.Customer_Product_ERR003);
                system.debug(e);
                throw e;
            }
            
            system.debug('response: ' + response);
            responseBody = response.getBody();

            if (responseBody == null || responseBody == '') {
                errorCodeText = 'Null response body.';
                setErrorResponseOnlineServiceLog(OSC016_NAME, state1, errorCodeText);
                AuraHandledException e = new AuraHandledException(System.Label.Customer_Product_ERR001+'\n'+System.Label.Customer_Product_ERR003);
                e.setMessage(System.Label.Customer_Product_ERR001+'\n'+System.Label.Customer_Product_ERR003);
                system.debug(e);
                throw e;
            } else{

                productBAs = CaseBAProduct.parseJsonToObj(responseBody);

                if(productBAs!=null){
                    //success response
                    if(productBAs.status.code == '0000'){
                        String pageMessage = productBAs.status.description;
                        RTL_CampaignUtil.saveToOnlineLogFuture( TRUE
                                                                ,state1.accObj.Name
                                                                ,pageMessage
                                                                ,''/*mule id*/
                                                                ,state1.userName
                                                                ,state1.tmbCustomerID
                                                                ,OSC016_NAME
                                                                ,state1.requestBody
                                                                ,responseBody
                                                                ,accJSON
                                                                ,state1.startTime
                                                                ,endTime);
                    }else{
                        //code != 0000
                        // errorCodeText = productAccounts.status.code + ' : ' + productAccounts.status.description;
                        errorCodeText = 'Response invalid cannot parsing!!!';
                        setErrorResponseOnlineServiceLog(OSC016_NAME, state1, errorCodeText);
                        AuraHandledException e = new AuraHandledException(System.Label.Customer_Product_ERR001+'\n'+System.Label.Customer_Product_ERR003);
                        e.setMessage(System.Label.Customer_Product_ERR001+'\n'+System.Label.Customer_Product_ERR003);
                        system.debug(e);
                        throw e;
                    }

                    // caseProductBancassuranceAll = CaseBAProduct.getCustomerProductBancassuranceList(productBAs);

                    if(productBAs.total != null && productBAs.bancassurances != null){
                        Double baSum = 0;
                        for (CaseBAProduct.Bancassurances ba : productBAs.bancassurances) {
                            baSum = baSum + Double.valueOf(ba.sumInsure);
                        }
                        result.add(BA);
                        result.add(String.valueOf(baSum));
                    }
                    else{
                        result.add(BA);
                        result.add(String.valueOf(0));
                    }

                }
            }
        }
        
        return result;
    }

    public static List<List<String>> getResultOSC17(HttpResponse response, ContinuationState state1){
        List<List<String>> result = new List<List<String>>();
        List<String> mutualFund = new List<String>();
        List<String> depo = new List<String>();
        List<String> lo = new List<String>();
        List<String> loLimit = new List<String>();
        List<String> cd = new List<String>();
        List<String> cdLimit = new List<String>();

        String accJSON = JSON.serialize(state1.accObj);
        system.debug('state.accObj: ' + accJSON);
        endTime = DateTime.now();
        responseBody = null;
        String statusResponse;

        system.debug('response: ' + response);

        if ( response == null ) {
            errorCodeText = 'Null response.';
            responseBody = null;
            setErrorResponseOnlineServiceLog(OSC017_NAME, state1, errorCodeText);
            AuraHandledException e = new AuraHandledException(System.Label.Customer_Product_ERR001+'\n'+System.Label.Customer_Product_ERR003);
            e.setMessage(System.Label.Customer_Product_ERR001+'\n'+System.Label.Customer_Product_ERR003);
            system.debug(e);
            throw e;
        }
        else {
            if( response.getStatusCode() == 2000 ) // if timeout
            {
                errorCodeText = 'Error occur while calling Webservice : Http Status Code '+response.getStatusCode();
                setErrorResponseOnlineServiceLog(OSC017_NAME, state1, errorCodeText);
                AuraHandledException e = new AuraHandledException(System.Label.Customer_Product_Timeout+'\n'+System.Label.Customer_Product_ReRequest+'\n'+System.Label.Customer_Product_ERR003);
                e.setMessage(System.Label.Customer_Product_Timeout+'\n'+System.Label.Customer_Product_ReRequest+'\n'+System.Label.Customer_Product_ERR003);
                system.debug(e);
                throw e;
            }
            if( response.getStatusCode() != 200 && response.getStatusCode() != 2000) // if HTTP Status Code is not a success code
            {
                system.debug('StatusCode: ' + response.getStatusCode());
                errorCodeText = 'Error occur while calling Webservice : Http Status Code '+response.getStatusCode();
                setErrorResponseOnlineServiceLog(OSC017_NAME, state1, errorCodeText);
                setErrorResponseOnlineServiceLog(OSC017_NAME, state1, errorCodeText);
                AuraHandledException e = new AuraHandledException(System.Label.Customer_Product_ERR001+'\n'+System.Label.Customer_Product_ERR003);
                e.setMessage(System.Label.Customer_Product_ERR001+'\n'+System.Label.Customer_Product_ERR003);
                system.debug(e);
                throw e;
            }

            responseBody = response.getBody();
            system.debug('responseBody: ' + responseBody);

            
            if (responseBody == null || responseBody == '') {
                errorCodeText = 'Null response body.';
                setErrorResponseOnlineServiceLog(OSC017_NAME, state1, errorCodeText);
                AuraHandledException e = new AuraHandledException(System.Label.Customer_Product_ERR001+'\n'+System.Label.Customer_Product_ERR003);
                e.setMessage(System.Label.Customer_Product_ERR001+'\n'+System.Label.Customer_Product_ERR003);
                system.debug(e);
                throw e;
            } else{

                //Success Reponse parse json
                custInfo = CsvGetWealthCustomer.parseJsonToObj(responseBody);
                system.debug('custInfo: ' + custInfo);

                if (custInfo != null) {
                    RTL_CampaignUtil.saveToOnlineLogFuture( TRUE
                                                            ,state1.accObj.Name
                                                            ,statusResponse
                                                            ,''/*mule id*/
                                                            ,state1.userName
                                                            ,state1.tmbCustomerID
                                                            ,OSC015_NAME
                                                            ,state1.requestBody
                                                            ,responseBody
                                                            ,accJSON
                                                            ,state1.startTime
                                                            ,endTime);
                }else{
                    //found error
                    setErrorResponseOnlineServiceLog(OSC017_NAME, state1, 'ERROR');
                    AuraHandledException e = new AuraHandledException(System.Label.Customer_Product_ERR002+'\n'+System.Label.Customer_Product_ERR003);
                    e.setMessage(System.Label.Customer_Product_ERR002+'\n'+System.Label.Customer_Product_ERR003);
                    system.debug(e);
                    throw e;
                }

                // Deposit and MF data.
                Decimal mfBalance = 0;
                Decimal depositBalance = 0;
                Decimal creditBalance = 0;
                Decimal creditLimit = 0;
                Decimal loanBalance = 0;
                Decimal loanTotalLimit = 0;
                if (custInfo.GetCustomerWealth.CustomerDeposit != null){
                    for (CsvGetWealthCustomer.CustomerDeposit dep : custInfo.GetCustomerWealth.CustomerDeposit){
                        if ((dep.AccountType).contains('MF')){
                            mfBalance = mfBalance + dep.SumAvaiBalance;
                        }
                        else{
                            depositBalance = depositBalance + dep.SumAvaiBalance;
                        }
                    }
                }
                mutualFund.add(MF);
                mutualFund.add(String.valueOf(mfBalance));
                depo.add(DEPOSIT);
                depo.add(String.valueOf(depositBalance));

                // Credit data.
                if (custInfo.GetCustomerWealth.CustomerNonDeposit != null){
                    // CsvGetWealthCustomer.CustomerDepositData custNonDeposit = custInfo.CustomerNonDeposit;
                    for (CsvGetWealthCustomer.CustomerNonDeposit nonDep : custInfo.GetCustomerWealth.CustomerNonDeposit){
                        creditBalance = creditBalance + nonDep.SumAvaiBalance;
                    }
                }
                cd.add(CREDIT);
                cd.add(String.valueOf(creditBalance));

                // Credit Limit.
                if (custInfo.GetCustomerWealth.CustomerCreditLine != null){
                    creditLimit = creditLimit + Decimal.valueOf(custInfo.GetCustomerWealth.CustomerCreditLine);
                    // creditLimit = creditLimit - creditBalance;
                }
                cdLimit.add(CREDIT_LIMIT);
                cdLimit.add(String.valueOf(creditLimit));

                // Loan Data.
                if (custInfo.GetCustomerWealth.CustomerLoan != null){
                    // CsvGetWealthCustomer.CustomerLoanData custLoan = custInfo.CustomerLoan;
                    loanBalance = custInfo.GetCustomerWealth.CustomerLoan.TotalTermLoanBalance
                                  + custInfo.GetCustomerWealth.CustomerLoan.TotalSecureLoanBalance
                                  + custInfo.GetCustomerWealth.CustomerLoan.TotalUnsecureLoanBalance;

                    loanTotalLimit = custInfo.GetCustomerWealth.CustomerLoan.TotalTermLoanLimit
                                     + custInfo.GetCustomerWealth.CustomerLoan.TotalSecureLoanLimit
                                     + custInfo.GetCustomerWealth.CustomerLoan.TotalUnsecureLoanLimit;
                    // loanTotalLimit = loanTotalLimit - loanBalance;
                }
                lo.add(LOAN);
                lo.add(String.valueOf(loanBalance));
                loLimit.add(LOAN_LIMIT);
                loLimit.add(String.valueOf(loanTotalLimit));

                // Add all the data to the list.
                result.add(mutualFund);
                result.add(depo);
                result.add(cd);
                result.add(cdLimit);
                result.add(lo);
                result.add(loLimit);

            }
        }

        return result;
    }   
}