@Istest
public class PerformanceProxyCtrlTest {
		static testMethod void PerformanceProxyCtrlTest() {
        test.startTest();
		List<User> us = TestUtils.createUsers(2,'Upload','Prospect','canvas@tmbbank.com',true);
        TestUtils.createStatusCode();
        TestUtils.createAppConfig();

        
        List<Account> acc = new List<Account>();
        Account acc1 = new Account ();
        acc1.Rating = 'Hot';
        acc1.IsDisqualified__c = false;
        acc1.First_name_PE__c = 'TestNotSame';
        acc1.First_Name_ENG_PE__c = 'TestNotSame';
        acc1.Last_name_PE__c = 'TestMock';
        acc1.Last_Name_PE_Eng__c  = 'TestMock';
        acc1.Name = 'Test Account';
        acc1.Segment_crm__c = '3';
        acc1.Phone ='345345';
        acc1.Phone ='050111222';
        acc1.Mobile_Number_PE__c  = '0801112233';
        acc1.OwnerId = us[0].id;
        acc1.Customer_Type__c = 'Juristic';
        acc1.ID_Type_PE__c = 'BRN ID';
        acc1.ID_Number_PE__c = '12344141';
        acc.add(acc1);
        insert acc;
        
        	ApexPages.StandardController sc = new ApexPages.StandardController(acc[0]);
            PageReference pageRef = Page.PerformanceProxyCtrl;
        	Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('acctId',acc[0].id);
            PerformanceProxyCtrl console = new PerformanceProxyCtrl(sc);
        	console.redirectPage();
        	console.redirectMobile();
            
            //system.assertEquals(pageRef.getUrl(), '/apex/performanceproxyctrl?acctId='+acc[0].id);
        }
}