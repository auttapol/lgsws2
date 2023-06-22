global class AutoInvestmentPlanDTO {

	// Error Handler message
	global String SoapStatus { get; set; }
	global String SoapMessage { get; set; }

	global String Instruction { get; set; }
	// TSD is Date  but when implement should be String
	global String Date_x { get; set; }
	global Date SinceDate { get; set; }
	global String CreatedChannel { get; set; }
	global String Frequency { get; set; }
	global Decimal Balance { get; set; }
	global String SavingAccountBundling { get; set; }


	public AutoInvestmentPlanDTO()
	{
		Balance = 0;
	}
	public string MarkedSavingAccountBundling {
		get {
			return NumberHelper.MarkAccountNo(SavingAccountBundling);
		}
	}
    
    global String convertedSinceDate{
        get{
            return NumberHelper.DateFormat(SinceDate);
        }
    }
    

}