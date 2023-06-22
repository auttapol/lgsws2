global class RetailAccountService { 
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
	private static IRetailAccountService mock;
	@TestVisible
	private static void setMockservice(IRetailAccountService mockService) {
		mock = mockService;
	}
	//Factory Medthod
	@TestVisible
	private static IRetailAccountService service() {

		if (Test.isRunningTest() && mock != null) return mock;
		return(IRetailAccountService) new RetailAccountServiceImpl();
	}

	global  static Boolean UpdateTotalAccountsAndSumOfDepesite(string accountId, decimal noOfProduct, decimal sumOfTotalDepositeOutstanding){ 
	   return service().UpdateTotalAccountsAndSumOfDepesite(accountId,noOfProduct,sumOfTotalDepositeOutstanding);
	}	
	
	global  static Account GetAccountById(Id acctId){

	 return service().GetAccountById(acctId);
	}
}