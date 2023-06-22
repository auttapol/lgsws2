public with sharing class SLOSEmailService {

    @testVisible
    private static ISLOSEmailService mockService; 

    
     public static ISLOSEmailService newinstance() {
        if (null != mockService) return mockService;
        return (ISLOSEmailService)Application.Services.newInstance(SLOSEmailService.class);
    }

    public static void emailHostProductMappingNeedProductId(List<Host_Product_Mapping__c> hsprds){
        newinstance().emailHostProductMappingNeedProductId(hsprds);
    }
    
    public static void emailAfterStageChange(List<Opportunity> opty){
        newinstance().emailAfterStageChange(opty);
    }
    
    public static void emailOppStageMappingNotFound(List<Opportunity> opty){
        newinstance().emailOppStageMappingNotFound(opty);
    }

    public interface ISLOSEmailService {
        void emailHostProductMappingNeedProductId(List<Host_Product_Mapping__c> hsprds);
        void emailAfterStageChange(List<Opportunity> opty);
        void emailOppStageMappingNotFound(List<Opportunity> opty);
    }
}