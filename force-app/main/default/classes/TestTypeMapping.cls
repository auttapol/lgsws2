@isTest
private class TestTypeMapping {


	@istest
	private static void testOSC01() {
		RTL_CustomerProductHoldingsService.CustomerProductHoldings item = new RTL_CustomerProductHoldingsService.CustomerProductHoldings();
        RTL_CustomerProductHoldingsService.MuleInfo muleInfo = new RTL_CustomerProductHoldingsService.MuleInfo();
        item.MuleInfo = muleInfo;
		//Deposit Detail
  
        RTL_CustomerProductHoldingsService.DepositAccountsType accountsType = new RTL_CustomerProductHoldingsService.DepositAccountsType();
        accountsType.MuleInfo = muleInfo;
        item.DepositAccounts = accountsType;
        accountsType.DepositAccount = new List<RTL_CustomerProductHoldingsService.DepositAccount>();
        accountsType.DepositAccount.add(new RTL_CustomerProductHoldingsService.DepositAccount());
        
        //Credit Detail
        RTL_CustomerProductHoldingsService.CreditCardAccountsType creditAccountsType = new RTL_CustomerProductHoldingsService.CreditCardAccountsType();
        creditAccountsType.muleInfo = muleInfo;
        item.CreditCardAccounts = creditAccountsType;
        creditAccountsType.CreditCardAccount = new List<RTL_CustomerProductHoldingsService.CreditCardAccount>();
        creditAccountsType.CreditCardAccount.add(new RTL_CustomerProductHoldingsService.CreditCardAccount());
        //Loan Detail
        RTL_CustomerProductHoldingsService.LoanAccountsType loanAccountsType = new RTL_CustomerProductHoldingsService.LoanAccountsType();
        loanAccountsType.MuleInfo = muleInfo;
        item.LoanAccounts = loanAccountsType;
        loanAccountsType.LoanAccount = new List<RTL_CustomerProductHoldingsService.LoanAccount>();
        loanAccountsType.LoanAccount.add(new RTL_CustomerProductHoldingsService.LoanAccount());
        //Bancassurance Detail
        RTL_CustomerProductHoldingsService.BancassuranceAccountsType bancAccountsType = new RTL_CustomerProductHoldingsService.BancassuranceAccountsType();
        bancAccountsType.MuleInfo = muleInfo;
        item.BancassuranceAccounts = bancAccountsType;
        bancAccountsType.BancassuranceAccount = new List<RTL_CustomerProductHoldingsService.BancassuranceAccount>();
        bancAccountsType.BancassuranceAccount.add(new RTL_CustomerProductHoldingsService.BancassuranceAccount());
        //InvestAccount Detail
        RTL_CustomerProductHoldingsService.InvestmentAccountsType investAccountsType = new RTL_CustomerProductHoldingsService.InvestmentAccountsType();
        investAccountsType.muleInfo = muleInfo;
        item.InvestmentAccounts = investAccountsType;
		investAccountsType.investmentAccount = new List<RTL_CustomerProductHoldingsService.InvestmentAccount>();
        investAccountsType.investmentAccount.add(new RTL_CustomerProductHoldingsService.InvestmentAccount());
		TypeMapper.MappingSoapToDTO(item);
	}
	@istest
	private static void testOSC02() {
		RTL_DepositProductDetailsService.DepositProductDetails item = new RTL_DepositProductDetailsService.DepositProductDetails();
		RTL_DepositProductDetailsService.JointAccountInfoType item1 = new RTL_DepositProductDetailsService.JointAccountInfoType();

		item.JointAccount = item1;
        RTL_DepositProductDetailsService.JointAccountInfo item2 = new RTL_DepositProductDetailsService.JointAccountInfo();
        RTL_DepositProductDetailsService.JointAccountInfo[] item3 = new RTL_DepositProductDetailsService.JointAccountInfo[]{item2};
		item1.JointAccount = item3;
		TypeMapper.MappingSoapToDTO(item);
	}

	@istest
	private static void testOSC05() {
		RTL_BancPrdDetailsService.BancassuranceProductDetails item =
		new RTL_BancPrdDetailsService.BancassuranceProductDetails();


		RTL_BancPrdDetailsService.BancassuranceInformation l11 = new RTL_BancPrdDetailsService.BancassuranceInformation();
		RTL_BancPrdDetailsService.BancassuranceDetails l12 = new RTL_BancPrdDetailsService.BancassuranceDetails();
		RTL_BancPrdDetailsService.PaymentInformation l13 = new RTL_BancPrdDetailsService.PaymentInformation();
		RTL_BancPrdDetailsService.NextCashBackInformation l14 = new RTL_BancPrdDetailsService.NextCashBackInformation();


		RTL_BancPrdDetailsService.InsuredPropertyAsset l15 = new RTL_BancPrdDetailsService.InsuredPropertyAsset();

	}

	@istest
	private static void testOSC06() {
		RTL_InvestmentPrdDetailsService.InvestmentProductDetails item = new RTL_InvestmentPrdDetailsService.InvestmentProductDetails();
		RTL_InvestmentPrdDetailsService.InvestmentInformation item2 = new RTL_InvestmentPrdDetailsService.InvestmentInformation();
		item.InvestmentInformation = item2;
		RTL_InvestmentPrdDetailsService.InvestmentTransactionType item3 = new RTL_InvestmentPrdDetailsService.InvestmentTransactionType();
		item.InvestmentTransaction = item3;
		item3.InvestmentTransaction = new List<RTL_InvestmentPrdDetailsService.InvestmentTransaction> ();
		item3.InvestmentTransaction.add(new RTL_InvestmentPrdDetailsService.InvestmentTransaction());
		RTL_InvestmentPrdDetailsService.AutoInvestmentPlanType item4 = new RTL_InvestmentPrdDetailsService.AutoInvestmentPlanType();
		item.AutoInvestmentPlan = item4;
		item4.AutoInvestmentPlan = new List<RTL_InvestmentPrdDetailsService.AutoInvestmentPlan>();
		TypeMapper.MappingSoapToDTO(item);
	}
}