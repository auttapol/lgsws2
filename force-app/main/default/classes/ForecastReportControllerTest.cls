@isTest
public class ForecastReportControllerTest {
    public static final Id SYSAD_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    public static final Id SESM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Sales Management Profile' LIMIT 1].Id;
    public static final Id SEZM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB SE Zone Manager Profile' LIMIT 1].Id;
	public static final Id BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;
    
    static{
        TestUtils.createAppConfig();
        
        Branch_and_zone__c bz = new Branch_and_zone__c();
        bz.Branch_Code__c = '001';
        insert bz;
        
        List<Region_and_Zone_Mapping__c> rzlst = new List<Region_and_Zone_Mapping__c>();
        Region_and_Zone_Mapping__c Rz1 = new Region_and_Zone_Mapping__c();
        Rz1.Team_Zone_Code__c = '9999';
        Rz1.Team_Zone_Name__c = 'SE-ChiangMai';
        Rz1.Region_Group_Code__c = '1111';
        Rz1.Region_Group_Name__c = 'SE1-North1';
        rzlst.add(Rz1);
        
        Region_and_Zone_Mapping__c Rz2 = new Region_and_Zone_Mapping__c();
        Rz2.Team_Zone_Code__c = '8888';
        Rz2.Team_Zone_Name__c = 'ChiangMai';
        Rz2.Region_Group_Code__c = '2222';
        Rz2.Region_Group_Name__c = 'North1';
        rzlst.add(Rz2);
        
        Region_and_Zone_Mapping__c Rz3 = new Region_and_Zone_Mapping__c();
        Rz3.Team_Zone_Code__c = '5001';
        Rz3.Team_Zone_Name__c = 'IIG-Dev';
        Rz3.Region_Group_Code__c = '5000';
        Rz3.Region_Group_Name__c = 'IIG';
        rzlst.add(Rz3);
        insert rzlst;
        
        List<User> userlst = new List<User>();

        User salesManagementSE = RTL_TestUtility.createUsers(1, 'SMSE', 'SMSE', 'SMSE@tmb.com.test', false).get(0);
		salesManagementSE.ProfileId = SESM_PROFILE_ID;
		salesManagementSE.isActive = true;
		salesManagementSE.RTL_Branch_Code__c = bz.Branch_Code__c;
		salesManagementSE.Employee_ID__c = '000001';
		salesManagementSE.Zone__c = 'SE-ChiangMai';
		salesManagementSE.Zone_Code__c = '9999';
		salesManagementSE.Region__c = 'SE1-North1';
		salesManagementSE.Region_Code__c = '1111';
        salesManagementSE.Segment__c = 'SE';
        userlst.add(salesManagementSE);
        
        User userSystemadmin = RTL_TestUtility.createUsers(1, 'Sysad', 'Sysad', 'Sysad@tmb.com.test', false).get(0);
		userSystemadmin.ProfileId = SYSAD_PROFILE_ID;
		userSystemadmin.isActive = true;
		userSystemadmin.RTL_Branch_Code__c = bz.Branch_Code__c;
		userSystemadmin.Employee_ID__c = '000002';
		userSystemadmin.Zone__c = 'ChiangMai';
		userSystemadmin.Zone_Code__c = '8888';
		userSystemadmin.Region__c = 'North1';
		userSystemadmin.Region_Code__c = '2222';
        userlst.add(userSystemadmin);
        
        User teamhead = RTL_TestUtility.createUsers(1, 'teamhead', 'teamhead', 'teamhead@tmb.com.test', false).get(0);
		teamhead.ProfileId = SEZM_PROFILE_ID;
		teamhead.isActive = true;
		teamhead.RTL_Branch_Code__c = bz.Branch_Code__c;
		teamhead.Employee_ID__c = '111111';
		teamhead.Zone__c = 'SE-ChiangMai';
		teamhead.Zone_Code__c = '9999';
		teamhead.Region__c = 'SE1-North1';
		teamhead.Region_Code__c = '1111';
        teamhead.ManagerId = salesManagementSE.Id;
        userlst.add(teamhead);
        
        User bdmSEowner0 = RTL_TestUtility.createUsers(1, 'bdmSEowner0', 'bdmSEowner0', 'bdmSEowner0@tmb.com.test', false).get(0);
		bdmSEowner0.ProfileId = BDM_PROFILE_ID;
		bdmSEowner0.isActive = true;
		bdmSEowner0.RTL_Branch_Code__c = bz.Branch_Code__c;
		bdmSEowner0.Employee_ID__c = '333330';
		bdmSEowner0.Zone__c = 'IIG-Dev';
		bdmSEowner0.Zone_Code__c = '5001';
		bdmSEowner0.Region__c = 'IIG';
		bdmSEowner0.Region_Code__c = '5000';
        bdmSEowner0.Segment__c = 'SE';
        userlst.add(bdmSEowner0);
        
        insert userlst;
    }
    
