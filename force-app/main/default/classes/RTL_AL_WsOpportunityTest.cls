@IsTest
public with sharing class RTL_AL_WsOpportunityTest {
    
    private static String encryptKey {
        get {
            return '208f6c8723b80c36fefc349575764dd14baf52d950a98c101034c403b1172b65';
        }
    }

    private static Account tempAccount { get; set;}
    private static Opportunity tempOpportunity { get; set;}

    @TestSetup
    static void makeData() {
        TestUtils.createAppConfig();
        AppConfig__c appConfig = AppConfig__c.getValues('runtrigger');
        appConfig.Value__c = 'true';
        update appConfig;

        TestUtils.prepareIntegrationMapping();
        insert new List<EIM_Map__c>{
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='LastModifiedDate',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='LastModifiedDate',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_Related_to_NBO_History__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_Related_to_NBO_History__c',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_Referral_Name__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_Referral__r.Name',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_Customer_Prospect_Mobile__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_Customer_Prospect_Mobile__c',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_CXM_MESSAGE_TYPE__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_CXM_MESSAGE_TYPE__c',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_Reason_Lost_TH__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_Reason_Lost__c',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_ID_NUMBER__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_ID_NUMBER__c',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_Reason_Lost__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_Reason_Lost__c',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='Name',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='Name',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_Customer_Segment__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_Customer_Segment__c',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_CXM_Product_Group__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_CXM_Product_Group__c',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_Priority__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_Priority__c',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='StageName',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='StageName',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_Status__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_Status__c',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='Created_By_Emp_ID__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='CreatedBy.Employee_ID__c',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='CloseDate',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='CloseDate',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='LastModifiedBy',Job_Type__c='ployee_ID__c',SF_Field__c='OPPTY_TO_CXM","LastModifiedBy.Employee_ID__c',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_ID_TYPE__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_ID_TYPE__c',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_Prod_SubGrp__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_Prod_SubGrp__c',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='CreatedDate',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='CreatedDate',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_Product_Name__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_Product_Name__c',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_TMB_Customer_ID_PE__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_TMB_Customer_ID_PE__c',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_Owner_Employee_ID__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_Owner_Employee_ID__c',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_RecordType_DevName__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_RecordType_DevName__c',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='Id',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='Id',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_Product_Group__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_Product_Group__c',Node__c='DataNode',Object__c='Opportunity'),
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_External_Ref_ID__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_External_Ref_ID__c',Node__c='DataNode',Object__c='Opportunity')
        };

        tempAccount = new Account(
            Name = 'First_name_PE__c Last_name_PE__c',
            Email_Address_PE__c = 'test@test.com.al',
            First_name_PE__c = 'First_name_PE__c',
            Last_name_PE__c = 'Last_name_PE__c',
            ID_Type_PE__c = 'Alien ID',
            ID_Number_PE__c = '111111222222',
            Mobile_Number_PE__c = 'Mobile_Number_PE__c',
            TMB_Customer_ID_PE__c = '001100000000000000000014144927',
            Primary_Address_Line_2_PE__c = 'Primary_Address_Line_2_PE__c',
            Primary_Address_Line_3_PE__c = 'Primary_Address_Line_3_PE__c',
            Zip_Code_Primary_PE__c = '00000',
            Province_Primary_PE__c = 'Province_Primary_PE__c',
            RecordTypeId = Account.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Retail_Prospect').getRecordTypeId()
        );
        insert tempAccount;
        tempOpportunity = new Opportunity(
            AccountId = tempAccount.Id,
            StageName = 'App In',
            RTL_Actual_Amount__c = 12353,
            RTL_AL_available_time__c = null,
            RTL_AL_car_bought_from__c = null,
            RTL_AL_car_brand__c = null,
            RTL_AL_car_gear__c = null,
            RTL_AL_car_group__c = null,
            RTL_AL_car_subtype__c = null,
            RTL_AL_car_type__c = null,
            RTL_AL_car_year__c = null,
            RTL_AL_contact_channel__c = null,
            RTL_AL_installment_amount__c = 0.00,
            RTL_AL_installment_periods__c = '0',
            RTL_AL_max_set_up_amount__c = 0.00,
            RTL_AL_normal_price__c = 0.00,
            RTL_AL_wanted_amount__c = 0.00,
            RTL_Product_Name__c = null,
            LeadSource = 'WEB',
            RTL_Campaign_Lead_Source__c = null,
            RTL_AL_oa_ref_code__c = null,
            Corebank_Emp_Id__c = null,
            RTL_Status__c = null,
            CloseDate = Date.valueOf(Datetime.now()),
            RTL_AL_PayPerMonth__c = 12000,
            RTL_AL_DownPercent__c = 1.2,
            RTL_AL_DownAmt__c = 1234,
            RTL_AL_CarBooked__c = false,
            RTL_AL_Showroom__c = null,
            RTL_AL_TentName__c = null,
            RecordTypeId = Opportunity.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Retail_Auto_Loan').getRecordTypeId()
        );
        insert tempOpportunity;

        
        RTL_product_master__c prod = new RTL_product_master__c();
        prod.Name = 'CYC';
        prod.Product_Group__c = 'Auto Loan';
        prod.Product_Sub_group__c = 'AL PERSONAL LOAN';
        prod.Active__c = true;
        insert prod;

        RTL_Contact_Address__c adds = new RTL_Contact_Address__c();
        adds.IsActive__c = true;
        adds.RTL_Province__c = 'กรุงเทพมหานคร';
        adds.RTL_District__c = 'เขตพระนคร';
        adds.RTL_Sub_District__c = 'พระบรมมหาราชวัง';
        adds.RTL_Zipcode__c = '50000';
        insert adds;

        Branch_and_Zone__c branch = new Branch_and_Zone__c();
        branch.Name = 'AL Marketing';
        branch.IsActive__c = true;
        insert branch;

        // RTL_Referral__c ref1 = new RTL_Referral__c();
        // ref1.RTL_Account_Name__c = tempAccount.Id;
        // ref1.RTL_FirstName__c = 'Fname002';
        // ref1.RTL_LastName__c = 'Lname001';
        // ref1.RTL_Mobile1__c = '0951234560';
        // ref1.RTL_Product_Name__c = prod.Id;
        // ref1.RTL_Contact_Address__c = [SELECT Id,Name FROM  RTL_Contact_Address__c WHERE IsActive__c = TRUE LIMIT 1].Id;
        // ref1.RTL_Stage__c = 'New';
        // ref1.RTL_Preferred_Branch__c = [SELECT Id,Name FROM  Branch_and_Zone__c WHERE Name = 'AL Marketing' LIMIT 1].Id;
        // ref1.RTL_AL_contact_channel__c = 'DS';
        // ref1.RecordTypeId = RTL_Referral__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Retail_Cross_Channel_Referral').getRecordTypeId();
        // insert ref1;
        
        Id recordTypeId  = [select Id from RecordType where SobjectType = 'Campaign' and DeveloperName=: 'Dummy_Campaign' and IsActive=true ].Id;
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = Recordtypeid;
        insert camp;

        Lead l = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
        l.RTL_Branch_Code_Rpt__c = '611';
        insert l;
        
        Campaignmember cm = new Campaignmember();
        cm.RTL_Marketing_Code__c = 'DOUTBOUND1HN00001023';
        cm.RTL_AL_response__c = true;
        cm.Customer__c = null;
        cm.RTL_AL_Response_Flage__c = true;
        cm.RTL_Is_Send_To_HPAP__c = true;
        cm.RTL_Is_Interface_Success__c = true;
        cm.CampaignId = camp.Id;
        cm.LeadId = l.Id;
        insert cm;

        RTL_Referral__c ref = new RTL_Referral__c();
        ref.RTL_Account_Name__c = tempAccount.Id;
        ref.RTL_FirstName__c = 'Fname001';
        ref.RTL_LastName__c = 'Lname001';
        ref.RTL_Mobile1__c = '0951234560';
        ref.RTL_Product_Name__c = prod.Id;
        ref.RTL_Contact_Address__c = adds.Id;
        ref.RTL_Stage__c = 'New';
        ref.RTL_Preferred_Branch__c = branch.Id;
        ref.RTL_AL_contact_channel__c = 'DS';
        ref.RTL_Campaign_Member__c = cm.id;
        ref.RecordTypeId = RTL_Referral__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Retail_Cross_Channel_Referral').getRecordTypeId();
        insert ref;

        Opportunity refOpportunity = new Opportunity(
            AccountId = tempAccount.Id,
            StageName = 'App In',
            RTL_Product_Name__c = prod.Id,
            RTL_Referral__c = ref.Id,
            CloseDate = Date.valueOf(Datetime.now()),
            RecordTypeId = Opportunity.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Retail_Auto_Loan').getRecordTypeId()
        );
        insert refOpportunity;
        
        Cross_Sell_Product__c csp = new Cross_Sell_Product__c(
        CampaignMemberId__c = cm.id,
        Campaign_Product__c = prod.id,
        RTL_OfferResult_Product__c = 'Referred',
        Product_Group__c = 'Auto Loan',
        RTL_Sub_Group__c = 'AL PERSONAL LOAN',
        OpportunityId__c = null
        );
        insert csp;
    }

    @IsTest
    static void testUpdateReferStatus(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        tempOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        System.runAs(sfextapi){
            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Opportunity/';
            request.httpMethod = 'PATCH';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object> {
                    'Id' => tempOpportunity.Id,
                    'RTL_AL_car_plate_no__c' => 'RTL_AL_car_plate_no__c',
                    'RTL_AL_car_type__c' => 'RTL_AL_car_type__c',
                    'RTL_AL_car_brand__c' => 'RTL_AL_car_brand__c',
                    'RTL_AL_car_group__c' => 'RTL_AL_car_group__c',
                    'RTL_AL_car_subtype__c' => 'RTL_AL_car_subtype__c',
                    'RTL_AL_car_year__c' => 'RTL_AL_car_year__c',
                    'RTL_AL_car_gear__c' => 'RTL_AL_car_gear__c',
                    'RTL_AL_CarBooked__c' => 'RTL_AL_CarBooked__c',
                    'RTL_AL_Showroom__c' => 'RTL_AL_Showroom__c',
                    'RTL_AL_car_bought_from__c' => 'RTL_AL_car_bought_from__c',
                    'RTL_AL_TentName__c' => 'RTL_AL_TentName__c',
                    'RTL_AL_max_set_up_amount__c' => 6999,
                    'RTL_AL_normal_price__c' => 123636,
                    'RTL_AL_DownPercent__c' => 1.25,
                    'RTL_AL_DownAmt__c' => 12666,
                    'RTL_AL_installment_amount__c' => 123,
                    'RTL_AL_installment_periods__c' => '12',
                    'RTL_AL_available_time__c' => 'RTL_AL_available_time__c',
                    'RTL_AL_contact_channel__c' => 'RTL_AL_contact_channel__c',
                    'RTL_AL_PayPerMonth__c' => 12000,
                    'RTL_AL_Refer_No__c' => 'RTL_AL_Refer_No__c',
                    'RTL_AL_Req_No1__c' => 'RTL_AL_Req_No1__c',
                    'RTL_AL_Req_No2__c' => 'RTL_AL_Req_No2__c',
                    'RTL_AL_wanted_amount__c' => 0.00,
                    'RTL_Status__c' => 'ปฏิเสธการให้สินเชื่อ',
                    'StageName' => 'Closed Lost',
                    'RTL_Reason_Lost__c' => 'ไม่ผ่านเกณฑ์',
                    'RTL_Actual_Amount__c' => 12355
                 }
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            
            RTL_AL_WebserviceAbstract.SCSReqRes responseEncrypt = RTL_AL_WsOpportunity.httpPatchWebservice();
        }
        Test.stopTest();
    }
    @IsTest
    static void testExceptionUpdateReferStatus(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Opportunity/';
            request.httpMethod = 'PATCH';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{}
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes responseEncrypt = RTL_AL_WsOpportunity.httpPatchWebservice();
        }
        Test.stopTest();
    }

    @IsTest
    static void testCreateAccountAndOpporunityHPAP(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            RTL_AL_WsOpportunity webserviceClass = new RTL_AL_WsOpportunity();

            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Opportunity/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'RTL_AL_available_time__c' => '9:00 - 12:00 น.',
                    'RTL_Branch_Name__c' => null,
                    'RTL_AL_car_bought_from__c' => null,
                    'RTL_AL_car_brand__c' => null,
                    'RTL_AL_car_gear__c' => null,
                    'RTL_AL_car_group__c' => null,
                    'RTL_AL_car_subtype__c' => null,
                    'RTL_AL_car_type__c' => null,
                    'RTL_AL_car_year__c' => null,
                    'RTL_AL_contact_channel__c' => null,
                    'RTL_AL_installment_amount__c' =>null,
                    'RTL_AL_installment_periods__c' =>null,
                    'RTL_AL_max_set_up_amount__c' =>null,
                    'RTL_AL_normal_price__c' =>null,
                    'RTL_AL_wanted_amount__c' =>null,
                    'RTL_Product_Name__c' => 'CYC',
                    'LeadSource' => 'WEB',
                    'RTL_Campaign_Lead_Source__c' => null,
                    'RTL_Customer_Segment__c' => null,
                    'RTL_Contact_Method__c' => null,
                    'RTL_AL_oa_ref_code__c' => null,
                    'RTL_Status__c' => null,
                    'CloseDate' => Datetime.now(),
                    'RTL_AL_PayPerMonth__c' => null,
                    'RTL_AL_DownPercent__c' => null,
                    'RTL_AL_DownAmt__c' => null,
                    'RTL_AL_CarBooked__c' => null,
                    'RTL_AL_Showroom__c' => null,
                    'RTL_AL_TentName__c' => null,
                    'Corebank_Emp_Id__c' => null,
                    'StageName' => 'App In',
                    'RecordTypeId' => Opportunity.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Retail_Auto_Loan').getRecordTypeId(),
                    'RTL_External_Ref_ID__c' => [SELECT Id FROM RTL_Referral__c LIMIT 1].Id,
                    'Account' => new Map<String, Object>{
                        'Email_Address_PE__c' => 'test@test.com.al',
                        'First_name_PE__c' => 'Test Autoloan 001',
                        'Last_name_PE__c' => 'HPAP',
                        'ID_Type_PE__c' => 'Alien ID',
                        'ID_Number_PE__c' => '111111222222',
                        'Mobile_Number_PE__c' => '0909830944',
                        'TMB_Customer_ID_PE__c'  => '001100000000000000000014144927'.removeEnd('7'),
                        'Primary_Address_Line_2_PE__c' => '',
                        'Primary_Address_Line_3_PE__c' => '',
                        'Zip_Code_Primary_PE__c' => '',
                        'Province_Primary_PE__c' => ''
                    }
                }
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes responseEncrypt = RTL_AL_WsOpportunity.httpPostWebservice();
        }
        Test.stopTest();
    }

    @IsTest
    static void testFindAccountAndCreateOpporunityHPAP(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Opportunity/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'RTL_AL_available_time__c' => '9:00 - 12:00 น.',
                    'RTL_Branch_Name__c' => null,
                    'RTL_AL_car_bought_from__c' => null,
                    'RTL_AL_car_brand__c' => null,
                    'RTL_AL_car_gear__c' => null,
                    'RTL_AL_car_group__c' => null,
                    'RTL_AL_car_subtype__c' => null,
                    'RTL_AL_car_type__c' => null,
                    'RTL_AL_car_year__c' => null,
                    'RTL_AL_contact_channel__c' => null,
                    'RTL_AL_installment_amount__c' =>null,
                    'RTL_AL_installment_periods__c' =>null,
                    'RTL_AL_max_set_up_amount__c' =>null,
                    'RTL_AL_normal_price__c' =>null,
                    'RTL_AL_wanted_amount__c' =>null,
                    'RTL_Product_Name__c' => 'CYC',
                    'LeadSource' => 'WEB',
                    'RTL_Campaign_Lead_Source__c' => null,
                    'RTL_Customer_Segment__c' => null,
                    'RTL_Contact_Method__c' => null,
                    'RTL_AL_oa_ref_code__c' => null,
                    'RTL_Status__c' => null,
                    'CloseDate' => Datetime.now(),
                    'RTL_AL_PayPerMonth__c' => null,
                    'RTL_AL_DownPercent__c' => null,
                    'RTL_AL_DownAmt__c' => null,
                    'RTL_AL_CarBooked__c' => null,
                    'RTL_AL_Showroom__c' => null,
                    'RTL_AL_TentName__c' => null,
                    'Corebank_Emp_Id__c' => null,
                    'StageName' => 'App In',
                    'RecordTypeId' => Opportunity.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Retail_Auto_Loan').getRecordTypeId(),
                    'RTL_External_Ref_ID__c' => 'DOUTBOUND1HN00001023',
                    'Account' => new Map<String, Object>{
                        'Email_Address_PE__c' => 'test@test.com.al',
                        'First_name_PE__c' => 'Test Autoloan 001',
                        'Last_name_PE__c' => 'HPAP',
                        'ID_Type_PE__c' => 'Alien ID',
                        'ID_Number_PE__c' => '111111222222',
                        'Mobile_Number_PE__c' => '0909830944',
                        'TMB_Customer_ID_PE__c'  => '001100000000000000000014144927'.removeEnd('7'),
                        'Primary_Address_Line_2_PE__c' => '',
                        'Primary_Address_Line_3_PE__c' => '',
                        'Zip_Code_Primary_PE__c' => '',
                        'Province_Primary_PE__c' => ''
                    }
                }
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            Test.setFixedSearchResults(new Id[] { 
                [SELECT Id FROM Account LIMIT 1].Id
            });
            RTL_AL_WebserviceAbstract.SCSReqRes response = RTL_AL_WsOpportunity.httpPostWebservice();
        }
        Test.stopTest();
    }
    @IsTest
    static void testRequiredFieldHPAP(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Opportunity/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'Account' => new Map<String, Object>{
                        'Email_Address_PE__c' => '',
                        'First_name_PE__c' => '',
                        'Last_name_PE__c' => '',
                        'ID_Type_PE__c' => '',
                        'ID_Number_PE__c' => '',
                        'Mobile_Number_PE__c' => '',
                        'TMB_Customer_ID_PE__c'  => '',
                        'Primary_Address_Line_2_PE__c' => '',
                        'Primary_Address_Line_3_PE__c' => '',
                        'Zip_Code_Primary_PE__c' => '',
                        'Province_Primary_PE__c' => ''
                    }
                }
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes response = RTL_AL_WsOpportunity.httpPostWebservice();
        }
        Test.stopTest();
    }
    @IsTest
    static void testExceptionHPAP(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Opportunity/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{}
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes response = RTL_AL_WsOpportunity.httpPostWebservice();
        }
        Test.stopTest();
    }
    // @IsTest
    // static void testDMLExceptionHPAP(){
    //     Test.startTest();
    //     User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
    //     System.runAs(sfextapi){
    //         RestRequest request = new RestRequest();
    //         request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Opportunity/';
    //         request.httpMethod = 'POST';
    //         request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
    //             new Map<String, Object>{
    //                 'Id' => 'adflasdflasjffasdlk'
    //             }
    //         ), encryptKey)));
    //         RestContext.request = request;
    //         Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
    //         RTL_AL_WebserviceAbstract.SCSReqRes response = RTL_AL_WsOpportunity.httpPostWebservice();
    //     }
    //     Test.stopTest();
    // }
    @IsTest
    static void testStampReferToCampaignMember(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        RTL_Referral__c ref = [SELECT Id FROM RTL_Referral__c LIMIT 1];            
        RTL_Contact_Address__c contactAd = [SELECT Id,Name FROM  RTL_Contact_Address__c WHERE IsActive__c = TRUE LIMIT 1];
        RTL_product_master__c prod = [SELECT Id,Name FROM RTL_product_master__c WHERE Name = 'CYC' AND Product_Group__c = 'Auto Loan' LIMIT 1];
        Branch_and_Zone__c pb = [SELECT Id,Name FROM  Branch_and_Zone__c WHERE Name = 'AL Marketing' LIMIT 1];
        System.runAs(sfextapi){

            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Opportunity/';
            request.httpMethod = 'PATCH';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'Id' => ref.Id,
                    'RTL_FirstName__c' => 'Fname001',
                    'RTL_LastName__c' => 'Lname001',
                    'RTL_Mobile1__c' => '0951234560',
                    'RTL_Product_Name__c' => prod.id,
                    'RTL_Contact_Address__c' => contactAd.Id,
                    'RTL_Stage__c' => 'New',
                    'RTL_Preferred_Branch__c' => pb.Id,
                    'RTL_AL_contact_channel__c' => 'DS',
                    'StageName' => 'Closed Lost',
                    'RecordTypeId' => RTL_Referral__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Retail_Cross_Channel_Referral').getRecordTypeId()
                }
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes response = RTL_AL_WsOpportunity.httpPatchWebservice();
        }
        Test.stopTest();
    }

    @IsTest
    static void testUpdateCampaignMember(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        Campaignmember cm = [SELECT Id FROM Campaignmember LIMIT 1];
        System.runAs(sfextapi){
            Lead l = [SELECT Id FROM Lead LIMIT 1];
            Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
            Branch_and_Zone__c pb = [SELECT Id,Name FROM  Branch_and_Zone__c WHERE Name = 'AL Marketing' LIMIT 1];
            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Opportunity/';
            request.httpMethod = 'PATCH';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'Id' => cm.Id,
                    'RTL_Marketing_Code__c' => 'DOUTBOUND1HN00001023',
                    'RTL_AL_response__c' => true,
                    'Customer__c' => null,
                    'RTL_AL_Response_Flage__c' => true,
                    'RTL_Is_Send_To_HPAP__c' => true,
                    'RTL_Is_Interface_Success__c' => true,
                    'CampaignId' => camp.Id,
                    'StageName' => 'Closed Lost',
                    'LeadId' => l.Id
                }
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes response = RTL_AL_WsOpportunity.httpPatchWebservice();
        }
        Test.stopTest();
    }
    @IsTest
    static void testElseUpdateCampaignMember(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        Account ac = [SELECT Id FROM Account LIMIT 1];
        System.runAs(sfextapi){
            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Opportunity/';
            request.httpMethod = 'PATCH';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'Id' => 'DOUTBOUND1HN00001024',
                    'StageName' => 'Closed Lost'
                }
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes response = RTL_AL_WsOpportunity.httpPatchWebservice();
        }
        Test.stopTest();
    }
    @IsTest
    static void testDMLExceptionUpdateCampaignMember(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        Account ac = [SELECT Id FROM Account LIMIT 1];
        System.runAs(sfextapi){
            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Opportunity/';
            request.httpMethod = 'PATCH';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'Id' => 'DOUTBOUND1HN00001023',
                    'StageName' => 'Closed Lost',
                    'RTL_AL_response__c' => false
                }
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes response = RTL_AL_WsOpportunity.httpPatchWebservice();
        }
        Test.stopTest();
    }

    @IsTest
    static void testStampOpptyToCampaignMember(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        tempOpportunity = [SELECT Id FROM Opportunity WHERE RTL_Referral__c!= NULL LIMIT 1];
        RTL_product_master__c pn = [SELECT Id,Name FROM RTL_product_master__c LIMIT 1];
        RTL_Referral__c ref = [SELECT Id FROM RTL_Referral__c LIMIT 1];            
        System.runAs(sfextapi){
            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Opportunity/';
            request.httpMethod = 'PATCH';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object> {
                    'Id' => tempOpportunity.Id,
                    'StageName' => 'Closed Lost',
                    'RTL_Reason_Lost__c' => 'ไม่ผ่านเกณฑ์',
                    'RTL_Referral__c' => ref.Id,
                    'RTL_Product_Name__c' => pn.Id
                 }
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            
            RTL_AL_WebserviceAbstract.SCSReqRes responseEncrypt = RTL_AL_WsOpportunity.httpPatchWebservice();
        }
        Test.stopTest();
    }

    @IsTest
    static void testDMLExceptionStampOpptyToCampaignMember(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        tempOpportunity = [SELECT Id FROM Opportunity WHERE RTL_Referral__c!= NULL LIMIT 1];
        RTL_product_master__c pn = [SELECT Id,Name FROM RTL_product_master__c LIMIT 1];
        RTL_Referral__c ref = [SELECT Id FROM RTL_Referral__c LIMIT 1];            
        System.runAs(sfextapi){
            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Opportunity/';
            request.httpMethod = 'PATCH';
            request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object> {
                    'Id' => tempOpportunity.Id,
                    'StageName' => 'Closed Lost',
                    'RTL_Referral__c' => ref.Id,
                    'RTL_Product_Name__c' => pn.Id
                 }
            ), encryptKey)));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            
            RTL_AL_WebserviceAbstract.SCSReqRes responseEncrypt = RTL_AL_WsOpportunity.httpPatchWebservice();
        }
        Test.stopTest();
    }

    // @IsTest
    // static void testDMLExceptionhttpPostWebservice(){
    //     Test.startTest();
    //     User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
    //     tempOpportunity = [SELECT Id FROM Opportunity WHERE RTL_Referral__c!= NULL LIMIT 1];
    //     RTL_product_master__c pn = [SELECT Id,Name FROM RTL_product_master__c LIMIT 1];
    //     RTL_Referral__c ref = [SELECT Id FROM RTL_Referral__c LIMIT 1];            
    //     System.runAs(sfextapi){
    //         RestRequest request = new RestRequest();
    //         request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Opportunity/';
    //         request.httpMethod = 'POST';
    //         request.requestBody = Blob.valueOf(String.valueOf(SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
    //             new Map<String, Object> {
    //                 'Id' => tempOpportunity.Id,
    //                 'StageName' => 'LLLLLLLLLL',
    //                 'RTL_Referral__c' => ref.Id,
    //                 'RTL_Product_Name__c' => pn.Id
    //              }
    //         ), encryptKey)));
    //         RestContext.request = request;
    //         Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            
    //         RTL_AL_WebserviceAbstract.SCSReqRes responseEncrypt = RTL_AL_WsOpportunity.httpPostWebservice();
    //     }
    //     Test.stopTest();
    // }
}