@isTest
private class CSEClientCreateBatchTest {
	
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
		insert acc;

		List<AccountTeamMember> accTeam = CSTestUtils.createAccountTeamMember(1,acc,u);

		List<Survey_Manager__c> smList = CSTestUtils.createSurveyManager(2);
		Survey_Sheet__c formA = CSTestUtils.insertSurveySheet(smList[0], acc.Id,u.Id,'FormA');
		Survey_Sheet__c formB = CSTestUtils.insertSurveySheet(smList[1],acc.Id,u.Id,'FormB');

		List<E_Client_Suitability__c> esList = CSTestUtils.createEclient(1,acc.Id,u.Id,formA,formB);
		CSTestUtils.createCSMurexTemp(2);

		List<CS_Segment_To_Queue_Mapping__mdt> queue = CSEClientCreateBatch.queue;

	}
	
	@isTest static void executeBatch() {
		// Implement test code
		List<CS_Murex_Temp__c> mtList = [SELECT Id, Name, Murex_ID__c, RM_Code__c, Murex_Counter_Label__c, As_of_date__c FROM CS_Murex_Temp__c LIMIT 1];
		List<E_Client_Suitability__c> ecList = [SELECT Id,CS_Murex_ID__c FROM E_Client_Suitability__c Limit 1];
        
		List<E_Client_Suitability__c> ec_suspend = new List<E_Client_Suitability__c>();

		DateTime expiryDateTime;
		
		Integer d = mtList[0].As_of_date__c.day();
		Integer mo = mtList[0].As_of_date__c.month();
		Integer yr = mtList[0].As_of_date__c.year();
		expiryDateTime = DateTime.newInstance(yr, mo, d);
		String csKey = mtList[0].RM_Code__c + expiryDateTime.format('YYYYMMdd');

		for(E_Client_Suitability__c ec : ecList)
		{
			E_Client_Suitability__c ecs = new E_Client_Suitability__c(Id = ec.Id);
			ecs.CS_Status__c = 'Suspended';
			ecs.CS_Key__c = csKey;

			ec_suspend.add(ecs);
		}
		update ec_suspend;
	

        Test.startTest();

            CSEClientCreateBatch obj = new CSEClientCreateBatch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
	}
	
}