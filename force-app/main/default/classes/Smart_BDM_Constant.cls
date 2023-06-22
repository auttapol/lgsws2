public class Smart_BDM_Constant {

    public static Map<String, Smart_BDM_Constant__mdt> Smart_BDM_Constants {
        get
        {
            if (Smart_BDM_Constants == null) {
                Smart_BDM_Constants = new Map<String , Smart_BDM_Constant__mdt>();
                for (Smart_BDM_Constant__mdt con : [SELECT Id, MasterLabel, DeveloperName, Value__c FROM Smart_BDM_Constant__mdt]) {
                    Smart_BDM_Constants.put(con.DeveloperName, con);
                }
            }
            return Smart_BDM_Constants;
        }
        set;
    }
    public static final String MAX_TOTAL_REVENUS   =  Smart_BDM_Constants.containsKey('MAX_TOTAL_REVENUS') ? Smart_BDM_Constants.get('MAX_TOTAL_REVENUS').value__c :  '100000000' ;
    public static final String RED_COLOR   =  Smart_BDM_Constants.containsKey('RED_COLOR') ? Smart_BDM_Constants.get('RED_COLOR').value__c :  'red' ;
    public static final String GREEN_COLOR   =  Smart_BDM_Constants.containsKey('GREEN_COLOR') ? Smart_BDM_Constants.get('GREEN_COLOR').value__c :  'green' ;
    public static final String WHITE_COLOR   =  Smart_BDM_Constants.containsKey('WHITE_COLOR') ? Smart_BDM_Constants.get('WHITE_COLOR').value__c :  'white' ;
    public static final String CREDIT_INFO_WARNING_MESSAGE   =  Smart_BDM_Constants.containsKey('CREDIT_INFO_WARNING_MESSAGE') ? Smart_BDM_Constants.get('CREDIT_INFO_WARNING_MESSAGE').value__c :  'End O/S > Limit' ;
    public static final String TOTAL_REVENUS_WARNING_MESSAGE   =  Smart_BDM_Constants.containsKey('TOTAL_REVENUS_WARNING_MESSAGE') ? Smart_BDM_Constants.get('TOTAL_REVENUS_WARNING_MESSAGE').value__c :  'รายได้เกิน 100 ล้านบาท' ;
    public static final String TOTAL_REVENUE_EMPTY_WARNING_MESSAGE   =  Smart_BDM_Constants.containsKey('TOTAL_REVENUE_EMPTY_WARNING_MESSAGE') ? Smart_BDM_Constants.get('TOTAL_REVENUE_EMPTY_WARNING_MESSAGE').value__c :  'Total revenue is empty' ;
    public static final String BUSINESS_CODE_WARNING_MESSAGE   =  Smart_BDM_Constants.containsKey('BUSINESS_CODE_WARNING_MESSAGE') ? Smart_BDM_Constants.get('BUSINESS_CODE_WARNING_MESSAGE').value__c :  'ประเภทธุรกิจไม่ผ่านเกณฑ์ธนาคาร' ;
    public static final String SUCCESS_MESSAGE   =  Smart_BDM_Constants.containsKey('SUCCESS_MESSAGE') ? Smart_BDM_Constants.get('SUCCESS_MESSAGE').value__c :  'Pass basic pre-screen' ;
    public static final String HOST_SYSTEM   =  Smart_BDM_Constants.containsKey('HOST_SYSTEM') ? Smart_BDM_Constants.get('HOST_SYSTEM').value__c :  'SLS' ;
    public static final String DEEP_LINK_TO_KONY_TELL_LANDING   =  Smart_BDM_Constants.containsKey('DEEP_LINK_TO_KONY_TELL_LANDING') ? Smart_BDM_Constants.get('DEEP_LINK_TO_KONY_TELL_LANDING').value__c :  'tmbsmart://?action=quickCATellMeNowLandingPage' ;
    public static final String DEEP_LINK_TO_KONY_LANDING   =  Smart_BDM_Constants.containsKey('DEEP_LINK_TO_KONY_LANDING') ? Smart_BDM_Constants.get('DEEP_LINK_TO_KONY_LANDING').value__c :  'tmbsmart://?action=quickCALandingPage' ;
    public static final String DEEP_LINK_TO_KONY_CAL_TOOLS   =  Smart_BDM_Constants.containsKey('DEEP_LINK_TO_KONY_CAL_TOOLS') ? Smart_BDM_Constants.get('DEEP_LINK_TO_KONY_CAL_TOOLS').value__c :  'tmbsmart://?action=calTools' ;
    public static final String SE_CREDIT_PRODUCT_RECORDTYPE_ID_OPPTY = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SE Credit Product').getRecordTypeId();

    public static final Integer AUTHORIZATION_TIMEOUT = Smart_BDM_Constants.containsKey('AUTHORIZATION_TIMEOUT') ? Integer.valueOf(Smart_BDM_Constants.get('AUTHORIZATION_TIMEOUT').value__c) : 120000;
    public static final Integer BUSINESS_GROUP_TIMEOUT = Smart_BDM_Constants.containsKey('BUSINESS_GROUP_TIMEOUT') ? Integer.valueOf(Smart_BDM_Constants.get('BUSINESS_GROUP_TIMEOUT').value__c) : 120000;
    public static final Integer BUSINESS_TYPE_TIMEOUT = Smart_BDM_Constants.containsKey('BUSINESS_TYPE_TIMEOUT') ? Integer.valueOf(Smart_BDM_Constants.get('BUSINESS_TYPE_TIMEOUT').value__c) : 120000;
    public static final Integer WORKING_CAPITAL_TIMEOUT = Smart_BDM_Constants.containsKey('WORKING_CAPITAL_TIMEOUT') ? Integer.valueOf(Smart_BDM_Constants.get('WORKING_CAPITAL_TIMEOUT').value__c) : 120000;
    public static final String SMARTBDM_CALCULATE_TOOLS_CREATE_JWT_TOKEN = 'Create JWT Token for using TMB APIs';
    public static final String SMARTBDM_CALCULATE_TOOLS_WORK_CAPITAL = 'SmartBDM Calculate Tools Work Capital';
    public static final String SMARTBDM_CALCULATE_TOOLS_BUSINESS_TYPE = 'SmartBDM Calculate Tools Business Type (Industry list)';
    public static final String SMARTBDM_CALCULATE_TOOLS_BUSINESS_GROUP = 'SmartBDM Calculate Tools Business Group (Industry list)';

    public static final String FIlTER_TYPE_CRITERIA_BUSINESS_GROUP_TH = Smart_BDM_Constants.containsKey('FIlTER_TYPE_CRITERIA_BUSINESS_GROUP_TH') ? Smart_BDM_Constants.get('FIlTER_TYPE_CRITERIA_BUSINESS_GROUP_TH').value__c :  '-,\'\',null,N';
    
    public static final List<String> EMAIL_SENT_TO_ALERT = new List<String>{ 'CRM Admin 2' };
    public static final Integer ttlSecs = Smart_BDM_Constants.containsKey('TTL_Seconds') ? Integer.valueOf(Smart_BDM_Constants.get('TTL_Seconds').value__c) :  3600 ;
    public static final Map<String, String> SmartBDM_CalculateTools_Settings {
        get{
            if(SmartBDM_CalculateTools_Settings == null){
                SmartBDM_CalculateTools_Settings = new Map<String,String>{
                    'ENDPOINT_BUSINESS_TYPE' => 'Smart_BDM_Cal_Tools_Business_Type',
                    'ENDPOINT_BUSINESS_GROUP' => 'Smart_BDM_Cal_Tools_Business_Group',
                    'ENDPOINT_WORKING_CAPITAL' => 'Smart_BDM_Cal_Tools_Working_Capital'
                };
            }
            return SmartBDM_CalculateTools_Settings;
        }
        set;
    }

    public static final Map<Integer, String> STATUS_CODE_CONTINUATION = new Map<Integer, String>{
        2000 => 'The timeout was reached, and the server didn’t get a chance to respond.',
        2001 => 'There was a connection failure.',
        2002 => 'Exceptions occurred.',
        2003 => 'The response hasn’t arrived (which also means that the Apex asynchronous callout framework hasn’t resumed).',
        2004 => 'The response size is too large (greater than 1 MB).'
    };

    public static final Map<String, String> TOKEN_REQUEST_BODY_ENLITE = new Map<String, String> {
        'ClientName' => Smart_BDM_Constants.containsKey('ENLITE_TOKEN_CLIENT_NAME') ? Smart_BDM_Constants.get('ENLITE_TOKEN_CLIENT_NAME').value__c : '',
        'UserName' => Smart_BDM_Constants.containsKey('ENLITE_TOKEN_USER_NAME') ? Smart_BDM_Constants.get('ENLITE_TOKEN_USER_NAME').value__c : ''
    };
 
    public static final String SMARTBDM_ENLITE_TOKEN = 'SmartBDM-Enlite-GetToken';
    public static final String SMARTBDM_ENLITE_COMPANY_LIST = ' : SmartBDM-Enlite-GetCompanyList';
    public static final String SMARTBDM_ENLITE_COMPANY_DETAIL = ' : SmartBDM-Enlite-GetCompanyDetail';
    public static final String SMARTBDM_ENLITE_LANGUAGE_SEARCHING = Smart_BDM_Constants.containsKey('SMARTBDM_ENLITE_LANGUAGE_SEARCHING') ? Smart_BDM_Constants.get('SMARTBDM_ENLITE_LANGUAGE_SEARCHING').value__c : 'en';
    public static final Integer TOKEN_ENLITE_TIMEOUT = Smart_BDM_Constants.containsKey('TOKEN_ENLITE_TIMEOUT') ? Integer.valueOf(Smart_BDM_Constants.get('TOKEN_ENLITE_TIMEOUT').value__c) : 120000;
    public static final Integer CUSTOMER_LIST_TIMEOUT = Smart_BDM_Constants.containsKey('CUSTOMER_LIST_TIMEOUT') ? Integer.valueOf(Smart_BDM_Constants.get('CUSTOMER_LIST_TIMEOUT').value__c) : 120000;
    public static final Integer CUSTOMER_DETAIL_TIMEOUT = Smart_BDM_Constants.containsKey('CUSTOMER_DETAIL_TIMEOUT') ? Integer.valueOf(Smart_BDM_Constants.get('CUSTOMER_DETAIL_TIMEOUT').value__c) : 120000;
    public static final String SMARTBDM_ENLITE_UID_COMPANYDETAIL = Smart_BDM_Constants.containsKey('SMARTBDM_ENLITE_UID_COMPANYDETAIL') ? Smart_BDM_Constants.get('SMARTBDM_ENLITE_UID_COMPANYDETAIL').value__c : '';
    public static final String SMARTBDM_ENLITE_APPID_COMPANYDETAIL = Smart_BDM_Constants.containsKey('SMARTBDM_ENLITE_APPID_COMPANYDETAIL') ? Smart_BDM_Constants.get('SMARTBDM_ENLITE_APPID_COMPANYDETAIL').value__c : '';
    public static final String SMARTBDM_ENLITE_UID_COMPANYLIST = Smart_BDM_Constants.containsKey('SMARTBDM_ENLITE_UID_COMPANYLIST') ? Smart_BDM_Constants.get('SMARTBDM_ENLITE_UID_COMPANYLIST').value__c : '';
    public static final String SMARTBDM_ENLITE_APPID_COMPANYLIST = Smart_BDM_Constants.containsKey('SMARTBDM_ENLITE_APPID_COMPANYLIST') ? Smart_BDM_Constants.get('SMARTBDM_ENLITE_APPID_COMPANYLIST').value__c : '';

    public static final String TOTAL_REVENUE_KEY = Smart_BDM_Constants.containsKey('TOTAL_REVENUE_KEY') ? Smart_BDM_Constants.get('TOTAL_REVENUE_KEY').value__c : 'FS4110100';
    public static final String NET_WORTH_KEY = Smart_BDM_Constants.containsKey('NET_WORTH_KEY') ? Smart_BDM_Constants.get('NET_WORTH_KEY').value__c : 'FS3700000';
    public static final Integer LIMIT_DISPLAY_RECORD = Smart_BDM_Constants.containsKey('LIMIT_DISPLAY_RECORD') ? Integer.valueOf(Smart_BDM_Constants.get('LIMIT_DISPLAY_RECORD').value__c) : 20;
    public static final Integer LIMIT_OFFSET_RECORD = Smart_BDM_Constants.containsKey('LIMIT_OFFSET_RECORD') ? Integer.valueOf(Smart_BDM_Constants.get('LIMIT_OFFSET_RECORD').value__c) : 200;

    public static final String SMARTBDM_KM_DEEPLINK_DEPOSIT_ACCOUNT = Smart_BDM_Constants.containsKey('SMARTBDM_KM_DEEPLINK_DEPOSIT_ACCOUNT') ? Smart_BDM_Constants.get('SMARTBDM_KM_DEEPLINK_DEPOSIT_ACCOUNT').value__c : '';
    public static final String SMARTBDM_KM_DEEPLINK_S1B = Smart_BDM_Constants.containsKey('SMARTBDM_KM_DEEPLINK_S1B') ? Smart_BDM_Constants.get('SMARTBDM_KM_DEEPLINK_S1B').value__c : '';
    public static final String SMARTBDM_KM_DEEPLINK_BIZ_TOUCH = Smart_BDM_Constants.containsKey('SMARTBDM_KM_DEEPLINK_BIZ_TOUCH') ? Smart_BDM_Constants.get('SMARTBDM_KM_DEEPLINK_BIZ_TOUCH').value__c : '';
    public static final String SMARTBDM_KM_DEEPLINK_BIZ_WOW = Smart_BDM_Constants.containsKey('SMARTBDM_KM_DEEPLINK_BIZ_WOW') ? Smart_BDM_Constants.get('SMARTBDM_KM_DEEPLINK_BIZ_WOW').value__c : '';
    public static final String SMARTBDM_KM_DEEPLINK_BUSINESS_CLICK = Smart_BDM_Constants.containsKey('SMARTBDM_KM_DEEPLINK_BUSINESS_CLICK') ? Smart_BDM_Constants.get('SMARTBDM_KM_DEEPLINK_BUSINESS_CLICK').value__c : '';
    public static final String CACHE_PARTITION_NAME_1 = Smart_BDM_Constants.containsKey('CACHE_PARTITION_NAME_1') ? Smart_BDM_Constants.get('CACHE_PARTITION_NAME_1').value__c : 'CreateGateWayToken';
    public static final Integer ADD_SEC_SCHEDULER_TOKEN = Smart_BDM_Constants.containsKey('ADD_SEC_SCHEDULER_TOKEN') ? Integer.valueOf(Smart_BDM_Constants.get('ADD_SEC_SCHEDULER_TOKEN').value__c) :60;
    public static final String SMART_BDM_CAL_TOOLS_NAMED_CREDENTIALS = Smart_BDM_Constants.containsKey('SMART_BDM_CAL_TOOLS_NAMED_CREDENTIALS') ? Smart_BDM_Constants.get('SMART_BDM_CAL_TOOLS_NAMED_CREDENTIALS').value__c : 'Smart_BDM_Cal_Tools_Create_Token';
    
    public static final Integer MANAGE_TOKEN_QUEUE_INTERVAL_SEC = Smart_BDM_Constants.containsKey('MANAGE_TOKEN_QUEUE_INTERVAL_SEC') ? Integer.valueOf(Smart_BDM_Constants.get('MANAGE_TOKEN_QUEUE_INTERVAL_SEC').value__c) : 300;
}