    @isTest
    public static void testGetRegionZoneName() {
        User rm = [SELECT Id, Name, Profile.Name, Zone__c FROM User WHERE Email = 'bdmSEowner0@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        
        Test.startTest();
        //admin role
        System.runAs(rm){
            ForecastReportController.getRegionZoneName(rm.Zone__c);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testGetCustomerPort() {
        User rm = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'bdmSEowner0@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        
        Test.startTest();
        //rm role
        System.runAs(rm){
            Map<String, Map<String, String>> mapPortTeamcode = new Map<String, Map<String, String>> ();
            Map<String, String> mapZoneName = new Map<String, String>();
            mapZoneName.put('5001', 'IIG-Dev');
            mapPortTeamcode.put('My Customer', mapZoneName);
            String result = JSON.serialize(mapPortTeamcode);
            String port = ForecastReportController.getCustomerPort();
            System.assertEquals(port, result);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testGetUserForecastReportRoleAdmin() {
        User admin = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'Sysad@tmb.com.test' AND ProfileId = :SYSAD_PROFILE_ID LIMIT 1];
        
        Test.startTest();
        //admin role
        System.runAs(admin){
            String adminRole = ForecastReportController.getUserForecastReportRole();
            System.assertEquals(adminRole, 'System Administrator');
        }
        Test.stopTest();
    }
    
    
    @isTest
    public static void testGetUserForecastReportRoleGroupHead() {
        User groupHead = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'SMSE@tmb.com.test' AND ProfileId = :SESM_PROFILE_ID LIMIT 1];
        
        Test.startTest();
        //group head role
        System.runAs(groupHead){
            String groupHeadRole = ForecastReportController.getUserForecastReportRole();
            System.debug('Profile Name: ' + groupHeadRole);
            System.assertEquals(groupHeadRole, 'GroupHead');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testGetUserForecastReportRoleTeamHead() {
        User teamHead = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'teamhead@tmb.com.test' AND ProfileId = :SEZM_PROFILE_ID LIMIT 1];
        
        Test.startTest();
        //team head role
        System.runAs(teamHead){
            String teamHeadRole = ForecastReportController.getUserForecastReportRole();
            System.assertEquals(teamHeadRole, 'TeamHead');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testGetUserForecastReportRoleRM() {
        User rm = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'bdmSEowner0@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        
        Test.startTest();
        //rm role
        System.runAs(rm){
            String rmRole = ForecastReportController.getUserForecastReportRole();
            System.assertEquals(rmRole, 'RM');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testGetCube1RM() {
        User rm = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'bdmSEowner0@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        String strYear = String.valueOf(Date.today().year());
        String port = 'My Customer';
        List<String> searchTeam = new List<String>();
        searchTeam.add('5001');
        String selectedProductGroup = 'Credit';
        
        Test.startTest();
        //rm role
        System.runAs(rm){
            try {
				ForecastReportController.getCUBE1Data(strYear,port,searchTeam,selectedProductGroup);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
                ForecastReportController.getCube1Report(strYear,port,searchTeam,selectedProductGroup);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
                ForecastReportController.getNewDealReport4(strYear,port,searchTeam);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            
            try {
                ForecastReportController.getCube2Report4(strYear,port,searchTeam);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
				ForecastReportController.getReportByProductGroup(strYear,port,searchTeam,selectedProductGroup);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testGetCube1TeamHead() {
        User teamHead = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'teamhead@tmb.com.test' AND ProfileId = :SEZM_PROFILE_ID LIMIT 1];
        String strYear = String.valueOf(Date.today().year());
        String portMyteam = 'My Team';
        String portMyAccountteam = 'My Account Team';
        List<String> searchTeam = new List<String>();
        searchTeam.add('5001');

        User rm = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'bdmSEowner0@tmb.com.test' AND ProfileId = :BDM_PROFILE_ID LIMIT 1];
        account acct = TestUtils.createAccounts(1, 'fname', 'Individual', true).get(0);
        acct.Owner = rm;
        update acct;

        AccountTeamMember atm = new AccountTeamMember(AccountId = acct.id, UserId = rm.id);
        insert atm;

        List<String> searchAccTeam = new List<String>();
        searchAccTeam.add('5679');
        searchAccTeam.add('5629');
        String selectedProductGroup = 'Deposit';
        
        Test.startTest();
        //teamHead role
        System.runAs(teamHead){
            try {
				ForecastReportController.getCUBE1Data(strYear,portMyteam,searchTeam,selectedProductGroup);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
				ForecastReportController.getCUBE1Data(strYear,portMyAccountteam,searchAccTeam,selectedProductGroup);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
                ForecastReportController.getCube1Report(strYear,portMyteam,searchTeam,selectedProductGroup);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
                ForecastReportController.getCube1Report(strYear,portMyAccountteam,searchAccTeam,selectedProductGroup);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
                ForecastReportController.getNewDealReport4(strYear,portMyteam,searchTeam);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
                ForecastReportController.getNewDealReport4(strYear,portMyAccountteam,searchAccTeam);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
                ForecastReportController.getCube2Report4(strYear,portMyteam,searchTeam);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
                ForecastReportController.getCube2Report4(strYear,portMyAccountteam,searchAccTeam);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
				ForecastReportController.getReportByProductGroup(strYear,portMyteam,searchTeam,selectedProductGroup);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
				ForecastReportController.getReportByProductGroup(strYear,portMyAccountteam,searchAccTeam,selectedProductGroup);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testGetCube1GroupHead() {
        User groupHead = [SELECT Id, Name, Profile.Name FROM User WHERE Email = 'SMSE@tmb.com.test' AND ProfileId = :SESM_PROFILE_ID LIMIT 1];
        String strYear = String.valueOf(Date.today().year());
        String port = 'Select Team';
        String myteamAccteamPort = 'My Team-Account Team';
        List<String> searchTeam = new List<String>();
        searchTeam.add('5001');
        searchTeam.add('5679');
        searchTeam.add('5629');
        String selectedProductGroup = 'Deposit';
        
        Test.startTest();
        //groupHead role
        System.runAs(groupHead){
            try {
				ForecastReportController.getCUBE1Data(strYear,port,searchTeam,selectedProductGroup);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
				ForecastReportController.getCUBE1Data(strYear,myteamAccteamPort,searchTeam,selectedProductGroup);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
                ForecastReportController.getCube1Report(strYear,port,searchTeam,selectedProductGroup);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
				ForecastReportController.getCube1Report(strYear,myteamAccteamPort,searchTeam,selectedProductGroup);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
                ForecastReportController.getNewDealReport4(strYear,port,searchTeam);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
				ForecastReportController.getNewDealReport4(strYear,myteamAccteamPort,searchTeam);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
                ForecastReportController.getCube2Report4(strYear,port,searchTeam);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
                ForecastReportController.getCube2Report4(strYear,myteamAccteamPort,searchTeam);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
				ForecastReportController.getReportByProductGroup(strYear,port,searchTeam,selectedProductGroup);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
            
            try {
				ForecastReportController.getReportByProductGroup(strYear,myteamAccteamPort,searchTeam,selectedProductGroup);
			} catch (Exception e) {
				System.debug(e.getMessage());
			}
        }
        Test.stopTest();
    }
}