public with sharing class Application {
    // Central configuration
    public static final iilib_Application.ServiceFactory Services =
        new iilib_Application.ServiceFactory(
                                                new Map<Type, Type> {
                                                /************************************************************************
                                                |   Service class                   => Implement class                  |
                                                ************************************************************************/
                                                    HostProductMappingService.class  => HostProductMappingServiceImpl.class,
                                                    SLOSEmailService.class           => SLOSEmailServiceImpl.class ,
                                                    HostProductResponseService.class => HostProductResponseServiceImpl.class,
                                                    SLOSServiceBroker.class => SLOSServiceImpl.class ,
                                                    HostApplicationResponseService.class => HostApplicationResponseServiceImpl.class
                                                }
        ); 
}