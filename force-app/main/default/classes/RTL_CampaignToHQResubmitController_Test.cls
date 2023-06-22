@isTest
//(SeeAllData=true)
private class RTL_CampaignToHQResubmitController_Test {

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

        List<RTL_Campaign_Endpoint__c> epList = new List<RTL_Campaign_Endpoint__c>();
        RTL_Campaign_Endpoint__c ep1 = new RTL_Campaign_Endpoint__c (
        	Name = 'Campaign TO HQ INT01',
        	RTL_Endpoint__c = 'www.test.com'
        	);
        epList.add(ep1);
        //insert ep;

        RTL_Campaign_Endpoint__c ep2 = new RTL_Campaign_Endpoint__c (
        	Name = 'requestb',
        	RTL_Endpoint__c = 'www.test.com'
        	);
        epList.add(ep2);
        //insert ep;
        insert epList;


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
        //masterC.RTL_Category__c = ' Communication ';
        //masterC.RTL_Campaign_Objective__c = 'Activation';
        //masterC.RTL_Priority__c = '3 Medium';
        //masterC.RTL_Campaign_Sub_Type__c = '2 HasCampaignFulfillment';
        //masterC.RTL_Campaign_Channel__c = '6 PrintMedia';
        //masterC.RTL_Campaign_Sub_Type__c = '2 HasCampaignFulfillment';
		insert masterC;


		Campaign childC = RTL_TestUtility.createChildCampaign('ChildCam1','1', masterC , rt) ;
		insert childC;

		//CampaignMemberStatus cms2 = new CampaignMemberStatus();
		//cms2.CampaignId = childC.id;
		//cms2.Label = 'Open';
		//cms2.SortOrder = 1;
		//insert cms2;

        Lead l = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
        insert l;

        List<CampaignMember> cml = new List<CampaignMember>();
        CampaignMember cm1 = new CampaignMember();
        cm1.LeadId = l.id;
        cm1.CampaignId = childC.id;
        //insert cm1;
        cml.add(cm1);

        //Test.startTest();
        Account acct = RTL_TestUtility.createAccounts(1 , true).get(0);

        Contact ct = RTL_TestUtility.createContacts(acct);
        ct.OwnerId = u.id;
        insert ct;

        CampaignMember cm2 = new CampaignMember();
        cm2.ContactId = ct.id;
        cm2.CampaignId = childC.id;
        //insert cm2;
        cml.add(cm2);

        insert cml;

	        //Lead l2 = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
	        //insert l2;

	        //CampaignMember cm3 = new CampaignMember();
	        //cm3.LeadId = l2.id;
	        //cm3.CampaignId = masterC.id;
	        //insert cm3;
        //Test.stopTest();


		//CampaignMemberStatus cms1 = new CampaignMemberStatus();
		//cms1.CampaignId = masterC.id;
		//cms1.Label = 'Open';
		//cms1.SortOrder = 1;
		////cms1.IsDeleted = false;
		//cms1.IsDefault = true;
		//insert cms1;

		//** Need this section to  complete validation before call out **//
		// Still have problem on trigger util class RTL_GenerateCampaignMemberStatus on CampaignMemberStatus
		//masterC.RTL_Category__c = 'Communication';
  //      masterC.RTL_Campaign_Objective__c = 'Loyalty';
  //      masterC.RTL_Priority__c = '3 Medium';
  //      masterC.RTL_Campaign_Sub_Type__c = '2 HasCampaignFulfillment';
  //      update masterC;

        RTL_Campaign_To_HQ_Callout_Log__c camLog1 = new RTL_Campaign_To_HQ_Callout_Log__c();
		camLog1.RTL_Campaign_ID__c = masterC.id;
		camLog1.RTL_No_of_Retry__c = 0;
		camLog1.RTL_Campaign__c = masterC.id;
		//camLog1.RTL_Status__c = 'Success';
		insert camLog1;
		
		RTL_Campaign_To_HQ_Callout_Transaction__c camTran1 = new RTL_Campaign_To_HQ_Callout_Transaction__c();
		camTran1.RTL_Campaign__c = masterC.id;
		camTran1.RTL_Campaign_To_HQ_Callout_Log__c = camLog1.id;
		camTran1.RTL_Call_Date__c = Datetime.now();
		camTran1.RTL_Status_Text__c = 'Processing';
		camTran1.RTL_Status__c = 'Processing';
		insert camTran1;

