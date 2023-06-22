/**
* This class is a controller for CustomerProductHoldingsAndNBO Visualforce page
* The controller will call a webservice to get Current Offer data 
* and query Last Offer data from Salesforce
*
* @author  Kanlaya Aungulavasapol
* @version 1.0
* @since   2018-07-02 
*/
public with sharing class CustomerProductHoldingsAndNBOCtrl extends OscControllerBase{

    public Account acct {get;set;}
    public String nboId {get;set;}
	public String nboURL {get;set;}
	public ProductOfferService.MuleInfo muleInfo {get;set;}
	
	public Map<String,LastOfferWrapper> lastOfferMap {get;set;}
	public Map<String,HoldingCurrentOfferWrapper> currentOfferMap {get;set;}
	public List<Product_Group_Label_Mapping__mdt> productGroupLabelMappingList {get;set;}
    	
    public User user {get;set;}/* current user */
    public List<String> nboSeq {get;set;}
    public Map<RTL_NBOService.NBOHistory, List<RTL_NBOService.NBOHistoryProduct>> mapNBO {get;set;}
	public String requestLabel;
    public String result {get;set;}
    
	private DateTime startTime;
	private DateTime endTime;
	private String requestBody;
	private String responseBody;
	private Id acctId;
	private String rmid;/* tmb customer id */
	private String userName;/* current user FirstName + LastName */
	private String acctName;/*customer name */
	private AsyncRTL_NextBestOffer.getNextBestOfferResponse_elementFuture asyncRet;

	/* Final Static parameters */
	private static final String PRODUCT_NAME_STR = 'Product Name';
	private static final String PRODUCT_GROUP_STR = 'Product Group';
	private static final String PRODUCT_SUB_GROUP_STR = 'Product sub Group';
	private static final String CC_INT01_NAME = 'CC_ProductHolding & NBO';
	private static final String OSC08_NAME = 'Fetch NBO';
	private static final String NBO_ERROR_FORMAT = 'OSC08';
	private static final String BA_ERROR_FORMAT = 'InsurancePolicyListCRMInq';
	private static final String PARTYACCTREL_ERROR_FORMAT = 'PartyAcctRelInq';
	private static final String NO_NBO_MESSAGE_FORMAT = 'ERR004';
	
	private static String ccInt01Endpoint{
		get{
			if(ccInt01Endpoint == null){
				AppConfig__c mc = AppConfig__c.getValues('WsCCINT01');
            	ccInt01Endpoint = mc == null ? 'https://sfmashupservices.tmbbank.com/retail/retrieveProdOffer/vit/retriveProductOffer' : mc.Value__c;
			}		
			return ccInt01Endpoint;
		}
		set;
	}

	public static Integer TIMEOUT_INT_SECS{
    get{
        Integer DEFAULT_TIMEOUT = 60;
        if(TIMEOUT_INT_SECS == null){
            try{
                TIMEOUT_INT_SECS = DEFAULT_TIMEOUT;
                List<App_Config__mdt> productHoldingTimeOut = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'ProductHolding_TIMEOUT_INT_SECS'];           
                    if (productHoldingTimeOut != null && productHoldingTimeOut.size() > 0) {
                        TIMEOUT_INT_SECS = Integer.valueOf(productHoldingTimeOut.get(0).Value__c);
                    }           
                    
                }catch( Exception e ){
                    TIMEOUT_INT_SECS = DEFAULT_TIMEOUT;
                }
        }
        return TIMEOUT_INT_SECS;
        
	}set;}
	
	// -------- Telephony Outbound ---------
    public Boolean checkProfileAssign {get;set;}

    public List<Campaign_Member_Profile_Assignment__mdt> cmProfileAssign {
        get{
            if(cmProfileAssign == null)
            {
                cmProfileAssign = [SELECT Id,MasterLabel,DeveloperName,Profile_Name__c FROM Campaign_Member_Profile_Assignment__mdt];
            }
            return cmProfileAssign;
        }
        set;
    }
    // -------- Telephony Outbound ---------


	public CustomerProductHoldingsAndNBOCtrl() {
		try{	

			acctId =  Apexpages.currentPage().getParameters().get('Id');  
			acct = getAccountInfo(acctId);
			if(acct != null){
				rmid = acct.TMB_Customer_ID_PE__c;
				acctName = acct.Name;
			}

			user = [select Id,Name,RTL_Branch_Code__c,Region_Code__c,Zone_Code__c,Profile.Name  from User where Id =:UserInfo.getUserId()];
			productGroupLabelMappingList = [SELECT Is_Main_Value__c,Label__c,Product_Group_Key__c,Type__c,Order__c,Current_Offer__c,Last_Offer__c FROM Product_Group_Label_Mapping__mdt ORDER BY Order__c ASC];
			userName = UserInfo.getName();
			// lastOfferMap = new Map<String,LastOfferWrapper>();

			// -------- Telephony Outbound ---------
			for(Campaign_Member_Profile_Assignment__mdt profileAssign : cmProfileAssign)
			{
				if(user.Profile.Name.ToUpperCase() == profileAssign.Profile_Name__c.ToUpperCase())
				{
					checkProfileAssign = true;
					break;
				}
				else {
					checkProfileAssign = false;
				}
			}
			// -------- Telephony Outbound ---------
			
		}catch(Exception e){
			System.debug('System Error : '+e.getMessage());
			pageMessage = System.Label.ERR002;
		}
			
	}

	public Account getAccountInfo(String accId){
        try{
            return [SELECT Id,Name,TMB_Customer_ID_PE__c,Core_Banking_Suggested_Segment__c
                    FROM Account 
                    WHERE Id = :accId ];
        }catch( Exception e ){
			return null;
        }      
    }

	public void getLastoffer(){
		try{

			lastOfferMap = new Map<String,LastOfferWrapper>();
					
			for(Product_Group_Label_Mapping__mdt productKey : productGroupLabelMappingList){
				String key = productKey.Product_Group_Key__c;
				String type = productKey.Type__c;
				
				if(productKey.Last_Offer__c == true){
					lastOfferMap.put(key,queryLastOffer(type,key,acctId));
				}else{
					lastOfferMap.put(key,new LastOfferWrapper());
				}			

			}

		}catch(Exception e){
			pageMessage = System.Label.ERR002;
			System.debug('Salesforce Error ::: '+e.getMessage());
		}
		
	}

	private LastOfferWrapper queryLastOffer(String type,String name,String acctId){
		LastOfferWrapper lastOffer;
		List<Opportunity> opp = new List<Opportunity>();
		List<RTL_NBO_History_Product__c> nboProduct = new List<RTL_NBO_History_Product__c>();
		List<CampaignMember> campaignMember = new List<CampaignMember>();
		List<LastOfferWrapper> lastOfferList = new List<LastOfferWrapper>();
		nboProduct = queryNBOProduct(type, name, acctId);
 		opp = queryOpportunity(type, name, acctId);
		campaignMember = queryCampaignMember(type, name, acctId);
		
		if(opp.size() > 0){	
			lastOffer = new LastOfferWrapper();	
			lastOffer.product = opp[0].RTL_Product_Name__r.Name;
			lastOffer.result = opp[0].StageName;
			lastOffer.reason = opp[0].RTL_Reason_Lost__c;
			lastOffer.LastModifiedDate = opp[0].LastModifiedDate;
			lastOfferList.add(lastOffer);
		}

		if(nboProduct.size() > 0){
			lastOffer = new LastOfferWrapper();			
			lastOffer.product = nboProduct[0].RTL_Product__c;
			lastOffer.result = nboProduct[0].RTL_Status__c;
			lastOffer.reason = nboProduct[0].RTL_Reject_Reason__c;
			lastOffer.LastModifiedDate = nboProduct[0].LastModifiedDate;
			lastOfferList.add(lastOffer);
		}
		System.debug('Campaign Member result :: '+campaignMember);
		if(campaignMember.size() > 0){
			lastOffer = new LastOfferWrapper();			
			for(Integer i = 1 ; i <= 5 ; i++){
				String productName;
				if(campaignMember[0].getSobject('RTL_Campaign_Product_'+i+'__r') != null){
					productName = (String)campaignMember[0].getSobject('RTL_Campaign_Product_'+i+'__r').get('Name');
				}
		
				String productSubGroup  = (String)campaignMember[0].get('RTL_Sub_Group_'+i+'__c');
				String productGroup  = (String)campaignMember[0].get('RTL_Product_Group_'+i+'__c');
				String offerResult = (String)campaignMember[0].get('RTL_OfferResult_Product_'+i+'__c');
				String reason = (String)campaignMember[0].get('RTL_Reason_'+i+'__c');

				//Product Name :: case other deposit product
				if(type == PRODUCT_NAME_STR && name == 'Others'){
					if(productName != 'All Free' && productName != 'No Fixed' && productGroup == 'Deposit' && (offerResult == 'Not Interested' || offerResult == 'ไม่สนใจ' )){
						lastOffer.product = productName;
						lastOffer.result = offerResult;
						lastOffer.reason = reason;
						break;
					}
				}//Product Name :: normal case
				else if(name == productName && (offerResult == 'Not Interested' || offerResult == 'ไม่สนใจ' )){
					lastOffer.product = productName;
					lastOffer.result = offerResult;
					lastOffer.reason = reason;
					break;
				}

				//Product Sub Grop :: case Life/Non Life  compare with both Life/Non Life and Life Insurance/Non Life Insurance
				if(name == 'Life' || name == 'Non Life'){
					if((name == productSubGroup || name+' Insurance' == productSubGroup) && (offerResult == 'Not Interested' || offerResult == 'ไม่สนใจ' )){
						lastOffer.product = productName;
						lastOffer.result = offerResult;
						lastOffer.reason = reason;
						break;
					}
				}//Product Sub Group :: normal case
				else if(name == productSubGroup && (offerResult == 'Not Interested' || offerResult == 'ไม่สนใจ' )){
					lastOffer.product = productName;
					lastOffer.result = offerResult;
					lastOffer.reason = reason;
					break;
				}

				//Product Group
				if(name == productGroup && (offerResult == 'Not Interested' || offerResult == 'ไม่สนใจ' )){
					lastOffer.product = productName;
					lastOffer.result = offerResult;
					lastOffer.reason = reason;
					break;
				}
				
			}
			//if campaign member record has offer result = 'Not Interested'
			if(lastOffer.result != null){
				lastOffer.LastModifiedDate = campaignMember[0].LastModifiedDate;
				lastOfferList.add(lastOffer);
			}	
				
		}
		
		lastOfferList.sort();
		return lastOfferList.size() > 0 ? lastOfferList[0]:new LastOfferWrapper();
	
	}

	private HoldingCurrentOfferWrapper getCurrentOffer(String name,ProductOfferService.ProductWrapper product){
		HoldingCurrentOfferWrapper currentOffer = new HoldingCurrentOfferWrapper(this,name,product.valueList);
		return currentOffer;
	}

    public override void CallSOAP(Continuation cont) {  
        cont.continuationMethod = 'processResponseSOAP';
        //async call to webservice SOAP API
        startTime = DateTime.now();
        AsyncRTL_NextBestOffer.AsyncNextBestOfferSOAP asyncSoap = new AsyncRTL_NextBestOffer.AsyncNextBestOfferSOAP();
        asyncRet = asyncSoap.beginGetNextBestOffer(cont, rmid);
    }	

    public Object processResponseSOAP() {
        try {
            //process SOAP API response
            RTL_NextBestOffer.NextBestOffer soapNBO = asyncRet.getValue();
			endTime = DateTime.now();
            //convert SOAP API response to map
            RTL_NBOService.NBO item = TypeMapper.MappingSoapToNBO(soapNBO);
            if (item != null) {
                if(item.SoapStatus == 'ERROR'){
                    pageMessage = item.SoapMessage;
					RTL_CampaignUtil.saveToOnlineLog(false,acctName,pageMessage,'', userName,rmid,OSC08_NAME,null,null,acct,startTime,endTime);
                    return null;
                }
                mapNBO = item.nboMap;
				//validate NBO and insert new inbound NBO to Salesforce
                String insertionErrMsg =  RTL_NBOService.validateNBO(acctId, user, mapNBO);
                 
                List<RTL_NBO_History__c> nboAndProductTmp = [select RTL_NBO_ID__c, RTL_Campaign_Name__c, RTL_Campaign_Code__c, RTL_NBO_Group__c,
                                                    RTL_NBO_SubGroup__c, RTL_Valid_From__c, RTL_Valid_To__c, 
                                                    RTL_Smart_Info__c, RTL_Contact_Date__c, 
                                                    RTL_Channel__c, 
                                                    RTL_Status__c, 
                                                    RTL_Number_of_Products__c, RTL_Number_of_Invalid_NBO__c
                                                    from RTL_NBO_History__c 
                                                    where RTL_NBO_ID__c =: nboId and (RTL_valid_to__c = null or RTL_valid_to__c >= TODAY) and RTL_Status__c != : RTL_Utility.NBO_STATUS_INVALID and RTL_Status__c != : RTL_Utility.NBO_STATUS_ACCEPTEDALL and RTL_Customer_Name__c = :acctId];                         	
               	
				if (insertionErrMsg != '') {//insert NBO failed
                    pageMessage = insertionErrMsg;
					RTL_CampaignUtil.saveToOnlineLog(false,acctName,pageMessage,'', userName,rmid,OSC08_NAME,null,null,acct,startTime,endTime);
                    return null;
                }   			   
				else if (nboAndProductTmp.size() == 0) { //NBO are invalid (NBO Expired or Accepted)
                    nboURL = '/apex/RTL_NBOHistoryDetailView?p=';
                }
				else{ //insert NBO successful and NBO is valid
					nboURL = '/apex/RTL_NBODetailView?p=';
				}
				RTL_CampaignUtil.saveToOnlineLog(true,acctName,'','', userName,rmid,OSC08_NAME,null,null,acct,startTime,endTime);
            }
        }catch(Exception e) {
			PageMessage = System.Label.ERR002;
			if(e.getMessage().contains('System.CalloutException IO Exception: Time out')){
				pageMessage = System.Label.Product_Holding_Timeout+'<br/>'+System.Label.Product_Holding_ReRequest;
			}
 
            System.debug('Show Error Message '+PageMessage);
			System.debug('There is error during processing fetched NBO: ' + e.getStackTraceString());
            RTL_CampaignUtil.saveToOnlineLog(false,acctName,e.getStackTraceString(),'', userName,rmid,OSC08_NAME,null,null,acct,startTime,endTime);
        }
        System.debug('Show Page Message '+PageMessage);
        return null;
    }

	// Action method
    public Object startCallProductOfferService() {
		// Create continuation with a timeout
		Continuation con = new Continuation(TIMEOUT_INT_SECS);
		// Set callback method
		con.continuationMethod='processResponse';
		
		requestBody = '{"rm_id":"'+rmid+'"}';                                                        
		// Create callout request
		HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		req.setEndpoint(ccInt01Endpoint);
		req.setBody(requestBody);
		startTime = DateTime.now();
		//req.set
		this.requestLabel = con.addHttpRequest(req);
		return con;  
		
    }
    
    // Callback method for startCallProductOfferService
    public Object processResponse() {  
		String errorCodeText = '';
		
		Map<String,ProductOfferService.ProductWrapper> productMap;
		
		try
		{
			HttpResponse response = Continuation.getResponse(this.requestLabel);
			endTime = DateTime.now();
			responseBody = response.getBody();
			currentOfferMap = new Map<String,HoldingCurrentOfferWrapper>();
			System.debug('Service Result '+responseBody);
			
			if( response == null ) 
			{ 
				pageMessage = System.Label.ERR001;
				RTL_CampaignUtil.saveToOnlineLog(false,acctName,'','', userName,rmid,CC_INT01_NAME,requestBody,responseBody,acct,startTime,endTime);
				return null;
			}
			if( response.getStatusCode() == 2000 ) // if timeout
			{
				pageMessage = System.Label.Product_Holding_Timeout+'<br/>'+System.Label.Product_Holding_ReRequest;
				errorCodeText = 'Error occur while calling Webservice : Http Status Code '+response.getStatusCode();
				RTL_CampaignUtil.saveToOnlineLog(false,acctName,errorCodeText,'', userName,rmid,CC_INT01_NAME,requestBody,responseBody,acct,startTime,endTime);
				return null;
			}
			if( response.getStatusCode() != 200 && response.getStatusCode() != 2000) // if HTTP Status Code is not a success code
			{
				pageMessage = pageMessage = System.Label.ERR001;
				errorCodeText = 'Error occur while calling Webservice : Http Status Code '+response.getStatusCode();
				RTL_CampaignUtil.saveToOnlineLog(false,acctName,errorCodeText,'', userName,rmid,CC_INT01_NAME,requestBody,responseBody,acct,startTime,endTime);
				return null;
			}
			//success case

			//parse json response into SF object
			ProductOfferService.parseJson(responseBody);
			muleInfo = ProductOfferService.muleInfo;

			if(muleInfo.status == 'ERROR'){
				pageMessage = System.Label.ERR001;
				RTL_CampaignUtil.saveToOnlineLog(false,acctName,String.join(muleInfo.message,'\n'),muleInfo.log_id, userName,rmid,CC_INT01_NAME,requestBody,responseBody,acct , startTime,endTime );
				return null;
			}

			productMap = ProductOfferService.productWrapperMap; 
			for(Product_Group_Label_Mapping__mdt productKey : productGroupLabelMappingList){
				String key = productKey.Product_Group_Key__c;
				String type = productKey.Type__c;
				
				if(productMap.containsKey(key)){
					currentOfferMap.put(key,getCurrentOffer(key,productMap.get(key)));
				}else{
					currentOfferMap.put(key,new HoldingCurrentOfferWrapper(this));
				}
				

			}
			System.debug('LastOffer '+LastOfferMap);

			if(muleInfo.status == 'PARTIAL SUCCESS'){				
				pageMessage = System.Label.INT_Investment_Incomplete_Info+'<br/>'+System.Label.Product_Holding_ReRequest;
				//add exception case , OSC08|Status ERROR ERR004 means no NBO found for this customer . Salesforce handle this case to show success
				if(muleInfo.message.size() == 1 && muleInfo.message.contains('OSC08|Status ERROR ERR004')){
					pageMessage = null;
				}
				RTL_CampaignUtil.saveToOnlineLog(false,acctName,String.join(muleInfo.message,'\n'),muleInfo.log_id, userName,rmid,CC_INT01_NAME,requestBody,responseBody,acct , startTime,endTime );
				return null;
			}
			RTL_CampaignUtil.saveToOnlineLog(true,acctName,'',muleInfo.log_id, userName,rmid,CC_INT01_NAME,requestBody,responseBody,acct , startTime,endTime );
			
			
		}catch(Exception e){
			pageMessage = System.Label.ERR002;
			System.debug('Salesforce error :: '+e.getMessage());
			RTL_CampaignUtil.saveToOnlineLog(false,acctName,e.getMessage(),muleInfo==null?'':muleInfo.log_id, userName,rmid,CC_INT01_NAME,requestBody,responseBody,acct , startTime,endTime );
			return null;
		}
		
		return null;
    }

    @RemoteAction
    public static String checkNBOExists(String NBOId) {
        List<RTL_NBO_History__c> NBOList = [SELECT Id,Name,RTL_NBO_ID__c,RTL_Valid_To__c FROM RTL_NBO_History__c WHERE RTL_NBO_ID__c =:NBOId];
        System.debug('NBO Size :: '+NBOList.size());
        if(NBOList.size() == 0){
            return null;
        }else if(NBOList[0].RTL_Valid_To__c >= System.today()){//if NBO valid (not expired)
			//return url to editable page
			return '/apex/RTL_NBODetailView?p=';
		}
		//return url to read-only page
        return '/apex/RTL_NBOHistoryDetailView?p=';
    }

	@RemoteAction
    public static String checkCampaignMemberExists(String NBOId,String tmbCustId) {
        //query CampaignMember by getting campaignCode from NBOID (first 10 digits of NBOid) and TMB Customer ID
		String campaignCode = NBOID.LEFT(10);
		List<CampaignMember> campaignMemberList = [SELECT Id,Name,RTL_Marketing_Code__c 
													 FROM CampaignMember 
													WHERE Campaign.RTL_Campaign_Code_10_digits__c =:campaignCode 
													  AND RTL_TMB_Cust_ID__c =: tmbCustId ];
		//query CampaignMember by marketing code
		// List<CampaignMember> campaignMemberList = [SELECT Id,Name,RTL_Marketing_Code__c FROM CampaignMember WHERE RTL_Marketing_Code__c =:NBOId];
        if(campaignMemberList.size() > 0){
            return campaignMemberList[0].id;
        }
        return null;
    }

	class LastOfferWrapper implements Comparable{
		public String refKey{get;set;}
		public String product{get;set;}
		public String result{get;set;}
		public String reason{get;set;}
		private Datetime lastModifiedDate{get;set;}

		public String getLastModifiedDate(){
			if(lastModifiedDate != null)
				return lastModifiedDate.format('dd/MM/yyyy');
			return null;
			
		}

		// Compare LastOffer based on LastmodifiedDate DESC.
		public Integer compareTo(Object compareTo) {
			// Cast argument to LastOfferWrapper
			LastOfferWrapper compareToLastOffer = (LastOfferWrapper)compareTo;
			
			// The return value of 0 indicates that both elements are equal.
			Integer returnValue = 0;
			if (lastModifiedDate < compareToLastOffer.lastModifiedDate) {
				// Set return value to a positive value.
				returnValue = 1;
			} else if (lastModifiedDate > compareToLastOffer.lastModifiedDate) {
				// Set return value to a negative value.
				returnValue = -1;
			}
			
			return returnValue;       
		}

	}

	@TestVisible
	class HoldingCurrentOfferWrapper{
		private List<String> holdingDescList;
		private List<String> campaignNBODescList;
		private List<String> ruleBasedNBODescList;
		
		private List<String> wsValueList;
		private CustomerProductHoldingsAndNBOCtrl ctrl;
		private String name;
		
		public Boolean holdingFlag {get;set;}
		public NBODetail campaignNBO {get;set;}
		public NBODetail ruleBasedNBO {get;set;}

		HoldingCurrentOfferWrapper(CustomerProductHoldingsAndNBOCtrl ctrl){
			holdingDescList = new List<String>();
			campaignNBODescList = new List<String>();
			ruleBasedNBODescList = new List<String>();
			this.ctrl = ctrl;
		}
		HoldingCurrentOfferWrapper(CustomerProductHoldingsAndNBOCtrl ctrl,String name,List<String> wsValueList){
			this(ctrl);
			this.wsValueList = wsValueList;/*format x:y;nbocodeY:z;nbocodeZ */
			this.name = name;
			
			//loop through each value for each product group label,each product group label may have multiple values eg. Others in Deposit
			for(String eachStr : wsValueList){		
				Integer i = 0;
				List<String> eachWsValue = eachStr.split(':');	
				
				for(String wsEachValue : eachWsValue){
					if(i == 0){// product holding part
						holdingDescList.add(wsEachValue);		
					}else if(i == 1){// campaign nbo part
						campaignNBODescList.add(wsEachValue);
					}else if(i == 2){// rule-based nbo part
						ruleBasedNBODescList.add(wsEachValue);
					}
					i++;
				}
			}

			holdingFlag = transformHoldingFlag();
			campaignNBO = transformNBO(campaignNBODescList);
			ruleBasedNBO = transformNBO(ruleBasedNBODescList);

		}
		
		public Boolean transformHoldingFlag(){
			try{
				if(ctrl.MuleInfo.status == 'PARTIAL SUCCESS'){
					if((name == 'Life' || name == 'Non Life' ) && isListStartsWithError(ctrl.MuleInfo.Message,BA_ERROR_FORMAT)){
						return null;
					}
					if(isListStartsWithError(ctrl.MuleInfo.Message,PARTYACCTREL_ERROR_FORMAT)){
						return null;
					}					
				}
				Integer noOfProductHolding;	
				//loop through each product holding value to sum the product holding value
				for(String eachHolding : holdingDescList){
					if(eachHolding != '' && noOfProductHolding == null){
						noOfProductHolding = Integer.valueOf(eachHolding);
					}else if(eachHolding != '' && noOfProductHolding != null){//
						noOfProductHolding += Integer.valueOf(eachHolding);
					}
				}
				//no value send from webservice
				if(noOfProductHolding == null){
					return null;
				}
				if(noOfProductHolding > 0){
					return true;
				}
				return false;
			}catch(Exception e){
				ctrl.pageMessage = System.Label.ERR002;
				RTL_CampaignUtil.saveToOnlineLog(false,ctrl.acctName,e.getMessage(),ctrl.muleInfo.log_id, ctrl.userName,ctrl.rmid,CC_INT01_NAME,ctrl.requestBody,ctrl.responseBody,ctrl.acct , ctrl.startTime,ctrl.endTime );
				return null;
			}
			
		}

		private Boolean isListStartsWithError(List<String> messageList,String errorFormat){
			for(String message : messageList){
				if(message.startsWith(errorFormat)){
					return true;
				}
			}
			return false;
		}

		private Boolean isListContainsError(List<String> messageList,String errorFormat){
			for(String message : messageList){
				if(message.contains(errorFormat)){
					return true;
				}
			}
			return false;
		}

		public NBODetail transformNBO(List<String> inputNBOList){
			try{
				List<NBODetail> nboDetailList = new List<NBODetail>();
			String NBOFlag = '';
			String NBOId = '';
			Integer countNBO = 0;

			if(ctrl.MuleInfo.status == 'PARTIAL SUCCESS'){
				//If error message starts with OSC08 and message don't contain ERR004(no NBO found) , return error
				if(isListStartsWithError(ctrl.MuleInfo.Message,NBO_ERROR_FORMAT) && !isListContainsError(ctrl.MuleInfo.Message,NO_NBO_MESSAGE_FORMAT)){
					return null;
				}					
			}
			// no value sent from webservice
			if(inputNBOList.size() == 0){
				return null;
			}

			for(String eachNBO : inputNBOList){
				NBODetail nbo = parseNBO(eachNBO);
				nboDetailList.add(nbo);
				if(nbo.noOfNBO > 0){
					countNBO++;
					NBOId = nbo.NBOId;
				}
			}
			NBOFlag = '0';
			if(countNBO > 0){
				NBOFlag = '1';
			}
			return new NBODetail(NBOFlag,nboId);
			}catch(Exception e){
				ctrl.pageMessage = System.Label.ERR002;
				RTL_CampaignUtil.saveToOnlineLog(false,ctrl.acctName,e.getMessage(),ctrl.muleInfo.log_id, ctrl.userName,ctrl.rmid,CC_INT01_NAME,ctrl.requestBody,ctrl.responseBody,ctrl.acct , ctrl.startTime,ctrl.endTime );
				return null;
			}
			
		}

		public NBODetail parseNBO(String NBOStr){
			NBODetail nbo = new NBODetail();
			List<String> nboList;
			if(NBOStr.indexOf(';') != -1){
				nboList = NBOStr.split(';');
				Integer i = 0;
				for(String nboObj : nboList){
					if(i == 0){			
						nbo.NBOFlag = nboObj;
						nbo.noOfNBO = Integer.ValueOf(nboObj);
					}else if(i == 1){
						nbo.NBOID = nboObj;
					}
					i++;
				}
			}else{
				nbo.NBOFlag = NBOStr;
				nbo.noOfNBO = Integer.ValueOf(NBOStr);
			}		

			return nbo;
		}
		
	}

	@TestVisible
	class NBODetail{
		Integer noOfNBO;
		String NBOFlag;
		String NBOId;

		NBODetail(){
			NBOFlag = '';
			NBOId = '';
		}

		NBODetail(String inNBOFlag , String inNBOId){
			NBOFlag = inNBOFlag;
			NBOId = inNBOId;
		}

		public String getNBOFlag(){
			return NBOFlag;
		}

		public String getNBOId(){
			return NBOId;
		}
		
	}

	/**
    * @param type - Type of product to query (Product Name, Product Group , Product Sub Group)
    * @param name - Name of Product Name , Product Group or Product Sub Group
    * @param acctId - account ID which related to campaign Member
    */
    public List<CampaignMember> queryCampaignMember(String type,String name,String acctId){
        String strWhere = '';
		List<String> nameList = new List<String>{name};
		if(name == 'Life' || name == 'Non Life'){
			nameList.add(name+' Insurance');
		}
        if(type == PRODUCT_NAME_STR){
            for(Integer i = 1 ; i <= 5 ; i++){
				if(name != 'Others'){
					strWhere += 'RTL_Campaign_Product_'+i+'__r.Name IN: nameList OR ';
				}
				else if(name == 'Others'){
					strWhere += '(RTL_Campaign_Product_'+i+'__r.Name NOT IN (\'All Free\',\'No Fixed\') AND RTL_Product_Group_'+i+'__c = \'Deposit\') OR ';
				} 
			}
        }else if(type == PRODUCT_GROUP_STR){
            for(Integer i = 1 ; i <= 5 ; i++){
				strWhere += 'RTL_Product_Group_'+i+'__c IN: nameList OR ';
			}
        }else if(type == PRODUCT_SUB_GROUP_STR){
            for(Integer i = 1 ; i <= 5 ; i++){
				strWhere += 'RTL_Sub_Group_'+i+'__c IN: nameList OR ';
			}
        }
		strWhere = '( '+strWhere.substring(0,strWhere.length()-3)+' )';

		String strFields = '';
		for(Integer i = 1 ; i <= 5 ; i++){
			strFields += 'RTL_Campaign_Product_'+i+'__r.Name,';
			strFields += 'RTL_Product_Group_'+i+'__c,';
			strFields += 'RTL_Sub_Group_'+i+'__c,';
			strFields += 'ToLabel(RTL_OfferResult_Product_'+i+'__c),';
			strFields += 'ToLabel(RTL_Reason_'+i+'__c),';
		}
        String strQuery = 'SELECT Id,Name,'+strFields+'LastModifiedDate ';
        strQuery += ' FROM CampaignMember ';
        strQuery += ' WHERE '+strWhere;
        strQuery += ' AND Contact.AccountId =: acctId ';
        strQuery += ' ORDER BY LastModifiedDate DESC ';
        strQuery += ' LIMIT 1';

		System.debug('Campaign Member query :: '+strQuery);

        return Database.query(strQuery);
		
	}

	/**
    * @param type - Type of product to query (Product Name, Product Group , Product Sub Group)
    * @param name - Name of Product Name , Product Group or Product Sub Group
    * @param acctId - account ID which related to NBO Product
    */
    public List<RTL_NBO_History_Product__c> queryNBOProduct(String type,String name,String acctId){
        String strWhere = '';
		List<String> nameList = new List<String>{name};
		if(name == 'Life' || name == 'Non Life'){
			nameList.add(name+' Insurance');
		}
        if(type == PRODUCT_NAME_STR){
			strWhere = 'RTL_Product__c IN: nameList';
			if(name == 'Others'){
				strWhere = 'RTL_Product__c NOT IN (\'All Free\',\'No Fixed\') AND RTL_Product_Group__c = \'Deposit\' ';
			}            
        }else if(type == PRODUCT_GROUP_STR){
            strWhere = 'RTL_Product_Group__c IN: nameList';
        }else if(type == PRODUCT_SUB_GROUP_STR){
            strWhere = 'RTL_Product_SubGroup__c IN: nameList';
        }
        String strQuery = 'SELECT Id,Name,RTL_Product__c,RTL_Product_Group__c,RTL_Product_SubGroup__c,ToLabel(RTL_Reject_Reason__c),ToLabel(RTL_Status__c),RTL_Related_NBO__r.RTL_Customer_Name__c,LastModifiedDate ';
        strQuery += ' FROM RTL_NBO_History_Product__c ';
        strQuery += ' WHERE '+strWhere;
        strQuery += ' AND RTL_Related_NBO__r.RTL_Customer_Name__c =: acctId ';
		strQuery += ' AND RTL_Status__c IN (\'Pending\',\'Rejected\') ';
        strQuery += ' ORDER BY LastModifiedDate DESC ';
        strQuery += ' LIMIT 1';

		System.debug('NBO Product Query :: '+strQuery);

        return Database.query(strQuery);
		
	}

 	/**
    * @param type - Type of product to query (Product Name, Product Group , Product Sub Group)
    * @param name - Name of Product Name , Product Group or Product Sub Group
    * @param acctId - account ID which related to Opportunity
    */
    public List<Opportunity> queryOpportunity(String type,String name,String acctId){
        String strWhere = '';
		List<String> nameList = new List<String>{name};
		if(name == 'Life' || name == 'Non Life'){
			nameList.add(name+' Insurance');
		}
        if(type == PRODUCT_NAME_STR){
            strWhere = 'RTL_Product_Name__r.Name IN: nameList';
			if(name == 'Others'){
				strWhere = 'RTL_Product_Name__r.Name NOT IN (\'All Free\',\'No Fixed\') AND RTL_Product_Group__c = \'Deposit\' ';
			}  
        }else if(type == PRODUCT_GROUP_STR){
            strWhere = 'RTL_Product_Group__c IN: nameList';
        }else if(type == PRODUCT_SUB_GROUP_STR){
            strWhere = 'RTL_Prod_SubGrp__c IN: nameList';
        }
        String strQuery = 'SELECT Id,Name,RTL_Product_Name__r.Name,ToLabel(StageName),ToLabel(RTL_Reason_Lost__c),LastModifiedDate ';
        strQuery += ' FROM Opportunity ';
        strQuery += ' WHERE '+strWhere;
        strQuery += ' AND AccountId =: acctId ';
        strQuery += ' ORDER BY LastModifiedDate DESC ';
        strQuery += ' LIMIT 1';

		System.debug('Opportunity Query :: '+strQuery);

        return Database.query(strQuery);
		
	}
}