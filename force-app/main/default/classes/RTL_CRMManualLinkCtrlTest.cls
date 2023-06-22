@isTest
public class RTL_CRMManualLinkCtrlTest {

    static testmethod void testPage(){
        PageReference crmManualLink = Page.RTL_CRM_Manual_Link;
        Test.setCurrentPage(crmManualLink);
        
        ReportProfileMapping__c reportProfileMapping = new ReportProfileMapping__c();
        reportProfileMapping.Name = 'Report';
        reportProfileMapping.ReferralReportName__c = 'Referral_Retail_Notification_list';
        reportProfileMapping.ProfileName__c = 'System Administrator';
        reportProfileMapping.IsActive__c = true;
        insert reportProfileMapping;
        
        
        Test.startTest();
        	RTL_CRMManualLinkCtrl ctrl = new RTL_CRMManualLinkCtrl();
        	Integer countReferral = ctrl.countNewReferral;
        	String reportReferral = ctrl.reportPageReferral;
        Test.stopTest();
    }
}