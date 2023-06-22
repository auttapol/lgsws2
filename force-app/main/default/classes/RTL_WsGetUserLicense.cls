@RestResource(urlMapping='/data/V1.0/pwa/*')
global without sharing class RTL_WsGetUserLicense extends WebserviceAbstract {

    global class PWAUserDetail {
        private String mobile_no;
        private String email;
        private String first_name_th;
        private String last_name_th;
        private String first_name_en;
        private String last_name_en;
        private String license_no_icp_1;
        private String license_no_icp_3;
        private String license_no_ip;
        private String license_no_ict;
        private String license_no_wealthy_link;
        private String license_no_unit_link;
        private String profile_image_url;
        private String employee_id;
        private String manager_email;

        private String license_no_life_insurance;
        private String license_no_non_life_insurance;
        private String license_no_paper_1;
        private String license_no_paper_4;
        private String license_no_paper_5;
        private String license_no_complex_p2;

    }

    @HttpPost
    global static void getPWAInfo() {
        RestRequest request = RestContext.request;
        WebserviceAbstract.Response response = new WebserviceAbstract.Response();
        String req = request.requestBody.toString();
        String encryptKey;
        String requestBodyDecrypt = null;

        String errorMessage = '';
        String customerName = '';
        String msLogId = '';
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        String RMID = '';
        String serviceName = '/services/data/V1.0/pwa/';
        String requestBody = req;
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

        try 
        {
 
            try {
                
                /* Validate header for get encrypt key */
                encryptKey = getKeyFromSystem(request);
                /* Decrypt body message */
                
            } catch (WebserviceAbstract.MissingHeaderException e) {
                response.status = 'FAIL';
                response.status_code = '90';
                response.message = 'Missing Request Header [Integration-System]';
                response.data = '';

                System.debug('MissingHeaderException');
                System.debug('Response: ' + response);
                encryptKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), SCSMessageAPIUtil.INTEGRATE_SYSTEM.OneApp);

            }
            // encryptKey = getKeyFromSystem(request);
            requestBodyDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(request.requestBody.toString(), encryptKey);
            // System.debug('requestBodyDecrypt: ' + requestBodyDecrypt);
            Map<String,String> requestHeader = request.headers;
            reqId = (String)requestHeader.get('ReqId');

            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(requestBodyDecrypt);
            // Map<String, Object> requestBodyMap = (Map<String, Object>)JSON.deserializeUntyped(requestBodyDecrypt);
            System.debug('RMID->' + jsonMap.get('RMID'));

            // Find RTL_RM_Name__c in account
            RMID = String.valueOf(jsonMap.get('RMID'));
            PWAUserDetail pwaUserDetail = new PWAUserDetail();
            List<Account> accList = [SELECT Id, TMB_Customer_ID_PE__c, RTL_RM_Name__c, RTL_Wealth_RM__c, Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c =: RMID LIMIT 1];

            if (accList.size() > 0) {
                System.debug('Account: ' + accList[0]);

                String RM_Name = accList[0].RTL_RM_Name__c;
                String userId = accList[0].RTL_Wealth_RM__c;
                Date todayDate = Date.today();
                accForLog = accList[0];

                if (RM_Name != null && RM_Name.length() > 0) {
                    // Start with 00 => RTL_Wealth_RM__c
                    // Start with other than 00 => Blank
                    String checkCode = RM_Name.substring(0,2);

                    // Find User detail
                    if (accList[0].RTL_Wealth_RM__c != null && !String.isBlank(accList[0].RTL_Wealth_RM__c)) {
                        List<User> userList = [ SELECT Id, Employee_ID__c, IsActive, Mobile_No__c, Email, First_Name_TH__c, Last_Name_TH__c, FirstName, LastName, Profile.Name, 
                                                RTL_Expiry_Date_ICP_1__c, RTL_Expiry_Date_ICP_3__c, RTL_Expiry_Date_IP__c, RTL_Expiry_Date_ICT__c, RTL_Expiry_Date_Wealthy_Link__c, 
                                                RTL_Active_Flag_Wealthy_Link__c, RTL_Expiry_Date_Unit_Link__c, RTL_Active_Flag_Unit_Link__c, Manager_Email__c,
                                                RTL_License_No_Life_Insurance__c, RTL_Expiry_Date_Life_Insurance__c, RTL_License_No_Non_Life_Insurance__c, RTL_Expiry_Date_Non_Life_Insurance__c, 
                                                RTL_License_No_Paper_1__c, RTL_Expiry_Date_Paper_1__c, RTL_License_No_Paper_4__c, RTL_Expiry_Date_Paper_4__c, RTL_License_No_Paper_5__c, RTL_Expiry_Date_Paper_5__c, 
                                                RTL_License_No_ICP_1__c, RTL_License_No_Complex_P2__c, RTL_Expiry_Date_Complex_P2__c, RTL_License_No_ICP_3__c, RTL_License_No_IP__c, RTL_License_No_ICT__c, 
                                                RTL_License_No_Wealthy_Link__c, RTL_License_No_Unit_Link__c FROM User WHERE Id =: userId];

                        if (checkCode != '00' && userList[0].IsActive == true) {
                            pwaUserDetail.employee_id = ConvertToString(CheckNullValue(userList[0].Employee_ID__c));
                            pwaUserDetail.mobile_no = ConvertToString(CheckNullValue(userList[0].Mobile_No__c));
                            pwaUserDetail.email = ConvertToString(CheckNullValue(userList[0].Email));
                            pwaUserDetail.first_name_th = ConvertToString(CheckNullValue(userList[0].First_Name_TH__c));
                            pwaUserDetail.last_name_th = ConvertToString(CheckNullValue(userList[0].Last_Name_TH__c));
                            pwaUserDetail.first_name_en = ConvertToString(CheckNullValue(userList[0].FirstName));
                            pwaUserDetail.last_name_en = ConvertToString(CheckNullValue(userList[0].LastName));
                            pwaUserDetail.manager_email = ConvertToString(CheckNullValue(userList[0].Manager_Email__c));

                            pwaUserDetail.license_no_life_insurance = CheckNullValue(userList[0].RTL_Expiry_Date_Life_Insurance__c) == '' ? '' : todayDate <= userList[0].RTL_Expiry_Date_Life_Insurance__c ? ConvertToString(CheckNullValue(userList[0].RTL_License_No_Life_Insurance__c)) : '';
                            pwaUserDetail.license_no_non_life_insurance = CheckNullValue(userList[0].RTL_Expiry_Date_Non_Life_Insurance__c) == '' ? '' : todayDate <= userList[0].RTL_Expiry_Date_Non_Life_Insurance__c ? ConvertToString(CheckNullValue(userList[0].RTL_License_No_Non_Life_Insurance__c)) : '';
                            pwaUserDetail.license_no_paper_1 = CheckNullValue(userList[0].RTL_Expiry_Date_Paper_1__c) == '' ? '' : todayDate <= userList[0].RTL_Expiry_Date_Paper_1__c ? ConvertToString(CheckNullValue(userList[0].RTL_License_No_Paper_1__c)) : '';
                            pwaUserDetail.license_no_paper_4 = CheckNullValue(userList[0].RTL_Expiry_Date_Paper_4__c) == '' ? '' : todayDate <= userList[0].RTL_Expiry_Date_Paper_4__c ? ConvertToString(CheckNullValue(userList[0].RTL_License_No_Paper_4__c)) : '';
                            pwaUserDetail.license_no_paper_5 = CheckNullValue(userList[0].RTL_Expiry_Date_Paper_5__c) == '' ? '' : todayDate <= userList[0].RTL_Expiry_Date_Paper_5__c ? ConvertToString(CheckNullValue(userList[0].RTL_License_No_Paper_5__c)) : '';
                            pwaUserDetail.license_no_icp_1 = CheckNullValue(userList[0].RTL_Expiry_Date_ICP_1__c) == '' ? '' : todayDate <= userList[0].RTL_Expiry_Date_ICP_1__c ? ConvertToString(CheckNullValue(userList[0].RTL_License_No_ICP_1__c)) : '';
                            pwaUserDetail.license_no_complex_p2 = CheckNullValue(userList[0].RTL_Expiry_Date_Complex_P2__c) == '' ? '' : todayDate <= userList[0].RTL_Expiry_Date_Complex_P2__c ? ConvertToString(CheckNullValue(userList[0].RTL_License_No_Complex_P2__c)) : '';
                            pwaUserDetail.license_no_icp_3 = CheckNullValue(userList[0].RTL_Expiry_Date_ICP_3__c) == '' ? '' : todayDate <= userList[0].RTL_Expiry_Date_ICP_3__c ? ConvertToString(CheckNullValue(userList[0].RTL_License_No_ICP_3__c)) : '';
                            pwaUserDetail.license_no_ip = CheckNullValue(userList[0].RTL_Expiry_Date_IP__c) == '' ? '' : todayDate <= userList[0].RTL_Expiry_Date_IP__c ? ConvertToString(CheckNullValue(userList[0].RTL_License_No_IP__c)) : '';
                            pwaUserDetail.license_no_ict = CheckNullValue(userList[0].RTL_Expiry_Date_ICT__c) == '' ? '' : todayDate <= userList[0].RTL_Expiry_Date_ICT__c ? ConvertToString(CheckNullValue(userList[0].RTL_License_No_ICT__c)) : '';
                            pwaUserDetail.license_no_wealthy_link = userList[0].RTL_Active_Flag_Wealthy_Link__c == true ? ConvertToString(CheckNullValue(userList[0].RTL_License_No_Wealthy_Link__c)) : '';
                            pwaUserDetail.license_no_unit_link = userList[0].RTL_Active_Flag_Unit_Link__c == true ? ConvertToString(CheckNullValue(userList[0].RTL_License_No_Unit_Link__c)) : '';

                            // Profile Image URL
                            // ConnectApi.Photo ph =  ConnectApi.UserProfiles.getPhoto(null, UserInfo.getUserId()); <-- replaca user id
                            //ConnectApi.Photo ph =  ConnectApi.UserProfiles.getPhoto(null, userList[0].Id);
                            //System.debug('standardEmailPhotoUrl' + ph.fullEmailPhotoUrl);

                            //pwaUserDetail.profile_image_url = ph.fullEmailPhotoUrl == null ? '' : ph.fullEmailPhotoUrl;

                            /* Start Test Code */
                            String publicLink = '';
                            String profileName = userList[0].Profile.Name;
                            String employeeId = userList[0].Employee_ID__c;
                            if (String.isNotBlank(profileName) && String.isNotBlank(employeeId)) {
                                /* Find library folder from metadata */
                                Library_Profile__mdt[] libraryProfile = [select id, Library__c from Library_Profile__mdt where Profile__c = :profileName];
                                if (libraryProfile != null && !libraryProfile.isEmpty() ) {
                                    // Get ContentWorkspace
                                    String libraryName = libraryProfile[0].Library__c;
                                    System.debug('libraryName-->' + libraryName);
                                    ContentWorkspace[] contentWorkspace = [select Id, Name from ContentWorkspace where Name=:libraryName];
                                    if(contentWorkspace != null && !contentWorkspace.isEmpty()) {
                                        Id workspaceId = contentWorkspace[0].Id;
                                        System.debug('workspaceId-->'+workspaceId);
                                        //ContentVersion[] contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion where FirstPublishLocationId =:workspaceId and Title = :employeeId order by lastmodifiedDate desc];
                                        ContentDocument[] contentDocument = [select Id, Title, ParentId from ContentDocument where ParentId = :workspaceId and Title = :employeeId];

                                        if(contentDocument != null && !contentDocument.isEmpty()) {
                                            System.debug('contentVersion size -->'+contentDocument.size());
                                            // Find in ContentDistribution if not found insert it
                                            String contentDocumentId = contentDocument[0].Id;
                                            System.debug('contentDocumentId-->'+contentDocumentId);
                                            
                                            ContentDistribution[] contentDistribution = [select Id, ContentDocumentId, ContentDownloadUrl from ContentDistribution where ContentDocumentId = :contentDocumentId];
                                            
                                            if(contentDistribution != null && !contentDistribution.isEmpty()) {
                                                //System.debug('url -->'+contentDistribution[0].ContentDownloadUrl);
                                                //publicLink = contentDistribution[0].ContentDownloadUrl;
                                                System.debug('delete contentDistribution');
                                                delete contentDistribution;
                                            } 
                                            System.debug('Insert ');
                                            ContentVersion cv = [SELECT Id, ContentSize, FileExtension FROM ContentVersion where ContentDocumentId = :contentDocumentId and IsLatest = true];
                                            ContentDistribution cd = new ContentDistribution();
                                            cd.Name = 'Test';
                                            cd.ContentVersionId = cv.Id;
                                            cd.PreferencesAllowViewInBrowser= true;
                                            cd.PreferencesLinkLatestVersion=true;
                                            cd.PreferencesNotifyOnVisit=false;
                                            cd.PreferencesPasswordRequired=false;
                                            cd.PreferencesAllowOriginalDownload= true;
                                            insert cd;

                                            Boolean IsValidfileType = false;
                                            if(cv.FileExtension.contains('png') || cv.FileExtension.contains('jpg')){
                                                IsValidfileType = true;
                                            }
                                            
                                            ContentDistribution[] newCd = [select Id, ContentDocumentId, ContentDownloadUrl from ContentDistribution where Id = :cd.Id];
                                            if(newCd != null && !newCd.isEmpty() && cv.ContentSize < 100000 && IsValidfileType) {
                                                System.debug('url -->'+newCd[0].ContentDownloadUrl);
                                                publicLink = newCd[0].ContentDownloadUrl;
                                            }
                                            
                                        }
                                    } else {
                                        System.debug('No authorize to access library [' + libraryName + ']');
                                    }
                                    
                                    System.debug('publicLink' + publicLink);
                                }
                            }

                            pwaUserDetail.profile_image_url = publicLink;
                            
                            /* End Test Code */
  
                            response.status = 'SUCCESS';
                            response.status_code = '0';
                            response.message = '';
                            response.data = pwaUserDetail;
                            // response.data = pwaUserDetail.getJSONString();
                        } else if (checkCode != '00' && userList[0].IsActive == false) {
                            response.status = 'FAIL';
                            response.status_code = '3';
                            response.message = 'Customer\'s PWA is inactive status';
                            response.data = '';
                        } else {
                            response.status = 'FAIL';
                            response.status_code = '2';
                            response.message = 'Customer do not have PWA';
                            response.data = '';
                        }
                    } else {
                        response.status = 'FAIL';
                        response.status_code = '2';
                        response.message = 'Customer do not have PWA';
                        response.data = '';
                    }
                } else {
                    response.status = 'FAIL';
                    response.status_code = '2';
                    response.message = 'Customer do not have PWA';
                    response.data = '';
                }
            } else {
                response.status = 'FAIL';
                response.status_code = '1';
                response.message = 'Customer not found';
                response.data = '';

                accForLog = null;
            }

            // response.status = 'SUCCESS';
            // response.status_code = '0';
            // response.message = '';
            // response.data = pwaUserDetail;

            System.debug('Response: ' + response);
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serializePretty(response), encryptKey));

            requestBody = requestHeader.toString() + '\n\n' + JSON.serializePretty(JSON.deserializeUntyped(JSON.serializePretty(JSON.deserializeUntyped(requestBodyDecrypt))));
            responseBody = JSON.serializePretty(pwaUserDetail);

            // accForLog = accList[0];
            endTime = DateTime.Now();

            // OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  reqId ,  userName,
            // RMID ,  serviceName , requestBody , responseBody ,  accForLog , startTime ,  endTime,  null );
            OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  reqId ,  userName,
            RMID ,  serviceName , requestBody , JSON.serializePretty(response) ,  accForLog , startTime ,  endTime,  null );

        } catch (Exception e) {
            response.status_code = '99';
            response.status = 'FAIL';
            response.message = 'Internal System Error';
            response.data = '';
System.debug(e.getMessage());
            System.debug('Response: ' + response);
            encryptKey = (String)SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), SCSMessageAPIUtil.INTEGRATE_SYSTEM.OneApp);
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(response), encryptKey));

            errorMessage = 'Internal System Error, Error Message: ' + e.getMessage();

            isSuccess = false;
            accForLog = null;
            endTime = DateTime.Now();

            requestBody = request.headers.toString() + '\n\n' + JSON.serializePretty(JSON.deserializeUntyped(JSON.serializePretty(JSON.deserializeUntyped(requestBodyDecrypt))));

            OnlineServiceLogUtils.saveToOnlineLog( isSuccess , customerName,  errorMessage,  reqId ,  userName,
            RMID ,  serviceName , requestBody , JSON.serializePretty(response) ,  accForLog , startTime ,  endTime,  null );
        }

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.statusCode = 200;
        RestContext.response.responseBody = Blob.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(response), encryptKey));
    }

    private static Object CheckNullValue(Object obj) {
        return obj == null ? '' : obj;
    }

    private static String ConvertToString(Object obj) {
        return String.valueOf(obj);
    }
}