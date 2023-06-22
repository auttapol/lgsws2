@isTest
private class CS_EClientSuitabilityUtilTest {

	@testSetup static void setupData(){

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

		List<CS_Segment_To_Queue_Mapping__mdt> queue = CS_EClientSuitabilityUtil.queue;
	}
	
	@isTest static void getSaleOwner() {

		List<CS_Murex_Temp__c> mtList = [SELECT Id, Name, Murex_ID__c, RM_Code__c, Murex_Counter_Label__c, As_of_date__c FROM CS_Murex_Temp__c LIMIT 1];

		Account acc = [SELECT Id,TMB_Customer_ID_PE__c FROM Account LIMIT 1];

		acc.TMB_Customer_ID_PE__c = mtList[0].RM_Code__c;

		update acc;

		Map<String,Account> idAccountMap = new Map<String,Account>();
		List<Account> accList = [SELECT Id,TMB_Customer_ID_PE__c,OwnerId,Core_Banking_Suggested_Segment__c,Customer_Segment_Team__c
								FROM Account];

		for( Account accOb : accList ){
			idAccountMap.put( accOb.TMB_Customer_ID_PE__c , accOb );
		}

		List<AccountTeamMember> accTeam = [SELECT Id, AccountId,TeamMemberRole, 
												UserId,  Account.TMB_Customer_ID_PE__c 
						  				FROM AccountTeamMember];

		Map<String,List<AccountTeamMember>> idAccountTeamMap = new Map<String,List<AccountTeamMember>>();
		for( AccountTeamMember atm : accTeam )
		{
			List<AccountTeamMember> actList = new List<AccountTeamMember>();
			
			actList.add(atm);
			idAccountTeamMap.put( atm.Account.TMB_Customer_ID_PE__c  , actList );
		}
		CS_EClientSuitabilityUtil.getSaleOwner(mtList[0].RM_Code__c,idAccountMap,idAccountTeamMap);
	}
	@isTest static void getEClientOwner() {

		List<CS_Murex_Temp__c> mtList = [SELECT Id, Name, Murex_ID__c, RM_Code__c, Murex_Counter_Label__c, As_of_date__c FROM CS_Murex_Temp__c LIMIT 1];
		Map<String,Group> queueNameIdMap = new Map<String,Group>();
		Map<String,Group>  segmentQueueMap = new Map<String,Group> ();
		
		List<Group> groupList  = [SELECT Id, Name, DeveloperName,Type, OwnerId FROM Group Where Type = 'Queue'  ];

		for(Group g : groupList)		
		{
			queueNameIdMap.put(g.DeveloperName ,g );
		}
		for( CS_Segment_To_Queue_Mapping__mdt x : CS_EClientSuitabilityUtil.queue )
		{
			segmentQueueMap.put( x.Fx_Sales_Segment__c , queueNameIdMap.get(x.Queue__c) );
		}
		

		Account acc = [select Id from Account LIMIT 1];

		acc.TMB_Customer_ID_PE__c = mtList[0].RM_Code__c;

		update acc;

		Map<String,Account> idAccountMap = new Map<String,Account>();
		List<Account> accList = [SELECT Id,TMB_Customer_ID_PE__c,OwnerId,Core_Banking_Suggested_Segment__c,Customer_Segment_Team__c
								FROM Account];

		for( Account accOb : accList ){
			idAccountMap.put( accOb.TMB_Customer_ID_PE__c , accOb );
		}

		List<AccountTeamMember> accTeam = [SELECT Id, AccountId,TeamMemberRole, 
												UserId,  Account.TMB_Customer_ID_PE__c 
						  				FROM AccountTeamMember];

		Map<String,List<AccountTeamMember>> idAccountTeamMap = new Map<String,List<AccountTeamMember>>();
		for( AccountTeamMember atm : accTeam )
		{
			List<AccountTeamMember> actList = new List<AccountTeamMember>();
			actList.add(atm);
			idAccountTeamMap.put( atm.Account.TMB_Customer_ID_PE__c  , actList );
		}

		CS_EClientSuitabilityUtil.getEClientOwner(mtList[0].RM_Code__c,idAccountMap,idAccountTeamMap,segmentQueueMap);

	}

	@isTest static void getEClientOwner2() {

		List<CS_Murex_Temp__c> mtList = [SELECT Id, Name, Murex_ID__c, RM_Code__c, Murex_Counter_Label__c, As_of_date__c FROM CS_Murex_Temp__c LIMIT 1];
		Map<String,Group> queueNameIdMap = new Map<String,Group>();
		Map<String,Group>  segmentQueueMap = new Map<String,Group> ();
		
		List<Group> groupList  = [SELECT Id, Name, DeveloperName,Type, OwnerId FROM Group Where Type = 'Queue'  ];

		for(Group g : groupList)		
		{
			queueNameIdMap.put(g.DeveloperName ,g );
		}
		for( CS_Segment_To_Queue_Mapping__mdt x : CS_EClientSuitabilityUtil.queue )
		{
			segmentQueueMap.put( x.Fx_Sales_Segment__c , queueNameIdMap.get(x.Queue__c) );
		}
		

		Account acc = [select Id from Account LIMIT 1];

		acc.TMB_Customer_ID_PE__c = mtList[0].RM_Code__c;

		update acc;

		Map<String,Account> idAccountMap = new Map<String,Account>();
		List<Account> accList = [SELECT Id,TMB_Customer_ID_PE__c,OwnerId,Core_Banking_Suggested_Segment__c,Customer_Segment_Team__c
								FROM Account];

		for( Account accOb : accList ){
			idAccountMap.put( accOb.TMB_Customer_ID_PE__c , accOb );
		}

		List<AccountTeamMember> accTeam = [SELECT Id, AccountId,TeamMemberRole, 
												UserId,  Account.TMB_Customer_ID_PE__c 
						  				FROM AccountTeamMember Where TeamMemberRole = 'Test'];

		Map<String,List<AccountTeamMember>> idAccountTeamMap = new Map<String,List<AccountTeamMember>>();
		for( AccountTeamMember atm : accTeam )
		{
			List<AccountTeamMember> actList = new List<AccountTeamMember>();
			actList.add(atm);
			idAccountTeamMap.put( atm.Account.TMB_Customer_ID_PE__c  , actList );
		}

		CS_EClientSuitabilityUtil.getEClientOwner(mtList[0].RM_Code__c,idAccountMap,idAccountTeamMap,segmentQueueMap);

	}

	@isTest static void getRM() {

		List<CS_Murex_Temp__c> mtList = [SELECT Id, Name, Murex_ID__c, RM_Code__c, Murex_Counter_Label__c, As_of_date__c FROM CS_Murex_Temp__c LIMIT 1];

		Account acc = [select Id from Account LIMIT 1];

		Map<String,Account> idAccountMap = new Map<String,Account>();
		List<Account> accList = [SELECT Id,TMB_Customer_ID_PE__c,OwnerId,Core_Banking_Suggested_Segment__c,Customer_Segment_Team__c
								FROM Account];

		for( Account accOb : accList ){
			idAccountMap.put( accOb.TMB_Customer_ID_PE__c , accOb );
		}

		CS_EClientSuitabilityUtil.getRM(mtList[0].RM_Code__c,idAccountMap);
	}

	
}