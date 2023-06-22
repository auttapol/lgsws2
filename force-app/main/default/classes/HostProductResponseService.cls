global with sharing class HostProductResponseService {
    @testVisible
    private static IHostProductResponseService mockService;
    public static IHostProductResponseService newinstance() {
        if (null != mockService) return mockService;
        return (IHostProductResponseService)Application.Services.newInstance(HostProductResponseService.class);
    }

    /***************************************************
    * @author Keattisak Chinburarat
    * @date 2016-11-24
    * @description
    ****************************************************/
    global static void reMappingHostProductResponseToOppLineItem(List<Host_Product_Response__c> hostProductResponse) {
        newinstance().reMappingHostProductResponseToOppLineItem(hostProductResponse);
    }
    /***************************************************
    * @author P'win
    * @date 2017-01-25
    * @description
     ****************************************************/
    global static void populateProductID(list<Host_Product_Response__c> listhostproductIN) {
        newinstance().populateProductID(listhostproductIN);
    }

    global static void checkProductExistInSalesforce(list<Host_Product_Response__c> listhostproductIN, boolean isUpdate){
        newinstance().checkProductExistInSalesforce(listhostproductIN,isUpdate);
    }

    global static void createProductMapping() {
        newinstance().createProductMapping();
    }

    /*
    global static void HostProductResponseTriggerMainProcess() {
        newinstance().HostProductResponseTriggerMainProcess();
    }

    global static Opportunitylineitem mapFieldOpportunityProduct(Opportunitylineitem oppProduct, host_product_response__c hostProductResponse) {
        return newinstance().mapFieldOpportunityProduct(oppProduct,hostProductResponse);
    }
    */
    
    global static void validateCurrentAppAfterUpsertHostApp(list<Host_Product_Response__c> listhostproductIN) {
        newinstance().validateCurrentAppAfterUpsertHostApp(listhostproductIN);
    }


    /***********************************************************************************
    *  INTERFACE
    ***********************************************************************************/
    public interface IHostProductResponseService {
        void reMappingHostProductResponseToOppLineItem(List<Host_Product_Response__c> hostProductResponse);
        // P'win
        void populateProductID(list<Host_Product_Response__c> listhostproductIN);
        void checkProductExistInSalesforce(list<Host_Product_Response__c> listhostproductIN, boolean isUpdate);
        void createProductMapping();
        //void HostProductResponseTriggerMainProcess();
        //Opportunitylineitem mapFieldOpportunityProduct(Opportunitylineitem oppProduct, host_product_response__c hostProductResponse);
        void validateCurrentAppAfterUpsertHostApp(list<Host_Product_Response__c> listhostproductIN);
    }
}