public class CaseAttachmentController {
	public string docTypeItem {get;set;}
	public Boolean errorMessage {get;set;}
	public Id caseId {get;set;}
	public string obContentType {get;set;}
	public string messageLimit {get;set;}
	public Boolean isSuccess {get;set;}

	public String responseObjectId {get;set;}
	public String errorMessageRespone {get;set;}
	public String requestBody {get;set;}
	public String responseBody {get;set;}
	public DateTime startTime {get;set;}
	public DateTime endTime {get;set;}

	public Boolean endProcess {get;set;}

	public Boolean isAllowedEdit {get;set;}
	Public transient Attachment objCaseAttach {
		get{
			if(objCaseAttach==null){
				objCaseAttach = new Attachment();
			}
		return objCaseAttach;
		} set;
	}
	public string segment {
		get{
			if(segment == null){
				segment = 'P';
			}
			return segment;
		} 
		set;
	}

	public Map<string,string> mapOp {
		get{
			if(mapOp==null){
				mapOp = new Map<string,string>();
			}
			return mapOp;
		}
		set;
	}

	public CaseAttachmentController(ApexPages.StandardSetController stdController){
		messageLimit = Label.ECM_Case_Message;

		errorMessage = false;
		isAllowedEdit = true;
		caseId = ApexPages.CurrentPage().getParameters().get('id');
		List<Case> caseList = [SELECT Id,Customer_ID__c,AccountId,Customer_ID_Number__c, Customer_Name__c FROM Case where id =: caseId];

		if(caseList[0].AccountId==null){
			isAllowedEdit = false;
        	ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,  Label.Case_No_Account ));
		}

		//UserRecordAccess uAccess = [SELECT RecordID, HasReadAccess, HasEditAccess FROM UserRecordAccess
  //                                          WHERE UserId = : UserInfo.getUserId()
  //                                                  AND RecordID = : caseId
  //                                                          //AND HasReadAccess = True
  //                                         ];
  //      Case casePermision = [SELECT Id, Is_Edit_Branch_Queue__c, CreatedById, LastModifiedById, Status, All_Previous_Owner__c FROM case WHERE ID = :caseId];

  //      if( uAccess.HasEditAccess == true && casePermision.Is_Edit_Branch_Queue__c == true) {
  //      	isAllowedEdit = true;
  //      	//isAllowedEdit = false;
  //      	//ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,  Label.Case_Edit_NotAuthorizedMsg ));
  //      }
  //      else{
  //      	isAllowedEdit = false;
  //      	ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,  Label.Case_Edit_NotAuthorizedMsg ));
  //      }
		
	}

	public List<string> getDoc()
	{
		errorMessage = false;

		String defult = '--None--';
		List<String> intList = new List<String>{'1','2','3','4'};
		List<string> options = new List<string>();
		List<ECM_MS_Doctype__c> ecmDocList = new List<ECM_MS_Doctype__c>();
		List<Case> caseList = [SELECT Id,Customer_ID__c,AccountId,Customer_ID_Number__c, Customer_Name__c FROM Case where id =: caseId];
		system.debug('caseId '+caseId);
		system.debug('caseList '+caseList[0].AccountId);
		if(caseList.size()>0){
			List<Account> accOfDocList = [SELECT Id,Customer_Type__c,Name,Segment_crm__c FROM Account where Id=:caseList.get(0).AccountId];
		
			if(accOfDocList.size()>0){
				if(accOfDocList.get(0).Segment_crm__c !=null && accOfDocList.get(0).Segment_crm__c != ''){
					if(intList.contains(accOfDocList.get(0).Segment_crm__c)){
						segment ='C';
					}
					else{
						segment ='P';
					}
				}
				else{
					if(accOfDocList.get(0).Customer_Type__c =='Juristic'){
						segment ='C';
					}
				}
		

				ecmDocList= [SELECT Id,Segment__c,Source__c,Type_Code__c,Type_Name_EN__c
													,Type_Name_TH__c,Type_Short_Name__c,Document_Object__c
													FROM ECM_MS_Doctype__c where Segment__c =: segment and Document_Object__c like '%case%'];

				system.debug('ecmDocList '+ecmDocList);
				for( ECM_MS_Doctype__c value : ecmDocList)
				{
					mapOp.put(value.Type_Name_TH__c,value.Type_Code__c);
					options.add(value.Type_Name_TH__c);
				}
			}
		}
		if(options.size()>0){
			defult = options[0];
			options.sort();
		}
		else{
			options.add(defult);
			defult = options[0];
		}
		docTypeItem = defult;
	   	return options;
	}


	//public List<SelectOption> getDocType()
	//{
	//	String defult = '--None--';
	//	List<String> intList = new List<String>{'1','2','3','4'};
	//	List<SelectOption> options = new List<SelectOption>();
	//	List<ECM_MS_Doctype__c> ecmDocList = new List<ECM_MS_Doctype__c>();
	//	List<Case> caseList = [SELECT Id,Customer_ID__c,AccountId,Customer_ID_Number__c, Customer_Name__c FROM Case where id =: caseId];
	//	system.debug('caseId '+caseId);
	//	system.debug('caseList '+caseList[0].AccountId);
	//	if(caseList.size()>0){
	//		List<Account> accOfDocList = [SELECT Id,Customer_Type__c,Name,Segment_crm__c FROM Account where Id=:caseList.get(0).AccountId];
	//		if(accOfDocList.size()>0){
	//			if(accOfDocList.get(0).Segment_crm__c !=null && accOfDocList.get(0).Segment_crm__c != ''){
	//				if(intList.contains(accOfDocList.get(0).Segment_crm__c)){
	//					segment ='C';
	//				}
	//				else{
	//					segment ='P';
	//				}
	//			}
	//			else{
	//				if(accOfDocList.get(0).Customer_Type__c =='Juristic'){
	//					segment ='C';
	//				}
	//			}
	//			ecmDocList= [SELECT Id,Segment__c,Source__c,Type_Code__c,Type_Name_EN__c
	//												,Type_Name_TH__c,Type_Short_Name__c,Document_Object__c
	//												FROM ECM_MS_Doctype__c where Segment__c =: segment and Document_Object__c like '%case%'];
	//			system.debug('ecmDocList '+ecmDocList);
	//			for( ECM_MS_Doctype__c value : ecmDocList)
	//			{
	//				options.add(new SelectOption(value.Type_Code__c,value.Type_Name_TH__c));
	//			}
	//		}
	//	}
	//	if(options.size()>0){
	//		defult = options.get(0).getValue();
	//		options.sort();
	//	}
	//	else{
	//		options.add(new SelectOption(defult,defult));
	//		defult = options.get(0).getValue();
	//	}
	//	docTypeItem = defult;
	//   	return options;
	//}

	public PageReference upload(){
		system.debug('<-----------Upload------------>!!! ');
		endProcess = false;
		//segment = 'C';
		system.debug(docTypeItem);
		system.debug('value '+mapOp.get(docTypeItem));
		system.debug(segment);
		string docTypeKey = mapOp.get(docTypeItem);
		
		List<ECM_MS_Doctype__c> ecm = [SELECT Segment__c,Archival_Period__c,Disposal_Period__c,Expiry_Period__c,Repository__c
									,Type_Short_Name__c,Type_Code__c,Doc_Template__c,Doc_Location__c,Channel__c,Type_Name_TH__c
									,Source__c,Key__c FROM ECM_MS_Doctype__c Where Type_Code__c =:docTypeKey and Segment__c =:segment and Document_Object__c like '%case%' LIMIT 1];

		if(ecm.size()>0){
			system.debug(ecm[0]);
			String repositoryId = ecm[0].Repository__c;
			User user = [SELECT Id,FirstName,LastName,Employee_ID__c FROM User Where Id =: UserInfo.getUserid()];
			List<Case> caseMaster = [SELECT Id,CaseNumber,Customer_ID__c,AccountId,Customer_ID_Number__c, Customer_Name__c FROM Case where id =: caseId];
			List<Account> accList = [SELECT Id, First_Name_ENG_PE__c, Last_Name_PE_Eng__c, First_name_PE__c, 
										Last_name_PE__c,Core_Banking_Suggested_Segment__c,ID_Type_PE__c
										FROM Account where id =:caseMaster[0].AccountId];
			string caseNumber = caseMaster[0].CaseNumber;
			//string appId = caseMaster[0].CaseNumber+Datetime.now().format('YYYYMMddHHmmss');
			string appId = caseMaster[0].CaseNumber;
	
			if(Limits.getHeapSize()<3000000 && objCaseAttach.body != null){
				String fileName = objCaseAttach.Name;
				String base64Data = EncodingUtil.base64Encode(objCaseAttach.body);
				String contentType = obContentType;
	
				if(checkAllowType(contentType)){
					uploadToECM(fileName,base64Data,contentType,appId,ecm,repositoryId,user,caseMaster,accList,segment);
					if(isSuccess){
						uploadResulteToRepo(fileName,appId,ecm,user,accList);
						onlineLog(caseNumber,appId,caseMaster,accList,base64Data);
						// PageReference CasePage = new ApexPages.StandardController(caseMaster[0]).view();
        				// CasePage.setRedirect(true);

						ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'File upload successfully'));
						errorMessage = true;
						endProcess = true;
        				return null;
						
						// return null;
					}
					else{
						onlineLog(caseNumber,appId,caseMaster,accList,base64Data);
						ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessageRespone));
						errorMessage = true;
					}
				}
				else{
					ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ECM_Case_File_Type));
					errorMessage = true;
				}
			}
			else{
				if(Limits.getHeapSize()>3000000){
					ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,  Label.ECM_Case_File_Size));
				}
				else{
					ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ECM_Case_File_Empty));
				}
				errorMessage = true;
			}
		}
		else{
			ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ECM_Case_Doctype_Empty));
			errorMessage = true;
		}
		
		return null;
	}


	private Boolean checkAllowType(string contentType){	
		List<ContentTypeFile__mdt> ct = [SELECT Id, valueType__c, valueInit__c FROM ContentTypeFile__mdt where valueType__c=:contentType];
		if(ct.size()>0){
			return true;
		}
		else{
			return false;
		}
	}

	private string typeInt(string typeName){	
		List<ID_Type__mdt> typeList = [SELECT Id,Label, valueType__c FROM ID_Type__mdt where Label =:typeName];
		if(typeList.size()>0){
			return typeList[0].valueType__c;
		}
		else{
			return null;
		}
	}

	private void uploadToECM(String fileName, String base64Data, String contentType,String appId,List<ECM_MS_Doctype__c> ecm,String repositoryId,User user,List<Case> caseMaster,List<Account> accList,string segment){
		//prepare Data

		Datetime now = Datetime.now();
		Date d = Date.today();
		Datetime myDT = datetime.newInstance(d.year(), d.month(),d.day());

		string typeInt = typeInt(accList[0].ID_Type_PE__c);

		wsapiEcmClevelCom.dmsPropertiesType properties = new wsapiEcmClevelCom.dmsPropertiesType();
		wsapiEcmClevelCom.dmsPropertyId[] propId = new wsapiEcmClevelCom.dmsPropertyId[]{};
		wsapiEcmClevelCom.dmsPropertyId ObjectId = new wsapiEcmClevelCom.dmsPropertyId();
			ObjectId.propertyDefinitionId = 'dms:objectTypeId';
			String[] objectTypeId_value = new String[]{};
			objectTypeId_value.add(ecm[0].Doc_Template__c);
			ObjectId.value = objectTypeId_value;
		propId.add(ObjectId);

		String doc_Name = Datetime.now().format('yyyyMMddHHMM') + '-' + ecm[0].Type_Code__c + '-' + ecm[0].Type_Short_Name__c +'-' + fileName;
        
		wsapiEcmClevelCom.dmsPropertyString[] propString = new wsapiEcmClevelCom.dmsPropertyString[]{};
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
		if(segment == 'P'){
			wsapiEcmClevelCom.dmsPropertyString TMB_APPLICATION_ID = insertPropString('TMB_APPLICATION_ID',appId);
			propString.add(TMB_APPLICATION_ID);
			if(caseMaster[0].Customer_ID__c!=null){
				wsapiEcmClevelCom.dmsPropertyString TMB_CUSTOMER_ID = insertPropString('TMB_CUSTOMER_ID',caseMaster[0].Customer_ID__c);
				propString.add(TMB_CUSTOMER_ID);
			}
			
			if(caseMaster[0].Customer_ID_Number__c != null && typeInt != null)
			{
				wsapiEcmClevelCom.dmsPropertyString TMB_IDENTIFICATION_ID_PRIMARY  = insertPropString('TMB_IDENTIFICATION_ID_PRIMARY',caseMaster[0].Customer_ID_Number__c);
				propString.add(TMB_IDENTIFICATION_ID_PRIMARY);
				wsapiEcmClevelCom.dmsPropertyString TMB_IDENTIFICATION_TYPE_PRIMARY  = insertPropString('TMB_IDENTIFICATION_TYPE_PRIMARY',typeInt);
				propString.add(TMB_IDENTIFICATION_TYPE_PRIMARY);
			}
			
		}
		else{
			wsapiEcmClevelCom.dmsPropertyString TMB_APPLICATION_IDS = insertPropString('TMB_APPLICATION_IDS',appId);
			propString.add(TMB_APPLICATION_IDS);
			if(caseMaster[0].Customer_ID__c!=null){
				wsapiEcmClevelCom.dmsPropertyString TMB_CUSTOMER_IDS = insertPropString('TMB_CUSTOMER_IDS',caseMaster[0].Customer_ID__c);
				propString.add(TMB_CUSTOMER_IDS);
			}
			if(caseMaster[0].Customer_ID_Number__c != null)
			{
				wsapiEcmClevelCom.dmsPropertyString TMB_IDENTIFICATION_IDS = insertPropString('TMB_IDENTIFICATION_IDS',caseMaster[0].Customer_ID_Number__c);
				propString.add(TMB_IDENTIFICATION_IDS);
			}
		}
        wsapiEcmClevelCom.dmsPropertyString TMB_CUS_FIRST_NAME_EN = insertPropString('TMB_CUS_FIRST_NAME_EN',accList[0].First_Name_ENG_PE__c);
		propString.add(TMB_CUS_FIRST_NAME_EN);
       	wsapiEcmClevelCom.dmsPropertyString TMB_CUS_LAST_NAME_EN = insertPropString('TMB_CUS_LAST_NAME_EN',accList[0].Last_Name_PE_Eng__c);
		propString.add(TMB_CUS_LAST_NAME_EN);
        wsapiEcmClevelCom.dmsPropertyString TMB_CUS_FIRST_NAME_TH = insertPropString('TMB_CUS_FIRST_NAME_TH',accList[0].First_name_PE__c);
		propString.add(TMB_CUS_FIRST_NAME_TH);
        wsapiEcmClevelCom.dmsPropertyString TMB_CUS_LAST_NAME_TH = insertPropString('TMB_CUS_LAST_NAME_TH',accList[0].Last_name_PE__c );
		propString.add(TMB_CUS_LAST_NAME_TH);


		wsapiEcmClevelCom.dmsPropertyDateTime[] propDatetime = new wsapiEcmClevelCom.dmsPropertyDateTime[]{};
		Integer archivalDay;
		if(Date.isLeapYear(Date.Today().Year()) == true)
		{
			archivalDay = Integer.valueof(Double.valueof(ecm[0].Archival_Period__c)*366);
		}
		else if(Date.isLeapYear(Date.Today().Year()) == false)
		{
			archivalDay = Integer.valueof(Double.valueof(ecm[0].Archival_Period__c)*365);
		}
		Datetime datetime_archivalDay = now.AddDays(archivalDay);
		wsapiEcmClevelCom.dmsPropertyDateTime TMB_ARCHIVAL_DATETIME = insertPropDatetime('TMB_ARCHIVAL_DATETIME',datetime_archivalDay);
		propDatetime.add(TMB_ARCHIVAL_DATETIME);
		Integer DisposalDay;
		if(Date.isLeapYear(Date.Today().Year()) == true)
		{
			DisposalDay = Integer.valueof(Double.valueof(ecm[0].Disposal_Period__c)*366);
		}
		else if(Date.isLeapYear(Date.Today().Year()) == false)
		{
			DisposalDay = Integer.valueof(Double.valueof(ecm[0].Disposal_Period__c)*365);
		}
		DateTime datetime_DisposalDay = now.AddDays(DisposalDay);
		wsapiEcmClevelCom.dmsPropertyDateTime TMB_DISPOSAL_DATETIME = insertPropDatetime('TMB_DISPOSAL_DATETIME',datetime_DisposalDay);
		propDatetime.add(TMB_DISPOSAL_DATETIME);
		if(ecm[0].Expiry_Period__c != null)
		{
			Integer ExpiryDay;
			if(Date.isLeapYear(Date.Today().Year()) == true)
			{
				ExpiryDay = Integer.valueof(Double.valueof(ecm[0].Expiry_Period__c)*366);
			}
			else if(Date.isLeapYear(Date.Today().Year()) == false)
			{
				ExpiryDay = Integer.valueof(Double.valueof(ecm[0].Expiry_Period__c)*365);
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

		//upload to ECM
		try{
			UploadToECMController uploadECM = new UploadToECMController();
			UploadToECMController.upToECM res = uploadECM.createDocInECM(repositoryId,properties,folderId,folderPath,contentStream);
			isSuccess = res.isSuccess;
			errorMessageRespone = res.errorMessage;
			requestBody=res.requestToJSON;
			responseBody=res.responseToJSON;
			startTime = res.startTime;
			endTime = res.endTime;
			responseObjectId = res.responseObjectId;
		}
		catch (Exception e){
			string errorMessage = 'Message: ' + e.getMessage() + ' TypeName: ' + e.getTypeName() + ' StackTrace: ' + e.getStackTraceString();
			system.debug(errorMessage);
		}

	}

	private void uploadResulteToRepo(String fileName,String appId,List<ECM_MS_Doctype__c> ecm,User user,List<Account> accList){
		ECM_Repository__c insertEcmRep = new ECM_Repository__c();
			insertEcmRep.Object_ID__c = responseObjectId;
			insertEcmRep.Case__c = caseId;
			//String fullFileURL = URL.getSalesforceBaseUrl().getHost();
			String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
			
			insertEcmRep.File_Link__c = fullFileURL+'/apex/viewECMfile?obId=' + responseObjectId;
			insertEcmRep.Document_Type__c = ecm[0].Type_Name_TH__c;
			insertEcmRep.Repository__c = ecm[0].Repository__c;
			insertEcmRep.ECM_Uploaded_Date_Time__c = DateTime.Now();
			insertEcmRep.File_Name__c = fileName;
			insertEcmRep.Uploaded_By__c = UserInfo.getUserid();
			insertEcmRep.ECM_App_ID__c = appId;
			insertEcmRep.ECM_MS_Doctype_Key__c = ecm[0].Key__c;
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
			insertEcmRep.Customer_Firstname__c = accList[0].First_name_PE__c;
			insertEcmRep.Customer_Lastname__c = accList[0].Last_name_PE__c;
			insertEcmRep.Customer_Firstname_EN__c = accList[0].First_Name_ENG_PE__c;
			insertEcmRep.Customer_Lastname_EN__c = accList[0].Last_Name_PE_Eng__c;
		insert insertEcmRep;

		
	}

	private void onlineLog(String caseNumber,String appId,List<Case> caseMaster,List<Account> accList,String base64Data){
		//CS-190412-1779
		//customerName = eClient.Name;
		//case number
		String customerName = caseNumber;

		String msLogId = appId;
		String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
		String rmId = caseMaster[0].Customer_ID_Number__c;
		String serviceName = 'Add Case Attachment ECM';
		Account acc=accList[0];
		OnlineServiceLogUtils.saveToOnlineLog(isSuccess ,customerName, errorMessageRespone, msLogId , userName, rmId , serviceName ,requestBody ,responseBody , acc , startTime , endTime, base64Data );
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
}