@isTest
private class RTL_CampaignCallListExtensionTest {
	
	@testSetup static void setupData() 
	{
        TestUtils.createAppConfig();
		RecordType rt = [SELECT id FROM recordType WHERE DeveloperName   = 'Exclusive_Campaign_Active' ];
		//RecordType masterRt = [SELECT id FROM recordType WHERE DeveloperName = 'Master_Campaign' ];

		RTL_Campaign_Running_No__c rn = new RTL_Campaign_Running_No__c( 
                        Name ='Local Exclusive Campaign Running No.' , 
                        DateValue__c='170717',
                        Day__c='17',
                        Month__c='07',
                        Year__c='17',
                        Running_No__c = '01' );
        insert rn;

        RTL_CampaignMember_Running_No__c cmrn = new RTL_CampaignMember_Running_No__c(
        	Name = 'Campaign Member Running No',
        	Running_No__c = '000000'
        	);

        insert cmrn;

        List<AppConfig__c> mc = new List<AppConfig__c> ();
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        insert mc;


        Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '611';
        insert bz;
      
        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'User1' , 'test@email.com' , false).get(0);
        u.RTL_Branch_Code__c  = '611';
        insert u;


        Campaign masterC = RTL_TestUtility.createMasterCampaign('MasterCam1',
        	'D20171001',
        	'Exclusive',
        	'MB',u
        	);
		insert masterC;

		Campaign childC = RTL_TestUtility.createChildCampaign('ChildCam1','1', masterC , rt) ;
		insert childC;

        Lead l = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
        insert l;

        CampaignMember cm1 = new CampaignMember();
        cm1.LeadId = l.id;
        cm1.CampaignId = childC.id;
        //insert cm1;


        Account acct = RTL_TestUtility.createAccounts(1 , true).get(0);
        //insert acct;

        Contact ct = RTL_TestUtility.createContacts(acct);
        ct.OwnerId = u.id;
        insert ct;

        CampaignMember cm2 = new CampaignMember();
        cm2.ContactId = ct.id;
        cm2.CampaignId = childC.id;
        //insert cm2;
                List<CampaignMember> cml = new List<CampaignMember>();
                cml.add(cm1);
                cml.add(cm2);
                insert cml;

	}

	@isTest static void executeCallList() 
	{
		
        Test.startTest();

                Campaign c = [SELECT ID FROM Campaign LIMIT 1];
                ApexPages.StandardController sc = new ApexPages.StandardController(c);

                PageReference pageRef = Page.RTL_CampaignCallList;
                //pageRef.getParameters().put('id', String.valueOf(acc.Id));
                Test.setCurrentPage(pageRef);


	        //System.runAs(u) {

	        	RTL_CampaignCallListExtension cce = new RTL_CampaignCallListExtension(sc);

	        	cce.searchcamMemOfferResult = '';
	        	cce.searchCampaignMembers();

		        List<SelectOption> userOwnerSelectionList  = cce.userOwnerSelectionList;
		        List<SelectOption> offerResultSelectList  = cce.offerResultSelectList ;
		        List<SelectOption> CampaignSelectOptionList  = cce.CampaignSelectOptionList ;
		        List<SelectOption> contactStatusSelectionList   = cce.contactStatusSelectionList;
		        List<SelectOption> invitationStatusSelectionList    = cce.invitationStatusSelectionList ;

		        String CampaignMemberID  = cce.CampaignMemberID;
	        	cce.backbutton();
	        	cce.cancel();
	        	cce.Next();
	        	cce.Previous();
	        	cce.getDisablePrevious();
	        	cce.getDisableNext();
	        //}

        Test.stopTest();

	}

	@isTest static void executeCallListMyList() 
	{
		
                Test.startTest();

                Campaign c = [SELECT ID FROM Campaign LIMIT 1];
                ApexPages.StandardController sc = new ApexPages.StandardController(c);

                PageReference pageRef = Page.RTL_CampaignCallList;
                pageRef.getParameters().put('mylist', '1' );
                Test.setCurrentPage(pageRef);

                UserRole ur = new UserRole();
                ur.name = 'BR-MGR-Zone-9290';
                insert ur;

                User u = [SELECT ID FROM USER WHERE FirstName = 'UserTest0'];
                u.UserRoleId = ur.id;
                update u;

        

        	System.runAs(u) {
        		RTL_CampaignCallListExtension cce = new RTL_CampaignCallListExtension(sc);
        	}

                Test.stopTest();

	}

	@isTest static void executeCallListMyTeamList() 
	{
		
		
        Test.startTest();

                Campaign c = [SELECT ID FROM Campaign LIMIT 1];
                ApexPages.StandardController sc = new ApexPages.StandardController(c);

                PageReference pageRef = Page.RTL_CampaignCallList;
                pageRef.getParameters().put('mylist', '1' );
                Test.setCurrentPage(pageRef);

	        UserRole ur = new UserRole();
                ur.name = 'BR-MGR-Zone-9290';
                insert ur;

		User u = [SELECT ID FROM USER WHERE FirstName = 'UserTest0'];
                u.UserRoleId = ur.id;
                update u;

        
        	System.runAs(u) {
	        	RTL_CampaignCallListExtension cce = new RTL_CampaignCallListExtension(sc);
	        	cce.searchselectedOwner = 'My team List';
	        	cce.searchCampaignMembers();
	        }
        Test.stopTest();

	}
	
	@isTest static void executeCallListCampaignSelected() 
	{


        Test.startTest();

                Campaign c = [SELECT ID FROM Campaign WHERE Name = 'ChildCam1' LIMIT 1];
                ApexPages.StandardController sc = new ApexPages.StandardController(c);

                PageReference pageRef = Page.RTL_CampaignCallList;
                pageRef.getParameters().put('id', c.id );
                Test.setCurrentPage(pageRef);

                UserRole ur = new UserRole();
                ur.name = 'BR-Sales-Zone-9290';
                insert ur;

		User u = [SELECT ID FROM USER WHERE FirstName = 'UserTest0'];
                u.UserRoleId = ur.id;
                update u;

        
        	RTL_CampaignCallListExtension cce = new RTL_CampaignCallListExtension(sc);
        	cce.searchselectedOwner = 'My team List';
	        cce.searchCampaignMembers();
        Test.stopTest();

	}
	
	
}