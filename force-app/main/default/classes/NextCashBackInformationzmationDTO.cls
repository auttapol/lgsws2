global class NextCashBackInformationzmationDTO {
	global Date PaymentDate { get; set; }
	global Decimal Amount { get; set; }
	global Decimal TotalPaid { get; set; }


	// Error Handler message
	global String SoapStatus { get; set; }
	global String SoapMessage { get; set; }

	global NextCashBackInformationzmationDTO()
	{
		Amount = TotalPaid = 0;
	}
    
    global String convertedPaymentDate{
        get{
            return NumberHelper.DateFormat(PaymentDate);
        }
    }
}