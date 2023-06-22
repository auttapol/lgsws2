global class InvestmentProductDTO implements Comparable{
	/*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   Data Transfer Objects
					 Investment Accounts: Multiple Blocks of Data Fields No. 33 - 41
	  Inputs:        None
	  Base Class:    -
	  Test Class:    -
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  ----------------------------------------------------------------------------------*/
	global string UnitHolderNo { get; set; }
	global string SubProductGroup { get; set; }
	global string ProductName { get; set; }
    global string SeqGrp {get;set;}
	global string AssetClass { get; set; }
	global string FundCode { get; set; }
	global string IssuerFundHouse { get; set; }
	global Date OpenedDate { get; set; }
	global Decimal Units { get; set; }
	global Decimal InitialValue { get; set; }
	global Decimal MarketValue { get; set; }
	global Decimal UnrealizedGL { get; set; }
    global Decimal NumberOfUnit { get; set; }
	global Decimal CostOfInvestment { get; set; }
	// SCR No. 2017-1-1804 for Average field Add on 18/10/2017
	global Decimal NavUnit { get; set; }
	global Decimal AverageCostPerUnit {
		get {
			if (NumberOfUnit == 0) {
				return 0;
			}
			return CostOfInvestment / NumberOfUnit;

		}
	}
	global Boolean UnitLtf5y { get; set; }
	// End SCR No. 2017-1-1804 for Average field Add on 18/10/2017
	global string Params {
		get {

			string p = UnitHolderNo + '&' + FundCode;
			return UrlHelper.encryptParams(p);

		}
	}
	global String convertedOpenedDate{
        get{
            return NumberHelper.DateFormat(OpenedDate);
        }
    }

	// Error Handler message
	global String SoapStatus { get; set; }
	global String SoapMessage { get; set; }

	//Retail CR Feb2018 - Release
	// -- Compare MF by Market Value(DSC) then Unit Holder No.(ASC) then Product Name (ASC)
	//Steam 1 CR Set2018
	// New compare Steam 1 by "Asset Class(ASC)" then "Market Value(DESC)" then "Unit Holder No.(ASC)" then "Product Name (ASC)"
    global Integer compareTo(Object compareTo) {
        InvestmentProductDTO compareToMF = (InvestmentProductDTO)compareTo;
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
		
		if(AssetClass == compareToMF.AssetClass ){

			if(MarketValue == compareToMF.MarketValue){
				
				if(UnitHolderNo == compareToMF.UnitHolderNo){

					// Product Name (ASC)
					if(ProductName > compareToMF.ProductName){
						// return 1;
						returnValue = 1;
					}else if(ProductName < compareToMF.ProductName){
						// return -1;
						returnValue = -1;
					}	
				}

				// Unit Holder No.(ASC)
				if(UnitHolderNo > compareToMF.UnitHolderNo){
					returnValue = 1;
				}else if(UnitHolderNo < compareToMF.UnitHolderNo){
					returnValue = -1;
				}
			}

			// Market Value(DESC)
			if (MarketValue < compareToMF.MarketValue) {
				// Set return value to a positive value.
				returnValue = 1;
			} else if (MarketValue > compareToMF.MarketValue) {
				// Set return value to a negative value.
				returnValue = -1;
			}
		}
		// Asset Class(ASC)
		if(AssetClass > compareToMF.AssetClass){
			returnValue = 1;
		}else if(AssetClass < compareToMF.AssetClass){
			returnValue = -1;
		}

		// Move #N/A be bottom
		if(AssetClass == '#N/A' && compareToMF.AssetClass != '#N/A'){
			returnValue = 1;
		}else if(AssetClass != '#N/A' && compareToMF.AssetClass == '#N/A') {
			returnValue = -1;
		}

		// Move Investment Record Not Found be bottom
		if(SoapStatus == 'ERROR' && compareToMF.SoapStatus != 'ERROR'){
			returnValue = 1;
		}else if(SoapStatus != 'ERROR' && compareToMF.SoapStatus == 'ERROR') {
			returnValue = -1;
		}


        return returnValue;       
    }

}