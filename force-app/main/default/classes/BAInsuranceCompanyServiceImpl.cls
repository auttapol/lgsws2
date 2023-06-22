public class BAInsuranceCompanyServiceImpl implements IBAInsuranceCompanyService {
	// Lazy Load
	private static Map<string /*company name*/, BA_Insurance_Company__c> BAInsuranceCompanies;
	public Map<string /*company name*/, BA_Insurance_Company__c> getAllBAInsuranceCompanies() {

		if (BAInsuranceCompanies == null) {
			System.Debug('TMB: -> BAInsuranceCompany Invoked');
			BAInsuranceCompanies = new Map<string /*company name*/, BA_Insurance_Company__c> ();
			List<BA_Insurance_Company__c> baCompanies = BAInsuranceCompanySelector.getAllBAInsuranceCompanies();
			// Create Map
			for (BA_Insurance_Company__c ba : baCompanies)
			{
				if (ba.Name != null && ba.Name != '')
				{
					if (!BAInsuranceCompanies.containsKey(ba.Name))
					{
						BAInsuranceCompanies.put(ba.Name, ba);
					}
				}
			}
		}
		return BAInsuranceCompanies;
	}

}