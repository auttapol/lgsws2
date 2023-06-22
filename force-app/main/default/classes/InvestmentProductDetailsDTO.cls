global class InvestmentProductDetailsDTO {

	// Error Handler message
	global String SoapStatus { get; set; }
	global String SoapMessage { get; set; }

	global InvestmentInformationDTO InvestmentInformation { get; set; }
	global List<InvestmentTransactionDTO> InvestmentTransactions { get; set; }
	global List<AutoInvestmentPlanDTO> AutoInvestmentPlans { get; set; }


	public InvestmentProductDetailsDTO()
	{
		InvestmentInformation = new InvestmentInformationDTO();
		InvestmentTransactions = new List<InvestmentTransactionDTO>();
		AutoInvestmentPlans = new List<AutoInvestmentPlanDTO>();
	}

}