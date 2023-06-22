global class CreditCardRDCProductDTO {
	/*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   Data Transfer Objects
	  Inputs:        None
	  Test Class:    -
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  ----------------------------------------------------------------------------------*/
	global string CardNumber { get; set; }
	global string CreditCardType { get; set; } /**It is used to derive the Product Name and Product Type (Sub Group) from Product Hierarchy.*/
	global string SubProductGroup { get; set; }
	global string ProductName { get; set; }
    global string SeqGrp {get;set;}
    global Boolean isEmployee {get;set;} /*get this value from salesforce*/
	global Date OpenedDate { get; set; }
	global string Status { get; set; }
	global decimal Outstanding { get; set; }
	global decimal VLimit { get; set; } /* Limit is reserv word >> Credit Limit*/
	public CreditCardRDCProductDTO() {
		Outstanding = VLimit = 0;
	}

	global string MarkedCardNumber {
		get {
			return NumberHelper.MarkCardNo(NumberHelper.TrimCardNo(CardNumber));

		}
	}

	global string MarkedOutstanding {
		get {
		    if (Outstanding == 0) return '-';
			return NumberHelper.MarkDecimal(Outstanding);

		}
	}

	global string MarkedVLimit {
		get {

			if (VLimit == 0) return '-';
			return NumberHelper.MarkDecimal(VLimit);

		}
	}
	global string Params {
		get {

			string p = CardNumber + '&' + CreditCardType + '&' +isEmployee;
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



}