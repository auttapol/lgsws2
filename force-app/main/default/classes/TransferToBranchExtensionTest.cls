@istest
public class TransferToBranchExtensionTest {
	
    static List<Branch_And_Zone__c> branchAndZoneList;
    static RTL_Referral__c referral;
    static User rmcUser;
    static User bdmUser;
    static User adminUser;

    static {
        TestUtils.createAppConfig();
        TestUtility_Referral.createAppConfigReferralAssignment();
        branchAndZoneList = RTL_TestUtility.createBranchZone(9,true);
        adminUser = TestUtils.createUsers(1,'USERADMIN','TESTCLASS','test_TMB@tmbbank.com',true)[0];
        
        ID RMC_ROLE_ID = [SELECT Id FROM UserRole WHERE Name LIKE '%RMC%' LIMIT 1].id;
        System.debug('RMC ROLE ID '+RMC_ROLE_ID);
        
        System.runAs(adminUser){
            //create rmc user for test
            rmcUser = TestUtility_Referral.createRMCTestUser(true);
            //create bdm user for test 
            bdmUser = TestUtility_Referral.createBDMTestUser(true);
        }
        
    }
    
    static testmethod void testTransferToBranch(){
    	System.runAs(rmcUser){
            //Insert referral without account
            referral = new RTL_Referral__c(RTL_FirstName__c='Test Referral',
                                           RTL_LastName__c='Without Account',
                                           RTL_Preferred_Branch__c = branchAndZoneList[0].id,
                                           RTL_Mobile1__c = '1111111111',
                                           RTL_Interested_Product__c = 'Payroll',
                                           RTL_Type__c = 'Sell (เพื่อนำเสนอขาย)',
                                           RTL_Sales_Amount_Per_Year__c = 'SE : <100 MB',
                                           RTL_Channel_Segment__C = 'Web'); 
            insert referral;
        }    
        Test.startTest();
        	
        	ApexPages.StandardController sc = new ApexPages.StandardController(referral);
        	TransferToBranchExtension ext = new TransferToBranchExtension(sc);
        
       		PageReference pageRef = Page.TransferReferralToBranch;
        
        	Test.setCurrentPage(pageRef);
        
        	ext.validateReferral();
        	ext.save();
        Test.stopTest();
    }
    
    static testmethod void testTransferToBranchMobile(){
    	System.runAs(rmcUser){
            //Insert referral without account
            referral = new RTL_Referral__c(RTL_FirstName__c='Test Referral',
                                           RTL_LastName__c='Without Account',
                                           RTL_Preferred_Branch__c = branchAndZoneList[0].id,
                                           RTL_Mobile1__c = '1111111111',
                                           RTL_Interested_Product__c = 'Payroll',
                                           RTL_Type__c = 'Sell (เพื่อนำเสนอขาย)',
                                           RTL_Sales_Amount_Per_Year__c = 'SE : <100 MB',
                                           RTL_Channel_Segment__C = 'Web'); 
            insert referral;
        }    
        Test.startTest();
        	
        	ApexPages.StandardController sc = new ApexPages.StandardController(referral);
        	TransferToBranchExtension ext = new TransferToBranchExtension(sc);
        
        	PageReference pageRef = Page.TransferReferralToBranch;
        
        	Test.setCurrentPage(pageRef);
        
        	ext.validateReferral();
        	ext.interestedProductSelectedList.add(ext.interestedProductList[0]);
        	ext.saveMobile();
        Test.stopTest();
    }
    
    static testmethod void testInvalidTransferToBranch(){
    	System.runAs(rmcUser){
            //Insert referral without account
            referral = new RTL_Referral__c(RTL_FirstName__c='Test Referral',
                                           RTL_LastName__c='Without Account',
                                           RTL_Preferred_Branch__c = branchAndZoneList[0].id,
                                           RTL_Mobile1__c = '1111111111',
                                           RTL_Interested_Product__c = 'Payroll',
                                           RTL_Type__c = 'Sell (เพื่อนำเสนอขาย)',
                                           RTL_Sales_Amount_Per_Year__c = 'SE : <100 MB',
                                           RTL_Channel_Segment__C = 'Branch'); 
            insert referral;
        }    
        Test.startTest();
        	
        	ApexPages.StandardController sc = new ApexPages.StandardController(referral);
        	TransferToBranchExtension ext = new TransferToBranchExtension(sc);
        
        	PageReference pageRef = Page.TransferReferralToBranch;
        
        	Test.setCurrentPage(pageRef);
        
        	ext.validateReferral();
        	ext.save();
        Test.stopTest();
    }
}