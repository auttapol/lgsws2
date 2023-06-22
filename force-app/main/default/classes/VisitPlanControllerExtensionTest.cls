@istest
public class VisitPlanControllerExtensionTest {
    
    static testMethod void VisitPlanControllerExtensionTest() {
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
        
        
		Recordtype visitplanrec = [SELECT Id,Name FROM RecordType where name = 'Visit Plan / Report'];
        Call_Report__c visitplan1 = new Call_Report__c(Customer_name__c=acc[0].id,Date_of_Visit__c=system.today(),Categories__c='Pre boarding',
                                           Main_purpose__c='First visit',Sub_Purpose__c = 'Credit',Status__c='1 - Open',Business_talk_and_opportunity__c='test12345');
        
		insert visitplan1;
        
        Visit_Report__c visitreport1 = new Visit_Report__c(Visit_Plan_Report__c = visitplan1.id,Business_Talk_Opportunity__c = '12354',
                                                           Additional_Comments__c = '123145');
        insert visitreport1;
        	ApexPages.StandardController sc = new ApexPages.StandardController(visitplan1);
            PageReference pageRef = Page.VisitPlanVisitResult;
        	Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', visitplan1.id);
            VisitPlanControllerExtension console = new VisitPlanControllerExtension(sc);
        	console.checkrender();
        
        
        	ApexPages.StandardController sc2 = new ApexPages.StandardController(visitreport1);
            PageReference pageRef2 = Page.VisitPlanVisitResult;
        	Test.setCurrentPage(pageRef2);
            ApexPages.currentPage().getParameters().put('id', visitreport1.id);
            VisitPlanControllerExtension console2 = new VisitPlanControllerExtension(sc2);
        	console2.checkrender();

        test.stopTest();
    }
}