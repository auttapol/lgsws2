@istest
public class CollateralReportExtensionTest {
	static testMethod void CollateralReportExtensionTest() {
        test.startTest();
		List<User> us = TestUtils.createUsers(2,'Upload','Prospect','canvas@tmbbank.com',true);
        TestUtils.createStatusCode();
        TestUtils.createAppConfig();

        
        List<Account> acc = new List<Account>();
        Account acc1 = new Account ();
        acc1.Rating = 'Hot';
        acc1.IsDisqualified__c = false;
        acc1.First_name_PE__c = 'Visit';
        acc1.First_Name_ENG_PE__c = 'Visit';
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
        
        
        Collateral__c colla = new Collateral__c();
        //colla.Appraisal_Value__c = 123;
        //colla.Pledge_Value__c = 234;
        colla.Collateral_Group_Type__c = 'ASDFG';
        colla.Collateral_Group_Type_Key__c  = 'Test1234';
        colla.Account__c = acc[0].id;
        insert colla;
        
        Collateral_Detail__c colladetail = new Collateral_Detail__c();
        colladetail.Appraisal_Date__c = system.today();
        colladetail.Collateral__c = colla.id;
        insert colladetail;
        
        
        	ApexPages.StandardController sc = new ApexPages.StandardController(acc[0]);
            PageReference pageRef = Page.Collateral_Report_Mobile;
        	Test.setCurrentPage(pageRef);
            //ApexPages.currentPage().getParameters().put('acctId',acc[0].id);
            CollateralReportExtension console = new CollateralReportExtension(sc);
        	console.getCollateralData();
            
            //system.assertEquals(pageRef.getUrl(), '/apex/performanceproxyctrl?acctId='+acc[0].id);
        }
}