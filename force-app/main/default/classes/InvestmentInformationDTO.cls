global class InvestmentInformationDTO {
	// Error Handler message
	global String SoapStatus { get; set; }
	global String SoapMessage { get; set; }


	global String ProductName { get; set; } // Product Name
	global String ProductType { get; set; } // Product_Sub_group__c
	global String AssetType { get; set; }   // Asset_Class__c
	global String FundType { get; set; }
	global String IssuerFundHouse { get; set; } // Issuer_Fund_House__c

	 
	global String UnitHolderNo { get; set; }
	global String FundCode { get; set; }
	global Decimal NumberOfUnit { get; set; }
	global Decimal CostOfInvestment { get; set; }
	global Decimal MarketValue { get; set; }
	global Decimal UnrealizedGL { get; set; }
	global Decimal NAVUnit { get; set; }
    global String AipInstruction {get;set;}
	//Note AvgCostUnit ?????????

	public InvestmentInformationDTO()
	{
		NumberOfUnit =
		CostOfInvestment =
		MarketValue =
		UnrealizedGL =
		NAVUnit = 0;
	}

	public Decimal AvgCostUnit {
		get {
			if (NumberOfUnit == 0) {
				return 0;
			}
			return CostOfInvestment / NumberOfUnit;

		}
	}

}