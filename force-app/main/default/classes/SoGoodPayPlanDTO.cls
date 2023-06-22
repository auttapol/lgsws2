global class SoGoodPayPlanDTO {

	global decimal LastCycleTransactionNonInterestCharge { get; set; }
	global decimal LastCycleAmountInTHBNonInterestCharge { get; set; }

	global decimal LastCycleTransactionInterestCharge { get; set; }
	global decimal LastCycleAmountInTHBInterestCharge { get; set; }

	global decimal TotalTransaction { get; set; }
	global decimal TotalTHB { get; set; }

	public SoGoodPayPlanDTO()
	{
		LastCycleTransactionNonInterestCharge =
		LastCycleAmountInTHBNonInterestCharge =
		LastCycleTransactionInterestCharge =
		LastCycleAmountInTHBInterestCharge =
		TotalTransaction =
		TotalTHB = 0;
	}
}