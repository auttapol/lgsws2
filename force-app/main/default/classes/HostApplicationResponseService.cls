global with sharing class HostApplicationResponseService {
    
    @testVisible
    private static IHostApplicationResponseService mockService;

    public static IHostApplicationResponseService newinstance(){
        if (mockService != null) return mockService;
        return (IHostApplicationResponseService) Application.Services.newInstance(HostApplicationResponseService.class);
    }
    
    global static void HostApplicationResponseMainProcess(list<host_application_response__c> listHostApp, list<host_application_response__c> listOldHostApp){
        newinstance().HostApplicationResponseMainProcess(listHostApp, listOldHostApp);
    }


    /****************
    * INTERFACE
    ****************/    
    public interface IHostApplicationResponseService {
        void HostApplicationResponseMainProcess(list<host_application_response__c> listHostApp, list<host_application_response__c> listOldHostApp);
    }
    
}