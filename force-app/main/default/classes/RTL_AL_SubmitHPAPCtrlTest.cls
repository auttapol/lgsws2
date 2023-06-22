@IsTest
public with sharing class RTL_AL_SubmitHPAPCtrlTest {
    private static String encryptKey {
        get {
            return '208f6c8723b80c36fefc349575764dd14baf52d950a98c101034c403b1172b65';
        }
    }
    private static Account tempAccount { get; set;}
    private static Opportunity tempOpportunity { get; set;}

    @TestSetup
    static void makeData(){
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
            new EIM_Map__c(IsActive__c=true,Field_Type__c='Request',External_Field__c='RTL_Product_Group__c',Job_Type__c='OPPTY_TO_CXM',SF_Field__c='RTL_Product_Group__c',Node__c='DataNode',Object__c='Opportunity')
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

        User contextuser = [SELECT Id FROM User WHERE Profile.Name = 'TMB Retail Mktg Campaign Mgmt' AND IsActive = true LIMIT 1];
        tempOpportunity = new Opportunity(
            OwnerId = contextuser.Id,
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

        Account acc = new Account();
        acc.Name = 'Test';
        acc.ID_Type_PE__c = 'Citizen ID';
        acc.ID_Number_PE__c = '7931087047594';
        acc.First_name_PE__c = 'Commercial Customer 000001';
        acc.Last_name_PE__c = 'Commercial Customer 000001';
        acc.Mobile_Number_PE__c = '52418';
        insert acc;
    }

    @IsTest
    static void testCalloutStatusHPAP(){
        
        Test.startTest();
        User contextuser = [SELECT Id FROM User WHERE Profile.Name = 'TMB Retail Mktg Campaign Mgmt' AND IsActive = true LIMIT 1];
        tempOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        tempOpportunity.StageName = 'Submit App';
        tempOpportunity.RTL_Is_Send_To_HPAP__c = true;
        update tempOpportunity;
        System.runAs(contextuser){

            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_SubmitHPAPCtrl.submitAppHPAP(tempOpportunity.Id);

        }
        Test.stopTest();

    }
    @IsTest
    static void testSubmitHPAP(){
        
        Test.startTest();
        User contextuser = [SELECT Id FROM User WHERE Profile.Name = 'TMB Retail Mktg Campaign Mgmt' AND IsActive = true LIMIT 1];
        tempOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        System.runAs(contextuser){
            Object obj;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            
            Continuation conti = (Continuation)RTL_AL_SubmitHPAPCtrl.submitAppHPAP(tempOpportunity.Id);
            Map<String, HttpRequest> requests = conti.getRequests();
            // Set the fake response for the continuation
            HttpRequest request = requests.values().iterator().next();
            String requestLabel = requests.keyset().iterator().next();
    
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody((String)SCSMessageAPIUtil.encryptMessageWithKey(
                '{"ResponseCode":"000","ResponseDetail":"OK","RefCode":"WEB","RefCode2":"OP1234","RefCode3":"20190613161923673"}',
                encryptKey
            ));
            // Invoke callback method
            Test.setContinuationResponse(requestLabel, response);
            RTL_AL_SubmitHPAPCtrl.callbackSubmitHPAP(new List<String>{requestLabel}, new Map<String, Object> {
                'recordId' => tempOpportunity.Id,
                'uuid' => new Uuid().getValue(),
                'privateKey' => encryptKey,
                'bodyRequestRaw' => (String)SCSMessageAPIUtil.decryptMessageWithKey(response.getBody(), encryptKey),
                'startDateTime' => Datetime.now()
            });
            
            // Response fail
            response.setStatusCode(200);
            response.setBody((String)SCSMessageAPIUtil.encryptMessageWithKey(
                '{"ResponseCode":"400","ResponseDetail":"Parameter invalid.","RefCode":"","RefCode2":"","RefCode3":""}',
                encryptKey
            ));
            Test.setContinuationResponse(requestLabel, response);
            RTL_AL_SubmitHPAPCtrl.callbackSubmitHPAP(new List<String>{requestLabel}, new Map<String, Object> {
                'recordId' => tempOpportunity.Id,
                'uuid' => new Uuid().getValue(),
                'privateKey' => encryptKey,
                'bodyRequestRaw' => (String)SCSMessageAPIUtil.decryptMessageWithKey(response.getBody(), encryptKey),
                'startDateTime' => Datetime.now()
            });

            // Exception
            response.setStatusCode(2001);
            response.setBody((String)SCSMessageAPIUtil.encryptMessageWithKey(
                '{"ResponseCode":"000","ResponseDetail":"OK","RefCode":"","RefCode2":"","RefCode3":""}',
                encryptKey
            ));
            Test.setContinuationResponse(requestLabel, response);
            RTL_AL_SubmitHPAPCtrl.callbackSubmitHPAP(new List<String>{requestLabel}, new Map<String, Object> {
                'recordId' => tempOpportunity.Id,
                'uuid' => new Uuid().getValue(),
                'privateKey' => encryptKey,
                'bodyRequestRaw' => (String)SCSMessageAPIUtil.decryptMessageWithKey(response.getBody(), encryptKey),
                'startDateTime' => Datetime.now()
            });
            
        }
        Test.stopTest();

    }
    
    // @IsTest
    // static void testcallAPIcreateReferral(){
    //     Test.startTest();
    //     User contextuser = [SELECT Id FROM User WHERE Profile.Name = 'TMB Retail Channel Sales' AND IsActive = true LIMIT 1];

    //     RTL_Referral__c ref = new RTL_Referral__c();
    //     ref.RTL_FirstName__c = 'Fname001';
    //     ref.RTL_LastName__c = 'Lname001';
    //     ref.RTL_Mobile1__c = '0951234560';
    //     ref.RTL_Product_Name__c = [SELECT Id,Name FROM  RTL_product_master__c WHERE Name = 'CYC' LIMIT 1].Id;
    //     ref.RTL_Contact_Address__c = [SELECT Id,Name FROM  RTL_Contact_Address__c WHERE IsActive__c = TRUE LIMIT 1].Id;
    //     ref.RTL_Stage__c = 'New';
    //     ref.RTL_Preferred_Branch__c = [SELECT Id,Name FROM  Branch_and_Zone__c WHERE Name = 'AL Marketing' LIMIT 1].Id;
    //     ref.RTL_AL_contact_channel__c = 'DS';
    //     ref.RecordTypeId = RTL_Referral__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Retail_Cross_Channel_Referral').getRecordTypeId();
    //     System.runAs(contextuser){
    //         Test.setMock(HttpCalloutMock.class, new MockHPAPHttpResponse());
    //         insert ref;
    //     }
    //     Test.stopTest();
    // }
    // @IsTest
    // static void testcallAPIcreateReferralFailProdName(){
    //     Test.startTest();
    //     User contextuser = [SELECT Id FROM User WHERE Profile.Name = 'TMB Retail Channel Sales' AND IsActive = true LIMIT 1];
    //     RTL_product_master__c prod = [SELECT Id,Name FROM  RTL_product_master__c WHERE Name = 'CYC' LIMIT 1];
    //     prod.Name = 'Test';
    //     update prod;

    //     RTL_Referral__c ref = new RTL_Referral__c();
    //     ref.RTL_FirstName__c = 'Fname001';
    //     ref.RTL_LastName__c = 'Lname001';
    //     ref.RTL_Mobile1__c = '0951234560';
    //     ref.RTL_Product_Name__c = prod.Id;
    //     ref.RTL_Contact_Address__c = [SELECT Id,Name FROM  RTL_Contact_Address__c WHERE IsActive__c = TRUE LIMIT 1].Id;
    //     ref.RTL_Stage__c = 'New';
    //     ref.RTL_Preferred_Branch__c = [SELECT Id,Name FROM  Branch_and_Zone__c WHERE Name = 'AL Marketing' LIMIT 1].Id;
    //     ref.RTL_AL_contact_channel__c = 'DS';
    //     ref.RecordTypeId = RTL_Referral__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Retail_Cross_Channel_Referral').getRecordTypeId();
    //     System.runAs(contextuser){
    //         Test.setMock(HttpCalloutMock.class, new MockHPAPHttpResponse());
    //         insert ref;
    //     }
    //     Test.stopTest();
    // }
    // @IsTest
    // static void testcallAPIcreateReferralwithAccount(){
    //     Test.startTest();
    //     User contextuser = [SELECT Id FROM User WHERE Profile.Name = 'TMB Retail Channel Sales' AND IsActive = true LIMIT 1];

    //     RTL_Referral__c ref = new RTL_Referral__c();
    //     ref.RTL_FirstName__c = 'Fname001';
    //     ref.RTL_LastName__c = 'Lname001';
    //     ref.RTL_Mobile1__c = '0951234560';
    //     ref.RTL_Product_Name__c = [SELECT Id,Name FROM  RTL_product_master__c WHERE Name = 'CYC' LIMIT 1].Id;
    //     ref.RTL_Contact_Address__c = [SELECT Id,Name FROM  RTL_Contact_Address__c WHERE IsActive__c = TRUE LIMIT 1].Id;
    //     ref.RTL_Stage__c = 'New';
    //     ref.RTL_Preferred_Branch__c = [SELECT Id,Name FROM  Branch_and_Zone__c WHERE Name = 'AL Marketing' LIMIT 1].Id;
    //     ref.RTL_AL_contact_channel__c = 'DS';
    //     ref.RecordTypeId = RTL_Referral__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Retail_Cross_Channel_Referral').getRecordTypeId();
    //     ref.RTL_Account_Name__c = [SELECT Id FROM Account LIMIT 1].Id;
    //     System.runAs(contextuser){
    //         Test.setMock(HttpCalloutMock.class, new MockHPAPHttpResponse());
    //         insert ref;
    //     }
    //     Test.stopTest();
    // }
}