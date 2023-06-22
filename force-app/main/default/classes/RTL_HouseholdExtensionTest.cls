@isTest
public class RTL_HouseholdExtensionTest {
	
    static User rmUser;
    static User rmManager;
    static List<Account> acctList;
    static List<RTL_Household__c> householdList;
    
    static{
       	TestUtils.createAppConfig();
        rmUser = RTL_TestUtility.createRetailTestUserWithBranch(true);
        rmManager = RTL_TestUtility.createRetailTestUser(true);
        acctList = RTL_TestUtility.createAccounts(2,true);
    }
    static testmethod void testInsertHouseholdSuccessCase(){
        rmUser.Employee_ID__c = '11111';
       	update rmUser;
        acctList[0].RTL_RM_Name__c = '11111';
        update acctList;
        Test.startTest();
        	
        	List<RTL_HouseHold__c> hhList = null;
        	hhList = [SELECT Id,Name FROM RTL_Household__c];
        	//check if system doesn't have any household data
        	System.assertEquals(0, hhList.size());
        	
        	Test.setCurrentPage(Page.RTL_HouseHold_Creation);
        	ApexPages.currentPage().getParameters().put('acctId',acctList[0].id);
        	ApexPages.StandardController std = new ApexPages.StandardController(acctList[0]);
        	RTL_HouseHoldExtension ext = new RTL_HouseHoldExtension(std);
        	ext.household.RTL_Benefit_Package__c = 'Wealth Package 1';
        	//save to insert household
        	ext.save();
        	hhList = [SELECT Id,Name,(SELECT ID,Name,RTL_Primary__c,RTL_Benefit__c FROM Household_Members__r) FROM RTL_Household__c];
        	//Check Result : Household was created in the system
        	System.assertEquals(1,hhList.size());
        	//Check Result : Household was created with one member
        	System.assertEquals(1,hhList[0].Household_Members__r.size());
        	//Check Result : Household Member is Primary
        	System.assertEquals(true,hhList[0].Household_Members__r[0].RTL_Primary__c);
        Test.stopTest();
        
    }
    
     static testmethod void testInsertHouseholdFromBranchSuccessCase(){
        RTL_Branch_Manager_Title__c branchTitle = new RTL_Branch_Manager_Title__c(Name='Branch Manager',RTL_Value__c ='Branch');
      	insert branchTitle;
        rmUser.RTL_Branch_Code__c = '111';
        rmUser.title = 'Branch';
       	update rmUser;
        acctList[0].RTL_RM_Name__c = '00111';
        update acctList;
        Test.startTest();
        	
        	List<RTL_HouseHold__c> hhList = null;
        	hhList = [SELECT Id,Name FROM RTL_Household__c];
        	//check if system doesn't have any household data
        	System.assertEquals(0, hhList.size());
        	
        	Test.setCurrentPage(Page.RTL_HouseHold_Creation);
        	ApexPages.currentPage().getParameters().put('acctId',acctList[0].id);
        	ApexPages.StandardController std = new ApexPages.StandardController(acctList[0]);
        	RTL_HouseHoldExtension ext = new RTL_HouseHoldExtension(std);
        	ext.household.RTL_Benefit_Package__c = 'Wealth Package 1';
        	//save to insert household
        	ext.save();
        	hhList = [SELECT Id,Name,(SELECT ID,Name,RTL_Primary__c,RTL_Benefit__c FROM Household_Members__r) FROM RTL_Household__c];
        	//Check Result : Household was created in the system
        	System.assertEquals(1,hhList.size());
        	//Check Result : Household was created with one member
        	System.assertEquals(1,hhList[0].Household_Members__r.size());
        	//Check Result : Household Member is Primary
        	System.assertEquals(true,hhList[0].Household_Members__r[0].RTL_Primary__c);
        Test.stopTest();
        
    }
    
    static testmethod void testDuplicateHouseholdNameCase(){
        Test.startTest();
        	//Insert Household to let the system have exist household record
        	householdList = RTL_TestUtility2.createHouseholdwithPrimaryMember(1,true,rmUser,acctList[0]);
        	acctList = [SELECT ID,Name,First_Name_PE__c,Last_Name_PE__c,Account_Type__c,Customer_Type__c FROM Account];
        	//update existing household name to account name
        	householdList[0].Name = acctList[0].Last_Name_PE__c+' '+acctList[0].First_Name_PE__c;
        	update householdList;
            System.debug('ACCT ::: '+acctList[0]);
        	Test.setCurrentPage(Page.RTL_HouseHold_Creation);
        	ApexPages.currentPage().getParameters().put('acctId',acctList[0].id);
        	ApexPages.StandardController std = new ApexPages.StandardController(acctList[0]);
        	RTL_HouseHoldExtension ext = new RTL_HouseHoldExtension(std); 
        	ext.household.RTL_Benefit_Package__c = 'Wealth Package 1';
        	//Insert Household
        	ext.save();
        	
        	//Check Result : Inserted Household must named as account name + sequence
        	System.debug('ACCT ::: '+acctList[0].Last_Name_PE__c +acctList[0].First_Name_PE__c );
            System.debug('ACCT ::: HOUSEHOLD NAME :: '+ext.household.Name);
        	System.assertEquals(acctList[0].Last_Name_PE__c+' '+acctList[0].First_Name_PE__c+' 001', ext.household.Name);
        	ext.cancel();
        Test.stopTest();
        
    }
    static testmethod void testInsertHouseholdFailedCase(){
        Test.startTest();
        	List<RTL_HouseHold__c> hhList = null;
        	hhList = [SELECT Id,Name FROM RTL_Household__c];
        	//check if system doesn't have any household data
        	System.assertEquals(0, hhList.size());
        
        	Test.setCurrentPage(Page.RTL_HouseHold_Creation);
        	ApexPages.currentPage().getParameters().put('acctId',acctList[0].id);
        	ApexPages.StandardController std = new ApexPages.StandardController(acctList[0]);
        	RTL_HouseHoldExtension ext = new RTL_HouseHoldExtension(std);
        	
        	ext.save();
        
        	hhList = [SELECT Id,Name FROM RTL_Household__c];
        	//Check Result : Sytem should not have any household data due to insertion failed.
        	System.assertEquals(0, hhList.size());
        	
        	ext.cancel();
        Test.stopTest();
        
    }
}