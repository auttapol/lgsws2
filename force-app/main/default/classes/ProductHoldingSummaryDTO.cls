public class ProductHoldingSummaryDTO {
	/*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   Data Transfer Objects
	  Inputs:        None
	  Test Class:    -
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  ----------------------------------------------------------------------------------*/

	public Map<String, String> ProductNames = new Map<String, String> ();
    public Map<String, String> ProductCodes = new Map<String, String> ();
	public Map<String, String> Accounts = new Map<String, String> ();
	// public Decimal ODBalance = 0;
	public Decimal Outstanding = 0;
	public Decimal VLimit = 0;
    public Boolean isEmployee = false; /*use this on vf*/
	/*public ProductHoldingSummaryDTO() {
	  Outstanding = 0;
	  VLimit = 0;
	  }*/
	public ProductHoldingSummaryDTO(string productSubGroup) {
		Outstanding = 0;
		VLimit = 0;
		ProductSubGroup = productSubGroup;
	}
	public void AddItem(Object item) {

		integer lstinx = ProductNames.size();
		if (item instanceof DepositeProductDTO) { /* contain Outstanding*/
			DepositeProductDTO dto = (DepositeProductDTO) item;
            Outstanding += dto.getLedgerBalance;
			// OD Balance
			VLimit += dto.getODLimit;

            //if is transactional deposit & this customer is TMB's employee set to true
            if (dto.ProductName != '#N/A')
            {
                ProductNames.put(dto.ProductName, dto.ProductName);
                ProductCodes.put(dto.DepositProductCode,dto.DepositProductCode);
            }		
            else{
                ProductNames.put(dto.ProductName + lstinx, dto.ProductName + lstinx);
                ProductCodes.put(dto.DepositProductCode + lstinx, dto.DepositProductCode + lstinx);
            }
			
			Accounts.put(dto.DepositAccountNumber, dto.DepositAccountNumber);
		}
		else if (item instanceof CreditCardRDCProductDTO) { /* contain Limit and Outstanding*/
			CreditCardRDCProductDTO dto = (CreditCardRDCProductDTO) item;
			Outstanding += dto.OutStanding;
			VLimit += dto.VLimit;
            
            if(dto.isEmployee == true && dto.SeqGrp == '3')
            {
                isEmployee = true;
            }

            if (dto.ProductName != '#N/A')
            {
                ProductNames.put(dto.ProductName, dto.ProductName);
                ProductCodes.put(dto.CreditCardType,dto.CreditCardType);
            }
			
            else
            {
                ProductNames.put(dto.ProductName + lstinx, dto.ProductName + lstinx);
                ProductCodes.put(dto.CreditCardType + lstinx,dto.CreditCardType + lstinx);
            }

			Accounts.put(dto.CardNumber, dto.CardNumber);
		}
		else if (item instanceof LoanProductDTO) { /* contain Limit and Outstanding*/
			LoanProductDTO dto = (LoanProductDTO) item;
			Outstanding += dto.OutStanding;
			VLimit += dto.VLimit;

            if (dto.ProductName != '#N/A')
            {
                ProductNames.put(dto.ProductName, dto.ProductName);
                ProductCodes.put(dto.LoanProductCode,dto.LoanProductCode);
            }
			
            else
            {
                ProductNames.put(dto.ProductName + lstinx, dto.ProductName + lstinx);
                ProductCodes.put(dto.LoanProductCode + lstinx,dto.LoanProductCode + lstinx);
            }
			

			Accounts.put(dto.LoanAccountNumber, dto.LoanAccountNumber);
		}
		else if (item instanceof InvestmentProductDTO) {
			InvestmentProductDTO dto = (InvestmentProductDTO) item;
            Outstanding += dto.MarketValue;

            if (dto.ProductName != '#N/A')
            {
                ProductNames.put(dto.ProductName, dto.ProductName);
                ProductCodes.put(dto.FundCode,dto.FundCode);
            }
			
            else
            {
                ProductNames.put(dto.ProductName + lstinx, dto.ProductName + lstinx);
                ProductCodes.put(dto.FundCode + lstinx,dto.FundCode + lstinx);
            }
			
			Accounts.put(dto.UnitHolderNo, dto.UnitHolderNo);
		}

		else if (item instanceof BancassuranceDTO) {

			BancassuranceDTO dto = (BancassuranceDTO) item;
            //Outstanding += dto.SumInsure;
            if (dto.ProductName != '#N/A')
            {
                ProductNames.put(dto.ProductName, dto.ProductName);
                ProductCodes.put(dto.PolicyNo,dto.PolicyNo);
            }
            else
            {
                ProductNames.put(dto.ProductName + lstinx, dto.ProductName + lstinx);
                ProductCodes.put(dto.PolicyNo + lstinx,dto.PolicyNo + lstinx);
            }
			
			Accounts.put(dto.PolicyNo, dto.PolicyNo);

		}
	}
	// PK Label
	public String ProductSubGroup { get; set; }
	public integer NoOfProduct {
		get {
			return ProductCodes.size();
		}
	}
	public integer NoOfAccount {
		get {
			return Accounts.size();
		}
	}
	public Decimal GetLimit {
		get { return VLimit;
		}
	}
	public string GetMakedOutstanding {
		get {
			return NumberHelper.MarkDecimal(GetOutstanding);
		}
	}
	public Decimal GetOutstanding {
		get {
			return Outstanding;
		}
	}
    
    public Boolean GetIsEmployee {
		get {
			return isEmployee;
		}
	}
    
}