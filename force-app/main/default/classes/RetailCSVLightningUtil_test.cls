@isTest
public class RetailCSVLightningUtil_test {
    public static final Id Channel_Sales_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Retail Channel Sales' LIMIT 1].Id;
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
        List<User> userList = new List<User>();
        User newUser = new User(FirstName = 'Test' , LastName = 'Man', 
                UserName='testMan@tmbbank.com',
                Email='testman@gmail.com', Alias='Testtmb',
                LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                CommunityNickname='TestManTMBTesttmb',
                ProfileId = Channel_Sales_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                Employee_ID__c ='MM01');
        insert newUser;
    }
    
    @isTest static void test_get () {
        String profile = 'System Admin';
        List<Account> accList = RTL_TestUtility.createAccounts(1, true);
        List<String> fields = new List<String>{ 'Name', 'RTL_Occupation_Details__r.RTL_Occupation_Desc__c', 'RTL_Preferred_Contact_Channel__c'}; 
        List<String> fieldstranslate = new List<String>{'RTL_Preferred_Contact_Channel__c'};
        Profile profileObj = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        List <User> TestUsers = TestUtils.createUsers(1, 'test', 'User', 'Retail@test.com', true);
        
        List<Sub_Debt_Transaction__c> subDebtList = new List<Sub_Debt_Transaction__c>();
        Sub_Debt_Transaction__c eachSubDebt = new Sub_Debt_Transaction__c();
        eachSubDebt.Product_ID__c = 'CPALL16OA';
        eachSubDebt.Name = 'วายุภักษ์3';
        eachSubDebt.Term__c = '5 Years';
        eachSubDebt.Issue_Date__c = Date.today();
        eachSubDebt.Amount__c = 10000000;
        eachSubDebt.Maturity_Date__c = Date.today();
        eachSubDebt.Sub_Debt_Transaction_Name__c = '0011000000000000000000000511872022080100001';
        eachSubDebt.Customer__c = accList.get(0).Id;
        eachSubDebt.Unit__c = 821900;
        eachSubDebt.Interest_Rate__c = '4.10% ต่อปี';
        subDebtList.add(eachSubDebt);
        insert subDebtList;

        RetailCSVLightningUtil.getDescribeFieldResultAndValue(accList.get(0).Id, fields, fieldstranslate);
        RetailCSVLightningUtil.getReference(accList.get(0).Id);
        RetailCSVLightningUtil.verifyFieldSecurity('RTL', profile, accList.get(0).Id);
        RetailCSVLightningUtil.getProfileName(TestUsers[0].Id);
        RetailCSVLightningUtil.getWatermarkHTML();
        RetailCSVLightningUtil.getSubDebtTransaction(accList.get(0).Id);
        RetailCSVLightningUtil.getInstantLendingDetail(accList.get(0).Id);

    }
    
    @isTest static void test_Service () {
        Test.startTest();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new SmartBDM_MockHttpResponseToken());
        String tokenKeyEnliteGateWay = SmartBDM_Utility.tokenKeyEnliteGateWay;

        Continuation conti = (Continuation)RetailCSVLightningUtil.getCVSAnalyticsData('001100000000000000000000051187');
		Map<String, HttpRequest> requests = conti.getRequests();
        // Set the fake response for the continuation
        String requestLabel = requests.keyset().iterator().next();
        
        // respone is success
        HttpResponse response = new HttpResponse();
        response.setBody('{ "GetCVSAnalyticsDataResponse": { "Result": { "Status": "SUCCESS", "MIBStatus": "YES/YES", "UsagePercentage": "0:37:5:18:21:18", "suitability": "", "currentPrivilege2Desc": "- ดอกเบี้ยพิเศษ NO FIXED", "touchStatus": "YES", "ibStatus": "YES" } }, "Status": { "StatusCode": "200", "StatusDesc": "Success" } }');
        response.setStatusCode(200);
        Test.setContinuationResponse(requestLabel, response);
        // Invoke callback method
        RetailCSVLightningUtil.callbackCVSAnalyticsData(new List<String>{requestLabel}, new Map<String, Object>{
            'RMID' => '001100000000000000000000051187',
            'RequestBody' => '{ "GetCVSAnalyticsDataRequest": { "RMID": "001100000000000000000000051187" } }',
            'StartTime' => (Datetime)Datetime.now(),
            'Account' => new Account()
        });
       	Test.stopTest();
    }

    @isTest static void test_SaveAssignBRC2Mainbank () {

        List<Account> accList = RTL_TestUtility.createAccounts(1, true);
        Test.startTest();
        RetailCSVLightningUtil.saveAssignBRC2Mainbank(accList.get(0).Id);
        Test.stopTest();

    }

    @isTest static void test_CallCYCCampaignMappingInqAPI(){
        Test.startTest();
        //String messageResponse1 = '{"status":{"code":"0000","description":"Success"},"cyc_campaign_mapping_list":[{"customer_id":"00XX00000000000000000000XXXXXX","marketing_code":"XXXXXXXXXXXXXXXXXXXX","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"31082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50001.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 1.TestLINE.Line.Line.","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"00XX00000000000000000000XXXXXX","marketing_code":"XXXXXXXXXXXXXXXXXXXX","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"31082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 2","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"00XX00000000000000000000XXXXXX","marketing_code":"XXXXXXXXXXXXXXXXXXXX","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"24082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 3","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"00XX00000000000000000000XXXXXX","marketing_code":"XXXXXXXXXXXXXXXXXXXX","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"29082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 4","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"}]}';
        Object result1 =  RetailCSVLightningUtil.CallCYCCampaignMappingInqAPI('ForTesting','','{"rmid":"00XX00000000000000000000XXXXXX"}','{"customerName":"TEST","rmId":"00XX00000000000000000000XXXXXX","accId":null,"accSegment":"Test Segmemnt"}');
        //System.assertEquals( JSON.deserializeUntyped(messageResponse1), result1);        
        Test.stopTest();
    }

    @isTest
    static void testGetHobbiesPicklist(){
        Test.startTest();
        Map<String, String>  hobbiesValues = RetailCSVLightningUtil.getHobbiesValuesIntoList();
        Test.stopTest();
    }

    @isTest
    static void testGetFoodPicklist(){
        Test.startTest();
        Map<String, String>  hobbiesValues = RetailCSVLightningUtil.getFoodValuesIntoList();
        Test.stopTest();
    }

    @isTest
    static void testGetOther1Picklist(){
        Test.startTest();
        Map<String, String>  hobbiesValues = RetailCSVLightningUtil.getOther1ValuesIntoList();
        Test.stopTest();
    }


    @isTest
    static void testGetMusicPicklist(){
        Test.startTest();
        Map<String, String>  hobbiesValues = RetailCSVLightningUtil.getMusicValuesIntoList();
        Test.stopTest();
    }


    @isTest
    static void testGetTravelPicklist(){
        Test.startTest();
        Map<String, String>  hobbiesValues = RetailCSVLightningUtil.getTravelValuesIntoList();
        Test.stopTest();
    }

    @isTest
    static void testGetLifePicklist(){
        Test.startTest();
        Map<String, String>  hobbiesValues = RetailCSVLightningUtil.getLifeValuesIntoList();
        Test.stopTest();
    }

    @isTest
    static void testGetOnAcPicklist(){
        Test.startTest();
        Map<String, String>  hobbiesValues = RetailCSVLightningUtil.getOnAcValuesIntoList();
        Test.stopTest();
    }

    @isTest
    static void testGetSportPicklist(){
        Test.startTest();
        Map<String, String>  hobbiesValues = RetailCSVLightningUtil.getSportValuesIntoList();
        Test.stopTest();
    }
    
    @isTest
    static void testGetPurposeContact1ValuesIntoList(){
        Test.startTest();
        Map<String, String>  hobbiesValues = RetailCSVLightningUtil.getPurposeContact1ValuesIntoList();
        Test.stopTest();
    }

    @isTest
    static void testGetPurposeContact2ValuesIntoList(){
        Test.startTest();
        Map<String, String>  hobbiesValues = RetailCSVLightningUtil.getPurposeContact2ValuesIntoList();
        Test.stopTest();
    }

    @isTest
    static void testGetRelationContact1ValuesIntoList(){
        Test.startTest();
        Map<String, String>  hobbiesValues = RetailCSVLightningUtil.getRelationContact1ValuesIntoList();
        Test.stopTest();
    }

    @isTest
    static void testGetRelationContact2ValuesIntoList(){
        Test.startTest();
        Map<String, String>  hobbiesValues = RetailCSVLightningUtil.getRelationContact2ValuesIntoList();
        Test.stopTest();
    }

    @isTest
    static void testGetPreferContactValuesIntoList(){
        Test.startTest();
        Map<String, String>  hobbiesValues = RetailCSVLightningUtil.getPreferContactValuesIntoList();
        Test.stopTest();
    }

    @isTest
    static void testGetAlterCValuesIntoList(){
        Test.startTest();
        Map<String, String>  hobbiesValues = RetailCSVLightningUtil.getAlterCValuesIntoList();
        Test.stopTest();
    }
    
    @isTest
    static void testGetUserLanguage(){
        Test.startTest();
        String hobbiesValues = RetailCSVLightningUtil.getUserLanguage();
        Test.stopTest();
    }  

    //@isTest
    //static void testGetDescribeFieldResultAndValue(){
      //  TestUtils.createAppConfig(); 
        //List<String> fields = new List<String>{ 'FATCA_Form_Completed__c', 'C_Home_phone_PE__c', 'Customer_Name_PE_Eng__c', 'RTL_Occupation_Details__r.RTL_Occupation_Desc__c', 'TMB_Customer_ID_PE__c'}; 
        //List<String> fieldstranslate = new List<String>{};
        //Test.startTest();
        //Object returnValue = RetailCSVLightningUtil.getDataAfterRefresh('0015D000012CMcGQAW', fields, fieldstranslate);   
        //Test.stopTest();
    //}
}