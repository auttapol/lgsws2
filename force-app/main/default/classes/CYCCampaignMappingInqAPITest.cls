@isTest
public with sharing class CYCCampaignMappingInqAPITest {
    
    // public CYCCampaignMappingInqAPITest() {
    // }

    @IsTest
    public static void TestPreparedata_Success(){
        // Success Response
        String messageResponse1 = '{"status":{"code":"0000","description":"Success"},"cyc_campaign_mapping_list":[{"customer_id":"00XX00000000000000000000XXXXXX","marketing_code":"XXXXXXXXXXXXXXXXXXXX","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"31082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50001.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 1.TestLINE.Line.Line.","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"00XX00000000000000000000XXXXXX","marketing_code":"XXXXXXXXXXXXXXXXXXXX","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"31082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 2","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"00XX00000000000000000000XXXXXX","marketing_code":"XXXXXXXXXXXXXXXXXXXX","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"24082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 3","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"},{"customer_id":"00XX00000000000000000000XXXXXX","marketing_code":"XXXXXXXXXXXXXXXXXXXX","campaign_name":"CYC TOP UP-TEST UAT","campaign_expiry_date":"29082021","contract_period":"60","car_product_group":"NEW CAR","car_register_no":"กท 3570","car_year":"2013","car_brand":"NISSAN","car_gear_type":"AUTO","car_group":"","car_model":"March","car_type":"เก๋ง 2 ตอน","committee_price":"50000.00","normal_price":"","installment_amount":"4044.00","remaining_installment_month":"13","offer_installment_amount":"0.00","offer_installment_month":"60","offer_interest_rate":"4.90","promotion_detail":"","promotion_condition":"เสนอวงเงินอนุมัติเบื้องต้น CYC-TOPUP -Test 4","remark":"","lead_owner":"272","owner_type":"BRANCH","as_of_date":"30062021"}]}';
        CYCCampaignMappingInqAPIMock mock1 = new CYCCampaignMappingInqAPIMock(200,messageResponse1);
        Test.setMock(HttpCalloutMock.class, mock1);        
        Test.startTest();
        Object result1 = RTL_CSVLightningUtil.CallCYCCampaignMappingInqAPI('ForTesting','','{"rmid":"00XX00000000000000000000XXXXXX"}','{"customerName":"TEST","rmId":"00XX00000000000000000000XXXXXX","accId":null,"accSegment":"Test Segmemnt"}');
        System.assertEquals( JSON.deserializeUntyped(messageResponse1), result1);        
        Test.stopTest();
        
    }

    @IsTest
    public static void TestPreparedata_Exception(){
        // Exception Response
        String messageResponse2 = 'Error';
        CYCCampaignMappingInqAPIMock mock2 = new CYCCampaignMappingInqAPIMock(500,messageResponse2);
        Test.setMock(HttpCalloutMock.class, mock2);

        Test.startTest();
        Object result1 = RetailCSVLightningUtil.CallCYCCampaignMappingInqAPI('ForTesting','','{"rmid":"00XX00000000000000000000XXXXXX"}','{"customerName":"TEST","rmId":"00XX00000000000000000000XXXXXX","accId":null,"accSegment":"Test Segmemnt"}');        
        Test.stopTest();
    }

    @isTest
    public static void TestgetMapValueFromParameter(){
        List<Map<String,Object>> list_obj = new List<Map<String,Object>>();
        Map<String,Object> testMap = new Map<String,Object>();
        testMap.put('name','Mr.TestClass');
        list_obj.add(testMap);
        Test.startTest();
        CYCCampaignMappingInqAPI CYCcampaignAPI = new CYCCampaignMappingInqAPI();
        CYCcampaignAPI.getMapValueFromParameter('name', list_obj);
        Test.stopTest();
    }


    @isTest
    public static void TestgetKey(){
        List<String> dataTest = new List<String>{'DWH','SCS','CoreHP','CoreBank','HPAPAPI','FloorPlan','EC','OneApp','Protection'};
        List<String> listKey = new List<String>();
        Test.startTest();
        CYCCampaignMappingInqAPI CYCcampaignAPI = new CYCCampaignMappingInqAPI();
        for(String d : dataTest){
            CYCcampaignAPI.getKey(d);
        }
        Test.stopTest();
    }

    @isTest
    public static void TestEncryptDecrypt(){
        String plainText = 'TestPlainText';
        String encMessage = '';
        String decMessage = '';
        Test.startTest();
        CYCCampaignMappingInqAPI CYCcampaignAPI = new CYCCampaignMappingInqAPI();
        encMessage = CYCcampaignAPI.EncryptMesage(plainText, 'DWH');
        decMessage = CYCcampaignAPI.DecryptMessage(encMessage, 'DWH');
        System.assertEquals(plainText, decMessage);
        Test.stopTest();
    }
    
}