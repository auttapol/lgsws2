@isTest
public class pdpaCalloutUtilTest {
    @testSetup 
    static void setup() {
        System.debug('TestSetup::');
        AppConfig__c configTriger = new AppConfig__c();
        configTriger.Name = 'runtrigger';
        configTriger.Value__c = 'true';
        insert configTriger;
        
        AppConfig__c configTimeout = new AppConfig__c();
        configTimeout.Name = 'PDPA_Timeout';
        configTimeout.Value__c = '2';
        insert configTimeout;
        
        Account acct = new Account();
        acct.First_Name_PE__c = 'เสถียรพร';
        acct.Last_Name_PE__c = 'คำดี';
        acct.First_Name_ENG_PE__c = 'SathianP';
        acct.Last_Name_PE_Eng__c = 'KD';
        acct.Name = acct.First_Name_PE__c + ' ' + acct.Last_Name_PE__c;
        acct.Email_Address_PE__c = 'satian@tmb.com';
        acct.Mobile_Number_PE__c = '0998877665';
        acct.RecordtypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
        acct.Account_Type__c = 'Retail Customer';
        acct.ID_Type_PE__c = 'Citizen ID';
        acct.ID_Number_PE__c = '4496799264466';
        acct.RTL_NID__c = '44466';
        acct.TMB_Customer_ID_PE__c = '001100000001100000000000000500';
        insert acct;
        
        PDPAMapping__c type1 = new PDPAMapping__c(Name = 'MARKET', 
                                                 Description_TH__c = 'การให้ความยินยอมในการเปิดเผยข้อมูลให้บุคคลอื่นเพื่อวัตถุประสงค์ทางการตลาด',
                                                 Description__c = 'Consent for Disclosure of Information for Marketing Purpose',
                                                 Display_Type__c = 'Market Conduct'
                                                 );
        insert type1;
        
        PDPAMapping__c type2 = new PDPAMapping__c(Name = 'PDPA-DEPOSIT', 
                                                 Description_TH__c = 'การให้ความยินยอมในการเปิดเผยข้อมูลส่วนบุคคลตามพ.ร.บ.คุ้มครองข้อมูลส่วนบุคคล',
                                                 Description__c = 'Consent for Disclosure of Personal Information',
                                                 Display_Type__c = 'PDPA'
                                                 );
        insert type2;
        
        String authorized = '{'+
            '"access_token": "eyJ0eXBlIjoiSldUIiwiYWxnIjoiUlM1MTIifQ.eyJhcGlfa2V5IjoiYWRtaW4iLCJzY29wZSI6InJlYWQgd3JpdGUiLCJleHAiOjE1NDY4NTg3MzUsInZlcnNpb24iOiIwMDEtMjAxODExMTEiLCJqdGkiOiIyYTQ4ZmEwYi0yMjEyLTRlMzItYTAzMC1mOWFlMmRkYWFlOTQifQ.HcK3lexOKd-ufV0adiIsKWfHzG34D606gFwFbABC-5QFKpUoLus_xq_DPPttpqj7VQB_cYIqaoFEI0HkD2rbTjXuhDDcbcpvkkaLO6DpGYfXi5RYgk7MQq7BPhgq_CVts4p4zUsLnae-c5s3cd5zC08qkNjOVMGlgNli1DZekCFa5vHdrXHICu7ih_CVV6QLLYnyhrN5-STSasxOaNqlZ5v69q0aADP69wyj2NL1SVdCoG8aPlm0ILSjKIM8lj9RsZ23Xs1LUlMGpYNqjhHEI2BDQazuW-VFz_lXi6q_84uM4XvU1bMV6TJxuVXLYjtpaY4Y2wBQJMICvfbIGN-mOg",'+
            '"token_type": "bearer",'+
            '"expires_in": 3600,'+
            '"scope": "read write",'+
            '"jti": "2a48fa0b-2212-4e32-a030-f9ae2ddaae94",'+
            '"client_id": "xxxxx",'+
            '"version": "001-20181111",'+
            '"isSuccess": true,'+
            '"errorMessage": "",'+
            '"requestBody": "",'+
            '"responseBody": ""'+
        '}';
        
        AuthenticationToken authenTokenCalculateTools = AuthenticationToken.parse(authorized);
        Datetime startTime = Datetime.now();
        Datetime endTime = Datetime.now();
        
        Cache.OrgPartition orgPartSmartBDMCalToolsCreateToken = Cache.Org.getPartition('local.CreateGateWayToken'); 
        orgPartSmartBDMCalToolsCreateToken.put('accesstoken', authenTokenCalculateTools.access_token, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('tokentype', authenTokenCalculateTools.token_type, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('expiresin', authenTokenCalculateTools.expires_in, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('scope', authenTokenCalculateTools.scope, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('jti', authenTokenCalculateTools.jti, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('clientid', authenTokenCalculateTools.client_id, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('version', authenTokenCalculateTools.version, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('isSuccess', authenTokenCalculateTools.isSuccess, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('errorMessage', authenTokenCalculateTools.errorMessage, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('requestBody', authenTokenCalculateTools.requestBody, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('responseBody', authenTokenCalculateTools.responseBody, Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('startTime', Datetime.now(), Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);
        orgPartSmartBDMCalToolsCreateToken.put('endtime', Datetime.now(), Smart_BDM_Constant.ttlSecs, Cache.Visibility.ALL, false);

        OnlineServiceLog onlineServiceLogGateWay = new OnlineServiceLog(authenTokenCalculateTools.isSuccess, authenTokenCalculateTools.errorMessage, authenTokenCalculateTools.requestBody, authenTokenCalculateTools.responseBody, startTime, endTime);
        orgPartSmartBDMCalToolsCreateToken.put('onlineServiceLogGateWay', onlineServiceLogGateWay.parseToJson(), authenTokenCalculateTools.expires_in, Cache.Visibility.ALL, false);
    }
    @isTest
    static void testF2FServiceToken(){
        System.debug('testF2FServiceToken');
        test.startTest();
        Account account = [SELECT id, First_Name_ENG_PE__c, Last_Name_PE_Eng__c, TMB_Customer_ID_PE__c, TMB_Employee_ID__c FROM Account WHERE TMB_Customer_ID_PE__c LIKE '001100000001100000000000000500'];
        String staffId = '001100000001100054000476500500';
        String customerId = account.TMB_Customer_ID_PE__c;
        String closeAction = 'canvasPublish(\'close\');';
        String closeActionType = 'javascript';
        String consentAction = 'maintenance';
        String pdpatype = apexpages.currentpage().getparameters().get('pdpatype');
        String consentType = pdpatype == 'Market Conduct' ? 'MARKET' : pdpatype == 'PDPA' ? 'PDPA' : '';
        String branchCode = '';
        String language = 'EN';
        String firstName = account.First_Name_ENG_PE__c;
        String lastName = account.Last_Name_PE_Eng__c;
        String idType = 'CI';
        String IdNumberEncrypt = 'XFtDk6Jw+ibuDuHIwka/Uw==';
        Test.setMock(HttpCalloutMock.class, new pdpaCalloutUtilHttpF2FServiceTokenMock());
        pdpaCalloutUtil.getPDPAF2FServiceToken(closeAction, closeActionType, consentAction, consentType, customerId, staffId, branchCode, language, 
                                               firstName, lastName, IdType, IdNumberEncrypt);
        test.stopTest();
    }
    
    @isTest
    static void testGetFagPdpa(){
        System.debug('testGetFagPdpa');
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new PDPAViewHistHttpCalloutMock());
		pdpaCalloutUtil.getFagPdpa('001100000001100000000000000500', 'PDPA_and_Market_Consent_getFlag');
        test.stopTest();
    }
    
    @isTest
    static void getExpiryDateTimeFromToken(){
        System.debug('getExpiryDateTimeFromToken');
        Cache.OrgPartition orgPartCreateToken = Cache.Org.getPartition('local.CreateGateWayToken');
        String token = (String) orgPartCreateToken.get('accesstoken');

        test.startTest();
		pdpaCalloutUtil.getExpiryDateTimeFromToken(token);
        test.stopTest();
    }
    
}