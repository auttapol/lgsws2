global class CSEClientCreateBatch implements Database.Batchable<sObject> {
	
	public String query;
	public Date lastExpiryDate;

	public static String SURVEY_TYPE = 'E-Client Suitability';

	public static string CS_STATUS_PENDING = 'Pending Review';
	public static string CS_STATUS_SUSPENDED = 'Suspended';

	public static List<CS_Segment_To_Queue_Mapping__mdt> queue 
	{
		get{

			if(queue == null)
			{

				queue = [SELECT Fx_Sales_Segment__c,Queue__c FROM CS_Segment_To_Queue_Mapping__mdt];
			}

			return queue;
		}
		set;
	}
	
	global CSEClientCreateBatch() {

		lastExpiryDate = Date.today().addMonths(2);

		// Get all Murex item to update
		query = 'SELECT name,Murex_ID__c, Id, RM_Code__c, CS_Expiry_Date__c, CS_Level__c, CS_Sign_Date__c, '+ 
			'Suspend_Flag__c, Murex_Last_Modified_Date__c, CS_Create_E_Client_Time_Stamp__c, CS_Is_Updated_From_Murex__c, ' +
			'Murex_Create_Date__c,As_of_date__c,Murex_Counter_Label__c ' +
			'FROM CS_Murex_Temp__c '+
			'WHERE CS_Is_Updated_From_Murex__c = true '

			;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

   		List<E_Client_Suitability__c> eClientList = new List<E_Client_Suitability__c>();
		List<Account> accountList = new List<Account>();
		List<E_Client_Suitability__c> eClient_SuspendList = new List<E_Client_Suitability__c>();
		List<Survey_Sheet__c> shList = new List<Survey_Sheet__c>();

		List<String> suspendEClient = new List<String>();
		List<String> csKeyList = new List<String>();
		String csKey;

   		Set<String> accSet = new Set<String>();

   		// Process all account in Murex to update account
   		for(sObject murexTemp : scope)
		{
			CS_Murex_Temp__c murexTempData = (CS_Murex_Temp__c)murexTemp;
			accSet.add( murexTempData.RM_Code__c );
		}

		Map<String,Account> idAccountMap = new Map<String,Account>();

		List<Account> accList = [SELECT Id,TMB_Customer_ID_PE__c,OwnerId,Core_Banking_Suggested_Segment__c,Customer_Segment_Team__c
				FROM Account WHERE TMB_Customer_ID_PE__c in :accSet ];


		for( Account acc : accList )
		{
			idAccountMap.put( acc.TMB_Customer_ID_PE__c , acc );
		}

		List<AccountTeamMember> accTeam = [SELECT Id, AccountId,TeamMemberRole, 
							 UserId,  Account.TMB_Customer_ID_PE__c 
						  FROM AccountTeamMember
						  WHERE Account.TMB_Customer_ID_PE__c in :accSet
						  AND TeamMemberRole = 'FX Sales' AND User.IsActive = true
						  ];

		
		Map<String,List<AccountTeamMember>> idAccountTeamMap = new Map<String,List<AccountTeamMember>>();
		for( AccountTeamMember atm : accTeam )
		{
			List<AccountTeamMember> actList;
			if( idAccountTeamMap.containsKey( atm.Account.TMB_Customer_ID_PE__c ) )
			{
				actList = idAccountTeamMap.get( atm.Account.TMB_Customer_ID_PE__c );
			}
			else 
			{
				actList = new List<AccountTeamMember>();
			}
			actList.add(atm);

			idAccountTeamMap.put( atm.Account.TMB_Customer_ID_PE__c  , actList );
		}

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
		
		for(sObject murexTemp : scope)
		{

			CS_Murex_Temp__c murexTempData = (CS_Murex_Temp__c)murexTemp;
			Account accountReference = new Account(TMB_Customer_ID_PE__c =  murexTempData.RM_Code__c ); 

		
			accountReference.CS_Murex_ID__c = murexTempData.Murex_ID__c;
			accountReference.CS_Level__c = murexTempData.CS_Level__c;
			accountReference.CS_Expiry_Date__c = murexTempData.CS_Expiry_Date__c;
			accountReference.CS_Sign_Date__c = murexTempData.CS_Sign_Date__c;
			accountReference.CS_Suspend_flag__c = murexTempData.Suspend_Flag__c;
			accountReference.Murex_Counter_Label__c = murexTempData.Murex_Counter_Label__c;

			accountList.add(accountReference);
		}

		if( accountList.size() > 0 )
		{
			Database.UpsertResult[] upsertResult = Database.upsert(accountList, Account.Fields.TMB_Customer_ID_PE__c , false);

		}

		for(sObject murexTemp : scope)
		{
			CS_Murex_Temp__c murexTempData = (CS_Murex_Temp__c)murexTemp;

			DateTime expiryDateTime;
			if(murexTempData.CS_Expiry_Date__c != null)
			{
				Integer d = murexTempData.CS_Expiry_Date__c.day();
				Integer mo = murexTempData.CS_Expiry_Date__c.month();
				Integer yr = murexTempData.CS_Expiry_Date__c.year();
				expiryDateTime = DateTime.newInstance(yr, mo, d);
				csKey = murexTempData.RM_Code__c + expiryDateTime.format('YYYYMMdd');
			}
			else
			{
				if(murexTempData.As_of_date__c != null)
				{
					Integer d = murexTempData.As_of_date__c.day();
					Integer mo = murexTempData.As_of_date__c.month();
					Integer yr = murexTempData.As_of_date__c.year();
					expiryDateTime = DateTime.newInstance(yr, mo, d);
					csKey = murexTempData.RM_Code__c + expiryDateTime.format('YYYYMMdd');
				}		
			}
						
			csKeyList.add(csKey);
		}

		List<E_Client_Suitability__c> ec_cskey =  [SELECT Id,CS_Status__c ,CS_Key__c,CS_Suspend_flag__c
		FROM E_Client_Suitability__c
		WHERE CS_Key__c =:csKeyList
		];

		Map<String,E_Client_Suitability__c> cskeyMap = new Map<String,E_Client_Suitability__c>();
		for( E_Client_Suitability__c ec : ec_cskey )
		{
			cskeyMap.put( ec.CS_Key__c , ec );
		}


		for(sObject murexTemp : scope)
		{
			CS_Murex_Temp__c murexTempData = (CS_Murex_Temp__c)murexTemp;

			
			if( murexTempData.CS_Expiry_Date__c > lastExpiryDate  )
			{
				// if expiry date more than 2 month , skip process e client
				continue;
			}

			DateTime expiryDateTime;
			if(murexTempData.CS_Expiry_Date__c != null)
			{
				Integer d = murexTempData.CS_Expiry_Date__c.day();
				Integer mo = murexTempData.CS_Expiry_Date__c.month();
				Integer yr = murexTempData.CS_Expiry_Date__c.year();
				expiryDateTime = DateTime.newInstance(yr, mo, d);
				csKey = murexTempData.RM_Code__c + expiryDateTime.format('YYYYMMdd');
			}
			else
			{
				if(murexTempData.As_of_date__c != null)
				{
					Integer d = murexTempData.As_of_date__c.day();
					Integer mo = murexTempData.As_of_date__c.month();
					Integer yr = murexTempData.As_of_date__c.year();
					expiryDateTime = DateTime.newInstance(yr, mo, d);
					csKey = murexTempData.RM_Code__c + expiryDateTime.format('YYYYMMdd');
				}		
			}
			

			Account accountReference = new Account(TMB_Customer_ID_PE__c =  murexTempData.RM_Code__c ); 
		

			Boolean newCustomerFlag = false;
	
			if( murexTempData.Murex_Create_Date__c == murexTempData.As_of_date__c )          
			{
				newCustomerFlag = true;
			}
			

			if( cskeyMap.containsKey( csKey ) )
			{
				if(cskeyMap.get( csKey ).CS_Key__c == csKey)
				{ 					
				
					if(cskeyMap.get( csKey ).CS_Suspend_flag__c != murexTempData.Suspend_Flag__c)
					{									
						E_Client_Suitability__c ecs = new E_Client_Suitability__c( CS_Key__c = csKey );
						ecs.CS_Suspend_flag__c = murexTempData.Suspend_Flag__c;
						ecs.CS_As_Of_Date_Murex__c = murexTempData.As_of_date__c;
						eClientList.add(ecs);	
						suspendEClient.add(csKey);		
					}

				}
					
			}
			else
			{
				if(murexTempData.Murex_ID__c != null)
				{
					E_Client_Suitability__c ecs = new E_Client_Suitability__c( CS_Key__c = csKey );

					ecs.CS_Murex_ID__c = murexTempData.Murex_ID__c;
					ecs.CS_Customer__r = accountReference;
					
					ecs.CS_Expiry_Date_Next__c = murexTempData.CS_Expiry_Date__c;
					ecs.CS_Level__c = murexTempData.CS_Level__c;
					ecs.CS_SIgn_Date__c = murexTempData.CS_Sign_Date__c;
					ecs.CS_Suspend_flag__c = murexTempData.Suspend_Flag__c;
					
					ecs.CS_New_Customer_flag__c = newCustomerFlag;
				
					ecs.CS_As_Of_Date_Murex__c = murexTempData.As_of_date__c;

					ecs.Murex_Counter_Label__c = murexTempData.Murex_Counter_Label__c;

					if(  murexTempData.Suspend_Flag__c )
					{
						ecs.CS_Status__c = CS_STATUS_SUSPENDED;
					}
					else 
					{
						ecs.CS_Status__c = CS_STATUS_PENDING;	
					}

					Id rmId = CS_EClientSuitabilityUtil.getRM( murexTempData.RM_Code__c, idAccountMap );
					Id salesOwnerId = CS_EClientSuitabilityUtil.getSaleOwner( murexTempData.RM_Code__c, idAccountMap , idAccountTeamMap );
					Id ownerId = CS_EClientSuitabilityUtil.getEClientOwner( murexTempData.RM_Code__c, idAccountMap , idAccountTeamMap,segmentQueueMap );
				
					if( rmId != null )
					{
						ecs.CS_RM__c = rmId;
					}

					if( salesOwnerId != null )
					{
						ecs.CS_Sales_Owner__c = salesOwnerId;
					}

					if( ownerId != null )
					{
						ecs.OwnerId = ownerId;
					}

					if( ecs.CS_Suspend_flag__c == false )
					{					
						if(ecs.CS_Level__c == 'Basic')
						{
							if(murexTempData.Murex_Create_Date__c == murexTempData.As_of_date__c)
							{							
								eClientList.add(ecs);				
							}
							
						}
						else
						{
							eClientList.add(ecs);
						}
									
					}
					else
					{
						eClientList.add(ecs);
					}
				}
				
			}	
			
		}

		if( eClientList.size() > 0 )
		{
			Database.UpsertResult[] upsertResult = Database.upsert(eClientList , E_Client_Suitability__c.Fields.CS_Key__c , false);
			List<CS_Murex_Temp__c> updatedtimeStampItems = new List<CS_Murex_Temp__c>();
			for (Integer i = 0; i < upsertResult.size(); i++) 
			{				
				if( upsertResult.get(i).isSuccess() )
				{
					CS_Murex_Temp__c murexTempUpdated = new CS_Murex_Temp__c();
					murexTempUpdated.Murex_ID__c = eClientList[i].CS_Murex_ID__c;
					murexTempUpdated.CS_Create_E_Client_Time_Stamp__c = System.Now();
					

					updatedtimeStampItems.add(murexTempUpdated);
				}			
			}
            Database.upsert(updatedtimeStampItems , CS_Murex_Temp__c.Fields.Murex_Counter_Label__c , false);
		}
			

		List<E_Client_Suitability__c> ec_suspend =  [SELECT Id, OwnerId,CS_Key__c,CS_Customer__c ,Name,CS_Status__c,
		CS_Suspend_flag__c ,CS_Customer_Survey_A__c, CS_Customer_Survey_B__c,CS_RM__c,CS_Sales_Owner__c,RecordTypeId
		FROM E_Client_Suitability__c
		WHERE CS_Key__c =:suspendEClient
		];

		Id pendingRecordTypeId = Schema.Sobjecttype.E_Client_Suitability__c.getRecordTypeInfosByName().get('Pending Review').getRecordTypeId();
		

		List<Survey_Answer__c> saList = new List<Survey_Answer__c>();
		List<Survey_Sheet__c> saList_suspend = new List<Survey_Sheet__c>();
		
		for(E_Client_Suitability__c ec : ec_suspend)
		{	
			E_Client_Suitability__c ecs = new E_Client_Suitability__c( CS_Key__c = ec.CS_Key__c );

			if(ec.CS_Suspend_flag__c == true)
			{				
				ecs.CS_Status__c = CS_STATUS_SUSPENDED;	

				if(ec.CS_Customer_Survey_A__c != null)
				{
					Survey_Sheet__c shA = new Survey_Sheet__c( Id = ec.CS_Customer_Survey_A__c );
					shA.Is_SurveyA_Approve__c = false;
					shA.Is_SurveyB_Approve__c = false;
					shA.Status__c = 'Cancelled';
					shList.add(shA);
				}
				if(ec.CS_Customer_Survey_B__c != null)
				{
					Survey_Sheet__c shB = new Survey_Sheet__c( Id = ec.CS_Customer_Survey_B__c );
					shB.Is_SurveyA_Approve__c = false;
					shB.Is_SurveyB_Approve__c = false;
					shB.Status__c = 'Cancelled';
					shList.add(shB);
		
				}		
				update shList;
                
                eClient_SuspendList.add(ecs);
			}
			else
			{
				if(ec.CS_Status__c == 'Suspended')
				{						
					if(ec.CS_Customer_Survey_A__c != null && ec.CS_Customer_Survey_B__c != null)
					{
						ecs.CS_Status__c = 'Reviewing';	
						ecs.Sale_Submitted_By__c = null;
						ecs.RM_TH_Approve_DT__c = null;
						ecs.Sale_Submit_Date_Time__c = null;
						ecs.RM_Submitted_By__c = null;
						ecs.RM_Submit_Date_Time__c = null; 
						ecs.Sales_TH_Approved_DT__c = null;
						ecs.CS_Sales_TH_Approved_Date_Time__c = null;
						ecs.CS_RM_TH_Approved_Date_Tme__c = null;

						Survey_Sheet__c shA = new Survey_Sheet__c( Id = ec.CS_Customer_Survey_A__c );
						shA.Is_SurveyA_Approve__c = false;
						shA.Is_SurveyB_Approve__c = false;
						shA.Status__c = 'New';
						saList_suspend.add(shA);
						Survey_Sheet__c shB = new Survey_Sheet__c( Id = ec.CS_Customer_Survey_B__c );
						shB.Is_SurveyA_Approve__c = false;
						shB.Is_SurveyB_Approve__c = false;
						shB.Status__c = 'New';
						saList_suspend.add(shB);

						update saList_suspend;
						
					}
					else
					{
						ecs.CS_Status__c = CS_STATUS_PENDING;	
						ecs.RecordTypeId = pendingRecordTypeId;
					}						
				}	

				eClient_SuspendList.add(ecs);
			}
		}

		if( eClient_SuspendList.size() > 0 )
		{
			Database.UpsertResult[] upsertResult = Database.upsert(eClient_SuspendList , E_Client_Suitability__c.Fields.CS_Key__c , false);
			List<CS_Murex_Temp__c> updatedtimeStampItems = new List<CS_Murex_Temp__c>();
			for (Integer i = 0; i < upsertResult.size(); i++) 
			{	        	
	        	if( upsertResult.get(i).isSuccess() )
	        	{
	        		CS_Murex_Temp__c murexTempUpdated = new CS_Murex_Temp__c();
	        		murexTempUpdated.Murex_ID__c = eClient_SuspendList[i].CS_Murex_ID__c;
	        		murexTempUpdated.CS_Create_E_Client_Time_Stamp__c = System.Now();
	        		

	        		updatedtimeStampItems.add(murexTempUpdated);
	        	}        	
			}
            Database.upsert(updatedtimeStampItems , CS_Murex_Temp__c.Fields.Murex_ID__c , false);
		}
	
	}

	global void finish(Database.BatchableContext BC) {
		CSEClientUpdateCustSegmentBatch segmentBatch = new CSEClientUpdateCustSegmentBatch();
		Database.executebatch(segmentBatch);
	}

	
	
}