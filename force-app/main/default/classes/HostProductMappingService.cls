public with sharing class HostProductMappingService {
	@testVisible
	private static IHostProductMappingService mockService;

	private static IHostProductMappingService newinstance() {
		if (null != mockService) return mockService;
		return (IHostProductMappingService) Application.Services.newInstance(HostProductMappingService.class);
	}

	// SLOS Email Notify to crm team there are some host product  mapping need to map
	public static void nofifyHostProductMappingNeedProductId() {        
		system.debug('=> Invoked nofifyIHostProductMappingNeedProductId ');
		newinstance().nofifyHostProductMappingNeedProductId();
	}
	public interface IHostProductMappingService {
		void nofifyHostProductMappingNeedProductId();
	}
}