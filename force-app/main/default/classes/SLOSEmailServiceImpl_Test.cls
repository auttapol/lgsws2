@isTest
private class SLOSEmailServiceImpl_Test {
    // Initial test data here
    @testSetup 
    static void initial() {
        // Custiom setting
        List<AppConfig__c> appconfigs = new List<AppConfig__c>();
        appconfigs.add(new AppConfig__c(Name = 'SLOS CRM', Value__c ='test@thai.com;test2@thail.com'));
        appconfigs.add(new AppConfig__c(Name = 'SLOS Host Product Mapping Email', Value__c ='Dear CRM Admin, <br /><br />There has been a product from Host which cannot be mapped to Salesforce product. <br /><br />{{Products}}<br /><br />Please kindly investigate and update the information on Host Product Mapping object.<br /><br />Thanks,<br />'));                       
        appconfigs.add(new AppConfig__c(Name = 'SLOS Host Product Mapping Email Title', Value__c ='Salesforce Notification : There has been a product from Host which cannot be mapped to Salesforce product'));           
        appconfigs.add(new AppConfig__c(Name = 'runtrigger', Value__c = 'true'));
        insert appconfigs;       
        //Mock Un Map Host Product
        Host_Product_Mapping__c pro = new Host_Product_Mapping__c();
        pro.Active_Flag__c = true;
        pro.Host_Name__c ='SLS';
        pro.Host_Prod_Name_Credit_Facility__c = 'OD';
        pro.Host_Product_Code__c = 'SLS001';
        pro.Host_Product_Group__c = 'TMB SME SmartBiz';
        pro.Product_Program__c = 'TMB SME SmartBiz';               
        insert pro;   
    }
    @isTest 
    private static void test_method_getCRMAdminEmails() {
        SLOSEmailServiceImpl svr = new SLOSEmailServiceImpl();
        list<String> email = svr.getCRMAdminEmails();
        system.assertEquals(2,email.size(),'Email size not equal 2 ');  
    }
    @isTest 
    private static void test_method_SendUnmapProduct() {        
        List<Host_Product_Mapping__c> unmappingHostproducts = new  List<Host_Product_Mapping__c>();
        for ( List<Host_Product_Mapping__c> rets : [Select id, Name, Active_Flag__c, Host_Name__c, Host_Prod_Name_Credit_Facility__c, Host_Product_Code__c, Host_Product_Group__c, Product_Program__c, Salesforce_Product__c From Host_Product_Mapping__c where Salesforce_Product__c = null ]) {
            unmappingHostproducts.addAll(rets);
        }     
        system.assertEquals(1,unmappingHostproducts.size(),'Host Product size not equal 1 ');          
        HostProductMappingService.nofifyHostProductMappingNeedProductId();
    }
}