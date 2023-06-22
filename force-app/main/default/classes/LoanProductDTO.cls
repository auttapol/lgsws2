global class LoanProductDTO {
	/*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   Data Transfer Objects
	  Inputs:        None
	  Test Class:    -
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  ----------------------------------------------------------------------------------*/
	global string LoanAccountNumber { get; set; }
	global string LoanProductCode { get; set; }
	global string ProductType { get; set; }
    global string Fiident {get; set; } /*CR for Tenor Month*/

	global string SubProductGroup { get; set; }
	global string ProductName { get; set; }
    global string ProjectCode {get;set;}
    global string DataSource {get;set;}
	global string SeqGrp {get;set;}

	global Date OpenedDate { get; set; }
	global string Status { get; set; }
	global Decimal Outstanding { get; set; }
	global Decimal VLimit { get; set; } /* Limit is reserv word */
	global Date MuturityDate { get; set; }
	global string HasCoBorrower { get; set; }
	global string MarkedLoanAccountNumber {
		get {
			return NumberHelper.MarkAccountNo(NumberHelper.TrimLoanAccountNo(LoanAccountNumber));
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

			string p = LoanAccountNumber + '&' + ProductType+'&'+Fiident+'&'+Status+'&'+ProjectCode+'&'+DataSource;
			return UrlHelper.encryptParams(p);

		}
	}
    
    global String convertedMaturityDate{
        get{
            //return NumberHelper.convertDateADtoBE(MuturityDate);
            return NumberHelper.DateFormat(MuturityDate);
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