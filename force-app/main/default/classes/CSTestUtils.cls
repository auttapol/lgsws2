public with sharing class CSTestUtils {

	public static Id acctRT = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Customer').getRecordTypeId();
	public static final Id SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

	public static List<User> createUsers(Integer size , String FName , String LName , String Email , Boolean doInsert) {
        List<User> userToCreate = new List<User>();
        for(Integer i = 0;i<size;i++){
            User newUser = new User(FirstName = FName+i , LastName = LName+i, 
                                    UserName=FName+i+LName+i+'@tmbbank.com',
                                    Email=Email, Alias='Testtmb'+i,
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname=FName+i+'_'+LName+i+'_'+'TMBTesttmb'+i,
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='MM01'+i);
            userToCreate.add(newUser);
        }
        
        if(doInsert){
            
            insert userToCreate;
        }
        
        return userToCreate;
    }

	public static List<Account> createAccounts(Integer size , Boolean doInsert)
    {
        List<Account> accountsToCreate = new List<Account>();
        RecordType recordType = [select Id from RecordType where developername='Retail_Prospect' and SobjectType = 'Account' and IsActive = true limit 1];
        for(Integer i =1 ; i<=size ;i++)
        {   
            Account acct = new Account(); 
            acct.Name = 'Test RTL Account '+i;
            acct.First_Name_PE__c = 'Test';
            acct.Last_name_PE__c = 'RTL Account '+i;
            acct.Phone ='1111111111';
            acct.Mobile_Number_PE__c  = '1111111111';
            acct.ID_Type_PE__c = 'Passport ID';
            acct.ID_Number_PE__c = '11111' + i;
            acct.RTL_NID__c = '1111' + i;
            acct.RecordType = recordType;
            acct.TMB_Customer_ID_PE__c  =  '001p000000CKy8AAD' + i;
            acct.RTL_RM_Name__c = 'RTL02';
            acct.RecordTypeId = acctRT;
            //acct.TMB_Customer_ID_PE__c = '000000000000000000000'+i;
            
            accountsToCreate.add(acct);    
        }
        
        if(doInsert){
                insert accountsToCreate;
        }
        
        return accountsToCreate;
    }    

	public static Contact createContacts(Account acc){

        Contact cont = new Contact();
        cont.AccountId = acc.id;
        cont.Salutation = 'Mr.';
        cont.LastName = 'TestMock'; 
        cont.Date_of_Birth__c = Date.today();
        cont.Position__c = 'position1';
        cont.Value_Style__c = 'Risk Awareness';
        cont.Decision_Map__c = 'User';
        cont.Product_Decision__c = '';
        cont.Description__c = 'contact description';
        cont.OwnerId  = acc.OwnerId;

        return cont;
    }

	public static List<AccountTeamMember> createAccountTeamMember(Integer size,Account acc,User user)
	{

		List<AccountTeamMember> accTeamList = new List<AccountTeamMember>();
		for(Integer i=0 ;i<size ;i++)
		{
			AccountTeamMember accTeam = new AccountTeamMember();
			accTeam.AccountId = acc.Id;
			accTeam.TeamMemberRole = 'Fx Sales';
			accTeam.UserId = user.Id;
			accTeamList.add(accTeam);
		}
		insert accTeamList;
		return accTeamList;
		
	}

	public static List<CS_Murex_Temp__c> createCSMurexTemp(Integer size)
	{

		List<CS_Murex_Temp__c> mtList = new List<CS_Murex_Temp__c>();
		for(Integer i=0 ;i<size ;i++)
		{
			CS_Murex_Temp__c mt = new CS_Murex_Temp__c();
			//mt.Name = 'MurexTest'+i;
			mt.Murex_ID__c  = 'Tortest'+i;
			mt.RM_Code__c = '000000000000'+i;
			mt.Murex_Counter_Label__c  = 'LabelTest'+i; 
			mt.As_of_date__c = Date.today();
			mt.Murex_Create_Date__c = Date.today();
			// mt.CS_Expiry_Date__c = Date.today().addMonths(2);
			mt.Suspend_Flag__c = false;
			mtList.add(mt);
		}
		insert mtList;
		return mtList;
		
	}
	
	public static List<E_Client_Suitability__c> createEclient(Integer size,Id accId,Id userId,Survey_Sheet__c formA ,Survey_Sheet__c formB)
	{
		
		List<E_Client_Suitability__c> ecList = new List<E_Client_Suitability__c>();
		for(Integer i=0 ;i<size ;i++)
		{
			E_Client_Suitability__c ec = new E_Client_Suitability__c();
			ec.CS_Murex_ID__c = 'Test'+i;
			//ec.CS_Customer__c = '001O000001Nf3cpIAB';
			//ec.CS_RM__c =  '005O0000005NRhHIAW';
			//ec.CS_Sales_Owner__c = '005O0000005NRhHIAW';
			ec.CS_Customer__c = accId;
			ec.CS_RM__c =  userId;
			ec.CS_Sales_Owner__c = userId;
			//Survey_Sheet__c formA = CSTestUtils.insertSurveySheet(smA, ec.CS_Customer__c, ec.CS_RM__c,'FormA');
			//Survey_Sheet__c formB = CSTestUtils.insertSurveySheet(smB,ec.CS_Customer__c,ec.CS_Sales_Owner__c,'FormB');
			ec.CS_Customer_Survey_A__c = formA.Id;
			ec.CS_Customer_Survey_B__c = formB.Id;
			// ec.CS_Stamped_Customer_Segment__c = 'CB';
			
			ecList.add(ec);
		}
		insert ecList;
		
		return ecList;
	}

	public static List<Survey_Manager__c> createSurveyManager(Integer size)
	{

		List<Survey_Manager__c> smList = new List<Survey_Manager__c>();
		for(Integer i=0 ;i<size ;i++)
		{
			Survey_Manager__c sm = new Survey_Manager__c();
			sm.Name = 'SurveyTest'+i;
			sm.CS_Survey_Manager_Key__c  = 'SurveyKeyTest'+i;
			smList.add(sm);
		}
		insert smList;
		return smList;
		
	}

	public static Survey_Version__c createSurveyVersion(Integer version,Survey_Manager__c sm )
	{
		Survey_Version__c sv = new Survey_Version__c();

		sv.Name = 'SurveyTest'+version;
		sv.CS_Survey_Version_Key__c = 'SurveyVersionKey'+version;
		sv.Active_Status__c  = true;
		sv.version__c = version;
		sv.Survey_Manager__c = sm.Id;

		insert sv;

		Survey_Manager__c smUpdate = new Survey_Manager__c(Id = sm.Id);
		smUpdate.Survey_Version__c = sv.Id;

		return sv;
	}


	public static Survey_Sheet__c insertSurveySheet( Survey_Manager__c sm , String  eCustomerId ,String ownerNameId,String type )
    {
		Survey_Sheet__c sh = new Survey_Sheet__c();
		sh.Survey_Version__c = sm.Survey_Version__c;
		sh.Info_1__c = sm.name;
		sh.Customer__c = eCustomerId;
		sh.OwnerId = ownerNameId;
		sh.Status__c = 'New';

		insert sh;	
		//createSurveyQuestion(sh.Survey_Version__c,sh);
		return sh;
	}


	public static Survey_Question__c createSurveyQuestion(Id svId)
	{
			Survey_Question__c sq = new Survey_Question__c();
			sq.Name = 'QuestionTest';
			sq.Survey_Version__c = svId;
			sq.Active_Status__c  = true;
			sq.Question_Number__c = 1;
			sq.Require_Input__c = 'Not Require'; 
			sq.Score_Calculate_Type__c = 'Max';

			insert sq;

			// createSurveyChoice(sq,sh);
			// createSurveySubQuestion(svId,sh,sq);

			return sq;
	}
	public static Survey_Question__c createSurveySubQuestion(Id svId,Survey_Question__c sqParent)
	{
			Survey_Question__c sq = new Survey_Question__c();
			sq.Name = 'SubQuestionTest';
			sq.Survey_Version__c = svId;
			sq.Active_Status__c  = true;
			sq.Question_Number__c = 1;
			sq.Parent_Question__c = sqParent.Id;
			sq.Require_Input__c = 'Not Require';
			sq.Score_Calculate_Type__c = 'Min';

			insert sq;

			// createSurveyChoiceSub(sq,sh);
			return sq;
	}

	public static Survey_Choice__c createSurveyChoice(Survey_Question__c sq)
	{

		Survey_Choice__c sc = new Survey_Choice__c();
		sc.Name = 'ChoiceTest';
		sc.Label__c = 'TestLabel';
		sc.Survey_Question__c  = sq.Id;
		sc.Option_Type__c = 'Checkbox';
		sc.Score__c = 2;

		insert sc;

		// createSurveyAnswer(sq,sc,sh);

		return sc;

	}

	public static Survey_Choice__c createSurveyChoiceSub(Survey_Question__c sq)
	{

		Survey_Choice__c sc = new Survey_Choice__c();
		sc.Name = 'ChoiceSubTest';
		sc.Label__c = 'TestLabel';
		sc.Survey_Question__c  = sq.Id;
		sc.Option_Type__c = 'Checkbox';
		sc.Dependent_Question__c = sq.Id;
		sc.Dependent_Question_Render_Type__c = 'After All Choice';

		insert sc;

		// createSurveyAnswer(sq,sc,sh);

		return sc;

	}



	public static Survey_Answer__c createSurveyAnswer(Survey_Question__c sq,Survey_Choice__c sc,Survey_Sheet__c sh)
	{

		Survey_Answer__c sa = new Survey_Answer__c();
		sa.Survey_Question__c  = sq.Id;
		sa.Survey_Choice__c = sc.Id;
		sa.Survey_Sheet__c = sh.Id;
		sa.Choice_Value__c = 'true';
		sa.Choice_Checked__c = true;
		sa.Score__c = 0;

		insert sa;
		return sa;

	}

	public static Survey_Score__c createSurveyScore(Survey_Manager__c sm )
	{

		Survey_Score__c sc = new Survey_Score__c();
		sc.Survey_Manager__c = sm.Id;
		sc.Low_score_range__c = 20;
		sc.Hight_score_range__c = 99;
		insert sc;
		return sc;

	}

}