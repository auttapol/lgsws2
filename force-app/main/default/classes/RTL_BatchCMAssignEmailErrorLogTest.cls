@isTest
public class RTL_BatchCMAssignEmailErrorLogTest {
	static {
        TestUtils.createAppConfig();
    }  

	public static testMethod void positive() {    

        Id recordTypeId  = [select Id from RecordType where SobjectType = 'Campaign' and DeveloperName=: 'Dummy_Campaign' and IsActive=true ].Id;

		RTL_Campaign_Assignment_Rule__c obj = new RTL_Campaign_Assignment_Rule__c();
        obj.RTL_Campaign_Lead_Source__c = 'web';
        obj.RTL_Start_Date__c = System.today()-10;
        obj.RTL_End_Date__c = System.today()+10;
        obj.RTL_Active__c = true;
        insert obj;
        
        Campaign camp = new Campaign();
        camp.Name = 'Campaign_';
        camp.Segment__c = 'MB';
        camp.OwnerId  = UserInfo.getUserId();
        camp.RecordTypeId = Recordtypeid;
        insert camp;
        
        List<Lead> leads = RTL_TestUtility.createLeads(2,true);
        //List<CampaignMember> campList = RTL_TestUtility.createCampaignmemberWithLead(leads,camp.id,true);

        Test.startTest();

        /*String query ='SELECT Id, Name FROM CampaignMember';
        RTL_BatchCMAssignEmailErrorLog email = new RTL_BatchCMAssignEmailErrorLog(query);
        Id BatchProcessId = Database.ExecuteBatch(email);*/

        Test.stopTest();


	
		
	}
}