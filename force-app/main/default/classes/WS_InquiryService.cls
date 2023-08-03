@RestResource(urlMapping='/InquiryService/*')
/*
*********************************************************
Apex Class Name    : WS_InquiryService
Created Date       : August 3, 2023
@description       : This is class is webservice that working with InquiryManager to dynamic query with configurable.
@author            : Auttapol Pipatpatama
Modification Log:
Ver    Date         Author                   Modification
1.00   03-08-2022   Auttapol Pipatpatama     Initial Version
*********************************************************
*/
global class WS_InquiryService extends WebserviceAbstract {
    private static final String SERVICE_NAME = '/InquiryService/';

    private static final Integer STATUS_CODE_SUCCESS = 0;
    private static final Integer STATUS_CODE_RECORD_NOT_FOUND = 1;
    private static final Integer STATUS_CODE_INVALID_REQUEST_BODY = 81;
    private static final Integer STATUS_CODE_INVALID_REQUEST_PARAMETER = 82;
    private static final Integer STATUS_CODE_INVALID_ENCRYPTION_KEY = 83;
    private static final Integer STATUS_CODE_MISSING_SERVICE_NAME = 84;
    private static final Integer STATUS_CODE_INVALID_SERVICE_NAME = 85;
    private static final Integer STATUS_CODE_SYSTEM_ERROR = 99;

    private static final Map<Integer, String> RESULT_CODE = new Map<Integer, String>{
        STATUS_CODE_SUCCESS => 'Success',
        STATUS_CODE_RECORD_NOT_FOUND => 'Record Not Found',
        STATUS_CODE_INVALID_REQUEST_BODY => 'Invalid request body', 
        STATUS_CODE_INVALID_REQUEST_PARAMETER => 'Invalid request parameter',
        STATUS_CODE_INVALID_ENCRYPTION_KEY => 'Invalid encryption key', 
        STATUS_CODE_MISSING_SERVICE_NAME => 'Missing service name', 
        STATUS_CODE_INVALID_SERVICE_NAME => 'Invalid service name', 
        STATUS_CODE_SYSTEM_ERROR => 'System error'
    };

    
    /*
    *********************************************************
    @Method Name    : mappingService
    @author         : Auttapol Pipatpatama
    @description    : method use for query from service name and body request
    @param          :
    @return         : 
    ********************************************************
    */
    @HttpPost
    global static void mappingService(){
        HttpResponse res;
        RestRequest request = RestContext.request;
        String encryptKey = '';

        try {
            // Check key from request
            Map<String, String> requestHeader = request.headers;
            String integrationSystem = requestHeader.get('Integration-System');

            if(String.isNotEmpty(integrationSystem)) {
                encryptKey = getKeyFromSystem(request);
            }

            // Get query name from URI
            String uri = request.requestURI;
            String inquiryName = uri.remove(SERVICE_NAME);
            System.debug('URI --> ' + uri); 
            System.debug('inquiryName --> ' + inquiryName); 

            // Validate inquiry service name
            if (String.isEmpty(inquiryName)) {
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf( generateJsonResult(STATUS_CODE_MISSING_SERVICE_NAME, null, encryptKey) );
                return;
            }

            String countQueryString = 'SELECT count() FROM Inquiry_List__c WHERE Inquiry_Name__c = :inquiryName';
            Integer countResult = Database.countQuery(countQueryString);
            if (countResult == 0) {
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf( generateJsonResult(STATUS_CODE_INVALID_SERVICE_NAME, null, encryptKey) );
                return;
            }

            // Parse body request to json
            Blob jsonBlob = request.requestBody;
            System.debug('jsonBlob --> ' + jsonBlob);

             // Validate json body
            if (jsonBlob == null || jsonBlob.size() == 0) {
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf( generateJsonResult(STATUS_CODE_INVALID_REQUEST_BODY, null, encryptKey) );
                return;
            }


            String jsonString = jsonBlob.toString();
            String requestBodyDecrypt = '';

            if (String.isNotEmpty(encryptKey)) {
                // Encrypt mode
                requestBodyDecrypt = (String) SCSMessageAPIUtil.decryptMessageWithKey(jsonString, encryptKey);
            } else {
                // No Encrypt mode
                requestBodyDecrypt = jsonString;
            }

            Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(requestBodyDecrypt);
            List<Map<String, Object>> myMaps = new List<Map<String, Object>>();
            Map<String, Object> inquiryKeyMap = (Map<String, Object>) meta.get('key');
            
            System.debug('inquiryKeyMap --> ' + inquiryKeyMap);

            // Call inquiry utility with service name
            InquiryManager inqMgr = new InquiryManager(inquiryName, inquiryKeyMap);
            List<Map<String, Object>> jsonResult = inqMgr.getResult();

            // Response
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = Blob.valueOf( generateJsonResult(STATUS_CODE_SUCCESS, jsonResult, encryptKey) );
            

        } catch (WebserviceAbstract.MissingHeaderException e) {
        	/* return error response */
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf( generateJsonResult(STATUS_CODE_INVALID_ENCRYPTION_KEY, null, encryptKey) );
            
        } catch (Exception e) {
        	/* return error response */
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.statusCode = 500;
            RestContext.response.responseBody = Blob.valueOf( generateJsonResult(STATUS_CODE_SYSTEM_ERROR, null, encryptKey) );
            
        }
    }
    
    /*
    *********************************************************
    @Method Name    : generateJsonResult
    @author         : Auttapol Pipatpatama
    @description    : method use for generate json result for return in response
    @param          : resultCode
    @param          : data
    @param          : encryptKey
    @return         : String
    ********************************************************
    */
    private static String generateJsonResult(Integer resultCode, Object data, String encryptKey) {
        Map<String, Object> returnValue = new Map<String, Object>{
            'data' => data ,
            'status_desc' => RESULT_CODE.get(resultCode),
            'status_code' => resultCode
        };

        if (String.isNotEmpty(encryptKey)) {
            return SCSMessageAPIUtil.encryptMessageWithKey(JSON.serializePretty(returnValue), encryptKey);
        } else {
            return JSON.serializePretty(returnValue);
        }
    }
}