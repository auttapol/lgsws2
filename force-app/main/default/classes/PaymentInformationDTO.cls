global class PaymentInformationDTO {
	global String PaymentMode { get; set; }
	global Decimal PremiumAmount { get; set; }
	global String PaymentMethod { get; set; }
	global Decimal TotalPremiumPaid { get; set; }
	global String YearOfPayment { get; set; }
	global Decimal NumberOfTimePremiumPaid { get; set; }
	global Date NextDueDate { get; set; }
	global Date LastPaymentDate { get; set; }


	// Error Handler message
	global String SoapStatus { get; set; }
	global String SoapMessage{ get; set; }


	public PaymentInformationDTO()
	{
		PremiumAmount = TotalPremiumPaid = NumberOfTimePremiumPaid = 0;
	}
    
    global String convertedNextDueDate{
        get{
            return NumberHelper.DateFormat(NextDueDate);
        }
    }
    
    global String convertedLastPaymentDate{
        get{
            return NumberHelper.DateFormat(LastPaymentDate);
        }
    }

}