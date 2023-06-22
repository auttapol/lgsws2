@isTest
public class Create_Case_Inquiry_ControllerTest {
    static{
        TestUtils.createAppConfig();
    }
    @isTest
    public static void PositiveTest(){
        List<Service_Type_Matrix__c> svtmList = new List<Service_Type_Matrix__c>();
        for (Integer i = 1; i <= 10; i++) {
            Service_Type_Matrix__c svtm = new Service_Type_Matrix__c();
            svtm.Segment__c = 'TEST';
            svtm.Service_Level1__c = 'Inquiry';
            svtm.Service_Level2__c = 'TESTLVL2';
            svtm.Service_Level3__c = 'TESTLVL3';
            svtm.Service_Level4__c = 'TESTLVL4' + i;
            svtm.SMS_Code_Resolution_1__c = 'TESTSMSReso1' + i;
            svtm.Service_Template__c = 'TESTTemplate' + i;
            svtm.Resolution_1__c = 'TESTReso1' + i;
            svtm.Journey__c = 'TESTJourney' + i;
            svtm.Validate_Code__c = 'V00' + i;
            svtm.Problem_Type__c = 'TESTProblem' + i;
            // [2020-03-26] Case Select Template.
            svtm.Service_Template__c = 'CreditService';
            svtm.Active__c = true;
            svtmList.add(svtm);
        }
        
        String devRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call Log Record Type').getRecordTypeId();
        User currentUser = [Select ID, Employee_ID__c from User where username = : userinfo.getUserName() limit 1];
        Task tsks = new Task();
        tsks.Call_Agent_Id__c = currentUser.Employee_ID__c;
        tsks.Call_Log_ID__c = '000012345';
        tsks.Call_Start_Datetime__c = DateTime.Now();
        tsks.Call_Number__c = '0891234567';
        tsks.OwnerId = UserInfo.getUserId();
        tsks.recordtypeID = devRecordTypeId;

        Case testCase = new Case();
        List<Case> caseList = new List<Case>();
        testCase.Status = 'Completed';
        testCase.PTA_Segment__c = 'RBG';
        testCase.Category__c = 'Inquiry';
        testCase.Sub_Category__c = 'Test';
        testCase.Issue__c = 'TEST';
        testCase.Call_Log_ID__c = '0000123456';
		testCase.Call_Number__c = '0891234567';
		testCase.Contact_Person_Name__c = 'TEST';
        testCase.Contact_Person_Phone__c ='0800000000';
        testCase.Contact_Person_Phone_2__c ='0800000000';
        testCase.To_Ext_1__c ='401 ,403';
        testCase.To_Ext_2__c ='401 ,(403)- 1';
        testCase.Problem_Type__c = 'TEST';
        testCase.Journey__c = 'TEST';
        testCase.Service_Type_Matrix_Code__c = 'V00001';
        testCase.Origin = 'ลูกค้าสัมพันธ์';
        testCase.FCR__c = true;
        caseList.add(testCase);
        Test.StartTest();
        insert svtmList;
        insert tsks;
        Create_Case_Inquiry_Controller.getServiceTypeMatrix();
        Create_Case_Inquiry_Controller.mappingCallLog();
        Create_Case_Inquiry_Controller.saveRecord(caseList,tsks);
        Test.StopTest();
    }
}