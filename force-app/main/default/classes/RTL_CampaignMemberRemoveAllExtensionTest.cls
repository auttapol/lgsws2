@isTest
public class RTL_CampaignMemberRemoveAllExtensionTest {
    @testSetup static void initData() {
        TestUtils.createAppConfig();
        RecordType rt = [SELECT id FROM recordType WHERE DeveloperName   = 'Local_Exclusive_Campaign' ];
        RecordType masterRt = RTL_TestUtility.masterRt;//[SELECT id FROM recordType WHERE DeveloperName = 'Master_Campaign' ];

        RTL_Campaign_Running_No__c rn = new RTL_Campaign_Running_No__c( 
                        Name ='Local Exclusive Campaign Running No.' , 
                        DateValue__c='010117',
                        Day__c='01',
                        Month__c='01',
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
        
        UserRole ur = [
                                SELECT ID, Name, developername, portaltype, portalaccountid 
                                from UserRole limit 1
                            ];
        System.Debug('ur : ' + ur);
        
        User u = RTL_TestUtility.createUsers(1, 'UserTest' ,'User1' , 'test@email.com' , false).get(0);
        u.RTL_Branch_Code__c  = '611';
        //u.UserRole = ur;
        insert u;
        
        User uu = [select id,UserRoleId from User limit 1];
        System.debug('uu : ' + uu.UserRoleId);


        Campaign masterC = RTL_TestUtility.createMasterCampaign('MasterCam1',
            'L20170101',
            'Local Exclusive',
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

    }
    
    @isTest static void testPositive1() {
        Test.startTest();
        Campaign cp = [select id from Campaign where RTL_Campaign_Type_child__c  ='Local Exclusive' limit 1];
        PageReference pageRef = Page.RTL_CampaignMemberRemoveAll;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',cp.id);      
        pageRef.getParameters().put('RemoveMenus','all'); 
        CampaignMember cm = [select id from CampaignMember where campaign.RTL_Campaign_Type__c ='Local Exclusive' limit 1];
        Apexpages.StandardController sc = new Apexpages.StandardController(cm);
        RTL_CampaignMemberRemoveAllExtension obj = new RTL_CampaignMemberRemoveAllExtension(sc);
        
        obj.RemoveMenus = 'all';
        obj.getItems();
        obj.saveToDel();
        obj.cancel();
        obj.back();
        
        Test.stopTest();
    }
    
    @isTest static void testPositive2() {
        Test.startTest();
        Campaign cp = [select id from Campaign where RTL_Campaign_Type_child__c  ='Local Exclusive' limit 1];
        PageReference pageRef = Page.RTL_CampaignMemberRemoveAll;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',cp.id);  
        pageRef.getParameters().put('RemoveMenus','unused'); 
        CampaignMember cm = [select id from CampaignMember where campaign.RTL_Campaign_Type__c ='Local Exclusive' limit 1];
        Apexpages.StandardController sc = new Apexpages.StandardController(cm);
        RTL_CampaignMemberRemoveAllExtension obj = new RTL_CampaignMemberRemoveAllExtension(sc);
        
        List<RTL_Campaign_Member_Status_Mapping__mdt> listUsedStatus = new List<RTL_Campaign_Member_Status_Mapping__mdt>();
        listUsedStatus = [select RTL_Contact_Status__c from RTL_Campaign_Member_Status_Mapping__mdt where RTL_Contact_Status__c = 'New'];

        obj.RemoveMenus = 'unused';
        obj.getItems();
        obj.saveToDel();
        obj.cancel();
        obj.back();
        
        
        Test.stopTest();
    }
}