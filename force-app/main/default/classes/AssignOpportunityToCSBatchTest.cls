@isTest
public class AssignOpportunityToCSBatchTest {
    
    @testSetup static void setup() {
		// Implement test code
		AppConfig__c mc =new AppConfig__c(Name = 'runtrigger', Value__c = 'false');
        insert mc;
                
	}
    
    @isTest static void executeBatch() {
        // Implement test code
        insert new AppConfig__c(name = 'runtrigger', value__c = 'TRUE');
        TestUtils.createAppConfigRetailtoComm();
        account acct = testutils.createAccounts(1, 'fname', 'Individual', true).get(0);
        
        Opportunity oppty = new Opportunity();
        oppty.Name = 'Test';
        oppty.RecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('SE Credit Product').getRecordTypeId();
        oppty.LeadSource = 'Lazada';
        oppty.StageName = 'Analysis'; 
        oppty.accountid = acct.id;
        oppty.ownerid = acct.ownerid;
        oppty.Expected_submit_date__c = date.today();
        oppty.closedate = date.today();
        
        insert oppty;
        
        Opportunity op = new Opportunity(Id = oppty.Id);
        op.StageName = 'Submit to Credit Process';
        op.LeadSource = 'Lazada';
        update op;
                
        Test.startTest();
        

        String q = 'SELECT Id, Name, LeadSource, StageName, CreatedDate '+ 
            'FROM Opportunity '+
            'Where StageName IN (\'Submit to Credit Process\') AND LeadSource = \'Lazada\' AND CreatedDate = TODAY'; 
        
        AssignOpportunityToCSBatch obj = new AssignOpportunityToCSBatch(q);
        obj.countOpptyError = 2;
        DataBase.executeBatch(obj); 
        
        Test.stopTest();
	}
    
    @isTest static void executeBatch2() {
        // Implement test code
        insert new AppConfig__c(name = 'runtrigger', value__c = 'TRUE');
        TestUtils.createAppConfigRetailtoComm();
        account acct = testutils.createAccounts(1, 'fname', 'Individual', true).get(0);
        
        Opportunity oppty = new Opportunity();
        oppty.Name = 'Test';
        oppty.RecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('SE Credit Product').getRecordTypeId();
        oppty.LeadSource = 'Lazada';
        oppty.StageName = 'Analysis'; 
        oppty.accountid = acct.id;
        oppty.ownerid = acct.ownerid;
        oppty.Expected_submit_date__c = date.today();
        oppty.closedate = date.today();
        
        insert oppty;
        
        Opportunity op = new Opportunity(Id = oppty.Id);
        op.StageName = 'Submit to Credit Process';
        op.LeadSource = 'Lazada';
        update op;
                
        Test.startTest();
        

        String q = 'SELECT Id, Name, LeadSource, StageName, CreatedDate '+ 
            'FROM Opportunity '+
            'Where StageName IN (\'Submit to Credit Process\') AND LeadSource = \'Lazada\' AND CreatedDate = TODAY'; 
        
        List<Opportunity> op1 = [SELECT Id FROM Opportunity LIMIT 1];
        Map<Id, String> opptyErrorMsgMap = new Map<Id, String>();
        opptyErrorMsgMap.put(op1[0].Id,'StatusCode : Test');
        Map<Id, Opportunity> opptyErrorMap = new Map<Id, Opportunity>();
        opptyErrorMap.put(op1[0].Id,op1[0]);
        
        AssignOpportunityToCSBatch obj = new AssignOpportunityToCSBatch(q);
        obj.opptyErrorMsgMap = opptyErrorMsgMap;
        obj.opptyErrorMap = opptyErrorMap;
        DataBase.executeBatch(obj); 
        
        Test.stopTest();
	}
}