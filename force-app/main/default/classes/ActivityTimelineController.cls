/**
 * @description       : 
 * @author            : tnn@ii.co.th
 * @Company           : iiG
 * @last modified on  : 01-21-2021
 * @last modified by  : tnn@ii.co.th
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   05-27-2021   kns@ii.co.th   Initial Version
**/
public with sharing class ActivityTimelineController {

    public static Integer PersonalizeTimelineDays {
        get {
            if (PersonalizeTimelineDays == null) {
                PersonalizeTimelineDays = AppConfig__c.getValues('Personalize Timeline days') == null ? 30 : Integer.valueOf(AppConfig__c.getValues('Personalize Timeline days').Value__c);
            }
            return PersonalizeTimelineDays;
        }
        set;
    }

    public static String ONEAPP_API_KEY {
        get {
             if (ONEAPP_API_KEY == null) {
                ONEAPP_API_KEY = AppConfig__c.getValues('OneApp_API_Key') == null ? '' : AppConfig__c.getValues('OneApp_API_Key').Value__c;
            }
            return ONEAPP_API_KEY;
        }
        set;
    }

    public static Integer CUSTOMER_PERSONALIZE_TIMEOUT_MILLISEC{
        get{
            Integer DEFAULT_TIMEOUT = 60000;
            if(CUSTOMER_PERSONALIZE_TIMEOUT_MILLISEC == null){
                try{
                    CUSTOMER_PERSONALIZE_TIMEOUT_MILLISEC = DEFAULT_TIMEOUT;
                    List<App_Config__mdt> callMeNowTimeOut = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'CUSTOMER_PERSONALIZE_TIMEOUT_MILLISEC'];           
                        if (callMeNowTimeOut != null && callMeNowTimeOut.size() > 0) {
                            CUSTOMER_PERSONALIZE_TIMEOUT_MILLISEC = Integer.valueOf(callMeNowTimeOut.get(0).Value__c);
                        }           
                        
                    }catch( Exception e ){
                        CUSTOMER_PERSONALIZE_TIMEOUT_MILLISEC = DEFAULT_TIMEOUT;
                    }
            }
            return CUSTOMER_PERSONALIZE_TIMEOUT_MILLISEC;
            
        }set;}

    private static final String SECTION_CUST_HOLD_HIG = 'RtlCust:Customer Product Holding (High)';

    public class ActivityWrapper {
        @AuraEnabled
        public List<Case> caseList {get;set;}
        @AuraEnabled
        public List<Opportunity> opportunities {get;set;}
        @AuraEnabled
        public List<CampaignMember> campaignMembers {get;set;}
        @AuraEnabled
        public Datetime startDate {get;set;}
        @AuraEnabled
        public Datetime endDate {get;set;}
        public ActivityWrapper() {
            this.caseList = new List<Case>();
            this.opportunities = new List<Opportunity>();
            this.campaignMembers = new List<CampaignMember>();
        }
       
    }

    public class ActivitiesCountWrapper {
        @AuraEnabled
        public Decimal caseCount {get;set;}
        @AuraEnabled
        public Decimal opportunityCount  {get;set;}
        @AuraEnabled
        public Decimal campaignMemberCount {get;set;}
        @AuraEnabled
        public Integer timelineDays {get;set;}

        public ActivitiesCountWrapper () {
            this.caseCount = 0;
            this.opportunityCount = 0;
            this.campaignMemberCount = 0;
            this.timelineDays = PersonalizeTimelineDays;
        }
    }

    public class OneAppResponse {
        @AuraEnabled
        public Boolean hasError {get;set;}
        @AuraEnabled
        public String errMsg {get;set;}
        @AuraEnabled
        public List<OneAppWrapper> dataList {get;set;}
    }

    public class OneAppWrapper { 
        @AuraEnabled
        public String cardId;
        @AuraEnabled
        public Long createDate;
        @AuraEnabled
        public Datetime createDateDT;
        @AuraEnabled
        public Long expiryDate;
        @AuraEnabled
        public Datetime expiryDateDT;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public Boolean isRead;
        @AuraEnabled
        public String salesforceType;
        @AuraEnabled
        public String subTitleThVerify;
        @AuraEnabled
        public String titleTh;
        @AuraEnabled
        public String titleThVerify;  
    }

    public class TimelineFilter {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String filterName;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public Boolean isDefault;
        @AuraEnabled
        public Decimal sortNumber; 

        public TimelineFilter(String id, String filterName, String value, Boolean isDefault, Decimal sortNumber) {
            this.id = id;
            this.filterName = filterName;
            this.value = value;
            this.isDefault = isDefault;
            this.sortNumber = sortNumber;
        }
    }

    @AuraEnabled
    public static Boolean getDataAccessPermission(String recordId) {
        // Account account = [SELECT OwnerId FROM Account WHERE Id =: recordId LIMIT 1];
        // User user = [SELECT Id,ManagerId FROM User WHERE Id =: account.OwnerId];
        User currentUser = [SELECT Id,Profile.Name FROM User WHERE ID =: Userinfo.getUserID() LIMIT 1];
        // String AccessType = '';
        // AccessType = getDataSecurity(SECTION_CUST_HOLD_HIG, currentUser.Profile.Name );
        // if(AccessType == 'All')
        // {
        //     return true;
        // }
        // else if(AccessType == 'Authorize Only')
        // {
        //     return RTL_AccountUtility.verifyFieldSecurity(SECTION_CUST_HOLD_HIG, currentUser.Profile.Name, account.Id);
        // }         
        
        // return false;
        return RTL_AccountUtility.verifyFieldSecurity(SECTION_CUST_HOLD_HIG, currentUser.Profile.Name, recordId);
    }

    @AuraEnabled
    public static List<TimelineFilter> getTimelineFilter() {
        List<TimelineFilter> timelineFilters = new List<TimelineFilter>();
        List<Personalize_Timeline_Filter__mdt> filters = [SELECT Id,Filter__c,Value__c,IsDefault__c,Sort_No__c FROM Personalize_Timeline_Filter__mdt ORDER BY Sort_No__c ASC];
        for (Personalize_Timeline_Filter__mdt filter : filters) {
            timelineFilters.add(new TimelineFilter(filter.Id,filter.Filter__c,filter.Value__c,filter.IsDefault__c,filter.Sort_No__c));
        }   
        return timelineFilters;
    }

    @AuraEnabled
    public static ActivitiesCountWrapper getActivitiesCount(String accountId) {
        ActivitiesCountWrapper activitiesCount = new activitiesCountWrapper();
        activitiesCount.caseCount = [SELECT COUNT() FROM Case WHERE AccountId =: accountId];
        activitiesCount.opportunityCount = [SELECT COUNT() FROM Opportunity WHERE AccountId =: accountId];
        activitiesCount.campaignMemberCount = [SELECT COUNT() FROM CampaignMember WHERE Contact.AccountId =: accountId];
        activitiesCount.timelineDays = PersonalizeTimelineDays;
        return activitiesCount;
    }

    @AuraEnabled
    public static ActivityWrapper getActivites (
    String accountId,
    Boolean queryOpportunnity,
    Boolean queryCase,
    Boolean queryCampaignMember,
    Integer times) 
    {
        Datetime dateStart = datetime.Now();
        Datetime dateEnd = datetime.Now();
        dateStart = dateStart.addDays(-(times * Integer.valueOf(PersonalizeTimelineDays)));
        ActivityWrapper activityWrapper = new ActivityWrapper();
        activityWrapper.startDate = dateStart;
        activityWrapper.endDate = dateEnd;
        if (queryOpportunnity) {
            activityWrapper.opportunities = [SELECT 
            Id,Name,RTL_Product_Name__c,RTL_Product_Name__r.Name,toLabel(StageName),Owner.Name,
            RTL_Owner_UserName__c,Amount,RTL_Oppt_Channel__c,CreatedDate,LastModifiedDate 
            FROM Opportunity 
            WHERE AccountId =: accountId 
            AND LastModifiedDate >=: dateStart
            AND LastModifiedDate <=: dateEnd
            ORDER BY LastModifiedDate DESC];
        }

        if (queryCase) {
            activityWrapper.caseList = [SELECT 
            Id,Subject,Description,Status,Origin,CreatedDate,LastModifiedDate
            FROM Case WHERE AccountId =: accountId 
            AND LastModifiedDate >=: dateStart
            AND LastModifiedDate <=: dateEnd
            ORDER BY LastModifiedDate DESC];
        }

        if (queryCampaignMember) {
            activityWrapper.campaignMembers = 
            [SELECT Id,Name,Campaign.Name,Campaign.StartDate,Campaign.EndDate,RTL_Campaign_Channel_formula__c,
            RTL_Segmentation__c,RTL_Product_Feature__c,RTL_Product_Group_1__c,RTL_Product_Group_2__c,
            RTL_Product_Group_3__c,RTL_Product_Group_4__c,RTL_Product_Group_5__c,RTL_Sub_Group_1__c,
            RTL_Sub_Group_2__c,RTL_Sub_Group_3__c,RTL_Sub_Group_4__c,RTL_Sub_Group_5__c,
            RTL_Campaign_Product_1__r.Name,RTL_Campaign_Product_2__r.Name,RTL_Campaign_Product_3__r.Name,
            RTL_Campaign_Product_4__r.Name,RTL_Campaign_Product_5__r.Name,toLabel(RTL_OfferResult_Product_1__c),
            toLabel(RTL_OfferResult_Product_2__c),toLabel(RTL_OfferResult_Product_3__c),toLabel(RTL_OfferResult_Product_4__c),
            RTL_Product_Name__c,toLabel(RTL_OfferResult_Product_5__c),LastModifiedDate
            FROM CampaignMember WHERE Contact.AccountId =: accountId 
            AND LastModifiedDate >=: dateStart
            AND LastModifiedDate <=: dateEnd
            ORDER BY LastModifiedDate DESC];
        }

        return  activityWrapper;
    }

    public static Map<String, Object> fetchOneAppData (Account acc , String tmbCustId) {
        Account accForLog = acc;
        HttpResponse response;
        String resDecrypt;
        String bodyRequest;
        Map<String, Object> result = new Map<String, Object>();
        Uuid uuidGenerateor = new Uuid();
        String uuid = uuidGenerateor.getValue();
        Datetime startDate = Datetime.now();
        String errorMsg = '';
        Boolean isSuccess = true;
        try {
           
            //String bodyRequest = '{"crmId": "001100000000000000000006394793"}';
            bodyRequest = '{"crmId": "'+tmbCustId+'"}';
            String privateKey = SCSMessageAPIUtil.getEncryptKey(SCSMessageAPIUtil.fetchUserSessionId(), SCSMessageAPIUtil.INTEGRATE_SYSTEM.ONEAPP);      
                
            String encryptBody = SCSMessageAPIUtil.encryptMessageWithKey(bodyRequest, privateKey);
            System.debug('debug Decrypt =>' + (String)SCSMessageAPIUtil.decryptMessageWithKey(encryptBody, privateKey));
            //String bodyRequest = '{"initial_vector":"19dd026dfc6b0fe80e58e123173d27e8","encrypted_data":"3ec1cf47307dc7a9521b11b35fe0161e3725be41288d51629b3ea5b087ccb35dfdfc49ac5cd628b554b3ed58ae7bc5c5"}';
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + SmartBDM_Utility.tokenKeyEnliteGateWay);
            req.setHeader('Content-Type', 'application/json;Charset="UTF-8"');
            req.setHeader('Request-Datetime', JSON.serialize(Datetime.now()));
            req.setHeader('Request-UID', uuid);
            req.setHeader('Request-App-ID', 'A0291');
            req.setHeader('service-name', 'customers-personalize-inbox');
            req.setHeader('API-Key', ONEAPP_API_KEY);
            req.setEndpoint('callout:Customer_personalize');
            req.setBody(encryptBody);
            req.setTimeout(CUSTOMER_PERSONALIZE_TIMEOUT_MILLISEC);
            response = http.send(req);
           
            System.debug('response :: ' + response);
            if (response != null) 
            {
                if (response.getStatusCode() == 200) 
                {
                    System.debug('Status ' + response.getStatusCode() + ' ' + response.getStatus());
                    resDecrypt = (String)SCSMessageAPIUtil.decryptMessageWithKey(response.getBody(), privateKey);
                    result = resDecrypt != null ? (Map<String, Object>)JSON.deserializeUntyped(resDecrypt) : new Map<String, Object>();
                    result.put('hasError', false);
                    System.debug('response :: ' + result);
                } 
                else if (response.getStatusCode() == 408) {
                    System.debug('Status ' + response.getStatusCode() + ' ' + response.getStatus());
                    System.debug('Request timeout');
                    resDecrypt = response.getBody();
                    Map<String, Object> responseBody =  (Map<String, Object>)JSON.deserializeUntyped(resDecrypt);
                    Map<String, Object> responseStatus =  (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(responseBody.get('Status')));
                    System.debug(responseStatus);
                    errorMsg =  responseStatus.containsKey('StatusDesc') ? (String)responseStatus.get('StatusDesc') : '';
                    result.put('hasError', true);
                    result.put('errMsg', 'Request timeout.');
                    isSuccess = false;
                }
                else 
                {
                    System.debug('Status ' + response.getStatusCode() + ' ' + response.getStatus());
                    System.debug(response.getBody());
                    resDecrypt = response.getBody();
                    Map<String, Object> responseBody =  (Map<String, Object>)JSON.deserializeUntyped(resDecrypt);
                    Map<String, Object> responseStatus =  (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(responseBody.get('Status')));
                    System.debug(responseStatus);
                    errorMsg =  responseStatus.containsKey('StatusDesc') ? (String)responseStatus.get('StatusDesc') : '';
                    result.put('hasError', true);
                    result.put('errMsg', 'There was an error while getting data from one app service.');
                    isSuccess = false;
                }    
            } else {
                System.debug('No response');
            }

            RTL_CampaignUtil.saveToOnlineLog(
                isSuccess,
                acc.Name, // customerName
                errorMsg,
                uuid, // msLogId
                UserInfo.getName(),
                tmbCustId, // RMId
                '/v1.0/customers/personalize/get-inbox',
                bodyRequest, // Request Body
                resDecrypt, // Response Body
                accForLog, // Account
                startDate,
                Datetime.now() // End datetime
            );

        }
        catch(System.CalloutException e) 
        {
            System.debug('ERROR: '+ e);
    
            errorMsg = '{"message:"'+ e.getMessage()+'"}';
            isSuccess = false;
            RTL_CampaignUtil.saveToOnlineLog(
                false,
                acc.Name, // customerName
                errorMsg,
                uuid, // msLogId
                UserInfo.getName(),
                tmbCustId, // RMId
                '/v1.0/customers/personalize/get-inbox',
                bodyRequest, // Request Body
                resDecrypt, // Response Body
                accForLog, // Account
                startDate,
                Datetime.now() // End datetime
            );
            result.put('hasError', true);
            result.put('errMsg', 'Request timeout');
            System.debug('result:'+result);
            return result;

        } catch (Exception e) {
            System.debug(e.getLineNumber());
            System.debug('ERROR' + String.format('{0}\n{1}', new List<String>{
                        e.getMessage(),
                        e.getStackTraceString()
                    }));
            errorMsg = String.format('{0}\n{1}', new List<String>{
                e.getMessage(),
                e.getStackTraceString()
            });

            result.put('hasError', true);
            result.put('errMsg', errorMsg);

            RTL_CampaignUtil.saveToOnlineLog(
                false,
                acc.Name, // customerName
                errorMsg,
                uuid, // msLogId
                UserInfo.getName(),
                tmbCustId, // RMId
                '/v1.0/customers/personalize/get-inbox',
                bodyRequest, // Request Body
                resDecrypt, // Response Body
                accForLog, // Account
                startDate,
                Datetime.now() // End datetime
            );
                    
            return result;
        }
        
        // result = TestData() != null ? (Map<String, Object>)JSON.deserializeUntyped(TestData()) : new Map<String, Object>();
        return result;
    }


    @AuraEnabled
    public static OneAppResponse getOneAppData(String recordId){
        try {
            List<Account> acc = [SELECT Id, Name, TMB_Customer_ID_PE__c,Core_Banking_Suggested_Segment__c FROM Account WHERE Id =: recordId LIMIT 1];
            List<OneAppWrapper> oneAppList = new List<OneAppWrapper>();
            OneAppResponse oneAppResponse = new OneAppResponse();
            if(acc.size() > 0)
            {
                if (acc[0].TMB_Customer_ID_PE__c != null) {
                    Map<String, Object>  resultBody = fetchOneAppData(acc[0],acc[0].TMB_Customer_ID_PE__c);
                    System.debug('resultBody:'+resultBody);
                    List<Object> dataList = new List<Object>();
                    Map<String, Object> dataMap = new Map<String, Object>();
                    oneAppResponse.hasError = false;
                    oneAppResponse.errMsg = '';
                    if (resultBody.get('hasError') == true) {
                        oneAppResponse.hasError = true;
                        oneAppResponse.errMsg = resultBody.get('errMsg').toString();
                    }
                    
                    if (resultBody.containsKey('data'))
                    {
                        System.debug('resultBody data:'+resultBody.get('data'));
                        dataMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(resultBody.get('data')));
                        dataList.addAll((List<Object>)dataMap.get('before'));
                        dataList.addAll((List<Object>)dataMap.get('today'));
                    }
                    System.debug('dataList:'+dataList);
                    if (dataList.size() > 0) {
                        for(Object data : dataList)
                        {
                            //System.debug('data:'+data);  
                            OneAppWrapper oneAppWrapper = (OneAppWrapper)JSON.deserialize(JSON.serialize(data), OneAppWrapper.class);
                            oneAppWrapper.createDateDT = DateTime.newInstance(oneAppWrapper.createDate);
                            oneAppWrapper.expiryDateDT = DateTime.newInstance(oneAppWrapper.expiryDate);
                            oneAppList.add(oneAppWrapper);
                        }
                        System.debug('oneAppList:'+oneAppList);
                    }
                    oneAppResponse.dataList = oneAppList;
                }
            }
            return oneAppResponse;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' Line :' + e.getLineNumber());
        }
    }

    // public static String getDataSecurity(String section,String userProfile)
    // {
        
    //     String accessType = '';
    //     try
    //     {
    //         Data_Security_Matrix__c dsm = [SELECT Profile_Name__c, Section_Name__c, Access_Type__c 
    //                 FROM Data_Security_Matrix__c 
    //                 WHERE Profile_Name__c =:userProfile 
    //                 AND Section_Name__c = :section
    //                 LIMIT 1
    //                 ];
    //         accessType = dsm.Access_Type__c;
            
    //     }
    //     catch (Exception e)
    //     {
    //         //*** In case of not found or any error occured, set visible status to no access
    //         accessType = 'No Access';
    //     }
        
    //     return accessType;
    // }

    // public static String TestData()
    // {
    //     String testBody = '{'+
    //         '"status":{'+
    //           ' "code":"0000",'+
    //            '"message":"success",'+
    //           ' "service":"personalization-service",'+
    //            '"description":null'+
    //         '},'+
    //         '"data":{'+
    //            '"today":['+
    //               '{'+
    //                 '"id":"6163db9165b58f63b448daa0",'+
    //                  '"cardId":"MF00001",'+
    //                  '"titleTh":"คุณกำลังสนใจกองทุน TMBGOLDอยู่หรือเปล่า?",'+
    //               '"titleThVerify":"คุณกำลังสนใจกองทุน TMBGOLDอยู่หรือเปล่า?",'+
    //               '"createDate":1633934225602,'+
    //                  '"expiryDate":1634230800000,'+
    //                  '"isRead":false,'+
    //                  '"salesforceType":"campaign"'+
    //               '},'+
    //               '{'+
    //                 '"id":"6163db9165b58f63b448daa1",'+
    //                 '"cardId":"PM00001",'+
    //                 '"titleTh":"สรุปยอดบัตรแฟลชการ์ดประจำสัปดาห์ครับ",'+
    //                 '"d":"สรุปยอดบัตรแฟลชการ์ดประจำสัปดาห์ครับ",'+
    //                 '"createDate":1633934225602,'+
    //                 '"expiryDate":1634230800000,'+
    //                 '"isRead":false,'+
    //                 '"salesforceType":"campaign"'+
    //               '}'+
    //            '],'+
    //            '"before":['+
    //               '{'+
    //                  '"id":"615e79f26a07f332374b089e",'+
    //                  '"cardId":"BA00001",'+
    //                  '"titleTh":"อัปเดตความเคลือ? นไหวในบัญชียูนิตลิงค์ครับ",'+
    //               '"titleThVerify":"อัปเดตความเคลือ? นไหวในบัญชียูนิตลิงค์ครับ",'+
    //               '"createDate":1633581554773,'+
    //                  '"expiryDate":1633626000000,'+
    //                  '"isRead":true,'+
    //                  '"salesforceType":"campaign"'+
    //               '},'+
    //               '{'+
    //                  '"id":"615e79f26a07f332374b089f",'+
    //                  '"cardId":"BA00002",'+
    //                  '"titleTh":"ทุกก้าวทีเ? ดินไป คุณมีความอุ่นใจเพียงพอแล้วหรือยัง",'+
    //               '"subTitleEn":"Check out varieties of protection most suitable for you here.",'+
    //                  '"titleThVerify":"ทุกก้าวทีเ? ดินไป คุณมีความอุ่นใจเพียงพอแล้วหรือยัง",'+
    //               '"createDate":1633581554773,'+
    //                  '"expiryDate":1633366800000,'+
    //                  '"isRead":false,'+
    //                  '"salesforceType":"campaign"'+
    //               '}'+
    //            ']'+
    //         '}'+
    //      '}';
    //      return testBody;
    // }
}