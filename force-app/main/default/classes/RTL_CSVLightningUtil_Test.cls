@isTest
public class RTL_CSVLightningUtil_Test {
    public static final Id SYSAD_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    
    public static final RecordType CommercialLeadRecordType {
        get{
            if(CommercialLeadRecordType == null){
                CommercialLeadRecordType = [SELECT ID, Name FROM RecordType WHERE Name = 'Commercial Lead' AND sObjectType='Lead' LIMIT 1];
            }
            return CommercialLeadRecordType;
        }
        set;
    }

    @testSetup static void setup() {
		TestUtils.createAppConfig();

		List<AppConfig__c> mc = new List<AppConfig__c> ();
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        insert mc;

        List<User> userlst = new List<User>();

        User userSystemadmin = RTL_TestUtility.createUsers(1, 'Sysad', 'Sysad', 'Sysad@tmb.com.test', false).get(0);
		userSystemadmin.ProfileId = SYSAD_PROFILE_ID;
		userSystemadmin.isActive = true;
		userSystemadmin.Employee_ID__c = '000002';
		userSystemadmin.Zone__c = 'ChiangMai';
		userSystemadmin.Zone_Code__c = '8888';
		userSystemadmin.Region__c = 'North1';
		userSystemadmin.Region_Code__c = '2222';
        userlst.add(userSystemadmin);
        insert userlst;

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

    }

    @isTest static void test_Utility() {
        Test.startTest();

        TestUtility_Referral.createAppConfigReferralAssignment();
        TestUtility_Referral.createReferralAssignment();
        TestUtility_Referral.createAppConfigCallMeNowBH();

        //Create Case
        Recordtype SErecordType = [Select ID, Name from Recordtype where SobjectType = 'Case' and Name = 'SE Call Center']; 
        List<Case> list_case = New list<Case>();
        Case caseNew1 = New Case(); 
        caseNew1.recordtypeID = SErecordType.id;
        caseNew1.Subject = 'TestCase';
        caseNew1.Status = 'New';
        caseNew1.Description = 'Test create Case';
        // caseNew1.AccountId = acc.id;
        caseNew1.Contact_Person_Email__c = 'test@gmail.com';
        caseNew1.Current_Service_Template__c = 'General';
        list_case.add(caseNew1);
        insert list_case;

        List<Branch_And_Zone__c> branchAndZoneList = RTL_TestUtility.createBranchZone(9,true);
        Lead leadRec = new Lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'BRN ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Juristic';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.RecordTypeId = CommercialLeadRecordType.id;
        leadRec.Interest_result__c = 'Yes';
        
        ///**********  CR Referral   *************///
        List<RTL_Referral__c> referralList = TestUtility_Referral.createReferralsWithoutAccount(1,branchAndZoneList[0].id,'Loan','Sell (เพื่อนำเสนอขาย)',false);
        referralList[0].RTL_Interested_Product__c = null;
        insert referralList;
        leadRec.RTL_Referral__c = referralList[0].id;
        insert leadRec;

        RecordTypeLightningUtil.fetchRecordType('Opportunity');
        // Worst case
        RTL_CaseLightningUtil.getCheckPermissionRecord('Opportunity');
        // Best case
        RTL_CaseLightningUtil.getCheckPermissionRecord((String)[SELECT Id FROM Case LIMIT 1].Id);

        // Worst case
        RTL_ReferralChangeOwner.getLeadByReferralId((Id)'001N000001UeDhlIAF');
        // Best case
        RTL_ReferralChangeOwner.getLeadByReferralId([SELECT Id FROM RTL_Referral__c LIMIT 1].Id);

        RTL_ReferralChangeOwner.acceptReferral([SELECT Id FROM RTL_Referral__c LIMIT 1].Id);
        RTL_ReferralChangeOwner.getOptyRecordType();

        Test.stopTest();
    }

