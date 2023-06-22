/**
 * @author ktc@tmbbank.com.acctplan
 * @description 

  Mock Services
  --------------------------------------------------------
  String clName = AccountPlanRefreshService.class.getName();
  // 
  // Bootstrap__c cs = Bootstrap__c.getInstance(clName);
  // 
  // Type t = Type.forName(className);
  // return (ClassFactory.IClassFactory) t.newInstance();
  // return (IAccountPlanRefreshService) t.newInstance();
 
*/


global without sharing class AccountPlanRefreshService {
	/**
	 * @description Support Mock Service
	 */
	@TestVisible
	private static IAccountPlanRefreshService mock;

	/**
	 * @description 
	 * @param mockService  Mock object to fake Implementation
	 */
	@TestVisible
	private static void setMockservice(IAccountPlanRefreshService mockService) {
		mock = mockService;
	}


	//Factory Medthod
	@TestVisible
	private static IAccountPlanRefreshService service() {

		if (Test.isRunningTest() && mock != null) return mock;
		return(IAccountPlanRefreshService) new AccountPlanRefreshServiceImpl();
	}

    global static void RefreshProductStrategyPort(Set<Id> accountIds, string year) {
		service().RefreshProductStrategyPort(accountIds, year);
	}
	/*start R5.2*/
	global static void RefreshProductStrategyPort(Set<Id> accountIds, string year,Id groupId) {
		service().RefreshProductStrategyPort(accountIds, year,groupId);
	}
    global static void RefreshProductStrategy2(Set<Id> accountIds, string year,Id groupId){
		service().RefreshProductStrategy2(accountIds, year, groupId);
	}
	global static void RefreshProductStrategyGroupWalletGroupPerformance(Set<Id> acctId,Set<Id> acctPlanCompanyId, Set<Id>  acctPlanWallet, String acctPlanGruopId) {
		service().RefreshProductStrategyGroupWalletGroupPerformance(acctId, acctPlanCompanyId,acctPlanWallet, acctPlanGruopId);
	}
	/*End R5.2*/

	global static void RefreshProductStrategy(Set<Id> accountIds, string year, id groupProfilesId) {
		service().RefreshProductStrategy(accountIds, year, groupProfilesId);
	}
	global static boolean RefreshDepositInter(String acctPlanCompanyId, String acctPlanWallet, String acctPlanGruopId) {

		Savepoint sp = Database.setSavepoint();
		Boolean ret = false;
		try {
			service().RefreshDepositInter(acctPlanCompanyId, acctPlanWallet, acctPlanGruopId);
			ret = true;
		}
		catch(Exception ex)
		{
			Database.rollback(sp);
			system.debug(ex);
			throw new AccountPlanRefreshServiceException(ex);

		}
		return ret;
	}

	global static boolean RefreshDepositDomestic(String acctPlanCompanyId, String acctPlanWallet, String acctPlanGruopId) {
		Savepoint sp = Database.setSavepoint();
		Boolean ret = false;
		try {
			service().RefreshDepositDomestic(acctPlanCompanyId, acctPlanWallet, acctPlanGruopId);
			ret = true;
		}
		catch(Exception ex)
		{
			Database.rollback(sp);
			system.debug(ex);
			throw new AccountPlanRefreshServiceException(ex);

		}
		return ret;


	}

	/*
	 * Parameter : listPortfolioId is id of AcctPlanPortfolio
	 * Return :
	 *          true = the process was done successfully
	 *          false = the process was false with AccountPlanRefreshServiceException exception  
	 * */
	global static Boolean RefreshWalletAndAnnualPerformanceRolling12Month(Set<ID> listPortfolioId) {
		Savepoint sp = Database.setSavepoint();
		Boolean ret = false;
		try {
			service().RefreshWalletAndAnnualPerformanceRolling12Month(listPortfolioId);
			ret = true;
		}
		catch(Exception ex)
		{
			Database.rollback(sp);
			system.debug(ex);
			throw new AccountPlanRefreshServiceException(ex);

		}
		return ret;
	}


	/* global static  Boolean RefreshCompanyProfileProductStrategy(Id companyProfileId,Id acctPlanWallet){
	  Savepoint sp = Database.setSavepoint();        
	  Boolean ret = false;
	  try{
	  service().RefreshCompanyProfileProductStrategy(companyProfileId,acctPlanWallet);
	  ret = true;
	  }
	  catch(Exception ex)
	  {
	  Database.rollback(sp);
	  system.debug(ex);
	  throw new AccountPlanCompanyPortSelectorException(ex);
	 
	  }        
	  return ret;
	  }
	 */
	//DA
	global static Boolean RefreshCompanyPerformanceProductStrategyForStep6(String companyProfileId, String acctPlanWallet, String acctPlanGruopId) {
		Savepoint sp = Database.setSavepoint();
		Boolean ret = false;
		try {
			service().RefreshProductStrategyAndWalletByDomain(companyProfileId, acctPlanWallet, acctPlanGruopId);
			service().RefreshCompanyPerformanceProductStrategyForStep6(companyProfileId);
			ret = true;
		}
		catch(Exception ex)
		{
			Database.rollback(sp);
			system.debug(ex);
			throw new AccountPlanRefreshServiceException(ex);

		}
		return ret;
	}

	global static Boolean RefreshGroupPerformanceProductStrategyForStep6(String groupProfileId) {
		Savepoint sp = Database.setSavepoint();
		Boolean ret = false;
		try {
			service().RefreshGroupPerformanceProductStrategyForStep6(groupProfileId);
			ret = true;
		}
		catch(Exception ex)
		{
			Database.rollback(sp);
			system.debug(ex);
			throw new AccountPlanRefreshServiceException(ex);

		}
		return ret;
	}

	global static Boolean RefreshPortfolioPerformanceProductStrategyForStep0(String portfolioId) {
		Savepoint sp = Database.setSavepoint();
		Boolean ret = false;
		try {
			service().RefreshPortfolioPerformanceProductStrategyForStep0(portfolioId);
			ret = true;
		}
		catch(Exception ex)
		{
			Database.rollback(sp);
			system.debug(ex);
			throw new AccountPlanRefreshServiceException(ex);

		}
		return ret;
	}

	global static Boolean RefreshProductStrategyAndWalletByDomain(String acctPlanCompanyId, String acctPlanWallet, String acctPlanGruopId) {
		Savepoint sp = Database.setSavepoint();
		Boolean ret = false;
		try {
			if (acctPlanGruopId == null || acctPlanGruopId == '') {
				service().RefreshProductStrategyAndWalletByDomain(acctPlanCompanyId, acctPlanWallet, '');
			}
			else {
				service().RefreshProductStrategyAndWalletByDomain(acctPlanCompanyId, acctPlanWallet, acctPlanGruopId);
			}
			//add byDA
			service().RefreshCompanyPerformanceProductStrategyForStep6(acctPlanCompanyId);
			ret = true;
		}
		catch(Exception ex)
		{
			Database.rollback(sp);
			system.debug(ex);
			throw new AccountPlanRefreshServiceException(ex);
		}
		return ret;
	}

	global static void RefreshNameProductStrategyPort(Set<Id> accountIds, string year) {
		service().RefreshNameProductStrategyPort(accountIds, year);
	}

	global static void RefreshGroupPerformance(Set<Id> accountIds, string year) {
		service().RefreshGroupPerformance(accountIds, year);
	}

	global static List<AccountPlanRefreshService.CustomerWalletInfo> initialStep0(string accountIds) {
		return service().initialStep0(accountIds);
	}

	global class AccountPlanRefreshServiceException extends Exception {
	}

	global class CustomerWalletInfo {
		public Id Id { get; set; }
		public Decimal Wallet { get; set; }
		public Decimal Annual { get; set; }
	}
}