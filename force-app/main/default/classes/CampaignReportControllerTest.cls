@isTest
public class CampaignReportControllerTest {
	@isTest
    static void test(){
        TestUtils.createAppConfig();
        String master = [SELECT Id, Name From recordtype where developername = 'Master_Campaign' LIMIT 1].Id;
        String exclusive = [SELECT Id, Name From recordtype where developername = 'Exclusive_Campaign' LIMIT 1].Id;
        Campaign c1 = new Campaign();
        c1.RTL_Campaign_Type__c = 'Mass';
        c1.Name = 'This is a Campaign';
        c1.RecordTypeId = master;
        c1.RTL_Campaign_Code_9_digits__c = 'M11111111';
        insert c1;
        /*
         Campaign c2 = new Campaign();
        c2.RTL_Campaign_Type__c = 'Mass';
        c2.Name = 'This is a Campaign';
        c2.RecordTypeId = master;
        c2.RTL_Campaign_Code_10_digits__c = '1234567890';
        insert c;
*/
        CampaignReportController.getCampaignList();
    }
    
}