    @isTest static void test_OSC07Service() {
        Test.startTest();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
        String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;

        Continuation conti = (Continuation)RTL_CSVLightningUtil.getCVSAnalyticsData('001100000000000000000000051187');
        Map<String, HttpRequest> requests = conti.getRequests();
        // Set the fake response for the continuation
        String requestLabel = requests.keyset().iterator().next();
        
        // respone is success
        HttpResponse response = new HttpResponse();
        response.setBody('{ "GetCVSAnalyticsDataResponse": { "Result": { "Status": "SUCCESS", "MIBStatus": "YES/YES", "UsagePercentage": "0:37:5:18:21:18", "suitability": "", "currentPrivilege2Desc": "- ดอกเบี้ยพิเศษ NO FIXED", "touchStatus": "YES", "ibStatus": "YES" } }, "Status": { "StatusCode": "200", "StatusDesc": "Success" } }');
        response.setStatusCode(200);
        Test.setContinuationResponse(requestLabel, response);
        // Invoke callback method
        RTL_CSVLightningUtil.callbackCVSAnalyticsData(new List<String>{requestLabel}, new Map<String, Object>{
            'RMID' => '001100000000000000000000051187',
            'RequestBody' => '{ "GetCVSAnalyticsDataRequest": { "RMID": "001100000000000000000000051187" } }',
            'StartTime' => (Datetime)Datetime.now(),
            'Account' => new Account()
        });

        // response body is empty
        response.setBody('');
        Test.setContinuationResponse(requestLabel, response);
        RTL_CSVLightningUtil.callbackCVSAnalyticsData(new List<String>{requestLabel}, new Map<String, Object>{
            'RMID' => '001100000000000000000000051187',
            'RequestBody' => '{ "GetCVSAnalyticsDataRequest": { "RMID": "001100000000000000000000051187" } }',
            'StartTime' => (Datetime)Datetime.now(),
            'Account' => new Account()
        });
        
        // response faild
        response.setBody('{ "GetCVSAnalyticsDataResponse": { }, "Status": { "StatusCode": "500", "StatusDesc": "Timeout exceeded" } }');
        Test.setContinuationResponse(requestLabel, response);
        RTL_CSVLightningUtil.callbackCVSAnalyticsData(new List<String>{requestLabel}, new Map<String, Object>{
            'RMID' => '001100000000000000000000051187',
            'RequestBody' => '{ "GetCVSAnalyticsDataRequest": { "RMID": "001100000000000000000000051187" } }',
            'StartTime' => (Datetime)Datetime.now(),
            'Account' => new Account()
        });

        // thrown exception
        try {
            response.setBody('{ "GetCVSAnalyticsDataResponse": { "Result": { "Status": "SUCCESS", "MIBStatus": "YES/YES", "UsagePercentage": "0:37:5:18:21:18", "suitability": "", "currentPrivilege2Desc": "- ดอกเบี้ยพิเศษ NO FIXED", "touchStatus": "YES", "ibStatus": "YES" } }, "Status": { "StatusCode": "200", "StatusDesc": "Success" } }');
            Test.setContinuationResponse(requestLabel, response);
            RTL_CSVLightningUtil.callbackCVSAnalyticsData(new List<String>{requestLabel}, new Map<String, Object>{
                'RMID' => '001100000000000000000000051187',
                'RequestBody' => '{ "GetCVSAnalyticsDataRequest": { "RMID": "001100000000000000000000051187" } }',
                'StartTime' => (Datetime)Datetime.now(),
                'Account' => [SELECT Id, Name, Core_Banking_Suggested_Segment__c FROM Account WHERE TMB_Customer_ID_PE__c = '001100000000000000000000051187' LIMIT 1]
            });
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        Test.stopTest();
    }

     @isTest static void test_CallCenterCSV() {
        User admin = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'Sysad@tmb.com.test' AND ProfileId = :SYSAD_PROFILE_ID LIMIT 1];
        Verification_History__c verify = new Verification_History__c();
        verify.Verification_Type__c = 'TMB ID';
        verify.Verification_Result__c = 'Success';
        verify.Verification_Status__c = '02 ActiveCustomer'; 
        verify.Verification_Date_Time__c = Datetime.Now();
        insert verify;
        List<Account> accList = RTL_TestUtility.createAccounts(1, true);

        CXM_Survey__c cxm = new CXM_Survey__c();
        cxm.Customer_ID__c = accList.get(0).TMB_Customer_ID_PE__c;
        cxm.Survey_Score__c = 95;
        cxm.Survey_Datetime__c = Datetime.Now();
        insert cxm;
        RTL_CSVLightningUtil.getDescribeFieldResultAndValue(accList.get(0).Id, new List<String>{ 'Name', 'RTL_Occupation_Details__r.RTL_Occupation_Desc__c'});
        RTL_CSVLightningUtil.getReference(accList.get(0).Id);
        RTL_CSVLightningUtil.getAccountField(accList.get(0).Id);
        System.runAs(admin){
            RTL_CSVLightningUtil.getMessengerCoverArea(accList.get(0).Id);
        }
        RTL_CSVLightningUtil.getVerification(verify.Id);
        RTL_CSVLightningUtil.getVerStatusColorCode(verify.Verification_Status__c);
        RTL_CSVLightningUtil.getVerStatusColorCode(verify.Verification_Status__c.replace(' ', ''));
        RTL_CSVLightningUtil.getVerResultColorCode(verify.Verification_Result__c);
        RTL_CSVLightningUtil.getVerResultColorCode(verify.Verification_Result__c + 'ABCD');
        RTL_CSVLightningUtil.getCXM(accList.get(0).Id);
        RTL_CSVLightningUtil.getCXMMeta();
        RTL_CSVLightningUtil.getComplaint(accList.get(0).Id);
    }

