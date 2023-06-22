public with sharing class HostProductMappingSchedulableHandler 
					implements HostProductMappingSchedulableDispatcher.IHostProductMappingSchedulableDispatched {
    public void execute(){
        system.debug('=> Invoked HostProductMappingSchedulableHandler ');		
        HostProductMappingService.nofifyHostProductMappingNeedProductId();     
    }
}