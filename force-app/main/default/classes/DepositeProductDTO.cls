global virtual class DepositeProductDTO {
	/*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   Data Transfer Objects
	  Inputs:        None
	  Test Class:    -
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  ----------------------------------------------------------------------------------*/
	global string DepositAccountNumber { get; set; } /* mulesoft field accountNumber   */
	//Update from JY  2016-05-11
	global string ProductType { get; set; }
    global Boolean isEmployee {get;set;} /*get this value from salesforce*/
    global string RMID {get;set;}/*get this value from service 1, 2nd drop*/
    global string Fiident {get;set;} /*CR for Tenor Month*/

	global string DepositProductCode { get; set; } /* mulesoft field productCode     */
	global string SubProductGroup { get; set; }
	global string ProductName { get; set; }
    global string ProjectCode {get;set;}
    global string DataSource {get;set;}
    global string SeqGrp {get;set;}
    
	global Date OpenedDate { get; set; } /* mulesoft field openedDate      */
	global string Status { get; set; } /* mulesoft field status          */
	// OutStanding = Available balance
	global decimal OutStanding { get; set; } /* mulesoft field outstanding     */
	global decimal AvgOutStanding { get; set; }
	global decimal IntEarning { get; set; } /* mulesoft field interestEarned     */
	global string Other { get; set; }
	global string HasJoint { get; set; } /* mulesoft field hasJoint     */
	global Decimal ODLimit { get; set; } /* mulesoft field ODLimit     */
	global Decimal LedgerBalance { get; set; } /* mulesoft field Ledger     */

	public DepositeProductDTO() {
		//OutStanding = AvgOutStanding = IntEarning = 0;
		IntEarning = 0;
	}

	global string MarkedDepositAccountNumber {
		get {
			return NumberHelper.MarkAccountNo(NumberHelper.TrimDepositAccountNo(DepositAccountNumber));

		}
	}
	global string MarkedOutStanding {
		get {
			if (OutStanding == 0 && isEmployee == false) return '-';
            else if(isEmployeePayroll()) return 'xxx';
			return NumberHelper.MarkDecimal(OutStanding);

		}
	}
	global string MarkedAvgOutStanding {
		get {
			if (AvgOutStanding == 0 && isEmployee == false) return '-';
            else if(isEmployeePayroll()) return 'xxx';
			return NumberHelper.MarkDecimal(AvgOutStanding);

		}
	}
	global string MarkedLedgerBalance {
		get {
			Decimal tmpValue = LedgerBalance == null ? 0 : LedgerBalance;
			if (tmpValue == 0 && isEmployee == false) return '-';
            else if(isEmployeePayroll()) return 'xxx';
			return NumberHelper.MarkDecimal(tmpValue);
		}
	}
	global decimal getODLimit {
		get {
			Decimal tmpValue = ODLimit == null ? 0 : ODLimit;
			return tmpValue;
		}
	}
	global decimal getLedgerBalance {
		get {
			Decimal tmpValue = LedgerBalance == null ? 0 : LedgerBalance;
			return tmpValue;
		}
	}

	global string Params {
		get {
			//string p = DepositAccountNumber + '&' + ProductType+'&'+isEmployee+'&'+ProjectCode+'&'+DataSource;
			//2 nd drop
			string p = DepositAccountNumber + '&' + ProductType+'&'+RMID+'&'+isEmployee+'&'+Fiident+'&'+ProjectCode+'&'+DataSource;
			return UrlHelper.encryptParams(p);

		}
	}
    
    global boolean isEmployeePayroll(){
        if(OutStanding == 0 && AvgOutStanding == 0 && isEmployee == true) return true;
        return false;
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