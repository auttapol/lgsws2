@RestResource(urlMapping='/data/V1.0/sobjects/Case/*')
global with sharing class RTL_WsCreateCase extends WebserviceAbstract {

    @HttpPost
    global static void createCase(){

        String errorMessage = '';
        String customerName = '';
        String msLogId = '';
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        String rmId = '';
        String serviceName = '/services/data/V1.0/sobjects/Case';
        String requestBody = '';
        String responseBody = '';
        String reqId = '';
        
        DateTime startTime = DateTime.Now();
        DateTime endTime;
        
        Account accForLog = new Account();
        
        Boolean isSuccess = true;

        String TrackMsgQuery = '';
        String TrackMsgCheckStart = '';
        String TrackMsgCheckEnd = '';    
        String TrackMsgInsertCase = '';

        String reponseString; 
        RestRequest request = RestContext.request;
        String encryptKey = null;
        String requestBodyDecrypt = null;

        try 
        {
            /* Additional get key specific from request */
            
            try {
                encryptKey = getKeyFromSystem(request);
            } catch (WebserviceAbstract.MissingHeaderException e) {
                encryptKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), SCSMessageAPIUtil.INTEGRATE_SYSTEM.OneApp);
            }
            //String encryptKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), SCSMessageAPIUtil.INTEGRATE_SYSTEM.OneApp);
            
            requestBodyDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(request.requestBody.toString(), encryptKey);


            Case caseObj = new Case();
            // Map<String, Object> requestBodyMap = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            Map<String, Object> requestBodyMap = (Map<String, Object>)JSON.deserializeUntyped(requestBodyDecrypt);
            Map<String,String> requestHeader = request.headers;
            String status = 'SUCCESS';        

            System.debug('requestBodyMap:'+requestBodyMap);
            System.debug('requestHeader:'+requestHeader);
            
            // if(caseObj.Sub_Channel__c != null){
            //     String subChannel = (String)requestBodyMap.get('Sub_Channel__c');
            //     caseObj.Sub_Channel__c = subChannel;
            // }
            // System.debug('Sub Channel : '+caseObj.Sub_Channel__c);

            String tmbcustId = (String)requestBodyMap.get('Customer_ID_OneApp__c');

             //Edit to default Customer ID in case service not send Customer ID to CRM
            if(tmbcustId ==  null || tmbcustId == ''){
                tmbcustId = 'NoCustomerID';
            }
            reqId = (String)requestHeader.get('ReqId');
            List<String> missingField = new List<String>();
            List<String> requireField = new List<String> {                
                'FCR__c',
                'Origin',
                'Service_Type_Matrix_Code__c',
                'Contact_Person_Name__c'
            };
            if(requestBodyMap.containsKey('FCR__c'))
            {
                if(requestBodyMap.get('FCR__c') != null)
                {
                    if((Boolean)requestBodyMap.get('FCR__c'))
                    {
                        requireField.add('Root_Cause_List__c');
                        requireField.add('Resolution_LIst__c');
                    }
                }
            }
            
            for(String field : requireField)
            {
                if(requestBodyMap.containsKey(field))
                {
                    System.debug('requireField '+ field + ': ' +requestBodyMap.get(field));
                    if(requestBodyMap.get(field) == null || requestBodyMap.get(field) == '')
                    {
                        missingField.add(field);
                    }
                } 
                else 
                {
                    missingField.add(field);
                } 
            }

            if(missingField.size() > 0)
            {
                isSuccess = false;
                errorMessage = 'Required fields are missing ' + String.join(missingField, ', ');
                reponseString = '{\n  "errorCode": "REQUIRED_FIELD_MISSING",\n  "message": "'+errorMessage+'"\n}';
            
                //RestContext.response.addHeader('ReqId', reqId);             
                if (!Test.isRunningTest()) {
                    RestContext.response.addHeader('Content-Type', 'application/json');
                    RestContext.response.statusCode = 400; 
                    RestContext.response.responseBody = Blob.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(reponseString, encryptKey));
                }          
                // RestContext.response.responseBody = Blob.valueOf(reponseString);                
            }
            else 
            {
                String serviceTypeCode = (String)requestBodyMap.get('Service_Type_Matrix_Code__c');
                List<Service_Type_Matrix__c> stm = [SELECT Id, OwnerId, Name, Segment__c, Service_Level1__c, Service_Level2__c, Service_Level3__c, Service_Level4__c, Service_Template__c, Severity__c, SLA__c, Responsible_BU__c, Closed_By_BU__c, Problem_Type__c, Journey__c, Validate_Code__c
                                                    , Service_issue_EN__c, SMS_Code_New__c, SMS_Code_In_Progress__c, SMS_Code_Resolved__c, Resolution_1__c, Resolution_2__c, SMS_Code_Resolution_1__c, SMS_Code_Resolution_2__c, Guideline__c, TAT__c, SMS_Code_for_Update_Progress__c
                                                    , Issue_for_ONEAPP_EN__c ,Issue_for_ONEAPP_TH__c , Product_Service_TH__c , Display_on_OneApp__c
                                                    FROM Service_Type_Matrix__c WHERE Validate_Code__c =: serviceTypeCode LIMIT 1];
                System.debug('serviceTypeCode:'+serviceTypeCode);
                System.debug('stm:'+stm);
                if(stm.size() > 0)
                {
                    System.debug('tmbcustId:'+tmbcustId);
                    //--------------TrackMsg--------------------
                    TrackMsgQuery += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start QueryAccount, message=';
                 
                    TrackMsgQuery += '\n tmbcustid:' + tmbcustId;                 
                                      
                    //--------------TrackMsg--------------------

                    List<Account> accObj = [SELECT Id,TMB_Customer_ID_PE__c,Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c =: tmbcustId LIMIT 1];

                    //--------------TrackMsg--------------------
                    TrackMsgQuery += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop QueryAccount, message=';
                                
                    //--------------TrackMsg--------------------
                    if(accObj.size() > 0)
                    {
                        caseObj.put('AccountId', accObj[0].Id);
                        accForLog = accObj[0];
                        //--------------TrackMsg--------------------
                        TrackMsgQuery += '\n accountid:' + accObj[0].Id;
                        //--------------TrackMsg--------------------
                    }  
                    else {
                        //--------------TrackMsg--------------------
                        TrackMsgCheckEnd += '\n accountid:';
                        //--------------TrackMsg--------------------
                    }

                    rmId = tmbcustId;      

                    //--------------TrackMsg--------------------
                    TrackMsgInsertCase += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Start InsertCase, message=';
                    TrackMsgInsertCase += '\n Service_Type_Matrix_Code__c:' + (String)requestBodyMap.get('Service_Type_Matrix_Code__c');
                    //--------------TrackMsg--------------------       

                    Service_Type_Matrix__c serviceTypeMatrix = stm[0];
                    caseObj.put('PTA_Segment__c', serviceTypeMatrix.Segment__c);    
                    caseObj.put('Category__c', serviceTypeMatrix.Service_Level1__c); 
                    caseObj.put('Sub_Category__c', serviceTypeMatrix.Service_Level2__c); 
                    caseObj.put('Product_Category__c', serviceTypeMatrix.Service_Level3__c); 
                    caseObj.put('Issue__c', serviceTypeMatrix.Service_Level4__c); 
                    caseObj.put('Current_Service_Template__c', serviceTypeMatrix.Service_Template__c);                   
                    caseObj.put('Problem_Type__c', serviceTypeMatrix.Problem_Type__c); 
                    caseObj.put('Journey__c', serviceTypeMatrix.Journey__c); 
                    caseObj.put('Responsible_BU__c', serviceTypeMatrix.Responsible_BU__c);    
                    caseObj.put('SLA_Day__c', serviceTypeMatrix.SLA__c); 
                    caseObj.put('Service_issue_EN__c', serviceTypeMatrix.Service_issue_EN__c); 
                    caseObj.put('SMS_Code_New__c', serviceTypeMatrix.SMS_Code_New__c); 
                    caseObj.put('SMS_Code_In_Progress__c', serviceTypeMatrix.SMS_Code_In_Progress__c); 
                    caseObj.put('SMS_Code_Resolved__c', serviceTypeMatrix.SMS_Code_Resolved__c); 
                    caseObj.put('SMS_Resolution_1__c', serviceTypeMatrix.Resolution_1__c);    
                    caseObj.put('SMS_Resolution_2__c', serviceTypeMatrix.Resolution_2__c); 
                    caseObj.put('SMS_Code_Resolution_1__c', serviceTypeMatrix.SMS_Code_Resolution_1__c); 
                    caseObj.put('SMS_Code_Resolution_2__c', serviceTypeMatrix.SMS_Code_Resolution_2__c); 
                    caseObj.put('Guideline__c', serviceTypeMatrix.Guideline__c); 
                    caseObj.put('TAT__c', serviceTypeMatrix.TAT__c);                       
                    caseObj.put('SMS_Code_for_Update_Progress__c', serviceTypeMatrix.SMS_Code_for_Update_Progress__c); 
                    caseObj.put('Issue_New_for_OneApp__c', serviceTypeMatrix.Issue_for_ONEAPP_TH__c); 
                    caseObj.put('Product_For_OneApp_TH__c', serviceTypeMatrix.Product_Service_TH__c); 
                    caseObj.put('Display_on_OneApp__c', serviceTypeMatrix.Display_on_OneApp__c); 
                    caseObj.put('Issue_New_for_OneApp_EN__c', serviceTypeMatrix.Issue_for_ONEAPP_EN__c); 
                    caseObj.put('Closed_By_BU__c', serviceTypeMatrix.Closed_By_BU__c);

                    if(serviceTypeMatrix.Service_Level4__c != null && serviceTypeMatrix.Service_Level4__c != '')
                    {
                        caseObj.put('Subject', serviceTypeMatrix.Service_Level4__c);         
                    }
                    else if(serviceTypeMatrix.Service_Level3__c != null && serviceTypeMatrix.Service_Level3__c != '')
                    {
                        caseObj.put('Subject', serviceTypeMatrix.Service_Level3__c); 
                    }
                    else if(serviceTypeMatrix.Service_Level2__c != null && serviceTypeMatrix.Service_Level2__c != '')
                    {
                        caseObj.put('Subject', serviceTypeMatrix.Service_Level2__c); 
                    }
                    else if(serviceTypeMatrix.Service_Level1__c != null && serviceTypeMatrix.Service_Level1__c != '')
                    {
                        caseObj.put('Subject', serviceTypeMatrix.Service_Level1__c); 
                    }
                    Id rbgRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Retail Service').getRecordTypeId();
                    Id wbgRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('WBG Service').getRecordTypeId();

                    if(caseObj.PTA_Segment__c == 'RBG'){
                        caseObj.RecordTypeId = rbgRecordTypeId;
                    }else if(caseObj.PTA_Segment__c == 'WBG'){
                        caseObj.RecordTypeId = wbgRecordTypeId;
                    }
                    TrackMsgInsertCase += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Map dynamic field from service';
                    Map<String, Schema.SObjectField> sObjectField = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap();
                    // Map dynamic field from service
                    for(String field : requestBodyMap.keySet())
                    {           
                        if(sObjectField.containsKey(field))
                        {
                            System.debug('fieldMap:'+ sObjectField.get(field));
                            System.debug('requestbody:'+ requestBodyMap.get(field));
                            caseObj.put(sObjectField.get(field), requestBodyMap.get(field));           
                        }   
                    }
                    
                    System.debug('caseObj:'+ caseObj);                 
                	TrackMsgInsertCase += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Before InsertCase';
                    System.debug('Start insert ' + RESTOpportunityUtil.getTHDatetimeNOW());
                    insert caseObj;
                    System.debug('End insert ' + RESTOpportunityUtil.getTHDatetimeNOW());

                    //--------------TrackMsg--------------------
                    TrackMsgInsertCase += '\n|' + RESTOpportunityUtil.getTHDatetimeNOW() + ': Stop InsertCase message=';
      
                    TrackMsgInsertCase += '\n Id:' + caseObj.Id;
                    //--------------TrackMsg--------------------               
    
                    List<Case> newCase = [SELECT Id,CaseNumber FROM Case WHERE Id =: caseObj.Id LIMIT 1];
                    Map<String, String> result = new Map<String, String>();
                    result.put('case_number',newCase[0].CaseNumber);           
                    errorMessage = TrackMsgQuery + TrackMsgCheckStart + TrackMsgCheckEnd + TrackMsgInsertCase;
                    reponseString = '{\n  "status": "'+status+'",\n  "message": "",\n  "data": {\n      "case_number": "'+newCase[0].CaseNumber+'" \n  }\n}';
    
                    if (!Test.isRunningTest()) { 
                        RestContext.response.addHeader('ReqId', reqId);
                        RestContext.response.addHeader('Content-Type', 'application/json');
                        //RestContext.response.responseBody = Blob.valueOf(reponseString);
                        RestContext.response.responseBody = Blob.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(reponseString, encryptKey));
                    }
                    System.debug('caseObj:'+ caseObj);
                  
                }
                else 
                {
                    isSuccess = false;
                    errorMessage = Label.CreateCase_ServiceTypeCode_ErrorMsg;
                    reponseString = '{\n  "errorCode": "INVALID_SERVICE_TYPE_CODE",\n  "message": "'+errorMessage+'"\n}';
                
                    //RestContext.response.addHeader('ReqId', reqId);
                    if (!Test.isRunningTest()) {            
                        RestContext.response.addHeader('Content-Type', 'application/json');
                        RestContext.response.statusCode = 500;
                        // RestContext.response.responseBody = Blob.valueOf(reponseString);
                        RestContext.response.responseBody = Blob.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(reponseString, encryptKey));
                    }
                }            
            }  
            endTime = DateTime.Now();
            // requestBody = requestHeader.toString() + '\n\n' +RestContext.request.requestBody.toString();
            // requestBody = requestHeader.toString() + '\n\n' + requestBodyDecrypt;
            requestBody = requestHeader.toString() + '\n\n' + JSON.serializePretty(JSON.deserializeUntyped(JSON.serializePretty(JSON.deserializeUntyped(requestBodyDecrypt))));
            responseBody =  reponseString;            

            OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  reqId ,  userName,
            rmId ,  serviceName , requestBody , responseBody ,  accForLog , startTime ,  endTime,  null );

        }
        catch (Exception e) {

            errorMessage = 'Message: ' + e.getMessage();
            isSuccess = false;
            endTime = DateTime.Now();

            reponseString = '{\n  "errorCode": "'+e.getTypeName()+'",\n  "message": "'+e.getMessage()+'"\n}';

            requestBody = RestContext.request.headers.toString() + '\n\n' +RestContext.request.requestBody.toString();
            if (String.isNotEmpty(requestBodyDecrypt)) {
                try {
                    requestBody = request.headers.toString() + '\n\n' + JSON.serializePretty(JSON.deserializeUntyped(JSON.serializePretty(JSON.deserializeUntyped(requestBodyDecrypt))));
                } catch (Exception e2) {
                    System.debug('ERR-->' + e2.getMessage());
                    requestBody = requestBodyDecrypt;
                }
            	
            } else {
                requestBody = RestContext.request.headers.toString() + '\n\n' +RestContext.request.requestBody.toString();
            }
            responseBody = reponseString;
            System.debug('k'+encryptKey);
            //RestContext.response.addHeader('ReqId', reqId);
            if (!Test.isRunningTest()) {            
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.statusCode = 500;
                RestContext.response.responseBody = Blob.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(reponseString, encryptKey));
            }
             
            OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  reqId ,  userName,
            rmId ,  serviceName , requestBody , responseBody ,  accForLog , startTime ,  endTime,  null );
        }

    }
}