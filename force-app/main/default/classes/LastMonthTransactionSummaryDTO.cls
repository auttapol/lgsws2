global class LastMonthTransactionSummaryDTO {
	/*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   Data Transfer Objects
	  Inputs:        None
	  Base Class:    -
	  Test Class:    -
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  ----------------------------------------------------------------------------------*/
	global decimal OfDeposit { get; set; }
	global decimal OfWithdraw { get; set; }
	global decimal OfTransferOutTMB { get; set; }
	global decimal OfTransferOutOther { get; set; }
	global decimal OfBillPayment { get; set; }

	public LastMonthTransactionSummaryDTO()
	{
		OfDeposit = OfWithdraw = OfTransferOutTMB = OfTransferOutOther = OfBillPayment = 0;
	}
}