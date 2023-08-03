@RestResource(urlMapping = '/data/V1.0/LeadScore/getScoringConditionDetail/*')
global with sharing class RTL_LGS_InquiryScoringConDetail extends RTL_AL_WebserviceAbstract{
    @HttpPost
    global static SCSReqRes getScoringConditionDetail(){
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
        String serviceName = '/LeadScore/getScoringConditionDetail';
        String requestBody = String.valueOf(request.requestBody);
        String responseBody = '';
        String reqId = requestHeader.containsKey('ReqId') ? requestHeader.get('ReqId') : '';
        Account acc = new Account();
        DateTime startTime = DateTime.Now();
        DateTime endTime;
        String requestBodyDecrypt = '';
        try{
            encryptKey = getKeyFromSystem(request);
            String integrationSystem = requestHeader.get('Integration-System');
            requestBodyDecrypt = (String) SCSMessageAPIUtil.decryptMessageWithKey(request.requestBody.toString(), encryptKey);
            requestBody = '"Integration System": ' + integrationSystem  + '\n\n' + requestBodyDecrypt;
        } catch (WebserviceAbstract.MissingHeaderException e){
            System.debug('ERROR : ' + e.getMessage());
            // Handle error
            // Return error response : invalid key
        }

        try{
            String statusCode = '0';
            status = 'Success.';
            
            String scoringCriteriaId = (String) AbstractCoreClass.getResult('Scoring_Criteria_Id', JSON.deserializeUntyped(requestBodyDecrypt));
            Boolean isSuccess = true;

            Map<String, Object> inquiryKeyMap = new Map<String, Object>();
            inquiryKeyMap.put('inquiryKeyId', scoringCriteriaId);

            InquiryManager inqMgr = new InquiryManager('LGS_InquiryScoringConDetail', inquiryKeyMap);
            //InquiryManager inqMgr = new InquiryManager('LGS_InquiryScoringConDetail', scoringCriteriaId);
            List<Map<String, Object>> jsonResult = inqMgr.getResult();
            if(jsonResult.isEmpty()){
                statusCode = '1';
                status = 'Record Not Found';
            }
            Map<String, Object> returnValue = new Map<String, Object>{ 'data' => jsonResult, 'status_desc' => status, 'status_code' => statusCode };
            
            endTime = DateTime.Now();
            responseBody = JSON.serializePretty(returnValue);
            RTL_CampaignUtil.saveToOnlineLog(isSuccess ,customerName, errorMessage, reqId , userName, 
		    rmId , serviceName ,requestBody ,responseBody , acc , startTime , endTime, null );
            
            return (SCSReqRes)returnResponse(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(returnValue), encryptKey));
        } catch (Exception e){
            
            String errorMsg = getErrorMessageException(e);
            status = errorMsg;
            String statusCode = '99';
            Boolean isSuccess = false;
            Map<String, String> returnValue = new Map<String, String>{ 'status_desc' => status, 'status_code' => statusCode };
            endTime = DateTime.Now();
            RTL_CampaignUtil.saveToOnlineLog(isSuccess ,customerName, errorMsg, reqId , userName, 
		    rmId , serviceName ,requestBody ,responseBody , acc , startTime , endTime, null );
            return (SCSReqRes)returnResponse(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(returnValue), encryptKey));
        }
    }

}