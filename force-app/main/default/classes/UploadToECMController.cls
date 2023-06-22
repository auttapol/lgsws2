public class UploadToECMController {

	public class upToECM {
		public string requestToJSON{get;set;}
		public string responseObjectId{get;set;}
		public string responseToJSON{get;set;}
		public DateTime startTime {get;set;}
		public DateTime endTime {get;set;}
		public string errorMessage{get;set;}
		public boolean isECMUpload{get;set;}
		public boolean isSuccess = true;
    }

    public class deleteECM {
		public boolean succesDelete{get;set;}
		public string requestToJSON{get;set;}
		public string responseToJSON{get;set;}
		public string code{get;set;}
		public string errorMessage{get;set;}
		public string objectId{get;set;}
		public DateTime startTime {get;set;}
		public DateTime endTime {get;set;}
    }

    public class viewECM {
    	public boolean succesView{get;set;}
		public string requestToJSON{get;set;}
		public string responseToJSON{get;set;}
		public string errorMessage{get;set;}
		public string objectId{get;set;}
		public string contentType{get;set;}
		public DateTime startTime {get;set;}
		public DateTime endTime {get;set;}
		public string ecmFile{get;set;}
		public string base64Data{get;set;}
    }

    public App_Config__mdt appConMeta_Timeout{
    	get{
			if(appConMeta_Timeout==null){
				appConMeta_Timeout = [SELECT Id, Label, Value__c FROM App_Config__mdt WHERE Label = 'ECM_REQUEST_TIMEOUT']; 
			}
			return appConMeta_Timeout;
		}
    	set;
    }
    
    public User deleteByUser{
    	get{
			if(deleteByUser==null){
				deleteByUser = [SELECT Id, Name, LastName, FirstName, Employee_ID__c FROM User WHERE Id =:UserInfo.getUserId()]; 
			}
			return deleteByUser;
		}
    	set;
    }

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
	public upToECM createDocInECM(string repositoryId,wsapiEcmClevelCom.dmsPropertiesType properties,string folderId,string folderPath,wsapiEcmClevelCom.dmsContentStreamType contentStream){
		upToECM varUpToECM = new upToECM();
		varUpToECM.startTime = DateTime.Now();
		//AppConfig__c appCon_Endpoint = AppConfig__c.getValues('ECM_Endpoint');
		//App_Config__mdt appConMeta_Timeout = [SELECT Id, Label, Value__c FROM App_Config__mdt WHERE Label = 'ECM_REQUEST_TIMEOUT'];

		String versioningState = '';
		String[] policies = new String[]{};

		wsapiEcmClevelCom.dmsAccessControlListType addACEs = new wsapiEcmClevelCom.dmsAccessControlListType();

		wsapiEcmClevelCom.dmsAccessControlListType removeACEs = new wsapiEcmClevelCom.dmsAccessControlListType();
	
		wsapiEcmClevelCom.dmsExtensionType extension = new wsapiEcmClevelCom.dmsExtensionType();

		wsapiEcmClevelCom.ObjectServicePort createDocumentRequest = new wsapiEcmClevelCom.ObjectServicePort();

		wsapiEcmClevelCom.createDocumentResponse createDocumentResponse = new wsapiEcmClevelCom.createDocumentResponse();
		wsapiEcmClevelCom.createDocument createDoc = new wsapiEcmClevelCom.createDocument();
		createDocumentRequest.endpoint_x = appCon_Endpoint.Value__c;
		createDocumentRequest.timeout_x = Integer.valueof(appConMeta_Timeout.Value__c);

		try{
			createDocumentResponse = createDocumentRequest.createDocument(repositoryId,properties,folderId,folderPath,
									contentStream,versioningState,policies ,addACEs,removeACEs,extension);

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

		
			varUpToECM.requestToJSON = JSON.serialize(createDoc);
			varUpToECM.responseToJSON = JSON.serialize(createDocumentResponse);
			varUpToECM.responseObjectId = createDocumentResponse.objectId;
			varUpToECM.isECMUpload = true;

			varUpToECM.errorMessage = '';
			varUpToECM.isSuccess = true;
			varUpToECM.endTime = DateTime.Now();

			system.debug('UprepositoryId '+repositoryId);
		system.debug('varUpToECM.responseObjectId '+varUpToECM.responseObjectId);

		}
		catch (Exception e){
			varUpToECM.responseObjectId = '';
			varUpToECM.isECMUpload = false;
	
			varUpToECM.errorMessage = 'Message: ' + e.getMessage() + ' TypeName: ' + e.getTypeName() + ' StackTrace: ' + e.getStackTraceString();
			varUpToECM.isSuccess = false;
			varUpToECM.endTime = DateTime.Now();
		}
		
		return varUpToECM;

	}

	public deleteECM deleteInECM(string repositoryId,string objectId){
		deleteECM dECM = new deleteECM();
        string markDeleteBy = '00000';
		if(deleteByUser.Employee_ID__c != null && deleteByUser.Employee_ID__c !=''){
			markDeleteBy = string.valueOf(deleteByUser.Employee_ID__c);
		}
		wsapiEcmClevelCom.ObjectServicePort getContentRequest = new wsapiEcmClevelCom.ObjectServicePort();
        wsapiEcmClevelCom.dmsSuccessType dmsSuccessType = new wsapiEcmClevelCom.dmsSuccessType();
        wsapiEcmClevelCom.deleteObject requestContent = new wsapiEcmClevelCom.deleteObject();
        getContentRequest.endpoint_x = appCon_Endpoint.Value__c;
        dECM.startTime = DateTime.Now();
        getContentRequest.timeout_x = Integer.valueof(appConMeta_Timeout.Value__c);
        system.debug('repositoryId '+repositoryId);
        system.debug('objectId '+objectId);
        system.debug('markDeleteBy '+markDeleteBy);

		requestContent.repositoryId = repositoryId;
		requestContent.objectId = objectId;
		requestContent.markDeleteBy = markDeleteBy;
        dECM.requestToJSON = JSON.serialize(requestContent);

    	try{
	        dmsSuccessType = getContentRequest.deleteObject(repositoryId,objectId,markDeleteBy);
	        dECM.objectId = dmsSuccessType.objectId;
    		dECM.responseToJSON = JSON.serialize(dmsSuccessType);
	        dECM.succesDelete = true;
	        dECM.code = dmsSuccessType.code;
	        dECM.errorMessage = '';
	        system.debug('deleteObjectResponse  '+dECM.responseToJSON);
	        dECM.endTime = DateTime.Now();
    	}
    	catch(Exception e){
    		dECM.objectId = dmsSuccessType.objectId;
    		dECM.responseToJSON = JSON.serialize(dmsSuccessType);
	        dECM.succesDelete = false;
	        dECM.errorMessage = 'Message: ' + e.getMessage() + ' TypeName: ' + e.getTypeName() + ' StackTrace: ' + e.getStackTraceString();
    		system.debug('errorMessage  '+dECM.errorMessage);
    		dECM.endTime = DateTime.Now();

    	}
        //dmsSuccessType = getContentRequest.deleteObject(repositoryId,objectId,markDeleteBy);
  		return dECM;
	}

	public viewECM viewInECM(string repositoryId,string objectId){
		viewECM vECM = new viewECM();
		system.debug('testView ');
        vECM.startTime = DateTime.Now();
        String streamId = '';
        Integer offset = 0;
        Integer length = 0;

        wsapiEcmClevelCom.ObjectServicePort getContentRequest = new wsapiEcmClevelCom.ObjectServicePort();
        wsapiEcmClevelCom.dmsContentStreamType getContentResponse = new wsapiEcmClevelCom.dmsContentStreamType();
        wsapiEcmClevelCom.dmsExtensionType extension = new wsapiEcmClevelCom.dmsExtensionType();
           
        getContentRequest.endpoint_x = appCon_Endpoint.Value__c;
        getContentRequest.timeout_x = Integer.valueof(appConMeta_Timeout.Value__c);        
        try { 
            getContentResponse = getContentRequest.getContentStream(repositoryId,objectId,streamId,offset,length,extension);
            vECM.ecmFile = getContentResponse.stream;
            vECM.base64Data = getContentResponse.stream;
 

            wsapiEcmClevelCom.getContentStream getContent = new wsapiEcmClevelCom.getContentStream();
            getContent.repositoryId = repositoryId;
            getContent.objectId = objectId;
            getContent.streamId = streamId;
            getContent.offset = offset;
            getContent.length = length;

            getContentResponse.stream = 'encrypt';
            vECM.requestToJSON = JSON.serialize(getContent);
            vECM.responseToJSON = JSON.serialize(getContentResponse);

            vECM.contentType = getContentResponse.mimeType;
            system.debug('contentType '+vECM.contentType);
            //if(contentType.contains('application')){
            //    typePDF = true;
            //}
            
            vECM.succesView = true;
            vECM.errorMessage = '';
            vECM.endTime = DateTime.Now();

        } catch (Exception e) {
            vECM.errorMessage = 'Message: ' + e.getMessage() + ' TypeName: ' + e.getTypeName() + ' StackTrace: ' + e.getStackTraceString();
            system.debug('e.getMessage() '+e.getMessage());
            vECM.succesView = false;
            vECM.endTime = DateTime.Now();
        }
  		return vECM;
	}

	
}