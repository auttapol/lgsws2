global class InvestmentTransactionDTO {
	// Error Handler message
	global String SoapStatus { get; set; }
	global String SoapMessage { get; set; }

	global Date TransactionDate { get; set; }
	global Date SettlementDate { get; set; }

	global String InteractChannel { get; set; }
	global String TransactionType { get; set; }
	global Decimal UnitMovement { get; set; }
	global Decimal UnitOutstanding { get; set; }
	global Decimal TransactionValue { get; set; }
	global Decimal ValuePerUnit { get; set; }
	global String Statue { get; set; }
	public InvestmentTransactionDTO()
	{
		UnitMovement =
		UnitOutstanding =
		TransactionValue =
		ValuePerUnit = 0;
	}
    
    global String convertedTransactionDate{
        get{
            return NumberHelper.DateFormat(TransactionDate);
        }
    }
    
    global String convertedSettlementDate{
        get{
            return NumberHelper.DateFormat(SettlementDate);
        }
    }
}