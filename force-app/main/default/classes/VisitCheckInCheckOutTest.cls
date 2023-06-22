@isTest
public class VisitCheckInCheckOutTest {
    
    static account acct;
    
    static testmethod void visitcheckinout()
    {
        test.startTest();
        insert new AppConfig__c(name = 'runtrigger', value__c = 'TRUE');
        insert new Status_Code__c(name = '7011', Status_Message__c = 'sm', Events__c = 'ev');
        
        TestUtils.createAppConfigRetailtoComm();
        
        acct = testutils.createAccounts(1, 'fname', 'Individual', true).get(0);
            acct.ownerid = userinfo.getUserId();
            update acct;

        call_report__c cr = new call_report__c(Customer_name__c = acct.id,Date_of_Visit__c = date.today(),Categories__c = 'Pre boarding',Main_purpose__c = 'First visit',Sub_Purpose__c = 'Credit');
            cr.RecordTypeId = [select id from recordtype where name ='Visit Plan / Report'].get(0).id;
            insert cr;
        call_report__c cr2 = new call_report__c(Customer_name__c = acct.id,Date_of_Visit__c = date.today(),Categories__c = 'Pre boarding',Main_purpose__c = 'First visit',Sub_Purpose__c = 'Credit');
            cr.RecordTypeId = [select id from recordtype where name ='Visit Plan / Report'].get(0).id;
            insert cr2;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cr);
        PageReference checkinoutpage = Page.VisitGetGeoLocation;
        checkinoutpage.getParameters().put('id',cr.id);
        checkinoutpage.getParameters().put('typeVisit','in');
        checkinoutpage.getParameters().put('lat','10');
        checkinoutpage.getParameters().put('lon','10');
        Test.setCurrentPage(checkinoutpage);
        VisitCheckInCheckOut vc = new VisitCheckInCheckOut(sc);
        pagereference pr1 = vc.RedirectCheckInOut();
        pagereference pr2 = vc.BackPage();
        vc.CheckIn();
        vc.CheckIn();
        vc.CheckOut();
        vc.CheckOut();
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(cr2);
        PageReference checkinoutpage2 = Page.VisitGetGeoLocation;
        checkinoutpage2.getParameters().put('id',cr2.id);
        checkinoutpage2.getParameters().put('typeVisit','out');
        checkinoutpage2.getParameters().put('lat','');
        checkinoutpage2.getParameters().put('lon','');
        Test.setCurrentPage(checkinoutpage2);
        VisitCheckInCheckOut vc2 = new VisitCheckInCheckOut(sc2);
        pr1 = vc2.RedirectCheckInOut();
        pr2 = vc2.BackPage();
        vc2.CheckOut();
        
        test.stopTest();
    }
    
}