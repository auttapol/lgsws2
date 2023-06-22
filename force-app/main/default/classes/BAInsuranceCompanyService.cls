public class BAInsuranceCompanyService { 
     /*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   Retail Account Service Factory
	  Inputs:        None
	  Test Class:    TestRetailAccountService
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  2016-04-18  Keattisak.C		 First Init
	  ----------------------------------------------------------------------------------*/
	@TestVisible
	private static IBAInsuranceCompanyService mock;
	@TestVisible
	private static void setMockservice(IBAInsuranceCompanyService mockService) {
		mock = mockService;
	}
	//Factory Medthod
	@TestVisible
	private static IBAInsuranceCompanyService service() {
	 
		if (Test.isRunningTest() && mock != null) return mock;
		return(IBAInsuranceCompanyService) new BAInsuranceCompanyServiceImpl();
	}

	public static  Map<string /*company name*/, BA_Insurance_Company__c> getAllBAInsuranceCompanies() {
	
			return service().getAllBAInsuranceCompanies();
		
	}
}