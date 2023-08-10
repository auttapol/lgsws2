@isTest

public with sharing class CampaignMemberToALBatchTest {

    static {
        TestUtils.createAppConfig();
        TestUtils.prepareIntegrationMapping();

        Id ADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

        User User = new User(FirstName='Test',LastName='Test', 
                                    UserName='TestTMB@tmb.com',
                                    Email='Test@tmbbank.com', Alias='Test',Segment__c ='MB',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='TestNickname',
                                    ProfileId = ADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='11111');
        insert User;
        System.runAs(User){
            Id recordTypeId  = [select Id from RecordType where SobjectType = 'Campaign' and DeveloperName=: 'Dummy_Campaign' and IsActive=true ].Id;
            Campaign camp = new Campaign();
            camp.Name = 'Campaign_';
            camp.Segment__c = 'MB';
            camp.OwnerId  = UserInfo.getUserId();
            camp.RecordTypeId = Recordtypeid;
            insert camp;

            Branch_and_zone__c bz = new Branch_and_zone__c();
            bz.Branch_Code__c = '611';
            bz.isActive__c = true;
            insert bz;

            Lead l = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
            l.RTL_Branch_Code_Rpt__c = '611';
            insert l;
            Lead l2 = new Lead(Company = 'Test', LastName = 'Test', Status = 'Open');
            l2.RTL_Branch_Code_Rpt__c = '611';
            insert l2;

            //mockdata
            Campaignmember cm = new Campaignmember();
            cm.RTL_Contact_Method__c = 'AL Sales';
            cm.RTL_Is_Interface_Success__c = false;
            cm.RTL_Is_Send_To_HPAP__c = false;
            cm.CampaignId = camp.Id;
            cm.LeadId = l.Id;
            cm.RTL_Product_Name__c = '';
            cm.RTL_AL_car_type__c = '';
            cm.RTL_AL_car_brand__c = '';
            cm.RTL_AL_car_group__c = '';
            cm.RTL_AL_car_subtype__c = '';
            cm.RTL_AL_car_gear__c  = '';
            cm.RTL_AL_car_year__c = '';
            cm.RTL_AL_wanted_amount__c = null;
            cm.RTL_AL_max_set_up_amount__c = null;
            cm.RTL_AL_installment_periods__c = '';
            cm.RTL_AL_PayPerMonth__c = null;
            cm.RTL_AL_DownPercent__c = null;
            cm.RTL_AL_DownAmt__c = null;
            cm.RTL_AL_installment_amount__c = null;
            cm.RTL_AL_available_time__c = '';
            cm.RTL_AL_ContactZipcode__c = '';
            cm.RTL_AL_ContactProvince__c = '';
            cm.RTL_AL_ContactDistrict__c = '';
            cm.RTL_AL_ContactSubDistrict__c = '';
            cm.RTL_AL_contact_channel__c = '';
            cm.RTL_AL_IsCarBooked__c = '';
            cm.RTL_AL_car_bought_from__c = '';
            cm.RTL_AL_TentName__c = '';
            cm.RTL_Branch_Code__c = '';
            cm.RTL_AL_car_plate_no__c = '';
            cm.RTL_AL_province_car_plate_no__c = '';
            cm.RTL_AL_Showroom__c = '';
            cm.Customer__c = null;
            cm.RTL_AL_comment__c = '';
            cm.LGS_Partner__c = '';
            cm.LGS_Lead_Received_Time__c = null;
            cm.LGS_001__c = '';
            cm.LGS_002__c = '';
            cm.LGS_003__c = '';
            cm.LGS_004__c = '';
            cm.LGS_005__c = '';
            cm.LGS_006__c = '';
            cm.LGS_007__c = '';
            cm.LGS_008__c = '';
            cm.LGS_009__c = '';
            cm.LGS_010__c = null;
            cm.LGS_011__c = null;
            cm.LGS_012__c = null;
            cm.LGS_013__c = null;
            cm.LGS_014__c = null;
            cm.LGS_015__c = null;
            cm.LGS_016__c = null;
            cm.LGS_017__c = null;
            cm.LGS_018__c = null;
            cm.LGS_019__c = null;
            cm.LGS_020__c = null;
            cm.WS_Response_Detail__c = null;
            insert cm;

            Campaignmember cm2 = new Campaignmember();
            cm2.RTL_Contact_Method__c = 'Normal Request';
            cm2.RTL_Is_Interface_Success__c = false;
            cm2.RTL_Is_Send_To_HPAP__c = false;
            cm2.CampaignId = camp.Id;
            cm2.LeadId = l2.Id;
            cm2.RTL_Product_Name__c = '';
            cm2.RTL_AL_car_type__c = '';
            cm2.RTL_AL_car_brand__c = '';
            cm2.RTL_AL_car_group__c = '';
            cm2.RTL_AL_car_subtype__c = '';
            cm2.RTL_AL_car_gear__c  = '';
            cm2.RTL_AL_car_year__c = '';
            cm2.RTL_AL_wanted_amount__c = null;
            cm2.RTL_AL_max_set_up_amount__c = null;
            cm2.RTL_AL_installment_periods__c = '';
            cm2.RTL_AL_PayPerMonth__c = null;
            cm2.RTL_AL_DownPercent__c = null;
            cm2.RTL_AL_DownAmt__c = null;
            cm2.RTL_AL_installment_amount__c = null;
            cm2.RTL_AL_available_time__c = '';
            cm2.RTL_AL_ContactZipcode__c = '';
            cm2.RTL_AL_ContactProvince__c = '';
            cm2.RTL_AL_ContactDistrict__c = '';
            cm2.RTL_AL_ContactSubDistrict__c = '';
            cm2.RTL_AL_contact_channel__c = '';
            cm2.RTL_AL_IsCarBooked__c = '';
            cm2.RTL_AL_car_bought_from__c = '';
            cm2.RTL_AL_TentName__c = '';
            cm2.RTL_Branch_Code__c = '';
            cm2.RTL_AL_car_plate_no__c = '';
            cm2.RTL_AL_province_car_plate_no__c = '';
            cm2.RTL_AL_Showroom__c = '';
            cm2.Customer__c = null;
            cm2.RTL_AL_comment__c = '';
            cm2.LGS_Partner__c = '';
            cm2.LGS_Lead_Received_Time__c = null;
            cm2.LGS_001__c = '';
            cm2.LGS_002__c = '';
            cm2.LGS_003__c = '';
            cm2.LGS_004__c = '';
            cm2.LGS_005__c = '';
            cm2.LGS_006__c = '';
            cm2.LGS_007__c = '';
            cm2.LGS_008__c = '';
            cm2.LGS_009__c = '';
            cm2.LGS_010__c = null;
            cm2.LGS_011__c = null;
            cm2.LGS_012__c = null;
            cm2.LGS_013__c = null;
            cm2.LGS_014__c = null;
            cm2.LGS_015__c = null;
            cm2.LGS_016__c = null;
            cm2.LGS_017__c = null;
            cm2.LGS_018__c = null;
            cm2.LGS_019__c = null;
            cm2.LGS_020__c = null;
            cm2.WS_Response_Detail__c = null;
            insert cm2;
        }
    }

    @isTest
    public static void testALBatch(){
        String query = 'SELECT Id,RTL_Campaign_Product_1__c,RTL_Campaign_Product_1__r.Name,RTL_AL_oa_ref_code__c, CampaignId, Campaign.Name,RTL_Marketing_Code__c,RTL_Web_Unique_ID__c, LeadSource, RTL_Product_Name__c, RTL_AL_car_type__c, RTL_AL_car_brand__c, RTL_AL_car_group__c'+
        ',RTL_AL_car_subtype__c, RTL_AL_car_gear__c, RTL_AL_car_year__c, RTL_AL_wanted_amount__c, RTL_AL_max_set_up_amount__c,RTL_AL_normal_price__c '+
        ', RTL_AL_installment_periods__c, RTL_AL_PayPerMonth__c, RTL_AL_DownPercent__c, RTL_AL_DownAmt__c, RTL_AL_installment_amount__c, RTL_AL_available_time__c'+
        ',RTL_AL_ContactZipcode__c, RTL_AL_ContactProvince__c, RTL_AL_ContactDistrict__c, RTL_AL_ContactSubDistrict__c, RTL_AL_contact_channel__c, RTL_AL_IsCarBooked__c'+
        ', RTL_AL_car_bought_from__c, RTL_AL_TentName__c, RTL_Branch_Code__c, RTL_AL_car_plate_no__c, RTL_AL_province_car_plate_no__c, RTL_AL_Showroom__c, LeadId, Lead.RTL_ID_Type__c, Lead.RTL_Citizen_Id__c, Lead.FirstName, Lead.LastName'+
        ', Customer__c, Customer__r.ID_Number_PE__c, Customer__r.ID_Type_PE__c, Customer__r.First_name_PE__c, Customer__r.Last_name_PE__c, Customer__r.Mobile_Number_PE__c,Customer__r.Email_Address_PE__c, RTL_CampHis_Phone__c '+
        ', Customer__r.TMB_Customer_ID_PE__c, RTL_AL_comment__c, LGS_Partner__c, LGS_Lead_Received_Time__c '+
        ', RTL_AL_Interested_Rate__c, LGS_001__c, LGS_002__c, LGS_003__c, LGS_004__c, LGS_005__c, LGS_006__c, LGS_007__c, LGS_008__c, LGS_009__c, LGS_010__c '+
        ', LGS_011__c, LGS_012__c, LGS_013__c, LGS_014__c, LGS_015__c, LGS_016__c, LGS_017__c, LGS_018__c, LGS_019__c, LGS_020__c, WS_Response_Detail__c,RTL_Is_Interface_Success__c,RTL_Is_Send_To_HPAP__c,Assigned_Agent_ID__c ' +
        'FROM Campaignmember ';


        List<CampaignMember> listcm = Database.query(query);
        System.debug(listcm.size());
        Test.setMock(HttpCalloutMock.class, new MockHPAPHttpResponse());
        Test.startTest();
        Database.executeBatch(new CampaignMemberToALBatch(listcm,true,null,null,DateTime.now()));
        Test.stopTest();
    }

    @isTest
    public static void testALBatchFailled(){
        String query = 'SELECT Id,RTL_Campaign_Product_1__c,RTL_Campaign_Product_1__r.Name,RTL_AL_oa_ref_code__c, CampaignId, Campaign.Name,RTL_Marketing_Code__c,RTL_Web_Unique_ID__c, LeadSource, RTL_Product_Name__c, RTL_AL_car_type__c, RTL_AL_car_brand__c, RTL_AL_car_group__c'+
        ',RTL_AL_car_subtype__c, RTL_AL_car_gear__c, RTL_AL_car_year__c, RTL_AL_wanted_amount__c, RTL_AL_max_set_up_amount__c,RTL_AL_normal_price__c '+
        ', RTL_AL_installment_periods__c, RTL_AL_PayPerMonth__c, RTL_AL_DownPercent__c, RTL_AL_DownAmt__c, RTL_AL_installment_amount__c, RTL_AL_available_time__c'+
        ',RTL_AL_ContactZipcode__c, RTL_AL_ContactProvince__c, RTL_AL_ContactDistrict__c, RTL_AL_ContactSubDistrict__c, RTL_AL_contact_channel__c, RTL_AL_IsCarBooked__c'+
        ', RTL_AL_car_bought_from__c, RTL_AL_TentName__c, RTL_Branch_Code__c, RTL_AL_car_plate_no__c, RTL_AL_province_car_plate_no__c, RTL_AL_Showroom__c, LeadId, Lead.RTL_ID_Type__c, Lead.RTL_Citizen_Id__c, Lead.FirstName, Lead.LastName'+
        ', Customer__c, Customer__r.ID_Number_PE__c, Customer__r.ID_Type_PE__c, Customer__r.First_name_PE__c, Customer__r.Last_name_PE__c, Customer__r.Mobile_Number_PE__c,Customer__r.Email_Address_PE__c, RTL_CampHis_Phone__c '+
        ', Customer__r.TMB_Customer_ID_PE__c, RTL_AL_comment__c, LGS_Partner__c, LGS_Lead_Received_Time__c '+
        ', RTL_AL_Interested_Rate__c, LGS_001__c, LGS_002__c, LGS_003__c, LGS_004__c, LGS_005__c, LGS_006__c, LGS_007__c, LGS_008__c, LGS_009__c, LGS_010__c '+
        ', LGS_011__c, LGS_012__c, LGS_013__c, LGS_014__c, LGS_015__c, LGS_016__c, LGS_017__c, LGS_018__c, LGS_019__c, LGS_020__c, WS_Response_Detail__c,RTL_Is_Interface_Success__c,RTL_Is_Send_To_HPAP__c,Assigned_Agent_ID__c ' +
        'FROM Campaignmember ';


        List<CampaignMember> listcm = Database.query(query);
        System.debug(listcm.size());
        Test.setMock(HttpCalloutMock.class, new MockHPAPHttpResponse(true));
        Test.startTest();
        Database.executeBatch(new CampaignMemberToALBatch(listcm,true,null,null,DateTime.now()));
        Test.stopTest();
    }

    @isTest
    public static void testScheduled(){
        CampaignMember cm = [SELECT Id,RTL_Contact_Method__c,RTL_Is_Interface_Success__c,RTL_Is_Send_To_HPAP__c,LastModifiedDate FROM Campaignmember WHERE RTL_Contact_Method__c =: 'Normal Request'];
        cm.RTL_Contact_Method__c = 'AL Sales';
        cm.createReferDate__c = Datetime.now().addDays(-1);
        update cm;
        Test.setMock(HttpCalloutMock.class, new MockHPAPHttpResponse());

        Test.startTest();
        String jobId = System.schedule('test', '0 0 8 ? * MON *', new CampaignMemberToALSchedule());
        Test.stopTest();
    }

    @isTest
    public static void testScheduledFail(){
        CampaignMember cm = [SELECT Id,RTL_Contact_Method__c,RTL_Is_Interface_Success__c,RTL_Is_Send_To_HPAP__c,LastModifiedDate FROM Campaignmember WHERE RTL_Contact_Method__c =: 'Normal Request'];
        cm.RTL_Contact_Method__c = 'AL Sales';
        cm.createReferDate__c = Datetime.now().addDays(-1);
        update cm;
        Test.setMock(HttpCalloutMock.class, new MockHPAPHttpResponse(true));
        
        Test.startTest();
        String jobId = System.schedule('test', '0 0 8 ? * MON *', new CampaignMemberToALSchedule());
        Test.stopTest();
    }
}