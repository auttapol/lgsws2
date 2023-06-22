@isTest
public class CallCenter_CSVCtrlTest {
    static {
        TestUtils.createAppConfig();
    }  
    
    public static testMethod void positive() {
        
        /*User retailUser = RTL_TestUtility.createRetailTestUser(true);
        System.runAs(retailUser) {
            
        }*/

        Verification_History__c verify = new Verification_History__c();
        verify.Verification_Type__c = 'TMB ID';
        verify.Verification_Result__c = 'Success';
        verify.Verification_Status__c = '02 ActiveCustomer'; 
        verify.Verification_Date_Time__c = Datetime.Now();
        insert verify;

        System.currentPageReference().getParameters().put('verf_hist_id',verify.Id);
        
        List<Account> accList = RTL_TestUtility.createAccounts(1,true);
        Test.setMock(WebServiceMock.class, new RTL_CvsAnalyticsDataServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCallMeNow(1,'body'));
        Test.startTest();
        System.currentPageReference().getParameters().put('Id',accList.get(0).Id);
        //ApexPages.StandardController sc = new ApexPages.StandardController(accList.get(0));
        CallCenter_CSVCtrl cls = new CallCenter_CSVCtrl();       
        Continuation contX = new Continuation(60);
        cls.CallSOAP(contX);
        cls.editMode();        
        cls.save();
        cls.cancel();
        cls.currentObject.id = null;
        cls.save();
        cls.processResponseSOAP();
        CVSAnalyticsDataDTO data = new CVSAnalyticsDataDTO();
        data.ibStatus = 'Y';
        CallCenter_CSVCtrl.wrapperWealthData a = new CallCenter_CSVCtrl.wrapperWealthData(data);
        CallCenter_CSVCtrl.wrapperNoteAndAttach b = new CallCenter_CSVCtrl.wrapperNoteAndAttach(new NoteAndAttachment(),'');
        CallCenter_CSVCtrl.wrapperActivityHistory c = new CallCenter_CSVCtrl.wrapperActivityHistory(new ActivityHistory(),'');
        cls.getMessengerCoverArea('');
        cls.DoNotContactList.add( new RTL_Do_not_Contact_Info__c() );
         cls.CustomerComplaintList.add( new Customer_Complaint__c() );
         cls.OpportunityList.add( new Opportunity() );
        cls.ReferralsList.add( new RTL_Referral__c() );
        cls.OpenActivityList.add( new OpenActivity() );
        cls.InterestedProductList.add( new RTL_Interested_products_c__c() );
        cls.AccountHistoryList.add( new AccountHistory() );
        cls.getCheckPermissionRecord();
        Test.stopTest();
        
    }
    
}