@isTest
public class ClosedCaseLayoutExtensionTest {
    static{
        TestUtils.createAppConfig();
    }

    public static testmethod void CaseUpdate(){
        Test.startTest();
        Case testCase = new Case();
        testCase.Status = 'New';
        testCase.Resolution_List__c = 'ปรับปรุงเงินคืน';
        testCase.Contact_Person_Name__c = 'TEST TEST';
        testCase.Contact_Person_Phone__c ='0800000000';
        testCase.Contact_Person_Phone_2__c ='0800000000';
        testCase.To_Ext_1__c ='401 ,403';
        testCase.To_Ext_2__c ='401 ,(403)- 1';

        testCase.Contact_Person_Email__c = 'test@gmail.com';
        testCase.Closed_By_BU__c = 'TEST';
        testCase.Subject = 'TEST Case';
        testCase.Service_Type_Matrix_Code__c = 'V0012';
        testCase.SMS_Resolution_1__c = 'ปรับปรุงเงินคืน';
        testCase.SMS_Resolution_2__c = 'ยืนยันรายการปกติ';
        testCase.SMS_Code_Resolution_1__c = 'CRMRBG_012';
        testCase.SMS_Code_Resolution_2__c = 'CRMRBG_001';
        testCase.Root_Cause_List__c = 'Customer_ลูกค้าร้องขอบริการ';
        testCase.Category__c = 'Complaint';
        ApexPages.StandardController sc1 = new ApexPages.StandardController(testCase);
        ClosedCaseLayoutExtension Case1 = new ClosedCaseLayoutExtension(sc1);
        Case1.checkedStatusNew = null;
        Case1.validateCase();
        Case1.oldStatus = 'Completed';
        Case1.validateCase();
        Case1.cancelCase();
        
        Test.stopTest();

    }



}