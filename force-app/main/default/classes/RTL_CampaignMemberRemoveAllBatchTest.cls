@isTest
public class RTL_CampaignMemberRemoveAllBatchTest {
    @testSetup static void initData() {
        TestUtils.createAppConfig();
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


        Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '611';
        bz.RTL_Zone_Code__c = '6711';
        insert bz;
        
        RTL_Branch_Manager_Title__c bm = new RTL_Branch_Manager_Title__c();
        bm.Name = 'Branch Manager';
        bm.RTL_Value__c = 'BM';
        insert bm;
        
        UserRole ur = [
                                SELECT ID, Name, developername, portaltype, portalaccountid 
                                from UserRole limit 1];
        System.Debug('ur : ' + ur);
        /*UserRole ur = [
                                SELECT ID, Name, developername, portaltype, portalaccountid 
                                from UserRole 
                                where Name = 'BR-MGR-Zone-6940(test)'//('WM-TL','BR-MGR-Zone')
                            ];*/
        System.Debug('ur : ' + ur);
        
        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'User1' , 'test@email.com' , false).get(0);
        u.RTL_Branch_Code__c  = '611';
        u.Title = 'BM';
        insert u;
        
        User uu = [select id,UserRoleId from User limit 1];
        System.debug('uu : ' + uu.UserRoleId);


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
        insert cm1;


        Account acct = RTL_TestUtility.createAccounts(1 , true).get(0);
        //insert acct;

        Contact ct = RTL_TestUtility.createContacts(acct);
        ct.OwnerId = u.id;
        insert ct;

        CampaignMember cm2 = new CampaignMember();
        cm2.ContactId = ct.id;
        cm2.CampaignId = childC.id;
        //insert cm2;
        
        RTL_Deleted_Campaign_Member__c cmD = new RTL_Deleted_Campaign_Member__c();
        cmD.RTL_Campaign_Member_ID__c = string.valueOf(cm1.id);
        cmD.RTL_Deleted__c = false;
        insert cmD;
    }
    
    @isTest static void testPositive() {
        Test.startTest();
        User u = [select id,UserRole.Name from User limit 1];
        Campaign cp = [select id from Campaign where name = 'ChildCam1' limit 1];
        List<RTL_Deleted_Campaign_Member__c> cmD = [select id, RTL_Campaign_Member_ID__c, RTL_Deleted__c from RTL_Deleted_Campaign_Member__c];
        
        RTL_CampaignMemberRemoveAllBatch obj = new RTL_CampaignMemberRemoveAllBatch(cp.id);
        obj.start(null);
        obj.execute(null, cmD);
        Test.stopTest();
    }
    
    @isTest static void testNegative() {
        Test.startTest();
        User u = [select id,UserRole.Name from User limit 1];
        Campaign cp = [select id from Campaign where name = 'ChildCam1' limit 1];
        List<RTL_Deleted_Campaign_Member__c> cmDList = new List<RTL_Deleted_Campaign_Member__c>();
        List<RTL_Deleted_Campaign_Member__c> cmD = [select id, RTL_Campaign_Member_ID__c, RTL_Deleted__c from RTL_Deleted_Campaign_Member__c];
        for(RTL_Deleted_Campaign_Member__c cm : cmD) {
            cm.RTL_Campaign_Member_ID__c = 'xxx';
            cmDList.add(cm);
        }
        update cmdList;        
            
        RTL_CampaignMemberRemoveAllBatch obj = new RTL_CampaignMemberRemoveAllBatch(cp.id);
        obj.execute(null, cmD);
        Test.stopTest();
    }
}