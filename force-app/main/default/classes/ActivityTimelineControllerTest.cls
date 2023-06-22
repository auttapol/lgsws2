@isTest 
public with sharing class ActivityTimelineControllerTest {
    private static String encryptKey {
        get {
            return '208f6c8723b80c36fefc349575764dd14baf52d950a98c101034c403b1172b65';
        }
    }
    
    private static String requestBody {
        get{
            string body = '{'+
                '"status":{'+
                  ' "code":"0000",'+
                   '"message":"success",'+
                  ' "service":"personalization-service",'+
                   '"description":null'+
                '},'+
                '"data":{'+
                   '"today":['+
                      '{'+
                        '"id":"6163db9165b58f63b448daa0",'+
                         '"cardId":"MF00001",'+
                         '"titleTh":"คุณกำลังสนใจกองทุน TMBGOLDอยู่หรือเปล่า?",'+
                      '"titleThVerify":"คุณกำลังสนใจกองทุน TMBGOLDอยู่หรือเปล่า?",'+
                      '"createDate":1633934225602,'+
                         '"expiryDate":1634230800000,'+
                         '"isRead":false,'+
                         '"salesforceType":"campaign"'+
                      '},'+
                      '{'+
                        '"id":"6163db9165b58f63b448daa1",'+
                        '"cardId":"PM00001",'+
                        '"titleTh":"สรุปยอดบัตรแฟลชการ์ดประจำสัปดาห์ครับ",'+
                        '"d":"สรุปยอดบัตรแฟลชการ์ดประจำสัปดาห์ครับ",'+
                        '"createDate":1633934225602,'+
                        '"expiryDate":1634230800000,'+
                        '"isRead":false,'+
                        '"salesforceType":"campaign"'+
                      '}'+
                   '],'+
                   '"before":['+
                      '{'+
                         '"id":"615e79f26a07f332374b089e",'+
                         '"cardId":"BA00001",'+
                         '"titleTh":"อัปเดตความเคลือ? นไหวในบัญชียูนิตลิงค์ครับ",'+
                      '"titleThVerify":"อัปเดตความเคลือ? นไหวในบัญชียูนิตลิงค์ครับ",'+
                      '"createDate":1633581554773,'+
                         '"expiryDate":1633626000000,'+
                         '"isRead":true,'+
                         '"salesforceType":"campaign"'+
                      '},'+
                      '{'+
                         '"id":"615e79f26a07f332374b089f",'+
                         '"cardId":"BA00002",'+
                         '"titleTh":"ทุกก้าวทีเ? ดินไป คุณมีความอุ่นใจเพียงพอแล้วหรือยัง",'+
                      '"subTitleEn":"Check out varieties of protection most suitable for you here.",'+
                         '"titleThVerify":"ทุกก้าวทีเ? ดินไป คุณมีความอุ่นใจเพียงพอแล้วหรือยัง",'+
                      '"createDate":1633581554773,'+
                         '"expiryDate":1633366800000,'+
                         '"isRead":false,'+
                         '"salesforceType":"campaign"'+
                      '}'+
                   ']'+
                '}'+
             '}';
            return body;
        }
    }
    
    @TestSetup
    static void makeData(){
        TestUtils.createAppConfig();
        Account acc = TestUtils.createAccounts(1,'CustomerTest','Individual',false).get(0);
        acc.TMB_Customer_ID_PE__c = '123456789';
       
        insert acc;     
    }
    
   @isTest static void testGetActivityTimeline() {
       	List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        String accountId = accList[0].Id;
        test.startTest();
        ActivityTimelineController.ActivityWrapper result = ActivityTimelineController.getActivites(accountId, true, true, true, 1);
        ActivityTimelineController.ActivityWrapper expect = new ActivityTimelineController.ActivityWrapper();
        Campaign campaign = new Campaign();
        Datetime dateStart = datetime.Now();
        Datetime dateEnd = datetime.Now();
        Integer PersonalizeTimelineDays = ActivityTimelineController.PersonalizeTimelineDays;
        dateStart = dateStart.addDays(-(1 * Integer.valueOf(PersonalizeTimelineDays)));
        expect.startDate = dateStart;
        expect.endDate = dateEnd;
        test.stopTest();
    }

    @isTest static void testGetActivityCount() {
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        String accountId = accList[0].Id;
        test.startTest();
        ActivityTimelineController.ActivitiesCountWrapper result = ActivityTimelineController.getActivitiesCount(accountId);
        test.stopTest();
    }

    @isTest static void testGetTimelineFilter() {
        test.startTest();
        List<ActivityTimelineController.TimelineFilter> result = ActivityTimelineController.getTimelineFilter();
        test.stopTest();
    }

    @isTest static void testGetDataAccessPermission () {
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        String accountId = accList[0].Id;

        test.startTest();
        Boolean expected = false;
        Boolean result = ActivityTimelineController.getDataAccessPermission(accountId);
        System.assertEquals(expected, result);
        test.stopTest();
    }

    @isTest static void testGetOneAppData () {
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        String accountId = accList[0].Id;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(200, encryptKey));        
        ActivityTimelineController.OneAppResponse result = ActivityTimelineController.getOneAppData(accountId);
        test.stopTest();
    }
    
     @isTest static void testGetOneAppData_ERROR () {
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        String accountId = accList[0].Id;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(408, encryptKey));        
        ActivityTimelineController.OneAppResponse result = ActivityTimelineController.getOneAppData(accountId);
        test.stopTest();
    }
    
   
}