@isTest 
private class RTL_CampaignCodeGeneratorTest {
    
    @testSetup static void setupData() 
	{
		RecordType rt = [SELECT id FROM recordType WHERE DeveloperName   = 'Exclusive_Campaign_Active' ];
		RecordType masterRt = RTL_TestUtility.masterRt;//[SELECT id FROM recordType WHERE DeveloperName = 'Master_Campaign' ];

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
        
        /*App_Config__mdt acMDT = new App_Config__mdt();
        acMDT.Value__c = 'Mike';
        acMDT.MasterLabel = 'Contact Center';
        insert acMDT;*/
        
 		RTL_product_master__c p = new RTL_product_master__c(Name='TESTP',Active__c=true);
        insert p;
        
        Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '001';
        insert bz;
      
        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'User1' , 'test@email.com' , false).get(0);
        u.RTL_Branch_Code__c  = '001';
        insert u;

         id MasterLocalExclusiveCampaignrecordTypeID = [SELECT ID from RecordType 
                                          WHERE sObjectType = 'Campaign'
                                          AND DeveloperName = 'Master_Campaign' LIMIT 1].get(0).id;
        
        Campaign masterC = RTL_TestUtility.createMasterCampaign('MasterCam1',
        	'D20171001',
        	'Exclusive',
        	'MB',u
        	);
        masterC.RecordTypeId = MasterLocalExclusiveCampaignrecordTypeID;
		insert masterC;
        

		Campaign childC = RTL_TestUtility.createChildCampaign('ChildCam1','1', masterC , rt) ;
		insert childC;

        //Lead l = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
        //insert l;

        //CampaignMember cm1 = new CampaignMember();
        //cm1.LeadId = l.id;
        //cm1.CampaignId = childC.id;
        ////cm1.RTL_Products_Offer_String__c = '1:INVESTMENT;2:MM;3:TESTP;3:TESTP;3:TESTP;3:TESTP;';
        
        //cm1.RTL_Products_Offer_String__c = '3:TESTP;';
        //cm1.RTL_Product_Group_1__c = 'Bancassurance';
        //cm1.RTL_Sub_Group_1__c = 'Life';
        //cm1.RTL_Assigned_Branch__c = bz.id;
        //cm1.RTL_Assigned_Agent__c = u.id;
        //insert cm1;

        //Account acct = RTL_TestUtility.createAccounts(1 , true).get(0);
        ////insert acct;

        //Contact ct = RTL_TestUtility.createContacts(acct);
        //ct.OwnerId = u.id;
        //insert ct;

	}


	
     @isTest static void validateGenerateCampaignCode(){
         
         
      //  Campaign c = [SELECT ID FROM Campaign LIMIT 1];
 		//List <Campaign> campaignList = new List<Campaign>();
        //campaignList.add(c);
          	List<Campaign> listCam = [SELECT id,Name,Status,RecordTypeId,RTL_Campaign_Type__c,ParentId FROM Campaign];
         
        	Test.startTest(); 
         system.debug('TestDubug:: '+ listCam);
            RTL_CampaignCodeGenerator.GenerateCampaignCode(listCam);
        System.assertEquals('B', RTL_CampaignCodeGenerator.getNextChar('A'));
        System.assertEquals('C', RTL_CampaignCodeGenerator.getNextChar('B'));
        System.assertEquals('D', RTL_CampaignCodeGenerator.getNextChar('C'));
        	Test.stopTest();
         

    }

    @isTest static void generateCampaignCode(){
        //List<Campaign> listCam = [SELECT id,Name,Status,RecordTypeId,RTL_Campaign_Type__c,ParentId FROM Campaign];
          

        Date todaydate = System.today();
        String todayDatestr = DateTime.newInstance(todaydate.year(),todaydate.month(),todaydate.day()).format('dd-MM-YY');
        RTL_CampaignCodeGenerator.dayvalue = todaydatestr.split('-').get(0);
        RTL_CampaignCodeGenerator.monthvalue = todaydatestr.split('-').get(1);
        RTL_CampaignCodeGenerator.yearvalue = todaydatestr.split('-').get(2);
        RTL_CampaignCodeGenerator.datevalue = RTL_CampaignCodeGenerator.yearvalue+RTL_CampaignCodeGenerator.monthvalue+RTL_CampaignCodeGenerator.dayvalue;

        Test.startTest(); 
            List<Campaign> listMasterCam = [SELECT id,Name,Status,RecordTypeId,RTL_Campaign_Type__c,ParentId FROM Campaign WHERE name='MasterCam1'];
            List<Campaign> listChildCam = [SELECT id,Name,Status,RecordTypeId,RTL_Campaign_Type__c,ParentId FROM Campaign WHERE name='ChildCam1'];
        
            RTL_CampaignCodeGenerator.generateCampaignCode9Digit(listMasterCam);
            RTL_CampaignCodeGenerator.generateCampaignCode10Digit(listChildCam);
        Test.stopTest();
    }
    
    // @isTest static void validateGetNextChar() {
     
     	
 		
    //}
    
    
}