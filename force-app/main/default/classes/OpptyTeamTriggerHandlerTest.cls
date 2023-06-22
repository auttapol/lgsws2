@isTest
public class OpptyTeamTriggerHandlerTest {

    public static testMethod void RunPositiveTestOpptyTeam(){
        System.debug(':::: RunPositive Test Opportunity Team Member Start ::::');
        TestInit.createUser(false);
        // --- create user ---
        List<User> userList = TestUtils.createUsers(10, 'fn','Ln', 'test@tmbbank.com', true);
        //  -------
    
        system.debug('### userList : '+userList.size());
        System.runAs(TestInit.us) {
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            System.debug('Current User Id: ' + UserInfo.getUserId()); 
            
            // --- create account ---
		    List<Account> accList = TestUtils.createAccounts(1, 'test', 'CType', true);
            system.debug('### accList : '+accList.size());
            
            system.debug('### Test ');
            // --- create opp ---
            List<Opportunity> oppList = TestUtils.createOpportunity(10, accList.get(0).Id, true);
            system.debug('### oppList : '+oppList.size());
            // ------
            TEST.startTest();
			RunSingleRecord(oppList,userList);
			Run100Records(oppList,userList);
            TEST.stopTest();
        }
        System.debug(':::: RunPositive Test Opportunity Team Member End ::::');
    }

	public static void RunSingleRecord(List<Opportunity> oppList , List<User> userList){
		System.debug(':::: Run Opportunity Team Member Single Record Start ::::');
		// --- creat opp team ---
		List<OpportunityTeamMember> oppteamlst = TestUtils.createOpportunityTeam(1, oppList.get(0).Id, userList, true);
		system.debug('### oppteamlstsize : '+oppteamlst.size());

		//TEST.startTest();
			try{
				delete oppteamlst;
			}catch(DmlException e){
				System.debug('### The following exception has occurred: ' + e.getMessage());
			}catch(Exception e){
				System.debug('### An exception occurred: ' + e.getMessage());
			}
		//TEST.stopTest();
        
        // --- check number of records ---
		List<OpportunityTeamMember> oppteamAfterDel = new List<OpportunityTeamMember>([SELECT Id FROM OpportunityTeamMember]);
		system.debug('### oppteamAfterDel : '+oppteamAfterDel.size());
		System.assertEquals(oppteamAfterDel.size(),0);

		System.debug(':::: Run Opportunity Team Member Single Record End ::::');
	}

	public static void Run100Records(List<Opportunity> oppList , List<User> userList){
		System.debug(':::: Run Opportunity Team Member 100 Records Start ::::');
		List<OpportunityTeamMember> oppteamAll = new List<OpportunityTeamMember>();
        // --- creat opp team ---
        List<OpportunityTeamMember> oppteamlst1 = TestUtils.createOpportunityTeam(10, oppList.get(0).Id, userList, true);
        List<OpportunityTeamMember> oppteamlst2 = TestUtils.createOpportunityTeam(10, oppList.get(1).Id, userList, true);
        List<OpportunityTeamMember> oppteamlst3 = TestUtils.createOpportunityTeam(10, oppList.get(2).Id, userList, true);
        List<OpportunityTeamMember> oppteamlst4 = TestUtils.createOpportunityTeam(10, oppList.get(3).Id, userList, true);
        List<OpportunityTeamMember> oppteamlst5 = TestUtils.createOpportunityTeam(10, oppList.get(4).Id, userList, true);
        List<OpportunityTeamMember> oppteamlst6= TestUtils.createOpportunityTeam(10, oppList.get(5).Id, userList, true);
        List<OpportunityTeamMember> oppteamlst7 = TestUtils.createOpportunityTeam(10, oppList.get(6).Id, userList, true);
        List<OpportunityTeamMember> oppteamlst8 = TestUtils.createOpportunityTeam(10, oppList.get(7).Id, userList, true);
        List<OpportunityTeamMember> oppteamlst9 = TestUtils.createOpportunityTeam(10, oppList.get(8).Id, userList, true);
        List<OpportunityTeamMember> oppteamlst10 = TestUtils.createOpportunityTeam(10, oppList.get(9).Id, userList, true);
        oppteamAll.addAll(oppteamlst1);
        oppteamAll.addAll(oppteamlst2);
        oppteamAll.addAll(oppteamlst3);
        oppteamAll.addAll(oppteamlst4);
        oppteamAll.addAll(oppteamlst5);
        oppteamAll.addAll(oppteamlst6);
        oppteamAll.addAll(oppteamlst7);
        oppteamAll.addAll(oppteamlst8);
        oppteamAll.addAll(oppteamlst9);
        oppteamAll.addAll(oppteamlst10);
        System.debug('###oppteamAll :  '+oppteamAll.size());
        // ------
        
		//TEST.startTest();
			try{
				delete oppteamAll;
			}catch(DmlException e){
				System.debug('### The following exception has occurred: ' + e.getMessage());
			}catch(Exception e){
				System.debug('### An exception occurred: ' + e.getMessage());
			}
		//TEST.stopTest();
        
		// --- check number of records ---
		List<OpportunityTeamMember> oppteamAfterDel2 = new List<OpportunityTeamMember>([SELECT Id FROM OpportunityTeamMember]);
		system.debug('### oppteamAfterDel2 : '+oppteamAfterDel2.size());
		//System.assertEquals(oppteamAfterDel2.size(),0);

		System.debug(':::: Run Opportunity Team Member 100 Records End ::::');
	}

}