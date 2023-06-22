public class ClickToCallController {

    public static Integer SERVICE_TIMEOUT_MILISEC{
        get{
            Integer DEFAULT_TIMEOUT = 60000;
            if(SERVICE_TIMEOUT_MILISEC == null){
                try{
                    SERVICE_TIMEOUT_MILISEC = DEFAULT_TIMEOUT;
                    List<App_Config__mdt> c2c_Timeout = [SELECT Id, Label, Value__c FROM App_Config__mdt WHERE Label = 'CLICKTOCALL_TIMEOUT_MILISEC' LIMIT 1];  
                    if (c2c_Timeout != null && c2c_Timeout.size() > 0) {
                        SERVICE_TIMEOUT_MILISEC = Integer.valueOf(c2c_Timeout.get(0).Value__c);
                    }           
                    
                }catch( Exception e ){
                    SERVICE_TIMEOUT_MILISEC = DEFAULT_TIMEOUT;
                }
            }
            return SERVICE_TIMEOUT_MILISEC;
            
        }set;
    }

    @AuraEnabled
    public static User getCurrentUser(){
        System.debug(UserInfo.getUserId());
        List<User> user = [SELECT Id,Employee_ID__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        return user[0];
    }

    @AuraEnabled
    public static Integer getTimeOut(){
        return SERVICE_TIMEOUT_MILISEC;
    }

	@AuraEnabled
    public static List<sObject> getFieldTypePhone(String recordId,String objectName)
    {
        try{                      
            String queryRecordType = 'select RecordTypeId,RecordType.Name  from '+objectName+' where id =: recordId';
            List<sObject> getObject = Database.query(queryRecordType);
            System.debug('getObject:'+getObject);
            String recordTypeName;
            if(getObject.size() > 0)
            {
                if(objectName == 'Account')
                {
                    Account acc = (Account)getObject[0];
                    recordTypeName = acc.recordType.Name;
                }
                else if(objectName == 'Contact')
                {
                    Contact ct = (Contact)getObject[0];
                    recordTypeName = ct.recordType.Name;
                } 
                else if(objectName == 'Lead')
                {
                    Lead ld = (Lead)getObject[0];
                    recordTypeName = ld.recordType.Name;
                }   
                else if(objectName == 'RTL_Referral__c')
                {
                    RTL_Referral__c rf = (RTL_Referral__c)getObject[0];
                    recordTypeName = rf.recordType.Name;
                }   
                else if(objectName == 'CampaignMember')
                {
                    CampaignMember cm = (CampaignMember)getObject[0];
                    recordTypeName = cm.recordType.Name;
                }   
            }
            
            List<Profile> profile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            String currentProflieName = profile[0].Name;
            System.debug('currentProflieName:'+currentProflieName);
            System.debug('recordTypeName:'+recordTypeName);
           	String appName;
            if (!Test.isRunningTest()) {               
                List<UserAppInfo> userAppInfo = [SELECT Id, AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() LIMIT 1];
                AppDefinition appDefinition = [SELECT DurableId, Label,DeveloperName FROM AppDefinition Where DurableId = :userAppInfo[0].AppDefinitionId];
                appName = appDefinition.DeveloperName;
            }
            else
            {
                appName = 'Service Console';
            }
            List<ClickToCallSetting__c > clickToCallSetting = [SELECT App_Name__c, Record_Type__c, Profile_Name__c, Phone_Field__c, Object__c, Use_Standard_Pagelayout__c 
                                                               FROM ClickToCallSetting__c  Where Record_Type__c =: recordTypeName AND Object__c =: objectName 
                                                               AND Profile_Name__c =: currentProflieName AND App_Name__c =: appName ];
            
            Map<String,String> phoneFieldInPage_Map = new Map<String,String>();
            List<String> phoneFieldsInObj_List = new List<String>();
            List<String> phoneFieldAll_List = new List<String>();
            
            SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            Map<String, Schema.SObjectField> objectFields = objectType.getDescribe().fields.getMap();
            
            for (String fieldName : objectFields.keySet()) {
                Schema.DescribeFieldResult fieldInfo = objectFields.get(fieldName).getDescribe();
                if (fieldInfo.getType() == Schema.DisplayType.PHONE) {
                    phoneFieldsInObj_List.add(fieldName);
                }
            }
            
            if(clickToCallSetting.size() > 0)
            {
                if(clickToCallSetting[0].Use_Standard_Pagelayout__c)
                {
                    String currentLayoutName;
                    if (!Test.isRunningTest()) {
                    	currentLayoutName = ApiCallLightningComponent.getLayoutNameForCurrentUserProfile(recordId,objectName);
                    }
                    else
                    {
                        currentLayoutName = 'Retails Call Center Inbound';
                    }
                    string layoutName = String.format('{0}-{1}', new String[]{objectName, currentLayoutName}); 
                    System.debug('layoutName:'+layoutName);
                    List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List<String> {layoutName});
                    System.debug('layouts:'+layouts);
                    
                    //Get Field From Pagelayout
                    if(layouts.size() > 0 )
                    {
                        Metadata.Layout layoutMd = (Metadata.Layout) layouts.get(0);
                        
                        for (Metadata.LayoutSection section : layoutMd.layoutSections) {
                            for (Metadata.LayoutColumn column : section.layoutColumns) {
                                if (column.layoutItems != null) {
                                    for (Metadata.LayoutItem phoneFieldInPage : column.layoutItems) {
                                        System.debug(phoneFieldInPage.field);
                                        for(String phoneFieldInObj : phoneFieldsInObj_List)
                                        {
                                            if(phoneFieldInObj == phoneFieldInPage.field)
                                            {
                                                phoneFieldInPage_Map.put(phoneFieldInPage.field,phoneFieldInPage.field);
                                            }
                                        }                      
                                    }
                                }
                            }
                        }
                    }
                    //Get Field From Metadata               
                    if(clickToCallSetting[0].Phone_Field__c != null)
                    {
                        List<String> phoneFieldMeta_List = clickToCallSetting[0].Phone_Field__c.split(',');
                        for(String phoneFieldInMeta : phoneFieldMeta_List)
                        {
                            for(String phoneFieldInObj : phoneFieldsInObj_List)
                            {
                                if(!phoneFieldInPage_Map.containsKey(phoneFieldInMeta))
                                {
                                    phoneFieldInPage_Map.put(phoneFieldInMeta,phoneFieldInMeta);
                                }                        
                            } 
                        }
                    }
                    
                    if(phoneFieldInPage_Map.size() > 0)
                    {
                        for(String field : phoneFieldInPage_Map.Values())
                        {
                            phoneFieldAll_List.add(field);
                        }
                    }
                }
                else
                {
                    if(clickToCallSetting[0].Phone_Field__c != null)
                    {
                        List<String> phoneFieldMeta_List = clickToCallSetting[0].Phone_Field__c.split(',');
                        for(String phoneFieldInMeta : phoneFieldMeta_List)
                        {
                            for(String phoneFieldInObj : phoneFieldsInObj_List)
                            {
                                if(phoneFieldInObj == phoneFieldInMeta)
                                {
                                    phoneFieldAll_List.add(phoneFieldInMeta);
                                }
                            } 
                        }
                    }
                }
            }
            System.debug('Field All:' + phoneFieldAll_List);
            String query;
            if(phoneFieldAll_List.size() > 0)
            {
                query = 'SELECT Id,Name, ' + String.join(phoneFieldAll_List, ',') + ' FROM '+ objectName +' Where Id =:recordId LIMIT 1';
            }
            else
            {
                query = 'SELECT Id,Name FROM '+ objectName +' Where Id =:recordId LIMIT 1';
            }
            
            System.debug('query:'+query);   
            List<sObject> objList = Database.query(query);
            
            return objList;
        }
        catch(Exception e)
        {
            String errorMsg = 'Message: ' + e.getMessage() + ' TypeName: ' + e.getTypeName() + ' StackTrace: ' + e.getStackTraceString();
            System.debug(errorMsg);
            return null;
        }
    }
    
    @AuraEnabled
    public static Map<String,String> getFieldLabel(String objectName)
    {      
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> objectFields = objectType.getDescribe().fields.getMap();
        Map<String,String> fieldLabelMap = new Map<String,String>();
        
        for (String fieldName : objectFields.keySet()) 
        {           
            Schema.DescribeFieldResult fieldInfo = objectFields.get(fieldName).getDescribe();
            if (fieldInfo.getType() == Schema.DisplayType.PHONE) {
                //System.debug('fieldName:'+fieldName);
                //System.debug(objectFields.get(fieldName).getDescribe().getLabel());
                fieldLabelMap.put(objectFields.get(fieldName).getDescribe().getName(),objectFields.get(fieldName).getDescribe().getLabel());
            }
            
        }
        
        return fieldLabelMap;
    }
    
    @AuraEnabled
    public static Map<String, Object> clickToCallAPI(String recordId,String phoneNum)
    {    
        System.debug('ClickToCallController.clickToCallAPI');
        String errorMessage = '';
        String customerName = '';
        String msLogId = '';
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        String rmId = '';
        String serviceName = 'callout:Telephony_Avaya_C2C_API';
        String requestBody = '';
        String responseBody = '';

        DateTime startTime = DateTime.Now();
        DateTime endTime;

        Account accForLog = new Account();

        Boolean isSuccess = true;

        User user = [SELECT Id,Name,Employee_ID__c,Extension FROM User WHERE Id =: UserInfo.getUserId()];
        String additionalInfo = '[{"infoKey":"Related_Object__c","infoValue":""}]';
        String message = '';

        String sfdcId = '';

        if(recordId.substring(0, 3) == '001')
        {
            sfdcId = recordId; 
        }
        else if(recordId.substring(0, 3) == '00v')
        {
            CampaignMember cm = [SELECT Id,RTL_Marketing_Code__c,LeadId, ContactId, Customer__c FROM CampaignMember WHERE Id =: recordId];
            additionalInfo = '[{"infoKey":"Marketing_Code","infoValue":"'+cm.RTL_Marketing_Code__c+'"}]';
            if(cm.Customer__c != null)
            {
                additionalInfo = '[{"infoKey":"Marketing_Code","infoValue":"'+cm.RTL_Marketing_Code__c+'"},'
                + '{"infoKey":"Related_Object__c","infoValue":"'+cm.Id+'"}]';     
                sfdcId =  cm.Customer__c;
            }        
        }
        else if(recordId.substring(0, 3) =='003')
        {
            Contact ct = [SELECT Id, AccountId FROM Contact WHERE Id =: recordId];
            additionalInfo = '[{"infoKey":"Related_Object__c","infoValue":"'+ct.Id+'"}]';     
            if(ct.AccountId != null)
            {            
                sfdcId =  ct.AccountId;
            }
        }
        else if(recordId.substring(0, 3) =='a2S')
        {
            RTL_Referral__c ref = [SELECT Id,RTL_Account_Name__c FROM RTL_Referral__c WHERE Id =: recordId];
            additionalInfo = '[{"infoKey":"Related_Object__c","infoValue":"'+ref.Id+'"}]';     
            if(ref.RTL_Account_Name__c != null)
            {             
                sfdcId =  ref.RTL_Account_Name__c;
            }
        }
        else if(recordId.substring(0, 3) =='00Q')
        {
            Lead lead = [SELECT Id,Account__c FROM Lead WHERE Id =: recordId];
            additionalInfo = '[{"infoKey":"Related_Object__c","infoValue":"'+lead.Id+'"}]';     
            if(lead.Account__c != null)
            {              
                sfdcId =  lead.Account__c;
            }
        }

        String jsonBody = '{'+
                            '"sfdcId": "'+ sfdcId +'",'+
                            // '"agentId": "'+ user.Id +'",'+
                            '"customerNo": "'+ phoneNum +'",'+
                            '"employeeId": "'+ user.Employee_ID__c +'@",'+
                            // '"extension": "'+ user.Extension +'",'+
                            '"additionalInfo": '+ additionalInfo +''+
                            '}';
        requestBody = jsonBody;
System.debug('JSON Body -->' + jsonBody );
        try 
            {

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Telephony_Avaya_C2C_API');
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + c2cGetToken());
            request.setHeader('Content-Type', 'application/json');
            request.setBody(jsonBody);
            //request.setTimeout(SERVICE_TIMEOUT_MILISEC);
            System.debug('request:'+request.getBody());
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                isSuccess = true;   
                // message = 'Success';               
            } 
            if (response.getStatusCode() == 201) {
                isSuccess = true;
                // message = 'Success';               
            } 
            else if (response.getStatusCode() == 101) {
                // message = 'Agent is logoff.';
                isSuccess = false;            
            } 
            else if (response.getStatusCode() == 102) {
                // message = 'Agent is not ready.';
                isSuccess = false;            
            }    
            else if (response.getStatusCode() == 103) {
                // message = 'Agent is on another call.';
                isSuccess = false;
            }    
            else if (response.getStatusCode() == 104) {
                // message = 'Unable to connect agent workspace.';
                isSuccess = false;
            } 
            else if (response.getStatusCode() == 105) {
                // message = 'Unexpected error.';
                isSuccess = false;
                
            }   
            else 
            {
                isSuccess = false;
            }
            System.debug('response:'+response.getStatusCode());
            
            responseBody = response.getBody(); //'{"status":"'+response.getStatusCode()+'", "message":"'+message+'"}';

            System.debug('responseBody:'+ response.getBody());

            Map<String, Object> responseBodyMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('responseBodyMap:'+ responseBodyMap);

            endTime = DateTime.now();

            OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  msLogId ,  userName, 
                                                    rmId ,  serviceName , requestBody , responseBody ,  accForLog , 
                                                    startTime ,  endTime,  null );
    
            return responseBodyMap;
        } 
        catch(System.CalloutException e) 
        {
            System.debug('ERROR: '+ e);
    
            errorMessage = '{"message:"'+ e.getMessage()+'"}';
            endTime = DateTime.now();
            isSuccess = false;
            OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  msLogId ,  userName, 
                                                  rmId ,  serviceName , requestBody , responseBody ,  accForLog , 
                                                  startTime ,  endTime,  null );
            Map<String, Object> responseBodyMap = new Map<String,Object>();
            responseBodyMap.put('message',e.getMessage());
            responseBodyMap.put('status','TIME OUT');

            System.debug('responseBodyMap:'+responseBodyMap);

          

            return responseBodyMap;
        }
        catch (Exception e) {
             
            responseBody = InboundUtility.restRespond(
                InboundUtility.HTTP_BAD_REQUEST,
                'Uncaught Exception',
                e.getMessage() + ' : ' + e.getStackTraceString()
            );
            errorMessage = '{"message:"'+ e.getMessage()+'"}';
            endTime = DateTime.now();
            isSuccess = false;
            OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  msLogId ,  userName, 
                                                  rmId ,  serviceName , requestBody , responseBody ,  accForLog , 
                                                  startTime ,  endTime,  null );

                                                  

            return null;
        }
    }

    public static String c2cGetToken()
    {
        String token;
        String jsonBody =  '{"username": "{!$Credential.Username}",'+
                            '"password": "{!$Credential.Password}"}';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Telephony_Avaya_C2C_getToken');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(jsonBody);
        HttpResponse response = http.send(request);
        System.debug('Get Token status code --->' + response.getStatusCode());

        if (response.getStatusCode() == 200) 
        {
            Map<String, Object> getTokenMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            //token = JSON.serialize(getTokenMap.get('api_token'));
            token = getTokenMap.get('api_token').ToString();
            System.debug('token:'+getTokenMap.get('api_token'));
        } else {
            System.debug('Get Token status body --->' + response.getBody());
        }
       
        return token;
    }
    
    @AuraEnabled
    public static void publishC2CEvent(String empId)
    {
            //Start Trigger Platform Events
            Click_To_Call__e c2c = new Click_To_Call__e(Employee_Id__c = empId);
            System.debug('c2c:'+c2c);
            Database.SaveResult results = EventBus.publish(c2c);
            
            // Inspect publishing result for each event
        
            if(results.isSuccess()){
                System.debug('Successfully published event.');
            }
            else
            {
                System.debug('Error returned: ' +
                            results.getErrors()[0].getStatusCode() +
                            ' - ' +
                            results.getErrors()[0].getMessage());
    
            }    
    }
}