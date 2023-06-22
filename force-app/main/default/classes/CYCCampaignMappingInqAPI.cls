public with sharing class CYCCampaignMappingInqAPI implements Callable {
	private String endpointName; /* Name of Named Credentil */
	private String endpoint;

	private String className;
	private HttpRequest request;
	private String START_METHOD = '[';
	private String END_METHOD = ']';
	private String START_PARAM = '<';
	private String END_PARAM = '>';
	private String token;

	private Datetime startTime;
    private Datetime endTime;
	private Boolean isSuccessRequest = false;
	private String errorMessageResponse;
	private String uidLogId;
	private List<Map<String, Object>> onlineSVL;
	private String requestAppId = '';
	private String encDeKey = '';			// Key for encrypt & Decrypt;
	private String encryptionKey = 'DWH'; // Default dwh

	/* endpointName = Named Credentail Set on environment  */
	public Object Preparedata(String endpointName, Object headerParam, Object bodyParam,Object OnlineServiceLog) {
		Object result;
		className = String.valueOf(this).subString(0, String.valueOf(this).indexOf(':'));
		this.endpointName = endpointName;
		System.debug('Current ClassName : ' + className);

		// 0) get custom metadata type
		String nameApiSetting = endpointName;
		List<API_Setup__mdt> apiSetting = [
			SELECT isActive__c,isLog__c,method__c, NamedCredential__c, header_request__c, body_request__c,start_param__c,end_param__c,start_method__c,end_method__c,inactive_return_message__c,timeout__c,http_success_response_code__c,success_code_check__c,request_appid__c,isHttpStatusCheck__c,isSuccessCodeCheck__c,error_mesage_tag__c,IsEncryption__c,EncryptionKey__c
			FROM API_Setup__mdt
			WHERE NamedCredential__c = :nameApiSetting
		];

		String method = 'POST'; // Default POST (only support now)
		String headerLayout = '';
		String bodyLayout = '';
		Boolean isActive = false; // Default active is false
		String prepareHeaderValue = '';
		String prepareBodyValue = '';
		String prepareBodyValuePlain = '';
		String response = '';
		String inactive_return_message = '{}'; // default f
		Integer apiTimeout = 10000; //
		Boolean isRequest = false;  // Default isRequest is false
		Boolean isLog = true; 		// Default isLog is true
		Boolean isHttpStatusCheck = false;  // Default is HttpStatusCheck true
		Boolean isSuccessCodeCheck = false;  // Default is SuccessStatusCheck false;
		Boolean isEncryptionCheck = false;	// Default is Encryption false
		String httprequestStausCheck = '';
		String layoutSuccessCodeCheck = '{}';
		String tagForErrorMesssage = '{}';
		List<Map<String, Object>> successCodeCheck;

		for (API_Setup__mdt api : apiSetting) {
			isActive = api.isActive__c;
			isLog = api.isLog__c;
			method = api.method__c.trim().length()>0?api.method__c:method;
			headerLayout = api.header_request__c;
			bodyLayout = api.body_request__c;
			START_PARAM = api.start_param__c.trim().length()>0?api.start_param__c:START_PARAM;
			END_PARAM = api.end_param__c.trim().length()>0?api.end_param__c:END_PARAM;
			START_METHOD = api.start_method__c.trim().length()>0?api.start_method__c:START_METHOD;
			END_METHOD = api.end_method__c.trim().length()>0?api.end_method__c:END_METHOD;
			inactive_return_message = api.inactive_return_message__c.trim().length()>0?api.inactive_return_message__c:inactive_return_message;
			apiTimeout = api.timeout__c != null? api.timeout__c.intValue() : apiTimeout;

			httprequestStausCheck = api.http_success_response_code__c.trim().length()>0?api.http_success_response_code__c:httprequestStausCheck;
			isHttpStatusCheck = api.isHttpStatusCheck__c;
			isSuccessCodeCheck = api.isSuccessCodeCheck__c;
			
			requestAppId = api.request_appid__c.trim().length()>0?api.request_appid__c:requestAppId;
			layoutSuccessCodeCheck =  api.success_code_check__c.trim().length()>0?api.success_code_check__c:layoutSuccessCodeCheck;
			tagForErrorMesssage = api.error_mesage_tag__c.trim().length()>0?api.error_mesage_tag__c:tagForErrorMesssage;
			
			isEncryptionCheck = api.IsEncryption__c;

			encryptionKey = api.EncryptionKey__c !=null?api.EncryptionKey__c:encryptionKey;
		}
		
		if (isActive) {
			// 1) set endpoint Using Named Credential End Point
			APIGateway_Service.RequestToken req = new APIGateway_Service.RequestToken();
			req.endPoint = endpointName;
			endpoint = req.parseEndpoint();

			// System.debug('debug >>>>> bodyParam : '+(String)bodyParam);
			// System.debug('debug >>>>> bodyLayout : '+bodyLayout);
			
			// 2) set Request
			List<Map<String, Object>> headerParamList = getLayOutData((String) headerParam); // Parameter on header
			List<Map<String, Object>> bodyParamList = getLayOutData((String) bodyParam); // Parameter on body
			onlineSVL = isLog?getLayOutData((String) OnlineServiceLog):onlineSVL;

			// System.debug('debug >>>>> bodyParamList : '+bodyParamList);

			// 2.1) Replace String of layout with Parameter
			prepareHeaderValue = prepareLayoutWithValue(headerLayout, headerParamList);
			prepareBodyValue = prepareLayoutWithValue(bodyLayout, bodyParamList);
			
			prepareBodyValuePlain = prepareBodyValue;
			prepareBodyValue = isEncryptionCheck?EncryptMesage(prepareBodyValue,encryptionKey):prepareBodyValue; //// 

			//System.debug('debug >>>>> bodyParamList : '+prepareBodyValue);
			
			// 2.2) Make Paramter of header iterable
			List<Map<String, Object>> headerSend = getLayOutData((String) prepareHeaderValue);
			//List<Map<String, Object>> bodySend = getLayOutData((String) prepareBodyValue);

			// 3) Set Header Request
			request = new HttpRequest();
			request.setMethod(method);
			for (Map<String, Object> tmpMap : headerSend) {
				for (String key : tmpMap.keySet()) {
					request.setHeader(key, (String) tmpMap.get(key));
					//System.debug(key+':'+tmpMap.get(key));
				}
			}
			request.setBody(prepareBodyValue);
			request.setEndpoint(endpoint);
			request.setTimeout(apiTimeout);
			
			// 4) Create Http and Request
			Http http = new Http();
			HttpResponse res;
			try {
				startTime = system.now();
				res = http.send(request); // send request >>
				//isSuccessRequest = true;                    // if there are already send request in line before isSuccessRequest is true
				response = res.getBody();
				// if(true){
				// 	onlineLog('Debug unauth', 'request', response);
				// 	return response;
				// }
				if(response.contains('Unauthorized')){
					Map<string,Object> unauthen = (Map<string,Object>) JSON.deserializeUntyped(response);
					result = unauthen.get('status');
					//return result;
				}
				else{
					response = isEncryptionCheck?DecryptMessage(response, encryptionKey):response;

					//System.debug('reponse : --->'+response);
					result = JSON.deserializeUntyped(response);
	
					//public Boolean IssucessRequest(Boolean isHttp,Boolean isSuccess,String httpStatus,String statusCode,Integer resCode,String resStatus)
					isSuccessRequest = IssucessRequest(isHttpStatusCheck,
									isSuccessCodeCheck,
									httprequestStausCheck, 
									getFirstJSONTextFromTag(layoutSuccessCodeCheck, getFirstKeyFromJSON(layoutSuccessCodeCheck)),
									res.getStatusCode(),
									getFirstJSONTextFromTag(response, getFirstKeyFromJSON(layoutSuccessCodeCheck))  
									);
					// System.debug('debug >>>>> response : '+response);
					errorMessageResponse = (!isSuccessRequest)? getFirstJSONTextFromTag(response, getFirstKeyFromJSON(tagForErrorMesssage)):errorMessageResponse;
				}
			} catch (Exception e) {
				errorMessageResponse = e.getMessage();
				// isSuccessRequest = false; // Default is request false
				System.debug('Exception on Request : '+prepareBodyValuePlain);
				System.debug('Exception '+res);
				System.debug(e);
			} finally{
				endTime = DateTime.now();
				
				isRequest = true;
			}
		} else {
			System.debug('********* This api is not Active or Not Found in Custome Meta Data *************');
			result = JSON.deserializeUntyped( inactive_return_message );
			System.debug( inactive_return_message );
		}
		// 5) for create onlineLog
		if(isRequest && isLog){
			onlineLog(getEndPointURL(), prepareBodyValuePlain, response);
		}
		return result;
	}

	/* for return Layout Data as List */
	public List<Map<String, Object>> getLayOutData(String layout) {
		List<Map<String, Object>> layoutList = new List<Map<String, Object>>();
		Map<String, Object> tmpMap = new Map<String, Object>();
		if (layout.length() > 0) {
			Object layoutObject = JSON.deserializeUntyped(layout);
			Map<String, Object> mapData = (Map<String, Object>) layoutObject;
			for (String key : mapData.keySet()) {
				tmpMap = new Map<String, Object>();
				tmpMap.put(key, mapData.get(key));
				layoutList.add(tmpMap);
			}
		}
		return layoutList;
	}

	/* get Parameter value Sending back to String*/
	public String getStrValueFromParameter(String paramName, List<Map<String, Object>> paramList) {
		String tmpStr = '';
		for (Map<String, Object> mapStr : paramList) {
			for (String key : mapStr.keySet()) {
				if (paramName == key) {
					tmpStr = (String) mapStr.get(key);
					break;
				}
			}
		}
		return tmpStr;
	}

	/* get Parameter value Sending back to Map*/
	public Map<String, Object> getMapValueFromParameter(String paramName, List<Map<String, Object>> paramList) {
		Map<String, Object> tmpMap = new Map<String, Object>();
		for (Map<String, Object> mapStr : paramList) {
			for (String key : mapStr.keySet()) {
				if (paramName == key) {
					tmpMap = mapStr;
					break;
				}
			}
		}
		return tmpMap;
	}

	/* for prepare data for request  message , */
	public String prepareLayoutWithValue(String message, List<Map<String, Object>> listParamValue) {
		String tmp1 = '';
		String tmp2 = '';
		String tmpMtd = findTypeOfLayout(message);
		//System.debug('Message : '+message);
		Map<String, Object> tmpMap = new Map<String, Object>();
		switch on tmpMtd {
			when 'NORMAL_TEXT' {
				// System.debug(' 1 : Return Message >> '+message);
				return message;
			}
			when 'CALL_METHOD' {
				tmp1 = message.substringBetween(START_METHOD, END_METHOD); // method name
				tmpMap = getMapValueFromParameter(tmp1, listParamValue);
				// System.debug(' 2 : Return Method >> '+tmp1);
				Callable callMethod = (Callable) Type.forName(className).newInstance();
				
				// Special Case from get data back to Object;
				if(tmp1== 'getUUID'){
					String tmpUUID = (String) callMethod.call(tmp1, tmpMap);
					uidLogId = tmpUUID;
					return tmpUUID;
				}else{
					return (String) callMethod.call(tmp1, tmpMap);
				} 
			}
			when 'REPLACE_PARAM' {
				tmp1 = message.substringBetween(START_PARAM, END_PARAM); // tmp1 is name of param meter
				// System.debug(' 3 : Return Param >> '+tmp1);
				return getStrValueFromParameter(tmp1, listParamValue);
			}
			when 'TEXT_AND_METHOD' {
				tmp1 = message.substring(0, message.indexOf(START_METHOD));
				tmp2 = message.substring(message.indexOf(START_METHOD), message.length());
				// System.debug(' 4 : Return TEXT('+tmp1+') : METHOD('+tmp2+')');
				return tmp1 + prepareLayoutWithValue(tmp2, listParamValue);
			}
			when 'TEXT_AND_PARAM' {
				tmp1 = message.substring(0, message.indexOf(START_PARAM));
				tmp2 = message.substring(message.indexOf(START_PARAM), message.length());
				// System.debug(' 5 : Return TEXT('+tmp1+') : PARAM('+tmp2+')');
				return tmp1 + prepareLayoutWithValue(tmp2, listParamValue);
			}
			when 'METHOD_AND_TEXT' {
				tmp1 = message.substring(0, message.indexOf(END_METHOD) + 1);
				tmp2 = message.substring(message.indexOf(END_METHOD) + 1, message.length());
				// System.debug(' 6 : Return METHOD('+tmp1+') : TEXT('+tmp2+')');
				return prepareLayoutWithValue(tmp1, listParamValue) + prepareLayoutWithValue(tmp2, listParamValue);
			}
			when 'PARAM_AND_TEXT' {
				tmp1 = message.substring(0, message.indexOf(END_PARAM) + 1);
				tmp2 = message.substring(message.indexOf(END_PARAM) + 1, message.length());
				// System.debug(' 7 : Return PARAM('+tmp1+') : TEXT('+tmp2+')');
				return prepareLayoutWithValue(tmp1, listParamValue) + prepareLayoutWithValue(tmp2, listParamValue);
			}
			when else {
				// System.debug(' 8 : Return ELSE ('+message+')');
				return message;
			}
		}
	}

	/*for find type of data that sending */
	public String findTypeOfLayout(String layoutMessage) {
		String txt = layoutMessage;
		Integer textPosition, methodPosition, disabledPosition, paramPosition;

		// System.debug('findTypeOfLayout : ' + txt);
		methodPosition = txt.indexOf(START_METHOD);
		paramPosition = txt.indexOf(START_PARAM);
		// System.debug('Method Pos :' + methodPosition + ', Param Pos :' + paramPosition);
		if (
			layoutMessage.containsNone(START_METHOD) &&
			layoutMessage.containsNone(END_METHOD) &&
			layoutMessage.containsNone(START_PARAM) &&
			layoutMessage.containsNone(END_PARAM)
		) {
			return 'NORMAL_TEXT';
		} else if (methodPosition == 0 && txt.substring(txt.indexOf(START_METHOD), txt.indexOf(END_METHOD) + 1) == txt) {
			// Case only Method in layout
			return 'CALL_METHOD';
		} else if (paramPosition == 0 && txt.substring(txt.indexOf(START_PARAM), txt.indexOf(END_PARAM) + 1) == txt) {
			// Case only Parameter in layout
			return 'REPLACE_PARAM';
		} else if (methodPosition > 0 && (methodPosition < paramPosition || paramPosition == -1)) {
			// Case Leading with Text and after are 'START_METHOD SIGN'
			return 'TEXT_AND_METHOD';
		} else if (paramPosition > 0 && (paramPosition < methodPosition || methodPosition == -1)) {
			// Case Leading with Text and after are 'START_PARAM SIGN'
			return 'TEXT_AND_PARAM';
		} else if (methodPosition == 0 && txt.indexOf(END_METHOD) + 1 < txt.length()) {
			// Case Leading with 'START_METHOD SIGN' and after with other
			return 'METHOD_AND_TEXT';
		} else if (paramPosition == 0 && txt.indexOf(END_PARAM) + 1 < txt.length()) {
			// Case Leading with 'START_PARAM SIGN' and after with other
			return 'PARAM_AND_TEXT';
		} else {
			return 'ELSE';
		}
	}

	///************/ Section Call Methods /*******************//

	// 3) Dispatch actual methods
	public Object call(String action, Map<String, Object> args) {
		//System.debug('Debug from call Method : args = '+args);
		switch on action {
			when 'getUUID' {
				return this.getUUID();
			}
			when 'getDateTime' {
				return this.getDateTime();
			}
			when 'getAccessToken' {
				return this.getAccessToken();
			}
			when else {
				return null;
			}
			//call('recusiveCallSwitch', new Map<String, Object> { 'message' => data }); // Call with Param Example
		}
	}

	// 3.1)
	public String getUUID() {
		Uuid uuidGenerateor = new Uuid();
		uidLogId = uuidGenerateor.getValue();  // can't assign to class variable
		return uidLogId;
	}

	// 3.2)
	public String getDateTime() {
		return Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
	}

	// 3.3)
	public String getAccessToken() {		
		return !Test.isRunningTest()?SmartBDM_Utility.tokenKeyCalculateTools:'ACCESSTOKENTEST';
	}

	///************/ End Section Call Methods /*******************//

	private String getEndPointURL(){
		String url;
		List<NamedCredential> nameCredentialList = [
			SELECT DeveloperName, Endpoint FROM NamedCredential where DeveloperName = :endpointName
		];
		for(NamedCredential n: nameCredentialList){
			url = n.Endpoint;
		}
		return url;
	}

	public List<Integer> getListIntegerFromStr(String str,String splitSign){
		List<Integer> list_int = new List<Integer>();
		try{
			String[] test = str.split(splitSign);
			for(String cc : test ){
				list_int.add(Integer.valueOf(cc));
			}
		}catch(Exception e){
			list_int.add(200); // Default Exception HTTP RESPONSE CODE 200			
		}
		return list_int;
	}

	public List<String> getListStringFromStr(String str,String splitSign){
		List<String> list_str = new List<String>();
		try{
			String[] test = str.split(splitSign);
			for(String cc : test ){
				list_str.add(cc);
			}
		}catch(Exception e){
			list_str.add(''); 		
		}
		return list_str;
	}

	public String getFirstJSONTextFromTag(String jsonText,String tag){
		String retText = '';
		JSONParser parser = JSON.createParser(jsonText);
		while (parser.nextToken() != null) {
			if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == tag)) {
					parser.nextToken();
					retText = parser.getText();
					break;
			}
		}
		return retText;
	}

	public String getFirstKeyFromJSON(String jsonText){
		String retText = '';
		JSONParser parser = JSON.createParser(jsonText);
		while (parser.nextToken() != null) {
			if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
					retText = parser.getText();
					break;
			}
		}
		return retText;
	}


	///***************/ Start Section Encrypt n' Decrypt /***********************//
	public String getKey(String keyFromSystem){
		String key = '';
		//{SCS, DWH, CoreHP, CoreBank, HPAPAPI, FloorPlan, EC, OneApp, Protection}
		key = Test.isRunningTest()?'1cbabd9ad577e463647e38062637b09e0ad64fa72234fc4552c4b7e12ce518b2':'';
		switch on keyFromSystem{
			when 'DWH' {
				key = !Test.isRunningTest()?(String)SCSMessageAPIUtil.getEncryptKey( SCSMessageAPIUtil.fetchUserSessionId() , SCSMessageAPIUtil.INTEGRATE_SYSTEM.DWH ):key;
			}when 'SCS' {
				key = !Test.isRunningTest()?(String)SCSMessageAPIUtil.getEncryptKey( SCSMessageAPIUtil.fetchUserSessionId() , SCSMessageAPIUtil.INTEGRATE_SYSTEM.SCS ):key;
			}when 'CoreHP' {
				key = !Test.isRunningTest()?(String)SCSMessageAPIUtil.getEncryptKey( SCSMessageAPIUtil.fetchUserSessionId() , SCSMessageAPIUtil.INTEGRATE_SYSTEM.CoreHP ):key;
			}when 'CoreBank' {
				key = !Test.isRunningTest()?(String)SCSMessageAPIUtil.getEncryptKey( SCSMessageAPIUtil.fetchUserSessionId() , SCSMessageAPIUtil.INTEGRATE_SYSTEM.CoreBank ):key;
			}when 'HPAPAPI' {
				key = !Test.isRunningTest()?(String)SCSMessageAPIUtil.getEncryptKey( SCSMessageAPIUtil.fetchUserSessionId() , SCSMessageAPIUtil.INTEGRATE_SYSTEM.HPAPAPI ):key;
			}when 'FloorPlan' {
				key = !Test.isRunningTest()?(String)SCSMessageAPIUtil.getEncryptKey( SCSMessageAPIUtil.fetchUserSessionId() , SCSMessageAPIUtil.INTEGRATE_SYSTEM.FloorPlan ):key;
			}when 'EC' {
				key = !Test.isRunningTest()?(String)SCSMessageAPIUtil.getEncryptKey( SCSMessageAPIUtil.fetchUserSessionId() , SCSMessageAPIUtil.INTEGRATE_SYSTEM.EC ):key;
			}when 'OneApp' {
				key = !Test.isRunningTest()?(String)SCSMessageAPIUtil.getEncryptKey( SCSMessageAPIUtil.fetchUserSessionId() , SCSMessageAPIUtil.INTEGRATE_SYSTEM.OneApp ):key;
			}when 'Protection' {
				key = !Test.isRunningTest()?(String)SCSMessageAPIUtil.getEncryptKey( SCSMessageAPIUtil.fetchUserSessionId() , SCSMessageAPIUtil.INTEGRATE_SYSTEM.Protection ):key;
			}
		}
		encDeKey = key;
		return key;
	}

	public String EncryptMesage(String plainMessage,String keyFromSystem){
		String encMessage = '';
		encDeKey = encDeKey.trim().length()<1? getKey(keyFromSystem): encDeKey;
		encMessage = SCSMessageAPIUtil.encryptMessageWithKey(plainMessage,encDeKey);
		return encMessage;
	}

	public String DecryptMessage(String enCryptMessage,String keyFromSystem){
		String plainMessage = '';
		encDeKey = encDeKey.trim().length()<1? getKey(keyFromSystem): encDeKey;
		plainMessage = SCSMessageAPIUtil.decryptMessageWithKey(enCryptMessage,encDeKey);
		return plainMessage;
	}

	///***************/ End Section Encrypt n' Decrypt /***********************//

	public Boolean IssucessRequest(Boolean isHttp,Boolean isSuccess,String httpStatus,String statusCode,Integer resCode,String resStatus){
		Boolean isHttpSuccess = false;
		Boolean isStatusSuccess = false;
		
		List<Integer> isHttpInt = new List<Integer>();
		List<String> isSuccessCode = new List<String>();
		
		isHttpInt = getListIntegerFromStr(httpStatus,',');					// Prepare HTTP STATUS
		isSuccessCode = getListStringFromStr(statusCode, ',');				// Prepare Status Code

		isHttpSuccess = (isHttp==false)?true:isHttpInt.contains(resCode); 
		isStatusSuccess = (isSuccess==false)?true:isSuccessCode.contains(resStatus);

		return isHttpSuccess && isStatusSuccess;
	}

	private void onlineLog(String serviceName, String requestBody, String responseBody) {
		
		String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
		String customerName;
		String rmId;
		Account acc = new Account();
		String accountId;

		String base64Data ='';

		for (Map<String, Object> tmpMap : onlineSVL) {
			for (String key : tmpMap.keySet()) {
				switch on key{
					when 'customerName'{
						customerName = (String) tmpMap.get(key);
					}
					when 'rmId'{
						rmId = (String) tmpMap.get(key);
					}
					when 'accId'{
						accountId = (String) tmpMap.get(key);
						acc.Id = accountId;
					}
					when 'accSegment'{
						// to setup formula field
						String tmpSegment = ',"Core_Banking_Suggested_Segment__c":"'+(String) tmpMap.get(key)+'"}';
						String accStr = JSON.serialize(acc);
						accStr = accStr.substring(0,accStr.length()-1);
						accStr += tmpSegment;
						acc = (Account) JSON.deserialize(accStr, Account.class);
					}
				}
			}
		}

		// System.debug('isSuccessRequest : '+isSuccessRequest);
		// System.debug('customerName : '+customerName);
		// System.debug('errorMessageResponse : '+errorMessageResponse);
		// System.debug('uidLogId : '+uidLogId);
		// System.debug('userName : '+userName);
		// System.debug('rmId : '+rmId);
		// System.debug('serviceName : '+serviceName);
		// System.debug('requestBody : '+requestBody);
		// System.debug('responseBody : '+responseBody);
		// System.debug('acc : '+acc);
		// System.debug('startTime : '+startTime);
		// System.debug('endTime : '+endTime);
		// System.debug('base64Data : '+base64Data);

		RTL_Online_Service_Log__c onlineLog = new RTL_Online_Service_Log__c();
		//System.debug('uidLogId : '+uidLogId);
		OnlineServiceLogUtils.saveToOnlineLog(
			isSuccessRequest,
			customerName,
			errorMessageResponse,
			requestAppId+' '+uidLogId,
			userName,
			rmId,
			serviceName,
			requestBody,
			responseBody,
			acc,
			startTime,
			endTime,
			base64Data
		);
	}
}