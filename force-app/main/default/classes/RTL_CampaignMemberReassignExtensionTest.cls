@isTest
public class RTL_CampaignMemberReassignExtensionTest {
    
    @testSetup static void initData() {
        TestUtils.createAppConfig();


        //Add for Test CampaignMember to CXM
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


        Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '611';
        insert bz;
        
        UserRole ur1 = [SELECT ID, Name, developername, portaltype, portalaccountid 
                            from UserRole limit 1
                    ];
        
/*      UserRole ur2 = [SELECT ID, Name, developername, portaltype, portalaccountid 
                            from UserRole 
                            where Name = 'WTL-6803'//WM-TL-9-6719'//('WM-TL','BR-MGR-Zone')
                    ];
*/
        List<User> ul = RTL_TestUtility.createUsers(2, 'UserTest' ,'User' , 'test@email.com' , false);
        ul.get(0).RTL_Branch_Code__c  = '611';
        ul.get(0).UserRole = ur1;

//        ul.get(1).UserRole = ur2;
        
        insert ul;

        system.debug([SELECT ID,IsAllowChangeBranch__c,IstAllowedReAssign__c,role_name__c,Role_Type__c 
                                                            FROM RTL_Campaign_Reassign_Role_Setting__mdt ]);

        User u = ul.get(0);
    
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

    @isTest static void testPositive() {
        Test.startTest();
        User u = [select id,UserRole.Name from User where alias='Testtmb0' limit 1];
        System.runAs(u) {

            Campaign cp = [select id from Campaign limit 1];
            PageReference pageRef = Page.RTL_CampaignMemberReassign;
            Test.setCurrentPage(pageRef);
            //pageRef.getParameters().put('id',cp.id);
            pageRef.getParameters().put('unassigned','1');        
            CampaignMember cm = [select id from CampaignMember limit 1];

            Apexpages.StandardController sc = new Apexpages.StandardController(cm);
            RTL_CampaignMemberReassignExtension rtmCMRE = new RTL_CampaignMemberReassignExtension(sc);
            
            rtmCMRE.camMemReassign.RTL_Assigned_Agent__c = u.id;

            rtmCMRE.CampaignMemberID = null;
            rtmCMRE.CampaignTypeSelectList = null;
            rtmCMRE.channelfieldMapping = null;
            rtmCMRE.contactStatusSelectionList = null; //
            rtmCMRE.campaignChannelSelectList = null;
            rtmCMRE.offerResultSelectList = null;
            rtmCMRE.CampaignSelectOptionList = null; //
            rtmCMRE.isAllowSeeUnassinged = null; //
            rtmCMRE.isAllowChangeBranch = null; //
            
            rtmCMRE.searchCampaignMembers();
            rtmCMRE.selectMember();
            rtmCMRE.reallocateAction();
            rtmCMRE.toggleSelectAll();
            rtmCMRE.backbutton();
            rtmCMRE.cancel();
            rtmCMRE.Next();
            rtmCMRE.Previous();
            rtmCMRE.getDisablePrevious();
            rtmCMRE.getDisableNext();
            rtmCMRE.getPageMessage();
            rtmCMRE.getAllowedReAssign();

            List<SelectOption> CampaignTypeSelectList = rtmCMRE.CampaignTypeSelectList;
            List<SelectOption> campaignChannelSelectList  = rtmCMRE.campaignChannelSelectList;
            Map<String,String> channelfieldMapping  = rtmCMRE.channelfieldMapping;
            List<SelectOption> contactStatusSelectionList = rtmCMRE.contactStatusSelectionList;
            List<SelectOption> offerResultSelectList = rtmCMRE.offerResultSelectList;
            List<SelectOption> CampaignSelectOptionList = rtmCMRE.CampaignSelectOptionList;
            string selectedleadstatus = rtmCMRE.selectedleadstatus;
            Integer totalSelectedMembers = rtmCMRE.totalSelectedMembers;
            Boolean isAllowSeeUnassinged  = rtmCMRE.isAllowSeeUnassinged;

            Branch_and_zone__c bz = [SELECT id FROM Branch_and_zone__c LIMIT 1];
            rtmCMRE.camMemReassign.RTL_Assigned_Branch__c = bz.id;
            rtmCMRE.reallocateAction();
             
        }

        Test.stopTest();
    }
    
     @isTest static void testNegative() {
        Test.startTest();
        //TestUtils.createForCXMToSales();
        User u = [select id,UserRole.Name from User where alias='Testtmb0' limit 1];
        //System.runAs(u) {
            Campaign cp = [select id from Campaign limit 1];
            User us = [SELECT id from User where FirstName = 'UserTest0'];
            PageReference pageRef = Page.RTL_CampaignMemberReassign;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id',cp.id);
            //pageRef.getParameters().put('isUnassigned','1');        
            CampaignMember cm = [select id from CampaignMember limit 1];
            cm.RTL_Assigned_Agent__c = us.id;
            update cm;
            Apexpages.StandardController sc = new Apexpages.StandardController(cm);
            RTL_CampaignMemberReassignExtension rtmCMRE = new RTL_CampaignMemberReassignExtension(sc);
            
            rtmCMRE.CampaignMemberID = null;
            rtmCMRE.CampaignTypeSelectList = null;
            rtmCMRE.channelfieldMapping = null;
            rtmCMRE.contactStatusSelectionList = null; //
            rtmCMRE.campaignChannelSelectList = null;
            rtmCMRE.offerResultSelectList = null;
            rtmCMRE.CampaignSelectOptionList = null; //
            rtmCMRE.isAllowSeeUnassinged = null; //
            rtmCMRE.isAllowChangeBranch = null; //
            rtmCMRE.CampMemObj = cm;
            rtmCMRE.camMemReassign = cm;
            
            rtmCMRE.searchCampaignMembers();
            rtmCMRE.selectMember();
            rtmCMRE.reallocateAction();
            rtmCMRE.toggleSelectAll();
            rtmCMRE.backbutton();
            rtmCMRE.cancel();
            rtmCMRE.Next();
            rtmCMRE.Previous();
            rtmCMRE.getDisablePrevious();
            rtmCMRE.getDisableNext();
            rtmCMRE.getPageMessage();
            rtmCMRE.getAllowedReAssign();
        //}
        Test.stopTest();
    }

    @isTest static void wealthUser() {

        User u = [select id,UserRole.Name from User where alias='Testtmb1' limit 1];

         System.runAs(u) {

            Campaign cp = [select id from Campaign limit 1];
            PageReference pageRef = Page.RTL_CampaignMemberReassign;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id',cp.id);
            //pageRef.getParameters().put('isUnassigned','1');        
            CampaignMember cm = [select id from CampaignMember limit 1];

            Apexpages.StandardController sc = new Apexpages.StandardController(cm);
            RTL_CampaignMemberReassignExtension rtmCMRE = new RTL_CampaignMemberReassignExtension(sc);

            rtmCMRE.selectedChannel = 'abc';
            //rtmCMRE.searchcamMemAssignedZone  = 'abc';
            //rtmCMRE.searchcamMemberType = 'abc';
            //rtmCMRE.searchselectedChannel = 'abc';
            //rtmCMRE.searchcamMemAssignedZone  = 'abc';

            rtmCMRE.selectedtype  = 'Lead';

            rtmCMRE.searchCampaignMembers();
         }


    }

    @isTest static void serachContact() {

        User u = [select id,UserRole.Name from User where alias='Testtmb1' limit 1];

         System.runAs(u) {

            Campaign cp = [select id from Campaign limit 1];
            PageReference pageRef = Page.RTL_CampaignMemberReassign;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id',cp.id);
            //pageRef.getParameters().put('isUnassigned','1');        
            CampaignMember cm = [select id from CampaignMember limit 1];

            Apexpages.StandardController sc = new Apexpages.StandardController(cm);
            RTL_CampaignMemberReassignExtension rtmCMRE = new RTL_CampaignMemberReassignExtension(sc);

            rtmCMRE.selectedChannel = 'abc';


            rtmCMRE.selectedtype  = 'Contact';
            rtmCMRE.searchCampaignMembers();
         }


    }
    
}