    @isTest static void test_CallCYCCampaignMappingInqAPI(){
        Test.startTest();
        //String messageResponse1 = '{"status":{"code":"0000","description":"Success"},"cyc_campaign_mapping_list":[{"customer_id":"00XX00000000000000000000XXXXXX","marketing_code":"XXXXXXXXXXXXXXXXXXXX","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"31082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50001.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 1.TestLINE.Line.Line.","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"00XX00000000000000000000XXXXXX","marketing_code":"XXXXXXXXXXXXXXXXXXXX","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"31082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 2","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"00XX00000000000000000000XXXXXX","marketing_code":"XXXXXXXXXXXXXXXXXXXX","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"24082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 3","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"00XX00000000000000000000XXXXXX","marketing_code":"XXXXXXXXXXXXXXXXXXXX","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"29082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 4","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"}]}';
        Object result1 = RTL_CSVLightningUtil.CallCYCCampaignMappingInqAPI('ForTesting','','{"rmid":"00XX00000000000000000000XXXXXX"}','{"customerName":"TEST","rmId":"00XX00000000000000000000XXXXXX","accId":null,"accSegment":"Test Segmemnt"}');
        //System.assertEquals( JSON.deserializeUntyped(messageResponse1), result1);        
        Test.stopTest();
    }

    @isTest static void test_getSetUpFormat(){
        Test.startTest();
        // Test RTL_CSVLightningUtil.getSetUpFormat
        RTL_CSVLightningUtil.getSetUpFormat('segment_coloring');
        Test.stopTest();        
    }

    @isTest static void test_getWatermarkHTML(){
        RTL_CSVLightningUtil.getWatermarkHTML();
    }

    @IsTest static void test_getPdpaDetail(){
        test.startTest();
        // Test.setMock(HttpCalloutMock.class, new PDPAViewHistHttpCalloutMock());
		RTL_CSVLightningUtil.getPdpaDetail('001100000001100000000000000500', 'PDPA_and_Market_Consent_getFlag');
        test.stopTest();      
    }

    @isTest static void test_getSubDebtTransaction(){
        List<Account> accList = RTL_TestUtility.createAccounts(1, true);
        Test.startTest();
        // Test RTL_CSVLightningUtil.getSetUpFormat
        RTL_CSVLightningUtil.getSubDebtTransaction(accList.get(0).Id);
        Test.stopTest();        
    }

    @isTest static void test_getInstantLendingDetail(){
        List<Account> accList = RTL_TestUtility.createAccounts(1, true);
        Test.startTest();
        // Test RTL_CSVLightningUtil.getSetUpFormat
        RTL_CSVLightningUtil.getInstantLendingDetail(accList.get(0).Id);
        Test.stopTest();
    }
    
}