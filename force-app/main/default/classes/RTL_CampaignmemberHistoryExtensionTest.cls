@isTest
private class RTL_CampaignmemberHistoryExtensionTest {
    
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
        //masterC.Approvedflag__c = true;
		insert masterC;
        

		Campaign childC = RTL_TestUtility.createChildCampaign('ChildCam1','1', masterC , rt) ;
		//childC.Approvedflag__c = true;
		insert childC;
        

        Lead l = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
        insert l;


        CampaignMember cm1 = new CampaignMember();
        cm1.LeadId = l.id;
        cm1.CampaignId = childC.id;
        insert cm1;

        //Add for Test Campaignmember to CXM
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'CXM_SERVICE_CONNECTOR';
        Aconfig.Value__c = 'true';        
        apps.add(Aconfig);
        insert apps;
        TestUtils.prepareIntegrationMapping();
        TestUtils.prepareEIMmaps();
       

	}


	@isTest static void executeCallList() 
	{
                Test.startTest();

                        Campaign masterC = [Select id,Approvedflag__c from Campaign WHERE name = 'MasterCam1'];
                        masterC.Approvedflag__c = true;
                        update masterC;

                        Campaign childC = [Select id,Approvedflag__c from Campaign WHERE name = 'ChildCam1'];
                        childC.Approvedflag__c = true;
                        update childC;

        		CampaignMember cm = [SELECT ID,campaign.Id FROM CampaignMember LIMIT 1];
                        cm.RTL_Contact_Status__c = 'Contact';
                        update cm;
        		   	

        		ApexPages.StandardController sc = new ApexPages.StandardController(cm);

        		PageReference pageRef = Page.RTL_CampaignMemberHistory;
                        //pageRef.getParameters().put('id', String.valueOf(acc.Id));
                        Test.setCurrentPage(pageRef);


 
        

                
     
	        //System.runAs(u) {

	        	RTL_CampaignmemberHistoryExtension che = new RTL_CampaignmemberHistoryExtension(sc);
	        	che.cancel();
	        //}

        Test.stopTest();

	}
}