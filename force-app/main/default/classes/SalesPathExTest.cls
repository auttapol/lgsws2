@isTest
public class SalesPathExTest {

    
    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
        TestUtils.createObjUserPermission();
        TestInit.createCustomSettingTriggerMsg();     
    }
    
     public static RecordType CompletedRecordType {get{
        if(CompletedRecordType ==null){
           CompletedRecordType = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Commercial Completed' 
                                 AND sObjectType='Lead' LIMIT 1];
        }
        return CompletedRecordType;
    }set;}
    
    
     	public static String COMPLETE_COLOR;
        public static String    INCOMPLETE_COLOR;
        public static String    WARNING_COLOR;
        public static String    ERROR_COLOR;
    
   public static testmethod void LeadPath(){
        Lead leadRec = new Lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'Passport ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Individual';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.Status ='Unqualified';
        leadRec.RecordTypeID = CompletedRecordType.id;
        insert LeadRec;
         
         
         PageReference SalesPathCustomized = Page.SalesPathCustomized;
        Test.setCurrentPage(SalesPathCustomized);
         
         
       	ApexPages.StandardController ctrl = new ApexPages.StandardController(leadRec);
            SalesPathEx LeadExten = new SalesPathEx(ctrl);
       		 COMPLETE_COLOR = LeadExten.COMPLETE_COLOR;
       		 INCOMPLETE_COLOR =  LeadExten.INCOMPLETE_COLOR;
       		 WARNING_COLOR = LeadExten.WARNING_COLOR;
       		 ERROR_COLOR = LeadExten.ERROR_COLOR;
       		 WARNING_COLOR = LeadExten.WARNING_COLOR;
       		List<Account> accList = TestUtils.createAccounts(1, 'test', 'CType', true);
            List<Opportunity> oppList = TestUtils.createOpportunity(1, accList.get(0).Id, true);
       Test.startTest();
       Opportunity oppty = oppList.get(0);
       oppty.StageName = 'CA-Prep';
       update oppty;
       oppty.StageName = 'Close Won';
       update oppty;
       
         Test.stopTest();
        	ApexPages.StandardController ctrl2 = new ApexPages.StandardController(oppty);
            SalesPathEx OppExten = new SalesPathEx(ctrl2);
         	
			
     
    }
    
}