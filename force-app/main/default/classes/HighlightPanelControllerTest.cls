@istest
public class HighlightPanelControllerTest {
    @isTest static void test(){
        //HighlightPanelController.getWatermarkHTML();
        TestUtils.createAppConfig();
        
        Account acc = new Account();
        acc.Name = 'Name';
        acc.Mobile_Number_PE__c = '0888888888';
        acc.Phone = '0222229900';
        acc.Email_Address_PE__c = 'aaa@a.com';
        INSERT acc;
        
        HighlightPanelController.getLatestNPS(acc.Id);
        
        CXM_Survey__c ss = new CXM_Survey__c();
        ss.Account__c = acc.Id;
        ss.Survey_Score__c = 9;
        insert ss;
        
        HighlightPanelController.getLatestNPS(acc.Id);
        //HighlightPanelController.getAccInfo(acc.Id);
        //HighlightPanelController.getMainBank(acc.Id);
        
        Customer_Main_Bank_Info__c mb = new Customer_Main_Bank_Info__c();
        mb.Customer__c = acc.Id;
        mb.Calculation_Date__c = System.today();
        mb.Main_Bank_Status__c = 'Y';
        insert mb;
        
        //HighlightPanelController.getMainBank(acc.Id);
        
        Branch_and_Zone__c bz = new Branch_and_Zone__c();
        bz.Name = 'สวนหลวง';
        insert bz;
        //HighlightPanelController.getBranchId(bz.Id);
        
        HighlightPanelController.getAccInfo(acc.Id);
          HighlightPanelController.getMainBank(acc.Id);
    }
}