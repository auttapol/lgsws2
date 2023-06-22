@isTest
public class LeadProxyExtensionCtrlTest {
  static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
        TestUtils.createObjUserPermission();
        TestInit.createCustomSettingTriggerMsg();
        
    }
    
    
    public static RecordType CommercialLeadRecordType {get{
        if(CommercialLeadRecordType ==null){
           CommercialLeadRecordType = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Commercial Lead' 
                                 AND sObjectType='Lead' LIMIT 1];
        }
        return CommercialLeadRecordType;
    }set;}
    
    
    public static testmethod void myUnittest(){
         Lead leadRec = new Lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'Passport ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Individual';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.Account__c = null;
        leadrec.RecordTypeId = CommercialLeadRecordType.id;
        
         insert leadRec;
        Lead leadRec2 = new Lead();
        ApexPages.StandardController controller2 = new ApexPages.StandardController(leadRec2);
        LeadProxyExtensionCtrl proxyExCre = new LeadProxyExtensionCtrl(controller2);
        proxyExCre.redirectPage();
        proxyExCre.redirectMobile();
        
        PageReference proxy = Page.LeadProxyExtension;
        ApexPages.StandardController controller = new ApexPages.StandardController(leadRec);
        LeadProxyExtensionCtrl proxyEx = new LeadProxyExtensionCtrl(controller);
        proxyEx.redirectPage();
        proxyEx.redirectMobile();
        Test.setCurrentPage(proxy);
         
        
        
    }
    
    
    
    
    
}