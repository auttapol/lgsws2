global class RetailProductService {
	/*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   RetailProduct Service Factory
	  Inputs:        None
	  Test Class:    TestRetailProductService
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  2016-04-18  Keattisak.C		 First Init
	  ----------------------------------------------------------------------------------*/
	@TestVisible
	private static IRetailProductService mock;
	@TestVisible
	private static void setMockservice(IRetailProductService mockService) {
		mock = mockService;
	}
	//Factory Medthod
	@TestVisible
	private static IRetailProductService service() {

		if (Test.isRunningTest() && mock != null) return mock;
		return(IRetailProductService) new RetailProductServiceImpl();
	}
	public static Map<string /*product code*/, RTLProductMasterDTO> getOnlyRTLProducts() {
	
			return service().getOnlyRTLProducts();
		
	}
}