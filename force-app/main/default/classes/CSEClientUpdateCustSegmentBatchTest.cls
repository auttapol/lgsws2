@isTest
private class CSEClientUpdateCustSegmentBatchTest {
	
	@testSetup static void setup() {
		// Implement test code
		List<AppConfig__c> mc = new List<AppConfig__c> ();
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        mc.Add(new AppConfig__c(Name = 'runCustomerNoteTrigger', Value__c = 'false'));
        insert mc;

        User u = CSTestUtils.createUsers(1, 'UserTestqqq' ,'Userqqq' , 'test22@email.com' , false).get(0);
        u.IsActive = true;
        insert u;

		Account acc = CSTestUtils.createAccounts(1,false).get(0);
		acc.Murex_Counter_Label__c = 'eclient';
		acc.TMB_Customer_ID_PE__c = '001100000000000000000000120183';
		acc.Segment_crm__c = '1';
		insert acc;

		List<AccountTeamMember> accTeam = CSTestUtils.createAccountTeamMember(1,acc,u);

		List<Survey_Manager__c> smList = CSTestUtils.createSurveyManager(2);
		Survey_Sheet__c formA = CSTestUtils.insertSurveySheet(smList[0], acc.Id,u.Id,'FormA');
		Survey_Sheet__c formB = CSTestUtils.insertSurveySheet(smList[1],acc.Id,u.Id,'FormB');

		List<E_Client_Suitability__c> esList = CSTestUtils.createEclient(1,acc.Id,u.Id,formA,formB);

		CSTestUtils.createCSMurexTemp(2);

	}
	
	@isTest static void executeBatch() {
		// Implement test code
		Account acc = [SELECT Id,Segment_crm__c,Customer_Segment_Team__c,Core_Banking_Suggested_Segment__c 
		FROM Account Where TMB_Customer_ID_PE__c = '001100000000000000000000120183' LIMIT 1];
		acc.Segment_crm__c = '2';
		update acc;
	
        Test.startTest();
		
            CSEClientUpdateCustSegmentBatch obj2 = new CSEClientUpdateCustSegmentBatch();
            DataBase.executeBatch(obj2); 

        Test.stopTest();

	}
	
}