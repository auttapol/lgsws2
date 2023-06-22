@isTest
public class RTL_HouseholdDetailProxyCtrlTest {
    
    static User rmUser;
    static User rmManager;
    static List<Account> acctList;
    static List<RTL_Household__c> householdList;
    static RTL_Household_Member__c member;
    
    static{
        TestUtils.createAppConfig();
        rmUser = RTL_TestUtility.createRetailTestUserWithBranch(true);
        rmManager = RTL_TestUtility.createRetailTestUser(true);
        acctList = RTL_TestUtility.createAccounts(2,true);
        householdList = RTL_TestUtility2.createHouseholdwithPrimaryMember(1,true,rmUser,acctList[0]);
        member = RTL_TestUtility2.createHouseholdMember(true,householdList[0].id,acctList[1]); 
    }
    static testmethod void testPositiveCase(){
        Test.startTest();
            Test.setCurrentPage(Page.RTL_HouseHold_Detail_Proxy_Page);
            ApexPages.StandardController std = new ApexPages.StandardController(member);
            RTL_HouseholdDetailProxyCtrl ext = new RTL_HouseholdDetailProxyCtrl(std);
            
            String nextPage = ext.redirectPage().getURL();
            //Check Result : Verify that Household Detail Page displays
            System.assertEquals('/apex/RTL_Household_Detail?id='+member.RTL_Household__c, nextPage);
        Test.stopTest();
        
    }
}