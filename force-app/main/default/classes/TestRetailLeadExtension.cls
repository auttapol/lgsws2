@isTest
public class TestRetailLeadExtension {
    static List<RTL_Referral__c> referralList;
    static List<Branch_And_Zone__c> branchAndZoneList;
    static List<RTL_Product_Master__c> retailProductMasterList;
    static{
        TestUtils.createAppConfig();
        TestUtility_Referral.createAppConfigCallMeNowBH();
    }
    static testmethod void testPositiveLeadCreation(){
        Test.startTest();
            Test.setCurrentPage(Page.RetailLeadCreation);
            Lead lead = new Lead();
            lead.LastName = 'xxx';
            lead.RTL_Mobile_Number__c = '0984387103';
            ApexPages.StandardController std = new ApexPages.StandardController(lead);
            ApexPages.currentPage().getParameters().put('saveAndNew', 'saveAndNew');
            RetailLeadExtension ext = new RetailLeadExtension(std);
            ext.save();
            ext.getisCreateMode();
            ext.cancelLead();
            ext.getDisplayS1();
        Test.stopTest();
        
    }
    
    static testmethod void testPositiveLeadCreation2(){
        Test.startTest();
            Test.setCurrentPage(Page.RetailLeadCreation);
            Lead lead = new Lead();
            lead.LastName = 'xxx';
            lead.RTL_Mobile_Number__c = '0984387103';
            ApexPages.StandardController std = new ApexPages.StandardController(lead);
            ApexPages.currentPage().getParameters().put('saveAndNew', 'saveAndNew');
            RetailLeadExtension ext = new RetailLeadExtension(std);
            ext.saveLead();
            ext.getisCreateMode();
            ext.cancelLead();
            ext.getDisplayS1();
        Test.stopTest();
        
    }
    
    static testmethod void testCreateLeadwithReferralCrossChannel(){
        TestUtility_Referral.createAppConfigReferralAssignment();
        TestUtility_Referral.createReferralAssignment();
        retailProductMasterList = retailProductMasterList = RTL_TestUtility.createRetailProducts(true);
        branchAndZoneList = RTL_TestUtility.createBranchZone(9,true);
        referralList = TestUtility_Referral.createReferralsCrossChannelWithoutAccount(1,branchAndZoneList[0].id,retailProductMasterList[0].id,true);
        Test.startTest();
            Test.setCurrentPage(Page.RetailLeadCreation);
            Lead lead = new Lead();
            lead.LastName = 'xxx';
            lead.RTL_Mobile_Number__c = '0984387103';
            ApexPages.StandardController std = new ApexPages.StandardController(lead);
            ApexPages.currentPage().getParameters().put('saveAndNew', 'saveAndNew');
            ApexPages.currentPage().getParameters().put('referralId', referralList[0].id);
            RetailLeadExtension ext = new RetailLeadExtension(std);
            ext.lead.RTL_ID_Type__c = 'Others';
            ext.lead.RTL_Citizen_Id__c = '259987' ;
            ext.lead.Status = 'Contacted';
            ext.saveLead();
            ext.getisCreateMode();
            ext.cancelLead();
            ext.getDisplayS1();
        Test.stopTest();
        
    }
    
    static testmethod void testCreateLeadwithReferral(){
        TestUtility_Referral.createAppConfigReferralAssignment();
        TestUtility_Referral.createReferralAssignment();
        branchAndZoneList = RTL_TestUtility.createBranchZone(9,true);
        referralList = TestUtility_Referral.createReferralsWithoutAccount(1,branchAndZoneList[0].id,'Payroll','Sell (เพื่อนำเสนอขาย)',true);
        Test.startTest();
            Test.setCurrentPage(Page.RetailLeadCreation);
            Lead lead = new Lead();
            lead.LastName = 'xxx';
            lead.RTL_Mobile_Number__c = '0984387103';
            ApexPages.StandardController std = new ApexPages.StandardController(lead);
            ApexPages.currentPage().getParameters().put('saveAndNew', 'saveAndNew');
            ApexPages.currentPage().getParameters().put('referralId', referralList[0].id);
            RetailLeadExtension ext = new RetailLeadExtension(std);
            ext.save();
            ext.getisCreateMode();
            ext.cancelLead();
            ext.getDisplayS1();
        Test.stopTest();
        
    }
    
    static testmethod void testNegativeLeadCreation(){
        Test.startTest();
            Test.setCurrentPage(Page.RetailLeadCreation);  
            ApexPages.StandardController std = new ApexPages.StandardController(new Lead());
            RetailLeadExtension ext = new RetailLeadExtension(std);
            ext.save();
            ext.getisCreateMode();
        Test.stopTest();
        
    }
    
    static testmethod void testNegativeLeadCreation2(){
        Test.startTest();
            Test.setCurrentPage(Page.RetailLeadCreation);  
            ApexPages.StandardController std = new ApexPages.StandardController(new Lead());
            RetailLeadExtension ext = new RetailLeadExtension(std);
            ext.saveLead();
            ext.getisCreateMode();
        Test.stopTest();
        
    }
    
    static testmethod void testPositiveLeadUpdate(){
        Lead lead = new Lead();
        lead.LastName = 'xxx';
        lead.Company = 'xxx';
        lead.RTL_Mobile_Number__c = '0984387103';
        insert lead;
        
        Test.startTest();
            Test.setCurrentPage(Page.RetailLeadCreation);
            ApexPages.StandardController std = new ApexPages.StandardController(lead);
            RetailLeadExtension ext = new RetailLeadExtension(std);
            ext.saveLead();
            ext.getisCreateMode();
            ext.cancelLead();
        Test.stopTest();
        
    }
}