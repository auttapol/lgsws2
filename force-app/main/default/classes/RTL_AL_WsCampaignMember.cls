@RestResource(urlMapping='/data/V1.0/sobjects/getByMarketingCode/*')
global with sharing class RTL_AL_WsCampaignMember extends RTL_AL_WebserviceAbstract {
  global RTL_AL_WsCampaignMember() {
  }
  public virtual class BaseException extends Exception {}
  public class OtherException extends BaseException {}

  @HttpPost
  global static SCSReqRes getOfferStatus() {
    Datetime startDate = Datetime.now();
    RestRequest request = RestContext.request;
    Map<String, String> requestHeader = RestContext.request.headers;
    String requestBodyDecrypt = '';
    String encryptKey = '';
    try {
      encryptKey = getKeyFromSystem(request);
    } catch (WebserviceAbstract.MissingHeaderException e) {
      encryptKey = (String) SCSMessageAPIUtil.getEncryptKey(
        SCSMessageAPIUtil.fetchUserSessionId(),
        SCSMessageAPIUtil.INTEGRATE_SYSTEM.OneApp
      );
    }

    try {
      requestBodyDecrypt = (String) SCSMessageAPIUtil.decryptMessageWithKey(
        request.requestBody.toString(),
        encryptKey
      );
      // if(requestHeader.containsKey('For-Test') ? requestHeader.get('For-Test') == 'DEV' : false) {
      //     requestBodyDecrypt = request.requestBody.toString();
      // }
      String marketingCode = (String) AbstractCoreClass.getResult(
        'marketingCode',
        JSON.deserializeUntyped(requestBodyDecrypt)
      );
      System.debug('marketingCode -->' + marketingCode);

      List<CampaignMember> ListcampaignMemberTouch = [
        SELECT
          Id,
          RTL_Marketing_Code__c,
          RTL_AL_response__c,
          Name,
          Customer__c,
          RTL_TMB_Cust_ID__c,
          RTL_RelatedOpportunity_1__c,
          RTL_RelatedOpportunity_2__c,
          RTL_RelatedOpportunity_3__c,
          RTL_RelatedOpportunity_4__c,
          RTL_RelatedOpportunity_5__c,
          RTL_AL_Response_Flage__c,
          RTL_Is_Send_To_HPAP__c,
          RTL_Is_Interface_Success__c,
          RTL_OfferResult_Product_1__c,
          RTL_OfferResult_Product_2__c,
          RTL_OfferResult_Product_3__c,
          RTL_OfferResult_Product_4__c,
          RTL_OfferResult_Product_5__c,
          Campaign.Status
        FROM CampaignMember
        WHERE
          RTL_Marketing_Code__c = :marketingCode
          AND RTL_Marketing_Code__c != NULL
        LIMIT 1
      ];
        if(ListcampaignMemberTouch.size() == 0){
          throw new OtherException('Marketing code does not found in salseforce');
        }
      CampaignMember campaignMemberTouch = ListcampaignMemberTouch[0];
      Boolean isCampaignExpired = campaignMemberTouch != null && campaignMemberTouch.Campaign.Status == 'Expired';
      Boolean isConvertedToOppty =
        (campaignMemberTouch != null &&
        (campaignMemberTouch.RTL_RelatedOpportunity_1__c != null ||
        campaignMemberTouch.RTL_RelatedOpportunity_2__c != null ||
        campaignMemberTouch.RTL_RelatedOpportunity_3__c != null ||
        campaignMemberTouch.RTL_RelatedOpportunity_4__c != null ||
        campaignMemberTouch.RTL_RelatedOpportunity_5__c != null)) || campaignMemberTouch.RTL_AL_response__c;

      Boolean isReferralCreated = 
        (campaignMemberTouch.RTL_OfferResult_Product_1__c == 'Referred' ||
        campaignMemberTouch.RTL_OfferResult_Product_2__c == 'Referred' ||
        campaignMemberTouch.RTL_OfferResult_Product_3__c == 'Referred' ||
        campaignMemberTouch.RTL_OfferResult_Product_4__c == 'Referred' ||
        campaignMemberTouch.RTL_OfferResult_Product_5__c == 'Referred');

      Boolean ResponseHPAP = campaignMemberTouch != null && campaignMemberTouch.RTL_Is_Send_To_HPAP__c == true ;
      
      Boolean isInterfaceSuccess =  campaignMemberTouch != null && campaignMemberTouch.RTL_Is_Interface_Success__c == true ;
      System.debug(ResponseHPAP);
      System.debug(isInterfaceSuccess);
      

      Map<String, String> returnValue = new Map<String, String>{
        'status_code' => isConvertedToOppty || ResponseHPAP || isInterfaceSuccess || isReferralCreated || isCampaignExpired ? '1' : '2',
        'message' => isConvertedToOppty || ResponseHPAP || isInterfaceSuccess || isReferralCreated || isCampaignExpired
          ? 'ขอขอบคุณที่ตอบรับข้อเสนอสินเชื่อรถแลกเงินท็อปอัพ ตามที่ท่านได้ยื่นเรื่องสมัครเรียบร้อยแล้ว สามารถตรวจสอบผลการอนุมัติได้ที่เจ้าหน้าที่รับสมัคร หรือโทร 1428'
          : 'Marketing code does not convert to Opportunity. Submit button in Touch is available.'
      };
      
      

      RTL_CampaignUtil.saveToOnlineLog(
        true,
        '', // customerName
        '',
        //requestHeader.containsKey('Request-UID')? requestHeader.get('Request-UID'): '', 
        requestHeader.containsKey('ReqId')? requestHeader.get('ReqId'): '',// msLogId
        UserInfo.getName(),
        '',
        String.isNotEmpty(request.resourcePath)
          ? String.format(
              '{0}: {1}',
              new List<Object>{ request.httpMethod, request.resourcePath }
            )
          : getServiceName(SERVICENAME.CreateLEAD),
        AbstractCoreClass.serializePrettyString(requestBodyDecrypt), // Request Body
        JSON.serializePretty(returnValue), // Response Body
        null,
        startDate,
        Datetime.now() // End datetime
      );

      return (SCSReqRes) returnResponse(
        SCSMessageAPIUtil.encryptMessageWithKey(
          JSON.serialize(returnValue),
          encryptKey
        )
      );
    } catch (Exception e) {
      String errorMsg = getErrorMessageException(e);
      String statusCode = '99';
      Boolean isSuccess = false;
      if(errorMsg == 'Marketing code does not found in salseforce'){
        statusCode = '3';
        isSuccess = true;
      }
      Map<String, String> returnValue = new Map<String, String>{
        'status_code' => statusCode,
        'message' => errorMsg 
      };
      RTL_CampaignUtil.saveToOnlineLog(
        isSuccess,
        '', // customerName
        errorMsg,
        //requestHeader.containsKey('Request-UID')? requestHeader.get('Request-UID'): '', 
        requestHeader.containsKey('ReqId')? requestHeader.get('ReqId'): '',// msLogId// msLogId
        UserInfo.getName(),
        '',
        String.isNotEmpty(request.resourcePath)
          ? String.format(
              '{0}: {1}',
              new List<Object>{ request.httpMethod, request.resourcePath }
            )
          : getServiceName(SERVICENAME.CreateLEAD),
        AbstractCoreClass.serializePrettyString(requestBodyDecrypt), // Request Body
        JSON.serializePretty(returnValue), // Response Body
        null,
        startDate,
        Datetime.now() // End datetime
      );
      return (SCSReqRes) returnResponse(
        SCSMessageAPIUtil.encryptMessageWithKey(
          JSON.serialize(returnValue),
          encryptKey
        )
      );
    }
  }
}