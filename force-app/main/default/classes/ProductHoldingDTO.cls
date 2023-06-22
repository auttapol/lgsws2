global class ProductHoldingDTO {
	/*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   Data Transfer Objects
	  Inputs:        None
	  Test Class:    -
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  ----------------------------------------------------------------------------------*/
	global List<BancassuranceDTO> Bancassurances { get; set; }
    global String BASoapStatus {get;set;}
    global String BASoapMessage {get;set;}
	global List<CreditCardRDCProductDTO> CreditCardRDCProducts { get; set; }
    global String cardSoapStatus {get;set;}
    global String cardSoapMessage {get;set;}
	global List<DepositeProductDTO> DepositeProducts { get; set; }
    global String depSoapStatus {get;set;}
    global String depSoapMessage {get;set;}
	global List<InvestmentProductDTO> InvestmentProducts { get; set; }
    global String investmentSoapStatus {get;set;}
    global String investmentSoapMessage {get;set;}
	global List<LoanProductDTO> LoanProducts { get; set; }
    global String loanSoapStatus {get;set;}
    global String loanSoapMessage {get;set;}
	// Error Handler message
    global String reqId {get;set;}
	global String SoapStatus { get; set; }
	global String SoapMessage { get; set; }



	global ProductHoldingDTO() {
		Bancassurances = new List<BancassuranceDTO> ();
		CreditCardRDCProducts = new List<CreditCardRDCProductDTO> ();
		DepositeProducts = new List<DepositeProductDTO> ();
		LoanProducts = new List<LoanProductDTO> ();
		InvestmentProducts = new List<InvestmentProductDTO> ();
	}
}