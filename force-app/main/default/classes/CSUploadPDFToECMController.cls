public class CSUploadPDFToECMController {

	public static AppConfig__c appCon_Endpoint {
		get
		{ 
			if( appCon_Endpoint == null)
			{
				appCon_Endpoint = AppConfig__c.getValues('ECM_Endpoint');
			}
			return appCon_Endpoint;
		} 
		set; 
	}
	public static App_Config__mdt appConMeta_Timeout { 
		get
		{ 
			if( appConMeta_Timeout == null)
			{
				appConMeta_Timeout = [SELECT Id, Label, Value__c FROM App_Config__mdt WHERE Label = 'ECM_REQUEST_TIMEOUT']; 
			}
			return appConMeta_Timeout;
		} 
		set; 
	}
    public static App_Config__mdt appConMeta_Refresh {
		get
		{ 
			if( appConMeta_Refresh == null)
			{
				appConMeta_Refresh = [SELECT Id, Label, Value__c FROM App_Config__mdt WHERE Label = 'ECM_REFRESH_STATUS_INTERVAL'];
			}
			return appConMeta_Refresh;
		} 
		set; 
	}
	public static App_Config__mdt appConMeta_ServiceName {
		get
		{ 
			if( appConMeta_ServiceName == null)
			{
				appConMeta_ServiceName = [SELECT Id, Label, Value__c FROM App_Config__mdt WHERE Label = 'ECM_CreateServiceName'];
			}
			return appConMeta_ServiceName;
		} 
		set; 
	}
	public static ECM_Key__mdt appConMeta_DocKey {
		get
		{ 
			if( appConMeta_DocKey == null)
			{
				appConMeta_DocKey = [SELECT Id, Label, Key__c FROM ECM_Key__mdt WHERE Label = 'Eclient Doc Key'];
			}
			return appConMeta_DocKey;
		} 
		set;
	}

	@AuraEnabled
	public static E_Client_Suitability__c getEclient(Id eclientId)
	{
		try 
		{
			E_Client_Suitability__c eClient = [SELECT Id,Name,CS_Status__c,CS_Basic_Flag__c,
					CS_RM__c,CS_Sales_Owner__c,CS_Sales_Owner__r.Reporting_Segment__c,CS_Sales_Owner__r.Segment__c,CS_Sales_Owner__r.ManagerId,OwnerId,CS_Expiry_Date_Next__c,CS_Customer__c,
					CS_Score__c,CS_Murex_ID__c,CS_SIgn_Date__c,CS_New_Customer_flag__c,ECM_Repository__c,ECM_Repository__r.ECM_Uploaded_By__c,
					ECM_Repository__r.File_Name__c,ECM_Repository__r.Uploaded_By__r.Name,ECM_Repository__r.ECM_Uploaded_Date_Time__c,ECM_App_ID__c
					From E_Client_Suitability__c
					 WHERE Id = : eclientId
					];
			if(eClient.ECM_App_ID__c != null)
			{
				eClient.ECM_App_ID__c = null;
				update eClient;
			}

			return eClient;

		} 
		catch(Exception e) 
		{
			System.debug(e.getMessage());
			return null;			
		}
		
	}

	@AuraEnabled
	public static RTL_Online_Service_Log__c getOnlineLog(Id eclientId)
	{
		try 
		{
			RTL_Online_Service_Log__c onlineLog = new RTL_Online_Service_Log__c();

			E_Client_Suitability__c eClient = [SELECT Id,Name,CS_Status__c,CS_Basic_Flag__c,
					CS_RM__c,CS_Sales_Owner__c,OwnerId,CS_Expiry_Date_Next__c,CS_Customer__c,
					CS_Score__c,CS_Murex_ID__c,CS_SIgn_Date__c,CS_New_Customer_flag__c,ECM_Repository__c,ECM_App_ID__c,
					ECM_Repository__r.File_Name__c,ECM_Repository__r.Uploaded_By__r.Name,ECM_Repository__r.ECM_Uploaded_Date_Time__c
					From E_Client_Suitability__c
					 WHERE Id = : eclientId
					];

			if(String.isNotEmpty(eClient.ECM_App_ID__c)) {
				onlineLog = [SELECT Id,RTL_Is_Success__c,	RTL_Mulesoft_Log_Id__c,	RTL_Error_Message__c
						FROM RTL_Online_Service_Log__c 
						WHERE RTL_Mulesoft_Log_Id__c =: eClient.ECM_App_ID__c
						];
			}
			
			return onlineLog;
		} 
		catch(Exception e) 
		{
			System.debug(e.getMessage());
			return null;			
		}
		
	}

	@AuraEnabled
	public static AsyncApexJob getApexJob()
	{
		try 
		{
			List<AsyncApexJob> apexJob = [SELECT Id, CreatedDate, CreatedById, MethodName,ApexClassId, Status, ParentJobId,ExtendedStatus 
			FROM AsyncApexJob Where MethodName = 'uploadPDFtoECM' ORDER BY CreatedDate DESC LIMIT 1];

			return apexJob[0];
		} 
		catch(Exception e) 
		{
			System.debug(e.getMessage());
			return null;			
		}
		
	}
	// @future(callout=true)
	@AuraEnabled 
    public static void saveFile(String fileName, String base64Data, String contentType , Id eclientId) { 
		try{
			uploadPDFtoECM(fileName,base64Data,contentType,eclientId);
		}
		catch(Exception e) 
		{
			System.debug(e.getMessage());			
		}
    }

	@future(callout=true)
    public static void uploadPDFtoECM(String fileName, String base64Data, String contentType , Id eclientId)
    {
		Boolean isSuccess;
		String customerName;
		String msLogId;
		String errorMessage;
		String userName;
		String rmId;
		String serviceName;
		String requestBody;
		String responseBody;
		Account acc;
		DateTime startTime;
		DateTime endTime;

		String requestToJSON;
		String responseToJSON; 

		String appId;

		E_Client_Suitability__c eClient = [SELECT Id,Name,CS_Status__c,CS_Basic_Flag__c,
			CS_RM__c,CS_Sales_Owner__c,CS_Sales_Owner__r.Reporting_Segment__c,OwnerId,CS_Expiry_Date_Next__c,CS_Customer__c,CS_Customer__r.ID_Number_PE__c,ECM_Repository__c,
			CS_Score__c,CS_Murex_ID__c,CS_SIgn_Date__c,CS_New_Customer_flag__c,CS_Customer__r.TMB_Customer_ID_PE__c,CS_Customer__r.Core_Banking_Suggested_Segment__c,
			CS_Customer__r.First_name_PE__c,CS_Customer__r.Last_name_PE__c,CS_Customer__r.First_Name_ENG_PE__c,CS_Customer__r.Last_Name_PE_Eng__c
			From E_Client_Suitability__c
			WHERE Id = : eclientId
			];
		
		Datetime now = Datetime.now();
		Date d = Date.today();
		Datetime myDT = datetime.newInstance(d.year(), d.month(),d.day());

		appId = eclientId+Datetime.now().format('YYYYMMddHHmmss');

		List<ECM_MS_Doctype__c> ecm = [SELECT Archival_Period__c,Disposal_Period__c,Expiry_Period__c,Repository__c,
		Type_Short_Name__c,Type_Code__c,Doc_Template__c,Doc_Location__c,Channel__c,Source__c,Key__c FROM ECM_MS_Doctype__c Where Key__c =: appConMeta_DocKey.Key__c LIMIT 1];

		User user = [SELECT Id,FirstName,LastName,Employee_ID__c FROM User Where Id =: UserInfo.getUserid()];

		ECM_Repository__c insertEcmRep = new ECM_Repository__c();

		wsapiEcmClevelCom.ObjectServicePort createDocumentRequest = new wsapiEcmClevelCom.ObjectServicePort();
		wsapiEcmClevelCom.createDocumentResponse createDocumentResponse = new wsapiEcmClevelCom.createDocumentResponse();
		wsapiEcmClevelCom.createDocument createDoc = new wsapiEcmClevelCom.createDocument();
		try 
		{
			startTime = DateTime.Now();		

			base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

			String repositoryId = ecm[0].Repository__c;
			wsapiEcmClevelCom.dmsPropertiesType properties = new wsapiEcmClevelCom.dmsPropertiesType();

			wsapiEcmClevelCom.dmsPropertyId[] propId = new wsapiEcmClevelCom.dmsPropertyId[]{};
			wsapiEcmClevelCom.dmsPropertyId ObjectId = new wsapiEcmClevelCom.dmsPropertyId();
			ObjectId.propertyDefinitionId = 'dms:objectTypeId';
			String[] objectTypeId_value = new String[]{};
			objectTypeId_value.add(ecm[0].Doc_Template__c);
			ObjectId.value = objectTypeId_value;
			propId.add(ObjectId);

			wsapiEcmClevelCom.dmsPropertyString[] propString = new wsapiEcmClevelCom.dmsPropertyString[]{};
			String doc_Name = Datetime.now().format('YYYYMMddHHMM') + '-' + ecm[0].Type_Code__c + '-' + ecm[0].Type_Short_Name__c +'-' + fileName;
			wsapiEcmClevelCom.dmsPropertyString DocumentTitle = insertPropString('DocumentTitle',doc_Name);
			propString.add(DocumentTitle);

			wsapiEcmClevelCom.dmsPropertyString TMB_CREATOR_ID = insertPropString('TMB_CREATOR_ID',user.Employee_ID__c);
			propString.add(TMB_CREATOR_ID);

			wsapiEcmClevelCom.dmsPropertyString TMB_DOC_SUBMIT_CHANNEL = insertPropString('TMB_DOC_SUBMIT_CHANNEL',ecm[0].Channel__c);
			propString.add(TMB_DOC_SUBMIT_CHANNEL);

			wsapiEcmClevelCom.dmsPropertyString TMB_DOC_TYPE_CODE = insertPropString('TMB_DOC_TYPE_CODE',ecm[0].Type_Code__c);
			propString.add(TMB_DOC_TYPE_CODE);

			wsapiEcmClevelCom.dmsPropertyString TMB_SOURCE = insertPropString('TMB_SOURCE',ecm[0].Source__c);
			propString.add(TMB_SOURCE);

			wsapiEcmClevelCom.dmsPropertyString TMB_APPLICATION_IDS = insertPropString('TMB_APPLICATION_IDS',appId);
			propString.add(TMB_APPLICATION_IDS); 

			wsapiEcmClevelCom.dmsPropertyString TMB_CUSTOMER_IDS = insertPropString('TMB_CUSTOMER_IDS',eClient.CS_Customer__r.TMB_Customer_ID_PE__c);
			propString.add(TMB_CUSTOMER_IDS);

			if(eClient.CS_Customer__r.ID_Number_PE__c != null)
			{
				wsapiEcmClevelCom.dmsPropertyString TMB_IDENTIFICATION_IDS = insertPropString('TMB_IDENTIFICATION_IDS',eClient.CS_Customer__r.ID_Number_PE__c);
				propString.add(TMB_IDENTIFICATION_IDS);
			}
            
            wsapiEcmClevelCom.dmsPropertyString TMB_CUS_FIRST_NAME_EN = insertPropString('TMB_CUS_FIRST_NAME_EN',eClient.CS_Customer__r.First_Name_ENG_PE__c);
			propString.add(TMB_CUS_FIRST_NAME_EN);
            
            wsapiEcmClevelCom.dmsPropertyString TMB_CUS_LAST_NAME_EN = insertPropString('TMB_CUS_LAST_NAME_EN',eClient.CS_Customer__r.Last_Name_PE_Eng__c);
			propString.add(TMB_CUS_LAST_NAME_EN);
            
            wsapiEcmClevelCom.dmsPropertyString TMB_CUS_FIRST_NAME_TH = insertPropString('TMB_CUS_FIRST_NAME_TH',eClient.CS_Customer__r.First_name_PE__c);
			propString.add(TMB_CUS_FIRST_NAME_TH);
            
            wsapiEcmClevelCom.dmsPropertyString TMB_CUS_LAST_NAME_TH = insertPropString('TMB_CUS_LAST_NAME_TH',eClient.CS_Customer__r.Last_name_PE__c );
			propString.add(TMB_CUS_LAST_NAME_TH);

			
			wsapiEcmClevelCom.dmsPropertyDateTime[] propDatetime = new wsapiEcmClevelCom.dmsPropertyDateTime[]{};
			
			Integer archivalDay;
			if(Date.isLeapYear(Date.Today().Year()) == true)
			{
				archivalDay = Integer.valueof(ecm[0].Archival_Period__c)*366;
			}
			else if(Date.isLeapYear(Date.Today().Year()) == false)
			{
				archivalDay = Integer.valueof(ecm[0].Archival_Period__c)*365;
			}

			Datetime datetime_archivalDay = now.AddDays(archivalDay);

			wsapiEcmClevelCom.dmsPropertyDateTime TMB_ARCHIVAL_DATETIME = insertPropDatetime('TMB_ARCHIVAL_DATETIME',datetime_archivalDay);
			propDatetime.add(TMB_ARCHIVAL_DATETIME);

			Integer DisposalDay;
			if(Date.isLeapYear(Date.Today().Year()) == true)
			{
				DisposalDay = Integer.valueof(ecm[0].Disposal_Period__c)*366;
			}
			else if(Date.isLeapYear(Date.Today().Year()) == false)
			{
				DisposalDay = Integer.valueof(ecm[0].Disposal_Period__c)*365;
			}
			DateTime datetime_DisposalDay = now.AddDays(DisposalDay);
			wsapiEcmClevelCom.dmsPropertyDateTime TMB_DISPOSAL_DATETIME = insertPropDatetime('TMB_DISPOSAL_DATETIME',datetime_DisposalDay);
			propDatetime.add(TMB_DISPOSAL_DATETIME);

			if(ecm[0].Expiry_Period__c != null)
			{
				Integer ExpiryDay;
				if(Date.isLeapYear(Date.Today().Year()) == true)
				{
					ExpiryDay = Integer.valueof(ecm[0].Expiry_Period__c)*366;
				}
				else if(Date.isLeapYear(Date.Today().Year()) == false)
				{
					ExpiryDay = Integer.valueof(ecm[0].Expiry_Period__c)*365;
				}

				Datetime datetime_expiryDay = now.AddDays(ExpiryDay);

				wsapiEcmClevelCom.dmsPropertyDateTime TMB_DOC_EXPIRY_DATE = insertPropDatetime('TMB_DOC_EXPIRY_DATE',datetime_expiryDay);
				propDatetime.add(TMB_DOC_EXPIRY_DATE);
				
			}

			wsapiEcmClevelCom.dmsPropertyDateTime TMB_DOC_IMPORT_DATETIME = insertPropDatetime('TMB_DOC_IMPORT_DATETIME',now);
			propDatetime.add(TMB_DOC_IMPORT_DATETIME);

			wsapiEcmClevelCom.dmsPropertyDateTime TMB_DOC_PUBLISH_DATE = insertPropDatetime('TMB_DOC_PUBLISH_DATE',myDT);
			propDatetime.add(TMB_DOC_PUBLISH_DATE);

			properties.propertyId = propId;
			properties.propertyString = propString;
			properties.propertyDateTime = propDatetime;

			String folderId = '';
			String folderPath = ecm[0].Doc_Location__c;
			wsapiEcmClevelCom.dmsContentStreamType contentStream = new wsapiEcmClevelCom.dmsContentStreamType();
			contentStream.mimeType = contentType;
			contentStream.filename = fileName;
			contentStream.stream = base64Data;
			contentStream.length = base64Data.length();

			String versioningState = '';
			String[] policies = new String[]{};

			wsapiEcmClevelCom.dmsAccessControlListType addACEs = new wsapiEcmClevelCom.dmsAccessControlListType();

			wsapiEcmClevelCom.dmsAccessControlListType removeACEs = new wsapiEcmClevelCom.dmsAccessControlListType();
		
			wsapiEcmClevelCom.dmsExtensionType extension = new wsapiEcmClevelCom.dmsExtensionType();


			createDocumentRequest.endpoint_x = appCon_Endpoint.Value__c;
			createDocumentRequest.timeout_x = Integer.valueof(appConMeta_Timeout.Value__c);	
			if(!Test.isRunningTest())
			{  
				createDocumentResponse = createDocumentRequest.createDocument(repositoryId,properties,folderId,folderPath,
										contentStream,versioningState,policies ,addACEs,removeACEs,extension);
					
				insertEcmRep.Object_ID__c = createDocumentResponse.objectId;
			}
			else 
			{	
				createDocumentResponse = null;		   
				insertEcmRep.Object_ID__c = 'TestObjectID';
			}
			insertEcmRep.Is_ECM_Upload__c = true;

			contentStream.stream = 'encrypt';

			createDoc.repositoryId = repositoryId;
			createDoc.properties = properties;
			createDoc.folderId = folderId;
			createDoc.folderPath = folderPath;
			createDoc.contentStream = contentStream;
			createDoc.versioningState = versioningState;
			createDoc.policies = policies; 
			createDoc.addACEs = addACEs;
			createDoc.removeACEs = removeACEs;
			createDoc.extension = extension;

			requestToJSON = JSON.serialize(createDoc);
			responseToJSON = JSON.serialize(createDocumentResponse);

			isSuccess = true;
			errorMessage = '';
			endTime = DateTime.Now();
			
		}
		catch (Exception e)
		{				
			insertEcmRep.Object_ID__c = '';
			insertEcmRep.Is_ECM_Upload__c = false;

			startTime = DateTime.Now();	
			errorMessage = 'Message: ' + e.getMessage() + ' TypeName: ' + e.getTypeName() + ' StackTrace: ' + e.getStackTraceString();
			isSuccess = false;
			endTime = DateTime.Now();
			
		}
		insertEcmRep.E_Client_Suitability__c = eClient.Id;
		
		insertEcmRep.Repository__c = ecm[0].Repository__c;
		insertEcmRep.ECM_Uploaded_Date_Time__c = DateTime.Now();
		insertEcmRep.File_Name__c = fileName;
		insertEcmRep.Uploaded_By__c = UserInfo.getUserid();
		insertEcmRep.ECM_App_ID__c = appId;
		
		if(user.FirstName == null )
		{
			insertEcmRep.ECM_Uploaded_By__c = user.LastName + ', ' + DateTime.now().format('dd/MM/yyyy HH:mm:ss');
		}
		else if(user.LastName == null)
		{
			insertEcmRep.ECM_Uploaded_By__c = user.FirstName + ', ' + DateTime.now().format('dd/MM/yyyy HH:mm:ss');
		}
		else 
		{
		   insertEcmRep.ECM_Uploaded_By__c = user.FirstName +' '+ user.LastName + ', ' + DateTime.now().format('dd/MM/yyyy HH:mm:ss');
		}
		insertEcmRep.Customer_Firstname__c = eClient.CS_Customer__r.First_name_PE__c;
		insertEcmRep.Customer_Lastname__c = eClient.CS_Customer__r.Last_name_PE__c;
		insertEcmRep.Customer_Firstname_EN__c = eClient.CS_Customer__r.First_Name_ENG_PE__c;
		insertEcmRep.Customer_Lastname_EN__c = eClient.CS_Customer__r.Last_Name_PE_Eng__c;

		customerName = eClient.Name;
		msLogId = appId;
		userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
		rmId = eClient.CS_Customer__r.TMB_Customer_ID_PE__c;
		serviceName = appConMeta_ServiceName.Value__c;
		requestBody = requestToJSON;
		responseBody = responseToJSON;
		acc = eClient.CS_Customer__r;
		insert insertEcmRep;
		if(insertEcmRep.E_Client_Suitability__c != null && insertEcmRep.Is_ECM_Upload__c == true)
		{	
			eClient.ECM_Repository__c = insertEcmRep.Id;		
		}
		eClient.ECM_App_ID__c = appId;
		update eClient;	
	
		OnlineServiceLogUtils.saveToOnlineLog(isSuccess ,customerName, errorMessage, msLogId , userName, 
		rmId , serviceName ,requestBody ,responseBody , acc , startTime , endTime, base64Data );

	}

	public static wsapiEcmClevelCom.dmsPropertyString insertPropString(String propertyDefinitionId,String value)
	{
		wsapiEcmClevelCom.dmsPropertyString propString = new wsapiEcmClevelCom.dmsPropertyString();
		propString.propertyDefinitionId = propertyDefinitionId;
		String[] propString_value = new String[]{};
		propString_value.add(value);
		propString.value = propString_value;
		return propString;

	}

	public static wsapiEcmClevelCom.dmsPropertyDateTime insertPropDatetime(String propertyDefinitionId,DateTime value)
	{
		wsapiEcmClevelCom.dmsPropertyDateTime propDatetime = new wsapiEcmClevelCom.dmsPropertyDateTime();
		propDatetime.propertyDefinitionId = propertyDefinitionId;
		Datetime[] propDatetime_value = new DateTime[]{};
		propDatetime_value.add(value);
		propDatetime.value = propDatetime_value;
		return propDatetime;

	}

    /*
	public static void saveToOnlineLog(Boolean isSuccess ,String customerName, String errorMessage, String msLogId , String userName, 
                            String rmId , String serviceName ,String requestBody ,String responseBody , Account acc , 
                            DateTime startTime , DateTime endTime, String base64Data )
    {
        RTL_Online_Service_Log__c osLog = new RTL_Online_Service_Log__c();
        
        osLog.RTL_Is_Success__c = isSuccess;  

        osLog.RTL_Customer_Name__c = customerName;
        
        osLog.RTL_Error_Message__c = errorMessage;
       
        osLog.RTL_Mulesoft_Log_Id__c = msLogId;
    
        osLog.RTL_Name_of_User__c = userName;

        osLog.RTL_RM_ID__c = rmId;
    
        osLog.RTL_Service_Name__c = serviceName;

        if( acc != null )
        {
            osLog.RTL_Account__c = acc.id;
            osLog.RTL_Customer_Segment__c = acc.Core_Banking_Suggested_Segment__c;
        }

        osLog.RTL_Start_DateTime__c = startTime;
        osLog.RTL_End_DateTime__c  = endTime;
        
        insert osLog;

        //List<Attachment> importattachmentfileList = new List<Attachment>();
        if( requestBody != '' && requestBody != null)
        { 
            //Attachment requestAttachment = new Attachment();
            //requestAttachment.parentId = osLog.id;
            //requestAttachment.name = 'createDocument_requestBody.txt';
            //requestAttachment.IsPrivate = false;
            //requestAttachment.body = Blob.valueOf(requestBody);
            //importattachmentfileList.add(requestAttachment);
            GenerateContentVersion(osLog.id, 'createDocument_requestBody.txt', false, Blob.valueOf(requestBody));
        }

        if( responseBody != '' && responseBody != null )
        { 
            //Attachment responseAttachment = new Attachment();
            //responseAttachment.parentId = osLog.id;
            //responseAttachment.name = 'createDocument_responseBody.txt';
            //responseAttachment.IsPrivate = false;
            //responseAttachment.body = Blob.valueOf(responseBody);
            //importattachmentfileList.add(responseAttachment);
            GenerateContentVersion(osLog.id, 'createDocument_responseBody.txt', false, Blob.valueOf(requestBody));
        }

        //if(  importattachmentfileList.size() > 0 )
        //{
        //    insert importattachmentfileList;
        //}
    }
    */

    private static void GenerateContentVersion (string parentId, string name, boolean isPrivated, Blob body) {
        
        ContentVersion cv = new ContentVersion();
		cv.ContentLocation = 'S'; //S - Salesforce
		cv.PathOnClient = name;
		cv.Origin = 'H'; //H - Chatter
		cv.Title = name;
		cv.VersionData = body;
        insert cv;
        
        // [cv] should have [Id] after [insert] command
        ContentVersion insertedCv = [SELECT Id, OwnerId, ContentDocumentId
                                     FROM ContentVersion
                                     WHERE Id =: cv.Id];
        
        ContentDocumentLink autoInsertCl = [SELECT Id, LinkedEntityId, ContentDocumentId
                                            FROM ContentDocumentLink
                                            WHERE ContentDocumentId =: insertedCv.ContentDocumentId];
        
        ContentDocumentLink clonedCl = autoInsertCl.clone();
        clonedCl.ShareType = 'V';
        clonedCl.LinkedEntityId = parentId;
        insert clonedCl;
        delete autoInsertCl;
    }
    
	@AuraEnabled
	public static List<Integer> ecmTimeOut(){

		List<Integer> timeOut = new List<Integer>();
		
		timeOut.add(Integer.valueof(appConMeta_Timeout.Value__c));
		timeOut.add(Integer.valueof(appConMeta_Refresh.Value__c));
		return timeOut;
	  
	}

	@AuraEnabled 
    public static User getCurrentUser(){
     // query current user information  
      User oUser = [Select Id,Name,Username,Country,Email,FirstName,LastName,IsActive,Segment__c,ManagerId,Reporting_Segment__c,Profile.Name
                 FROM User Where Id =: userInfo.getUserId() AND isActive=true];
        return oUser;
    }
	

}