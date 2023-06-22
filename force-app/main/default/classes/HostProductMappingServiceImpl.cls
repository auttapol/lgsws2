public with sharing class HostProductMappingServiceImpl
    implements HostProductMappingService.IHostProductMappingService {
    public HostProductMappingServiceImpl() {
    }   
    public void nofifyHostProductMappingNeedProductId() {
        system.debug('HostProductMappingServiceImpl Run');
        // 1) Get All Host_Product_Mapping__c that no Product2 id assigned
        List<Host_Product_Mapping__c> unmappingHostproducts = new  List<Host_Product_Mapping__c>();
        for ( List<Host_Product_Mapping__c> rets :
                [Select id, Name, Active_Flag__c, Host_Name__c, Host_Prod_Name_Credit_Facility__c, 
                Host_Product_Code__c, Host_Product_Group__c, Product_Program__c, Salesforce_Product__c 
                From Host_Product_Mapping__c 
                where Salesforce_Product__c = null ]) {
            unmappingHostproducts.addAll(rets);
        }
        // 2) if there are product need to notify
        if (unmappingHostproducts.size() > 0) {
           SLOSEmailService.emailHostProductMappingNeedProductId(unmappingHostproducts);
        }
    }
    
}