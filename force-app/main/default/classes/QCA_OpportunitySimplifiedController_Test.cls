@isTest
public class QCA_OpportunitySimplifiedController_Test {
    
    @testSetup 
    static void setup() {
        TestUtils.createAppConfig();
        AppConfig__c mc = AppConfig__c.getValues('runtrigger');
        mc.Value__c = 'true';
        update mc;

        User User01 = RTL_TestUtility.createUsers(1, 'TestMock', 'SmartBDM', 'smartbdm@tmb.com.test', false).get(0);
		User01.ProfileId = QCA_LeadSimplifiedController_Test.BDM_PROFILE_ID;
		User01.isActive = true;
		User01.title = 'Branch Manager';
		// User01.RTL_Branch_Code__c = bz.Branch_Code__c;
		User01.Employee_ID__c = '123456';
		insert User01;

        String dateInString = DateTime.Now().format('MMddyyyyhhmmss');
        Account acct = TestUtils.createAccounts(1, 'test', 'CType', false).get(0);
		acct.Customer_Type__c = 'Individual';
		acct.OwnerID = User01.Id;
		acct.RecordTypeId = QCA_LeadSimplifiedController_Test.PROSPECT_ID;
        acct.Customer_Type__c = 'Juristic';
        acct.ID_Type_PE__c = 'BRN ID';
        acct.ID_Number_PE__c = dateInString + '99901';
		insert acct;

        Opportunity oppty = TestUtils.createOpportunity(1, acct.Id, false).get(0);
        oppty.OwnerId = User01.Id;
        insert oppty;
    }

    public static List<Opportunity> getOpportunityList(){
        return [SELECT Id FROM Opportunity];
    }

    @isTest
    static void test_QCA_OpportunitySimplifiedController_positive() {
        List<Opportunity> opptyList = getOpportunityList();
        QCA_OpportunitySimplifiedController.getDeepLink();
        QCA_OpportunitySimplifiedController.getRecordTypeSimplifiedOpportunity();
        QCA_OpportunitySimplifiedController.getOpportuniyObjById(opptyList.get(0).Id);
        QCA_OpportunitySimplifiedController.updateTrackStatus((String)opptyList.get(0).Id, '0');
        QCA_OpportunitySimplifiedController.getOpportuniyObjById('006N000000DNSHOIA4');
    }
}