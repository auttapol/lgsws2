global class BancassuranceDetailsDTO {
	//Key to find BA_Insurance_Company__c
	global String InsuranceCompany { get; set; }

	global String Address { get; set; }
	global String ContactNumber1 { get; set; }
	global String ContactNumber2 { get; set; }
	// Data stored in Salesforce

	// Error Handler message
	global String SoapStatus { get; set; }
	global String SoapMessage { get; set; }

}