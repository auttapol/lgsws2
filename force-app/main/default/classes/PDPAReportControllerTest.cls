@Istest
public class PDPAReportControllerTest {
	@istest
    static void test(){
         TestUtils.createAppConfig();
        Account acc = new Account();
        acc.Name = 'Name';
        acc.RMC_Has_PDPA__c = 'Y';
        acc.RTL_Wealth_RM__c = userinfo.getUserId();
        acc.Phone = '082221111';
        acc.Mobile_Number_PE__c = '019292222';
        acc.RMC_Has_Market_Conduct__c = 'N';
        insert acc;
        
        PDPAReportController.getPDPAReport();
        PDPAReportController.getMarketConductReport();
        PDPAReportController.getPDPAList(acc.Id);
        
         Account acc2 = new Account();
        acc2.Name = 'Name';
        acc2.RMC_Has_PDPA__c = 'Y';
        acc2.RTL_Wealth_RM__c = userinfo.getUserId();
        acc2.Phone = '082221111';
        acc2.Mobile_Number_PE__c = '019292222';
        acc2.RMC_Has_Market_Conduct__c = 'N';
        acc2.Email_Address_PE__c = 'aaaaa@aaa.com';
        insert acc2;
        PDPAReportController.getPDPAList(acc2.Id);
        
        PDPAReportController.getPDPAList('test hello test test');
        
        PDPAReportController.printPDPA(acc2.Id, 0);
        PDPAReportController.sendEmailController(acc2.Id, 0);
        PDPAReportController.editPDPAController(0, acc2.Id, 'type');
        
    }
}