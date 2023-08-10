@RestResource(urlMapping = '/data/V1.0/LeadScore/getScoringList/*')
global with sharing class RTL_LGS_InquiryLeadScoringList extends RTL_AL_WebserviceAbstract{
    @HttpPost
    global static SCSReqRes getLeadScoringListInfo(){
        RestRequest request = RestContext.request;
        Map<String, String> requestHeader = RestContext.request.headers;
        System.debug(request);
        String encryptKey = '';
        String errorMessage = '';
        String status = '';
        String customerName = '';
        String msLogId = '';
        String userName = UserInfo.getName();
        String rmId = '';
        String serviceName = '/LeadScore/getScoringList';
        String requestBody = String.valueOf(request.requestBody);
        String requestBodyDecrypt = '';
        String responseBody = '';
        String reqId = requestHeader.containsKey('ReqId') ? requestHeader.get('ReqId') : '';
        Account acc = new Account();
        DateTime startTime = DateTime.Now();
        DateTime endTime;
        
        try{
            encryptKey = getKeyFromSystem(request);
            String integrationSystem = requestHeader.get('Integration-System');
            System.debug('encryptKey' + encryptKey);
            requestBodyDecrypt = (String) SCSMessageAPIUtil.decryptMessageWithKey(request.requestBody.toString(), encryptKey);
            requestBody = '"Integration System": ' + integrationSystem  + '\n\n' + (requestBodyDecrypt!=null?requestBodyDecrypt:'');
        } catch (WebserviceAbstract.MissingHeaderException e){
            System.debug('ERROR : ' + e.getMessage());
            // Handle error
            // Return error response : invalid key
        }

        try{
            Boolean isSuccess = true;
            String statusCode = '0';
            status = 'Success.';
            InquiryManager inqMgr = new InquiryManager('LGS_InquiryLeadScoringList',  new Map<String, Object>());
            //InquiryManager inqMgr = new InquiryManager('LGS_InquiryLeadScoringList', '');
            List<Map<String, Object>> jsonResult = inqMgr.getResult();
            Map<String, Object> returnValue = new Map<String, Object>{ 'data' => jsonResult, 'status_desc' => status, 'status_code' => statusCode };
            endTime = DateTime.Now();
            responseBody = JSON.serializePretty(returnValue);
            RTL_CampaignUtil.saveToOnlineLog(isSuccess ,customerName, errorMessage, reqId , userName, 
		    rmId , serviceName , requestBody,responseBody , acc , startTime , endTime, null );
            return (SCSReqRes)returnResponse(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(returnValue), encryptKey));
        } catch (Exception e){
            String errorMsg = getErrorMessageException(e);
            status = errorMsg;
            String statusCode = '99';
            Boolean isSuccess = false;
            Map<String, String> returnValue = new Map<String, String>{ 'status_desc' => errorMsg, 'status_code' => statusCode };
            endTime = DateTime.Now();
            RTL_CampaignUtil.saveToOnlineLog(isSuccess ,customerName, errorMsg, reqId , userName, 
		    rmId , serviceName ,requestBody ,responseBody , acc , startTime , endTime, null );
            return (SCSReqRes)returnResponse(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(returnValue), encryptKey));
        }
    }

}