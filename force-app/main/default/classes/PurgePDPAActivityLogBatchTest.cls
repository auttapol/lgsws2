@isTest
public class PurgePDPAActivityLogBatchTest {
    public PurgePDPAActivityLogBatchTest() {

    }

    @isTest
    public static void testExecuteBatch() {
        PDPA_Activity_Log__c activity = new PDPA_Activity_Log__c(
                Create_Date__c = Datetime.now()
            );
            
        insert activity;

        
        Test.startTest();
            Date backDate = System.Today().addDays(1);
            String q = 'SELECT Id FROM PDPA_Activity_Log__c WHERE CreatedDate <=: BACKDATE';

            database.executebatch(new PurgePDPAActivityLogBatch(q, backDate), 2000);
        Test.stopTest();
    }
}