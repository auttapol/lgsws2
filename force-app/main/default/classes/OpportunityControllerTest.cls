@IsTest
public class OpportunityControllerTest {

    static {
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
		TestUtils.createObjUserPermission();
        TestInit.createCustomSettingTriggerMsg();
    }
    
    public static testmethod void ControllerTest(){
      
        Opportunity opp = new Opportunity();
		opp.Expected_submit_date__c = System.today();
        opp.CloseDate = System.today();
        opp.StageName = 'Analysis';
        Opp.Description = 'Test';
        opp.Name = 'Test';
         PageReference oppcreate = Page.OpportunityCreation;
       
        RecordType rts = [SELECT ID, name,SObjectType FROM RecordType 
                                     WHERE SObjectType = 'Opportunity'
                                	 AND Name ='SE Credit Product'
                          			  LIMIT 1];
        Call_Report__c report = new Call_Report__c();
        Account acct = TestUtils.createAccounts(1, 'OppConTest', 'Individual', false).get(0);
        acct.OwnerId = Userinfo.getUserId();
        insert acct;
        report.Customer_name__c = acct.id;
        System.debug(acct.OwnerId);
        report.Status__c ='2 - Completed';
        report.Categories__c = 'Pre boarding';
        report.Main_purpose__c ='First visit';
        report.Date_of_Visit__c  = System.today();
        report.Complete_Date__c = System.today();
        report.Outcome__c ='Win Deal';
        report.OwnerId = Userinfo.getUserId();
        report.Actual_Visit_Date__c = System.today();
        report.Sub_Purpose__c = 'Credit';
        
        insert report;
        
        
        oppcreate.getParameters().put('recordType',rts.id);
		oppcreate.getParameters().put('visitPlanID',report.id);
        Test.setCurrentPage(oppcreate);

        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(opp);
        
        OpportunityController controller = new OpportunityController(stdController);
        controller.save();
        Test.stopTest();
    }
    
    public static testmethod void RecordTypeTest(){
        PageReference oppType = Page.OpportunityRecordType;
		Opportunity opp = new Opportunity();
		opp.Expected_submit_date__c = System.today();
        opp.CloseDate = System.today();
        opp.StageName = 'Analysis';
        Opp.Description = 'Test';
        opp.Name = 'Test';
        
        RecordType rts = [SELECT ID, name,SObjectType FROM RecordType 
                                     WHERE SObjectType = 'Opportunity'
                                	 AND Name ='SE Credit Product'
                          			  LIMIT 1];
               oppType.getParameters().put('visitplanID','');
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(opp);
        
        OpportunityRecordTypeSelection controller = new OpportunityRecordTypeSelection(stdController);
         controller.next();
        Test.stopTest();
    }
}