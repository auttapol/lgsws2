@RestResource(urlMapping = '/data/V1.0/CampaignMember/getInfoByMarketingCode/*')
global with sharing class RTL_AL_WsCampaignMemberInfo extends RTL_AL_WebserviceAbstract{
  global RTL_AL_WsCampaignMemberInfo(){
  }

  public virtual class BaseException extends Exception{
  }

  public class OtherException extends BaseException{
  }

  @HttpPost
  global static SCSReqRes getCarInfo(){
    Datetime startDate = Datetime.now();
    RestRequest request = RestContext.request;
    Map<String, String> requestHeader = RestContext.request.headers;
    String requestBodyDecrypt = '';
    String requestBody = '';
    String encryptKey = '';
    String status;

    String integrationSystem = requestHeader.get('Integration-System');
    
    try{
      encryptKey = getKeyFromSystem(request);
    } catch (WebserviceAbstract.MissingHeaderException e){
      encryptKey = (String) SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), SCSMessageAPIUtil.INTEGRATE_SYSTEM.OneApp);
    }
    System.debug('encryptKey : '+encryptKey);

    List<Lead> campaignMemberInfo = new List<Lead>();
    String key = null;
    Boolean isMarketingCode;
    try{
      requestBodyDecrypt = (String) SCSMessageAPIUtil.decryptMessageWithKey(request.requestBody.toString(), encryptKey);
      String marketingCode = (String) AbstractCoreClass.getResult('marketingCode', JSON.deserializeUntyped(requestBodyDecrypt));
      System.debug('marketingCode -->' + marketingCode);
      requestBody = '"Integration System": ' + integrationSystem  + '\n\n' + requestBodyDecrypt;
      String webUniqueId = (String) AbstractCoreClass.getResult('webUniqueId', JSON.deserializeUntyped(requestBodyDecrypt));
      System.debug('webUniqueId -->' + webUniqueId);

      if (marketingCode != null && marketingCode != ''){
        key = marketingCode;
        isMarketingCode = true;
      } else if (webUniqueId != null && webUniqueId != ''){
        key = webUniqueId;
        isMarketingCode = false;
        campaignMemberInfo = [SELECT Id, Status FROM Lead WHERE RTL_Web_Unique_ID_c__c = :key AND Status = 'Duplicated' LIMIT 1];
      }
      
      String message = '';
      // Enhance for Inquiry Campaign Member details from CRM to LGS
      // if (integrationSystem.toUpperCase() == 'LGS'){
      if (key != null){
          try {
            if(campaignMemberInfo.size() > 0){
              throw new OtherException('Marketing code/Web Unique ID does not found in Campaign Member because lead duplicate.');
            }
            String statusCode = '0';
            status = 'Success.';
            InquiryManager inqMgr = new InquiryManager('',  new Map<String, Object>());
            Map<String, Object> inquiryKeyMap = new Map<String, Object>();
            if(isMarketingCode){
              inquiryKeyMap.put('RTL_Marketing_Code__c',key);
            }else{
              inquiryKeyMap.put('RTL_Web_Unique_ID__c',key);
            }
            if (integrationSystem.toUpperCase() == 'LGS'){
              inqMgr = new InquiryManager('LGS_InquiryCampInfo', inquiryKeyMap);
            }else{
              inqMgr = new InquiryManager('OneApp_InquiryCampInfo', inquiryKeyMap);
            }
            
            List<Map<String, Object>> jsonResult = inqMgr.getResult();
            System.debug(jsonResult);
            Map<String, Object> returnValue = new Map<String, Object>{ 'data' => jsonResult, 'status_desc' => status, 'status_code' => statusCode };
            
            if (jsonResult.isEmpty()){
              throw new OtherException('Marketing code/Web Unique ID does not found in Salesforce.');
            }
            RTL_CampaignUtil.saveToOnlineLog(true, '',  // customerName
            '', 
            //requestHeader.containsKey('Request-UID')? requestHeader.get('Request-UID'): '',
            requestHeader.containsKey('ReqId') ? requestHeader.get('ReqId') : '',     // msLogId
            UserInfo.getName(), '', String.isNotEmpty(request.resourcePath) ? String.format('{0}: {1}', new List<Object>{ request.httpMethod, request.resourcePath }) : getServiceName(SERVICENAME.CreateLEAD), (requestBody),      // Request Body
            JSON.serializePretty(returnValue),      // Response Body
            null, startDate, Datetime.now() // End datetime
            );
            return (SCSReqRes)returnResponse(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(returnValue), encryptKey));
          } catch (Exception e){
            String errorMsg = getErrorMessageException(e);
            status = errorMsg;
            String statusCode = '99';
            Boolean isSuccess = false;
            if (errorMsg == 'Marketing code/Web Unique ID does not found in Salesforce.'){
              statusCode = '3';
              isSuccess = true;
            }else if(errorMsg == 'Marketing code/Web Unique ID does not found in Campaign Member because lead duplicate.'){
              statusCode = '4';
              isSuccess = true;
            }
            Map<String, String> returnValue = new Map<String, String>{ 'status_desc' => errorMsg, 'status_code' => statusCode };
            RTL_CampaignUtil.saveToOnlineLog(isSuccess, '',  // customerName
            '', 
            //requestHeader.containsKey('Request-UID')? requestHeader.get('Request-UID'): '',
            requestHeader.containsKey('ReqId') ? requestHeader.get('ReqId') : '',     // msLogId
            UserInfo.getName(), '', String.isNotEmpty(request.resourcePath) ? String.format('{0}: {1}', new List<Object>{ request.httpMethod, request.resourcePath }) : getServiceName(SERVICENAME.CreateLEAD), (requestBody),      // Request Body
            JSON.serializePretty(returnValue),      // Response Body
            null, startDate, Datetime.now() // End datetime
            );
            return (SCSReqRes)returnResponse(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(returnValue), encryptKey));
          }
      } else{
        throw new OtherException('Invalid Marketing code and Web UniqueId');
      }

    }
      //AL Inquiry Campaign Member details
      // else if (key != null){
      //   String statusCode = '0';
      //   Map<String, Object> inquiryKeyMap = new Map<String, Object>();
      //   inquiryKeyMap.put('RTL_Web_Unique_ID__c',key);
      //   inquiryKeyMap.put('RTL_Marketing_Code__c',key);

      //   InquiryManager inqMgr = new InquiryManager('OneApp_InquiryCampInfo', inquiryKeyMap);
      //   //InquiryManager inqMgr = new InquiryManager('OneApp_InquiryCampInfo', key);
        
      //   List<Map<String, Object>> jsonResult = inqMgr.getResult();
        
      //   Map<String, Object> returnValue = new Map<String, Object>{ 'data' => jsonResult, 'status_desc' => message, 'status_code' => statusCode };
      //   System.debug('inqMgr --> '+inqMgr);
      //   System.debug('JSON :' + jsonResult);
      //   if (jsonResult.isEmpty()){
      //     throw new OtherException('Marketing code/Web Unique ID does not found in Salesforce.');
      //   }
      //   RTL_CampaignUtil.saveToOnlineLog(true, '',      // customerName
      //   '', 
      //   //requestHeader.containsKey('Request-UID')? requestHeader.get('Request-UID'): '',
      //   requestHeader.containsKey('ReqId') ? requestHeader.get('ReqId') : '',     // msLogId
      //   UserInfo.getName(), '', String.isNotEmpty(request.resourcePath) ? String.format('{0}: {1}', new List<Object>{ request.httpMethod, request.resourcePath }) : getServiceName(SERVICENAME.CreateLEAD), (requestBody),      // Request Body
      //   JSON.serializePretty(returnValue),      // Response Body
      //   null, startDate, Datetime.now() // End datetime
      //   );
      //   // mDebugUntruncated(SCSMessageAPIUtil.encryptMessageWithKey(
      //   //   JSON.serialize(returnValue),
      //   //   encryptKey
      //   // ));
      //   // if (isMarketingCode){
      //   //   campaignMemberInfo = [SELECT Id, CampaignId, 
      //   //   // RTL_HP_Account_No__c,
      //   //   RTL_Account_No_1__c, RTL_Marketing_Code__c, RTL_AL_car_brand__c, RTL_AL_car_gear__c, RTL_AL_car_group__c, RTL_AL_car_subtype__c, RTL_AL_car_type__c, RTL_AL_car_year__c, RTL_AL_installment_amount__c, RTL_AL_max_set_up_amount__c, RTL_AL_normal_price__c, RTL_Campaign_Product_1__c, RTL_Campaign_Product_1__r.Name, RTL_AL_car_plate_no__c, RTL_AL_ILA_AMT__c, RTL_AL_REMN_MTH__c, RTL_AL_OFFR_ILA_AMT__c, RTL_AL_OFFR_ILA_MTH__c, RTL_AL_promotion_detail__c, Lead.RTL_Owner_Type__c, 
      //   //   //  LeadOwner,
      //   //   RTL_Promotion__c, RTL_Remark__c, RTL_TMB_Cust_ID__c, RTL_AL_Province_Car_Plate_No__c, RTL_AL_CAMP_EXP_DTE__c, RTL_AL_BlueBook__c, RTL_AL_BlueBook__r.RTL_AL_bluebook_code__c, Campaign.RTL_Campaign_Code_10_digits__c
      //   //               FROM CampaignMember
      //   //               WHERE RTL_Marketing_Code__c = :key
      //   //               LIMIT 1];
      //   // } else if (!isMarketingCode){
      //   //   campaignMemberInfo = [SELECT Id, CampaignId, 
      //   //   // RTL_HP_Account_No__c,
      //   //   RTL_Account_No_1__c, RTL_Marketing_Code__c, RTL_AL_car_brand__c, RTL_AL_car_gear__c, RTL_AL_car_group__c, RTL_AL_car_subtype__c, RTL_AL_car_type__c, RTL_AL_car_year__c, RTL_AL_installment_amount__c, RTL_AL_max_set_up_amount__c, RTL_AL_normal_price__c, RTL_Campaign_Product_1__c, RTL_Campaign_Product_1__r.Name, RTL_AL_car_plate_no__c, RTL_AL_ILA_AMT__c, RTL_AL_REMN_MTH__c, RTL_AL_OFFR_ILA_AMT__c, RTL_AL_OFFR_ILA_MTH__c, RTL_AL_promotion_detail__c, 
      //   //   // Lead.RTL_Owner_Type__c,
      //   //   //  LeadOwner,
      //   //   RTL_Promotion__c, RTL_Remark__c, RTL_TMB_Cust_ID__c, RTL_AL_Province_Car_Plate_No__c, RTL_AL_CAMP_EXP_DTE__c, RTL_AL_BlueBook__c, RTL_AL_BlueBook__r.RTL_AL_bluebook_code__c, Campaign.RTL_Campaign_Code_10_digits__c
      //   //               FROM CampaignMember
      //   //               WHERE RTL_Web_Unique_ID__c = :key
      //   //               LIMIT 1];
      //   // }
      //   // System.debug('campaignMemberInfo => ' + campaignMemberInfo);

      //   return (SCSReqRes)returnResponse(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(returnValue), encryptKey));
      // } else{
      //   throw new OtherException('Invalid Marketing code and Web UniqueId');
      // }
      // Map<String, Object> res = new Map<String, Object>();

    catch (Exception e){
      String errorMsg = getErrorMessageException(e);
      String statusCode = '99';
      Boolean isSuccess = false;
      requestBodyDecrypt = (String) SCSMessageAPIUtil.decryptMessageWithKey(request.requestBody.toString(), encryptKey);
      requestBody = '"Integration System": ' + integrationSystem  + '\n\n' + requestBodyDecrypt;
      // if (errorMsg == 'Marketing code/Web Unique ID does not found in Salesforce.'){
      //   statusCode = '3';
      //   isSuccess = true;
      // }
      Map<String, String> returnValue = new Map<String, String>{ 'status_desc' => errorMsg, 'status_code' => statusCode// Don't create lead
      // 'Error' => e.getMessage(),
      // 'Line' => e.getStackTraceString()
       };
      RTL_CampaignUtil.saveToOnlineLog(isSuccess, '',      // customerName
      errorMsg, 
      //requestHeader.containsKey('Request-UID')? requestHeader.get('Request-UID'): '',
      requestHeader.containsKey('ReqId') ? requestHeader.get('ReqId') : '',     // msLogId// msLogId
      UserInfo.getName(), '', String.isNotEmpty(request.resourcePath) ? String.format('{0}: {1}', new List<Object>{ request.httpMethod, request.resourcePath }) : getServiceName(SERVICENAME.CreateLEAD), requestBody,      // Request Body
      JSON.serializePretty(returnValue),      // Response Body
      null, startDate, Datetime.now() // End datetime
      );
      return (SCSReqRes)returnResponse(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(returnValue), encryptKey));
    }
  }

  // private static Map<String, Object> bodyResponse(CampaignMember cm){
  //   return new Map<String, Object>{ 'CampaignCode' => cm.Campaign.RTL_Campaign_Code_10_digits__c != null ? cm.Campaign.RTL_Campaign_Code_10_digits__c : '', 'RTL_HP_Account_No__c' => cm.RTL_Account_No_1__c != null ? cm.RTL_Account_No_1__c : '', 'RTL_Marketing_Code__c' => cm.RTL_Marketing_Code__c != null ? cm.RTL_Marketing_Code__c : '', 'RTL_AL_car_brand__c' => cm.RTL_AL_car_brand__c != null ? cm.RTL_AL_car_brand__c : '', 'RTL_AL_car_gear__c' => cm.RTL_AL_car_gear__c != null ? cm.RTL_AL_car_gear__c : '', 'RTL_AL_car_group__c' => cm.RTL_AL_car_group__c != null ? cm.RTL_AL_car_group__c : '', 'RTL_AL_car_subtype__c' => cm.RTL_AL_car_subtype__c != null ? cm.RTL_AL_car_subtype__c : '', 'RTL_AL_car_type__c' => cm.RTL_AL_car_type__c != null ? cm.RTL_AL_car_type__c : '', 'RTL_AL_car_year__c' => cm.RTL_AL_car_year__c != null ? cm.RTL_AL_car_year__c : '', 'RTL_AL_installment_amount__c' => cm.RTL_AL_installment_amount__c != null ? cm.RTL_AL_installment_amount__c : null, 'RTL_AL_max_set_up_amount__c' => cm.RTL_AL_max_set_up_amount__c != null ? cm.RTL_AL_max_set_up_amount__c : null, 'RTL_AL_normal_price__c' => cm.RTL_AL_normal_price__c != null ? cm.RTL_AL_normal_price__c : null, 'RTL_Product_Name__c' => cm.RTL_Campaign_Product_1__c != null ? cm.RTL_Campaign_Product_1__r.Name != null ? cm.RTL_Campaign_Product_1__r.Name : '' : '', 'RTL_AL_car_plate_no__c' => cm.RTL_AL_car_plate_no__c != null ? cm.RTL_AL_car_plate_no__c : '', 'RTL_AL_ILA_AMT__c' => cm.RTL_AL_ILA_AMT__c != null ? cm.RTL_AL_ILA_AMT__c : null, 'RTL_AL_REMN_MTH__c' => cm.RTL_AL_REMN_MTH__c != null ? cm.RTL_AL_REMN_MTH__c : null, 'RTL_AL_OFFR_ILA_AMT__c' => cm.RTL_AL_OFFR_ILA_AMT__c != null ? cm.RTL_AL_OFFR_ILA_AMT__c : null, 'RTL_AL_OFFR_ILA_MTH__c' => cm.RTL_AL_OFFR_ILA_MTH__c != null ? cm.RTL_AL_OFFR_ILA_MTH__c : null, 'RTL_AL_promotion_detail__c' => cm.RTL_AL_promotion_detail__c != null ? cm.RTL_AL_promotion_detail__c : '', 
  //   // 'RTL_Owner_Type__c' => cm.Lead.RTL_Owner_Type__c != null ? cm.Lead.RTL_Owner_Type__c: '',
  //   //'LeadOwner' => cm.LeadOwner != null ? cm.LeadOwner : '',
  //   'RTL_Promotion__c' => cm.RTL_Promotion__c != null ? cm.RTL_Promotion__c : '', 'RTL_Remark__c' => cm.RTL_Remark__c != null ? cm.RTL_Remark__c : '', 'RTL_TMB_Cust_ID__c' => cm.RTL_TMB_Cust_ID__c != null ? cm.RTL_TMB_Cust_ID__c : '', 'RTL_AL_province_car_plate_no__c' => cm.RTL_AL_Province_Car_Plate_No__c != null ? cm.RTL_AL_Province_Car_Plate_No__c : '', 'RTL_AL_CAMP_EXP_DTE__c' => cm.RTL_AL_CAMP_EXP_DTE__c != null ? cm.RTL_AL_CAMP_EXP_DTE__c : null, 'RTL_AL_bluebook_code__c' => cm.RTL_AL_BlueBook__c != null ? cm.RTL_AL_BlueBook__r.RTL_AL_bluebook_code__c != null ? cm.RTL_AL_BlueBook__r.RTL_AL_bluebook_code__c : '' : '', 'ID' => cm.Id };
  // }

}