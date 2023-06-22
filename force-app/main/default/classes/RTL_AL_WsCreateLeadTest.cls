@isTest
public with sharing class RTL_AL_WsCreateLeadTest {
    
    private static Id CampaignRecordtypeid {
        get {
            return [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName=: 'Dummy_Campaign' AND IsActive = true]?.Id;
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
        insert new List<RTL_Lead_Assignment_Rule__c>{
            new RTL_Lead_Assignment_Rule__c(
                RTL_Active_Flag__c = true,
                RTL_Priority__c = 100,
                RTL_Lead_Record_Type__c = 'Retail Banking',
                RTL_IsAssign_Campaign__c = true,
                RTL_IsInsertProduct__c = true,
                RTL_Lead_Field_Criteria_1__c = 'RTL_Customer_Segment__c',
                RTL_Lead_Field_Value_1__c = 'O2O Web',
                RTL_Lead_Field_Criteria_2__c = 'RTL_Contact_Method__c',
                RTL_Lead_Field_Value_2__c = 'Normal Request',
                RTL_Lead_Field_Criteria_3__c = '',
                RTL_Lead_Field_Value_3__c = '',
                RTL_Assigned_User_field__c = '',
                RTL_Branch_and_Zone_Queue_User_field__c = 'Branch_Queue_Name__c'
            ),
            new RTL_Lead_Assignment_Rule__c(
                RTL_Active_Flag__c = true,
                RTL_Priority__c = 150,
                RTL_Lead_Record_Type__c = 'Retail Banking',
                RTL_IsAssign_Campaign__c = true,
                RTL_IsInsertProduct__c = true,
                RTL_Lead_Field_Criteria_1__c = 'RTL_Customer_Segment__c',
                RTL_Lead_Field_Value_1__c = 'O2O Web',
                RTL_Lead_Field_Criteria_2__c = 'RTL_Contact_Method__c',
                RTL_Lead_Field_Value_2__c = 'Others',
                RTL_Lead_Field_Criteria_3__c = '',
                RTL_Lead_Field_Value_3__c = '',
                RTL_Assigned_User_field__c = '',
                RTL_Branch_and_Zone_Queue_User_field__c = 'Branch_Queue_Name__c'
            ),
           new RTL_Lead_Assignment_Rule__c(
                RTL_Active_Flag__c = true,
                RTL_Priority__c = 91,
                RTL_Lead_Record_Type__c = 'Retail Banking',
                RTL_IsAssign_Campaign__c = true,
                RTL_IsInsertProduct__c = true,
                RTL_Lead_Field_Criteria_1__c = 'RTL_Customer_Segment__c',
                RTL_Lead_Field_Value_1__c = 'MIS',
                RTL_Lead_Field_Criteria_2__c = 'RTL_TMB_Campaign_Source__c',
                RTL_Lead_Field_Value_2__c = 'Touch',
                RTL_Lead_Field_Criteria_3__c = 'RTL_Owner_Type__c',
                RTL_Lead_Field_Value_3__c = 'Employee',
                RTL_Assigned_User_field__c = 'RTL_Employee_ID__c',
                RTL_Branch_and_Zone_Queue_User_field__c = ''
           ),
            new RTL_Lead_Assignment_Rule__c(
                RTL_Active_Flag__c = true,
                RTL_Priority__c = 92,
                RTL_Lead_Record_Type__c = 'Retail Banking',
                RTL_IsAssign_Campaign__c = true,
                RTL_IsInsertProduct__c = true,
                RTL_Lead_Field_Criteria_1__c = 'RTL_Customer_Segment__c',
                RTL_Lead_Field_Value_1__c = 'MIS',
                RTL_Lead_Field_Criteria_2__c = 'RTL_TMB_Campaign_Source__c',
                RTL_Lead_Field_Value_2__c = 'Touch',
                RTL_Lead_Field_Criteria_3__c = 'RTL_Owner_Type__c',
                RTL_Lead_Field_Value_3__c = 'Branch',
                RTL_Assigned_User_field__c = '',
                RTL_Branch_and_Zone_Queue_User_field__c = 'Branch_Queue_Name__c'
            )
        };
        
        
        RTL_Campaign_Running_No__c rn = new RTL_Campaign_Running_No__c( 
            Name ='Local Exclusive Campaign Running No.' , 
            DateValue__c='170717',
            Day__c='17',
            Month__c='07',
            Year__c='17',
            Running_No__c = '01' );
        insert rn;
        
        RTL_CampaignMember_Running_No__c cmrn = new RTL_CampaignMember_Running_No__c(
            Name = 'Campaign Member Running No',
            Running_No__c = '000000'
        );
        
        insert cmrn;
        
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = CampaignRecordtypeid;
        insert camp;
        
        Lead l = new Lead(           
            RTL_AL_Interested_Rate__c = null,
            RTL_AL_response__c = true,
            RTL_AL_car_plate_no__c = null,
            RTL_Employee_ID__c = null,
            RTL_AL_oa_ref_code__c = 'MK2021062100002',
            RecordTypeId = '01290000000iZYKAA2',
            RTL_TMB_Campaign_Reference__c = '',
            RTL_Web_Unique_ID_c__c = '',
            RTL_Contact_Method__c = 'Normal Request',
            RTL_Customer_Segment__c = 'MIS',
            RTL_TMB_Campaign_Source__c = 'Touch',
            LeadSource = 'Website',
            RTL_Product_Name__c = 'CYC',
            RTL_AL_wanted_amount__c = 189000.0,
            RTL_AL_normal_price__c = 210000.0,
            RTL_AL_max_set_up_amount__c = 32000,
            RTL_AL_installment_periods__c = '48',
            RTL_AL_installment_amount__c = 4972.0,
            RTL_Mobile_Number__c = '0824200021',
            RTL_Citizen_Id__c = null,
            RTL_ID_Type__c = null,
            LastName = 'Narathip-3',
            FirstName = 'S.',
            RTL_Email_Address__c = 'nrs@ii.co.th',
            RTL_AL_contact_channel__c = 'BR',
            RTL_AL_comment__c = null,
            RTL_AL_car_year__c = '2009',
            RTL_AL_car_type__c = 'รถกระบะ',
            RTL_AL_car_subtype__c = 'BT-50 2.5 S (CD) (Single Cab) (MNC) (MY09)',
            RTL_AL_car_group__c = 'BT-50',
            RTL_AL_car_gear__c = 'Manual',
            RTL_AL_car_brand__c = 'MAZDA',
            RTL_AL_car_bought_from__c = '',
            RTL_Branch_Name__c = '001',
            RTL_AL_available_time__c = 'ตลอดเวลาทำการ',
            RTL_AL_ContactProvince__c = '',
            RTL_AL_ContactZipcode__c = '',
            RTL_AL_ContactSubDistrict__c = '',
            RTL_AL_ContactDistrict__c = '',
            RTL_Address_Line1__c = null,
            RTL_AL_ILA_AMT__c = 2000,
            RTL_AL_REMN_MTH__c = 3000,
            RTL_AL_OFFR_ILA_AMT__c = 5000,
            RTL_AL_OFFR_ILA_MTH__c = 4000,
            RTL_AL_promotion_detail__c = 'RTL_AL_promotion_detail__c',
            RTL_AL_CAMP_EXP_DTE__c = null,
            RTL_Owner_Type__c = 'Employee'
        );
        insert l;

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
        
         CampaignMember cm1 = new CampaignMember(
            LeadId = l.id,
            CampaignId = camp.id,

            RTL_AL_Interested_Rate__c = null,
            RTL_AL_response__c = true,
            RTL_AL_car_plate_no__c = null,
            RTL_AL_oa_ref_code__c = 'MK2021062100002',
            RTL_TMB_Campaign_Reference__c = '',
            RTL_Contact_Method__c = 'Normal Request',
            //RTL_Customer_Segment__c = 'MIS',
            RTL_TMB_Campaign_Source__c = 'Touch',
            RTL_Product_Name__c = 'CYC',
            RTL_AL_wanted_amount__c = 189000.0,
            RTL_AL_normal_price__c = 210000.0,
            RTL_AL_max_set_up_amount__c = 32000,
            RTL_AL_installment_periods__c = '48',
            RTL_AL_installment_amount__c = 4972.0,
            RTL_AL_contact_channel__c = 'BR',
            RTL_AL_comment__c = null,
            RTL_AL_car_year__c = '2009',
            RTL_AL_car_type__c = 'รถกระบะ',
            RTL_AL_car_subtype__c = 'BT-50 2.5 S (CD) (Single Cab) (MNC) (MY09)',
            RTL_AL_car_group__c = 'BT-50',
            RTL_AL_car_gear__c = 'Manual',
            RTL_AL_car_brand__c = 'MAZDA',
            RTL_AL_car_bought_from__c = '',
            RTL_AL_available_time__c = 'ตลอดเวลาทำการ',
            RTL_AL_ContactProvince__c = '',
            RTL_AL_ContactZipcode__c = '',
            RTL_AL_ContactSubDistrict__c = '',
            RTL_AL_ContactDistrict__c = '',
            RTL_AL_ILA_AMT__c = 2000,
            RTL_AL_REMN_MTH__c = 3000,
            RTL_AL_OFFR_ILA_AMT__c = 5000,
            RTL_AL_OFFR_ILA_MTH__c = 4000,
            RTL_AL_promotion_detail__c = 'RTL_AL_promotion_detail__c',
            RTL_AL_CAMP_EXP_DTE__c = null,
            RTL_RelatedOpportunity_1__c = tempOpportunity.Id,
            RTL_OfferResult_Product_1__c = 'Not Interested',
            RTL_OfferResult_Product_2__c = 'Not Interested',
            RTL_OfferResult_Product_3__c = 'Not Interested',
            RTL_OfferResult_Product_4__c = 'Not Interested',
            RTL_OfferResult_Product_5__c = 'Not Interested'
        );
        insert cm1;
        
        /*CampaignMember cm2 = new CampaignMember(
            LeadId = l.id,
            CampaignId = camp.id,

            RTL_AL_ContactDistrict__c = '',
            RTL_AL_ContactSubDistrict__c = '',
            RTL_AL_ContactZipcode__c = '',
            RTL_AL_ContactProvince__c = '',
            RTL_AL_available_time__c = 'ตลอดเวลาทำการ',
            RTL_Branch_Name__c = 001,
            RTL_AL_car_bought_from__c = '',
            RTL_AL_car_brand__c = 'MAZDA',
            RTL_AL_car_gear__c = 'Manual',
            RTL_AL_car_group__c = 'BT-50',
            RTL_AL_car_subtype__c = 'BT-50 2.5 S (CD) (Single Cab) (MNC) (MY09)',
            RTL_AL_car_type__c = 'รถกระบะ',
            RTL_AL_car_year__c = 2009,
            RTL_AL_contact_channel__c = 'BR',
            RTL_Email_Address__c = 'ab@1553.com',
            FirstName = 'first1',
            LastName = 'last2',
            RTL_Mobile_Number__c = 0999999999,
            RTL_AL_installment_amount__c = 4972.0,
            RTL_AL_installment_periods__c = 48,
            RTL_AL_normal_price__c = 210000.0,
            RTL_AL_wanted_amount__c = 189000.0,
            RTL_Product_Name__c = 'CYC',
            LeadSource = 'Website',
            RTL_TMB_Campaign_Source__c = 'Organic',
            RTL_AL_oa_ref_code__c = 'WEB20210916103',
            RTL_Customer_Segment__c = 'O2O Web',
            RTL_Contact_Method__c = 'Call me now',
            RTL_Marketing_Code__c = 'DOUTBOUND11354363404',
            RTL_TMB_Campaign_Reference__c = '',
            RecordTypeId = '01290000000iZYKAA2',
            RTL_AL_response__c = false
        );
        insert cm2;*/
        /*CampaignMember cm2 = new CampaignMember(
            LeadId = l.id,
            CampaignId = camp.id,
            RTL_Product_Name__c = 'CYC',
            FirstName = 'TestAL',
            LastName = 'TestAL',
            RTL_Mobile_Number__c = '0888888888',
            RTL_Branch_Name__c = '',
            RecordTypeId = '01290000000iZYK', 
            RTL_BranchW2L_Area__c = '00000',
            RTL_Marketing_Code__c = 'DOUTBOUND1SI00001020',
            RTL_Call_Back_Date_time__c = '2021-11-06T18=05=00Z',
            RTL_Contact_Method__c = 'AL Sales',
            LeadSource = 'Website',
            RTL_TMB_Campaign_Source__c = 'sitchantay',
            RTL_TMB_Campaign_Reference__c = 'sitref',
            RTL_Multiple_Interested_Product_s__c = 'false',
            RTL_Customer_Segment__c = 'TMB Web',
            Rating = 'High',
            RTL_Media_Source__c = 'sitsource',
            RTL_Medium__c = 'sitmedium',
            RTL_Promotion__c = '',
            RTL_Employee_ID__c = '',
            RTL_Consent__c= true,
            RTL_Media_Source__c='test'
            );
            insert cm2;*/
      
    }

    private static String encryptKey {
        get {
            return '208f6c8723b80c36fefc349575764dd14baf52d950a98c101034c403b1172b65';
        }
    }

    @IsTest
    static void testDropLeadSuccess(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            RTL_AL_WsCreateLead webserviceClass = new RTL_AL_WsCreateLead();
            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Lead/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf((String)SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'RTL_Address_Line1__c' => 'Unknown',
                    'RTL_Address_Line2__c' => 'Unknown',
                    'RTL_Address_Line3__c' => 'Unknown',
                    'RTL_Address_Line5__c' => 'Unknown',
                    'RTL_Address_Line4__c' => 'Unknown',
                    'RTL_AL_available_time__c' => '',
                    'RTL_Branch_Name__c' => '',
                    'RTL_AL_car_bought_from__c' => '',
                    'RTL_AL_car_brand__c' => 'Toyota',
                    'RTL_AL_car_gear__c' => 'Manual',
                    'RTL_AL_car_group__c' => 'Fortuner',
                    'RTL_AL_car_subtype__c' => '2.4 G (MY15) (MNC)',
                    'RTL_AL_car_type__c' => '',
                    'RTL_AL_car_year__c' => '',
                    'RTL_AL_comment__c' => '',
                    'RTL_AL_contact_channel__c' => 'BR',
                    'RTL_Email_Address__c' => 'admin@ttbank.com',
                    'FirstName' => 'T.',
                    'LastName' => 'TTB-Test-3',
                    'RTL_ID_Type__c' => 'Other',
                    'RTL_Citizen_Id__c' => '1234123412340',
                    'RTL_Mobile_Number__c' => '0812341234',
                    'RTL_AL_installment_amount__c' => 20000,
                    'RTL_AL_installment_periods__c' => 60,
                    'RTL_AL_max_set_up_amount__c' => 1287554,
                    'RTL_AL_normal_price__c' => 1239000,
                    'RTL_AL_wanted_amount__c' => 1030043,
                    'RTL_Product_Name__c' => 'test',
                    'LeadSource' => 'Website',
                    'RTL_TMB_Campaign_Source__c' => 'Touch',
                    'RTL_AL_oa_ref_code__c' => '',
                    'RTL_Contact_Method__c' => 'Normal Request',
                    'RTL_Customer_Segment__c' => 'O2O Web',
                    'RTL_Web_Unique_ID_c__c' => '',
                    'RTL_TMB_Campaign_Reference__c' => '',
                    'RecordTypeId' => Lead.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Retail_Banking').getRecordTypeId(),
                    'RTL_Marketing_Code__c' => 'xx11',
                    'RTL_Employee_ID__c' => '',
                    'RTL_AL_car_plate_no__c' => '1กก 1234',
                    'RTL_AL_response__c' => '',
                    'RTL_AL_Interested_Rate__c' => ''
                }
            ), encryptKey));
            RestContext.request = request;

            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes response = RTL_AL_WsCreateLead.httpPostWebservice();
            
        }
        Test.stopTest();
    }


    @IsTest
    static void testDropLeadFail(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Lead/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf((String)SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'RecordTypeId' => Lead.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Retail_Banking').getRecordTypeId()
                }
            ), encryptKey));
            RestContext.request = request;

            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes response = RTL_AL_WsCreateLead.httpPostWebservice();
        }
        Test.stopTest();
        
    }


    @IsTest
    static void testDropLeadTouch(){
        Test.startTest();
        List<CampaignMember> campaignsTest = [SELECT RTL_Marketing_Code__c FROM CampaignMember ];
        CampaignMember campaignTest = campaignsTest.size() > 0 ? campaignsTest.get(0) : null;
        system.debug(campaignsTest);
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            
            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Lead/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf((String)SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'RTL_AL_Interested_Rate__c' => null,
                    'RTL_AL_response__c' => true,
                    'RTL_AL_car_plate_no__c' => null,
                    'RTL_Employee_ID__c' => null,
                    'RTL_Marketing_Code__c' => campaignTest?.RTL_Marketing_Code__c,
                    'RTL_AL_oa_ref_code__c' => 'MK2021062100002',
                    'RTL_Web_Unique_ID__c' => '',
                    'RecordTypeId' => '01290000000iZYKAA2',
                    'RTL_TMB_Campaign_Reference__c' => '',
                    'RTL_Web_Unique_ID_c__c' => '',
                    'RTL_Contact_Method__c' => 'Normal Request',
                    'RTL_Customer_Segment__c' => 'MIS',
                    'RTL_TMB_Campaign_Source__c' => 'Touch',
                    'LeadSource' => 'Website',
                    'RTL_Product_Name__c' => 'CYC',
                    'RTL_AL_wanted_amount__c' => 189000.0,
                    'RTL_AL_normal_price__c' => 210000.0,
                    'RTL_AL_max_set_up_amount__c' => null,
                    'RTL_AL_installment_periods__c' => 48,
                    'RTL_AL_installment_amount__c' => 4972.0,
                    'RTL_Mobile_Number__c' => '0824200021',
                    'RTL_Citizen_Id__c' => null,
                    'RTL_ID_Type__c' => null,
                    'LastName' => 'TTB-Test-3',
                    'FirstName' => 'T.',
                    'RTL_Email_Address__c' => 'admin@ttbank.com',
                    'RTL_AL_contact_channel__c' => 'BR',
                    'RTL_AL_comment__c' => null,
                    'RTL_AL_car_year__c' => '2009',
                    'RTL_AL_car_type__c' => 'รถกระบะ',
                    'RTL_AL_car_subtype__c' => 'BT-50 2.5 S (CD) (Single Cab) (MNC) (MY09)',
                    'RTL_AL_car_group__c' => 'BT-50',
                    'RTL_AL_car_gear__c' => 'Manual',
                    'RTL_AL_car_brand__c' => 'MAZDA',
                    'RTL_AL_car_bought_from__c' => '',
                    'RTL_Branch_Name__c' => '001',
                    'RTL_AL_available_time__c' => 'ตลอดเวลาทำการ',
                    'RTL_AL_ContactProvince__c' => '',
                    'RTL_AL_ContactZipcode__c' => '',
                    'RTL_AL_ContactSubDistrict__c' => '',
                    'RTL_AL_ContactDistrict__c' => '',
                    'RTL_Address_Line1__c' => null,
                    'RTL_AL_ILA_AMT__c' => 2000,
                    'RTL_AL_REMN_MTH__c' => 3000,
                    'RTL_AL_OFFR_ILA_AMT__c' => 5000,
                    'RTL_AL_OFFR_ILA_MTH__c' => 4000,
                    'RTL_AL_promotion_detail__c' => 'RTL_AL_promotion_detail__c',
                    'RTL_AL_CAMP_EXP_DTE__c' => null,
                    'RTL_Owner_Type__c' => 'Employee'
                }
            ), encryptKey));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes response = RTL_AL_WsCreateLead.httpPostWebservice();

        }
        Test.stopTest();
    }
    @IsTest
    static void testDropLeadTouchEmpty(){
        Test.startTest();
        List<CampaignMember> campaignsTest = [SELECT RTL_Marketing_Code__c FROM CampaignMember ];
        CampaignMember campaignTest = campaignsTest.size() > 0 ? campaignsTest.get(0) : null;
        system.debug(campaignsTest);
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            
            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Lead/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf((String)SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'RTL_AL_Interested_Rate__c' => null,
                    'RTL_AL_response__c' => true,
                    'RTL_AL_car_plate_no__c' => null,
                    'RTL_Employee_ID__c' => null,
                    'RTL_AL_oa_ref_code__c' => 'MK2021062100002',
                    'RTL_Web_Unique_ID__c' => '',
                    'RecordTypeId' => '01290000000iZYKAA2',
                    'RTL_TMB_Campaign_Reference__c' => '',
                    'RTL_Web_Unique_ID_c__c' => '',
                    'RTL_Contact_Method__c' => 'Normal Request',
                    'RTL_Customer_Segment__c' => 'MIS',
                    'RTL_TMB_Campaign_Source__c' => 'Touch',
                    'LeadSource' => 'Website',
                    'RTL_Product_Name__c' => 'CYC',
                    'RTL_AL_wanted_amount__c' => 189000.0,
                    'RTL_AL_normal_price__c' => 210000.0,
                    'RTL_AL_max_set_up_amount__c' => null,
                    'RTL_AL_installment_periods__c' => 48,
                    'RTL_AL_installment_amount__c' => 4972.0,
                    'RTL_Mobile_Number__c' => '0824200021',
                    'RTL_Citizen_Id__c' => null,
                    'RTL_ID_Type__c' => null,
                    'LastName' => 'TTB-Test-3',
                    'FirstName' => 'T.',
                    'RTL_Email_Address__c' => 'admin@ttbank.com',
                    'RTL_AL_contact_channel__c' => 'BR',
                    'RTL_AL_comment__c' => null,
                    'RTL_AL_car_year__c' => '2009',
                    'RTL_AL_car_type__c' => 'รถกระบะ',
                    'RTL_AL_car_subtype__c' => 'BT-50 2.5 S (CD) (Single Cab) (MNC) (MY09)',
                    'RTL_AL_car_group__c' => 'BT-50',
                    'RTL_AL_car_gear__c' => 'Manual',
                    'RTL_AL_car_brand__c' => 'MAZDA',
                    'RTL_AL_car_bought_from__c' => '',
                    'RTL_Branch_Name__c' => '001',
                    'RTL_AL_available_time__c' => 'ตลอดเวลาทำการ',
                    'RTL_AL_ContactProvince__c' => '',
                    'RTL_AL_ContactZipcode__c' => '',
                    'RTL_AL_ContactSubDistrict__c' => '',
                    'RTL_AL_ContactDistrict__c' => '',
                    'RTL_Address_Line1__c' => null,
                    'RTL_AL_ILA_AMT__c' => 2000,
                    'RTL_AL_REMN_MTH__c' => 3000,
                    'RTL_AL_OFFR_ILA_AMT__c' => 5000,
                    'RTL_AL_OFFR_ILA_MTH__c' => 4000,
                    'RTL_AL_promotion_detail__c' => 'RTL_AL_promotion_detail__c',
                    'RTL_AL_CAMP_EXP_DTE__c' => null,
                    'RTL_Owner_Type__c' => 'Employee'
                }
            ), encryptKey));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes response = RTL_AL_WsCreateLead.httpPostWebservice();

        }
        Test.stopTest();
    }

    @IsTest
    static void testGetOfferResult(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        CampaignMember campaignsTest = [SELECT Id, RTL_Marketing_Code__c FROM CampaignMember LIMIT 1];
        system.debug(campaignsTest);
        System.runAs(sfextapi){
            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/getByMarketingCode/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf((String)SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'marketingCode' => campaignsTest?.RTL_Marketing_Code__c //'D23487633AEG00000023'
                }
            ), encryptKey));
            RestContext.request = request;
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes response2 = RTL_AL_WsCampaignMember.getOfferStatus();
            
            RTL_AL_WsCampaignMember rtl_al_wscampaignmember = new RTL_AL_WsCampaignMember();
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetOfferResultFail(){
        Test.startTest();
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/getByMarketingCode/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf((String)SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    //'marketingCode' => null
                    'marketingCode' => 'D23487633AEG00000023'
                }
            ), encryptKey));
            RestContext.request = request;
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes response2 = RTL_AL_WsCampaignMember.getOfferStatus();
            
            RTL_AL_WsCampaignMember rtl_al_wscampaignmember = new RTL_AL_WsCampaignMember();
        }
        Test.stopTest();
    }
    @IsTest
    static void testDropLeadTouchNomktlosefield(){
        Test.startTest();
        List<CampaignMember> campaignsTest = [SELECT RTL_Marketing_Code__c FROM CampaignMember ];
        CampaignMember campaignTest = campaignsTest.size() > 0 ? campaignsTest.get(0) : null;
        system.debug(campaignsTest);
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            
            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Lead/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf((String)SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'RTL_AL_Interested_Rate__c' => null,
                    'RTL_AL_response__c' => true,
                    'RTL_AL_car_plate_no__c' => null,
                    'RTL_Employee_ID__c' => null,
                    'RTL_AL_oa_ref_code__c' => 'MK2021062100002',
                    'RTL_Web_Unique_ID__c' => '',
                    'RecordTypeId' => '01290000000iZYKAA2',
                    'RTL_TMB_Campaign_Reference__c' => '',
                    'RTL_Web_Unique_ID_c__c' => '',
                    'RTL_Contact_Method__c' => 'Normal Request',
                    'RTL_Customer_Segment__c' => 'MIS',
                    'RTL_TMB_Campaign_Source__c' => 'Touch',
                    'LeadSource' => 'Website',
                    'RTL_Product_Name__c' => 'CYC',
                    'RTL_AL_wanted_amount__c' => 189000.0,
                    'RTL_AL_normal_price__c' => 210000.0,
                    'RTL_AL_max_set_up_amount__c' => null,
                    'RTL_AL_installment_periods__c' => 48,
                    'RTL_AL_installment_amount__c' => 4972.0,
                    'RTL_Mobile_Number__c' => '0824200021',
                    'RTL_Citizen_Id__c' => null,
                    'RTL_ID_Type__c' => null,
                    'LastName' => 'TTB-Test-3',
                    'FirstName' => 'T.',
                    'RTL_Email_Address__c' => 'admin@ttbank.com',
                    'RTL_AL_contact_channel__c' => 'BR',
                    'RTL_AL_comment__c' => null,
                    'RTL_AL_car_year__c' => '2009',
                    'RTL_AL_car_type__c' => 'รถกระบะ',
                    'RTL_AL_car_subtype__c' => 'BT-50 2.5 S (CD) (Single Cab) (MNC) (MY09)',
                    'RTL_AL_car_group__c' => 'BT-50',
                    'RTL_AL_car_gear__c' => 'Manual',
                    'RTL_AL_car_brand__c' => 'MAZDA',
                    'RTL_AL_car_bought_from__c' => '',
                    'RTL_Branch_Name__c' => '001',
                    'RTL_AL_available_time__c' => 'ตลอดเวลาทำการ',
                    'RTL_AL_ContactProvince__c' => '',
                    'RTL_AL_ContactZipcode__c' => '',
                    'RTL_AL_ContactSubDistrict__c' => '',
                    'RTL_AL_ContactDistrict__c' => '',
                    'RTL_Address_Line1__c' => null,
                    'RTL_AL_ILA_AMT__c' => 2000,
                    'RTL_AL_REMN_MTH__c' => 3000,
                    'RTL_AL_OFFR_ILA_AMT__c' => 5000,
                    'RTL_AL_OFFR_ILA_MTH__c' => 4000,
                    'RTL_AL_promotion_detail__c' => 'RTL_AL_promotion_detail__c',
                    'RTL_AL_CAMP_EXP_DTE__c' => null,
                    'RTL_Owner_Type__c' => 'Employee'
                }
            ), encryptKey));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes response = RTL_AL_WsCreateLead.httpPostWebservice();
            Test.stopTest();    
        }       
    }
    @IsTest
    static void testDropLeadFailNocon(){
        Test.startTest();
        List<CampaignMember> campaignsTest = [SELECT RTL_Marketing_Code__c FROM CampaignMember ];
        CampaignMember campaignTest = campaignsTest.size() > 0 ? campaignsTest.get(0) : null;
        system.debug(campaignsTest);
        User sfextapi = [SELECT Id FROM user WHERE name = 'sfextapi'];
        System.runAs(sfextapi){
            
            RestRequest request = new RestRequest();
            request.requestUri = URL.getSalesforceBaseUrl().toExternalForm() + '/data/V1.0/sobjects/Lead/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf((String)SCSMessageAPIUtil.encryptMessageWithKey(JSON.serialize(
                new Map<String, Object>{
                    'RTL_AL_Interested_Rate__c' => null,
                    'RTL_AL_response__c' => true,
                    'RTL_AL_car_plate_no__c' => null,
                    'RTL_Employee_ID__c' => null,
                    'RTL_AL_oa_ref_code__c' => 'MK2021062100002',
                    'RTL_Web_Unique_ID__c' => '',
                    'RecordTypeId' => '01290000000iZYKAA2',
                    'RTL_TMB_Campaign_Reference__c' => '',
                    'RTL_Web_Unique_ID_c__c' => '',
                    'RTL_Contact_Method__c' => 'Normal Request',
                    'RTL_Customer_Segment__c' => 'MIS',
                    'RTL_TMB_Campaign_Source__c' => 'Touch',
                    'LeadSource' => 'Website',
                    'RTL_Product_Name__c' => 'CYC',
                    'RTL_AL_wanted_amount__c' => 189000.0,
                    'RTL_AL_normal_price__c' => 210000.0,
                    'RTL_AL_max_set_up_amount__c' => null,
                    'RTL_AL_installment_periods__c' => 48,
                    'RTL_AL_installment_amount__c' => 4972.0,
                    'RTL_Mobile_Number__c' => '0824200021',
                    'RTL_Citizen_Id__c' => null,
                    'RTL_ID_Type__c' => null,
                    'LastName' => 'TTB-Test-3',
                    
                    'RTL_Email_Address__c' => 'admin@ttbank.com',
                    'RTL_AL_contact_channel__c' => 'BR',
                    'RTL_AL_comment__c' => null,
                    'RTL_AL_car_year__c' => '2009',
                    'RTL_AL_car_type__c' => 'รถกระบะ',
                    'RTL_AL_car_subtype__c' => 'BT-50 2.5 S (CD) (Single Cab) (MNC) (MY09)',
                    'RTL_AL_car_group__c' => 'BT-50',
                    'RTL_AL_car_gear__c' => 'Manual',
                    'RTL_AL_car_brand__c' => 'MAZDA',
                    'RTL_AL_car_bought_from__c' => '',
                    'RTL_Branch_Name__c' => '001',
                    'RTL_AL_available_time__c' => 'ตลอดเวลาทำการ',
                    'RTL_AL_ContactProvince__c' => '',
                    'RTL_AL_ContactZipcode__c' => '',
                    'RTL_AL_ContactSubDistrict__c' => '',
                    'RTL_AL_ContactDistrict__c' => '',
                    'RTL_Address_Line1__c' => null,
                    'RTL_AL_ILA_AMT__c' => 2000,
                    'RTL_AL_REMN_MTH__c' => 3000,
                    'RTL_AL_OFFR_ILA_AMT__c' => 5000,
                    'RTL_AL_OFFR_ILA_MTH__c' => 4000,
                    'RTL_AL_promotion_detail__c' => 'RTL_AL_promotion_detail__c',
                    'RTL_AL_CAMP_EXP_DTE__c' => null,
                    'RTL_Owner_Type__c' => 'Employee'
                    //'RecordTypeId' => Lead.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('Retail_Banking').getRecordTypeId()
                }
            ), encryptKey));
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));
            RTL_AL_WebserviceAbstract.SCSReqRes response = RTL_AL_WsCreateLead.httpPostWebservice();
            Test.stopTest();    
        }     
    }
    
}