		RTL_Campaign_To_HQ_Callout_Transaction__c camTran2 = new RTL_Campaign_To_HQ_Callout_Transaction__c();
		camTran2.RTL_Campaign__c = masterC.id;
		camTran2.RTL_Campaign_To_HQ_Callout_Log__c = camLog1.id;
		camTran2.RTL_Call_Date__c = Datetime.now();
		camTran2.RTL_Status_Text__c = 'Success';
		camTran2.RTL_Status__c = 'Success';
		insert camTran2;

		RTL_Campaign_To_HQ_Callout_Transaction__c camTran3 = new RTL_Campaign_To_HQ_Callout_Transaction__c();
		camTran3.RTL_Campaign__c = masterC.id;
		camTran3.RTL_Campaign_To_HQ_Callout_Log__c = camLog1.id;
		camTran3.RTL_Call_Date__c = Datetime.now();
		camTran3.RTL_Status_Text__c = 'Fail';
		camTran3.RTL_Status__c = 'Fail';
		insert camTran3;

		//RTL_Campaign_To_HQ_Callout_Log__c camLog2 = new RTL_Campaign_To_HQ_Callout_Log__c();
		//camLog2.RTL_Campaign_ID__c = childC.id;
		//camLog2.RTL_No_of_Retry__c = 0;
		//camLog2.RTL_Campaign__c = childC.id;
		//camLog2.RTL_Status__c = 'Success';
		//insert camLog2;
		
		//RTL_Campaign_To_HQ_Callout_Transaction__c camTran4 = new RTL_Campaign_To_HQ_Callout_Transaction__c();
		//camTran4.RTL_Campaign__c = childC.id;
		//camTran4.RTL_Campaign_To_HQ_Callout_Log__c = camLog2.id;
		//camTran4.RTL_Call_Date__c = Datetime.now();
		//camTran4.RTL_Status_Text__c = 'Processing';
		//camTran4.RTL_Status__c = 'Processing';
		//insert camTran4;

	}

	//@isTest static void controllerMasterTest() {

	//	Campaign c = [SELECT ID FROM Campaign WHERE Name='MasterCam1'];
		


	//	Test.startTest();

	//		PageReference pageRef = Page.RTL_CampaignToHQResubmit;
	//		Test.setCurrentPage(pageRef);

	//		//campaignId = ApexPages.currentPage().getParameters().get('campaign_id');
	//		System.currentPageReference().getParameters().put('campaign_id', c.id);
	//		RTL_CampaignToHQResubmitController controller = new RTL_CampaignToHQResubmitController();

	//		controller.getLog();
	//		controller.cancel();
	//		controller.resubmitRequest();




	//	Test.stopTest();

	//}

	@isTest static void controllerChildTest() {

		Campaign c = [SELECT ID FROM Campaign WHERE Name='ChildCam1'];

		Test.startTest();

			PageReference pageRef = Page.RTL_CampaignToHQResubmit;
			Test.setCurrentPage(pageRef);

			//campaignId = ApexPages.currentPage().getParameters().get('campaign_id');
			System.currentPageReference().getParameters().put('campaign_id', c.id);
			RTL_CampaignToHQResubmitController controller = new RTL_CampaignToHQResubmitController();

			controller.getLog();
			controller.cancel();
			controller.resubmitRequest();

		Test.stopTest();

	}


	//@isTest static void controllerChildTestNotApprove() {


	//	Campaign c = [SELECT ID FROM Campaign WHERE Name='ChildCam1'];

	//	Test.startTest();

	//		PageReference pageRef = Page.RTL_CampaignToHQResubmit;
	//		Test.setCurrentPage(pageRef);

	//		//campaignId = ApexPages.currentPage().getParameters().get('campaign_id');
	//		System.currentPageReference().getParameters().put('campaign_id', c.id);
	//		RTL_CampaignToHQResubmitController controller = new RTL_CampaignToHQResubmitController();

	//		controller.getLog();
	//		controller.cancel();
	//		controller.resubmitRequest();

	//	Test.stopTest();

	//}

}