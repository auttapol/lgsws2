@isTest
public class RTL_CampaignMemberUtilTest {
 
    @testSetup static void initData() {
        TestUtils.createAppConfig();
        
        //Add for Test campaignmember to CXM
        List<AppConfig__c> apps = new  List<AppConfig__c>();
        AppConfig__c Aconfig = new AppConfig__c();
        Aconfig.Name = 'CXM_SERVICE_CONNECTOR';
        Aconfig.Value__c = 'true';        
        apps.add(Aconfig);
        insert apps;
        TestUtils.prepareIntegrationMapping();
        TestUtils.prepareEIMmaps();
        
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
        
        //system.debug('getUserID:::'+u)

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
        cm1.RTL_Contact_Status__c = 'new';
        //cm1.RTL_Products_Offer_String__c = '3:TESTP;';
        cm1.RTL_Product_Group_1__c = 'OTHERS';
        cm1.RTL_OfferResult_Product_1__c = null;
        cm1.RTL_Product_Group_2__c = 'OTHERS';
        cm1.RTL_OfferResult_Product_2__c = null;
        cm1.RTL_Product_Group_3__c = 'OTHERS';
        cm1.RTL_OfferResult_Product_3__c = null;
        cm1.RTL_Product_Group_4__c = 'OTHERS';
        cm1.RTL_OfferResult_Product_4__c = null;
        cm1.RTL_Product_Group_5__c = 'OTHERS';
        cm1.RTL_OfferResult_Product_5__c = null;

        //cm1.RTL_Campaign_Product_1__c = p.id;
        cm1.RTL_Assigned_Branch__c = bz.id;
        cm1.RTL_Assigned_Agent__c = u.id;
        insert cm1;
/*
        Account acct = RTL_TestUtility.createAccounts(1 , true).get(0);
        //insert acct;

        Contact ct = RTL_TestUtility.createContacts(acct);
        ct.OwnerId = u.id;
        insert ct;

        CampaignMember cm2 = new CampaignMember();
        cm2.ContactId = ct.id;
        cm2.CampaignId = childC.id;
        cm2.RTL_Assigned_Branch__c = bz.id;
        cm2.RTL_Assigned_Agent__c = u.id;
        insert cm2;
*/
    }

    
    @isTest static void TestStep_Assigned_Branch ()
    { 
         Test.startTest();
        
        Campaign C = [SELECT id,Status,Approvedflag__c,RecordType.DeveloperName from Campaign where Name = 'ChildCam1'];
        User us = [SELECT id from User where FirstName = 'UserTest0'];
        Branch_and_zone__c bz = [SELECT id from Branch_and_zone__c where Branch_Code__c = '001'];
        Account acct = RTL_TestUtility.createAccounts(1 , true).get(0);
        //insert acct;

        Contact ct = RTL_TestUtility.createContacts(acct);
        ct.OwnerId = us.id;
        insert ct;
         Lead l = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
        insert l;

        CampaignMember cm1 = new CampaignMember();
        cm1.LeadId = l.id;
        cm1.CampaignId = C.id;
        cm1.RTL_Products_Offer_String__c = '3:TESTP;';
        cm1.RTL_Assigned_Branch__c = bz.id;
        //cm1.RTL_Assigned_Agent__c = us.id;
        insert cm1;
        
		CampaignMember cm2 = new CampaignMember();
        cm2.ContactId = ct.id;
        cm2.CampaignId = C.id;
        cm2.RTL_Assigned_Branch__c = bz.id;
        //cm2.RTL_Assigned_Agent__c = us.id;
        insert cm2;
        
        Map<ID,CampaignMember> triggerOldCampaignMemberList = new Map<ID,CampaignMember>();
         List<CampaignMember> listCamMem = [SELECT Id,LeadId,CampaignId,ContactId,RTL_Products_Offer_String__c,RTL_Assigned_Branch__c,RTL_Assigned_Agent__c,RTL_Offer_Result_Eng__c FROM CampaignMember];
         for( CampaignMember campMemObject : listCamMem  )
            {
                campMemObject.RTL_Assigned_Branch__c = bz.id;
               // campMemObject.RTL_Assigned_Agent__c = us.id;
                //update campMemObject;
				triggerOldCampaignMemberList.put(campMemObject.id,campMemObject);
            }
        
            RTL_CampaignMemberUtil.RTL_UpdateCampaignMemberAssigned(listCamMem,triggerOldCampaignMemberList);
        
        
        	RTL_CampaignMemberUtil.updateLeadOwnerIdFromCampaign(listCamMem);
        
        List<Campaign> listCam = [SELECT id,Name,Status FROM Campaign where name = 'MasterCam1'];
        Map<ID,Campaign> triggerOldCampaignList = new Map<ID,Campaign>();
         for( Campaign campObject : listCam  )
            {
                campObject.Status = 'Expired';
                update campObject;
				triggerOldCampaignList.put(campObject.id,campObject); 
            }
        //RTL_CampaignMemberUtil.updateExpiredCampaignMemberProductOfferResult(listCam,triggerOldCampaignList);
        RTL_CampaignMemberUtil.updateExpiredCampaignMemberDataBatch(listCam,triggerOldCampaignList);

        RTL_CampaignMemberUtil.checkActiveCampaign(C,cm1);
        Test.stopTest();
    }
    
    
    @isTest static void TestStep_Assigned_Agent ()
    { 
         Test.startTest();
        
        Campaign C = [SELECT id,Status,Approvedflag__c,RecordType.DeveloperName from Campaign where Name = 'ChildCam1'];
        User us = [SELECT id from User where FirstName = 'UserTest0'];
         Branch_and_zone__c bz = [SELECT id from Branch_and_zone__c where Branch_Code__c = '001'];
        Account acct = RTL_TestUtility.createAccounts(1 , true).get(0);
        //insert acct;

        Contact ct = RTL_TestUtility.createContacts(acct);
        ct.OwnerId = us.id;
        insert ct;
        Lead l = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open');
        insert l;

        CampaignMember cm1 = new CampaignMember();
        cm1.LeadId = l.id;
        cm1.CampaignId = C.id;
        cm1.RTL_Products_Offer_String__c = '3:TESTP;';
        //cm1.RTL_Assigned_Branch__c = bz.id;
        cm1.RTL_Assigned_Agent__c = us.id;
        insert cm1;
        
		CampaignMember cm2 = new CampaignMember();
        cm2.ContactId = ct.id;
        cm2.CampaignId = C.id;
        //cm2.RTL_Assigned_Branch__c = bz.id;
        cm2.RTL_Assigned_Agent__c = us.id;
        insert cm2;
        
        Map<ID,CampaignMember> triggerOldCampaignMemberList = new Map<ID,CampaignMember>();
         List<CampaignMember> listCamMem = [SELECT Id,LeadId,CampaignId,ContactId,RTL_Products_Offer_String__c,RTL_Assigned_Branch__c,RTL_Assigned_Agent__c,RTL_Offer_Result_Eng__c FROM CampaignMember];
         for( CampaignMember campMemObject : listCamMem  )
            {
               //campMemObject.RTL_Assigned_Branch__c = bz.id;
                campMemObject.RTL_Assigned_Agent__c = us.id;
				//update campMemObject;
				triggerOldCampaignMemberList.put(campMemObject.id,campMemObject);
                
            }
        RTL_CampaignMemberUtil.RTL_UpdateCampaignMemberAssigned(listCamMem,triggerOldCampaignMemberList);
        system.debug('listCamMem:'+ listCamMem);
        
        RTL_CampaignMemberUtil.updateLeadOwnerIdFromCampaign(listCamMem);
        
        List<Campaign> listCam = [SELECT id,Name,Status FROM Campaign where name = 'MasterCam1'];
        Map<ID,Campaign> triggerOldCampaignList = new Map<ID,Campaign>();
         for( Campaign campObject : listCam  )
            {
                campObject.Status = 'Expired';
                update campObject;
				triggerOldCampaignList.put(campObject.id,campObject); 
            }
        //RTL_CampaignMemberUtil.updateExpiredCampaignMemberProductOfferResult(listCam,triggerOldCampaignList);
        RTL_CampaignMemberUtil.updateExpiredCampaignMemberDataBatch(listCam,triggerOldCampaignList);


        RTL_CampaignMemberUtil.checkActiveCampaign(C,cm1);
        Test.stopTest();
    }
    
    @isTest static void Test_RTL_UpdateCampaignMemberOfferResultBatch ()
    {
        Test.startTest();
         
        List<Campaign> expiringCampaign = [SELECT id FROM Campaign];

        List<ID> expiringCampaignId = new List<ID>();
        for( Campaign c : expiringCampaign  )
        {
            expiringCampaignId.add(c.id);
        }

        RTL_UpdateCampaignMemberOfferResultBatch ucmorBatch = new RTL_UpdateCampaignMemberOfferResultBatch(expiringCampaignId);
        Database.executeBatch(ucmorBatch);  

        Test.stopTest();
    }
    
}