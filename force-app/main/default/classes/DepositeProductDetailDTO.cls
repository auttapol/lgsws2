global class DepositeProductDetailDTO {
	/*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   Data Transfer Objects
	  Inputs:        None	 
	  Test Class:    -
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  ----------------------------------------------------------------------------------*/
	global DepositeProductDetailDTO() {
		JoinAccountInformations = new List<JoinAccountInformationDTO> ();
		LastMonthTransactionSummary = new LastMonthTransactionSummaryDTO();
		BeneficiaryInformations = new List<BeneficiaryInformationDTO> ();
		StandingOrders = new List<StandingOrderDTO> ();
		DepositAccountNumber = '';
		NoActiveDebitCardBundling = 0;
	}
	global string DepositAccountNumber { get; set; } /* mulesoft field accountNumber   */
	global string DepositProductCode { get; set; } /* mulesoft field productCode     */
	global string SubProductGroup { get; set; }
	global string ProductName { get; set; }
	global Date OpenedDate { get; set; } /* mulesoft field openedDate      */
	global string Status { get; set; } /* mulesoft field status          */
	global decimal OutStanding { get; set; } /* mulesoft field outstanding     */
	//global decimal AvgOutStanding { get; set; }
	global decimal InterestEarned { get; set; } /* mulesoft field interestEarned     */
	global string Other { get; set; }
	global string HasJoint { get; set; } /* mulesoft field hasJoint     */
	global string AccountName { get; set; } /* mulesoft field accountName   */
	global decimal InterestRate { get; set; } /* mulesoft field interestRate   */
	global Date MaturityDate { get; set; } /* mulesoft field maturityDate   */
	global string SMSAlertService { get; set; }
	global string MEAccountBundledBank { get; set; } /* mulesoft field meAccountBundledBank   */
	global Decimal NoActiveDebitCardBundling { get; set; } /* mulesoft field numberOfActiveDebitCardBundling   */
	global Decimal AvgBalanceMTD { get; set; } /* mulesoft field avgBalanceMTD   */
	global Decimal ODLimit { get; set; } /* mulesoft field ODLimit     */
	global Decimal LedgerBalance { get; set; } /* mulesoft field Ledger     */
    
    global Boolean isEmployee {get;set;}

	// Error Handler message
	global String reqId {get;set;}
	global String SoapStatus { get; set; }
	global String SoapMessage { get; set; }

	// Ralate List
	global List<JoinAccountInformationDTO> JoinAccountInformations { get; set; }
	global LastMonthTransactionSummaryDTO LastMonthTransactionSummary { get; set; }
	global List<BeneficiaryInformationDTO> BeneficiaryInformations { get; set; }
	global List<StandingOrderDTO> StandingOrders { get; set; }
	global string MarkedDepositAccountNumber {
		get {
			return NumberHelper.MarkAccountNo(NumberHelper.TrimDepositAccountNo(DepositAccountNumber));

		}
	}
	global string MarkedOutStanding {
		get {
            if(isEmployeePayroll == true) return 'xxx';
			return NumberHelper.MarkDecimal(OutStanding);

		}
	}
	global string MarkedAvgBalanceMTD {
		get {
            if(isEmployeePayroll == true) return 'xxx';
			return NumberHelper.MarkDecimal(AvgBalanceMTD);

		}
	}
    
    global boolean isEmployeePayroll{
        get{
            if(isEmployee == true && Outstanding == 0 && AvgBalanceMTD == 0) return true;
        	return false;
        }
    }
    
    global String convertedOpenedDate{
        get{
            return NumberHelper.DateFormat(OpenedDate);
        }
    }
    
    global String convertedMaturityDate{
        get{
            return NumberHelper.DateFormat(MaturityDate);
        }
    }
	global Decimal MarkedODLimit {
		get {
			return ODLimit == null ? 0 : ODLimit;
		}
	}
	global string MarkedLedgerBalance {
		get {
			Decimal tmpValue = LedgerBalance == null ? 0 : LedgerBalance;
            if(isEmployeePayroll == true) return 'xxx';
			return NumberHelper.MarkDecimal(tmpValue);
		}
	}
}