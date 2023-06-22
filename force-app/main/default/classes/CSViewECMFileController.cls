public class CSViewECMFileController {
    public String ecmFile {get;set;}
	
	private String repId;
	private String objId;	

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
    public static App_Config__mdt appConMeta_ServiceName {
        get {
            if(appConMeta_ServiceName == null)
            {
                appConMeta_ServiceName = [SELECT Id, Label, Value__c FROM App_Config__mdt WHERE Label = 'ECM_GetServiceName'];
            }
            return appConMeta_ServiceName;
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

    public CSViewECMFileController()
    {
      
    }

    public void getStream()
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
		String base64Data;
		Id id = apexpages.currentpage().getparameters().get('ecId');

		E_Client_Suitability__c eClient = [SELECT Id,Name,CS_Customer__c,CS_Customer__r.ID_Number_PE__c,CS_Score__c,CS_Murex_ID__c,
			CS_Customer__r.TMB_Customer_ID_PE__c,CS_Customer__r.Core_Banking_Suggested_Segment__c,ECM_Repository__r.Repository__c,ECM_Repository__r.Object_ID__c 
			From E_Client_Suitability__c
			WHERE Id = : id
			];
        
        try 
        {         
            
            startTime = DateTime.Now();
            wsapiEcmClevelCom.ObjectServicePort getContentRequest = new wsapiEcmClevelCom.ObjectServicePort();
		    wsapiEcmClevelCom.dmsContentStreamType getContentResponse = new wsapiEcmClevelCom.dmsContentStreamType();

            String repositoryId = eClient.ECM_Repository__r.Repository__c;
            String objectId = eClient.ECM_Repository__r.Object_ID__c;
            String streamId = '';
            Integer offset = 0;
            Integer length = 0;
            wsapiEcmClevelCom.dmsExtensionType extension = new wsapiEcmClevelCom.dmsExtensionType();
            
            getContentRequest.endpoint_x = appCon_Endpoint.Value__c;
			getContentRequest.timeout_x = Integer.valueof(appConMeta_Timeout.Value__c);        
            if(!Test.isRunningTest())
			{  
				getContentResponse = getContentRequest.getContentStream(repositoryId,objectId,streamId,offset,length,extension);
                ecmFile = getContentResponse.stream;
			    base64Data = getContentResponse.stream;
            }
			else 
			{	
				getContentResponse = null;
                ecmFile = null;
			    base64Data = '';
			}

			wsapiEcmClevelCom.getContentStream getContent = new wsapiEcmClevelCom.getContentStream();
			getContent.repositoryId = repositoryId;
			getContent.objectId = objectId;
			getContent.streamId = streamId;
			getContent.offset = offset;
			getContent.length = length;

			getContentResponse.stream = 'encrypt';
			
			requestToJSON = JSON.serialize(getContent);
			responseToJSON = JSON.serialize(getContentResponse);
            
			isSuccess = true;
			errorMessage = '';
			endTime = DateTime.Now();

        } catch (Exception e) {
            errorMessage = 'Message: ' + e.getMessage() + ' TypeName: ' + e.getTypeName() + ' StackTrace: ' + e.getStackTraceString();
			isSuccess = false;
			endTime = DateTime.Now();
        }

        customerName = eClient.Name;
        msLogId = id+Datetime.now().format('YYYYMMddHHMMss');
        userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        rmId = eClient.CS_Customer__r.TMB_Customer_ID_PE__c;
        serviceName = appConMeta_ServiceName.Value__c;
        requestBody = requestToJSON;
        responseBody = responseToJSON;
        acc = eClient.CS_Customer__r;

        OnlineServiceLogUtils.saveToOnlineLog(isSuccess ,customerName, errorMessage, msLogId , userName, 
		rmId , serviceName ,requestBody ,responseBody , acc , startTime , endTime, base64Data);
              
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

        List<Attachment> importattachmentfileList = new List<Attachment>();
        if( requestBody != '' && requestBody != null)
        { 
            Attachment requestAttachment = new Attachment();
            requestAttachment.parentId = osLog.id;
            requestAttachment.name = 'getContent_requestBody.txt';
            requestAttachment.IsPrivate = false;
            requestAttachment.body = Blob.valueOf(requestBody);
            importattachmentfileList.add(requestAttachment);

        }

        if( responseBody != '' && responseBody != null )
        { 
            Attachment responseAttachment = new Attachment();
            responseAttachment.parentId = osLog.id;
            responseAttachment.name = 'getContent_responseBody.txt';
            responseAttachment.IsPrivate = false;
            responseAttachment.body = Blob.valueOf(responseBody);
            importattachmentfileList.add(responseAttachment);

        }

        if(  importattachmentfileList.size() > 0 )
        {

            insert importattachmentfileList;
        }
    }
	*/

}