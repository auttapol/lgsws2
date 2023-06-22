@isTest
public class RTL_HouseholdRelationshipManagerTest {
	static User rmUser;
    static User rmManager;
    static AppConfig__c Aconfig;
    static List<Account> acctList;
    static List<RTL_Household__c> householdList;
    static List<RTL_Household_Member__c> memberList;
    static List<RTL_Household_History_And_Approval__c> historyList;
    
    static{
        Aconfig = new AppConfig__c();
        Aconfig.Name = 'runtrigger';
        Aconfig.Value__c = 'false'; 
        insert Aconfig;
        rmUser = RTL_TestUtility.createRetailTestUserWithBranch(true);
        rmManager = RTL_TestUtility.createRetailTestUser(true);
        acctList = RTL_TestUtility.createAccounts(2,true);
        householdList = RTL_TestUtility2.createHouseholdwithPrimaryMember(1,true,rmUser,acctList[0]);
        RTL_Branch_Manager_Title__c branchTitle = new RTL_Branch_Manager_Title__c(Name='Branch Manager',RTL_Value__c='Branch Manager');
        insert branchTitle;
        rmUser.ManagerId = rmManager.Id;
        update rmUser;
        
    }
    
    static testmethod void testUpdateRMwithEmployeeId(){
        Test.startTest();
         	Aconfig.Value__c = 'true'; 
        	update Aconfig;
            acctList[0].RTL_RM_Name__c = 'RTL01';
         	update acctList;
        	
        	householdList = queryHousehold();
            system.assertEquals(householdList[0].RTL_RM__c, rmManager.id);
            
        Test.stopTest();
        
    }
    
    static testmethod void testUpdateRMwithBranchCodeANDPendingHousehold(){
        Test.startTest();
        	Integer emailbefore = Limits.getEmailInvocations();
        	historyList = [SELECT ID,Name FROM RTL_Household_History_And_Approval__c];
        	for(RTL_Household_History_And_Approval__c history : historyList){
            	history.RTL_Outcome__c = 'Pending';
            
        	}
        	update historyList;
         	Aconfig.Value__c = 'true'; 
        	update Aconfig;
            acctList[0].RTL_RM_Name__c = '00002';
         	update acctList;
        
        	householdList = queryHousehold();
        	system.assertNotEquals(emailbefore,Limits.getEmailInvocations(),'should have decreased');
        	system.assertEquals(householdList[0].RTL_RM__c, rmUser.id);
            
        Test.stopTest();
        
    }
    
    static testmethod void testUpdateRMwithBranchCode(){
        Test.startTest();
         	Aconfig.Value__c = 'true'; 
        	update Aconfig;
            acctList[0].RTL_RM_Name__c = '00002';
         	update acctList;
        	
        	householdList = queryHousehold();
            system.assertEquals(householdList[0].RTL_RM__c, rmUser.id);
        Test.stopTest();
        
    }
    
    static List<RTL_Household__c> queryHousehold(){
        List<RTL_Household__c> hhList = [SELECT Id,Name,RTL_RM__c FROM RTL_Household__c];
        return hhList;
    }
}