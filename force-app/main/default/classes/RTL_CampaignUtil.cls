public class RTL_CampaignUtil 
{
    public static String remark;
    public static String service;
    public static final String SF_ERROR_CODE = 'Salesforce Error';
    public static final String INT06_SERVICE_NAME = 'RetriveCampaignMember';
    public static final String INT07_SERVICE_NAME = 'RetriveSmsUssdRegistration';

    public static final String INT06_NO_RESPONSE_ERROR = 'No Response from INT06';
    public static final String INT07_NO_RESPONSE_ERROR = 'No Response from INT07';
    
    public static final String HTTP_RESPONSE_ERROR = 'Http response error';
    
    public static final Map<Integer,String> HTTP_RESPONSE_STATUS_CODE = new Map<Integer,String>{
        200=>'Ok',
        201=>'Created',
        204=>'No Content',
        400=>'Bad Request',
        403=>'Forbidden',
        404=>'Not Found',
        405=>'Method Not Allowed',
        409=>'Conflict',
        500=>'Internal Server Error',
        2000=>'The timeout was reached, and the server didn’t get a chance to respond',
        2001=>'There was a connection failure.',
        2002=>'Exceptions occurred.',
        2003=>'The response hasn’t arrived (which also means that the Apex asynchronous callout framework hasn’t resumed).',
        2004=>'The response size is too large (greater than 1 MB).',
        9999=>'Unknow Status'
    };

    public static String getHttpResponseMessage( String statusText , Integer statusCode)
    {
        if( statusText == null || statusText == '' )
        {
            if( RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.containsKey(statusCode) )
            {
                statusText = RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(statusCode);
            }
            else
            { 
                statusText = RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(9999);
            }
        }

        return HTTP_RESPONSE_ERROR + ': ' + statusText + '(' + statusCode + ')';
    }

    public static void insertOnlineLogWithResponse(String errorCodeLog,String resultDesc,String rmId,String serviceName,
        Id accId ,String requestBody, String responseBody , DateTime startTime , DateTime endTime )
    {
        //User u = [SELECT Id,FirstName,LastName,Employee_ID__c FROM User WHERE id =:UserInfo.getUserId() ];
        // System.debug('IM HERE ' + errorCodeLog + ' A ' + resultDesc);
        
        Account acc = new Account();
        if( accId != null )
        {
            acc = [SELECT id,Core_Banking_Suggested_Segment__c,name FROM Account WHERE id=:accId];
        }
        
        String customerName = acc.name;

        String errorMessage = '';
        Boolean isSuccess = false;
        String msLogId = '';
        //String userName = u.FirstName + ' ' + u.LastName;
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();

        if( errorCodeLog == '' )
        {
            if( resultDesc != '' && resultDesc != 'success')
            {
                errorCodeLog = 'Salesforce Error';
                errorMessage = errorCodeLog + '|' + resultDesc;
            }
            else
            {
                errorMessage = '' + resultDesc;
            }
        }
        else
        {
            errorMessage = errorCodeLog + '|' + resultDesc;
        }

        if( errorMessage == '' || errorMessage == 'success')
        {
            isSuccess = true;
        }
        else
        {
            isSuccess = false;
        }

        RTL_CampaignUtil.saveToOnlineLog(isSuccess ,customerName, errorMessage, 
                        msLogId , userName ,
                        rmId , serviceName ,                 
                        requestBody ,responseBody, 
                        acc, startTime , endTime );

    }

    //*********************************************************************This method For save online log only For INT01

    public static void insertOnlineLogWithResponseINT01(String errorCodeLog,String resultDesc,String rmId,String serviceName,
        String CampName ,String requestBody, String responseBody , DateTime startTime , DateTime endTime )
    {
        
        String customerName = CampName;

        String errorMessage = '';
        Boolean isSuccess = false;
        String msLogId = '';
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();

        if( errorCodeLog == '' )
        {
            if( resultDesc != '' && resultDesc != 'success')
            {
                errorCodeLog = 'Salesforce Error';
                errorMessage = errorCodeLog + '|' + resultDesc;
            }
            else
            {
                errorMessage = '' + resultDesc;
            }
        }
        else
        {
            errorMessage = errorCodeLog + '|' + resultDesc;
        }

        if( errorMessage == '' || errorMessage == 'success')
        {
            isSuccess = true;
        }
        else
        {
            isSuccess = false;
        }

        RTL_CampaignUtil.saveToOnlineLog(isSuccess ,customerName, errorMessage, 
                        msLogId , userName ,
                        rmId , serviceName ,                 
                        requestBody ,responseBody, 
                        null, startTime , endTime );

    }

    // CR203 - Product holding : Update adding paramenter mslogid 
    public static void insertOnlineLogWithResponse(String errorCodeLog, String resultDesc, String rmId, String reqId, String serviceName,
        Id accId, String requestBody, String responseBody, DateTime startTime, DateTime endTime)
    {
        //User u = [SELECT Id,FirstName,LastName,Employee_ID__c FROM User WHERE id =:UserInfo.getUserId() ];
        // System.debug('IM HERE ' + errorCodeLog + ' A ' + resultDesc);
        
        Account acc = new Account();
        if( accId != null )
        {
            acc = [SELECT id,Core_Banking_Suggested_Segment__c,name FROM Account WHERE id=:accId];
        }
        
        String customerName = acc.name;

        String errorMessage = '';
        Boolean isSuccess = false;
        String msLogId = reqId;
        //String userName = u.FirstName + ' ' + u.LastName;
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();

        if( errorCodeLog == '' )
        {
            if( resultDesc != '' && resultDesc != 'success')
            {
                errorCodeLog = 'Salesforce Error';
                errorMessage = errorCodeLog + '|' + resultDesc;
            }
            else
            {
                errorMessage = '' + resultDesc;
            }
        }
        else
        {
            errorMessage = errorCodeLog + '|' + resultDesc;
        }

        if( errorMessage == '' || errorMessage == 'success')
        {
            isSuccess = true;
        }
        else
        {
            isSuccess = false;
        }

        RTL_CampaignUtil.saveToOnlineLog(isSuccess ,customerName, errorMessage, 
                        msLogId , userName ,
                        rmId , serviceName ,                 
                        requestBody ,responseBody, 
                        acc, startTime , endTime );
    }

    /*
    * Standard online log save method
    * V2 - add datetime for start and end Date
    */
    public static void saveToOnlineLog(Boolean isSuccess ,String customerName, String errorMessage, String msLogId , String userName, 
                            String rmId , String serviceName ,String requestBody ,String responseBody , Account acc , 
                            DateTime startTime , DateTime endTime )
    {
        // System.debug('CHECK RES REQ ' + requestBody + '\n' + responseBody);
        RTL_Online_Service_Log__c osLog = new RTL_Online_Service_Log__c();
        
        //*** Mapping from TSD ****//
        osLog.RTL_Is_Success__c = isSuccess;  

        //Campaign.Name - INT 01
        //Account.Name - INT 06,07
        osLog.RTL_Customer_Name__c = customerName;
        //MuleSoft.Message
        osLog.RTL_Error_Message__c = errorMessage;
        //Mulesoft.LogId
        osLog.RTL_Mulesoft_Log_Id__c = msLogId;
        //User.FirstName + " " + User.LastName
        osLog.RTL_Name_of_User__c = userName;
        //Campaign.code - INT01
        //Marketting Code or TMB cust ID - INT 06 07
        osLog.RTL_RM_ID__c = rmId;
        // CampaignMaster - INT 01 
        // RetriveCampaignMember - INT 06
        // TBD - INT 07
        osLog.RTL_Service_Name__c = serviceName;


        // String customerSegment = '';
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
            requestAttachment.name = 'requestBody.txt';
            requestAttachment.IsPrivate = false;
            requestAttachment.body = Blob.valueOf(requestBody);
            importattachmentfileList.add(requestAttachment);
        }

        if( responseBody != '' && responseBody != null )
        { 
            Attachment responseAttachment = new Attachment();
            responseAttachment.parentId = osLog.id;
            responseAttachment.name = 'responseBody.txt';
            responseAttachment.IsPrivate = false;
            responseAttachment.body = Blob.valueOf(responseBody);
            importattachmentfileList.add(responseAttachment);
        }

        if(  importattachmentfileList.size() > 0 )
        {
            // System.debug('ADD Attachment!');
            insert importattachmentfileList;
        }
    }

    //Duplicate Method to add REMARK
    public static void saveToOnlineLog(Boolean isSuccess, String customerName, String errorMessage, String msLogId, String userName, String rmId, String serviceName, String requestBody, String responseBody, Account acc, DateTime startTime, DateTime endTime, String remark){
        System.debug(RTL_CampaignUtil.remark);

        // if(RTL_CampaignUtil.remark != null && RTL_CampaignUtil.remark != ''){
        //     RTL_Online_Service_Log__c osLogNew = new RTL_Online_Service_Log__c();
        
        //     osLogNew.RTL_Is_Success__c = isSuccess;  
        //     osLogNew.RTL_Customer_Name__c = customerName;
        //     osLogNew.RTL_Error_Message__c = errorMessage;
        //     osLogNew.RTL_Mulesoft_Log_Id__c = msLogId;
        //     osLogNew.RTL_Name_of_User__c = userName;
        //     osLogNew.RTL_RM_ID__c = rmId;
        //     osLogNew.RTL_Service_Name__c = RTL_CampaignUtil.service;

        //     if(acc != null){
        //         osLogNew.RTL_Account__c = acc.id;
        //         osLogNew.RTL_Customer_Segment__c = acc.Core_Banking_Suggested_Segment__c;
        //     }

        //     osLogNew.RTL_Start_DateTime__c = startTime;
        //     osLogNew.RTL_End_DateTime__c  = endTime;
            
        //     insert osLogNew;
        // }

        RTL_Online_Service_Log__c osLog = new RTL_Online_Service_Log__c();
        
        osLog.RTL_Is_Success__c = isSuccess;  
        osLog.RTL_Customer_Name__c = customerName;
        osLog.RTL_Error_Message__c = errorMessage;
        osLog.RTL_Mulesoft_Log_Id__c = msLogId;
        osLog.RTL_Name_of_User__c = userName;
        osLog.RTL_RM_ID__c = rmId;
        osLog.RTL_Service_Name__c = serviceName;
        osLog.Remark__c = remark;

        if(acc != null){
            osLog.RTL_Account__c = acc.id;
            osLog.RTL_Customer_Segment__c = acc.Core_Banking_Suggested_Segment__c;
        }

        osLog.RTL_Start_DateTime__c = startTime;
        osLog.RTL_End_DateTime__c  = endTime;
        
        insert osLog;

        List<Attachment> importattachmentfileList = new List<Attachment>();

        if( requestBody != '' && requestBody != null){ 
            Attachment requestAttachment = new Attachment();
            requestAttachment.parentId = osLog.id;
            requestAttachment.name = 'requestBody.txt';
            requestAttachment.IsPrivate = false;
            requestAttachment.body = Blob.valueOf(requestBody);
            importattachmentfileList.add(requestAttachment);
        }

        if( responseBody != '' && responseBody != null ){ 
            Attachment responseAttachment = new Attachment();
            responseAttachment.parentId = osLog.id;
            responseAttachment.name = 'responseBody.txt';
            responseAttachment.IsPrivate = false;
            responseAttachment.body = Blob.valueOf(responseBody);
            importattachmentfileList.add(responseAttachment);
        }

        if(  importattachmentfileList.size() > 0 ){
            insert importattachmentfileList;
        }
    }

