public with sharing class RTL_TMBProtectionAPIOneApp extends AbstractCoreClass {
  private static Integer TIMEOUT {
    get {
      if (TIMEOUT == null) {
        String value = [
          SELECT Id, DeveloperName, Value__c
          FROM App_Config__mdt
          WHERE DeveloperName = 'ProductHolding_TIMEOUT_INT_SECS'
        ]
        ?.Value__c;
        TIMEOUT = value == null ? 120000 : Integer.valueOf(value) * 1000;
      }
      return TIMEOUT;
    }
    set;
  }
  private static String API_KEY {
    get {
      if (API_KEY == null) {
        API_KEY = [
          SELECT Value__c
          FROM App_Config__mdt
          WHERE DeveloperName = 'TMB_Protection_API_Key'
        ]
        ?.Value__c;
      }
      return API_KEY;
    }
    set;
  }

  @AuraEnabled(continuation=true)
  public static Object calloutPopupBAViewTMBProtection(String tmb_cust_id) {
    Datetime startDate = Datetime.now();

    if (String.isEmpty(tmb_cust_id)) {
      return new Map<String, Object>{
        'success' => false,
        'message' => System.Label.TMB_CUST_ID_Required,
        'statusdesc' => System.Label.TMB_CUST_ID_Required
      };
    }

    try {
      User selfuserinfo = [
        SELECT Id, Name, Employee_ID__c, LanguageLocaleKey
        FROM User
        WHERE Id = :UserInfo.getUserId()
      ];

      Uuid uuidGenerateor = new Uuid();
      String uuid = uuidGenerateor.getValue();

      String bodyRequest = JSON.serialize(
        new Map<String, String>{
          'rmId' => tmb_cust_id?.right(14),
          'documentType' => '',
          'documentId' => '',
          'channel' => 'sf', // default value => 'sf'
          'customerType' => '',
          'state' => '',
          'productGroup' => '',
          'requestId' => uuid, // auto generate callback service
          'language' => selfuserinfo.LanguageLocaleKey == 'th' ? 'TH' : 'EN',
          'staffId' => selfuserinfo?.Employee_ID__c,
          'page' => ''
        }
      );

      String privateKey = (String) SCSMessageAPIUtil.getEncryptKey(
        SCSMessageAPIUtil.fetchUserSessionId(),
        SCSMessageAPIUtil.INTEGRATE_SYSTEM.Protection
      );
      String bodyEncrypt = String.isNotEmpty(privateKey)
        ? (String) SCSMessageAPIUtil.encryptMessageWithKey(
            bodyRequest,
            privateKey
          )
        : bodyRequest;

      HttpRequest req = new HttpRequest();
      req.setMethod('POST');
      req.setHeader('Authorization', 'Bearer ' + API_KEY);
      req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
      req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
      req.setHeader('Request-UID', uuid);
      req.setEndpoint('callout:BA_Web_View');
      req.setBody(bodyEncrypt);
      req.setTimeout(TIMEOUT);

      Continuation con = new Continuation(
        TIMEOUT / 1000 != 0 ? TIMEOUT / 1000 : 1
      );
      con.state = new Map<String, Object>{
        'Authorization' => req.getHeader('Authorization'),
        'Endpoint' => req.getEndpoint(),
        'Request-UID' => req.getHeader('Request-UID'),
        'Request-Datetime' => startDate,
        'Request-Body' => bodyRequest,
        'PrivateKey' => privateKey,
        'RMId' => tmb_cust_id
      };
      con.continuationMethod = 'callbackPopUPBAViewTMBProtection';
      con.addHttpRequest(req);
      return con;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Object callbackPopUPBAViewTMBProtection(
    List<String> labels,
    Object state
  ) {
    HttpResponse res = Continuation.getResponse((String) labels.get(0));

    String uuid = (String) getResult('Request-UID', state);
    String startDatime = (String) getResult('Request-Datetime', state);
    String requestBody = (String) getResult('Request-Body', state);
    String privateKey = (String) getResult('PrivateKey', state);
    String endpoint = (String) getResult('Endpoint', state);
    String RMId = (String) getResult('RMId', state);

    String urlEndpoint = [
      SELECT Endpoint, DeveloperName
      FROM NamedCredential
      WHERE DeveloperName = :endpoint.remove('callout:')
    ]
    ?.Endpoint;

    Account account = [
      SELECT Id, Name, TMB_Customer_ID_PE__c, Core_Banking_Suggested_Segment__c
      FROM Account
      WHERE TMB_Customer_ID_PE__c = :RMId
      LIMIT 1
    ];

    Map<String, Object> result = new Map<String, Object>();
    String dataDecrypt;
    try {
      if (String.isNotEmpty(res.getBody())) {
        dataDecrypt = String.isNotEmpty(privateKey)
          ? (String) SCSMessageAPIUtil.decryptMessageWithKey(
              res.getBody(),
              privateKey
            )
          : res.getBody();
        result = dataDecrypt != null
          ? (Map<String, Object>) JSON.deserializeUntyped(dataDecrypt)
          : result;
      }

      Boolean isSuccess = String.isNotEmpty(res.getBody()) &&
        dataDecrypt != null
        ? getValuesWithRegex(
            AbstractCoreClass.serializePrettyString(dataDecrypt),
            new List<String>{ 'Code', 'code' }
          ) == 'SUCCESS'
        : false;
      Boolean isError =
        String.isEmpty(res.getBody()) ||
        dataDecrypt == null ||
        getValuesWithRegex(
          AbstractCoreClass.serializePrettyString(dataDecrypt),
          new List<String>{ 'Code', 'code' }
        ) != 'SUCCESS';
      String errorMsg = String.isNotEmpty(dataDecrypt) && dataDecrypt != null
        ? getValuesWithRegex(
            AbstractCoreClass.serializePrettyString(dataDecrypt),
            new List<String>{ 'errors', 'title', 'Message', 'message' }
          )
        : RTL_CampaignUtil.HTTP_RESPONSE_STATUS_CODE.get(res.getStatusCode());

      RTL_CampaignUtil.saveToOnlineLog(
        isSuccess,
        account?.Name, // customerName
        errorMsg, // Error message
        result.containsKey('requestId')
          ? (String) result.get('requestId')
          : uuid, // msLogId
        UserInfo.getName(),
        RMId, // RMId
        urlEndpoint,
        AbstractCoreClass.serializePrettyString(requestBody), // Request Body
        !result.isEmpty()
          ? JSON.serializePretty(result)
          : res.getBody(), // Response Body
        account, // Account
        Datetime.valueofGmt(
          startDatime.trim().replace('T', ' ').replace('Z', '')
        ),
        Datetime.now() // End datetime
      );

      if (isError) {
        return new Map<String, Object>{
          'success' => isSuccess,
          'message' => errorMsg,
          'statuscode' => res.getStatusCode(),
          'statusdesc' => String.isEmpty(res.getBody())
            ? System.Label.ERR001_ProductHoldingV3
            : System.Label.ERR001_ProductHolding
        };
      }
      return result;
    } catch (Exception e) {
      RTL_CampaignUtil.saveToOnlineLog(
        false,
        account?.Name, // customerName
        e.getMessage(), // Error message
        uuid, // msLogId
        UserInfo.getName(),
        RMId, // RMId
        urlEndpoint,
        AbstractCoreClass.serializePrettyString(requestBody), // Request Body
        result != null && !result.isEmpty()
          ? JSON.serializePretty(result)
          : res?.getBody(), // Response Body
        account, // Account
        Datetime.valueofGmt(
          startDatime.trim().replace('T', ' ').replace('Z', '')
        ),
        Datetime.now() // End datetime
      );
      return new Map<String, Object>{
        'success' => false,
        'message' => e.getStackTraceString(),
        'statuscode' => 500,
        'statusdesc' => System.Label.ERR001_ProductHolding
      };
    }
  }
}