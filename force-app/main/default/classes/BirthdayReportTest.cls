@isTest
public class BirthdayReportTest {
	@isTest
    static void test(){
        TestUtils.createAppConfig();
        
        Account acc = new Account();
        acc.Name = 'test';
        acc.Phone = '0999932211';
        acc.Mobile_Number_PE__c = '083234222';
        acc.RTL_Date_Of_Birth__c = Date.today();
        acc.RTL_Wealth_RM__c = UserInfo.getUserId();
        insert acc;
        BirthdayReport.getBirthdayList();
    }
}