/*
    * DataPartition Standard online log save method
    * V2 - add datetime for start and end Date
    */
    public static void saveToOnlineLogDataPartition(Boolean isSuccess ,String customerName, String errorMessage, String msLogId , String userName, 
                            String rmId , String serviceName ,String requestBody ,String responseBody , Account acc , 
                            DateTime startTime , DateTime endTime, Boolean isDataPartition )
    {
        RTL_Online_Service_Log__c osLog = new RTL_Online_Service_Log__c();

        osLog.dpt_Data_Partition_Log__c = isDataPartition;
                
        //*** Mapping from TSD ****//
        osLog.RTL_Is_Success__c = isSuccess;  

        //Campaign.Name - INT 01
        //Account.Name - INT 06,07
        osLog.RTL_Customer_Name__c = customerName;
        //MuleSoft.Message
        osLog.RTL_Error_Message__c = errorMessage;
        //Mulesoft.LogId
        osLog.RTL_Mulesoft_Log_Id__c = msLogId;
        //User.FirstName + " " + User.LastName
        osLog.RTL_Name_of_User__c = userName;
        //Campaign.code - INT01
        //Marketting Code or TMB cust ID - INT 06 07
        osLog.RTL_RM_ID__c = rmId;
        // CampaignMaster - INT 01 
        // RetriveCampaignMember - INT 06
        // TBD - INT 07
        osLog.RTL_Service_Name__c = serviceName;

        osLog.RTL_Account__c = acc.id;

        // String customerSegment = '';
        if( acc != null )
        {
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
            requestAttachment.name = 'requestBody.txt';
            requestAttachment.IsPrivate = false;
            requestAttachment.body = Blob.valueOf(requestBody);
            importattachmentfileList.add(requestAttachment);
        }

        if( responseBody != '' && responseBody != null )
        { 
            Attachment responseAttachment = new Attachment();
            responseAttachment.parentId = osLog.id;
            responseAttachment.name = 'responseBody.txt';
            responseAttachment.IsPrivate = false;
            responseAttachment.body = Blob.valueOf(responseBody);
            importattachmentfileList.add(responseAttachment);
        }

        if(  importattachmentfileList.size() > 0 )
        {
            insert importattachmentfileList;
        }
    }
    
    /*  Method for old version of save log without date start/end */

    /*
    * Standard online log save method
    */
    public static void saveToOnlineLog(Boolean isSuccess ,String customerName, String errorMessage, String msLogId , String userName, 
                            String rmId , String serviceName ,String requestBody ,String responseBody , Account acc )
    {
        saveToOnlineLog( isSuccess ,customerName, errorMessage, 
                msLogId , userName ,
                rmId , serviceName ,                 
                requestBody ,responseBody, 
                acc, System.now() , System.now() );
    }
  /*
    * Data Partition online log save method
    */
    public static void saveToOnlineLogDataPartition(Boolean isSuccess ,String customerName, String errorMessage, String msLogId , String userName, 
                            String rmId , String serviceName ,String requestBody ,String responseBody , Account acc, Boolean isDataPartition)
    {
        saveToOnlineLogDataPartition( isSuccess ,customerName, errorMessage, 
                msLogId , userName ,
                rmId , serviceName ,                 
                requestBody ,responseBody, 
                acc, System.now() , System.now(), isDataPartition);
    }

    /*
        Standard online log save method
        V2 - add datetime for start and end Date
        V3 - add insert online service log list
    */
    // List<OnlineServiceLog> onlineServiceLog, String customerName, String errorMessage, String msLogId, String userName, String rmId, String serviceName, Account acc, DateTime startTime, DateTime endTime
    public static void saveToOnlineLog(List<OnlineServiceLog> onlineServiceLog, String customerName, String errorMessage, String msLogId, String userName, String rmId, String serviceName, Account acc, DateTime startTime, DateTime endTime) {

        List<RTL_Online_Service_Log__c> osLog_lst = new List<RTL_Online_Service_Log__c>();
        List<Attachment> importattachmentfileList = new List <Attachment>();

        for (OnlineServiceLog osl : onlineServiceLog) {
            RTL_Online_Service_Log__c osLog = new RTL_Online_Service_Log__c();
            //*** Mapping from TSD ****//
            osLog.RTL_Is_Success__c = osl.isSuccess;
            //Campaign.Name - INT 01
            //Account.Name - INT 06,07
            osLog.RTL_Customer_Name__c = customerName;
            //MuleSoft.Message
            osLog.RTL_Error_Message__c = osl.errorMesssage;
            //Mulesoft.LogId
            osLog.RTL_Mulesoft_Log_Id__c = msLogId;
            //User.FirstName + " " + User.LastName
            osLog.RTL_Name_of_User__c = userName;
            //Campaign.code - INT01
            //Marketting Code or TMB cust ID - INT 06 07
            osLog.RTL_RM_ID__c = rmId;
            // CampaignMaster - INT 01 
            // RetriveCampaignMember - INT 06
            // TBD - INT 07
            osLog.RTL_Service_Name__c = serviceName;

            if (acc != null) {
                osLog.RTL_Account__c = acc.id;
                osLog.RTL_Customer_Segment__c = acc.Core_Banking_Suggested_Segment__c;
            }
            osLog.RTL_Start_DateTime__c = startTime;
            osLog.RTL_End_DateTime__c = endTime;

            osLog_lst.add(osLog);
        }
        if (osLog_lst.size() > 0) {
            insert osLog_lst;
        }

        for (Integer i = 0; i < osLog_lst.size(); i++) {
            RTL_Online_Service_Log__c rtl_osl = osLog_lst.get(i);
            OnlineServiceLog osl = onlineServiceLog.get(i);
            if (osl.requestBody != '' && osl.requestBody != null) {
                Attachment requestAttachment = new Attachment();
                requestAttachment.parentId = rtl_osl.Id;
                requestAttachment.name = 'requestBody.txt';
                requestAttachment.IsPrivate = false;
                requestAttachment.body = Blob.valueOf(osl.requestBody);
                importattachmentfileList.add(requestAttachment);
            }
            if (osl.responseBody != '' && osl.responseBody != null) {
                Attachment responseAttachment = new Attachment();
                responseAttachment.parentId = rtl_osl.Id;
                responseAttachment.name = 'responseBody.txt';
                responseAttachment.IsPrivate = false;
                responseAttachment.body = Blob.valueOf(osl.responseBody);
                importattachmentfileList.add(responseAttachment);
            }
        }
        if (importattachmentfileList.size() > 0) {
            insert importattachmentfileList;
        }
    }
	
	@future
    public static void saveToOnlineLogFuture(Boolean isSuccess ,String customerName, String errorMessage, String msLogId , String userName, 
                            String rmId , String serviceName ,String requestBody ,String responseBody , String acc , 
                            DateTime startTime , DateTime endTime )
    {
        Account account = (Account)JSON.deserialize(acc, Account.class);
        saveToOnlineLog(isSuccess ,customerName, errorMessage, msLogId , userName, 
                            rmId , serviceName ,requestBody ,responseBody , account , 
                            startTime , endTime );
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getRecordTypeCampaignMap() {
        Map<String, Object> recordTpyeMap = new Map<String, Object>();
        for (Campaign_Type_RecordType_Mapping__c ctr : [SELECT Name, RecordType_Id__c FROM Campaign_Type_RecordType_Mapping__c]) {
            recordTpyeMap.put(ctr.Name, ctr.RecordType_Id__c);
        }
        return recordTpyeMap;
    }
    
    public static void insertOnlineServiceLogMultiWithAttach(Map<String, RTL_Online_Service_Log__c> osloglst, Map<String, OnlineServiceLog> oslogDetaillst){
        List<Attachment> importattachmentfileList = new List <Attachment>();
        
        if (osloglst.size() > 0) {
            insert osloglst.values();
        }

        for (String key : osloglst.keySet()) {
            RTL_Online_Service_Log__c rtl_osl = osloglst.containsKey(key) ? osloglst.get(key) : null;
            OnlineServiceLog osl = oslogDetaillst.containsKey(key) ? oslogDetaillst.get(key) : null;

            if(rtl_osl == null || osl == null) continue;

            if (osl.requestBody != '' && osl.requestBody != null) {
                Attachment requestAttachment = new Attachment();
                requestAttachment.parentId = rtl_osl.Id;
                requestAttachment.name = 'requestBody.txt';
                requestAttachment.IsPrivate = false;
                requestAttachment.body = Blob.valueOf(osl.requestBody);
                importattachmentfileList.add(requestAttachment);
            }
            
            if (osl.responseBody != '' && osl.responseBody != null) {
                Attachment responseAttachment = new Attachment();
                responseAttachment.parentId = rtl_osl.Id;
                responseAttachment.name = 'responseBody.txt';
                responseAttachment.IsPrivate = false;
                responseAttachment.body = Blob.valueOf(osl.responseBody);
                importattachmentfileList.add(responseAttachment);
            }
        }

        if (importattachmentfileList.size() > 0) {
            insert importattachmentfileList;
        }
    }
    public static void saveToOnlineLog(List<OnlineServiceLog> onlineServiceLog, String customerName, String errorMessage, String msLogId, String userName, Boolean rmId, String serviceName, Account acc, DateTime startTime, DateTime endTime) {

        List<RTL_Online_Service_Log__c> osLog_lst = new List<RTL_Online_Service_Log__c>();
        List<Attachment> importattachmentfileList = new List <Attachment>();

        for (OnlineServiceLog osl : onlineServiceLog) {
            RTL_Online_Service_Log__c osLog = new RTL_Online_Service_Log__c();
            osLog.RTL_Is_Success__c = osl.isSuccess;

            osLog.RTL_Customer_Name__c = customerName;
            osLog.RTL_Error_Message__c = osl.errorMesssage;
            osLog.RTL_Mulesoft_Log_Id__c = msLogId;
            osLog.RTL_Name_of_User__c = userName;
            if(rmId){
                osLog.RTL_RM_ID__c = osl.rmId;
            }
            osLog.RTL_Service_Name__c = serviceName;

            if (acc != null) {
                osLog.RTL_Account__c = acc.id;
                osLog.RTL_Customer_Segment__c = acc.Core_Banking_Suggested_Segment__c;
            }
            osLog.RTL_Start_DateTime__c = startTime;
            osLog.RTL_End_DateTime__c = endTime;

            osLog_lst.add(osLog);
        }
        if (osLog_lst.size() > 0) {
            insert osLog_lst;
        }

        for (Integer i = 0; i < osLog_lst.size(); i++) {
            RTL_Online_Service_Log__c rtl_osl = osLog_lst.get(i);
            OnlineServiceLog osl = onlineServiceLog.get(i);
            if (osl.requestBody != '' && osl.requestBody != null) {
                Attachment requestAttachment = new Attachment();
                requestAttachment.parentId = rtl_osl.Id;
                requestAttachment.name = 'requestBody.txt';
                requestAttachment.IsPrivate = false;
                requestAttachment.body = Blob.valueOf(osl.requestBody);
                importattachmentfileList.add(requestAttachment);
            }
            if (osl.responseBody != '' && osl.responseBody != null) {
                Attachment responseAttachment = new Attachment();
                responseAttachment.parentId = rtl_osl.Id;
                responseAttachment.name = 'responseBody.txt';
                responseAttachment.IsPrivate = false;
                responseAttachment.body = Blob.valueOf(osl.responseBody);
                importattachmentfileList.add(responseAttachment);
            }
        }
        if (importattachmentfileList.size() > 0) {
            insert importattachmentfileList;
        }
    }
}