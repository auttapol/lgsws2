@isTest
private class RTL_CampaignStatusGeneratorTest {
	
	@testSetup static void setupData() 
	{
         TestUtils.createAppConfig();
		RecordType rt = [SELECT id FROM recordType WHERE DeveloperName   = 'Exclusive_Campaign_Active' ];

		List<AppConfig__c> mc = new List<AppConfig__c> ();
        mc.Add(new AppConfig__c(Name = 'runtrigger', Value__c = 'false'));
        insert mc;

        RTL_CampaignMember_Running_No__c cmrn = new RTL_CampaignMember_Running_No__c(
        	Name = 'Campaign Member Running No',
        	Running_No__c = '000000'
        	);
        insert cmrn;

        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'User1' , 'test@email.com' , false).get(0);
        u.RTL_Branch_Code__c  = '611';
        insert u;

		List<Campaign> cList = new List<Campaign>();
		Campaign cNew = RTL_TestUtility.createMasterCampaign('MasterCam1',
        	'D20171001',
        	'Exclusive',
        	'MB',u
        	);
		cNew.status = '';
		//cNew.RTL_Category__c = 'Communication';
		cList.add(cNew);

		insert cList;

		Campaign childC = RTL_TestUtility.createChildCampaign('ChildCam1','1', cNew , rt) ;
		//childC.RTL_Category__c = 'Sales';
		//childC.RTL_Campaign_Objective__c
		insert childC;

		Lead l = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
        insert l;

		CampaignMember cm1 = new CampaignMember();
        cm1.LeadId = l.id;
        cm1.CampaignId = childC.id;
        cm1.status = 'Open';
        insert cm1;

        //List<CampaignMemberStatus> cmsList = new List<CampaignMemberStatus>();
        //CampaignMemberStatus cms1 = new CampaignMemberStatus (
        //	SortOrder = 4,
        //	Label = 'Open',
        //	CampaignId = cNew.id
        //	);
        //cmsList.add(cms1);
        ////insert cms;

        //CampaignMemberStatus cms2 = new CampaignMemberStatus (
        //	SortOrder = 4,
        //	Label = 'Open',
        //	CampaignId = childC.id
        //	);
        //cmsList.add(cms2);
        //insert cmsList;


	}

	@isTest static void testGeneral() {

		List<Campaign> triggernewCampaign = new List<Campaign>();
		Map<ID,Campaign> triggerOldCampaignMap = new Map<ID,Campaign>();

  		Campaign oldCam = [Select id,name,ParentId,RTL_Category__c from campaign where name = 'MasterCam1'];

  		triggernewCampaign.add(oldCam);

  		Campaign newCam = oldCam.clone(false, false, false, false);

  		triggerOldCampaignMap.put( oldCam.id, newCam );

		

		RTL_CampaignStatusGenerator.RTL_GenerateCampaignMemberStatus(triggernewCampaign,triggerOldCampaignMap);

		Map<String,String> statusDefaultMapping  = RTL_CampaignStatusGenerator.statusDefaultMapping; 

	}

	@isTest static void testUpdateCampaignMember() {
		List<CampaignMember> cml = [SELECT id,RTL_Campaign_Category_formula__c,RTL_Contact_Status__c,RTL_Offer_Result__c 
			FROM CampaignMember LIMIT 1];

		RTL_CampaignStatusGenerator.RTL_UpdateCampaignMemberStatus(cml);
	}
	

}