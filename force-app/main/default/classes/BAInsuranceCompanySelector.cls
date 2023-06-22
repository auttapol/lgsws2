public class BAInsuranceCompanySelector { 
/*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   Selector for BA_Insurance_Company__c
	  Inputs:        None
	  Test Class:    TestBAInsuranceCompanySelector
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  ----------------------------------------------------------------------------------*/
	private static string selectAll() {
		return 'SELECT Id,Name,Address__c,ContactNo1__c,ContactNo2__c  FROM BA_Insurance_Company__c ';
	}
	public static List<BA_Insurance_Company__c> getAllBAInsuranceCompanies() {
		List<BA_Insurance_Company__c> ret;
		string sql = selectAll();
		System.Debug('TMB: -> SOQL : ' + sql);
		try
		{
			ret = (List<BA_Insurance_Company__c>) Database.query(sql);
		}
		catch(Exception ex)
		{
			throw new RetailProductSelectorException('There is some error when query BA_Insurance_Company__c', ex);
		}
		return ret;
	}
	public class RetailProductSelectorException extends Exception {
	}

}